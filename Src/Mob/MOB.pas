unit MOB;

{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}

interface



// Ativa otimização de loops
uses
  Windows, SysUtils, MiscData, BaseMob, Packets, Classes, Math, System.SyncObjs;
{$OLDTYPELAYOUT OFF}
{$REGION 'Mob Threads'}

type
  TMobSpawnThread1 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;

type
  TMobHandlerThread1 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;

type
  TMobMovimentThread1 = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    MobID: Integer;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE; MobID: Integer);
    destructor Destroy; override;
  end;

{$ENDREGION}
{$REGION 'Mob Data'}

type
  PMobSPoisition = ^TMobSPosition;

  TMobSPosition = record // dinamic informations
    Index: WORD; // static index for a packet render generation on client
    HP, MP: DWORD; // health, mana
    InitPos: TPosition; // initial position [X,Y]
    DestPos: TPosition; // destine position [X,Y]
    CurrentPos: TPosition; // current position [X,Y] change by moviment thread
    FirstDestPos: TPosition;
    InitAttackRange: WORD;
    // range for follow the player to attack him [on init]
    DestAttackRange: BYTE;
    // range for follow the player to attack him [on dest]
    InitMoveWait: WORD; // wait to move to destine position [Thread use]
    DestMoveWait: WORD; // wait to move to initial position [Thread use]
    Base: TBaseMob;
    DeadTime: TDateTime;
    LastMoviment: TDateTime;
    MovedTo: TypeMobLocation;
    MovimentsTime: BYTE;
    XPositionDif: WORD;
    YPositionDif: WORD;
    XPositionsToMove: WORD;
    YPositionsToMove: WORD;
    IsAttacked: Boolean;
    AttackerID: BYTE;
    LastAttackerID: BYTE;
    FirstPlayerAttacker: BYTE;
    LastMyAttack: TDateTime;
    LastSkillAttack: TDateTime;
    NeighborIndex: smallint;
    isNormalBoss: Boolean;
    isFinalBoss: Boolean;
    isGuard: Boolean;
    isMutant: Boolean;
    isTemp: Boolean;
    GeneratedAt: TDateTime;
    LastSkillUsedByMob: TDateTime;
    ActualUsingSkill: WORD;
    AttackSamePlayerTimes: WORD;

    UpdatedMobSpawn, UpdatedMobHandler, UpdatedMobMoviment: TDateTime;
  public
    procedure SendMobDamage(PlayerID: WORD; MobID: DWORD; SkillID: DWORD;
      Anim: DWORD; out DnTypeA: BYTE);
    function GetMobDamage(PlayerID: WORD; Skill: DWORD;
      out DamageType: TDamageType): UInt64;
    function GetMobDamageType(PlayerID: WORD; Skill: DWORD; IsPhys: Boolean)
      : TDamageType;
    procedure MobHandler(ClientHandlerID: Integer = 0);
    procedure MobMoviment(ClientHandlerID: Integer = 0);
    procedure MobMove(Position: TPosition; Speed: BYTE = 25;
      MoveType: BYTE = 0);
    procedure AttackPlayer(SkillID: WORD = 0);
    function GetDamageByPlayer(Skill: DWORD;
      out DamageType: TDamageType): UInt64;
    function GetDamageTypePlayer(Skill: DWORD; IsPhys: Boolean): TDamageType;
    procedure UpdateSpawnToPlayers(mid, smid: Integer;
      ClientHandlerID: Integer = 0);
  end;

type // mob inventory class
  TMobInvent = packed record
    ItemID: WORD; // id
    Amount: WORD; // amount
  end;

type
  PMobSa = ^TMobSa;

  TMobSa = record // static informations
    IndexGeneric: WORD; // index file generated
    Name: Array [0 .. 63] of AnsiChar; // name of mob on main array
    IntName: WORD; // name for client read and show it
    Equip: Array [0 .. 12] of WORD; // mob equips [face, weapon]
    MobsP: Array [0 .. 49] of TMobSPosition; // all 50 mobs positions
    MobElevation, Cabeca, Perna: BYTE; // mob "altura"
    FisAtk, MagAtk, FisDef, MagDef: DWORD; // mob attributes
    MoveSpeed: BYTE; // mob speed move
    MobExp: DWORD; // mob exp give for player
    MobLevel: WORD; // for a name collor on client
    InitHP: DWORD;
    Rotation: DWORD;
    MobType: WORD;
    IsService: WordBool;
    SpawnType: BYTE;
    cntControl: WORD;
    ReespawnTime: WORD;
    Skill01, Skill02, Skill03, Skill04, Skill05: WORD;
    DropIndex: WORD;
    IsActiveToSpawn: Boolean;
    DungeonDropIndex: WORD;
  end;

type
  TMobStruct = packed record
    TMobS: Array [0 .. 999] of TMobSa;
    // até 389 tipos de mobs diferentes em lakia
  end;

type
  TMobDungeonStruct = packed record
    TMobS: Array [0 .. 44] of TMobSa;
    // até 45 tipos de mobs diferentes por dungeon
  end;

type
  TMobFuncs = class(TObject)
    class function GetMobGeralID(Channel: BYTE; ID: WORD;
      out MobPosID: WORD): Integer;
    class function GetMobDgGeralID(Channel: BYTE; ID: DWORD;
      DungeonInstanceID: BYTE): Integer;
  end;
{$ENDREGION}

implementation

uses
  GlobalDefs, DateUtils, Player, PlayerData, Log, ItemFunctions, Util;
{$REGION 'Mob Threads'}

{ TMobSpawnThread1 }
constructor TMobSpawnThread1.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
  Self.Priority := tpLower;
end;

destructor TMobSpawnThread1.Destroy;
begin
  fCritSect.Free;
  inherited;
end;

procedure TMobSpawnThread1.Execute;
var
  i: word;
  j: byte;
  xPlayer: PPlayer;
  key: TPlayerKey;
begin


  while (Servers[0].IsActive) and not(xServerClosed) do
  begin
    try
      fCritSect.Enter;
      try
        for Key in ActivePlayers.Keys do
        begin
          if Key.ServerID <> Self.ChannelId then
            Continue;

          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if (xPlayer^.Status <> PLAYING) or xPlayer^.Unlogging or
             xPlayer^.SocketClosed or xPlayer^.Base.IsDead or
             xPlayer^.ChangingChannel then
            Continue;

          // Libera a seção crítica antes do processamento pesado

            for i := 0 to 500 do
            begin
              with Servers[key.ServerID].MOBS.TMobS[i] do
              begin
                if IntName = 0 then
                  Continue;

                for j := 1 to 49 do
                begin
                  with MobsP[j] do
                  begin
                    if (Index = 0) or (Base.ClientID = 0) then
                      Continue;

                    if xPlayer^.Base.PlayerCharacter.LastPos.InRange(InitPos, 70) then
                    begin
                      Servers[Key.ServerID].MOBS.TMobS[i].MobsP[j].UpdateSpawnToPlayers(i, j, xPlayer^.base.ClientID);
                    end;
                  end;
                end;
              end;
            end;

        end;
      finally
        fCritSect.Leave;
      end;

      TThread.Sleep(FDelay);
    except
      on E: Exception do
      begin
        fCritSect.Leave;
        Logger.Write(E.Message + ' | TMobHandlerThread1.Execute', TlogType.Error);
        continue;
      end;
    end;
  end;


end;


{ TMobHandlerThread1 }
constructor TMobHandlerThread1.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
     Self.Priority := tpLower;
end;

destructor TMobHandlerThread1.Destroy;
begin
  fCritSect.Free;
  inherited;
end;

procedure TMobHandlerThread1.Execute;
var
  i: Word;
  j: Byte;
  xPlayer: PPlayer;
  key: TPlayerKey;
