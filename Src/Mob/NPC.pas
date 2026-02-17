unit NPC;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses BaseNpc, PlayerData, MiscData, System.Ansistrings;
{$OLDTYPELAYOUT ON}

type
  PNpc = ^TNpc;

  TNpc = record
  public
    Base: TBaseNpc;
    Character: TCustomNpc;
    PlayerChar: TNpcCharacter;
    NPCFile: TNPCFile;
    GenerID: word;
    IsInstantiated: Boolean;
    IsAttacked: Boolean;
    AttackerID: byte;
    FirstPlayerAttacker: byte;
    LastMyAttack: TDateTime;
    LastSkillAttack: TDateTime;
    DeadTime: TDateTime;
    LastUpdatedHP: TDateTime;
    FirstPosition: TPosition;
    DevirName: String;
    { TNpc }
    procedure Create(Id: word; Name: string; Channel: byte);
    function LoadFile(NPCName: string): Boolean;
    function InstanciateNPC: Boolean;
    procedure MobMove(Position: TPosition; Speed: byte = 25;
      MoveType: byte = 0);
    procedure AttackPlayer(OtherPlayer: Pointer; InitialDamage: word;
      SkillID: word = 0);
    procedure UpdateHPForVisibles();
    procedure KillStone(Id: word; KillerId: byte);
    procedure KillGuard(Id: word; KillerId: byte);
    function GetDevirIdByStoneOrGuardId(Id: word): word;
  end;
{$OLDTYPELAYOUT OFF}

implementation

uses GlobalDefs, Windows, SysUtils, Functions, Packets, Player, Math,
  DateUtils, ServerSocket, ItemFunctions, Log;
{$REGION 'TNpc'}

procedure TNpc.Create(Id: word; Name: string; Channel: byte);
begin

  // if id <> 2092 then
  // exit;

  if (Self.LoadFile(Name)) then
  begin

    case Id of
      2130:
        begin
//          WriteLn('Nero Ursula');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Criança Raptada';
          NPCFile.Header.Options[0] := 60;
          NPCFile.Header.Options[1] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '88', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 229;
          NPCFile.Base.Base.Equip[0].App := 229;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 90;
          NPCFile.Base.LastPos.X := 3352;
          NPCFile.Base.LastPos.Y := 3660;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;

      2706:
        begin
//          WriteLn('Nero Ursula segundo andar');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Engenheiro Raptado';
          NPCFile.Header.Options[0] := 59;
          NPCFile.Header.Options[1] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '611', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 229;
          NPCFile.Base.Base.Equip[0].App := 229;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 90;
          NPCFile.Base.LastPos.X := 3533;
          NPCFile.Base.LastPos.Y := 3774;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;

      2707:
        begin

          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Teleport Save';
          NPCFile.Header.Options[0] := 47;
          NPCFile.Header.Options[1] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '1006', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 215;
          NPCFile.Base.Base.Equip[0].App := 215;
          NPCFile.Base.Base.Equip[6].Index := 1501;
          NPCFile.Base.Base.Equip[6].App := 1501;
          NPCFile.Base.Base.Equip[6].Refi := 240;
          NPCFile.Base.Rotation := 90;
          NPCFile.Base.LastPos := TPosition.Create(3424, 3760);

          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;

      2700:
        begin
//          WriteLn('Lilola Ursula');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Dungeon Buffs';
          NPCFile.Header.Options[0] := 64;
          NPCFile.Header.Options[1] := 35;
          NPCFile.Header.Options[2] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '842', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 225;
          NPCFile.Base.Base.Equip[0].App := 225;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 282;
          NPCFile.Base.LastPos.X := 3445;
          NPCFile.Base.LastPos.Y := 3621;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;
      2701:
        begin
//          WriteLn('Lilola Evgenia Inferior');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Dungeon Buffs';
          NPCFile.Header.Options[0] := 64;
          NPCFile.Header.Options[1] := 35;
          NPCFile.Header.Options[2] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '842', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 225;
          NPCFile.Base.Base.Equip[0].App := 225;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 282;
          NPCFile.Base.LastPos.X := 3778;
          NPCFile.Base.LastPos.Y := 3664;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;
      2702:
        begin
