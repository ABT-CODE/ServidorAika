unit PacketHandlers;
// {$OPTIMIZATION ON}  // Ativa otimizações gerais
// {$O+}               // Ativa otimização de loops

interface

uses
  Player, Packets, SysUtils, AnsiStrings, Clipbrd, Generics.Collections,
  Winsock2, Math, System.Threading;

type
  TPacketHandlers = class(TObject)
  public

    class function teste(var Player: TPlayer): boolean;
    class function SeeInventory(var Player: TPlayer; id: Integer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function CheckLogin(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function CreateCharacter(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function RequestDeleteChar(var Player: TPlayer;
      var Buffer: Array of BYTE): boolean;
    class function DeleteChar(var Player: TPlayer; var Buffer: array of BYTE)
      : boolean; static;
    class function NumericToken(var Player: TPlayer; var Buffer: array of BYTE)
      : boolean; static;
    class function MovementCommand(var Player: PPlayer;
      var Buffer: array of BYTE): boolean;
    class function OpenNPC(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function CloseNPCOption(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function UpdateRotation(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function UpdateAction(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function ChangeGold(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    { Chat Functions }
    class function SendClientSay(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function SendItemChat(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function PKMode(var Player: TPlayer): boolean;
    class function BuyNPCItens(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function SellNPCItens(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    { Inventory Item Functions }
    class function DeleteItem(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function UngroupItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function AgroupItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function MoveItem(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    { Change Item Atributes [Refine/etc] }
    class function ChangeItemAttribute(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Troca }
    class function TradeRequest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function TradeResponse(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function TradeRefresh(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function TradeCancel(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Item Bar Functions }
    class function ChangeItemBar(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Mob Functions }
    class function UpdateMobInfo(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Premium Items }
    class function BuyItemCash(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function SendGift(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function ReclaimCoupom(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Item Functions }
    class function UseItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function UseBuffItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function UnsealItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Buff Functions }
    class function RemoveBuff(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Attack & Skill Functions }
    class function UseSkill(var Player: PPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function LearnSkill(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function ResetSkills(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function CheckItemsDefault(Player: PPlayer): boolean;
    class function AttackTarget(Player: PPlayer; Packet: PPacket_302;
      ByUseSkill: boolean = false; Tipo: BYTE = 0): boolean;
    class function RevivePlayer(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function CancelSkillLaunching(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Friend List }
    class function AddFriendRequest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function AddFriendResponse(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function DeleteFriend(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Friend Chat }
    class function OpenFriendWindow(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function SendFriendSay(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function CloseFriendWindow(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Ver Char Info }
    class function RequestCharInfo(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Party }
    class function SendParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function AcceptParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function KickParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function DestroyParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function GiveLeaderParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function UpdateMemberPosition(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function AddSelfParty(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function PartyAlocateConfig(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Raid }
    class function SendRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function AcceptRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function ExitRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function DestroyRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function GiveLeaderRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function RemoveFromRaid(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { PersonalShop }
    class function CreatePersonalShop(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function OpenPersonalShop(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function BuyPersonalShopItem(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function ClosePersonalShop(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    { Karak }
    class function KarakAereo(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function EntrarElter(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;

    class function UseMountSkill(var Player: PPlayer;
      var Buffer: ARRAY OF BYTE): boolean;

    class function StartFishing(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function EndFishing(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function StartF12(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function StartJoquempo(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;

    { Change Channel }

    class function ChangeChannel(var Player: TPlayer; var Buffer: ARRAY OF BYTE; Ação: Integer = 0): boolean;
    class function TeleportLakia(var Player: TPlayer): boolean;
    class function TeleportOutValhalla(var Player: TPlayer): boolean;
    class function TeleportLeopold(var Player: TPlayer): boolean;
    class function ChangeChannelOther(var Player: TPlayer; var Packet: TChangeChannelPacket; Ação: Integer = 0): boolean;
    class function LoginIntoChannel(var Player: TPlayer; var Buffer: ARRAY OF BYTE; Ação: Integer = 0): boolean;
    { Guild }
    class function CreateGuild(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function CloseGuildChest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function ChangeGuildMemberRank(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function UpdateGuildRanksConfig(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function UpdateGuildNotices(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function UpdateGuildSite(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function InviteToGuildRequest(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function InviteToGuildAccept(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function InviteToGuildDeny(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function KickMemberOfGuild(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function ExitGuild(var Player: TPlayer;
      var Buffer: ARRAY OF BYTE): boolean;
    class function RequestGuildToAlly(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    class function ChangeMasterGuild(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Request Time }
    class function RequestServerTime(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    class function RequestServerPing(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Other Handlers }
    class function GetStatusPoint(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    class function ReceiveEventItem(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Duel }
    class function SendRequestDuel(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    class function DuelResponse(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Quest }
    class function AbandonQuest(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Teleport do FC }
    class function TeleportSetPosition(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Titles }
    class function UpdateActiveTitle(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Pran }
    class function RenamePran(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    { Mail }
    class function openMail(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function withdrawMailItem(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function checkSendMailRequirements(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    class function sendCharacterMail(var Player: TPlayer;
      var Buffer: array of BYTE): boolean;
    { Dungeons }
    class function RequestEnterDungeon(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function DungeonLobbyConfirm(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    { MakeItems }
    class function MakeItem(var Player: TPlayer; Buffer: Array of BYTE)
      : boolean;
    class function RepairItens(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function RenoveItem(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    { Nation Packets }
    class function UpdateNationGold(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function UpdateNationTaxes(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;

    // { GM Tool Functions }
    // class function CheckGMLogin(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMPlayerMove(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMSendChat(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMGoldManagment(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMCashManagment(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMLevelManagment(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMBuffsManagment(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMDisconnect(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMBan(var Player: TPlayer; Buffer: ARRAY OF BYTE): boolean;
    // class function GMEventItem(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMEventItemForAll(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestServerInformation(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMSendSpawnMob(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestPlayerAccount(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMReceiveAccBackup(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestGMUsernames(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestCommandsAutoriz(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMApproveCommand(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMReproveCommand(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMSendAddEffect(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestCreateCoupom(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestComprovantSearchID(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestComprovantSearchName(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestCreateComprovant(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestComprovantValidate(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;
    // class function GMRequestDeletePrans(var Player: TPlayer;
    // Buffer: ARRAY OF BYTE): boolean;

    { All Attributes Aika Functions }
    class function RequestAllAttributes(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    class function RequestAllAttributesTarget(var Player: TPlayer;
      Buffer: ARRAY OF BYTE): boolean;
    { Auction }
    class function RequestAuctionItems(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function RequestRegisterItem(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function RequestOwnAuctionItems(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function RequestAuctionOfferCancel(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function RequestAuctionOfferBuy(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;

    { Reliquares }
    class function RequestUpdateReliquare(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function MoveItemToReliquare(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;

    { Collect Item }
    class function CollectMapItem(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
    class function CancelCollectMapItem(var Player: TPlayer;
      Buffer: Array of BYTE): boolean;
  end;

implementation

uses
  GlobalDefs, Functions, Log, PlayerData, Util, MiscData, Windows,
  NPCHandlers, ItemFunctions, SkillFunctions, DateUtils, PartyData,
  CommandHandlers, BaseMob, GuildData, MOB, EntityMail, FilesData,
  AuctionFunctions, SQL, Dungeon, BaseNpc;
{$REGION 'Login Functions'}

class function TPacketHandlers.CheckLogin(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TRequestLoginPacket absolute Buffer;
  Username: String;
  I: Integer;
  Cid: Word;
  dcs: boolean;
  PlayerPtr: PPlayer;

  procedure DisconnectPlayer;
  begin
    Player.SocketClosed := True;
    Servers[Player.ChannelIndex].Disconnect(Player);
  end;

begin
  Result := false;
  PlayerPtr := @Player;

  if (Packet.Version <> 124) then
  begin
    Player.SendClientMessage
      ('Client desatualizado. Abrir pelo Launcher como Administrador.');
    Logger.Write(Packet.Version.ToString, TLogType.Packets);
    DisconnectPlayer;
    Exit;
  end;

  Username := LowerCase(TFunctions.CharArrayToString(Packet.Username));
  ZeroMemory(@Player.Account.Characters, SizeOf(TCharacterDB) * 3);

  if not Player.LoadAccSQL(Username) then
  begin
    Player.SendClientMessage('Conta não encontrada.');
    DisconnectPlayer;
    Exit;
  end;

  if Player.Account.Header.AccountStatus = 8 then
  begin
    Player.SendClientMessage
      ('Conta bloqueada. Entre em contato com o suporte.');
    DisconnectPlayer;
    Exit;
  end;

  dcs := false;

  if not(Player.Account.Header.Nation = TCitizenShip.none) then
  begin

    if not(Player.ChannelIndex = Ord(Player.Account.Header.Nation) - 1) then
    begin
      WriteLn('desconectando jogador');
      DisconnectPlayer;
      Exit;
    end;

  end;

  for I := Low(Servers) to High(Servers) do
  begin

    if Player.ChannelIndex = I then
      Cid := Servers[I].GetPlayerByUsernameAux(Username, Player.Base.ClientID)
    else
      Cid := Servers[I].GetPlayerByUsername(Username);

    if Cid > 0 then
    begin
      Servers[I].Disconnect(Cid);
      Servers[I].Disconnect(Servers[I].Players[Cid]);
      Servers[I].Players[Cid].SocketClosed := True;

      if Assigned(Servers[I].Players[Cid].Thread) then
      begin
        closesocket(Servers[I].Players[Cid].Socket);
        if not Servers[I].Players[Cid].Thread.Finished then
          Servers[I].Players[Cid].Thread.Terminate;
        WaitForSingleObject(Servers[I].Players[Cid].Thread.Handle, 10000);
      end;

      ZeroMemory(@Servers[I].Players[Cid], SizeOf(TPlayer));
      dcs := True;
    end;

  end;

  if dcs then
  begin
    Player.SendClientMessage('Conexão anterior finalizada.');
    Player.Account.Header.IsActive := True;
    Player.Base.IsActive := True;
    Player.Status := CharList;    //WaitingLogin
    DisconnectPlayer;
    Exit;
  end;

  Player.Account.Header.IsActive := True;
  Logger.Write('[' + string(ServerList[Player.ChannelIndex].Name) + ']: Conta conectada [' + Username + '].', TLogType.ConnectionsTraffic);
  Player.Authenticated := True;
  Player.SaveStatus(Username);
  Player.SendCharList;
  Result := True;
end;

class function TPacketHandlers.NumericToken(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TNumericTokenPacket absolute Buffer;
begin
  Result := True; // 0 Não tem  // 1 tem numerica //2 trocar
  Player.SaveCharOnCharRoom(Packet.Slot);
  Player.SendToWorld(Packet.Slot);

  Logger.Write('[' + Player.Account.Header.Username + '] | Personagem [' +
          String(Player.Account.Characters[Packet.Slot].Base.Name) + '] | Autenticado e Logado em: [' +
          DateTimeToStr(Now) + ']', TLogType.ConnectionsTraffic);

  Exit;
  if Player.Account.Header.NumError[Packet.Slot] >= 5 then
  begin
    Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
    Exit;
  end;

  case Packet.RequestChange of
    0:
      if Player.Account.Header.NumericToken[Packet.Slot] = '' then
      begin
        Player.Account.Header.NumericToken[Packet.Slot] := Packet.Numeric_1;
        Player.SaveCharOnCharRoom(Packet.Slot);
        Player.SendToWorld(Packet.Slot);
      end;
    1, 2:
      if (AnsiCompareText(Packet.Numeric_1,
        Trim(Player.Account.Header.NumericToken[Packet.Slot])) = 0) or
        (Packet.RequestChange = 2) and
        (AnsiCompareText(Packet.Numeric_2,
        Trim(Player.Account.Header.NumericToken[Packet.Slot])) = 0) then
      begin
        if Packet.RequestChange = 2 then
          Player.Account.Header.NumericToken[Packet.Slot] := Packet.Numeric_1;

        Player.Account.Header.NumError[Packet.Slot] := 0;
        Player.SaveCharOnCharRoom(Packet.Slot);
        Player.SendToWorld(Packet.Slot);
      end
      else
      begin
        Inc(Player.Account.Header.NumError[Packet.Slot]);
        Player.SubStatus := Waiting;
        Player.SendPacket(Packet, Packet.Header.Size);
        Player.SaveCharOnCharRoom(Packet.Slot);

        if Packet.RequestChange = 1 then
          Player.SendCharList;
      end;
  end;
end;

{$ENDREGION}
{$REGION 'Character Functions'}

class function TPacketHandlers.CreateCharacter(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TCreateCharacterRequestPacket absolute Buffer;
  ClasseChar: BYTE;
//  PlayerSQLComp: TQuery;
begin
  Result := True;

  if not(Player.VerifyAmount(string(Packet.Name))) then
  begin
    Player.SendClientMessage('Você já tem 3 personagens.', 16, 0, 1);
    Exit;
  end;

  if not(TFunctions.IsLetter(string(Packet.Name))) then
  begin
    Player.SendClientMessage('Você só pode usar caracteres alfanuméricos.',
      16, 0, 1);
    Exit;
  end;

  if (Length(string(Packet.Name)) > 14) then
  begin
    Player.SendClientMessage('Limitado a 14 caracteres apenas.', 16, 0, 1);
    Exit;
  end;

  if Player.NameExists(string(Packet.Name)) then
  begin
    Player.SendClientMessage('Já existe um personagem com esse nome.',
      16, 0, 1);
    Exit;
  end;

  if (1 = 1) then
  begin
    var
      CombinedString: string;
    CombinedString := '';
    for var I := 0 to 15 do
      CombinedString := CombinedString + Packet.Name[I];

    // Verifica se a string combinada é 'leilão' ou 'leilao'
    if (LowerCase(CombinedString) = 'leilão') or
      (LowerCase(CombinedString) = 'leilao') or
      (LowerCase(CombinedString) = 'rafinha') or
      (LowerCase(CombinedString) = 'administrador') or
      (LowerCase(CombinedString) = 'admin') or
      (LowerCase(CombinedString) = 'caligula') or
      (LowerCase(CombinedString) = 'gm') then
      Exit;
  end;

  if (Packet.SlotIndex > 2) then
  begin
    Player.SendClientMessage('SLOT_ERROR', 16, 0, 1);
    Exit;
  end;
  if (Packet.ClassIndex < 10) then
  begin
    Player.SendClientMessage('class_id error, try to create your toon again.',
      16, 0, 1);
    Exit;
  end;
  ClasseChar := 0;
  // war
  if (Packet.ClassIndex >= 10) and (Packet.ClassIndex <= 19) then
    ClasseChar := 0;
  // templar
  if (Packet.ClassIndex >= 20) and (Packet.ClassIndex <= 29) then
    ClasseChar := 1;
  // att
  if (Packet.ClassIndex >= 30) and (Packet.ClassIndex <= 39) then
    ClasseChar := 2;
  // dual
  if (Packet.ClassIndex >= 40) and (Packet.ClassIndex <= 49) then
    ClasseChar := 3;
  // mago
  if (Packet.ClassIndex >= 50) and (Packet.ClassIndex <= 59) then
    ClasseChar := 4;
  // cleriga
  if (Packet.ClassIndex >= 60) and (Packet.ClassIndex <= 69) then
    ClasseChar := 5;
  if (Packet.Cabelo < 7700) or (Packet.Cabelo > 7731) then
    Exit;
  // Move os atributos iniciais para a database qndo cria o char
  Move(InitialAccounts[ClasseChar], Player.Account.Characters[Packet.SlotIndex],
    SizeOf(TCharacterDB));
  Player.Account.Characters[Packet.SlotIndex].Base.Equip[0].Index :=
    Packet.ClassIndex;
  Player.Account.Characters[Packet.SlotIndex].Base.Equip[1].Index :=
    Packet.Cabelo;
  for var I := 120 to 125 do
  begin
    Player.Account.Characters[Packet.SlotIndex].Base.Inventory[I].Index := 5300;
    Player.Account.Characters[Packet.SlotIndex].Base.Inventory[I].APP := 5300;
    Player.Account.Characters[Packet.SlotIndex].Base.Inventory[I].Refi := 1;
  end;

  for var I := 80 to 83 do
    Player.Account.Header.Storage.Itens[I].Index := 5310;

{$REGION 'Setando as balas que vao no slot inv[5,6] e equip[15]'}
  case ClasseChar of
    2:
      begin
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].
          Index := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].APP := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5].
          Index := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .APP := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6].
          Index := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .APP := 4615;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .Refi := 1000;
      end;
    3:
      begin
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].
          Index := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].APP := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Equip[15].Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5].
          Index := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .APP := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[5]
          .Refi := 1000;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6].
          Index := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .APP := 4600;
        Player.Account.Characters[Packet.SlotIndex].Base.Inventory[6]
          .Refi := 1000;
      end;
  end;
{$ENDREGION}
  Player.Account.Characters[Packet.SlotIndex].Base.CreationTime :=
    DateTimeToUnix(Now);
  Move(Packet.Name, Player.Account.Characters[Packet.SlotIndex]
    .Base.Name[0], 16);
  case Packet.Local of
    0:
      begin
        Player.Account.Characters[Packet.SlotIndex].LastPos.Create(3450, 690);
      end; // 0 = 3450 690
    1:
      begin // 1 = 3470 935
        Player.Account.Characters[Packet.SlotIndex].LastPos.Create(3470, 935);
      end;
  end;
  Logger.Write(string(Player.Account.Header.Username) +
    ' criou um novo personagem [' + String(Packet.Name) + '].',
    TLogType.ConnectionsTraffic);
  if not(Player.SaveCreatedChar(string(Packet.Name), Packet.SlotIndex)) then
  begin
    ZeroMemory(@Player.Account.Characters[Packet.SlotIndex],
      SizeOf(TCharacterDB));
    Player.SendCharList;
    Exit;
  end;

  // PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
  // AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
  // AnsiString(MYSQL_DATABASE));
  // if not(PlayerSQLComp.Query.Connection.Connected) then
  // begin
  // Logger.Write('Falha de conexão individual com mysql.[CreateCharacter]',
  // TlogType.Warnings);
  // Logger.Write('PERSONAL MYSQL FAILED LOAD.[CreateCharacter]', TlogType.Error);
  // PlayerSQLComp.Free;
  // Exit;
  // end;
  //
  // PlayerSQLComp.SetQuery('select coalesce(av.referrer, "") from account_validate av inner join '+
  // 'accounts a on a.mail=av.email WHERE a.id = ' +
  // Player.Account.Header.AccountId.ToString);
  // PlayerSQLComp.Run();
  //
  // if(PlayerSQLComp.Query.RecordCount > 0) then
  // begin
  // if(PlayerSQLComp.Query.Fields[0].asstring <> '') then
  // begin
  // TItemFunctions.PutItemOnEvent(Player, 4357, 500);
  // end;
  // end;

//  PlayerSQLComp.Free;

  Player.SendCharList;
end;

class function TPacketHandlers.RequestDeleteChar(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  RecvPacket: TDeleteCharacterRequestPacket absolute Buffer;
  FTime: TDateTime;
  TimeNow: TDateTime;
begin
  Result := false;
  if (RecvPacket.Delete = True) then
  begin
    if (AnsiCompareText(String(Player.Account.Characters[RecvPacket.SlotIndex]
      .Base.Numeric), String(RecvPacket.Numeric)) <> 0) then
    begin
      Player.SendCharList;
      Player.SendClientMessage('Número não correspondente!', 16);
      Exit;
    end;
    if (Player.Account.CharactersDelete[RecvPacket.SlotIndex] = True) then
    begin
      Player.Account.CharactersDelete[RecvPacket.SlotIndex] := false;
      Player.Account.CharactersDeleteTime[RecvPacket.SlotIndex] := '';
      Player.SaveCharOnCharRoom(RecvPacket.SlotIndex);
      Player.SendCharList;
      Player.SendClientMessage('Exclusão de personagem cancelada!', 16);
      Exit;
    end;
  end;
  if (Player.Account.Characters[RecvPacket.SlotIndex].Base.Name = '') then
  begin
    Player.SendCharList;
    Player.SendClientMessage('Parece que esse personagem não existe!', 16);
    Exit;
  end;
  if (Player.Account.Characters[RecvPacket.SlotIndex].Base.Numeric <> '') then
  begin
    if (String(RecvPacket.Numeric) <> String(Player.Account.Characters
      [RecvPacket.SlotIndex].Base.Numeric)) then
    begin
      Player.SendCharList;
      Player.SendClientMessage('Número não correspondente!', 16);
      Exit;
    end;
  end
  else
  begin
    Player.SendCharList;
    Player.SendClientMessage('Você não possui um número. Crie um.', 16);
    Exit;
  end;
  if (Player.Account.CharactersDelete[RecvPacket.SlotIndex] = false) then
  begin
    // Define o tempo de exclusão para 10 segundos a partir de agora
    FTime := Now + EncodeTime(0, 0, 2, 0);
    Player.Account.CharactersDelete[RecvPacket.SlotIndex] := True;
    Player.Account.CharactersDeleteTime[RecvPacket.SlotIndex] :=
      DateTimeToStr(FTime);
    Player.SaveCharOnCharRoom(RecvPacket.SlotIndex);
    Player.SendCharList;
    Result := True;
    Exit;
  end;
  // Verifica se o tempo de exclusão já passou
  FTime := StrToDateTime(String(Player.Account.CharactersDeleteTime
    [RecvPacket.SlotIndex]));
  TimeNow := Now;
  if (FTime < TimeNow) then
  begin
    Player.SendCharList;
    Player.SendClientMessage('Você pode deletar este personagem!', 16);
    Result := True;
  end
  else
  begin
    Player.SendCharList;
    Player.SendClientMessage
      ('Você ainda não pode excluir este personagem!', 16);
    Exit;
  end;
end;

class function TPacketHandlers.DeleteChar(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  RecvPacket: TDeleteChar absolute Buffer;
  Slot, I: BYTE;
  FTime: TDateTime;
  CharFileDir, MailsFileDir, FriendsFileDir, Name: string;
  Guild: PGuild;
begin

  Player.SendClientMessage
    ('Desativado até análise de risco de bugar sua conta.', 16);
  Exit(false);

  Slot := BYTE(RecvPacket.Slot);
  if (String(Player.Account.Characters[Slot].Base.Numeric) <> '') then
  begin
    if (String(RecvPacket.Numeric) <> String(Player.Account.Characters[Slot]
      .Base.Numeric)) then
    begin
      Player.SendCharList;
      Player.SendClientMessage('Numerica não correspondente!', 16);
      Exit;
    end;
  end;
  { FTime := StrToDateTime(String(Player.Account.CharactersDeleteTime[Slot]));
    if (CompareDateTime(Now, FTime) = -1) then
    begin
    Player.SendCharList;
    Player.SendClientMessage
    ('Você ainda não pode excluir este personagem!', 16);

    end; }
  if (Player.Account.CharactersDelete[Slot] = True) and
    (String(Player.Account.Characters[Slot].Base.Name) <> '') then
  begin
    if Player.Account.Characters[Slot].Base.GuildIndex > 0 then
    begin
      Guild := @Guilds[Player.Account.Characters[Slot].Base.GuildIndex];
      Guild.RemoveMember(Player.Account.Characters[Slot].Index, false);
      Player.Account.Characters[Slot].Base.GuildIndex := 0;
    end;
    Name := string(Player.Account.Characters[Slot].Base.Name);
    if (TFunctions.IsLetter(Name)) then
    begin
      CharFileDir := 'C:\Database\Chars\' + Trim(Name)[1] + '\' + Trim(Name)
        + '.char';
      MailsFileDir := 'C:\Database\Mails\' + Trim(Name)[1] + '\' + Trim(Name)
        + '.mail';
      FriendsFileDir := 'C:\Database\Friends\' + Trim(Name)[1] + '\' +
        Trim(Name) + '.friends'
    end
    else
    begin
      CharFileDir := 'C:\Database\Chars\etc\' + Trim(Name) + '.char';
      MailsFileDir := 'C:\Database\Mails\etc\' + Trim(Name) + '.mail';
      FriendsFileDir := 'C:\Database\Friends\etc\' + Trim(Name) + '.friends';
    end;
    DeleteFile(PWideChar(CharFileDir));
    DeleteFile(PWideChar(MailsFileDir));
    DeleteFile(PWideChar(FriendsFileDir));
    Player.DeleteCharacter(Slot);
    ZeroMemory(@Player.Account.Characters[Slot], SizeOf(TCharacterDB));
    Player.Account.Header.NumericToken[Slot] := '';
    Player.Account.Header.NumError[Slot] := 0;
    Player.Account.Header.PlayerDelete[Slot] := false;
    Player.SendCharList;
    Player.SendClientMessage('Personagem deletado com sucesso!', 16);
  end
  else
  begin
    Player.SendClientMessage('Você não pode deletar esse personagem!', 16);
    Player.SendCharList;
    Exit;
  end;
  ZeroMemory(@RecvPacket, SizeOf(RecvPacket));
  Result := True;
end;

{$ENDREGION}
{$REGION 'Character Status Functions [Move/PK/Rotation]'}

// alterado dia 03/08/2024
class function TPacketHandlers.MovementCommand(var Player: PPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TMovementPacket absolute Buffer;
  NewPranPosition: TPosition;
  UpdatedPosition: boolean;
begin
  Result := false;
  UpdatedPosition := false;
  if (Player^.Base.PlayerCharacter.LastPos = Packet.Destination) then
    Exit(True);
  if Packet.Header.Index <> Player^.Base.ClientID then
    Exit;


  if not Packet.Destination.IsValid or (Packet.MoveType <> MOVE_NORMAL) or
    (Player^.OpennedNPC > 0) or (Player^.OpennedOption > 0) then
    Exit;

  Player^.Base.SendToVisible(Packet, Packet.Header.Size, false);
  Player^.Base.PlayerCharacter.LastPos := Packet.Destination;


  if not Player^.Base.PlayerCharacter.LastPos.InRange(Player^.Character.LastPos, 3) then
  begin
    Player^.Character.LastPos := Packet.Destination;
    UpdatedPosition := True;
    Player^.OpennedNPC := 0;
    Player^.OpennedOption := 0;
  end;

  if UpdatedPosition then
  begin
    if Player^.Account.Header.Pran1.Iddb > 0 then
    begin
      if Player^.Account.Header.Pran1.IsSpawned then
      begin
        Randomize;
        NewPranPosition := Player^.Base.Neighbors[Random(7)].pos;
        if not NewPranPosition.InRange(Player^.Account.Header.Pran1.Position, 2) then
        begin
          Player^.Account.Header.Pran1.Position := NewPranPosition;
          ZeroMemory(@Packet, SizeOf(Packet));
          Packet.Header.Size := SizeOf(Packet);
          Packet.Header.Index := Player^.Base.PranClientID;
          Packet.Header.Code := $301;
          Packet.Destination := Player^.Account.Header.Pran1.Position;
          Packet.MoveType := MOVE_NORMAL;
          Packet.Speed := Player^.Base.PlayerCharacter.SpeedMove - 10;
          if not NewPranPosition.InRange(Player^.Base.PlayerCharacter.LastPos, 25) then
            Packet.Speed := Player^.Base.PlayerCharacter.SpeedMove + 10;
          Player^.Base.SendToVisible(Packet, Packet.Header.Size, True);
        end;
      end;
    end;
    if Player^.Account.Header.Pran2.Iddb > 0 then
    begin
      if Player^.Account.Header.Pran2.IsSpawned then
      begin
        Randomize;
        NewPranPosition := Player^.Base.Neighbors[Random(7)].pos;
        if not NewPranPosition.InRange(Player^.Account.Header.Pran2.Position, 2) then
        begin
          Player^.Account.Header.Pran2.Position := NewPranPosition;
          ZeroMemory(@Packet, SizeOf(Packet));
          Packet.Header.Size := SizeOf(Packet);
          Packet.Header.Index := Player^.Base.PranClientID;
          Packet.Header.Code := $301;
          Packet.Destination := Player^.Account.Header.Pran2.Position;
          Packet.MoveType := MOVE_NORMAL;
          Packet.Speed := Player^.Base.PlayerCharacter.SpeedMove - 10;
          if not NewPranPosition.InRange(Player^.Base.PlayerCharacter.LastPos, 25) then
            Packet.Speed := Player^.Base.PlayerCharacter.SpeedMove + 10;
          Player^.Base.SendToVisible(Packet, Packet.Header.Size, True);
        end;
      end;
    end;
  end;

  Player^.Base.LastMovedTime := Now;
  Player^.Base.CurrentAction := 0;

  Result := True;

end;

class function TPacketHandlers.PKMode(var Player: TPlayer): boolean;
var
  Packet: TSignalData;
  l: Integer;
begin
  // Verifica se o Player não tem o PvP ativado e está em um duelo
  if (not Player.Character.PlayerKill) and Player.Dueling then
  begin
    Player.SendClientMessage
      ('Você não pode ativar o PvP enquanto estiver em duelo.');
    Exit(false);
  end;

  ZeroMemory(@Packet, SizeOf(TSignalData));
  Packet.Header.Size := SizeOf(TSignalData);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $307;

  if Player.Character.PlayerKill then
  begin
    Packet.Data := 0;
    Player.Character.PlayerKill := false;
    Player.Base.PlayerCharacter.PlayerKill := false;
  end
  else
  begin
    Packet.Data := 1;
    Player.Character.PlayerKill := True;
    Player.Base.PlayerCharacter.PlayerKill := True;
  end;
  Player.Base.SendToVisible(Packet, SizeOf(TSignalData));
  Result := True;
end;

class function TPacketHandlers.UpdateRotation(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  if Player.Character.Rotation <> Packet.Data then
  begin
    Player.Character.Rotation := Packet.Data;
    Player.Base.SendToVisible(Packet, Packet.Header.Size, false);
    Exit(True);
  end;
  Result := false;
end;

class function TPacketHandlers.UpdateAction(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSendActionPacket absolute Buffer;
begin
  // Logger.Write(Packet.Data.ToString, TLogType.Packets);

  // 40, 65
  if (Packet.Index in [40, 65]) then
  begin
    Player.Base.CurrentAction := Packet.Index;
  end;

  if Packet.Index = $41 then
  begin
    Randomize; // Inicializa o gerador de números aleatórios
    case Random(11) of // Gera um número aleatório entre 0 e 5
      0:
        Packet.Index := $43; // PULOS
      1:
        Packet.Index := $44;
      2:
        Packet.Index := $45;  // Com luzes
      3:
        Packet.Index := $46;   // Ula - Ula
      4:
        Packet.Index := $4A;   // Garota Mágica
      5:
        Packet.Index := $4B;   // Alguma dança
      6:
        Packet.Index := $47;
      7:
        Packet.Index := $48;   // DAB REPETINDO
      8:
        Packet.Index := $49;   // DAB PARADO
      9:
        Packet.Index := $4C;   // MANDAR BEIJO
      10:
        Packet.Index := $4D;   // DANÇA NORMAL CLASSE
    end;
    Player.Base.CurrentAction := Packet.Index;
    Player.Base.SendEffectOther(Packet.Index, 1);
    Logger.Write('Dança [' + Packet.Index.ToString + ']', Warnings);
  end;

  Player.Base.SendToVisible(Packet, Packet.Header.Size, false);
end;

class function TPacketHandlers.ChangeGold(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TChangeChestGoldPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := false;

  try
    if (Packet.ChestType < 2) or (Packet.ChestType > 3) then
    begin
      WriteLn('ChestType fora do intervalo permitido: ', Packet.ChestType);
      Exit;
    end;

    if Packet.Value = 0 then
    begin
      WriteLn('Packet.Value é zero');
      Exit;
    end;

    case Packet.ChestType of
      STORAGE_TYPE:
        begin
          if Packet.Value < 0 then
          begin
            if (Player.Account.Header.Storage.Gold < Abs(Packet.Value)) or
              ((Player.Character.Base.Gold + Abs(Packet.Value)) > 2000000000)
            then
            begin
              WriteLn('Erro de Gold no Storage: saldo insuficiente ou limite excedido.');
              Exit;
            end;
          end
          else if (Player.Character.Base.Gold < Packet.Value) or
            ((Player.Account.Header.Storage.Gold + Packet.Value) > 2000000000)
          then
          begin
            WriteLn('Erro de Gold no Storage: saldo insuficiente ou limite excedido.');
            Exit;
          end;

          Player.Account.Header.Storage.Gold :=
            Player.Account.Header.Storage.Gold + Packet.Value;
          Player.Character.Base.Gold := Player.Character.Base.Gold -
            Packet.Value;
          Player.RefreshMoney;
          Player.Character.IsStorageSend := false;
          Player.SendStorage(STORAGE_TYPE_PLAYER);

          WriteLn('Transação no Storage concluída com sucesso.');
        end;

      GUILDCHEST_TYPE:
        begin
          if not(Player.OpennedOption = 11) or (Player.OpennedNPC <= 0) or
            (Player.Character.Base.GuildIndex <= 0) then
          begin
            WriteLn('Guild chest não aberto corretamente ou GuildIndex inválido.');
            Exit;
          end;

          Guild := @Guilds[Player.Character.GuildSlot];

          if (Guild.MemberInChest <> Guild.FindMemberFromCharIndex
            (Player.Character.Index)) or not Guild.GetRankConfig
            (Guild.Members[Guild.FindMemberFromCharIndex(Player.Character.Index)
            ].Rank).UseGWH then
          begin
            WriteLn('Acesso ao Guild Chest negado.');
            Exit;
          end;

          Guild.LastChestActionDate := Now;

          if Packet.Value < 0 then
          begin
            if (Guild.Chest.Gold < Abs(Packet.Value)) or
              ((Player.Character.Base.Gold + Abs(Packet.Value)) > 2000000000)
            then
            begin
              WriteLn('Erro de Gold no Guild Chest: saldo insuficiente ou limite excedido.');
              Exit;
            end;
          end
          else if Player.Character.Base.Gold < Packet.Value then
          begin
            WriteLn('Gold insuficiente no personagem para transferir ao Guild Chest.');
            Exit;
          end;

          Guild.Chest.Gold := Guild.Chest.Gold + UInt64(Packet.Value);
          Player.Character.Base.Gold := Player.Character.Base.Gold -
            Packet.Value;
          Player.RefreshMoney;
          Player.RefreshGuildChestGold;

          WriteLn('Transação no Guild Chest concluída com sucesso.');
        end;
    end;
  except
    on E: Exception do
    begin
      WriteLn('Erro no processamento do ChestType: ', E.Message);
      Exit;
    end;
  end;

  Result := false;
end;

{$ENDREGION}
{$REGION 'Chat Functions'}
// class function TPacketHandlers.teste(var Player: TPlayer): boolean;
// var
// Buff: array[0..8091] of Byte; // Pacote com tamanho máximo de 8092 bytes
// Len: Integer;
// i, j: Integer;
// begin
// ZeroMemory(@Buff, SizeOf(Buff));
//
// // Valores fixos no buffer
// Buff[0] := $A8; Buff[1] := $00; Buff[2] := $00;
// Buff[3] := $76; Buff[4] := $35; Buff[5] := $75;
// Buff[6] := $99; Buff[7] := $01; Buff[8] := $00; Buff[9] := $00;
// Buff[10] := $00; Buff[11] := $00; Buff[12] := $01; Buff[13] := $00;
// Buff[14] := $00; Buff[15] := $00; Buff[16] := $20; Buff[17] := $00; Buff[18] := $00; Buff[19] := $00;
//
// Len := 168; // Tamanho do pacote
//
// // Inicializando os valores de Buff[20] a Buff[168] com um valor padrão (por exemplo, 0x00)
// for j := 20 to 168 do
// Buff[j] := $00;
//
// // Loop para testar os bytes de Buff[8] até Buff[15] e depois Buff[15] até Buff[8]
// for i := 8 to 11 do
// begin
// // Testando o valor 0x00 para Buff[i]
// Buff[i] := $00;
// Player.SendPacket(Buff, Len);
// Writeln(Format('8 a 15 Pacote enviado com Buff[%d] = %x', [i, Buff[i]]));
// sleep(5);
//
// // Testando valores de Buff[20] a Buff[60] para 0x00, 0x01
// for j := 20 to 60 do
// begin
// Buff[j] := $00;
// Player.SendPacket(Buff, Len);
// Writeln(Format('8 a 15 Pacote enviado com Buff[%d] = %x', [j, Buff[j]]));
// sleep(5);
//
// Buff[j] := $01;
// if (j + 3 <= 60) then
// begin
// Buff[j + 1] := $10;
// Buff[j + 2] := $10;
// Buff[j + 3] := $10;
// end;
// Player.SendPacket(Buff, Len);
// Writeln(Format('8 a 15 Pacote enviado com Buff[%d..%d] = %x %x %x %x', [j, j + 3, Buff[j], Buff[j + 1], Buff[j + 2], Buff[j + 3]]));
// sleep(5);
//
// // Revertendo os próximos 3 bytes
// if (j + 3 <= 60) then
// begin
// Buff[j + 1] := $00;
// Buff[j + 2] := $00;
// Buff[j + 3] := $00;
// end;
// end;
// end;
//
// // Loop para testar os bytes de Buff[15] até Buff[8] (retrocedendo)
// for i := 11 downto 8 do
// begin
// // Testando o valor 0x00 para Buff[i]
// Buff[i] := $00;
// Player.SendPacket(Buff, Len);
// Writeln(Format('15 a 8 Pacote enviado com Buff[%d] = %x', [i, Buff[i]]));
// sleep(5);
//
// // Testando valores de Buff[20] a Buff[60] para 0x00, 0x01
// for j := 20 to 60 do
// begin
// Buff[j] := $00;
// Player.SendPacket(Buff, Len);
// Writeln(Format('15 a 8 Pacote enviado com Buff[%d] = %x', [j, Buff[j]]));
// sleep(5);
//
// Buff[j] := $01;
// if (j + 3 <= 60) then
// begin
// Buff[j + 1] := $10;
// Buff[j + 2] := $10;
// Buff[j + 3] := $10;
// end;
// Player.SendPacket(Buff, Len);
// Writeln(Format('15 a 8 Pacote enviado com Buff[%d..%d] = %x %x %x %x', [j, j + 3, Buff[j], Buff[j + 1], Buff[j + 2], Buff[j + 3]]));
// sleep(5);
//
// // Revertendo os próximos 3 bytes
// if (j + 3 <= 60) then
// begin
// Buff[j + 1] := $00;
// Buff[j + 2] := $00;
// Buff[j + 3] := $00;
// end;
// end;
// end;
//
// end;


// class function TPacketHandlers.teste(var Player: TPlayer): boolean;
// var
// Buff: array[0..8091] of Byte; // Pacote com tamanho máximo de 8092 bytes
// Len: Integer;
// i, j: Integer;
// begin
// ZeroMemory(@Buff, SizeOf(Buff));
//
//
// // Valores fixos no buffer
// Buff[0] := $A8; Buff[1] := $00; Buff[2] := $00;
// Buff[3] := $76; Buff[4] := $35; Buff[5] := $75;
// Buff[6] := $5F; Buff[7] := $00; Buff[8] := $00; Buff[9] := $00;
// Buff[10] := $00; Buff[11] := $00; Buff[12] := $01; Buff[13] := $00;
// Buff[14] := $00; Buff[15] := $00; Buff[16] := $00; Buff[17] := $00; Buff[18] := $00; Buff[19] := $00;
//
// Len := 168; // Tamanho do pacote
//
// // Inicializando os valores de Buff[20] a Buff[168] com um valor padrão (por exemplo, 0x00)
// for i := 20 to 168 do
// Buff[i] := $00;
//
//
// //Pacote enviado com Buff[6] = 1, Buff[7] = 10
//
// //ENTRE AF E AA TEM AS COISAS DA ELTER
// // AB PRA PEGAR A PONTUACAO DO PLACAR DE BAIXO
// // Loop para testar todas as combinações de Buff[6] e Buff[7] de 0x00 a 0xFF
// for i := $AB downto 0 do
// begin
// for j := $FF downto 0 do
// begin
//
// if Player.Status <> Playing then
// begin
// Writeln('Jogador desconectado. Interrompendo o teste.');
// Exit; // Ou 'Break' se você deseja sair do loop mais interno
// end;
//
// Buff[6] := i;  // Testando todos os valores de 0x00 a 0xFF para Buff[6]
// Buff[7] := j;  // Testando todos os valores de 0x00 a 0xFF para Buff[7]
//
// if (Buff[6] <= 1) and (j < 10) then
// continue;
// if (Buff[6] = 4) and (j > 200) then
// continue;
// if (Buff[6] = 5) and (j < 30) then
// continue;
// if (Buff[6] = 36) and (j < 250) then
// continue;
// if (Buff[6] = 80) and (j < 100) then
// continue;
// if (Buff[6] = 92) and (j > 100) then
// continue;
// if (Buff[6] = 98) and (j > 100) then
// continue;
// if (Buff[6] = 99) and ((j > 0) and (j < 5)) then
// continue;
// if (Buff[6] = 163) and ((j > 0) and (j < 5)) then
// continue;
// if (Buff[6] = 164) and ((j > 0) and (j < 5)) then
// continue;
// if (Buff[6] = 165) and ((j > 0) and (j < 5)) then
// continue;
//
// Player.SendPacket(Buff, Len);
// Writeln(Format('Pacote enviado com Buff[6] = %x, Buff[7] = %x', [Buff[6], Buff[7]]));
// Player.SendClientMessage(Buff[6].ToString + ' ' + Buff[7].ToString);
// Player.SendClientMessage(Format('Pacote enviado com Buff[6] = %x, Buff[7] = %x', [Buff[6], Buff[7]]));
// sleep(50); // Intervalo entre os pacotes
// end;
// end;
//
// end;

class function TPacketHandlers.teste(var Player: TPlayer): boolean;
var
  Packet: TElterPontuacao;
  Len: Integer;
  I, j, k, l: Integer;
begin


  // Player.Base.SendEffectOther($45,1);
  //

  // var packets: TElterFecharPlacar;

  // packets.Header.Size:= sizeof(TElterFecharPlacar);
  // packets.Header.Code:= $199;
  //
  // packets.TempoRestante := 60;
  // packets.Status:= 4;
  // Player.SendPacket(packets, sizeof(TElterFecharPlacar));

  var
    Packets: TElterFecharPlacar;

  Packets.Header.Size := SizeOf(TElterFecharPlacar);
  Packets.Header.Code := $310;

  Packets.TempoRestante := 33;
  // packets.Status:= 4;
  Player.SendPacket(Packets, SizeOf(TElterFecharPlacar));

  // entre 1000 a 900 tem algo sobre skills de montaria ou skills transmutada
  Packet.Header.Size := SizeOf(TElterPontuacao);
  Packet.TeamRed := 5;
  Packet.TeamBlue := 6;

  /// /for i:= 450 downto 425 do
  // for i:= 300 downto 0 do
  // begin
  // if (i = 426) or (i = 421) or (i = 422) or (i = 418) then
  // continue;
  // if (i <= 425) and (i >= 418) then
  // continue;
  // if i = 335 then
  // continue;
  //
  //
  // if Player.SocketClosed or Player.xdisconnected or Player.Unlogging then
  // continue;
  //
  // packet.Header.Index:= Player.Base.ClientID;
  // Packet.Header.Code:= i;
  // Player.SendPacket(packet, sizeof(TElterPontuacao));
  // Player.SendClientMessage('pacote enviado int: ' + i.ToString);
  // Player.SendClientMessage('pacote enviado hex: ' + i.ToHexString);
  //
  // WriteLN('pacote enviado int: ' + i.ToString);
  // WriteLN('pacote enviado hex: ' + i.ToHexString);
  // sleep(250);
  // end;

  for I := 950 to 1050 do
  begin
    if (I = 426) or (I = 421) or (I = 422) or (I = 418) then
      continue;
    if (I <= 425) and (I >= 418) then
      continue;
    if I = 335 then
      continue;

    if Player.SocketClosed or Player.xdisconnected or Player.Unlogging then
      continue;

    Packet.Header.Index := Player.Base.ClientID;
    Packet.Header.Code := I;
    Player.SendPacket(Packet, SizeOf(TElterPontuacao));
    Player.SendClientMessage('pacote enviado int: ' + I.ToString);
    Player.SendClientMessage('pacote enviado hex: ' + I.ToHexString);

    WriteLn('pacote enviado int: ' + I.ToString);
    WriteLn('pacote enviado hex: ' + I.ToHexString);
    sleep(500);
  end;



  // for I := Low(Player.Base.VisibleTargets) to High(Player.Base.VisibleTargets) do
  // begin
  // writeln('ClientID: ', Player.Base.VisibleTargets[I].ClientID);
  // end;


  //
  // Packet.Header.Size := sizeof(Packet);
  // Packet.Header.Index:= Player.Base.ClientID;
  // Packet.Header.Code:= $304;
  // Packet.InLoop:= 0;
  //
  // for i := 205 to $ffff do
  // begin
  // Packet.Index:= i;
  // Player.SendPacket(Packet, sizeof(Packet));
  // Player.SendClientMessage('packet id: ' + i.ToString);
  // sleep(5);
  //
  // end;

  // Result := False; // Valor inicial para a função
  // ZeroMemory(@Packet, SizeOf(Packet));
  //
  // Packet.Header.Size := Sizeof(Packet);
  // Packet.Header.Index:= Player.Base.ClientID;
  //
  // for j := $103 downto 0 do
  // begin
  // if j = $19E  then
  // Continue;
  //
  // Packet.Header.Code := j;
  // Packet.Valor1:= 05;
  // Packet.Valor2:= 08;
  // Packet.Valor3:= 10;
  //
  // Player.SendPacket(Packet, SizeOf(Packet));
  // Writeln(Format('Pacote enviado com Buff = %x', [j]));
  // Player.SendClientMessage(Format('Pacote enviado com Buff = %x', [j]));

  // Sleep(1000); // Intervalo entre pacotes
  // end;

  Result := True; // Indica que a função foi executada com sucesso

  //

  // for i := $f0 to $ff do
  // begin
  // Buff[7] := i;
  //
  // for j := 0 to $FF do
  // begin
  // if (i= $9) and (j < $65) then
  // Continue;
  // if (i= $E)then
  // Continue;
  // if (i= $f) and (j > 0) and (j < 6) then
  // Continue;
  //
  // // if (j >= $10) and (j <= $17) then
  // //    Continue;
  // //     if (j <= $5f) and (j <= $17) then
  // //    Continue;
  // //    if (j >= $61) and (j <= $67) then
  // //    Continue;
  // //    if (j >= $a0) and (j <= $a4) then
  // //    Continue;
  // //        if (j >= $8e) and (j <= $b0) then
  // //    Continue;
  //
  //
  // // Configurar Buff[6] e Buff[7]
  // Buff[6] := j;       // Mantém os 8 bits menos significativos
  //
  //
  // // Enviar o pacote
  // Player.SendPacket(Buff, Len);
  // Writeln(Format('Pacote enviado com Buff = %x %x', [i, j]));
  // Player.SendClientMessage(Format('Pacote enviado com Buff = %x %x', [i, j]));
  //
  // Sleep(2); // Intervalo entre pacotes
  // end;
  // end;
  //
  /// /
  // for i := $Ac to $ff do
  // begin
  // Buff[7] := i;
  //
  // for j := 0 to $FF do
  // begin
  // if (i= $9) and (j < $65) then
  // Continue;
  // if (i= $E)then
  // Continue;
  // if (i= $f) and (j > 0) and (j < 6) then
  // Continue;
  //
  // // if (j >= $10) and (j <= $17) then
  // //    Continue;
  // //     if (j <= $5f) and (j <= $17) then
  // //    Continue;
  // //    if (j >= $61) and (j <= $67) then
  // //    Continue;
  // //    if (j >= $a0) and (j <= $a4) then
  // //    Continue;
  // //        if (j >= $8e) and (j <= $b0) then
  // //    Continue;
  //
  //
  // // Configurar Buff[6] e Buff[7]
  // Buff[6] := j;       // Mantém os 8 bits menos significativos
  //
  //
  // // Enviar o pacote
  // Player.SendPacket(Buff, Len);
  // Writeln(Format('Pacote enviado com Buff = %x %x', [i, j]));
  // Player.SendClientMessage(Format('Pacote enviado com Buff = %x %x', [i, j]));
  //
  // Sleep(2); // Intervalo entre pacotes
  // end;
  // end;
  //

end;

procedure DebugPacketWithHex(var Buffer: array of BYTE);
var
  I: Integer;

begin

end;

class function TPacketHandlers.SendClientSay(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TChatPacket absolute Buffer;
  OtherPlayer: PPlayer;
  ItemSlot: BYTE;
  PingString, strAux: String;
  PingInt, I, j: Integer;
  HexDump: String;
  PacketBytes: TBytes absolute Buffer; // Mapear Buffer como array de bytes
begin

  strAux := '';
  Result := false;
  // Packet.TypeChat:= 9;
  case Packet.TypeChat of
    CHAT_TYPE_NORMAL:
      begin
        if (String(Packet.Fala) = '.novos %') then
        begin
          Player.Base.Character.Nation := 3;
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.kills') then
        begin
          var
            SQLComp: TQuery;
          var
            PlayerSQLComp: TQuery;
          var
            Len1, Len2, TotalVermelho, TotalAzul, KillsTeamRed,
              KillsTeamBlue: Integer;
          PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
            AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
            AnsiString(MYSQL_DATABASE));

          SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
            AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
            AnsiString(MYSQL_DATABASE), True);

          TotalVermelho := 0;
          TotalAzul := 0;
          KillsTeamRed := 0;
          KillsTeamBlue := 0;

          var
            Buff: array [0 .. 8091] of BYTE;
            // Pacote com tamanho máximo de 8092 bytes
          var
            Buff1: array [0 .. 8091] of BYTE;
            // Pacote com tamanho máximo de 8092 bytes
          var
            Len: Integer;
          var
            k: Integer;
          ZeroMemory(@Buff, SizeOf(Buff));
          ZeroMemory(@Buff1, SizeOf(Buff1));

          Buff[0] := $A8;
          Buff[1] := $00;
          Buff[2] := $00;
          Buff[3] := $76;
          Buff[4] := $35;
          Buff[5] := $75;
          Buff[6] := $AB;
          Buff[7] := $01;
          Buff[8] := $00;
          Buff[9] := $00;
          Buff[10] := $00;
          Buff[11] := $00;
          Buff[12] := $00;
          Buff[13] := $00;
          Buff[14] := $00;
          Buff[15] := $00;
          Buff[16] := $00;
          Buff[17] := $00;
          Buff[18] := $00;
          Buff[19] := $00;

          // Inicializa os dados básicos do pacote para Kills (Buff2)
          Buff1[0] := $A8; // Início do pacote
          Buff1[1] := $00;
          Buff1[2] := $00;
          Buff1[3] := $00; // Reservado (0)
          Buff1[4] := $00; // Reservado (0)
          Buff1[5] := $00; // Reservado (0)
          Buff1[6] := $AC; // Identificador do pacote
          Buff1[7] := $01; // Indicador do tipo de pacote
          Buff1[8] := $00;
          Buff1[9] := $00;
          Buff1[10] := $00;
          Buff1[11] := $00; // Reservado (0)

          Buff1[12] := $00; // Kills do time vermelho (1 byte)
          Buff1[13] := $00; // Reservado (0)
          Buff1[14] := $00; // Reservado (0)
          Buff1[15] := $00; // Reservado (0)

          Buff1[16] := $00; // Kills do time azul (1 byte)
          Buff1[17] := $00; // Reservado (0)
          Buff1[18] := $00; // Reservado (0)
          Buff1[19] := $00; // Reservado (0)
          Len := 168; // Tamanho do pacote

          // Inicializando os valores de Buff[20] a Buff[168] com um valor padrão (por exemplo, 0x00)

          for I := 20 to 168 do
            Buff[I] := $00;
          for I := 20 to 168 do
            Buff1[I] := $00;

          try
            // Contagem de jogadores do time vermelho (nation = 5)
            PlayerSQLComp.SetQuery
              ('SELECT COUNT(id) AS TotalPlayers FROM elter WHERE nation = 5');
            PlayerSQLComp.Run;
            TotalVermelho := PlayerSQLComp.Query.Fields[0].AsInteger;

            // Contagem de jogadores do time azul (nation = 4)
            PlayerSQLComp.SetQuery
              ('SELECT COUNT(id) AS TotalPlayers FROM elter WHERE nation = 4');
            PlayerSQLComp.Run;
            TotalAzul := PlayerSQLComp.Query.Fields[0].AsInteger;

            // Contagem de kills do time vermelho (kills_vermelho)
            PlayerSQLComp.SetQuery
              ('SELECT SUM(kills_vermelho) AS TotalKills FROM elter_vars');
            PlayerSQLComp.Run;
            KillsTeamRed := PlayerSQLComp.Query.Fields[0].AsInteger;

            // Contagem de kills do time azul (kills_azul)
            PlayerSQLComp.SetQuery
              ('SELECT SUM(kills_azul) AS TotalKills FROM elter_vars');
            PlayerSQLComp.Run;
            KillsTeamBlue := PlayerSQLComp.Query.Fields[0].AsInteger;

          except
            on E: Exception do
            begin
              Logger.Write('Erro ao contar jogadores e kills nas tabelas: ' +
                E.Message, TLogType.Error);
              TotalVermelho := 0;
              TotalAzul := 0;
              KillsTeamRed := 0;
              KillsTeamBlue := 0;
            end;
          end;

          // Atualiza o buffer de jogadores - Buff1
          // Para o time vermelho (Buff1[12] a Buff1[15]) - Players
          if TotalVermelho > 255 then
          begin
            Buff[12] := (TotalVermelho shr 24) and $FF;
            // Byte mais significativo
            Buff[13] := (TotalVermelho shr 16) and $FF;
            Buff[14] := (TotalVermelho shr 8) and $FF;
            Buff[15] := TotalVermelho and $FF; // Byte menos significativo
          end
          else
          begin
            Buff[12] := TotalVermelho and $FF;
            // Representação compacta em 1 byte
            Buff[13] := 0;
            Buff[14] := 0;
            Buff[15] := 0;
          end;

          // Para o time azul (Buff1[16] a Buff1[19]) - Players
          if TotalAzul > 255 then
          begin
            Buff[16] := (TotalAzul shr 24) and $FF; // Byte mais significativo
            Buff[17] := (TotalAzul shr 16) and $FF;
            Buff[18] := (TotalAzul shr 8) and $FF;
            Buff[19] := TotalAzul and $FF; // Byte menos significativo
          end
          else
          begin
            Buff[16] := TotalAzul and $FF; // Representação compacta em 1 byte
            Buff[17] := 0;
            Buff[18] := 0;
            Buff[19] := 0;
          end;

          // Atualiza o buffer de kills - Buff2
          // Para o time vermelho (Buff2[12] a Buff2[15]) - Kills
          if KillsTeamRed > 255 then
          begin
            Buff1[12] := (KillsTeamRed shr 24) and $FF;
            // Byte mais significativo
            Buff1[13] := (KillsTeamRed shr 16) and $FF;
            Buff1[14] := (KillsTeamRed shr 8) and $FF;
            Buff1[15] := KillsTeamRed and $FF; // Byte menos significativo
          end
          else
          begin
            Buff1[12] := KillsTeamRed and $FF;
            // Representação compacta em 1 byte
            Buff1[13] := 0;
            Buff1[14] := 0;
            Buff1[15] := 0;
          end;

          // Para o time azul (Buff2[16] a Buff2[19]) - Kills
          if KillsTeamBlue > 255 then
          begin
            Buff1[16] := (KillsTeamBlue shr 24) and $FF;
            // Byte mais significativo
            Buff1[17] := (KillsTeamBlue shr 16) and $FF;
            Buff1[18] := (KillsTeamBlue shr 8) and $FF;
            Buff1[19] := KillsTeamBlue and $FF; // Byte menos significativo
          end
          else
          begin
            Buff1[16] := KillsTeamBlue and $FF;
            // Representação compacta em 1 byte
            Buff1[17] := 0;
            Buff1[18] := 0;
            Buff1[19] := 0;
          end;

          // Define os comprimentos dos pacotes
          Len1 := 168; // Comprimento do pacote de players
          Len2 := 168; // Comprimento do pacote de kills

          Player.SendPacket(Buff, Len);
          Player.SendPacket(Buff1, Len);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.elter') then
        begin
          var
            Buffer1: array of BYTE;
          SetLength(Buffer1, SizeOf(TChangeChannelPacket));
          // Tamanho total do pacote

          // Preenchendo o cabeçalho do pacote (TPacketHeader)
          PPacket_F05(@Buffer1[0])^.Header.Size := SizeOf(TChangeChannelPacket);
          // Tamanho total do pacote
          PPacket_F05(@Buffer1[0])^.Header.Key := 0;
          // Chave, pode ser ajustada conforme necessário
          PPacket_F05(@Buffer1[0])^.Header.ChkSum := 0;
          // Checksum, pode ser calculado
          PPacket_F05(@Buffer1[0])^.Header.Index := Player.Base.ClientID;
          // ID do cliente
          PPacket_F05(@Buffer1[0])^.Header.Code := $F05;
          // Código do pacote (0xF05)
          PPacket_F05(@Buffer1[0])^.Header.Time := 0; // Timestamp atual
          // PPacket_F05(@Buffer1[0])^.Header.Time := GetTickCount; // Timestamp atual

          // Preenchendo os dados do pacote com o canal desejado (0 no caso)
          PPacket_F05(@Buffer1[0])^.Info1 := 3; // Canal 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Tipo de canal 0 (igual a Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1, 50) then
          begin
            WriteLn('Jogador teleportado para o canal Leopold = ID 3 Canal com sucesso.');
          end;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.canal0') then
        begin
          var
            Buffer1: array of BYTE;
          SetLength(Buffer1, SizeOf(TChangeChannelPacket));
          // Tamanho total do pacote

          // Preenchendo o cabeçalho do pacote (TPacketHeader)
          PPacket_F05(@Buffer1[0])^.Header.Size := SizeOf(TChangeChannelPacket);
          // Tamanho total do pacote
          PPacket_F05(@Buffer1[0])^.Header.Key := 0;
          // Chave, pode ser ajustada conforme necessário
          PPacket_F05(@Buffer1[0])^.Header.ChkSum := 0;
          // Checksum, pode ser calculado
          PPacket_F05(@Buffer1[0])^.Header.Index := Player.Base.ClientID;
          // ID do cliente
          PPacket_F05(@Buffer1[0])^.Header.Code := $F05;
          // Código do pacote (0xF05)
          PPacket_F05(@Buffer1[0])^.Header.Time := 0; // Timestamp atual
          // PPacket_F05(@Buffer1[0])^.Header.Time := GetTickCount; // Timestamp atual

          // Preenchendo os dados do pacote com o canal desejado (0 no caso)
          PPacket_F05(@Buffer1[0])^.Info1 := 0; // Canal 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Tipo de canal 0 (igual a Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1) then
          begin
            WriteLn('Jogador teleportado para o canal Leopold = ID 3 Canal com sucesso.');
          end;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.canal1') then
        begin
          var
            Buffer1: array of BYTE;
          SetLength(Buffer1, SizeOf(TChangeChannelPacket));
          // Tamanho total do pacote

          // Preenchendo o cabeçalho do pacote (TPacketHeader)
          PPacket_F05(@Buffer1[0])^.Header.Size := SizeOf(TChangeChannelPacket);
          // Tamanho total do pacote
          PPacket_F05(@Buffer1[0])^.Header.Key := 0;
          // Chave, pode ser ajustada conforme necessário
          PPacket_F05(@Buffer1[0])^.Header.ChkSum := 0;
          // Checksum, pode ser calculado
          PPacket_F05(@Buffer1[0])^.Header.Index := Player.Base.ClientID;
          // ID do cliente
          PPacket_F05(@Buffer1[0])^.Header.Code := $F05;
          // Código do pacote (0xF05)
          PPacket_F05(@Buffer1[0])^.Header.Time := 123; // Timestamp atual
          // PPacket_F05(@Buffer1[0])^.Header.Time := GetTickCount; // Timestamp atual

          // Preenchendo os dados do pacote com o canal desejado (0 no caso)
          PPacket_F05(@Buffer1[0])^.Info1 := 1; // Canal 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Tipo de canal 0 (igual a Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1) then
          begin
            WriteLn('Jogador teleportado para o canal Leopold = ID 3 Canal com sucesso.');
          end;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.canal2') then
        begin
          var
            Buffer1: array of BYTE;
          SetLength(Buffer1, SizeOf(TChangeChannelPacket));
          // Tamanho total do pacote

          // Preenchendo o cabeçalho do pacote (TPacketHeader)
          PPacket_F05(@Buffer1[0])^.Header.Size := SizeOf(TChangeChannelPacket);
          // Tamanho total do pacote
          PPacket_F05(@Buffer1[0])^.Header.Key := 0;
          // Chave, pode ser ajustada conforme necessário
          PPacket_F05(@Buffer1[0])^.Header.ChkSum := 0;
          // Checksum, pode ser calculado
          PPacket_F05(@Buffer1[0])^.Header.Index := Player.Base.ClientID;
          // ID do cliente
          PPacket_F05(@Buffer1[0])^.Header.Code := $F05;
          // Código do pacote (0xF05)
          PPacket_F05(@Buffer1[0])^.Header.Time := 0; // Timestamp atual
          // PPacket_F05(@Buffer1[0])^.Header.Time := GetTickCount; // Timestamp atual

          // Preenchendo os dados do pacote com o canal desejado (0 no caso)
          PPacket_F05(@Buffer1[0])^.Info1 := 2; // Canal 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Tipo de canal 0 (igual a Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1) then
          begin
            WriteLn('Jogador teleportado para o canal Leopold = ID 3 Canal com sucesso.');
          end;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.canal3') then
        begin
          var
            Buffer1: array of BYTE;
          SetLength(Buffer1, SizeOf(TChangeChannelPacket));
          // Tamanho total do pacote

          // Preenchendo o cabeçalho do pacote (TPacketHeader)
          PPacket_F05(@Buffer1[0])^.Header.Size := SizeOf(TChangeChannelPacket);
          // Tamanho total do pacote
          PPacket_F05(@Buffer1[0])^.Header.Key := 0;
          // Chave, pode ser ajustada conforme necessário
          PPacket_F05(@Buffer1[0])^.Header.ChkSum := 0;
          // Checksum, pode ser calculado
          PPacket_F05(@Buffer1[0])^.Header.Index := Player.Base.ClientID;
          // ID do cliente
          PPacket_F05(@Buffer1[0])^.Header.Code := $F05;
          // Código do pacote (0xF05)
          PPacket_F05(@Buffer1[0])^.Header.Time := 0; // Timestamp atual
          // PPacket_F05(@Buffer1[0])^.Header.Time := GetTickCount; // Timestamp atual

          // Preenchendo os dados do pacote com o canal desejado (0 no caso)
          PPacket_F05(@Buffer1[0])^.Info1 := 1; // Canal 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Tipo de canal 0 (igual a Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1, 100) then
          begin
            WriteLn('Jogador teleportado para o canal Leopold = ID 3 Canal com sucesso.');
          end;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.tiamat') then
        begin
          Player.Teleport(TPosition.Create(2945, 1663));
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.deviramk') then
        begin
          Player.Teleport(TPosition.Create(3661, 1977));
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.devirsig') then
        begin
          Player.Teleport(TPosition.Create(2745, 2029));
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.devircahill') then
        begin
          Player.Teleport(TPosition.Create(3452, 833));
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.pacotes') then
        begin
          var
            Len: Integer;
          var
            Buff: array [0 .. 8091] of BYTE;
          ZeroMemory(@Buff, SizeOf(Buff));
          ZeroMemory(@Buff, 8092);
          // Preencher o Buff com a sequência de bytes
          Buff[0] := $A8;
          Buff[1] := $00;
          Buff[2] := $08;
          Buff[3] := $88;
          Buff[4] := $01;
          Buff[5] := $00;
          Buff[6] := $86;
          Buff[7] := $0F;
          Buff[8] := $E1;
          Buff[9] := $32;
          Buff[10] := $BB;
          Buff[11] := $25;
          Buff[12] := $01;
          Buff[13] := $00;
          Buff[14] := $00;
          Buff[15] := $00;
          Buff[16] := $00;
          Buff[17] := $00;
          Buff[18] := $00;
          Buff[19] := $FF;
          Buff[20] := $99;
          Buff[21] := $FF;
          Buff[22] := $FF;
          Buff[23] := $5B;
          Buff[24] := $53;
          Buff[25] := $45;
          Buff[26] := $52;
          Buff[27] := $56;
          Buff[28] := $45;
          Buff[29] := $52;
          Buff[30] := $5D;
          Buff[31] := $00;
          Buff[32] := $00;
          Buff[33] := $00;
          Buff[34] := $00;
          Buff[35] := $00;
          Buff[36] := $00;
          Buff[37] := $00;
          Buff[38] := $42;
          Buff[39] := $65;
          Buff[40] := $6D;
          Buff[41] := $2D;
          Buff[42] := $76;
          Buff[43] := $69;
          Buff[44] := $6E;
          Buff[45] := $64;
          Buff[46] := $6F;
          Buff[47] := $20;
          Buff[48] := $61;
          Buff[49] := $6F;
          Buff[50] := $20;
          Buff[51] := $73;
          Buff[52] := $65;
          Buff[53] := $72;
          Buff[54] := $76;
          Buff[55] := $69;
          Buff[56] := $64;
          Buff[57] := $6F;
          Buff[58] := $72;
          Buff[59] := $2C;
          Buff[60] := $20;
          Buff[61] := $61;
          Buff[62] := $6A;
          Buff[63] := $75;
          Buff[64] := $64;
          Buff[65] := $65;
          Buff[66] := $20;
          Buff[67] := $64;
          Buff[68] := $6F;
          Buff[69] := $61;
          Buff[70] := $6E;
          Buff[71] := $64;
          Buff[72] := $6F;
          Buff[73] := $20;
          Buff[74] := $65;
          Buff[75] := $6D;
          Buff[76] := $20;
          Buff[77] := $6E;
          Buff[78] := $6F;
          Buff[79] := $73;
          Buff[80] := $73;
          Buff[81] := $6F;
          Buff[82] := $20;
          Buff[83] := $73;
          Buff[84] := $69;
          Buff[85] := $74;
          Buff[86] := $65;
          Buff[87] := $21;
          Buff[88] := $00;
          Buff[89] := $00;
          Buff[90] := $00;
          Buff[91] := $00;
          Buff[92] := $00;
          Buff[93] := $00;
          Buff[94] := $00;
          Buff[95] := $00;
          Buff[96] := $00;
          Buff[97] := $00;
          Buff[98] := $00;
          Buff[99] := $00;
          Buff[100] := $00;
          Buff[101] := $00;
          Buff[102] := $00;
          Buff[103] := $00;
          Buff[104] := $00;
          Buff[105] := $00;
          Buff[106] := $00;
          Buff[107] := $00;
          Buff[108] := $00;
          Buff[109] := $00;
          Buff[110] := $00;
          Buff[111] := $00;
          Buff[112] := $00;
          Buff[113] := $00;
          Buff[114] := $00;
          Buff[115] := $00;
          Buff[116] := $00;
          Buff[117] := $00;
          Buff[118] := $00;
          Buff[119] := $00;
          Buff[120] := $00;
          Buff[121] := $00;
          Buff[122] := $00;
          Buff[123] := $00;
          Buff[124] := $00;
          Buff[125] := $00;
          Buff[126] := $00;
          Buff[127] := $00;
          Buff[128] := $00;
          Buff[129] := $00;
          Buff[130] := $00;
          Buff[131] := $00;
          Buff[132] := $00;
          Buff[133] := $00;
          Buff[134] := $00;
          Buff[135] := $00;
          Buff[136] := $00;
          Buff[137] := $00;
          Buff[138] := $00;
          Buff[139] := $00;
          Buff[140] := $00;
          Buff[141] := $00;
          Buff[142] := $00;
          Buff[143] := $00;
          Buff[144] := $00;
          Buff[145] := $00;
          Buff[146] := $00;
          Buff[147] := $00;
          Buff[148] := $00;
          Buff[149] := $00;
          Buff[150] := $00;
          Buff[151] := $00;
          Buff[152] := $00;
          Buff[153] := $00;
          Buff[154] := $00;
          Buff[155] := $00;
          Buff[156] := $00;
          Buff[157] := $00;
          Buff[158] := $00;
          Buff[159] := $00;
          Buff[160] := $00;
          Buff[161] := $00;
          Buff[162] := $00;
          Buff[163] := $00;
          Buff[164] := $00;
          Buff[165] := $00;
          Buff[166] := $00;
          Buff[167] := $00;

          // O código continua preenchendo o array Buff...

          // Definir o comprimento do pacote
          // Len := 168;

          // Chamar o método SendPacket usando Self

          // Servers[Player.Base.ChannelId].Players[Player.Base.ClientID].SendPacket(Buff, Len);
          // Player.SendPacket(Buff, Len);
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.nacao1') then
        begin
          Player.Base.Character.Nation := 1;
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.nacao2') then
        begin
          Player.Base.Character.Nation := 2;
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.nacao3') then
        begin
          Player.Base.Character.Nation := 3;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.cash') then
        begin
          if (Player.Account.Header.CashInventory.Cash < 899999) then
            Player.AddCash(100000);

          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.gold') then
        begin
          if (Player.Base.PlayerCharacter.Base.Gold < 999999999) then
            Player.AddGold(1000000000);

          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.neve') then
        begin

          for I := 0 to 449 do
          begin
            if Servers[Player.ChannelIndex].Mobs.TMobS[I].IntName <> 2418 then
              continue;

            TItemFunctions.SpawnMob(Player,
              Player.Base.PlayerCharacter.CurrentPos, I,
              Player.Base.ClientID, True);
            Result := True;
            Exit;

          end;

        end;

        if (String(Packet.Fala) = '.gor') then
        begin
          TItemFunctions.SpawnMob(Player,
            Player.Base.PlayerCharacter.CurrentPos, 372,
            Player.Base.ClientID, True);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.seridun') then
        begin
          TItemFunctions.SpawnMob(Player,
            Player.Base.PlayerCharacter.CurrentPos, 373,
            Player.Base.ClientID, True);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.seridun') then
        begin
          TItemFunctions.SpawnMob(Player,
            Player.Base.PlayerCharacter.CurrentPos, 373 - 5,
            Player.Base.ClientID, True);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.outro') then
        begin
          TItemFunctions.SpawnMob(Player,
            Player.Base.PlayerCharacter.CurrentPos, 374,
            Player.Base.ClientID, True);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.renovar') then
        begin
          var
            Packet1: TF12Effect;
          Packet1.Header.Size := SizeOf(Packet);
          Packet1.Header.Index := $7535;
          Packet1.ClientID := Player.Base.ClientID;
          Packet1.Header.Code := $114;

          for I := 9000 to 10000 do
          begin
            // Player.Base.SendCreateMob(SPAWN_NORMAL,0,true,0,i);
            Packet1.EffectId := I;
            Player.Base.SendToVisible(Packet1, SizeOf(Packet1), True);
            Player.SendClientMessage('testado : ' + I.ToString);
            sleep(200);
          end;

          Result := True;
          Exit;
        end;



        // if (String(Packet.Fala) = '.novor') then
        // begin
        // Servers[0].GetPlayer('Rafinho');
        //
        // Exit(true);
        // end;

        if (String(Packet.Fala) = '.imortal') then
        begin
          Player.Base.AddBuff(6990);

          Exit(True);
        end;
        if (String(Packet.Fala) = '.mortal') then
        begin

          Player.Base.RemoveBuffByIndex(6990);

          Exit(True);
        end;
        if (String(Packet.Fala) = '.hp') then
        begin

          Player.Base.AddBuff(6649);

          Exit(True);
        end;

        if (String(Packet.Fala) = '.times') then
        begin

          Player.SendClientMessage('está teleportando? ' +
            Player.ChangingChannel.ToString());;

          Exit(True);
        end;

        if (String(Packet.Fala) = '.red0') then
        begin

          var
            Freq: Int64; // Frequência do contador de alta resolução
          var
            StartCount, EndCount: Int64; // Contadores de início e fim
          var
            ElapsedTime: System.Double; // Tempo decorrido em milissegundos
          if not QueryPerformanceFrequency(Freq) then
          begin
            WriteLn('O contador de alta resolução não é suportado neste sistema.');
            Exit;
          end;

          if Freq = 0 then
          begin
            WriteLn('A frequência do contador é zero. Não é possível calcular o tempo.');
            Exit;
          end;

          QueryPerformanceCounter(StartCount);

          WriteLn('cheguei até aqui ');
          QueryPerformanceCounter(EndCount);
          ElapsedTime := (EndCount - StartCount) / Freq;
          WriteLn(Format('O código foi executado em %.9f ms.', [ElapsedTime]));

        end;

        if (String(Packet.Fala) = '.red1') then
        begin

          var
            Freq: Int64; // Frequência do contador de alta resolução
          var
            StartCount, EndCount: Int64; // Contadores de início e fim
          var
            ElapsedTime: System.Double; // Tempo decorrido em milissegundos
          if not QueryPerformanceFrequency(Freq) then
          begin
            WriteLn('O contador de alta resolução não é suportado neste sistema.');
            Exit;
          end;

          if Freq = 0 then
          begin
            WriteLn('A frequência do contador é zero. Não é possível calcular o tempo.');
            Exit;
          end;

          QueryPerformanceCounter(StartCount);

          try
            WriteLn('cheguei até aqui ');
          finally
            QueryPerformanceCounter(EndCount);
            ElapsedTime := (EndCount - StartCount) / Freq;
            WriteLn(Format('O código foi executado em %.9f ms.',
              [ElapsedTime]));
          end;



          // writeln(' testando red');
          // for i:= 0 to 15000 do
          // begin
          //
          // if ((Skilldata[i].EF[0] = 212) or (Skilldata[i].EF[1] = 212) or (Skilldata[i].EF[0] = 212)) then
          // begin
          // if (Skilldata[i].EF[0] = 212) and (Skilldata[i].EFV[0] > 0) then
          // WriteLn('id: ' + i.ToString + ' rate ' + Skilldata[i].EFV[0].ToString);
          //
          // if (Skilldata[i].EF[1] = 212) and (Skilldata[i].EFV[1] > 0) then
          // WriteLn('id: ' + i.ToString + ' rate ' + Skilldata[i].EFV[0].ToString);
          //
          // if (Skilldata[i].EF[2] = 212) and (Skilldata[i].EFV[2] > 0) then
          // WriteLn('id: ' + i.ToString + ' rate ' + Skilldata[i].EFV[0].ToString);
          //
          // end;
          //
          // end;

          //

          // for i:= 0 to 15000 do
          // begin
          //
          // if ((Skilldata[i].EF[0] = 3) or (Skilldata[i].EF[1] = 3) or (Skilldata[i].EF[0] = 3)) and  ((Skilldata[i].EFV[0] > 4000) or (Skilldata[i].EFV[1] > 4000) or (Skilldata[i].EFV[2] > 4000)) then
          // begin
          // WriteLn('id: ' + i.ToString);
          // end;
          //
          // end;


          // Player.SendClientMessage(Player.base.GetMobClass().ToString);
          // for i:= 0 to 15000 do
          // begin
          // if SkillData[i].Classe <> 0 then
          // continue;
          //
          //
          // if (skilldata[i].TargetType <> 1) and (skilldata[i].Damage < 30000) then
          // continue;
          // WriteLn('id: ' + i.ToString);
          /// /              if (SkillData[i].Range = 0) and (Skilldata[i].DamageRange = 0) then
          /// /              continue;
          //
          //
          //
          /// /              if ((Skilldata[i].EF[0] = 3) or (Skilldata[i].EF[1] = 3) or (Skilldata[i].EF[0] = 3)) and  ((Skilldata[i].EFV[0] > 4000) or (Skilldata[i].EFV[1] > 4000) or (Skilldata[i].EFV[2] > 4000)) then
          /// /              begin
          /// /              WriteLn('id: ' + i.ToString);
          /// /              end;
          //
          // end;

          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.infamia') then
        begin
          Player.Base.Character.CurrentScore.Infamia := 0;
          Player.Base.SendCreateMob(0, 0, True);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.dc') then
        begin
          Player.Disconnect;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.testar') then
        begin
          var key: TPlayerKey;
          var xPlayer: PPlayer;
          // Itera sobre as chaves do dicionário ActivePlayers
          for Key in ActivePlayers.Keys do
          begin

            // Acessa o jogador associado à chave
            xPlayer := @Servers[Key.ServerID].Players[key.ClientID];

            // Exemplo: Enviar uma mensagem para o jogador
            xPlayer.SendClientMessage('Você está sendo testado!');

          end;

          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.1') then
        begin
          // Writeln('Critico ' + Player.Base.Character.CurrentScore.Critical.ToString);
          // Writeln('Acerto ' + Player.Base.Character.CurrentScore.Acerto.ToString);
          // Writeln('Esquiva ' + Player.Base.Character.CurrentScore.Esquiva.ToString);
          // Writeln('Esquiva ' + Player.Base.Character.CurrentScore.Esquiva.ToString);
          // Writeln('Esquiva ' + Player.Base.Character.CurrentScore.Esquiva.ToString);

          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.remover') then
        begin

          // Servers[0].PlayersInElter := Servers[0].PlayersInElter - 1;
          // Servers[0].PlayersSetados := Servers[0].PlayersSetados - 1;
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.dungeon') then
        begin
          Player.SendClientMessage('');
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.ver') then
        begin
          var
          id := 1;
          // TPacketHandlers.SeeInventory(id, Player, Buffer);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.entrarelter') then
        begin

          Self.ChangeChannel(Player, Buffer, 50);

        end;

        if (String(Packet.Fala) = '.opcode') then
        begin

          for I := 0 to $FF do
          begin

            // if i = $ then
            // Continue;

            Player.SendData(Player.Base.ClientID, I, $1);
            Player.SendClientMessage('Pacote enviado com id do opcode ' +
              I.ToString);
            sleep(1000);
          end;

        end;

        if (String(Packet.Fala) = '.novor') then
        begin
          WriteLn('tempo restante ' + Player.F12TempoRestante.ToString);
          WriteLn('tempo gasto ' + Player.F12TempoAtivo.ToString);

          if Player.F12Ativo then
            WriteLn('ativo')
          else
            WriteLn('inativo');

        end;

        if (String(Packet.Fala) = '.teste') then
        begin
          Self.teste(Player);
          // Player.OpennedNPC:= 0;
          // Player.OpennedOption:=0;
          // //Player.SaveInGame(Player.Base.Character.CharIndex, false);
          // Player.SaveInGamePrincipal(Player.Base.Character.CharIndex, false);
          // Player.SaveInGame(Player.Base.Character.CharIndex, false);

        end;
        if (String(Packet.Fala) = '.testar') then
        begin
          WriteLn('acerto do jogador: ' + Player.Base.Character.CurrentScore.
            Acerto.ToString);

          // Player.SendClientMessage('Dungeon thread id ? ' +Player.DungeonInstanceID.ToString,16,16,16);
          // Player.SendClientMessage('Dungeon está ativo? '+DungeonInstances[Player.DungeonInstanceID].InstanceOnline.ToString,16,16,16);
          // Player.SendClientMessage('Dungeon index?  '+DungeonInstances[Player.DungeonInstanceID].index.ToString,16,16,16);
          //

          // TPacketHandlers.Teste(Player);


          // for i := 0 to 999999 do
          // begin
          // Player.send(i);
          // sleep(50);
          // Player.SendEffect(0);
          // sleep(50);
          // end;

          // Player.SendClientMessage('Esperando status: ' + Player.Waiting1.ToString);
          // for i := 0 to IpList.Count - 1 do
          // begin
          // var Ip := IpList[i];
          // var Count := 0;  // Reinicia a contagem a cada novo IP
          // for j := 0 to IpList.Count - 1 do
          // begin
          // if IpList[j] = Ip then
          // Inc(Count);
          // end;
          //
          // // Exibe o IP e a quantidade de vezes que apareceu
          // Player.SendClientMessage('IP: ' + Ip + ' - Contagem: ' + Count.ToString);
          // end;

          // Player.SendData(Player.Base.ClientId, $310, $15);

          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.salvar') then
        begin
          Player.Disconnect;
          Player.SocketClosed := True;
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.quantidade') then
        begin
          // Player.SendClientMessage('Quantidade de Players na Elter ' + Servers[0].PlayersInElter.ToString);
          // Player.SendClientMessage('Quantidade de Players setados (esperando/lutando/finalizando) ' + Servers[0].PlayersSetados.ToString);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.mover') then
        begin
          WriteLn(Player.Base.PlayerCharacter.Base.ClassInfo);
          Player.Teleport(TPosition.Create(3452, 833));
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.ursula') then
        begin
          Player.Teleport(TPosition.Create(3213, 3752));
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.mina1') then
        begin
          Player.Teleport(TPosition.Create(2716, 1611));
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.mina2') then
        begin
          Player.Teleport(TPosition.Create(2365, 1581));
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.jardim') then
        begin
          Player.Teleport(TPosition.Create(1835, 1094));
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.mob') then
        begin
          WriteLn(Player.Base.PlayerCharacter.Base.CurrentScore.Esquiva);
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.team') then
        begin
          WriteLn(Player.Team1);
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.cidade') then
        begin
          WriteLn(Player.GetCurrentCityID);
          Result := True;
          Exit;
        end;
        if (String(Packet.Fala) = '.console') then
        begin
          WinExec('cmd.exe /C cls', SW_HIDE);
        end;

        if (String(Packet.Fala) = '.auxilio') then
        begin
          var
            PlayerSQLComp: TQuery;
          var
            LocalPremiumTime: TDateTime;
          var
            CurrentTime, NextMinuteTime: TDateTime;

          PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
            AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
            AnsiString(MYSQL_DATABASE));

          if not(PlayerSQLComp.Query.Connection.Connected) then
          begin
            Logger.Write
              ('Falha de conexão com o banco de dados.[SendAccountStatus]',
              TLogType.Warnings);
            Logger.Write('MYSQL CONNECTION FAILED.[SendAccountStatus]',
              TLogType.Error);
            PlayerSQLComp.Destroy;
            Exit;
          end;

          try
            // Consulta SQL para pegar o username e premium_time
            PlayerSQLComp.SetQuery('SELECT username, premium_time ' +
              'FROM premium_account ' + 'WHERE username = "' +
              Player.Account.Header.Username + '"');

            PlayerSQLComp.Run();

            // Self.SendClientMessage('Data de término', 16, 16, 16);
            // Self.SendClientMessage('Dia: ' + FormatDateTime('dd/mm/yyyy', LocalPremiumTime) + ' às ' + FormatDateTime('hh:nn', LocalPremiumTime), 16, 16, 16);
            // Verifica se o resultado da consulta não está vazio
            if PlayerSQLComp.Query.IsEmpty then
            begin
              PlayerSQLComp.Free;
              Exit;
            end;

            // Pega o valor do premium_time da consulta e converte diretamente para TDateTime
            Player.Account.Header.Username :=
              String(PlayerSQLComp.Query.FieldByName('username').AsString);
            LocalPremiumTime := PlayerSQLComp.Query.FieldByName('premium_time')
              .AsDateTime;

          except
            on E: Exception do
            begin
              Logger.Write('Erro ao carregar os dados de premium_account. Msg['
                + E.Message + ']', TLogType.Error);
              PlayerSQLComp.Destroy;
              Exit;
            end;
          end;

          PlayerSQLComp.Destroy;
          // Obtém a hora atual
          CurrentTime := Now;

          // Verifica se o premium_time é anterior ao horário atual (ou seja, expirou)
          if LocalPremiumTime < CurrentTime then
          begin
            Exit;
          end;
          // Define o horário do próximo minuto a partir do momento atual
          NextMinuteTime := IncMinute(CurrentTime, 1);

          // Verifica se o premium_time é posterior ao próximo minuto
          if LocalPremiumTime >= NextMinuteTime then
          begin
          end
          else
          begin
          end;
          Result := True;
          Exit;
        end;

        // if (String(Packet.Fala) = '.aviso') then
        // begin
        //
        /// /        self.RequestServerPing(Player,)
        // end;
        if (String(Packet.Fala) = '.eltercustom') then
        begin

          if not(Player.Account.Header.AccountType = TAccountType.Admin) then
            Exit;

          StartElter := True;

        end;

        if (String(Packet.Fala) = '.aviso') then
        begin
          var
            Packets: TElterFecharPlacar;

          Packets.Header.Size := SizeOf(TElterFecharPlacar);
          Packets.Header.Code := $199;

          Packets.TempoRestante := 60;

          for I := 0 to 65535 do
          begin
            Packets.Status := I;
            Player.SendPacket(Packets, SizeOf(TElterFecharPlacar));
            sleep(1);
            Player.SendClientMessage('enviado packet ' + I.ToString);
          end;




          // for I := 0 to 39 do
          // begin
          // Player.SendClientMessage('meu item bar original : ' + ((Player.Base.Character.ItemBar[i] / 16) - 2).ToString);
          // Player.SendClientMessage('meu item bar personalizado : ' + Player.Base.Character.ItemBar[i].ToString);
          // var SkillID: integer :=  round(Player.Base.Character.ItemBar[i] / 16);
          // if (skillid = -2) or (Player.Base.Character.ItemBar[i] = 0) then
          // continue;
          // Player.RefreshItemBarSlot(I, 2, SkillID);
          // end;
          //
          //
          //
          // for I := 0 to 39 do
          // begin
          // Player.SendClientMessage('meu item bar original : ' + ((Player.Base.Character.ItemBar[i] / 16) - 2).ToString);
          // Player.SendClientMessage('meu item bar personalizado : ' + Player.Base.Character.ItemBar[i].ToString);
          // var SkillID: integer :=  round(Player.Base.Character.ItemBar[i] / 16);
          // if (skillid = -2) or (Player.Base.Character.ItemBar[i] = 0) then
          // continue;
          // Player.RefreshItemBarSlot(I, 1, SkillID);
          // end;
          //
          //
          //
          // for I := 0 to 39 do
          // begin
          // Player.SendClientMessage('meu item bar original : ' + ((Player.Base.Character.ItemBar[i] / 16) - 2).ToString);
          // Player.SendClientMessage('meu item bar personalizado : ' + Player.Base.Character.ItemBar[i].ToString);
          // var SkillID: integer :=  round(Player.Base.Character.ItemBar[i] / 16);
          // if (skillid = -2) or (Player.Base.Character.ItemBar[i] = 0) then
          // continue;
          // Player.RefreshItemBarSlot(I, 0, SkillID);
          // end;
          //
          //
          //
          // for I := 0 to 39 do
          // begin
          // Player.SendClientMessage('meu item bar original : ' + ((Player.Base.Character.ItemBar[i] / 16) - 2).ToString);
          // Player.SendClientMessage('meu item bar personalizado : ' + Player.Base.Character.ItemBar[i].ToString);
          // var SkillID: integer :=  round(Player.Base.Character.ItemBar[i] / 16);
          // if (skillid = -2) or (Player.Base.Character.ItemBar[i] = 0) then
          // continue;
          // Player.RefreshItemBarSlot(I, 3, SkillID);
          // end;
          //
          //
          //
          // for I := 0 to 39 do
          // begin
          // Player.SendClientMessage('meu item bar original : ' + ((Player.Base.Character.ItemBar[i] / 16) - 2).ToString);
          // Player.SendClientMessage('meu item bar personalizado : ' + Player.Base.Character.ItemBar[i].ToString);
          // var SkillID: integer :=  round(Player.Base.Character.ItemBar[i] / 16);
          // if (skillid = -2) or (Player.Base.Character.ItemBar[i] = 0) then
          // continue;
          // Player.RefreshItemBarSlot(I, 4, SkillID);
          // end;
          //
          //
          // for I := 0 to 39 do
          // begin
          // Player.SendClientMessage('meu item bar original : ' + ((Player.Base.Character.ItemBar[i] / 16) - 2).ToString);
          // Player.SendClientMessage('meu item bar personalizado : ' + Player.Base.Character.ItemBar[i].ToString);
          // var SkillID: integer :=  round(Player.Base.Character.ItemBar[i] / 16);
          // if (skillid = -2) or (Player.Base.Character.ItemBar[i] = 0) then
          // continue;
          // Player.RefreshItemBarSlot(I, 5, SkillID);
          // end;
          //
          // for I := 0 to 39 do
          // begin
          // Player.SendClientMessage('meu item bar original : ' + ((Player.Base.Character.ItemBar[i] / 16) - 2).ToString);
          // Player.SendClientMessage('meu item bar personalizado : ' + Player.Base.Character.ItemBar[i].ToString);
          // var SkillID: integer :=  round(Player.Base.Character.ItemBar[i] / 16);
          // if (skillid = -2) or (Player.Base.Character.ItemBar[i] = 0) then
          // continue;
          // Player.RefreshItemBarSlot(I, 6, SkillID);
          // end;

          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.online') then
        begin
          // Mostra quantidade de players online multiplicado por 2
          Player.SendClientMessage((2 * ActivePlayersNow).ToString +
            ' Jogador(es) ativos', 16, 16, 16);
          Result := True;
          Exit;
        end;

        if (String(Packet.Fala) = '.horario') then
        begin
          // Mostra o horario do servidor (da maquina)
          Player.SendClientMessage(DateTimeToStr(Now), 16, 16, 16);
          Result := True;
          Exit;
        end;

        if (Packet.Fala[0] = '%') then
        begin
          if (Player.IsArchon) then
          begin
            Packet.TypeChat := CHAT_TYPE_NATION;

            if (Nations[Player.Base.Character.Nation - 1]
              .TacticianGuildID = Guilds[Player.Character.GuildSlot].Index) then
            begin
              Packet.NotUse[0] := 1;
            end;

            if (Nations[Player.Base.Character.Nation - 1].JudgeGuildID = Guilds
              [Player.Character.GuildSlot].Index) then
            begin
              Packet.NotUse[0] := 2;
            end;

            if (Nations[Player.Base.Character.Nation - 1]
              .TreasurerGuildID = Guilds[Player.Character.GuildSlot].Index) then
            begin
              Packet.NotUse[0] := 3;
            end;

            strAux := string(Packet.Fala);
            strAux := ReplaceStr(strAux, '%', '');

            System.AnsiStrings.StrPLCopy(Packet.Fala, strAux, 128);
            WriteLn('=== Debug do Pacote ===');

            // Exibir valores do cabeçalho (Header)
            WriteLn('Header:');
            WriteLn('  Size: ', IntToHex(Packet.Header.Size, 2));
            // Exibir Size em hexadecimal sem zeros à esquerda
            WriteLn('  Key: ', IntToHex(Packet.Header.Key, 2));
            // Exibir Key em hexadecimal sem zeros à esquerda
            WriteLn('  ChkSum: ', IntToHex(Packet.Header.ChkSum, 2));
            // Exibir ChkSum em hexadecimal sem zeros à esquerda
            WriteLn('  Index: ', IntToHex(Packet.Header.Index, 2));
            // Exibir Index em hexadecimal sem zeros à esquerda
            WriteLn('  Code: ', IntToHex(Packet.Header.Code, 2));
            // Exibir Code em hexadecimal sem zeros à esquerda
            WriteLn('  Time: ', IntToHex(Packet.Header.Time, 2));
            // Exibir Time em hexadecimal sem zeros à esquerda

            // Exibir os valores do corpo do pacote (TChatPacket)
            WriteLn('TypeChat: ', IntToHex(Packet.TypeChat, 2));
            // Exibir TypeChat em hexadecimal sem zeros à esquerda
            WriteLn('NotUse: ', IntToHex(Packet.NotUse[0], 2), ' ',
              IntToHex(Packet.NotUse[1], 2), ' ', IntToHex(Packet.NotUse[2], 2),
              ' ', IntToHex(Packet.NotUse[3], 2), ' ',
              IntToHex(Packet.NotUse[4], 2), ' ', IntToHex(Packet.NotUse[5], 2)
              ); // Exibir os valores de NotUse em hexadecimal sem zeros à esquerda

            WriteLn('Color: ', IntToHex(Packet.Color, 8));
            // Exibir Color em hexadecimal

            // Exibir o Nick e Fala como bytes em hexadecimal, compactado
            var
            NickHex := '';
            var
              l: Integer;
            for l := 1 to Length(Trim(String(Packet.Nick))) do
              NickHex := NickHex +
                IntToHex(Ord(Trim(String(Packet.Nick))[l]), 2) + ' ';
            WriteLn('Nick: ', Trim(NickHex)); // Remover espaços extras no final

            var
            FalaHex := '';
            for l := 1 to Length(Trim(String(Packet.Fala))) do
              FalaHex := FalaHex +
                IntToHex(Ord(Trim(String(Packet.Fala))[l]), 2) + ' ';
            WriteLn('Fala: ', Trim(FalaHex)); // Remover espaços extras no final

            var
            HexString := '';
            for l := 0 to 167 do
              HexString := HexString + Format('%.2x ', [Buffer[l]]);
            // %.2x garante 2 dígitos hexadecimais

            WriteLn(HexString);

            for I := Low(Servers) to High(Servers) do
            begin
              for j := Low(Servers[I].Players) to High(Servers[I].Players) do
              begin
                if (Servers[I].Players[j].Status < Playing) then
                  continue;
                if ((Servers[I].Players[j].Base.Character.Nation = Player.Base.
                  Character.Nation) and
                  not(Servers[I].Players[j].Base.Character.Nation = 0)) then
                begin
                  WriteLn('marechal');

                  Servers[I].Players[j].SendPacket(Packet, Packet.Header.Size);
                end;
              end;
            end;

          end
          else
          begin
            Player.Base.SendToVisible(Packet, Packet.Header.Size);
          end;
        end
        else
        begin
          // for i := 0 to 20 do
          // begin
          // Packet.TypeChat:= i;
          // WriteLn('packet chat: ' +i.ToString);
          // sleep(1500);
          if Player.IsAuxilyUser then
            Packet.TypeChat := 8;

          Player.Base.SendToVisible(Packet, Packet.Header.Size);

          // end;
          // Writeln('envio com false no encrypt ');
          // Player.Base.SendToVisible(Packet, Packet.Header.Size, true);
          // Writeln('envio com true no encrypt ');
        end;
      end;
    CHAT_TYPE_SUSSURO:
      begin
        if (Player.Account.Header.AccountType >= GameMaster) and
          (Packet.Nick[0] = '/') then
        begin
          TCommandHandlers.ProcessCommands(Player, string(Packet.Nick),
            string(Packet.Fala));
          Result := True;
          Exit;
        end;
        if not(Servers[Player.ChannelIndex].GetPlayerByName(string(Packet.Nick),
          OtherPlayer)) then
        begin
          Player.SendClientMessage('Personagem não encontrado.');
          Exit;
        end;
        Player.SendPacket(Packet, Packet.Header.Size);
        AnsiStrings.StrLCopy(Packet.Nick, Player.Character.Base.Name, 16);

        OtherPlayer.SendPacket(Packet, Packet.Header.Size);
      end;
    CHAT_TYPE_GRUPO:
      begin
        Player.SendToParty(Packet, Packet.Header.Size);
      end;
    CHAT_TYPE_GUILD:
      begin
        if Player.Character.Base.GuildIndex <= 0 then
        begin
          Player.SendClientMessage('Você não está em uma guild.');
          Exit;
        end;
        Guilds[Player.Character.GuildSlot].SendChatMessage(Packet,
          Packet.Header.Size);
      end;
    CHAT_TYPE_GRITO:
      begin

        for j := 0 to 3 do
        begin
          for I := Low(Servers[j].Players) to High(Servers[j].Players) do
          begin

            var
              PlayerOther: PPlayer;

            PlayerOther := @Servers[j].Players[I];

            if ((PlayerOther.Status <> Playing) or (PlayerOther.SocketClosed))
            then
              continue;

            Packet.TypeChat := 8;

            Servers[j].SendPacketTo(I, Packet, Packet.Header.Size);

          end;

          Player.ShoutTime := Now;

        end;
      end;
    CHAT_TYPE_ALLY:
      begin
        if Player.Character.Base.GuildIndex <= 0 then
        begin
          Player.SendClientMessage('Você não está em uma guild.');
          Exit;
        end;

        if (Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1) then
          Exit;

        Guilds[Player.Character.GuildSlot].SendChatAllyMessage(Packet,
          Packet.Header.Size);
      end;
    CHAT_TYPE_NATION:
      begin
        if not(Player.IsArchon) then
        begin
          if not(Player.IsMarshal) then
            Exit;
        end;
        for I := Low(Servers) to High(Servers) do
        begin
          for j := Low(Servers[I].Players) to High(Servers[I].Players) do
          begin
            if (Servers[I].Players[j].Status < Playing) then
              continue;
            if ((Servers[I].Players[j].Base.Character.Nation = Player.Base.
              Character.Nation) and
              not(Servers[I].Players[j].Base.Character.Nation = 0)) then
            begin
              // Packet.Color :=$FFFFFFFF;
              // Writeln('marechal 1');
              // var colorindex: integer;
              // for colorIndex := 0 to 19 do
              // begin
              // Packet.Color := $4F000000 + (colorIndex * $00111111); // Gera 20 cores no formato $AARRGGBB
              //
              // end;
              // var nome: AnsiString := 'Caligula';
              // AnsiStrings.StrLCopy(Packet.Nick, PAnsiChar(nome), 16);
              // var chattype: integer;
              // Packet.TypeChat := 7;
              Servers[I].Players[j].SendPacket(Packet, Packet.Header.Size);

              // var nickindex: integer;
              // for nickIndex := 0 to 15 do
              // begin
              // Packet.Nick[nickIndex] := #0;
              // end;
              // // Zera cada posição do array Packet.Nick
              // Writeln('=== Debug do Pacote ===');
              //
              // // Exibir valores do cabeçalho (Header)
              // Writeln('Header:');
              // Writeln('  Size: ', IntToHex(Packet.Header.Size, 2));  // Exibir Size em hexadecimal sem zeros à esquerda
              // Writeln('  Key: ', IntToHex(Packet.Header.Key, 2));  // Exibir Key em hexadecimal sem zeros à esquerda
              // Writeln('  ChkSum: ', IntToHex(Packet.Header.ChkSum, 2));  // Exibir ChkSum em hexadecimal sem zeros à esquerda
              // Writeln('  Index: ', IntToHex(Packet.Header.Index, 2));  // Exibir Index em hexadecimal sem zeros à esquerda
              // Writeln('  Code: ', IntToHex(Packet.Header.Code, 2));  // Exibir Code em hexadecimal sem zeros à esquerda
              // Writeln('  Time: ', IntToHex(Packet.Header.Time, 2));  // Exibir Time em hexadecimal sem zeros à esquerda
              //
              // // Exibir os valores do corpo do pacote (TChatPacket)
              // Writeln('TypeChat: ', IntToHex(Packet.TypeChat, 2));  // Exibir TypeChat em hexadecimal sem zeros à esquerda
              // Writeln('NotUse: ', IntToHex(Packet.NotUse[0], 2), ' ',
              // IntToHex(Packet.NotUse[1], 2), ' ',
              // IntToHex(Packet.NotUse[2], 2), ' ',
              // IntToHex(Packet.NotUse[3], 2), ' ',
              // IntToHex(Packet.NotUse[4], 2), ' ',
              // IntToHex(Packet.NotUse[5], 2));  // Exibir os valores de NotUse em hexadecimal sem zeros à esquerda
              //
              // Writeln('Color: ', IntToHex(Packet.Color, 8));  // Exibir Color em hexadecimal
              //
              // // Exibir o Nick e Fala como bytes em hexadecimal, compactado
              // var NickHex := '';
              // var l: integer;
              // for l := 1 to Length(Trim(String(Packet.Nick))) do
              // NickHex := NickHex + IntToHex(Ord(Trim(String(Packet.Nick))[l]), 2) + ' ';
              // Writeln('Nick: ', Trim(NickHex));  // Remover espaços extras no final
              //
              // var FalaHex := '';
              // for l := 1 to Length(Trim(String(Packet.Fala))) do
              // FalaHex := FalaHex + IntToHex(Ord(Trim(String(Packet.Fala))[l]), 2) + ' ';
              // Writeln('Fala: ', Trim(FalaHex));  // Remover espaços extras no final
              //
              // var HexString := '';
              // for l := 0 to 167 do
              // HexString := HexString + Format('%.2x ', [Buffer[l]]);  // %.2x garante 2 dígitos hexadecimais
              //
              // Writeln(HexString);
            end;
          end;
        end;
      end;
    CHAT_TYPE_MEGAFONE:
      begin
        /// /        ItemSlot := TItemFunctions.GetItemSlotByItemType(Player, 80,
        /// /          INV_TYPE, 0);
        /// /        if (ItemSlot = 255) then
        /// /        begin
        /// /          Player.SendClientMessage
        /// /            ('Você precisa ter o item [Ticket do Megafone]');
        /// /          Exit;
        /// /        end
        /// /        else
        /// /        begin
        // TItemFunctions.DecreaseAmount(@Player.Base.Character.Inventory
        // [ItemSlot], 1);
        // Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
        // Player.Base.Character.Inventory[ItemSlot], False);
        // for i:= 0 to 20 do
        // begin
        // Packet.TypeChat:= i;
        // Servers[Player.ChannelIndex].SendToAll(Packet, Packet.Header.Size);
        // writeln('enviado :' + i.ToString);
        // sleep(1500);
        // end;
        // end;
      end
  else
    begin
      Logger.Write('packet-> chatType: ' + Packet.TypeChat.ToString,
        TLogType.Packets);
      Exit;
    end;
  end;
  Result := True;
end;

class function TPacketHandlers.SendItemChat(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TLinkItemPacket absolute Buffer;
begin
  Result := Player.Base.IsActive and Packet.LinkItem and
    Player.SendItemChat(Packet.ItemSlot, Packet.ChatType, string(Packet.Fala));
end;

{$ENDREGION}
{$REGION 'NPC Functions'}

procedure Sair(var Player: TPlayer);
begin
  Player.OpennedNPC := 0;
  Player.OpennedOption := 0;
end;

class function TPacketHandlers.OpenNPC(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TOpenNPCPacket absolute Buffer;
  PacketReliqShow: TSendDevirInfoPacket;
  ReliqSlot: BYTE;
  I, InvSlotFree: Integer;
begin
  Result := false;

  case Packet.Index of
    2048 .. 3047:
      begin
        if not(Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
          .Base.PlayerCharacter.LastPos.InRange(Servers[Player.ChannelIndex]
          .NPCS[Packet.Index].Base.PlayerCharacter.LastPos, 10)) then
        begin
          Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .SendSignal($7535, $10F); // fecha o npc pra reabrir
          Sair(Player);
        end;
      end;
  end;

  if (Packet.Index = 0) and not(Packet.Type1 = 8) then
  begin
    Sair(Player);
    Exit;
  end;

  if (((Packet.Index >= 3048) and (Packet.Index <= 3334)) or
    ((Packet.Index >= 3380) and (Packet.Index <= 9147))) then
  begin
    // Clique nos guardas da própria nação
    Sair(Player);
    Exit;
  end;

  if (Packet.Index >= 10148) and (Packet.Index <= 11147) then
  begin

    if Packet.Index = 11000 then // ursula teleporte
    begin
      // Remover buffs de inventário
      if Player.Base.BuffExistsByIndex(77) then
        Player.Base.RemoveBuffByIndex(77);
      if Player.Base.BuffExistsByIndex(53) then
        Player.Base.RemoveBuffByIndex(53);
      if Player.Base.BuffExistsByIndex(153) then
        Player.Base.RemoveBuffByIndex(153);

      Servers[Player.ChannelIndex].CollectReliquare(@Player, Packet.Index);
    end;

    if Packet.Index = 11147 then
    begin
      if Player.Base.Character.Nation = 0 then
        Exit;

      if Servers[Player.ChannelIndex].AltarStolen then
      begin
        Player.SendClientMessage('O Altar dessa nação já foi roubado', 16, 16);
        Exit;
      end;

      if Player.ChannelIndex = Player.Base.Character.Nation - 1 then
      begin
        Player.SendClientMessage
          ('Você não pode abrir o altar da sua própria nação', 16, 16, 16);
        Player.CollectingReliquare := false;
        Player.CollectingAltar := false;
        Player.CollectingID := 0;
        Exit;
      end;

      // Remover buffs de inventário
      if Player.Base.BuffExistsByIndex(77) then
        Player.Base.RemoveBuffByIndex(77);
      if Player.Base.BuffExistsByIndex(53) then
        Player.Base.RemoveBuffByIndex(53);
      if Player.Base.BuffExistsByIndex(153) then
        Player.Base.RemoveBuffByIndex(153);

      Servers[Player.ChannelIndex].CollectReliquare(@Player, Packet.Index);
      Exit;
    end;

    // Clique nos objetos de coletar (baú, relíquias, etc)
    case Servers[Player.ChannelIndex].OBJ[Packet.Index].Face of
      320:
        begin
          if Player.Base.Character.Nation = 0 then
            Exit;

          InvSlotFree := TItemFunctions.GetInvAvailableSlots(Player);
          if InvSlotFree <= 0 then
          begin
            Player.SendClientMessage
              ('Inventário cheio para coletar relíquias.');
            Exit;
          end;

          // Remover buffs de inventário
          if Player.Base.BuffExistsByIndex(77) then
            Player.Base.RemoveBuffByIndex(77);
          if Player.Base.BuffExistsByIndex(53) then
            Player.Base.RemoveBuffByIndex(53);
          if Player.Base.BuffExistsByIndex(153) then
            Player.Base.RemoveBuffByIndex(153);

          Servers[Player.ChannelIndex].CollectReliquare(@Player, Packet.Index);
        end;
      350:
        begin

        end;
    else
      begin
        // Programar aqui para as caixas de item/gold/evento
      end;
    end;
    Exit;
  end;

  if (Packet.Index <= MAX_CONNECTIONS) and not(Packet.Type1 = 8) then
  begin
    Player.SendClientMessage('Esta opção não funciona em jogadores.');
    Sair(Player);
    Exit;
  end;

  case Packet.Type1 of
    1, 2, 21: // Conversa, Quests, Menu (não fecha o NPC)
      begin
        // Nada a fazer
      end;
  else
    begin
      Player.SendSignal($7535, $10F); // Fecha o NPC para reabrir
    end;
  end;

  case Packet.Index of
    3335: // amk devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3335].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Sair(Player);
          Exit;
        end;

        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Sair(Player);
          Exit;
        end;

        if (Servers[Player.ChannelIndex].Devires[0].NationID = Integer
          (Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própria nação.');
            Sair(Player);
            Exit;
          end
          else
          begin // [ENTREGAR RELÍQUIA]
            // Verifica se há algum jogador obtendo relíquia atualmente
            if Servers[Player.ChannelIndex].Devires[0]
              .PlayerIndexGettingReliq <> 0 then
            begin
              Player.SendClientMessage
                ('O jogador <' + AnsiString(Servers[Player.ChannelIndex].Players
                [Servers[Player.ChannelIndex].Devires[0]
                .PlayerIndexGettingReliq].Base.Character.Name) +
                '> está com o devir aberto agora.');
              Exit;
            end;

            ZeroMemory(@PacketReliqShow, SizeOf(PacketReliqShow));
            PacketReliqShow.Header.Size := SizeOf(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 00;
            PacketReliqShow.TypeOpen := 5;

            for I := 0 to 4 do
            begin
              if (Servers[Player.ChannelIndex].Devires[0].Slots[I].ItemId <> 0)
              then
              begin
                PacketReliqShow.DevirReliq.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].APP :=
                  PacketReliqShow.DevirReliq.Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].Unknown := I;
                PacketReliqShow.DevirReliq.Slots[I].TimeToEstabilish :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[1].Slots[I]
                  .TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[I].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[I].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[I].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].TimeCapped :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[1].Slots[I].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots
                  [I].NameCapped,
                  String(Servers[Player.ChannelIndex].Devires[1].Slots[I]
                  .NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[I]
                  .IsAble.ToInteger;
              end;
            end;

            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 0;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end;
        end
        else
        begin
          if (Servers[Player.ChannelIndex].Devires[0].IsOpen) then
          begin
            if (Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq
              <> 0) then
            begin
              Player.SendClientMessage
                ('O jogador <' + AnsiString(Servers[Player.ChannelIndex].Players
                [Servers[Player.ChannelIndex].Devires[0]
                .PlayerIndexGettingReliq].Base.Character.Name) +
                '> está com o devir aberto agora.');
              Exit;
            end;

            ZeroMemory(@PacketReliqShow, SizeOf(PacketReliqShow));
            PacketReliqShow.Header.Size := SizeOf(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 00;
            PacketReliqShow.TypeOpen := 5;

            for I := 0 to 4 do
            begin
              if (Servers[Player.ChannelIndex].Devires[0].Slots[I].ItemId <> 0)
              then
              begin
                PacketReliqShow.DevirReliq.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].APP :=
                  PacketReliqShow.DevirReliq.Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].Unknown := I;
                PacketReliqShow.DevirReliq.Slots[I].TimeToEstabilish :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[0].Slots[I]
                  .TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[I].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[I].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[I].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].TimeCapped :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[0].Slots[I].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots
                  [I].NameCapped,
                  String(Servers[Player.ChannelIndex].Devires[0].Slots[I]
                  .NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive :=
                  Servers[Player.ChannelIndex].Devires[0].Slots[I]
                  .IsAble.ToInteger;
              end;
            end;

            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 0;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[0].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end
          else
          begin
            Sair(Player);
            Exit;
          end;
        end;

      end;

    3336: // sig devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3336].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Sair(Player);
          Exit;
        end;

        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Sair(Player);
          Exit;
        end;

        if (Servers[Player.ChannelIndex].Devires[1].NationID = Integer
          (Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própria nação.');
            Sair(Player);
            Exit;
          end;
        end
        else if (Servers[Player.ChannelIndex].Devires[1].IsOpen) then
        begin
          if (Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq
            <> 0) then
          begin
            Player.SendClientMessage('O jogador <' +
              AnsiString(Servers[Player.ChannelIndex].Players
              [Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq]
              .Base.Character.Name) + '> está com o devir aberto agora.');
            Exit;
          end;
        end
        else
        begin
          Sair(Player);
          Exit;
        end;

        ZeroMemory(@PacketReliqShow, SizeOf(PacketReliqShow));
        PacketReliqShow.Header.Size := SizeOf(PacketReliqShow);
        PacketReliqShow.Header.Index := 0;
        PacketReliqShow.Header.Code := $B52;
        PacketReliqShow.DevirID := 01;
        PacketReliqShow.TypeOpen := 05;

        for I := 0 to 4 do
        begin
          if (Servers[Player.ChannelIndex].Devires[1].Slots[I].ItemId <> 0) then
          begin
            PacketReliqShow.DevirReliq.Slots[I].ItemId :=
              Servers[Player.ChannelIndex].Devires[1].Slots[I].ItemId;
            PacketReliqShow.DevirReliq.Slots[I].APP :=
              PacketReliqShow.DevirReliq.Slots[I].ItemId;
            PacketReliqShow.DevirReliq.Slots[I].Unknown := I;
            PacketReliqShow.DevirReliq.Slots[I].TimeToEstabilish :=
              TFunctions.DateTimeToUNIXTimeFAST
              (Servers[Player.ChannelIndex].Devires[1].Slots[I]
              .TimeToEstabilish);
            PacketReliqShow.DevirReliq.Slots[I].UnkByte1 := 2;
            PacketReliqShow.DevirReliq.Slots[I].UnkByte2 := 1;
            PacketReliqShow.DevirReliInfo.Slots[I].ItemId :=
              Servers[Player.ChannelIndex].Devires[1].Slots[I].ItemId;
            PacketReliqShow.DevirReliInfo.Slots[I].IsActive := 1;
            PacketReliqShow.DevirReliInfo.Slots[I].TimeCapped :=
              TFunctions.DateTimeToUNIXTimeFAST
              (Servers[Player.ChannelIndex].Devires[1].Slots[I].TimeCapped);
            System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[I]
              .NameCapped, String(Servers[Player.ChannelIndex].Devires[1].Slots
              [I].NameCapped), 16);
          end
          else
          begin
            PacketReliqShow.DevirReliInfo.Slots[I].IsActive :=
              Servers[Player.ChannelIndex].Devires[1].Slots[I].IsAble.ToInteger;
          end;
        end;

        Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := 5;
        Player.OpennedDevir := 1;
        Player.OpennedTemple := Packet.Index;
        Servers[Player.ChannelIndex].Devires[1].PlayerIndexGettingReliq :=
          Player.Base.ClientID;
        Exit;

      end;
    3337: // cahil devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3337].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Sair(Player);
          Exit;
        end;

        if Integer(Player.Account.Header.Nation) = 0 then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Sair(Player);
          Exit;
        end;

        if Servers[Player.ChannelIndex].Devires[2].NationID = Integer
          (Player.Account.Header.Nation) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if ReliqSlot = 255 then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própria nação.');
            Sair(Player);
            Exit;
          end;
        end
        else
        begin
          if Servers[Player.ChannelIndex].Devires[2].IsOpen then
          begin
            if Servers[Player.ChannelIndex].Devires[2]
              .PlayerIndexGettingReliq <> 0 then
            begin
              Player.SendClientMessage
                ('O jogador <' + AnsiString(Servers[Player.ChannelIndex].Players
                [Servers[Player.ChannelIndex].Devires[2]
                .PlayerIndexGettingReliq].Base.Character.Name) +
                '> está com o devir aberto agora.');
              Exit;
            end;
          end
          else
          begin
            Sair(Player);
            Exit;
          end;
        end;

        ZeroMemory(@PacketReliqShow, SizeOf(PacketReliqShow));
        PacketReliqShow.Header.Size := SizeOf(PacketReliqShow);
        PacketReliqShow.Header.Index := 0;
        PacketReliqShow.Header.Code := $B52;
        PacketReliqShow.DevirID := 02;
        PacketReliqShow.TypeOpen := 05;

        for I := 0 to 4 do
        begin
          if Servers[Player.ChannelIndex].Devires[2].Slots[I].ItemId <> 0 then
          begin
            PacketReliqShow.DevirReliq.Slots[I].ItemId :=
              Servers[Player.ChannelIndex].Devires[2].Slots[I].ItemId;
            PacketReliqShow.DevirReliq.Slots[I].APP :=
              PacketReliqShow.DevirReliq.Slots[I].ItemId;
            PacketReliqShow.DevirReliq.Slots[I].Unknown := I;
            PacketReliqShow.DevirReliq.Slots[I].TimeToEstabilish :=
              TFunctions.DateTimeToUNIXTimeFAST
              (Servers[Player.ChannelIndex].Devires[2].Slots[I]
              .TimeToEstabilish);
            PacketReliqShow.DevirReliq.Slots[I].UnkByte1 := 2;
            PacketReliqShow.DevirReliq.Slots[I].UnkByte2 := 1;
            PacketReliqShow.DevirReliInfo.Slots[I].ItemId :=
              Servers[Player.ChannelIndex].Devires[2].Slots[I].ItemId;
            PacketReliqShow.DevirReliInfo.Slots[I].IsActive := 1;
            PacketReliqShow.DevirReliInfo.Slots[I].TimeCapped :=
              TFunctions.DateTimeToUNIXTimeFAST
              (Servers[Player.ChannelIndex].Devires[2].Slots[I].TimeCapped);
            System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[I]
              .NameCapped, String(Servers[Player.ChannelIndex].Devires[2].Slots
              [I].NameCapped), 16);
          end
          else
          begin
            PacketReliqShow.DevirReliInfo.Slots[I].IsActive :=
              Servers[Player.ChannelIndex].Devires[2].Slots[I].IsAble.ToInteger;
          end;
        end;

        Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := 5;
        Player.OpennedDevir := 2;
        Player.OpennedTemple := Packet.Index;
        Servers[Player.ChannelIndex].Devires[2].PlayerIndexGettingReliq :=
          Player.Base.ClientID;
        Exit;

      end;
    3338: // mirza devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3338].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Sair(Player);
          Exit;
        end;

        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Sair(Player);
          Exit;
        end;

        if (Servers[Player.ChannelIndex].Devires[3].NationID = Integer
          (Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própria nação.');
            Sair(Player);
            Exit;
          end
          else
          begin
            if (Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq
              <> 0) then
            begin
              Player.SendClientMessage
                ('O jogador <' + AnsiString(Servers[Player.ChannelIndex].Players
                [Servers[Player.ChannelIndex].Devires[3]
                .PlayerIndexGettingReliq].Base.Character.Name) +
                '> está com o devir aberto agora.');
              Exit;
            end;

            ZeroMemory(@PacketReliqShow, SizeOf(PacketReliqShow));
            PacketReliqShow.Header.Size := SizeOf(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 03;
            PacketReliqShow.TypeOpen := 5;

            for I := 0 to 4 do
            begin
              if (Servers[Player.ChannelIndex].Devires[3].Slots[I].ItemId <> 0)
              then
              begin
                PacketReliqShow.DevirReliq.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].APP :=
                  PacketReliqShow.DevirReliq.Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].Unknown := I;
                PacketReliqShow.DevirReliq.Slots[I].TimeToEstabilish :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[3].Slots[I]
                  .TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[I].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[I].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[I].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].TimeCapped :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[3].Slots[I].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots
                  [I].NameCapped,
                  String(Servers[Player.ChannelIndex].Devires[3].Slots[I]
                  .NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[I]
                  .IsAble.ToInteger;
              end;
            end;

            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 3;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end;
        end
        else
        begin
          if (Servers[Player.ChannelIndex].Devires[3].IsOpen) then
          begin
            if (Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq
              <> 0) then
            begin
              Player.SendClientMessage
                ('O jogador <' + AnsiString(Servers[Player.ChannelIndex].Players
                [Servers[Player.ChannelIndex].Devires[3]
                .PlayerIndexGettingReliq].Base.Character.Name) +
                '> está com o devir aberto agora.');
              Exit;
            end;

            ZeroMemory(@PacketReliqShow, SizeOf(PacketReliqShow));
            PacketReliqShow.Header.Size := SizeOf(PacketReliqShow);
            PacketReliqShow.Header.Index := 0;
            PacketReliqShow.Header.Code := $B52;
            PacketReliqShow.DevirID := 03;
            PacketReliqShow.TypeOpen := 5;

            for I := 0 to 4 do
            begin
              if (Servers[Player.ChannelIndex].Devires[3].Slots[I].ItemId <> 0)
              then
              begin
                PacketReliqShow.DevirReliq.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].APP :=
                  PacketReliqShow.DevirReliq.Slots[I].ItemId;
                PacketReliqShow.DevirReliq.Slots[I].Unknown := I;
                PacketReliqShow.DevirReliq.Slots[I].TimeToEstabilish :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[3].Slots[I]
                  .TimeToEstabilish);
                PacketReliqShow.DevirReliq.Slots[I].UnkByte1 := 2;
                PacketReliqShow.DevirReliq.Slots[I].UnkByte2 := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].ItemId :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[I].ItemId;
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive := 1;
                PacketReliqShow.DevirReliInfo.Slots[I].TimeCapped :=
                  TFunctions.DateTimeToUNIXTimeFAST
                  (Servers[Player.ChannelIndex].Devires[3].Slots[I].TimeCapped);
                System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots
                  [I].NameCapped,
                  String(Servers[Player.ChannelIndex].Devires[3].Slots[I]
                  .NameCapped), 16);
              end
              else
              begin
                PacketReliqShow.DevirReliInfo.Slots[I].IsActive :=
                  Servers[Player.ChannelIndex].Devires[3].Slots[I]
                  .IsAble.ToInteger;
              end;
            end;

            Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
            Player.OpennedNPC := Packet.Index;
            Player.OpennedOption := 5;
            Player.OpennedDevir := 3;
            Player.OpennedTemple := Packet.Index;
            Servers[Player.ChannelIndex].Devires[3].PlayerIndexGettingReliq :=
              Player.Base.ClientID;
            Exit;
          end
          else
          begin
            Sair(Player);
            Exit;
          end;
        end;

      end;
    3339: // zelant devir
      begin
        if not(Player.Base.PlayerCharacter.LastPos.InRange
          (Servers[Player.ChannelIndex].DevirNpc[3339].PlayerChar.LastPos, 10))
        then
        begin
          Player.SendClientMessage('Você está muito longe do templo.');
          Sair(Player);
          Exit;
        end;

        if (Integer(Player.Account.Header.Nation) = 0) then
        begin
          Player.SendClientMessage
            ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
          Sair(Player);
          Exit;
        end;

        if (Servers[Player.ChannelIndex].Devires[4].NationID = Integer
          (Player.Account.Header.Nation)) then
        begin
          ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
          if (ReliqSlot = 255) then
          begin
            Player.SendClientMessage
              ('Você não pode abrir o templo de sua própria nação.');
            Sair(Player);
            Exit;
          end;
        end
        else if (Servers[Player.ChannelIndex].Devires[4].IsOpen) then
        begin
          if (Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq
            <> 0) then
          begin
            Player.SendClientMessage('O jogador <' +
              AnsiString(Servers[Player.ChannelIndex].Players
              [Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq]
              .Base.Character.Name) + '> está com o devir aberto agora.');
            Exit;
          end;
        end
        else
        begin
          Sair(Player);
          Exit;
        end;

        ZeroMemory(@PacketReliqShow, SizeOf(PacketReliqShow));
        PacketReliqShow.Header.Size := SizeOf(PacketReliqShow);
        PacketReliqShow.Header.Index := 0;
        PacketReliqShow.Header.Code := $B52;
        PacketReliqShow.DevirID := 04;
        PacketReliqShow.TypeOpen := 5;

        for I := 0 to 4 do
        begin
          if (Servers[Player.ChannelIndex].Devires[4].Slots[I].ItemId <> 0) then
          begin
            PacketReliqShow.DevirReliq.Slots[I].ItemId :=
              Servers[Player.ChannelIndex].Devires[4].Slots[I].ItemId;
            PacketReliqShow.DevirReliq.Slots[I].APP :=
              PacketReliqShow.DevirReliq.Slots[I].ItemId;
            PacketReliqShow.DevirReliq.Slots[I].Unknown := I;
            PacketReliqShow.DevirReliq.Slots[I].TimeToEstabilish :=
              TFunctions.DateTimeToUNIXTimeFAST
              (Servers[Player.ChannelIndex].Devires[4].Slots[I]
              .TimeToEstabilish);
            PacketReliqShow.DevirReliq.Slots[I].UnkByte1 := 2;
            PacketReliqShow.DevirReliq.Slots[I].UnkByte2 := 1;
            PacketReliqShow.DevirReliInfo.Slots[I].ItemId :=
              Servers[Player.ChannelIndex].Devires[4].Slots[I].ItemId;
            PacketReliqShow.DevirReliInfo.Slots[I].IsActive := 1;
            PacketReliqShow.DevirReliInfo.Slots[I].TimeCapped :=
              TFunctions.DateTimeToUNIXTimeFAST
              (Servers[Player.ChannelIndex].Devires[4].Slots[I].TimeCapped);
            System.AnsiStrings.StrPLCopy(PacketReliqShow.DevirReliInfo.Slots[I]
              .NameCapped, String(Servers[Player.ChannelIndex].Devires[4].Slots
              [I].NameCapped), 16);
          end
          else
          begin
            PacketReliqShow.DevirReliInfo.Slots[I].IsActive :=
              Servers[Player.ChannelIndex].Devires[4].Slots[I].IsAble.ToInteger;
          end;
        end;

        Player.SendPacket(PacketReliqShow, PacketReliqShow.Header.Size);
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := 5;
        Player.OpennedDevir := 4;
        Player.OpennedTemple := Packet.Index;
        Servers[Player.ChannelIndex].Devires[4].PlayerIndexGettingReliq :=
          Player.Base.ClientID;

      end;
  end;

  if (Packet.Index >= 3370) and (Packet.Index <= 3390) then
  begin
    if not(Player.Base.PlayerCharacter.LastPos.InRange
      (Servers[Player.ChannelIndex].CastleObjects[Packet.Index]
      .PlayerChar.LastPos, 3)) then
    begin
      Player.SendClientMessage('Você está muito longe da orbe.');
      Sair(Player);
      Exit;
    end;

    if (Integer(Player.Account.Header.Nation) = 0) then
    begin
      Player.SendClientMessage
        ('Você não pode abrir templos. Registre-se em uma nação primeiro!');
      Sair(Player);
      Exit;
    end;

    case Packet.Index of

      3370: // orbe da agua 3551 2759
        begin
          Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder[0] :=
            @Servers[Player.ChannelIndex].Players[Player.Base.ClientID];
          // Inc(Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded);
          Servers[Player.ChannelIndex].CastleSiegeHandler.SendHoldingOrbPacket
            (Player, Packet.Index);
        end;
      3371: // orbe do vento 3616 2759
        begin
          Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder[1] :=
            @Servers[Player.ChannelIndex].Players[Player.Base.ClientID];
          // Inc(Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded);
          Servers[Player.ChannelIndex].CastleSiegeHandler.SendHoldingOrbPacket
            (Player, Packet.Index);
        end;
      3372: // orbe do fogo 3584 2860
        begin
          Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder[2] :=
            @Servers[Player.ChannelIndex].Players[Player.Base.ClientID];
          // Inc(Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded);
          Servers[Player.ChannelIndex].CastleSiegeHandler.SendHoldingOrbPacket
            (Player, Packet.Index);
        end;

      3373: // bandeira do marechal 3584 2805
        begin
          if (Servers[Player.ChannelIndex].CastleSiegeHandler.OrbsHolded < 3)
          then
          begin
            Player.SendClientMessage
              ('As orbes precisam ser ocupadas antes de iniciar o selo');
            Exit;
          end;

          if (Player.Character.GuildSlot > 0) then
          begin
            if (Guilds[Player.Character.GuildSlot].Index <>
              Guilds[Player.Character.GuildSlot].Ally.Leader) then
            begin
              Player.SendClientMessage
                ('Somente lider da aliança pode pegar a bandeira.');
              Exit;
            end;

            if (Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
              Player.Base.Character.CharIndex) then
            begin
              Player.SendClientMessage
                ('Somente lider da aliança pode pegar a bandeira.');
              Exit;
            end;

            Servers[Player.ChannelIndex].CastleSiegeHandler.SealHolder :=
              @Servers[Player.ChannelIndex].Players[Player.Base.ClientID];
            Servers[Player.ChannelIndex].CastleSiegeHandler.
              SealHoldingStart := Now;
            Servers[Player.ChannelIndex].CastleSiegeHandler.
              SealBeingHold := True;
            Servers[Player.ChannelIndex].CastleSiegeHandler.
              SendHoldingSeal(Player);
          end;
        end;
    end;

    Player.OpennedNPC := Packet.Index;
    Exit;
  end;
  // Writeln(Packet.Type1);
  // Writeln(Packet.Type2);

  case Packet.Type1 of

    47:
      begin
        Sair(Player);

        if not Player.InDungeon then
          Exit;

        DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].InstanceOnline := false;
        DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].Index := 0;
        DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].CreateTime := Now;
        DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].Party := nil;
        DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].DungeonID := 0;
        DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].Dificult := 0;
        ZeroMemory(@DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].Mobs,
          SizeOf(DungeonInstances[Servers[Player.ChannelIndex].Players
          [Player.Base.ClientID].DungeonInstanceID].Mobs));

        for I in Player.Party.Members do
        begin
          Servers[Player.ChannelIndex].Players[I].SendPlayerToSavedPosition;
          Servers[Player.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonID := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonIDDificult := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonInstanceID := 0;
          Servers[Player.ChannelIndex].Players[I].InDungeon := false;

          Servers[Player.ChannelIndex].Players[I].Base.RemoveAllDebuffs;
          Servers[Player.ChannelIndex].Players[I].Base.ResolutoPoints := 0;
          Servers[Player.ChannelIndex].Players[I].Base.SendCurrentHPMP;
          Servers[Player.ChannelIndex].Players[I].TavaEmDG := false;
          Servers[Player.ChannelIndex].Players[I].Base.ClearTargetList;
          Servers[Player.ChannelIndex].Players[I].Base.VisibleMobs.Clear;
          Servers[Player.ChannelIndex].Players[I].Base.VisibleNPCS.Clear;
          Servers[Player.ChannelIndex].Players[I].Base.VisiblePlayers.Clear;

          if (Servers[Player.ChannelIndex].Players[I].SavedPos.IsValid) then
            Servers[Player.ChannelIndex].Players[I].SendPlayerToSavedPosition
          else
            Servers[Player.ChannelIndex].Players[I].SendPlayerToCityPosition;

        end;

        Exit;
      end;

    59:
      begin

        if Packet.Index = 2706 then
        begin
          Player.Teleport(TPosition.Create(3404, 3760));
        end;

      end;

    60:
      begin

        if Packet.Index = 2130 then
        begin
          Player.Teleport(TPosition.Create(3504, 3604));
        end;

      end;

    38:
      begin
        var
          Buffer1: array of BYTE;
        SetLength(Buffer1, SizeOf(TChangeChannelPacket));

        // Filling the packet header (TPacketHeader)
        PPacket_F05(@Buffer1[0])^.Header.Size := SizeOf(TChangeChannelPacket);
        // Total packet size
        PPacket_F05(@Buffer1[0])^.Header.Key := 0;
        // Key, can be adjusted as needed
        PPacket_F05(@Buffer1[0])^.Header.ChkSum := 0;
        // Checksum, can be calculated
        PPacket_F05(@Buffer1[0])^.Header.Index := Player.Base.ClientID;
        // Client ID
        PPacket_F05(@Buffer1[0])^.Header.Code := $F05; // Packet code (0xF05)
        PPacket_F05(@Buffer1[0])^.Header.Time := 0; // Timestamp
        // PPacket_F05(@Buffer1[0])^.Header.Time := GetTickCount; // Timestamp (optional)

        if Player.Base.Character.Nation = 0 then
        begin
          Player.Disconnect();
          Exit;
        end;

        if Player.Base.Character.Nation = 1 then
        begin

          // Filling the packet data with the desired channel (0 in this case)
          PPacket_F05(@Buffer1[0])^.Info1 := 1 - 1; // Channel 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Channel type 0 (same as Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1, 11) then
          begin
          end;
        end;
        if Player.Base.Character.Nation = 2 then
        begin

          // Filling the packet data with the desired channel (0 in this case)
          PPacket_F05(@Buffer1[0])^.Info1 := 2 - 1; // Channel 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Channel type 0 (same as Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1, 12) then
          begin
          end;
        end;
        if Player.Base.Character.Nation = 3 then
        begin

          // Filling the packet data with the desired channel (0 in this case)
          PPacket_F05(@Buffer1[0])^.Info1 := 3 - 1; // Channel 0
          PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
          // Channel type 0 (same as Info1)

          if TPacketHandlers.ChangeChannel(Player, Buffer1, 13) then
          begin
          end;
        end;

        WriteLn('NPC do Agros');
        Sair(Player);
        Exit;
      end;
    $0:
      begin
        if (Player.OpennedNPC = 0) then
        begin
          Result := TNPCHandlers.ShowOptions(Player,
            Servers[Player.ChannelIndex].NPCS[Packet.Index]);
        end
        else
        begin
          Player.SendSignal(Player.Base.ClientID, $10F);
          Sair(Player);
          Result := True;
        end;
      end;
    $1: // falar com npc
      begin
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := Packet.Type1;
        Result := TNPCHandlers.SendTalk(Player, Packet.Index);
        Exit;
      end;
    $2: // quest
      begin
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := Packet.Type1;
        Result := TNPCHandlers.SendQuests(Player, Packet.Index, Packet.Type2);
        Exit;
      end;
    $4: // entrar no castelo
      begin
        Result := TNPCHandlers.EnterInCastle(Player, Packet.Index);
        Sair(Player);
        Exit;
      end;
    $5: // abre o npc
      Result := TNPCHandlers.ShowShop(Player, Servers[Player.ChannelIndex].NPCS
        [Packet.Index]);
    $6: // mostra skills do player
      Result := TNPCHandlers.ShowSkills(Player,
        Servers[Player.ChannelIndex].NPCS[Packet.Index]);
    $7:
      Player.SendStorage(STORAGE_TYPE_PLAYER);
    $8: // fecha o npc
      begin
        Sair(Player);
        Exit;
      end;
    12: // cadastrar no castelo
      begin
        Result := TNPCHandlers.SignInCastle(Player, Packet.Index);
        Sair(Player);
        Exit;
      end;
    $A: // abre o dialogo pra criar uma guild
      begin
        Sair(Player);
        Player.SendData(Player.Base.ClientID, $341, 0);
        Exit;
      end;
    $B: // abre o baú da guild
      begin
        if Player.Character.Base.GuildIndex <= 0 then
        begin
          Sair(Player);
          Exit;
        end;
        if (Guilds[Player.Character.GuildSlot].OpenChest(Player.Character.Index,
          Player.ChannelIndex) = false) then
        begin
          Sair(Player);
          Exit;
        end;
      end;
    $D:
      Player.SendStorage(STORAGE_TYPE_PRANS);
    $F:
      Result := TNPCHandlers.ShowBigorna(Player);
    $1F:
      Result := TNPCHandlers.ShowRepareItens(Player);
    $11:
      Result := TNPCHandlers.ShowEnchant(Player);
    $12:
      Result := TNPCHandlers.ShowChangeApp(Player);
    $13:
      Result := TNPCHandlers.ShowNivelament(Player);
    $14:
      begin
        Sair(Player);
        Result := TNPCHandlers.ShowChangeNation(Player);
        Exit;
      end;
    $15: // reenviar pro menu
      begin
        Player.OpennedNPC := Packet.Index;
        Player.OpennedOption := Packet.Type1;
        Result := TNPCHandlers.ShowOptions(Player,
          Servers[Player.ChannelIndex].NPCS[Packet.Index]);
        Exit;
      end;

    $16:
      begin
        TNPCHandlers.GetQuest(Player, Packet.Type2, Packet.Index);
        Sair(Player);
        Exit;
      end;
    $18:
      begin
        TNPCHandlers.FinishQuest(Player, Packet.Type2);
        Servers[Player.ChannelIndex].NPCS[Player.OpennedNPC].Base.SendCreateMob
          (SPAWN_NORMAL, Player.Base.ClientID, false);
        Sair(Player);
        Exit;
      end;
    $19:
      begin
        Sair(Player);
        TNPCHandlers.SaveLocation(Player, Packet.Index);
        Exit;
      end;
    $1A:
      Result := TNPCHandlers.ShowDungeonDialog(Player);
    $20:
      begin
        Result := TNPCHandlers.ShowRepareAllItens(Player);
      end;
    $21:
      Result := TNPCHandlers.ShowDesmontItem(Player);
    $10:
      Result := TNPCHandlers.ShowReinforce(Player);
    $23:
      begin
        Sair(Player);
        TNPCHandlers.LilolaBuff(Player, Packet.Index);
        Exit;
      end;

    $30:
      Result := TNPCHandlers.ShowActionHouse(Player);
    $2C:
      Result := TNPCHandlers.ShowMountEnchant(Player);
    $3E:
      Result := TNPCHandlers.ShowPranEnchant(Player);
    $41:
      begin
        if (Player.Base.Character.Gold < VALOR_LILOLA) then
        begin
          Player.SendClientMessage('Você não possui gold suficiente.',
            16, 16, 16);
          Sair(Player);
          Exit;
        end
        else
        begin
          Player.DecGold(VALOR_LILOLA);
          Player.Base.AddBuff(6498, True);
          Player.Base.AddBuff(6499, True);
          Player.Base.AddBuff(206, True, false, 3000);
          Player.Base.AddBuff(268, True, false, 3000);
          Player.Base.AddBuff(345, True, false, 3000);
          Player.Base.AddBuff(5160, True, false, 3000);
          Player.Base.AddBuff(5189, True, false, 3000);
          Player.SendClientMessage('Você gastou ' + Copy(IntToStr(VALOR_LILOLA),
            1, 2) + 'k de golds para obter a benção paga!', 16, 16, 16);
          Result := True;
          Sair(Player);
          Exit;
        end;
      end;
    52: // Teleportar Leopold
      begin

        TPacketHandlers.TeleportLeopold(Player);
        Sair(Player);
        Result := True;
        Exit;


      end;
    // criar teleportes 1
    67: // karena   ursula
      begin // (3087 3621 ursula) (393, 2180 karena)
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Proíbido o acesso com relíquia!');
          Sair(Player);
          Exit;
        end;
        Player.Teleport(TPosition.Create(3087, 3621));
        Sair(Player);
        Exit;
      end;

    68: // deskeroa basilan
      begin // (1635 2218 basilan)     (1893, 3787  deskeroa)
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Proíbido o acesso com relíquia!');
          Sair(Player);
          Exit;
        end;

        if (Player.Base.Character.Gold >= 2500) then
        begin
          Player.DecGold(2500);
          Player.Teleport(TPosition.Create(1635, 2218));
        end;

        Sair(Player);
        Exit;
      end;

    69: // regenchain
      begin // 3399, 564
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Proíbido o acesso com relíquia!');
          Sair(Player);
          Exit;
        end;
        Player.Teleport(TPosition.Create(3399, 564));
        Sair(Player);
        Exit;
      end;

    70:
      begin // Desfazer aliança
        Sair(Player);

        if (Player.Character.GuildSlot = 0) then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        with Guilds[Player.Character.GuildSlot] do
        begin
          if (GuildLeaderCharIndex <> Player.Base.Character.CharIndex) then
          begin
            Player.SendClientMessage('Você não é o líder da sua guilda.');
            Exit;
          end;

          if (GetAllyGuildCount <= 1) then
          begin
            Player.SendClientMessage('A aliança atual não pode ser desfeita.');
            Exit;
          end;

          if (Index <> Ally.Leader) then
          begin
            Player.SendClientMessage
              ('Somente o líder da aliança pode desfazê-la.');
            Exit;
          end;
        end;

        TNPCHandlers.DestroyAlliance(Player);
        Exit;

      end;
    71: // 'Remover aliado 01
      begin
        Sair(Player);

        if Player.Character.GuildSlot = 0 then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex then
        begin
          Player.SendClientMessage('Você não é o líder da sua guilda.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1 then
        begin
          Player.SendClientMessage
            ('O aliado selecionado não pode ser removido.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].Ally.Guilds[1].Index = 0 then
        begin
          Player.SendClientMessage('O aliado 02 não existe para ser removido.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].Index <>
          Guilds[Player.Character.GuildSlot].Ally.Leader then
        begin
          Player.SendClientMessage
            ('Somente o líder da aliança pode retirar um aliado.');
          Exit;
        end;

        TNPCHandlers.RemoveMemberAlliance(Player, 1);
        Exit;
      end;
    72: // Remover aliado 02
      begin
        Sair(Player);

        if Player.Character.GuildSlot = 0 then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex then
        begin
          Player.SendClientMessage('Você não é o líder da sua guilda.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1 then
        begin
          Player.SendClientMessage
            ('O aliado selecionado não pode ser removido.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].Ally.Guilds[2].Index = 0 then
        begin
          Player.SendClientMessage('O aliado 02 não existe para ser removido.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].Index <>
          Guilds[Player.Character.GuildSlot].Ally.Leader then
        begin
          Player.SendClientMessage
            ('Somente o líder da aliança pode retirar um aliado.');
          Exit;
        end;

        TNPCHandlers.RemoveMemberAlliance(Player, 2);
        Exit;
      end;
    73: // Remover aliado 03
      begin
        Sair(Player);

        if (Player.Character.GuildSlot = 0) then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        with Guilds[Player.Character.GuildSlot] do
        begin
          if (GuildLeaderCharIndex <> Player.Base.Character.CharIndex) then
          begin
            Player.SendClientMessage('Você não é o lider da sua guilda.');
            Exit;
          end;

          if (GetAllyGuildCount <= 1) then
          begin
            Player.SendClientMessage
              ('O aliado selecionado não pode ser removido.');
            Exit;
          end;

          if (Ally.Guilds[3].Index = 0) then
          begin
            Player.SendClientMessage
              ('O aliado 03 não existe para ser removido.');
            Exit;
          end;

          if (Index <> Ally.Leader) then
          begin
            Player.SendClientMessage
              ('Somente o lider da aliança pode retirar um aliado.');
            Exit;
          end;
        end;

        TNPCHandlers.RemoveMemberAlliance(Player, 3);
        Exit;

      end;
    74: // Sair da aliança
      begin
        Sair(Player);

        if Player.Character.GuildSlot = 0 then
        begin
          Player.SendClientMessage('Você não está em uma guilda.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
          Player.Base.Character.CharIndex then
        begin
          Player.SendClientMessage('Você não é o líder da sua guilda.');
          Exit;
        end;

        if Guilds[Player.Character.GuildSlot].GetAllyGuildCount <= 1 then
        begin
          Player.SendClientMessage('Você não pode sair da sua aliança');
          Exit;
        end;

        TNPCHandlers.ExitAlliance(Player);
        Exit;

      end;
    75: // voltar para regenchain
      begin
        if Player.Base.InClastleVerus then
        begin
          Player.Teleport(TPosition.Create(3399, 564));
        end;

        Player.Base.InClastleVerus := false;

        Sair(Player);
        Exit;
      end;

    76: // [Defesa] Torre 01
      begin // 3584 2848
        Player.SendSignal(Player.Base.ClientID, $10F);

        if Player.Character.GuildSlot > 0 then
        begin
          if (Guilds[Player.Character.GuildSlot].Index
            in [Nations[Player.Base.Character.Nation - 1].MarechalGuildID,
            Nations[Player.Base.Character.Nation - 1].TacticianGuildID,
            Nations[Player.Base.Character.Nation - 1].JudgeGuildID,
            Nations[Player.Base.Character.Nation - 1].TreasurerGuildID]) then
          begin
            if Player.Base.InClastleVerus then
              Player.Teleport(TPosition.Create(3584, 2848));
          end;
        end;

        Sair(Player);
        Exit;

      end;
    77: // [Defesa] Torre 02
      begin // 3558 2769
        Player.SendSignal(Player.Base.ClientID, $10F);

        if (Player.Character.GuildSlot > 0) then
        begin
          if (Guilds[Player.Character.GuildSlot].Index
            in [Nations[Player.Base.Character.Nation - 1].MarechalGuildID,
            Nations[Player.Base.Character.Nation - 1].TacticianGuildID,
            Nations[Player.Base.Character.Nation - 1].JudgeGuildID,
            Nations[Player.Base.Character.Nation - 1].TreasurerGuildID]) then
          begin
            if (Player.Base.InClastleVerus) then
              Player.Teleport(TPosition.Create(3558, 2769));
          end;
        end;

        Sair(Player);
        Exit;
      end;
    78: // [Defesa] Torre 03
      begin // 3608 2771
        Player.SendSignal(Player.Base.ClientID, $10F);

        if (Player.Character.GuildSlot > 0) then
        begin
          if (Guilds[Player.Character.GuildSlot].Index
            in [Nations[Player.Base.Character.Nation - 1].MarechalGuildID,
            Nations[Player.Base.Character.Nation - 1].TacticianGuildID,
            Nations[Player.Base.Character.Nation - 1].JudgeGuildID,
            Nations[Player.Base.Character.Nation - 1].TreasurerGuildID]) then
          begin
            if (Player.Base.InClastleVerus) then
            begin
              Player.Teleport(TPosition.Create(3608, 2771));
            end;
          end;
        end;
        Exit;
      end;

    79: // Teleportar Leopold
      begin
        TPacketHandlers.TeleportLeopold(Player);
        Sair(Player);
        Result := True;
        Exit;
      end;
    83: // Lakia
      begin
        TPacketHandlers.TeleportLakia(Player);
        Sair(Player);
        Result := True;
        Exit;
      end;

    84: // Karena 649, 1585
      // leopold para karena 1394 2712
      // npc 2054
      begin
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Proíbido o acesso com relíquia!');
          Sair(Player);
          Exit;
        end;
        if (Player.ChannelIndex = 3) then
        begin

          begin // 393, 2180
            Player.Teleport(TPosition.Create(649, 1585));
            Sair(Player);
            Exit;
          end;

        end;

      end;

    80: // Escada Leopold
      // npc 2297

      begin // 1397 1684
        if (Player.ChannelIndex = 3) then
        begin

          begin // 1397, 1684
            Player.Teleport(TPosition.Create(1397, 1684));

            Sair(Player);
            Exit;
          end;

        end;

      end;

    81: // entrada Caverna Hekla
      begin // 3439 2227 npc 2087
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Proíbido o acesso com relíquia!');
          Sair(Player);
          Exit;
        end;

        Player.Teleport(TPosition.Create(3092, 3447));
        Sair(Player);
        Exit;

      end;

    82: // Saida Caverna Hekla
      begin // npc 2086
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Proíbido o acesso com relíquia!');
          Sair(Player);
          Exit;
        end;

        Player.Teleport(TPosition.Create(3438, 2227));
        Sair(Player);
        Exit;

      end;
    87: // karak aereo

      begin
        ReliqSlot := TItemFunctions.GetItemReliquareSlot(Player);
        if (ReliqSlot <> 255) then
        begin
          Player.SendClientMessage('Proíbido o acesso com relíquia!');
          Sair(Player);
          Exit;
        end;

        var
          k: Integer;
        var
          ClientID: Integer;
        var
          Len: Integer;
        var
          Buffer2: ARRAY OF BYTE;
          // Zera o conteúdo do buffer
        ZeroMemory(@Buffer2, SizeOf(Buffer2));

        // Definir o tamanho do buffer baseado no tamanho do pacote TKarakAereo
        SetLength(Buffer2, SizeOf(TKarakAereo)); // Tamanho total do pacote

        // Preenche o cabeçalho do pacote
        PPacket_0308(@Buffer2[0])^.Header.Size := $10; // 10 00 00 00
        PPacket_0308(@Buffer2[0])^.Header.Key := 0; // 00 00
        PPacket_0308(@Buffer2[0])^.Header.ChkSum := 0; // 00 00
        PPacket_0308(@Buffer2[0])^.Header.Index := 0; // 00 00 00 00
        PPacket_0308(@Buffer2[0])^.Header.Code := $0308; // 08 03
        PPacket_0308(@Buffer2[0])^.Header.Time := 0; // 00 00 00 00

        // Define os valores de Type para alcançar o resultado desejado
        PPacket_0308(@Buffer2[0])^.Type1 := $3B; // 60 SEGUNDOS
        PPacket_0308(@Buffer2[0])^.Type2 := $00; // 00 (valor fixado)
        PPacket_0308(@Buffer2[0])^.Type3 := $00; // 00 (valor fixado)
        PPacket_0308(@Buffer2[0])^.Type4 := $00; // 00 (valor fixado)

        // Define o tamanho do buffer (Len) com o tamanho da estrutura preenchida
        Len := SizeOf(TKarakAereo);
        // Usando SizeOf para obter o tamanho correto em bytes

        // Dump do conteúdo do buffer em formato hexadecima

        if TPacketHandlers.KarakAereo(Player, Buffer2) then
        begin
          // Player.SendClientMessage('Aguardando Karak Aereo', 16, 16, 16);
        end;

        // Mensagem ao jogador
        Sair(Player);

        // Finaliza a execução do código
        Exit;
      end;

          88: // Teleportar Leopold
      begin

        TPacketHandlers.TeleportOutValhalla(Player);
        Sair(Player);
        Result := True;
        Exit;


      end;

  else
    begin
      Player.SendSignal(Player.Base.ClientID, $10F);
      Sair(Player);
      Exit;
    end;
  end;
  Player.OpennedNPC := Packet.Index;
  Player.OpennedOption := Packet.Type1;
end;

class function TPacketHandlers.CloseNPCOption(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := false;
  if (Packet.Data = 0) or (Player.OpennedNPC < 2048) then
  begin
    Sair(Player);
    Exit;
  end;

  Sair(Player);
  case Player.OpennedDevir of
    0 .. 4:
      begin
        // Writeln('era pra ter fechado o devir');
        Servers[Player.ChannelIndex].Devires[Player.OpennedDevir]
          .PlayerIndexGettingReliq := 0;
        Player.OpennedDevir := 255;
        Player.OpennedTemple := 255;
      end;
  end;

  if (Packet.Data >= 3370) and (Packet.Data <= 3372) and
    (Player.OpennedNPC = Packet.Data) then
  begin
    Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder
      [3370 - Packet.Data] := nil;
  end;

  Result := True;
end;

class function TPacketHandlers.BuyNPCItens(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TBuyNPCItemPacket absolute Buffer;
  BuyItem: TItem;
  PriceItem: TItemPrice;
  AuxSlot, AuxSlotItem: BYTE;
begin
  Result := false;

  if (Packet.Index < 2048) or (Packet.Index > 3047) then
    Exit;

  if (Packet.Index = 2296) and not Player.IsAuxilyUser then
  begin
    Player.SendClientMessage('-> PLAYER PREMIUM [LAN] EXPIRADO <-', 16, 16, 16);
    Exit;
  end;

  if (Player.OpennedNPC <> Packet.Index) or
    ((Packet.Index >= 3335) and (Packet.Index <= 3339)) then
    Exit;

  BuyItem := Servers[Player.ChannelIndex].NPCS[Packet.Index].Character.Inventory
    [Packet.Slot];
  if (BuyItem.Index = 0) or (Packet.Quantidade = 0) then
    Exit;

  if TItemFunctions.GetInvAvailableSlots(Player) = 0 then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  if TItemFunctions.GetBuyItemPrice(BuyItem, PriceItem, Packet.Quantidade) then
  begin
    if (BuyItem.Index = 4204) then
      PriceItem.PriceType := PRICE_MEDAL;

    if (Player.OpennedNPC = 2296) and not Player.IsAuxilyUser then
    begin
      Player.SendClientMessage('-> PLAYER PREMIUM [LAN] EXPIRADO <-',
        16, 16, 16);
      Exit;
    end;

    case PriceItem.PriceType of
      PRICE_HONOR:
        begin
          if Player.Character.Base.CurrentScore.Honor < PriceItem.Value1 then
            Exit;
          DecCardinal(Player.Character.Base.CurrentScore.Honor,
            PriceItem.Value1);
          BuyItem.APP := BuyItem.Index;
          BuyItem.Refi := Packet.Quantidade;
          if (TItemFunctions.GetItemEquipSlot(BuyItem.Index) = 0) then
            TItemFunctions.PutItem(Player, BuyItem)
          else
            TItemFunctions.PutEquipament(Player, BuyItem.Index);
        end;
      PRICE_MEDAL:
        begin
          if Player.Character.Base.CurrentScore.Honor < PriceItem.Value1 then
            Exit;
          if PriceItem.Value2 > 0 then
          begin
            AuxSlot := TItemFunctions.GetItemSlot2(Player, 4204);
            if (AuxSlot = 255) or (Player.Base.Character.Inventory[AuxSlot].Refi
              < PriceItem.Value2) then
              Exit;
            TItemFunctions.DecreaseAmount(@Player.Base.Character.Inventory
              [AuxSlot], PriceItem.Value2);
            Player.Base.SendRefreshItemSlot(AuxSlot, false);
          end;
          DecCardinal(Player.Character.Base.CurrentScore.Honor,
            PriceItem.Value1);
          Player.Base.SendRefreshKills;
          BuyItem.APP := BuyItem.Index;
          BuyItem.Refi := 1;
          if TItemFunctions.GetItemEquipSlot(BuyItem.Index) = 0 then
            TItemFunctions.PutItem(Player, BuyItem)
          else
            TItemFunctions.PutEquipament(Player, BuyItem.Index);
        end;
      PRICE_GOLD:
        begin
          if PriceItem.Value1 <= 1 then
            Exit;
          if PriceItem.Value1 > Player.Character.Base.Gold then
            Exit;
          Player.DecGold(PriceItem.Value1);
          BuyItem.Refi := Packet.Quantidade;
          BuyItem.APP := BuyItem.Index;
          AuxSlotItem := TItemFunctions.GetItemEquipSlot(BuyItem.Index);
          if (AuxSlotItem = 0) or (AuxSlotItem = 15) then
            TItemFunctions.PutItem(Player, BuyItem)
          else
            TItemFunctions.PutEquipament(Player, BuyItem.Index);
          Player.RefreshMoney;
        end;
      PRICE_ITEM:
        begin
          AuxSlot := TItemFunctions.GetItemSlot2(Player, PriceItem.Value1);
          if (AuxSlot = 255) or (Player.Base.Character.Inventory[AuxSlot].Refi <
            PriceItem.Value2) then
          begin
            Player.SendClientMessage
              ('Você não possui a quantidade de itens necessária.');
            Exit;
          end;

          TItemFunctions.DecreaseAmount(Player, AuxSlot, PriceItem.Value2);
          Player.Base.SendRefreshItemSlot(AuxSlot, false);

          BuyItem.Refi := Packet.Quantidade;
          BuyItem.APP := BuyItem.Index;
          AuxSlotItem := TItemFunctions.GetItemEquipSlot(BuyItem.Index);
          if (AuxSlotItem >= 1) and (AuxSlotItem <= 15) then
            TItemFunctions.PutEquipament(Player, BuyItem.Index)
          else
            TItemFunctions.PutItem(Player, BuyItem.Index, BuyItem.Refi);
        end;
    end;
  end;
  Result := True;
end;

class function TPacketHandlers.SellNPCItens(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSellNPCItemPacket absolute Buffer;
  Item: pItem;
  SellPrice, AuxPrice: Integer;
begin
  Result := false;

  // Verifica se o NPC correto está aberto
  if Packet.Index <> Player.OpennedNPC then
  begin
    Result := True;
    Player.SendClientMessage('NPC Não esta aberto.');
    Exit;
  end;

  Item := @Player.Character.Base.Inventory[Packet.Slot];

  // Verifica se o item pode ser agrupado
  if TItemFunctions.CanAgroup(Item^) then
  begin
    // Verifica se o item tem tempo (não pode ser vendido)
    if Item^.Time > 0 then
    begin
      Player.SendClientMessage('Esse item não pode ser vendido.');
      Exit;
    end;

    // Verifica se o preço de venda é zero ou menor
    if ItemList[Item.Index].SellPrince <= 0 then
    begin
      Player.SendClientMessage('Esse item não pode ser vendido.');
      Exit;
    end;

    // Verifica o tipo do item
    if ItemList[Item.Index].TypeItem = 7 then
    begin
      Player.SendClientMessage('Esse item não pode ser vendido.');
      Exit;
    end;

    // Calcula o preço de venda
    if ItemList[Item.Index].SellPrince < 5 then
    begin
      SellPrice := (ItemList[Item.Index].SellPrince * Item.Refi);
    end
    else
    begin
      case ItemList[Item.Index].ItemType of
        60, 61:
          SellPrice := ((ItemList[Item.Index].SellPrince div 4) * Item.Refi);
      else
        SellPrice := ((ItemList[Item.Index].SellPrince div 5) * Item.Refi);
      end;
    end;

    // Adiciona o ouro e limpa o item
    Player.AddGold(SellPrice);
    ZeroMemory(Item, SizeOf(TItem));
    Player.RefreshMoney;
    Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.Slot, Item^, false);
    Result := True;
    Exit;
  end
  else
  begin
    // Caso o item não seja agrupável
    if ((Packet.Index >= 3335) and (Packet.Index <= 3339)) then
    begin
      // Clicou nos NPCs para entregar relíquia
    end
    else
    begin
      // Verifica se o item tem tempo (não pode ser vendido)
      if Item^.Time > 0 then
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
        Exit;
      end;

      // Verifica se o preço de venda é zero ou menor
      if ItemList[Item.Index].SellPrince <= 0 then
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
        Exit;
      end;

      // Verifica se o tipo do item é 7
      if ItemList[Item.Index].TypeItem = 7 then
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
        Exit;
      end;

      // Verifica se o item pode ser vendido (TipoTrade = 0 e durabilidade > 0)
      if ItemList[Item.Index].TypeTrade = 0 then
      begin
        if ItemList[Item.Index].Durabilidade > 0 then
        begin
          SellPrice := (ItemList[Item.Index].SellPrince div 5);
          AuxPrice := Round((Item.MIN / Item.MAX) * SellPrice);
          Player.AddGold(AuxPrice);
          ZeroMemory(Item, SizeOf(TItem));
          Player.RefreshMoney;
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.Slot, Item^, false);
        end
        else
        begin
          Player.SendClientMessage('Item não agrupável para venda.');
        end;
      end
      else
      begin
        Player.SendClientMessage('Esse item não pode ser vendido.');
      end;
    end;
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'Inventory Item Functions'}

class function TPacketHandlers.DeleteItem(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TDeleteItemPacket absolute Buffer;
  Item: pItem;
begin
  Result := false;
  // Determinando a referência de Item com base no tipo de slot
  case Packet.TypeSlot of
    EQUIP_TYPE:
      Item := @Player.Character.Base.Equip[Packet.Slot];
    INV_TYPE:
      Item := @Player.Character.Base.Inventory[Packet.Slot];
    PRAN_INV_TYPE:
      begin
        case Player.SpawnedPran of
          0:
            Item := @Player.Account.Header.Pran1.Inventory[Packet.Slot];
          1:
            Item := @Player.Account.Header.Pran2.Inventory[Packet.Slot];
        else
          Exit;
        end;
      end;
  else
    Exit;
  end;

  if ItemList[Item.Index].ItemType = 10 then
    Exit;

  // Verificando se o item é do tipo relíquia
  if ItemList[Item.Index].ItemType = 40 then
  begin

    { Comentado, mas deixado para referência futura
      Servers[Player.ChannelIndex].CreateMapObject(@Player, 320, Item.Index);
      Servers[Player.ChannelIndex].SendServerMsg('O jogador ' +
      AnsiString(Player.Character.Base.Name) + ' dropou a relíquia <' +
      AnsiString(ItemList[Item.Index].Name) + '>.'); }

    ZeroMemory(Item, SizeOf(TItem));
    Player.Base.SendRefreshItemSlot(Packet.TypeSlot, Packet.Slot, Item^, false);
    Result := True;
    Exit;
  end;

  // Remover buff de experiência/quest double, se for o caso
  if ItemList[Item.Index].ItemType = 716 then
    Player.Base.RemoveBuff(ItemList[Item.Index].UseEffect);

  // Enviar mensagem ao cliente
  Player.SendClientMessage('O item [' + AnsiString(ItemList[Item.Index].Name) +
    '] foi deletado.', 0);

  // Limpar item e atualizar slot
  ZeroMemory(Item, SizeOf(TItem));
  Player.Base.SendRefreshItemSlot(Packet.TypeSlot, Packet.Slot, Item^, false);

  Result := True;
end;

class function TPacketHandlers.UngroupItem(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TUngroupItemPacket absolute Buffer;
  srcItem, destItem: pItem;
  Slot: BYTE;
begin
  Result := false;
  srcItem := nil;

  case Packet.SlotType of
    EQUIP_TYPE, STORAGE_TYPE, PRAN_EQUIP_TYPE:
      begin
        Result := True;
        Exit;
      end;

    INV_TYPE:
      begin
        srcItem := @Player.Character.Base.Inventory[Packet.Slot];
      end;

    PRAN_INV_TYPE:
      begin
        case Player.SpawnedPran of
          0:
            srcItem := @Player.Account.Header.Pran1.Inventory[Packet.Slot];
          1:
            srcItem := @Player.Account.Header.Pran2.Inventory[Packet.Slot];
        else
          begin
            Result := True;
            Exit;
          end;
        end;
      end;
  end;

  if (srcItem = nil) or ((Packet.Quantidade >= srcItem.Refi) or
    (ItemList[srcItem.Index].Expires)) then
    Exit;

  // Logica para mover o item
  if Packet.SlotType = PRAN_INV_TYPE then
  begin
    Slot := TItemFunctions.GetEmptyPranSlot(Player);
  end
  else
  begin
    Slot := TItemFunctions.GetEmptySlot(Player);
  end;

  if Slot = 255 then
  begin
    Player.SendClientMessage('Inventario cheio.');
    Exit;
  end;

  // Define o destino do item
  if Packet.SlotType = PRAN_INV_TYPE then
  begin
    if Player.SpawnedPran = 0 then
      destItem := @Player.Account.Header.Pran1.Inventory[Slot]
    else
      destItem := @Player.Account.Header.Pran2.Inventory[Slot];
  end
  else
  begin
    destItem := @Player.Character.Base.Inventory[Slot];
  end;

  Move(srcItem^, destItem^, SizeOf(TItem));
  TItemFunctions.SetItemAmount(destItem^, Packet.Quantidade);
  Dec(srcItem.Refi, Packet.Quantidade);

  // Envia o refresh dos slots
  Player.Base.SendRefreshItemSlot(Packet.SlotType, Packet.Slot,
    srcItem^, false);
  Player.Base.SendRefreshItemSlot(Packet.SlotType, Slot, destItem^, false);

  Result := True;
end;

class function TPacketHandlers.AgroupItem(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TAgroupItemPacket absolute Buffer;
  srcItem, destItem: pItem;
begin
  srcItem := @Player.Character.Base.Inventory[Packet.srcSlot];
  destItem := @Player.Character.Base.Inventory[Packet.destSlot];

  if (srcItem.Index = destItem.Index) then
  begin
    TItemFunctions.SetItemAmount(destItem^, srcItem.Refi, True);
    ZeroMemory(srcItem, SizeOf(TItem));
    Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.srcSlot, srcItem^, false);
    Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.destSlot,
      destItem^, false);
  end;

  Result := True;
end;

class function TPacketHandlers.MoveItem(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TMoveItemPacket absolute Buffer;
  Aux: TItem;
  ReSpawn, UpdatePoint, PranRespawn: boolean;
  TypeEquip, Helper, Helper2: Integer;
  destItem, srcItem: pItem;
  DestBag, SrcBag: Integer;
  Guild: PGuild;
  SpawnPran, UnspawnPran: BYTE;
begin
  Result := false;
  SrcBag := 0;
  DestBag := 0;
  SpawnPran := 255;
  UnspawnPran := 255;

if (Packet.SrcType = BAR_ITEM) or
   ((Packet.SrcType = EQUIP_TYPE) and (Packet.DestType <> INV_TYPE)) or
   ((Packet.DestType = EQUIP_TYPE) and (Packet.SrcType <> INV_TYPE)) or
   ((Packet.DestType = 3) and (Packet.SrcType = 6)) then
  Exit;

  TypeEquip := 0;
  ReSpawn := false;
  PranRespawn := false;
  UpdatePoint := false;
  srcItem := nil;
  destItem := nil;
  // WriteLn('source slot ' + packet.SrcSlot.tostring + ' destino slot ' + Packet.DestSlot.ToString );
  // WriteLn('source type ' + Packet.SrcType.ToString +  ' destino type ' + Packet.DestType.ToString +  '');

  case (Packet.SrcType) of
    INV_TYPE:
      begin
        SrcBag := 0;
        if (Packet.srcSlot < 120) then
        begin
          case Packet.srcSlot of
            0 .. 19:
              SrcBag := 120;
            20 .. 39:
              SrcBag := 121;
            40 .. 59:
              SrcBag := 122;
            60 .. 79:
              SrcBag := 123;
            80 .. 99:
              SrcBag := 124;
            100 .. 119:
              SrcBag := 125;
          end;
          if Player.Character.Base.Inventory[SrcBag].Index <= 0 then
            Exit;
          srcItem := @Player.Character.Base.Inventory[Packet.srcSlot];
        end
        else
          Exit;
      end;
    EQUIP_TYPE:
      begin
        if (Packet.srcSlot < 16) and (Packet.srcSlot > 1) then
        begin
          srcItem := @Player.Character.Base.Equip[Packet.srcSlot];
          TypeEquip := EQUIPING_TYPE;
          case Packet.srcSlot of
            2, 3, 4, 5, 6, 7, 8, 9:
              ReSpawn := True;
          else
            UpdatePoint := True;
          end;
        end
        else
          Exit;
      end;
    STORAGE_TYPE:
      begin
        // if not(Player.OpennedOption = 7) or not(Player.OpennedOption = 13)  or (Player.OpennedNPC <= 0) then
        // Exit;
        // Player.SendClientMessage('Sim passou');
        SrcBag := 0;
        if (Packet.srcSlot < 80) then
        begin
          case Packet.srcSlot of
            0 .. 19:
              SrcBag := 80;
            20 .. 39:
              SrcBag := 81;
            40 .. 59:
              SrcBag := 82;
            60 .. 79:
              SrcBag := 83;
          end;
          if Player.Account.Header.Storage.Itens[SrcBag].Index <= 0 then
            Exit;
          srcItem := @Player.Account.Header.Storage.Itens[Packet.srcSlot];
        end
        else
        begin
          if ((Packet.srcSlot = 84) or (Packet.srcSlot = 85)) then
          begin // central da pran pro inventário
            if (ItemList[Player.Account.Header.Storage.Itens[Packet.srcSlot].
              Index].ItemType = 10) then
            begin // o item movido pode ser apenas pran
              srcItem := @Player.Account.Header.Storage.Itens[Packet.srcSlot];
            end
            else
              Exit;
          end
          else
            Exit;
        end;
      end;
    GUILDCHEST_TYPE:
      begin
        if not(Player.OpennedOption = 11) or (Player.OpennedNPC <= 0) then
          Exit;
        if (Packet.srcSlot < 50) then
        begin
          if Player.Character.Base.GuildIndex <= 0 then
            Exit;
          Guild := @Guilds[Player.Character.GuildSlot];
          if Guild.MemberInChest <> Guild.FindMemberFromCharIndex
            (Player.Character.Index) then
            Exit;
          if Guild.GetRankConfig
            (Guild.Members[Guild.FindMemberFromCharIndex(Player.Character.Index)
            ].Rank).UseGWH = false then
          begin
            Player.SendClientMessage('Você não tem permissão para isso.');
            Exit;
          end;
          srcItem := @Guild.Chest.Items[Packet.srcSlot];
        end
        else
          Exit;
      end;
    PRAN_EQUIP_TYPE:
      begin
        if (Packet.srcSlot <= 5) and (Packet.srcSlot > 0) and
          not(Player.SpawnedPran = 255) then
        begin
          case Player.SpawnedPran of
            0:
              srcItem := @Player.Account.Header.Pran1.Equip[Packet.srcSlot];
            1:
              srcItem := @Player.Account.Header.Pran2.Equip[Packet.srcSlot];
          end;
          TypeEquip := EQUIPING_TYPE;
          PranRespawn := True;
        end
        else
          Exit;
      end;
    PRAN_INV_TYPE:
      begin
        if (Packet.srcSlot <= 39) and not(Player.SpawnedPran = 255) then
        begin
          case Player.SpawnedPran of
            0:
              begin
                case Packet.srcSlot of
                  0 .. 19:
                    SrcBag := 40;
                  20 .. 39:
                    SrcBag := 41;
                end;
                if (Player.Account.Header.Pran1.Inventory[SrcBag].Index = 0)
                then
                  Exit;
                srcItem := @Player.Account.Header.Pran1.Inventory
                  [Packet.srcSlot];
              end;
            1:
              begin
                case Packet.srcSlot of
                  0 .. 19:
                    SrcBag := 40;
                  20 .. 39:
                    SrcBag := 41;
                end;
                if (Player.Account.Header.Pran2.Inventory[SrcBag].Index = 0)
                then
                  Exit;
                srcItem := @Player.Account.Header.Pran2.Inventory
                  [Packet.srcSlot];
              end;
          end;
        end
        else
          Exit;
      end;
  end;
  case (Packet.DestType) of
    INV_TYPE:
      begin
        DestBag := 0;
        if (Packet.destSlot < 120) then
        begin
          case Packet.destSlot of
            0 .. 19:
              DestBag := 120;
            20 .. 39:
              DestBag := 121;
            40 .. 59:
              DestBag := 122;
            60 .. 79:
              DestBag := 123;
            80 .. 99:
              DestBag := 124;
            100 .. 119:
              DestBag := 125;
          end;
          if Player.Character.Base.Inventory[DestBag].Index <= 0 then
            Exit;
          destItem := @Player.Character.Base.Inventory[Packet.destSlot];
        end
        else
          Exit;
      end;
    EQUIP_TYPE:
      begin
        if (Packet.destSlot < 16) and (Packet.destSlot > 1) then
        begin
          destItem := @Player.Character.Base.Equip[Packet.destSlot];
          TypeEquip := DESEQUIPING_TYPE;
          case Packet.destSlot of
            2, 3, 4, 5, 6, 7, 8, 9:
              ReSpawn := True;
          else
            UpdatePoint := True;
          end;
        end
        else
          Exit;
      end;
    STORAGE_TYPE:
      begin
        if ((not(Player.OpennedOption = 7) and not(Player.OpennedOption = 13))
          or (Player.OpennedNPC <= 0)) then
          Exit;
        DestBag := 0;
        if (Packet.destSlot < 80) then
        begin
          case Packet.destSlot of
            0 .. 19:
              DestBag := 80;
            20 .. 39:
              DestBag := 81;
            40 .. 59:
              DestBag := 82;
            60 .. 79:
              DestBag := 83;
          end;
          if Player.Account.Header.Storage.Itens[DestBag].Index <= 0 then
            Exit;
          destItem := @Player.Account.Header.Storage.Itens[Packet.destSlot];
        end
        else
        begin
          if ((Packet.destSlot = 84) or (Packet.destSlot = 85)) then
          begin // inventário pra central pran
            if (ItemList[Player.Character.Base.Inventory[Packet.srcSlot].Index]
              .ItemType = 10) then
            begin // o item movido pode ser apenas pran
              destItem := @Player.Account.Header.Storage.Itens[Packet.destSlot];
            end
            else
              Exit;
          end
          else
            Exit;
        end;
      end;
    GUILDCHEST_TYPE:
      begin
        if not(Player.OpennedOption = 11) or (Player.OpennedNPC <= 0) then
          Exit;
        if (Packet.destSlot < 50) then
        begin
          if Player.Character.Base.GuildIndex <= 0 then
            Exit;
          Guild := @Guilds[Player.Character.GuildSlot];
          if Guild.MemberInChest <> Guild.FindMemberFromCharIndex
            (Player.Character.Index) then
            Exit;
          if Guild.GetRankConfig
            (Guild.Members[Guild.FindMemberFromCharIndex(Player.Character.Index)
            ].Rank).UseGWH = false then
          begin
            Player.SendClientMessage('Você não tem permissão para isso.');
            Exit;
          end;
          destItem := @Guild.Chest.Items[Packet.destSlot];
        end
        else
          Exit;
      end;
    PRAN_EQUIP_TYPE:
      begin
        if (Packet.destSlot <= 5) and (Packet.destSlot > 0) and
          not(Player.SpawnedPran = 255) then
        begin
          case Player.SpawnedPran of
            0:
              destItem := @Player.Account.Header.Pran1.Equip[Packet.destSlot];
            1:
              destItem := @Player.Account.Header.Pran2.Equip[Packet.destSlot];
          end;
          TypeEquip := DESEQUIPING_TYPE;
          PranRespawn := True;
        end
        else
          Exit;
      end;
    PRAN_INV_TYPE:
      begin
        if (Packet.destSlot <= 39) and not(Player.SpawnedPran = 255) then
        begin
          case Player.SpawnedPran of
            0:
              begin
                case Packet.destSlot of
                  0 .. 19:
                    DestBag := 40;
                  20 .. 39:
                    DestBag := 41;
                end;
                if (Player.Account.Header.Pran1.Inventory[DestBag].Index = 0)
                then
                  Exit;
                destItem := @Player.Account.Header.Pran1.Inventory
                  [Packet.destSlot];
              end;
            1:
              begin
                case Packet.destSlot of
                  0 .. 19:
                    DestBag := 40;
                  20 .. 39:
                    DestBag := 41;
                end;
                if (Player.Account.Header.Pran2.Inventory[DestBag].Index = 0)
                then
                  Exit;
                destItem := @Player.Account.Header.Pran2.Inventory
                  [Packet.destSlot];
              end;
          end;
        end
        else
          Exit;
      end;
  end;

  // Player.Base.SendRefreshItemSlot(Packet.destType, Packet.destSlot,
  // destItem^, False);
  // Player.Base.SendRefreshItemSlot(Packet.SrcType, Packet.srcSlot,
  // srcItem^, False);

  if ((Packet.SrcType = INV_TYPE) and (Packet.DestType = STORAGE_TYPE) and
    not(ItemList[Player.Character.Base.Inventory[Packet.srcSlot].Index]
    .ItemType = 10)) then
  begin
    if (srcItem^.Index > 0) and (ItemList[srcItem^.Index].TypeTrade = 1) then
      Exit;
    if (destItem^.Index > 0) and (ItemList[destItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = PRAN_INV_TYPE) then
  begin
    if (srcItem^.Index > 0) and (ItemList[srcItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  if (Packet.SrcType = PRAN_INV_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and (ItemList[destItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  // 02 / 01 / 2025 foi removido isso aqui tava bloqueando pran de equipar
  // if (Packet.SrcType = PRAN_INV_TYPE) and (Packet.DestType = PRAN_EQUIP_TYPE)
  // then
  // begin
  // Writeln('acessei aqui 1');
  // Exit;
  // end;
  // if (Packet.SrcType = PRAN_EQUIP_TYPE) and (Packet.DestType = PRAN_INV_TYPE)
  // then
  // begin
  // Writeln('acessei aqui 2');
  // Exit;
  // end;
  // if ((Packet.DestType = PRAN_EQUIP_TYPE) and (Packet.SrcType = PRAN_EQUIP_TYPE))
  // then
  // begin
  // Writeln('acessei aqui 3');
  // Exit;
  // end;

  // if((ItemList[destItem.Index].ItemType = 8) and
  // (ItemList[srcItem.Index].ItemType = 8)) then
  // Exit;

  if ((ItemList[destItem.Index].ItemType in [50, 52]) and
    (Packet.SrcType = EQUIP_TYPE) and (srcItem.Index > 0)) then
  begin
    if (ItemList[destItem.Index].Rank <> ItemList[srcItem.Index].Rank) then
      Exit;
  end;

  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = PRAN_EQUIP_TYPE) then
  begin
    if (TItemFunctions.GetItemEquipPranSlot(srcItem.Index) <> Packet.destSlot)
    then
      Exit;
    case Player.SpawnedPran of
      0:
        begin
          if (ItemList[srcItem.Index].Level > (Player.Account.Header.Pran1.Level
            + 1)) then
            Exit;
          if (Player.GetPranClassStoneItem
            (Player.Account.Header.Pran1.ClassPran) <> ItemList[srcItem.Index]
            .Classe) then
          begin
            if (ItemList[srcItem.Index].Classe > 0) then
              Exit;
          end;
        end;
      1:
        begin
          if (ItemList[srcItem.Index].Level > (Player.Account.Header.Pran2.Level
            + 1)) then
            Exit;
          if (Player.GetPranClassStoneItem
            (Player.Account.Header.Pran2.ClassPran) <> ItemList[srcItem.Index]
            .Classe) then
          begin
            if (ItemList[srcItem.Index].Classe > 0) then
              Exit;
          end;
        end;
    end;
  end;
  if (Packet.SrcType = PRAN_EQUIP_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and
      (TItemFunctions.GetItemEquipPranSlot(destItem.Index) <> Packet.destSlot)
    then
      Exit;
    if (destItem.Index > 0) then
      case Player.SpawnedPran of
        0:
          begin
            if (ItemList[destItem.Index].Level >
              (Player.Account.Header.Pran1.Level + 1)) then
              Exit;
            if (Player.GetPranClassStoneItem
              (Player.Account.Header.Pran1.ClassPran) <> ItemList[destItem.
              Index].Classe) then
            begin
              if (ItemList[destItem.Index].Classe > 0) then
                Exit;
            end;
          end;
        1:
          begin
            if (ItemList[destItem.Index].Level >
              (Player.Account.Header.Pran2.Level + 1)) then
              Exit;
            if (Player.GetPranClassStoneItem
              (Player.Account.Header.Pran2.ClassPran) <> ItemList[destItem.
              Index].Classe) then
            begin
              if (ItemList[destItem.Index].Classe > 0) then
                Exit;
            end;
          end;
      end;
  end;
  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = GUILDCHEST_TYPE) then
  begin
    if (srcItem^.Index > 0) and not(ItemList[srcItem^.Index].TypeTrade = 0) then
      Exit;
    if (destItem^.Index > 0) and not(ItemList[destItem^.Index].TypeTrade = 0)
    then
      Exit;
  end;
  if (Packet.SrcType = STORAGE_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and (ItemList[destItem^.Index].TypeTrade = 1) then
      Exit;
  end;
  if (Packet.SrcType = GUILDCHEST_TYPE) and (Packet.DestType = INV_TYPE) then
  begin
    if (destItem^.Index > 0) and not(ItemList[destItem^.Index].TypeTrade = 0)
    then
      Exit;
  end;
  if (Packet.SrcType = INV_TYPE) and (Packet.DestType = EQUIP_TYPE) then
  begin // do inventário para o equip
    if (TItemFunctions.GetItemEquipSlot(srcItem^.Index) <> Packet.destSlot) then
      Exit;

    var
      itemlevel, Level: Integer;

    Level := 0;

    case srcItem^.Refi of
      1:
        Level := 1;
      2:
        Level := 2;
      3:
        Level := 3;
      4:
        Level := 4;
      5:
        Level := 5;
      6:
        Level := 6;
      7:
        Level := 7;
      8:
        Level := 8;
      9:
        Level := 9;
      10:
        Level := 10;
      11:
        Level := 11;
      12:
        Level := 12;
      13:
        Level := 13;
      14:
        Level := 14;
      15:
        Level := 15;
      17:
        Level := 1;
      18:
        Level := 2;
      19:
        Level := 3;
      20:
        Level := 4;
      21:
        Level := 5;
      22:
        Level := 6;
      23:
        Level := 7;
      24:
        Level := 8;
      25:
        Level := 9;
      26:
        Level := 10;
      27:
        Level := 11;
      28:
        Level := 12;
      29:
        Level := 13;
      30:
        Level := 14;
      31:
        Level := 15;
      33:
        Level := 1;
      34:
        Level := 2;
      35:
        Level := 3;
      36:
        Level := 4;
      37:
        Level := 5;
      38:
        Level := 6;
      39:
        Level := 7;
      40:
        Level := 8;
      41:
        Level := 9;
      42:
        Level := 10;
      43:
        Level := 11;
      44:
        Level := 12;
      45:
        Level := 13;
      46:
        Level := 14;
      47:
        Level := 15;
      49:
        Level := 1;
      50:
        Level := 2;
      51:
        Level := 3;
      52:
        Level := 4;
      53:
        Level := 5;
      54:
        Level := 6;
      55:
        Level := 7;
      57:
        Level := 8;
      58:
        Level := 9;
      59:
        Level := 10;
      60:
        Level := 11;
      61:
        Level := 12;
      62:
        Level := 13;
      63:
        Level := 14;
      65:
        Level := 15;
      66:
        Level := 1;
      67:
        Level := 2;
      68:
        Level := 3;
      69:
        Level := 4;
      70:
        Level := 5;
      71:
        Level := 6;
      72:
        Level := 7;
      73:
        Level := 8;
      74:
        Level := 9;
      75:
        Level := 10;
      76:
        Level := 11;
      77:
        Level := 12;
      78:
        Level := 13;
      79:
        Level := 14;
      80:
        Level := 15;
      81:
        Level := 1;
      82:
        Level := 2;
      83:
        Level := 3;
      84:
        Level := 4;
      85:
        Level := 5;
      86:
        Level := 6;
      87:
        Level := 7;
      88:
        Level := 8;
      89:
        Level := 9;
      90:
        Level := 10;
      91:
        Level := 11;
      92:
        Level := 12;
      93:
        Level := 13;
      94:
        Level := 14;
      95:
        Level := 15;
      97:
        Level := 1;
      98:
        Level := 2;
      99:
        Level := 3;
      100:
        Level := 4;
      101:
        Level := 5;
      102:
        Level := 6;
      103:
        Level := 7;
      104:
        Level := 8;
      105:
        Level := 9;
      106:
        Level := 10;
      107:
        Level := 11;
      108:
        Level := 12;
      109:
        Level := 13;
      110:
        Level := 14;
      111:
        Level := 15;
      113:
        Level := 1;
      114:
        Level := 2;
      115:
        Level := 3;
      116:
        Level := 4;
      117:
        Level := 5;
      118:
        Level := 6;
      119:
        Level := 7;
      120:
        Level := 8;
      121:
        Level := 9;
      122:
        Level := 10;
      123:
        Level := 11;
      124:
        Level := 12;
      125:
        Level := 13;
      126:
        Level := 14;
      127:
        Level := 15;
      129:
        Level := 1;
      130:
        Level := 2;
      131:
        Level := 3;
      132:
        Level := 4;
      133:
        Level := 5;
      134:
        Level := 6;
      135:
        Level := 7;
      136:
        Level := 8;
      137:
        Level := 9;
      138:
        Level := 10;
      139:
        Level := 11;
      140:
        Level := 12;
      141:
        Level := 13;
      142:
        Level := 14;
      143:
        Level := 15;
      145:
        Level := 1;
      146:
        Level := 2;
      147:
        Level := 3;
      148:
        Level := 4;
      149:
        Level := 5;
      150:
        Level := 6;
      151:
        Level := 7;
      152:
        Level := 8;
      153:
        Level := 9;
      154:
        Level := 10;
      155:
        Level := 11;
      156:
        Level := 12;
      157:
        Level := 13;
      158:
        Level := 14;
      159:
        Level := 15;
      161:
        Level := 1;
      162:
        Level := 2;
      163:
        Level := 3;
      164:
        Level := 4;
      165:
        Level := 5;
      166:
        Level := 6;
      167:
        Level := 7;
      168:
        Level := 8;
      169:
        Level := 9;
      170:
        Level := 10;
      171:
        Level := 11;
      172:
        Level := 12;
      173:
        Level := 13;
      174:
        Level := 14;
      175:
        Level := 15;
      177:
        Level := 1;
      178:
        Level := 2;
      179:
        Level := 3;
      180:
        Level := 4;
      181:
        Level := 5;
      182:
        Level := 6;
      183:
        Level := 7;
      184:
        Level := 8;
      185:
        Level := 9;
      186:
        Level := 10;
      187:
        Level := 11;
      188:
        Level := 12;
      189:
        Level := 13;
      190:
        Level := 14;
      191:
        Level := 15;
      193:
        Level := 1;
      194:
        Level := 2;
      195:
        Level := 3;
      196:
        Level := 4;
      197:
        Level := 5;
      198:
        Level := 6;
      199:
        Level := 7;
      200:
        Level := 8;
      201:
        Level := 9;
      202:
        Level := 10;
      203:
        Level := 11;
      204:
        Level := 12;
      205:
        Level := 13;
      206:
        Level := 14;
      207:
        Level := 15;
      209:
        Level := 1;
      210:
        Level := 2;
      211:
        Level := 3;
      212:
        Level := 4;
      213:
        Level := 5;
      214:
        Level := 6;
      215:
        Level := 7;
      216:
        Level := 8;
      217:
        Level := 9;
      218:
        Level := 10;
      219:
        Level := 11;
      220:
        Level := 12;
      221:
        Level := 13;
      222:
        Level := 14;
      223:
        Level := 15;
      225:
        Level := 1;
      226:
        Level := 2;
      227:
        Level := 3;
      228:
        Level := 4;
      229:
        Level := 5;
      230:
        Level := 6;
      231:
        Level := 7;
      232:
        Level := 8;
      233:
        Level := 9;
      234:
        Level := 10;
      235:
        Level := 11;
      236:
        Level := 12;
      237:
        Level := 13;
      238:
        Level := 14;
      239:
        Level := 15;
      241:
        Level := 1;
      242:
        Level := 2;
      243:
        Level := 3;
      244:
        Level := 4;
      245:
        Level := 5;
      246:
        Level := 6;
      247:
        Level := 7;
      248:
        Level := 8;
      249:
        Level := 9;
      250:
        Level := 10;
      251:
        Level := 11;
      252:
        Level := 12;
      253:
        Level := 13;
      254:
        Level := 14;
      255:
        Level := 15;

    end;

    if srcItem^.Refi >= 16 then
    begin
      itemlevel := ItemList[srcItem^.Index].Level - Level;
      if Player.Base.Character.Level < itemlevel then
      begin
        Player.SendClientMessage('Fora do nível específicado.');
        Exit;
      end;
    end
    else
    begin
      if Player.Base.Character.Level < ItemList[srcItem^.Index].Level then
      begin
        Player.SendClientMessage('Fora do nível específicado.');
        Exit;
      end;
    end;



    //
    // if srcItem^.Refi >= 16 then
    // encantamento := srcItem^.Refi div 16
    // else
    // encantamento := 0;
    //
    // // Calcula o nivelamento
    // if srcItem^.Refi >= 16 then
    // nivelamento := (srcItem^.Refi div 16) + 15 - 1
    // else
    // nivelamento := 0;
    //
    // // Ajusta o nível do item
    // itemLevel := ItemList[srcItem^.Index].Level - nivelamento;

    // Verifica se o nível do jogador é compatível com o nível ajustado do item



    // Calcula o nível de refinamento
    // var refineLevel := srcItem^.Refi div 16; // +1, +2, etc.
    //
    // // Ajusta o nível do item com base no refinamento
    // var itemLevel := ItemList[srcItem^.Index].Level - (refineLevel - 1);
    //
    // if srcItem^.Refi > 1 then
    // begin
    // if (Player.Base.character.Level < itemLevel) and (Player.Base.character.Level < ItemList[srcItem^.Index].Level) then
    // begin
    // Player.SendClientMessage('Você não pode equipar este item. Nível muito baixo após ajuste de refinamento.');
    // Exit;
    // end
    // end
    // else
    // begin
    // if (Player.Base.character.Level < ItemList[srcItem^.Index].Level) then
    // begin
    // Player.SendClientMessage('Nível muito baixo');
    // Exit;
    // end
    // end;



    // mexer nivelamento
    // if ItemList[srcItem^.Index].Level > 99 then
    // Exit;

    // if (Player.Character.Base.Level < ItemList[srcItem^.Index].Level) then
    // Exit;

    if (ItemList[srcItem^.Index].ItemType = 10) then
    begin // movendo pran do inventário pro equip, mandar sendtoworld e spawn
      if (Player.Account.Header.Pran1.ItemId = srcItem^.Identific) then
      begin
        SpawnPran := 0;
      end
      else if (Player.Account.Header.Pran2.ItemId = srcItem^.Identific) then
      begin
        SpawnPran := 1;
      end;
      if (destItem^.Index > 0) then
      begin
        if (Player.Account.Header.Pran1.ItemId = destItem^.Identific) then
        begin
          UnspawnPran := 0;
        end
        else if (Player.Account.Header.Pran2.ItemId = destItem^.Identific) then
        begin
          UnspawnPran := 1;
        end;
      end;
    end
    else
    begin
      if (Player.Base.GetMobClass() <> Player.Base.GetMobClass
        (ItemList[srcItem^.Index].Classe)) and
        ((ItemList[srcItem^.Index].ItemType <> 1019) or
        (ItemList[srcItem^.Index].ItemType <> 103)) then
      begin
        Exit;
      end;
    end;

  end;
  if (Packet.SrcType = EQUIP_TYPE) and (Packet.DestType = INV_TYPE) then
  begin // do equip para o inventario
    if (destItem^.Index > 0) then
    begin
      if (TItemFunctions.GetItemEquipSlot(destItem^.Index) <> Packet.srcSlot)
      then
        Exit;
      if (Player.Character.Base.Level < ItemList[destItem^.Index].Level) then
        Exit;
      if (Player.Base.GetMobClass() <> Player.Base.GetMobClass
        (ItemList[destItem^.Index].Classe)) then
      begin
        Exit;
      end;
    end;
    if (ItemList[srcItem^.Index].ItemType = 10) then
    begin // movendo pran do equip para o inv, mandar unspawn
      if (Player.Account.Header.Pran1.ItemId = srcItem^.Identific) then
      begin
        UnspawnPran := 0;
      end
      else if (Player.Account.Header.Pran2.ItemId = srcItem^.Identific) then
      begin
        UnspawnPran := 1;
      end;
      if (destItem^.Index > 0) then
      begin
        if (Player.Account.Header.Pran1.ItemId = destItem^.Identific) then
        begin
          SpawnPran := 0;
        end
        else if (Player.Account.Header.Pran2.ItemId = destItem^.Identific) then
        begin
          SpawnPran := 1;
        end;
      end;
    end;
  end;

  if (srcItem.Index = destItem.Index) and (ItemList[destItem.Index].CanAgroup)
  then
    TItemFunctions.AgroupItem(srcItem, destItem)
  else
  begin
    Move(destItem^, Aux, SizeOf(TItem));
    Move(srcItem^, destItem^, SizeOf(TItem));
    Move(Aux, srcItem^, SizeOf(TItem));
    if (TypeEquip = EQUIPING_TYPE) then
    begin
      Player.Base.SetEquipEffect(srcItem^, EQUIPING_TYPE);
      Player.Base.SetEquipEffect(destItem^, DESEQUIPING_TYPE);
    end
    else if (TypeEquip = DESEQUIPING_TYPE) then
    begin
      Player.Base.SetEquipEffect(srcItem^, DESEQUIPING_TYPE);
      Player.Base.SetEquipEffect(destItem^, EQUIPING_TYPE);
    end;
  end;

  Player.Base.SendRefreshItemSlot(Packet.DestType, Packet.destSlot,
    destItem^, false);
  Player.Base.SendRefreshItemSlot(Packet.SrcType, Packet.srcSlot,
    srcItem^, false);

  if (ReSpawn) then
  begin
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
    Player.Base.SendCreateMob(SPAWN_NORMAL);
  end
  else if (UpdatePoint) then
  begin
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
  end;
  if (PranRespawn) then
  begin
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
    Player.SendPranSpawn(Player.SpawnedPran);
  end;
  if not(UnspawnPran = 255) then
  begin
    Player.SpawnedPran := 255;
    Player.SendPranToWorld(255);
    Player.SendPranUnspawn(UnspawnPran);
    Player.SetPranPassiveSkill(UnspawnPran, 0);
    Player.SetPranEquipAtributes(UnspawnPran, false);
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
  end;
  if not(SpawnPran = 255) then
  begin
    Player.SendPranSpawn(SpawnPran);
    Player.SendPranToWorld(SpawnPran);
    Player.SetPranPassiveSkill(SpawnPran, 1);
    Player.SetPranEquipAtributes(SpawnPran, True);
    Player.Base.GetCurrentScore;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.Base.SendCurrentHPMP;
    Player.SpawnedPran := SpawnPran;
  end;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Change Item Atributes [Refine/etc]'}

class function TPacketHandlers.ChangeItemAttribute(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TChangeItemAttPacket absolute Buffer;
  Reinforced: BYTE;
  MaterialSlot: Word;
begin
  Reinforced := 0;
  Result := false;

  case Packet.ChangeType of
{$REGION 'Redução LV'}
    CHANGE_LEVEL:
      begin
        Reinforced := TItemFunctions.ReduceItemLevel(Player, Packet.ItemSlot);
        // if Reinforced in [0, 4, 5, 9] then
        // begin
        // case Reinforced of
        // 0: Player.SendClientMessage('O Item foi destruído.');
        // 4: Player.SendClientMessage('Algo de errado não está certo.');
        // 5: Player.SendClientMessage('Você não possui gold suficiente.');
        // 9: Player.SendClientMessage('Usou hack, perdeu os itens!');
        // end;
        // Exit;
        // end;
        Result := True;
      end;
{$ENDREGION}
{$REGION 'Reinforce'}
    CHANGE_REINFORCE:
      begin
        Reinforced := TItemFunctions.ReinforceItem(Player, Packet.ItemSlot,
          Packet.Item2, Packet.Item3);
        if Reinforced in [0, 4, 5, 9] then
        begin
          case Reinforced of
            0:
              Player.SendClientMessage('O Item foi destruído.');
            4:
              Player.SendClientMessage('Algo de errado não está certo.');
            5:
              Player.SendClientMessage('Você não possui gold suficiente.');
            9:
              Player.SendClientMessage('Usou hack, perdeu os itens!');
          end;
          Exit;
        end;
        Result := True;
      end;
{$ENDREGION}
{$REGION 'Enchant'}
    CHANGE_ENCHANTS:
      begin
        Reinforced := TItemFunctions.EnchantItem(Player, Packet.ItemSlot,
          Packet.Item2);
        if Reinforced in [0, 1, 3, 4] then
        begin
          case Reinforced of
            0:
              Player.SendClientMessage('Algo de errado não está certo!', 16);
            1:
              Player.SendClientMessage('Erro de item. Contatue o suporte!', 16);
            3:
              Player.SendClientMessage
                ('Já existe esse atributo encantado no item.', 16);
            4:
              Player.SendClientMessage
                ('O vaizan que você usou resultou em um atributo já encantado.',
                16);
          end;
          Exit;
        end;
        Result := True;
      end;
{$ENDREGION}
{$REGION 'Change APP'}
    CHANGE_APP:
      begin
        MaterialSlot := TItemFunctions.GetItemSlot2(Player, 4580);
        if MaterialSlot = 255 then
        begin
          Player.SendClientMessage('Você não possui Athlon!', 16);
          Exit;
        end;

        Reinforced := TItemFunctions.ChangeApp(Player, Packet.ItemSlot,
          MaterialSlot, Packet.Item2);
        if Reinforced in [0, 1] then
        begin
          case Reinforced of
            0:
              Player.SendClientMessage('Algo de errado não está certo!', 16);
            1:
              Player.SendClientMessage
                ('Este item não pode ser colocado como aparência!', 16);
          end;
          Exit;
        end;

        if Player.Character.Base.Gold < 500 then
        begin
          Player.SendClientMessage('Você não tem o gold necessário!', 16);
          Exit;
        end;

        Dec(Player.Character.Base.Gold, 500);
        Result := True;
      end;
{$ENDREGION}
{$REGION 'Mount Enchant'}
    CHANGE_MOUNT_ENCHANTS, CHANGE_PRAN_ENCHANTS:
      begin
        Reinforced := TItemFunctions.EnchantMount(Player, Packet.ItemSlot,
          Packet.Item2);
        if Reinforced in [0, 1] then
        begin
          case Reinforced of
            0:
              Player.SendClientMessage('Algo de errado não está certo!', 16);
            1:
              Player.SendClientMessage('Erro de item. Contacte o suporte!', 16);
          end;
          Exit;
        end;
        Result := True;
      end;
{$ENDREGION}
  end;

  Player.RefreshMoney;
  Player.Base.SendRefreshItemSlot(Packet.ItemSlot, false);

  if Packet.Item2 <> $FFFFFFFF then
    Player.Base.SendRefreshItemSlot(Packet.Item2, false);

  if Packet.Item3 <> $FFFFFFFF then
    Player.Base.SendRefreshItemSlot(Packet.Item3, false);

  Player.SendChangeItemResponse(Reinforced, Packet.ChangeType);
end;

{$ENDREGION}
{$REGION 'Troca'}

class function TPacketHandlers.TradeRequest(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := false;

  if (Player.Base.Character.Nation <> Servers[Player.ChannelIndex].Players
    [Packet.Data].Base.Character.Nation) or (Packet.Data <= 0) or
    (Packet.Data > MAX_CONNECTIONS) then
  begin
    Player.SendClientMessage('Você não pode negociar com esse jogador.');
    Exit;
  end;

  if (Player.Character.TradingWith <> 0) or
    (Servers[Player.ChannelIndex].Players[Packet.Data].Character.TradingWith
    <> 0) then
  begin
    Player.SendClientMessage('Jogador ja está em negociação.');
    Exit;
  end;

  Servers[Player.ChannelIndex].Players[Packet.Data]
    .SendData(Player.Base.ClientID, $315, Player.Base.ClientID);
  Result := True;
end;

class function TPacketHandlers.TradeResponse(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TResponseTradePacket absolute Buffer;
  I: Integer;
  OtherPlayer: TPlayer;
begin
  Result := false;
  Player.Character.TradingWith := Packet.OtherClient;

  case Packet.Response of
    TRADE_ACEPT:
      begin
        Packet.OtherClient := Player.Base.ClientID;
        Servers[Player.ChannelIndex].SendPacketTo(Player.Character.TradingWith,
          Packet, Packet.Header.Size);

        OtherPlayer := Servers[Player.ChannelIndex].Players
          [Player.Character.TradingWith];
        OtherPlayer.Character.TradingWith := Player.Base.ClientID;

        ZeroMemory(@Player.Character.Trade, SizeOf(TTrade));
        ZeroMemory(@OtherPlayer.Character.Trade, SizeOf(TTrade));

        for I := 0 to 9 do
        begin
          Player.Character.Trade.Slots[I] := $FF;
          OtherPlayer.Character.Trade.Slots[I] := $FF;
        end;

        Player.Character.Trade.OtherClientid := Player.Character.TradingWith;
        OtherPlayer.Character.Trade.OtherClientid := Player.Base.ClientID;

        Player.RefreshTrade;
        Player.RefreshTradeTo(Player.Character.TradingWith);

        OtherPlayer.RefreshTrade;
        OtherPlayer.RefreshTradeTo(Player.Base.ClientID);

        Result := True;
      end;

    TRADE_REFUSE:
      begin
        Packet.OtherClient := Player.Base.ClientID;

        Servers[Player.ChannelIndex].Players[Player.Character.TradingWith]
          .SendClientMessage('Pedido de troca recusado!');
        Servers[Player.ChannelIndex].SendPacketTo(Player.Character.TradingWith,
          Packet, Packet.Header.Size);

        Player.Character.TradingWith := 0;
      end;
  end;
end;

class function TPacketHandlers.TradeRefresh(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TTradePacket absolute Buffer;
  OtherPlayer: PPlayer;
  I: Integer;
  slot_cnt: Integer;
begin
  Result := false;
  if (Packet.Header.Index = 0) or (Player.Character.TradingWith = 0) or
    (Player.Character.TradingWith > MAX_CONNECTIONS) then
    Exit;

  OtherPlayer := @Servers[Player.ChannelIndex].Players
    [Player.Character.TradingWith];

  if Packet.Trade.Ready then
  begin
    slot_cnt := 0;
    for I := 0 to 9 do
      if Packet.Trade.Slots[I] <> 255 then
        Inc(slot_cnt);

    if TItemFunctions.GetInvAvailableSlots(OtherPlayer^) < slot_cnt then
    begin
      OtherPlayer.SendClientMessage('Libere mais espaço no inventário antes.');
      Player.SendClientMessage
        ('O inventário do alvo não possui espaço suficiente.');
      Packet.Trade.Ready := false;
      OtherPlayer.Character.Trade.Ready := false;
      OtherPlayer.RefreshTradeTo(Player.Base.ClientID);
      Exit;
    end;
  end;

  for I := 0 to 9 do
  begin
    if Packet.Trade.Itens[I].Index = 0 then
      continue;

    if (ItemList[Packet.Trade.Itens[I].Index].UseEffect in [12 .. 100]) or
      (ItemList[Packet.Trade.Itens[I].Index].TypeTrade > 0) or
      (ItemList[Player.Base.Character.Inventory[Packet.Trade.Slots[I]].Index]
      .TypeTrade > 0) then
    begin
      ZeroMemory(@OtherPlayer.Character.Trade, SizeOf(TTrade));
      ZeroMemory(@Player.Character.Trade, SizeOf(TTrade));
      OtherPlayer.CloseTrade;
      Player.CloseTrade;

      if ItemList[Packet.Trade.Itens[I].Index].UseEffect in [12 .. 100] then
      begin
        Player.SendClientMessage('Item trocável somente via Leilão');
        OtherPlayer.SendClientMessage('Item trocável somente via Leilão');
      end
      else
      begin
        Player.SendClientMessage
          ('Não é possível trocar itens que não são trocáveis.');
        OtherPlayer.SendClientMessage
          ('Não é possível trocar itens que não são trocáveis.');
      end;
      Exit;
    end;
  end;

  if Packet.Trade.Confirm and OtherPlayer.Character.Trade.Confirm then
  begin
    Result := TFunctions.ExecuteTrade(Player, OtherPlayer);
    OtherPlayer.RefreshTradeTo(Player.Base.ClientID);
    OtherPlayer.CloseTrade;
    Player.CloseTrade;
    Player.SendClientMessage('Troca realizada com sucesso.');
    OtherPlayer.SendClientMessage('Troca realizada com sucesso.');
    Exit;
  end;

  Move(Packet.Trade, Player.Character.Trade, SizeOf(TTrade));
  Player.RefreshTradeTo(OtherPlayer.Base.ClientID);
  Result := True;
end;

class function TPacketHandlers.TradeCancel(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := false;
  if (Player.Base.PersonalShop.Index > 0) or (Player.Base.PersonalShopIndex > 0)
  then
  begin
    Result := Self.ClosePersonalShop(Player, Buffer);
    Exit;
  end;

  if Player.Character.TradingWith = 0 then
    Exit;

  Servers[Player.ChannelIndex].Players[Player.Character.TradingWith].CloseTrade;
  Player.Character.TradingWith := 0;
  Result := True;
end;

{$ENDREGION}
{$REGION 'Item Bar Functions'}

class function TPacketHandlers.ChangeItemBar(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TChangeItemBarPacket absolute Buffer;
begin
  Result := True;
  case Packet.SrcType of
    0:
      begin
        Player.RefreshItemBarSlot(Packet.destSlot, 0, Packet.SrcIndex);
        Player.Character.Base.ItemBar[Packet.destSlot] := 0;
      end;
    2:
      begin
        Player.Character.Base.ItemBar[Packet.destSlot] :=
          (Packet.SrcIndex * 16) + 2;
        Player.RefreshItemBarSlot(Packet.destSlot, 2, Packet.SrcIndex);
      end;
    3:
      begin
        if (SkillData[Packet.SrcIndex + 5760].Duration = 0) and
          (Packet.SrcIndex <> 0) then
          Exit;
        Player.RefreshItemBarSlot(Packet.destSlot, 3, Packet.SrcIndex);
        if Player.SpawnedPran = 0 then
          Player.Account.Header.Pran1.ItemBar[Packet.destSlot] :=
            Packet.SrcIndex
        else
          Player.Account.Header.Pran2.ItemBar[Packet.destSlot] :=
            Packet.SrcIndex;
      end;
    6:
      begin
        if TItemFunctions.GetItemSlot2(Player, Packet.SrcIndex) = 255 then
          Exit;
        Player.Character.Base.ItemBar[Packet.destSlot] := Packet.SrcIndex;
        Player.RefreshItemBarSlot(Packet.destSlot, 6, Packet.SrcIndex);
      end;
  else
    Result := false;
  end;
end;

{$ENDREGION}
{$REGION 'MOB Functions'}

class function TPacketHandlers.UpdateMobInfo(var Player: TPlayer;
  var Buffer: array of BYTE): Boolean;
var
  Packet: TRequestMobInfoPacket absolute Buffer;
  MOB: TBaseMob;
  NPC: TBaseNpc;
begin
  Result := False;
  if (Packet.Index = 0) or (Packet.Index > 3048) then
    Exit;


  if (Packet.Index < 3048) and (Packet.Index > MAX_CONNECTIONS) then
  begin
      case Packet.Type1 of
        1:
          begin
            Packet.Index := 2047 + Packet.Index;
          end;
      end;
      if not(TBaseNpc.GetMob(Packet.Index, Player.ChannelIndex, NPC)) then
        Exit;
      if (Player.Base.VisibleNPCS.Contains(Packet.Index)) then
        Exit;
      NPC.SendCreateMob(SPAWN_NORMAL, Player.Base.ClientId, False);
      Result := true;
  end;

end;

{$ENDREGION}
{$REGION 'Premium Items'}

class function TPacketHandlers.BuyItemCash(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
  Slot: Integer;
  CashInventory: PCashInventory;
begin
  Result := false;

  WriteLn('index do item ' + PremiumItems[Packet.Data].Index.ToString);
  if (Packet.Data = 0) or (PremiumItems[Packet.Data].show = 0) then
  begin
    Player.SendClientMessage('Item inválido ou não pode ser comprado.');
    Exit;
  end;

  CashInventory := @Player.Account.Header.CashInventory;
  if (CashInventory.Cash >= PremiumItems[Packet.Data].Price) then
  begin
    Slot := CashInventory.AddItem(Packet.Data);
    if (Slot >= 0) then
    begin
      DecCardinal(CashInventory.Cash, PremiumItems[Packet.Data].Price);
      Player.Base.SendRefreshItemSlot(CASH_TYPE, Slot,
        CashInventory.Items[Slot].ToItem, false);
      Player.SendClientMessage('Item comprado com sucesso.');
      Player.SendPlayerCash;
      Result := True;
    end
    else
      Player.SendClientMessage('Você não tem espaço suficiente na loja cash.');
  end
  else
    Player.SendClientMessage('Você não tem cash suficiente.');
end;

class function TPacketHandlers.SendGift(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSendGiftPacket absolute Buffer;
  SelfPremium: PCashInventory;
  OtherPremium: PCashInventory;
begin
  Result := false;
  SelfPremium := @Player.Account.Header.CashInventory;
  if not(Servers[Player.ChannelIndex].Players[Packet.Target].Base.IsActive) then
    Exit;

  OtherPremium := @Servers[Player.ChannelIndex].Players[Packet.Target]
    .Account.Header.CashInventory;
  if (SelfPremium.IsEmpyt(Packet.Slot)) or
    (OtherPremium.AddItem(SelfPremium.Items[Packet.Slot].Index) = -1) then
  begin
    Player.SendClientMessage
      ('Inventário cash do destinatário já está cheio ou item inválido.');
    Exit;
  end;

  Servers[Player.ChannelIndex].Players[Packet.Target].SendClientMessage
    ('Recebeu presente de ' + AnsiString(Player.Character.Base.Name) + '.');
  ZeroMemory(@SelfPremium.Items[Packet.Slot], SizeOf(TItemCash));
  Servers[Player.ChannelIndex].Players[Packet.Target].SendCashInventory;
  Player.SendCashInventory;
  Result := True;
end;

class function TPacketHandlers.ReclaimCoupom(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TPacketReclaimCoupom absolute Buffer;
  SQLComp: TQuery;
  RealCupom: String;
  I: Integer;
  CashAmount: Integer;
  CommandID: Integer;
begin
  Result := false;

  if (Trim(String(Packet.Coupom)) = '') or (Length(String(Packet.Coupom)) < 16)
  then
  begin
    Player.SendClientMessage('Cupom inválido.');
    Exit;
  end;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[CheckGMLogin]',
      TLogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[CheckGMLogin]', TLogType.Error);
    SQLComp.Free;
    Exit;
  end;

  RealCupom := '';
  for I := 1 to 16 do
  begin
    RealCupom := RealCupom + Char(Packet.Coupom[I - 1]);
    if (I in [4, 8, 12]) then
      RealCupom := RealCupom + '-';
  end;

  SQLComp.SetQuery
    ('SELECT id, target_itemid, command_type, target_itemcnt FROM gm_commands WHERE coupom = '
    + QuotedStr(RealCupom) +
    ' AND runned = 1 AND refused = 0 AND target_name = ""');
  SQLComp.Run;

  if (SQLComp.Query.RecordCount = 0) then
  begin
    Player.SendClientMessage('Cupom inválido.');
    SQLComp.Free;
    Exit;
  end;

  CommandID := SQLComp.Query.Fields[0].AsInteger;
  case SQLComp.Query.Fields[2].AsInteger of
    COUPOM_GMCOMMAND:
      begin
        CashAmount := SQLComp.Query.Fields[1].AsInteger * 1000;
        Player.AddCash(CashAmount);
        Player.SendPlayerCash;
        Player.SendClientMessage('You has activated a PinCode [' +
          CashAmount.ToString + ' iNizCoins].');
      end;
  end;

  SQLComp.SetQuery('UPDATE gm_commands SET target_name = ' +
    QuotedStr(String(Player.Base.Character.Name)) + ' WHERE id = ' +
    CommandID.ToString);
  SQLComp.Query.Connection.StartTransaction;
  SQLComp.Run(false);
  SQLComp.Query.Connection.Commit;

  SQLComp.Free;
  Result := True;
end;

{$ENDREGION}
{$REGION 'Item Functions'}

class function TPacketHandlers.UseItem(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TUseItemPacket absolute Buffer;
  ItemIndex: word;
  ItemType: word;
  EquipSlot: byte;
begin
  Result := false;
  if Player.Base.IsDead then
    Exit;

  case Packet.TypeSlot of
    INV_TYPE:
    begin
      Result := TItemFunctions.UseItem(Player, Packet.Slot, Packet.Type1);
      Exit;
    end;

    ITEM_USE_TYPE:
      begin
        ItemIndex := Player.Base.Character.Inventory[Packet.Slot].Index;
        if ItemIndex = 0 then
          Exit;

        ItemType := ItemList[ItemIndex].ItemType;
        case ItemType of
          708, 709:
            begin
              if Packet.Type1 > 16 then
              begin
                Packet.Type1 := Packet.Type1 - 16;
                EquipSlot := TItemFunctions.GetItemEquipSlot
                  (Player.Base.Character.Inventory[Packet.Type1].Index);
                if ((ItemType = 708) and (EquipSlot = 6)) or
                  ((ItemType = 709) and (EquipSlot in [2, 3, 4, 5, 7])) then
                begin
                  Player.Base.Character.Inventory[Packet.Type1].MIN := Player.Base.Character.Inventory[Packet.Type1].MAX;
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.Type1, Player.Base.Character.Inventory[Packet.Type1], false);
                end;
              end
              else
              begin
                EquipSlot := TItemFunctions.GetItemEquipSlot
                  (Player.Base.Character.Equip[Packet.Type1].Index);
                if ((ItemType = 708) and (EquipSlot = 6)) or
                  ((ItemType = 709) and (EquipSlot in [2, 3, 4, 5, 7])) then
                begin
                  Player.Base.Character.Equip[Packet.Type1].MIN := Player.Base.Character.Equip[Packet.Type1].MAX;
                  Player.Base.SendRefreshItemSlot(EQUIP_TYPE, Packet.Type1, Player.Base.Character.Equip[Packet.Type1], false);
                end;
              end;

              Player.SendClientMessage('Item reparado com sucesso.');
            end;

        else
          Player.SendClientMessage('Item ainda não configurado.');
        end;

        TItemFunctions.DecreaseAmount(@Player.Base.Character.Inventory
          [Packet.Slot]);
        Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.Slot,
          Player.Base.Character.Inventory[Packet.Slot], false);
                Exit;
      end;

    CASH_TYPE:
    begin
      Result := TItemFunctions.UsePremiumItem(Player, Packet.Slot);
            Exit;
    end;
  end;
end;

class function TPacketHandlers.UseBuffItem(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TUseBuffItemPacket absolute Buffer;
  Item: pItem;
begin
  Result := false;
  Item := @Player.Character.Base.Inventory[Packet.Slot];

  if (Item.IsSealed) then
    Exit;

  case ItemList[Item.Index].ItemType of
    0:
      Result := false;

    ITEM_TYPE_BUFF:
      begin
        case SkillData[ItemList[Item.Index].UseEffect].Index of
          285:
            if (Player.Base.BuffExistsByIndex(285)) then
              Player.SendClientMessage('Não é combinável com [' +
                AnsiString(SkillData[ItemList[Item.Index].UseEffect]
                .Name + '].'));

          280: // buque de rosas brancas
            if (Player.Base.BuffExistsByIndex(281)) then
              Player.SendClientMessage('Não é combinável com [' +
                AnsiString(SkillData[ItemList[Item.Index].UseEffect]
                .Name + '].'));

          281: // buque de rosas vermelhas
            if (Player.Base.BuffExistsByIndex(280)) then
              Player.SendClientMessage('Não é combinável com [' +
                AnsiString(SkillData[ItemList[Item.Index].UseEffect]
                .Name + '].'));

          305: // poção halloween, ronire, pascoa, premiuns
            if (Player.Base.BuffExistsByIndex(305)) then
              Player.SendClientMessage('Não é combinável com [' +
                AnsiString(SkillData[ItemList[Item.Index].UseEffect]
                .Name + '].'));

          544: // poção Gratidão Wars
            if (ItemList[Item.Index].ItemType = 544) then
            begin
              Player.Base.RemoveBuff(ItemList[Item.Index].UseEffect);
              if (Player.Base.BuffExistsInArray([545])) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect]
                  .Name + '].'));
                Exit;
              end;
            end;

          545: // poção Honrra Wars
            if (ItemList[Item.Index].ItemType = 545) then
            begin
              Player.Base.RemoveBuff(ItemList[Item.Index].UseEffect);
              if (Player.Base.BuffExistsInArray([544])) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[Item.Index].UseEffect]
                  .Name + '].'));
                Exit;
              end;
            end;
        end;

        Player.Base.AddBuff(ItemList[Item.Index].UseEffect);
      end;

    ITEM_TYPE_BUFF2:
      begin
        if (SkillData[ItemList[Item.Index].UseEffect].Index = 251) and
          (Player.Base.BuffExistsByIndex(251)) then
        begin
          Player.SendClientMessage('Não é combinável com [' +
            AnsiString(SkillData[ItemList[Item.Index].UseEffect].Name + '].'));
          Exit;
        end;

        case ItemList[Item.Index].UseEffect of
          8124:
            if (Player.Base.BuffExistsByIndex(251)) then
              Exit;
        end;

        Player.Base.AddBuff(ItemList[Item.Index].UseEffect);
      end;
  end;
end;

class function TPacketHandlers.UnsealItem(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
  Item: pItem;
begin
  Result := false;
  Item := @Player.Character.Base.Inventory[Packet.Data];
  if (Item.Index = 0) or (not Item.IsSealed) then
    Exit;

  Item.IsSealed := false;
  TItemFunctions.UseItem(Player, Packet.Data);
  Player.Base.SendRefreshItemSlot(Packet.Data, false);

  Result := True;
end;

{$ENDREGION}
{$REGION 'Buff Functions'}

class function TPacketHandlers.RemoveBuff(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TRemoveBuffPacket absolute Buffer;
begin
  Result := Player.Base.RemoveBuff(Packet.BuffIndex);
  if (Result) then
  begin
    Player.Base.SendRefreshBuffs;
    Player.Base.SendCurrentHPMP;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
  end;
end;
{$ENDREGION}
{$REGION 'Attack & Skill Functions'}

function CheckAttack(var Player: PPlayer; Packet: TSendSkillUse;
  Tipo: Integer): boolean;
var
  OtherPlayer: PPlayer;
  EquipIndex: Integer;
begin
  Result := false; // Valor padrão caso as condições não sejam atendidas
  var
  Skill1 := SkillData[Packet.Skill];



  // if (Skill1.Classe <> Player.base.Character.ClassInfo) then
  // begin
  // case Skill1.Index of
  // 164:
  // begin
  // // Código para o índice 164
  // end;
  //
  // 165:
  // begin
  // // Código para o índice 165
  // end;
  //
  // else
  // begin
  // Player.SendClientMessage('Skill não é da sua classe');
  // Exit;
  // end;
  // end; // Fim do case
  // end;

  if Skill1.Index = 318 then
    Exit;

  EquipIndex := Player.Base.Character.Equip[6].Index;
  if EquipIndex <= 0 then
    Exit;

  if Tipo = 1 then
  begin

    if (Servers[Player.ChannelIndex].Players[Packet.Index].Status <> Playing) or
      Servers[Player.ChannelIndex].Players[Packet.Index].SocketClosed then
    begin
      // Player.SendClientMessage('O Alvo está indisponível');

      if not(Packet.Index = 0) then
      begin
        Exit;
      end;
    end;

  end;

  // Verifica se o índice é inválido ou condições específicas
  if ((Packet.Skill = 0) or (Packet.Skill = 5760) or (Packet.Skill = 5860) or
    (Packet.Skill = 5960)) or ((Skill1.Classe >= 61) and (Skill1.Classe <= 84)
    and (Skill1.Duration = 0)) then
    Exit;

  // Verifica se o nível do personagem é insuficiente
  if Player.Base.Character.Level < Skill1.MinLevel then
    Exit;

  // Verifica se o personagem está morto

  if (SkillData[Packet.Skill].Index = 163) or
    (SkillData[Packet.Skill].Index = 164) then
  begin
    WriteLn('é skill de player ');
    if Player.Base.BuffExistsByIndex(77) then
    begin
      Player.Base.RemoveBuffByIndex(77);
    end;
    if Player.Base.BuffExistsByIndex(53) then
    begin
      Player.Base.RemoveBuffByIndex(53);
    end;

  end
  else
  begin
    if Player.Base.BuffExistsByIndex(163) then
    begin
      Player.Base.RemoveBuffByIndex(163);
      Exit;
    end;
  end;

  // Remover buffs específicos
  if not(SkillData[Packet.Skill].Index = 77) or
    not(SkillData[Packet.Skill].Index = 53) then
  begin
    if Player.Base.BuffExistsByIndex(77) then
    begin
      Player.Base.RemoveBuffByIndex(77);
    end;
    if Player.Base.BuffExistsByIndex(53) then
    begin
      Player.Base.RemoveBuffByIndex(53);
    end;
  end;

  // Verifica condições de ataque para classes de mob 2 ou 3
  if (Player.Base.GetMobClass() in [2, 3]) then
  begin
    if Player.Base.Character.Equip[15].Index = 0 then
    begin
      Player.SendClientMessage('Você está sem balas.');
      Exit;
    end;

  end;

  // Se nenhuma condição de saída foi atendida, retorna True
  Result := True;
end;

function GetTargetType(TipoMob: Word; Dungeon: boolean): BYTE;
begin

  if (TipoMob >= 1) and (TipoMob <= 1000) then
    Result := 1 // player
  else if Dungeon then
    Result := 8
  else if (TipoMob >= 3340) and (TipoMob <= 3354) then // devir stones
    Result := 4
  else if ((TipoMob >= 3355) and (TipoMob <= 3369)) or
    ((TipoMob >= 3391) and (TipoMob <= 3399)) then
    Result := 5
  else if (TipoMob >= 3048) and (TipoMob < 9148) then // mobs
    Result := 2
  else if (TipoMob >= 2048) and (TipoMob < 3048) then // npc
    Result := 3
  else if (TipoMob > 9148) then // npc+mobs temporários
    Result := 6
  else if (TipoMob >= 3391) and (TipoMob <= 3399) then
    Result := 7
  else
    Result := 0; // caso nenhum tipo seja encontrado
end;

function RemoveMp(Packet: TSendSkillUse; Player: PPlayer): boolean;
var
  SkillMP, MPToRemove: Integer;
  PranMPAdjustment: Integer;
  CureMPAdjustment: Integer;
  GeneralMPAdjustment: Integer;
begin
  Result := false;
  MPToRemove := 0;

  // Determina o valor base de MPToRemove
  if (Packet.Index = 0) then
  begin
    case SkillData[Packet.Skill].Index of
      107, 110, 166, 167:
        MPToRemove := SkillData[Packet.Skill].MP div 10;
    end;
  end
  else if (SkillData[Packet.Skill].Index = 107) then
    MPToRemove := SkillData[Packet.Skill].MP div 10;

  if (MPToRemove = 0) then
    MPToRemove := SkillData[Packet.Skill].MP;

  // Ajustes de MP
  PranMPAdjustment := (MPToRemove div 100) * Player.Base.GetMobAbility
    (EF_PRAN_REQUIRE_MP);
  CureMPAdjustment := (MPToRemove div 100) * Player.Base.GetMobAbility
    (EF_MPCURE);
  GeneralMPAdjustment := (MPToRemove div 100) * Player.Base.GetMobAbility
    (EF_REQUIRE_MP);

  // Aplica os ajustes
  Dec(MPToRemove, PranMPAdjustment);
  Dec(MPToRemove, CureMPAdjustment);
  Dec(MPToRemove, GeneralMPAdjustment);

  // Verifica se o jogador tem MP suficiente
  if (Player.Base.Character.CurrentScore.CurMP < MPToRemove) then
  begin
    // Player.Base.SendCurrentAllSkillCooldown;
    // Servers[Player.Base.ChannelId].Players[Player.Base.ClientId].SendClientMessage('Você não possui MP necessário para realizar a habilidade.');
    Exit(false);
  end
  else
  begin
    Player.Base.RemoveMp(MPToRemove, True);
    Result := True;
  end;
end;

class function TPacketHandlers.UseSkill(var Player: PPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSendSkillUse absolute Buffer;
  Packet2: TSendAtkPacket;
  OtherMob: PBaseMob;
  Bufferx: array of BYTE;
  MobId, MobPid: Word;
  Tipo: BYTE;
  DataSkill: P_SkillData;
begin
  Result := false;
  Player^.LastAttackSents := Now;
  if not(CheckItemsDefault(Player)) or not RemoveMp(Packet, Player) then
    Exit;
  Tipo := GetTargetType(Packet.Index, Player^.InDungeon);
  if not Player.Base.CheckCooldown3(Packet) or not CheckAttack(Player, Packet,
    Tipo) then
    Exit;

  Player^.Base.SendToVisible(Packet, Packet.Header.Size);
  DataSkill := @SkillData[Packet.Skill];



  Player^.Base.CurrentAction := 0;
  Player^.LastPositionLongSkill := Packet.pos;
  Player^.Base.UsingSkill := Packet.Skill;

  if DataSkill^.CastTime <= 0 then
  begin
    FillChar(Packet2, SizeOf(Packet2), 0);
    Packet2.Header.Size := SizeOf(Packet2);
    Packet2.Header.Index := Player^.Base.ClientID;
    Packet2.Header.Code := $302;
    Packet2.Index := Packet.Index;
    Packet2.Anim := DataSkill^.SelfAnimation;
    Packet2.Skill := Packet.Skill;
    Packet2.MyPos := Player^.Base.PlayerCharacter.LastPos;

    if Tipo > 1 then
    begin
      OtherMob := Player^.Base.GetTargetInList(Packet.Index);
      if (OtherMob = nil) or OtherMob.IsDead then
        Exit;
    end;

    case Tipo of
      1: // Players
        begin
          Packet2.TargetPos := Servers[Player^.ChannelIndex].Players
            [Packet.Index].Base.PlayerCharacter.LastPos;
          Player^.Base.Target := @Servers[Player^.ChannelIndex].Players
            [Packet.Index].Base;
        end;
      2, 6: // Mobs
        begin
          if OtherMob = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet.Index, MobPid);
            if MobId = -1 then
            begin
              WriteLn('Erro: MobId = -1');
              Exit;
            end;
            OtherMob := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId].MobsP
              [MobPid].Base;
            Player^.Base.AddTargetToList(OtherMob);
          end;
          Packet2.TargetPos := Servers[Player^.ChannelIndex].Mobs.TMobS
            [OtherMob.MobId].MobsP[OtherMob.SecondIndex].CurrentPos;
        end;
      8: // Dungeon Mobs
        begin
          if Player^.InDungeon and (Packet.Index <> Player^.Base.ClientID) then
          begin
            MobId := TMobFuncs.GetMobDgGeralID(Player^.ChannelIndex,
              Packet.Index, Player^.DungeonInstanceID);
            if MobId = -1 then
            begin
              Player^.SendClientMessage
                ('Erro: MobId = -1. Não foi possível obter MobGeralID. INDEX: '
                + AnsiString(Packet.Index.ToString));
              Exit;
            end;
            OtherMob := @DungeonInstances[Player^.DungeonInstanceID].Mobs
              [MobId].Base;
            Player^.Base.AddTargetToList(OtherMob);
            Packet2.TargetPos := Servers[Player^.ChannelIndex].Mobs.TMobS
              [OtherMob.MobId].MobsP[OtherMob.SecondIndex].CurrentPos;
          end;
        end;
    else
      begin // Devir Stones, Devir Guards, Royal Guards
        if OtherMob <> nil then
        begin
          case Tipo of
            4:
              Packet2.TargetPos := Servers[Player^.ChannelIndex].DevirStones
                [OtherMob.ClientID].PlayerChar.LastPos;
            5:
              Packet2.TargetPos := Servers[Player^.ChannelIndex].DevirGuards
                [OtherMob.ClientID].PlayerChar.LastPos;
            7:
              Packet2.TargetPos := Servers[Player^.ChannelIndex].RoyalGuards
                [OtherMob.ClientID].PlayerChar.LastPos;
          end;
        end;
      end;
    end;

    SetLength(Bufferx, SizeOf(Packet2));
    Move(Packet2, Bufferx[0], SizeOf(Packet2));
    Self.AttackTarget(Player, PPacket_302(Bufferx), True, Tipo);
  end;

  Result := True;
end;

class function TPacketHandlers.LearnSkill(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TLearnSkillPacket absolute Buffer;
  BarIndex: Integer;
  SkillID: Integer;
begin
  Result := false;
  if (SkillData[Packet.SkillIndex].MinLevel > Player.Character.Base.Level) then
  begin
    Player.SendClientMessage('Não possui level necessário.');
    Exit;
  end;

  if (SkillData[Packet.SkillIndex].SkillPoints >
    Player.Character.Base.CurrentScore.SkillPoint) then
  begin
    Player.SendClientMessage('Não possui pontos de habilidade necessário.');
    Exit;
  end;

  if (SkillData[Packet.SkillIndex].LearnCosts > Player.Character.Base.Gold) then
  begin
    Player.SendClientMessage('Não possui gold suficiente.');
    Exit;
  end;

  if not Player.Base.MatchClassInfo(SkillData[Packet.SkillIndex].Classe) then
  begin
    Player.SendClientMessage('Esta habilidade não pertence a sua classe.');
    Exit;
  end;

  if (SkillData[Packet.SkillIndex].Index = 427) then
  begin
    Player.SendClientMessage('Esta habilidade não está disponível.');
    Exit;
  end;

  if (Player.SkillUpgraded = Packet.SkillIndex) then
    Exit;

  // Packet.SkillIndex := 318;
  // SkillID:= 65;
  if (TSkillFunctions.IncremmentSkillLevel(Player, Packet.SkillIndex, SkillID))
  then
  begin
    if (Player.Character.Base.CurrentScore.SkillPoint = 1) then
    begin
      Player.Character.Base.CurrentScore.Status := 0;
      Player.Base.Character.CurrentScore.SkillPoint := 0;
    end
    else
      Dec(Player.Character.Base.CurrentScore.SkillPoint,
        SkillData[Packet.SkillIndex].SkillPoints);

    Dec(Player.Character.Base.Gold, SkillData[Packet.SkillIndex].LearnCosts);

    Player.SendPlayerSkills(Packet.NPCIndex);
    Player.RefreshMoney;
    Player.SendPlayerSkillsLevel;
    Player.SetActiveSkillPassive(SkillID, Packet.SkillIndex);
    Player.Base.SendCurrentHPMP;
    Player.Base.SendStatus;
    Player.Base.SendRefreshPoint;
    Player.SkillUpgraded := Packet.SkillIndex;
    Player.Base.GetCurrentScore;
    Player.Base.SendRefreshLevel;
    TSkillFunctions.UpdateAllOnBar(Player, Packet.SkillIndex - 1,
      Packet.SkillIndex, BarIndex);
    Sair(Player);
    Result := True;
  end;
end;

class function TPacketHandlers.ResetSkills(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Taxa: Integer;
  I: BYTE;
begin
  Result := false;
  Taxa := ((Player.Base.Character.Level * 1000) div 2);
  if (Player.Base.Character.Gold < Taxa) then
  begin
    Player.SendClientMessage
      ('Você não possui gold sulficiente para reniciar as suas habilidades!',
      16);
    Exit;
  end;
  for I := 0 to 39 do
  begin
    Player.Base.Character.ItemBar[I] := 0;
    Player.RefreshItemBarSlot(I, 0, Player.Base.Character.ItemBar[I]);
  end;
  Player.SearchSkillsPassive(1);
  Player.Base.SendCurrentHPMP;
  Move(InitialAccounts[Player.Base.GetMobClass].Skills, Player.Character.Skills,
    SizeOf(InitialAccounts[Player.Base.GetMobClass].Skills));
  for I := 0 to Length(Player.Character.Skills.Others) - 1 do
  begin
    Player.Character.Skills.Others[I].Level := 0;
  end;
  Player.Character.Skills.Others[0].Level := 1;
  Dec(Player.Base.Character.Gold, Taxa);
  Player.Character.Base.CurrentScore.SkillPoint :=
    Player.CalcSkillPoints(Player.Base.Character.Level);
  Player.SendPlayerSkills;
  Player.Base.GetCurrentScore;
  Player.Base.SendRefreshPoint;
  Player.Base.SendStatus;
  Player.Base.SendRefreshLevel;
  Player.Base.SendCurrentHPMP();
  Player.SendPlayerSkills;
  Player.RefreshMoney;
  Player.SendPlayerSkillsLevel;
  Player.Base.SendStatus;
  Player.Base.SendRefreshPoint;
  Sair(Player);
  Result := True;
end;

function CheckPlayerAttackConditionsBasic(Player: PPlayer; Packet: PPacket_302;
  TargetPlayer: PPlayer): boolean;
var
  PlayerGuild: PGuild;
  OtherPlayerGuild: PGuild;
begin
  Result := false;

  if Player^.Base.IsDead or TargetPlayer^.SocketClosed then
    Exit;

  // Verifica se o jogador ou o alvo estão dentro de áreas específicas
  if (Abs(2947 - TargetPlayer^.Base.PlayerCharacter.LastPos.X) <= 8) and
    (Abs(1664 - TargetPlayer^.Base.PlayerCharacter.LastPos.Y) <= 8) or
    (Abs(2947 - Player^.Base.PlayerCharacter.LastPos.X) <= 8) and
    (Abs(1664 - Player^.Base.PlayerCharacter.LastPos.Y) <= 8) or
    (Abs(1486 - Player^.Base.PlayerCharacter.LastPos.X) <= 4) and
    (Abs(1610 - Player^.Base.PlayerCharacter.LastPos.Y) <= 4) or
    (Abs(1486 - TargetPlayer^.Base.PlayerCharacter.LastPos.X) <= 4) and
    (Abs(1610 - TargetPlayer^.Base.PlayerCharacter.LastPos.Y) <= 4) then
    Exit(True);

  // Verifica se está dentro de uma cidade
  if (Player^.GetCurrentCityID in [1, 10, 14]) or
    (TargetPlayer^.GetCurrentCityID in [1, 10, 14]) then
    Exit(True);

  // Verifica se o ataque é de longo alcance e se a posição está fora do alcance
  if (Abs(Player^.Base.PlayerCharacter.LastPos.X - Packet^.TargetPos.X) > 35) or
    (Abs(Player^.Base.PlayerCharacter.LastPos.Y - Packet^.TargetPos.Y) > 35)
  then
    Exit(True);

  Result := True;
end;

function CheckPlayerAttackConditionsSkill(Player: PPlayer; Packet: PPacket_302;
  TargetPlayer: PPlayer; DataSkill: BYTE): boolean;
var
  PlayerGuild: PGuild;
  OtherPlayerGuild: PGuild;
begin
  Result := false;

  if Player^.Base.IsDead or TargetPlayer^.Base.IsDead or TargetPlayer^.SocketClosed
  then
    Exit;

  // Verifica se o jogador ou o alvo estão dentro de áreas específicas
  if (Abs(2947 - TargetPlayer^.Base.PlayerCharacter.LastPos.X) <= 8) and
    (Abs(1664 - TargetPlayer^.Base.PlayerCharacter.LastPos.Y) <= 8) or
    (Abs(2947 - Player^.Base.PlayerCharacter.LastPos.X) <= 8) and
    (Abs(1664 - Player^.Base.PlayerCharacter.LastPos.Y) <= 8) or
    (Abs(1486 - Player^.Base.PlayerCharacter.LastPos.X) <= 4) and
    (Abs(1610 - Player^.Base.PlayerCharacter.LastPos.Y) <= 4) or
    (Abs(1486 - TargetPlayer^.Base.PlayerCharacter.LastPos.X) <= 4) and
    (Abs(1610 - TargetPlayer^.Base.PlayerCharacter.LastPos.Y) <= 4) then
    Exit(True);

  // Verifica se está dentro de uma cidade
  if (Player^.GetCurrentCityID in [1, 10, 14]) or
    (TargetPlayer^.GetCurrentCityID in [1, 10, 14]) then
    Exit(True);

  // Verifica se o ataque é de longo alcance e se a posição está fora do alcance
  if (Abs(Player^.Base.PlayerCharacter.LastPos.X - Packet.TargetPos.X) > 35) or
    (Abs(Player^.Base.PlayerCharacter.LastPos.Y - Packet.TargetPos.Y) > 35) then
    Exit(True);

  // verifica se vai atacar companheiros abaixo
  if (DataSkill <> 2) then
  begin

    // ve se o player é da sua mesma pt e sai
    if (Player^.PartyIndex > 0) and (TargetPlayer^.PartyIndex > 0) and
      (Player^.PartyIndex = TargetPlayer^.PartyIndex) then
      Exit;

    // ve se é da mesma guild e nao está em duelo com vc e sai, se nao estiver em duelo, evitando atks em proprios membros guuild

    if (Player^.Character.GuildSlot > 0) and
      (TargetPlayer^.Character.GuildSlot > 0) then
    begin
      PlayerGuild := @Guilds[Player^.Character.GuildSlot];
      OtherPlayerGuild := @Guilds[TargetPlayer^.Character.GuildSlot];

      if (PlayerGuild^.Name = OtherPlayerGuild^.Name) and
        (Player^.DuelingWith <> TargetPlayer^.DuelingWith) then
        Exit;
    end;

  end;

  Result := True;

end;

procedure DefaultCheckBasic(Player: PPlayer);
begin

  if Player^.Base.BuffExistsByIndex(77) then
    Player^.Base.RemoveBuffByIndex(77);
  if Player^.Base.BuffExistsByIndex(53) then
    Player^.Base.RemoveBuffByIndex(53);
  if Player^.Base.BuffExistsByIndex(153) then
    Player^.Base.RemoveBuffByIndex(153);

end;

procedure DefaultCheckSkill(Player: PPlayer; DataSkill: P_SkillData);
begin

  if (DataSkill^.Level > Player^.Base.Character.Level) then
    Exit;

  if Player^.Base.BuffExistsByIndex(77) then
    Player^.Base.RemoveBuffByIndex(77);
  if Player^.Base.BuffExistsByIndex(53) then
    Player^.Base.RemoveBuffByIndex(53);
  if Player^.Base.BuffExistsByIndex(153) then
    Player^.Base.RemoveBuffByIndex(153);

  if not((DataSkill^.Classe >= 61) and (DataSkill^.Classe <= 84)) then
    if ((DataSkill^.Index <> 163) or (DataSkill^.Index <> 164)) and
      Player^.Base.BuffExistsByIndex(163) then
      Player^.Base.RemoveBuffByIndex(163);

  if (not(DataSkill^.Index in [196, 220, 244]) and (DataSkill^.Classe < 61))
  then
    if (Player^.Base.GetMobClass(Player^.Base.Character.ClassInfo) <>
      Player^.Base.GetMobClass(DataSkill^.Classe)) then
      Exit;

end;

class function TPacketHandlers.CheckItemsDefault(Player: PPlayer): boolean;
var
  Arma: pItem;
  Bala: pItem;
  Packet: TRefreshItemPacket;
begin

  Result := false;

  Arma := @Player^.Base.Character.Equip[6];
  if Arma^.Index = 0 then
    Exit;

  if (Player^.Base.GetMobClass = 2) or (Player^.Base.GetMobClass = 3) then
  begin
    Bala := @Player^.Base.Character.Equip[15];
    if (Bala.Index >= 1) and (ItemList[Bala^.Index].ItemType = 50) then
    begin
      TItemFunctions.DecreaseAmount(Bala,
        IfThen(Player^.Base.GetMobClass(Player^.Base.Character.ClassInfo)
        = 3, 2, 1));
    end
    else if Bala^.Index = 0 then
      Exit;

  end;
  Result := True;
end;

class function TPacketHandlers.AttackTarget(Player: PPlayer;
  Packet: PPacket_302; ByUseSkill: boolean = false; Tipo: BYTE = 0): boolean;
var
  OtherMob: PBaseMob;
  MobId, MobPid: Word;
  DataSkill: P_SkillData;
  MobDungeonID: Word;
  Freq: Int64;
  StartCount, EndCount: Int64;
  ElapsedTime: System.Double;
  TargetPlayer: PPlayer;
  Arma: pItem;
  DungeonMobPointer: PMobsStructDungeonInstance;
  NormalMobPointer: PBaseMob;

begin
  Result := True;

  DataSkill := @SkillData[Packet^.Skill];

  if not ByUseSkill and (Packet.Skill = 0) then
  begin

    if not(CheckItemsDefault(Player)) then
      Exit;

    Player^.LastAttackSents := Now;

    Tipo := GetTargetType(Packet^.Index, Player^.InDungeon);

    Case Tipo of
      1:
        begin

          TargetPlayer := @Servers[Player.ChannelIndex].Players[Packet^.Index];
          DefaultCheckBasic(Player);
          // procedure para executar ações padrão do atk basico
          if not CheckPlayerAttackConditionsBasic(Player, Packet, TargetPlayer)
          then // anticheats
            Exit;

          if (Player^.Base.Character.Nation = TargetPlayer^.Base.Character.
            Nation) and (Player^.Base.ClientID <> TargetPlayer^.Base.ClientID)
          then
          begin
            Player^.LastAttackSent := Now;
            Player^.AttackingNation := True;
          end;

          Player^.Base.SendDamage(Packet^.Skill, Packet^.Anim,
            @TargetPlayer^.Base, DataSkill, Tipo);

          Inc(Player^.Base.AttacksAccumulated);
          Inc(TargetPlayer^.Base.AttacksReceivedAccumulated);
          Exit;

        end;
      2, 6:
        begin

          NormalMobPointer := Player^.Base.GetTargetInList(Packet^.Index);
          if NormalMobPointer = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet^.Index, MobPid);
            if MobId = -1 then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            NormalMobPointer := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId]
              .MobsP[MobPid].Base;
            Player^.Base.AddTargetToList(NormalMobPointer);
          end;

          if not(Servers[Player^.ChannelIndex].Mobs.TMobS
            [NormalMobPointer^.MobId].IsActiveToSpawn) or
            (NormalMobPointer^.IsDead) then
            Exit;

          if not(Servers[Player^.ChannelIndex].Mobs.TMobS
            [NormalMobPointer^.MobId].MobsP[NormalMobPointer^.SecondIndex]
            .IsAttacked) then
            Servers[Player^.ChannelIndex].Mobs.TMobS[NormalMobPointer^.MobId]
              .MobsP[NormalMobPointer^.SecondIndex].FirstPlayerAttacker :=
              Player^.Base.ClientID;

          Servers[Player^.ChannelIndex].Mobs.TMobS[NormalMobPointer^.MobId]
            .MobsP[NormalMobPointer^.SecondIndex].IsAttacked := True;
          Servers[Player^.ChannelIndex].Mobs.TMobS[NormalMobPointer^.MobId]
            .MobsP[NormalMobPointer^.SecondIndex].AttackerID :=
            Player^.Base.ClientID;
          Player^.Base.SendDamage(Packet^.Skill, Packet^.Anim, NormalMobPointer,
            DataSkill, Tipo);
          Inc(Player^.Base.AttacksAccumulated);
        end;
      4:
        begin

          OtherMob := Player^.Base.GetTargetInList(Packet.Index);
          if OtherMob = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet.Index, MobPid);
            if MobId = -1 then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            OtherMob := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId].MobsP
              [MobPid].Base;
            Player^.Base.AddTargetToList(OtherMob);
          end;

          if OtherMob^.IsDead then
            Exit;

          if not(Servers[Player^.ChannelIndex].DevirStones[OtherMob^.ClientID]
            .IsAttacked) then
            Servers[Player^.ChannelIndex].DevirStones[OtherMob^.ClientID]
              .FirstPlayerAttacker := Player^.Base.ClientID;
          Servers[Player^.ChannelIndex].DevirStones[OtherMob^.ClientID]
            .IsAttacked := True;
          Servers[Player^.ChannelIndex].DevirStones[OtherMob^.ClientID]
            .AttackerID := Player^.Base.ClientID;

          Player^.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob,
            DataSkill, Tipo);
          Inc(Player^.Base.AttacksAccumulated);
        end;
      5:
        begin
          Inc(Player^.Base.AttacksAccumulated);

          OtherMob := Player^.Base.GetTargetInList(Packet.Index);
          if OtherMob = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet.Index, MobPid);
            if MobId = -1 then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            OtherMob := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId].MobsP
              [MobPid].Base;
            Player^.Base.AddTargetToList(OtherMob);
          end;

          if OtherMob^.IsDead then
            Exit;

          if not(Servers[Player^.ChannelIndex].DevirGuards[OtherMob^.ClientID]
            .IsAttacked) then
            Servers[Player^.ChannelIndex].DevirGuards[OtherMob^.ClientID]
              .FirstPlayerAttacker := Player^.Base.ClientID;
          Servers[Player^.ChannelIndex].DevirGuards[OtherMob^.ClientID]
            .IsAttacked := True;
          Servers[Player^.ChannelIndex].DevirGuards[OtherMob^.ClientID]
            .AttackerID := Player^.Base.ClientID;

          Player^.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob,
            DataSkill, Tipo);
        end;
      7:
        begin
          Inc(Player^.Base.AttacksAccumulated);

          OtherMob := Player^.Base.GetTargetInList(Packet.Index);
          if OtherMob = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet.Index, MobPid);
            if MobId = -1 then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            OtherMob := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId].MobsP
              [MobPid].Base;
            Player^.Base.AddTargetToList(OtherMob);
          end;

          if OtherMob^.IsDead then
            Exit;

          if not(Servers[Player^.ChannelIndex].RoyalGuards[OtherMob^.ClientID]
            .IsAttacked) then
            Servers[Player^.ChannelIndex].RoyalGuards[OtherMob^.ClientID]
              .FirstPlayerAttacker := Player^.Base.ClientID;
          Servers[Player^.ChannelIndex].RoyalGuards[OtherMob^.ClientID]
            .IsAttacked := True;
          Servers[Player^.ChannelIndex].RoyalGuards[OtherMob^.ClientID]
            .AttackerID := Player^.Base.ClientID;

          Player^.Base.SendDamage(Packet.Skill, Packet.Anim, OtherMob,
            DataSkill, Tipo);
        end;
      8:
        begin

          DefaultCheckBasic(Player);

          if (Packet^.Index <> Player^.Base.ClientID) then
          begin

            MobDungeonID := TMobFuncs.GetMobDgGeralID(Player^.ChannelIndex,
              Packet^.Index, Player^.DungeonInstanceID);

            DungeonMobPointer := @DungeonInstances[Player^.DungeonInstanceID]
              .Mobs[MobDungeonID];
            if DungeonMobPointer^.Base.IsDead then
              Exit;

            if not DungeonInstances[Player^.DungeonInstanceID].Mobs
              [MobDungeonID].IsAttacked then
            begin
              DungeonMobPointer^.IsAttacked := True;
              DungeonMobPointer^.FirstPlayerAttacker := Player^.Base.ClientID;
            end;

            DungeonMobPointer^.AttackerID := Player^.Base.ClientID;

            Player^.Base.SendDamage(Packet^.Skill, Packet^.Anim,
              @DungeonMobPointer^.Base, DataSkill, Tipo);
          end;
        end;

    end;

    Exit;

  end
  else
  begin

    if not ByUseSkill then
    begin
      Tipo := GetTargetType(Packet^.Index, Player^.InDungeon);

      Player^.LastAttackSents := Now;

      if not(CheckItemsDefault(Player)) then
        Exit;

    end;

    if not ByUseSkill and (DataSkill^.CastTime = 0) then
    begin
      if not((DataSkill^.Classe >= 61) and (DataSkill^.Classe <= 84)) or
        (Player^.Base.Character.ClassInfo div 10 <> DataSkill^.Classe div 10)
      then
        Exit;
    end;

    if (DataSkill^.SuccessRate = 1) and (DataSkill^.range > 0) then
    begin
      if DataSkill^.CastTime <= 0 then
      begin
        if not Player^.Base.CheckCooldown2(Packet.Skill) then
          Exit;
      end;

      if (Player^.LastPositionLongSkill.X = 0) or
        (Player^.LastPositionLongSkill.Y = 0) then
        Player^.LastPositionLongSkill := Packet.TargetPos;

      Player^.Base.AreaSkill(Packet.Skill, Packet.Anim, nil,
        Player^.LastPositionLongSkill, DataSkill);
      Exit;
    end;

    if (Packet.Skill > 0) and not Player^.Base.CheckCooldown2(Packet.Skill) then
      Exit;

    Case Tipo of
      1:
        begin

          if Packet^.Index <> Player^.Base.ClientID then
          begin

            TargetPlayer := @Servers[Player.ChannelIndex].Players
              [Packet^.Index];

            if (SecondsBetween(Now, TargetPlayer^.base.RevivedTime) <= 7) then
            begin
              Player^.SendClientMessage('Alvo acabou de nascer.');
              Exit;
            end;


            DefaultCheckSkill(Player, DataSkill);

            if not CheckPlayerAttackConditionsBasic(Player, Packet, TargetPlayer)
            then // anticheats
              Exit;

            if (Player^.Base.Character.Nation = TargetPlayer^.Base.Character.
              Nation) and (Player^.Base.ClientID <> TargetPlayer^.Base.ClientID)
            then
            begin
              Player^.LastAttackSent := Now;
              Player^.AttackingNation := True;
            end;

            if TargetPlayer^.Base.IsDead and (DataSkill^.Index <> 126) then
              Exit;

            Player^.Base.HandleSkill(Packet^.Skill, Packet^.Anim,
              @TargetPlayer^.Base, Packet^.TargetPos, DataSkill, Tipo);
            Inc(Player^.Base.AttacksAccumulated);
            Inc(TargetPlayer^.Base.AttacksReceivedAccumulated);
            Exit;
          end
          else
          begin
            Player^.Base.HandleSkill(Packet^.Skill, Packet^.Anim, @Player^.Base,
              Packet^.TargetPos, DataSkill, Tipo);
            Exit;
          end;

        end;
      2, 6:
        begin

          DefaultCheckSkill(Player, DataSkill);

          NormalMobPointer := Player^.Base.GetTargetInList(Packet^.Index);
          if (NormalMobPointer = nil) then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player.ChannelIndex,
              Packet.Index, MobPid);
            if (MobId = -1) then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            OtherMob := @Servers[Player.ChannelIndex].Mobs.TMobS[MobId].MobsP
              [MobPid].Base;
            Player.Base.AddTargetToList(OtherMob);
          end;

          if not(Servers[Player^.ChannelIndex].Mobs.TMobS
            [NormalMobPointer^.MobId].IsActiveToSpawn) or
            (NormalMobPointer^.IsDead) then
            Exit;

          if not(Servers[Player^.ChannelIndex].Mobs.TMobS
            [NormalMobPointer^.MobId].MobsP[NormalMobPointer^.SecondIndex]
            .IsAttacked) then
            Servers[Player^.ChannelIndex].Mobs.TMobS[NormalMobPointer^.MobId]
              .MobsP[NormalMobPointer^.SecondIndex].FirstPlayerAttacker :=
              Player^.Base.ClientID;

          Servers[Player^.ChannelIndex].Mobs.TMobS[NormalMobPointer^.MobId]
            .MobsP[NormalMobPointer^.SecondIndex].IsAttacked := True;
          Servers[Player^.ChannelIndex].Mobs.TMobS[NormalMobPointer^.MobId]
            .MobsP[NormalMobPointer^.SecondIndex].AttackerID :=
            Player^.Base.ClientID;
          Player^.Base.HandleSkill(Packet^.Skill, Packet^.Anim,
            NormalMobPointer, Packet^.TargetPos, DataSkill, Tipo);
          Inc(Player^.Base.AttacksAccumulated);

        end;
      4:
        begin

          DefaultCheckSkill(Player, DataSkill);

          NormalMobPointer := Player^.Base.GetTargetInList(Packet^.Index);
          if NormalMobPointer = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet^.Index, MobPid);
            if MobId = -1 then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            NormalMobPointer := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId]
              .MobsP[MobPid].Base;
            Player^.Base.AddTargetToList(NormalMobPointer);
          end;

          if (NormalMobPointer^.IsDead) then
            Exit;

          if not(Servers[Player^.ChannelIndex].DevirStones
            [NormalMobPointer^.ClientID].IsAttacked) then
            Servers[Player^.ChannelIndex].DevirStones
              [NormalMobPointer^.ClientID].FirstPlayerAttacker :=
              Player^.Base.ClientID;
          Servers[Player^.ChannelIndex].DevirStones[NormalMobPointer^.ClientID]
            .IsAttacked := True;
          Servers[Player^.ChannelIndex].DevirStones[NormalMobPointer^.ClientID]
            .AttackerID := Player^.Base.ClientID;

          Inc(Player^.Base.AttacksAccumulated);
          Player^.Base.HandleSkill(Packet^.Skill, Packet^.Anim,
            @NormalMobPointer^, Packet^.TargetPos, DataSkill, Tipo);
        end;
      5:
        begin
          DefaultCheckSkill(Player, DataSkill);

          NormalMobPointer := Player^.Base.GetTargetInList(Packet^.Index);
          if NormalMobPointer = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet^.Index, MobPid);
            if MobId = -1 then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            NormalMobPointer := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId]
              .MobsP[MobPid].Base;
            Player^.Base.AddTargetToList(NormalMobPointer);
          end;

          if (NormalMobPointer^.IsDead) then
            Exit;

          if not(Servers[Player^.ChannelIndex].DevirGuards
            [NormalMobPointer^.ClientID].IsAttacked) then
            Servers[Player^.ChannelIndex].DevirGuards
              [NormalMobPointer^.ClientID].FirstPlayerAttacker :=
              Player^.Base.ClientID;
          Servers[Player^.ChannelIndex].DevirGuards[NormalMobPointer^.ClientID]
            .IsAttacked := True;
          Servers[Player^.ChannelIndex].DevirGuards[NormalMobPointer^.ClientID]
            .AttackerID := Player^.Base.ClientID;

          Inc(Player^.Base.AttacksAccumulated);
          Player^.Base.HandleSkill(Packet^.Skill, Packet^.Anim,
            @NormalMobPointer^, Packet^.TargetPos, DataSkill, Tipo);
        end;
      7:
        begin
          DefaultCheckSkill(Player, DataSkill);

          NormalMobPointer := Player^.Base.GetTargetInList(Packet^.Index);
          if NormalMobPointer = nil then
          begin
            MobId := TMobFuncs.GetMobGeralID(Player^.ChannelIndex,
              Packet^.Index, MobPid);
            if MobId = -1 then
            begin
              Logger.Write('retornando -1 no GetMobGeralID mobid',
                TLogType.Error);
              Exit;
            end;
            NormalMobPointer := @Servers[Player^.ChannelIndex].Mobs.TMobS[MobId]
              .MobsP[MobPid].Base;
            Player^.Base.AddTargetToList(NormalMobPointer);
          end;

          if (NormalMobPointer^.IsDead) then
            Exit;

          if not(Servers[Player^.ChannelIndex].RoyalGuards
            [NormalMobPointer^.ClientID].IsAttacked) then
            Servers[Player^.ChannelIndex].RoyalGuards
              [NormalMobPointer^.ClientID].FirstPlayerAttacker :=
              Player^.Base.ClientID;
          Servers[Player^.ChannelIndex].RoyalGuards[NormalMobPointer^.ClientID]
            .IsAttacked := True;
          Servers[Player^.ChannelIndex].RoyalGuards[NormalMobPointer^.ClientID]
            .AttackerID := Player^.Base.ClientID;

          Inc(Player^.Base.AttacksAccumulated);
          Player^.Base.HandleSkill(Packet^.Skill, Packet^.Anim,
            @NormalMobPointer^, Packet^.TargetPos, DataSkill, Tipo);
        end;
      8:
        begin

          DefaultCheckSkill(Player, DataSkill);

          if Packet.Index = Player^.Base.ClientID then
          begin
            OtherMob := @Player^.Base;
            Player^.Base.HandleSkill(Packet.Skill, Packet.Anim, OtherMob,
              Packet.TargetPos, DataSkill, Tipo);
            Exit;
          end
          else
          begin

            MobDungeonID := TMobFuncs.GetMobDgGeralID(Player^.ChannelIndex,
              Packet^.Index, Player^.DungeonInstanceID);

            DungeonMobPointer := @DungeonInstances[Player^.DungeonInstanceID]
              .Mobs[MobDungeonID];
            if DungeonMobPointer^.Base.IsDead then
              Exit;

            if not DungeonInstances[Player^.DungeonInstanceID].Mobs
              [MobDungeonID].IsAttacked then
            begin
              DungeonMobPointer^.IsAttacked := True;
              DungeonMobPointer^.FirstPlayerAttacker := Player^.Base.ClientID;
            end;

            DungeonMobPointer^.AttackerID := Player^.Base.ClientID;

            Player^.Base.HandleSkill(Packet^.Skill, Packet^.Anim,
              @DungeonMobPointer^.Base, Packet^.TargetPos, DataSkill, Tipo);

            Exit;
          end;

        end;

    End;

  end;

  Result := True;
end;

class function TPacketHandlers.RevivePlayer(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  TeleportX, teleportY: word;
  nationMessage: string;
  updateColumn: string;
  Nation: byte;
  currentCityID: byte;
begin
  Result := false;
  if not(Player.Base.IsDead) then
    Exit;

  if Player.TavaEmDG then
  begin

    DungeonInstances[Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID].InstanceOnline := false;
    DungeonInstances[Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID].Index := 0;
    DungeonInstances[Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID].CreateTime := Now;
    DungeonInstances[Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID].Party := nil;
    DungeonInstances[Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID].DungeonID := 0;
    DungeonInstances[Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID].Dificult := 0;
    ZeroMemory(@DungeonInstances[Servers[Player.ChannelIndex].Players
      [Player.Base.ClientID].DungeonInstanceID].Mobs,
      SizeOf(DungeonInstances[Servers[Player.ChannelIndex].Players
      [Player.Base.ClientID].DungeonInstanceID].Mobs));

    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonLobbyIndex := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonLobbyDificult := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID].DungeonID := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonIDDificult := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .InDungeon := false;

    Player.Character.Base.CurrentScore.CurHP :=
      Player.Character.Base.CurrentScore.MaxHp;
    Player.Character.Base.CurrentScore.CurMP :=
      Player.Character.Base.CurrentScore.MaxMp;
    Player.Base.IsDead := false;
    Player.Base.RevivedTime := Now;
    Player.Base.RemoveAllDebuffs;
    Player.Base.ResolutoPoints := 0;
    Player.Base.SendCurrentHPMP;
    Player.TavaEmDG := false;
    Player.Base.ClearTargetList;
    Player.Base.VisibleMobs.Clear;
    Player.Base.VisibleNPCS.Clear;
    Player.Base.VisiblePlayers.Clear;

    if (Player.SavedPos.IsValid) then
      Player.SendPlayerToSavedPosition
    else
      Player.SendPlayerToCityPosition;

    Exit(True);
  end;

  if Player.EquipeEmDG then
  begin

    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonLobbyIndex := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonLobbyDificult := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID].DungeonID := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonIDDificult := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .DungeonInstanceID := 0;
    Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
      .InDungeon := false;

    Player.Character.Base.CurrentScore.CurHP :=
      Player.Character.Base.CurrentScore.MaxHp;
    Player.Character.Base.CurrentScore.CurMP :=
      Player.Character.Base.CurrentScore.MaxMp;
    Player.Base.IsDead := false;
    Player.Base.RevivedTime := Now;
    Player.Base.RemoveAllDebuffs;
    Player.Base.ResolutoPoints := 0;
    Player.Base.SendCurrentHPMP;
    Player.TavaEmDG := false;
    Player.Base.ClearTargetList;
    Player.Base.VisibleMobs.Clear;
    Player.Base.VisibleNPCS.Clear;
    Player.Base.VisiblePlayers.Clear;

    if (Player.SavedPos.IsValid) then
      Player.SendPlayerToSavedPosition
    else
      Player.SendPlayerToCityPosition;
    Exit(True);
  end;

  if (Player.Waiting1 = 2) then
  begin
    currentCityID := Player.GetCurrentCityID;
    Nation := Player.Base.Character.Nation;

    case currentCityID of
      13: // Agros Haima
        begin
          if (Nation = 4) then
          begin
            TeleportX := 2616;
            teleportY := 3550;
          end
          else if (Nation = 5) then
          begin
            TeleportX := 2778;
            teleportY := 3395;
          end;
        end;

      17: // Estádio Elter
        begin
          if (Nation = 4) then
          begin
            TeleportX := 2433;
            teleportY := 3608;
          end
          else if (Nation = 5) then
          begin
            TeleportX := 2434;
            teleportY := 3814;
          end;
        end;

      58: // Academia de Batalha
        begin
          if (Nation = 4) then
          begin
            TeleportX := 1690;
            teleportY := 3418;
          end
          else if (Nation = 5) then
          begin
            TeleportX := 1592;
            teleportY := 3432;
          end;
        end;
    end;

    Player.Teleport(TPosition.Create(TeleportX, teleportY));
    Player.Character.Base.CurrentScore.CurHP :=
      Player.Character.Base.CurrentScore.MaxHp;
    Player.Character.Base.CurrentScore.CurMP :=
      Player.Character.Base.CurrentScore.MaxMp;
    Player.Base.IsDead := false;
    Player.Base.RevivedTime := Now;
    Player.Base.RemoveAllDebuffs;
    Player.Base.ResolutoPoints := 0;
    Player.Base.SendCurrentHPMP;
    Player.Base.AddBuff(9014);
    Exit(True);
  end;

  if Player.Base.InClastleVerus then
  begin
    // Se o jogador está no castelo em Verus, teleportar para a posição de spawn.
    Player.Teleport(Player.Base.PositionSpawnedInCastle);
  end
  else
  begin
    // Verifica se a nação do jogador é diferente da nação do servidor e não é 0
    if (Player.Character.Base.Nation <> 0) and
      (Player.Character.Base.Nation <> Servers[Player.ChannelIndex].NationID)
    then
    begin
      // Verifica se o CityID está entre 18 e 29 e a nação do servidor é 15
      if (Player.GetCurrentCityID in [18 .. 29]) and
        (Servers[Player.ChannelIndex].NationID = 15) then
      begin
        WriteLn('Estou entrando em Leopold, após ter morrido no city id ' +
          IntToStr(Player.GetCurrentCityID));
        Player.Teleport(TPosition.Create(914, 3700));
      end
      else if (Player.GetCurrentCityID = 62) then
      begin
        // Teleportar para Tiamat se não atender às condições de Leopold
        Player.Teleport(TPosition.Create(1486, 1610));
      end
      else
      begin
        // Teleportar para Tiamat se não atender às condições de Leopold
        Player.Teleport(TPosition.Create(2944, 1664));
      end;
    end
    else
    begin
      // Se a nação do jogador for igual à do servidor, retornar para a posição salva.
      Player.SendPlayerToSavedPosition();
    end;
  end;

  // Atualiza HP e MP para 99% do valor atual
  Player.Character.Base.CurrentScore.CurHP :=
    Player.Character.Base.CurrentScore.MaxHp;
  Player.Character.Base.CurrentScore.CurMP :=
    Player.Character.Base.CurrentScore.MaxMp;

  // Define o jogador como vivo e atualiza o tempo de revivido
  Player.Base.IsDead := false;
  Player.Base.RevivedTime := Now;

  // Remove todos os debuffs e zera os pontos de Resoluto
  Player.Base.RemoveAllDebuffs;
  Player.Base.ResolutoPoints := 0;

  // Envia a atualização de HP e MP para o jogador
  Player.Base.SendCurrentHPMP;

  Result := True;
end;

class function TPacketHandlers.CancelSkillLaunching(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  if Player.Base.IsDead then
    Exit;

  Player.Base.SendToVisible(Packet, Packet.Header.Size, false);
end;
{$ENDREGION}
{$REGION 'Friend List'}

class function TPacketHandlers.AddFriendRequest(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TAddFriendRequestPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := false;
  if Packet.Nick = '' then
    Exit;

  if not Servers[Player.ChannelIndex].GetPlayerByName(string(Packet.Nick),
    OtherPlayer) then
  begin
    Player.SendClientMessage('Jogador não encontrado.');
    Exit;
  end;

  if Player.FriendList.Count >= 50 then
  begin
    Player.SendClientMessage('Lista de amigos cheia.');
    Exit;
  end;

  if Player.FriendList.ContainsKey(OtherPlayer.Character.Index) then
  begin
    Player.SendClientMessage('Jogador já adicionado.');
    Exit;
  end;

  if OtherPlayer^.FriendList.Count >= 50 then
  begin
    Player.SendClientMessage('Lista de amigos do usuário cheia.');
    Exit;
  end;

  if (Player.Base.Character.Nation <> 0) and
    (OtherPlayer.Base.Character.Nation <> 0) and
    (Player.Base.Character.Nation <> OtherPlayer.Base.Character.Nation) then
  begin
    Player.SendClientMessage
      ('Não é possível adicionar jogadores de outras nações.');
    Exit;
  end;

  Packet.id := Player.Base.ClientID;
  AnsiStrings.StrCopy(Packet.Nick, Player.Character.Base.Name);
  OtherPlayer^.SendPacket(Packet, Packet.Header.Size);
  Result := True;
end;

class function TPacketHandlers.AddFriendResponse(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TAddFriendResponsePacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := false;
  if (Packet.id = 0) or (Packet.id > MAX_CONNECTIONS) then
    Exit;

  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.id];
  if not OtherPlayer^.Base.IsActive then
  begin
    Player.SendClientMessage('Jogador não encontrado.');
    Exit;
  end;

  if Packet.Response = 0 then
  begin
    OtherPlayer^.SendClientMessage('Pedido de amizade recusado.');
    Exit;
  end;

  case Player.AddFriend(Packet.id) of
    0:
      Result := True;
    1:
      Player.SendClientMessage('Personagem offline ou não existe.');
    2:
      Player.SendClientMessage('Lista de amigos cheia.');
    3:
      Player.SendClientMessage('Lista de amigos do usuário cheia.');
  end;

  if Result then
  begin
    Player.SendClientMessage(PChar('Você aceitou amizade de ' +
      OtherPlayer^.Base.Character.Name));
    OtherPlayer^.SendClientMessage(PChar('Jogador ' + Player.Base.Character.Name
      + ' aceitou seu pedido de amizade.'));
  end;
end;

class function TPacketHandlers.DeleteFriend(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TDeleteFriendPacket absolute Buffer;
begin
  Result := (Packet.CharIndex > 0) and Player.EntityFriend.removeFriend
    (Packet.CharIndex);
end;
{$ENDREGION}
{$REGION 'Friend Chat'}

class function TPacketHandlers.OpenFriendWindow(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TOpenFriendWindowPacket absolute Buffer;
  OtherPlayer: Word;
  OtherServer: BYTE;
  // FriendSlot: BYTE;
begin
  Result := false;
{$OLDTYPELAYOUT ON}
  if not(Player.EntityFriend.getFriend(Packet.CharIndex, OtherPlayer,
    OtherServer)) then
    Exit;
{$OLDTYPELAYOUT OFF}
  if (Player.FriendOpenWindowns.Count >= 6) then
    Exit;
  Player.SendPacket(Packet, Packet.Header.Size);
  Player.FriendOpenWindowns.Add(Packet.WindowIndex, Packet.CharIndex);
  Result := True;
end;

class function TPacketHandlers.SendFriendSay(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSendFriendChatPacket absolute Buffer;
  OtherPlayer: Word;
  OtherServer: BYTE;
  OtherWinIndex: DWORD;
  Key: DWORD;
  friendCharacterId: UInt64;
  I: BYTE;
begin
  Result := false;
  OtherWinIndex := $FF;
{$OLDTYPELAYOUT ON}
  if not(Player.FriendOpenWindowns.TryGetValue(Packet.WindowIndex,
    friendCharacterId)) then
    Exit;
  if not(Player.EntityFriend.getFriend(friendCharacterId, OtherPlayer,
    OtherServer)) then
  begin
    Player.SendClientMessage('O jogador está offline.');
    Exit;
  end;
{$REGION 'Verifica se ajanela ja ta aberta pro outro jogador'}
  if not(Servers[OtherServer].Players[OtherPlayer]
    .FriendOpenWindowns.ContainsValue(Player.Character.Index)) then
  begin
    if (Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.Count >= 6)
    then
      Exit;
    for I := 0 to 5 do
    begin
      if not(Servers[OtherServer].Players[OtherPlayer]
        .FriendOpenWindowns.ContainsKey(I)) then
      begin
        OtherWinIndex := I;
        Break;
      end;
    end;
    if (OtherWinIndex = $FF) then
      Exit;
    Servers[OtherServer].Players[OtherPlayer].FriendOpenWindowns.Add
      (OtherWinIndex, Player.Character.Index);
    Servers[OtherServer].Players[OtherPlayer].OpenFriendWindow(Player.Character.
      Index, OtherWinIndex);
  end
  else
  begin
    for Key in Servers[OtherServer].Players[OtherPlayer]
      .FriendOpenWindowns.Keys do
    begin
      if (Player.Character.Index = Servers[OtherServer].Players[OtherPlayer]
        .FriendOpenWindowns.Items[Key]) then
      begin
        OtherWinIndex := Key;
      end;
    end;
  end;
{$ENDREGION}
  if (OtherWinIndex = $FF) then
    Exit;
  Player.SendPacket(Packet, Packet.Header.Size);
  Packet.Header.Index := Servers[OtherServer].Players[OtherPlayer]
    .Base.ClientID;
  Packet.WindowIndex := OtherWinIndex;
  Servers[OtherServer].Players[OtherPlayer].SendPacket(Packet,
    Packet.Header.Size);
{$OLDTYPELAYOUT OFF}
  Result := True;
end;

class function TPacketHandlers.CloseFriendWindow(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TCloseFriendWindowPacket absolute Buffer;
begin
  Result := false;
  if not(Player.FriendOpenWindowns.ContainsKey(Packet.WindowIndex)) then
    Exit;
  Player.FriendOpenWindowns.Remove(Packet.WindowIndex);
  Result := True;
end;
{$ENDREGION}
{$REGION 'Ver Char Info'}

class function TPacketHandlers.RequestCharInfo(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TRequestCharInfoPacket absolute Buffer;
  OtherPlayer: PPlayer;
  CharName: String;
  id: Word;
  I: Integer;
begin
  Result := false;
  id := 0;
  // Writeln('Packet index request char info' + Player.Base.PranClientID.ToString);
  if (Packet.Index >= 44241) then
  begin
    // Player.ViewPran(Player.Base.PranClientID);
    Result := True;
    Exit;
  end;
  if (Packet.Index >= 0) or (Packet.Index <= MAX_CONNECTIONS) then
  begin
    if Packet.Index <= 0 then
    begin
      CharName := String(Packet.Nick);
      if (Trim(CharName) = '') then
        Exit;

      for I := Low(Servers) to High(Servers) do
      begin
        OtherPlayer := Servers[I].GetPlayer(CharName);

        if (OtherPlayer <> nil) then
          Break;
      end;

      if (OtherPlayer = nil) then
        Exit;
      if (OtherPlayer.SocketClosed) then
        Exit;
      if ((OtherPlayer.Status < Playing) or
        (OtherPlayer.Socket = INVALID_SOCKET)) then
        Exit;
      id := OtherPlayer.Base.ClientID;
    end
    else
    begin
      // inclusão dia 29/07/2024
      if (Packet.Index > 999) then
        Exit;

      OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.Index];

      if (OtherPlayer.SocketClosed) then
        Exit;

      if ((OtherPlayer.Status < Playing) or
        (OtherPlayer.Socket = INVALID_SOCKET)) then
        Exit;

      id := OtherPlayer.Base.ClientID;
    end;
    if not(id = 0) then
    begin
      Player.CharInfoResponse(id);
      TPacketHandlers.SeeInventory(Player, Packet.Index, Buffer);
      // Player.ViewPran(Player.Base.PranClientID);
      if Player.Base.PranClientID > 0 then
        Player.ViewPran(Player.Base.PranClientID, id);

    end;
  end;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Party'}

class function TPacketHandlers.SendParty(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSendPartyPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := false;

  if (Player.Party <> nil) and (Player.Party.Members.Count >= 6) then
  begin
    Player.SendClientMessage('O grupo está cheio.');
    Exit;
  end;

  if (Packet.PlayerIndex > 0) and (Packet.PlayerIndex <= MAX_CONNECTIONS) then
    OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.PlayerIndex]
  else if not Servers[Player.ChannelIndex].GetPlayerByName(string(Packet.Name),
    OtherPlayer) then
    Exit;

  if not OtherPlayer.Base.IsActive or (OtherPlayer.PartyIndex <> 0) then
  begin
    if OtherPlayer.PartyIndex <> 0 then
      Player.SendClientMessage('O jogador já está em um grupo.');
    Exit;
  end;

  if (Player.Base.Character.Nation <> 0) and
    (OtherPlayer.Base.Character.Nation <> 0) and
    (Player.Base.Character.Nation <> OtherPlayer.Base.Character.Nation) then
  begin
    Player.SendClientMessage
      ('Não é possível convidar jogadores de outras nações.');
    Exit;
  end;

  Packet.Header.Index := Packet.PlayerIndex;
  Packet.PlayerIndex := Player.Base.ClientID;
  AnsiStrings.StrLCopy(Packet.Name, Player.Character.Base.Name, 16);
  OtherPlayer.PartyRequester := Player.Base.ClientID;
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

class function TPacketHandlers.AcceptParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TAcceptPartyPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := false;

  if Player.PartyRequester = 0 then
    Exit;

  OtherPlayer := @Servers[Player.ChannelIndex].Players[Player.PartyRequester];

  if not OtherPlayer.Base.IsActive then
    Exit;

  // Remove o jogador do grupo atual, se estiver em um
  if Player.PartyIndex <> 0 then
    Player.Party.RemoveMember(Player.Base.ClientID);

  case Packet.AceptType of
    BOOL_ACCEPT:
      begin
        if OtherPlayer.PartyIndex = 0 then
        begin
          if not TParty.CreateParty(OtherPlayer.Base.ClientID,
            Player.ChannelIndex) then
          begin
            OtherPlayer.SendClientMessage('Não foi possível criar o grupo.');
            Exit;
          end;
        end;

        if not OtherPlayer.Party.AddMember(Player.Base.ClientID) then
          OtherPlayer.SendClientMessage
            ('Não foi possível adicionar o jogador ao grupo.')
        else
          Player.Party.RefreshParty;
      end;
    BOOL_REFUSE:
      OtherPlayer.SendClientMessage
        (AnsiString(Player.Character.Base.Name + ' recusou entrar no grupo.'));
  end;

  Result := True;
end;

class function TPacketHandlers.KickParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TKickPartyPacket absolute Buffer;
  I: Word;
begin
  Result := false;

  if (Player.Party = Nil) then
    Exit;

  if (Packet.PlayerIndex > MAX_CONNECTIONS) then
    Exit;
  if (Player.Base.ClientID = Packet.PlayerIndex) then
  begin
    if (Player.Base.ClientID = Player.Party.Leader) then
    begin
      if (Player.InDungeon) then
      begin
        DungeonInstances[Player.DungeonInstanceID].InstanceOnline := false;
        WriteLn('Status da Instance 6 ' + DungeonInstances
          [Player.DungeonInstanceID].InstanceOnline.ToString);

        DungeonInstances[Player.DungeonInstanceID].Index := 0;
        DungeonInstances[Player.DungeonInstanceID].CreateTime := Now;
        DungeonInstances[Player.DungeonInstanceID].Party := nil;
        DungeonInstances[Player.DungeonInstanceID].DungeonID := 0;
        DungeonInstances[Player.DungeonInstanceID].Dificult := 0;
        ZeroMemory(@DungeonInstances[Player.DungeonInstanceID].Mobs,
          SizeOf(DungeonInstances[Player.DungeonInstanceID].Mobs));

        for I in Player.Party.Members do
        begin
          Servers[Player.ChannelIndex].Players[I].SendClientMessage
            ('O jogador [' + AnsiString(Player.Base.Character.Name) +
            '] era líder do grupo e saiu, todos foram expulsos do calabouço.');

          Servers[Player.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonID := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonIDDificult := 0;
          Servers[Player.ChannelIndex].Players[I].DungeonInstanceID := 0;
          Servers[Player.ChannelIndex].Players[I].InDungeon := false;

          if (Servers[Player.ChannelIndex].Players[I].SavedPos.IsValid) then
            Servers[Player.ChannelIndex].Players[I]
              .Teleport(Servers[Player.ChannelIndex].Players[I].SavedPos)
          else
            Servers[Player.ChannelIndex].Players[I]
              .Teleport(TPosition.Create(3399, 564));
        end;
      end;
    end
    else
    begin
      if (Player.InDungeon) then
      begin
        // Player.DungeonInstanceID
        DungeonInstances[Player.DungeonInstanceID].InstanceOnline := false;
        Player.DungeonLobbyIndex := 0;
        Player.DungeonLobbyDificult := 0;
        Player.DungeonID := 0;
        Player.DungeonIDDificult := 0;
        Player.DungeonInstanceID := 0;
        Player.InDungeon := false;
        WriteLn('Status da Instance 7 ' + DungeonInstances
          [Player.DungeonInstanceID].InstanceOnline.ToString);
        if (Player.SavedPos.IsValid) then
          Player.Teleport(Player.SavedPos)
        else
          Player.Teleport(TPosition.Create(3399, 564));
        // Servers[Player.ChannelIndex].Players[I
        // Servers[Player.ChannelIndex].Players[Player.Party.Leader].SendPlayerToSavedPosition;
        // var TotalPlayers: Integer;
        // TotalPlayers := Length(Player.Party.Members.Count); // Retorna o número de membros
        // if (TotalPlayers = 1) then
        // begin
        // for I in Player.Party.Members do
        // Servers[Player.ChannelIndex].Players[Player.Party.Leader].SendPlayerToSavedPosition;
        // end;

        var
          TotalPlayers, l: Integer;
        begin
          // Obtém a quantidade de jogadores na Party
          TotalPlayers := Player.Party.Members.Count;

          // Itera pelos jogadores na Party
          if TotalPlayers = 1 then
            for I := 0 to TotalPlayers - 1 do
            begin
              // Servers[Player.ChannelIndex].Players[
              // Integer(Player.Party.Members[l]) // Converte o ponteiro para o índice correto
              // ].SendClientMessage(
              // 'O jogador [' + AnsiString(Player.Base.Character.Name) +
              // '] saiu do grupo e foi expulso do calabouço.'
              // );
              Servers[Player.ChannelIndex].Players
                [Integer(Player.Party.Members[l])].SendPlayerToSavedPosition;
            end;
        end;

        for I in Player.Party.Members do
        begin
          Servers[Player.ChannelIndex].Players[I].SendClientMessage
            ('O jogador [' + AnsiString(Player.Base.Character.Name) +
            '] saiu do grupo e foi expulso do calabouço.');

        end;
      end;
    end;

    Player.Party.RemoveMember(Packet.PlayerIndex);

    Player.Party.RefreshParty;
    Player.RefreshParty;
    Result := True;

    Exit;
  end;

  if (Player.Base.ClientID = Player.Party.Leader) then
  begin
    if (Player.InDungeon) then
    begin
      DungeonInstances[Player.DungeonInstanceID].InstanceOnline := false;
      WriteLn('Status da Instance 5 ' + DungeonInstances
        [Player.DungeonInstanceID].InstanceOnline.ToString);
      DungeonInstances[Player.DungeonInstanceID].Index := 0;
      DungeonInstances[Player.DungeonInstanceID].CreateTime := Now;
      DungeonInstances[Player.DungeonInstanceID].Party := nil;
      DungeonInstances[Player.DungeonInstanceID].DungeonID := 0;
      DungeonInstances[Player.DungeonInstanceID].Dificult := 0;
      ZeroMemory(@DungeonInstances[Player.DungeonInstanceID].Mobs,
        SizeOf(DungeonInstances[Player.DungeonInstanceID].Mobs));

      for I in Player.Party.Members do
      begin
        Servers[Player.ChannelIndex].Players[I].SendClientMessage
          ('O jogador [' + AnsiString(Player.Base.Character.Name) +
          '] era líder do grupo e saiu, todos foram expulsos do calabouço.');

        Servers[Player.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonID := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonIDDificult := 0;
        Servers[Player.ChannelIndex].Players[I].DungeonInstanceID := 0;
        Servers[Player.ChannelIndex].Players[I].InDungeon := false;

        if (Servers[Player.ChannelIndex].Players[I].SavedPos.IsValid) then
          Servers[Player.ChannelIndex].Players[I]
            .Teleport(Servers[Player.ChannelIndex].Players[I].SavedPos)
        else
          Servers[Player.ChannelIndex].Players[I]
            .Teleport(TPosition.Create(3399, 564));
      end;
    end;
    // ver aqui para me retirar da party
    Player.Party.RemoveMember(Packet.PlayerIndex);
    Player.Party.RefreshParty;
    Servers[Player.ChannelIndex].Players[Packet.PlayerIndex].RefreshParty;
  end
  else
  begin
    Player.SendClientMessage('Você não é o lider do grupo.');
    Player.RefreshParty;
  end;
  Result := True;
end;

class function TPacketHandlers.DestroyParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TDestroyPartyPacket absolute Buffer;
  I: Word;
begin
  Result := false;
  if not(Player.Base.ClientID = Packet.PlayerIndex) then
    Exit;
  if (Player.Party = Nil) then
    Exit;
  if not(Packet.PlayerIndex = Player.Party.Leader) then
  begin
    Player.SendClientMessage('Você não é o lider do grupo.');
    Player.RefreshParty;
    Exit;
  end;
  if (Player.InDungeon) then
  begin
    DungeonInstances[Player.DungeonInstanceID].Index := 0;
    DungeonInstances[Player.DungeonInstanceID].CreateTime := Now;
    DungeonInstances[Player.DungeonInstanceID].Party := nil;
    DungeonInstances[Player.DungeonInstanceID].DungeonID := 0;
    DungeonInstances[Player.DungeonInstanceID].Dificult := 0;
    ZeroMemory(@DungeonInstances[Player.DungeonInstanceID].Mobs,
      SizeOf(DungeonInstances[Player.DungeonInstanceID].Mobs));
    DungeonInstances[Player.DungeonInstanceID].InstanceOnline := false;
    WriteLn('Status da Instance 8 ' + DungeonInstances[Player.DungeonInstanceID]
      .InstanceOnline.ToString);
    for I in Player.Party.Members do
    begin
      Servers[Player.ChannelIndex].Players[I].SendClientMessage
        ('O jogador [' + AnsiString(Player.Base.Character.Name) +
        '] era líder do grupo e saiu, todos foram expulsos do calabouço.');
      Servers[Player.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonID := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonIDDificult := 0;
      Servers[Player.ChannelIndex].Players[I].DungeonInstanceID := 0;
      Servers[Player.ChannelIndex].Players[I].InDungeon := false;
      Servers[Player.ChannelIndex].Players[I].Teleport
        (TPosition.Create(3450, 690));
    end;
  end;
  Player.Party.DestroyParty(Packet.PlayerIndex);
end;

class function TPacketHandlers.GiveLeaderParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TGiveLeaderPartyPacket absolute Buffer;
begin
  Result := false;
  if (Player.Party = Nil) or (Packet.PlayerIndex > MAX_CONNECTIONS) or
    (Player.Party.Leader <> Player.Base.ClientID) or
    not(Player.Party.Members.Contains(Packet.PlayerIndex)) then
    Exit;

  Player.Party.Leader := Packet.PlayerIndex;
  Player.Party.RefreshParty;
  Result := True;
end;

class function TPacketHandlers.UpdateMemberPosition(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TPartyMemberPositionPacket absolute Buffer;
  Party: PParty;
  OtherPlayer: PPlayer;
begin
  Result := false;

  // if (Player.PartyIndex = 0) or (Player.Party.Members.Count = 1) then
  // Exit;

  Party := @Servers[Player.ChannelIndex].Parties[Player.PartyIndex];
  if not(Party.Members.Contains(Packet.PlayerIndex)) or
    (Packet.PlayerIndex = Player.Base.ClientID) then
    Exit;

  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.PlayerIndex];
  OtherPlayer.SendPositionParty(Player.Base.ClientID);
  Result := True;
end;

class function TPacketHandlers.AddSelfParty(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
begin
  if Player.PartyIndex = 0 then
  begin
    if not TParty.CreateParty(Player.Base.ClientID, Player.ChannelIndex) then
    begin
      Player.SendClientMessage('Não foi possível criar o grupo.');
      Result := True;
      Exit;
    end;
  end
  else
    Player.SendClientMessage('Você já está em um grupo.');

  Player.RefreshParty;
  Result := True;
end;

class function TPacketHandlers.PartyAlocateConfig(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TUpdatePartyAlocate absolute Buffer;
  I: Word;
begin
  Result := false;

  if (Player.PartyIndex = 0) or
    ((Player.Party.InRaid) and not(Player.Party.IsRaidLeader)) or
    not(Player.Party.Leader = Player.Base.ClientID) then
  begin
    if not(Player.Party.Leader = Player.Base.ClientID) then
      Player.SendClientMessage('Você não é o líder do grupo.')
    else if (Player.Party.InRaid) and not(Player.Party.IsRaidLeader) then
      Player.SendClientMessage('Você não é o líder da raid.');

    Player.RefreshParty;
    Exit;
  end;

  Player.Party.ExpAlocate := Packet.ExpAlocate;
  Player.Party.ItemAlocate := Packet.ItemAlocate;

  if not(Player.Party.InRaid) then
    Player.Party.RefreshParty
  else
  begin
    for I := 1 to 3 do
    begin
      if Player.Party.PartyAllied[I] = 0 then
        continue;

      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
        .ExpAlocate := Player.Party.ExpAlocate;
      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
        .ItemAlocate := Player.Party.ItemAlocate;
    end;
    Player.Party.RefreshRaid;
  end;

  Result := True;
end;
{$ENDREGION}
{$REGION 'Raids'}

class function TPacketHandlers.SendRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSendInviteToRaid absolute Buffer;
  OtherPlayer: PPlayer;
begin
  if (Packet.SendTo = 0) or (Packet.SendTo > MAX_CONNECTIONS) or
    (Player.PartyIndex = 0) then
    Exit;

  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.SendTo];

  if (OtherPlayer.Status < Playing) then
  begin
    Player.SendClientMessage('O alvo não está disponível 3.');
    Exit;
  end;

  if (not OtherPlayer.Base.PlayerCharacter.LastPos.InRange(
    (Player.Base.PlayerCharacter.LastPos), 20)) then
  begin
    Player.SendClientMessage('O alvo está muito longe.');
    Exit;
  end;

  if (OtherPlayer.PartyIndex = 0) then
  begin
    Player.SendClientMessage('O alvo não está em grupo.');
    Exit;
  end;

  if (OtherPlayer.Party.Leader <> OtherPlayer.Base.ClientID) then
  begin
    Player.SendClientMessage('O alvo não é lider do outro grupo.');
    Exit;
  end;

  if (OtherPlayer.Party.InRaid) then
  begin
    Player.SendClientMessage('O alvo já está em uma legião.');
    Exit;
  end;

  if (Player.Party.Leader <> Player.Base.ClientID) then
  begin
    Player.SendClientMessage('Você não é lider do seu grupo.');
    Exit;
  end;

  if not Player.Party.IsRaidLeader then
  begin
    Player.SendClientMessage
      ('Seu grupo não pode convidar outros grupos. Peça ao lider da legião.');
    Exit;
  end;

  if (Player.Party.PartyRaidCount >= 4) then
  begin
    Player.SendClientMessage('Sua legião já está completa, com 4 grupos.');
    Exit;
  end;

  if (Player.Base.Character.Nation <> 0) and
    (OtherPlayer.Base.Character.Nation <> 0) and
    (Player.Base.Character.Nation <> OtherPlayer.Base.Character.Nation) then
  begin
    Player.SendClientMessage
      ('Não é possível convidar jogadores de outras nações para a raid.');
    Exit;
  end;

  Packet.Header.Index := Packet.SendTo;
  Packet.SendTo := Player.Base.ClientID;
  OtherPlayer.RaidRequester := Player.Base.ClientID;
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);
  Result := True;
end;

class function TPacketHandlers.AcceptRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TInviteToRaidResponse absolute Buffer;
  OtherPlayer, AnotherPlayer: PPlayer;
  Guild, OtherGuild, OtherGuild2, OtherGuild3: PGuild;
  I: Integer;
  SelfNationID, EmptySlot: Integer;
  newGrade: boolean;
begin
  if Player.AliianceByLegion then
  begin
    Guild := nil;
    OtherGuild := nil;
    OtherGuild2 := nil;
    OtherGuild3 := nil;
    Player.AliianceByLegion := false;
    newGrade := false;

    if (Player.AllianceRequester = 0) or (Player.Status < Playing) then
      Exit;

    OtherPlayer := @Servers[Player.ChannelIndex].Players
      [Player.AllianceRequester];

    case Packet.Accept of
      BOOL_ACCEPT:
        begin
          EmptySlot := 255;
          Guild := @Guilds[Player.Character.GuildSlot];
          OtherGuild := @Guilds[OtherPlayer.Character.GuildSlot];

          for I := 1 to 3 do
          begin
            if OtherGuild.Ally.Guilds[I].Index = 0 then
            begin
              EmptySlot := I;
              Break;
            end;
          end;

          OtherGuild.Ally.Guilds[EmptySlot].Index := Guild.Index;
          System.AnsiStrings.StrPLCopy(OtherGuild.Ally.Guilds[EmptySlot].Name,
            String(Guild.Name), 18);

          case EmptySlot of
            1:
              begin
                if OtherGuild.Ally.Guilds[2].Index <> 0 then
                  OtherGuild2 :=
                    @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
                    (OtherGuild.Ally.Guilds[2].Index)];
                if OtherGuild.Ally.Guilds[3].Index <> 0 then
                  OtherGuild3 :=
                    @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
                    (OtherGuild.Ally.Guilds[3].Index)];
              end;
            2:
              begin
                if OtherGuild.Ally.Guilds[1].Index <> 0 then
                  OtherGuild2 :=
                    @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
                    (OtherGuild.Ally.Guilds[1].Index)];
                if OtherGuild.Ally.Guilds[3].Index <> 0 then
                  OtherGuild3 :=
                    @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
                    (OtherGuild.Ally.Guilds[3].Index)];
              end;
            3:
              begin
                if OtherGuild.Ally.Guilds[1].Index <> 0 then
                  OtherGuild2 :=
                    @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
                    (OtherGuild.Ally.Guilds[1].Index)];
                if OtherGuild.Ally.Guilds[2].Index <> 0 then
                  OtherGuild3 :=
                    @Guilds[Servers[Player.ChannelIndex].GetGuildSlotByID
                    (OtherGuild.Ally.Guilds[2].Index)];
              end;
          end;

          if Guild <> nil then
            Move(OtherGuild.Ally, Guild.Ally, SizeOf(TGuildAlly));
          if OtherGuild2 <> nil then
            Move(OtherGuild.Ally, OtherGuild2.Ally, SizeOf(TGuildAlly));
          if OtherGuild3 <> nil then
            Move(OtherGuild.Ally, OtherGuild3.Ally, SizeOf(TGuildAlly));

          if OtherPlayer.IsMarshal then
          begin
            SelfNationID := OtherPlayer.Character.Base.Nation - 1;
            if Nations[SelfNationID].TacticianGuildID = 0 then
            begin
              Nations[SelfNationID].TacticianGuildID := Guild.Index;
              System.AnsiStrings.StrPLCopy
                (Nations[SelfNationID].Cerco.Defensoras.Estrategista,
                String(Guild.Name), SizeOf(String(Guild.Name)));
            end
            else if Nations[SelfNationID].JudgeGuildID = 0 then
            begin
              Nations[SelfNationID].JudgeGuildID := Guild.Index;
              System.AnsiStrings.StrPLCopy
                (Nations[SelfNationID].Cerco.Defensoras.Juiz,
                String(Guild.Name), SizeOf(String(Guild.Name)));
            end
            else if Nations[SelfNationID].TreasurerGuildID = 0 then
            begin
              Nations[SelfNationID].TreasurerGuildID := Guild.Index;
              System.AnsiStrings.StrPLCopy
                (Nations[SelfNationID].Cerco.Defensoras.Tesoureiro,
                String(Guild.Name), SizeOf(String(Guild.Name)));
            end;
            Nations[SelfNationID].SaveNation;
            newGrade := True;
          end;

          for I := 0 to 127 do
          begin
            if (Guild <> nil) and (Guild.Members[I].Logged) then
            begin
              if Servers[Player.ChannelIndex].GetPlayerByCharIndex
                (Guild.Members[I].CharIndex, AnotherPlayer) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');
                if newGrade then
                begin
                  AnotherPlayer.SendNationInformation;
                  AnotherPlayer.Base.GetCurrentScore;
                  AnotherPlayer.Base.SendRefreshPoint;
                  AnotherPlayer.Base.SendStatus;
                  AnotherPlayer.Base.SendRefreshLevel;
                  AnotherPlayer.Base.SendCurrentHPMP;
                end;
              end;
            end;

            if (OtherGuild <> nil) and (OtherGuild.Members[I].Logged) then
            begin
              if Servers[Player.ChannelIndex].GetPlayerByCharIndex
                (OtherGuild.Members[I].CharIndex, AnotherPlayer) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');
                if newGrade then
                begin
                  AnotherPlayer.SendNationInformation;
                  AnotherPlayer.Base.GetCurrentScore;
                  AnotherPlayer.Base.SendRefreshPoint;
                  AnotherPlayer.Base.SendStatus;
                  AnotherPlayer.Base.SendRefreshLevel;
                  AnotherPlayer.Base.SendCurrentHPMP;
                end;
              end;
            end;

            if (OtherGuild2 <> nil) and (OtherGuild2.Members[I].Logged) then
            begin
              if Servers[Player.ChannelIndex].GetPlayerByCharIndex
                (OtherGuild2.Members[I].CharIndex, AnotherPlayer) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');
                if newGrade then
                begin
                  AnotherPlayer.SendNationInformation;
                  AnotherPlayer.Base.GetCurrentScore;
                  AnotherPlayer.Base.SendRefreshPoint;
                  AnotherPlayer.Base.SendStatus;
                  AnotherPlayer.Base.SendRefreshLevel;
                  AnotherPlayer.Base.SendCurrentHPMP;
                end;
              end;
            end;

            if (OtherGuild3 <> nil) and (OtherGuild3.Members[I].Logged) then
            begin
              if Servers[Player.ChannelIndex].GetPlayerByCharIndex
                (OtherGuild3.Members[I].CharIndex, AnotherPlayer) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage('Sua aliança teve mudanças.');
                if newGrade then
                begin
                  AnotherPlayer.SendNationInformation;
                  AnotherPlayer.Base.GetCurrentScore;
                  AnotherPlayer.Base.SendRefreshPoint;
                  AnotherPlayer.Base.SendStatus;
                  AnotherPlayer.Base.SendRefreshLevel;
                  AnotherPlayer.Base.SendCurrentHPMP;
                end;
              end;
            end;
          end;

          if Guild <> nil then
            TFunctions.SaveGuilds(Guild.Slot);
          if OtherGuild <> nil then
            TFunctions.SaveGuilds(OtherGuild.Slot);
          if OtherGuild2 <> nil then
            TFunctions.SaveGuilds(OtherGuild2.Slot);
          if OtherGuild3 <> nil then
            TFunctions.SaveGuilds(OtherGuild3.Slot);
        end;
      BOOL_REFUSE:
        OtherPlayer.SendClientMessage
          ('O lider da guild escolhida recusou-se a entrar na aliança.');
    end;
  end
  else
  begin
    if (Player.RaidRequester = 0) or (OtherPlayer.Status < Playing) then
      Exit;

    OtherPlayer := @Servers[Player.ChannelIndex].Players[Player.RaidRequester];

    case Packet.Accept of
      BOOL_ACCEPT:
        begin
          if not OtherPlayer.Party.InRaid then
          begin
            if not TParty.CreateRaid(Player.RaidRequester, Player.Base.ClientID,
              Player.ChannelIndex) then
              OtherPlayer.SendClientMessage('Não foi possível criar a raid.')
            else
              OtherPlayer.Party.RefreshParty;
          end
          else
          begin
            if not TParty.AddPartyToRaid(Player.RaidRequester,
              Player.Base.ClientID, Player.ChannelIndex) then
              OtherPlayer.SendClientMessage
                ('Não foi possível adicionar o grupo na raid.')
            else
              OtherPlayer.Party.RefreshParty;
          end;
        end;
      BOOL_REFUSE:
        OtherPlayer.SendClientMessage
          (AnsiString(Player.Character.Base.Name +
          ' recusou entrar na legião.'));
    end;
    Result := True;
  end;
end;

class function TPacketHandlers.ExitRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  I, j, k: BYTE;
  NewPartyID: Word;
begin
  if (Player.Base.PartyId = 0) then
  begin
    Exit;
  end;
  if (Player.Party.InRaid = false) then
  begin
    Exit;
  end;
  if (Player.Party.IsRaidLeader) then
  begin // transferir o lider da raid para outro grupo
    j := 0;
    for I := 1 to 3 do
    begin
      if (Player.Party.PartyAllied[I] = 0) then
        continue;
      if (j = 0) then
      begin
        NewPartyID := Player.Party.PartyAllied[I];
        Servers[Player.ChannelIndex].Parties[NewPartyID].IsRaidLeader := True;
        Inc(j);
      end;
      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
        .PartyRaidCount := Servers[Player.ChannelIndex].Parties
        [Player.Party.PartyAllied[I]].PartyRaidCount - 1;
      for k := 1 to 3 do
      begin
        if (Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
          .PartyAllied[k] = 0) then
          continue;
        if (Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
          .PartyAllied[k] = Player.Party.Index) then
        begin
          Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
            .PartyAllied[k] := 0;
          Break;
        end;
      end;
    end;
    Servers[Player.ChannelIndex].Parties[NewPartyID].RefreshRaid;
    ZeroMemory(@Player.Party.PartyAllied[I],
      SizeOf(Player.Party.PartyAllied[I]));
    Player.Party.InRaid := false;
    Player.Party.PartyRaidCount := 0;
    Player.Party.RaidPartyId := 0;
    Player.Party.RefreshParty;
  end
  else // apenas sair e atualizar pro restante
  begin
    j := 0;
    for I := 1 to 3 do
    begin
      if (Player.Party.PartyAllied[I] = 0) then
        continue;
      if (j = 0) then
      begin
        NewPartyID := Player.Party.PartyAllied[I];
        Inc(j);
      end;
      Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
        .PartyRaidCount := Servers[Player.ChannelIndex].Parties
        [Player.Party.PartyAllied[I]].PartyRaidCount - 1;
      for k := 1 to 3 do
      begin
        if (Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
          .PartyAllied[k] = 0) then
          continue;
        if (Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
          .PartyAllied[k] = Player.Party.Index) then
        begin
          Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[I]]
            .PartyAllied[k] := 0;
          Break;
        end;
      end;
    end;
    Servers[Player.ChannelIndex].Parties[NewPartyID].RefreshRaid;
    ZeroMemory(@Player.Party.PartyAllied[I],
      SizeOf(Player.Party.PartyAllied[I]));
    Player.Party.InRaid := false;
    Player.Party.PartyRaidCount := 0;
    Player.Party.RaidPartyId := 0;
    Player.Party.RefreshParty;
  end;
end;

class function TPacketHandlers.DestroyRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
begin
end;

class function TPacketHandlers.GiveLeaderRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TGiveRaidLeader absolute Buffer;
  OtherPlayer: PPlayer;
  cnt, I: Integer;
begin
  if (Player.PartyIndex = 0) or (Packet.GiveTo = 0) or (not Player.Party.InRaid)
  then
    Exit;

  if not((Player.Party.Leader = Player.Base.ClientID) and
    Player.Party.IsRaidLeader) then
  begin
    Player.SendClientMessage('Você não é o lider da raid.');
    Exit;
  end;

  OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.GiveTo);
  if (OtherPlayer = nil) or (OtherPlayer.PartyIndex = 0) then
  begin
    Player.SendClientMessage('O alvo não está disponível 4.');
    Exit;
  end;

  cnt := 0;
  for I := 1 to 3 do
  begin
    if Player.Party.PartyAllied[I] = OtherPlayer.Party.Index then
    begin
      cnt := I;
      Break;
    end;
  end;

  if (cnt = 0) or (OtherPlayer.Party.Leader <> OtherPlayer.Base.ClientID) then
  begin
    Player.SendClientMessage('O alvo não é o lider do grupo.');
    Exit;
  end;

  Player.Party.IsRaidLeader := false;
  OtherPlayer.Party.IsRaidLeader := True;
  Player.Party.RefreshRaid;
  Result := True;
end;

class function TPacketHandlers.RemoveFromRaid(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
begin
end;
{$ENDREGION}
{$REGION 'PersonalShop'}

class function TPacketHandlers.CreatePersonalShop(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TPersonalShopPacket absolute Buffer;
  I, j: Integer;
  breakis: boolean;
begin

  for I := 0 to 9 do
  begin

    case (ItemList[Player.Base.Character.Inventory[Packet.Shop.Products[I].Slot]
      .Index].UseEffect) of
      12 .. 100:
        begin
          Player.SendClientMessage('Item trocável somente via Leilão');
          Exit;
        end;

    end;
  end;

  if (Player.GetCurrentCityID <> 1) then
    Exit;

  Result := false;
  if (Player.Base.ClientID <> Packet.Shop.Index) then
    Exit;
  if (Packet.Shop.Name <= '') then
    Exit;
  // incluido dia 29/07/2024
  if (Player.Character.TradingWith <> 0) then
    Exit;

  if ((Player.Base.PersonalShop.Index <> 0) or
    (Player.Base.PersonalShopIndex <> 0)) then
    Exit;

  if (Player.OpennedNPC <> 0) then
    Exit;

  if (TPosition.Create(2947, 1664)
    .InRange(Player.Base.PlayerCharacter.LastPos, 10)) then
  begin
    Player.SendClientMessage('Você não pode negociar em guerra.');
    Exit;
  end;

  breakis := false;
  for I := 0 to 9 do
  begin
    if (Packet.Shop.Products[I].Slot = $FFFF) then
      continue;

    if (ItemList[Player.Base.Character.Inventory[Packet.Shop.Products[I].Slot].
      Index].TypeTrade > 0) then
      Packet.Shop.Products[I].Slot := $FFFF;

    for j := 0 to 9 do
    begin
      if (I = j) then
        continue;

      if (Packet.Shop.Products[j].Slot = $FFFF) then
        continue;

      if (Packet.Shop.Products[I].Slot = Packet.Shop.Products[j].Slot) then
      begin
        breakis := True;

        Player.ClosePersonalShop;
        Player.SendClientMessage
          ('Você não pode vender o mesmo item várias vezes.');
        Break;
      end;
    end;

    if (breakis) then
      Break;
  end;

  if (breakis) then
    Exit;

  Move(Packet.Shop, Player.Base.PersonalShop, SizeOf(Packet.Shop));
  Player.Base.SendCreateMob;
  Player.SendPersonalShop(Player.Base.PersonalShop);
end;

class function TPacketHandlers.OpenPersonalShop(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
  BufferNil: ARRAY [0 .. SizeOf(TPersonalShopData) - 1] OF BYTE;
begin
  Result := false;
  if (Packet.Header.Index = Packet.Data) then
    Exit;
  if (Player.GetCurrentCityID <> 1) then
    Exit;

  // Inserido dia 29/07/2024
  if (Packet.Data = 0) then
    Exit;

  if (Player.Character.TradingWith <> 0) then
    Exit;

  if ((Player.Base.PersonalShop.Index <> 0) or
    (Player.Base.PersonalShopIndex <> 0)) then
    Exit;

  if (Player.OpennedNPC <> 0) then
    Exit;

  if (TPosition.Create(2947, 1664)
    .InRange(Player.Base.PlayerCharacter.LastPos, 10)) then
  begin
    Player.SendClientMessage('Você não pode negociar em guerra.');
    Exit;
  end;

  ZeroMemory(@BufferNil, SizeOf(BufferNil));
  if (CompareMem(@Servers[Player.ChannelIndex].Players[Packet.Data]
    .Base.PersonalShop, @BufferNil, SizeOf(BufferNil))) then
    Exit;
  Player.SendPersonalShop(Servers[Player.ChannelIndex].Players[Packet.Data]
    .Base.PersonalShop);
  Player.Base.PersonalShopIndex := Packet.Data;
  Result := True;
end;

class function TPacketHandlers.BuyPersonalShopItem(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TBuyPersonalShopItemPacket absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := false;
  if (Packet.Header.Index = Packet.Index) then
    Exit;
  if (Player.Base.PersonalShopIndex = 0) or
    (Player.Base.PersonalShopIndex <> Packet.Index) then
    Exit;

  // incluido dia 29/07/2024
  if (Player.GetCurrentCityID <> 1) then
    Exit;
  if (Player.Character.TradingWith <> 0) then
    Exit;

  if (Player.OpennedNPC <> 0) then
    Exit;

  if (TPosition.Create(2947, 1664)
    .InRange(Player.Base.PlayerCharacter.LastPos, 10)) then
  begin
    Player.SendClientMessage('Você não pode negociar em guerra.');
    Exit;
  end;

  if (TItemFunctions.GetEmptySlot(Player) = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.Index];
  if CompareMem(@Packet.Product, @OtherPlayer.Base.PersonalShop.Products
    [Packet.Slot], SizeOf(Packet.Product)) then
  begin
    if Packet.Product.Price > Player.Base.Character.Gold then
    begin
      Player.SendClientMessage('Gold insuficiente.');
      Exit;
    end;
    Player.DecGold(Packet.Product.Price);
    TItemFunctions.PutItem(Player, OtherPlayer.Character.Base.Inventory
      [Packet.Product.Slot]);
    OtherPlayer.AddGold(Packet.Product.Price);
    ZeroMemory(@OtherPlayer.Character.Base.Inventory[Packet.Product.Slot],
      SizeOf(TItem));
    OtherPlayer.Base.SendRefreshItemSlot(Packet.Product.Slot, false);
    ZeroMemory(@OtherPlayer.Base.PersonalShop.Products[Packet.Slot],
      SizeOf(TPersonalShopItem));
    Player.SendClientMessage('Item comprado com sucesso.');
    Player.SendPersonalShop(OtherPlayer.Base.PersonalShop);
    OtherPlayer.SendPersonalShop(OtherPlayer.Base.PersonalShop);
    Exit;
  end;
  Player.SendClientMessage('Item inválido.');
end;

class function TPacketHandlers.ClosePersonalShop(var Player: TPlayer;
  var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
begin
  Result := false;

  if (Player.GetCurrentCityID <> 1) then
    Exit;

  // incluido dia 29/07/2024

  if (Player.Character.TradingWith <> 0) then
    Exit;

  if (Player.OpennedNPC <> 0) then
    Exit;

  if (TPosition.Create(2947, 1664)
    .InRange(Player.Base.PlayerCharacter.LastPos, 10)) then
  begin
    Player.SendClientMessage('Você não pode negociar em guerra.');
    Exit;
  end;

  if not(Player.Base.PersonalShopIndex = 0) then
  begin
    Player.Base.PersonalShopIndex := 0;
    Exit;
  end;
  Player.SendData(Packet.Header.Index, Packet.Header.Code, 0);
  if (Packet.Header.Index = Player.Base.PersonalShop.Index) then
  begin
    ZeroMemory(@Player.Base.PersonalShop, SizeOf(TPersonalShopData));
    Player.Base.SendCreateMob;
    Player.Base.SendStatus;
  end;
  Result := True;
end;
{$ENDREGION}
{ Elter }

class function TPacketHandlers.EntrarElter(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TEntrarElter absolute Buffer;
  Posx, Posy: Integer;
  Buffer1: array of BYTE;
  currentMinute, currentSecond: Word;
  Count, j, I: Integer;

begin
  Result := True;
  // WriteLn('entrando na elter');
  Count := 0;

  currentMinute := MinuteOf(Now);
  currentSecond := SecondOf(Now);

  // Verifica se ainda está dentro dos primeiros 225 segundos, mesmo no minuto 4

  if not RegisterElterOld or Servers[3].FinishedCadastro then
  begin
    Player.SendClientMessage('Já passou o horário da elter', 16, 16, 16);
    Exit;
  end;

  // if ((currentMinute >= 3) and not ((currentMinute = 3) and (currentSecond <= 38))) or Servers[3].FinishedCadastro then
  // begin
  // Player.SendClientMessage('Já passou o horário da elter', 16, 16, 16);
  // Exit;
  // end;



  // if not (currentMinute < 3) or not ((currentMinute = 3) and (currentSecond <= 38)) then
  // begin
  // Player.SendClientMessage('Já passou o horário da elter', 16, 16, 16);
  // Exit;
  // end;

  // Verifica se o jogador está no canal correto para sua nação
  if (Player.Base.Character.Nation <> Player.ChannelIndex + 1) and
    not(Player.Base.Character.Level < Elter_Min_Level) then
  begin
    Player.SendClientMessage('Somente no País Lar ou Level ' +
      Elter_Min_Level.ToString);
    Exit;
  end;

  if (Elter_Status = 0) then
    Exit;

  // Verifica se algum IP aparece mais que x vezes
  for I := 0 to IpList.Count - 1 do
  begin
    // Conta quantas vezes o IP aparece na lista
    for j := 0 to IpList.Count - 1 do
    begin
      if IpList[j] = IpList[I] then
        Inc(Count);
    end;
  end;

  if Count > Elter_Max_Players then
  begin
    Player.SendClientMessage('Proibido a entrada de mais que: ' +
      Elter_Max_Players.ToString + ' jogadores POR IP na elter.');
    Exit;
  end;

  IpList.Add(Player.Ip);

  SetLength(Buffer1, SizeOf(TChangeChannelPacket));
  PPacket_F05(@Buffer1[0])^.Header.Size := SizeOf(TChangeChannelPacket);
  PPacket_F05(@Buffer1[0])^.Header.Key := 0;
  PPacket_F05(@Buffer1[0])^.Header.ChkSum := 0;
  PPacket_F05(@Buffer1[0])^.Header.Index := Player.Base.ClientID;
  PPacket_F05(@Buffer1[0])^.Header.Code := $F05;
  PPacket_F05(@Buffer1[0])^.Header.Time := 0;
  PPacket_F05(@Buffer1[0])^.Info1 := 3;
  PPacket_F05(@Buffer1[0])^.TypeChanel := 0;
  TPacketHandlers.ChangeChannel(Player, Buffer1, 50);

end;

class function TPacketHandlers.SeeInventory(var Player: TPlayer; id: Integer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSeeInventory absolute Buffer;
begin
  // Preenche o cabeçalho do pacote
  Packet.Header.Size := SizeOf(TSeeInventory); // Tamanho total do pacote
  Packet.Header.Key := 0; // Chave, pode ser ajustada conforme necessário
  Packet.Header.ChkSum := 0; // Checksum, pode ser calculado
  Packet.Header.Index := Player.Base.ClientID; // ID do cliente
  Packet.Header.Code := $18E; // Código do pacote (0xF05)
  Packet.Header.Time := 0; // Timestamp

  // Copia o inventário e o ouro diretamente para o pacote
  Move(Servers[Player.ChannelIndex].Players[id].Base.Character.Inventory,
    Packet.Inventory, SizeOf(Packet.Inventory));
  Move(Servers[Player.ChannelIndex].Players[id].Base.Character.Gold,
    Packet.Gold, SizeOf(Packet.Gold));

  // Envia o pacote
  Player.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

class function TPacketHandlers.StartFishing(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TStartFishing absolute Buffer;
begin
  Result := false;

  if (Player.IsFishingPoints >= 5) and
    (MinutesBetween(Now, Player.IsFishingDelay) < 10) then
  begin
    Player.SendClientMessage
      ('Você já pescou o limite de vezes nos últimos 10 minutos.');
    Exit;
  end;

  // Se passaram 10 minutos desde a última pesca, reseta o contador
  if (MinutesBetween(Now, Player.IsFishingDelay) >= 10) then
  begin
    Player.IsFishingPoints := 0;
    Player.IsFishingDelay := Now;
  end;

  if ItemList[Player.Base.Character.Equip[6].Index].ItemType <> 1019 then
  begin
    Player.SendClientMessage('Pesca permitida somente com vara de pescar.');
    Player.IsFishing := false;
    Exit;
  end;

  if (ItemList[Player.Base.Character.Equip[15].Index].ItemType = 102) or
    (ItemList[Player.Base.Character.Equip[15].Index].ItemType = 103) then
  begin

    TItemFunctions.DecreaseAmount(@Player.Base.Character.Equip[15], 1);
    Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 15,
      Player.Base.Character.Equip[15], false);
  end
  else
  begin
    Player.IsFishing := false;
    Exit;
  end;

  if (Player.Base.PlayerCharacter.LastPos.X <> 0) and
    (Player.Base.PlayerCharacter.LastPos.Y <> 0) and
    (Abs(Player.Base.PlayerCharacter.LastPos.X - Packet.Position.X) +
    Abs(Player.Base.PlayerCharacter.LastPos.Y - Packet.Position.Y) > 15) then
  begin
    Player.SendClientMessage
      ('Local incompatível com sua posição, tente novamente.');
    Player.IsFishing := false;
    Exit;
  end;

  Randomize;

  Player.FishingRandom1 := RandomRange(1, 51); // Valor entre 100 e 130
  Player.FishingRandom2 := RandomRange(52, 102); // Valor entre 150 e 160

  Packet.Header.Size := SizeOf(TStartFishing);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $362;
  Packet.barX1 := Player.FishingRandom1;
  Packet.barX2 := Player.FishingRandom2;
  Packet.null1 := 0;
  Packet.null2 := 0;
  Player.Base.SendToVisible(Packet, SizeOf(TStartFishing));
  Player.IsFishing := True;
  Player.IsFishingPosition := Packet.Position;
  Result := True;

end;

class function TPacketHandlers.EndFishing(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TEndFishing absolute Buffer;
  Premio, RandomPremio, RandomPercentage: Integer;
begin
  Result := false;

  if not Player.IsFishing then
    Exit;

  if ItemList[Player.Base.Character.Equip[6].Index].ItemType <> 1019 then
  begin
    Player.SendClientMessage('Pesca permitida somente com vara de pescar.');
    Player.IsFishing := false;
    Exit;
  end;

  if (Player.Base.PlayerCharacter.LastPos.X <> 0) and
    (Player.Base.PlayerCharacter.LastPos.Y <> 0) and
    (Abs(Player.Base.PlayerCharacter.LastPos.X - Player.IsFishingPosition.X) +
    Abs(Player.Base.PlayerCharacter.LastPos.Y - Player.IsFishingPosition.Y) > 15)
  then
  begin
    Player.SendClientMessage
      ('Local incompatível com sua posição, tente novamente.');
    Player.IsFishing := false;
    Exit;
  end;

  if (Player.FishingRandom1 <= Packet.Result) and
    (Player.FishingRandom2 >= Packet.Result) then
  begin
    Player.FishingRandom1 := 0;
    Player.FishingRandom2 := 0;
    Randomize; // Inicializa o gerador de números aleatórios
    // RandomPercentage := Random(100) + 1;  // Número entre 1 e 100
    //
    // if RandomPercentage <= 80 then  // 80% de chance de ganhar
    // begin
    RandomPremio := Random(8) + 1; // Sorteia de 1 a 9

    if Packet.Result > 90 then
      Premio := 4189
    else
      case RandomPremio of
        1:
          Premio := 4181;
        2:
          Premio := 4182;
        3:
          Premio := 4183;
        4:
          Premio := 4184;
        5:
          Premio := 4185;
        6:
          Premio := 4186;
        7:
          Premio := 4187;
        8:
          Premio := 4188;
      end;

    Player.SendClientMessage('Parabéns você conseguiu pescar um: ' +
      ItemList[Premio].Name);
    Inc(Player.IsFishingPoints, 1);
    Player.IsFishingDelay := Now;

    // end;

    TItemFunctions.PutItem(Player, Premio, 1);

  end
  else
  begin
    Premio := 5224;
    Player.SendClientMessage('Parabéns você não pescou nada');
  end;



  // if Packet.Result then
  // Exit;

  Packet.Header.Size := SizeOf(TEndFishing);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $363;
  Packet.Result := Premio;
  Player.Base.SendToVisible(Packet, SizeOf(TEndFishing));
  Player.IsFishing := false;
  Result := True;

end;

class function TPacketHandlers.StartF12(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TStartF12 absolute Buffer;
  Packet1: TF12Effect;
  TempoRestanteMinutos: Integer;
begin

  Result := false;

  if (Player.F12TempoRestante <= 1) and (Packet.Status = 1) then
  begin
    Player.SendClientMessage('Sem tempo disponível');
    Exit;
  end;

  if Packet.Status = 1 then
  begin
    Packet.Header.Size := SizeOf(Packet);
    Packet.Header.Index := Player.Base.ClientID;
    Packet.Status := 1;
    Packet.TempoRestante := Player.F12TempoRestante;
    Packet.Unk1 := Player.F12TempoAtivo; // tempo usado
    Packet.Unk2 := 360;
    Player.F12Ativo := True;
    Player.Base.SendPacket(Packet, SizeOf(Packet));
    Packet1.Header.Size := SizeOf(Packet1);
    Packet1.Header.Index := $7535;
    Packet1.ClientID := Player.Base.ClientID;
    Packet1.Header.Code := $114;
    Packet1.EffectId := $15;
    Packet1.Unk := $0;
    Player.Base.SendToVisible(Packet1, SizeOf(Packet1), True);
  end;

  if Packet.Status = 0 then
  begin
    // Player.SendClientMessage('Enviando desativação do F12');
    Packet.Header.Size := SizeOf(Packet);
    Packet.Header.Index := Player.Base.ClientID;
    Packet.Status := 0;
    Packet.TempoRestante := Player.F12TempoRestante;
    Packet.Unk1 := Player.F12TempoAtivo; // tempo usado
    Packet.Unk2 := 360;
    Player.F12Ativo := false;
    Player.Base.SendPacket(Packet, SizeOf(Packet));
    Packet1.Header.Size := SizeOf(Packet1);
    Packet1.Header.Index := $7535;
    Packet1.ClientID := Player.Base.ClientID;
    Packet1.Header.Code := $114;
    Packet1.EffectId := $0;
    Packet1.Unk := $0;
    Player.Base.SendToVisible(Packet1, SizeOf(Packet1), True);
  end;

  Result := True;
end;

class function TPacketHandlers.StartJoquempo(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TJoquempoStart absolute Buffer;
begin
  Result := false;
  Player.SendClientMessage('iniciando o pedra, papel e tesoura.');
  sleep(2000);
  if Packet.Padrao = 0 then
    Player.SendClientMessage('Tipo de escolha: Pedra');

  if Packet.Padrao = 1 then
    Player.SendClientMessage('Tipo de escolha: Papel');

  if Packet.Padrao = 2 then
    Player.SendClientMessage('Tipo de escolha: Tesoura');

  if Packet.Padrao = 3 then
    Player.SendClientMessage('Tipo de escolha: Randomico');

  Player.SendData(Player.Base.ClientID, $233, $21);

  Result := True;
end;

class function TPacketHandlers.UseMountSkill(var Player: PPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TUseMountSkill absolute Buffer;
  SkillUsePacket: TSendSkillUse;
  Buffer1: array of BYTE;
begin
  if not Player.Base.BuffExistsByIndex(163) or
    (Player.Base.Character.Equip[9].Index = 0) then
  begin
    Player.SendClientMessage
      ('O uso dessa habilidade requer estar montado ou com uma montaria equipada');
    Exit(false);
  end;

  if (Packet.SkillID <> 0) and (Packet.SkillID <> 1) then
  begin
    Player.SendClientMessage('Skill ID ' + Packet.SkillID.ToString);
    Player.SendClientMessage('Usando skill de montaria');
    Exit(True);
  end;

  // Preenche o pacote com os valores comuns
  SkillUsePacket.Header.Size := SizeOf(TSendSkillUse);
  SkillUsePacket.Header.Key := 255;
  SkillUsePacket.Header.ChkSum := 0;
  SkillUsePacket.Header.Index := Player.Base.ClientID;
  SkillUsePacket.Header.Code := $320;
  SkillUsePacket.Header.Time := 123;
  SkillUsePacket.Index := Player.Base.ClientID;
  SkillUsePacket.pos := Player.Base.PlayerCharacter.LastPos;

  // Define o SkillID com base no Packet.SkillID

  // case Player.base.Character.Equip[9].index of
  // 1:
  // end;

  if Packet.SkillID = 0 then
    SkillUsePacket.Skill := 6986
  else if Packet.SkillID = 1 then
    SkillUsePacket.Skill := 6987;

  // Prepara o buffer e chama UseSkill
  SetLength(Buffer1, SizeOf(SkillUsePacket));
  Move(SkillUsePacket, Buffer1[0], SizeOf(SkillUsePacket));

  // Chama a UseSkill com o novo buffer
  Result := Self.UseSkill(Player, Buffer1);
end;

{$ENDREGION}
{ TPacketHandlers }

class function TPacketHandlers.KarakAereo(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TKarakAereo absolute Buffer;
  // Mapeia o Buffer para o tipo TKarakAereo
begin

  // Player.SendClientMessage('Acessei a funcao TKarakAereo', 16, 16, 16);
  Result := True;
  Exit;
  var
    I: Integer;
  for I := 0 to High(Buffer) do
  begin
    // Exibe o valor de cada byte, pode modificar conforme o tipo de dado esperado
    WriteLn('Byte ' + I.ToString + ': ' + Buffer[I].ToString);
  end;
  Player.SendClientMessage('Acessei o pacote de Karak', 16, 16, 16);
  // Writeln('Passei por aqui pelo karak');
  Player.SendPacket(Packet, Packet.Header.Size);
  // Envia o pacote para o jogador

  // Cria e inicia a thread para contar até 60 segundos

  Result := True;
end;

{$REGION 'Change Channel'}

class function TPacketHandlers.TeleportLeopold(var Player: TPlayer): boolean;
var
  ChangeChannelToken: TChangeChannelToken;
  OtherChannelid: BYTE;
  Packet: TChangeChannelPacket;
  playerData1: TPlayerData1;
  Ação: byte;
begin
  Result := false;
  Player.CheckInventoryRelic(true);
  //montagem do pacote
  Packet.Header.Size := 20;
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $F05;
  Packet.Info1 := 3;
  Ação:= 100;
  //montagem do pacote

  try
    OtherChannelid := Packet.Info1;
    if not(Assigned(Servers[OtherChannelid])) then
    begin
      Exit;
    end;
    if not(Servers[OtherChannelid].IsActive) then
    begin
      Exit;
    end;
    if (Player.ChannelIndex = OtherChannelid) then
    begin
      Exit;
    end;

    ZeroMemory(@ChangeChannelToken, SizeOf(TChangeChannelToken));
    ChangeChannelToken.CharSlot := Player.SelectedCharacterIndex;
    ChangeChannelToken.ChangeTime := Now;
    ChangeChannelToken.OldChannelID := Player.ChannelIndex;
    ChangeChannelToken.OldClientID := Player.Base.ClientID;
    ChangeChannelToken.PartyTeleport.ChannelId := OtherChannelid;

    ChangeChannelToken.accFromOther := Player.Account;
    ChangeChannelToken.charFromOther := Player.Character;
    ChangeChannelToken.buffFromOther := Player.Base.PlayerCharacter.Buffs;

    if (Player.PartyIndex <> 0) then
    Player.Party.RemoveMember(Player.Base.ClientID);

    Player.DesconectedByOtherChannel := True;
    Packet.TypeChanel := OtherChannelid;
    Packet.Info1 := Player.Account.Header.AccountId;
    Packet.Header.Index := Player.Base.ClientID;

    if not(ChangeChannelList.ContainsKey(Player.Account.Header.AccountId)) then
      ChangeChannelList.Add(Player.Account.Header.AccountId, ChangeChannelToken);


    ChangeChannelOpcode.Remove(Player.Base.Character.Name);
    if not ChangeChannelOpcode.ContainsKey(Player.Base.Character.Name) then
    begin
      playerData1.Name := Player.Base.Character.Name;
      playerData1.Action := Ação; // Defina a ação conforme necessário
      ChangeChannelOpcode.Add(Player.Base.Character.Name, playerData1);
    end;


    sleep(200);
    TFunctions.SavePlayerSecundario(@Player, Player.SelectedCharacterIndex);
    TFunctions.SavePlayerPrincipal(@Player, Player.SelectedCharacterIndex);
    Player.SendPacket(Packet, Packet.Header.Size);
    Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
    Result := True;
  except
    on E: Exception do
    begin
      WriteLn('An error occurred no TeleportLeopold: ' + E.Message);
      Player.SendClientMessage
        ('An error occurred while processing your request.', 0, 0, 0);
    end;
  end;

end;


class function TPacketHandlers.TeleportLakia(var Player: TPlayer): boolean;
var
  ChangeChannelToken: TChangeChannelToken;
  OtherChannelid: BYTE;
  Packet: TChangeChannelPacket;
  playerData1: TPlayerData1;
  Ação: byte;
begin
  Result := false;
  Player.CheckInventoryRelic(true);
  //montagem do pacote
  Packet.Header.Size := 20;
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $F05;
  Packet.Info1 := Player.Base.Character.Nation - 1;
  Ação:= 101;
  //montagem do pacote

  try
    OtherChannelid := Packet.Info1;
    if not(Assigned(Servers[OtherChannelid])) then
    begin
      Exit;
    end;
    if not(Servers[OtherChannelid].IsActive) then
    begin
      Exit;
    end;
    if (Player.ChannelIndex = OtherChannelid) then
    begin
      Exit;
    end;

    ZeroMemory(@ChangeChannelToken, SizeOf(TChangeChannelToken));
    ChangeChannelToken.CharSlot := Player.SelectedCharacterIndex;
    ChangeChannelToken.ChangeTime := Now;
    ChangeChannelToken.OldChannelID := Player.ChannelIndex;
    ChangeChannelToken.OldClientID := Player.Base.ClientID;
    ChangeChannelToken.PartyTeleport.ChannelId := OtherChannelid;

    ChangeChannelToken.accFromOther := Player.Account;
    ChangeChannelToken.charFromOther := Player.Character;
    ChangeChannelToken.buffFromOther := Player.Base.PlayerCharacter.Buffs;

    if (Player.PartyIndex <> 0) then
    Player.Party.RemoveMember(Player.Base.ClientID);

    Player.DesconectedByOtherChannel := True;
    Packet.TypeChanel := OtherChannelid;
    Packet.Info1 := Player.Account.Header.AccountId;
    Packet.Header.Index := Player.Base.ClientID;

    if not(ChangeChannelList.ContainsKey(Player.Account.Header.AccountId)) then
      ChangeChannelList.Add(Player.Account.Header.AccountId, ChangeChannelToken);


    ChangeChannelOpcode.Remove(Player.Base.Character.Name);
    if not ChangeChannelOpcode.ContainsKey(Player.Base.Character.Name) then
    begin
      playerData1.Name := Player.Base.Character.Name;
      playerData1.Action := Ação; // Defina a ação conforme necessário
      ChangeChannelOpcode.Add(Player.Base.Character.Name, playerData1);
    end;


    sleep(200);
    TFunctions.SavePlayerSecundario(@Player, Player.SelectedCharacterIndex);
    TFunctions.SavePlayerPrincipal(@Player, Player.SelectedCharacterIndex);
    Player.SendPacket(Packet, Packet.Header.Size);
    Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
    Result := True;
  except
    on E: Exception do
    begin
      WriteLn('An error occurred no TeleportLakia: ' + E.Message);
      Player.SendClientMessage
        ('An error occurred while processing your request.', 0, 0, 0);
    end;
  end;

end;

class function TPacketHandlers.TeleportOutValhalla(var Player: TPlayer): boolean;
var
  ChangeChannelToken: TChangeChannelToken;
  OtherChannelid: BYTE;
  Packet: TChangeChannelPacket;
  playerData1: TPlayerData1;
  Ação: byte;
begin
  Result := false;
  Player.CheckInventoryRelic(true);
  //montagem do pacote
  Packet.Header.Size := 20;
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $F05;
  Packet.Info1 := 3;
  Ação:= 102;
  //montagem do pacote

  try
    OtherChannelid := Packet.Info1;
    if not(Assigned(Servers[OtherChannelid])) then
    begin
      Exit;
    end;
    if not(Servers[OtherChannelid].IsActive) then
    begin
      Exit;
    end;
    if (Player.ChannelIndex = OtherChannelid) then
    begin
      Exit;
    end;

    ZeroMemory(@ChangeChannelToken, SizeOf(TChangeChannelToken));
    ChangeChannelToken.CharSlot := Player.SelectedCharacterIndex;
    ChangeChannelToken.ChangeTime := Now;
    ChangeChannelToken.OldChannelID := Player.ChannelIndex;
    ChangeChannelToken.OldClientID := Player.Base.ClientID;
    ChangeChannelToken.PartyTeleport.ChannelId := OtherChannelid;

    ChangeChannelToken.accFromOther := Player.Account;
    ChangeChannelToken.charFromOther := Player.Character;
    ChangeChannelToken.buffFromOther := Player.Base.PlayerCharacter.Buffs;

    if (Player.PartyIndex <> 0) then
    Player.Party.RemoveMember(Player.Base.ClientID);

    Player.DesconectedByOtherChannel := True;
    Packet.TypeChanel := OtherChannelid;
    Packet.Info1 := Player.Account.Header.AccountId;
    Packet.Header.Index := Player.Base.ClientID;

    if not(ChangeChannelList.ContainsKey(Player.Account.Header.AccountId)) then
      ChangeChannelList.Add(Player.Account.Header.AccountId, ChangeChannelToken);


    ChangeChannelOpcode.Remove(Player.Base.Character.Name);
    if not ChangeChannelOpcode.ContainsKey(Player.Base.Character.Name) then
    begin
      playerData1.Name := Player.Base.Character.Name;
      playerData1.Action := Ação; // Defina a ação conforme necessário
      ChangeChannelOpcode.Add(Player.Base.Character.Name, playerData1);
    end;


    sleep(200);
    TFunctions.SavePlayerSecundario(@Player, Player.SelectedCharacterIndex);
    TFunctions.SavePlayerPrincipal(@Player, Player.SelectedCharacterIndex);
    Player.SendPacket(Packet, Packet.Header.Size);
    Servers[Player.ChannelIndex].Disconnect(Player);
    Player.SocketClosed := True;
    Result := True;
  except
    on E: Exception do
    begin
      WriteLn('An error occurred no TeleportLakia: ' + E.Message);
      Player.SendClientMessage
        ('An error occurred while processing your request.', 0, 0, 0);
    end;
  end;

end;

class function TPacketHandlers.ChangeChannelOther(var Player: TPlayer;
  var Packet: TChangeChannelPacket; Ação: Integer = 0): boolean;
var
  ChangeChannelToken: TChangeChannelToken;
  ChangeTokenIndParty: TChangeChannelToken;
  I, j, k: Integer;
  OtherChannelid: BYTE;
  FWaiting: Integer;
  pos: TPosition;
  Resultado: boolean;
  // Mudando: TMudandoCanal;
begin
  Resultado := false;

  Player.CheckInventoryRelic(true);

  if Player.PartyIndex <> 0 then
  begin
    if (Packet.Info1 = 3) then // acesso a leopold
    begin
      if (Ação = 0) then
      begin
        if Player.PartyIndex <> 0 then
          Player.Party.RemoveMember(Player.Base.ClientID);

        Resultado := false;
        for I := 0 to 119 do
        begin
          if (Player.Base.Character.Inventory[I].Index = 8080) or
            (Player.Base.Character.Inventory[I].Index = 8451) then
          begin
            Resultado := True;
            Break; // Sai do loop assim que encontrar o item
          end;
        end;

        if Resultado then
          Ação := 100
        else
        begin
          Player.SendClientMessage
            ('Necessário o item de teleporte para iniciar o teleporte para Leopold');
          Result := false;
          Exit;
        end;
      end;
    end;
  end;
  Result := false;

  try
    OtherChannelid := Packet.Info1;
    if not(Assigned(Servers[OtherChannelid])) then
    begin
      // Writeln('Erro: Canal destino não é válido. ERR_1.');
      // Player.SendClientMessage('Canal destino não válido. ERR_1.');
      Exit;
    end;
    if not(Servers[OtherChannelid].IsActive) then
    begin
      // Writeln('Erro: Canal destino não é válido. ERR_2.');
      // Player.SendClientMessage('Canal destino não válido. ERR_2.');
      Exit;
    end;
    if (Player.ChannelIndex = OtherChannelid) then
    begin
      // Writeln('Erro: Canal destino não é válido. ERR_3.');
      // Player.SendClientMessage('Canal destino não válido. ERR_3.');
      Exit;
    end;



    // Writeln('Preparando troca de canal...');

    ZeroMemory(@ChangeChannelToken, SizeOf(TChangeChannelToken));
    ChangeChannelToken.CharSlot := Player.SelectedCharacterIndex;
    ChangeChannelToken.ChangeTime := Now;
    ChangeChannelToken.OldChannelID := Player.ChannelIndex;
    ChangeChannelToken.OldClientID := Player.Base.ClientID;
    ChangeChannelToken.PartyTeleport.ChannelId := OtherChannelid;

    ChangeChannelToken.accFromOther := Player.Account;
    ChangeChannelToken.charFromOther := Player.Character;
    ChangeChannelToken.buffFromOther := Player.Base.PlayerCharacter.Buffs;

    if (Player.PartyIndex <> 0) then
    begin
      // Writeln('Jogador está em um grupo.');
      if (Player.Party.Leader = Player.Base.ClientID) then
      begin
        if (Player.Party.PartyRaidCount > 1) then
        begin

          if not(Player.Party.IsRaidLeader) then
          begin
{$REGION APENAS UM MEMBRO E ESTÁ EM RAID}
            ChangeChannelToken.PartyTeleport.RequestId :=
              Player.Party.RequestId;
            ChangeChannelToken.PartyTeleport.ExpAlocate :=
              Player.Party.ExpAlocate;
            ChangeChannelToken.PartyTeleport.ItemAlocate :=
              Player.Party.ItemAlocate;
            ChangeChannelToken.PartyTeleport.LastSlotItemReceived :=
              Player.Party.LastSlotItemReceived;
            ChangeChannelToken.PartyTeleport.InRaid := false;
            ChangeChannelToken.PartyTeleport.IsRaidLeader := True;
            ChangeChannelToken.PartyTeleport.PartyRaidCount :=
              Player.Party.PartyRaidCount;
            ChangeChannelToken.PartyTeleport.MemberName := TList<BYTE>.Create;
            ChangeChannelToken.AccountStatus := 0;

            for j in Player.Party.Members do
            begin
              if not(Servers[Player.ChannelIndex].Players[j]
                .Base.PlayerCharacter.LastPos.InRange(TPosition.Create(2947,
                1664), 15)) then
              begin
                WriteLn('fora do range');
                Player.Party.RemoveMember(j);
                continue;
              end;
              if not(j = Player.Party.Leader) then
              begin
                Packet.TypeChanel := OtherChannelid;
                Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId;
                Packet.Header.Index := j;
                Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                  Packet.Header.Size);
                Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
            end;
            for j in Player.Party.Members do
            begin
              if not(ChangeChannelToken.PartyTeleport.MemberName.Contains
                (Servers[Player.ChannelIndex].Players[j]
                .Base.Character.CharIndex)) then
                ChangeChannelToken.PartyTeleport.MemberName.Add
                  (Servers[Player.ChannelIndex].Players[j]
                  .Base.Character.CharIndex);
              Servers[Player.ChannelIndex].Players[j]
                .DesconectedByOtherChannel := True;
              if not(j = Player.Party.Leader) then
              begin // mandar informação de telar pros outros
                Randomize;
                Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.LastPos := TPosition.Create(2947, 1664);
                ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
                ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                  .Players[j].SelectedCharacterIndex;
                ChangeTokenIndParty.ChangeTime := Now;
                ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                  .Players[j].Base.ClientID;
                ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                ChangeTokenIndParty.AccountStatus := 0;
                ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                  .Players[j].Account;
                ChangeTokenIndParty.charFromOther :=
                  Servers[Player.ChannelIndex].Players[j].Character;
                ChangeTokenIndParty.buffFromOther :=
                  Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.Buffs;
                if (Servers[Player.ChannelIndex].Players[j]
                  .CheckGameMasterLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 1;
                end;
                if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged)
                then
                begin
                  ChangeTokenIndParty.AccountStatus := 2;
                end;
                if not(ChangeChannelList.ContainsKey
                  (Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId)) then
                begin
                  ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                    .Account.Header.AccountId, ChangeTokenIndParty);
                end;

              end;
            end;
{$ENDREGION}
          end
          else
          begin
{$REGION É PARTY LEADER E ESTÁ EM RAID}
            ChangeChannelToken.PartiesTeleport[0].RequestId :=
              Player.Party.RequestId;
            ChangeChannelToken.PartiesTeleport[0].ExpAlocate :=
              Player.Party.ExpAlocate;
            ChangeChannelToken.PartiesTeleport[0].ItemAlocate :=
              Player.Party.ItemAlocate;
            ChangeChannelToken.PartiesTeleport[0].LastSlotItemReceived :=
              Player.Party.LastSlotItemReceived;
            ChangeChannelToken.PartiesTeleport[0].InRaid := True;
            ChangeChannelToken.PartiesTeleport[0].IsRaidLeader := True;
            ChangeChannelToken.PartiesTeleport[0].PartyRaidCount :=
              Player.Party.PartyRaidCount;
            ChangeChannelToken.PartiesLeader[0] :=
              Player.Base.Character.CharIndex;
            ChangeChannelToken.PartiesTeleport[0].MemberName :=
              TList<BYTE>.Create;
            ChangeChannelToken.AccountStatus := 0;
            if (Player.CheckGameMasterLogged) then
            begin
              ChangeChannelToken.AccountStatus := 1;
            end;
            if (Player.CheckAdminLogged) then
            begin
              ChangeChannelToken.AccountStatus := 2;
            end;
            for j in Player.Party.Members do
            begin
              if not(Servers[Player.ChannelIndex].Players[j]
                .Base.PlayerCharacter.LastPos.InRange(TPosition.Create(2947,
                1664), 15)) then
              begin
                Player.Party.RemoveMember(j);
                continue;
              end;
              if not(j = Player.Party.Leader) then
              begin
                Packet.TypeChanel := OtherChannelid;
                Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId;
                Packet.Header.Index := j;
                Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                  Packet.Header.Size);
                Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
            end;
            for j in Player.Party.Members do
            begin
              if not(ChangeChannelToken.PartiesTeleport[0].MemberName.Contains
                (Servers[Player.ChannelIndex].Players[j]
                .Base.Character.CharIndex)) then
                ChangeChannelToken.PartiesTeleport[0].MemberName.Add
                  (Servers[Player.ChannelIndex].Players[j]
                  .Base.Character.CharIndex);
              Servers[Player.ChannelIndex].Players[j]
                .DesconectedByOtherChannel := True;
              if not(j = Player.Party.Leader) then
              begin // mandar informação de telar pros outros
                Randomize;
                Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.LastPos := TPosition.Create(2947, 1664);
                ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
                ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                  .Players[j].SelectedCharacterIndex;
                ChangeTokenIndParty.ChangeTime := Now;
                ChangeTokenIndParty.AccountStatus := 0;
                ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                  .Players[j].Base.ClientID;
                ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                  .Players[j].Account;
                ChangeTokenIndParty.charFromOther :=
                  Servers[Player.ChannelIndex].Players[j].Character;
                ChangeTokenIndParty.buffFromOther :=
                  Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.Buffs;
                if (Servers[Player.ChannelIndex].Players[j]
                  .CheckGameMasterLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 1;
                end;
                if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged)
                then
                begin
                  ChangeTokenIndParty.AccountStatus := 2;
                end;
                if not(ChangeChannelList.ContainsKey
                  (Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId)) then
                begin
                  ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                    .Account.Header.AccountId, ChangeTokenIndParty);
                end;
              end;
            end;
            for k := 1 to 3 do
            begin
              if (Player.Party.PartyAllied[k] = 0) then
                continue;
              ChangeChannelToken.PartiesTeleport[k].RequestId :=
                Player.Party.RequestId;
              ChangeChannelToken.PartiesTeleport[k].ExpAlocate :=
                Player.Party.ExpAlocate;
              ChangeChannelToken.PartiesTeleport[k].ItemAlocate :=
                Player.Party.ItemAlocate;
              ChangeChannelToken.PartiesTeleport[k].LastSlotItemReceived :=
                Player.Party.LastSlotItemReceived;
              ChangeChannelToken.PartiesTeleport[k].InRaid := True;
              ChangeChannelToken.PartiesTeleport[k].IsRaidLeader := false;
              ChangeChannelToken.PartiesTeleport[k].PartyRaidCount :=
                Player.Party.PartyRaidCount;
              ChangeChannelToken.PartiesTeleport[k].MemberName :=
                TList<BYTE>.Create;
              for j in Servers[Player.ChannelIndex].Parties
                [Player.Party.PartyAllied[k]].Members do
              begin
                if not(Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.LastPos.InRange
                  (Player.Base.PlayerCharacter.LastPos, 15)) then
                begin
                  Servers[Player.ChannelIndex].Parties
                    [Player.Party.PartyAllied[k]].RemoveMember(j);
                  continue;
                end;

                Packet.TypeChanel := OtherChannelid;
                Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId;
                Packet.Header.Index := j;
                Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                  Packet.Header.Size);
                Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
              for j in Servers[Player.ChannelIndex].Parties
                [Player.Party.PartyAllied[k]].Members do
              begin
                if not(ChangeChannelToken.PartiesTeleport[k].MemberName.Contains
                  (Servers[Player.ChannelIndex].Players[j]
                  .Base.Character.CharIndex)) then
                  ChangeChannelToken.PartiesTeleport[k].MemberName.Add
                    (Servers[Player.ChannelIndex].Players[j]
                    .Base.Character.CharIndex);
                ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
                ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                  .Players[j].SelectedCharacterIndex;
                ChangeTokenIndParty.ChangeTime := Now;
                ChangeTokenIndParty.AccountStatus := 0;
                ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                  .Players[j].Base.ClientID;
                ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                  .Players[j].Account;
                ChangeTokenIndParty.charFromOther :=
                  Servers[Player.ChannelIndex].Players[j].Character;
                ChangeTokenIndParty.buffFromOther :=
                  Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.Buffs;
                if (Servers[Player.ChannelIndex].Players[j]
                  .CheckGameMasterLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 1;
                end;
                if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged)
                then
                begin
                  ChangeTokenIndParty.AccountStatus := 2;
                end;
                Servers[Player.ChannelIndex].Players[j]
                  .DesconectedByOtherChannel := True;
                if (j = Servers[Player.ChannelIndex].Parties
                  [Player.Party.PartyAllied[k]].Leader) then
                begin
                  ChangeChannelToken.PartiesLeader[k] :=
                    Servers[Player.ChannelIndex].Players[j]
                    .Base.Character.CharIndex;
                end
                else
                begin
                  Randomize;
                  Servers[Player.ChannelIndex].Players[j]
                    .Base.PlayerCharacter.LastPos :=
                    Servers[Player.ChannelIndex].Players
                    [Servers[Player.ChannelIndex].Parties
                    [Player.Party.PartyAllied[k]].Leader].Base.Neighbors
                    [RandomRange(0, 8)].pos;
                end;
                if not(ChangeChannelList.ContainsKey
                  (Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId)) then
                begin
                  ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                    .Account.Header.AccountId, ChangeTokenIndParty);
                end;

              end;
{$ENDREGION}
            end;
          end;
        end
        else
        begin
{$REGION EM GRUPO NÃO EM RAID}
          ChangeChannelToken.PartyTeleport.RequestId := Player.Party.RequestId;
          ChangeChannelToken.PartyTeleport.ExpAlocate :=
            Player.Party.ExpAlocate;
          ChangeChannelToken.PartyTeleport.ItemAlocate :=
            Player.Party.ItemAlocate;
          ChangeChannelToken.PartyTeleport.LastSlotItemReceived :=
            Player.Party.LastSlotItemReceived;
          ChangeChannelToken.PartyTeleport.InRaid := false;
          ChangeChannelToken.PartyTeleport.IsRaidLeader := True;
          ChangeChannelToken.PartyTeleport.PartyRaidCount :=
            Player.Party.PartyRaidCount;
          ChangeChannelToken.PartyTeleport.MemberName := TList<BYTE>.Create;
          ChangeChannelToken.AccountStatus := 0;
          if (Player.CheckGameMasterLogged) then
          begin
            ChangeChannelToken.AccountStatus := 1;
          end;
          if (Player.CheckAdminLogged) then
          begin
            ChangeChannelToken.AccountStatus := 2;
          end;
          for j in Player.Party.Members do
          begin
            if not(Servers[Player.ChannelIndex].Players[j]
              .Base.PlayerCharacter.LastPos.InRange(TPosition.Create(2947,
              1664), 15)) then
            begin
              Player.Party.RemoveMember(j);
              continue;
            end;
            if not(j = Player.Party.Leader) then
            begin
              Packet.TypeChanel := OtherChannelid;
              Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                .Account.Header.AccountId;
              Packet.Header.Index := j;
              Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                Packet.Header.Size);
              Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
            end;
          end;
          for j in Player.Party.Members do
          begin
            if not(ChangeChannelToken.PartyTeleport.MemberName.Contains
              (Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex))
            then
              ChangeChannelToken.PartyTeleport.MemberName.Add
                (Servers[Player.ChannelIndex].Players[j]
                .Base.Character.CharIndex);
            Servers[Player.ChannelIndex].Players[j]
              .DesconectedByOtherChannel := True;
            if not(j = Player.Party.Leader) then
            begin // mandar informação de telar pros outros
              Randomize;
              Servers[Player.ChannelIndex].Players[j]
                .Base.PlayerCharacter.LastPos := TPosition.Create(2947, 1664);
              ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
              ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                .Players[j].SelectedCharacterIndex;
              ChangeTokenIndParty.ChangeTime := Now;
              ChangeTokenIndParty.AccountStatus := 0;
              ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                .Players[j].Base.ClientID;
              ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
              ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                .Players[j].Account;
              ChangeTokenIndParty.charFromOther := Servers[Player.ChannelIndex]
                .Players[j].Character;
              ChangeTokenIndParty.buffFromOther := Servers[Player.ChannelIndex]
                .Players[j].Base.PlayerCharacter.Buffs;
              if (Servers[Player.ChannelIndex].Players[j].CheckGameMasterLogged)
              then
              begin
                ChangeTokenIndParty.AccountStatus := 1;
              end;
              if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged) then
              begin
                ChangeTokenIndParty.AccountStatus := 2;
              end;
              if not(ChangeChannelList.ContainsKey(Servers[Player.ChannelIndex]
                .Players[j].Account.Header.AccountId)) then
              begin
                ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId, ChangeTokenIndParty);
              end;
            end;
          end;

{$ENDREGION}
        end;
      end;
    end
    else
    begin
      // Writeln('Jogador não está em um grupo.');
      Player.DesconectedByOtherChannel := True;
    end;
    // Writeln('Finalizando troca de canal...');
    Packet.TypeChanel := OtherChannelid;
    Packet.Info1 := Player.Account.Header.AccountId;
    Packet.Header.Index := Player.Base.ClientID;
    if not(ChangeChannelList.ContainsKey(Player.Account.Header.AccountId)) then
    begin
      // Writeln('Adicionando jogador à lista de troca.');
      ChangeChannelList.Add(Player.Account.Header.AccountId,
        ChangeChannelToken);
    end;
    // Writeln('Enviando pacote de troca para o jogador...');
    ChangeChannelOpcode.Remove(Player.Base.Character.Name);
    if not ChangeChannelOpcode.ContainsKey(Player.Base.Character.Name) then
    begin
      var
        playerData1: TPlayerData1;
      playerData1.Name := Player.Base.Character.Name;
      playerData1.Action := Ação; // Defina a ação conforme necessário
      ChangeChannelOpcode.Add(Player.Base.Character.Name, playerData1);
    end;


    // SMudandoCanal.Nome := Player.Base.Character.Name;
    // if not MudandoCanal.ContainsKey(Player.Base.Character.Name) then
    // begin
    // MudandoCanal.add(Player.Base.Character.Name, SMudandoCanal);
    // Player.ChangingChannel:= true;
    // Player.SendClientMessage('mudando de canal');
    // end;

    sleep(200);
//    Player.SaveInGame(Player.SelectedCharacterIndex);
    TFunctions.SavePlayerSecundario(@Player, Player.SelectedCharacterIndex);
//    Player.SaveInGamePrincipal(Player.SelectedCharacterIndex);
    TFunctions.SavePlayerPrincipal(@Player, Player.SelectedCharacterIndex);
    Player.SendPacket(Packet, Packet.Header.Size);
        Servers[Player.ChannelIndex].Disconnect(Player);

    Player.SocketClosed := True;
    Result := True;
  except
    on E: Exception do
    begin
      WriteLn('An error occurred: ' + E.Message);
      Player.SendClientMessage
        ('An error occurred while processing your request.', 0, 0, 0);
    end;
  end;

end;

class function TPacketHandlers.ChangeChannel(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE; Ação: Integer = 0): boolean;
var
  Packet: TChangeChannelPacket absolute Buffer;
  ChangeChannelToken: TChangeChannelToken;
  ChangeTokenIndParty: TChangeChannelToken;
  I, j, k: Integer;
  OtherChannelid: BYTE;
  FWaiting: Integer;
  pos: TPosition;
  Resultado: boolean;
begin
  Resultado := false;
  Player.CheckInventoryRelic(true);
  if Player.PartyIndex <> 0 then
  begin
    if (Packet.Info1 = 3) then // acesso a leopold
    begin
      if (Ação = 0) then
      begin
        if Player.PartyIndex <> 0 then
          Player.Party.RemoveMember(Player.Base.ClientID);

        Resultado := false;
        for I := 0 to 119 do
        begin
          if (Player.Base.Character.Inventory[I].Index = 8080) or
            (Player.Base.Character.Inventory[I].Index = 8451) then
          begin
            Resultado := True;
            Break; // Sai do loop assim que encontrar o item
          end;
        end;

        if Resultado then
          Ação := 100
        else
        begin
          Player.SendClientMessage
            ('Necessário o item de teleporte para iniciar o teleporte para Leopold');
          Result := false;
          Exit;
        end;
      end;
    end;
  end;
  Result := false;


  try
    OtherChannelid := Packet.Info1;
    if not(Assigned(Servers[OtherChannelid])) or not(Servers[OtherChannelid].IsActive) or (Player.ChannelIndex = OtherChannelid) then
      Exit;




    // Writeln('Preparando troca de canal...');

    ZeroMemory(@ChangeChannelToken, SizeOf(TChangeChannelToken));
    ChangeChannelToken.CharSlot := Player.SelectedCharacterIndex;
    ChangeChannelToken.ChangeTime := Now;
    ChangeChannelToken.OldChannelID := Player.ChannelIndex;
    ChangeChannelToken.OldClientID := Player.Base.ClientID;
    ChangeChannelToken.PartyTeleport.ChannelId := OtherChannelid;

    ChangeChannelToken.accFromOther := Player.Account;
    ChangeChannelToken.charFromOther := Player.Character;
    ChangeChannelToken.buffFromOther := Player.Base.PlayerCharacter.Buffs;

    if (Player.PartyIndex <> 0) then
    begin
      // Writeln('Jogador está em um grupo.');
      if (Player.Party.Leader = Player.Base.ClientID) then
      begin
        if (Player.Party.PartyRaidCount > 1) then
        begin

          if not(Player.Party.IsRaidLeader) then
          begin
{$REGION APENAS UM MEMBRO E ESTÁ EM RAID}
            ChangeChannelToken.PartyTeleport.RequestId :=
              Player.Party.RequestId;
            ChangeChannelToken.PartyTeleport.ExpAlocate :=
              Player.Party.ExpAlocate;
            ChangeChannelToken.PartyTeleport.ItemAlocate :=
              Player.Party.ItemAlocate;
            ChangeChannelToken.PartyTeleport.LastSlotItemReceived :=
              Player.Party.LastSlotItemReceived;
            ChangeChannelToken.PartyTeleport.InRaid := false;
            ChangeChannelToken.PartyTeleport.IsRaidLeader := True;
            ChangeChannelToken.PartyTeleport.PartyRaidCount :=
              Player.Party.PartyRaidCount;
            ChangeChannelToken.PartyTeleport.MemberName := TList<BYTE>.Create;
            ChangeChannelToken.AccountStatus := 0;

            for j in Player.Party.Members do
            begin
              if not(Servers[Player.ChannelIndex].Players[j]
                .Base.PlayerCharacter.LastPos.InRange(TPosition.Create(2947,
                1664), 15)) then
              begin
                WriteLn('fora do range');
                Player.Party.RemoveMember(j);
                continue;
              end;
              if not(j = Player.Party.Leader) then
              begin
                Packet.TypeChanel := OtherChannelid;
                Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId;
                Packet.Header.Index := j;
                Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                  Packet.Header.Size);
                Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
            end;
            for j in Player.Party.Members do
            begin
              if not(ChangeChannelToken.PartyTeleport.MemberName.Contains
                (Servers[Player.ChannelIndex].Players[j]
                .Base.Character.CharIndex)) then
                ChangeChannelToken.PartyTeleport.MemberName.Add
                  (Servers[Player.ChannelIndex].Players[j]
                  .Base.Character.CharIndex);
              Servers[Player.ChannelIndex].Players[j]
                .DesconectedByOtherChannel := True;
              if not(j = Player.Party.Leader) then
              begin // mandar informação de telar pros outros
                Randomize;
                Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.LastPos := TPosition.Create(2947, 1664);
                ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
                ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                  .Players[j].SelectedCharacterIndex;
                ChangeTokenIndParty.ChangeTime := Now;
                ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                  .Players[j].Base.ClientID;
                ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                ChangeTokenIndParty.AccountStatus := 0;
                ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                  .Players[j].Account;
                ChangeTokenIndParty.charFromOther :=
                  Servers[Player.ChannelIndex].Players[j].Character;
                ChangeTokenIndParty.buffFromOther :=
                  Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.Buffs;
                if (Servers[Player.ChannelIndex].Players[j]
                  .CheckGameMasterLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 1;
                end;
                if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged)
                then
                begin
                  ChangeTokenIndParty.AccountStatus := 2;
                end;
                if not(ChangeChannelList.ContainsKey
                  (Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId)) then
                begin
                  ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                    .Account.Header.AccountId, ChangeTokenIndParty);
                end;

              end;
            end;
{$ENDREGION}
          end
          else
          begin
{$REGION É PARTY LEADER E ESTÁ EM RAID}
            ChangeChannelToken.PartiesTeleport[0].RequestId :=
              Player.Party.RequestId;
            ChangeChannelToken.PartiesTeleport[0].ExpAlocate :=
              Player.Party.ExpAlocate;
            ChangeChannelToken.PartiesTeleport[0].ItemAlocate :=
              Player.Party.ItemAlocate;
            ChangeChannelToken.PartiesTeleport[0].LastSlotItemReceived :=
              Player.Party.LastSlotItemReceived;
            ChangeChannelToken.PartiesTeleport[0].InRaid := True;
            ChangeChannelToken.PartiesTeleport[0].IsRaidLeader := True;
            ChangeChannelToken.PartiesTeleport[0].PartyRaidCount :=
              Player.Party.PartyRaidCount;
            ChangeChannelToken.PartiesLeader[0] :=
              Player.Base.Character.CharIndex;
            ChangeChannelToken.PartiesTeleport[0].MemberName :=
              TList<BYTE>.Create;
            ChangeChannelToken.AccountStatus := 0;
            if (Player.CheckGameMasterLogged) then
            begin
              ChangeChannelToken.AccountStatus := 1;
            end;
            if (Player.CheckAdminLogged) then
            begin
              ChangeChannelToken.AccountStatus := 2;
            end;
            for j in Player.Party.Members do
            begin
              if not(Servers[Player.ChannelIndex].Players[j]
                .Base.PlayerCharacter.LastPos.InRange(TPosition.Create(2947,
                1664), 15)) then
              begin
                Player.Party.RemoveMember(j);
                continue;
              end;
              if not(j = Player.Party.Leader) then
              begin
                Packet.TypeChanel := OtherChannelid;
                Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId;
                Packet.Header.Index := j;
                Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                  Packet.Header.Size);
                Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
            end;
            for j in Player.Party.Members do
            begin
              if not(ChangeChannelToken.PartiesTeleport[0].MemberName.Contains
                (Servers[Player.ChannelIndex].Players[j]
                .Base.Character.CharIndex)) then
                ChangeChannelToken.PartiesTeleport[0].MemberName.Add
                  (Servers[Player.ChannelIndex].Players[j]
                  .Base.Character.CharIndex);
              Servers[Player.ChannelIndex].Players[j]
                .DesconectedByOtherChannel := True;
              if not(j = Player.Party.Leader) then
              begin // mandar informação de telar pros outros
                Randomize;
                Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.LastPos := TPosition.Create(2947, 1664);
                ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
                ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                  .Players[j].SelectedCharacterIndex;
                ChangeTokenIndParty.ChangeTime := Now;
                ChangeTokenIndParty.AccountStatus := 0;
                ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                  .Players[j].Base.ClientID;
                ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                  .Players[j].Account;
                ChangeTokenIndParty.charFromOther :=
                  Servers[Player.ChannelIndex].Players[j].Character;
                ChangeTokenIndParty.buffFromOther :=
                  Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.Buffs;
                if (Servers[Player.ChannelIndex].Players[j]
                  .CheckGameMasterLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 1;
                end;
                if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged)
                then
                begin
                  ChangeTokenIndParty.AccountStatus := 2;
                end;
                if not(ChangeChannelList.ContainsKey
                  (Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId)) then
                begin
                  ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                    .Account.Header.AccountId, ChangeTokenIndParty);
                end;
              end;
            end;
            for k := 1 to 3 do
            begin
              if (Player.Party.PartyAllied[k] = 0) then
                continue;
              ChangeChannelToken.PartiesTeleport[k].RequestId :=
                Player.Party.RequestId;
              ChangeChannelToken.PartiesTeleport[k].ExpAlocate :=
                Player.Party.ExpAlocate;
              ChangeChannelToken.PartiesTeleport[k].ItemAlocate :=
                Player.Party.ItemAlocate;
              ChangeChannelToken.PartiesTeleport[k].LastSlotItemReceived :=
                Player.Party.LastSlotItemReceived;
              ChangeChannelToken.PartiesTeleport[k].InRaid := True;
              ChangeChannelToken.PartiesTeleport[k].IsRaidLeader := false;
              ChangeChannelToken.PartiesTeleport[k].PartyRaidCount :=
                Player.Party.PartyRaidCount;
              ChangeChannelToken.PartiesTeleport[k].MemberName :=
                TList<BYTE>.Create;
              for j in Servers[Player.ChannelIndex].Parties
                [Player.Party.PartyAllied[k]].Members do
              begin
                if not(Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.LastPos.InRange
                  (Player.Base.PlayerCharacter.LastPos, 15)) then
                begin
                  Servers[Player.ChannelIndex].Parties
                    [Player.Party.PartyAllied[k]].RemoveMember(j);
                  continue;
                end;

                Packet.TypeChanel := OtherChannelid;
                Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId;
                Packet.Header.Index := j;
                Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                  Packet.Header.Size);
                Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
              end;
              for j in Servers[Player.ChannelIndex].Parties
                [Player.Party.PartyAllied[k]].Members do
              begin
                if not(ChangeChannelToken.PartiesTeleport[k].MemberName.Contains
                  (Servers[Player.ChannelIndex].Players[j]
                  .Base.Character.CharIndex)) then
                  ChangeChannelToken.PartiesTeleport[k].MemberName.Add
                    (Servers[Player.ChannelIndex].Players[j]
                    .Base.Character.CharIndex);
                ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
                ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                  .Players[j].SelectedCharacterIndex;
                ChangeTokenIndParty.ChangeTime := Now;
                ChangeTokenIndParty.AccountStatus := 0;
                ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                  .Players[j].Base.ClientID;
                ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
                ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                  .Players[j].Account;
                ChangeTokenIndParty.charFromOther :=
                  Servers[Player.ChannelIndex].Players[j].Character;
                ChangeTokenIndParty.buffFromOther :=
                  Servers[Player.ChannelIndex].Players[j]
                  .Base.PlayerCharacter.Buffs;
                if (Servers[Player.ChannelIndex].Players[j]
                  .CheckGameMasterLogged) then
                begin
                  ChangeTokenIndParty.AccountStatus := 1;
                end;
                if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged)
                then
                begin
                  ChangeTokenIndParty.AccountStatus := 2;
                end;
                Servers[Player.ChannelIndex].Players[j]
                  .DesconectedByOtherChannel := True;
                if (j = Servers[Player.ChannelIndex].Parties
                  [Player.Party.PartyAllied[k]].Leader) then
                begin
                  ChangeChannelToken.PartiesLeader[k] :=
                    Servers[Player.ChannelIndex].Players[j]
                    .Base.Character.CharIndex;
                end
                else
                begin
                  Randomize;
                  Servers[Player.ChannelIndex].Players[j]
                    .Base.PlayerCharacter.LastPos :=
                    Servers[Player.ChannelIndex].Players
                    [Servers[Player.ChannelIndex].Parties
                    [Player.Party.PartyAllied[k]].Leader].Base.Neighbors
                    [RandomRange(0, 8)].pos;
                end;
                if not(ChangeChannelList.ContainsKey
                  (Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId)) then
                begin
                  ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                    .Account.Header.AccountId, ChangeTokenIndParty);
                end;

              end;
{$ENDREGION}
            end;
          end;
        end
        else
        begin
{$REGION EM GRUPO NÃO EM RAID}
          ChangeChannelToken.PartyTeleport.RequestId := Player.Party.RequestId;
          ChangeChannelToken.PartyTeleport.ExpAlocate :=
            Player.Party.ExpAlocate;
          ChangeChannelToken.PartyTeleport.ItemAlocate :=
            Player.Party.ItemAlocate;
          ChangeChannelToken.PartyTeleport.LastSlotItemReceived :=
            Player.Party.LastSlotItemReceived;
          ChangeChannelToken.PartyTeleport.InRaid := false;
          ChangeChannelToken.PartyTeleport.IsRaidLeader := True;
          ChangeChannelToken.PartyTeleport.PartyRaidCount :=
            Player.Party.PartyRaidCount;
          ChangeChannelToken.PartyTeleport.MemberName := TList<BYTE>.Create;
          ChangeChannelToken.AccountStatus := 0;
          if (Player.CheckGameMasterLogged) then
          begin
            ChangeChannelToken.AccountStatus := 1;
          end;
          if (Player.CheckAdminLogged) then
          begin
            ChangeChannelToken.AccountStatus := 2;
          end;
          for j in Player.Party.Members do
          begin
            if not(Servers[Player.ChannelIndex].Players[j]
              .Base.PlayerCharacter.LastPos.InRange(TPosition.Create(2947,
              1664), 15)) then
            begin
              Player.Party.RemoveMember(j);
              continue;
            end;
            if not(j = Player.Party.Leader) then
            begin
              Packet.TypeChanel := OtherChannelid;
              Packet.Info1 := Servers[Player.ChannelIndex].Players[j]
                .Account.Header.AccountId;
              Packet.Header.Index := j;
              Servers[Player.ChannelIndex].Players[j].SendPacket(Packet,
                Packet.Header.Size);
              Servers[Player.ChannelIndex].Players[j].SocketClosed := True;
            end;
          end;
          for j in Player.Party.Members do
          begin
            if not(ChangeChannelToken.PartyTeleport.MemberName.Contains
              (Servers[Player.ChannelIndex].Players[j].Base.Character.CharIndex))
            then
              ChangeChannelToken.PartyTeleport.MemberName.Add
                (Servers[Player.ChannelIndex].Players[j]
                .Base.Character.CharIndex);
            Servers[Player.ChannelIndex].Players[j]
              .DesconectedByOtherChannel := True;
            if not(j = Player.Party.Leader) then
            begin // mandar informação de telar pros outros
              Randomize;
              Servers[Player.ChannelIndex].Players[j]
                .Base.PlayerCharacter.LastPos := TPosition.Create(2947, 1664);
              ZeroMemory(@ChangeTokenIndParty, SizeOf(TChangeChannelToken));
              ChangeTokenIndParty.CharSlot := Servers[Player.ChannelIndex]
                .Players[j].SelectedCharacterIndex;
              ChangeTokenIndParty.ChangeTime := Now;
              ChangeTokenIndParty.AccountStatus := 0;
              ChangeTokenIndParty.OldClientID := Servers[Player.ChannelIndex]
                .Players[j].Base.ClientID;
              ChangeTokenIndParty.OldChannelID := Player.ChannelIndex;
              ChangeTokenIndParty.accFromOther := Servers[Player.ChannelIndex]
                .Players[j].Account;
              ChangeTokenIndParty.charFromOther := Servers[Player.ChannelIndex]
                .Players[j].Character;
              ChangeTokenIndParty.buffFromOther := Servers[Player.ChannelIndex]
                .Players[j].Base.PlayerCharacter.Buffs;
              if (Servers[Player.ChannelIndex].Players[j].CheckGameMasterLogged)
              then
              begin
                ChangeTokenIndParty.AccountStatus := 1;
              end;
              if (Servers[Player.ChannelIndex].Players[j].CheckAdminLogged) then
              begin
                ChangeTokenIndParty.AccountStatus := 2;
              end;
              if not(ChangeChannelList.ContainsKey(Servers[Player.ChannelIndex]
                .Players[j].Account.Header.AccountId)) then
              begin
                ChangeChannelList.Add(Servers[Player.ChannelIndex].Players[j]
                  .Account.Header.AccountId, ChangeTokenIndParty);
              end;
            end;
          end;

{$ENDREGION}
        end;
      end;
    end
    else
    begin
      // Writeln('Jogador não está em um grupo.');
      Player.DesconectedByOtherChannel := True;
    end;
    // Writeln('Finalizando troca de canal...');
    Packet.TypeChanel := OtherChannelid;
    Packet.Info1 := Player.Account.Header.AccountId;
    Packet.Header.Index := Player.Base.ClientID;
    if not(ChangeChannelList.ContainsKey(Player.Account.Header.AccountId)) then
    begin
      // Writeln('Adicionando jogador à lista de troca.');
      ChangeChannelList.Add(Player.Account.Header.AccountId,
        ChangeChannelToken);
    end;
    // Writeln('Enviando pacote de troca para o jogador...');
    ChangeChannelOpcode.Remove(Player.Base.Character.Name);
    if not ChangeChannelOpcode.ContainsKey(Player.Base.Character.Name) then
    begin
      var
        playerData1: TPlayerData1;
      playerData1.Name := Player.Base.Character.Name;
      playerData1.Action := Ação; // Defina a ação conforme necessário
      ChangeChannelOpcode.Add(Player.Base.Character.Name, playerData1);
    end;


    // SMudandoCanal.Nome := Player.Base.Character.Name;
    // if not MudandoCanal.ContainsKey(Player.Base.Character.Name) then
    // begin
    // MudandoCanal.add(Player.Base.Character.Name, SMudandoCanal);
    // Player.ChangingChannel:= true;
    // Player.SendClientMessage('mudando de canal');
    // end;

    sleep(200);
    TFunctions.SavePlayerSecundario(@Player, Player.SelectedCharacterIndex);
    TFunctions.SavePlayerPrincipal(@Player, Player.SelectedCharacterIndex);
    Player.SendPacket(Packet, Packet.Header.Size);
    Servers[Player.ChannelIndex].Disconnect(Player);

    Player.SocketClosed := True;
    Result := True;
  except
    on E: Exception do
    begin
      WriteLn('An error occurred: ' + E.Message);
      Player.SendClientMessage
        ('An error occurred while processing your request.', 0, 0, 0);
    end;
  end;

end;

class function TPacketHandlers.LoginIntoChannel(var Player: TPlayer;
  var Buffer: ARRAY OF BYTE; Ação: Integer = 0): boolean;
var
  Packet: TChannelSendInfoPacket absolute Buffer;
  ChangeChannelToken: TChangeChannelToken;
  I, j, k: Integer;
  OtherPlayer, xOtherPlayer: PPlayer;
  xParty: PParty;
  cnt: Integer;
  Cid: Word;
  FWaiting: Integer;
  playerData1: TPlayerData1;
  StartTime: Int64;
  Timeout: Integer;
begin
  Result := false;
  Player.ChangingChannel := True;
  if (string(Packet.Username) = '') then
  begin
    Player.SocketClosed := True;
    Exit;
  end;

  if (Player.SocketClosed) then
    Exit;

  Player.SendP131;
  Player.SendChannelClientIndex;
  ZeroMemory(@ChangeChannelToken, SizeOf(TChangeChannelToken));

  if not(ChangeChannelList.ContainsKey(Packet.Serial)) then
  begin
    Player.SocketClosed := True;
    Exit;
  end;
  if not(ChangeChannelList.TryGetValue(Packet.Serial, ChangeChannelToken)) then
  begin
    Player.SocketClosed := True;
    Exit;
  end;
  if (ChangeChannelToken.OldClientID = 0) then
  begin
    Player.SocketClosed := True;
    Exit;
  end;

  if (Player.SocketClosed) then
    Exit;
  Player.SocketClosed:= false;
  Player.Account := ChangeChannelToken.accFromOther;
  Player.Character := ChangeChannelToken.charFromOther;
  Player.Character.Buffs := ChangeChannelToken.buffFromOther;

  Player.Authenticated := True;
  Player.LoggedByOtherChannel := True;
  ChangeChannelList.Remove(Player.Account.Header.AccountId);
  Player.SelectedCharacterIndex := ChangeChannelToken.CharSlot;
  Player.Account.Header.IsActive := True;
  ZeroMemory(@Player.Base.MOB_EF, SizeOf(Player.Base.MOB_EF));
  ZeroMemory(@Player.Base.PlayerCharacter, SizeOf(TPlayerCharacter));

  Player.SendToWorld(ChangeChannelToken.CharSlot, false);

  Player.SendToWorldSends(True);
  // if MudandoCanal.ContainsKey(Player.Base.Character.Name) then
  // begin
  // MudandoCanal.add(Player.Base.Character.Name, SMudandoCanal);
  // Player.ChangingChannel:= true;
  // Player.SendClientMessage('está teleportando');
  // end;

  sleep(3500);

  Player.ChangingChannel := false;

  Player.Base.LastAttackMsg := IncSecond(Now, -6);
  // if MudandoCanal.ContainsKey(Player.Base.Character.Name) then
  // begin
  // MudandoCanal.Remove(Player.Base.Character.Name);
  // Player.SendClientMessage('está teleportando? '+ Player.ChangingChannel.ToString);
  //
  // Player.SendClientMessage('está teleportando? '+ Player.ChangingChannel.ToString);

  // Player.SendClientMessage('não está mais mudando de canal');
  // end;

  if (ChangeChannelToken.PartyTeleport.MemberName = nil) then
  begin
    if (ChangeChannelToken.PartiesTeleport[0].MemberName = nil) then
    begin
      Player.ChangingChannel := false;
      Exit;
    end;

    for k := 0 to 3 do
    begin
      if (ChangeChannelToken.PartiesTeleport[k].MemberName = nil) then
        continue;

      for I := 1 to Length(Servers[Player.ChannelIndex].Parties) do
      begin
        if (Servers[Player.ChannelIndex].Parties[I].Members.Count = 0) then
        begin
          xParty := @Servers[Player.ChannelIndex].Parties[I];
          OtherPlayer := nil;

          if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
            (ChangeChannelToken.PartiesLeader[k], OtherPlayer)) then
          begin
            xParty.Leader := OtherPlayer.Base.ClientID;
          end;

          xParty.RequestId := ChangeChannelToken.PartiesTeleport[k].RequestId;
          xParty.ExpAlocate := ChangeChannelToken.PartiesTeleport[k].ExpAlocate;
          xParty.ItemAlocate := ChangeChannelToken.PartiesTeleport[k]
            .ItemAlocate;
          xParty.LastSlotItemReceived := ChangeChannelToken.PartiesTeleport[k]
            .LastSlotItemReceived;
          xParty.InRaid := True;

          if (k = 0) then
            xParty.IsRaidLeader := True
          else
            xParty.IsRaidLeader := false;

          xParty.PartyRaidCount := ChangeChannelToken.PartiesTeleport[k]
            .PartyRaidCount;

          for j in ChangeChannelToken.PartiesTeleport[k].MemberName do
          begin
            OtherPlayer := nil;
            if (Servers[Player.ChannelIndex].GetPlayerByCharIndex(j,
              OtherPlayer)) then
            begin
              if not(xParty.Members.Contains(OtherPlayer.Base.ClientID)) then
              begin
                xParty.Members.Add(OtherPlayer.Base.ClientID);
              end;
              if (xParty.Leader = 0) then
                xParty.Leader := OtherPlayer.Base.ClientID;
              Servers[Player.ChannelIndex].Players[xParty.Leader]
                .Teleportado_raid := True;

            end;
          end;

          if j = xParty.Leader then
          begin
            Servers[Player.ChannelIndex].Players[xParty.Leader]
              .Teleportado_raid := True;
            Servers[Player.ChannelIndex].Players[xParty.Leader].Party :=
              @Servers[Player.ChannelIndex].Parties[I];
            Servers[Player.ChannelIndex].Players[xParty.Leader].PartyIndex :=
              xParty.Index;
            Servers[Player.ChannelIndex].Players[xParty.Leader].Base.PartyId :=
              xParty.Index;
          end;

          for j in xParty.Members do
          begin
            Servers[Player.ChannelIndex].Players[j].Party :=
              @Servers[Player.ChannelIndex].Parties[I];
            Servers[Player.ChannelIndex].Players[j].PartyIndex := xParty.Index;
            Servers[Player.ChannelIndex].Players[j].Base.PartyId :=
              xParty.Index;
            Servers[Player.ChannelIndex].Players[j].SendClientMessage
              ('Aguarde sua raid ser reconstruída...');
          end;

          ttask.Run(
            procedure
            begin
              sleep(1000);
              xParty.RefreshParty;
            end); // Executa o RefreshParty

          Break;
        end;
      end;
    end;

    OtherPlayer := nil;
    if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
      (ChangeChannelToken.PartiesLeader[0], OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[1], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[2], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[3], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    // OtherPlayer := nil;
    if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
      (ChangeChannelToken.PartiesLeader[1], OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[0], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[2], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[3], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
      (ChangeChannelToken.PartiesLeader[2], OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[0], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[1], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[3], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
      (ChangeChannelToken.PartiesLeader[3], OtherPlayer)) then
    begin
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[0], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[1], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (ChangeChannelToken.PartiesLeader[2], xOtherPlayer)) then
        OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
    end;
    if not(OtherPlayer = nil) then
      ttask.Run(
        procedure
        begin
          sleep(1000);
          OtherPlayer.Party.RefreshRaid;
        end); // Executa o RefreshParty;
    Player.ChangingChannel := false;
  end
  else // então é minha party
  begin
    for I := 1 to Length(Servers[Player.ChannelIndex].Parties) do
      if (Servers[Player.ChannelIndex].Parties[I].Members.Count = 0) then
      begin
        WriteLn('executando codigo da propria pt');
        xParty := @Servers[Player.ChannelIndex].Parties[I];
        xParty.Leader := Player.Base.ClientID;
        xParty.RequestId := ChangeChannelToken.PartyTeleport.RequestId;
        xParty.ExpAlocate := ChangeChannelToken.PartyTeleport.ExpAlocate;
        xParty.ItemAlocate := ChangeChannelToken.PartyTeleport.ItemAlocate;
        xParty.LastSlotItemReceived :=
          ChangeChannelToken.PartyTeleport.LastSlotItemReceived;
        xParty.InRaid := false;
        xParty.IsRaidLeader := True;
        xParty.PartyRaidCount := 1;
        for j in ChangeChannelToken.PartyTeleport.MemberName do
        begin
          OtherPlayer := nil;
          if (Servers[Player.ChannelIndex].GetPlayerByCharIndex(j, OtherPlayer))
          then
          begin
            if not(xParty.Members.Contains(OtherPlayer.Base.ClientID)) then
            begin
              xParty.Members.Add(OtherPlayer.Base.ClientID);
            end;
          end;
        end;

        for j in xParty.Members do
        begin
          Servers[Player.ChannelIndex].Players[j].Party :=
            @Servers[Player.ChannelIndex].Parties[I];
          Servers[Player.ChannelIndex].Players[j].PartyIndex := xParty.Index;
          Servers[Player.ChannelIndex].Players[j].Base.PartyId := xParty.Index;
          Servers[Player.ChannelIndex].Players[j].SendClientMessage
            ('Aguarde seu grupo ser reconstruído...');
        end;

        ttask.Run(
          procedure
          begin
            sleep(1000);
            xParty.RefreshParty;
          end); // Executa o RefreshParty
        Break;
      end;

    Player.ChangingChannel := false;
  end;





  // if (ChangeChannelToken.PartyTeleport.MemberName = nil) then
  // begin
  // TTask.Run(
  // procedure
  // var
  // i, j, k: Integer;
  // OtherPlayer, xOtherPlayer: PPlayer;
  // xParty: PParty;
  // Player: TPlayer;
  // begin
  // sleep(3000);
  // if (ChangeChannelToken.PartiesTeleport[0].MemberName = nil) then
  // begin
  // Player.ChangingChannel:= false;
  // Exit;
  // end;
  //
  // WriteLn('Executando código da própria raid em uma thread separada.');
  //
  // for k := 0 to 3 do
  // begin
  // if (ChangeChannelToken.PartiesTeleport[k].MemberName = nil) then
  // Continue;
  //
  // for i := 1 to Length(Servers[Player.ChannelIndex].Parties) do
  // begin
  // if (Servers[Player.ChannelIndex].Parties[i].Members.Count = 0) then
  // begin
  // xParty := @Servers[Player.ChannelIndex].Parties[i];
  // OtherPlayer := nil;
  //
  // if (Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[k], OtherPlayer)) then
  // begin
  // xParty.Leader := OtherPlayer.Base.ClientID;
  // end;
  //
  // xParty.RequestId := ChangeChannelToken.PartiesTeleport[k].RequestId;
  // xParty.ExpAlocate := ChangeChannelToken.PartiesTeleport[k].ExpAlocate;
  // xParty.ItemAlocate := ChangeChannelToken.PartiesTeleport[k].ItemAlocate;
  // xParty.LastSlotItemReceived := ChangeChannelToken.PartiesTeleport[k].LastSlotItemReceived;
  // xParty.InRaid := True;
  //
  // if (k = 0) then
  // xParty.IsRaidLeader := True
  // else
  // xParty.IsRaidLeader := False;
  //
  // xParty.PartyRaidCount := ChangeChannelToken.PartiesTeleport[k].PartyRaidCount;
  //
  // for j in ChangeChannelToken.PartiesTeleport[k].MemberName do
  // begin
  // OtherPlayer := nil;
  // if (Servers[Player.ChannelIndex].GetPlayerByCharIndex(j, OtherPlayer)) then
  // begin
  // if not (xParty.Members.Contains(OtherPlayer.Base.ClientID)) then
  // begin
  // xParty.Members.Add(OtherPlayer.Base.ClientID);
  // end;
  // if (xParty.Leader = 0) then
  // xParty.Leader := OtherPlayer.Base.ClientID;
  // Servers[Player.ChannelIndex].Players[xParty.Leader].Teleportado_raid := True;
  // end;
  // end;
  //
  // if j = xParty.Leader then
  // begin
  // Servers[Player.ChannelIndex].Players[xParty.Leader].Teleportado_raid := True;
  // Servers[Player.ChannelIndex].Players[xParty.Leader].Party := @Servers[Player.ChannelIndex].Parties[i];
  // Servers[Player.ChannelIndex].Players[xParty.Leader].PartyIndex := xParty.Index;
  // Servers[Player.ChannelIndex].Players[xParty.Leader].Base.PartyId := xParty.Index;
  // end;
  //
  // for j in xParty.Members do
  // begin
  // Servers[Player.ChannelIndex].Players[j].Party := @Servers[Player.ChannelIndex].Parties[i];
  // Servers[Player.ChannelIndex].Players[j].PartyIndex := xParty.Index;
  // Servers[Player.ChannelIndex].Players[j].Base.PartyId := xParty.Index;
  // Servers[Player.ChannelIndex].Players[j].SendClientMessage('Aguarde sua raid ser reconstruída...');
  // end;
  //
  // xParty.RefreshParty;
  // Break;
  // end;
  // end;
  // end;
  //
  // OtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
  // OtherPlayer)) then
  // begin
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
  // end;
  // //OtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
  // OtherPlayer)) then
  // begin
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
  // end;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
  // OtherPlayer)) then
  // begin
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
  // end;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[3],
  // OtherPlayer)) then
  // begin
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[0],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[1] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[1],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[2] := xOtherPlayer.Party.Index;
  // xOtherPlayer := nil;
  // if(Servers[Player.ChannelIndex].GetPlayerByCharIndex(ChangeChannelToken.PartiesLeader[2],
  // xOtherPlayer)) then
  // OtherPlayer.Party.PartyAllied[3] := xOtherPlayer.Party.Index;
  // end;
  // if not(Otherplayer = nil) then
  // OtherPlayer.Party.RefreshRaid;
  // Player.ChangingChannel:= false;
  // end
  // );
  // end
  // else // Então é minha party
  // begin
  // TTask.Run(
  // procedure
  // var
  // i, j: Integer;
  // OtherPlayer: PPlayer;
  // xParty: PParty;
  // Player: TPlayer;
  // begin
  // sleep(3000);
  // WriteLn('Executando código da própria party em uma thread separada.');
  //
  // for i := 1 to Length(Servers[Player.ChannelIndex].Parties) do
  // begin
  // if (Servers[Player.ChannelIndex].Parties[i].Members.Count = 0) then
  // begin
  // xParty := @Servers[Player.ChannelIndex].Parties[i];
  // xParty.Leader := Player.Base.ClientID;
  // xParty.RequestId := ChangeChannelToken.PartyTeleport.RequestId;
  // xParty.ExpAlocate := ChangeChannelToken.PartyTeleport.ExpAlocate;
  // xParty.ItemAlocate := ChangeChannelToken.PartyTeleport.ItemAlocate;
  // xParty.LastSlotItemReceived := ChangeChannelToken.PartyTeleport.LastSlotItemReceived;
  // xParty.InRaid := False;
  // xParty.IsRaidLeader := True;
  // xParty.PartyRaidCount := 1;
  //
  // for j in ChangeChannelToken.PartyTeleport.MemberName do
  // begin
  // OtherPlayer := nil;
  // if (Servers[Player.ChannelIndex].GetPlayerByCharIndex(j, OtherPlayer)) then
  // begin
  // if not (xParty.Members.Contains(OtherPlayer.Base.ClientID)) then
  // begin
  // xParty.Members.Add(OtherPlayer.Base.ClientID);
  // end;
  // end;
  // end;
  //
  // for j in xParty.Members do
  // begin
  // Servers[Player.ChannelIndex].Players[j].Party := @Servers[Player.ChannelIndex].Parties[i];
  // Servers[Player.ChannelIndex].Players[j].PartyIndex := xParty.Index;
  // Servers[Player.ChannelIndex].Players[j].Base.PartyId := xParty.Index;
  // Servers[Player.ChannelIndex].Players[j].SendClientMessage('Grupo sendo reconstruído');
  // end;
  //
  // xParty.RefreshParty; // Executa o RefreshParty
  // Break;
  // end;
  // end;
  // Player.ChangingChannel:= false;
  // end
  // );
  // end;

  Result := True;
end;
{$ENDREGION}
{$REGION 'Guild'}

class function TPacketHandlers.CreateGuild(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TCreateGuildDialogPacket absolute Buffer;
  PartyMemberIndex: Word;
  PartyMember: PPlayer;
  I, Helper: Integer;
const
  Taxa = 50000;
begin
  Result := false;
  if (Player.Character.Base.Nation <= 0) then
  begin
    Player.SendClientMessage('É necessário ter nação para criar uma guild.');
    Exit;
  end;
  if (Player.Character.Base.GuildIndex > 0) then
  begin
    Player.SendClientMessage('Você já está em uma guild.');
    Exit;
  end;
  if (Player.PartyIndex = 0) or (Player.Party.Members.Count < 6) then
  begin
    Player.SendClientMessage
      ('Você precisa de um grupo com 6 pessoas para criar a guild.');
    Player.SendClientMessage('Corrigir isso aqui pra nao deixar menos de 6');
     Exit;
  end;
  if (Player.PartyIndex <> 0) then
  if (Player.Party.Leader <> Player.Character.Base.ClientID) then
  begin
    Player.SendClientMessage('Você não é o líder do grupo.');
    Exit;
  end;
  if Player.Character.Base.Gold < Taxa then
  begin
    Player.SendClientMessage
      ('Você não tem gold suficiente para criar uma guild.');
    Exit;
  end;
  if Player.Character.Base.Level < 10 then
  begin
    Player.SendClientMessage('O level minímo para criar uma guild é 10.');
    Exit;
  end;

  case Packet.Stage of
    0:
      begin
        Packet.Stage := 1;
        Packet.Rate := Taxa;
        Player.SendPacket(Packet, Packet.Header.Size);
      end;
    2:
      begin
        for PartyMemberIndex in Player.Party.Members do
        begin
          PartyMember := @Servers[Player.ChannelIndex].Players
            [PartyMemberIndex];
          if PartyMember.Character.Base.Nation <= 0 then
          begin
            Player.SendClientMessage
              ('Todos os membros do grupo devem ter nação.');
            Exit;
          end;
        end;
        if not TFunctions.IsLetter(String(Packet.GuildName)) then
        begin
          Player.SendClientMessage('Caracteres não permitidos.');
          Exit;
        end;
        Helper := 0;
        for I := Low(Guilds) to High(Guilds) do
        begin
          if AnsiString(Packet.GuildName) = AnsiString(Guilds[I].Name) then
          begin
            Player.SendClientMessage('Já existe uma guild com esse nome.');
            Exit;
          end;
          if (Guilds[I].Index = 0) then
            Helper := I;
        end;
        if (Helper = 0) then
        begin
          Player.SendClientMessage
            ('Já atingimos o limite de criação de guildas.');
          Exit;
        end;
        Player.DecGold(Taxa);
        for I := Low(Guilds) to High(Guilds) do
          if Guilds[I].Index <= 0 then
          begin
            ZeroMemory(@Guilds[I], SizeOf(Guilds[I]));
            Guilds[I].Slot := I;
            Guilds[I].CreateGuild(Packet.GuildName,
              Player.Base.Character.Nation, Player.ChannelIndex,
              Player.Party, @Player);
            Break;
          end;
      end;
  end;
  Result := True;
end;

class function TPacketHandlers.CloseGuildChest(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Guild: PGuild;
begin
  Result := false;
  if Player.Character.Base.GuildIndex > 0 then
  begin
    Guild := @Guilds[Player.Character.GuildSlot];
    if Guild.MemberInChest = Guild.FindMemberFromCharIndex
      (Player.Base.Character.CharIndex) then
    begin
      Guild.CloseChest;
      Sair(Player);
    end;
    Result := True;
  end;
end;

class function TPacketHandlers.ChangeGuildMemberRank(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TChangeGuildMemberRankPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := false;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;

  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank < 4 then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;

  Guild.ChangeRank(Packet.CharIndex, Packet.Rank);
  TFunctions.SaveGuilds(Player.Character.GuildSlot);
  Result := True;
end;

class function TPacketHandlers.UpdateGuildRanksConfig(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TUpdateGuildRanksConfigPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := false;
  if (Player.Character.Base.GuildIndex <= 0) or
    (Player.Character.Base.GuildIndex <> Packet.GuildIndex) then
    Exit;

  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank < 4 then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;

  Clipboard.AsText := Packet.RanksConfig[0].ToHexString(2);
  Guild.UpdateRanksConfig(Packet.RanksConfig);
  TFunctions.SaveGuilds(Player.Character.GuildSlot);

  Result := True;
end;

class function TPacketHandlers.UpdateGuildNotices(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TUpdateGuildNoticesPacket absolute Buffer;
  Guild: PGuild;
begin
  Result := false;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;

  Guild := @Guilds[Player.Character.GuildSlot];
  if not Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank).EditNotices then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;

  Guild.UpdateNotices(Packet.Notices[0], Packet.Notices[1], Packet.Notices[2]);
  TFunctions.SaveGuilds(Player.Character.GuildSlot);
  Result := True;
end;

class function TPacketHandlers.UpdateGuildSite(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TUpdateGuildSitePacket absolute Buffer;
  Guild: PGuild;
begin
  Result := false;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank).EditNotices = false then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  Guilds[Player.Character.GuildSlot].UpdateSite(Packet.Site);

  TFunctions.SaveGuilds(Player.Character.GuildSlot);
  Result := True;
end;

class function TPacketHandlers.InviteToGuildRequest(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
  OtherPlayer: PPlayer;
  Guild: PGuild;
begin
  Result := false;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank).Invite = false then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;
  if Packet.Data > High(Servers[Player.ChannelIndex].Players) then
  begin
    Player.SendClientMessage('Player index inválida.');
    Exit;
  end;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.Data];
  if (OtherPlayer.Base.IsActive = false) or
    (OtherPlayer.Account.Header.IsActive = false) then
  begin
    Player.SendClientMessage('Personagem não encontrado.');
    Exit;
  end;
  if (OtherPlayer.Character.Base.GuildIndex > 0) then
  begin
    Player.SendClientMessage('O jogador já está em uma guild.');
    Exit;
  end;
  if (OtherPlayer.GuildRecruterCharIndex > 0) and
    (MinutesBetween(Now, Player.GuildInviteTime) <= 1) then
  begin
    Player.SendClientMessage('O jogador já tem um convite pendente.');
    Exit;
  end;
  if (BYTE(OtherPlayer.Account.Header.Nation) <> Guild.Nation) then
  begin
    Player.SendClientMessage('O jogador não pertence a nação da guild.');
    Exit;
  end;
  OtherPlayer.GuildRecruterCharIndex := Servers[Player.ChannelIndex].Players
    [Packet.Header.Index].Base.Character.CharIndex;
  OtherPlayer.GuildInviteTime := Now;
  OtherPlayer.InviteToGuildRequest(Packet.Data);
  Result := True;
end;

class function TPacketHandlers.InviteToGuildAccept(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Recruter: PPlayer;
begin
  Result := false;
  if Player.GuildRecruterCharIndex <= 0 then
    Exit;
  if MinutesBetween(Now, Player.GuildInviteTime) > 1 then
  begin
    Player.SendClientMessage('O convite expirou.');
    Exit;
  end;
  if Servers[Player.ChannelIndex].GetPlayerByCharIndex
    (Player.GuildRecruterCharIndex, Recruter) then
  begin
    Guilds[Recruter.Character.GuildSlot].AddMember
      (Player.Base.Character.CharIndex, Player.ChannelIndex, 0,
      Player.GuildRecruterCharIndex);
    Player.SendP152;
  end;
  TFunctions.SaveGuilds(Recruter.Character.GuildSlot);
  Player.SendNationInformation;
  Result := True;
end;

class function TPacketHandlers.InviteToGuildDeny(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  OtherPlayer: TPlayer;
begin
  Result := false;
  if not Servers[Player.ChannelIndex].GetPlayerByCharIndex
    (Player.GuildRecruterCharIndex, OtherPlayer) then
    Exit;
  OtherPlayer.SendClientMessage('O personagem recusou o seu convite.');
  Player.GuildRecruterCharIndex := 0;
  Player.GuildInviteTime := 0;
  Result := True;
end;

class function TPacketHandlers.KickMemberOfGuild(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
  Guild: PGuild;
  OtherPlayer: PPlayer;
  I: Integer;
begin
  Result := false;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank).Kick = false then
  begin
    Player.SendClientMessage('Você não tem permissão para isso.');
    Exit;
  end;

  if (Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank < Guild.Members
    [Guild.FindMemberFromCharIndex(Packet.Data)].Rank) then
  begin
    Player.SendClientMessage
      ('O jogador selecionado possui rank maior que o seu.');
    Exit;
  end;

  Guilds[Player.Character.GuildSlot].RemoveMember(Packet.Data, True);
  for I := Low(Servers) to High(Servers) do
  begin
    OtherPlayer := nil;
    if (Servers[I].GetPlayerByCharIndex(Packet.Data, OtherPlayer) = True) then
    begin
      OtherPlayer.SendNationInformation;
      Break;
    end
    else
      continue;
  end;

  TFunctions.SaveGuilds(Player.Character.GuildSlot);

  Result := True;
end;

class function TPacketHandlers.ExitGuild(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Aux: Word;
begin
  Result := false;
  if Player.Character.Base.GuildIndex <= 0 then
    Exit;
  if (Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex = Player.Base.
    Character.CharIndex) then
  begin
    Player.SendClientMessage
      ('Você não pode sair da guilda sendo o lider dela.');
    Exit;
  end;

  Aux := Player.Character.GuildSlot;

  Guilds[Player.Character.GuildSlot].RemoveMember
    (Player.Base.Character.CharIndex, false);
  Player.SendNationInformation;

  TFunctions.SaveGuilds(Aux);
  Result := True;
end;

class function TPacketHandlers.RequestGuildToAlly(var Player: TPlayer;
Buffer: array of BYTE): boolean;
var
  Packet: TGuildRequestAllyPacket absolute Buffer;
  xSendpacket: TSendInviteToRaid;
  Guild: PGuild;
  OtherGuild: PGuild;
  I, P: Integer;
  leadMemberId: Word;
  LeadPlayer: PPlayer;
begin
  Result := false;
  if AnsiStrings.CompareStr(Packet.GuildName, '') = 0 then
    Exit;
  if Player.Base.Character.GuildIndex = 0 then
    Exit;
  Guild := @Guilds[Player.Character.GuildSlot];
  if Guild.Members[Guild.FindMemberFromCharIndex
    (Player.Base.Character.CharIndex)].Rank < 4 then
  begin
    Player.SendClientMessage('Você não é o líder da guild.');
    Exit;
  end;
  if Guild.Ally.Leader <> Guild.Index then
  begin
    Player.SendClientMessage('Você não é o líder da aliança');
    Exit;
  end;
  for I := Low(Guilds) to High(Guilds) do
    if AnsiStrings.CompareStr(Guilds[I].Name, Packet.GuildName) = 0 then
    begin
      for P := Low(Guilds[I].Ally.Guilds) + 1 to High(Guilds[I].Ally.Guilds) do
        if not(AnsiStrings.CompareStr(Guilds[I].Ally.Guilds[P].Name, '') = 0)
        then
        begin
          Player.SendClientMessage('A guild já está em uma aliança.');
          Exit;
        end;
    end;
  for I := Low(Guild.Ally.Guilds) + 1 to High(Guild.Ally.Guilds) do
  begin
    if (AnsiStrings.CompareStr(Guilds[I].Ally.Guilds[I].Name, '') = 0) then
      Break
    else if not(AnsiStrings.CompareStr(Guilds[I].Ally.Guilds[I].Name, '') = 0)
    then
      if I = High(Guild.Ally.Guilds) then
      begin
        Player.SendClientMessage('Não há mais espaço na aliança.');
        Exit;
      end;
  end;
  OtherGuild := TFunctions.SearchGuildByName(String(Packet.GuildName));
  if (OtherGuild = nil) then
  begin
    Player.SendClientMessage
      ('Erro de busca por guild para inclusão na aliança. Ticket pro suporte.');
    Exit;
  end;
  if (OtherGuild.Nation <> Guild.Nation) then
  begin
    Player.SendClientMessage('A guild escolhida é de outra nação.');
    Exit;
  end;
  leadMemberId := OtherGuild.FindMemberFromCharIndex
    (OtherGuild.GuildLeaderCharIndex);
  if not(OtherGuild.Members[leadMemberId].Logged) then
  begin
    Player.SendClientMessage('O lider da guild escolhida está offline.');
    Exit;
  end;
  if (OtherGuild.Index = Guild.Index) then
  begin
    Player.SendClientMessage
      ('Você não pode adicionar a própia legião na aliança.');
    Exit;
  end;

  ZeroMemory(@xSendpacket, SizeOf(xSendpacket));
  xSendpacket.Header.Size := SizeOf(xSendpacket);
  xSendpacket.Header.Code := $342;
  xSendpacket.Header.Index := Player.Base.ClientID;
  if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
    (OtherGuild.GuildLeaderCharIndex, LeadPlayer)) then
  begin
    xSendpacket.SendTo := LeadPlayer.Base.ClientID;
    LeadPlayer.SendClientMessage('A aliança de <' + AnsiString(Guild.Name) +
      '> lhe convida a participar da aliança com sua Legião.', 16, 32, 8);
    LeadPlayer.SendPacket(xSendpacket, xSendpacket.Header.Size);
    LeadPlayer.AliianceByLegion := True;
    LeadPlayer.AllianceRequester := Player.Base.ClientID;
    LeadPlayer.AllianceSlot := Packet.SlotAlly;
  end;
  Result := True;
end;

class function TPacketHandlers.ChangeMasterGuild(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TChangeMasterGuild absolute Buffer;
  OtherPlayer, xOtherPlayer: PPlayer;
  I: Integer;
  SelfMemberID, TargetMemberId: BYTE;
begin
  if (Player.Base.Character.GuildIndex = 0) then
  begin
    Player.SendClientMessage('Você não está em uma guilda.');
    Exit;
  end;
  if (Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex <>
    Player.Base.Character.CharIndex) then
  begin
    Player.SendClientMessage('Você não é o lider atual para fazer isso.');
    Exit;
  end;
  if (Packet.CharIndex = 0) then
    Exit;

  for I := 0 to 3 do
  begin
    if (String(Nations[Player.Character.Base.Nation - 1].Cerco.Atacantes[I]
      .LordMarechal) = String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage
        ('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
    if (String(Nations[Player.Character.Base.Nation - 1].Cerco.Atacantes[I]
      .Estrategista) = String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage
        ('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
    if (String(Nations[Player.Character.Base.Nation - 1].Cerco.Atacantes[I]
      .Juiz) = String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage
        ('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
    if (String(Nations[Player.Character.Base.Nation - 1].Cerco.Atacantes[I]
      .Tesoureiro) = String(Guilds[Player.Character.GuildSlot].Name)) then
    begin
      Player.SendClientMessage
        ('Você não pode alterar o mestre guild estando cadastrado na guerra.');
      Exit;
    end;
  end;

  if (String(Nations[Player.Character.Base.Nation - 1]
    .Cerco.Defensoras.LordMarechal) = String(Guilds[Player.Character.GuildSlot]
    .Name)) then
  begin
    Player.SendClientMessage
      ('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;
  if (String(Nations[Player.Character.Base.Nation - 1]
    .Cerco.Defensoras.Estrategista) = String(Guilds[Player.Character.GuildSlot]
    .Name)) then
  begin
    Player.SendClientMessage
      ('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;
  if (String(Nations[Player.Character.Base.Nation - 1].Cerco.Defensoras.Juiz)
    = String(Guilds[Player.Character.GuildSlot].Name)) then
  begin
    Player.SendClientMessage
      ('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;
  if (String(Nations[Player.Character.Base.Nation - 1]
    .Cerco.Defensoras.Tesoureiro) = String(Guilds[Player.Character.GuildSlot]
    .Name)) then
  begin
    Player.SendClientMessage
      ('Você não pode alterar o mestre guild estando cadastrado na grade.');
    Exit;
  end;

  OtherPlayer := nil;
  if (Servers[Player.ChannelIndex].GetPlayerByCharIndex(Packet.CharIndex,
    OtherPlayer)) then
  begin
    if (OtherPlayer.Base.Character.GuildIndex <>
      Player.Base.Character.GuildIndex) then
    begin
      Player.SendClientMessage('Alvo não pertence a mesma guild que a sua.');
      Exit;
    end;
    for I := 0 to 127 do
    begin
      if (Guilds[Player.Character.GuildSlot].Members[I].CharIndex = 0) then
        continue;
      if (Guilds[Player.Character.GuildSlot].Members[I]
        .CharIndex = OtherPlayer.Character.Base.CharIndex) then
      begin
        TargetMemberId := I;
      end;
      if (Guilds[Player.Character.GuildSlot].Members[I]
        .CharIndex = Player.Character.Base.CharIndex) then
      begin
        SelfMemberID := I;
      end;
    end;
    Guilds[Player.Character.GuildSlot].Members[TargetMemberId].Rank :=
      Guilds[Player.Character.GuildSlot].Members[SelfMemberID].Rank;
    Guilds[Player.Character.GuildSlot].Members[SelfMemberID].Rank := 3;
    Guilds[Player.Character.GuildSlot].GuildLeaderCharIndex :=
      Guilds[Player.Character.GuildSlot].Members[TargetMemberId].CharIndex;
    for I := 0 to 127 do
    begin
      if (Guilds[Player.Character.GuildSlot].Members[I].CharIndex = 0) then
        continue;
      xOtherPlayer := nil;
      if (Servers[Player.ChannelIndex].GetPlayerByCharIndex
        (Guilds[Player.Character.GuildSlot].Members[I].CharIndex, xOtherPlayer))
      then
      begin
        xOtherPlayer.SendGuildInfo;
        xOtherPlayer.UpdateGuildMemberRank(Player.Base.Character.CharIndex,
          Guilds[Player.Character.GuildSlot].Members[SelfMemberID].Rank);
        xOtherPlayer.UpdateGuildMemberRank(OtherPlayer.Base.Character.CharIndex,
          Guilds[Player.Character.GuildSlot].Members[TargetMemberId].Rank);
        xOtherPlayer.SendClientMessage
          ('O lider guild passou a ser o personagem <' +
          AnsiString(OtherPlayer.Character.Base.Name) + '.>');
      end;
    end;

    TFunctions.SaveGuilds(Player.Character.GuildSlot);
  end
  else
  begin
    Player.SendClientMessage('Alvo não disponível.');
    Exit;
  end;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Request Time'}

class function TPacketHandlers.RequestServerTime(var Player: TPlayer;
Buffer: array of BYTE): boolean;
begin
  Player.SendClientMessage(AnsiString(DateTimeToStr(Now)), 16);
  Result := True;
end;

class function TPacketHandlers.RequestServerPing(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  xMs: Single;
begin
  xMs := MilliSecondsBetween(Player.PingCommandUsed, Now);

  Player.SendClientMessage(xMs.ToString + ' ms.');

  Result := True;
end;
{$ENDREGION}
{$REGION 'Other Handlers'}

class function TPacketHandlers.GetStatusPoint(var Player: TPlayer;
Buffer: array of BYTE): boolean;
var
  Packet: TGetStatusPointPacket absolute Buffer;
  StatusScore: ^Integer;
begin
  Result := false;

  if Packet.StatusAmount > Player.Character.Base.CurrentScore.Status then
    Exit;

  case Packet.StatusIndex of
    0:
      StatusScore := @Player.Character.Base.CurrentScore.Str;
    1:
      StatusScore := @Player.Character.Base.CurrentScore.Agility;
    2:
      StatusScore := @Player.Character.Base.CurrentScore.Int;
    3:
      StatusScore := @Player.Character.Base.CurrentScore.Cons;
    4:
      StatusScore := @Player.Character.Base.CurrentScore.Luck;
  else
    Exit;
  end;

  Inc(StatusScore^, Packet.StatusAmount);
  Dec(Player.Character.Base.CurrentScore.Status, Packet.StatusAmount);

  with Player.Base do
  begin
    GetCurrentScore;
    SendStatus;
    SendRefreshPoint;
    SendCurrentHPMP;
  end;

  Result := True;
end;

class function TPacketHandlers.ReceiveEventItem(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  PlayerSQLComp: TQuery;
begin
  if (Player.Status < Playing) then
    Exit; // testar o bagulho pra ver se é conta sem estar ingame
  if (TItemFunctions.GetInvAvailableSlots(Player) = 0) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  if (Player.DiaryItemAvaliable) then
  begin
    TItemFunctions.PutItemOnEvent(Player, 10467);
  end;

  Player.GetAllEventItems;

  Result := True;
end;
{$ENDREGION}
{$REGION 'Duel'}

class function TPacketHandlers.SendRequestDuel(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSendDuelResquest absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := True;
  if Servers[Player.ChannelIndex].DuelCount >= 5 then
  begin
    Player.SendClientMessage
      ('já existem 5 duelos ativos no momento, aguarde um pouco!');
    Exit;
  end;
  if (Packet.ClientID > 0) then
  begin
    OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.ClientID];
  end
  else
  begin
    OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(String(Packet.Nick));
  end;
  if (OtherPlayer.Status < Playing) then
  begin
    Player.SendClientMessage('Alvo não está logado.');
    Exit;
  end;
  if (Player.Base.PlayerCharacter.PlayerKill) then
  begin
    Player.SendClientMessage('Não é possível duelar com o PvP ligado.');
    Exit;
  end;
  if (OtherPlayer.Character.Base.Nation <> Player.Character.Base.Nation) then
  begin
    Player.SendClientMessage('O alvo não é da sua nação.');
    Exit;
  end;
  if ((Player.Character.Base.Level < 10) or (OtherPlayer.Character.Base.Level
    < 10)) then
  begin
    Player.SendClientMessage
      ('É necessário que os dois jogadores sejam nivel 10 para duelar.');
    Exit;
  end;
  if ((OtherPlayer.PartyIndex <> 0) and (Player.PartyIndex <> 0)) then
  begin
    if (OtherPlayer.PartyIndex = Player.PartyIndex) then
    begin
      Player.SendClientMessage('Jogador inválido. Pertence ao seu grupo.');
      Exit;
    end;
  end;
  if (OtherPlayer.Dueling) then
  begin
    Player.SendClientMessage('O jogador já está em um duelo.');
    Exit;
  end;
  Packet.Header.Index := Player.Base.ClientID;
  Packet.ClientID := Player.Base.ClientID;
  Move(Player.Base.Character.Name, Packet.Nick, 16);
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);
  OtherPlayer.DuelRequester := Player.Base.ClientID;
end;

class function TPacketHandlers.DuelResponse(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSendDuelResponse absolute Buffer;
  OtherPlayer: PPlayer;
begin
  Result := True;
  OtherPlayer := @Servers[Player.ChannelIndex].Players[Player.DuelRequester];
  if (OtherPlayer.Status < Playing) then
  begin
    Player.SendClientMessage('O jogador desafiante não está mais online.');
    Exit;
  end;
  if (Packet.Response = 0) then
  begin
    OtherPlayer.SendClientMessage
      ('O jogador desafiado recusou seu convite de duelo.');
    Exit;
  end;
  if (not Player.Base.PlayerCharacter.LastPos.InRange(
    (OtherPlayer.Base.PlayerCharacter.LastPos), DISTANCE_TO_WATCH)) then
  begin
    Player.SendClientMessage('O jogador desafiante está muito longe.');
    Exit;
  end;
  if (OtherPlayer.Base.IsDead) then
  begin
    Player.SendClientMessage('O jogador desafiante está morto.');
    Exit;
  end;
  if (Player.Base.PlayerCharacter.PlayerKill) then
  begin
    Player.SendClientMessage('Não possível duelar com o PvP ligado.');
    Exit;
  end;
  if (Player.Dueling) then
  begin
    Player.SendClientMessage('Você já está em um duelo.');
    Exit;
  end;
  Player.SendDuelTime;
  OtherPlayer.SendDuelTime;
  Player.CreateDuelSession(OtherPlayer);
end;
{$ENDREGION}
{$REGION 'Quest'}

class function TPacketHandlers.AbandonQuest(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TAbandonQuestPacket absolute Buffer;
  QuestIndex, NpcIx: Word;
begin
  if (Player.QuestExists(Packet.QuestID, QuestIndex)) then
  begin
    if (Servers[Player.ChannelIndex].NPCS[Player.PlayerQuests[QuestIndex]
      .Quest.NPCID].Base.PlayerCharacter.LastPos.InRange
      (Player.Base.PlayerCharacter.LastPos, 30)) then
    begin
      NpcIx := Player.PlayerQuests[QuestIndex].Quest.NPCID;

      if (Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
      begin
        Player.PlayerQuests[QuestIndex].IsDone := True;
        Player.SendPacket(Packet, Packet.Header.Size);
      end
      else
      begin
        if not(Player.PlayerQuests[QuestIndex].IsDone) then
        begin
          ZeroMemory(@Player.PlayerQuests[QuestIndex],
            SizeOf(Player.PlayerQuests[QuestIndex]));
          Player.SendPacket(Packet, Packet.Header.Size);
        end;
      end;

      Servers[Player.ChannelIndex].NPCS[NpcIx].Base.SendCreateMob(SPAWN_NORMAL,
        Player.Base.ClientID, false);
    end
    else
    begin
      if (Player.PlayerQuests[QuestIndex].Quest.QuestMark = 11) then
      begin
        Player.PlayerQuests[QuestIndex].IsDone := True;
        Player.SendPacket(Packet, Packet.Header.Size);
      end
      else
      begin
        if not(Player.PlayerQuests[QuestIndex].IsDone) then
        begin
          ZeroMemory(@Player.PlayerQuests[QuestIndex],
            SizeOf(Player.PlayerQuests[QuestIndex]));
          Player.SendPacket(Packet, Packet.Header.Size);
        end;
      end;
    end;
  end;
  Result := True;
end;
{$ENDREGION}
{$REGION 'Teleport do FC'}

class function TPacketHandlers.TeleportSetPosition(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TTeleportFcPacket absolute Buffer;
begin
  if Packet.Slot <= 5 then
  begin
    Player.TeleportList[Packet.Slot] := Player.Base.PlayerCharacter.LastPos;
    Packet.Posx := Round(Player.TeleportList[Packet.Slot].X);
    Packet.Posy := Round(Player.TeleportList[Packet.Slot].Y);
    Player.SendPacket(Packet, Packet.Header.Size);
    Player.SaveCharacterTeleportList(Player.Base.PlayerCharacter.Base.Name);
  end;
  Result := True;
end;

{$ENDREGION}
{$REGION 'Titles'}

class function TPacketHandlers.UpdateActiveTitle(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TSignalData absolute Buffer;
  I: BYTE;
begin
  Result := True;
  Player.Base.SetOffTitleActiveEffect;

  if (Packet.Data = 0) then
  begin
    ZeroMemory(@Player.Base.PlayerCharacter.ActiveTitle, SizeOf(TTitle));
    Player.SendUpdateActiveTitle;
  end
  else
  begin
    for I := 0 to 95 do
      if (Player.Base.PlayerCharacter.Titles[I].Index = Packet.Data) and
        (Player.Base.PlayerCharacter.Titles[I].Level <> 0) then
      begin
        Player.Base.PlayerCharacter.ActiveTitle :=
          Player.Base.PlayerCharacter.Titles[I];
        Player.Base.SetOnTitleActiveEffect;
        Player.SendUpdateActiveTitle;
        Break;
      end;
  end;

  Player.Base.GetCurrentScore;
  Player.Base.SendRefreshPoint;
  Player.Base.SendStatus;
  Player.Base.SendRefreshLevel;
  Player.Base.SendCurrentHPMP();
end;

{$ENDREGION}
{$REGION 'Pran'}

class function TPacketHandlers.RenamePran(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TRenamePranPacket absolute Buffer;
begin
  Result := false;

  if not(TFunctions.IsLetter(String(Packet.Name))) then
  begin
    Player.SendClientMessage('O nome não pode conter esses caracteres.');
    Exit;
  end;

  if (TFunctions.VerifyNameAlreadyExists(Player, String(Packet.Name))) then
  begin
    Player.SendClientMessage('O nome ja está em uso.');
    Exit;
  end;

  if (Player.Account.Header.Pran1.Name = '') then
    AnsiStrings.StrPLCopy(Player.Account.Header.Pran1.Name,
      AnsiString(Packet.Name), 16)
  else if (Player.Account.Header.Pran2.Name = '') then
    AnsiStrings.StrPLCopy(Player.Account.Header.Pran2.Name,
      AnsiString(Packet.Name), 16)
  else
  begin
    Player.SendClientMessage('Todas suas prans já possuem nome.');
    Exit;
  end;

  Packet.AccountId := Player.Account.Header.AccountId;
  Player.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
    Player.Account.Header.Storage.Itens[84], false);
  Player.Base.SendRefreshItemSlot(STORAGE_TYPE, 85,
    Player.Account.Header.Storage.Itens[85], false);
  Player.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

{$ENDREGION}
{$REGION 'Mail'}

class function TPacketHandlers.openMail(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TOpenMailPacket absolute Buffer;
  dwGold: DWORD;
  itemCount: BYTE;
begin
  Result := false;
  case Packet.OpenType of
{$REGION 'Ver conteúdo da carta'}
    0:
      begin
        if (TEntityMail.sendMailContent(Player, Packet.Index)) then
          TEntityMail.setMailRead(Player, Packet.Index)
        else
          Exit;
      end;
{$ENDREGION}
{$REGION 'Remove carta'}
    1:
      begin
        if not(TEntityMail.deleteMail(Player, Packet.Index)) then
          Exit;
        Packet.Slot := 0;
        Packet.CharIndex := Player.Character.Index;
        Packet.Delete := True;
        Player.SendPacket(Packet, Packet.Header.Size);
        TEntityMail.sendMailList(Player);
        Player.SendClientMessage('Correio excluído.');
      end;
{$ENDREGION}
{$REGION 'Devolver carta'}
    2:
      begin
        if not(TEntityMail.returnEmail(Player, Packet.Index)) then
        begin
          Exit;
        end;
        Packet.Slot := 0;
        Packet.CharIndex := Player.Character.Index;
        Packet.Delete := True;
        Player.SendPacket(Packet, Packet.Header.Size);
        TEntityMail.sendMailList(Player);
        Player.SendClientMessage('Correio retornado.');
      end;
{$ENDREGION}
{$REGION 'Pegar Gold Carta'}
    3:
      begin
        if not(TEntityMail.getMailGold(Player, Packet.Index, dwGold)) then
        begin
          WriteLn('o erro foi aqui 0');
          Exit;
        end;
        if (dwGold = 0) then
        begin
          WriteLn('o erro foi aqui 1');
          Exit;
        end;
        if not(TEntityMail.withdrawGold(Player, Packet.Index)) then
        begin
          WriteLn('o erro foi aqui 2');
          Exit;
        end;

        var
          SQLComp: TQuery;
        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE));

        if not(SQLComp.Query.Connection.Connected) then
        begin
          Logger.Write
            ('Falha de conexão individual com mysql.[erro no getmail gold]',
            TLogType.Warnings);
          Logger.Write('PERSONAL MYSQL FAILED LOAD.[erro no getmail gold]',
            TLogType.Error);
          SQLComp.Free;
          Exit;
        end;

        try
          // Configurando a consulta com o índice do pacote
          SQLComp.SetQuery
            (Format('SELECT sentcharactername FROM mails WHERE id = %d',
            [Packet.Index]));

          // Executando a consulta
          SQLComp.Run(True);

          // Verificando se há resultados na consulta
          if SQLComp.Query.EOF then
          begin
            WriteLn('Nenhum registro encontrado.');
          end
          else
          begin
            // Obtendo o valor do campo sentcharactername
            var
            sentCharacterName := SQLComp.Query.Fields[0].AsString;

            // Comparando o valor do campo
            if sentCharacterName = 'Casa de Leilões' then
            begin
              Player.AddCash(dwGold);
              Player.SendClientMessage('Cash adicionado a sua conta.');
              var
                LogFile: TextFile;
              var
                LogMessage: string;
                // Verifica se a pasta 'logs' existe, se não, cria
              if not DirectoryExists('logs') then
                CreateDir('logs');

              // Prepara a mensagem com o nick
              LogMessage := ' [DATE_TIME: ' + DateTimeToStr(Now) +
                ' - Cash recuperado da venda de item no leilao ' +
                Player.Base.Character.Name;

              // Atribui o caminho do arquivo de log
              AssignFile(LogFile, 'logs\leilao\withdraw.txt');

              // Cria o arquivo e escreve a mensagem nele
              try
                if FileExists('logs\leilao\withdraw.txt') then
                  Append(LogFile) // Se o arquivo já existe, abre para adicionar
                else
                  Rewrite(LogFile); // Se o arquivo não existe, cria o arquivo
                WriteLn(LogFile, LogMessage);
              finally
                CloseFile(LogFile); // Fecha o arquivo após escrever
              end;

            end
            else
            begin
              Player.AddGold(dwGold);
              var
                LogFile: TextFile;
              var
                LogMessage: string;
                // Verifica se a pasta 'logs' existe, se não, cria
              if not DirectoryExists('logs') then
                CreateDir('logs');

              // Prepara a mensagem com o nick
              LogMessage := ' [DATE_TIME: ' + DateTimeToStr(Now) +
                ' - Gold sacado pelo player ' + Player.Base.Character.Name;

              // Atribui o caminho do arquivo de log
              AssignFile(LogFile, 'logs\correio\saques.txt');

              // Cria o arquivo e escreve a mensagem nele
              try
                if FileExists('logs\correio\saques.txt') then
                  Append(LogFile) // Se o arquivo já existe, abre para adicionar
                else
                  Rewrite(LogFile); // Se o arquivo não existe, cria o arquivo
                WriteLn(LogFile, LogMessage);
              finally
                CloseFile(LogFile); // Fecha o arquivo após escrever
              end;

            end;
          end;

        except
          on E: Exception do
          begin
            WriteLn('An error occurred: ' + E.Message);
            Player.SendClientMessage
              ('An error occurred while processing your request.', 0, 0, 0);
          end;
        end;
        SQLComp.Free;

        if not(TEntityMail.getMailItemCount(Player, Packet.Index, itemCount))
        then
        begin
          WriteLn('o erro foi aqui 3');
          Exit;
        end;
        if (itemCount = 0) then
        begin
          Packet.Delete := True;
        end;
        Packet.CharIndex := Player.Base.Character.CharIndex;
        Player.SendPacket(Packet, Packet.Header.Size);
        Player.SendClientMessage('Gold recolhido.');
      end;
{$ENDREGION}
  end;
  Result := True;
end;

class function TPacketHandlers.withdrawMailItem(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TGetMailContentPacket absolute Buffer;
  Item: TItem;
  itemCount: BYTE;
  ItemIndex: UInt64;
begin
  Result := false;
  if (TItemFunctions.GetEmptySlot(Player) = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  if (Packet.Slot > 4) then
  begin
    Exit;
  end;
  ItemIndex := 0;
  if not(TEntityMail.getMailItemSlot(Player, Packet.Index, Packet.Slot, Item,
    ItemIndex)) then
    Exit;
  if (Item.Index = 0) or (ItemIndex = 0) then
    Exit;
  if (TItemFunctions.PutItem(Player, Item, 0, True) = -1) then
  begin
    Exit;
  end;
  TEntityMail.withdrawItem(Player, ItemIndex, Packet.Index);
  if not(TEntityMail.getMailItemCount(Player, Packet.Index, itemCount)) then
    Exit;
  if (itemCount = 0) then
  begin
    TEntityMail.setAllItemsWithdraw(Player, Packet.Index);
  end;
  TEntityMail.sendMailContent(Player, Packet.Index);
  if (itemCount = 0) then
  begin
    TEntityMail.sendMailList(Player);
  end;
  Result := True;
end;

class function TPacketHandlers.checkSendMailRequirements(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TSendMailPacket absolute Buffer;
  Nation: TCitizenShip;
begin
  Result := false;
  if Packet.Nick = 'leilao' then
  begin
    Packet.Send := BOOL_ACCEPT;
    Packet.Nation := Integer(Nation);
    Player.SendPacket(Packet, Packet.Header.Size);
    Player.CanSendMailTo := string(Packet.Nick);
    Result := True;
  end
  else
  begin
    if not(TFunctions.GetCharacterNation(string(Packet.Nick), Nation)) then
    begin
      Packet.Send := BOOL_REFUSE;
      Player.SendPacket(Packet, Packet.Header.Size);
      Exit;
    end;
    if not(Player.Account.Header.Nation = TCitizenShip.none) and
      (Player.Account.Header.Nation <> Nation) then
    begin
      Packet.Send := BOOL_REFUSE;
      Packet.Nation := Integer(Nation);
      Player.SendPacket(Packet, Packet.Header.Size);
      Exit;
    end;
    Packet.Send := BOOL_ACCEPT;
    Packet.Nation := Integer(Nation);
    Player.SendPacket(Packet, Packet.Header.Size);
    Player.CanSendMailTo := string(Packet.Nick);
    Result := True;
  end;
end;

class function TPacketHandlers.sendCharacterMail(var Player: TPlayer;
var Buffer: array of BYTE): boolean;
var
  Packet: TContentMailPacket absolute Buffer;
  I: Integer;
  mailIndex: UInt64;
begin
  Result := false;
  if not(Packet.Content.Nick = 'leilao') then
  begin
    WriteLn('nick nao é leilao');
    for I := 0 to 4 do
    begin

      case ItemList[Player.Character.Base.Inventory[Packet.Content.ItemSlot[I]].
        Index].UseEffect of
        12 .. 100:
          begin;
            Player.SendClientMessage
              ('Item trocável somente via Leilão Gold ou Leilão Web');
            Exit;
          end;

      end;
    end;
    if (string(Packet.Content.Nick) <> Player.CanSendMailTo) then
    begin
      Logger.Write('name differs from original target', TLogType.Packets);
      Exit;
    end;
    if not(Player.Character.Base.Gold >= 500) then
    begin
      Player.CanSendMailTo := '';
      Player.SendClientMessage('Não possuí gold suficiente.');
      Player.SendData(Player.Base.ClientID, $3F15, BOOL_REFUSE);
      Exit;
    end;
    if not(Player.Character.Base.Gold >= Packet.Content.Gold) then
    begin
      Player.CanSendMailTo := '';
      Player.SendClientMessage('Você não possui todo esse gold, sabia?');
      Player.SendData(Player.Base.ClientID, $3F15, BOOL_REFUSE);
      Exit;
    end;
    Player.DecGold(500);
    Player.DecGold(Packet.Content.Gold);
    if not(TEntityMail.AddMail(Player, Packet.Content, mailIndex)) then
    begin
      Logger.Write('add mail fail', TLogType.Packets);
      Exit;
    end;

    for I := 0 to 4 do
    begin
      if (Packet.Content.ItemSlot[I] = $FF) then
        continue;
      if (ItemList[Player.Character.Base.Inventory[Packet.Content.ItemSlot[I]].
        Index].TypeTrade <> 0) then
        continue;
      if not(TEntityMail.addMailItem(Player, Packet.Content.ItemSlot[I], I,
        mailIndex)) then
        Exit;
      ZeroMemory(@Player.Character.Base.Inventory[Packet.Content.ItemSlot[I]],
        SizeOf(TItem));
      Player.Base.SendRefreshItemSlot(Packet.Content.ItemSlot[I], false);
    end;
    Player.SendData(Player.Base.ClientID, $3F15, BOOL_ACCEPT);
    Player.SendClientMessage('Correio enviado.');
    Player.CanSendMailTo := '';
    Exit;
  end
  else
  begin

    if (string(Packet.Content.Nick) <> Player.CanSendMailTo) then
    begin
      Logger.Write('name differs from original target', TLogType.Packets);
      Exit;
    end;

    var
      itemCount, FoundItemID: Integer;
    itemCount := 0;
    FoundItemID := -1; // Valor inicial indicando que nenhum item foi encontrado

    for I := 0 to 4 do
    begin
      if Packet.Content.ItemSlot[I] = $FF then
      // Verifica se o slot contém um item
      begin
        continue;
      end
      else
      begin
        Inc(itemCount); // Incrementa a contagem de itens encontrados
        FoundItemID := Packet.Content.ItemSlot[I];
      end;
    end;

    if itemCount = 0 then
    begin
      Player.SendClientMessage('Necessário enviar um item', 0, 0, 0);
      Exit;
    end;

    if itemCount > 1 then
    begin
      Player.SendClientMessage('Coloque apenas um item por vez', 0, 0, 0);
      Exit;
    end;

    if itemCount = 1 then
    begin
      Packet.Content.ItemSlot[0] := FoundItemID;
    end;

    if itemCount = 1 then
    begin
      // Verifica se o índice 0 está vazio antes de modificar
      if Packet.Content.ItemSlot[0] = $FF then
      begin
        Player.SendClientMessage('Use o slot 1', 0, 0, 0);
        Exit;
      end;

      // Caso contrário, define o slot 0 como o ID do item encontrado
      Packet.Content.ItemSlot[0] := FoundItemID;
    end;

    if not(ItemList[Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].
      Index].TypeTrade = 0) then
    begin
      Player.SendClientMessage(' erro');
      Exit;
    end;

    var
      Tipo: string;
    var
      Valor: Integer;

    if not((Packet.Content.Titulo = 'cash') or (Packet.Content.Titulo = 'gold'))
    then
    begin
      Player.SendClientMessage('Selecione um metodo de pagamento!');
      Exit;
    end;

    if (Packet.Content.Gold = 0) then
    begin
      Player.SendClientMessage('Selecione um valor para cobrar no seu item!');
      Exit;
    end;

    if Packet.Content.Titulo = 'gold' then
    begin
      if (Player.Base.Character.Gold >= 500000) then
      begin
        Player.DecGold(500000);
        Tipo := 'Gold';
        Valor := 500000;
      end
      else
      begin
        Player.SendClientMessage
          ('Necessário 500k de gold para enviar para o leilão web');
        Exit;
      end;
    end;
    if Packet.Content.Titulo = 'cash' then
    begin
      if (Player.Account.Header.CashInventory.Cash >= 100) then
      begin
        Player.DecCash(100);
        Tipo := 'Cash';
        Valor := 100;
      end
      else
      begin
        Player.SendClientMessage
          ('Necessário 100 de cash para enviar para o leilão web');
        Exit;
      end;
    end;

    // Player.DecGold(Packet.Content.Gold); vamos usar a variavel do packet.content.gold pra cobrar o valor
    // if not(TEntityMail.AddMail(Player, Packet.Content, mailIndex)) then
    // begin
    // var LogFile: TextFile;
    // var LogMessage: string;
    // // Verifica se a pasta 'logs' existe, se não, cria
    // if not DirectoryExists('leilão') then
    // CreateDir('leilão');
    //
    // // Prepara a mensagem com o nick
    // LogMessage := ' [ERRO] [DATE_TIME: '+ DateTimeToStr(Now) +' - erro ao adicionar item no leilão nick: ' + Player.Base.Character.Name + ' Devolver ' + Tipo + ' Quantidade ' + Valor.ToString;
    //
    // // Atribui o caminho do arquivo de log
    // AssignFile(LogFile, 'logs\leilão\erro.txt');
    //
    // // Cria o arquivo e escreve a mensagem nele
    // try
    // if FileExists('logs\leilão\erro.txt') then
    // Append(LogFile)  // Se o arquivo já existe, abre para adicionar
    // else
    // Rewrite(LogFile);  // Se o arquivo não existe, cria o arquivo
    // Writeln(LogFile, LogMessage);
    // finally
    // CloseFile(LogFile);  // Fecha o arquivo após escrever
    // end;
    // Exit;
    // end;

    for I := 0 to 4 do
    begin
      if (Packet.Content.ItemSlot[I] = $FF) then
        continue;
      if (ItemList[Player.Character.Base.Inventory[Packet.Content.ItemSlot[I]].
        Index].TypeTrade <> 0) then
        continue;

    end;

    var
      LogFile: TextFile;
    var
      LogMessage: string;
      // Verifica se a pasta 'logs' existe, se não, cria
    if not DirectoryExists('leilão') then
      CreateDir('leilão');

    // Prepara a mensagem com o nick
    LogMessage := ' [SUCESSO] [DATE_TIME: ' + DateTimeToStr(Now) +
      ' - item enviado para o leilão nick: ' + Player.Base.Character.Name +
      ' Tipo de item gasto ' + Tipo + ' Quantidade ' + Valor.ToString +
      ' Item adicionado: ' + ItemList
      [Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Index].Name +
      ' infos: ' + ' ADD1: ' + Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].Effects.Index[0].ToString + ' ADD1_Value ' +
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Effects.Value
      [0].ToString + ' ADD2: ' + Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].Effects.Index[1].ToString + ' ADD2_Value ' +
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Effects.Value
      [1].ToString + ' ADD3: ' + Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].Effects.Index[2].ToString + ' ADD3_Value ' +
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Effects.Value
      [2].ToString;

    // Atribui o caminho do arquivo de log
    AssignFile(LogFile, 'logs\leilão\sucesso.txt');

    // Cria o arquivo e escreve a mensagem nele
    try
      if FileExists('logs\leilão\sucesso.txt') then
        Append(LogFile) // Se o arquivo já existe, abre para adicionar
      else
        Rewrite(LogFile); // Se o arquivo não existe, cria o arquivo
      WriteLn(LogFile, LogMessage);
    finally
      CloseFile(LogFile); // Fecha o arquivo após escrever
    end;

    WriteLn('contagem 1');
    var
      itemlevel: Word;
    var
      ItemReinforce: Word;
    var
      SQLComp: TQuery;

      // Criação do objeto TQuery
    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));

    // Formata a consulta e armazena em uma variável
    var
    QueryStr := Format('INSERT INTO leilao_site (' +
      'CharacterId, CharacterName, ExpireDate, SellingPrice, ' +
      'ItemId, ItemLookId, IdentificableAddOns, EffectId_1, EffectValue_1, ' +
      'EffectId_2, EffectValue_2, EffectId_3, EffectValue_3, DurabilityMin, ' +
      'DurabilityMax, Amount_Reinforce, ItemTime, ItemType, ItemLevel, ' +
      'ReinforceLevel, Active) ' +
      'VALUES (%d, ''%s'', DATE_ADD(NOW(), INTERVAL 2 DAY), %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, ''%s'', %d, %d, 1)',
      [Player.Base.Character.CharIndex, Player.Base.Character.Name,
      Packet.Content.Gold, Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].Index, Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].APP, Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].Identific, Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].Effects.Index[0],
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Effects.Value
      [0], Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Effects.
      Index[1], Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]]
      .Effects.Value[1], Player.Character.Base.Inventory[Packet.Content.ItemSlot
      [0]].Effects.Index[2], Player.Character.Base.Inventory
      [Packet.Content.ItemSlot[0]].Effects.Value[2],
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].MIN,
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].MAX,
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Refi,
      Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Time,
      ItemList[Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].
      Index].ItemType.ToString, // String esperada para ItemType
    ItemList[Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]].Index]
      .Level, 1]);

    SQLComp.Query.Connection.StartTransaction;
    SQLComp.SetQuery(QueryStr);
    SQLComp.Run(false);
    SQLComp.Query.Connection.Commit;
    SQLComp.Free;
    WriteLn('contagem 2');
    ZeroMemory(@Player.Character.Base.Inventory[Packet.Content.ItemSlot[0]],
      SizeOf(TItem));
    Player.Base.SendRefreshItemSlot(Packet.Content.ItemSlot[0], false);
    Player.SendData(Player.Base.ClientID, $3F15, BOOL_ACCEPT);
    Player.SendClientMessage('Item enviado para o leilão web.');
    Player.CanSendMailTo := '';
    Result := True;
  end;
end;
{$ENDREGION}
{$REGION 'Dungeons'}

class function TPacketHandlers.RequestEnterDungeon(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TSelectDungeonToEnter absolute Buffer;
  I: Word;
begin
  Result := false;

  if Dungeon_Status = 0 then
  begin
    Player.SendPlayerToSavedPosition();
    Player.SendClientMessage('Dungeon desabilitada');
    Exit;
  end;

  Player.CheckInventoryRelic(true);

  if Player.OpennedOption = 26 then
  begin
    if Player.PartyIndex <> 0 then
    begin
      if Player.Party.Leader <> Player.Base.ClientID then
      begin
        Player.SendClientMessage('Você não é o lider do grupo.');
        Exit;
      end;

      case Player.OpennedNPC of

                                2302:
            if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2302]
            .Base.PlayerCharacter.LastPos, 5) then
            begin
             for I in Player.Party.Members do
              if Servers[Player.ChannelIndex].DGPrisao[Packet.Dificult].LevelMin
                > Servers[Player.ChannelIndex].Players[I].Base.Character.Level
              then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGPrisao
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end
              else
                Player.SendDungeonLobby(True, 6,
                  Packet.Dificult);
            end;

          2410:
            if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2410]
            .Base.PlayerCharacter.LastPos, 5) then
            begin
             for I in Player.Party.Members do
              if Servers[Player.ChannelIndex].DGPheltas[Packet.Dificult].LevelMin
                > Servers[Player.ChannelIndex].Players[I].Base.Character.Level
              then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGPheltas
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end
              else
                Player.SendDungeonLobby(True, 10,
                  Packet.Dificult);
            end;



        2197:
          if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2197]
            .Base.PlayerCharacter.LastPos, 5) then
            begin
             for I in Player.Party.Members do
              if Servers[Player.ChannelIndex].DGMines1[Packet.Dificult].LevelMin
                > Servers[Player.ChannelIndex].Players[I].Base.Character.Level
              then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGMines1
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end
              else
                Player.SendDungeonLobby(True, DUNGEON_LOST_MINES,
                  Packet.Dificult);
            end;


        2151:
          if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2151]
            .Base.PlayerCharacter.LastPos, 5) then
          begin

            if (Player.PartyIndex <> 0) and (Player.Party.Members.Count < 10)
              and (Servers[Player.ChannelIndex].DGMines2[Packet.Dificult]
              .LevelMin > Servers[Player.ChannelIndex].Players[I]
              .Base.Character.Level) then
            begin
              for I in Player.Party.Members do
                Servers[Player.ChannelIndex].Players[I].SendClientMessage
                  ('Necessário 10 jogadores no mínimo, para entrar na Mina 2 e ter um level mínimo de: '
                  + Servers[Player.ChannelIndex].DGMines2[Packet.Dificult]
                  .LevelMin.ToString);
              Exit;
            end;

            if (Player.PartyIndex = 0) then
            begin
              Player.SendClientMessage
                ('Necessário 10 jogadores no mínimo, para entrar na Mina 2');
              Exit;
            end;

            Player.SendDungeonLobby(True, DUNGEON_MINE_2, Packet.Dificult);
          end;

        2095:
          if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2095]
            .Base.PlayerCharacter.LastPos, 5) then
            begin
            for I in Player.Party.Members do
              if Servers[Player.ChannelIndex].DGEvgInf[Packet.Dificult].LevelMin
                > Servers[Player.ChannelIndex].Players[I].Base.Character.Level
              then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGEvgInf
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end
              else
                Player.SendDungeonLobby(True, DUNGEON_MARAUDER_HOLD,
                  Packet.Dificult);
            end;

        2103:
          if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2103]
            .Base.PlayerCharacter.LastPos, 5) then
          begin
            for I in Player.Party.Members do
              if Servers[Player.ChannelIndex].DGEvgSup[Packet.Dificult].LevelMin
                > Servers[Player.ChannelIndex].Players[I].Base.Character.Level
              then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGEvgSup
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end
              else
                Player.SendDungeonLobby(True, DUNGEON_MARAUDER_CABIN,
                  Packet.Dificult);
          end;

        2109:
          if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2109]
            .Base.PlayerCharacter.LastPos, 5) then
           begin
            for I in Player.Party.Members do
              if Servers[Player.ChannelIndex].DGUrsula[Packet.Dificult].LevelMin
                > Servers[Player.ChannelIndex].Players[I].Base.Character.Level
              then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGUrsula
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end
              else
                Player.SendDungeonLobby(True, DUNGEON_ZANTORIAN_CITADEL,
                  Packet.Dificult);
           end;

        2258:
          if Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
            .Base.PlayerCharacter.LastPos.InRange
            (Servers[Player.ChannelIndex].NPCS[2258]
            .Base.PlayerCharacter.LastPos, 5) then
          begin
            for I in Player.Party.Members do
              if Servers[Player.ChannelIndex].DGKinary[Packet.Dificult].LevelMin
                > Servers[Player.ChannelIndex].Players[I].Base.Character.Level
              then
              begin
                Player.SendClientMessage('A dungeon selecionada requer nivel ['
                  + AnsiString(Servers[Player.ChannelIndex].DGKinary
                  [Packet.Dificult].LevelMin.ToString) + '].');
                Exit;
              end
              else
                Player.SendDungeonLobby(True, DUNGEON_KINARY_AVIARY,
                  Packet.Dificult);
          end;
      end;
    end
    else
    begin
      case Player.OpennedNPC of
        2302:   //Prisao
        begin

          if Servers[Player.ChannelIndex].DGPrisao[Packet.Dificult].LevelMin >
              Player.Base.Character.Level then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGPrisao[Packet.Dificult]
                .LevelMin.ToString) + '].');
              Exit;
            end
            else
              Player.SendDungeonLobby(false, 6, Packet.Dificult);

        end;


        2410:   //pheltas
        begin

          if Servers[Player.ChannelIndex].DGPheltas[Packet.Dificult].LevelMin >
              Player.Base.Character.Level then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGPheltas[Packet.Dificult]
                .LevelMin.ToString) + '].');
              Exit;
            end
            else
              Player.SendDungeonLobby(false, 10, Packet.Dificult);

        end;

        2197:
        begin
          if Servers[Player.ChannelIndex].DGMines1[Packet.Dificult].LevelMin >
            Player.Base.Character.Level then
          begin
            Player.SendClientMessage('A dungeon selecionada requer nivel [' +
              AnsiString(Servers[Player.ChannelIndex].DGMines1[Packet.Dificult]
              .LevelMin.ToString) + '].');
            Exit;
          end
          else
            Player.SendDungeonLobby(false, DUNGEON_LOST_MINES, Packet.Dificult);
        end;

        2151:
        begin
          for I in Player.Party.Members do
            if Servers[Player.ChannelIndex].DGMines2[Packet.Dificult].LevelMin >
              Servers[Player.ChannelIndex].Players[I].Base.Character.Level then
            begin
              Player.SendClientMessage('A dungeon selecionada requer nivel [' +
                AnsiString(Servers[Player.ChannelIndex].DGMines2
                [Packet.Dificult].LevelMin.ToString) + '].');
              Exit;
            end
            else
              Player.SendDungeonLobby(false, DUNGEON_MINE_2, Packet.Dificult);
        end;

        2095:
        begin
          if Servers[Player.ChannelIndex].DGEvgInf[Packet.Dificult].LevelMin >
            Player.Base.Character.Level then
          begin
            Player.SendClientMessage('A dungeon selecionada requer nivel [' +
              AnsiString(Servers[Player.ChannelIndex].DGEvgInf[Packet.Dificult]
              .LevelMin.ToString) + '].');
            Exit;
          end
          else
            Player.SendDungeonLobby(false, DUNGEON_MARAUDER_HOLD,
              Packet.Dificult);
        end;

        2103:
        begin
          if Servers[Player.ChannelIndex].DGEvgSup[Packet.Dificult].LevelMin >
            Player.Base.Character.Level then
          begin
            Player.SendClientMessage('A dungeon selecionada requer nivel [' +
              AnsiString(Servers[Player.ChannelIndex].DGEvgSup[Packet.Dificult]
              .LevelMin.ToString) + '].');
            Exit;
          end
          else
            Player.SendDungeonLobby(false, DUNGEON_MARAUDER_CABIN,
              Packet.Dificult);
        end;

        2109:
        begin
          if Servers[Player.ChannelIndex].DGUrsula[Packet.Dificult].LevelMin >
            Player.Base.Character.Level then
          begin
            Player.SendClientMessage('A dungeon selecionada requer nivel [' +
              AnsiString(Servers[Player.ChannelIndex].DGUrsula[Packet.Dificult]
              .LevelMin.ToString) + '].');
            Exit;
          end
          else
            Player.SendDungeonLobby(false, DUNGEON_ZANTORIAN_CITADEL,
              Packet.Dificult);
        end;

        2258:
        begin
          if Servers[Player.ChannelIndex].DGKinary[Packet.Dificult].LevelMin >
            Player.Base.Character.Level then
          begin
            Player.SendClientMessage('A dungeon selecionada requer nivel [' +
              AnsiString(Servers[Player.ChannelIndex].DGKinary[Packet.Dificult]
              .LevelMin.ToString) + '].');
            Exit;
          end
          else
            Player.SendDungeonLobby(false, DUNGEON_KINARY_AVIARY,
              Packet.Dificult);
        end;
      end;
    end;
  end;

  Result := True;
end;

class function TPacketHandlers.DungeonLobbyConfirm(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TConfirmDungeonEnter absolute Buffer;
  PacketToSend: TSelectDungeonToEnter;
  I, cnt: Word;
  RequiredGold: Integer;
begin
  Player.CheckInventoryRelic(true);

  if (Player.DungeonLobbyDificult in [0 .. 3]) and (Dungeon_Valor_Status = 1)
    and (Packet.Index <> 0) then
  begin
    case Player.DungeonLobbyDificult of
      0:
        RequiredGold := Dungeon_Valor_Normal;
      1:
        RequiredGold := Dungeon_Valor_Dificil;
      2:
        RequiredGold := Dungeon_Valor_Elite;
      3:
        RequiredGold := Dungeon_Valor_Infernal;
    end;

    if Player.Character.Base.Gold < RequiredGold then
    begin
      for I in Player.Party.Members do
      begin
        Servers[Player.ChannelIndex].Players[I].SendClientMessage
          ('[' + AnsiString(Player.Base.Character.Name) +
          '] é pobre, não tem o gold necessário pra entrar na dungeon.');
        if I <> Player.Base.ClientID then
          Servers[Player.ChannelIndex].SendPacketTo(I, Packet,
            Packet.Header.Size);
      end;
      Player.SendClientMessage('Necessários ' + RequiredGold.ToString +
        ' de gold(s) para entrar na dungeon!', 16);
      Exit(false);
    end
    else
    begin
      Dec(Player.Character.Base.Gold, RequiredGold);
    end;
  end;

  WriteLn('packet index ' + Packet.Index.ToString);

  if Packet.Index = 0 then
  begin
    if Player.PartyIndex <> 0 then
    begin
      for I in Player.Party.Members do
      begin
        Servers[Player.ChannelIndex].Players[I].SendClientMessage
          ('[' + AnsiString(Player.Base.Character.Name) +
          '] se recusou a entrar na dungeon.');
        if I <> Player.Base.ClientID then
          Servers[Player.ChannelIndex].SendPacketTo(I, Packet,
            Packet.Header.Size);
      end;
    end
    else
    begin
      Player.SendClientMessage('[' + AnsiString(Player.Base.Character.Name) +
        '] se recusou a entrar na dungeon.');
    end;
  end
  else
  begin
    if Player.PartyIndex <> 0 then
    begin
      SetLength(Player.Party.DungeonLobbyConfirm, Player.Party.Members.Count);
      for I := Low(Player.Party.Members.ToArray)
        to High(Player.Party.Members.ToArray) do
      begin
        if Player.Party.Members.ToArray[I] = Packet.Header.Index then
        begin
          Player.Party.DungeonLobbyConfirm[I] := Packet.Header.Index;
          Player.Party.SendToParty(Packet, Packet.Header.Size);
          Break;
        end;
      end;

      cnt := 0;
      for I := Low(Player.Party.DungeonLobbyConfirm)
        to High(Player.Party.DungeonLobbyConfirm) do
      begin
        if Player.Party.DungeonLobbyConfirm[I] > 0 then
          Inc(cnt);
      end;

      if cnt = Length(Player.Party.DungeonLobbyConfirm) then
      begin
        Player.createDungeonInstance(True, Player.DungeonLobbyIndex,
          Player.DungeonLobbyDificult);
        for I in Player.Party.Members do
        begin
          PacketToSend.Header.Size := SizeOf(PacketToSend);
          PacketToSend.Header.Index := I;
          PacketToSend.Header.Code := $334;
          PacketToSend.Dificult := Player.DungeonLobbyDificult + 1;
          Servers[Player.ChannelIndex].Players[I].SendPacket(PacketToSend,
            PacketToSend.Header.Size);
        end;
      end;
    end
    else
    begin
      Player.SendPacket(Packet, Packet.Header.Size);
      Player.createDungeonInstance(false, Player.DungeonLobbyIndex,
        Player.DungeonLobbyDificult);
      PacketToSend.Header.Size := SizeOf(PacketToSend);
      PacketToSend.Header.Index := Player.Base.ClientID;
      PacketToSend.Header.Code := $334;
      PacketToSend.Dificult := Player.DungeonLobbyDificult + 1;
      Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
    end;
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'Make Items'}

class function TPacketHandlers.MakeItem(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
type
  TItemRequired = packed record
    ItemId, Amount, Slot: Word;
  end;
var
  Packet: TMakeItemPacket absolute Buffer;
  MIIndex, RandomTax: Word;
  I, cnt, EmptySlot: Word;
  CurrentAmount, CurrentSlot: BYTE;
  ItemsRequired: Array of TItemRequired;
  VaizanSlot: BYTE;
  Helper1: Integer;
begin
  Result := false;
  if (Packet.Null3 = 1) then
  begin
    case (TItemFunctions.GetItemEquipSlot(Player.Base.Character.Inventory
      [Packet.ItemId].Index)) of
      2 .. 7, 11 .. 14:
        begin
          case ItemList[Player.Base.Character.Inventory[Packet.ItemId].
            Index].Level of
            1 .. 10:
              RandomTax := Level_10_Destroy_Range
                [RandomRange(0, Length(Level_10_Destroy_Range))];
            11 .. 20:
              RandomTax := Level_10_Destroy_Range
                [RandomRange(0, Length(Level_10_Destroy_Range))];
            21 .. 30:
              RandomTax := Level_20_Destroy_Range
                [RandomRange(0, Length(Level_20_Destroy_Range))];
            31 .. 40:
              RandomTax := Level_30_Destroy_Range
                [RandomRange(0, Length(Level_30_Destroy_Range))];
            41 .. 50:
              RandomTax := Level_40_Destroy_Range
                [RandomRange(0, Length(Level_40_Destroy_Range))];
            51 .. 60:
              RandomTax := Level_50_Destroy_Range
                [RandomRange(0, Length(Level_50_Destroy_Range))];
            61 .. 70:
              RandomTax := Level_60_Destroy_Range
                [RandomRange(0, Length(Level_60_Destroy_Range))];
            71 .. 80:
              RandomTax := Level_70_Destroy_Range
                [RandomRange(0, Length(Level_70_Destroy_Range))];
            81 .. 90:
              RandomTax := Level_80_Destroy_Range
                [RandomRange(0, Length(Level_80_Destroy_Range))];
            91 .. 99:
              RandomTax := Level_90_Destroy_Range
                [RandomRange(0, Length(Level_90_Destroy_Range))];
          else
            begin
              Player.SendClientMessage('Este item não pode ser desmontado.');
              Exit;
            end;
          end;
          cnt := RandomRange(1, 6);
          if ItemList[Player.Base.Character.Inventory[Packet.ItemId].Index]
            .Level in [81 .. 99] then
            cnt := RandomRange(1, 8);
          TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.ItemId);
          TItemFunctions.PutItem(Player, RandomTax, cnt);
        end;
    else
      begin
        Player.SendClientMessage('Este item não pode ser desmontado.');
        Exit;
      end;
    end;
    Player.SendClientMessage('Item desmontado com sucesso.');
    Packet.ItemId := 0;
    Packet.Null := 0;
    Packet.Amount := 0;
    Packet.null2 := 0;
    Packet.Null3 := 0;
    Packet.Null4 := 0;
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end
  else if ((Packet.Null3 = 3) or (Packet.Null3 = 4)) then
  begin
    if (TItemFunctions.CanAgroup(Player.Base.Character.Inventory[Packet.ItemId]))
    then
    begin
      Player.SendClientMessage('Esse item não pode ser limpo.');
      Exit;
    end;
    case ItemList[Player.Base.Character.Inventory[Packet.ItemId].Index]
      .TypeItem of
      TYPE_ITEM_NORMAL:
        VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 513,
          INV_TYPE);
      TYPE_ITEM_RARE_SUPERIOR, TYPE_ITEM_SUPERIOR:
        VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 514,
          INV_TYPE);
      TYPE_ITEM_RARO, TYPE_ITEM_LEGENDARY:
        VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 515,
          INV_TYPE);
      TYPE_ITEM_PREMIUM:
        begin
          Player.SendClientMessage('Itens de cash não podem ser limpos.');
          Exit;
        end;
    end;
    if (VaizanSlot = 255) then
    begin
      Player.SendClientMessage('Você deve possuir o item Vaizan necessário.');
      Exit;
    end;
    case Packet.Amount of
      0:
        begin
          ZeroMemory(@Player.Base.Character.Inventory[Packet.ItemId]
            .Effects, 6);
          if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
          begin
            Dec(Player.Base.Character.Inventory[VaizanSlot].Refi, 1);
            Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
              Player.Base.Character.Inventory[VaizanSlot], false);
          end
          else
            TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);
        end;
      1, 2, 3:
        begin
          if (Packet.Amount = 1) then
          begin
            if (Player.Base.Character.Inventory[Packet.ItemId].Effects.
              Index[0] = 0) then
            begin
              if (Player.Base.Character.Inventory[Packet.ItemId].Effects.
                Index[1] = 0) then
              begin
                Player.Base.Character.Inventory[Packet.ItemId].Effects.
                  Index[2] := 0;
                Player.Base.Character.Inventory[Packet.ItemId]
                  .Effects.Value[2] := 0;
              end
              else
              begin
                Player.Base.Character.Inventory[Packet.ItemId].Effects.
                  Index[1] := 0;
                Player.Base.Character.Inventory[Packet.ItemId]
                  .Effects.Value[1] := 0;
              end;
            end
            else
            begin
              Player.Base.Character.Inventory[Packet.ItemId].Effects.
                Index[0] := 0;
              Player.Base.Character.Inventory[Packet.ItemId]
                .Effects.Value[0] := 0;
            end;
          end
          else if (Packet.Amount = 2) then
          begin
            if (Player.Base.Character.Inventory[Packet.ItemId].Effects.
              Index[1] = 0) then
            begin
              Player.Base.Character.Inventory[Packet.ItemId].Effects.
                Index[2] := 0;
              Player.Base.Character.Inventory[Packet.ItemId]
                .Effects.Value[2] := 0;
            end
            else
            begin
              Player.Base.Character.Inventory[Packet.ItemId].Effects.
                Index[1] := 0;
              Player.Base.Character.Inventory[Packet.ItemId]
                .Effects.Value[1] := 0;
            end;
          end
          else if (Packet.Amount = 3) then
          begin
            if (Player.Base.Character.Inventory[Packet.ItemId].Effects.
              Index[2] = 0) then
            begin
              if (Player.Base.Character.Inventory[Packet.ItemId].Effects.
                Index[1] = 0) then
              begin
                Player.Base.Character.Inventory[Packet.ItemId].Effects.
                  Index[0] := 0;
                Player.Base.Character.Inventory[Packet.ItemId]
                  .Effects.Value[0] := 0;
              end
              else
              begin
                Player.Base.Character.Inventory[Packet.ItemId].Effects.
                  Index[1] := 0;
                Player.Base.Character.Inventory[Packet.ItemId]
                  .Effects.Value[1] := 0;
              end;
            end
            else
            begin
              Player.Base.Character.Inventory[Packet.ItemId].Effects.
                Index[2] := 0;
              Player.Base.Character.Inventory[Packet.ItemId]
                .Effects.Value[2] := 0;
            end;
          end;
          if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
            TItemFunctions.DecreaseAmount(@Player.Base.Character.Inventory
              [VaizanSlot], 1)
          else
            TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);
        end;
    end;
    Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.ItemId,
      Player.Base.Character.Inventory[Packet.ItemId], false);
    Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
      Player.Base.Character.Inventory[VaizanSlot], false);
    Player.SendClientMessage('Adicionais do item limpos com sucesso.');
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end
  else if (Packet.Null3 = 6) then
  begin
    if (TItemFunctions.CanAgroup(Player.Base.Character.Inventory[Packet.ItemId]))
    then
    begin
      Player.SendClientMessage('Esse item não pode ser limpo.');
      Exit;
    end;
    if (Player.Base.Character.Inventory[Packet.ItemId].APP = 0) then
    begin
      Player.SendClientMessage('Esse item não possui aparencia.');
      Exit;
    end;
    if (Player.Base.Character.Inventory[Packet.ItemId].
      Index = Player.Base.Character.Inventory[Packet.ItemId].APP) then
    begin
      Player.SendClientMessage('Esse item já está limpo.');
      Exit;
    end;
    VaizanSlot := TItemFunctions.GetItemSlotByItemType(Player, 517, INV_TYPE);
    if (VaizanSlot = 255) then
    begin
      Player.SendClientMessage
        ('Você deve possuir o item Pedra Mágica da Restauração.');
      Exit;
    end;
    Player.Base.Character.Inventory[Packet.ItemId].APP :=
      Player.Base.Character.Inventory[Packet.ItemId].Index;
    if (Player.Base.Character.Inventory[VaizanSlot].Refi > 1) then
    begin
      Dec(Player.Base.Character.Inventory[VaizanSlot].Refi, 1);
      Player.Base.SendRefreshItemSlot(INV_TYPE, VaizanSlot,
        Player.Base.Character.Inventory[VaizanSlot], false);
    end
    else
      TItemFunctions.RemoveItem(Player, INV_TYPE, VaizanSlot);
    Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.ItemId,
      Player.Base.Character.Inventory[Packet.ItemId], false);
    Player.SendClientMessage('Aparência do item removida.');
    Player.SendPacket(Packet, Packet.Header.Size);
    Exit;
  end;
  MIIndex := TFunctions.SearchMakeItemIDByRewardID(Packet.ItemId);
  if (MIIndex = 3000) then
  begin
    Player.SendClientMessage('Item não encontrado na forja.');
    Exit;
  end;
  if (MakeItems[MIIndex].LevelMin + 1 > Player.Base.Character.Level) then
  begin
    Player.SendClientMessage('Você não possui o nível necessário.');
    Exit;
  end;
  if ((MakeItems[MIIndex].Price * Packet.Amount) > Player.Base.Character.Gold)
  then
  begin
    Player.SendClientMessage('Você não possui o gold necessário. ' +
      (MakeItems[MIIndex].Price * Packet.Amount).ToString + ' necessários.');
    Exit;
  end;
  EmptySlot := TItemFunctions.GetEmptySlot(Player);
  if (EmptySlot = 255) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  Helper1 := 1;
  if not(TItemFunctions.GetItemEquipSlot(MakeItems[MIIndex].ResultItemID)
    in [2, 3, 4, 5, 6, 7, 11, 12, 13, 14]) then
    Helper1 := Packet.Amount;
  cnt := 1;
  for I := Low(MakeItemsIngredients) to High(MakeItemsIngredients) do
  begin
    if not(MakeItems[MIIndex].ResultItemID = MakeItemsIngredients[I].id) then
      continue;
    if (Helper1 = 0) then
      Helper1 := 1;
    SetLength(ItemsRequired, cnt);
    ItemsRequired[cnt - 1].ItemId := MakeItemsIngredients[I].ItemId;
    ItemsRequired[cnt - 1].Amount := MakeItemsIngredients[I].Amount * Helper1;
    if (TItemFunctions.GetItemSlotAndAmountByIndex(Player,
      ItemsRequired[cnt - 1].ItemId, CurrentSlot, CurrentAmount)) then
    begin
      if (CurrentAmount < ItemsRequired[cnt - 1].Amount) then
      begin
        Player.SendClientMessage('Você precisa de (' +
          AnsiString(ItemsRequired[cnt - 1].Amount.ToString) + ') do item [' +
          AnsiString(ItemList[ItemsRequired[cnt - 1].ItemId].Name) + '].');
        Exit;
      end;
    end
    else
    begin
      Player.SendClientMessage('Você precisa ter o item [' +
        AnsiString(ItemList[ItemsRequired[cnt - 1].ItemId].Name) +
        ']. Separe a quantidade correta em apenas UM slot.');
      Exit;
    end;
    ItemsRequired[cnt - 1].Slot := CurrentSlot;
    Inc(cnt);
  end;
  Randomize;
  RandomTax := RandomRange(1, (MakeItems[MIIndex].TaxSuccess div 10) + 1);
  if (RandomTax <= (MakeItems[MIIndex].TaxSuccess div 10)) then
  begin
    Player.SendClientMessage('A criação do item foi bem sucedida.');
    Player.DecGold(MakeItems[MIIndex].Price * Helper1);
    TItemFunctions.PutItem(Player, MakeItems[MIIndex].ResultItemID, Helper1);
    for I := Low(ItemsRequired) to High(ItemsRequired) do
    begin
      if ((TItemFunctions.GetItemEquipSlot(ItemsRequired[I].ItemId) >= 2) and
        (TItemFunctions.GetItemEquipSlot(ItemsRequired[I].ItemId) <= 14)) then
        TItemFunctions.RemoveItem(Player, INV_TYPE, ItemsRequired[I].Slot)
      else
      begin
        TItemFunctions.DecreaseAmount(Player, ItemsRequired[I].Slot,
          ItemsRequired[I].Amount);
        Player.Base.SendRefreshItemSlot(INV_TYPE, ItemsRequired[I].Slot,
          Player.Base.Character.Inventory[ItemsRequired[I].Slot], false);
      end;
    end;
  end
  else
    Player.SendClientMessage('A criação do item falhou.');
  Result := True;
end;

class function TPacketHandlers.RepairItens(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TPacketRepareItens absolute Buffer;
  I, j, k: Integer;
  TotalToReapair: Single;
  TotalTo: Integer;
  LostDur: Integer;
  ItemsToRepairInv, ItemsToRepairEqp: Array of BYTE;
begin
  Result := false;

  if (Packet.Unk = 0) then
  begin
    TotalToReapair := 0;

    for I := 0 to 9 do
    begin
      case Packet.ItensToRepareSlotType[I] of
        0: // equip
          begin
            if (Player.Base.Character.Equip[Packet.ItensToRepareSlot[I]].
              Index = 0) then
              continue;

            LostDur := Player.Base.Character.Equip[Packet.ItensToRepareSlot[I]]
              .MAX - Player.Base.Character.Equip
              [Packet.ItensToRepareSlot[I]].MIN;

            if (ItemList[Player.Base.Character.Equip[Packet.ItensToRepareSlot[I]
              ].Index].Rank = 0) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Equip[Packet.ItensToRepareSlot
                [I]].Index].SellPrince * 0.00025) * LostDur);
            end
            else if (ItemList[Player.Base.Character.Equip
              [Packet.ItensToRepareSlot[I]].Index].Rank = 1) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Equip[Packet.ItensToRepareSlot
                [I]].Index].SellPrince * 0.00025) * LostDur);
            end
            else
            begin
              TotalToReapair := TotalToReapair +
                (((ItemList[Player.Base.Character.Equip[Packet.ItensToRepareSlot
                [I]].Index].SellPrince * 0.00025) *
                (ItemList[Player.Base.Character.Equip[Packet.ItensToRepareSlot
                [I]].Index].Rank - 1)) * LostDur);
            end;

          end;

        1: // inventário
          begin
            if (Player.Base.Character.Inventory[Packet.ItensToRepareSlot[I]].
              Index = 0) then
              continue;

            LostDur := Player.Base.Character.Inventory
              [Packet.ItensToRepareSlot[I]].MAX -
              Player.Base.Character.Inventory[Packet.ItensToRepareSlot[I]].MIN;

            if (ItemList[Player.Base.Character.Inventory
              [Packet.ItensToRepareSlot[I]].Index].Rank = 0) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Inventory
                [Packet.ItensToRepareSlot[I]].Index].SellPrince * 0.00025)
                * LostDur);
            end
            else if (ItemList[Player.Base.Character.Inventory
              [Packet.ItensToRepareSlot[I]].Index].Rank = 1) then
            begin
              TotalToReapair := TotalToReapair +
                ((ItemList[Player.Base.Character.Inventory
                [Packet.ItensToRepareSlot[I]].Index].SellPrince * 0.00025)
                * LostDur);
            end
            else
            begin
              TotalToReapair := TotalToReapair +
                (((ItemList[Player.Base.Character.Inventory
                [Packet.ItensToRepareSlot[I]].Index].SellPrince * 0.00025) *
                (ItemList[Player.Base.Character.Inventory
                [Packet.ItensToRepareSlot[I]].Index].Rank - 1)) * LostDur);
            end;

          end;

        255:
          begin
            continue;
          end;
      end;
    end;

    TotalTo := Round(TotalToReapair);

    if (Player.Base.Character.Gold < TotalTo) then
    begin
      Player.SendClientMessage('Você necessita de ' + TotalTo.ToString +
        ' de gold para realizar essa ação.');
      Exit;
    end;

    Player.DecGold(TotalTo);

    for I := 0 to 9 do
    begin
      case Packet.ItensToRepareSlotType[I] of
        0: // equip
          begin
            Player.Base.Character.Equip[Packet.ItensToRepareSlot[I]].MIN :=
              Player.Base.Character.Equip[Packet.ItensToRepareSlot[I]].MAX;
            Player.Base.SendRefreshItemSlot(EQUIP_TYPE,
              Packet.ItensToRepareSlot[I], Player.Base.Character.Equip
              [Packet.ItensToRepareSlot[I]], false);
          end;

        1: // inventário
          begin
            Player.Base.Character.Inventory[Packet.ItensToRepareSlot[I]].MIN :=
              Player.Base.Character.Inventory[Packet.ItensToRepareSlot[I]].MAX;
            Player.Base.SendRefreshItemSlot(INV_TYPE,
              Packet.ItensToRepareSlot[I], Player.Base.Character.Inventory
              [Packet.ItensToRepareSlot[I]], false);
          end;

        255:
          begin
            continue;
          end;
      end;
    end;

    Player.SendPacket(Packet, Packet.Header.Size);
  end
  else if (Packet.Unk = 1) then
  begin
    SetLength(ItemsToRepairInv, 0);

    TotalToReapair := 0;

    for I := 0 to 119 do
    begin
      if (Player.Base.Character.Inventory[I].Index = 0) then
        continue;

      if ((Player.Base.Character.Inventory[I].MAX = 0) or
        (Player.Base.Character.Inventory[I].MIN = Player.Base.Character.
        Inventory[I].MAX)) then
        continue;

      SetLength(ItemsToRepairInv, Length(ItemsToRepairInv) + 1);
      ItemsToRepairInv[Length(ItemsToRepairInv) - 1] := I;

      LostDur := Player.Base.Character.Inventory[I].MAX -
        Player.Base.Character.Inventory[I].MIN;
      if (ItemList[Player.Base.Character.Inventory[I].Index].Rank = 0) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Inventory[I].Index].SellPrince *
          0.00025) * LostDur);
      end
      else if (ItemList[Player.Base.Character.Inventory[I].Index].Rank = 1) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Inventory[I].Index].SellPrince *
          0.00025) * LostDur);
      end
      else
      begin
        TotalToReapair := TotalToReapair +
          (((ItemList[Player.Base.Character.Inventory[I].Index].SellPrince *
          0.00025) * (ItemList[Player.Base.Character.Inventory[I].Index].Rank -
          1)) * LostDur);
      end;

    end;

    SetLength(ItemsToRepairEqp, 0);

    for I := 2 to 7 do
    begin
      if (Player.Base.Character.Equip[I].Index = 0) then
        continue;

      if ((Player.Base.Character.Equip[I].MAX = 0) or
        (Player.Base.Character.Equip[I].MIN = Player.Base.Character.Equip[I]
        .MAX)) then
        continue;

      SetLength(ItemsToRepairEqp, Length(ItemsToRepairEqp) + 1);
      ItemsToRepairEqp[Length(ItemsToRepairEqp) - 1] := I;

      LostDur := Player.Base.Character.Equip[I].MAX -
        Player.Base.Character.Equip[I].MIN;
      if (ItemList[Player.Base.Character.Equip[I].Index].Rank = 0) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Equip[I].Index].SellPrince * 0.00025)
          * LostDur);
      end
      else if (ItemList[Player.Base.Character.Equip[I].Index].Rank = 1) then
      begin
        TotalToReapair := TotalToReapair +
          ((ItemList[Player.Base.Character.Equip[I].Index].SellPrince * 0.00025)
          * LostDur);
      end
      else
      begin
        TotalToReapair := TotalToReapair +
          (((ItemList[Player.Base.Character.Equip[I].Index].SellPrince *
          0.00025) * (ItemList[Player.Base.Character.Equip[I].Index].Rank - 1))
          * LostDur);
      end;

    end;

    TotalTo := Round(TotalToReapair);

    if (Player.Base.Character.Gold < TotalTo) then
    begin
      Player.SendClientMessage('Você necessita de ' + TotalTo.ToString +
        ' de gold para realizar essa ação.');
      Exit;
    end;

    Player.DecGold(TotalTo);

    if (Length(ItemsToRepairInv) > 0) then
    begin
      for I := 0 to Length(ItemsToRepairInv) - 1 do
      begin
        Player.Base.Character.Inventory[ItemsToRepairInv[I]].MIN :=
          Player.Base.Character.Inventory[ItemsToRepairInv[I]].MAX;
        Player.Base.SendRefreshItemSlot(INV_TYPE, ItemsToRepairInv[I],
          Player.Base.Character.Inventory[ItemsToRepairInv[I]], false);
      end;
    end;

    if (Length(ItemsToRepairEqp) > 0) then
    begin
      for I := 0 to Length(ItemsToRepairEqp) - 1 do
      begin
        Player.Base.Character.Equip[ItemsToRepairEqp[I]].MIN :=
          Player.Base.Character.Equip[ItemsToRepairEqp[I]].MAX;
        Player.Base.SendRefreshItemSlot(EQUIP_TYPE, ItemsToRepairEqp[I],
          Player.Base.Character.Equip[ItemsToRepairEqp[I]], false);
      end;
    end;

    Player.SendPacket(Packet, Packet.Header.Size);
  end;
  Sair(Player);

  Result := True;
end;

class function TPacketHandlers.RenoveItem(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TPacketRenoveItem absolute Buffer;
  ItemToRenove, Item1: pItem;
begin
  Result := false;

  if (Packet.SlotItemToRenove in [1 .. 119]) and (Packet.SlotItem1 in [1 .. 119])
  then
  begin
    ItemToRenove := @Player.Base.Character.Inventory[Packet.SlotItemToRenove];
    Item1 := @Player.Base.Character.Inventory[Packet.SlotItem1];

    case ItemList[Item1.Index].ItemType of
      35: // reparador de roupa de pran
        if (ItemList[ItemToRenove.Index].Classe in [100 .. 104]) then
        begin // é realmente roupa de pran
          ItemToRenove.MIN := 0;
          ItemToRenove.MAX := 0;
          ItemToRenove.ExpireDate :=
            IncHour(Now, ItemList[Item1.Index].UseEffect);

          TItemFunctions.DecreaseAmount(Player, Packet.SlotItem1, 1);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItem1,
            Item1^, false);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItemToRenove,
            ItemToRenove^, false);

          Player.Base.SendPacket(Packet, Packet.Header.Size);
          Player.SendClientMessage('Você renovou o item [' +
            ItemList[ItemToRenove.Index].Name + '] por mais ' +
            (ItemList[Item1.Index].UseEffect div 24).ToString + ' dias.');
        end;

      520: // licença de montaria
        if (TItemFunctions.GetItemEquipSlot(ItemToRenove.Index) = 9) then
        begin // é realmente montaria
          ItemToRenove.ExpireDate :=
            IncHour(Now, ItemList[Item1.Index].UseEffect);

          TItemFunctions.DecreaseAmount(Player, Packet.SlotItem1, 1);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItem1,
            Item1^, false);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Packet.SlotItemToRenove,
            ItemToRenove^, false);

          Player.Base.SendPacket(Packet, Packet.Header.Size);
          Player.SendClientMessage('Você renovou o item [' +
            ItemList[ItemToRenove.Index].Name + '] por mais ' +
            (ItemList[Item1.Index].UseEffect div 24).ToString + ' dias.');
        end;
    end;
  end;

  Result := True;
end;
{$ENDREGION}
{$REGION 'Nation Packets'}

class function TPacketHandlers.UpdateNationGold(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TUpdateNationTreasure absolute Buffer;
begin
  Result := True;
  Packet.Gold := 0;
  if Player.Base.Character.Nation <> 0 then
    Packet.Gold := Nations[Player.Base.Character.Nation - 1].NationGold;
  Player.SendPacket(Packet, SizeOf(Packet));
end;

class function TPacketHandlers.UpdateNationTaxes(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TUpdateNationTaxes absolute Buffer;
  CitizenTax, VisitorTax: BYTE;
  I, j: Integer;
begin
  Result := True;
  if not Player.IsMarshal then
    Exit;

  CitizenTax := Packet.CitizenTax;
  VisitorTax := Packet.VisitorTax;

  if (CitizenTax < 5) or (CitizenTax > 15) or (VisitorTax < 10) or
    (VisitorTax > 20) then
    Exit;

  Nations[Player.Base.Character.Nation - 1].CitizenTax := CitizenTax;
  Nations[Player.Base.Character.Nation - 1].VisitorTax := VisitorTax;
  Nations[Player.Base.Character.Nation - 1].SaveNationTaxes;

  for I := Low(Servers) to High(Servers) do
  begin
    for j := Low(Servers[I].Players) to High(Servers[I].Players) do
    begin
      if (Servers[I].Players[j].Status >= Playing) and
        (Servers[I].Players[j].Base.Character.Nation = Player.Base.Character.
        Nation) then
      begin
        Servers[I].Players[j].SendClientMessage
          ('A taxa de sua nação foi setada em ' +
          AnsiString(CitizenTax.ToString) + '% para cidadãos e ' +
          AnsiString(VisitorTax.ToString) + '% para não-cidadãos.');
        Servers[I].Players[j].SendNationInformation;
      end;
    end;
  end;
end;

class function TPacketHandlers.RequestUpdateReliquare(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TRequestDevirInfoPacket absolute Buffer;
begin
  if Packet.Channel = 4 then
    Packet.Channel := 2;
  Player.SendUpdateReliquareInformation
    (IfThen(Packet.Channel > High(Servers) + 1, Player.ChannelIndex,
    Packet.Channel));
end;

{$ENDREGION}
{$REGION 'GM Tool Packets'}
// class function TPacketHandlers.CheckGMLogin(var Player: TPlayer;
// Buffer: array of BYTE): boolean;
// var
// Packet: TPacketLoginIntoServer absolute Buffer;
// Packet2: TPacketLoginIntoServerResponse;
// PasswordErrors: Integer;
// MasterPriv: Integer;
// xPassword: String;
// SQLComp: TQuery;
//
// begin
// ZeroMemory(@Packet2, SizeOf(TPacketLoginIntoServerResponse));
// Packet2.Header.Size := SizeOf(TPacketLoginIntoServerResponse);
// Packet2.Header.Index := Player.Base.ClientID;
// Packet2.Header.Code := $3203;
// Packet2.Response := -1;
// if (Trim(String(Packet.Username)) = '') then
// begin
// Logger.Write('Username vazio', TLogType.Warnings);
// Player.SendPacket(Packet2, Packet2.Header.Size);
// Exit;
// end;
// SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE));
// if not(SQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[CheckGMLogin]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[CheckGMLogin]', TLogType.Error);
// SQLComp.Free;
// Exit;
// end;
// SQLComp.SetQuery(Format('SELECT * FROM gm_accounts WHERE' + ' username=%s',
// [QuotedStr(String(Packet.Username))]));
// SQLComp.Run(True);
// if (SQLComp.Query.RowsAffected = 0) then
// begin
// Logger.Write('Username não encontrado. ' + String(Packet.Username),
// TLogType.Warnings);
// SQLComp.Free;
// Player.SendPacket(Packet2, Packet2.Header.Size);
// Exit;
// end;
// if (SQLComp.Query.FieldByName('account_status').AsInteger = 0) then
// begin
// Logger.Write('Account GM blocked by excessible passoword errors.',
// TLogType.Error);
// SQLComp.Free;
// Player.SendPacket(Packet2, Packet2.Header.Size);
// Exit;
// end;
// MasterPriv := SQLComp.Query.FieldByName('master_priv').AsInteger;
// xPassword := SQLComp.Query.FieldByName('password').AsString;
// if (String(Packet.Password) <> TFunctions.StringToMd5(xPassword)) then
// begin
// PasswordErrors := SQLComp.Query.FieldByName('password_errors').AsInteger;
// if (PasswordErrors >= 5) then
// begin
// SQLComp.SetQuery
// (Format('UPDATE gm_accounts SET account_status = 0 where username = %s',
// [QuotedStr(String(Packet.Username))]));
// SQLComp.Run(false);
// end
// else
// begin
// Inc(PasswordErrors);
// SQLComp.SetQuery
// (Format('UPDATE gm_accounts SET password_errors = %d where username = %s',
// [PasswordErrors, QuotedStr(String(Packet.Username))]));
// SQLComp.Run(false);
// end;
// Logger.Write('As senhas diferem. packet: ' + String(Packet.Password) +
// ' db: ' + TFunctions.StringToMd5(xPassword), TLogType.Warnings);
// SQLComp.Free;
// Player.SendPacket(Packet2, Packet2.Header.Size);
// Exit;
// end
// else
// begin
// SQLComp.SetQuery
// (Format('UPDATE gm_accounts SET password_errors = %d where username = %s',
// [0, QuotedStr(String(Packet.Username))]));
// SQLComp.Run(false);
// end;
// Logger.Write('Super Usuário logado usando username: ' +
// String(Packet.Username), TLogType.ConnectionsTraffic);
// Packet2.Response := 1;
// Player.SendPacket(Packet2, Packet2.Header.Size);
// Player.Base.SessionOnline := True;
// Player.Base.SessionUsername := String(Packet.Username);
// Player.Base.SessionMasterPriv := TMasterPrives(MasterPriv);
// SQLComp.Free;
// end;
//
// class function TPacketHandlers.GMPlayerMove(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TMovePacket absolute Buffer;
// OtherPlayer: PPlayer;
// begin
// Result := false;
// if (Player.Base.SessionOnline) then
// begin
// if (Player.Base.SessionMasterPriv < ModeradorPriv) then
// Exit;
// if not(Packet.Position.IsValid) then
// Exit;
// if (Trim(String(Packet.NickName)) = '') then
// Exit;
// Servers[Player.ChannelIndex].GetPlayerByName(String(Packet.NickName),
// OtherPlayer);
// if (OtherPlayer^.Status < Playing) then
// Exit;
// OtherPlayer^.Teleport(Packet.Position);
// if (String(Player.Base.Character.Name) <> String(Packet.NickName)) then
// begin
// OtherPlayer^.SendClientMessage('Você foi teleportado pelo <' +
// String(Player.Base.Character.Name) +
// '> com atributos de Administrador.');
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> MOVEU o personagem {' + String(OtherPlayer^.Base.Character.Name) +
// '} para a posição X: ' + Packet.Position.X.ToString + ' Y: ' +
// Packet.Position.Y.ToString, TLogType.Painel);
// Result := True;
// end;
// end;
//
// class function TPacketHandlers.GMSendChat(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TClientMessagePacket2 absolute Buffer;
// I: Integer;
// str_aux: String;
// begin
// try
// if (Player.Base.SessionOnline) then
// begin
// if (Player.Base.SessionMasterPriv < ModeradorPriv) then
// Exit;
//
// str_aux := Copy(Packet.Msg, 0, 90);
// if (Packet.Type2 = 1) then
// begin
// for I := Low(Servers) to High(Servers) do
// begin
// if not(Servers[I].IsActive) then
// continue;
// Servers[I].SendServerMsg
// (AnsiString('<[GameMaster] ' + Player.Base.Character.Name + '> ' +
// str_aux), Packet.Type1, Packet.Null);
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> GRITOU mundialmente a seguinte mensagem {' + String(str_aux) + '}',
// TLogType.Painel);
// Exit;
// end;
// Servers[Player.ChannelIndex].SendServerMsg
// (AnsiString('<[GameMaster] ' + Player.Base.Character.Name + '> ' +
// str_aux), Packet.Type1, Packet.Null);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> GRITOU localmente a seguinte mensagem {' + String(str_aux) + '}',
// TLogType.Painel);
// end;
// except
// { on E: Exception do
// begin
// Logger.Write('Erro TPacketHandlers.GMSendChat ' + E.Message + ' ' +
// , TlogType.Error);
// end; }
// end;
// end;
//
// class function TPacketHandlers.GMGoldManagment(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendGoldAddRemove absolute Buffer;
// I: Integer;
// OtherPlayer: PPlayer;
// begin
// OtherPlayer := Nil;
// if (Player.CheckAdminLogged) then
// begin
// if (Trim(String(Packet.NickName)) = '') then
// begin // ir por targetid
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
// if (OtherPlayer <> nil) then
// begin
// if (Packet.Add) then
// begin // adicionar
// OtherPlayer.AddGold(Packet.Gold);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> CRIOU GOLD para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Gold.ToString + ' §', TLogType.Painel);
// end
// else
// begin
// if not(Packet.RemoveAllGold) then
// begin // remover
// if (((OtherPlayer.Character.Base.Gold - Packet.Gold) <= 0) or
// (OtherPlayer.Character.Base.Gold = 0)) then
// begin
// OtherPlayer.Character.Base.Gold := 0;
// OtherPlayer.RefreshMoney;
// end
// else
// begin
// OtherPlayer.Character.Base.Gold :=
// (OtherPlayer.Character.Base.Gold - Packet.Gold);
// OtherPlayer.RefreshMoney;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> REMOVEU GOLD para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Gold.ToString + ' §', TLogType.Painel);
// end
// else
// begin // zerar
// OtherPlayer.Character.Base.Gold := 0;
// OtherPlayer.RefreshMoney;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ZEROU GOLD para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}', TLogType.Painel);
// end;
// end;
//
// end;
// end
// else // ir por nickname
// begin
// for I := Low(Servers) to High(Servers) do
// begin
// OtherPlayer := Nil;
// OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
// if (OtherPlayer = nil) then
// begin
// continue;
// end;
// if (Packet.Add) then
// begin // adicionar
// OtherPlayer.AddGold(Packet.Gold);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> CRIOU GOLD para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Gold.ToString + ' §', TLogType.Painel);
// end
// else
// begin
// if not(Packet.RemoveAllGold) then
// begin // remover
// if (((OtherPlayer.Character.Base.Gold - Packet.Gold) <= 0) or
// (OtherPlayer.Character.Base.Gold = 0)) then
// begin
// OtherPlayer.Character.Base.Gold := 0;
// OtherPlayer.RefreshMoney;
// end
// else
// begin
// OtherPlayer.Character.Base.Gold :=
// (OtherPlayer.Character.Base.Gold - Packet.Gold);
// OtherPlayer.RefreshMoney;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> REMOVEU GOLD para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Gold.ToString + ' §', TLogType.Painel);
// end
// else
// begin // zerar
// OtherPlayer.Character.Base.Gold := 0;
// OtherPlayer.RefreshMoney;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ZEROU GOLD para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}', TLogType.Painel);
// end;
// end;
// end;
// end;
// end;
// end;
//
// class function TPacketHandlers.GMCashManagment(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendCashAddRemove absolute Buffer;
// I: Integer;
// OtherPlayer: PPlayer;
// begin
// OtherPlayer := Nil;
// if (Player.CheckAdminLogged) then
// begin
// if (Trim(String(Packet.NickName)) = '') then
// begin // ir por targetid
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
// if (OtherPlayer <> nil) then
// begin
// if (Packet.Add) then
// begin // adicionar
// OtherPlayer.AddCash(Packet.Cash);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> CRIOU CASH para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Cash.ToString + ' §', TLogType.Painel);
// end
// else
// begin
// if not(Packet.RemoveAllCash) then
// begin // remover
// if (((OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash)
// <= 0) or (OtherPlayer.Account.Header.CashInventory.Cash = 0)) then
// begin
// OtherPlayer.Account.Header.CashInventory.Cash := 0;
// OtherPlayer.SendPlayerCash;
// end
// else
// begin
// OtherPlayer.Account.Header.CashInventory.Cash :=
// (OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash);
// OtherPlayer.SendPlayerCash;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> REMOVEU CASH para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Cash.ToString + ' §', TLogType.Painel);
// end
// else
// begin // zerar
// OtherPlayer.Account.Header.CashInventory.Cash := 0;
// OtherPlayer.SendPlayerCash;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ZEROU CASH para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}', TLogType.Painel);
// end;
// end;
// end;
// end
// else // ir por nickname
// begin
// for I := Low(Servers) to High(Servers) do
// begin
// OtherPlayer := Nil;
// OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
// if (OtherPlayer = nil) then
// begin
// continue;
// end;
// if (Packet.Add) then
// begin // adicionar
// OtherPlayer.AddCash(Packet.Cash);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> CRIOU CASH para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Cash.ToString + ' §', TLogType.Painel);
// end
// else
// begin
// if not(Packet.RemoveAllCash) then
// begin // remover
// if (((OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash)
// <= 0) or (OtherPlayer.Account.Header.CashInventory.Cash = 0)) then
// begin
// OtherPlayer.Account.Header.CashInventory.Cash := 0;
// OtherPlayer.SendPlayerCash;
// end
// else
// begin
// OtherPlayer.Account.Header.CashInventory.Cash :=
// (OtherPlayer.Account.Header.CashInventory.Cash - Packet.Cash);
// OtherPlayer.SendPlayerCash;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> REMOVEU CASH para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Cash.ToString + ' §', TLogType.Painel);
// end
// else
// begin // zerar
// OtherPlayer.Account.Header.CashInventory.Cash := 0;
// OtherPlayer.SendPlayerCash;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ZEROU CASH para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}', TLogType.Painel);
// end;
// end;
// end;
// end;
// end;
// end;
//
// class function TPacketHandlers.GMLevelManagment(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendLevelAddRemove absolute Buffer;
// I, gmuid, Helper: Integer;
// OtherPlayer: PPlayer;
// LevelExp: UInt64;
// AddExp: UInt64;
// MySQLComp: TQuery;
// begin
// OtherPlayer := Nil;
// if (Player.CheckGameMasterLogged) then
// begin
// if (Player.CheckAdminLogged) then
// begin
// if (Trim(String(Packet.NickName)) = '') then
// begin // ir por targetid
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
// if (OtherPlayer <> nil) then
// begin
// if (Packet.Add) then
// begin // adicionar
// try
// LevelExp := ExpList[Player.Character.Base.Level +
// (Packet.Level - 1)] + 1;
// except
// LevelExp := High(ExpList);
// end;
// AddExp := LevelExp - UInt64(Player.Character.Base.Exp);
// OtherPlayer.AddExp(AddExp, Helper);
// OtherPlayer.Base.SendRefreshLevel;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> CRIOU LEVEL para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Level.ToString + ' §', TLogType.Painel);
// end
// else
// begin
// if not(Packet.RemoveAllLevel) then
// begin // remover
// if (((OtherPlayer.Base.Character.Level - Packet.Level) <= 0) or
// (OtherPlayer.Base.Character.Level = 1)) then
// begin
// OtherPlayer.Base.Character.Level := 1;
// OtherPlayer.Base.Character.Exp := 1;
// OtherPlayer.Base.SendRefreshLevel;
// end
// else
// begin
// OtherPlayer.Base.Character.Level :=
// (OtherPlayer.Base.Character.Level - Packet.Level);
// OtherPlayer.Base.Character.Exp :=
// ExpList[OtherPlayer.Base.Character.Level];
// OtherPlayer.Base.SendRefreshLevel;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name)
// + '> REMOVEU LEVEL para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § '
// + Packet.Level.ToString + ' §', TLogType.Painel);
// end
// else
// begin // zerar
// OtherPlayer.Base.Character.Level := 1;
// OtherPlayer.Base.Character.Exp := 1;
// OtherPlayer.Base.SendRefreshLevel;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name)
// + '> ZEROU LEVEL para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}',
// TLogType.Painel);
// end;
// end;
// end;
// end
// else // ir por nickname
// begin
// for I := Low(Servers) to High(Servers) do
// begin
// OtherPlayer := Nil;
// OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
// if (OtherPlayer = nil) then
// begin
// continue;
// end;
// if (Packet.Add) then
// begin // adicionar
// try
// LevelExp := ExpList[Player.Character.Base.Level +
// (Packet.Level - 1)] + 1;
// except
// LevelExp := High(ExpList);
// end;
// AddExp := LevelExp - UInt64(Player.Character.Base.Exp);
// OtherPlayer.AddExp(AddExp, Helper);
// OtherPlayer.Base.SendRefreshLevel;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> CRIOU LEVEL para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § ' +
// Packet.Level.ToString + ' §', TLogType.Painel);
// end
// else
// begin
// if not(Packet.RemoveAllLevel) then
// begin // remover
// if (((OtherPlayer.Base.Character.Level - Packet.Level) <= 0) or
// (OtherPlayer.Base.Character.Level = 1)) then
// begin
// OtherPlayer.Base.Character.Level := 1;
// OtherPlayer.Base.Character.Exp := 1;
// OtherPlayer.Base.SendRefreshLevel;
// end
// else
// begin
// OtherPlayer.Base.Character.Level :=
// (OtherPlayer.Base.Character.Level - Packet.Level);
// OtherPlayer.Base.Character.Exp :=
// ExpList[OtherPlayer.Base.Character.Level];
// OtherPlayer.Base.SendRefreshLevel;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name)
// + '> REMOVEU LEVEL para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} na quantia de § '
// + Packet.Level.ToString + ' §', TLogType.Painel);
// end
// else
// begin // zerar
// OtherPlayer.Base.Character.Level := 1;
// OtherPlayer.Base.Character.Exp := 1;
// OtherPlayer.Base.SendRefreshLevel;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name)
// + '> ZEROU LEVEL para o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}',
// TLogType.Painel);
// end;
// end;
// end;
// end;
// end
// else // gerar a assinatura do comando
// begin
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMLevelManagment]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMLevelManagment]',
// TLogType.Error);
// Exit;
// end;
//
// MySQLComp.SetQuery('select id from gm_accounts where username = ' +
// QuotedStr(Player.Base.SessionUsername));
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
// gmuid := MySQLComp.Query.Fields[0].AsInteger;
//
// if (Trim(String(Packet.NickName)) = '') then
// begin
// MySQLComp.SetQuery
// (Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'
// + 'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'
// + 'refused_at, reason_run, reason_refuse) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'
// + '%d, %s, %s, %s)', [gmuid, LEVEL_GMCOMMAND, 0,
// QuotedStr('UPDATE characters SET level = (level + ' +
// Packet.Level.ToString + ') WHERE ' + 'clientid = ' +
// QuotedStr(Packet.TargetID.ToString) + ';'),
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr('1899-12-30'), QuotedStr(''),
// QuotedStr(String(Servers[Player.ChannelIndex].Players
// [Packet.TargetID].Base.Character.Name)), 0, Packet.Level, 0,
// QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr('')]));
// end
// else
// begin
// MySQLComp.SetQuery
// (Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'
// + 'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'
// + 'refused_at, reason_run, reason_refuse) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'
// + '%d, %s, %s, %s)', [gmuid, LEVEL_GMCOMMAND, 0,
// QuotedStr('UPDATE characters SET level = (level + ' +
// Packet.Level.ToString + ') WHERE ' + 'name = ' +
// QuotedStr(String(Packet.NickName)) + ';'),
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr('1899-12-30'), QuotedStr(''),
// QuotedStr(String(Packet.NickName)), 0, Packet.Level, 0,
// QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr('')]));
// end;
// MySQLComp.Run(false);
//
// MySQLComp.Free;
// end;
// end;
// end;
// end;
//
// class function TPacketHandlers.GMBuffsManagment(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendBuffAddRemove absolute Buffer;
// I: Integer;
// OtherPlayer: PPlayer;
// begin
// OtherPlayer := Nil;
// if (Player.CheckAdminLogged) then
// begin
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
// if (OtherPlayer <> nil) then
// begin
// if (Packet.Add = 1) then
// begin // adicionar
// OtherPlayer.Base.AddBuff(Packet.BuffID);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> BUFFOU o personagem {' + String(OtherPlayer^.Base.Character.Name) +
// '} com o buff § [' + Packet.BuffID.ToString + '] ' +
// String(SkillData[Packet.BuffID].Name) + ' §', TLogType.Painel);
// end
// else
// begin
// if not(Packet.RemoveAllBuff = 1) then
// begin // remover
// OtherPlayer.Base.RemoveBuff(Packet.BuffID);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> REMOVEU BUFF do personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} buff § [' +
// Packet.BuffID.ToString + '] ' +
// String(SkillData[Packet.BuffID].Name) + ' §', TLogType.Painel);
// end
// else
// begin // zerar
// OtherPlayer.Base.ZerarBuffs();
// OtherPlayer.Base.GetCurrentScore;
// OtherPlayer.Base.SendStatus;
// OtherPlayer.Base.SendRefreshPoint;
// OtherPlayer.Base.SendRefreshBuffs;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ZEROU BUFFS do personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}', TLogType.Painel);
// end;
// end;
// end;
// end;
// Result := True;
// end;
//
// class function TPacketHandlers.GMDisconnect(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendDisconnect absolute Buffer;
// I: Integer;
// OtherPlayer: PPlayer;
// begin
// OtherPlayer := Nil;
// if (Player.CheckGameMasterLogged) then
// begin
// if (Trim(String(Packet.NickName)) = '') then
// begin // ir por targetid
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
// if (OtherPlayer <> nil) then
// begin
// OtherPlayer.SendCloseClient;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> DESCONECTOU o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}', TLogType.Painel);
// end;
// end
// else
// begin // ir por nickname
// for I := Low(Servers) to High(Servers) do
// begin
// OtherPlayer := Nil;
// OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
// if (OtherPlayer = nil) then
// begin
// continue;
// end;
// OtherPlayer.SendCloseClient;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> DESCONECTOU o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '}', TLogType.Painel);
// end;
// end;
// end;
// end;
//
// class function TPacketHandlers.GMBan(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendBan absolute Buffer;
// I, j: Integer;
// OtherPlayer: PPlayer;
// begin
// OtherPlayer := Nil;
// if (Player.CheckGameMasterLogged) then
// begin
// if (Trim(String(Packet.NickName)) = '') then
// begin // ir por targetid
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
// if (OtherPlayer <> nil) then
// begin
// if (Packet.Days >= 1000) then
// begin // ban perma
// OtherPlayer.Account.Header.AccountStatus := 8;
// for j := Low(Servers) to High(Servers) do
// begin
// if (Trim(String(Packet.Reason)) = '') then
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido permanentemente. Motivo do ban não apresentado.',
// 16, 32, 16);
// end
// else
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido permanentemente. Motivo do ban: ', 16, 32, 16);
// Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
// end;
// end;
// OtherPlayer.SendCloseClient;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> BANIU PERMANENTE o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} com o motivo § ' +
// String(Packet.Reason) + ' §', TLogType.Painel);
// end
// else // ban by days
// begin
// OtherPlayer.Account.Header.AccountStatus := 8;
// OtherPlayer.Account.Header.BanDays := Packet.Days;
// for j := Low(Servers) to High(Servers) do
// begin
// if (Trim(String(Packet.Reason)) = '') then
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
// ' dias. Motivo do ban não apresentado.', 16, 32, 16);
// end
// else
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
// ' dias. Motivo do ban: ', 16, 32, 16);
// Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
// end;
// end;
// OtherPlayer.SendCloseClient;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> BANIU POR ' + Packet.Days.ToString + ' dia(s) o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} com o motivo § ' +
// String(Packet.Reason) + ' §', TLogType.Painel);
// end;
// end;
// end
// else
// begin
// for I := Low(Servers) to High(Servers) do
// begin
// OtherPlayer := Nil;
// OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
// if (OtherPlayer = nil) then
// begin
// continue;
// end;
// if (Packet.Days >= 1000) then
// begin // ban perma
// OtherPlayer.Account.Header.AccountStatus := 8;
// for j := Low(Servers) to High(Servers) do
// begin
// if (Trim(String(Packet.Reason)) = '') then
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido permanentemente. Motivo do ban não apresentado.',
// 16, 32, 16);
// end
// else
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido permanentemente. Motivo do ban: ', 16, 32, 16);
// Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
// end;
// end;
// OtherPlayer.SendCloseClient;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> BANIU PERMANENTE o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} com o motivo § ' +
// String(Packet.Reason) + ' §', TLogType.Painel);
// end
// else // ban by days
// begin
// OtherPlayer.Account.Header.AccountStatus := 8;
// OtherPlayer.Account.Header.BanDays := Packet.Days;
// for j := Low(Servers) to High(Servers) do
// begin
// if (Trim(String(Packet.Reason)) = '') then
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
// ' dias. Motivo do ban não apresentado.', 16, 32, 16);
// end
// else
// begin
// Servers[j].SendServerMsg
// ('O jogador <' + AnsiString(OtherPlayer.Base.Character.Name) +
// '> foi banido por ' + AnsiString(IntToStr(Packet.Days)) +
// ' dias. Motivo do ban: ', 16, 32, 16);
// Servers[j].SendServerMsg(AnsiString(Packet.Reason), 16, 32, 16);
// end;
// end;
// OtherPlayer.SendCloseClient;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> BANIU POR ' + Packet.Days.ToString + ' dia(s) o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} com o motivo § ' +
// String(Packet.Reason) + ' §', TLogType.Painel);
// end;
// end;
// end;
// end;
// end;
//
// class function TPacketHandlers.GMEventItem(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendItemEventOne absolute Buffer;
// I, j: Integer;
// OtherPlayer: PPlayer;
// SQLComp: TQuery;
// MySQLComp: TQuery; // Declaração local
// gmuid: Integer;
//
// begin
// if (Player.CheckModeratorLogged) then
// begin
// if (Player.CheckAdminLogged) then
// begin
// if (Trim(String(Packet.NickName)) = '') then
// begin // ir por targetid
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
// if (OtherPlayer <> nil) then
// begin
// SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), True);
// if not(SQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMEventItem]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItem]',
// TLogType.Error);
// SQLComp.Free;
// Exit;
// end;
//
// SQLComp.SetQuery
// (Format('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '
// + 'identific, effect1_index, effect1_value, effect2_index, effect2_value, '
// + 'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) '
// + 'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)',
// [EVENT_ITEM, OtherPlayer.Character.Base.CharIndex, Packet.ItemId,
// Packet.Amount]));
// SQLComp.Query.Connection.StartTransaction;
// SQLComp.Run(false);
// SQLComp.Query.Connection.Commit;
// Player.SendClientMessage('Item de Evento "T" enviado com sucesso.',
// 32, 16, 32);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ENVIOU ITEM EVENTO "T" o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} item § [' +
// Packet.ItemId.ToString + '] ' + String(ItemList[Packet.ItemId].Name)
// + ' QTDE: ' + Packet.Amount.ToString + ' §', TLogType.Painel);
// SQLComp.Free;
// end;
// end
// else
// begin
// SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
// AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
// AnsiString(MYSQL_DATABASE));
// if not(SQLComp.Query.Connection.Connected) then
// begin
// OtherPlayer := Nil;
// OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
// if (OtherPlayer = nil) then
// // begin
// // break;  dava erro aqui antes break ou continue então foi comentado
// // end;
// SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), True);
// if not(SQLComp.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMEventItem-else]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItem-else]',
// TLogType.Error);
// SQLComp.Free;
// Exit;
// end;
// SQLComp.SetQuery
// (Format('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '
// + 'identific, effect1_index, effect1_value, effect2_index, effect2_value, '
// + 'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) '
// + 'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)',
// [EVENT_ITEM, OtherPlayer.Character.Base.CharIndex, Packet.ItemId,
// Packet.Amount]));
// SQLComp.Query.Connection.StartTransaction;
// SQLComp.Run(false);
// SQLComp.Query.Connection.Commit;
// Player.SendClientMessage('Item de Evento "T" enviado com sucesso.',
// 32, 16, 32);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ENVIOU ITEM EVENTO "T" o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} item § [' +
// Packet.ItemId.ToString + '] ' + String(ItemList[Packet.ItemId].Name)
// + ' QTDE: ' + Packet.Amount.ToString + ' §', TLogType.Painel);
// SQLComp.Free;
// end;
// SQLComp.SetQuery
// (Format('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '
// + 'identific, effect1_index, effect1_value, effect2_index, effect2_value, '
// + 'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) '
// + 'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)',
// [EVENT_ITEM, OtherPlayer.Character.Base.CharIndex, Packet.ItemId,
// Packet.Amount]));
// SQLComp.Run(false);
// Player.SendClientMessage('Item de Evento "T" enviado com sucesso.',
// 32, 16, 32);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ENVIOU ITEM EVENTO "T" o personagem {' +
// String(OtherPlayer^.Base.Character.Name) + '} item § [' +
// Packet.ItemId.ToString + '] ' + String(ItemList[Packet.ItemId].Name) +
// ' QTDE: ' + Packet.Amount.ToString + ' §', TLogType.Painel);
// SQLComp.Free;
// end;
// end
// else
// begin
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), True);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// OtherPlayer := Nil;
// OtherPlayer := Servers[I].GetPlayer(String(Packet.NickName));
// if (OtherPlayer = nil) then
// begin
// MySQLComp.SetQuery
// (Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'
// + 'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'
// + 'refused_at, reason_run, reason_refuse, reason_create) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'
// + '%d, %s, %s, %s, %s)', [gmuid, ITEM_GMCOMMAND, 0,
// QuotedStr('INSERT INTO items (item, refi, slot_type) VALUES (' +
// Packet.ItemId.ToString + ', ' + Packet.Amount.ToString +
// ', 17) WHERE ' + 'owner_id = ' + QuotedStr(Packet.TargetID.ToString)
// + ';'), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr('1899-12-30'), QuotedStr(''),
// QuotedStr(String(Servers[Player.ChannelIndex].Players
// [Packet.TargetID].Base.Character.Name)), Packet.ItemId,
// Packet.Amount, 0, QuotedStr('1899-12-30'), QuotedStr(''),
// QuotedStr(''), QuotedStr(String(Packet.Reason))]));
// end
// else
// begin
// MySQLComp.SetQuery
// (Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'
// + 'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'
// + 'refused_at, reason_run, reason_refuse, reason_create) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'
// + '%d, %s, %s, %s, %s)', [gmuid, ITEM_GMCOMMAND, 0,
// QuotedStr('INSERT INTO items (item, refi, slot_type) VALUES (' +
// Packet.ItemId.ToString + ', ' + Packet.Amount.ToString +
// ', 17) WHERE ' + 'owner_id = ' + QuotedStr(String(Packet.NickName))
// + ';'), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr('1899-12-30'), QuotedStr(''),
// QuotedStr(String(Packet.NickName)), Packet.ItemId, Packet.Amount, 0,
// QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
// QuotedStr(String(Packet.Reason))]));
// end;
// MySQLComp.Query.Connection.StartTransaction;
// MySQLComp.Run(false);
// MySQLComp.Query.Connection.Commit;
//
// // Player.SendMessageToPainel('Seu comando foi recebido e passará por análise.',
// // MB_ICONINFORMATION, 0);
// end;
// end;
// end;
// end;
//
/// /
// class function TPacketHandlers.GMEventItemForAll(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendItemEventForAll absolute Buffer;
// I, j: Integer;
// OtherPlayer: PPlayer;
// SQLComp, SQLCompAux: TQuery;
// begin
// if (Player.CheckAdminLogged) then
// begin
// SQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE));
// if not(SQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMEventItemForAll]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItemForAll]',
// TLogType.Error);
// SQLComp.Free;
// Exit;
// end;
// SQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE));
// if not(SQLCompAux.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMEventItemForAll2]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMEventItemForAll2]',
// TLogType.Error);
// SQLCompAux.Destroy;
// Exit;
// end;
// SQLComp.SetQuery('SELECT id FROM characters');
// SQLComp.Run();
// SQLComp.Query.First;
// for I := 0 to SQLComp.Query.RowsAffected - 1 do
// begin
// SQLCompAux.SetQuery
// (Format('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '
// + 'identific, effect1_index, effect1_value, effect2_index, effect2_value, '
// + 'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) '
// + 'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)',
// [EVENT_ITEM, SQLComp.Query.FieldByName('id').AsInteger, Packet.ItemId,
// Packet.Amount]));
// SQLCompAux.Run(false);
// SQLComp.Query.Next;
// end;
// Player.SendClientMessage
// ('Item de Evento "T" enviado PARA TODOS com sucesso.', 32, 16, 32);
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> ENVIOU ITEM EVENTO "T" PARA TODOS PERSONAGENS' + ' item § [' +
// Packet.ItemId.ToString + '] ' + String(ItemList[Packet.ItemId].Name) +
// ' QTDE: ' + Packet.Amount.ToString + ' §', TLogType.Painel);
// SQLComp.Free;
// SQLCompAux.Destroy;
// end;
// end;
//
// class function TPacketHandlers.GMRequestServerInformation(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendServerInfos;
// I: Integer;
// begin
// if (Player.Base.SessionMasterPriv < ModeradorPriv) then
// Exit;
//
// ZeroMemory(@Packet, SizeOf(TSendServerInfos));
// Packet.Header.Size := SizeOf(Packet);
// Packet.Header.Code := $3215;
// Packet.Header.Index := Player.Base.ClientID;
// for I := Low(Servers) to High(Servers) do
// begin
// case Servers[I].NationID of
// 1:
// begin
// Packet.Server01Online := Servers[I].ActivePlayersNowHere;
// Packet.Server01Reliq := Servers[I].ActiveReliquaresOnTemples;
// end;
// 2:
// begin
// Packet.Server02Online := Servers[I].ActivePlayersNowHere;
// Packet.Server02Reliq := Servers[I].ActiveReliquaresOnTemples;
// end;
// 3:
// begin
// Packet.Server03Online := Servers[I].ActivePlayersNowHere;
// Packet.Server03Reliq := Servers[I].ActiveReliquaresOnTemples;
// end;
// 4:
// begin
// Packet.Server04Online := Servers[I].ActivePlayersNowHere;
// Packet.Server04Reliq := Servers[I].ActiveReliquaresOnTemples;
// end;
// 5:
// begin
// Packet.Server05Online := Servers[I].ActivePlayersNowHere;
// Packet.Server05Reliq := Servers[I].ActiveReliquaresOnTemples;
// end;
// end;
// end;
// Player.SendPacket(Packet, Packet.Header.Size);
// // Sleep(10);
// end;
//
// class function TPacketHandlers.GMSendSpawnMob(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendSpawnMob absolute Buffer;
// I, j, Helper: Integer;
// Spawned: boolean;
// begin
// Result := false;
// Spawned := false;
// if not(Player.CheckGameMasterLogged) then
// if not(Player.CheckAdminLogged) then
// if not(Player.CheckModeratorLogged) then
// Exit;
// // if(Player.CheckGameMasterLogged) then
// // begin
// if (Packet.MobId > 450) then
// Exit;
// if (Packet.Position.IsValid) then
// begin // spawnar usando posicao
// for I := 1 to 50 do
// begin
// if (Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.ClientID <> 0) then
// continue;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].Index :=
// ((Packet.MobId + I) + 9148);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].InitPos.X
// := Packet.Position.X;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].InitPos.Y
// := Packet.Position.Y;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].DestPos.X
// := Packet.Position.X;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].DestPos.Y
// := Packet.Position.Y;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.Create(nil, ((Packet.MobId + I) + 9148), Player.ChannelIndex);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].Base.MobId
// := Packet.MobId;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.IsActive := True;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.ClientID := (Packet.MobId + I) + 9148;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.SecondIndex := I;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].MovedTo :=
// TypeMobLocation.Init;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .LastMyAttack := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .LastSkillAttack := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].CurrentPos
// := Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP
// [I].InitPos;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .XPositionsToMove := 1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .YPositionsToMove := 1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .NeighborIndex := -1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].HP :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].InitHP;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].MP :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].InitHP;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DNFis :=
// I + RandomRange(200, 299);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DNMag :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DNFis;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DefFis :=
// I + RandomRange(200, 299);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DefMag :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DefFis;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.Esquiva := MOB_ESQUIVA;
// // estava 0
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.Nation := Player.Base.Character.Nation;
// // Self.ChannelId + 1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .LastMyAttack := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .isTemp := True;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .GeneratedAt := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId]
// .IsActiveToSpawn := True;
// Spawned := True;
// Break;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> SPAWNOU MOB em posição específica' + ' § [' + Packet.MobId.ToString +
// '] X: ' + Packet.Position.X.ToString + ' Y: ' + Packet.Position.Y.ToString
// + ' §', TLogType.Painel);
// end
// else // spawnar usando neighbor do persona
// begin
// for I := 1 to 50 do
// begin
// if (Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.ClientID <> 0) then
// continue;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].Index :=
// ((Packet.MobId + I) + 9148);
// Randomize;
// Helper := RandomRange(1, 8);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].InitPos.X
// := Player.Base.Neighbors[Helper].pos.X;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].InitPos.Y
// := Player.Base.Neighbors[Helper].pos.Y;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].DestPos.X
// := Player.Base.Neighbors[Helper].pos.X;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].DestPos.Y
// := Player.Base.Neighbors[Helper].pos.Y;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.Create(nil, ((Packet.MobId + I) + 9148), Player.ChannelIndex);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].Base.MobId
// := Packet.MobId;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.IsActive := True;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.ClientID := (Packet.MobId + I) + 9148;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.SecondIndex := I;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].MovedTo :=
// TypeMobLocation.Init;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .LastMyAttack := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .LastSkillAttack := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].CurrentPos
// := Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP
// [I].InitPos;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.LastPos := Servers[Player.ChannelIndex].Mobs.TMobS
// [Packet.MobId].MobsP[I].CurrentPos;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .XPositionsToMove := 1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .YPositionsToMove := 1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .NeighborIndex := -1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].HP :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].InitHP;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I].MP :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].InitHP;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DNFis :=
// I + RandomRange(200, 299);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DNMag :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DNFis;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DefFis :=
// I + RandomRange(200, 299);
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DefMag :=
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.DefFis;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.CurrentScore.Esquiva := MOB_ESQUIVA;
// // estava 0
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .Base.PlayerCharacter.Base.Nation := Player.Base.Character.Nation;
// // Self.ChannelId + 1;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .LastMyAttack := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .isTemp := True;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].MobsP[I]
// .GeneratedAt := Now;
// Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId]
// .IsActiveToSpawn := True;
// Spawned := True;
// Break;
// end;
// Logger.Write('A conta de painel [' + Player.Base.SessionUsername +
// '] logada no personagem <' + String(Player.Base.Character.Name) +
// '> SPAWNOU MOB em posição vizinha do personagem' + ' § [' +
// Packet.MobId.ToString + '] X: ' + Player.Base.Neighbors[Helper]
// .pos.X.ToString + ' Y: ' + Player.Base.Neighbors[Helper].pos.Y.ToString +
// ' §', TLogType.Painel);
// end;
// if (Spawned = false) then
// begin
// Player.SendClientMessage('Não foi possível spawnar o mob ' +
// AnsiString(Servers[Player.ChannelIndex].Mobs.TMobS[Packet.MobId].Name));
// end;
// // end;
// Result := True;
// end;
//
/// /
// class function TPacketHandlers.GMRequestPlayerAccount(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TRequestSearchAccountFile absolute Buffer;
// begin
// if (Player.Base.SessionMasterPriv < ModeradorPriv) then
// Exit;
//
// TFunctions.GetAccountsBackup(Player, Packet.TypeOfCommand,
// String(Packet.Username));
// end;
//
/// /
// class function TPacketHandlers.GMReceiveAccBackup(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendAccountRecovery absolute Buffer;
// PacketToSend: TSendAccountRecoveryReturn;
// I, Cid: Integer;
// TempPlayer: TPlayer;
// begin
// if (Player.Base.SessionMasterPriv < GameMasterPriv) then
// Exit;
//
// ZeroMemory(@PacketToSend, SizeOf(PacketToSend));
// PacketToSend.Header.Size := SizeOf(PacketToSend);
// PacketToSend.Header.Index := Player.Base.ClientID;
// PacketToSend.Header.Code := $3227;
//
// PacketToSend.Response := 255;
//
// if not(FileExists(String(DATABASE_PATH + 'ACCS\' +
// Packet.AccountBackup.Header.Username + '\' + String(Packet.FileName) +
// '.acc'))) then
// begin
// PacketToSend.Response := 253;
//
// Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
// Exit;
// end;
//
// for I := Low(Servers) to High(Servers) do
// begin
// Cid := Servers[I].GetPlayerByUsername(Packet.AccountBackup.Header.Username);
//
// if (Cid > 0) then
// begin
// Servers[I].Disconnect(Servers[I].Players[Cid]);
// Servers[I].Players[Cid].SocketClosed := True;
//
// if (Servers[I].Players[Cid].Thread.ClientID > 0) then
// begin
// if (Assigned(Servers[I].Players[Cid].Thread)) then
// if not(Servers[I].Players[Cid].Thread.Finished) then
// WaitForSingleObject(Servers[I].Players[Cid].Thread.Handle,
// INFINITE);
// end;
//
// // ZeroMemory(@Servers[i].Players[Cid], sizeof(TPlayer));
// end;
// end;
//
// try
// ZeroMemory(@TempPlayer, SizeOf(TempPlayer));
//
// TempPlayer.Account := Packet.AccountBackup;
//
// Move(TempPlayer.Account.Characters[0], TempPlayer.Character,
// SizeOf(TPlayerCharacter));
// TempPlayer.Base.Create(@TempPlayer.Character.Base, 998,
// Player.ChannelIndex);
// TempPlayer.Base.PlayerCharacter.LastPos := TPosition.Create(3450, 690);
// TempPlayer.SaveInGame(0, True);
// TempPlayer.Base.Destroy();
//
// Move(TempPlayer.Account.Characters[1], TempPlayer.Character,
// SizeOf(TPlayerCharacter));
// TempPlayer.Base.Create(@TempPlayer.Character.Base, 998,
// Player.ChannelIndex);
// TempPlayer.Base.PlayerCharacter.LastPos := TPosition.Create(3450, 690);
// TempPlayer.SaveInGame(1, True);
// TempPlayer.Base.Destroy();
//
// Move(TempPlayer.Account.Characters[2], TempPlayer.Character,
// SizeOf(TPlayerCharacter));
// TempPlayer.Base.Create(@TempPlayer.Character.Base, 998,
// Player.ChannelIndex);
// TempPlayer.Base.PlayerCharacter.LastPos := TPosition.Create(3450, 690);
// TempPlayer.SaveInGame(2, True);
// TempPlayer.Base.Destroy();
//
// PacketToSend.Response := 1;
// finally
// Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
// end;
// end;
//
/// /
// class function TPacketHandlers.GMRequestGMUsernames(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendRequestGMUsernames absolute Buffer;
// PacketToSend: TSendGMUsernameToClient;
// MySQLComp: TQuery;
// I: Integer;
// begin
// if (Player.Base.SessionMasterPriv < AdministratorPriv) then
// Exit;
//
// if (Packet.Data = 1) then
// begin
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestGMUsernames]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestGMUsernames]',
// TLogType.Error);
// Exit;
// end;
//
// MySQLComp.SetQuery('select username from gm_accounts');
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
// MySQLComp.Query.First;
//
// for I := 0 to MySQLComp.Query.RecordCount - 1 do
// begin
// ZeroMemory(@PacketToSend, SizeOf(PacketToSend));
// PacketToSend.Header.Size := SizeOf(PacketToSend);
// PacketToSend.Header.Code := $322F;
// PacketToSend.Header.Index := Player.Base.ClientID;
//
// System.AnsiStrings.StrPLCopy(PacketToSend.GMUsernameTo,
// MySQLComp.Query.Fields[0].AsString, 16);
//
// Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
// sleep(75);
//
// MySQLComp.Query.Next;
// end;
// end;
// MySQLComp.Free;
// end;
// end;
//
/// /
// type
// TReceiveAutorizCommandFromServer = record
// Header: TPacketHeader;
// GMID: Integer;
// GMUsername: array [0 .. 15] of AnsiChar;
// CommandID: Integer; // Adicionado campo CommandID
// CommandType: Integer;
// CommandSQL: array [0 .. 1024] of AnsiChar;
// CreatedAt: TDateTime;
// TargetItemID: Integer;
// TargetItemCnt: Integer;
// TargetName: array [0 .. 15] of AnsiChar;
// ReasonCreate: array [0 .. 15] of AnsiChar;
// end;
//
// class function TPacketHandlers.GMRequestCommandsAutoriz(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendAutorizSearchCommands absolute Buffer;
// PacketToSend: TReceiveAutorizCommandFromServer;
// gmuid, I: Integer;
// MySQLComp: TQuery;
// CommandID: Integer;
//
// begin
// if (Player.Base.SessionMasterPriv < AdministratorPriv) then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMRequestGMUsernames]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestGMUsernames]',
// TLogType.Error);
// Exit;
// end;
//
// if (Trim(String(Packet.GMUsername)) <> '') then
// begin // pegar os comandos filtrados por username
// MySQLComp.SetQuery('select id from gm_accounts where username = ' +
// QuotedStr(String(Packet.GMUsername)));
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
// gmuid := MySQLComp.Query.Fields[0].AsInteger;
//
// case Packet.TypeOfView of
// 0:
// begin
// MySQLComp.SetQuery
// ('select * from gm_commands where runned=1 and refused=0 and' +
// ' owner_gmid = ' + gmuid.ToString);
// end;
// 1:
// begin
// MySQLComp.SetQuery
// ('select * from gm_commands where runned=0 and refused=1 and' +
// ' owner_gmid = ' + gmuid.ToString);
// end;
//
// 2:
// begin
// MySQLComp.SetQuery
// ('select * from gm_commands where runned=0 and refused=0 and' +
// ' owner_gmid = ' + gmuid.ToString);
// end;
//
// else
// begin
// MySQLComp.Free;
// Exit;
// end;
// end;
//
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
// MySQLComp.Query.First;
// for I := 0 to MySQLComp.Query.RecordCount - 1 do
// begin
// ZeroMemory(@PacketToSend, SizeOf(PacketToSend));
// PacketToSend.Header.Size := SizeOf(PacketToSend);
// PacketToSend.Header.Code := $322B;
// PacketToSend.Header.Index := Player.Base.ClientID;
//
// PacketToSend.GMID := gmuid;
//
// System.AnsiStrings.StrPLCopy(PacketToSend.GMUsername,
// String(Packet.GMUsername), 16);
//
// PacketToSend.CommandType := MySQLComp.Query.FieldByName
// ('command_type').AsInteger;
// System.AnsiStrings.StrPLCopy(PacketToSend.CommandSQL,
// MySQLComp.Query.FieldByName('command').AsString, 1025);
// PacketToSend.CreatedAt := MySQLComp.Query.FieldByName('created_at')
// .AsDateTime;
// PacketToSend.TargetItemID := MySQLComp.Query.FieldByName
// ('target_itemid').AsInteger;
// PacketToSend.TargetItemCnt := MySQLComp.Query.FieldByName
// ('target_itemcnt').AsInteger;
// System.AnsiStrings.StrPLCopy(PacketToSend.TargetName,
// MySQLComp.Query.FieldByName('target_name').AsString, 16);
// System.AnsiStrings.StrPLCopy(PacketToSend.ReasonCreate,
// MySQLComp.Query.FieldByName('reason_create').AsString, 16);
//
// Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
// sleep(75);
//
// MySQLComp.Query.Next;
// end;
// end;
//
// end;
// end
// else // pegar os comandos filtrados por data
// begin
// case Packet.TypeOfView of
// 0:
// begin
// MySQLComp.SetQuery
// ('select gc.*, ga.username from gm_commands gc inner join gm_accounts ga on ga.id = gc.owner_gmid where runned=1 and refused=0 and'
// + ' created_at >= ' +
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Packet.InitDate)) +
// ' and created_at <= ' +
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Packet.FinalDate)));
// end;
// 1:
// begin
// MySQLComp.SetQuery
// ('select gc.*, ga.username from gm_commands gc inner join gm_accounts ga on ga.id = gc.owner_gmid where runned=0 and refused=1 and'
// + ' created_at >= ' +
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Packet.InitDate)) +
// ' and created_at <= ' +
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Packet.FinalDate)));
// end;
//
// 2:
// begin
// MySQLComp.SetQuery
// ('select gc.*, ga.username from gm_commands gc inner join gm_accounts ga on ga.id = gc.owner_gmid where runned=0 and refused=0 and'
// + ' created_at >= ' +
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Packet.InitDate)) +
// ' and created_at <= ' +
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Packet.FinalDate)));
// end;
//
// else
// begin
// MySQLComp.Free;
// Exit;
// end;
// end;
//
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
// MySQLComp.Query.First;
// for I := 0 to MySQLComp.Query.RecordCount - 1 do
// begin
// ZeroMemory(@PacketToSend, SizeOf(PacketToSend));
// PacketToSend.Header.Size := SizeOf(PacketToSend);
// PacketToSend.Header.Code := $322B;
// PacketToSend.Header.Index := Player.Base.ClientID;
//
// PacketToSend.CommandID := MySQLComp.Query.FieldByName('id').AsInteger;
//
// PacketToSend.GMID := MySQLComp.Query.FieldByName('owner_gmid')
// .AsInteger;
//
// System.AnsiStrings.StrPLCopy(PacketToSend.GMUsername,
// MySQLComp.Query.FieldByName('username').AsString, 16);
//
// PacketToSend.CommandType := MySQLComp.Query.FieldByName('command_type')
// .AsInteger;
// System.AnsiStrings.StrPLCopy(PacketToSend.CommandSQL,
// MySQLComp.Query.FieldByName('command').AsString, 1025);
// PacketToSend.CreatedAt := MySQLComp.Query.FieldByName('created_at')
// .AsDateTime;
// PacketToSend.TargetItemID := MySQLComp.Query.FieldByName
// ('target_itemid').AsInteger;
// PacketToSend.TargetItemCnt := MySQLComp.Query.FieldByName
// ('target_itemcnt').AsInteger;
// System.AnsiStrings.StrPLCopy(PacketToSend.TargetName,
// MySQLComp.Query.FieldByName('target_name').AsString, 16);
// System.AnsiStrings.StrPLCopy(PacketToSend.ReasonCreate,
// MySQLComp.Query.FieldByName('reason_create').AsString, 16);
//
// Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
// sleep(75);
//
// MySQLComp.Query.Next;
// end;
// end
// else
// begin
// // Player.SendMessageToPainel('Não foram encontrados registros para autorização.', MB_ICONEXCLAMATION, 0);
// end;
// end;
//
// MySQLComp.Free;
// end;
//
/// /
// class function TPacketHandlers.GMApproveCommand(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TAcceptCommandPacket absolute Buffer;
// MySQLComp: TQuery;
// TargetToName: String;
// CharIndex, I: Integer;
// ItemId, ItemAmount, CommandType: Word;
// OtherPlayer: PPlayer;
// AlreadyGived: boolean;
// CharLevel: Word;
// LevelExp: UInt64;
// LevelNow: Word;
// Cupom, Commandx: String;
// begin
// Cupom := '';
// if (Player.Base.SessionMasterPriv < AdministratorPriv) then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMApproveCommand]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMApproveCommand]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// MySQLComp.SetQuery
// ('SELECT command, command_type, target_itemid, target_itemcnt, target_name, runned, refused FROM '
// + 'gm_commands WHERE id = ' + Packet.CommandID.ToString);
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
//
// if ((MySQLComp.Query.FieldByName('runned').AsInteger = 1) or
// (MySQLComp.Query.FieldByName('refused').AsInteger = 1)) then
// begin
// MySQLComp.Free;
// Exit;
// end;
//
// TargetToName := MySQLComp.Query.FieldByName('target_name').AsString;
// ItemId := MySQLComp.Query.FieldByName('target_itemid').AsInteger;
// ItemAmount := MySQLComp.Query.FieldByName('target_itemcnt').AsInteger;
// CommandType := MySQLComp.Query.FieldByName('command_type').AsInteger;
// Commandx := MySQLComp.Query.FieldByName('command').AsString;
//
// MySQLComp.SetQuery('SELECT id, level FROM characters WHERE name = ' +
// QuotedStr(TargetToName));
// MySQLComp.Run();
//
// if ((MySQLComp.Query.RecordCount > 0) or (CommandType in [3, 4])) then
// begin
// if not(CommandType in [3, 4]) then
// begin
// CharIndex := MySQLComp.Query.FieldByName('id').AsInteger;
// CharLevel := MySQLComp.Query.FieldByName('level').AsInteger;
// end;
//
// case CommandType of
// 1: // level
// begin
//
// AlreadyGived := false;
//
// for I := Low(Servers) to High(Servers) do
// begin
// if (Servers[I].GetPlayerByName(TargetToName, OtherPlayer)) then
// begin // da o level ao vivo
// OtherPlayer.AddLevel(ItemAmount);
//
// AlreadyGived := True;
// Break;
// end;
// end;
//
// if not(AlreadyGived) then
// begin // atualiza na db
// if ((CharLevel + ItemAmount) >= LEVEL_CAP) then
// LevelNow := LEVEL_CAP
// else
// LevelNow := (CharLevel + ItemAmount);
//
// LevelExp := ExpList[LevelNow - 1] + 1;
//
// MySQLComp.SetQuery('UPDATE characters SET level=' +
// LevelNow.ToString + ', experience=' + LevelExp.ToString +
// ' WHERE id = ' + CharIndex.ToString);
// MySQLComp.Run(false);
// end;
// end;
//
// 2: // item
// begin
// MySQLComp.SetQuery
// (Format('INSERT INTO items (id, slot_type, owner_id, slot, item_id, app, '
// + 'identific, effect1_index, effect1_value, effect2_index, effect2_value, '
// + 'effect3_index, effect3_value, min, max, refine, time, owner_mail_slot) '
// + 'VALUES (0, %d, %d, 0, %d, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, %d, 0, 0)',
// [EVENT_ITEM, CharIndex, ItemId, ItemAmount]));
// MySQLComp.Run(false);
//
// for I := Low(Servers) to High(Servers) do
// begin
// if (Servers[I].GetPlayerByName(TargetToName, OtherPlayer)) then
// begin
// OtherPlayer.SendClientMessage
// ('Você recebeu um item de evento. Pressione T.');
// Break;
// end;
// end;
// end;
//
// 3, 4: // cupom
// begin
// Cupom := Commandx;
// end;
// end;
// end;
// end;
//
// MySQLComp.SetQuery(Format('UPDATE gm_commands SET runned = 1, reason_run=%s,'
// + 'runned_at=%s, runned_by=%s, command=CONCAT(command,%s), coupom=%s WHERE id=%d',
// [QuotedStr(String(Packet.Reason)),
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr(Player.Base.SessionUsername), QuotedStr(#13 + 'Motivo Aprovado: '
// + String(Packet.Reason)), QuotedStr(Cupom), Packet.CommandID]));
// MySQLComp.Run(false);
//
// MySQLComp.Free;
//
// // Player.SendMessageToPainel('Comando APROVADO com sucesso.',
// // MB_ICONINFORMATION, 0);
// end;
//
/// /
// class function TPacketHandlers.GMReproveCommand(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TRefuseCommandPacket absolute Buffer;
// MySQLComp: TQuery;
// begin
// if (Player.Base.SessionMasterPriv < AdministratorPriv) then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMReproveCommand]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMReproveCommand]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// MySQLComp.SetQuery
// (Format('UPDATE gm_commands SET refused = 1, reason_refuse=%s,' +
// 'refused_at=%s, runned_by=%s, command=CONCAT(command,%s) WHERE id=%d',
// [QuotedStr(String(Packet.Reason)),
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr(Player.Base.SessionUsername), QuotedStr(#13 + 'Motivo Reprovado: '
// + String(Packet.Reason)), Packet.CommandID]));
// MySQLComp.Run(false);
//
// MySQLComp.Free;
//
// // Player.SendMessageToPainel('Comando REPROVADO com sucesso.',
// // MB_ICONINFORMATION, 0);
// end;
//
/// /
// class function TPacketHandlers.GMSendAddEffect(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendAddEffectGMPacket absolute Buffer;
// OtherPlayer: PPlayer;
// begin
// Result := false;
//
// if (Player.Base.SessionMasterPriv < GameMasterPriv) then
// Exit;
//
// if (Packet.TargetID = 0) then
// Packet.TargetID := Player.Base.ClientID;
//
// OtherPlayer := nil;
// OtherPlayer := Servers[Player.ChannelIndex].GetPlayer(Packet.TargetID);
//
// if (OtherPlayer <> nil) then
// begin
// OtherPlayer.SendEffect(Packet.EffectId);
// end;
//
// Result := True;
// end;
//
/// /
// class function TPacketHandlers.GMRequestCreateCoupom(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSendCreateCoupomRequest absolute Buffer;
// MySQLComp: TQuery;
// gmuid: Integer;
// Coupom, xx: String;
// Product, I: Integer;
// cmdto, cntto: Integer;
// begin
// Product := 0;
// if (Player.Base.SessionMasterPriv < ModeradorPriv) then
// Exit;
//
// if (Trim(String(Packet.GMUsername)) = '') then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), True);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestCreateCoupom]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestCreateCoupom]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// MySQLComp.SetQuery('select id from gm_accounts where username = ' +
// QuotedStr(Player.Base.SessionUsername));
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount = 0) then
// begin
// MySQLComp.Free;
// Exit;
// end;
//
// if (Packet.ItemId > 0) then
// begin
// Product := Packet.ItemId;
// cmdto := FOUNDER_GMCOMMAND;
//
// if (Packet.ItemAmount > 0) then
// begin
// cntto := Packet.ItemAmount;
// end
// else
// begin
// cntto := 1;
// end;
// end
// else
// begin
// case Packet.PinCodeType of
// 0:
// Product := 10;
// 1:
// Product := 20;
// 2:
// Product := 50;
// 3:
// Product := 100;
// end;
// cntto := 0;
// cmdto := COUPOM_GMCOMMAND;
// end;
// Coupom := '';
// xx := UpperCase(TFunctions.StringToMd5(DateTimeToStr(Now)));
// for I := 1 to 16 do
// begin
// SetLength(Coupom, Length(Coupom) + 1);
// Coupom[High(Coupom)] := xx[I];
// if (I in [4, 8, 12]) then
// begin
// SetLength(Coupom, Length(Coupom) + 1);
// Coupom[High(Coupom)] := '-';
// end;
// end;
//
// gmuid := MySQLComp.Query.FieldByName('id').AsInteger;
//
// MySQLComp.SetQuery
// (Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,' +
// 'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'
// + 'refused_at, reason_run, reason_refuse, reason_create, coupom) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'
// + '%d, %s, %s, %s, %s, %s)', [gmuid, cmdto, 0, QuotedStr(Coupom),
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''), Product, cntto, 0,
// QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
// QuotedStr(String(Packet.Reason)), QuotedStr(Coupom)]));
// MySQLComp.Query.Connection.StartTransaction;
// MySQLComp.Run(false);
// MySQLComp.Query.Connection.Commit;
//
// if (MySQLComp.Query.RowsAffected > 0) then
// begin
// // Player.SendMessageToPainel('Cupom ['+Coupom+'] registrado com sucesso.' + #13+
// // 'Aguardando aprovação do administrador para cupom ter validade.', MB_ICONINFORMATION, 0);
// end;
//
// MySQLComp.Free;
// end;
//
/// /
// class function TPacketHandlers.GMRequestComprovantSearchID(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSearchComprovantByID absolute Buffer;
// PacketToSend: TComprovantReceive;
// MySQLComp, MySQLCompAux: TQuery;
// begin
// if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestComprovantSearchID]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchID]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// if (String(Packet.TransactionID) <> '') then
// begin
// MySQLComp.SetQuery('select * from founders where idtransaction=' +
// QuotedStr(UpperCase(String(Packet.TransactionID))));
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount = 0) then
// begin
// // Player.SendMessageToPainel('O comprovante em questão não foi encontrado.',
// // MB_ICONERROR, 0);
// MySQLComp.Free;
// Exit;
// end;
//
// ZeroMemory(@PacketToSend, SizeOf(TComprovantReceive));
// PacketToSend.Header.Size := SizeOf(PacketToSend);
// PacketToSend.Header.Code := $3244;
// PacketToSend.Header.Index := Player.Base.ClientID;
//
// PacketToSend.ComprovantDBID := MySQLComp.Query.FieldByName('id').AsInteger;
//
// System.AnsiStrings.StrPLCopy(PacketToSend.TransactionID,
// MySQLComp.Query.FieldByName('idtransaction').AsString, 256);
// System.AnsiStrings.StrPLCopy(PacketToSend.NameOfComprovant,
// MySQLComp.Query.FieldByName('name').AsString, 256);
// PacketToSend.ValueOfComprovant := MySQLComp.Query.FieldByName
// ('valueofcomprovant').AsFloat;
// PacketToSend.DateOfComprovant := MySQLComp.Query.FieldByName
// ('dateofcomprovant').AsDateTime;
// PacketToSend.IsValidated := boolean(MySQLComp.Query.FieldByName('validated')
// .AsInteger);
//
// MySQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
// AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLCompAux.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestComprovantSearchID_aux]',
// TLogType.Warnings);
// Logger.Write
// ('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchID_aux]',
// TLogType.Error);
// MySQLCompAux.Destroy;
// Exit;
// end;
//
// MySQLCompAux.SetQuery('select username from gm_accounts where id=' +
// MySQLComp.Query.FieldByName('validated_gmid').AsString);
// MySQLCompAux.Run();
//
// if (MySQLCompAux.Query.RecordCount > 0) then
// begin
// System.AnsiStrings.StrPLCopy(PacketToSend.ValidatedBy,
// MySQLCompAux.Query.FieldByName('username').AsString, 64);
// end;
//
// System.AnsiStrings.StrPLCopy(PacketToSend.CoupomAttributed,
// MySQLComp.Query.FieldByName('coupom').AsString, 64);
//
// MySQLCompAux.Destroy;
//
// Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
// end;
//
// MySQLComp.Free;
// end;
//
/// /
// class function TPacketHandlers.GMRequestComprovantSearchName
// (var Player: TPlayer; Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TSearchComprovantByName absolute Buffer;
// PacketToSend: TComprovantReceive;
// MySQLComp, MySQLCompAux: TQuery;
// I: Integer;
// begin
// if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestComprovantSearchName]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchName]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// if (String(Packet.NameOfComprovant) <> '') then
// begin
// MySQLComp.SetQuery('select * from founders where name LIKE "%' +
// (String(Packet.NameOfComprovant)) + '%"');
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount = 0) then
// begin
// // Player.SendMessageToPainel('O comprovante em questão não foi encontrado.',
// // MB_ICONERROR, 0);
// MySQLComp.Free;
// Exit;
// end;
//
// MySQLComp.Query.First;
//
// for I := 0 to MySQLComp.Query.RecordCount - 1 do
// begin
// ZeroMemory(@PacketToSend, SizeOf(TComprovantReceive));
// PacketToSend.Header.Size := SizeOf(PacketToSend);
// PacketToSend.Header.Code := $3244;
// PacketToSend.Header.Index := Player.Base.ClientID;
//
// PacketToSend.ComprovantDBID := MySQLComp.Query.FieldByName('id')
// .AsInteger;
//
// System.AnsiStrings.StrPLCopy(PacketToSend.TransactionID,
// MySQLComp.Query.FieldByName('idtransaction').AsString, 256);
// System.AnsiStrings.StrPLCopy(PacketToSend.NameOfComprovant,
// MySQLComp.Query.FieldByName('name').AsString, 256);
// PacketToSend.ValueOfComprovant := MySQLComp.Query.FieldByName
// ('valueofcomprovant').AsFloat;
// PacketToSend.DateOfComprovant := MySQLComp.Query.FieldByName
// ('dateofcomprovant').AsDateTime;
// PacketToSend.IsValidated :=
// boolean(MySQLComp.Query.FieldByName('validated').AsInteger);
//
// MySQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
// AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
// AnsiString(MYSQL_DATABASE), false);
// if not(MySQLCompAux.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestComprovantSearchName_aux]',
// TLogType.Warnings);
// Logger.Write
// ('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantSearchName_aux]',
// TLogType.Error);
// MySQLCompAux.Destroy;
// Exit;
// end;
//
// MySQLCompAux.SetQuery('select username from gm_accounts where id=' +
// MySQLComp.Query.FieldByName('validated_gmid').AsString);
// MySQLCompAux.Run();
//
// if (MySQLCompAux.Query.RecordCount > 0) then
// begin
// System.AnsiStrings.StrPLCopy(PacketToSend.ValidatedBy,
// MySQLCompAux.Query.FieldByName('username').AsString, 64);
// end;
//
// System.AnsiStrings.StrPLCopy(PacketToSend.CoupomAttributed,
// MySQLComp.Query.FieldByName('coupom').AsString, 64);
//
// MySQLCompAux.Destroy;
//
// Player.SendPacket(PacketToSend, PacketToSend.Header.Size);
//
// MySQLComp.Query.Next;
// end;
// end;
//
// MySQLComp.Free;
// end;
//
/// /
// class function TPacketHandlers.GMRequestCreateComprovant(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TComprovantCreate absolute Buffer;
// MySQLComp: TQuery;
// gmuid: Integer;
// Coupom, xx: String;
// Product, I: Integer;
// begin
// if not(Player.CheckAdminLogged) then
// Exit;
// Product := 0;
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), True);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestCreateComprovant]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestCreateComprovant]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// if ((Packet.TransactionID <> '') and (Packet.NameOfComprovant <> '') and
// (Packet.ValueOfComprovant <> 0) and (DateToStr(Packet.DateOfComprovant)
// <> '')) then
// begin
// MySQLComp.SetQuery('SELECT id from gm_accounts where username = ' +
// QuotedStr(Player.Base.SessionUsername));
// MySQLComp.Run();
//
// gmuid := MySQLComp.Query.FieldByName('id').AsInteger;
//
// MySQLComp.SetQuery('SELECT id from founders where idtransaction=' +
// QuotedStr(string(Packet.TransactionID)));
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
// // Player.SendMessageToPainel('Esse ID de transação já existe.', MB_ICONERROR, 0);
// MySQLComp.Free;
// Exit;
// end;
//
// case Round(Packet.ValueOfComprovant) of
// 1 .. 30:
// Product := 14134;
// 31 .. 59:
// Product := 14135;
// 60 .. 228:
// Product := 14136;
// 229 .. 330:
// Product := 14137;
// end;
// Coupom := '';
//
// if (Product > 0) then
// begin
// xx := UpperCase(TFunctions.StringToMd5(DateTimeToStr(Now)));
// for I := 1 to 16 do
// begin
// SetLength(Coupom, Length(Coupom) + 1);
// Coupom[High(Coupom)] := xx[I];
// if (I in [4, 8, 12]) then
// begin
// SetLength(Coupom, Length(Coupom) + 1);
// Coupom[High(Coupom)] := '-';
// end;
// end;
// end;
//
// MySQLComp.SetQuery
// (Format('INSERT INTO gm_commands (owner_gmid,command_type,runned,command,'
// + 'created_at, runned_at, runned_by, target_name, target_itemid, target_itemcnt, refused,'
// + 'refused_at, reason_run, reason_refuse, reason_create, coupom) VALUES (%d, %d, %d, %s, %s, %s, %s, %s, %d, %d,'
// + '%d, %s, %s, %s, %s, %s)', [gmuid, FOUNDER_GMCOMMAND, 1,
// QuotedStr(Coupom), QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr(FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)),
// QuotedStr(Player.Base.SessionUsername), QuotedStr(''), Product, 1, 0,
// QuotedStr('1899-12-30'), QuotedStr(''), QuotedStr(''),
// QuotedStr(String
// ('Criação de cupom para recebimento de founder via comprovante.')),
// QuotedStr(Coupom)]));
// MySQLComp.Query.Connection.StartTransaction;
// MySQLComp.Run(false);
// MySQLComp.Query.Connection.Commit;
//
// MySQLComp.SetQuery
// (Format('INSERT INTO founders (idtransaction, name, dateofcomprovant, ' +
// 'valueofcomprovant, coupom) VALUES (%s, %s, %s, %s, %s)',
// [QuotedStr(String(Packet.TransactionID)),
// QuotedStr(String(Packet.NameOfComprovant)),
// QuotedStr(FormatDateTime('yyyy-mm-dd', Packet.DateOfComprovant)),
// ReplaceStr(FloatToStr(Packet.ValueOfComprovant), ',', '.'),
// QuotedStr(Coupom)]));
// MySQLComp.Query.Connection.StartTransaction;
// MySQLComp.Run(false);
// MySQLComp.Query.Connection.Commit;
//
// if (MySQLComp.Query.RowsAffected > 0) then
// // begin
// // if(Coupom <> '') then
// // begin
// // Player.SendMessageToPainel('Comprovante cadastrado com sucesso.' +
// // #13 + 'Cupom de ativação do founder: ' + Coupom, MB_ICONINFORMATION, 0);
// // end
// // else
// // begin
// // Player.SendMessageToPainel('Comprovante cadastrado com sucesso.' +
// // #13 + 'Parece que o valor foi diferente do cadastrado. Necessária criação manual do cupom.', MB_ICONINFORMATION, 0);
// // end;
// // end;
// end
// else
// begin
// // Player.SendMessageToPainel('Dados corrompidos durante transmissão.', MB_ICONERROR, 0);
// end;
//
// MySQLComp.Free;
// end;
//
/// /
// class function TPacketHandlers.GMRequestComprovantValidate(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TComprovantValidate absolute Buffer;
// MySQLComp: TQuery;
// gmuid, founderuid: Integer;
// begin
// if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), True);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write
// ('Falha de conexão individual com mysql.[GMRequestComprovantValidate]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestComprovantValidate]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// if (Packet.ComprovantDBID > 0) then
// begin
// MySQLComp.SetQuery('SELECT id from gm_accounts where username = ' +
// QuotedStr(Player.Base.SessionUsername));
// MySQLComp.Run();
//
// gmuid := MySQLComp.Query.FieldByName('id').AsInteger;
//
// MySQLComp.SetQuery('select * from founders where id=' +
// Packet.ComprovantDBID.ToString);
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount = 0) then
// begin
// // Player.SendMessageToPainel('Solicitação não encontrada.', MB_ICONERROR, 0);
// MySQLComp.Free;
// Exit;
// end
// else
// begin
// if (MySQLComp.Query.FieldByName('validated').AsInteger = 1) then
// begin
// // Player.SendMessageToPainel('Solicitação já foi validada.', MB_ICONERROR, 0);
// MySQLComp.Free;
// Exit;
// end;
//
// founderuid := MySQLComp.Query.FieldByName('id').AsInteger;
//
// MySQLComp.SetQuery('UPDATE founders SET validated=1, validated_gmid=' +
// gmuid.ToString + ' WHERE id =' + founderuid.ToString);
// MySQLComp.Run(false);
//
// if (MySQLComp.Query.RowsAffected > 0) then
// // begin
// // Player.SendMessageToPainel('Você LEU o ticket, ACHOU o compovante, MARCOU como entregue e ENTREGOU o produto no mesmo ticket.', MB_ICONINFORMATION, 0);
// // end;
// end;
// end;
//
// MySQLComp.Free;
// end;
//
/// /
// class function TPacketHandlers.GMRequestDeletePrans(var Player: TPlayer;
// Buffer: ARRAY OF BYTE): boolean;
// var
// Packet: TPacketSendDeletePrans absolute Buffer;
// MySQLComp: TQuery;
// charID: Integer;
// begin
// if not((Player.CheckGameMasterLogged) or (Player.CheckAdminLogged)) then
// Exit;
//
// MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVERGM), MYSQL_PORT,
// AnsiString(MYSQL_USERNAMEGM), AnsiString(MYSQL_PASSWORDGM),
// AnsiString(MYSQL_DATABASE), True);
// if not(MySQLComp.Query.Connection.Connected) then
// begin
// Logger.Write('Falha de conexão individual com mysql.[GMRequestDeletePrans]',
// TLogType.Warnings);
// Logger.Write('PERSONAL MYSQL FAILED LOAD.[GMRequestDeletePrans]',
// TLogType.Error);
// MySQLComp.Free;
// Exit;
// end;
//
// if (Packet.AccountIndex > 0) then
// begin
// MySQLComp.SetQuery('SELECT * from prans where acc_id = ' +
// Packet.AccountIndex.ToString);
// MySQLComp.Run();
//
// if (MySQLComp.Query.RecordCount > 0) then
// begin
// try
// charID := MySQLComp.Query.FieldByName('char_id').AsInteger;
//
// MySQLComp.SetQuery
// ('delete from quests where questid in (39, 40, 41, 406, 407) and charid = '
// + charID.ToString);
// MySQLComp.Run(false);
// MySQLComp.SetQuery('delete from items where owner_id = ' +
// charID.ToString +
// ' and slot_type = 0 and item_id in (100,101,102,103,104,105)');
// MySQLComp.Run(false);
// MySQLComp.SetQuery('delete from items where owner_id = ' +
// charID.ToString +
// ' and slot_type = 1 and item_id in (100,101,102,103,104,105)');
// MySQLComp.Run(false);
// MySQLComp.SetQuery('delete from items where owner_id = ' +
// Packet.AccountIndex.ToString +
// ' and slot_type = 2 and item_id in (100,101,102,103,104,105)');
// MySQLComp.Run(false);
// finally
// // Player.SendMessageToPainel('Procedimento executado.' + #13 +
// // 'tables affected: prans, items, quests',
// // MB_ICONINFORMATION, 0);
// end;
// end
// else
// // begin
// // Player.SendMessageToPainel('Não existem prans no banco de dados linkados a conta.',
// // MB_ICONERROR, 0);
// // end;
// end;
//
// end;

class function TPacketHandlers.RequestAllAttributes(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TRequestAllAttributes absolute Buffer;
  Packet2: TResponseAllAttributes;
begin
  if Player.Status < Playing then
    Exit;

  Player.Base.GetCurrentScore;
  ZeroMemory(@Packet2, SizeOf(TResponseAllAttributes));
  Packet2.Header.Size := SizeOf(TResponseAllAttributes);
  Packet2.Header.Index := Player.Base.ClientID;
  Packet2.Header.Code := $23FF;
  Packet2.Resfriamento := Player.Base.PlayerCharacter.ReduceCooldown;
  Packet2.DanoHab := Player.Base.PlayerCharacter.HabAtk;
  Packet2.Cura := Player.Base.PlayerCharacter.CureTax;
  Packet2.DanoPvp := Player.Base.PlayerCharacter.PvPDamage;
  Packet2.DefPvp := Player.Base.PlayerCharacter.PvPDefense;
  Packet2.PerFis := Player.Base.PlayerCharacter.FisPenetration;
  Packet2.PerMag := Player.Base.PlayerCharacter.MagPenetration;
  Packet2.RecHP := Player.Base.GetMobAbility(EF_REGENHP) +
    Player.Base.GetMobAbility(EF_PRAN_REGENHP) +
    (Player.Base.PlayerCharacter.Base.CurrentScore.Cons * 3);
  Packet2.RecMP := Player.Base.GetMobAbility(EF_REGENMP) +
    Player.Base.GetMobAbility(EF_PRAN_REGENMP) +
    (Player.Base.PlayerCharacter.Base.CurrentScore.Cons * 3);
  Packet2.DanoCrit := Player.Base.PlayerCharacter.DamageCritical;
  Packet2.ResisCrit := Player.Base.PlayerCharacter.CritRes;
  Packet2.ResisDuplo := Player.Base.PlayerCharacter.DuploRes;
  Packet2.DiminDanoCrit := Player.Base.PlayerCharacter.ResDamageCritical;
  Packet2.ResisLent := Player.Base.GetMobAbility(EF_IM_RUNSPEED) +
    Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisStun := Player.Base.GetMobAbility(EF_IM_SKILL_STUN) +
    Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisSilence := Player.Base.GetMobAbility(EF_IM_SILENCE1) +
    Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisChoque := Player.Base.GetMobAbility(EF_IM_SKILL_SHOCK) +
    Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisImobi := Player.Base.GetMobAbility(EF_IM_SKILL_IMMOVABLE) +
    Player.Base.PlayerCharacter.Resistence;
  Packet2.ResisMedo := Player.Base.GetMobAbility(EF_IM_FEAR) +
    Player.Base.PlayerCharacter.Resistence;
  Player.SendPacket(Packet2, Packet2.Header.Size);
end;

class function TPacketHandlers.RequestAllAttributesTarget(var Player: TPlayer;
Buffer: ARRAY OF BYTE): boolean;
var
  Packet: TRequestAllAttributesTarget absolute Buffer;
  Packet2: TResponseAllAttributesTarget;
  OtherPlayer: PPlayer;
begin
  if Player.Status < Playing then
    Exit;

  OtherPlayer := @Servers[Player.ChannelIndex].Players[Packet.TargetID];
  if (OtherPlayer.Base.Character.Nation > 0) then
  begin
    if (OtherPlayer.Base.Character.Nation <> Player.Base.Character.Nation) then
    begin
      Player.SendClientMessage('O alvo não pertence a sua nação.');
      Exit;
    end;
  end;
  OtherPlayer.Base.GetCurrentScore;
  ZeroMemory(@Packet2, SizeOf(TResponseAllAttributesTarget));
  Packet2.Header.Size := SizeOf(TResponseAllAttributesTarget);
  Packet2.Header.Index := OtherPlayer.Base.ClientID;
  Packet2.Header.Code := $23FC;
  Packet2.Resfriamento := OtherPlayer.Base.PlayerCharacter.ReduceCooldown;
  Packet2.DanoHab := OtherPlayer.Base.PlayerCharacter.HabAtk;
  Packet2.Cura := OtherPlayer.Base.PlayerCharacter.CureTax;
  Packet2.DanoPvp := OtherPlayer.Base.PlayerCharacter.PvPDamage;
  Packet2.DefPvp := OtherPlayer.Base.PlayerCharacter.PvPDefense;
  Packet2.PerFis := OtherPlayer.Base.PlayerCharacter.FisPenetration;
  Packet2.PerMag := OtherPlayer.Base.PlayerCharacter.MagPenetration;
  Packet2.RecHP := OtherPlayer.Base.GetMobAbility(EF_REGENHP) +
    OtherPlayer.Base.GetMobAbility(EF_PRAN_REGENHP) +
    (OtherPlayer.Base.PlayerCharacter.Base.CurrentScore.Cons * 3);
  Packet2.RecMP := OtherPlayer.Base.GetMobAbility(EF_REGENMP) +
    OtherPlayer.Base.GetMobAbility(EF_PRAN_REGENMP) +
    (OtherPlayer.Base.PlayerCharacter.Base.CurrentScore.Cons * 3);
  Packet2.DanoCrit := OtherPlayer.Base.PlayerCharacter.DamageCritical;
  Packet2.ResisCrit := OtherPlayer.Base.PlayerCharacter.CritRes;
  Packet2.ResisDuplo := OtherPlayer.Base.PlayerCharacter.DuploRes;
  Packet2.DiminDanoCrit := OtherPlayer.Base.PlayerCharacter.ResDamageCritical;
  Packet2.ResisLent := OtherPlayer.Base.GetMobAbility(EF_IM_RUNSPEED) +
    OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisStun := OtherPlayer.Base.GetMobAbility(EF_IM_SKILL_STUN) +
    OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisSilence := OtherPlayer.Base.GetMobAbility(EF_IM_SILENCE1) +
    OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisChoque := OtherPlayer.Base.GetMobAbility(EF_IM_SKILL_SHOCK) +
    OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisImobi := OtherPlayer.Base.GetMobAbility(EF_IM_SKILL_IMMOVABLE) +
    OtherPlayer.Base.PlayerCharacter.Resistence;
  Packet2.ResisMedo := OtherPlayer.Base.GetMobAbility(EF_IM_FEAR) +
    OtherPlayer.Base.PlayerCharacter.Resistence;
  Player.SendPacket(Packet2, Packet2.Header.Size);
end;
{$ENDREGION}
{$REGION 'Auction'}

class function TPacketHandlers.RequestAuctionItems(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TRequestAuctionItemsPacket absolute Buffer;
begin
  Result := True;
  Result := TAuctionFunctions.GetAuctionItems(Player, Packet.ItemType,
    Packet.LevelMin, Packet.LevelMax, Packet.ReinforceMin, Packet.ReinforceMax,
    Packet.SearchByName);

  if not Result then
    Player.SendClientMessage('Erro ao obter itens do leilão!');

end;

class function TPacketHandlers.RequestRegisterItem(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TAuctionRegisterItemPacket absolute Buffer;
begin
  if not TAuctionFunctions.RegisterAuctionItem(Player, Packet.Price,
    Packet.Slot, Packet.Time) then
    Player.SendClientMessage('Erro ao registrar item no leilão!');
end;

class function TPacketHandlers.RequestOwnAuctionItems(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
begin
  if not TAuctionFunctions.GetSelfAuctionItems(Player) then
    Player.SendClientMessage('Erro ao consultar seus itens no leilão!');
end;

class function TPacketHandlers.RequestAuctionOfferCancel(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TAuctionCancelOfferPacket absolute Buffer;
begin
  if TItemFunctions.GetEmptySlot(Player) = 255 then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  if not TAuctionFunctions.CancelItemOffer(Player, Packet.AuctionOfferId) then
    Player.SendClientMessage('Erro ao cancelar oferta no leilão!');
end;

class function TPacketHandlers.RequestAuctionOfferBuy(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TAuctionCancelOfferPacket absolute Buffer;
begin
  if TItemFunctions.GetEmptySlot(Player) = 255 then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;
  if not TAuctionFunctions.RequestBuyItem(Player, Packet.AuctionOfferId) then
    Player.SendClientMessage('Erro ao comprar oferta no leilão!');
end;

{$ENDREGION}
{$REGION 'Reliquiares'}

class function TPacketHandlers.MoveItemToReliquare(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TMoveItemToReliquare absolute Buffer;
  IsRecap: boolean;
  Item: pItem;
  SellPrice, I, DevirID, SlotId, j, Honor, ItemSlot, AuxPrice, k: Integer;
  TempleSpace: TSpaceTemple;
  ReliqIndex: Word;
  EmptySlot, AuxSlot: BYTE;
  PriceItem: TItemPrice;
  AlreadyReliq: BYTE;
  TimeEst: TDateTime;
  AuxSlotItem: DWORD;
begin
  if Packet.DevirClientID = 263 then
  begin // entregar reliquia
    Item := @Player.Character.Base.Inventory[Packet.srcSlot];

    if (Item^.Index >= 6370) and (Item^.Index <= 6444) or (Item^.Index >= 12000)
      and (Item^.Index <= 12032) then
    begin
      for I := Low(Servers) to High(Servers) do
      begin
        if not Servers[I].IsActive then
          continue;
        for DevirID := 0 to 4 do
        begin
          for SlotId := 0 to 4 do
          begin
            if (Servers[I].Devires[DevirID].Slots[SlotId].ItemId <> 0) and
              (ItemList[Item^.Index].UseEffect = ItemList
              [Servers[I].Devires[DevirID].Slots[SlotId].ItemId].UseEffect) then
            begin
              Player.SendClientMessage('Já possui uma reliquia desse tipo ' +
                AnsiString(ItemList[Item^.Index].Name) + ' no seu ' +
                Servers[I].DevirNpc[DevirID + 3335].DevirName +
                ' ou de outra nação.');
              Exit;
            end;
          end;
        end;
      end;

      TempleSpace := Servers[Player.ChannelIndex].GetFreeTempleSpaceByIndex
        (Player.OpennedDevir);

      if TempleSpace.DevirID = 255 then
      begin
        Player.SendClientMessage
          ('Todos os espaços sagrados disponíveis estão lotados.');
        Exit;
      end;

      if (Player.Base.Character.Nation = 0) or
        (Player.Base.Character.Nation <> Servers[Player.ChannelIndex].Devires
        [TempleSpace.DevirID].NationID) then
      begin
        Player.SendClientMessage
          ('Para que seja computado a relíquia, deve se ter nacionalidade no país.');
        Exit;
      end;

      IsRecap := false;
      for I := Low(Servers) to High(Servers) do
      begin
        if not Servers[I].IsActive then
          continue;
        for DevirID := 0 to 4 do
        begin
          for SlotId := 0 to 4 do
          begin
            if Servers[I].Devires[DevirID].Slots[SlotId].Furthed and
              (Servers[I].Devires[DevirID].Slots[SlotId].ItemFurthed = Item.
              Index) then
            begin
              if I = Player.ChannelIndex then
                IsRecap := True;
              Servers[I].Devires[DevirID].Slots[SlotId].Furthed := false;
              Servers[I].Devires[DevirID].Slots[SlotId].ItemFurthed := 0;
              Break;
            end;
          end;
        end;
      end;

      Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots
        [TempleSpace.SlotId].ItemId := Item^.Index;
      Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots
        [TempleSpace.SlotId].APP := Item^.Index;
      Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots
        [TempleSpace.SlotId].TimeCapped := IncHour(Now, 3);
      if IsRecap then
        Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots
          [TempleSpace.SlotId].TimeToEstabilish := Now
      else
        Servers[Player.ChannelIndex].Devires[TempleSpace.DevirID].Slots
          [TempleSpace.SlotId].TimeToEstabilish :=
          IncHour(Now, RELIQ_EST_TIME + 3);

      Move(Player.Base.Character.Name, Servers[Player.ChannelIndex].Devires
        [TempleSpace.DevirID].Slots[TempleSpace.SlotId].NameCapped[0], 16);
      Inc(Servers[Player.ChannelIndex].ReliqEffect[ItemList[Item^.Index].EF[0]],
        ItemList[Item^.Index].EFV[0]);
      Servers[Player.ChannelIndex].SaveTemplesDB(@Player);
      Servers[Player.ChannelIndex].UpdateReliquaresForAll;
      Servers[Player.ChannelIndex].SendServerMsgForNation
        ('O tesouro sagrado <' + AnsiString(ItemList[Item^.Index].Name) +
        '> foi colocado no templo, efeito será aplicado.',
        Player.Base.Character.Nation, 16, 16, 16);

      Player.UpdateReliquareOpennedDevir(TempleSpace.DevirID);

      if Player.PartyIndex <> 0 then
      begin
        if not Player.Party.InRaid then
        begin
          for I in Player.Party.Members do
          begin
            if Servers[Player.ChannelIndex].Players[I]
              .Base.PlayerCharacter.LastPos.InRange
              (Player.Base.PlayerCharacter.LastPos, 20) then
            begin
              Honor := (ItemList[Item^.Index].Level + 1) *
                INC_HONOR_RELIQ_LEVEL;
              Inc(Servers[Player.ChannelIndex].Players[I]
                .Base.Character.CurrentScore.Honor, Honor);
              Servers[Player.ChannelIndex].Players[I].SendClientMessage
                ('Adquiriu ' + AnsiString(Honor.ToString) +
                ' pontos de honra.');
              Servers[Player.ChannelIndex].Players[I].Base.SendRefreshKills();
              TItemFunctions.PutItem(Servers[Player.ChannelIndex].Players
                [I], 8544);
            end;
          end;
        end
        else
        begin
          for I in Player.Party.Members do
          begin
            if Servers[Player.ChannelIndex].Players[I]
              .Base.PlayerCharacter.LastPos.InRange
              (Player.Base.PlayerCharacter.LastPos, 20) then
            begin
              Honor := (ItemList[Item^.Index].Level + 1) *
                INC_HONOR_RELIQ_LEVEL;
              Inc(Servers[Player.ChannelIndex].Players[I]
                .Base.Character.CurrentScore.Honor, Honor);
              Servers[Player.ChannelIndex].Players[I].SendClientMessage
                ('Adquiriu ' + AnsiString(Honor.ToString) +
                ' pontos de honra.');
              Servers[Player.ChannelIndex].Players[I].Base.SendRefreshKills();
              TItemFunctions.PutItem(Servers[Player.ChannelIndex].Players
                [I], 8544);
            end;
          end;
          for j := 1 to 3 do
          begin
            if Player.Party.PartyAllied[j] = 0 then
              continue;
            for I in Servers[Player.ChannelIndex].Parties
              [Player.Party.PartyAllied[j]].Members do
            begin
              if Servers[Player.ChannelIndex].Players[I]
                .Base.PlayerCharacter.LastPos.InRange
                (Player.Base.PlayerCharacter.LastPos, 20) then
              begin
                Honor := (ItemList[Item^.Index].Level + 1) *
                  INC_HONOR_RELIQ_LEVEL;
                Inc(Servers[Player.ChannelIndex].Players[I]
                  .Base.Character.CurrentScore.Honor, Honor);
                Servers[Player.ChannelIndex].Players[I].SendClientMessage
                  ('Adquiriu ' + AnsiString(Honor.ToString) +
                  ' pontos de honra.');
                Servers[Player.ChannelIndex].Players[I].Base.SendRefreshKills();
                TItemFunctions.PutItem(Servers[Player.ChannelIndex].Players
                  [I], 8544);
              end;
            end;
          end;
        end;
      end
      else
      begin
        Honor := (ItemList[Item^.Index].Level + 1) * INC_HONOR_RELIQ_LEVEL;
        Inc(Player.Base.Character.CurrentScore.Honor, Honor);
        Player.SendClientMessage('Adquiriu ' + AnsiString(Honor.ToString) +
          ' pontos de honra.');
        Player.Base.SendRefreshKills();
        TItemFunctions.PutItem(Player, 8544);
      end;

      TItemFunctions.RemoveItem(Player, INV_TYPE, Packet.srcSlot);
      Player.SendSignal(Player.Base.ClientID, $10F);
      Player.SendEffect(0);
    end;
  end
  else if Packet.DevirClientID = 1793 then
  begin // puxar relíquia
    if Servers[Player.ChannelIndex].Devires[Player.OpennedDevir]
      .NationID = Player.Base.Character.Nation then
    begin
      Player.SendClientMessage('Você não pode pegar seus próprios tesouros.');
      Exit;
    end;

    EmptySlot := TItemFunctions.GetEmptySlot(Player);
    if EmptySlot = 255 then
    begin
      Player.SendClientMessage('Inventário cheio.');
      Exit;
    end;

    AlreadyReliq := TItemFunctions.GetItemSlotByItemType(Player, 40,
      INV_TYPE, 0);
    if AlreadyReliq <> 255 then
    begin
      Player.SendClientMessage
        ('Você não pode carregar mais de uma relíquia por vez.');
      Exit;
    end;

    TimeEst := IncHour(Servers[Player.ChannelIndex].Devires[Player.OpennedDevir]
      .Slots[Packet.srcSlot].TimeToEstabilish, -3);
    if TimeEst > Now then
    begin
      Player.SendClientMessage('Relíquia não liberada ainda.');
      Exit;
    end;

    ReliqIndex := Servers[Player.ChannelIndex].Devires[Player.OpennedDevir]
      .Slots[Packet.srcSlot].ItemId;
    if ReliqIndex = 0 then
      Exit;

    TItemFunctions.PutItem(Player, ReliqIndex, 1);
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].Slots
      [Packet.srcSlot].ItemFurthed := Servers[Player.ChannelIndex].Devires
      [Player.OpennedDevir].Slots[Packet.srcSlot].ItemId;
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].Slots
      [Packet.srcSlot].ItemId := 0;
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].Slots
      [Packet.srcSlot].APP := 0;
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].Slots
      [Packet.srcSlot].TimeToEstabilish := IncHour(Now, 3);
    ZeroMemory(@Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].Slots
      [Packet.srcSlot].NameCapped, 16);
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].Slots
      [Packet.srcSlot].TimeFurthed := IncHour(Now, 3);
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir].Slots
      [Packet.srcSlot].Furthed := True;
    Player.SendSignal(Player.Base.ClientID, $10F);
    Servers[Player.ChannelIndex].SaveTemplesDB(@Player);
    Servers[Player.ChannelIndex].CloseDevir(Player.OpennedDevir,
      Player.OpennedTemple, Player.Base.ClientID);
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir]
      .PlayerIndexGettingReliq := 0;

    DecInt(Servers[Player.ChannelIndex].ReliqEffect[ItemList[ReliqIndex].EF[0]],
      ItemList[ReliqIndex].EFV[0]);
    Player.UpdateReliquareOpennedDevir(Player.OpennedDevir);
    Servers[Player.ChannelIndex].Devires[Player.OpennedDevir]
      .CollectedReliquare := True;
    Player.OpennedDevir := 255;
    Player.OpennedTemple := 255;
    Servers[Player.ChannelIndex].UpdateReliquaresForAll;
    Player.SendPacket(Packet, Packet.Header.Size);

    Servers[Player.ChannelIndex].SendServerMsgForNation('O tesouro sagrado [' +
      AnsiString(ItemList[ReliqIndex].Name) +
      '] foi roubado do templo. Efeito sagrado cancelado.',
      Servers[Player.ChannelIndex].NationID, 16, 32, 16);
  end;
end;

{$ENDREGION}
{$REGION 'Collect Items'}

class function TPacketHandlers.CollectMapItem(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TCollectItem absolute Buffer;
  xPacket: TSendRemoveMobPacket;
  I, AlreadyReliq: Integer;
  xPos: TPosition;
begin
  Result := false;

  if not Player.Base.PlayerCharacter.LastPos.InRange
    (Servers[Player.ChannelIndex].OBJ[Packet.Index].Position, 10) then
  begin
    Player.SendClientMessage('Muito longe do objeto.');

    Player.CollectingReliquare := false;
    Player.CollectingAltar := false;
    Player.Teleporting := false;
    Player.CollectingID := 0;
    Exit;
  end;

  if (Packet.Index = 0) or (Packet.Index < 10148) or (Packet.Index > 11147) or
    (Servers[Player.ChannelIndex].OBJ[Packet.Index].Index = 0) then
  begin
    Player.CollectingReliquare := false;
    Player.CollectingAltar := false;
    Player.Teleporting := false;
    Player.CollectingID := 0;
    Exit;
  end;

  AlreadyReliq := TItemFunctions.GetItemSlotByItemType(Player, 40, INV_TYPE, 0);
  if AlreadyReliq <> 255 then
  begin
    Player.SendClientMessage
      ('Você não pode carregar mais de uma relíquia por vez.');
    Exit;
  end;

  if Player.Teleporting then
  begin
    if (Player.CollectingID <> Packet.Index) or
      (SecondsBetween(Now, Player.CollectInitTime) <= 3) then
    begin
      Player.CollectingReliquare := false;
      Player.CollectingAltar := false;
      Player.Teleporting := false;

      Player.SendPlayerToSavedPosition;

      // ZeroMemory(@xPacket, sizeof(xPacket));
      // xPacket.Header.Size := sizeof(xPacket);
      // xPacket.Header.Index := $7535;
      // xPacket.Header.Code := $101;
      // xPacket.Index := Packet.Index;
      //
      // Servers[Player.ChannelIndex].Players[Player.base.ClientID].SendPacket(xPacket, xPacket.Header.Size);

      Player.CollectingID := 0;
      Exit;
    end;

  end;

  if Player.CollectingReliquare then
  begin
    if (Player.CollectingID <> Packet.Index) or
      (SecondsBetween(Now, Player.CollectInitTime) <= 9) then
    begin
      Player.CollectingReliquare := false;
      Player.CollectingAltar := false;
      Player.CollectingID := 0;
      Exit;
    end;

    TItemFunctions.PutItem(Player, Servers[Player.ChannelIndex].OBJ
      [Packet.Index].ContentItemID);
    ZeroMemory(@xPacket, SizeOf(xPacket));
    xPacket.Header.Size := SizeOf(xPacket);
    xPacket.Header.Index := $7535;
    xPacket.Header.Code := $101;
    xPacket.Index := Packet.Index;

    if Player.Base.VisibleMobs.Contains(Packet.Index) then
      Player.Base.VisibleMobs.Remove(Packet.Index);

    xPos := Servers[Player.ChannelIndex].OBJ[Packet.Index].Position;
    ZeroMemory(@Servers[Player.ChannelIndex].OBJ[Packet.Index],
      SizeOf(Servers[Player.ChannelIndex].OBJ[Packet.Index]));

    for I := Low(Servers[Player.ChannelIndex].Players)
      to High(Servers[Player.ChannelIndex].Players) do
    begin
      if (Servers[Player.ChannelIndex].Players[I].Status >= Playing) and
        (Servers[Player.ChannelIndex].Players[I].Base.PlayerCharacter.LastPos.
        Distance(xPos) <= DISTANCE_TO_WATCH) then
      begin
        Servers[Player.ChannelIndex].Players[I].SendPacket(xPacket,
          xPacket.Header.Size);
        if Servers[Player.ChannelIndex].Players[I].Base.VisibleMobs.Contains
          (Packet.Index) then
          Servers[Player.ChannelIndex].Players[I].Base.VisibleMobs.Remove
            (Packet.Index);
        // Servers[Player.ChannelIndex].Players[i].Base.UpdateVisibleList();
      end;
    end;
  end;

  if Player.CollectingAltar then
  begin

    if Player.ChannelIndex = Player.Base.Character.Nation - 1 then
    begin
      Player.SendClientMessage
        ('Você não pode abrir o altar da sua própria nação', 16, 16, 16);
      Player.CollectingReliquare := false;
      Player.CollectingAltar := false;
      Player.CollectingID := 0;
      Exit;
    end;
    //
    if Servers[Player.ChannelIndex].AltarStolen then
    begin
      Player.SendClientMessage('O altar já foi roubado', 16, 16, 16);
      Player.CollectingReliquare := false;
      Player.CollectingAltar := false;
      Player.CollectingID := 0;
      Exit;
    end;

    if (Player.CollectingID <> Packet.Index) or
      (SecondsBetween(Now, Player.CollectInitTime) <= 9) then
    begin
      Player.CollectingReliquare := false;
      Player.CollectingAltar := false;
      Player.CollectingID := 0;
      Exit;
    end;

    var
      Gold: Int64;
    var
      stringer: string;
    Gold := 50000000;
    Player.AddGold(Gold);
    Player.SendClientMessage('Você recebeu ' + Gold.ToString +
      ' de golds', 0, 0, 0);

    if Player.ChannelIndex = 0 then
    begin
      stringer := 'Tibérica'
    end
    else if Player.ChannelIndex = 1 then
    begin
      stringer := 'Odeon'
    end
    else if Player.ChannelIndex = 2 then
    begin
      stringer := 'Ellora';
    end;

    Servers[0].SendServerMsg('O Altar de ' + stringer +
      ' foi roubado.', 16, 16);
    Servers[1].SendServerMsg('O Altar de ' + stringer +
      ' foi roubado.', 16, 16);
    Servers[2].SendServerMsg('O Altar de ' + stringer +
      ' foi roubado.', 16, 16);
    Servers[3].SendServerMsg('O Altar de ' + stringer +
      ' foi roubado.', 16, 16);

    if Player.ChannelIndex = 0 then
    begin
      Servers[0].SendServerMsg
        ('O altar foi roubado e este país está sob penalidade.');
    end
    else if Player.ChannelIndex = 1 then
    begin
      Servers[1].SendServerMsg
        ('O altar foi roubado e este país está sob penalidade.');
    end
    else if Player.ChannelIndex = 2 then
    begin
      Servers[2].SendServerMsg
        ('O altar foi roubado e este país está sob penalidade.');
    end;

    ZeroMemory(@xPacket, SizeOf(xPacket));
    xPacket.Header.Size := SizeOf(xPacket);
    xPacket.Header.Index := $7535;
    xPacket.Header.Code := $101;
    xPacket.Index := Packet.Index;

    if Player.Base.VisibleMobs.Contains(Packet.Index) then
      Player.Base.VisibleMobs.Remove(Packet.Index);

    xPos := Servers[Player.ChannelIndex].OBJ[Packet.Index].Position;
    ZeroMemory(@Servers[Player.ChannelIndex].OBJ[Packet.Index],
      SizeOf(Servers[Player.ChannelIndex].OBJ[Packet.Index]));

    for I := Low(Servers[Player.ChannelIndex].Players)
      to High(Servers[Player.ChannelIndex].Players) do
    begin
      if (Servers[Player.ChannelIndex].Players[I].Status >= Playing) and
        (Servers[Player.ChannelIndex].Players[I].Base.PlayerCharacter.LastPos.
        Distance(xPos) <= DISTANCE_TO_WATCH) then
      begin
        Servers[Player.ChannelIndex].Players[I].SendPacket(xPacket,
          xPacket.Header.Size);
        if Servers[Player.ChannelIndex].Players[I].Base.VisibleMobs.Contains
          (Packet.Index) then
          Servers[Player.ChannelIndex].Players[I].Base.VisibleMobs.Remove
            (Packet.Index);
        // Servers[Player.ChannelIndex].Players[i].Base.UpdateVisibleList();
      end;
    end;
  end;
  Result := True;
end;

class function TPacketHandlers.CancelCollectMapItem(var Player: TPlayer;
Buffer: Array of BYTE): boolean;
var
  Packet: TCancelCollectItem absolute Buffer;
begin
  Player.CollectingReliquare := false;
  Player.CollectingID := 0;

  if (Packet.Index >= 3370) and (Packet.Index <= 3372) and
    (Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder
    [Packet.Index - 3370].Base.ClientID = Player.Base.ClientID) then
  begin
    Servers[Player.ChannelIndex].CastleSiegeHandler.OrbHolder
      [Packet.Index - 3370] := nil;
  end;

  Result := True;
end;
{$ENDREGION}

end.