begin
  while (Servers[0].IsActive) and not(xServerClosed) do
  begin
    try
      fCritSect.Enter;
      try
        for Key in ActivePlayers.Keys do
        begin
          if Key.ServerID <> Self.ChannelId then
            Continue;

          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if (xPlayer^.Status <> PLAYING) or xPlayer^.Unlogging or
             xPlayer^.SocketClosed or xPlayer^.Base.IsDead or
             xPlayer^.ChangingChannel then
            Continue;

          // Libera a seção crítica antes do processamento pesado

            for i := 0 to 500 do
            begin
              with Servers[key.ServerID].MOBS.TMobS[i] do
              begin
                if IntName = 0 then
                  Continue;

                for j := 1 to 49 do
                begin
                  with MobsP[j] do
                  begin
                    if (Index = 0) or (Base.ClientID = 0) then
                      Continue;

                    if xPlayer^.Base.PlayerCharacter.LastPos.InRange(InitPos, 70) then
                    begin
                      MobHandler(xPlayer^.Base.ClientID);
                    end;
                  end;
                end;
              end;
            end;

        end;
      finally
        fCritSect.Leave;
      end;

      TThread.Sleep(FDelay);
    except
      on E: Exception do
      begin
        fCritSect.Leave;
        Logger.Write(E.Message + ' | TMobHandlerThread1.Execute', TlogType.Error);
        continue;
      end;
    end;
  end;
end;


{ TMobMovimentThread }
constructor TMobMovimentThread1.Create(SleepTime: Integer; ChannelId: BYTE;
  MobID: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.MobID := MobID;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
     Self.Priority := tpLower;
end;

destructor TMobMovimentThread1.Destroy;
begin
  fCritSect.Free;
  inherited;
end;

procedure TMobMovimentThread1.Execute;
var
  i: Word;
  j: Byte;
  xPlayer: PPlayer;
  key: TPlayerKey;
begin
  while (Servers[0].IsActive) and not(xServerClosed) do
  begin
    try
      fCritSect.Enter;
      try
        for Key in ActivePlayers.Keys do
        begin
          if Key.ServerID <> Self.ChannelId then
            Continue;

          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if (xPlayer^.Status <> PLAYING) or xPlayer^.Unlogging or
             xPlayer^.SocketClosed or xPlayer^.Base.IsDead or
             xPlayer^.ChangingChannel then
            Continue;

          // Libera a seção crítica para não bloquear outras threads


            for i := 0 to 500 do
            begin
              with Servers[key.ServerID].MOBS.TMobS[i] do
              begin
                if IntName = 0 then
                  Continue;

                for j := 1 to 49 do
                begin
                  with MobsP[j] do
                  begin
                    if (Index = 0) or (Base.ClientID = 0) then
                      Continue;

                    if xPlayer.Base.PlayerCharacter.LastPos.InRange(InitPos, 70) then
                    begin
                      MobMoviment(xPlayer^.Base.ClientID);
                    end;
                  end;
                end;
              end;
            end;

        end;
      finally
        fCritSect.Leave;
      end;

      TThread.Sleep(FDelay);
    except
      on E: Exception do
      begin
        fCritSect.Leave;
        Logger.Write(E.Message + ' | TMobMovimentThread1.Execute', TlogType.Error);
        continue;
      end;
    end;
  end;
end;

{$ENDREGION}
{$OLDTYPELAYOUT OFF}

class function TMobFuncs.GetMobGeralID(Channel: BYTE; ID: WORD;
  out MobPosID: WORD): Integer;
var
  i: WORD;
  j: BYTE;
begin
  Result := -1;
  for i := Low(Servers[Channel].MOBS.TMobS)
    to High(Servers[Channel].MOBS.TMobS) do
  begin
    for j := 1 to 49 do
    begin
      if Servers[Channel].MOBS.TMobS[i].MobsP[j].Index = ID then
      begin
        Result := i;
        MobPosID := j;
        Exit; // Substituí o `break` com `Exit` para evitar continuar desnecessariamente.
      end;
    end;
  end;
end;

class function TMobFuncs.GetMobDgGeralID(Channel: BYTE; ID: DWORD;
  DungeonInstanceID: BYTE): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := Low(DungeonInstances[DungeonInstanceID].MOBS)
    to High(DungeonInstances[DungeonInstanceID].MOBS) do
  begin
    if (DungeonInstances[DungeonInstanceID].MOBS[i].Base.ClientID = ID) then
    begin
      Result := i;
      Exit; // Encerra a função imediatamente ao encontrar o resultado
    end;
    // if not (DungeonInstances[DungeonInstanceID].MOBS[i].Base.IsDead) then
    // Writeln('MobID não encontrado para o ClientID: ' + IntToStr(ID));
  end;
  // Caso não tenha encontrado o mob, loga a mensagem

end;

procedure TMobSPosition.SendMobDamage(PlayerID: WORD; MobID: DWORD;
  // envio de dano PLAYER >> MOB, MESMO SENDDAMAGE DE PLAYER
  SkillID: DWORD; Anim: DWORD; out DnTypeA: BYTE);
var
  Packet: TRecvDamagePacket;
  dnType: TDamageType;
  i, mbid, j: DWORD;
  AuxID: Integer;
  RandonPosition: Integer;
  RandonLocal: Integer;
  DnAux: BYTE;
begin
  if (Self.Base.IsDead) or
    ((Self.isGuard) and (BYTE(Servers[Self.Base.ChannelId].Players[PlayerID]
    .Account.Header.Nation) = Servers[Self.Base.ChannelId].NationID)) then
    Exit;

  ZeroMemory(@Packet, sizeof(Packet));
  Self.IsAttacked := True;
  Self.AttackerID := PlayerID;
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := PlayerID;
  Packet.Header.Code := $102;
  Packet.SkillID := SkillID;
  Packet.AttackerPos := Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.LastPos;
  Packet.AttackerID := PlayerID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.Character.CurrentScore.CurHP;
  Packet.TargetID := Self.Index;
  Packet.MobAnimation := SkillData[SkillID].TargetAnimation;
  Packet.DANO := Self.GetMobDamage(PlayerID, SkillID, dnType);
  Packet.dnType := dnType;

  if Packet.DANO >= Self.HP then
  begin
    Self.HP := 0;
    Self.Base.IsDead := True;
    Self.IsAttacked := FALSE;
    Self.AttackerID := 0;
    Self.DeadTime := Now;
    Packet.MobAnimation := 30;

    Servers[Self.Base.ChannelId].Players[PlayerID].Base.VisibleMobs.Remove
      (Self.Index);
    Self.Base.VisibleMobs.Clear;

    Servers[Self.Base.ChannelId].Players[PlayerID].SendClientMessage
      ('Você recebeu ' + AnsiString(Servers[Self.Base.ChannelId].MOBS.TMobS
      [Self.Base.MobID].MobExp.ToString) + ' pontos de experiência.', 0);
  end
  else
  begin
    Self.HP := Self.HP - Packet.DANO;
  end;

  if Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_DRAIN_HP) > 0 then
  begin
    Servers[Self.Base.ChannelId].Players[PlayerID].Base.Character.CurrentScore.
      CurHP := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.Character.CurrentScore.CurHP + (Packet.DANO div 100) *
      Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
      (EF_DRAIN_HP);
  end;

  if Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_DRAIN_MP) > 0 then
  begin
    Servers[Self.Base.ChannelId].Players[PlayerID].Base.Character.CurrentScore.
      CurMP := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.Character.CurrentScore.CurMP + (Packet.DANO div 100) *
      Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
      (EF_DRAIN_MP);
  end;

  if Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_SPLASH) > 0 then
  begin
    if (SkillData[SkillID].Index in [0, 48, 96]) then
    begin
      for i in Servers[Self.Base.ChannelId].Players[PlayerID]
        .Base.VisibleMobs do
      begin
        if (i = Servers[Self.Base.ChannelId].Players[PlayerID].Base.ClientID) or
          (i = Self.Index) or Servers[Self.Base.ChannelId].Players[i]
          .Base.IsDead or
          (not Self.CurrentPos.InRange(Servers[Self.Base.ChannelId].Players[i]
          .Base.PlayerCharacter.LastPos, 5)) then
          Continue;

        if Packet.DANO >= Servers[Self.Base.ChannelId].Players[i]
          .Base.Character.CurrentScore.CurHP then
        begin
          Servers[Self.Base.ChannelId].Players[i].Base.Character.CurrentScore.
            CurHP := 0;
          Servers[Self.Base.ChannelId].Players[i].Base.IsDead := True;
          Servers[Self.Base.ChannelId].Players[i].Base.SendEffect($0);
          Packet.MobAnimation := 30;
        end
        else
        begin
          Servers[Self.Base.ChannelId].Players[i].Base.Character.CurrentScore.
            CurHP := Servers[Self.Base.ChannelId].Players[i]
            .Base.Character.CurrentScore.CurHP - Packet.DANO;
        end;

        Servers[Self.Base.ChannelId].Players[i].Base.LastReceivedAttack := Now;
        Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[i]
          .Base.Character.CurrentScore.CurHP;
        Servers[Self.Base.ChannelId].Players[PlayerID].Base.SendToVisible
          (Packet, Packet.Header.size);
      end;
    end;
  end;

  if Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
    (EF_SKILL_INVISIBILITY) > 0 then
  begin
    if Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobClass
      (Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.Character.ClassInfo) = 2 then
    begin
      for i := 0 to 15 do
        Servers[Self.Base.ChannelId].Players[PlayerID].Base.RemoveBuff
          (2081 + i);
    end
    else
    begin
      for i := 0 to 15 do
        Servers[Self.Base.ChannelId].Players[PlayerID].Base.RemoveBuff
          (3041 + i);
    end;
  end;

  if Self.CurrentPos.Distance(Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.LastPos) > 5 then
  begin
    Randomize;
    RandonPosition := RandomRange(-2, 3);
    // Consolidando cálculo em uma única linha
    Self.CurrentPos := TPosition.Create(Servers[Self.Base.ChannelId].Players
      [PlayerID].Base.PlayerCharacter.LastPos.X + RandonPosition,
      Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.PlayerCharacter.LastPos.Y + RandonPosition);
    Self.MobMove(Self.CurrentPos, 50);
  end;

  Self.Base.LastReceivedAttack := Now;
  Packet.MobCurrHP := Self.HP;
  Servers[Self.Base.ChannelId].Players[PlayerID].Base.SendCurrentHPMP();
  Servers[Self.Base.ChannelId].Players[PlayerID].Base.SendToVisible(Packet,
    Packet.Header.size);