//          WriteLn('Lilola Evgenia Superior');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Dungeon Buffs';
          NPCFile.Header.Options[0] := 64;
          NPCFile.Header.Options[1] := 35;
          NPCFile.Header.Options[2] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '842', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 225;
          NPCFile.Base.Base.Equip[0].App := 225;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 282;
          NPCFile.Base.LastPos.X := 3629;
          NPCFile.Base.LastPos.Y := 3421;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;
      2703:
        begin
//          WriteLn('Lilola Mina 1');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Dungeon Buffs';
          NPCFile.Header.Options[0] := 64;
          NPCFile.Header.Options[1] := 35;
          NPCFile.Header.Options[2] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '842', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 225;
          NPCFile.Base.Base.Equip[0].App := 225;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 282;
          NPCFile.Base.LastPos.X := 2848;
          NPCFile.Base.LastPos.Y := 3346;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;
      2704:
        begin
//          WriteLn('Lilola Jardim');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Dungeon Buffs';
          NPCFile.Header.Options[0] := 64;
          NPCFile.Header.Options[1] := 35;
          NPCFile.Header.Options[2] := 8;
          NPCFile.Base.Index := Id;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '842', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 225;
          NPCFile.Base.Base.Equip[0].App := 225;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 282;
          NPCFile.Base.LastPos.X := 3350;
          NPCFile.Base.LastPos.Y := 3290;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;
      2705:
        begin
//          WriteLn('Lilola Mina 2');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Dungeon Buffs';
          NPCFile.Header.Options[0] := 64;
          NPCFile.Header.Options[1] := 35;
          NPCFile.Header.Options[2] := 8;
          NPCFile.Base.Index := 2700;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '842', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 225;
          NPCFile.Base.Base.Equip[0].App := 225;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 282;
          NPCFile.Base.LastPos.X := 2575;
          NPCFile.Base.LastPos.Y := 3771;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;

        2708:
        begin
//          WriteLn('Retorno de Valhalla');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Retorno Nação';
          NPCFile.Header.Options[0] := 83;
          NPCFile.Header.Options[1] := 8;
          NPCFile.Base.Index := 2708;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '842', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 225;
          NPCFile.Base.Base.Equip[0].App := 225;
          NPCFile.Base.Base.Equip[6].Index := 1504;
          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 282;
          NPCFile.Base.LastPos := TPosition.Create(1486, 1610);
//          NPCFile.Base.LastPos.X := 2575;
//          NPCFile.Base.LastPos.Y := 3771;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;

        2709:
        begin
//          WriteLn('Retorno de Valhalla');
          Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
          FillChar(NPCFile.Header.Options, sizeof(NPCFile.Header.Options), 0);
          NPCFile.Header.Title := 'Acesso Valhalla';

          NPCFile.Header.Options[0] := 88;
          NPCFile.Header.Options[1] := 8;


          NPCFile.Base.Index := 2709;
          System.Ansistrings.StrPLCopy(NPCFile.Base.Base.Name, '1006', 16);
          NPCFile.Base.Base.CurrentScore.Sizes.Altura := 7;
          NPCFile.Base.Base.CurrentScore.Sizes.Tronco := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Perna := 119;
          NPCFile.Base.Base.CurrentScore.Sizes.Corpo := 180;
          NPCFile.Base.Base.CurrentScore.MaxHp := 20000;
          NPCFile.Base.Base.CurrentScore.CurHP := 20000;
          NPCFile.Base.Base.CurrentScore.MaxMp := 20000;
          NPCFile.Base.Base.Equip[0].Index := 569;
          NPCFile.Base.Base.Equip[0].App := 569;


//          NPCFile.Base.Base.Equip[6].Index := 1504;
//          NPCFile.Base.Base.Equip[6].App := 1504;
          NPCFile.Base.Rotation := 134;
          NPCFile.Base.LastPos := TPosition.Create(3433, 715);
