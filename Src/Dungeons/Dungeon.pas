unit Dungeon;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Windows, SysUtils, MOB, MiscData, PartyData, Classes, BaseMob, Math,
  System.Threading;
{$OLDTYPELAYOUT ON}
{$REGION 'Dungeon Thread'}

type
  TDungeonMainThread = class(TThread)
  private
    FDelay: word;
    ChannelId: byte;
    InstanceID: byte;
    SelfParty: PParty;
    StartTime, CurrentTime: Uint64;
    Aviso15min, Aviso30min, Aviso60min, Finalizando: boolean;
    // fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
    procedure Contagem;
    procedure EndDungeon;
    procedure MobHandler;
  public
    constructor Create(SleepTime: word; ChannelId: byte; InstanceID: byte);
  end;
{$ENDREGION}
{$REGION 'Dungeons Data'}

type
  TDungeonMobDrop = packed record
    SemCoroa: Array [0 .. 41] of WORD; // 12 {1=ursula normal}{2=coroacinza}
    CoroaPrata: Array [0 .. 41] of WORD;
    CoroaDourada: Array [0 .. 41] of WORD;
  end;

type
  TDungeonMobDropData = packed record
    Drops: Array [0 .. 41] of WORD;
  end;

type
  TDungeon = record
    Index: BYTE;
    Dificult: BYTE;
    LevelMin: BYTE;
    EntranceNPCID: WORD;
    EntrancePosition: TPosition; // pra calcular se todos os players estão lá
    SpawnInDungeonPosition: TPosition; // posição que vai spawnar la dentro
    MOBS: TMobDungeonStruct; // até 45 tipos de mobs diferentes
    MobsDrop: TDungeonMobDrop;
    // NPCS: Array [2600 .. 2609] of TNpc; // até 10 npcs dentro da dg
  end;

type
  PMobsStructDungeonInstance = ^TMobsStructDungeonInstance;

  TMobsStructDungeonInstance = packed record
    IntName: WORD;
    Equip: Array [0 .. 12] of WORD; // mob equips [face, weapon]
    Base: TBaseMob;
    MaxHP, CurrentHP: DWORD;
    Position: TPosition;
    MobLevel: BYTE;
    MobExp: DWORD;
    MobType: WORD;
    MobElevation, Cabeca, Perna: BYTE; // mob "altura"
    FisAtk, MagAtk, FisDef, MagDef: WORD; // mob attributes

    DeadTime: TDateTime;
    LastMoviment: TDateTime;
    MovedTo: TypeMobLocation;
    MovimentsTime: BYTE;

    XPositionDif: WORD;
    YPositionDif: WORD;
    XPositionsToMove: WORD;
    YPositionsToMove: WORD;

    IsAttacked: boolean;
    AttackerID: WORD;
    FirstPlayerAttacker: WORD;

    LastMyAttack: TDateTime;
    OrigPos: TPosition;

    NeighborIndex: Integer;

  public
    procedure AttackPlayer(DanoInicial: Integer; ChannelIndex: BYTE;
      ClientID: BYTE);
    procedure MobMove(Position: TPosition; DungeonInstance: BYTE;
      Speed: BYTE = 25; MoveType: BYTE = 0);
  end;

type
  PDungeonInstance = ^TDungeonInstance;

  TDungeonInstance = record
    Index: WORD;
    Party: PParty; // pointer da party que está entrando
    CreateTime: TDateTime;
    DungeonID: BYTE;
    Dificult: BYTE;
    MOBS: Array [1 .. 450] of TMobsStructDungeonInstance;
    MobsDrop: Array [1 .. 450] of TDungeonMobDropData;
    MainThread: TDungeonMainThread;
    InstanceOnline: boolean;
  end;