end;

function TMobSPosition.GetMobDamage(PlayerID: WORD; Skill: DWORD;
  out DamageType: TDamageType): UInt64;
var
  IsPhysical: Boolean;
  ResultDamage: UInt64;
  MobDef: DWORD;
  MoreDamage: UInt64;
begin
  Result := 0;
  IsPhysical := (Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobClass
    >= 0) and (Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobClass
    <= 3) or (SkillData[Skill].Index = 96);

  if IsPhysical then
  begin
    ResultDamage := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.PlayerCharacter.Base.CurrentScore.DNFis;
    MobDef := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].FisDef -
      ((Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].FisDef div 100)
      * Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
      (EF_PIERCING_RESISTANCE1));
  end
  else
  begin
    ResultDamage := Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.PlayerCharacter.Base.CurrentScore.DNMAG;
    MobDef := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].MagDef -
      ((Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].MagDef div 100)
      * Servers[Self.Base.ChannelId].Players[PlayerID].Base.GetMobAbility
      (EF_PIERCING_RESISTANCE2));
  end;

  DamageType := Self.GetMobDamageType(PlayerID, Skill, IsPhysical);
  if DamageType = Miss then
    Exit;

  inc(ResultDamage, SkillData[Skill].Damage);
  ResultDamage := ResultDamage - (MobDef shr 3);
  Randomize;
  inc(ResultDamage, (Random(99) + 5));

  if Skill > 0 then
  begin
    inc(ResultDamage, Servers[Self.Base.ChannelId].Players[PlayerID]
      .Base.GetMobAbility(EF_SKILL_DAMAGE));
    if SkillData[Skill].Index = 336 then
    begin
      inc(ResultDamage,
        ((Servers[Self.Base.ChannelId].Players[PlayerID]
        .Base.Character.CurrentScore.CurHP div 100) * SkillData[Skill]
        .Adicional));
    end;
  end;

  case DamageType of
    Critical:
      ResultDamage := Round(ResultDamage * 1.5);
    Double:
      ResultDamage := Round(ResultDamage * 2.0);
    DoubleCritical:
      ResultDamage := Round(ResultDamage * 3.0);
  end;

  if (ResultDamage < 0) or (ResultDamage > 1000000) then
    ResultDamage := 1;

  Result := ResultDamage;
end;

function TMobSPosition.GetMobDamageType(PlayerID: WORD; Skill: DWORD;
  IsPhys: Boolean): TDamageType;
var
  RamdomArray: ARRAY [0 .. 999] OF BYTE;
  RamdomSlot: WORD;
  Chance: BYTE;

  function GetEmpty: WORD;
  var
    i: WORD;
  begin
    Result := 0;
    for i := 0 to 999 do
      if RamdomArray[i] = 0 then
        inc(Result);
  end;

  procedure SetChance(Chance: WORD; const Type1: BYTE);
  var
    Empty: WORD;
  begin
    if Chance = 0 then
      Exit;

    Empty := GetEmpty;
    if Chance > Empty then
      Chance := Empty;

    while Chance > 0 do
    begin
      RamdomSlot := Random(1000);
      if RamdomArray[RamdomSlot] = 0 then
      begin
        RamdomArray[RamdomSlot] := Type1;
        Chance := Chance - 1; // Decremento explícito
      end;
    end;

  end;

begin
  ZeroMemory(@RamdomArray, Length(RamdomArray));
  Randomize;

{$REGION 'Seta a chance basica dos tipos de dano'}
  if IsPhys then
    Chance := 55
  else
    Chance := 60;

  SetChance(Chance, BYTE(TDamageType.Critical));
  // CHANCE SETADA VIA MAGO/FIGHTER
  SetChance(20, BYTE(TDamageType.Miss)); // CHANCE PADRAO DE MISS

  if IsPhys then
  begin
    SetChance(40, BYTE(TDamageType.Double)); // CHANCE PADRAO SE FOR FIGHTER
    SetChance(20, BYTE(TDamageType.DoubleCritical));
    // CHANCE PADRAO SE FOR MAGO
  end;

  SetChance(Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.Base.CurrentScore.Critical,
    BYTE(TDamageType.Critical));
  SetChance(Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.DuploAtk, BYTE(TDamageType.Double));
  SetChance(Round(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID]
    .MobLevel / 2), BYTE(TDamageType.Miss));
  SetChance(((Servers[Self.Base.ChannelId].Players[PlayerID]
    .Base.PlayerCharacter.DuploAtk + Servers[Self.Base.ChannelId].Players
    [PlayerID].Base.PlayerCharacter.Base.CurrentScore.Critical) div 2),
    BYTE(TDamageType.DoubleCritical));
{$ENDREGION}
  Result := TDamageType(RamdomArray[Random(1000)]);
end;

procedure TMobSPosition.MobHandler(ClientHandlerID: Integer);
var
  i: Integer;
  UpdatedBuffs, Rand: Integer;
  OtherPlayer, OPP: PPlayer;