//          NPCFile.Base.LastPos.X := 2575;
//          NPCFile.Base.LastPos.Y := 3771;
          Base.Create(@Self.Character, NPCFile.Base.Index, Channel, true);
          Exit;
        end;
    else

      Move(NPCFile.Base.Base, Self.Character, sizeof(TCustomNpc));
      Base.Create(@Self.Character, Id, Channel, true);

    end;

  end;
end;

function TNpc.LoadFile(NPCName: string): Boolean;
var
  f: file of TNPCFile;
  local: string;
begin
  Result := False;
  ZeroMemory(@NPCFile, sizeof(TAccountFile));
  local := 'Data\NPCs\' + Trim(NPCName) + '.npc';
  if not(FileExists(local)) then
    Exit;
  try
    AssignFile(f, local);
    Reset(f);
    Read(f, NPCFile);
    CloseFile(f);
    Result := true;
  except
    CloseFile(f);
  end;
end;

function TNpc.InstanciateNPC;
// var
// i: BYTE;
begin
  Result := False;
  try
    Move(NPCFile.Base, Self.PlayerChar, sizeof(TNpcDB));
    Move(Self.PlayerChar, Self.Base.PlayerCharacter, sizeof(TNpcCharacter));
  except
    Exit;
  end;
  Result := true;
end;

procedure TNpc.MobMove(Position: TPosition; Speed: byte = 25;
  MoveType: byte = 0);
var
  Packet: TMobMovimentPacket;
  i: byte;
begin
  ZeroMemory(@Packet, sizeof(TMobMovimentPacket));
  Packet.Header.size := sizeof(TMobMovimentPacket);
  Packet.Header.Index := Self.PlayerChar.Base.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Position;
  Packet.MoveType := MoveType;
  Packet.Speed := Speed;
  for i in Self.Base.VisibleMobs do
  begin
    if (i <= MAX_CONNECTIONS) then
    begin
      if (Servers[Self.Base.ChannelId].Players[i].status < TPlayerStatus.Playing)
      then
        continue;
      Servers[Self.Base.ChannelId].Players[i].SendPacket(Packet,
        Packet.Header.size);
    end;
  end;
end;

procedure TNpc.AttackPlayer(OtherPlayer: Pointer; InitialDamage: word;
  SkillID: word = 0);
var
  MPLayer: PPlayer;
  Packet: TRecvDamagePacket;
  DANO, cnt: Integer;
  PlDef, AttackResultType: Integer;
  Item: PItem;
  RlkSlot: Integer;