{$ENDREGION}
{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, Packets, Log, DateUtils, PlayerData, Player, ItemFunctions;

{$REGION 'Mob Dungeon Functions'}

procedure TMobsStructDungeonInstance.AttackPlayer(DanoInicial: Integer;
  ChannelIndex: BYTE; ClientID: BYTE);
var
  Packet: TRecvDamagePacket;
  dnType: TDamageType;
  SkillIDa, Dano, DamageReduction: Integer;
  AddBuff: boolean;
  Deftarget: Integer;
  xPlayer: PPlayer;
  Multiplicador, divisorDefesa, AttackResultType: Integer;
begin

  try
    if Self.AttackerID = 0 then
      Exit;

    if Self.Base.IsDead then
      Exit;

    SkillIDa := 0;
    ZeroMemory(@Packet, sizeof(Packet));

    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := Self.Base.ClientID;
    Packet.Header.Code := $102;
    Packet.SkillID := SkillIDa;
    Packet.AttackerPos := Self.Position;
    Packet.AttackerID := Self.Base.ClientID;
    Packet.Animation := 06;
    Packet.AttackerHP := Self.CurrentHP;
    Packet.TargetID := Self.AttackerID;
    Packet.MobAnimation := 26;

    xPlayer := @Servers[Self.Base.ChannelId].Players[Self.AttackerID];

    if xPlayer^.Base.IsDead then
      Exit;

    if xPlayer^.Base.GetMobAbility(EF_IMMUNITY) > 0 then
    begin
      dnType := TDamageType.Immune;
      Packet.dnType := dnType;
      xPlayer^.Base.LastReceivedAttack := Now;
      Packet.MobCurrHP := xPlayer^.Base.PlayerCharacter.Base.CurrentScore.CurHP;
      xPlayer^.Base.SendToVisible(Packet, Packet.Header.size, True);
      Exit;
    end
    else if xPlayer^.Base.BuffExistsByIndex(19) then
    begin
      xPlayer^.Base.RemoveBuffByIndex(19);
      dnType := TDamageType.Block;
      Packet.dnType := dnType;
      xPlayer^.Base.LastReceivedAttack := Now;
      Packet.MobCurrHP := xPlayer^.Base.PlayerCharacter.Base.CurrentScore.CurHP;
      xPlayer^.Base.SendToVisible(Packet, Packet.Header.size, True);
      Exit;
    end
    else if xPlayer^.Base.BuffExistsByIndex(91) then
    begin
      xPlayer^.Base.RemoveBuffByIndex(91);
      dnType := TDamageType.Miss2;
      Packet.dnType := dnType;
      xPlayer^.Base.LastReceivedAttack := Now;
      Packet.MobCurrHP := xPlayer^.Base.PlayerCharacter.Base.CurrentScore.CurHP;
      xPlayer^.Base.SendToVisible(Packet, Packet.Header.size, True);
      Exit;
    end;

    Deftarget := xPlayer^.Base.PlayerCharacter.Base.CurrentScore.DefFis;

    case xPlayer^.DungeonLobbyDificult of
      0 .. 3: // Dificuldades de 0 a 3
        begin
          Multiplicador := xPlayer^.DungeonLobbyDificult + 1;
          divisorDefesa := xPlayer^.DungeonLobbyIndex + 2;

          case xPlayer^.DungeonLobbyIndex of
            1:
              Dano := ((DanoInicial + (25 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
            2:
              Dano := ((DanoInicial + (50 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
            3:
              Dano := ((DanoInicial + (75 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
            4:
              Dano := ((DanoInicial + (100 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
            5:
              Dano := ((DanoInicial + (125 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
            6:
              Dano := ((DanoInicial + (150 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
            7:
              Dano := ((DanoInicial + (175 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
            8:
              Dano := ((DanoInicial + (200 * Multiplicador)) div 2) -
                (Deftarget div divisorDefesa);
          end;
        end;
    end;

    DamageReduction := (Dano div 100) *
      (xPlayer^.Base.GetEquipedItensDamageReduce div 10);
    Dec(Dano, DamageReduction);
    Inc(Dano, (RandomRange(10, 39) + 7));

    AttackResultType := RandomRange(1, 101);
    case AttackResultType of
      2 .. 15:
        dnType := TDamageType.Miss;
      16 .. 30:
        dnType := TDamageType.Critical;
      31 .. 100:
        dnType := TDamageType.Normal;
    else
      dnType := TDamageType.Normal;
    end;

    if (SecondsBetween(Now, xPlayer^.Base.RevivedTime) <= 7) then
      Exit;

    Self.Base.AttackParseForMobs(0, 0, @xPlayer.Base, Dano, dnType, AddBuff,
      Packet.MobAnimation);

    Packet.dnType := dnType;
    Packet.Dano := Dano;
    xPlayer^.Base.LastReceivedAttack := Now;

    try
      if Self.AttackerID = 0 then
        Exit;

      if (Packet.Dano >= xPlayer^.Base.Character.CurrentScore.CurHP) and
        not(xPlayer^.Base.IsDead) then
      begin

        xPlayer^.Base.Character.CurrentScore.CurHP := 0;
        xPlayer^.Base.IsDead := True;
        xPlayer^.Base.SendEffect($0);
        Packet.MobAnimation := 30;
        xPlayer^.Base.SendToVisible(Packet, Packet.Header.size, True);

        if (xPlayer^.Party.Index > 0) then
        begin
          if (xPlayer^.Party.Members.Count = 1) then
          begin
            xPlayer^.TavaEmDG := True;
            Exit;
          end
          else
          begin
            xPlayer^.EquipeEmDg := True;
          end;
        end;
        xPlayer^.Base.SendEffect($0);
        Packet.MobAnimation := 30;

        Self.IsAttacked := FALSE;
        Self.LastMoviment := Now;
        Self.MovimentsTime := 0;
        Self.MovedTo := Init;
      end
      else
      begin
        if xPlayer^.Base.IsDead then
          Exit;

        xPlayer^.Base.Character.CurrentScore.CurHP :=
          (xPlayer^.Base.Character.CurrentScore.CurHP - Packet.Dano);
      end;

      xPlayer^.Base.LastReceivedAttack := Now;

      Packet.MobCurrHP := xPlayer^.Base.Character.CurrentScore.CurHP;

      xPlayer^.Base.SendToVisible(Packet, Packet.Header.size, True);
    except
      on E: Exception do
        Logger.Write('Error at mob Attack Player: ' + DateTimeToStr(Now),
          TlogType.Error);
    end;

  except
    on E: Exception do
      Logger.Write('Error at mob Attack Player: ' + DateTimeToStr(Now),
        TlogType.Error);
  end;
end;

procedure TMobsStructDungeonInstance.MobMove(Position: TPosition;
  DungeonInstance: BYTE; Speed: BYTE; MoveType: BYTE);
var
  Packet: TMobMovimentPacket;
  i: Integer;
  xPlayer: PPlayer;
begin
  ZeroMemory(@Packet, sizeof(TMobMovimentPacket));

  Packet.Header.size := sizeof(TMobMovimentPacket);
  Packet.Header.Index := Self.Base.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Position;
  Packet.MoveType := MoveType; // 00 andando 01 teleportando

  // Atribui o valor de Packet.Speed diretamente
  if (Speed = 25) then
    Packet.Speed := 25
  else
    Packet.Speed := Speed;

  Self.Base.PlayerCharacter.LastPos := Position;

  // A otimização ocorre aqui, evitando acessar "Self.Base.VisibleMobs" repetidamente
  for i in Self.Base.VisibleMobs do
  begin
    if (i <= MAX_CONNECTIONS) then
    begin
      xPlayer := @Servers[Self.Base.ChannelId].Players[i];
      // Verifica o status do jogador diretamente
      if (xPlayer.Status <> Playing) then
        continue;

      xPlayer.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

{$ENDREGION}

constructor TDungeonMainThread.Create(SleepTime: word; ChannelId: byte;
  InstanceID: byte);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.InstanceID := InstanceID;
  Self.FreeOnTerminate := True;
  SelfParty := DungeonInstances[Self.InstanceID].Party;
  StartTime := GetTickCount64;

  inherited Create(FALSE);
  Self.Priority := tpLower;
end;

procedure TDungeonMainThread.EndDungeon;
begin
  DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].InstanceOnline := FALSE;
  DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].Index := 0;
  DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].CreateTime := Now;
  DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].Party := nil;
  DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].DungeonID := 0;
  DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].Dificult := 0;
  ZeroMemory(@DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].MOBS,
  sizeof(DungeonInstances[Servers[Self.ChannelId].Players[SelfParty.Leader].DungeonInstanceID].MOBS));
end;

procedure TDungeonMainThread.Contagem;
var
  j: BYTE;
  xPlayer: PPlayer;
  CurrentTime: Int64;
begin

  CurrentTime := GetTickCount64() - StartTime;

  if (CurrentTime >= (15 * 60 * 1000)) and not Aviso15min and not Aviso30min and
    not Finalizando and
    (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players
    [SelfParty.Leader], 221, INV_TYPE, 0) = 255) then
  begin
    Aviso15min := True;
    for j in SelfParty.Members.ToArray do
    begin
      xPlayer := @Servers[Self.ChannelId].Players[j];
      xPlayer.SendClientMessage('15 minutos se passaram na dungeon!');
    end;
  end;

  if (CurrentTime >= (28 * 60 * 1000)) and Aviso15min and not Aviso30min and
    not Finalizando and
    (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players
    [SelfParty.Leader], 221, INV_TYPE, 0) = 255) then
  begin
    Aviso30min := True;
    for j in SelfParty.Members.ToArray do
    begin
      xPlayer := @Servers[Self.ChannelId].Players[j];
      xPlayer.SendClientMessage('Faltam 2 minutos para a dungeon ser finalizada');
    end;
  end;

  if (CurrentTime >= (29 * 60 * 1000)) and Aviso15min and Aviso30min and
    not Finalizando and
    (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players
    [SelfParty.Leader], 221, INV_TYPE, 0) = 255) then
  begin
    Finalizando := True;
    for j in SelfParty.Members.ToArray do
    begin
      xPlayer := @Servers[Self.ChannelId].Players[j];
      xPlayer.SendClientMessage('Dungeon sendo finalizada!');
    end;

    TTask.Run(
      procedure
      var
        j: Integer;
      begin
        Sleep(60000);
        Self.EndDungeon;

        for j in SelfParty.Members.ToArray do
        begin
          xPlayer := @Servers[Self.ChannelId].Players[j];
          xPlayer.SendClientMessage
            ('Dungeon finalizada, todos os membros foram removidos do calabouço!');
          xPlayer.UnsetDungeon();
        end;
        Self.Destroy;
      end);
  end;

  if (CurrentTime >= (60 * 60 * 1000)) and not Finalizando then
  begin
    Finalizando := True;
    TTask.Run(
      procedure
      var
        j: Integer;
      begin
        Sleep(60000);
        Self.EndDungeon;

        for j in SelfParty.Members.ToArray do
        begin
          xPlayer := @Servers[Self.ChannelId].Players[j];
          xPlayer.SendClientMessage('Dungeon finalizada, todos os membros foram removidos do calabouço!');
          xPlayer.UnsetDungeon();
        end;
        Self.Destroy;
      end);
  end;
end;

procedure TDungeonMainThread.MobHandler;
var
  i: WORD;
  UpdatedBuffs, Rand, j: BYTE;
  xPlayer: PPlayer;
  MOB: PMobsStructDungeonInstance;
  xMember: PPlayer;
  CurrentTime: TDateTime;
  DistanceToPlayer: BYTE;
begin
{$REGION 'Mob Handler dungeon'}
  CurrentTime := Now;
  // Armazena o tempo atual para evitar múltiplas chamadas a Now

  for i := Low(DungeonInstances[Self.InstanceID].MOBS)
    to High(DungeonInstances[Self.InstanceID].MOBS) do
  begin
    MOB := @DungeonInstances[Self.InstanceID].MOBS[i];
    if (MOB^.AttackerID = 0) or (MOB^.Base.ClientID = 0) or MOB^.Base.IsDead
    then
      continue;

    xPlayer := @Servers[Self.ChannelId].Players[MOB^.AttackerID];

{$REGION 'Buffs'}
    UpdatedBuffs := MOB^.Base.RefreshBuffs;
    if UpdatedBuffs > 0 then
      MOB^.Base.SendRefreshBuffs;
{$ENDREGION}
{$REGION 'Attack'}
    if MOB^.IsAttacked then
    begin
      DistanceToPlayer := MOB^.Position.Distance(xPlayer^.Base.PlayerCharacter.LastPos);
      if MOB^.Position.InRange(xPlayer^.Base.PlayerCharacter.LastPos, 5) then
      begin
        if SecondsBetween(CurrentTime, MOB^.LastMyAttack) >= 2 then
        begin
          if not xPlayer^.Base.IsDead and not xPlayer^.Base.BuffExistsByIndex
            (77) and not xPlayer^.Base.BuffExistsByIndex(53) and
            not xPlayer^.Base.BuffExistsByIndex(153) and
            not xPlayer^.Base.BuffExistsByIndex(386) and
            (MOB^.Base.GetDebuffCount = 0) then
          begin
            MOB^.LastMyAttack := CurrentTime;
            MOB^.AttackPlayer(MOB^.FisAtk, Self.ChannelId,
              xPlayer^.Base.ClientID);
            xPlayer^.Base.LastReceivedAttack := CurrentTime;
          end;
        end;
      end
      else
      begin
        Randomize;
        Rand := Random(7);
        MOB^.Position := xPlayer^.Base.Neighbors[Rand].pos;
        if not xPlayer^.Base.BuffExistsByIndex(77) and
          not xPlayer^.Base.BuffExistsByIndex(53) and
          not xPlayer^.Base.BuffExistsByIndex(153) and
          not xPlayer^.Base.BuffExistsByIndex(386) then
          MOB^.MobMove(MOB^.Position, Self.InstanceID, 35)
        else
        begin
          MOB^.Position := MOB^.OrigPos;
          MOB^.MobMove(MOB^.Position, Self.InstanceID, 35);
          MOB^.CurrentHP := MOB^.MaxHP;
          MOB^.AttackerID := 0;
          MOB^.IsAttacked := FALSE;
        end;
      end;

      if not MOB^.Position.InRange(MOB^.OrigPos, 20) then
      begin
        MOB^.Position := MOB^.OrigPos;
        MOB^.MobMove(MOB^.Position, Self.InstanceID, 35);
        MOB^.CurrentHP := MOB^.MaxHP;
        MOB^.AttackerID := 0;
        MOB^.IsAttacked := FALSE;
      end;
    end
    else
    begin
      for j in DungeonInstances[Self.InstanceID].Party.Members.ToArray do
      begin
        xMember := @Servers[Self.ChannelId].Players[j];
        if xMember^.Base.PlayerCharacter.LastPos.InRange(MOB^.Position, 15) then
        begin
          MOB^.OrigPos := MOB^.Position;
          MOB^.IsAttacked := True;
          MOB^.AttackerID := xMember^.Base.ClientID;
          MOB^.LastMyAttack := CurrentTime;
          MOB^.CurrentHP := MOB^.MaxHP;
          Break;
        end;
      end;
    end;
{$ENDREGION}
  end;
{$ENDREGION}
end;

procedure TDungeonMainThread.Execute;
var
  xMember: PPlayer;
  j: BYTE;
begin

  while (DungeonInstances[Self.InstanceID].InstanceOnline) or
    (SelfParty.Members.Count > 0) do
  begin

    Self.Contagem;

    Self.MobHandler;

    TThread.Yield;
    TThread.Sleep(FDelay);
  end;

  if SelfParty.Members.Count = 0 then
  begin
    Self.EndDungeon;

    for j in SelfParty.Members.ToArray do
    begin
      xMember := @Servers[Self.ChannelId].Players[j];
      xMember^.SendClientMessage
        ('Dungeon finalizada, todos os membros foram removidos do calabouço!');
      xMember^.UnsetDungeon();
    end;
    Self.Destroy;
  end;

end;



end.