begin
  // if(MilliSecondsBetween(Now, Self.UpdatedMobHandler) < 1000) then
  // Exit;

  Self.UpdatedMobHandler := Now;

  if (Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].IntName = 0) then
    Exit;

  // try
  if (Self.Base.IsDead = FALSE) then // attack and IA verifications
  begin
    if (Self.isTemp) then // Verificação de mob temporário PAINEL
    begin
      if (MinutesBetween(Now, Self.GeneratedAt) >= 120) then
      begin
        for i in Self.Base.VisibleMobs do
        begin
          OtherPlayer := @Servers[Self.Base.ChannelId].Players[i];
          if (not Assigned(OtherPlayer.FriendList)) or (OtherPlayer.InDungeon)
            or (OtherPlayer.Status < PLAYING) then
          begin
            Self.Base.VisibleMobs.Remove(i);
            Continue;
          end;
          if (OtherPlayer.Base.VisibleMobs.Contains(Self.Index)) then
          begin
            OtherPlayer.Base.VisibleMobs.Remove(Self.Index);
            OtherPlayer.UnspawnMob(Self.Base.MobID, Self.Base.SecondIndex);
            OtherPlayer.Base.RemoveTargetFromList(@Self.Base);
          end;
        end;
        ZeroMemory(@Self, sizeof(Self));
        Exit;
      end;
    end;