begin
  try
    // WriteLN('atacando jogador');
    MPLayer := OtherPlayer;
    ZeroMemory(@Packet, sizeof(Packet));
    Packet.Header.size := sizeof(Packet);
    Packet.Header.Index := Self.PlayerChar.Base.ClientID;
    Packet.Header.Code := $102;
    Packet.SkillID := SkillID;
    Packet.AttackerPos := Self.PlayerChar.LastPos;
    Packet.AttackerID := Packet.Header.Index;
    Packet.Animation := 6;
    Packet.AttackerHP := Self.PlayerChar.Base.CurrentScore.CurHP;
    Packet.TargetID := Self.AttackerID;
    Packet.MobAnimation := 26;
    var
    Atacante := Servers[Self.Base.ChannelId].Players[Self.AttackerID];

    // MPlayer:= @Servers[Self.Base.ChannelId].Players[Self.AttackerID];

    PlDef := (MPLayer.Base.Character.CurrentScore.DefMag +
      MPLayer.Base.Character.CurrentScore.DefFis) div 2;
    DANO := InitialDamage - (PlDef shr 3);
    inc(DANO, (RandomRange(10, 49) div 2) + 5);

    Randomize;
    AttackResultType := RandomRange(1, 100);
    case AttackResultType of
      1 .. 20:
        Packet.DnType := TDamageType.Miss;
      21 .. 50:
        Packet.DnType := TDamageType.Critical;
    else
      Packet.DnType := TDamageType.Normal;
    end;

    if Packet.DnType = TDamageType.Miss then
      DANO := 0
    else
    begin
      if Atacante.Base.BuffExistsByIndex(19) then
      begin
        DANO := 0;
        Packet.DnType := TDamageType.Block;
        Atacante.Base.RemoveBuffByIndex(19);
      end
      else if Atacante.Base.BuffExistsByIndex(91) then
      begin
        DANO := 0;
        Packet.DnType := TDamageType.Miss2;
        Atacante.Base.RemoveBuffByIndex(91);
      end;
    end;

    Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.AddBuff(SkillID);

    Packet.DANO := DANO;

    if Packet.DANO >= Atacante.Base.Character.CurrentScore.CurHP then
    begin
      Servers[Self.Base.ChannelId].Players[Self.AttackerID]
        .Base.Character.CurrentScore.CurHP := 0;
      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.IsDead := true;
      Servers[Self.Base.ChannelId].Players[Self.AttackerID].Base.SendEffect($0);

      cnt := 0;
      repeat
        RlkSlot := TItemFunctions.GetItemSlotByItemType(Atacante, 40,
          INV_TYPE, 0);
        if RlkSlot <> 255 then
        begin
          Item := @Atacante.Base.Character.Inventory[RlkSlot];
          Servers[Self.Base.ChannelId].CreateMapObject(@Atacante, 320,
            Item.Index);
          Servers[Self.Base.ChannelId].SendServerMsg
            ('O jogador ' + AnsiString(Atacante.Base.Character.Name) +
            ' dropou a relíquia <' + AnsiString(ItemList[Item.Index]
            .Name) + '>.');
          ZeroMemory(Item, sizeof(TItem));
          Atacante.Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, False);
          inc(cnt);
        end;
      until RlkSlot = 255;

      if cnt > 0 then
        Atacante.SendEffect(0);

      Packet.MobAnimation := 30;
      Self.IsAttacked := False;
      Self.PlayerChar.LastPos := Self.PlayerChar.CurrentPos;

      if Self.Character.ClientID = 3335 then
        Self.MobMove(Self.PlayerChar.LastPos, 70);

      Self.MobMove(Self.PlayerChar.LastPos, 45);
    end
    else
    begin
      Atacante.Base.Character.CurrentScore.CurHP :=
        Atacante.Base.Character.CurrentScore.CurHP - Packet.DANO;
    end;

    Atacante.Base.LastReceivedAttack := Now;
    Packet.MobCurrHP := Atacante.Base.Character.CurrentScore.CurHP;
    Atacante.Base.SendToVisible(Packet, Packet.Header.size, true);
  except

    on E: Exception do
    begin
      Logger.Write('erro no AttackPlayer (NPC >> PLAYER)' + E.Message,
        TLogType.Error);
    end;

  end;

end;

procedure TNpc.UpdateHPForVisibles();
var
  Packet: TSendCurrentHPMPPacket;
begin
  if ((Now >= IncSecond(Self.LastUpdatedHP, 10)) and
    Assigned(Self.Base.VisibleMobs)) then
  begin
    if (Self.Base.VisibleMobs.Count > 0) then
    begin
      ZeroMemory(@Packet, sizeof(TSendCurrentHPMPPacket));
      var
      Base := Self.PlayerChar.Base;
      Packet.Header.size := sizeof(TSendCurrentHPMPPacket);
      Packet.Header.Code := $103; // AIKA
      Packet.Header.Index := Base.ClientID;
      Packet.CurHP := Base.CurrentScore.CurHP;
      Packet.MaxHp := Base.CurrentScore.MaxHp;
      Packet.CurMP := Base.CurrentScore.CurMP;
      Packet.MaxMp := Base.CurrentScore.MaxMp;
      Self.Base.SendToVisible(Packet, Packet.Header.size);
    end;
  end;
end;

procedure TNpc.KillStone(Id: word; KillerId: byte);
var
  DId, oldDid, i, deadCnt: Integer;
  TempId: Integer;
  AllDied: Boolean;
begin
  DId := Self.GetDevirIdByStoneOrGuardId(Id);
  if (DId = 255) then
    Exit;
  case DId of
    0:
      TempId := 3335;
    1:
      TempId := 3336;
    2:
      TempId := 3337;
    3:
      TempId := 3338;
    4:
      TempId := 3339;
  end;
  oldDid := DId;
  inc(Servers[Self.Base.ChannelId].Devires[DId].StonesDied, 1);
  deadCnt := 0;
  for i := 3340 to 3354 do
  begin
    DId := Self.GetDevirIdByStoneOrGuardId(i);
    if (DId = 255) then
      continue;
    if (DId <> oldDid) then
      continue;
    if (Servers[Self.Base.ChannelId].DevirStones[i].Base.IsDead) then
      inc(deadCnt, 1);
  end;
  if (deadCnt >= 3) then
  begin
    if (Servers[Self.Base.ChannelId].Devires[oldDid].IsOpen = true) then
      Exit;
    Servers[Self.Base.ChannelId].SendServerMsg
      ('O templo de ' + AnsiString(Servers[Self.Base.ChannelId].DevirNpc[TempId]
      .DevirName) + ' foi aberto, e poderá ser roubado.', 16, 16, 16);
    Servers[Self.Base.ChannelId].Devires[oldDid].IsOpen := true;
    Servers[Self.Base.ChannelId].Devires[oldDid].OpenTime := Now;
    Servers[Self.Base.ChannelId].OpenDevir(oldDid, TempId, KillerId);
  end;
end;

procedure TNpc.KillGuard(Id: word; KillerId: byte);
// var
// DId: Integer;
// TempId: Integer;
begin
  { Did := Self.GetDevirIdByStoneOrGuardId(id);
    if(Did = 255) then
    Exit;
    case Did of
    0:
    TempId := 3335;
    1:
    TempId := 3336;
    2:
    TempId := 3337;
    3:
    TempId := 3338;
    4:
    TempId := 3339;
    end;
    Inc(Servers[Self.Base.ChannelId].Devires[Did].GuardsDied, 1);
    if(Servers[Self.Base.ChannelId].Devires[Did].ReliqCount <= 2) then
    begin //tenho que checar pra ver se os totens estão vivos ou não
    if(Servers[Self.Base.ChannelId].Devires[Did].StonesDied >= 3) then
    begin
    if(Servers[Self.Base.ChannelId].Devires[Did].GuardsDied >= 3) then
    begin
    if(Servers[Self.Base.ChannelId].Devires[Did].IsOpen = True) then
    Exit;
    Servers[Self.Base.ChannelId].SendServerMsg('O templo de ' +
    AnsiString(
    Servers[Self.Base.ChannelId].DevirNpc[Tempid].PlayerChar.Base.PranName[0]) +
    ' foi aberto, e poderá ser roubado.', 16, 16, 16);
    Servers[Self.Base.ChannelId].Devires[Did].IsOpen := True;
    Servers[Self.Base.ChannelId].Devires[Did].OpenTime := Now;
    Servers[Self.Base.ChannelId].OpenDevir(Did, Tempid, KillerId);
    end;
    end;
    end
    else //tenho que checar pra ver se apenas as pedras estão vivas ou não
    begin
    if(Servers[Self.Base.ChannelId].Devires[Did].StonesDied >= 3) then
    begin
    if(Servers[Self.Base.ChannelId].Devires[Did].IsOpen = True) then
    Exit;
    Servers[Self.Base.ChannelId].SendServerMsg('O templo de ' +
    AnsiString(
    Servers[Self.Base.ChannelId].DevirNpc[Tempid].PlayerChar.Base.PranName[0]) +
    ' foi aberto, e poderá ser roubado.', 16, 16, 16);
    Servers[Self.Base.ChannelId].Devires[Did].IsOpen := True;
    Servers[Self.Base.ChannelId].Devires[Did].OpenTime := Now;
    Servers[Self.Base.ChannelId].OpenDevir(Did, Tempid, KillerId);
    end;
    end; }
end;

function TNpc.GetDevirIdByStoneOrGuardId(Id: word): word;
begin
  case Id of
    3340 .. 3365:
      case (Id - 3340) mod 5 of
        0:
          Result := 0; // amk devir
        1:
          Result := 1; // sig devir
        2:
          Result := 2; // cah devir
        3:
          Result := 3; // mir devir
        4:
          Result := 4; // zel devir
      else
        Result := 255;
      end;
  else
    Result := 255;
  end;
end;

{$ENDREGION}

end.