{$REGION 'Buffs'}
    if (Self.Base.RefreshBuffs > 0) then
      Self.Base.SendRefreshBuffs;
{$ENDREGION}
{$REGION 'Attack'}
    if not(Self.Base.GetMobAbility(EF_SKILL_STUN) = 0) or
      not(Self.Base.GetMobAbility(EF_SILENCE1) = 0) or
      not(Self.Base.GetMobAbility(EF_SILENCE2) = 0) or
      not(Self.Base.GetMobAbility(EF_SKILL_SHOCK) = 0) or
      not(Self.Base.GetMobAbility(EF_SKILL_SLEEP) = 0) then
    begin
      Self.AttackSamePlayerTimes := 0;
      Exit;
    end;

    if not(Self.Base.GetMobAbility(EF_SKILL_IMMOVABLE) = 0) then
      Exit;

    if (Self.IsAttacked) then // se o mob foi atacado, entao...
    begin
      if (Self.FirstPlayerAttacker <> Self.AttackerID) or
        (Self.LastAttackerID <> Self.AttackerID) then
      begin
        Self.LastAttackerID := Self.AttackerID;
        Self.AttackSamePlayerTimes := 0;
      end;

      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID].Status < PLAYING)
      then
        Exit;

      if (Self.CurrentPos.Distance(Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base.PlayerCharacter.LastPos) <= 3) then
      begin
        if not(Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.IsDead)
        then
        begin
          if (SecondsBetween(Now, Self.LastMyAttack) >= 3) then
          begin
            if ((Self.Base.GetMobAbility(EF_SKILL_STUN) = 0) and
              (Self.Base.GetMobAbility(EF_SILENCE1) = 0)) then
            begin
              if (Self.isGuard and (SecondsBetween(Now, Self.LastSkillAttack)
                >= 20)) then
              begin
                if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                  .Base.BuffExistsByIndex(36)) then
                begin
                  Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                    .Base.BolhaPoints, 1);
                  if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                    .Base.BolhaPoints = 0) then
                  begin
                    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.RemoveBuffByIndex(36);
                    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .SendClientMessage
                      ('Você resistiu à habilidade de slow. Proteção caiu.',
                      16, 1, 1);
                  end
                  else
                  begin
                    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .SendClientMessage
                      ('Você resistiu à habilidade de slow. Proteção restam ' +
                      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                      .Base.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
                  end;
                end
                else
                begin
                  // WriteLn('enviando lentidao em massa');
                  Self.AttackPlayer(6470); // lentidão em massa
                  // Writeln('id generico '+ Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].IndexGeneric.ToString);
                  // WriteLN('enviado '+ Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].Name);
                  // writeln('is guard ' + Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.Mobid].IntName.ToString);
                end;
                Self.LastMyAttack := Now;
                Self.LastSkillAttack := Now;
              end
              else
              begin
                Self.LastMyAttack := Now;
                Self.AttackPlayer(0);
              end;
            end;
          end;
        end
        else
        begin
          OPP := nil;

          for i := 1 to High(Servers[Self.Base.ChannelId].Players) do
          begin
            if ((Servers[Self.Base.ChannelId].Players[i].Status < PLAYING) or
              (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
              Continue;
            if (Servers[Self.Base.ChannelId].Players[i]
              .Base.PlayerCharacter.LastPos.InRange(Self.InitPos, 25)) then
            begin
              OPP := @Servers[Self.Base.ChannelId].Players[i];
              Break;
            end;
          end;

          if (OPP <> nil) then
          begin
            Self.FirstPlayerAttacker := OPP.Base.ClientID;
            Self.AttackerID := OPP.Base.ClientID;
          end
          else
          begin
            Self.MovedTo := Init;
            Self.MovimentsTime := 0;
            Self.LastMoviment := Now;
            Self.AttackerID := 0;
            Self.IsAttacked := FALSE;
            Self.FirstPlayerAttacker := 0;
            LastSkillUsedByMob := Now;
            ActualUsingSkill := 0;
            Self.CurrentPos := Self.InitPos;
            Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
            Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS
              [Self.Base.MobID].InitHP;
            Self.MobMove(Self.InitPos, 40, MOVE_NORMAL);
            Self.AttackSamePlayerTimes := 0;
          end;
        end;
      end
      else if (Self.InitPos.Distance(Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base.PlayerCharacter.LastPos) >= 51) then
      begin
        OPP := nil;

        for i := 1 to High(Servers[Self.Base.ChannelId].Players) do
        begin
          if ((Servers[Self.Base.ChannelId].Players[i].Status < PLAYING) or
            (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
            Continue;
          if (Servers[Self.Base.ChannelId].Players[i]
            .Base.PlayerCharacter.LastPos.InRange(Self.InitPos, 25)) then
          begin
            if (Self.isGuard) then
            begin
              if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex
                (77) or Servers[Self.Base.ChannelId].Players[i]
                .Base.BuffExistsByIndex(53) or Servers[Self.Base.ChannelId]
                .Players[i].Base.BuffExistsByIndex(153) or
                (Servers[Self.Base.ChannelId].Players[i]
                .Base.Character.Nation = Self.Base.PlayerCharacter.Base.Nation)
                or (Servers[Self.Base.ChannelId].Players[i]
                .Base.Character.Nation <= 0) or Servers[Self.Base.ChannelId]
                .Players[i].Base.IsDead) then
                Continue;
            end;
            OPP := @Servers[Self.Base.ChannelId].Players[i];
            Break;
          end;
        end;

        if (OPP <> nil) then
        begin
          Self.FirstPlayerAttacker := OPP.Base.ClientID;
          Self.AttackerID := OPP.Base.ClientID;
        end
        else
        begin
          Self.MovedTo := Init;
          Self.MovimentsTime := 0;
          Self.LastMoviment := Now;
          Self.AttackerID := 0;
          Self.IsAttacked := FALSE;
          Self.FirstPlayerAttacker := 0;
          LastSkillUsedByMob := Now;
          ActualUsingSkill := 0;
          Self.CurrentPos := Self.InitPos;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS
            [Self.Base.MobID].InitHP;
          Self.MobMove(Self.InitPos, 40, MOVE_NORMAL);
          Self.AttackSamePlayerTimes := 0;
        end;
      end
      else
      begin
        OPP := nil;

        for i := 1 to High(Servers[Self.Base.ChannelId].Players) do
        begin
          if ((Servers[Self.Base.ChannelId].Players[i].Status < PLAYING) or
            (Servers[Self.Base.ChannelId].Players[i].SocketClosed)) then
            Continue;
          if (Servers[Self.Base.ChannelId].Players[i]
            .Base.PlayerCharacter.LastPos.InRange(Self.InitPos, 25)) then
          begin
            if (Self.isGuard) then
            begin
              if (Servers[Self.Base.ChannelId].Players[i].Base.BuffExistsByIndex
                (77) or Servers[Self.Base.ChannelId].Players[i]
                .Base.BuffExistsByIndex(53) or Servers[Self.Base.ChannelId]
                .Players[i].Base.BuffExistsByIndex(153) or
                (Servers[Self.Base.ChannelId].Players[i]
                .Base.Character.Nation = Self.Base.PlayerCharacter.Base.Nation)
                or (Servers[Self.Base.ChannelId].Players[i]
                .Base.Character.Nation <= 0) or Servers[Self.Base.ChannelId]
                .Players[i].Base.IsDead) then
                Continue;
            end;
            OPP := @Servers[Self.Base.ChannelId].Players[i];
            Break;
          end;
        end;

        if (OPP <> nil) then
        begin
          Self.FirstPlayerAttacker := OPP.Base.ClientID;
          Self.AttackerID := OPP.Base.ClientID;
          Randomize;
          Self.CurrentPos := Servers[Self.Base.ChannelId].Players
            [Self.AttackerID].Base.Neighbors[RandomRange(1, 8)].pos;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.MobMove(Self.CurrentPos, 40);
        end
        else
        begin
          Self.MovedTo := Init;
          Self.MovimentsTime := 0;
          Self.LastMoviment := Now;
          Self.AttackerID := 0;
          Self.IsAttacked := FALSE;
          Self.FirstPlayerAttacker := 0;
          LastSkillUsedByMob := Now;
          ActualUsingSkill := 0;
          Self.CurrentPos := Self.InitPos;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS
            [Self.Base.MobID].InitHP;
          Self.MobMove(Self.InitPos, 40, MOVE_NORMAL);
          Self.AttackSamePlayerTimes := 0;
        end;
      end;

{$ENDREGION}
    end
    else
    begin
      Self.AttackSamePlayerTimes := 0;

      if (Self.isGuard) then
      begin
        if (Servers[Self.Base.ChannelId].Players[ClientHandlerID].Status <
          PLAYING) or (Servers[Self.Base.ChannelId].Players[ClientHandlerID]
          .Base.BuffExistsByIndex(77)) or
          (Servers[Self.Base.ChannelId].Players[ClientHandlerID]
          .Base.BuffExistsByIndex(53)) or
          (Servers[Self.Base.ChannelId].Players[ClientHandlerID]
          .Base.BuffExistsByIndex(153)) then
          Exit;

        if (Servers[Self.Base.ChannelId].Players[ClientHandlerID]
          .Base.PlayerCharacter.LastPos.InRange(Self.CurrentPos, 30)) and
          not(Servers[Self.Base.ChannelId].Players[ClientHandlerID].Base.IsDead)
        then
        begin
          if (Servers[Self.Base.ChannelId].Players[ClientHandlerID]
            .Base.Character.Nation > 0) and
            (Servers[Self.Base.ChannelId].Players[ClientHandlerID]
            .Base.Character.Nation <> Self.Base.PlayerCharacter.Base.Nation)
          then
          begin
            Self.IsAttacked := True;
            Self.AttackerID := ClientHandlerID;
            Exit;
          end;
        end;
      end;

      if (Self.Base.VisibleMobs.Count > 0) then
      begin
        for i in Self.Base.VisibleMobs do
        begin
          OtherPlayer := @Servers[Self.Base.ChannelId].Players[i];
          if (OtherPlayer.InDungeon) or (OtherPlayer.Status < PLAYING) or
            (OtherPlayer.SocketClosed) or
            (OtherPlayer.Base.BuffExistsByIndex(77)) or
            (OtherPlayer.Base.BuffExistsByIndex(53)) or
            (OtherPlayer.Base.BuffExistsByIndex(153)) or
            (OtherPlayer.Base.IsDead) then
            Continue;

          OtherPlayer.Base.LureMobsInRange;
        end;
      end;

    end;
  end;
end;

procedure TMobSPosition.MobMoviment(ClientHandlerID: Integer);
var
  Rand, i: Integer;
  OPP: PPlayer;
begin
  // Atualiza o tempo da última movimentação
  Self.UpdatedMobMoviment := Now;

  // Verifica se o mob possui um nome válido
  if (Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].IntName = 0) then
    Exit;

  try
    // Verifica se o mob está vivo e não está sendo atacado
    if (Self.Base.IsDead = FALSE) and (Self.IsAttacked = FALSE) then
    begin
      if (Self.MovedTo = Init) then
      begin
        if (SecondsBetween(Now, Self.LastMoviment) > Self.InitMoveWait) then
        begin
          Self.XPositionDif := Round(Self.DestPos.X - Self.CurrentPos.X);
          Self.XPositionDif := abs(Self.XPositionDif);
          if (Self.XPositionDif >= 2) then
            Self.CurrentPos.X := Self.CurrentPos.X +
              IfThen(Self.DestPos.X > Self.CurrentPos.X, 1.5, -1.5);

          Self.YPositionDif := Round(Self.DestPos.Y - Self.CurrentPos.Y);
          Self.YPositionDif := abs(Self.YPositionDif);
          if (Self.YPositionDif >= 2) then
            Self.CurrentPos.Y := Self.CurrentPos.Y +
              IfThen(Self.DestPos.Y > Self.CurrentPos.Y, 1.5, -1.5);

          inc(Self.MovimentsTime);
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          if (Self.MovimentsTime >= 2) then
          begin
            Self.MovimentsTime := 0;
            Self.MobMove(Self.CurrentPos, 25);
          end;

          if (Self.CurrentPos.Distance(Self.DestPos) <= 0) then
          begin
            Self.MovedTo := Dest;
            Self.MovimentsTime := 0;
            Self.LastMoviment := Now;
            Self.CurrentPos := Self.DestPos;
            Exit; // Adiciona Exit para evitar loops infinitos
          end;
        end;
      end
      else if (Self.MovedTo = Dest) then
      begin
        if (SecondsBetween(Now, Self.LastMoviment) > Self.InitMoveWait) then
        begin
          Self.XPositionDif := Round(Self.CurrentPos.X - Self.InitPos.X);
          Self.XPositionDif := abs(Self.XPositionDif);
          if (Self.XPositionDif >= 2) then
            Self.CurrentPos.X := Self.CurrentPos.X +
              IfThen(Self.InitPos.X < Self.CurrentPos.X, -1.5, 1.5);

          Self.YPositionDif := Round(Self.CurrentPos.Y - Self.InitPos.Y);
          Self.YPositionDif := abs(Self.YPositionDif);
          if (Self.YPositionDif >= 2) then
            Self.CurrentPos.Y := Self.CurrentPos.Y +
              IfThen(Self.InitPos.Y < Self.CurrentPos.Y, -1.5, 1.5);

          inc(Self.MovimentsTime);
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          if (Self.MovimentsTime >= 2) then
          begin
            Self.MovimentsTime := 0;
            Self.MobMove(Self.CurrentPos, 25);
          end;

          if (Self.CurrentPos.Distance(Self.InitPos) <= 0) then
          begin
            Self.MovedTo := Init;
            Self.MovimentsTime := 0;
            Self.LastMoviment := Now;
            Self.CurrentPos := Self.InitPos;
            Exit; // Adiciona Exit para evitar loops infinitos
          end;
        end;
      end;
    end;

    // Verifica se o mob está sendo atacado
    if (Self.AttackerID > 0) and (Self.Base.IsDead = FALSE) and
      (Self.IsAttacked = True) then
    begin
      // Verifica se o mob não possui habilidades que impedem movimentação
      if (Self.Base.GetMobAbility(EF_SKILL_STUN) <> 0) or
        (Self.Base.GetMobAbility(EF_SKILL_IMMOVABLE) <> 0) or
        (Self.Base.GetMobAbility(EF_SKILL_SHOCK) <> 0) or
        (Self.Base.GetMobAbility(EF_SKILL_SLEEP) <> 0) then
        Exit;

      Randomize;
      Rand := RandomRange(1, 8);

      // Move-se em direção à posição do atacante
      Self.XPositionDif :=
        Round(Self.CurrentPos.X - Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base.Neighbors[Rand].pos.X);
      Self.XPositionDif := abs(Self.XPositionDif);
      if (Self.XPositionDif >= 3) then
        Self.CurrentPos.X := Self.CurrentPos.X +
          IfThen(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.X < Self.CurrentPos.X, -2, 2);

      Self.YPositionDif :=
        Round(Self.CurrentPos.Y - Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base.Neighbors[Rand].pos.Y);
      Self.YPositionDif := abs(Self.YPositionDif);
      if (Self.YPositionDif >= 3) then
        Self.CurrentPos.Y := Self.CurrentPos.Y +
          IfThen(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Neighbors[Rand].pos.Y < Self.CurrentPos.Y, -2, 2);

      Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
      Self.MobMove(Self.CurrentPos, 40);
    end;

    // Se o mob está sendo atacado e se afastou do ponto inicial
    if (Self.IsAttacked = True) and
      (not Self.CurrentPos.InRange(Self.InitPos, 40)) then
    begin
      // Verifica se o mob não possui habilidades que impedem movimentação
      if (Self.Base.GetMobAbility(EF_SKILL_STUN) <> 0) or
        (Self.Base.GetMobAbility(EF_SKILL_IMMOVABLE) <> 0) or
        (Self.Base.GetMobAbility(EF_SKILL_SHOCK) <> 0) or
        (Self.Base.GetMobAbility(EF_SKILL_SLEEP) <> 0) then
        Exit;

      OPP := nil;
      for i := 1 to High(Servers[Self.Base.ChannelId].Players) do
      begin
        if (Servers[Self.Base.ChannelId].Players[i].Status >= PLAYING) and
          not(Servers[Self.Base.ChannelId].Players[i].SocketClosed) and
          (Servers[Self.Base.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
          InRange(Self.InitPos, 40)) then
        begin
          OPP := @Servers[Self.Base.ChannelId].Players[i];
          Break;
        end;
      end;

      if (OPP <> nil) then
      begin
        Self.FirstPlayerAttacker := OPP.Base.ClientID;
        Self.AttackerID := OPP.Base.ClientID;
      end
      else
      begin
        Self.MovedTo := Init;
        Self.MovimentsTime := 0;
        Self.LastMoviment := Now;
        Self.CurrentPos := Self.InitPos;
        Exit; // Adiciona Exit para evitar loops infinitos
      end;
    end;
  except
    on E: Exception do
      // Captura exceções para evitar crashs e log de erro
      Logger.Write('Error at mob Moviment [' + E.Message + '] b.e: ' +
        E.BaseException.Message + ' mobid: ' + Self.Base.MobID.ToString + ' t:'
        + DateTimeToStr(Now), TlogType.Error);
  end;
end;

procedure TMobSPosition.MobMove(Position: TPosition; Speed: BYTE;
  MoveType: BYTE);
var
  Packet: TMobMovimentPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, sizeof(TMobMovimentPacket));
  Packet.Header.size := sizeof(TMobMovimentPacket);
  Packet.Header.Index := Self.Index;
  Packet.Header.Code := $301;
  Packet.Destination := Position;
  Packet.MoveType := MoveType;
  Packet.Speed := IfThen(Speed = 25, Servers[Self.Base.ChannelId].MOBS.TMobS
    [Self.Base.MobID].MoveSpeed, Speed);

  for i in Self.Base.VisibleMobs do
  begin
    if (i <= max_connections) then
    begin
      with Servers[Self.Base.ChannelId].Players[i] do
      begin
        if (not Assigned(FriendList) or SocketClosed or
          (Status < TPlayerStatus.PLAYING)) then
          Continue;

        SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
end;

procedure TMobSPosition.AttackPlayer(SkillID: WORD);
var
  Packet: TRecvDamagePacket;
  dnType: TDamageType;
  DANO: Integer;
  SkillIDa: Integer;
  AttackResultType, RlkSlot: BYTE;
  DefTarget: Integer;
  i, j: Integer;
  OtherPlayer, OPP: PPlayer;
  Item: PItem;
  cnt: BYTE;
  AddBuff: Boolean;
begin

  if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.BuffExistsByIndex(53) or Servers[Self.Base.ChannelId].Players
    [Self.AttackerID].Base.BuffExistsByIndex(77) or Servers[Self.Base.ChannelId]
    .Players[Self.AttackerID].Base.BuffExistsByIndex(153) or
    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.BuffExistsByIndex(386) then
  begin
    Self.MovedTo := Init;
    Self.MovimentsTime := 0;
    Self.LastMoviment := Now;
    Self.AttackerID := 0;
    Self.IsAttacked := FALSE;
    Self.FirstPlayerAttacker := 0;
    LastSkillUsedByMob := Now;
    ActualUsingSkill := 0;
    Self.CurrentPos := Self.InitPos;
    Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
    Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].InitHP;
    Self.MobMove(Self.InitPos, 40, MOVE_NORMAL);
    Self.AttackSamePlayerTimes := 0;
    Exit;
  end;

  try
    SkillIDa := SkillID;

    if (SkillID = 0) and (Servers[Self.Base.ChannelId].MOBS.TMobS
      [Self.Base.MobID].Skill01 > 0) then
    begin
      if (SecondsBetween(Self.LastSkillUsedByMob, Now) > 4) then
      begin
        Self.LastSkillUsedByMob := Now;

        case Self.ActualUsingSkill of
          0:
            begin
              SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS
                [Self.Base.MobID].Skill01;
              if SkillIDa > 0 then
                inc(Self.ActualUsingSkill)
              else
                Self.ActualUsingSkill := 0;
            end;
          1:
            begin
              SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS
                [Self.Base.MobID].Skill02;
              if SkillIDa > 0 then
                inc(Self.ActualUsingSkill)
              else
                Self.ActualUsingSkill := 0;
            end;
          2:
            begin
              SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS
                [Self.Base.MobID].Skill03;
              if SkillIDa > 0 then
                inc(Self.ActualUsingSkill)
              else
                Self.ActualUsingSkill := 0;
            end;
          3:
            begin
              SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS
                [Self.Base.MobID].Skill04;
              if SkillIDa > 0 then
                inc(Self.ActualUsingSkill)
              else
                Self.ActualUsingSkill := 0;
            end;
          4:
            begin
              SkillIDa := Servers[Self.Base.ChannelId].MOBS.TMobS
                [Self.Base.MobID].Skill05;
              if SkillIDa > 0 then
                inc(Self.ActualUsingSkill);
              Self.ActualUsingSkill := 0;
              // Reinicia a habilidade após o uso de Skill05
            end;
        end;
      end;
    end;

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID].SocketClosed) then
      Exit;

    if (Self.Base.IsDead) then
    begin
      Self.IsAttacked := FALSE;
      Self.AttackerID := 0;
      Exit;
    end;

    if (Self.isGuard) then
    begin
      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.Nation > 0) then
        if (Servers[Self.Base.ChannelId].NationID = Servers[Self.Base.ChannelId]
          .Players[Self.AttackerID].Base.Character.Nation) then
        begin
          Self.IsAttacked := FALSE;
          Self.AttackerID := 0;
          Exit;
        end;
    end;

    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := Self.Index;
    Packet.Header.Code := $102;
    Packet.SkillID := SkillIDa;
    Packet.AttackerPos := Self.CurrentPos;
    Packet.AttackerID := Self.Index;
    Packet.Animation := 06;
    Packet.AttackerHP := Self.HP;
    Packet.TargetID := Self.AttackerID;
    Packet.MobAnimation := 26;

    DANO := 0;
    if (SkillIDa > 0) then
      DANO := (Self.Base.PlayerCharacter.Base.CurrentScore.DNFis div 2) +
        SkillData[SkillIDa].Damage
    else
      DANO := Self.Base.PlayerCharacter.Base.CurrentScore.DNFis div 2;

    case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.GetMobClass of
      0 .. 3:
        DefTarget := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.PlayerCharacter.Base.CurrentScore.DefFis;
    else
      DefTarget := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.PlayerCharacter.Base.CurrentScore.DefMag;
    end;

    Randomize;
    AttackResultType := RandomRange(1, 101);

    case AttackResultType of
      2 .. 15:
        dnType := TDamageType.Miss;
      16 .. 30:
        dnType := TDamageType.Critical;
    else
      dnType := TDamageType.Normal;
    end;

    DANO := DANO - (DefTarget shr 3);
    inc(DANO, (RandomRange(10, 39) + 7));

    if (dnType = TDamageType.Miss) then
      DANO := 0
    else
    begin
      if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.BuffExistsByIndex(19)) then
      begin
        DANO := 0;
        dnType := TDamageType.Block;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.RemoveBuffByIndex(19);
      end
      else if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.BuffExistsByIndex(91)) then
      begin
        DANO := 0;
        dnType := TDamageType.Miss2;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.RemoveBuffByIndex(91);
      end;
    end;

    if (Servers[Self.Base.ChannelId].ReliqEffect[EF_RELIQUE_DEF_MONSTER] > 0)
    then
      DANO := DANO - (Servers[Self.Base.ChannelId].ReliqEffect
        [EF_RELIQUE_DEF_MONSTER] * (DANO div 100));

    if (dnType = TDamageType.Critical) then
      DANO := Round(DANO * 1.5);

    if (DANO < 0) then
      DANO := 1;

    AddBuff := True;

    if SkillIDa > 0 then
      Self.Base.AttackParseForMobs(SkillIDa, 0,
        @Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base, DANO,
        dnType, AddBuff, Packet.MobAnimation)
    else
      Self.Base.AttackParseForMobs(0, 0, @Servers[Self.Base.ChannelId].Players
        [Self.AttackerID].Base, DANO, dnType, AddBuff, Packet.MobAnimation);

    if Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.GetMobAbility
      (EF_IMMUNITY) > 0 then
    begin
      dnType := TDamageType.Immune;
      Packet.DANO := 0;
      AddBuff := FALSE;
    end;

    if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(19) then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.RemoveBuffByIndex(19);
      dnType := TDamageType.Block;
      Packet.DANO := 0;
      AddBuff := FALSE;
    end;

    if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(91) then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.RemoveBuffByIndex(91);
      dnType := TDamageType.Miss2;
      Packet.DANO := 0;
      AddBuff := FALSE;
    end;

    if SkillIDa > 0 then
    begin
      if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.BuffExistsByIndex(36) then
      begin
        DANO := 0;
        Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.BolhaPoints, 1);
        if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.BolhaPoints = 0 then
        begin
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.RemoveBuffByIndex(36);
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .SendClientMessage
            ('Você resistiu à habilidade de slow. Proteção caiu.', 16, 1, 1);
        end
        else
        begin
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .SendClientMessage
            ('Você resistiu à habilidade de slow. Proteção restam ' +
            Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
        end;

        AddBuff := FALSE;
      end;
    end;

    Packet.dnType := dnType;
    Packet.DANO := DANO;

    if (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(53)) or
      (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(77)) or
      (Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.BuffExistsByIndex(24)) then
    begin
      Self.IsAttacked := FALSE;
      Self.AttackerID := 0;
      Exit;
    end;

    if Packet.DANO >= Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP then
    begin
      if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.BuffExistsByIndex(134) then
      begin
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Character.CurrentScore.CurHP := 1;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID].SendClientMessage
          ('Cura preventiva entrou em ação e feitiço foi desfeito.', 0);
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.RemoveBuffByIndex(134);
      end
      else
      begin
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Character.CurrentScore.CurHP := 0;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.IsDead := True;
        Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.SendEffect($0);
        Packet.MobAnimation := 30;
        cnt := 0;
        while TItemFunctions.GetItemSlotByItemType
          (Servers[Self.Base.ChannelId].Players[Self.AttackerID], 40, INV_TYPE,
          0) <> 255 do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType
            (Servers[Self.Base.ChannelId].Players[Self.AttackerID], 40,
            INV_TYPE, 0);
          if RlkSlot <> 255 then
          begin
            Item := @Servers[Self.Base.ChannelId].Players[Self.AttackerID]
              .Base.Character.Inventory[RlkSlot];
            Servers[Self.Base.ChannelId].CreateMapObject
              (@Servers[Self.Base.ChannelId].Players[Self.AttackerID], 320,
              Item.Index);
            Servers[Self.Base.ChannelId].SendServerMsg
              ('O jogador ' + AnsiString(Servers[Self.Base.ChannelId].Players
              [Self.AttackerID].Base.Character.Name) + ' dropou a relíquia <' +
              AnsiString(ItemList[Item.Index].Name) + '>.');
            ZeroMemory(Item, sizeof(TItem));
            Servers[Self.Base.ChannelId].Players[Self.AttackerID]
              .Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, FALSE);
            cnt := cnt + 1;
          end;
        end;
        if cnt > 0 then
          Servers[Self.Base.ChannelId].Players[Self.AttackerID].SendEffect(0);

        OPP := nil;

        for i := 1 to High(Servers[Self.Base.ChannelId].Players) do
        begin
          if (Servers[Self.Base.ChannelId].Players[i].Status < PLAYING) or
            (Servers[Self.Base.ChannelId].Players[i].SocketClosed) then
            Continue;

          if (Servers[Self.Base.ChannelId].Players[i]
            .Base.PlayerCharacter.LastPos.InRange(Self.InitPos, 40)) and
            not Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.IsDead
          then
          begin
            OPP := @Servers[Self.Base.ChannelId].Players[i];
            Break;
          end;
        end;

        if OPP = nil then
        begin
          Self.IsAttacked := FALSE;
          Self.LastMoviment := Now;
          Self.CurrentPos := InitPos;
          Self.MovimentsTime := 0;
          Self.MovedTo := Init;
          Self.FirstPlayerAttacker := 0;
          Self.Base.PlayerCharacter.LastPos := Self.CurrentPos;
          Self.HP := Servers[Self.Base.ChannelId].MOBS.TMobS
            [Self.Base.MobID].InitHP;
          Self.MobMove(Self.InitPos, 50, MOVE_NORMAL); // era move normal
        end
        else
          Self.AttackerID := OPP.Base.ClientID;
        Self.FirstPlayerAttacker := OPP.Base.ClientID;
      end;
    end
    else
    begin
      if DANO > 0 then
        Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.RemoveHP
          (DANO, FALSE, FALSE);
    end;

    inc(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated);

    if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.AttacksReceivedAccumulated >= 48 then
    begin
      for i := 2 to 7 do
      begin
        if Servers[Self.Base.ChannelId].Players[Self.AttackerID]
          .Base.Character.Equip[i].Index > 0 then
        begin
          if not Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.BuffExistsByIndex(303) then
          begin
            case Servers[Self.Base.ChannelId].Players[Self.AttackerID]
              .Base.Character.Equip[i].Refi of
              1 .. 80:
                Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                  .Base.Character.Equip[i].MIN, 1);
              81 .. 160:
                Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                  .Base.Character.Equip[i].MIN, 2);
              161 .. 240:
                Dec(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
                  .Base.Character.Equip[i].MIN, 3);
            end;
          end;
          Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.SendRefreshItemSlot(EQUIP_TYPE, i,
            Servers[Self.Base.ChannelId].Players[Self.AttackerID]
            .Base.Character.Equip[i], FALSE);
        end;
      end;

      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.AttacksReceivedAccumulated := 0;
    end;

    Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.LastReceivedAttack := Now;
    Packet.MobCurrHP := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.Character.CurrentScore.CurHP;
    Packet.DeathPos := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.PlayerCharacter.LastPos;
    Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendToVisible
      (Packet, Packet.Header.size, True);

    if Packet.DANO > 0 then
    begin
      if SkillIDa > 0 then
      begin
        if (SkillData[SkillIDa].SuccessRate = 1) and
          (SkillData[SkillIDa].Range > 0) then
        begin // skill em área
          if AddBuff then
            Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.AddBuff
              (SkillIDa);
        end
        else // skill única
        begin
          if AddBuff then
            Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.AddBuff
              (SkillIDa);
        end;
      end;
    end;

    if not Self.IsAttacked then
      Self.AttackerID := 0;

  except
    on E: Exception do
      Logger.Write('Error at mob Attack Player [' + E.Message + '] b.e: ' +
        E.BaseException.Message + ' user: ' +
        String(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.Name) + ' t:' + DateTimeToStr(Now), TlogType.Error);
  end;
end;

function TMobSPosition.GetDamageByPlayer(Skill: DWORD;
  out DamageType: TDamageType): UInt64;
var
  IsPhysical: Boolean;
  ResultDamage: UInt64;
  MobDef: DWORD;
begin
  Result := 0;
  // Determina se o dano é físico ou mágico
  IsPhysical := (SkillData[Skill].Index = 96) or
    (Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.GetMobClass
    in [0 .. 3]);

  // Determina o dano base
  if IsPhysical then
  begin
    ResultDamage := Servers[Self.Base.ChannelId].MOBS.TMobS
      [Self.Base.MobID].FisAtk;
    MobDef := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.PlayerCharacter.Base.CurrentScore.DefFis;
  end
  else
  begin
    ResultDamage := Servers[Self.Base.ChannelId].MOBS.TMobS
      [Self.Base.MobID].MagAtk;
    MobDef := Servers[Self.Base.ChannelId].Players[Self.AttackerID]
      .Base.PlayerCharacter.Base.CurrentScore.DefMag;
  end;

  // Determina o tipo de dano
  DamageType := Self.GetDamageTypePlayer(Skill, IsPhysical);
  if DamageType = Miss then
    Exit;

  // Aplica o cálculo do dano
  inc(ResultDamage, SkillData[Skill].Damage);
  ResultDamage := ResultDamage - (MobDef shr 3);
  Randomize;
  inc(ResultDamage, (Random(20) + 5));

  // Aplica bônus de dano crítico
  if DamageType = Critical then
    ResultDamage := Round(ResultDamage * 1.5);

  // Garante que o dano esteja no intervalo permitido
  if (ResultDamage < 0) or (ResultDamage > 1000000) then
    ResultDamage := 1;

  Result := ResultDamage;
end;

function TMobSPosition.GetDamageTypePlayer(Skill: DWORD; IsPhys: Boolean)
  : TDamageType;
var
  RamdomArray: ARRAY [0 .. 999] OF BYTE;
  InitialSlot: WORD;
  procedure SetChance(Chance: WORD; const Type1: BYTE);
  var
    i: Integer;
  begin
    if Chance = 0 then
      Exit;
    for i := 1 to Chance do
    begin
      if InitialSlot >= 999 then
        Continue;
      RamdomArray[InitialSlot] := Type1;
      inc(InitialSlot);
    end;
  end;

begin
  ZeroMemory(@RamdomArray, 1000);
  InitialSlot := 0;

  // Define as chances para Miss, Critical e Normal
  SetChance(Servers[Self.Base.ChannelId].Players[Self.AttackerID]
    .Base.PlayerCharacter.Base.CurrentScore.Esquiva, BYTE(TDamageType.Miss));
  SetChance(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID]
    .MobLevel div 2, BYTE(TDamageType.Critical));
  SetChance(Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].MobLevel,
    BYTE(TDamageType.Normal));

  Randomize;
  Result := TDamageType(RamdomArray[Random(InitialSlot)]);
end;

procedure TMobSPosition.UpdateSpawnToPlayers(mid, smid: Integer;
  ClientHandlerID: Integer);
var
  OtherPlayer: PPlayer;
begin
  try
    if (ClientHandlerID <= 0) or (ClientHandlerID > max_connections) then Exit;

    if (Self.Base.MobID > 449) or (Self.Base.IsDead) then
    begin
      if (Self.DeadTime.Year >= Now.Year) and
         (SecondsBetween(Now, Self.DeadTime) >= Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].ReespawnTime) then
      begin
        with Self do
        begin
          Base.IsDead := False;
          IsAttacked := False;
          CurrentPos := InitPos;
          MovedTo := Init;
          MovimentsTime := 0;
          FirstPlayerAttacker := 0;
          LastSkillUsedByMob := Now;
          ActualUsingSkill := 0;
          LastMoviment := Now;
          HP := Servers[Base.ChannelId].MOBS.TMobS[Base.MobID].InitHP;
          MP := HP;
        end;
      end;
      Exit;
    end;

    OtherPlayer := Servers[Self.Base.ChannelId].GetPlayer(ClientHandlerID);
    if not Assigned(OtherPlayer) or OtherPlayer^.SocketClosed or (OtherPlayer^.Status <> PLAYING) then Exit;
    if (Self.CurrentPos.X < 50) or (Self.CurrentPos.Y < 50) then Exit;
    if OtherPlayer^.Unlogging or OtherPlayer^.Base.IsDead or Self.Base.IsDead then Exit;
    if not Servers[Self.Base.ChannelId].MOBS.TMobS[Self.Base.MobID].IsActiveToSpawn then Exit;
    if not OtherPlayer^.IsInstantiated or not OtherPlayer^.Base.PlayerCharacter.LastPos.IsValid then Exit;
    if not Self.CurrentPos.IsValid then Exit;

    if OtherPlayer^.Base.PlayerCharacter.LastPos.InRange(Self.CurrentPos, DISTANCE_TO_WATCH) then
    begin
      if not OtherPlayer^.Base.VisibleMobs.Contains(Self.Base.ClientID) then
      begin
        OtherPlayer^.Base.VisibleMobs.Add(Self.Base.ClientID);
        OtherPlayer^.Base.AddTargetToList(@Self.Base);

        if Self.isGuard and ((BYTE(OtherPlayer^.Account.Header.Nation) = Servers[Self.Base.ChannelId].NationID) or
           (OtherPlayer^.Base.Character.Level < 16)) then
          OtherPlayer^.SpawnMobGuard(Self.Base.MobID, Self.Base.SecondIndex)
        else
          OtherPlayer^.SpawnMob(Self.Base.MobID, Self.Base.SecondIndex);
      end;

      if not Self.Base.VisibleMobs.Contains(OtherPlayer^.Base.ClientID) then
        Self.Base.VisibleMobs.Add(OtherPlayer^.Base.ClientID);
    end
    else
    begin
      if OtherPlayer^.Base.VisibleMobs.Contains(Self.Base.ClientID) then
      begin
        if not Self.isTemp then
        begin
          OtherPlayer^.UnspawnMob(Self.Base.MobID, Self.Base.SecondIndex);
          OtherPlayer^.Base.VisibleMobs.Remove(Self.Base.ClientID);
          OtherPlayer^.Base.RemoveTargetFromList(@Self.Base);
        end;
      end;

      if Self.Base.VisibleMobs.Contains(OtherPlayer.Base.ClientID) then
        Self.Base.VisibleMobs.Remove(OtherPlayer.Base.ClientID);
    end;
  except
    on E: Exception do
    begin
      OtherPlayer.SocketClosed := True;
      Logger.Write('Error at mob UpdateSpawnToPlayers [' + E.Message + '] b.e: ' + E.BaseException.Message + ' t:' + DateTimeToStr(Now), TlogType.Error);
      Raise;
    end;
  end;
end;

end.
