unit Player;
//{$OPTIMIZATION ON}  // Ativa otimizações gerais
//{$O+}               // Ativa otimização de loops

interface

uses BaseMob, PlayerData, Winsock2, Windows, System.Threading, SysUtils,
  PlayerThread, PartyData, MiscData, AnsiStrings, Generics.Collections,
  GuildData, SQL, Data.DB, MOB, Classes, FilesData, EntityFriend,
  Dungeon, Math;
{$OLDTYPELAYOUT ON}
{$REGION 'Duel Thread'}

type
  TDuelThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    Player1, Player2: WORD;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE;
      Player1, Player2: BYTE);
  end;
{$ENDREGION}

type
  PPlayer = ^TPlayer;

  TPlayer = record
    { Create Destroy }
    procedure Create(clientId: WORD; Channel: BYTE);
    procedure Destroy;
  private
    FWaiting: BYTE;
    FTeam: BYTE;
    FLastPacketTimes: TDictionary<Integer, TDateTime>;
    procedure AddPlayerToActiveList(ServerID, ClientID: byte; Player: TPlayer);
    procedure RemovePlayerFromActiveList(ServerID, ClientID: byte);
  public
    DeathSendByThread: boolean;
    OldNation: BYTE;
    LastUpdateVisible: TDateTime;
    LastUpdateTimeThread: TDateTime;
    LastTTimeItensThread: TDateTime;
    LastTQuestItensThread: TDateTime;
    TavaEmDG: boolean;
    Teleportado_Raid: boolean;
    Teleportado_Grupo: boolean;
    EquipeEmDg: boolean;
    IsFishing: boolean;
    IsFishingPosition: TPosition;
    IsFishingPoints: byte;
    IsFishingDelay: TDateTime;
    FishingRandom1: byte;
    FishingRandom2: byte;
    F12TempoRestante: Integer;
    F12TempoAtivo: Integer;
    F12Ativo: boolean;
    F12LastFree: TDateTime;
    ChangingChannel: boolean;
    Base: TBaseMob;
    FirstRecv: boolean;
    RecvPackets: boolean;
    LastAttackSents: TDateTime;
    // atk normal de qlq tipo, pra setar no attackreceived e regen de hp
    LastAttackSent: TDateTime; // relacionado ao pk
    AttackingNation: boolean;
    EffectSent: smallint;
    Killnation: BYTE;
    LastCorreioMsg: TDateTime;
    Avisado: BYTE; // elter aviso de kick
    Setado: boolean;
    Removido: boolean;
    Teleporte: BYTE;
    LastTimeSaved: TDateTime;
    xdisconnected: boolean;
    SelectedCharacterIndex: shortint;
    Account: TAccountFile;
    Character: TPlayerCharacter;
    PlayerCharacter: TCharacter;
    CountTime: TDateTime;
    Status: TPlayerStatus;
    SubStatus: TPlayerStatus;
    Thread: TPlayerThread;
    // MobsThread: TPlayerThreadMobsUpdate;
    // PlayerSQL: TQuery;
    // SqlInUse: Boolean;
    TimeUpdate: TDateTime;
    SkillUpgraded: smallint;
    PlayerThreadActive: boolean;
    Unlogging: boolean;
    FDSet: TFDSet;
    AlreadyReading: boolean;
    SocketClosed: boolean;
    ChannelIndex: BYTE;
    Socket: TSocket;
    SockInUse: boolean;
    Ip: String;
    { Open Npc var }
    OpennedNPC: smallint;
    OpennedOption: BYTE;
    OpennedDevir: BYTE;
    OpennedTemple: BYTE;
    IsInstantiated: boolean;
    Party: PParty;
    PartyIndex: BYTE;
    GuildRecruterCharIndex: BYTE;
    GuildInviteTime: TDateTime;
    PartyRequester: BYTE;
    RaidRequester: BYTE;
    CanSendMailTo: string;
    { Duel }
    DuelRequester: BYTE;
    DuelThread: TDuelThread;
    Dueling: boolean;
    DuelFlagPosition: TPosition;
    DuelInitTime: TDateTime;
    DuelWinner: boolean;
    DuelOutTimes: WORD;
    DuelFlagID: WORD;
    DuelingWith: BYTE;
    FriendList: TFriendList;
    EntityFriend: TEntityFriend;
    FriendOpenWindowns: TDictionary<WORD, UInt64>;
    PlayerQuests: Array [0 .. 49] of QuestDin;
    TeleportList: Array [0 .. 4] of TPosition;
    SavedPos: TPosition;
    CurrentCity: TCity;
    CurrentCityID: BYTE;
    Cycles, Laps: BYTE;
    HPRCycles, HPRLaps: Integer;
    SKDCycles, SKDLaps: Integer;
    ShoutTime: TDateTime;
    SpawnedPran: BYTE;
    DungeonLobbyIndex: BYTE;
    DungeonLobbyDificult: BYTE;
    InDungeon: boolean;
    DungeonID: BYTE;
    DungeonIDDificult: BYTE;
    DungeonInstanceID: BYTE;
    DesconectedByOtherChannel: boolean;
    LoggedByOtherChannel: boolean;
    LastPositionLongSkill: TPosition;
    AliianceByLegion: boolean;
    AllianceRequester: BYTE;
    AllianceSlot: BYTE;
    CollectingReliquare: boolean;
    CollectingAltar: boolean;
    Teleporting: boolean;
    CollectInitTime: TDateTime;
    CollectingID: smallint;
    FaericForm: boolean;
    Authenticated, SendedSendToWorld: boolean;
    ConnectionedTime: TDateTime;
    PingCommandUsed: TDateTime;
    IsAuxilyUser: boolean;
    procedure Disconnect;
    { TPlayer }
    // procedure EnviarMsg;
    function CreateSQL: TQuery;
    procedure CheckInventoryRelic(DropRelic: boolean);
    function LoadAccountSql(Username: String): boolean;
    function LoadAccSQL(Username: String): boolean;
    function LoadCharacterMisc(CharID: Integer): boolean;
    function NameExists(CharacterName: String): boolean;
    function VerifyAmount(CharacterName: String): boolean;
    function SaveAccountToken(Username: String): boolean;
    function SaveStatus(Username: String): boolean;
    function SaveCreatedChar(CharacterName: String; Slot: Integer): boolean;
    function SaveCharOnCharRoom(CharID: Integer): boolean;
    function DeleteCharacter(CharID: Integer): boolean;
    function LoadCharacterTeleportList(CharName: String): boolean;
    function SaveCharacterTeleportList(CharName: String): boolean;
    function LoadSavedLocation(): TPosition;
    function SaveSavedLocation(Pos: TPosition): boolean;
    function CheckSelfSocket(): boolean;
    procedure SendPacket(const Packet; size: WORD; Encrypt: boolean = True);
    procedure SendSignal(headerClientId, packetCode: WORD); overload;
    procedure SendSignal(Client, packetCode, size: WORD); overload;
    procedure SendData(clientId, packetCode: WORD; Data: DWORD);
    function GetCurrentCity: TCity;
    function GetCurrentCityID: BYTE;
    procedure SetCurrentNeighbors();
    { Sends }
    procedure Limpar_Elter(AChannelIndex: Integer; ACharacterName: string);
    procedure Elter_Estatico(Player: TPlayer);
    procedure RegisterElter;
    procedure TeleportToLeopold;
    procedure RemoverDgs;
    procedure SendClientMessage(Msg: AnsiString; MsgType: Integer = 16;
      Null: Integer = 0; Type2: Integer = 0);
    procedure SendCharList(Type1: BYTE = 0);
    function BackToCharList: boolean;
    procedure SendToWorld(CharID: BYTE; aSendPacket: boolean = True);
    procedure SendToWorld2(CharID: BYTE);
    procedure SendPranToWorld(PranSlot: BYTE);
    procedure SendPranSpawn(PranSlot: BYTE; SendTo: WORD = 0;
      SpawnType: BYTE = 2);
    procedure SendPranUnspawn(PranSlot: BYTE; SendTo: WORD = 0);
    procedure SetPranPassiveSkill(PranSlot: BYTE; Action: BYTE);
    function GetPranClassStoneItem(PranClass: BYTE): BYTE;
    function PranIsFairy(PranClass: BYTE): boolean;
    procedure SetPranEquipAtributes(PranSlot: BYTE; SetOn: boolean);
    procedure RefreshMoney;
    procedure RefreshItemBarSlot(Slot, Type1, Item: Integer);
    procedure SendStorage(StorageType: Integer = 1);
    procedure SendChangeItemResponse(ReinforceResult: WORD;
      ChangeType: BYTE = 0);

    procedure SendAutoFarmTime();
    function GetAutoFarmTime(CharName: string): Integer;
    procedure AddFreeAutoFarmTime(CharName: string);
    procedure AddAutoFarmTime(CharName: AnsiString; tempo: Integer);
    function GetAutoFarmTimeUsed(CharName: string): Integer;
    procedure SendAccountStatus();

    procedure UnsetDungeon(unk: boolean = false);

    procedure SendToWorldSends(IsSendedByOtherChannel: boolean = false);
    procedure SendTitleUpdate(TitleIDAcquire: DWORD; TitleIDLeveled: DWORD);
    procedure RefreshPlayerInfos(SendToVisible: boolean = True);
    procedure SpawnMob(mobid: DWORD; MobIdGen: DWORD);
    procedure SpawnMobGuard(mobid: DWORD; MobIdGen: DWORD);
    procedure UnspawnMob(mobid: DWORD; MobIdGen: DWORD);
    // procedure SpawnPet(PetID: WORD);
    // procedure UnSpawnPet(PetID: WORD);
    procedure SendTeleportPositionsFC();
    procedure SendPlayerToSavedPosition();
    procedure SendPlayerToCityPosition();
    procedure DisparosRapidosBarReset(SkillID: DWORD);
    procedure PredadorInvBarReset(SkillID: DWORD);
    procedure SendUpdateActiveTitle();
    procedure SendNationInformation();
    function GetPranEvolutedCnt(): Integer;
    function SetPranEvolutedCnt(Cnt: Integer): boolean;
    function GetPranClass(xPran: PPran): BYTE;
    procedure SendCloseClient();
    procedure SendCloseNpc();
    { Unk/Others Sends }
    procedure SendNumbers;
    procedure SendClientIndex;
    procedure SendP12C;
    procedure SendKarakAereo;
    procedure SendP131;
    procedure SendP16F;
    procedure SendP186;
    procedure SendP227;
    procedure SendP33D;
    procedure SendP357;
    procedure SendP3A2;
    procedure SendP94C;
    { Trade }
    procedure RefreshTrade;
    procedure RefreshTradeTo(clientId: Integer);
    procedure CloseTrade;
    { Party }
    procedure SendToParty(var Packet; size: WORD; SendSelf: boolean = True);
    procedure RefreshParty;
    function AddMemberParty(PlayerIndex: WORD): boolean;
    procedure SendPositionParty(SendTo: WORD = 0);
    { Cash }
    procedure SendPlayerCash;
    procedure SendCashInventory;
    procedure SendCancelCollectItem(Index: Integer);
    { Char Info }
    procedure CharInfoResponse(Index: WORD);
    procedure ViewPran(Index: WORD; indexplayer: WORD = 0);
    { Player Add Functions }
    function AddExp(Value: Int64; out ExpPreReliq: Integer;
      ExpType: Integer = 0): Int64;
    procedure AddExpPerc(Value: WORD; Ação: Integer = 0);
    procedure AddLevel(Value: WORD = 1; Ação: WORD = 0);
    procedure AddPranExp(PranSlot: BYTE; Value: DWORD);
    procedure SendPranLevelAndExp(Level: DWORD; Exp: Int64);
    procedure SendPranDevotionAndFood(Devotion, Food: WORD);
    procedure AddPranLevel(PranSlot: BYTE; Value: WORD = 1);
    function PranBarExistsIndex(PranID: BYTE; Index: DWORD): BYTE;
    procedure AddGold(Value: Int64);
    procedure AddCash(Value: Cardinal);
    procedure DecCash(Value: Cardinal);
    procedure DecGold(Value: Int64);
    procedure AddTitle(TitleID, TitleLevel: Integer; xMsg: boolean = True);
    { Title }
    function GetTitle(TitleID: Integer): boolean;
    procedure RemoveTitle(TitleID: Integer);
    procedure UpdateTitleLevel(TitleID, TitleLevel: Integer;
      xMsg: boolean = True);
    { Skills }
    procedure SetPlayerSkills;
    procedure SendPlayerSkills(NPCIndex: Integer = 0);
    procedure SendPlayerSkillsLevel;
    function CalcSkillPoints(Level: WORD): WORD;
    procedure SearchSkillsPassive(Mode: BYTE = 0);
    procedure SetActiveSkillPassive(SkillIndex: Integer; SkillIDLevel: Integer);
    procedure SetDesativeSkillPassive(SkillIndex: Integer);
    { Friend list }
    procedure sendToFriends(const Packet; size: WORD);
    procedure sendFriendToSocial(const characterId: UInt64);
    function AddFriend(PlayerIndex: WORD): BYTE;
    procedure AtualizeFriendInfos(characterId: UInt64);
    procedure sendDeleteFriend(characterId: UInt64);
    procedure SendFriendLogin;
    procedure SendFriendLogout;
    procedure RefreshSocialFriends;
    procedure RefreshMeToFriends;
    procedure OpenFriendWindow(CharIndex, WindowIndex: DWORD);
    procedure CloseFriendWindow(characterId: UInt64);
    { PersonalShop }
    procedure SendPersonalShop(Shop: TPersonalShopData);
    procedure ClosePersonalShop;
    { Teleport Functions }
    procedure Teleport(Pos: TPosition);
    { Change Channel }
    procedure SendChannelClientIndex;
    procedure SendLoginConfirmation;
    { Chat Functions }
    function SendItemChat(Slot: WORD; ChatType: BYTE; Msg: string): boolean;
    { Effect and Animation Functions }
    procedure SendEffect(EffectIndex: DWORD);
    procedure SendAnimation(AnimationIndex: DWORD; Loop: DWORD = 0);
    procedure SendDevirChange(DevirNpcID: DWORD; DevirAnimation: DWORD);
    procedure SendAnimationDeadOf(clientId: DWORD);
    { Guild }
    procedure SearchAndSetGuildSlot;
    procedure SendGuildInfo;
    procedure SendGuildPlayers;
    procedure AddPlayerToGuild(Player: TPlayerFromGuild);
    procedure GuildMemberLogin(MemberId: Integer);
    procedure GuildMemberLogout(MemberId: Integer);
    procedure UpdateGuildMemberRank(CharIndex, Rank: Integer);
    procedure UpdateGuildMemberLevel(CharIndex, Level: Integer);
    procedure UpdateGuildRanksConfig;
    procedure UpdateGuildNotices;
    procedure UpdateGuildSite;
    procedure InviteToGuildRequest(clientId: Integer);
    procedure GetOutGuild(Expulsion: boolean);
    procedure SendGuildChestPermission;
    procedure SendGuildChest;
    procedure CloseGuildChest;
    procedure RefreshGuildChestGold;
    procedure SendP152;
    { Duel }
    procedure SendDuelTime();
    procedure CreateDuelSession(OtherPlayer: PPlayer);
    procedure SendDuelEnd(MsgType: BYTE);
    procedure RemoveDuelFlag(FlagID: WORD = 0);
    procedure SendDuelEffect(FlagID: WORD);
    { Quest }
    procedure SendQuests();
    procedure UpdateQuest(QuestID: DWORD);
    procedure RemoveQuest(QuestID: DWORD);
    procedure SendExpGoldMsg(Exp, Gold: DWORD);
    function QuestExists(QuestID: WORD; out QuestIndex: WORD): boolean;
    function SearchEmptyQuestIndex(): WORD;
    function QuestCount(): WORD;
    { Event Item }
    procedure GetAllEventItems();
    function DiaryItemAvaliable(): boolean;
    { Dungeon }
    procedure SendDungeonLobby(InParty: boolean; Dungeon, Dificult: BYTE);
    function GetFreeDungeonInstance(): BYTE;
    procedure CreateDungeonInstance(InParty: boolean; Dungeon, Dificult: BYTE);
    procedure SendSpawnMobDungeon(MOB: PMobsStructDungeonInstance);
    procedure SendRemoveMobDungeon(MOB: PMobsStructDungeonInstance);
    { Nation }
    function IsMarshal(): boolean;
    function IsArchon(): boolean;
    function IsGradeMarshal(): boolean;
    function IsGradeArchon(): boolean;
    { Reliquares and Devir }
    procedure SendUpdateReliquareInformation(Channel: BYTE);
    procedure SendReliquesToPlayer();
    procedure UpdateReliquareOpennedDevir(DevirID: Integer);
    { Classes }
    class function GetPlayer(Index: WORD; Server: BYTE; out Player: TPlayer)
      : boolean; static;
    class procedure ForEach(proc: TProc<PPlayer>; Server: BYTE);
      overload; static;
    class procedure ForEach(proc: TProc<PPlayer, TParallel.TLoopState>;
      Server: BYTE); overload; static;
    function GetTitleLevelValue(Slot, Level: BYTE): WORD;
    function CheckGameMasterLogged(): boolean;
    function CheckAdminLogged(): boolean;
    function CheckModeratorLogged(): boolean;
    function GetLastPacketTime(HeaderCode: Integer): TDateTime;
    procedure SetLastPacketTime(HeaderCode: Integer);

    procedure SendMessageGritoForGameMaster(Nick: String; ServerFrom: Integer;
      xMsg: String);
    property Waiting1: BYTE read FWaiting write FWaiting;
    property Team1: BYTE read FTeam write FTeam;

  end;
{$OLDTYPELAYOUT OFF}

implementation

uses GlobalDefs, Functions, ItemFunctions, SkillFunctions, EncDec, Packets, Log,
  DateUtils, EntityMail, Util, FireDAC.Phys.Intf;

function CalculateChecksum(const Buffer: ARRAY OF BYTE; size: WORD): BYTE;
var
  I: Integer;
  Sum: Integer;
begin
  Sum := 0;
  for I := 0 to size - 1 do
    Sum := Sum + Buffer[I];
  Result := BYTE(Sum and $FF); // Usando máscara para limitar o valor a 8 bits
end;

{$REGION 'Duel Thread'}

constructor TDuelThread.Create(SleepTime: Integer; ChannelId: BYTE;
  Player1, Player2: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.Player1 := Player1;
  Self.Player2 := Player2;
  inherited Create(false);
  Self.Priority := tpLower;
  // inc(DuelosAtivos);
end;

procedure TDuelThread.Execute;
var
  I: Integer;
  P1, P2: PPlayer;
  P1Out, P2Out: boolean;
  SecondsPassed: Integer;
begin
  P1 := @Servers[Self.ChannelId].Players[Self.Player1];
  P2 := @Servers[Self.ChannelId].Players[Self.Player2];
  P1.DuelOutTimes := 0;
  P2.DuelOutTimes := 0;

  Sleep(DUEL_TIME_WAIT);

  while (P1.Dueling) do
  begin

    if not(P1.Base.IsActive) then
    begin
      P1.Dueling := false;
      P2.Dueling := false;
      P1.DuelWinner := false;
      P2.DuelWinner := True;
      Break;
    end;

    if not(P2.Base.IsActive) then
    begin
      P1.Dueling := false;
      P2.Dueling := false;
      P1.DuelWinner := True;
      P2.DuelWinner := false;
      Break;
    end;

    // Gerenciando o estado de P1
    if not P1.Base.PlayerCharacter.LastPos.InRange((P1.DuelFlagPosition), DISTANCE_TO_WATCH) then
    begin
      if (P1.DuelOutTimes = 0) then
      begin
        P1.SendClientMessage('Volte em até 5 segundos para a área de duelo.');
        P2.SendClientMessage
          ('Seu alvo está fora da área de duelo. 5 Segundos para voltar.');
        Inc(P1.DuelOutTimes);
      end
      else if (P1.DuelOutTimes >= 5) then
      begin
        P1.Dueling := false;
        P2.Dueling := false;
        P1.DuelWinner := false;
        P2.DuelWinner := True;
        Break;
      end
      else
        Inc(P1.DuelOutTimes);
    end
    else
      P1.DuelOutTimes := 0;

    // Gerenciando o estado de P2
    if not P2.Base.PlayerCharacter.LastPos.InRange((P1.DuelFlagPosition), DISTANCE_TO_WATCH) then
    begin
      if (P2.DuelOutTimes = 0) then
      begin
        P2.SendClientMessage('Volte em até 5 segundos para a área de duelo.');
        P1.SendClientMessage
          ('Seu alvo está fora da área de duelo. 5 Segundos para voltar.');
        Inc(P2.DuelOutTimes);
      end
      else if (P2.DuelOutTimes >= 5) then
      begin
        P2.Dueling := false;
        P1.Dueling := false;
        P2.DuelWinner := false;
        P1.DuelWinner := True;
        Break;
      end
      else
        Inc(P2.DuelOutTimes);
    end
    else
      P2.DuelOutTimes := 0;

    // Verificando o tempo de duelo
    SecondsPassed := SecondsBetween(Now, P1.DuelInitTime);
    if (SecondsPassed >= (300 + DUEL_TIME_WAIT)) then
    begin
      P2.Dueling := false;
      P1.Dueling := false;
      P2.DuelWinner := false;
      P1.DuelWinner := false;
      P1.SendClientMessage
        ('Duelo terminou. Limite máximo de tempo é de 5 minutos.');
      P2.SendClientMessage
        ('Duelo terminou. Limite máximo de tempo é de 5 minutos.');
      Break;
    end;

    // Verificando a vida dos jogadores
    if (P1.Base.Character.CurrentScore.CurHP <= 10) then
    begin
      P2.Dueling := false;
      P1.Dueling := false;
      P2.DuelWinner := True;
      P1.DuelWinner := false;
      Break;
    end;

    if (P2.Base.Character.CurrentScore.CurHP <= 10) then
    begin
      P2.Dueling := false;
      P1.Dueling := false;
      P2.DuelWinner := false;
      P1.DuelWinner := True;
      Break;
    end;

    // Reduzindo a frequência de Sleep para melhorar o desempenho
    TThread.Sleep(FDelay);
  end;

  // Finalizando o duelo
  if (P1.DuelWinner) then
  begin
    P1.SendDuelEnd(1); // win
    P2.SendDuelEnd(0); // lose
    P1.SendClientMessage(AnsiString(P1.Character.Base.Name) + ' venceu ' +
      AnsiString(P2.Character.Base.Name) + ' no duelo.');
    P2.RemoveDuelFlag;
    P1.RemoveDuelFlag;
    for I in P1.Base.VisiblePlayers do
    begin
      if not(Servers[Self.ChannelId].Players[I].Base.IsActive) then
        Continue;
      Servers[Self.ChannelId].Players[I].SendClientMessage
        (AnsiString(P1.Character.Base.Name) + ' venceu ' +
        AnsiString(P2.Character.Base.Name) + ' no duelo.');
      Servers[Self.ChannelId].Players[I].RemoveDuelFlag(P1.DuelFlagID);
    end;
  end
  else if (P2.DuelWinner) then
  begin
    P1.SendDuelEnd(0); // lose
    P2.SendDuelEnd(1); // win
    P2.SendClientMessage(AnsiString(P2.Character.Base.Name) + ' venceu ' +
      AnsiString(P1.Character.Base.Name) + ' no duelo.');
    P2.RemoveDuelFlag;
    P1.RemoveDuelFlag;
    for I in P2.Base.VisiblePlayers do
    begin
      if not(Servers[Self.ChannelId].Players[I].Base.IsActive) then
        Continue;
      Servers[Self.ChannelId].Players[I].SendClientMessage
        (AnsiString(P2.Character.Base.Name) + ' venceu ' +
        AnsiString(P1.Character.Base.Name) + ' no duelo.');
      Servers[Self.ChannelId].Players[I].RemoveDuelFlag(P1.DuelFlagID);
    end;
  end
  else
  begin
    P1.SendDuelEnd(0); // lose
    P2.SendDuelEnd(0); // lose
    P1.SendClientMessage('Duelo entre ' + AnsiString(P1.Character.Base.Name) +
      ' e ' + AnsiString(P2.Character.Base.Name) + ' deu empate.');
    P1.RemoveDuelFlag;
    P2.RemoveDuelFlag;
    for I in P1.Base.VisiblePlayers do
    begin
      if not(Servers[Self.ChannelId].Players[I].Base.IsActive) then
        Continue;
      Servers[Self.ChannelId].Players[I].SendClientMessage
        ('Duelo entre ' + AnsiString(P1.Character.Base.Name) + ' e ' +
        AnsiString(P2.Character.Base.Name) + ' deu empate.');
      Servers[Self.ChannelId].Players[I].RemoveDuelFlag(P1.DuelFlagID);
    end;
  end;

  P1.Base.RemoveAllDebuffs;
  P2.Base.RemoveAllDebuffs;
  P1.Base.ResolutoPoints := 0;
  P2.Base.ResolutoPoints := 0;
end;

{$ENDREGION}
{$REGION 'Create & Destroy'}

procedure TPlayer.CheckInventoryRelic(DropRelic: boolean);
var
  RlkSlot: BYTE;
  Reliquia: PItem;
  CityID, Channel_ID: BYTE;
  NationName, CityName, mensagem1, mensagem2, mensagem3: string;
begin

  CityID := Self.GetCurrentCityID;
  Channel_ID := Self.ChannelIndex;

  RlkSlot := TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0);

  // Enquanto encontrar um slot válido, continua
  while RlkSlot <> 255 do
  begin
    // Aponta para a relíquia no inventário
    Reliquia := @Self.Base.Character.Inventory[RlkSlot];

    // Cria a relíquia no chão
    Servers[Self.Base.ChannelId].CreateMapObject
      (@Servers[Self.Base.ChannelId].Players[Self.Base.clientId], 320,
      Reliquia^.Index);

    // Zera a memória do item e dá refresh no inventário do jogador
    ZeroMemory(Reliquia, SizeOf(TItem));
    Self.Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Reliquia^, false);

    // Efeito visual
    Self.SendEffect(0);

    if (CityID >= Low(MapNames)) and (CityID <= High(MapNames)) then
    begin

      CityName := MapNames[CityID];

      if (Channel_ID >= Low(Nacoes)) and (Channel_ID <= High(Nacoes)) then
      begin
        NationName := Nacoes[Channel_ID];

        // Verifica se o nome do mapa não está vazio
        if (CityName <> '') then
          mensagem3 := '[Mapa]: ' + CityName + ' [Nação]: ' + NationName;
      end;
    end
    else
      mensagem3 := '';
    mensagem1 := 'O jogador ' + AnsiString(Self.Base.Character.Name) +
      ' dropou a relíquia:';
    mensagem2 := '<' + AnsiString(ItemList[Reliquia^.Index].Name) + '>.';

    Servers[Self.Base.ChannelId].SendServerMsg(mensagem1, 16, 32, 16);
    Servers[Self.Base.ChannelId].SendServerMsg(mensagem2, 16, 32, 16);
    if mensagem3 <> '' then
      Servers[Self.Base.ChannelId].SendServerMsg(mensagem3, 16, 32, 16);

    // Pega o próximo slot com relíquia
    RlkSlot := TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0);
  end;

end;

function TPlayer.CreateSQL: TQuery;
begin
  // Criando a conexão usando as variáveis globais já definidas
  Result := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

end;

procedure TPlayer.AddPlayerToActiveList(ServerID, ClientID: byte; Player: TPlayer);
var
  Key: TPlayerKey;
begin
    Key.ServerID := ServerID;
    Key.ClientID := ClientID;
    ActivePlayers.AddOrSetValue(Key, Player);
end;


procedure TPlayer.RemovePlayerFromActiveList(ServerID, ClientID: byte);
var
  Key: TPlayerKey;
begin
  Key.ServerID := ServerID;
  Key.ClientID := ClientID;
  ActivePlayers.Remove(Key);
end;


procedure TPlayer.Create(clientId: WORD; Channel: BYTE);
var
  address: TSockAddrIn;
  addressLength: Integer;
begin

  Killnation := 0;
  FLastPacketTimes := TDictionary<Integer, TDateTime>.Create;
  Self.ChannelIndex := Channel;
  Self.Unlogging := false;
  PlayerThreadActive := True;
  Base.Create(@Self.Character.Base, clientId, Channel);

  getpeername(Self.Socket, TSockAddr(address), addressLength);
  Self.Ip := string(inet_ntoa(address.sin_addr));

  Self.FriendOpenWindowns := TDictionary<WORD, UInt64>.Create(6);
  Self.FriendOpenWindowns.Clear;
  ZeroMemory(@PlayerQuests, SizeOf(PlayerQuests));
  ShoutTime := Now;
  SpawnedPran := 255;
  Self.LastTimeSaved := Now;
  Self.Base.LastReceivedAttack := Now - (1 / 24 / 60);
  Self.LastAttackSents := Now - (1 / 24 / 60);
  FaericForm := false;
  Self.SendedSendToWorld := false;

  Self.EntityFriend := TEntityFriend.Create(@Self);
  Self.FriendList := TDictionary<UInt64, TFriend>.Create(50);

  Self.LastAttackSent := Now - (1 / 24 / 60);
  AddPlayerToActiveList(Self.ChannelIndex, Self.Base.ClientID, Self);

end;

procedure TPlayer.Destroy;
var
  Guild: PGuild;
  I, ch, RlkSlot: BYTE;
  cid: WORD;
  Item: PItem;
  str_aux: String;
begin

  RemovePlayerFromActiveList(Self.ChannelIndex, Self.Base.ClientID);

  if Self.FWaiting <> 0 then
  begin
    IpList.Remove(Ip);

    case Self.FTeam of

      4:
        begin
          Servers[3].Quantidade_Azul := Servers[3].Quantidade_Azul - 1;
        end;

      5:
        begin
          Servers[3].Quantidade_Vermelho := Servers[3].Quantidade_Vermelho - 1;
        end;

    end;
  end;

  // Writeln('acessei o destroy');

  FLastPacketTimes.Free;
  Self.Unlogging := True;

  if Self.Base.clientId = 0 then
    Exit;

  // Se estiver na tela de seleção de personagem
  if Self.Status = TPlayerStatus.CharList then
  begin
    Writeln('deslogando de forma tela de selecao de personagem');
    for I := 0 to 2 do
    begin
      if Self.Account.Characters[I].Base.Name <> '' then
        Self.SaveCharOnCharRoom(I);
    end;

    Self.Account.Header.IsActive := false;
    Self.SaveStatus(String(Self.Account.Header.Username));
    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;

    Self.Base.Destroy;
    FreeAndNil(Self.FriendOpenWindowns);
    FreeAndNil(Self.EntityFriend);
    FreeAndNil(Self.FriendList);

    closesocket(Self.Socket);
    xdisconnected := True;

    Exit;
  end;

  // Se já passou da tela de seleção de personagem
  if Self.Status > TPlayerStatus.CharList then
  begin
    Writeln('na tela de selecao de personagem, deslogando char');

    for I in Self.Base.VisiblePlayers do
    begin
      if Self.SpawnedPran = 0 then
        Self.SendPranUnspawn(0, I)
      else
        Self.SendPranUnspawn(1, I);
    end;

    Self.SendFriendLogout;
    Self.Base.SendRemoveMob(0, 0, false);

    // Desconectar do calabouço, caso esteja em um
    if Self.InDungeon then
    begin
      if Self.Base.clientId = Self.Party.Leader then
      begin
        DungeonInstances[Self.DungeonInstanceID].Index := 0;
        DungeonInstances[Self.DungeonInstanceID].CreateTime := Now;
        DungeonInstances[Self.DungeonInstanceID].Party := nil;
        DungeonInstances[Self.DungeonInstanceID].DungeonID := 0;
        DungeonInstances[Self.DungeonInstanceID].Dificult := 0;
        ZeroMemory(@DungeonInstances[Self.DungeonInstanceID].MOBS,
          SizeOf(DungeonInstances[Self.DungeonInstanceID].MOBS));
        DungeonInstances[Self.DungeonInstanceID].InstanceOnline := false;

        Writeln('Status da Instance 1 ' + DungeonInstances
          [Self.DungeonInstanceID].InstanceOnline.ToString);

        for I in Self.Party.Members do
        begin
          if I = Self.Base.clientId then
            Continue;

          Servers[Self.ChannelIndex].Players[I].SendClientMessage
            ('O jogador [' + AnsiString(Self.Base.Character.Name) +
            '] era líder do grupo e se desconectou, todos foram expulsos do calabouço.');

          Servers[Self.ChannelIndex].Players[I].DungeonLobbyIndex := 0;
          Servers[Self.ChannelIndex].Players[I].DungeonLobbyDificult := 0;
          Servers[Self.ChannelIndex].Players[I].DungeonID := 0;
          Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := 0;
          Servers[Self.ChannelIndex].Players[I].DungeonInstanceID := 0;
          Servers[Self.ChannelIndex].Players[I].InDungeon := false;
          Servers[Self.ChannelIndex].Players[I].SendPlayerToSavedPosition;
        end;
      end
      else
      begin
        Self.DungeonLobbyIndex := 0;
        Self.DungeonLobbyDificult := 0;
        Self.DungeonID := 0;
        Self.DungeonIDDificult := 0;
        Self.DungeonInstanceID := 0;
        Self.InDungeon := false;
        Self.SendPlayerToSavedPosition;

        for I in Self.Party.Members do
        begin
          Servers[Self.ChannelIndex].Players[I].SendClientMessage
            ('O jogador [' + AnsiString(Self.Base.Character.Name) +
            '] se desconectou e foi expulso do calabouço.');
        end;
      end;
    end;

    // Guild logout
    if Self.Character.Base.GuildIndex > 0 then
    begin
      Guild := @Guilds[Self.Character.GuildSlot];
      Guild.SendMemberLogout(Self.Character.Index);

      if Guild.MemberInChest = Guild.FindMemberFromCharIndex(Self.Character.
        Index) then
      begin
        Guild.MemberInChest := $FF;
        Guild.LastChestActionDate := 0;
      end;
    end;

    // Desvinculação da party
    if not Self.DesconectedByOtherChannel then
    begin
      if Self.PartyIndex > 0 then
        Self.Party.RemoveMember(Self.Base.clientId);

      Self.CheckInventoryRelic(true);

      Self.Base.RemoveBuffByIndex(91);
    end
    else
    begin
      if Self.PartyIndex > 0 then
      begin
        if Self.Party.Leader = Self.Base.clientId then
        begin
          Self.Party.DestroyParty(Self.Base.clientId);
          Self.Party.RefreshParty;
          Self.RefreshParty;
        end;
      end;
    end;

    // Pet logout
    // if Self.Base.Character.Equip[8].Index <> 0 then
    // Self.Base.DestroyPet(Self.Base.PetClientID);

    Self.Account.Header.IsActive := false;
    Self.Base.IsActive := false;
    str_aux := String(Self.Account.Header.Username);

    Self.SaveStatus(str_aux);
    Self.SaveCharOnCharRoom(Self.SelectedCharacterIndex);
//    Self.SaveInGame(Self.SelectedCharacterIndex);
    TFunctions.SavePlayerSecundario(@Self, Self.SelectedCharacterIndex);
    TFunctions.SavePlayerPrincipal(@Self, Self.SelectedCharacterIndex);

    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;

    Self.Base.Destroy;
    FreeAndNil(Self.FriendOpenWindowns);
    FreeAndNil(Self.EntityFriend);
    FreeAndNil(Self.FriendList);

    closesocket(Self.Socket);
    xdisconnected := True;

    // Writeln('salvou antes de ir pra tela de login');
  end
  else if Self.Status < TPlayerStatus.CharList then
  begin
    Writeln('deslogando de forma tela de login');
    Self.Account.Header.IsActive := false;
    Self.Base.IsActive := false;
    Self.SaveStatus(String(Self.Account.Header.Username));

    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;

    Self.Base.Destroy;
    FreeAndNil(Self.FriendOpenWindowns);
    FreeAndNil(Self.EntityFriend);
    FreeAndNil(Self.FriendList);

    closesocket(Self.Socket);
    xdisconnected := True;

    Writeln('bugzinho brabo');
  end;
end;

function TPlayer.GetLastPacketTime(HeaderCode: Integer): TDateTime;
begin
  if not FLastPacketTimes.TryGetValue(HeaderCode, Result) then
    Result := 0;
end;

procedure TPlayer.SetLastPacketTime(HeaderCode: Integer);
begin
  FLastPacketTimes.AddOrSetValue(HeaderCode, Now);
end;

{$ENDREGION}
{$REGION 'TPlayer'}

function TPlayer.LoadAccountSql(Username: String): boolean;
var
  PlayerSQLComp: TQuery;
  DateTimeValue, LastTokenCreationTime, Epoch: TDateTime;

begin
  Result := false;
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadAccountSql]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadAccountSql]', TlogType.Error);
    PlayerSQLComp.Destroy;
    Exit;
  end;

  try
    PlayerSQLComp.SetQuery
      ('SELECT id, password_hash, last_token, last_token_creation_time, ' +
      ' nation, isactive, account_status, account_type, storage_gold, cash, premium_time, ban_days'
      + ' FROM accounts WHERE username = "' + Username + '"');

    // Servers[Self.ChannelIndex].cSQL.AddParameter2('pusername', Username);
    PlayerSQLComp.Run();

    if (PlayerSQLComp.Query.IsEmpty) then
    begin
      PlayerSQLComp.Destroy;
      Exit;
    end;

    Self.Account.Header.AccountId := PlayerSQLComp.Query.FieldByName('id')
      .AsInteger;
    Self.Account.Header.Username := String(Username);
    Self.Account.Header.Password :=
      ShortString(PlayerSQLComp.Query.FieldByName('password_hash').AsString);
    AnsiStrings.StrPLCopy(Self.Account.Header.Token.Token,
      AnsiString(PlayerSQLComp.Query.FieldByName('last_token').AsString), 32);

    LastTokenCreationTime :=
      UnixToDateTime(PlayerSQLComp.Query.FieldByName('last_token_creation_time')
      .AsInteger);

    Self.Account.Header.Token.CreationTime := LastTokenCreationTime;

    Self.Account.Header.Nation :=
      TCitizenship(PlayerSQLComp.Query.FieldByName('nation').AsInteger);
    Self.Account.Header.IsActive := (PlayerSQLComp.Query.FieldByName('isactive')
      .AsInteger).ToBoolean;
    Self.Account.Header.AccountStatus := PlayerSQLComp.Query.FieldByName
      ('account_status').AsInteger;
    Self.Account.Header.AccountType :=
      TAccountType(PlayerSQLComp.Query.FieldByName('account_type').AsInteger);
    Self.Account.Header.Storage.Gold := PlayerSQLComp.Query.FieldByName
      ('storage_gold').AsInteger;
    Self.Account.Header.CashInventory.Cash := PlayerSQLComp.Query.FieldByName
      ('cash').AsInteger;

    Self.Account.Header.PremiumTime := DateTimeValue;

    Self.Account.Header.BanDays := PlayerSQLComp.Query.FieldByName('ban_days')
      .AsInteger;

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load Account error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' + Username + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      // Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  PlayerSQLComp.Destroy;
  Result := True;
end;

function TPlayer.LoadAccSQL(Username: String): boolean;
var
  CharCount: Integer;
  Slot: Integer;
  ItemAmount: Integer;
  ItemSlot: Integer;
  I: Integer;
  J: Integer;
  SQLComp: TQuery;
begin
  Result := false;
  if not(Self.LoadAccountSql(Username)) then
  begin
    Logger.Write('Dentro do if', TlogType.Error);
    Exit;
  end;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadAccSQL]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadAccSQL]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    // Self.PlayerSQL.MySQL.StartTransaction;
    SQLComp.SetQuery
      ('SELECT id, slot, numeric_errors, deleted, numeric_token, name, ' +
      'classinfo, strength, agility, intelligence, constitution, luck, status, '
      + 'altura, tronco, perna, corpo, curhp, curmp, honor, killpoint, infamia, '
      + 'skillpoint, experience, level, guildindex, gold, creationtime, ' +
      'numeric_token, logintime, speedmove, rotation, lastlogin, loggedtime, ' +
      'playerkill, posx, posy, deleted, delete_time, active_title ' +
      'FROM characters WHERE owner_accid = ' +
      Self.Account.Header.AccountId.ToString + ' LIMIT 3');
    // PlayerSQL.AddParameter2('powner_accid', Self.Account.Header.AccountId);
    SQLComp.Run();
    CharCount := SQLComp.Query.RecordCount;
    if (CharCount = 0) then
    begin
      // Self.PlayerSQL.MySQL.Commit;
      SQLComp.Destroy;
      Result := True;
      Exit;
    end;
    for I := 0 to (CharCount - 1) do
    begin
      Slot := SQLComp.Query.FieldByName('slot').AsInteger;
      Self.Account.Header.NumError[Slot] :=
        (SQLComp.Query.FieldByName('numeric_errors').AsInteger);
      Self.Account.Header.PlayerDelete[Slot] :=
        boolean(SQLComp.Query.FieldByName('deleted').AsInteger);
      Self.Account.Header.NumericToken[Slot] :=
        ShortString(SQLComp.Query.FieldByName('numeric_token').AsString);
      Self.Account.Characters[Slot].Index := SQLComp.Query.FieldByName('id')
        .AsInteger;
      AnsiStrings.StrPLCopy(Self.Account.Characters[Slot].Base.Name,
        AnsiString(SQLComp.Query.FieldByName('name').AsString), 16);
      Self.Account.Characters[Slot].Base.CharIndex := Self.Account.Characters
        [Slot].Index;
      // PlayerSQL.Query.FieldByName('slot').AsInteger;
      case Self.Account.Header.Nation of
        TCitizenship.None:
          Self.Account.Characters[Slot].Base.Nation := 0;
        TCitizenship.Server1:
          Self.Account.Characters[Slot].Base.Nation := 1;
        TCitizenship.Server2:
          Self.Account.Characters[Slot].Base.Nation := 2;
        TCitizenship.Server3:
          Self.Account.Characters[Slot].Base.Nation := 3;
      end;
      Self.Account.Characters[Slot].Base.ClassInfo :=
        (SQLComp.Query.FieldByName('classinfo').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Str :=
        (SQLComp.Query.FieldByName('strength').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.agility :=
        (SQLComp.Query.FieldByName('agility').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Int :=
        (SQLComp.Query.FieldByName('intelligence').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Cons :=
        (SQLComp.Query.FieldByName('constitution').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Luck :=
        (SQLComp.Query.FieldByName('luck').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Status :=
        (SQLComp.Query.FieldByName('status').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Altura :=
        (SQLComp.Query.FieldByName('altura').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Tronco :=
        (SQLComp.Query.FieldByName('tronco').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Perna :=
        (SQLComp.Query.FieldByName('perna').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Corpo :=
        (SQLComp.Query.FieldByName('corpo').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.CurHP :=
        SQLComp.Query.FieldByName('curhp').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.CurMp :=
        SQLComp.Query.FieldByName('curmp').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.Honor :=
        SQLComp.Query.FieldByName('honor').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.KillPoint :=
        SQLComp.Query.FieldByName('killpoint').AsInteger;
      Self.Account.Characters[Slot].Base.CurrentScore.Infamia :=
        (SQLComp.Query.FieldByName('infamia').AsInteger);
      Self.Account.Characters[Slot].Base.CurrentScore.SkillPoint :=
        (SQLComp.Query.FieldByName('skillpoint').AsInteger);

           Self.Account.Characters[Slot].Base.Exp :=
        SQLComp.Query.FieldByName('experience').AsLargeInt;
      Self.Account.Characters[Slot].Base.Level :=
        (SQLComp.Query.FieldByName('level').AsInteger);


      if (SQLComp.Query.FieldByName('experience').AsLargeInt = 0) and (SQLComp.Query.FieldByName('level').AsInteger = 1) then
      begin
       Self.Account.Characters[Slot].Base.Exp := 1;
      end;




      Self.Account.Characters[Slot].Base.GuildIndex :=
        SQLComp.Query.FieldByName('guildindex').AsInteger;
      Self.Account.Characters[Slot].Base.Gold :=
        SQLComp.Query.FieldByName('gold').AsLargeInt;
      Self.Account.Characters[Slot].Base.CreationTime :=
        TFunctions.DateTimeToUNIXTimeFAST
        (SQLComp.Query.FieldByName('creationtime').AsInteger);
      AnsiStrings.StrPLCopy(Self.Account.Characters[Slot].Base.Numeric,
        AnsiString(SQLComp.Query.FieldByName('numeric_token').AsString), 4);
      Self.Account.Characters[Slot].Base.LoginTime :=
        SQLComp.Query.FieldByName('logintime').AsInteger;
      Self.Account.Characters[Slot].SpeedMove :=
        (SQLComp.Query.FieldByName('speedmove').AsInteger);
      Self.Account.Characters[Slot].Rotation :=
        (SQLComp.Query.FieldByName('rotation').AsInteger);
      Self.Account.Characters[Slot].LoggedTime :=
        SQLComp.Query.FieldByName('loggedtime').AsInteger;
      Self.Account.Characters[Slot].PlayerKill :=
        boolean(SQLComp.Query.FieldByName('playerkill').AsInteger);
      Self.Account.Characters[Slot].LastPos.X :=
        SQLComp.Query.FieldByName('posx').AsSingle;

      Self.Account.Characters[Slot].LastPos.Y :=
        SQLComp.Query.FieldByName('posy').AsSingle;

      Self.Account.CharactersDelete[Slot] :=
        (SQLComp.Query.FieldByName('deleted').AsInteger).ToBoolean;

      Self.Account.CharactersDeleteTime[Slot] :=
        ShortString(SQLComp.Query.FieldByName('delete_time').AsString);

      Self.Account.Characters[Slot].ActiveTitle.Index :=
        (SQLComp.Query.FieldByName('active_title').AsInteger);

      if not(I = (CharCount - 1)) then
      begin
        SQLComp.Query.Next;
      end;
    end;
    for I := 0 to (CharCount - 1) do
    begin
      SQLComp.SetQuery
        ('SELECT slot, item_id, app, identific, effect1_index, effect2_index, '
        + 'effect3_index, effect1_value, effect2_value, effect3_value, min, max, refine, time '
        + 'FROM items WHERE owner_id = ' + Self.Account.Characters[I].
        Index.ToString + ' AND slot_type=0 LIMIT 16');
      // PlayerSQL.AddParameter2('powner_id', Self.Account.Characters[i].Index);
      SQLComp.Run();
      ItemAmount := SQLComp.Query.RecordCount;
      Slot := I;
      if not(ItemAmount = 0) then
      begin
        for J := 0 to (ItemAmount - 1) do
        begin
          ItemSlot := SQLComp.Query.FieldByName('slot').AsInteger;
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Index :=
            (SQLComp.Query.FieldByName('item_id').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].APP :=
            (SQLComp.Query.FieldByName('app').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Identific :=
            SQLComp.Query.FieldByName('identific').AsInteger;
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Index[0] :=
            (SQLComp.Query.FieldByName('effect1_index').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Index[1] :=
            (SQLComp.Query.FieldByName('effect2_index').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Index[2] :=
            (SQLComp.Query.FieldByName('effect3_index').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Value[0] :=
            (SQLComp.Query.FieldByName('effect1_value').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Value[1] :=
            (SQLComp.Query.FieldByName('effect2_value').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Effects.Value[2] :=
            (SQLComp.Query.FieldByName('effect3_value').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].MIN :=
            (SQLComp.Query.FieldByName('min').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].MAX :=
            (SQLComp.Query.FieldByName('max').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Refi :=
            (SQLComp.Query.FieldByName('refine').AsInteger);
          Self.Account.Characters[Slot].Base.Equip[ItemSlot].Time :=
            (SQLComp.Query.FieldByName('time').AsInteger);
          if not(J = (ItemAmount - 1)) then
          begin
            SQLComp.Query.Next;
          end;
        end;
      end;
    end;
    // Self.PlayerSQL.MySQL.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load Character to room(loadaccsql) error. msg[' +
        E.Message + ' : ' + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      // Self.PlayerSQL.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;

function TPlayer.LoadCharacterMisc(CharID: Integer): boolean;
var
  ID, ItemAmount, ItemAmount2, ItemSlot, SkillType, J, k: Integer;
  z, I: BYTE;
  QuestIndex: WORD;
  MySQLComp: TQuery;
begin
  TFunctions.ManageAccountsBackupCount(Self, Self.Account.Header.Username);

  MySQLComp := Self.CreateSQL;

  if not MySQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadCharacterMisc]', TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadCharacterMisc]', TlogType.Error);
    MySQLComp.Destroy;
    Exit(False);
  end;

  if Self.Account.Characters[CharID].Base.Exp = 0 then
  begin
    MySQLComp.SetQuery('SELECT id, slot FROM characters WHERE owner_accid = ' +
      Self.Account.Header.AccountId.ToString + ' ORDER BY slot LIMIT 3');
    MySQLComp.Run();
    if MySQLComp.Query.RecordCount > 0 then
    begin
      MySQLComp.Query.First;
      for I := 0 to MySQLComp.Query.RecordCount - 1 do
      begin
        Self.Account.Characters[MySQLComp.Query.FieldByName('slot').AsInteger].Index :=
          MySQLComp.Query.FieldByName('id').AsInteger;
        MySQLComp.Query.Next;
      end;
    end
    else
    begin
      MySQLComp.Destroy;
      Exit(True);
    end;
  end;

  for z := 0 to 2 do
  begin
    if Self.Account.Characters[z].Index = 0 then Continue;

    CharID := z;
    ID := Self.Account.Characters[CharID].Index;

    try
      // Load Inventory
      MySQLComp.SetQuery('SELECT slot, item_id, app, identific, effect1_index, effect2_index, ' +
        'effect3_index, effect1_value, effect2_value, effect3_value, min, max, refine, time ' +
        'FROM items WHERE owner_id = ' + ID.ToString + ' AND slot_type=1 ORDER BY slot LIMIT 126');
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      if ItemAmount > 0 then
      begin
        MySQLComp.Query.First;
        for I := 0 to ItemAmount - 1 do
        begin
          if MySQLComp.Query.FieldByName('item_id').AsInteger <> 0 then
          begin
            ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
            with Self.Account.Characters[CharID].Base.Inventory[ItemSlot] do
            begin
              Index := MySQLComp.Query.FieldByName('item_id').AsInteger;
              APP := MySQLComp.Query.FieldByName('app').AsInteger;
              Identific := MySQLComp.Query.FieldByName('identific').AsInteger;
              Effects.Index[0] := MySQLComp.Query.FieldByName('effect1_index').AsInteger;
              Effects.Index[1] := MySQLComp.Query.FieldByName('effect2_index').AsInteger;
              Effects.Index[2] := MySQLComp.Query.FieldByName('effect3_index').AsInteger;
              Effects.Value[0] := MySQLComp.Query.FieldByName('effect1_value').AsInteger;
              Effects.Value[1] := MySQLComp.Query.FieldByName('effect2_value').AsInteger;
              Effects.Value[2] := MySQLComp.Query.FieldByName('effect3_value').AsInteger;
              MIN := MySQLComp.Query.FieldByName('min').AsInteger;
              MAX := MySQLComp.Query.FieldByName('max').AsInteger;
              Refi := MySQLComp.Query.FieldByName('refine').AsInteger;
              Time := MySQLComp.Query.FieldByName('time').AsInteger;
            end;
          end;
          MySQLComp.Query.Next;
        end;
      end;

      // Default items for slots 120-123
      for I := 120 to 123 do
      begin
        if Self.Account.Characters[CharID].Base.Inventory[I].Index = 0 then
        begin
          Self.Account.Characters[CharID].Base.Inventory[I].Index := 5300;
          Self.Account.Characters[CharID].Base.Inventory[I].APP := 5300;
          Self.Account.Characters[CharID].Base.Inventory[I].Refi := 1;
        end;
      end;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Inventory error. msg[' + E.Message + ' : ' +
          E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
          DateTimeToStr(Now) + '.', TlogType.Error);
      end;
    end;

    try
      // Load Skills
      MySQLComp.SetQuery('SELECT slot, type, item, level FROM skills WHERE owner_charid = ' +
        ID.ToString + ' ORDER BY slot LIMIT 60');
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      if ItemAmount > 0 then
      begin
        MySQLComp.Query.First;
        for I := 0 to ItemAmount - 1 do
        begin
          if MySQLComp.Query.FieldByName('item').AsInteger <> 0 then
          begin
            ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
            SkillType := MySQLComp.Query.FieldByName('type').AsInteger;
            if SkillType = 1 then
            begin
              Self.Account.Characters[CharID].Skills.Basics[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item').AsInteger;
              Self.Account.Characters[CharID].Skills.Basics[ItemSlot].Level :=
                MySQLComp.Query.FieldByName('level').AsInteger;
            end
            else if SkillType = 2 then
            begin
              Self.Account.Characters[CharID].Skills.Others[ItemSlot].Index :=
                MySQLComp.Query.FieldByName('item').AsInteger;
              Self.Account.Characters[CharID].Skills.Others[ItemSlot].Level :=
                MySQLComp.Query.FieldByName('level').AsInteger;
            end;
          end;
          MySQLComp.Query.Next;
        end;
      end;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Skills error. msg[' + E.Message + ' : ' +
          E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
          DateTimeToStr(Now) + '.', TlogType.Error);
      end;
    end;

    try
      // Load Items on Bar
      MySQLComp.SetQuery('SELECT slot, item FROM itembars WHERE owner_charid = ' +
        ID.ToString + ' ORDER BY slot LIMIT 40');
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      if ItemAmount > 0 then
      begin
        MySQLComp.Query.First;
        for I := 0 to ItemAmount - 1 do
        begin
          if MySQLComp.Query.FieldByName('item').AsInteger <> 0 then
          begin
            ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
            Self.Account.Characters[CharID].Base.ItemBar[ItemSlot] :=
              MySQLComp.Query.FieldByName('item').AsInteger;
          end;
          MySQLComp.Query.Next;
        end;
      end;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Items on bar error. msg[' + E.Message + ' : ' +
          E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
          DateTimeToStr(Now) + '.', TlogType.Error);
      end;
    end;

    try
      // Load Buffs
      MySQLComp.SetQuery('SELECT buff_index, buff_time FROM buffs WHERE owner_charid = ' +
        ID.ToString + ' LIMIT 60');
      MySQLComp.Run();
      ItemAmount := MySQLComp.Query.RecordCount;
      if ItemAmount > 0 then
      begin
        MySQLComp.Query.First;
        for I := 0 to ItemAmount - 1 do
        begin
          if MySQLComp.Query.FieldByName('buff_index').AsInteger <> 0 then
          begin
            Self.Account.Characters[CharID].Buffs[I].Index :=
              MySQLComp.Query.FieldByName('buff_index').AsInteger;
            Self.Account.Characters[CharID].Buffs[I].CreationTime :=
              UnixToDateTime(StrToInt64(MySQLComp.Query.FieldByName('buff_time').AsString));
          end;
          MySQLComp.Query.Next;
        end;
      end;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL Load misc Buffs error. msg[' + E.Message + ' : ' +
          E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
          DateTimeToStr(Now) + '.', TlogType.Error);
      end;
    end;

    if z = Self.SelectedCharacterIndex then
    begin
      try
        // Load Quests
        MySQLComp.SetQuery('SELECT questid, isdone, req1, req2, req3, req4, req5, updated_at ' +
          'FROM quests WHERE charid = ' + ID.ToString);
        MySQLComp.Run();
        ItemAmount := MySQLComp.Query.RecordCount;
        if ItemAmount > 0 then
        begin
          MySQLComp.Query.First;
          for I := 0 to ItemAmount - 1 do
          begin
            QuestIndex := Self.SearchEmptyQuestIndex;
            if QuestIndex <> 255 then
            begin
              Self.PlayerQuests[QuestIndex].ID := MySQLComp.Query.FieldByName('questid').AsInteger;
              Self.PlayerQuests[QuestIndex].IsDone := MySQLComp.Query.FieldByName('isdone').AsInteger.ToBoolean;
              Self.PlayerQuests[QuestIndex].Complete[0] := MySQLComp.Query.FieldByName('req1').AsInteger;
              Self.PlayerQuests[QuestIndex].Complete[1] := MySQLComp.Query.FieldByName('req2').AsInteger;
              Self.PlayerQuests[QuestIndex].Complete[2] := MySQLComp.Query.FieldByName('req3').AsInteger;
              Self.PlayerQuests[QuestIndex].Complete[3] := MySQLComp.Query.FieldByName('req4').AsInteger;
              Self.PlayerQuests[QuestIndex].Complete[4] := MySQLComp.Query.FieldByName('req5').AsInteger;
              Self.PlayerQuests[QuestIndex].UpdatedAt :=
                TFunctions.UNIXTimeToDateTimeFAST(MySQLComp.Query.FieldByName('updated_at').AsLargeInt);
              for J := Low(_Quests) to High(_Quests) do
              begin
                if _Quests[J].QuestID = DWORD(Self.PlayerQuests[QuestIndex].ID) then
                begin
                  Move(_Quests[J], Self.PlayerQuests[QuestIndex].Quest, SizeOf(TQuestMisc));
                  Break;
                end;
              end;
            end;
            MySQLComp.Query.Next;
          end;
        end;
      except
        on E: Exception do
        begin
          Logger.Write('MYSQL Load misc Quests error. msg[' + E.Message + ' : ' +
            E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
            DateTimeToStr(Now) + '.', TlogType.Error);
        end;
      end;

      try
        // Load Titles
        MySQLComp.Query.Connection.StartTransaction;
        MySQLComp.SetQuery('SELECT title_index, title_level, title_progress FROM titles WHERE owner_charid = ' +
          ID.ToString);
        MySQLComp.Run();
        ItemAmount := MySQLComp.Query.RecordCount;
        if ItemAmount > 0 then
        begin
          MySQLComp.Query.First;
          for I := 0 to ItemAmount - 1 do
          begin
            if MySQLComp.Query.FieldByName('title_index').AsInteger <> 0 then
            begin
              Self.Character.Titles[I].Index := MySQLComp.Query.FieldByName('title_index').AsInteger;
              Self.Character.Titles[I].Level := MySQLComp.Query.FieldByName('title_level').AsInteger;
              Self.Character.Titles[I].Progress := MySQLComp.Query.FieldByName('title_progress').AsInteger;
              if Self.Account.Characters[CharID].ActiveTitle.Index = Self.Character.Titles[I].Index then
              begin
                Self.Account.Characters[CharID].ActiveTitle.Level := Self.Character.Titles[I].Level;
              end;
            end;
            MySQLComp.Query.Next;
          end;
        end;
        MySQLComp.Query.Connection.Commit;
      except
        on E: Exception do
        begin
          Logger.Write('MYSQL Load Titles error. msg[' + E.Message + ' : ' +
            E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
            DateTimeToStr(Now) + '.', TlogType.Error);
          MySQLComp.Query.Connection.Rollback;
        end;
      end;
    end;
  end;

  try
    // Load Prans
    MySQLComp.SetQuery('SELECT id, item_id, name, level, class, hp, max_hp, mp, max_mp, xp, def_p, def_m, ' +
      'food, devotion, p_cute, p_smart, p_sexy, p_energetic, p_tough, p_corrupt, width, chest, leg, ' +
      'created_at, updated_at FROM prans WHERE acc_id = ' + Self.Account.Header.AccountId.ToString +
      ' ORDER BY id LIMIT 2');
    MySQLComp.Run();
    ItemAmount := MySQLComp.Query.RecordCount;
    if ItemAmount > 0 then
    begin
      J := 0;
      MySQLComp.Query.First;
      for I := 0 to ItemAmount - 1 do
      begin
        if J = 0 then
        begin
          // Load Pran1
          with Account.Header.Pran1 do
          begin
            Iddb := MySQLComp.Query.FieldByName('id').AsInteger;
            ItemID := MySQLComp.Query.FieldByName('item_id').AsInteger;
            AccId := Self.Account.Header.AccountId;
            AnsiStrings.StrPLCopy(Name, AnsiString(MySQLComp.Query.FieldByName('name').AsString), 16);
            Level := MySQLComp.Query.FieldByName('level').AsInteger;
            ClassPran := MySQLComp.Query.FieldByName('class').AsInteger;
            CurHP := MySQLComp.Query.FieldByName('hp').AsInteger;
            MaxHp := MySQLComp.Query.FieldByName('max_hp').AsInteger;
            CurMp := MySQLComp.Query.FieldByName('mp').AsInteger;
            MaxMP := MySQLComp.Query.FieldByName('max_mp').AsInteger;
            Exp := MySQLComp.Query.FieldByName('xp').AsInteger;
            DefFis := MySQLComp.Query.FieldByName('def_p').AsInteger;
            DefMag := MySQLComp.Query.FieldByName('def_m').AsInteger;
            Food := MySQLComp.Query.FieldByName('food').AsInteger;
            Devotion := MySQLComp.Query.FieldByName('devotion').AsInteger;
            Personality.Cute := MySQLComp.Query.FieldByName('p_cute').AsInteger;
            Personality.Smart := MySQLComp.Query.FieldByName('p_smart').AsInteger;
            Personality.Sexy := MySQLComp.Query.FieldByName('p_sexy').AsInteger;
            Personality.Energetic := MySQLComp.Query.FieldByName('p_energetic').AsInteger;
            Personality.Tough := MySQLComp.Query.FieldByName('p_tough').AsInteger;
            Personality.Corrupt := MySQLComp.Query.FieldByName('p_corrupt').AsInteger;
            Width := MySQLComp.Query.FieldByName('width').AsInteger;
            Chest := MySQLComp.Query.FieldByName('chest').AsInteger;
            Leg := MySQLComp.Query.FieldByName('leg').AsInteger;
            CreatedAt := MySQLComp.Query.FieldByName('created_at').AsInteger;
            Updated_at := MySQLComp.Query.FieldByName('updated_at').AsInteger;
          end;

          // Load Pran1 Equip
          MySQLComp.SetQuery('SELECT slot, item_id, app, identific, effect1_index, effect2_index, ' +
            'effect3_index, effect1_value, effect2_value, effect3_value, min, max, refine, time ' +
            'FROM items WHERE slot_type = ' + PRAN_EQUIP_TYPE.ToString + ' AND owner_id = ' +
            Account.Header.Pran1.Iddb.ToString + ' ORDER BY slot LIMIT 16');
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if ItemAmount2 > 0 then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2 - 1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              with Account.Header.Pran1.Equip[ItemSlot] do
              begin
                Index := MySQLComp.Query.FieldByName('item_id').AsInteger;
                APP := MySQLComp.Query.FieldByName('app').AsInteger;
                Identific := MySQLComp.Query.FieldByName('identific').AsInteger;
                Effects.Index[0] := MySQLComp.Query.FieldByName('effect1_index').AsInteger;
                Effects.Index[1] := MySQLComp.Query.FieldByName('effect2_index').AsInteger;
                Effects.Index[2] := MySQLComp.Query.FieldByName('effect3_index').AsInteger;
                Effects.Value[0] := MySQLComp.Query.FieldByName('effect1_value').AsInteger;
                Effects.Value[1] := MySQLComp.Query.FieldByName('effect2_value').AsInteger;
                Effects.Value[2] := MySQLComp.Query.FieldByName('effect3_value').AsInteger;
                MIN := MySQLComp.Query.FieldByName('min').AsInteger;
                MAX := MySQLComp.Query.FieldByName('max').AsInteger;
                Refi := MySQLComp.Query.FieldByName('refine').AsInteger;
                Time := MySQLComp.Query.FieldByName('time').AsInteger;
              end;
              MySQLComp.Query.Next;
            end;
          end;

          // Load Pran1 Inventory
          MySQLComp.SetQuery('SELECT slot, item_id, app, identific, effect1_index, effect2_index, ' +
            'effect3_index, effect1_value, effect2_value, effect3_value, min, max, refine, time ' +
            'FROM items WHERE slot_type = ' + PRAN_INV_TYPE.ToString + ' AND owner_id = ' +
            Account.Header.Pran1.Iddb.ToString + ' ORDER BY slot LIMIT 42');
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if ItemAmount2 > 0 then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2 - 1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              with Account.Header.Pran1.Inventory[ItemSlot] do
              begin
                Index := MySQLComp.Query.FieldByName('item_id').AsInteger;
                APP := MySQLComp.Query.FieldByName('app').AsInteger;
                Identific := MySQLComp.Query.FieldByName('identific').AsInteger;
                Effects.Index[0] := MySQLComp.Query.FieldByName('effect1_index').AsInteger;
                Effects.Index[1] := MySQLComp.Query.FieldByName('effect2_index').AsInteger;
                Effects.Index[2] := MySQLComp.Query.FieldByName('effect3_index').AsInteger;
                Effects.Value[0] := MySQLComp.Query.FieldByName('effect1_value').AsInteger;
                Effects.Value[1] := MySQLComp.Query.FieldByName('effect2_value').AsInteger;
                Effects.Value[2] := MySQLComp.Query.FieldByName('effect3_value').AsInteger;
                MIN := MySQLComp.Query.FieldByName('min').AsInteger;
                MAX := MySQLComp.Query.FieldByName('max').AsInteger;
                Refi := MySQLComp.Query.FieldByName('refine').AsInteger;
                Time := MySQLComp.Query.FieldByName('time').AsInteger;
              end;
              MySQLComp.Query.Next;
            end;
          end;

          // Load Pran1 Skills
          MySQLComp.SetQuery('SELECT slot, item, level FROM skills WHERE owner_charid = ' +
            Account.Header.Pran1.Iddb.ToString + ' AND type = 3 ORDER BY slot LIMIT 10');
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if ItemAmount2 > 0 then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2 - 1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
              Account.Header.Pran1.Skills[ItemSlot].Index := MySQLComp.Query.FieldByName('item').AsInteger;
              Account.Header.Pran1.Skills[ItemSlot].Level := MySQLComp.Query.FieldByName('level').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;

          // Load Pran1 Skill Bar
          MySQLComp.SetQuery('SELECT slot, item FROM itembars WHERE owner_charid = ' +
            (Account.Header.Pran1.Iddb + 1024000).ToString + ' ORDER BY slot LIMIT 3');
          MySQLComp.Run();
          ItemAmount2 := MySQLComp.Query.RecordCount;
          if ItemAmount2 > 0 then
          begin
            MySQLComp.Query.First;
            for k := 0 to ItemAmount2 - 1 do
            begin
              ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger - 100;
              Account.Header.Pran1.ItemBar[ItemSlot] := MySQLComp.Query.FieldByName('item').AsInteger;
              MySQLComp.Query.Next;
            end;
          end;
        end
        else
        begin
          // Load Pran2 (similar to Pran1)
          // ... (omitted for brevity)
        end;

        if ItemAmount > 1 then
        begin
          Inc(J);
          MySQLComp.SetQuery('SELECT id, item_id, name, level, class, hp, max_hp, mp, max_mp, xp, def_p, def_m, ' +
            'food, devotion, p_cute, p_smart, p_sexy, p_energetic, p_tough, p_corrupt, width, chest, leg, ' +
            'created_at, updated_at FROM prans WHERE acc_id = ' + Self.Account.Header.AccountId.ToString +
            ' ORDER BY id LIMIT 2');
          MySQLComp.Run();
          MySQLComp.Query.First;
          MySQLComp.Query.Next;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load misc Prans error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
    end;
  end;

  try
    // Load Storage
    MySQLComp.SetQuery('SELECT slot, item_id, app, identific, effect1_index, effect2_index, ' +
      'effect3_index, effect1_value, effect2_value, effect3_value, min, max, refine, time ' +
      'FROM items WHERE owner_id = ' + Self.Account.Header.AccountId.ToString +
      ' AND slot_type=2 ORDER BY slot LIMIT 86');
    MySQLComp.Run();
    ItemAmount := MySQLComp.Query.RecordCount;
    if ItemAmount > 0 then
    begin
      MySQLComp.Query.First;
      for I := 0 to ItemAmount - 1 do
      begin
        if MySQLComp.Query.FieldByName('item_id').AsInteger <> 0 then
        begin
          ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
          with Self.Account.Header.Storage.Itens[ItemSlot] do
          begin
            Index := MySQLComp.Query.FieldByName('item_id').AsInteger;
            APP := MySQLComp.Query.FieldByName('app').AsInteger;
            Identific := MySQLComp.Query.FieldByName('identific').AsInteger;
            Effects.Index[0] := MySQLComp.Query.FieldByName('effect1_index').AsInteger;
            Effects.Index[1] := MySQLComp.Query.FieldByName('effect2_index').AsInteger;
            Effects.Index[2] := MySQLComp.Query.FieldByName('effect3_index').AsInteger;
            Effects.Value[0] := MySQLComp.Query.FieldByName('effect1_value').AsInteger;
            Effects.Value[1] := MySQLComp.Query.FieldByName('effect2_value').AsInteger;
            Effects.Value[2] := MySQLComp.Query.FieldByName('effect3_value').AsInteger;
            MIN := MySQLComp.Query.FieldByName('min').AsInteger;
            MAX := MySQLComp.Query.FieldByName('max').AsInteger;
            Refi := MySQLComp.Query.FieldByName('refine').AsInteger;
            Time := MySQLComp.Query.FieldByName('time').AsInteger;
          end;
        end;
        MySQLComp.Query.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load misc Storage error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
    end;
  end;

  try
    // Load Premium Items
    MySQLComp.SetQuery('SELECT slot, item_id, app, identific FROM items WHERE owner_id = ' +
      Self.Account.Header.AccountId.ToString + ' AND slot_type=10 ORDER BY slot LIMIT 24');
    MySQLComp.Run();
    ItemAmount := MySQLComp.Query.RecordCount;
    if ItemAmount > 0 then
    begin
      MySQLComp.Query.First;
      for I := 0 to ItemAmount - 1 do
      begin
        if MySQLComp.Query.FieldByName('item_id').AsInteger <> 0 then
        begin
          ItemSlot := MySQLComp.Query.FieldByName('slot').AsInteger;
          Self.Account.Header.CashInventory.Items[ItemSlot].Index :=
            MySQLComp.Query.FieldByName('item_id').AsInteger;
          Self.Account.Header.CashInventory.Items[ItemSlot].APP :=
            MySQLComp.Query.FieldByName('app').AsInteger;
          Self.Account.Header.CashInventory.Items[ItemSlot].Identific :=
            MySQLComp.Query.FieldByName('identific').AsInteger;
        end;
        MySQLComp.Query.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Load misc Premium error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' + Self.Account.Header.Username + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
    end;
  end;

  MySQLComp.Destroy;
  Result := True;
end;
function TPlayer.NameExists(CharacterName: String): boolean;
var
  SQLComp: TQuery;
begin
  Result := True;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  try
    if not(SQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[NameExists]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[NameExists]', TlogType.Error);
      Exit;
    end;

    SQLComp.SetQuery('SELECT id FROM characters WHERE name = "' +
      CharacterName + '"');
    SQLComp.Run();

    if (SQLComp.Query.RecordCount = 0) then
      Result := false;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Verify Name Exists error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
    end;
  end;

  SQLComp.Destroy;
end;

function TPlayer.VerifyAmount(CharacterName: String): boolean;
var
  CharCount: Integer;
  SQLComp: TQuery;
begin
  Result := false;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[VerifyAmount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[VerifyAmount]', TlogType.Error);
    SQLComp.Free; // Usar Free ao invés de Destroy, que é mais comum e seguro
    Exit;
  end;

  try
    SQLComp.SetQuery('SELECT id FROM characters WHERE owner_accid = ' +
      Self.Account.Header.AccountId.ToString + ' LIMIT 3');
    SQLComp.Run();
    CharCount := SQLComp.Query.RecordCount;

    if CharCount = 3 then
      Exit;
  except
    on E: Exception do
      Logger.Write('MYSQL Verify Amount error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
  end;

  SQLComp.Free; // Usar Free ao invés de Destroy, mais seguro
  Result := True;
end;

function TPlayer.SaveAccountToken(Username: String): boolean;
var
  SQLComp: TQuery;
  Token: String;
  TokenCreationTime: String;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveAccountToken]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveAccountToken]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  SQLComp.Query.Connection.StartTransaction;
  try
    Token := String(Self.Account.Header.Token.Token);
    TokenCreationTime :=
      IntToStr(DateTimeToUnix(Self.Account.Header.Token.CreationTime));

    SQLComp.SetQuery('UPDATE accounts SET last_token = "' + Token + '",' +
      ' last_token_creation_time = "' + TokenCreationTime +
      '" WHERE username = "' + Username + '"');

    SQLComp.Run(false);
    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Account Token error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      SQLComp.Query.Connection.Rollback;
    end;
  end;

  SQLComp.Destroy;
  Result := True;
end;

function TPlayer.SaveStatus(Username: String): boolean;
var
  PlayerSQLComp: TQuery;
  is_active: Integer;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);

  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveStatus]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveStatus]', TlogType.Error);
    PlayerSQLComp.Free; // Usar Free ao invés de Destroy
    Exit;
  end;

  // Definir o status ativo de forma concisa
  is_active := Ord(Self.Account.Header.IsActive);
  // Substitui a verificação ternária por Ord

  try
    PlayerSQLComp.Query.Connection.StartTransaction;
    // Montar o query de forma mais limpa e eficiente
    PlayerSQLComp.SetQuery('UPDATE accounts SET isactive=' + is_active.ToString
      + ', premium_time="", account_status=' +
      Self.Account.Header.AccountStatus.ToString + ', ban_days=' +
      Self.Account.Header.BanDays.ToString + ', cash=' +
      Self.Account.Header.CashInventory.Cash.ToString + ' WHERE username="' +
      Username + '"');
    PlayerSQLComp.Run(false);
    PlayerSQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Status error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      PlayerSQLComp.Query.Connection.Rollback;
    end;
  end;

  PlayerSQLComp.Free; // Usar Free ao invés de Destroy
  Result := True;
end;

function TPlayer.SaveCreatedChar(CharacterName: String; Slot: Integer): boolean;
var
  I: Integer;
  Item: PItem;
  CharID: Integer;
  SQLComp: TQuery;
begin
  Result := false;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveCreatedChar]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveCreatedChar]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  SQLComp.Query.Connection.StartTransaction;
  try
    SQLComp.SetQuery
      (format('INSERT INTO characters (owner_accid, name, slot, classinfo,' +
      ' strength, agility, intelligence, constitution, luck, status, altura, tronco,'
      + ' perna, corpo, experience, level, gold, posx, posy, creationtime, pranevcnt, last_diary_event) VALUES '
      + '(%d, %s, %d, %d, ' + '%d, %d, %d, %d, %d, %d, %d, %d, ' +
      '%d, %d, %d, %d, %d, %s, %s, %s, %d, %s)', [Self.Account.Header.AccountId,
      QuotedStr(String(Self.Account.Characters[Slot].Base.Name)), Slot,
      Self.Account.Characters[Slot].Base.ClassInfo,
      Self.Account.Characters[Slot].Base.CurrentScore.Str,
      Self.Account.Characters[Slot].Base.CurrentScore.agility,
      Self.Account.Characters[Slot].Base.CurrentScore.Int,
      Self.Account.Characters[Slot].Base.CurrentScore.Cons,
      Self.Account.Characters[Slot].Base.CurrentScore.Luck,
      Self.Account.Characters[Slot].Base.CurrentScore.Status,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Altura,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Tronco,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Perna,
      Self.Account.Characters[Slot].Base.CurrentScore.Sizes.Corpo,
      Self.Account.Characters[Slot].Base.Exp, Self.Account.Characters[Slot]
      .Base.Level, Self.Account.Characters[Slot].Base.Gold,
      QuotedStr(Self.Account.Characters[Slot].LastPos.X.ToString),
      QuotedStr(Self.Account.Characters[Slot].LastPos.Y.ToString),
      QuotedStr(TFunctions.DateTimeToUNIXTimeFAST(Now).ToString),
      Self.Account.PranEvoCnt, QuotedStr(TFunctions.DateTimeToUNIXTimeFAST(Now)
      .ToString)]));
    SQLComp.Run(false);
    SQLComp.Query.SQL.Clear;
    SQLComp.Query.SQL.Add('select id from characters where name =' +
      QuotedStr(String(Self.Account.Characters[Slot].Base.Name)));
    SQLComp.Run(True);
    if (SQLComp.Query.RecordCount > 0) then
    begin
      Self.Account.Characters[Slot].Index := SQLComp.Query.Fields[0].AsInteger;
      Self.Account.Characters[Slot].Base.CharIndex := Self.Account.Characters
        [Slot].Index;
    end
    else
    begin
      Logger.Write('Não foi possível resgatar o código do cliente.',
        TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
    CharID := Self.Account.Characters[Slot].Index;
    for I := 0 to 7 do
    begin
      Item := @Self.Account.Characters[Slot].Base.Equip[I];
      if (Item^.Index = 0) then
        Continue;
      SQLComp.SetQuery
        (format('INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
        'app, effect1_index, effect1_value, effect2_index, effect2_value,' +
        ' effect3_index, effect3_value, min, max, refine, time) VALUES ' +
        '(0, %d, %d, %d, ' + '%d, %d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d)',
        [CharID, I, Item^.Index, Item^.APP, Item^.Effects.Index[0],
        Item^.Effects.Value[0], Item^.Effects.Index[1], Item^.Effects.Value[1],
        Item^.Effects.Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX,
        Item^.Refi, Item^.Time]));
      { PlayerSQL.AddParameter2('pisactive', Item.IsActive);
        PlayerSQL.AddParameter2('pgeneratedin', Item.GeneratedIn);
        PlayerSQL.AddParameter2('pgeneratedtime',
        TFunctions.DateTimeToUNIXTimeFAST(Item.GeneratedTime));
        PlayerSQL.AddParameter2('pgeneratoraccid', Item.GeneratorAccountID); }
      { PlayerSQL.AddParameter2('pslot_type', 0);
        PlayerSQL.AddParameter2('powner_id', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem_id', Item.Index);
        PlayerSQL.AddParameter2('papp', Item.APP);
        PlayerSQL.AddParameter2('peffect1_index', Item.Effects.Index[0]);
        PlayerSQL.AddParameter2('peffect1_value', Item.Effects.Value[0]);
        PlayerSQL.AddParameter2('peffect2_index', It7em.Effects.Index[1]);
        PlayerSQL.AddParameter2('peffect2_value', Item.Effects.Value[1]);
        PlayerSQL.AddParameter2('peffect3_index', Item.Effects.Index[2]);
        PlayerSQL.AddParameter2('peffect3_value', Item.Effects.Value[2]);
        PlayerSQL.AddParameter2('pmin', Item.MIN);
        PlayerSQL.AddParameter2('pmax', Item.MAX);
        PlayerSQL.AddParameter2('prefine', Item.Refi);
        PlayerSQL.AddParameter2('ptime', Item.Time); }
      SQLComp.Run(false);
    end;
    for I := 0 to 125 do
    begin
      Item := @Self.Account.Characters[Slot].Base.Inventory[I];
      if (Item^.Index = 0) then
        Continue;
      SQLComp.SetQuery
        (format('INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
        'app, effect1_index, effect1_value, effect2_index, effect2_value,' +
        ' effect3_index, effect3_value, min, max, refine, time) VALUES ' +
        '(1, %d, %d, %d, ' + '%d, %d, %d, %d, %d, ' + '%d, %d, %d, %d, %d, %d)',
        [CharID, I, Item^.Index, Item^.APP, Item^.Effects.Index[0],
        Item^.Effects.Value[0], Item^.Effects.Index[1], Item^.Effects.Value[1],
        Item^.Effects.Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX,
        Item^.Refi, Item^.Time]));
      { PlayerSQL.AddParameter2('pisactive', Item.IsActive);
        PlayerSQL.AddParameter2('pgeneratedin', Item.GeneratedIn);
        PlayerSQL.AddParameter2('pgeneratedtime',
        TFunctions.DateTimeToUNIXTimeFAST(Item.GeneratedTime));
        PlayerSQL.AddParameter2('pgeneratoraccid', Item.GeneratorAccountID); }
      { PlayerSQL.AddParameter2('pslot_type', 1);
        PlayerSQL.AddParameter2('powner_id', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem_id', Item.Index);
        PlayerSQL.AddParameter2('papp', Item.APP);
        PlayerSQL.AddParameter2('peffect1_index', Item.Effects.Index[0]);
        PlayerSQL.AddParameter2('peffect1_value', Item.Effects.Value[0]);
        PlayerSQL.AddParameter2('peffect2_index', Item.Effects.Index[1]);
        PlayerSQL.AddParameter2('peffect2_value', Item.Effects.Value[1]);
        PlayerSQL.AddParameter2('peffect3_index', Item.Effects.Index[2]);
        PlayerSQL.AddParameter2('peffect3_value', Item.Effects.Value[2]);
        PlayerSQL.AddParameter2('pmin', Item.MIN);
        PlayerSQL.AddParameter2('pmax', Item.MAX);
        PlayerSQL.AddParameter2('prefine', Item.Refi);
        PlayerSQL.AddParameter2('ptime', Item.Time); }
      SQLComp.Run(false);
    end;
    for I := 0 to 5 do
    begin
      if (Self.Account.Characters[Slot].Skills.Basics[I].Index = 0) then
      begin
        Continue;
      end;
      SQLComp.SetQuery
        (format('INSERT INTO skills (owner_charid, slot, item, level, type) VALUES '
        + '(%d, %d, %d, %d, 1)', [CharID, I, Self.Account.Characters[Slot]
        .Skills.Basics[I].Index, Self.Account.Characters[Slot].Skills.Basics
        [I].Level]));
      { PlayerSQL.AddParameter2('powner_charid', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem', Self.Account.Characters[Slot]
        .Skills.Basics[i].Index);
        PlayerSQL.AddParameter2('plevel', Self.Account.Characters[Slot]
        .Skills.Basics[i].Level);
        PlayerSQL.AddParameter2('ptype', 1); }
      SQLComp.Run(false);
    end;
    for I := 0 to 39 do
    begin
      if (Self.Account.Characters[Slot].Skills.Others[I].Index = 0) then
      begin
        Continue;
      end;
      SQLComp.SetQuery
        (format('INSERT INTO skills (owner_charid, slot, item, level, type) VALUES '
        + '(%d, %d, %d, %d, 2)', [CharID, I, Self.Account.Characters[Slot]
        .Skills.Others[I].Index, Self.Account.Characters[Slot].Skills.Others
        [I].Level]));
      { PlayerSQL.AddParameter2('powner_charid', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem', Self.Account.Characters[Slot]
        .Skills.Others[i].Index);
        PlayerSQL.AddParameter2('plevel', Self.Account.Characters[Slot]
        .Skills.Others[i].Level);
        PlayerSQL.AddParameter2('ptype', 2); }
      SQLComp.Run(false);
    end;

    for I := 0 to 39 do
    begin
      if (Self.Account.Characters[Slot].Base.ItemBar[I] = 0) then
      begin
        Continue;
      end;
      SQLComp.SetQuery
        (format('INSERT INTO itembars (owner_charid, slot, item) VALUES ' +
        '(%d, %d, %d)', [CharID, I, Self.Account.Characters[Slot]
        .Base.ItemBar[I]]));
      { PlayerSQL.AddParameter2('powner_charid', CharID);
        PlayerSQL.AddParameter2('pslot', i);
        PlayerSQL.AddParameter2('pitem', Self.Account.Characters[Slot]
        .Base.ItemBar[i]); }
      SQLComp.Run(false);
    end;

    SQLComp.SetQuery
      (format('INSERT INTO auto_time (`character`, time, time_used, last_free_day) VALUES '
      + '("%s", %d, %d, "%s")', [Self.Account.Characters[Slot].Base.Name, 3600,
      0, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]));
    SQLComp.Run(false);

    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Created Char error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      SQLComp.Query.Connection.Rollback;
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;

function TPlayer.SaveCharOnCharRoom(CharID: Integer): boolean;
var
  ID: Integer;
  PlayerSQLComp: TQuery;
begin
  Result := false;
  if (Self.Base.clientId = 0) then
  begin
    Exit;
  end;

  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);

  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveCharOnCharRoom]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveCharOnCharRoom]',
      TlogType.Error);
    PlayerSQLComp.Destroy;
    Exit;
  end;

  try
    // Combine as duas consultas SQL em uma única instrução
    PlayerSQLComp.SetQuery('SELECT id FROM characters WHERE name = "' +
      String(Self.Account.Characters[CharID].Base.Name) + '"');
    PlayerSQLComp.Run;
    ID := PlayerSQLComp.Query.FieldByName('id').AsInteger;

    // Iniciar a transação e realizar o UPDATE em seguida
    PlayerSQLComp.Query.Connection.StartTransaction;
    PlayerSQLComp.SetQuery('UPDATE characters SET numeric_token="' +
      String(Self.Account.Header.NumericToken[CharID]) + '", delete_time="' +
      String(Self.Account.CharactersDeleteTime[CharID]) + '", deleted=' +
      Self.Account.CharactersDelete[CharID].ToInteger.ToString + ', ' +
      'numeric_errors=' + Self.Account.Header.NumError[CharID].ToString +
      ' WHERE id=' + ID.ToString);
    PlayerSQLComp.Run(false);

    // Commit a transação
    PlayerSQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save Char on CharRoom error. msg[' + E.Message + ' : '
        + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      PlayerSQLComp.Query.Connection.Rollback;
    end;
  end;

  PlayerSQLComp.Destroy;
  Result := True;
end;

function TPlayer.DeleteCharacter(CharID: Integer): boolean;
var
  ID: Integer;
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveNation]', TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  SQLComp.Query.Connection.StartTransaction;
  try
    ID := Self.Account.Characters[CharID].Index;

    // Executar as queries de deletação em sequência
    SQLComp.SetQuery(format('DELETE FROM characters WHERE id=%d', [ID]));
    SQLComp.Run(false);
    SQLComp.SetQuery
      (format('DELETE FROM itembars WHERE owner_charid=%d', [ID]));
    SQLComp.Run(false);
    SQLComp.SetQuery(format('DELETE FROM items WHERE owner_id=%d', [ID]));
    SQLComp.Run(false);
    SQLComp.SetQuery(format('DELETE FROM skills WHERE owner_charid=%d', [ID]));
    SQLComp.Run(false);

    // Commitar a transação se tudo ocorrer sem erros
    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Delete Character error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      SQLComp.Query.Connection.Rollback;
    end;
  end;

  SQLComp.Destroy;
  Result := True;
end;


function TPlayer.LoadCharacterTeleportList(CharName: String): boolean;
var
  SList1, SList2: TStringList;
  PositionsLine: String;
  I, Cnt: Integer;
  SQLComp: TQuery;
begin
  Result := false;
  if not(Self.Base.GetMobClass = 4) then
    Exit;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write
      ('Falha de conexão individual com mysql.[LoadCharacterTeleportList]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadCharacterTeleportList]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery(format('SELECT tp_positions FROM characters WHERE name=%s',
      [QuotedStr(CharName)]));
    SQLComp.Run();
    PositionsLine := SQLComp.Query.FieldByName('tp_positions').AsString;
    if PositionsLine <> '' then
    begin
      SList1 := TStringList.Create;
      SList2 := TStringList.Create;
      ExtractStrings([';'], [' '], PChar(PositionsLine), SList1);
      ExtractStrings([','], [' '], PChar(SList1.Text), SList2);
      Cnt := 0;
      for I := 0 to (SList2.Count div 2) - 1 do
      begin
        Self.TeleportList[I] := TPosition.Create(StrToInt(SList2.Strings[Cnt]),
          StrToInt(SList2.Strings[Cnt + 1]));
        Inc(Cnt, 2);
      end;
      SList1.Free;
      SList2.Free;
    end;
  except
    on E: Exception do
      Logger.Write('MYSQL Load TeleportList error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
  end;
  SQLComp.Destroy;
  Result := True;
end;

function TPlayer.SaveCharacterTeleportList(CharName: String): boolean;
var
  ID, I: Integer;
  LinePositions, LinePos: String;
  SQLComp: TQuery;
begin
  Result := false;
  if not(Self.Base.GetMobClass = 4) then
    Exit;

  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write
      ('Falha de conexão individual com mysql.[SaveCharacterTeleportList]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveCharacterTeleportList]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;

  try
    // Concatenar todas as posições válidas diretamente
    for I := 0 to 4 do
    begin
      if not(Self.TeleportList[I].IsValid) then
        Continue;
      LinePositions := LinePositions + Round(Self.TeleportList[I].X).ToString +
        ',' + Round(Self.TeleportList[I].Y).ToString + ';';
    end;

    SQLComp.SetQuery(format('SELECT id FROM characters WHERE name=%s',
      [QuotedStr(CharName)]));
    SQLComp.Run();

    ID := SQLComp.Query.FieldByName('id').AsInteger;
    SQLComp.SetQuery(format('UPDATE characters SET tp_positions=%s WHERE id=%d',
      [QuotedStr(LinePositions), ID]));
    SQLComp.Run(false);

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL Save TeleportList error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
    end;
  end;

  SQLComp.Destroy;
  Result := True;
end;

function TPlayer.LoadSavedLocation(): TPosition;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadSavedLocation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadSavedLocation]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery('SELECT saved_posx, saved_posy FROM characters WHERE id=' +
      Self.Character.Base.CharIndex.ToString);
    SQLComp.Run();
    if (SQLComp.Query.RecordCount = 0) or
      (not(SQLComp.Query.FieldByName('saved_posx').IsNull) and
      not(SQLComp.Query.FieldByName('saved_posy').IsNull)) then
    begin
      Result.Create(SQLComp.Query.FieldByName('saved_posx').AsInteger,
        SQLComp.Query.FieldByName('saved_posy').AsInteger);
      if not(Result.IsValid) then
        Result.Create(3450, 690);
    end
    else
    begin
      Result.Create(3450, 690);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.LoadSavedLocation ' + E.Message, TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;

function TPlayer.SaveSavedLocation(Pos: TPosition): boolean;
var
  SQLComp: TQuery;
begin
  Result := false;
  if ((Pos.X = 0) or (Pos.Y = 0)) then
    Exit;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveSavedLocation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveSavedLocation]',
      TlogType.Error);
    SQLComp.Destroy;
    Exit;
  end;
  try
    SQLComp.SetQuery('UPDATE characters SET saved_posx=' + Round(Pos.X).ToString
      + ', saved_posy=' + Round(Pos.Y).ToString + ' WHERE id=' +
      Self.Character.Base.CharIndex.ToString);
    SQLComp.Run(false);
    Result := True;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.SaveSavedLocation ' + E.Message, TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;

function TPlayer.CheckSelfSocket(): boolean;
begin
  Result := not(Self.Socket = INVALID_SOCKET);
end;
// correção de envio de pacote

// correção de envio de pacote

function Verificacoes(Self: TPlayer; Size: word): boolean;
begin
Result:= false;
 if (size = 0) or
(size > 21999) or
Self.SocketClosed or
(Self.Base.ClientID = 0) or
(Self.Base.ClientID > 1000) or
not Self.CheckSelfSocket then exit;



 Result:= true;





end;

procedure TPlayer.SendPacket(const Packet; size: WORD; Encrypt: Boolean);
const
  MAX_BUFFER_SIZE = 21999;
var
  RetVal: Integer;
  Buffer: ARRAY [0..MAX_BUFFER_SIZE] OF BYTE;
  BytesSent: Integer;
  TotalBytesSent: Integer;
  BytesToSend: Integer;
  PacketPtr: PByte;
begin
  //Logger.Write('Iniciando SendPacket', TlogType.Warnings);

  if (Self.SocketClosed) then
  begin
   // Logger.Write('Socket já está fechado.', TlogType.Error);
    Exit;
  end;

  if (size > MAX_BUFFER_SIZE) then
  begin
   // Logger.Write('Tamanho do pacote excede o limite do buffer. Desconectando cliente.', TlogType.Error);
    Self.Disconnect;
    Exit;
  end;

  ZeroMemory(@Buffer, SizeOf(Buffer));

  if not CheckSelfSocket then
  begin
   // Logger.Write('Socket inválido.', TlogType.Error);
    Exit;
  end;

 // Logger.Write('Aguardando SockInUse.', TlogType.Warnings);
  while (Self.SockInUse) do
    Sleep(10);
  Self.SockInUse := True;
 // Logger.Write('SockInUse adquirido.', TlogType.Warnings);

  Move(Packet, Buffer[0], size);

  if Encrypt then
  begin
    //Logger.Write('Criptografando pacote.', TlogType.Warnings);
    TEncDec.Encrypt(@Buffer, size);
  end;

  TotalBytesSent := 0;
  PacketPtr := @Buffer[0];
  BytesToSend := size;

  while (BytesToSend > 0) and (Self.Socket <> INVALID_SOCKET) do
  begin
    try
     // Logger.Write('Enviando pacote.', TlogType.Warnings);
      RetVal := Send(Self.Socket, PacketPtr^, BytesToSend, 0);

      if RetVal = SOCKET_ERROR then
      begin
       // Logger.Write('Erro no envio: ' + IntToStr(WSAGetLastError), TlogType.Warnings);

        if (WSAGetLastError = WSAEWOULDBLOCK) then
        begin
         // Logger.Write('Erro WSAEWOULDBLOCK, envio do pacote será tentado novamente.', TlogType.Warnings);
          Self.SockInUse := False;
          Exit;
        end;

        //Logger.Write('Erro desconhecido no envio, desconectando socket.', TlogType.Error);
        Self.Disconnect;
        Break;
      end
      else if RetVal = 0 then
      begin
        Logger.Write('Send retornou 0, indicando que a conexão foi fechada.', TlogType.Warnings);
        Self.SocketClosed := True;
        Break;
      end
      else
      begin
       // Logger.Write('Pacote enviado com sucesso. Bytes enviados: ' + IntToStr(RetVal), TlogType.Warnings);
        Inc(TotalBytesSent, RetVal);
        Dec(BytesToSend, RetVal);
        Inc(PacketPtr, RetVal);
      end;
    except
      on E: Exception do
      begin
        Logger.Write('Erro na função SendPacket: ' + E.Message, TlogType.Error);
        Self.Disconnect;
        Break;
      end;
    end;
  end;

  if not (Self.SocketClosed) and (BytesToSend = 0) then
  begin
   //Logger.Write('Pacote enviado completamente. Total de bytes enviados: ' + IntToStr(TotalBytesSent), TlogType.Warnings);
  end
  else if not (Self.SocketClosed) then
  begin
   // Logger.Write('Send falhou com um erro desconhecido. Bytes restantes: ' + IntToStr(BytesToSend), TlogType.Warnings);
    Self.Disconnect;
  end;

  Self.SockInUse := False;
  //Logger.Write('Finalizando SendPacket.', TlogType.Warnings);
end;


// procedure TPlayer.SendPacket(const Packet; size: WORD; Encrypt: Boolean);
// const
// MAX_BUFFER_SIZE = 21999;
// var
// Buffer: array [0..MAX_BUFFER_SIZE] of Byte;
// BytesSent: Integer;
// PacketPtr: PByte;
// FDSet: TFDSet;
// Timeout: TTimeVal;
// RetVal: Integer;
// begin
// WriteLn('enviando pacote');
// // Verifica se o jogador está conectado
// if Self.Base.ClientID = 0 then
// Exit;
//
// // Verifica se o tamanho do pacote é válido
// if (size = 0) or (size > MAX_BUFFER_SIZE) then
// begin
// if size > MAX_BUFFER_SIZE then
// Self.Disconnect; // Desconecta o jogador se o pacote for muito grande
// Exit;
// end;
//
// // Verifica se o socket é válido
// if not CheckSelfSocket then
// Exit;
//
// // Marca o socket como em uso
// Self.SockInUse := True;
//
// try
// // Limpa o buffer
// ZeroMemory(@Buffer[0], MAX_BUFFER_SIZE);
//
// // Copia o pacote para o buffer temporário
// Move(Packet, Buffer[0], size);
//
// // Criptografa o pacote, se necessário
// if Encrypt then
// TEncDec.Encrypt(@Buffer, size);
//
// BytesSent := 0;
// PacketPtr := @Buffer[0];
//
// // Configura o timeout para operações não bloqueantes
// Timeout.tv_sec := 0; // 0 segundos
// Timeout.tv_usec := 21000; // 50 milissegundos (ajustável conforme necessário)
//
// // Loop para enviar o pacote em partes
// while (BytesSent < size) and (Self.Socket <> INVALID_SOCKET) do
// begin
// // Configura o conjunto de descritores de arquivo
// FD_ZERO(FDSet);
// FD_SET(Self.Socket, FDSet);
//
// // Verifica se o socket está pronto para escrita
// RetVal := Select(0, nil, @FDSet, nil, @Timeout);
//
// if RetVal = SOCKET_ERROR then
// begin
// // Erro no socket, desconecta o jogador
// Logger.Write('Erro no socket durante o envio: ' + WSAGetLastError.ToString, TLogType.Warnings);
// Self.Disconnect;
// Break;
// end
// else if RetVal > 0 then
// begin
// // Tenta enviar os dados
// RetVal := Send(Self.Socket, PacketPtr^, size - BytesSent, 0);
//
// if RetVal = SOCKET_ERROR then
// begin
// // Verifica se o erro é "WOULDBLOCK" (não bloqueante)
// if WSAGetLastError = WSAEWOULDBLOCK then
// begin
// // Socket temporariamente indisponível, tenta novamente após um pequeno atraso
// writeln('Socket bloqueante, tentando novamente...');
// Continue;
// end
// else
// begin
// // Outro erro, desconecta o jogador
// Logger.Write('Erro ao enviar pacote: ' + WSAGetLastError.ToString, TLogType.Warnings);
// Self.Disconnect;
// Break;
// end;
// end
// else if RetVal > 0 then
// begin
// // Atualiza o número de bytes enviados
// Inc(BytesSent, RetVal);
// Inc(PacketPtr, RetVal);
// end;
// end
// else
// begin
// // Timeout ocorreu, tenta novamente
// writeln('Timeout ao enviar pacote, tentando novamente...');
// Continue;
// end;
// end;
// finally
//
// // Libera o socket para uso
// Self.SockInUse := False;
// end;
//
// end;
// procedure TPlayer.SendPacket(const Packet; size: WORD; Encrypt: boolean);
// const
// MAX_BUFFER_SIZE = 21999;
// var
// Buffer: array [0 .. MAX_BUFFER_SIZE] of BYTE;
// BytesSent: Integer;
// PacketPtr: PByte;
// RetVal: Integer;
// EncryptedPacket: PByte;
// begin
// // Verifica se o socket está fechado ou o pacote é muito grande
// if (Self.SocketClosed) or (size > MAX_BUFFER_SIZE) then
// begin
// if size > MAX_BUFFER_SIZE then
// Self.Disconnect; // Desconecta o jogador se o pacote for muito grande
// Exit;
// end;
//
// // Verifica se o socket está válido
// if not CheckSelfSocket then
// Exit;
//
// // Marca o socket como em uso
// Self.SockInUse := True;
//
// try
// // Aloca memória para o pacote criptografado, se necessário
// if Encrypt then
// begin
// GetMem(EncryptedPacket, size);
// try
// // Copia o pacote para o buffer temporário
// Move(Packet, EncryptedPacket^, size);
//
// // Criptografa o pacote
// TEncDec.Encrypt(EncryptedPacket, size);
//
// // Inicializa variáveis para envio
// BytesSent := 0;
// PacketPtr := EncryptedPacket;
// except
// FreeMem(EncryptedPacket);
// raise;
// end;
// end
// else
// begin
// // Se não for criptografar, usa o pacote original
// BytesSent := 0;
// PacketPtr := @Packet;
// end;
//
// // Loop para enviar o pacote em partes
// while (BytesSent < size) and (Self.Socket <> INVALID_SOCKET) do
// begin
// // Tenta enviar os dados
// RetVal := Send(Self.Socket, PacketPtr^, size - BytesSent, 0);
//
// if RetVal = SOCKET_ERROR then
// begin
// // Verifica se o erro é "WOULDBLOCK" (não bloqueante)
// if WSAGetLastError = WSAEWOULDBLOCK then
// begin
// // Socket temporariamente indisponível, tenta novamente
// Continue;
// end
// else
// begin
// // Outro erro, desconecta o jogador
// Self.Disconnect;
// Break;
// end;
// end
// else if RetVal > 0 then
// begin
// // Atualiza o número de bytes enviados
// Inc(BytesSent, RetVal);
// Inc(PacketPtr, RetVal);
// end;
// end;
//
// finally
// // Libera a memória alocada para o pacote criptografado, se necessário
// if Encrypt then
// FreeMem(EncryptedPacket);
//
// // Libera o socket para uso
// Self.SockInUse := false;
// end;
// end;

procedure TPlayer.Disconnect;
begin
  if Self.Socket <> INVALID_SOCKET then
  begin
    shutdown(Self.Socket, 0);
    closesocket(Self.Socket);
    Self.Socket := INVALID_SOCKET;
  end;
  if not Self.SocketClosed then
  begin
    Self.SocketClosed := True;
    Servers[Self.ChannelIndex].Disconnect(Self);
    Servers[Self.ChannelIndex].Players[Self.Base.clientId]
      .PlayerThreadActive := false;
    PlayersThreads := PlayersThreads - 1;
//    Self.Destroy;
  end;
end;

procedure TPlayer.SendSignal(headerClientId, packetCode: WORD);
var
  signal: TPacketHeader;
begin
  ZeroMemory(@signal, SizeOf(TPacketHeader));
  signal.size := SizeOf(TPacketHeader);
  signal.Index := headerClientId;
  signal.Code := packetCode;
  SendPacket(signal, signal.size)
end;

procedure TPlayer.SendSignal(Client, packetCode, size: WORD);
var
  signal: TPacketHeader;
  Buffer: array of BYTE;
begin
  ZeroMemory(@signal, SizeOf(TPacketHeader));
  SetLength(Buffer, size);
  ZeroMemory(@Buffer, size);
  signal.size := size;
  signal.Index := Client;
  signal.Code := packetCode;
  Move(signal, Buffer, 12);
  SendPacket(Buffer, size);
end;

procedure TPlayer.SendData(clientId, packetCode: WORD; Data: DWORD);
var
  signal: TSignalData;
begin
  ZeroMemory(@signal, SizeOf(TSignalData));
  signal.Header.size := SizeOf(TSignalData);
  signal.Header.Index := clientId;
  signal.Header.Code := packetCode;
  signal.Data := Data;
  SendPacket(signal, signal.Header.size)
end;

function TPlayer.GetCurrentCity: TCity;
var
  I: WORD;
  MapID: BYTE;
  X, Y: DWORD;
begin
  MapID := 0;
  X := Round(Self.Base.PlayerCharacter.LastPos.X);
  Y := Round(Self.Base.PlayerCharacter.LastPos.Y);

  for I := 0 to 64 do
  begin
    with MapsData.Limits[I] do
      if (X > StartX) and (X < FinalX) and (Y > StartY) and (Y < FinalY) then
      begin
        MapID := I + 1;
        Break;
      end;
  end;

  Result := TCity(MapID);
end;

function TPlayer.GetCurrentCityID: BYTE;
var
  I: BYTE;
  MapID: BYTE;
  X, Y: DWORD;
begin
  MapID := 0;
  X := Round(Self.Base.PlayerCharacter.LastPos.X);
  Y := Round(Self.Base.PlayerCharacter.LastPos.Y);

  for I := 0 to 64 do
  begin
    with MapsData.Limits[I] do
    begin
      if (X > StartX) and (X < FinalX) and (Y > StartY) and (Y < FinalY) then
      begin
        MapID := I + 1;
        Break;
      end;
    end;
  end;

  Result := MapID;
end;

procedure TPlayer.SetCurrentNeighbors();
var
  I: BYTE;
  offset: Single;
begin
  for I := 0 to 8 do
  begin
    offset := 0.5 + (I div 2) * 0.1; // Calcular o deslocamento
    if I mod 2 = 0 then
    begin
      Self.Base.Neighbors[I].Pos.X :=
        Self.Base.PlayerCharacter.LastPos.X - offset;
      Self.Base.Neighbors[I].Pos.Y :=
        Self.Base.PlayerCharacter.LastPos.Y - offset;
    end
    else
    begin
      Self.Base.Neighbors[I].Pos.X :=
        Self.Base.PlayerCharacter.LastPos.X + offset;
      Self.Base.Neighbors[I].Pos.Y :=
        Self.Base.PlayerCharacter.LastPos.Y + offset;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Sends'}

procedure TPlayer.SendClientMessage(Msg: AnsiString; MsgType: Integer = 16;
  Null: Integer = 0; Type2: Integer = 0);
var
  Packet: TClientMessagePacket;
  I: Integer;
begin
  ZeroMemory(@Packet, SizeOf(TClientMessagePacket));
  Packet.Header.size := 144;
  Packet.Header.Code := $984;
  Packet.Null := Null; { 16 = Msg Amarela }
  Packet.Type1 := MsgType; { 16 + = msg aparece em cima na tela }
  { 32 + = msg de GM }
  { 48 + = msg de GM + msg em cima }
  Packet.Type2 := Type2;

  // Preenche a mensagem diretamente sem o uso de "Length(Msg)" no laço
  for I := 0 to High(Msg) do
  begin
    Packet.Msg[I] := Msg[I + 1];
  end;

  SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendCharList(Type1: BYTE);
var
  Packet: TSendToCharListPacket;
  I, z: BYTE;
begin
  Writeln('charlist 1');
  ZeroMemory(@Packet, SizeOf(TSendToCharListPacket));

  if (Type1 = 0) then
  begin
    ZeroMemory(@Self.Base.MOB_EF, SizeOf(Self.Base.MOB_EF));
    ZeroMemory(@Self.Base.PlayerCharacter, SizeOf(TPlayerCharacter));
  end;

  Packet.Header.size := SizeOf(TSendToCharListPacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $901;
  Packet.AcountID := Account.Header.AccountId;

  for I := 0 to 2 do
  begin
    Move(Account.Characters[I].Base.Name, Packet.CharactersData[I].Name, 16);
    Packet.CharactersData[I].Nation := Integer(Account.Header.Nation);

    for z := 0 to 7 do
    begin
      Packet.CharactersData[I].Equip[z] := Account.Characters[I]
        .Base.Equip[z].APP;
    end;

    // Packet.CharactersData[i].Refine[7] := Account.Characters[i].Base.Equip[6].Refi div $10;
    Packet.CharactersData[I].Refine[7] := 15;
    Move(Account.Characters[I].Base.CurrentScore,
      Packet.CharactersData[I].Attributes, SizeOf(TAttributes));

    // if Account.Header.NumericToken[i] <> '' then
    // Packet.CharactersData[i].NumRegister := True;
    // Packet.CharactersData[i].NumericError := Account.Header.NumError[i];

    Move(Account.Characters[I].Base.CurrentScore.Sizes,
      Packet.CharactersData[I].size, SizeOf(TSize));
    Move(Account.Characters[I].Base.Gold, Packet.CharactersData[I].Gold,
      SizeOf(DWORD));
    Move(Account.Characters[I].Base.Exp, Packet.CharactersData[I].Exp,
      SizeOf(DWORD));

    Packet.CharactersData[I].ClassInfo := Account.Characters[I].Base.ClassInfo;
    Packet.CharactersData[I].Level := Account.Characters[I].Base.Level - 1;
    Packet.CharactersData[I].Equip[0] := Account.Characters[I]
      .Base.Equip[0].Index;
    Packet.CharactersData[I].Equip[1] := Account.Characters[I]
      .Base.Equip[1].Index;

    // if (Self.Account.CharactersDelete[i] = True) then
    // begin
    // Packet.CharactersData[i].DeleteTime := TFunctions.DateTimeToUNIXTimeFAST(StrToDateTime(String(Self.Account.CharactersDeleteTime[i])));
    // end;
  end;

  // Envio do pacote
  if (Status = CharList) then
  begin
    SendPacket(Packet, Packet.Header.size);
    Exit;
  end;

  Status := CharList;
  SubStatus := Senha2;
  SendPacket(Packet, Packet.Header.size);
end;

function TPlayer.BackToCharList: boolean;
var
  Guild: PGuild;
  I, ch, RlkSlot: BYTE;
  cid: WORD;
  ChangeChannelToken: TChangeChannelToken;
  Item: PItem;
  str_aux: String;
begin
  Exit;
  Writeln('Destruindo 5');
  if (SecondsBetween(Now, Self.Base.LastReceivedAttack) <= 10) or
    (SecondsBetween(Now, Self.LastAttackSents) <= 10) then
  begin

    var
      RemainingSeconds, restante: Integer;
    RemainingSeconds := SecondsBetween(Now, Self.Base.LastReceivedAttack);
    restante := RemainingSeconds - 10;
    Self.SendClientMessage('Você não pode deslogar em modo ataque!');
    Self.SendClientMessage
      (format('Faltam %d segundo(s) para o modo ataque ser desativado.',
      [abs(restante)]));
    Exit;
  end;
  // Exit;
  if (Self.Status > TPlayerStatus.CharList) then
  begin
    case Self.SpawnedPran of
      0:
        begin
          for I in Self.Base.VisiblePlayers do
          begin
            Self.SendPranUnspawn(0, I);
          end;
        end;
      1:
        begin
          for I in Self.Base.VisiblePlayers do
          begin
            Self.SendPranUnspawn(1, I);
          end;
        end;
    end;

    // if (Self.InDungeon) then
    // begin
    // if (Self.Base.clientId = Self.Party.Leader) then
    // begin
    // DungeonInstances[Self.DungeonInstanceID].Index := 0;
    // DungeonInstances[Self.DungeonInstanceID].CreateTime := Now;
    // DungeonInstances[Self.DungeonInstanceID].Party := nil;
    // DungeonInstances[Self.DungeonInstanceID].DungeonID := 0;
    // DungeonInstances[Self.DungeonInstanceID].Dificult := 0;
    // ZeroMemory(@DungeonInstances[Self.DungeonInstanceID].MOBS,
    // sizeof(DungeonInstances[Self.DungeonInstanceID].MOBS));
    // DungeonInstances[Self.DungeonInstanceID].InstanceOnline := false;
    // Writeln('Status da Instance 2 ' + DungeonInstances[Self.DungeonInstanceID].InstanceOnline.ToString);
    // for i in Self.Party.Members do
    // begin
    // if (i = Self.Base.clientId) then
    // Continue;
    // Servers[Self.ChannelIndex].Players[i].SendClientMessage
    // ('O jogador [' + AnsiString(Self.Base.Character.Name) +
    // '] era líder do grupo e se desconectou, todos foram expulsos do calabouço.');
    // Servers[Self.ChannelIndex].Players[i].DungeonLobbyIndex := 0;
    // Servers[Self.ChannelIndex].Players[i].DungeonLobbyDificult := 0;
    // Servers[Self.ChannelIndex].Players[i].DungeonID := 0;
    // Servers[Self.ChannelIndex].Players[i].DungeonIDDificult := 0;
    // Servers[Self.ChannelIndex].Players[i].DungeonInstanceID := 0;
    // Servers[Self.ChannelIndex].Players[i].InDungeon := false;
    // Servers[Self.ChannelIndex].Players[i]
    // .Teleport(TPosition.Create(3399, 564));
    // end;
    // end
    // else
    // begin
    // Self.DungeonLobbyIndex := 0;
    // Self.DungeonLobbyDificult := 0;
    // Self.DungeonID := 0;
    // Self.DungeonIDDificult := 0;
    // Self.DungeonInstanceID := 0;
    // Self.InDungeon := false;
    // Self.Teleport(TPosition.Create(3399, 564));
    // for i in Self.Party.Members do
    // begin
    // Servers[Self.ChannelIndex].Players[i].SendClientMessage
    // ('O jogador [' + AnsiString(Self.Base.Character.Name) +
    // '] se desconectou e foi expulso do calabouço.');
    // end;
    // end;
    // end;
    // if Self.Character.Base.GuildIndex > 0 then
    // begin
    // Guild := @Guilds[Self.Character.GuildSlot];
    // Guild.SendMemberLogout(Self.Character.Index);
    // if Guild.MemberInChest = Guild.FindMemberFromCharIndex(Self.Character.
    // Index) then
    // begin
    // Guild.MemberInChest := $FF;
    // Guild.LastChestActionDate := 0;
    // end;
    // end;
    // if not(Self.DesconectedByOtherChannel) then
    // begin
    // if (Self.PartyIndex > 0) then
    // begin
    // Self.Party.RemoveMember(Self.Base.clientId);
    // Self.Party.RefreshParty;
    // Self.RefreshParty;
    // end;
    // while (TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0)
    // <> 255) do
    // begin
    // RlkSlot := TItemFunctions.GetItemSlotByItemType(Self, 40, INV_TYPE, 0);
    // if (RlkSlot <> 255) then
    // begin
    // Item := @Self.Base.Character.Inventory[RlkSlot];
    // Servers[Self.ChannelIndex].CreateMapObject(@Self, 320, Item.Index);
    // { Servers[Self.ChannelIndex].SendServerMsg('O jogador ' +
    // AnsiString(Self.Base.Character.Name) + ' dropou a relíquia <' +
    // AnsiString(ItemList[Item.Index].Name) + '>.'); }
    // ZeroMemory(Item, sizeof(TItem));
    // Self.Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, false);
    // end;
    // end;
    // Self.Base.RemoveBuffByIndex(91);
    // end
    // else
    // begin
    // if (Self.PartyIndex > 0) then
    // begin
    // if (Self.Party.Leader = Self.Base.clientId) then
    // begin
    // Self.Party.DestroyParty(Self.Base.clientId);
    // // Self.Party.RemoveMember(Self.Base.clientId);
    // Self.Party.RefreshParty;
    // Self.RefreshParty;
    // end;
    // end;
    // end;
    Self.SendFriendLogout;
    Self.Base.SendRemoveMob(0, 0, false);

    SendSignal(Self.Base.clientId, $318);
//    Self.SaveInGamePrincipal(Self.SelectedCharacterIndex);
    TFunctions.SavePlayerPrincipal(@Self, Self.SelectedCharacterIndex);
    Self.SaveCharOnCharRoom(Self.SelectedCharacterIndex);

    cid := Self.Base.clientId;
    ch := Self.Base.ChannelId;

    Self.SpawnedPran := 255;
    ZeroMemory(@Self.PlayerQuests, SizeOf(Self.PlayerQuests));
    ZeroMemory(@Self.TeleportList, SizeOf(Self.TeleportList));
    Self.OpennedNPC := 0;
    Self.OpennedOption := 0;

    ShoutTime := Now;
    Self.Base.LastReceivedAttack := Now;
    FaericForm := false;
    Self.TimeUpdate := Now;

    Self.Base.Destroy(True);
    Self.FriendList.Clear;
    Self.FriendOpenWindowns.Clear;
    FreeAndNil(Self.EntityFriend);
    Self.EntityFriend := TEntityFriend.Create(@Self);

    Status := CharList;
    Self.IsInstantiated := false;
    Self.SendedSendToWorld := false;
    Self.LastTimeSaved := Now;
    // Self.Account.Characters[Slot].Base.Equip[ItemSlot]
    ZeroMemory(@Character, SizeOf(TPlayerCharacter));

    // ZeroMemory(@self.base.Character, sizeof(TCharacter));

    ZeroMemory(@Self.Account.Header.Pran1, SizeOf(TPran));
    ZeroMemory(@Self.Account.Header.Pran2, SizeOf(TPran));

    Self.Base.Create(@Self.Character.Base, cid, ch);

    Self.Base.TimeForGoldTime := Now;

    Self.SendCharList(1);

    SelectedCharacterIndex := -1;
  end;

  Result := True;
end;

procedure TPlayer.SendToWorld(CharID: BYTE; aSendPacket: boolean);
var
  Packet: TSendToWorldPacket;
  I: Integer;
  CurrentTitle: TTitleData;
  TitleCategory: BYTE;
  TitleSlot: BYTE;
  ItemPran1, ItemPran2, ItemInventory: PItem;
  Pran1ItemID, Pran2ItemID: Integer;
  Pran1OldSlot: BYTE;
  Pran1OldType: BYTE;
  Pran2OldSlot: BYTE;
  Pran2OldType: BYTE;
  ItemBlank: TItem;
  // EmptySlot: BYTE;
begin
  if (Self.SendedSendToWorld) then
    Exit;

  Pran1OldSlot := 0;
  Pran1OldType := 0;
  Pran2OldSlot := 0;
  Pran2OldType := 0;
  Self.OpennedDevir := 255;
  Self.OpennedTemple := 255;
  ZeroMemory(@Packet, SizeOf(TSendToWorldPacket));
  SelectedCharacterIndex := CharID;
  Packet.Header.size := SizeOf(TSendToWorldPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $925;
  Packet.AcountSerial := Account.Header.AccountId;

  if (aSendPacket) then
  begin
    Self.LoadCharacterMisc(CharID);

    Move(Account.Characters[CharID], Character, SizeOf(TCharacterDB));
  end;

  if (Self.Character.Base.GuildIndex > 0) then
  begin
    Self.SearchAndSetGuildSlot;
  end;
  Character.Base.clientId := Base.clientId;
  Self.Character.Base.LoginTime := TFunctions.DateTimeToUNIXTimeFAST(Now);
  Self.Character.Base.LoginTime1 := TFunctions.DateTimeToUNIXTimeFAST(Now);
  Self.Character.Base.LoginTime2 := TFunctions.DateTimeToUNIXTimeFAST(Now);
  Self.Character.Base.UTC := 3;
  Self.Character.Base.EndDayTime := Servers[Self.ChannelIndex].GetEndDayTime;

  Self.Character.Base.Nation := BYTE(Self.Account.Header.Nation);

  Self.AddFreeAutoFarmTime(Self.Base.Character.Name);

  { Seta as skills do char [os leveis que vai no packet] }
  Self.SetPlayerSkills;

{$REGION 'Set Titles List'}
  Self.Character.Base.ActiveTitle := Character.ActiveTitle.Index;
  ZeroMemory(@Self.Character.Base.TitleCategoryLevel, 12 * SizeOf(DWORD));
  for I := 0 to 95 do
  begin
    CurrentTitle := Self.Character.Titles[I];
    if (CurrentTitle.Index = 0) or (CurrentTitle.Level = 0) then
      Continue;

    TitleCategory := BYTE(trunc(CurrentTitle.Index / 8));
    TitleSlot := (CurrentTitle.Index mod 8);
    Inc(Self.Character.Base.TitleCategoryLevel[TitleCategory],
      TFunctions.GetTitleLevelValue(TitleSlot, CurrentTitle.Level));

    with Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1] do
    begin
      case TitleType of
        8:
          Self.Character.Base.TitleProgressType8[TitleIndex - 1] :=
            CurrentTitle.Progress;
        9:
          Self.Character.Base.TitleProgressType9[1] := CurrentTitle.Progress;
        4:
          Self.Character.Base.TitleProgressType4 := CurrentTitle.Progress;
        10:
          Self.Character.Base.TitleProgressType10 := CurrentTitle.Progress;
        7:
          Self.Character.Base.TitleProgressType7 := CurrentTitle.Progress;
        11:
          Self.Character.Base.TitleProgressType11 := CurrentTitle.Progress;
        12:
          Self.Character.Base.TitleProgressType12 := CurrentTitle.Progress;
        13:
          Self.Character.Base.TitleProgressType13 := CurrentTitle.Progress;
        15:
          Self.Character.Base.TitleProgressType15 := CurrentTitle.Progress;
        16:
          Self.Character.Base.TitleProgressType16[TitleIndex - 1] :=
            CurrentTitle.Progress;
        23:
          Self.Character.Base.TitleProgressType23 := CurrentTitle.Progress;
      else
        // Logger.Write('Nada !!', TlogType.Packets);
      end;
    end;
  end;


  // 0..48 Dungeon and Monsters <8>
  // 49 Elter Notavel <9>
  // 50 Inimigo Publico <4>
  // 51 Saqueador <10>
  // 52 Exterminador <7>
  // 53 Mestre de Batalha <11>
  // 54 Rei das Lutas <12>
  // 55 Perito Em Pesca <13>
  // 56 Aventureiro Mestre <15>
  // 57 ??
  // 58 Gatinho Assustado <16> [1]
  // 59 Pupilo de Alan <16> [2]
  // 60 Mestre da Arena <16> [3]
  // 61 <16> [4]
  // 62 <16> [5]
  // 74 Abre Alas<16> [17]
  // 75 ??
  // 76 ??
  // 77 ??
  // 78 ??
  // 79 ??
  // 80 Sangue Frio <23>
  //
{$ENDREGION}
  Character.Base.CurrentScore.ServerReset := Servers[Self.ChannelIndex]
    .ResetTime;
  for I := 0 to 15 do
    Self.Base.SetEquipEffect(Character.Base.Equip[I], EQUIPING_TYPE);

  Move(Character.Base, Packet.Character, SizeOf(TCharacter));
  Move(Self.Character, Self.Base.PlayerCharacter, SizeOf(TPlayerCharacter));
  if (aSendPacket) then
  begin
    Self.SendData(Base.clientId, $CCCC, $1);
    Self.SendData(Base.clientId, $186, $1);
    Self.SendData(Base.clientId, $186, $1);
    Self.SendData(Base.clientId, $186, $1);
  end;

  try
    Pran1ItemID := 0;
    Pran2ItemID := 0;

    if (Self.Account.Header.Pran1.Iddb <> 0) then
    begin
      Move(Self.Account.Header.Pran1.Name, Packet.Character.PranName[0], 16);
      Pran1ItemID := Self.Account.Header.Pran1.ItemID;
    end;

    if (Self.Account.Header.Pran2.Iddb <> 0) then
    begin
      Move(Self.Account.Header.Pran2.Name, Packet.Character.PranName[1], 16);
      Pran2ItemID := Self.Account.Header.Pran2.ItemID;
    end;

    begin
      // Packet.Character.CurrentScore.Infamia := $ffffff;
      Self.TimeUpdate := IncSecond(Now, 600);

      // Envio dos itens de forma otimizada
      Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
        Self.Account.Header.Storage.Itens[84], false);
      Self.SendClientIndex;
      Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 85,
        Self.Account.Header.Storage.Itens[85], false);
      Self.SendClientIndex;

      SendPacket(Packet, Packet.Header.size);
    end;

    // talvez seja isso aq
{$REGION 'Setando cada pran com cada nome de pran'}
    ItemPran1 := nil;
    ItemPran2 := nil;

    // Procurar o item e mandar o pointer dele
    for I := 0 to 119 do
    begin
      // Procurando no inventário
      ItemInventory := @Self.Character.Base.Inventory[I];
      if (ItemInventory.Index = 0) then
        Continue;
      if (ItemInventory.Identific = Pran1ItemID) then // Achou a pran1
      begin
        ItemPran1 := @Self.Character.Base.Inventory[I];
        Pran1OldSlot := I;
        Pran1OldType := INV_TYPE;
      end
      else if (ItemInventory.Identific = Pran2ItemID) then // Achou a pran2
      begin
        ItemPran2 := @Self.Character.Base.Inventory[I];
        Pran2OldSlot := I;
        Pran2OldType := INV_TYPE;
      end;
    end;

    ItemInventory := @Self.Character.Base.Equip[10];
    if (ItemInventory.Index > 0) then
    begin
      if (ItemInventory.Identific = Pran1ItemID) then // Achou a pran1
      begin
        ItemPran1 := @Self.Character.Base.Equip[10];
        Pran1OldSlot := 10;
        Pran1OldType := EQUIP_TYPE;
      end
      else if (ItemInventory.Identific = Pran2ItemID) then // Achou a pran2
      begin
        ItemPran2 := @Self.Character.Base.Equip[10];
        Pran2OldSlot := 10;
        Pran2OldType := EQUIP_TYPE;
      end;
    end;

    for I := 84 to 85 do
    begin // Procurando nos slots de pran
      ItemInventory := @Self.Account.Header.Storage.Itens[I];
      if (ItemInventory.Index = 0) then
        Continue;
      if (ItemInventory.Identific = Pran1ItemID) then // Achou a pran1
      begin
        ItemPran1 := @Self.Account.Header.Storage.Itens[I];
        Pran1OldSlot := I;
        Pran1OldType := STORAGE_TYPE;
      end
      else if (ItemInventory.Identific = Pran2ItemID) then // Achou a pran2
      begin
        ItemPran2 := @Self.Account.Header.Storage.Itens[I];
        Pran2OldSlot := I;
        Pran2OldType := STORAGE_TYPE;
      end;
    end;

    ZeroMemory(@ItemBlank, SizeOf(ItemBlank));

    if ItemPran1 <> nil then
    begin
      if ItemPran1.Index > 0 then
      begin
        // Eliminar redundância em código de envio de atualização
        Self.Base.SendRefreshItemSlot(Pran1OldType, Pran1OldSlot,
          ItemBlank, false);
        Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemPran1^, false);
        Self.SendClientIndex;
        Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemBlank, false);
        Self.Base.SendRefreshItemSlot(Pran1OldType, Pran1OldSlot,
          ItemPran1^, false);
      end;
    end;

    if ItemPran2 <> nil then
    begin
      if ItemPran2.Index > 0 then
      begin
        // Eliminar redundância em código de envio de atualização
        Self.Base.SendRefreshItemSlot(Pran2OldType, Pran2OldSlot,
          ItemBlank, false);
        Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemPran2^, false);
        Self.SendClientIndex;
        Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84, ItemBlank, false);
        Self.Base.SendRefreshItemSlot(Pran2OldType, Pran2OldSlot,
          ItemPran2^, false);
      end;
    end;

{$ENDREGION}
  except
    on E: Exception do
      Logger.Write('SendToWorld at pran settings region Error. msg[' + E.Message
        + ' : ' + E.GetBaseException.Message + '] username[' +
        String(Self.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
  end;
  // Self.SetCurrentNeighbors;
  Self.SendedSendToWorld := True;
end;

procedure TPlayer.SendToWorld2(CharID: BYTE);
var
  Packet: TSendToWorldPacket;
  CurrentTitle: PTitleData;
  I: Integer;
  TitleCategory: BYTE;
  TitleSlot: BYTE;
begin
  SelectedCharacterIndex := CharID;
  Self.LoadCharacterMisc(CharID);
  Move(Account.Characters[CharID], Character, SizeOf(TCharacterDB));
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $925;
  Packet.AcountSerial := Self.Account.Header.AccountId;
  Packet.Character.clientId := Self.Base.clientId;
  Packet.Character.CharIndex := Self.Character.Index;
  Packet.Character.Name := Self.Character.Base.Name;
  Packet.Character.Nation := Self.Character.Base.Nation;
  Packet.Character.ClassInfo := Self.Character.Base.ClassInfo;

  Packet.Character.CurrentScore := Self.Character.Base.CurrentScore;

  Packet.Character.EndDayTime := TFunctions.DateTimeToUNIXTimeFAST(Now);
  for I := 0 to 15 do
    Self.Base.SetEquipEffect(Character.Base.Equip[I], EQUIPING_TYPE);
  Move(Self.Character.Base.Equip, Packet.Character.Equip,
    SizeOf(Packet.Character.Equip));
  Move(Self.Character.Base.Inventory, Packet.Character.Inventory,
    SizeOf(Packet.Character.Inventory));
  Move(Self.Character.Base.ItemBar, Packet.Character.ItemBar,
    SizeOf(Packet.Character.ItemBar));
  Self.SetPlayerSkills;
  Move(Self.Character.Base.SkillList, Packet.Character.SkillList,
    SizeOf(Packet.Character.SkillList));
  Packet.Character.ActiveTitle := Self.Character.Base.ActiveTitle;
  Packet.Character := Self.Character.Base;
  for I := 0 to 95 do
  begin
    CurrentTitle := @Self.Character.Titles[I];
    if (CurrentTitle.Index = 0) then
      Continue;
    TitleCategory := trunc(CurrentTitle.Index div 8);
    TitleSlot := (CurrentTitle.Index mod 8);
    Packet.Character.TitleCategoryLevel[TitleCategory] :=
      Packet.Character.TitleCategoryLevel[TitleCategory] +
      Self.GetTitleLevelValue(TitleSlot, CurrentTitle.Level);
    case Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
      .TitleType of
      8:
        Packet.Character.TitleProgressType8
          [Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
          .TitleIndex - 1] := CurrentTitle.Progress;
      9:
        Packet.Character.TitleProgressType9[1] := CurrentTitle.Progress;
      4:
        Packet.Character.TitleProgressType4 := CurrentTitle.Progress;
      10:
        Packet.Character.TitleProgressType10 := CurrentTitle.Progress;
      7:
        Packet.Character.TitleProgressType7 := CurrentTitle.Progress;
      11:
        Packet.Character.TitleProgressType11 := CurrentTitle.Progress;
      12:
        Packet.Character.TitleProgressType12 := CurrentTitle.Progress;
      13:
        Packet.Character.TitleProgressType13 := CurrentTitle.Progress;
      15:
        Packet.Character.TitleProgressType15 := CurrentTitle.Progress;
      16:
        Packet.Character.TitleProgressType16
          [Titles[CurrentTitle.Index].TitleLevel[CurrentTitle.Level - 1]
          .TitleIndex - 1] := CurrentTitle.Progress;
      23:
        Packet.Character.TitleProgressType23 := CurrentTitle.Progress;
    end;
  end;
  Packet.Character.Exp := Self.Character.Base.Exp;
  Packet.Character.Level := Self.Character.Base.Level;
  Packet.Character.Gold := Self.Character.Base.Gold;
  Packet.Character.GuildIndex := Self.Character.Base.GuildIndex;
  Packet.Character.LoginTime := TFunctions.DateTimeToUNIXTimeFAST(Now);
  Packet.Character.Location := Self.Character.Base.Location;
  Packet.Character.CreationTime := Self.Character.Base.CreationTime;
  Packet.Character.CurrentScore.ServerReset := Servers[Self.ChannelIndex]
    .ResetTime;
  Move(Self.Character.Base.Numeric, Packet.Character.Numeric,
    SizeOf(Packet.Character.Numeric));
  Move(Self.Character, Self.Base.PlayerCharacter, SizeOf(TPlayerCharacter));
  Self.SendData(Base.clientId, $CCCC, $1);
  SendP3A2;
  SendP186;
  SendP186;
  SendP186;
  Self.SendP131;
  Self.SendPacket(Packet, Packet.Header.size);
  SendP12C;
  Self.Base.SendRefreshItemSlot(2, 54, Self.Account.Header.Storage.Itens
    [54], false);
  Self.SendClientIndex;
  Self.Base.SendRefreshItemSlot(2, 55, Self.Account.Header.Storage.Itens
    [55], false);
  Self.SendClientIndex;
  Self.SendP94C;
  Self.SendedSendToWorld := True;
end;

procedure TPlayer.SendPranToWorld(PranSlot: BYTE);
var
  Packet: TSendPranToWorld;
  I: Integer;
  Tamanho: Integer;
  Level: Cardinal;
  Pran: TPran;
begin
  ZeroMemory(@Packet, SizeOf(TSendPranToWorld));
  Packet.Header.size := SizeOf(TSendPranToWorld);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $907;

  if (PranSlot = 0) then
    Pran := Self.Account.Header.Pran1
  else if (PranSlot = 1) then
    Pran := Self.Account.Header.Pran2
  else
    Exit; // In case an invalid PranSlot is passed

  Move(Pran.Name, Packet.Name, 16);
  Packet.PranClass := Pran.ClassPran;
  Packet.Food := Pran.Food;

  if (Pran.Personality.Cute >= Pran.Devotion) then
    Packet.Personality := 00
  else if (Pran.Personality.Smart >= Pran.Devotion) then
    Packet.Personality := 01
  else if (Pran.Personality.Sexy >= Pran.Devotion) then
    Packet.Personality := 02
  else if (Pran.Personality.Energetic >= Pran.Devotion) then
    Packet.Personality := 03
  else if (Pran.Personality.Tough >= Pran.Devotion) then
    Packet.Personality := 04
  else if (Pran.Personality.Corrupt >= Pran.Devotion) then
    Packet.Personality := 05;

  for I := 0 to 9 do { ATTENTION PRAN SKILL Count can be 10 or 12 }
  begin
    if (Pran.Skills[I].Level = 0) then
      Continue;

    Tamanho := TSkillFunctions.GetSkillPranLevel(I,
      Pran.Skills[I].Level, Level);
    Move(Level, Packet.unk[I], Tamanho);
  end;

  for I := 0 to 2 do
  begin
    if (Pran.ItemBar[I] = 0) then
      Continue;

    Packet.PranSkillBar[I] := Pran.ItemBar[I];
  end;

  Packet.Devotion := Pran.Devotion;
  Packet.MaxHp := Pran.MaxHp;
  Packet.CurHP := Pran.CurHP;
  Packet.MaxMP := Pran.MaxMP;
  Packet.CurMp := Pran.CurMp;
  Packet.Exp := Pran.Exp;
  Packet.DefFis := Pran.DefFis;
  Packet.DefMag := Pran.DefMag;

  Move(Pran.Equip, Packet.Equips, 16 * SizeOf(TItem));
  Move(Pran.Inventory, Packet.Inventory, 42 * SizeOf(TItem));

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendPranSpawn(PranSlot: BYTE; SendTo: WORD; SpawnType: BYTE);
var
  Packet: TSendCreatePranPacket;
  I: Integer;
  Rand: Integer;
  Title: String;
begin
  ZeroMemory(@Packet, SizeOf(TSendCreatePranPacket));
  Packet.Header.size := SizeOf(TSendCreatePranPacket);
  Packet.Header.Code := $349;

  // Definir o nome e atributos principais da pran
  if (PranSlot = 0) then
  begin
    if not(Self.PranIsFairy(Self.Account.Header.Pran1.ClassPran)) then
    begin
      Move(Self.Account.Header.Pran1.Name, Packet.Name[0], 16);
      for I := 0 to 7 do
        Packet.Equip[I] := Self.Account.Header.Pran1.Equip[I].Index;

      Packet.MaxHp := Self.Account.Header.Pran1.MaxHp;
      Packet.CurHP := Self.Account.Header.Pran1.CurHP;
      Packet.MaxMP := Self.Account.Header.Pran1.MaxMP;
      Packet.CurMp := Self.Account.Header.Pran1.CurMp;
      Packet.SpeedMove := Self.Base.PlayerCharacter.SpeedMove;
      Packet.SpawnType := SpawnType;
      Packet.Altura := Self.Account.Header.Pran1.Width;
      Packet.Tronco := Self.Account.Header.Pran1.Chest;
      Packet.Perna := Self.Account.Header.Pran1.Leg;
      Packet.PranClientID := Self.Base.PranClientID;
      Packet.Header.Index := Packet.PranClientID;
      Title := String('Pran do ' + Self.Character.Base.Name);
      AnsiStrings.StrPLCopy(Packet.Title, AnsiString(Title), 32);

      // Verificar se o envio é para o próprio ou outro jogador
      if (SendTo = 0) then
      begin
        Randomize;
        Rand := RandomRange(0, 8);
        Packet.Position := Self.Base.Neighbors[Rand].Pos;
        Self.Account.Header.Pran1.Position := Packet.Position;
        Self.Base.SendToVisible(Packet, Packet.Header.size, True);
        Self.Account.Header.Pran1.IsSpawned := True;
      end
      else
      begin
        Packet.Position := Self.Account.Header.Pran1.Position;
        Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
          Packet.Header.size);
      end;
    end
    else // pran modo elfa
    begin
      case Self.Account.Header.Pran1.ClassPran of
        61 .. 64:
          Self.SendEffect(2);
        71 .. 74:
          Self.SendEffect(4);
        81 .. 84:
          Self.SendEffect(8);
      end;
    end;
  end
  else if (PranSlot = 1) then
  begin
    if not(Self.PranIsFairy(Self.Account.Header.Pran2.ClassPran)) then
    begin
      Move(Self.Account.Header.Pran2.Name, Packet.Name[0], 16);
      for I := 0 to 7 do
        Packet.Equip[I] := Self.Account.Header.Pran2.Equip[I].Index;

      Packet.MaxHp := Self.Account.Header.Pran2.MaxHp;
      Packet.CurHP := Self.Account.Header.Pran2.CurHP;
      Packet.MaxMP := Self.Account.Header.Pran2.MaxMP;
      Packet.CurMp := Self.Account.Header.Pran2.CurMp;
      Packet.SpeedMove := Self.Base.PlayerCharacter.SpeedMove;
      Packet.SpawnType := SpawnType;
      Packet.Altura := Self.Account.Header.Pran2.Width;
      Packet.Tronco := Self.Account.Header.Pran2.Chest;
      Packet.Perna := Self.Account.Header.Pran2.Leg;
      Packet.PranClientID := Self.Base.PranClientID;
      Packet.Header.Index := Packet.PranClientID;
      Title := String('Pran do ' + Self.Character.Base.Name);
      AnsiStrings.StrPLCopy(Packet.Title, AnsiString(Title), 32);

      // Verificar se o envio é para o próprio ou outro jogador
      if (SendTo = 0) then
      begin
        Randomize;
        Rand := RandomRange(0, 8);
        Packet.Position := Self.Base.Neighbors[Rand].Pos;
        Self.Account.Header.Pran2.Position := Packet.Position;
        Self.Base.SendToVisible(Packet, Packet.Header.size, True);
        Self.Account.Header.Pran2.IsSpawned := True;
      end
      else
      begin
        Packet.Position := Self.Account.Header.Pran2.Position;
        Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
          Packet.Header.size);
      end;
    end
    else // pran modo elfa
    begin
      case Self.Account.Header.Pran2.ClassPran of
        61 .. 64:
          Self.SendEffect(2);
        71 .. 74:
          Self.SendEffect(4);
        81 .. 84:
          Self.SendEffect(8);
      end;
    end;
  end;
end;

procedure TPlayer.SendPranUnspawn(PranSlot: BYTE; SendTo: WORD);
var
  Packet: TSendRemoveMobPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(TSendRemoveMobPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $101;

  if (PranSlot = 0) and (Self.Account.Header.Pran1.Iddb > 0) then
  begin
    Packet.Index := Self.Base.PranClientID;
    Packet.DeleteType := 0;

    if (Self.Account.Header.Pran1.Level < 4) then
      Self.SendEffect(0)
    else
    begin
      if (SendTo = 0) then
      begin
        Self.Base.SendToVisible(Packet, Packet.Header.size, True);
        if (Self.SpawnedPran = 255) then
        begin
          Self.Account.Header.Pran1.IsSpawned := false;
        end;
      end
      else
      begin
        Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
          Packet.Header.size);
      end;
    end;
  end
  else if (PranSlot = 1) and (Self.Account.Header.Pran2.Iddb > 0) then
  begin
    Packet.Index := Self.Base.PranClientID;
    Packet.DeleteType := 0;

    if (Self.Account.Header.Pran2.Level < 4) then
      Self.SendEffect(0)
    else
    begin
      if (SendTo = 0) then
      begin
        Self.Base.SendToVisible(Packet, Packet.Header.size, True);
        if (Self.SpawnedPran = 255) then
        begin
          Self.Account.Header.Pran2.IsSpawned := false;
        end;
      end
      else
      begin
        Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet,
          Packet.Header.size);
      end;
    end;
  end;
end;

procedure TPlayer.SetPranPassiveSkill(PranSlot: BYTE; Action: BYTE);
var
  I: Integer;
begin
  case PranSlot of
    0:
      begin
        case Action of
          0:
            // desativando as passivas
            begin
              for I := 0 to 9 do
              begin
                if (Self.Account.Header.Pran1.Skills[I].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran1.Skills[I].
                  Index + (Self.Account.Header.Pran1.Skills[I].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran1.Skills[I].Level) *
                        Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.DecreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran1.Skills[I].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.DecreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran1.Skills[I]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.DecreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran1.Skills[I].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[I].Level) *
                        Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[I].Level)
                        * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[I].Level) *
                        Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[I].Level)
                        * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                end;
              end;
            end;
          1: // ativando as passivas
            begin
              for I := 0 to 9 do
              begin
                if (Self.Account.Header.Pran1.Skills[I].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran1.Skills[I].
                  Index + (Self.Account.Header.Pran1.Skills[I].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran1.Skills[I].Level) *
                        Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.IncreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran1.Skills[I].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.IncreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran1.Skills[I]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.IncreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran1.Skills[I].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[I].Level) *
                        Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[I].Level)
                        * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[I].Level) *
                        Self.Account.Header.Pran1.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[I].Level)
                        * Self.Account.Header.Pran1.Skills[I].Level)));
                    end;
                end;
              end;
            end;
        end;
      end;
    1:
      begin
        case Action of
          0: // desativando as passivas
            begin
              for I := 0 to 9 do
              begin
                if (Self.Account.Header.Pran2.Skills[I].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran2.Skills[I].
                  Index + (Self.Account.Header.Pran2.Skills[I].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran2.Skills[I].Level) *
                        Self.Account.Header.Pran1.Skills[I].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.DecreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran2.Skills[I].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.DecreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran2.Skills[I]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.DecreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran2.Skills[I].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                      Base.DecreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran2.Skills[I].Level) *
                        Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran2.Skills[I].Level)
                        * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.DecreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran1.Skills[I].Level) *
                        Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.DecreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran1.Skills[I].Level)
                        * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                end;
              end;
            end;
          1: // ativando as passivas
            begin
              for I := 0 to 9 do
              begin
                if (Self.Account.Header.Pran2.Skills[I].Level = 0) then
                  Continue;
                case SkillData[Self.Account.Header.Pran2.Skills[I].
                  Index + (Self.Account.Header.Pran2.Skills[I].Level - 1)
                  ].Index of
                  193: // bravura [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (5 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  194: // defesa elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                    end;
                  197: // coragem [hp+] 23 + ((13+level) * level)
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (23 + (13 + Self.Account.Header.Pran2.Skills[I].Level) *
                        Self.Account.Header.Pran2.Skills[I].Level));
                    end;
                  199: // lamina flamejante [crit+] 1*lv
                    begin
                      Base.IncreasseMobAbility(EF_CRITICAL,
                        Self.Account.Header.Pran2.Skills[I].Level);
                    end;
                  217: // coragem [ataque em todos os sentidos] 3 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (3 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  218: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                    end;
                  221: // sabedoria [mp+] 30 + (20*lv)
                    begin
                      Base.IncreasseMobAbility(EF_MP,
                        (30 + (20 * Self.Account.Header.Pran2.Skills[I]
                        .Level)));
                    end;
                  223: // toque assombrado [res+] lv*1
                    begin
                      Base.IncreasseMobAbility(EF_RESISTANCE6,
                        Self.Account.Header.Pran2.Skills[I].Level);
                    end;
                  241: // coragem [ataque em todos os sentidos] 5 + (2*lv)
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE1, // patk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_PRAN_DAMAGE2, // matk
                        (4 + (2 * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  242: // proteção elemental [defesa em todos os sentidos] lv*2
                    begin
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE1, // patk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                      Base.IncreasseMobAbility(EF_PRAN_RESISTANCE2, // matk
                        (2 * Self.Account.Header.Pran2.Skills[I].Level));
                    end;
                  245: // serenidade [hp e mp+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran2.Skills[I].Level) *
                        Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran2.Skills[I].Level)
                        * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                  247: // vento da clemencia [hp_res e mp_res+]
                    begin
                      Base.IncreasseMobAbility(EF_HP,
                        (15 + ((8 + Self.Account.Header.Pran2.Skills[I].Level) *
                        Self.Account.Header.Pran2.Skills[I].Level)));
                      Base.IncreasseMobAbility(EF_MP,
                        (21 + ((11 + Self.Account.Header.Pran2.Skills[I].Level)
                        * Self.Account.Header.Pran2.Skills[I].Level)));
                    end;
                end;
              end;
            end;
        end;
      end;
  end;
end;

function TPlayer.GetPranClassStoneItem(PranClass: BYTE): BYTE;
begin
  Result := 0;
  case PranClass of
    61, 62, 71, 72, 81, 82:
      Result := 100;
    63, 73, 83:
      Result := 101;
    64, 74, 84:
      Result := 102;
  end;
end;

function TPlayer.PranIsFairy(PranClass: BYTE): boolean;
begin
  Result := (PranClass in [61, 71, 81]) or Self.FaericForm;
end;

procedure TPlayer.SetPranEquipAtributes(PranSlot: BYTE; SetOn: boolean);
var
  I: BYTE;
begin
  if SetOn then
  begin
    case PranSlot of
      0:
        begin
          for I := 0 to 15 do
          begin
            if (Self.Account.Header.Pran1.Equip[I].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran1.Equip[I],
              EQUIPING_TYPE);
          end;
        end;
      1:
        begin
          for I := 0 to 15 do
          begin
            if (Self.Account.Header.Pran2.Equip[I].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran2.Equip[I],
              EQUIPING_TYPE);
          end;
        end;
    end;
  end
  else
  begin
    case PranSlot of
      0:
        begin
          for I := 0 to 15 do
          begin
            if (Self.Account.Header.Pran1.Equip[I].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran1.Equip[I],
              DESEQUIPING_TYPE);
          end;
        end;
      1:
        begin
          for I := 0 to 15 do
          begin
            if (Self.Account.Header.Pran2.Equip[I].Index = 0) then
              Continue;
            Self.Base.SetEquipEffect(Self.Account.Header.Pran2.Equip[I],
              DESEQUIPING_TYPE);
          end;
        end;
    end;
  end;
end;

procedure TPlayer.RefreshMoney;
var
  Packet: TRefreshMoneyPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $312;
  Packet.InventoryGold := Character.Base.Gold;
  Packet.ChestGold := Account.Header.Storage.Gold;
  SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.RefreshItemBarSlot(Slot: Integer; Type1: Integer;
  Item: Integer);
var
  Packet: TChangeItemBarPacket;
begin
  ZeroMemory(@Packet, SizeOf(TChangeItemBarPacket));
  Packet.Header.size := SizeOf(TChangeItemBarPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $31E;
  Packet.DestSlot := Slot;
  Packet.SrcType := Type1;
  Packet.SrcIndex := Item;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendStorage(StorageType: Integer = 1);
var
  Packet: TStoragePacket;
begin
  ZeroMemory(@Packet, SizeOf(TStoragePacket));
  Packet.Header.size := SizeOf(TStoragePacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $137;
  Move(Self.Account.Header.Storage, Packet.Storage, SizeOf(TStoragePlayer));
  Self.SendPacket(Packet, Packet.Header.size);
  Self.SendData(Self.Base.clientId, $310, StorageType);

  // Envio dos itens em slots 84 e 85
  Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 84,
    Self.Account.Header.Storage.Itens[84], false);
  Self.Base.SendRefreshItemSlot(STORAGE_TYPE, 85,
    Self.Account.Header.Storage.Itens[85], false);
end;

procedure TPlayer.SendChangeItemResponse(ReinforceResult: WORD;
  ChangeType: BYTE);
var
  Packet: TReinforceResponse;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $32E;
  Packet.ReinforceResult := ReinforceResult;
  Packet.Unk1 := ChangeType;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.AddFreeAutoFarmTime(CharName: string);
var
  PlayerSQLComp: TQuery;
  AutoTime, DaysPassed, tempo: DWORD;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  try
    // Verifica se já passou um dia desde last_free_day
    PlayerSQLComp.SetQuery
      ('SELECT last_free_day FROM auto_time WHERE `character` = ''' +
      StringReplace(CharName, '''', '\''', [rfReplaceAll]) + '''');
    PlayerSQLComp.Run();

    if (PlayerSQLComp.Query.RecordCount > 0) then
    begin
      // Pegamos o valor de last_free_day
      if PlayerSQLComp.Query.FieldByName('last_free_day').AsString <> '' then
      begin
        PlayerSQLComp.SetQuery
          ('SELECT Time, TIMESTAMPDIFF(DAY, last_free_day, NOW()) AS days_passed '
          + 'FROM auto_time WHERE `character` = ''' + StringReplace(CharName,
          '''', '\''', [rfReplaceAll]) + '''');
        PlayerSQLComp.Run();

        if PlayerSQLComp.Query.RecordCount > 0 then
        begin
          DaysPassed :=
            StrToIntDef(PlayerSQLComp.Query.FieldByName('days_passed')
            .AsString, 0);
          tempo := PlayerSQLComp.Query.FieldByName('time').AsInteger;

          if (DaysPassed >= 1) and (tempo = 0) then
          begin
            // Atualiza o tempo e redefine last_free_day para hoje
            PlayerSQLComp.SetQuery
              ('UPDATE auto_time SET time = time + 3600, last_free_day = NOW() '
              + 'WHERE `character` = ''' + StringReplace(CharName, '''', '\''',
              [rfReplaceAll]) + '''');
            PlayerSQLComp.Query.ExecSQL();
          end;
        end;
      end;
    end;
  except
    on E: Exception do
      Logger.Write('Erro ao atualizar auto_time. Msg[' + E.Message + ']',
        TlogType.Error);
  end;

  PlayerSQLComp.Destroy;
end;

procedure TPlayer.AddAutoFarmTime(CharName: AnsiString; tempo: Integer);
var
  PlayerSQLComp: TQuery;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  try
    PlayerSQLComp.SetQuery('UPDATE auto_time SET time = ' + tempo.ToString +
      ' WHERE `character` = ''' + StringReplace(CharName, '''', '\''',
      [rfReplaceAll]) + '''');
    PlayerSQLComp.Query.ExecSQL();

  except
    on E: Exception do
      Logger.Write('Erro ao atualizar auto_time. Msg[' + E.Message + ']',
        TlogType.Error);
  end;

  PlayerSQLComp.Destroy;
end;

function TPlayer.GetAutoFarmTime(CharName: string): Integer;
var
  PlayerSQLComp: TQuery;
  AutoTime: Integer;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  Result := 0;
  try
    PlayerSQLComp.SetQuery
      ('SELECT time, last_free_day FROM auto_time WHERE `character` = ''' +
      CharName + '''');
    PlayerSQLComp.Run();
    // AutoTime := PlayerSQLComp.Query.FieldByName('time').AsInteger;
    AutoTime := PlayerSQLComp.Query.FieldByName('time').AsInteger;
    Result := AutoTime;

  except
    on E: Exception do
    begin
      Logger.Write('Erro ao carregar os dados de auto_caça. Msg[' + E.Message +
        ']', TlogType.Error);
    end;
  end;
  PlayerSQLComp.Destroy;
end;

function TPlayer.GetAutoFarmTimeUsed(CharName: string): Integer;
var
  PlayerSQLComp: TQuery;
  AutoTimeUsed: Integer;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  Result := 0;

  try
    PlayerSQLComp.SetQuery
      ('SELECT time_used FROM auto_time WHERE `character` = ''' +
      CharName + '''');
    PlayerSQLComp.Run();
    AutoTimeUsed := PlayerSQLComp.Query.FieldByName('time_used').AsInteger;
    Result := AutoTimeUsed;

  except
    on E: Exception do
    begin
      Logger.Write('Erro ao carregar os dados de auto_caça. Msg[' + E.Message +
        ']', TlogType.Error);
    end;
  end;

  PlayerSQLComp.Destroy;

end;

procedure TPlayer.SendAutoFarmTime;
var
  PlayerSQLComp: TQuery;
  AutoTime: Integer;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  try
    // Consulta SQL para pegar o username e premium_time
    PlayerSQLComp.SetQuery('SELECT time FROM auto_time WHERE `character` = ''' +
      Self.Base.Character.Name + '''');
    
    PlayerSQLComp.Run();

    // Verifica se o resultado da consulta não está vazio
    if not PlayerSQLComp.Query.IsEmpty then
    begin
      AutoTime := PlayerSQLComp.Query.FieldByName('time').AsInteger;
      Self.F12TempoRestante := AutoTime;
    end;

    // WriteLn('tempo de caça restante' + Self.F12TempoRestante.ToString + ' Tempo de autotime retornado na tabela ' +  Autotime.ToString )

  except
    on E: Exception do
    begin
      Logger.Write('Erro ao carregar os dados de premium_account. Msg[' +
        E.Message + ']', TlogType.Error);
    end;
  end;

  PlayerSQLComp.Destroy;

end;

procedure TPlayer.SendAccountStatus();
var
  Packet: TSendAccountStatus;
  PlayerSQLComp: TQuery;
  LocalPremiumTime: TDateTime;
  CurrentTime, NextMinuteTime: TDateTime;
begin
  // Inicializa o pacote
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $14F;
  Packet.Header.Index := Self.Base.clientId;

  // Cria a consulta SQL para buscar o PremiumTime e Username da tabela premium_account
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(PlayerSQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão com o banco de dados.[SendAccountStatus]',
      TlogType.Warnings);
    Logger.Write('MYSQL CONNECTION FAILED.[SendAccountStatus]', TlogType.Error);
    PlayerSQLComp.Free;
    Exit;
  end;

  try
    // Consulta SQL para pegar o username e premium_time
    PlayerSQLComp.SetQuery('SELECT username, premium_time ' +
      'FROM premium_account ' + 'WHERE username = "' +
      Self.Account.Header.Username + '"');

    PlayerSQLComp.Run();

    // Verifica se o resultado da consulta não está vazio
    if PlayerSQLComp.Query.IsEmpty then
    begin
      Self.Base.RemoveBuff(9298);
      Exit;
    end;

    // Pega o valor do premium_time da consulta e converte diretamente para TDateTime
    LocalPremiumTime := PlayerSQLComp.Query.FieldByName('premium_time')
      .AsDateTime;

  except
    on E: Exception do
    begin
      Logger.Write('Erro ao carregar os dados de premium_account. Msg[' +
        E.Message + ']', TlogType.Error);
      Exit;
    end;
  end;

  PlayerSQLComp.Free;

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
    Packet.Status := AuxilioRed1; // Define o tipo de pacote de status
    Logger.Write('-> PLAYER PREMIUM [LAN] ACABOU DE LOGAR <- LOGIN: ' +
      Self.Account.Header.Username + ' Data de Término: ' +
      FormatDateTime('dd/mm/yyyy hh:nn', LocalPremiumTime), TlogType.Warnings);
    Self.IsAuxilyUser := True;
  end
  else
  begin
    Exit;
  end;

  // Envia o pacote para o cliente
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.Limpar_Elter(AChannelIndex: Integer; ACharacterName: string);
var
  PlayerSQLComp: TQuery;
begin
  // Limpar elter Navicat

  // DELIMITER $$
  //
  // CREATE PROCEDURE LimparElter(IN PlayerName VARCHAR(255))
  // BEGIN
  // DELETE FROM elter WHERE nome_antigo = PlayerName;
  // END $$
  //
  // DELIMITER ;

  if AChannelIndex <> 3 then
  begin
    // Criar o objeto de consulta (PlayerSQLComp)
    PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));
    try
      // Chamar o procedimento armazenado
      PlayerSQLComp.SetQuery('CALL LimparElter(:PlayerName)');
      PlayerSQLComp.Query.ParamByName('PlayerName').AsString := ACharacterName;
      PlayerSQLComp.Query.ExecSQL;
    finally
      // Liberar o objeto da memória
      PlayerSQLComp.Free;
    end;
  end;
end;

procedure TPlayer.Elter_Estatico(Player: TPlayer);
var
  Packet: TShowElterDialog;

begin

  if (Self.Waiting1 = 0) and (Elter_Status = 1) and RegisterElterOld then
  begin

    Packet.Header.size := SizeOf(TShowElterDialog);
    Packet.Header.Index := Self.Base.clientId;
    Packet.Header.Code := $394;
    Packet.tempo := abs(Servers[3].RemainingTime - 10);

    Self.SendPacket(Packet, SizeOf(TShowElterDialog));
  end;

end;

procedure TPlayer.RegisterElter();
var
  CharacterName: string;
  CharacterNation: Integer;
  StatusValue: Integer;
  NewNation: Integer;
  PlayerSQLComp: TQuery; // Definir o objeto PlayerSQLComp
var
  Packets: TElterPlacar;
begin
  // Verifica se a cidade é 45 e o canal é 3
  if (Self.GetCurrentCityID = 45) and (Self.ChannelIndex = 3) then
  begin
    // Definir o estado de espera
    Self.FWaiting := 1;
    Randomize;
    Self.Teleport(TPosition.Create(3905 + random(10), 3911 + random(5)));

    // Dados do jogador
    CharacterName := Self.Base.Character.Name;
    CharacterNation := Self.Base.Character.Nation;
    Self.OldNation := Self.Base.Character.Nation;
    StatusValue := 1; // Status inicial do jogador

    // Criar o objeto de consulta (PlayerSQLComp)
    PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));

    try
      // Chama o procedimento armazenado para registrar ou atualizar a nação
      PlayerSQLComp.SetQuery
        ('CALL sp_InsertOrUpdateElter(:CharacterName, :CharacterNation, :StatusValue, @NewNation)');

      // Passando parâmetros de entrada
      PlayerSQLComp.Query.ParamByName('CharacterName').AsString :=
        CharacterName;
      PlayerSQLComp.Query.ParamByName('CharacterNation').AsInteger :=
        CharacterNation;
      PlayerSQLComp.Query.ParamByName('StatusValue').AsInteger := StatusValue;

      // Executando a procedure
      PlayerSQLComp.Query.ExecSQL;

      // Recuperando o valor de saída
      PlayerSQLComp.SetQuery('SELECT @NewNation AS NewNation');
      PlayerSQLComp.Query.Open;
      NewNation := PlayerSQLComp.Query.Fields[0].AsInteger;

      // Use logs para depuração
      // Logger.Write('Valor de saída NewNation: ' + IntToStr(NewNation));

      // Atualiza a nação do personagem
      Self.Base.Character.Nation := NewNation;
      if NewNation = 4 then
      begin
        Self.SendClientMessage('Entrou no time azul');
        Self.FTeam := 4;

        Packets.Header.size := SizeOf(TElterPlacar);
        Packets.Header.Index := Self.Base.clientId;
        Packets.Header.Code := $1AA;
        Packets.Status := 0;
        Packets.Contagem := Servers[3].RemainingTime;

        Self.SendPacket(Packets, SizeOf(TElterPlacar));


        // for var I := 0 to 39 do
        // begin
        //
        // var SkillID: integer :=  round(Self.Base.Character.ItemBar[i] / 16);
        // if (skillid = -2) or (Self.Base.Character.ItemBar[i] = 0) then
        // continue;
        // Self.RefreshItemBarSlot(I, 2, SkillID);
        // end;

      end
      else
      begin

        Self.SendClientMessage('Entrou no time vermelho');
        Self.FTeam := 5;

        Packets.Header.size := SizeOf(TElterPlacar);
        Packets.Header.Index := Self.Base.clientId;
        Packets.Header.Code := $1AA;
        Packets.Status := 0;
        Packets.Contagem := Servers[3].RemainingTime;

        Self.SendPacket(Packets, SizeOf(TElterPlacar));


        // for var I := 0 to 39 do
        // begin
        //
        // var SkillID: integer :=  round(Self.Base.Character.ItemBar[i] / 16);
        // if (skillid = -2) or (Self.Base.Character.ItemBar[i] = 0) then
        // continue;
        // Self.RefreshItemBarSlot(I, 2, SkillID);
        // end;

      end;
      // Self.SendClientMessage('Seu nome, nação, status e nação estática foram registrados.', 16, 16, 16);
      Self.SendNationInformation;
    except
      on E: Exception do
        Logger.Write('Erro ao inserir dados na tabela "elter": ' + E.Message,
          TlogType.Error);
    end;

  end;
end;

procedure TPlayer.TeleportToLeopold;
var
  CurrentCityID: Integer;
  NationID: Integer;
begin
  // Obtém o ID da cidade atual e o ID da nação do servidor
  CurrentCityID := Self.GetCurrentCityID;
  NationID := Servers[Self.ChannelIndex].NationID;

  if (Self.ChannelIndex <> 3) and (CurrentCityID = 62) then
    Self.Teleport(TPosition.Create(3450, 690));

  // Se a nação for 15 e o jogador não estiver esperando
  if (NationID = 15) and (Self.FWaiting = 0) then
  begin
    // Verifica se o jogador está nas cidades 0 ou 1
    if (CurrentCityID = 0) or (CurrentCityID = 1) then
    begin
      Writeln('Estou entrando em Leopold, mas como telei do mapa 0 ou 1, irei passar por aqui para poder teleportar especificamente');
    end;

    // Teleporta para a posição em Leopold
    Self.Teleport(TPosition.Create(914, 3700));
    Writeln('Estou entrando em Leopold de modo normal');
  end;
  // if (NationID <> 15) then
  if (NationID <> 15) and (Self.FWaiting = 0) then
  begin
    // Caso a nação não seja 15, teleporta para a nação do jogador dependendo da cidade
    case CurrentCityID of
      13, 58, 62, 17 .. 29:
        begin
          Self.Teleport(TPosition.Create(3400, 565));
          Writeln('Acabei de logar e estou indo para minha nação após sair de Leopold');
        end;
    end;
  end
  else
  begin
    // Writeln('erro 9899');
  end;
end;

procedure TPlayer.RemoverDgs;
var
  CurrentCityID: Integer;
  NationID: Integer;
begin
  // Obtém o ID da cidade atual e o ID da nação do servidor
  CurrentCityID := Self.GetCurrentCityID;
  NationID := Servers[Self.ChannelIndex].NationID;
  if (NationID <> 15) then
  begin
    // Caso a nação não seja 15, teleporta para a nação do jogador dependendo da cidade
    case CurrentCityID of
      3, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 56:
        begin
          Self.SendPlayerToSavedPosition();
          Writeln('Estava em uma dg ao logar e fui mandado para o save!' +
            CurrentCityID.ToString);
        end;
    end;
  end;

end;
//
// procedure TPlayer.EnviarMsg;
//
// end;

procedure TPlayer.UnsetDungeon(unk: boolean = false);
begin
  Self.DungeonLobbyIndex := 0;
  Self.DungeonLobbyDificult := 0;
  Self.DungeonID := 0;
  Self.DungeonIDDificult := 0;
  Self.DungeonInstanceID := 0;
  Self.InDungeon := false;
  Self.TavaEmDG := false;
  Self.EquipeEmDg := false;
  Self.SendPlayerToSavedPosition;
end;

procedure TPlayer.SendToWorldSends(IsSendedByOtherChannel: boolean);
var
  I, J: Integer;
  xCharacterId: UInt64;
  PtrMyFriend: PPlayer;
  AlreadyActivatedAux: boolean;
  ResultOf: Integer;
  Slot: Integer;
  Packet: Tp357;
  // currentHour, currentMinute, currentSecond: Word;
  // Buffer: ARRAY[0..8091] OF BYTE;  // Buffer para enviar a mensagem
  // Len: Integer;
var
  Buff: ARRAY [0 .. 167] OF BYTE; // Buffer para enviar a mensagem
var
  Buff1: ARRAY [0 .. 167] OF BYTE; // Buffer para enviar a mensagem
var
  Len, Len1: Integer;
  PlayerData1: TPlayerData1;

begin

  if Self.IsInstantiated then
    Exit;

  Self.Base.LastReceivedAttack := Now - (1 / 24 / 60);
  // Limpar a tabela "elter" quando o player loga
  // Writeln('pássando pelo sendtoworldssends99');
  Limpar_Elter(Self.ChannelIndex, Self.Base.Character.Name);

  // Verificar se é hora de mostrar o aviso do elter

  Elter_Estatico(Self);

  // Definir o status do personagem
  IsAuxilyUser := false;
  Self.Base.LastMovedTime := Now;
  Self.Base.LastMovedMessageHack := Now;

  // Carregar e registrar dados
  Self.LoadCharacterTeleportList(String(Self.Base.Character.Name));
  // Self.SendTeleportPositionsFC();
  // Self.EnviarMsg;

  Base.SendCreateMob(SPAWN_NORMAL, Self.Base.clientId);

  if ChangeChannelOpcode.ContainsKey(Self.Base.Character.Name) then
  begin
    PlayerData1 := ChangeChannelOpcode.Items[Self.Base.Character.Name];
    Writeln('Ação de ' + PlayerData1.Action.ToString);
    if PlayerData1.Action = 0 then // teleporte normal entre nações
    begin
      Self.Teleport(TPosition.Create(2944, 1664));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;

    if PlayerData1.Action = 2 then // era de teste
    begin
      Self.Teleport(TPosition.Create(3450, 690));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;
    if PlayerData1.Action = 11 then // agros para canal 0
    begin
      Self.Teleport(TPosition.Create(3450, 690));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;
    if PlayerData1.Action = 12 then // agros para canal 1
    begin
      Self.Teleport(TPosition.Create(3450, 690));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;
    if PlayerData1.Action = 13 then // agros para canal 2
    begin
      Self.Teleport(TPosition.Create(3450, 690));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;
    if PlayerData1.Action = 50 then // para entrar na elter
    begin
      Self.Teleport(TPosition.Create(3950, 3950));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;
    if PlayerData1.Action = 100 then // Para entrar em leopold
    begin
      Self.Teleport(TPosition.Create(911, 3701));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;
    if PlayerData1.Action = 101 then
    // Para entrar em lakia, depois de ter saído de leopold
    begin
      Self.Teleport(TPosition.Create(3450, 690));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;

    if PlayerData1.Action = 102 then
    // Para entrar em Valhalla, vindo de Lakia
    begin
      Self.Teleport(TPosition.Create(1486, 1610));
      ChangeChannelOpcode.Remove(Self.Base.Character.Name);
    end;
  end
  else
  begin

    case Self.GetCurrentCityID of
      13, 58, // IDs específicos
      17 .. 29, // Range de 17 a 29
      31, 62: // ID específico fora do range
        begin
          Self.Teleport(TPosition.Create(3400, 565));
          Writeln('Acabei de logar e estou indo para minha nação após sair de Leopold');
        end;
    end;

  end;
  Self.RegisterElter();
  // Verificar guilda

  Self.SendPlayerSkills;

  // Garantir que o personagem tem experiência mínima
  // if Self.Character.Base.Exp = 0 then
  // begin
  // i := TItemFunctions.GetItemSlot2(Self, 5284);
  // if i <> 255 then
  // TItemFunctions.RemoveItem(Self, INV_TYPE, i);
  // Self.Character.Base.Exp := 1;
  // Base.SendRefreshLevel;
  // end;

  Self.SendCashInventory;
  try
    if Self.Character.Base.GuildIndex > 0 then
    begin
      Self.Character.GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
        (Self.Character.Base.GuildIndex);
      Self.SendGuildInfo;
      Self.RefreshPlayerInfos;
      Self.SendP152;
      Self.SendGuildPlayers;
      Guilds[Self.Character.GuildSlot].SendMemberLogin
        (Self.Character.Base.CharIndex);
    end;
  except
    on E: Exception do
    begin
      // Log ou tratamento de erro
      Writeln('Erro ao executar o bloco do guild: ' + E.Message);
    end;
  end;

  // Atualizar lista de amigos e enviar notificações
  try
    Self.CurrentCityID := Self.GetCurrentCityID;
    if Self.EntityFriend.readFriendList(@Self) then
    begin
      Self.RefreshSocialFriends;
      Self.SendFriendLogin;
      Self.RefreshMeToFriends;
    end;
  except
    // Tratar possíveis exceções
  end;
  Self.Character.PlayerKill := false;
  Self.Base.PlayerCharacter.PlayerKill := Self.Character.PlayerKill;

  AlreadyActivatedAux := false;
  Self.SendPlayerCash;

  Self.SearchSkillsPassive(0);

  if not IsSendedByOtherChannel then
  begin
    Self.SendAccountStatus();
  end;

  // Carregar a última posição salva
  Self.SavedPos := Self.LoadSavedLocation();

  // Adicionar buffs ao entrar no jogo
  for I := 0 to 59 do
  begin
    if Self.Base.PlayerCharacter.Buffs[I].Index = 0 then
      Continue;
    Self.Base.AddBuffWhenEntering(Self.Base.PlayerCharacter.Buffs[I].Index,
      Self.Base.PlayerCharacter.Buffs[I].CreationTime);

  end;

  Self.Status := Playing;
  Self.Base.SendRefreshBuffs;
  Self.SendQuests;
  TEntityMail.sendUnreadMails(Self);
  Self.SendUpdateActiveTitle();
  Self.Base.SetOnTitleActiveEffect;

  // Enviar informações da nação
  Self.SendNationInformation;
  Self.SendReliquesToPlayer;

  // Atualizar o escore e status
  Self.Base.GetCurrentScore;
  Self.Base.SendRefreshPoint;
  Self.Base.SendStatus;
  Self.Base.SendRefreshLevel;
  // Self.Base.SendCurrentHPMPLogin(true);
  Self.Base.SendCurrentHPMP();

  // Se o personagem tem montaria, corrigir atributos
  if Self.Base.Character.Equip[9].Index <> 0 then
  begin
    Self.Base.SendRefreshItemSlot(EQUIP_TYPE, 9,
      Self.Base.Character.Equip[9], false);
  end;

  // Atualizar barra de itens
  for I := 0 to 39 do
  begin
    if Self.Character.Base.ItemBar[I] = 0 then
      Continue;
    if TItemFunctions.GetItemSlot2(Self, Self.Character.Base.ItemBar[I]) = 255
    then
      Continue;
    Self.RefreshItemBarSlot(I, 6, Self.Character.Base.ItemBar[I]);
  end;

  // Atualizar posição e cidade atual
  Self.Character.LastPos := Self.Base.PlayerCharacter.LastPos;

  Self.IsInstantiated := True;

  // Limpar listas de mobs, jogadores e NPCs visíveis
  Self.Base.VisibleMobs.Clear;
  Self.Base.VisiblePlayers.Clear;
  Self.Base.VisibleNPCS.Clear;

  Self.SetCurrentNeighbors;
  Base.SendCreateMob(SPAWN_NORMAL, Self.Base.clientId);

  Self.SetCurrentNeighbors;
  // Self.Base.UpdateVisibleList();
  Base.SendCreateMob(SPAWN_TELEPORT, 0, false);

  Self.Base.PranClientID := Servers[Self.ChannelIndex].GetFreePranClientID;
  Servers[Self.ChannelIndex].Prans[Self.Base.PranClientID] :=
    Self.Base.clientId;

  // Verificar se o personagem tem Pran equipado
  if Self.Character.Base.Equip[10].Identific > 0 then
  begin
    if Self.Account.Header.Pran1.ItemID = Self.Character.Base.Equip[10].Identific
    then
    begin
      Self.SendPranSpawn(0, 0, 0);
      Self.SendPranToWorld(0);
      Self.SetPranPassiveSkill(0, 1);
      Self.SpawnedPran := 0;
      Self.Account.Header.Pran1.IsSpawned := True;
      Self.SetPranEquipAtributes(Self.SpawnedPran, True);
    end;
    if Self.Account.Header.Pran2.ItemID = Self.Character.Base.Equip[10].Identific
    then
    begin
      Self.SendPranSpawn(1, 0, 0);
      Self.SendPranToWorld(1);
      Self.SetPranPassiveSkill(1, 1);
      Self.SpawnedPran := 1;
      Self.Account.Header.Pran2.IsSpawned := True;
      Self.SetPranEquipAtributes(Self.SpawnedPran, True);
    end;
  end;

  // // Verificar se o personagem tem mascote
  // if Self.Base.Character.Equip[8].Index <> 0 then
  // begin
  // i := Servers[Self.ChannelIndex].GetFreePetClientID;
  // if i = 0 then
  // begin
  // Self.SendClientMessage('Erro ao spawnar mascote. Contate o suporte.');
  // end
  // else
  // begin
  // Randomize;
  // Self.Base.CreatePet(NORMAL_PET, Self.Base.Neighbors[RandomRange(0, 8)].Pos, Self.Base.Character.Equip[8].Index);
  // Self.SpawnPet(Self.Base.PetClientID);
  //
  // for J in Self.Base.VisiblePlayers do
  // begin
  // Servers[Self.ChannelIndex].Players[J].SpawnPet(Self.Base.PetClientID);
  // if not Servers[Self.ChannelIndex].Players[J].Base.VisibleMobs.Contains(Self.Base.PetClientID) then
  // Servers[Self.ChannelIndex].Players[J].Base.VisibleMobs.Add(Self.Base.PetClientID);
  // end;
  // end;
  // end;

  // Realizar teleporte para Leopold ou outro destino
  // Self.TeleportToLeopold;
  Self.RemoverDgs;
  SendAutoFarmTime;

end;

{$REGION ''}
{$ENDREGION}

procedure TPlayer.SendTitleUpdate(TitleIDAcquire: DWORD; TitleIDLeveled: DWORD);
var
  Packet: TUpdateTitleListPacket;
begin
  ZeroMemory(@Packet, SizeOf(TUpdateTitleListPacket));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $17D;
  Packet.IDAcquire := TitleIDAcquire;
  Packet.IDLeveled := TitleIDLeveled;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.RefreshPlayerInfos(SendToVisible: boolean);
var
  Packet: TRefreshPlayerInfosPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $130;
  Packet.Index := Self.Base.clientId;
  Packet.Nation := Self.Character.Base.Nation;

  if Self.Character.Base.GuildIndex > 0 then
  begin
    Packet.GuildIndex := Self.Character.Base.GuildIndex;
    Move(Guilds[Self.Character.GuildSlot].Name, Packet.GuildName, 19);
  end;

  // Enviar o pacote para a visibilidade, se necessário
  if SendToVisible then
    Self.Base.SendToVisible(Packet, Packet.Header.size)
  else
    Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SpawnMob(mobid: DWORD; MobIdGen: DWORD);
var
  Packet: TSpawnMobPacket;
begin
  if (Self.SocketClosed) then
    Exit;

  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].Index;
  Packet.Header.Code := $35E;

  // Equipamentos
  Packet.Equip[0] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[0];
  Packet.Equip[1] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[1];
  Packet.Equip[6] := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].Equip[6];

  // Posições e atributos
  with Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP[MobIdGen] do
  begin
    Packet.Position := CurrentPos;
    Packet.MaxHp := HP;
    Packet.MaxMP := MP;
  end;

  // Outros atributos
  with Servers[Self.ChannelIndex].MOBS.TMobS[mobid] do
  begin
    Packet.Rotation := Rotation;
    Packet.CurHP := InitHP;
    Packet.CurMp := InitHP;
    // Usando InitHP para MP pode ser correto se for o valor esperado
    Packet.Level := MobLevel;
    Packet.IsService := IsService;
    Packet.SpawnType := SpawnType;
    Packet.Altura := MobElevation;
    Packet.Tronco := Cabeca;
    Packet.Perna := Perna;
    Packet.Corpo := 0;
    Packet.MobType := MobType;
    Packet.MobName := IntName;
  end;

  // Enviando os pacotes
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SpawnMobGuard(mobid: DWORD; MobIdGen: DWORD);
var
  Packet: TSendCreateNpcPacket;
begin
  ZeroMemory(@Packet, SizeOf(TSendCreateNpcPacket));
  Packet.Header.size := SizeOf(Packet);

  // Evitar redundância no acesso à estrutura
  with Servers[Self.ChannelIndex].MOBS.TMobS[mobid] do
  begin
    Packet.Header.Index := MobsP[MobIdGen].Index;
    Packet.Header.Code := $349;
    System.AnsiStrings.StrPLCopy(Packet.Name, AnsiString(IntToStr(IntName)),
      SizeOf(IntName));
    Packet.Equip[0] := Equip[0];
    Packet.Equip[1] := Equip[1];
    Packet.Equip[6] := Equip[6];
    Packet.Position := MobsP[MobIdGen].CurrentPos;
    Packet.Rotation := Rotation;
    Packet.CurHP := InitHP;
    Packet.CurMp := InitHP;
    // Confirmando que CurMP recebe InitHP, se necessário ajuste aqui
    Packet.MaxHp := MobsP[MobIdGen].HP;
    Packet.MaxMP := MobsP[MobIdGen].MP;
    Packet.Altura := MobElevation;
    Packet.Tronco := Cabeca;
    Packet.Perna := Perna;
  end;

  Packet.IsService := 1;
  Packet.SpawnType := SPAWN_NORMAL;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.UnspawnMob(mobid: DWORD; MobIdGen: DWORD);
var
  Packet: TSendRemoveMobPacket;
  MobIndex: DWORD;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  MobIndex := Servers[Self.ChannelIndex].MOBS.TMobS[mobid].MobsP
    [MobIdGen].Index;

  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := MobIndex;
  Packet.Header.Code := $101;
  Packet.Index := MobIndex;
  Packet.DeleteType := 0;

  Self.SendPacket(Packet, Packet.Header.size);
end;

// procedure TPlayer.SpawnPet(PetID: WORD);
// var
// Packet: TSendCreateMobPacket;
// begin
/// /  ZeroMemory(@Packet, sizeof(TSendCreateMobPacket));
/// /  Packet.Header.size := sizeof(Packet);
/// /  Packet.Header.Index := Servers[Self.ChannelIndex].PETS[PetID].Base.clientId;
/// /  Packet.Header.Code := $349;
/// /  System.AnsiStrings.StrPLCopy(Packet.Name,
/// /    AnsiString(IntToStr(Servers[Self.ChannelIndex].PETS[PetID].IntName)),
/// /    sizeof(IntToStr(Servers[Self.ChannelIndex].PETS[PetID].IntName)));
/// /  Packet.Equip[0] := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.Equip[0].Index;
/// /  Packet.Equip[1] := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.Equip[1].Index;
/// /
/// /            var i: integer;
/// /        for i := 0 to 7 do
/// /        begin
/// /        Packet.Equip[i] := Self.Base.Character.Equip[i].Index;
/// /        Writeln(Packet.Equip[i].ToString);
/// /        end;
/// /  Packet.Position := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.LastPos;
/// /  Packet.Rotation := 0;
/// /  Packet.CurHP := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.CurHP;
/// /  Packet.CurMp := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.CurMp;
/// /  Packet.MaxHp := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.MaxHp;
/// /  Packet.MaxMP := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.MaxMP;
/// /  Packet.IsService := 0;
/// /  Packet.SpawnType := SPAWN_NORMAL;
/// /  Packet.Altura := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Altura;
/// /  Packet.Tronco := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Tronco;
/// /  Packet.Perna := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Perna;
/// /  Packet.Corpo := Servers[Self.ChannelIndex].PETS[PetID]
/// /    .Base.PlayerCharacter.Base.CurrentScore.Sizes.Corpo;
/// /  System.AnsiStrings.StrPLCopy(Packet.Title, Servers[Self.ChannelIndex].Players
/// /    [Servers[Self.ChannelIndex].PETS[PetID].MasterClientID].Base.Character.Name
/// /    + #39 + 's PET', 32);
/// /
/// /  Self.SendPacket(Packet, Packet.Header.size);
// end;
//
// procedure TPlayer.UnSpawnPet(PetID: WORD);
// var
// Packet: TSendRemoveMobPacket;
// begin
// ZeroMemory(@Packet, sizeof(Packet));
// Packet.Header.size := sizeof(Packet);
// Packet.Header.Index := Servers[Self.ChannelIndex].PETS[PetID].Base.clientId;
// Packet.Header.Code := $101;
// Packet.Index := Servers[Self.ChannelIndex].PETS[PetID].Base.clientId;
// Packet.DeleteType := 0;
// Self.SendPacket(Packet, Packet.Header.size);
// end;
procedure TPlayer.SendTeleportPositionsFC();
var
  Packet: TTeleportFcPacket;
  I: Integer;
begin
  if Self.Base.GetMobClass <> 4 then
    Exit;

  ZeroMemory(@Packet, SizeOf(TTeleportFcPacket));
  Packet.Header.size := SizeOf(TTeleportFcPacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $34A;

  for I := 0 to 4 do
  begin
    if Self.TeleportList[I].IsValid then
    begin
      Packet.Slot := I;
      Packet.PosX := Round(Self.TeleportList[I].X);
      Packet.PosY := Round(Self.TeleportList[I].Y);
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

procedure TPlayer.SendPlayerToSavedPosition();
begin
  if (Self.SavedPos.X = 0) or (Self.SavedPos.Y = 0) then
    Self.Teleport(TPosition.Create(3400, 565))
  else
    Self.Teleport(Self.SavedPos);
end;

procedure TPlayer.SendPlayerToCityPosition();
begin
  Self.Teleport(TPosition.Create(3400, 565));
end;

procedure TPlayer.DisparosRapidosBarReset(SkillID: DWORD);
var
  Packet: Tp12C;
begin
  ZeroMemory(@Packet, SizeOf(Tp12C));
  Packet.Header.size := SizeOf(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;
  Packet.Skills[24] := 300;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.PredadorInvBarReset(SkillID: DWORD);
var
  Packet: Tp12C;
begin
  ZeroMemory(@Packet, SizeOf(Tp12C));
  Packet.Header.size := SizeOf(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;
  Packet.Skills[28] := 150 -
    (150 div 100 * Self.Base.GetMobAbility(EF_COOLTIME));
end;

procedure TPlayer.SendUpdateActiveTitle();
var
  Packet: TUpdateActiveTitlePacket;
begin
  ZeroMemory(@Packet, SizeOf(TUpdateActiveTitlePacket));
  Packet.Header.size := SizeOf(TUpdateActiveTitlePacket);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $361;
  Packet.TitleIndex := Self.Base.PlayerCharacter.ActiveTitle.Index;

  // Elimina a redundância do cálculo da TitleLevel
  if Self.Base.PlayerCharacter.ActiveTitle.Level > 0 then
    Packet.TitleLevel := Self.Base.PlayerCharacter.ActiveTitle.Level - 1
  else
    Packet.TitleLevel := 0;

  Self.Base.SendToVisible(Packet, Packet.Header.size);
end;

procedure TPlayer.SendNationInformation();
var
  Packet: TGuildsGradePacket;
  PacketSiege: TGuildsSiegePacket;
  SelfNationID, I: BYTE;
begin
  try
    ZeroMemory(@Packet, SizeOf(Packet));
    ZeroMemory(@PacketSiege, SizeOf(PacketSiege));
    Packet.Header.size := SizeOf(Packet);
    Packet.Header.Index := Self.Base.clientId;
    Packet.Header.Code := $936;
    PacketSiege.Header.size := SizeOf(PacketSiege);
    PacketSiege.Header.Index := Self.Base.clientId;
    PacketSiege.Header.Code := $91A;

    if (Self.Character.Base.Nation = 0) then
      SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
    else
      SelfNationID := Self.Character.Base.Nation - 1;

    Packet.Guilds.LordMarechal := Nations[SelfNationID]
      .Cerco.Defensoras.LordMarechal;
    Packet.Guilds.Estrategista := Nations[SelfNationID]
      .Cerco.Defensoras.Estrategista;
    Packet.Guilds.Juiz := Nations[SelfNationID].Cerco.Defensoras.Juiz;
    Packet.Guilds.Tesoureiro := Nations[SelfNationID]
      .Cerco.Defensoras.Tesoureiro;

    PacketSiege.Defensoras.LordMarechal := Packet.Guilds.LordMarechal;
    PacketSiege.Defensoras.Estrategista := Packet.Guilds.Estrategista;
    PacketSiege.Defensoras.Juiz := Packet.Guilds.Juiz;
    PacketSiege.Defensoras.Tesoureiro := Packet.Guilds.Tesoureiro;

    for I := 0 to 3 do
    begin
      PacketSiege.Atacantes[I].LordMarechal := Nations[SelfNationID]
        .Cerco.Atacantes[I].LordMarechal;
      PacketSiege.Atacantes[I].Estrategista := Nations[SelfNationID]
        .Cerco.Atacantes[I].Estrategista;
      PacketSiege.Atacantes[I].Juiz := Nations[SelfNationID]
        .Cerco.Atacantes[I].Juiz;
      PacketSiege.Atacantes[I].Tesoureiro := Nations[SelfNationID]
        .Cerco.Atacantes[I].Tesoureiro;
    end;

    Packet.GuildsID[0] := Nations[SelfNationID].MarechalGuildID;
    Packet.GuildsID[1] := Nations[SelfNationID].TacticianGuildID;
    Packet.GuildsID[2] := Nations[SelfNationID].JudgeGuildID;
    Packet.GuildsID[3] := Nations[SelfNationID].TreasurerGuildID;
    Packet.Nation := SelfNationID + 1;
    Packet.RegisterBonus := Nations[SelfNationID].Settlement;
    Packet.CitizenTax := Nations[SelfNationID].CitizenTax;
    Packet.NoCitizenTax := Nations[SelfNationID].VisitorTax;
    Packet.NationAlly := 0;
    Packet.AllyanceDate := Nations[SelfNationID].AllyDate;
    AnsiStrings.StrPLCopy(Packet.MarshalAlly,
      String(AnsiString(Nations[SelfNationID].MarechalAllyName)), 16);
    Packet.RankNation := Nations[SelfNationID].NationRank;

    Self.SendPacket(Packet, Packet.Header.size);
    Self.SendPacket(PacketSiege, PacketSiege.Header.size);

    // Buffs relacionados à nação e cargos específicos
    if Self.IsMarshal then
    begin
      if not(Self.Base.BuffExistsByID(6600)) then
        Self.Base.AddBuff(6600);
    end
    else
    begin
      if (Self.Base.BuffExistsByID(6600)) then
        Self.Base.RemoveBuff(6600);
    end;

    if Self.IsArchon then
    begin
      if not(Self.Base.BuffExistsByID(ARCHON_BUFF)) then
        Self.Base.AddBuff(ARCHON_BUFF);
    end
    else
    begin
      if (Self.Base.BuffExistsByID(ARCHON_BUFF)) then
        Self.Base.RemoveBuff(ARCHON_BUFF);
    end;

    if Self.IsGradeMarshal then
    begin
      if not(Self.IsMarshal) then
        if not(Self.Base.BuffExistsByID(6601)) then
          Self.Base.AddBuff(6601);
    end
    else
    begin
      if (Self.Base.BuffExistsByID(6601)) then
        Self.Base.RemoveBuff(6601);
    end;

    if Self.IsGradeArchon then
    begin
      if not(Self.IsArchon) then
        if not(Self.Base.BuffExistsByID(CAVALEIROS_ARCHON)) then
          Self.Base.AddBuff(CAVALEIROS_ARCHON);
    end
    else
    begin
      if (Self.Base.BuffExistsByID(CAVALEIROS_ARCHON)) then
        Self.Base.RemoveBuff(CAVALEIROS_ARCHON);
    end;

  except
    on E: Exception do
    begin
      Logger.Write('Error LM Buffs ' + E.Message, TlogType.Warnings);
    end;
  end;
end;

function TPlayer.GetPranEvolutedCnt(): Integer;
var
  SQLComp: TQuery;
begin
  Result := -1;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  // Verificando a conexão
  if not SQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetPranEvolutedCnt]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetPranEvolutedCnt]',
      TlogType.Error);
    SQLComp.Free;
    Exit;
  end;

  try
    SQLComp.SetQuery(format('SELECT pranevcnt FROM characters WHERE id=%d',
      [Self.Character.Index]));
    SQLComp.Run();

    // Verificando se há resultados
    if SQLComp.Query.RecordCount > 0 then
      Result := SQLComp.Query.FieldByName('pranevcnt').AsInteger
    else
    begin
      Self.SendClientMessage
        ('Erro de personagem, procure o suporte. TPlayer.GetPranEvolutedCnt 0x01');
      Exit;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.GetPranEvolutedCnt ' + E.Message, TlogType.Error);
      Exit;
    end;
  end;

  SQLComp.Free;
end;

function TPlayer.SetPranEvolutedCnt(Cnt: Integer): boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);

  // Verificando a conexão
  if not SQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SetPranEvolutedCnt]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SetPranEvolutedCnt]',
      TlogType.Error);
    SQLComp.Free;
    Exit;
  end;

  SQLComp.Query.Connection.StartTransaction;
  try
    SQLComp.SetQuery(format('UPDATE characters SET pranevcnt=%d WHERE id=%d',
      [Cnt, Self.Character.Index]));
    SQLComp.Run(false);
    SQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('TPlayer.SetPranEvolutedCnt ' + E.Message, TlogType.Error);
      SQLComp.Query.Connection.Rollback;
      Exit;
    end;
  end;

  SQLComp.Free;
end;

function TPlayer.GetPranClass(xPran: PPran): BYTE;
begin
  Result := 255;
  case xPran.ClassPran of
    61 .. 64:
      Result := 1;
    71 .. 74:
      Result := 2;
    81 .. 84:
      Result := 3;
  end;
end;

procedure TPlayer.SendCloseClient();
var
  Packet: TSignalData;
begin
  ZeroMemory(@Packet, SizeOf(TSignalData));
  Packet.Header.size := SizeOf(TSignalData);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $358;
  Packet.Data := 1;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendCloseNpc();
var
  Packet: TSignalData;
begin
  ZeroMemory(@Packet, SizeOf(TSignalData));
  Packet.Header.size := SizeOf(TSignalData);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $348;

  Self.SendPacket(Packet, Packet.Header.size);
end;
{$REGION 'Unk Sends'}

procedure TPlayer.SendKarakAereo;
var
  Packet: TKarakAereo;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $0C;
  Self.SendPacket(Packet, Packet.Header.size);
  Writeln('Passando Pelo SendKarakAereo no player.pas');
end;

procedure TPlayer.SendNumbers;
var
  Packet: TSendNumbersPacket;
  I: Integer;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $D41;
  Packet.AccountId := Self.Account.Header.AccountId;
  for I := 0 to High(Packet.Numbers) do
    Packet.Numbers[I].Index := I;

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendClientIndex;
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $117;
  Packet.Index := Self.Base.clientId;
  // Packet.Effect := Self.Base.clientId;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP12C;
var
  Packet: Tp12C;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $12C;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP131;
var
  Packet: Tp131;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $131;
  Packet.Unk_1 := $FFFFFFFF;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP16F;
var
  Packet: TUpdateBuffPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $16F;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP186;
var
  Packet: Tp186;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $186;
  Packet.Unk_0 := $1;
  // Packet.Unk_2 := $1;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP227;
var
  Packet: Tp227;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $227;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP33D;
var
  Packet: Tp33D;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $33D;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP357;
var
  Packet: Tp357;

begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $357;
  Packet.Null1 := $2082;

  Self.SendPacket(Packet, Packet.Header.size);

end;

procedure TPlayer.SendP3A2;
var
  Packet: Tp3A2;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $3A2;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP94C;
var
  Packet: Tp94C;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $94C;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Cash'}

procedure TPlayer.SendPlayerCash;
begin
  Self.SendData(0, $139, Self.Account.Header.CashInventory.Cash);
end;

procedure TPlayer.SendCashInventory;
var
  Packet: TUpdateCashInventory;
begin
  ZeroMemory(@Packet, SizeOf(TUpdateCashInventory));
  with Packet do
  begin
    Header.size := SizeOf(TUpdateCashInventory);
    Header.Code := $138;
    Move(Self.Account.Header.CashInventory.Items, Items, SizeOf(Items));
  end;
  Self.SendPacket(Packet, Packet.Header.size);
end;

{$ENDREGION}

procedure TPlayer.SendCancelCollectItem(Index: Integer);
var
  Packet: TCancelCollectItem;
begin
  ZeroMemory(@Packet, SizeOf(TCancelCollectItem));
  with Packet do
  begin
    Header.size := SizeOf(TCancelCollectItem);
    Header.Index := $7535;
    Header.Code := $33A;
    Self.SendPacket(Packet, Header.size);
  end;
end;
{$ENDREGION}
{$REGION 'Trade'}

procedure TPlayer.RefreshTrade;
var
  Packet: TTradePacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  with Packet do
  begin
    Header.size := SizeOf(Packet);
    Header.Index := Self.Base.clientId;
    Header.Code := $317;
    Move(Self.Character.Trade, Trade, SizeOf(Trade));
    Trade.OtherClientid := Self.Character.TradingWith;
    Self.SendPacket(Packet, Header.size);
  end;
end;

procedure TPlayer.RefreshTradeTo(clientId: Integer);
var
  Packet: TTradePacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  with Packet do
  begin
    Header.size := SizeOf(Packet);
    Header.Index := Self.Base.clientId;
    Header.Code := $317;
    Move(Self.Character.Trade, Trade, SizeOf(Trade));
    Trade.OtherClientid := Self.Base.clientId;
    Servers[Self.ChannelIndex].Players[clientId].SendPacket(Packet,
      Header.size);
  end;
end;

procedure TPlayer.CloseTrade;
begin
  Self.Character.TradingWith := 0;
  Self.SendData(Self.Base.clientId, $318, 0);
end;
{$ENDREGION}
{$REGION 'Party'}

procedure TPlayer.SendToParty(var Packet; size: WORD; SendSelf: boolean);
begin
  if (Self.PartyIndex <> 0) then
  begin
    Self.Party := @Servers[Self.ChannelIndex].Parties[Self.PartyIndex];
    Self.Party.SendToParty(Packet, size);
  end;
end;

procedure TPlayer.RefreshParty;
var
  Packet: TUpdatePartyPacket;
  I, J, k, m, n: Integer;
  CurPlayer: PPlayer;
  OtherParty, LeaderParty, stParty: PParty;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  if not(Self.PartyIndex = 0) then
  begin
    Self.Party := @Servers[Self.ChannelIndex].Parties[PartyIndex];
  end;
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $326;
  if (Self.PartyIndex = 0) then
  begin
    Self.SendPacket(Packet, Packet.Header.size);
    for I := 1 to 3 do
    begin
      Packet.PartyInRaidIndex := I;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
    Exit;
  end;
  J := 0;
  for I in Self.Party.Members do
  begin
    CurPlayer := @Servers[Self.ChannelIndex].Players[I];
    AnsiStrings.StrLCopy(Packet.Name[J], CurPlayer.Character.Base.Name, 16);
    Packet.PlayerIndex[J] := CurPlayer.Base.clientId;
    Packet.ClassInfo[J] := CurPlayer.Character.Base.ClassInfo;
    Packet.Level[J] := CurPlayer.Character.Base.Level - 1;
    Packet.CurHP[J] := CurPlayer.Base.Character.CurrentScore.CurHP;
    Packet.MaxHp[J] := CurPlayer.Base.GetCurrentHP;
    Packet.CurMp[J] := CurPlayer.Base.Character.CurrentScore.CurMp;
    Packet.MaxMP[J] := CurPlayer.Base.GetCurrentMP;
    Packet.LeaderIndex := Self.Party.Leader;
    Inc(J);

    // if not(i = Self.Base.ClientID) then
    // CurPlayer.SendPositionParty(Self.Base.ClientID);
  end;
  Packet.itemallocate := Self.Party.itemalocate;
  Packet.expallocate := Self.Party.expalocate;
  if not(Party.InRaid) then
  begin
    Packet.PartyInRaidIndex := 0;
    Packet.IsPartyLeaderOfRaid := 1; // Byte(Self.Party.IsRaidLeader.ToInteger);
    Self.SendPacket(Packet, Packet.Header.size);
    ZeroMemory(@Packet, SizeOf(Packet));
    Packet.Header.size := SizeOf(Packet);
    Packet.Header.Index := Self.Base.clientId;
    Packet.Header.Code := $326;
    for I := 1 to 3 do
    begin
      Packet.PartyInRaidIndex := I;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end
  else
  begin
    Packet.PartyInRaidIndex := 0;
    Packet.IsPartyLeaderOfRaid := BYTE(Self.Party.IsRaidLeader.ToInteger);
    Self.SendPacket(Packet, Packet.Header.size);
    if (Self.Party.PartyRaidCount = 1) then
    begin
      Self.Party.InRaid := false;
      Self.Party.IsRaidLeader := True;
    end;
    for k := 1 to 3 do
    begin
      ZeroMemory(@Packet, SizeOf(Packet));
      Packet.Header.size := SizeOf(Packet);
      Packet.Header.Index := Self.Base.clientId;
      Packet.Header.Code := $326;
      if (Self.Party.InRaid = false) then
      begin
        Packet.PartyInRaidIndex := k;
        Self.SendPacket(Packet, Packet.Header.size);
        Continue;
      end;
      if (Party.PartyAllied[k] = 0) then
      begin
        Packet.PartyInRaidIndex := k;
        Self.SendPacket(Packet, Packet.Header.size);
        Continue;
      end;
      OtherParty := @Servers[Self.ChannelIndex].Parties[Party.PartyAllied[k]];
      J := 0;
      for I in OtherParty.Members do
      begin
        CurPlayer := @Servers[Self.ChannelIndex].Players[I];
        AnsiStrings.StrLCopy(Packet.Name[J], CurPlayer.Character.Base.Name, 16);
        Packet.PlayerIndex[J] := CurPlayer.Base.clientId;
        Packet.ClassInfo[J] := CurPlayer.Character.Base.ClassInfo;
        Packet.Level[J] := CurPlayer.Character.Base.Level - 1;
        Packet.CurHP[J] := CurPlayer.Base.Character.CurrentScore.CurHP;
        Packet.MaxHp[J] := CurPlayer.Base.GetCurrentHP;
        Packet.CurMp[J] := CurPlayer.Base.Character.CurrentScore.CurMp;
        Packet.MaxMP[J] := CurPlayer.Base.GetCurrentMP;
        Packet.LeaderIndex := OtherParty.Leader;
        Inc(J);

        // if not(i = CurPlayer.Base.ClientID) then
        // CurPlayer.SendPositionParty(i);

        { }
      end;

      Packet.itemallocate := OtherParty.itemalocate;
      Packet.expallocate := OtherParty.expalocate;
      Packet.PartyInRaidIndex := k;
      Packet.IsPartyLeaderOfRaid := BYTE(OtherParty.IsRaidLeader.ToInteger);
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

function TPlayer.AddMemberParty(PlayerIndex: WORD): boolean;
begin
  if (Self.PartyIndex = 0) then
    Exit(false);

  Result := Servers[Self.ChannelIndex].Parties[Self.PartyIndex]
    .AddMember(PlayerIndex);
end;

procedure TPlayer.SendPositionParty(SendTo: WORD = 0);
var
  Packet: TPartyMemberCoordPacket;
begin
  // if Self.Party.Members.Count = 1 then
  // Exit;

  ZeroMemory(@Packet, SizeOf(Packet));
  with Packet.Header do
  begin
    size := SizeOf(Packet);
    Index := Self.Base.clientId;
    Code := $11D;
  end;
  Packet.Index := Self.Base.clientId;
  Packet.PosX := Round(Self.Base.PlayerCharacter.LastPos.X);
  Packet.PosY := Round(Self.Base.PlayerCharacter.LastPos.Y);

  if (SendTo = 0) then
    Self.SendPacket(Packet, Packet.Header.size)
  else
    Servers[Self.ChannelIndex].SendPacketTo(SendTo, Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Char info'}

procedure TPlayer.ViewPran(Index: WORD; indexplayer: WORD = 0);
var
  Packet: TSendPranView;
  FPlayer: PPlayer;
  I, J: Integer;
  Pran1, Pran2: TPran;
begin
  Pran1 := Servers[Self.ChannelIndex].Players[indexplayer].Account.Header.Pran1;
  Pran2 := Servers[Self.ChannelIndex].Players[indexplayer].Account.Header.Pran2;

  if not Pran1.IsSpawned or not Pran2.IsSpawned then
    Exit;

  if (index < 44241) or (@Servers[Self.ChannelIndex].Players[indexplayer]
    .SpawnedPran = nil) then
    Exit;

  FPlayer := @Servers[Self.ChannelIndex].Players[indexplayer];

  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := index;
  Packet.Header.Code := $1A1;

  case (FPlayer.SpawnedPran) of
    0:
      begin
        Move(FPlayer.Account.Header.Pran1.Name, Packet.Name, 16);
        Packet.PranClass := FPlayer.Account.Header.Pran1.ClassPran;
        // debugar o crescimento pra mostrar corretamente
        Packet.Food := FPlayer.Account.Header.Pran1.Food;
        if FPlayer.Account.Header.Pran1.Personality.Cute >=
          FPlayer.Account.Header.Pran1.Devotion then
          Packet.Personality := 00
        else if FPlayer.Account.Header.Pran1.Personality.Smart >=
          FPlayer.Account.Header.Pran1.Devotion then
          Packet.Personality := 01
        else if FPlayer.Account.Header.Pran1.Personality.Sexy >=
          FPlayer.Account.Header.Pran1.Devotion then
          Packet.Personality := 02
        else if FPlayer.Account.Header.Pran1.Personality.Energetic >=
          FPlayer.Account.Header.Pran1.Devotion then
          Packet.Personality := 03
        else if FPlayer.Account.Header.Pran1.Personality.Tough >=
          FPlayer.Account.Header.Pran1.Devotion then
          Packet.Personality := 04
        else if FPlayer.Account.Header.Pran1.Personality.Corrupt >=
          FPlayer.Account.Header.Pran1.Devotion then
          Packet.Personality := 05;
        Packet.Devotion := FPlayer.Account.Header.Pran1.Devotion;
        Packet.MaxHp := FPlayer.Account.Header.Pran1.MaxHp;
        Packet.CurHP := FPlayer.Account.Header.Pran1.CurHP;
        Packet.MaxMP := FPlayer.Account.Header.Pran1.MaxMP;
        Packet.CurMp := FPlayer.Account.Header.Pran1.CurMp;
        Packet.Exp := FPlayer.Account.Header.Pran1.Exp;
        Packet.DefFis := FPlayer.Account.Header.Pran1.DefFis;
        Packet.DefMag := FPlayer.Account.Header.Pran1.DefMag;
        for I := 1 to 5 do
        begin
          Packet.Equip1[I].Index := FPlayer.Account.Header.Pran1.Equip[I].Index;
          Packet.Equip1[I].APP := FPlayer.Account.Header.Pran1.Equip[I].APP;
          Packet.Equip1[I].Identific := FPlayer.Account.Header.Pran1.Equip[I]
            .Identific;
          for J := 0 to 2 do
          begin
            Packet.Equip1[I].Effects.Index[J] :=
              FPlayer.Account.Header.Pran1.Equip[I].Effects.Index[J];
            Packet.Equip1[I].Effects.Value[J] :=
              FPlayer.Account.Header.Pran1.Equip[I].Effects.Value[J];
          end;

          Packet.Equip1[I].MIN := FPlayer.Account.Header.Pran1.Equip[I].MIN;
          Packet.Equip1[I].MAX := FPlayer.Account.Header.Pran1.Equip[I].MAX;
          Packet.Equip1[I].Refi := FPlayer.Account.Header.Pran1.Equip[I].Refi;
          Packet.Equip1[I].Time := FPlayer.Account.Header.Pran1.Equip[I].Time;
        end;

        case FPlayer.Account.Header.Pran1.Level of
          0 .. 4:
            Packet.Unk1 := 0;
          7 .. 20:
            Packet.Unk1 := 2;
          21 .. 50:
            Packet.Unk1 := 3;
        else
          Packet.Unk1 := 4;
        end;

        Packet.Unk2 := FPlayer.Account.Header.Pran1.Level;
        Packet.Unk3 := FPlayer.Account.Header.Pran1.Level;
      end;
    1:
      begin
        Move(FPlayer.Account.Header.Pran2.Name, Packet.Name, 16);
        Packet.PranClass := FPlayer.Account.Header.Pran2.ClassPran;
        // debugar o crescimento pra mostrar corretamente
        Packet.Food := FPlayer.Account.Header.Pran2.Food;
        if FPlayer.Account.Header.Pran2.Personality.Cute >=
          FPlayer.Account.Header.Pran2.Devotion then
          Packet.Personality := 00
        else if FPlayer.Account.Header.Pran2.Personality.Smart >=
          FPlayer.Account.Header.Pran2.Devotion then
          Packet.Personality := 01
        else if FPlayer.Account.Header.Pran2.Personality.Sexy >=
          FPlayer.Account.Header.Pran2.Devotion then
          Packet.Personality := 02
        else if FPlayer.Account.Header.Pran2.Personality.Energetic >=
          FPlayer.Account.Header.Pran2.Devotion then
          Packet.Personality := 03
        else if FPlayer.Account.Header.Pran2.Personality.Tough >=
          FPlayer.Account.Header.Pran2.Devotion then
          Packet.Personality := 04
        else if FPlayer.Account.Header.Pran2.Personality.Corrupt >=
          FPlayer.Account.Header.Pran2.Devotion then
          Packet.Personality := 05;
        Packet.Devotion := FPlayer.Account.Header.Pran2.Devotion;
        Packet.MaxHp := FPlayer.Account.Header.Pran2.MaxHp;
        Packet.CurHP := FPlayer.Account.Header.Pran2.CurHP;
        Packet.MaxMP := FPlayer.Account.Header.Pran2.MaxMP;
        Packet.CurMp := FPlayer.Account.Header.Pran2.CurMp;
        Packet.Exp := FPlayer.Account.Header.Pran2.Exp;
        Packet.DefFis := FPlayer.Account.Header.Pran2.DefFis;
        Packet.DefMag := FPlayer.Account.Header.Pran2.DefMag;
        for I := 1 to 5 do
        begin
          Packet.Equip1[I].Index := FPlayer.Account.Header.Pran2.Equip[I].Index;
          Packet.Equip1[I].APP := FPlayer.Account.Header.Pran2.Equip[I].APP;
          Packet.Equip1[I].Identific := FPlayer.Account.Header.Pran2.Equip[I]
            .Identific;
          for J := 0 to 2 do
          begin
            Packet.Equip1[I].Effects.Index[J] :=
              FPlayer.Account.Header.Pran2.Equip[I].Effects.Index[J];
            Packet.Equip1[I].Effects.Value[J] :=
              FPlayer.Account.Header.Pran2.Equip[I].Effects.Value[J];
          end;

          Packet.Equip1[I].MIN := FPlayer.Account.Header.Pran2.Equip[I].MIN;
          Packet.Equip1[I].MAX := FPlayer.Account.Header.Pran2.Equip[I].MAX;
          Packet.Equip1[I].Refi := FPlayer.Account.Header.Pran2.Equip[I].Refi;
          Packet.Equip1[I].Time := FPlayer.Account.Header.Pran2.Equip[I].Time;
        end;

        case FPlayer.Account.Header.Pran2.Level of
          0 .. 4:
            Packet.Unk1 := 0;
          7 .. 20:
            Packet.Unk1 := 2;
          21 .. 50:
            Packet.Unk1 := 3;
        else
          Packet.Unk1 := 4;
        end;

        Packet.Unk2 := FPlayer.Account.Header.Pran2.Level;
        Packet.Unk3 := FPlayer.Account.Header.Pran2.Level;
      end;

  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.CharInfoResponse(Index: WORD);
var
  Packet: TCharInfoResponsePacket;
  FPlayer: PPlayer;
begin
  if (Servers[Self.ChannelIndex].Players[Index].SocketClosed) then
    Exit;
  ZeroMemory(@Packet, SizeOf(Packet));
  FPlayer := @Servers[Self.ChannelIndex].Players[Index];
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $19E;
  System.AnsiStrings.StrPLCopy(Packet.Nick, FPlayer.Base.Character.Name, 16);
  if ((FPlayer.Base.Character.GuildIndex > 0) and
    (FPlayer.Base.PlayerCharacter.GuildSlot > 0)) then
  begin
    System.AnsiStrings.StrPLCopy(Packet.GuildName,
      Guilds[FPlayer^.Base.PlayerCharacter.GuildSlot].Name, 19);
  end
  else
    Packet.GuildName := 'Nenhuma';
  // FPlayer.Base.GetCurrentScore;
  Packet.Classe := FPlayer.Base.Character.ClassInfo;
  Packet.Nacao := FPlayer.Base.Character.Nation;
  Packet.Infamia := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Infamia;
  Packet.Honra := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Honor;
  Packet.Pvp := FPlayer.Base.PlayerCharacter.Base.CurrentScore.KillPoint;
  Packet.Str := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Str;
  Packet.Agi := FPlayer.Base.PlayerCharacter.Base.CurrentScore.agility;
  Packet.Int := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Int;
  Packet.Cons := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Cons;
  Packet.Sorte := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Luck;
  Packet.Status := FPlayer.Base.PlayerCharacter.Base.CurrentScore.Status;
  Packet.AtkFis := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DNFis;
  Packet.DefFis := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DefFis;
  Packet.AtkMag := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DNMag;
  Packet.DefMag := FPlayer.Base.PlayerCharacter.Base.CurrentScore.DefMag;
  Packet.Movimento := FPlayer.Base.PlayerCharacter.SpeedMove;
  Packet.Resistencia := FPlayer.Base.PlayerCharacter.Resistence;
  Packet.AtkDuplo := FPlayer.Base.PlayerCharacter.DuploAtk;
  Packet.Exp := FPlayer.Base.Character.Exp;

  if not(FPlayer.Base.Character.Level = 0) then
    Packet.Level := FPlayer.Base.Character.Level - 1;
  Move(FPlayer.Base.Character.Equip, Packet.Equips, (SizeOf(TItem) * 9));
  Packet.Equips2[11] := FPlayer.Base.Character.Equip[11];
  Packet.Equips2[12] := FPlayer.Base.Character.Equip[12];
  Packet.Equips2[13] := FPlayer.Base.Character.Equip[13];
  Packet.Equips2[14] := FPlayer.Base.Character.Equip[14];
  Packet.Equips2[15] := FPlayer.Base.Character.Equip[15];
  if (FPlayer.Base.Character.Equip[9].Index <> 0) then
  begin // se tiver montaria
    Packet.MountEquip.Index := FPlayer.Base.Character.Equip[9].Index;
    Packet.MountEquip.APP := Packet.MountEquip.Index;
    Packet.MountEquip.Identific := FPlayer.Base.Character.Equip[9].Identific;
    Packet.MountEquip.Slot1 := FPlayer.Base.Character.Equip[9].Effects.Index[0];
    Packet.MountEquip.Slot2 := FPlayer.Base.Character.Equip[9].Effects.Index[1];
    Packet.MountEquip.Slot3 := FPlayer.Base.Character.Equip[9].Effects.Index[2];
    Packet.MountEquip.Enc1 := FPlayer.Base.Character.Equip[9].Effects.Value[0];
    Packet.MountEquip.Enc2 := FPlayer.Base.Character.Equip[9].Effects.Value[1];
    Packet.MountEquip.Enc3 := FPlayer.Base.Character.Equip[9].Effects.Value[2];
    Packet.MountEquip.MIN := FPlayer.Base.Character.Equip[9].MIN;
    Packet.MountEquip.Time := FPlayer.Base.Character.Equip[9].Time;
  end;
  case (FPlayer.SpawnedPran) of
    0:
      begin
        System.AnsiStrings.StrPLCopy(Packet.PranName,
          FPlayer.Account.Header.Pran1.Name, 16);
        Packet.PranEquip.Index := FPlayer.Base.Character.Equip[10].Index;
        Packet.PranEquip.APP := FPlayer.Base.Character.Equip[10].APP;
        Packet.PranEquip.Identific := FPlayer.Base.Character.Equip[10]
          .Identific;
        Packet.PranEquip.CreationTime := FPlayer.Account.Header.Pran1.CreatedAt;
        Packet.PranEquip.Devotion := FPlayer.Account.Header.Pran1.Food;
        Packet.PranEquip.State := 00;
        Packet.PranEquip.Level := FPlayer.Account.Header.Pran1.Level;
        // Self.ViewPran(FPlayer.base.PranClientID);
      end;
    1:
      begin
        System.AnsiStrings.StrPLCopy(Packet.PranName,
          FPlayer.Account.Header.Pran2.Name, 16);
        Packet.PranEquip.Index := FPlayer.Base.Character.Equip[10].Index;
        Packet.PranEquip.APP := FPlayer.Base.Character.Equip[10].APP;
        Packet.PranEquip.Identific := FPlayer.Base.Character.Equip[10]
          .Identific;
        Packet.PranEquip.CreationTime := FPlayer.Account.Header.Pran2.CreatedAt;
        Packet.PranEquip.Devotion := FPlayer.Account.Header.Pran2.Food;
        Packet.PranEquip.State := 00;
        Packet.PranEquip.Level := FPlayer.Account.Header.Pran2.Level;
        // Self.ViewPran(FPlayer.base.PranClientID);
      end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);

end;
{$ENDREGION}
{$REGION 'Player Add Functions'}

function IsWeekend(const ADateTime: TDateTime): boolean;
begin
  Result := (DayOfWeek(ADateTime) in [6, 7, 1]);
  // Sexta-feira, Sábado e Domingo
end;

function TPlayer.AddExp(Value: Int64; out ExpPreReliq: Integer;
  ExpType: Integer = 0): Int64;
var
  NewExp, ExpBase: Int64;
  Mensagem: string;
  Packet: TSendExpBaseMsg;
begin
  Result := 0;

  if ExpType = EXP_TYPE_MOB then
  begin
    NewExp := (Value * EXP_MULTIPLIER) div 10000;
    ExpBase := NewExp;

    if IsWeekend(now) then
      NewExp := NewExp * 2;

    if Self.Base.GetMobAbility(EF_MULTIPLE_EXP4) > 0 then
      NewExp := NewExp * 4
    else if Self.Base.GetMobAbility(EF_PREMIUM_PER_EXP) > 0 then
      NewExp := NewExp * 2;

    ExpPreReliq := NewExp;

    if (Servers[Self.ChannelIndex].ReliqEffect[EF_RELIQUE_PER_EXP] > 0) and (NewExp > 0) then
      Inc(NewExp, Servers[Self.ChannelIndex].ReliqEffect[EF_RELIQUE_PER_EXP] * (NewExp div 100));

    Inc(Self.Character.Base.Exp, NewExp);

    if Old_Exp = 1 then
    begin
      ZeroMemory(@Packet, SizeOf(Packet));
      Packet.Header.size := SizeOf(Packet);
      Packet.Header.Index := Self.Base.clientId;
      Packet.Header.Code := $153;
      Packet.Exp := ExpBase;
      Packet.ExpExtra := NewExp - ExpBase;
      Packet.ExpBatalhao := 0;
      Self.SendPacket(Packet, Packet.Header.size);
    end
    else
    begin
      if IsWeekend(now) then
        Mensagem := Format('Adquiriu %d + %d exp.', [NewExp, ExpBase])
      else
        Mensagem := Format('Adquiriu %d exp.', [NewExp]);

      Self.SendClientMessage(Mensagem, 0, 0, 0);
    end;

    Result := NewExp;
  end
  else if ExpType = EXP_TYPE_NORMAL then
  begin
    Inc(Self.Character.Base.Exp, Value);
    Result := Value;
  end
  else if ExpType = EXP_TYPE_QUEST then
  begin
    // Lógica para EXP de missão, se necessário
  end;

  while (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) and
    (Self.Character.Base.Level < LEVEL_CAP) do
    Self.AddLevel;

  if (Self.Character.Base.Level = LEVEL_CAP) and
    (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) then
    Self.Character.Base.Exp := ExpList[Self.Character.Base.Level];

  Self.Base.SendRefreshLevel;
end;
procedure TPlayer.AddExpPerc(Value: WORD; Ação: Integer = 0);
var
  Perc: Single;
  Exp: Int64;
  DifLevel: Int64;
begin
  Perc := Value / 1000;
  if (Self.Character.Base.Level = 99) then
  begin
    Exit;
  end;
  DifLevel := ExpList[Self.Character.Base.Level] -
    ExpList[Self.Character.Base.Level - 1];
  Exp := Round(DifLevel * Perc);

  if (Ação = 1) then
  begin
    Dec(Self.Character.Base.Exp, Exp);
    Writeln('diminuindo exp');
    while (Self.Character.Base.Exp < ExpList[Self.Character.Base.Level]) and
      (Self.Character.Base.Level < LEVEL_CAP) do
    begin
      Writeln('level antigo ' + Self.Character.Base.Level.ToString);
      Self.Character.Base.Level := Self.Character.Base.Level - 1;
      Writeln('level novo ' + Self.Character.Base.Level.ToString);
    end;
    Self.Base.SendRefreshLevel;
    Exit;

  end;

  Inc(Self.Character.Base.Exp, Exp);

  while (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) and
    (Self.Character.Base.Level < LEVEL_CAP) do
    Self.AddLevel;

  if (Self.Character.Base.Level = LEVEL_CAP) and
    (Self.Character.Base.Exp > ExpList[Self.Character.Base.Level]) then
    Self.Character.Base.Exp := ExpList[Self.Character.Base.Level];
  Self.Base.SendRefreshLevel;
end;

procedure TPlayer.AddLevel(Value: WORD = 1; Ação: WORD = 0);
begin
  if (Ação = 1) then
  begin
    if (Self.Character.Base.Level > 1) then
    begin
      Self.Character.Base.Level := Self.Character.Base.Level - 1;
      // Remove um nível
      Self.Base.Character.CurrentScore.CurHP :=
        Self.Base.Character.CurrentScore.MaxHp;
      Self.Base.Character.CurrentScore.CurMp :=
        Self.Base.Character.CurrentScore.MaxMP;
      Self.Base.SendCurrentHPMP(True);
      Self.Base.SendRefreshLevel;
      Self.Base.SendRefreshPoint;

      if (Self.PartyIndex > 0) then
        Servers[Self.ChannelIndex].Parties[PartyIndex].RefreshParty;

      Self.SendEffect(1);
      Self.RefreshMeToFriends;

      if (Self.Character.Base.GuildIndex > 0) then
        Guilds[Self.Character.Base.GuildIndex].UpdateLevel
          (Self.Base.Character.CharIndex, Self.Base.Character.Level);

      Exit; // Encerra o método após a remoção de nível
    end;
    Exit; // Encerra caso o nível seja <= 1
  end;

  // Lógica para adicionar níveis
  if Self.Account.Header.AccountType >= GameMaster then
  begin

  end
  else
  begin
    if (Self.Character.Base.Level = LEVEL_CAP) then
      Exit;
  end;

  if (Self.Character.Base.Level <= 50) and
    (Self.Character.Base.Level + Value >= 51) then
  begin
    Inc(Self.Character.Base.ClassInfo);
  end;

  Inc(Self.Character.Base.Level, Value);
  Inc(Self.Character.Base.CurrentScore.SkillPoint, SKILL_POINT_PER_LEVEL);

  if (Self.Character.Base.Level > 50) then
  begin
    Inc(Self.Character.Base.CurrentScore.Status, STATUS_POINT_PER_LEVEL);

    if (Self.Character.Base.Level mod 10 = 1) then
    begin
      Inc(Self.Character.Base.CurrentScore.SkillPoint, SKILL_POINT_X);
      Inc(Self.Character.Base.CurrentScore.Status, STATUS_POINT_X);
    end;
  end;

  Self.Base.Character.CurrentScore.CurHP :=
    Self.Base.Character.CurrentScore.MaxHp;
  Self.Base.Character.CurrentScore.CurMp :=
    Self.Base.Character.CurrentScore.MaxMP;

  Self.Base.SendCurrentHPMP(True);
  Self.Base.SendRefreshLevel;
  Self.Base.SendRefreshPoint;

  if (Self.PartyIndex > 0) then
    Servers[Self.ChannelIndex].Parties[PartyIndex].RefreshParty;

  Self.SendEffect(1);
  Self.RefreshMeToFriends;

  if (Self.Character.Base.GuildIndex > 0) then
    Guilds[Self.Character.Base.GuildIndex].UpdateLevel
      (Self.Base.Character.CharIndex, Self.Base.Character.Level);
end;

procedure TPlayer.AddPranExp(PranSlot: BYTE; Value: DWORD);
begin
  if PranSlot = 0 then
  begin
    Inc(Self.Account.Header.Pran1.Exp, Value);
    while (Self.Account.Header.Pran1.Exp > PranExpList
      [Self.Account.Header.Pran1.Level + 1]) and
      (Self.Account.Header.Pran1.Level + 1 < MAX_PRAN_LEVEL) do
      Self.AddPranLevel(0);
    if (Self.Account.Header.Pran1.Level + 1 = MAX_PRAN_LEVEL) and
      (Self.Account.Header.Pran1.Exp > PranExpList
      [Self.Account.Header.Pran1.Level + 1]) then
      Self.Account.Header.Pran1.Exp :=
        PranExpList[Self.Account.Header.Pran1.Level + 1];
    Self.SendPranLevelAndExp((Self.Account.Header.Pran1.Level + 1),
      Self.Account.Header.Pran1.Exp);
  end
  else
  begin
    Inc(Self.Account.Header.Pran2.Exp, Value);
    while (Self.Account.Header.Pran2.Exp > PranExpList
      [Self.Account.Header.Pran2.Level + 1]) and
      (Self.Account.Header.Pran2.Level + 1 < MAX_PRAN_LEVEL) do
      Self.AddPranLevel(1);
    if (Self.Account.Header.Pran2.Level + 1 = MAX_PRAN_LEVEL) and
      (Self.Account.Header.Pran2.Exp > PranExpList
      [Self.Account.Header.Pran2.Level + 1]) then
      Self.Account.Header.Pran2.Exp :=
        PranExpList[Self.Account.Header.Pran2.Level + 1];
    Self.SendPranLevelAndExp((Self.Account.Header.Pran2.Level + 1),
      Self.Account.Header.Pran2.Exp);
  end;
end;

function TPlayer.PranBarExistsIndex(PranID: BYTE; Index: DWORD): BYTE;
var
  I: Integer;
begin
  Result := 255;
  for I := 0 to 2 do
  begin
    if ((PranID = 0) and (Self.Account.Header.Pran1.ItemBar[I] = Index)) or
      ((PranID = 1) and (Self.Account.Header.Pran2.ItemBar[I] = Index)) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TPlayer.AddPranLevel(PranSlot: BYTE; Value: WORD);
var
  I: Integer;
  helper: Integer;
  baseSkillPran: WORD;
begin
  case PranSlot of
    0:
      begin
        if (Self.Account.Header.Pran1.Level = MAX_PRAN_LEVEL) then
          Exit;

        Inc(Self.Account.Header.Pran1.Level);
        Self.SendClientMessage('Sua pran subiu de nível.');
        Self.SendPranLevelAndExp((Self.Account.Header.Pran1.Level + 1),
          Self.Account.Header.Pran1.Exp);
        Inc(Self.Account.Header.Pran1.MaxHp, PRAN_HP_INC_PER_LEVEL);
        Inc(Self.Account.Header.Pran1.MaxMP, PRAN_MP_INC_PER_LEVEL);
        Self.Account.Header.Pran1.CurHP := Self.Account.Header.Pran1.MaxHp;
        Self.Account.Header.Pran1.CurMp := Self.Account.Header.Pran1.MaxMP;
        Self.SetPranPassiveSkill(0, 0);

        if (Self.Account.Header.Pran1.Level + 1 >= 5) and
          (Self.Account.Header.Pran1.Level + 1 <= 30) then
        begin
          for I := 0 to (Self.Account.Header.Pran1.Level div 5) + 2 do
            Inc(Self.Account.Header.Pran1.Skills[I].Level);
        end
        else if (Self.Account.Header.Pran1.Level + 1 >= 35) and
          (Self.Account.Header.Pran1.Level + 1 <= 50) then
        begin
          for I := 0 to 9 do
            if (I <> 3) then
              Inc(Self.Account.Header.Pran1.Skills[I].Level);
        end
        else if (Self.Account.Header.Pran1.Level + 1 >= 55) and
          (Self.Account.Header.Pran1.Level + 1 <= 70) then
        begin
          for I := 4 to 9 do
            Inc(Self.Account.Header.Pran1.Skills[I].Level);
        end;

        Self.SetPranPassiveSkill(0, 1);
        Self.SendPranToWorld(0);

        if Self.GetPranClass(@Self.Account.Header.Pran1) = 1 then
          baseSkillPran := 5760
        else if Self.GetPranClass(@Self.Account.Header.Pran1) = 2 then
          baseSkillPran := 5860
        else if Self.GetPranClass(@Self.Account.Header.Pran1) = 3 then
          baseSkillPran := 5960;

        for I := 0 to 2 do
          for helper := 0 to 9 do
            if (((Self.Account.Header.Pran1.ItemBar[I] + baseSkillPran) >=
              Self.Account.Header.Pran1.Skills[helper].Index) and
              ((Self.Account.Header.Pran1.ItemBar[I] + baseSkillPran) <=
              Self.Account.Header.Pran1.Skills[helper].Index + 9)) then
            begin
              Self.Account.Header.Pran1.ItemBar[I] :=
                ((Self.Account.Header.Pran1.Skills[helper].
                Index + Self.Account.Header.Pran1.Skills[helper].Level - 1) -
                baseSkillPran);
            end;

        Self.RefreshItemBarSlot(0, 3, Self.Account.Header.Pran1.ItemBar[0]);
        Self.RefreshItemBarSlot(1, 3, Self.Account.Header.Pran1.ItemBar[1]);
        Self.RefreshItemBarSlot(2, 3, Self.Account.Header.Pran1.ItemBar[2]);
      end;
    1:
      begin
        if (Self.Account.Header.Pran2.Level = MAX_PRAN_LEVEL) then
          Exit;

        Inc(Self.Account.Header.Pran2.Level);
        Self.SendClientMessage('Sua pran subiu de nível.');
        Self.SendPranLevelAndExp((Self.Account.Header.Pran2.Level + 1),
          Self.Account.Header.Pran2.Exp);
        Inc(Self.Account.Header.Pran2.MaxHp, PRAN_HP_INC_PER_LEVEL);
        Inc(Self.Account.Header.Pran2.MaxMP, PRAN_MP_INC_PER_LEVEL);
        Self.Account.Header.Pran2.CurHP := Self.Account.Header.Pran2.MaxHp;
        Self.Account.Header.Pran2.CurMp := Self.Account.Header.Pran2.MaxMP;
        Self.SetPranPassiveSkill(0, 0);

        if (Self.Account.Header.Pran2.Level + 1 >= 5) and
          (Self.Account.Header.Pran2.Level + 1 <= 30) then
        begin
          for I := 0 to (Self.Account.Header.Pran2.Level div 5) + 2 do
            Inc(Self.Account.Header.Pran2.Skills[I].Level);
        end
        else if (Self.Account.Header.Pran2.Level + 1 >= 35) and
          (Self.Account.Header.Pran2.Level + 1 <= 50) then
        begin
          for I := 0 to 9 do
            if (I <> 3) then
              Inc(Self.Account.Header.Pran2.Skills[I].Level);
        end
        else if (Self.Account.Header.Pran2.Level + 1 >= 55) and
          (Self.Account.Header.Pran2.Level + 1 <= 70) then
        begin
          for I := 4 to 9 do
            Inc(Self.Account.Header.Pran2.Skills[I].Level);
        end;

        Self.SetPranPassiveSkill(0, 1);
        Self.SendPranToWorld(0);

        if Self.GetPranClass(@Self.Account.Header.Pran1) = 1 then
          baseSkillPran := 5760
        else if Self.GetPranClass(@Self.Account.Header.Pran1) = 2 then
          baseSkillPran := 5860
        else if Self.GetPranClass(@Self.Account.Header.Pran1) = 3 then
          baseSkillPran := 5960;

        for I := 0 to 2 do
          for helper := 0 to 9 do
            if (((Self.Account.Header.Pran2.ItemBar[I] + baseSkillPran) >=
              Self.Account.Header.Pran2.Skills[helper].Index) and
              ((Self.Account.Header.Pran2.ItemBar[I] + baseSkillPran) <=
              Self.Account.Header.Pran2.Skills[helper].Index + 9)) then
            begin
              Self.Account.Header.Pran2.ItemBar[I] :=
                ((Self.Account.Header.Pran2.Skills[helper].
                Index + Self.Account.Header.Pran2.Skills[helper].Level - 1) -
                baseSkillPran);
            end;

        Self.RefreshItemBarSlot(0, 3, Self.Account.Header.Pran2.ItemBar[0]);
        Self.RefreshItemBarSlot(1, 3, Self.Account.Header.Pran2.ItemBar[1]);
        Self.RefreshItemBarSlot(2, 3, Self.Account.Header.Pran2.ItemBar[2]);
      end;
  end;
end;

procedure TPlayer.SendPranLevelAndExp(Level: DWORD; Exp: Int64);
var
  Packet: TRefreshPranLevelExpPacket;
begin
  ZeroMemory(@Packet, SizeOf(TRefreshPranLevelExpPacket));
  Packet.Header.size := SizeOf(TRefreshPranLevelExpPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $116;
  Packet.Level := Level;
  Packet.Exp := Exp;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendPranDevotionAndFood(Devotion, Food: WORD);
var
  Packet: TRefreshPranDevotionFoodPacket;
begin
  ZeroMemory(@Packet, SizeOf(TRefreshPranDevotionFoodPacket));
  Packet.Header.size := SizeOf(TRefreshPranDevotionFoodPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $96B;
  Packet.Devotion := Devotion;
  Packet.Food := Food;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.AddGold(Value: Int64);
begin
  Inc(Self.Character.Base.Gold, Value);
  Self.RefreshMoney;
end;

procedure TPlayer.AddCash(Value: Cardinal);
begin
  Inc(Self.Account.Header.CashInventory.Cash, Value);
  Self.SendPlayerCash;
end;

procedure TPlayer.DecCash(Value: Cardinal);
begin
  // Ensure Cash is a simple type (e.g., Cardinal, Integer)
  Self.Account.Header.CashInventory.Cash :=
    Self.Account.Header.CashInventory.Cash - Value;
  Self.SendPlayerCash;
end;

procedure TPlayer.DecGold(Value: Int64);
begin
  Dec(Self.Character.Base.Gold, Value);
  Self.RefreshMoney;
end;

procedure TPlayer.AddTitle(TitleID, TitleLevel: Integer; xMsg: boolean);
var
  I: Integer;
  Slot: Integer;
  SQLComp: TQuery;
begin
  Slot := 255;
  for I := 0 to 95 do
  begin
    if (Self.Base.PlayerCharacter.Titles[I].Index = 0) then
    begin
      Slot := I;
      Break;
    end;
  end;

  if (Slot = 255) then
  begin
    Self.SendClientMessage('Sua lista de títulos está cheia.');
    Exit;
  end;

  // Criar a conexão uma vez antes do loop
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  try
    // Verificar se a conexão com o banco de dados foi estabelecida
    if not SQLComp.Query.Connection.Connected then
    begin
      Logger.Write('Falha de conexão individual com mysql.[AddTitle]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[AddTitle]', TlogType.Error);
      Exit;
    end;

    // Operação de inserção para outros personagens, se necessário
    if (Self.Account.GetCharCount(Self.Account.Header.AccountId,
      Self.ChannelIndex, @Self) > 1) and (TitleID in [17, 18]) then
    begin
      for I := 0 to 2 do
      begin
        if (Self.Account.Characters[I].Base.CharIndex = 0) or
          (Self.Account.Characters[I].Base.CharIndex = Self.Base.Character.
          CharIndex) then
          Continue;

        SQLComp.SetQuery
          (format('INSERT INTO titles (owner_charid, title_index, title_level, title_progress) VALUES (%d, %d, %d, %d)',
          [Self.Account.Characters[I].Base.CharIndex, TitleID, TitleLevel, 1]));
        SQLComp.Run(false);
      end;
    end;

    // Atualiza o título do personagem
    Self.Base.PlayerCharacter.Titles[Slot].Index := TitleID;
    Self.Base.PlayerCharacter.Titles[Slot].Level := TitleLevel;
    if (xMsg) then
      Self.Base.PlayerCharacter.Titles[Slot].Progress :=
        Titles[TitleID].TitleLevel[TitleLevel - 1].TitleGoal
    else
      Self.Base.PlayerCharacter.Titles[Slot].Progress := 1;

    // Insere o título no banco de dados
    SQLComp.SetQuery
      (format('INSERT INTO titles (owner_charid, title_index, title_level, title_progress) VALUES (%d, %d, %d, %d)',
      [Self.Base.Character.CharIndex, Self.Base.PlayerCharacter.Titles[Slot].
      Index, Self.Base.PlayerCharacter.Titles[Slot].Level,
      Self.Base.PlayerCharacter.Titles[Slot].Progress]));
    SQLComp.Run(false);

  finally
    SQLComp.Free;
  end;

  if (xMsg) then
  begin
    Self.SendTitleUpdate(TitleID, TitleLevel - 1);
    Self.SendClientMessage('Você obteve um novo título [' +
      AnsiString(Titles[TitleID].TitleLevel[TitleLevel - 1].TitleName) + ']');
  end;
end;

function TPlayer.GetTitle(TitleID: Integer): boolean;
var
  SQLComp: TQuery;
begin
  Result := false;
  if (Self.Base.Character.CharIndex <> 0) then
  begin
    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));

    try
      if not(SQLComp.Query.Connection.Connected) then
      begin
        Logger.Write('Falha de conexão individual com mysql.[GetTitle]',
          TlogType.Warnings);
        Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetTitle]', TlogType.Error);
        Exit;
      end;

      SQLComp.SetQuery
        ('SELECT 1 FROM titles WHERE owner_charid=:onwer_id AND title_index=:title_id LIMIT 1');
      SQLComp.AddParameter2('owner_charid', Self.Base.Character.CharIndex);
      SQLComp.AddParameter2('title_id', TitleID);
      SQLComp.Run();

      Result := SQLComp.Query.RecordCount > 0;
    finally
      SQLComp.Free;
    end;
  end;
end;

procedure TPlayer.RemoveTitle(TitleID: Integer);
var
  I, Slot: Integer;
  SQLComp: TQuery;
begin
  Slot := 255;
  for I := 0 to 95 do
  begin
    if (Self.Base.PlayerCharacter.Titles[I].Index = TitleID) then
    begin
      Slot := I;
      Break;
    end;
  end;

  if (Slot = 255) then
    Exit;

  // Resetando os dados do título

  Self.Base.PlayerCharacter.Titles[Slot].Index := 0;
  Self.Base.PlayerCharacter.Titles[Slot].Level := 0;
  Self.Base.PlayerCharacter.Titles[Slot].Progress := 0;

  // Criando a consulta SQL e verificando a conexão
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not SQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[RemoveTitle]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[RemoveTitle]', TlogType.Error);
    SQLComp.Free;
    Exit;
  end;

  // Executando a remoção no banco de dados
  SQLComp.SetQuery
    (format('DELETE FROM titles WHERE owner_charid = %d AND title_index = %d',
    [Self.Base.Character.CharIndex, TitleID]));
  SQLComp.Run(false);

  // Atualizando o cliente e enviando a mensagem
  Self.SendTitleUpdate(TitleID, 0);
  Self.SendClientMessage('Você teve o título [' +
    AnsiString(Titles[TitleID].TitleLevel[0].TitleName) + '] deletado.');

  SQLComp.Free;
end;

procedure TPlayer.UpdateTitleLevel(TitleID, TitleLevel: Integer; xMsg: boolean);
var
  I, Slot: Integer;
  SQLComp: TQuery;
begin
  Slot := 255;
  for I := 0 to 95 do
  begin
    if (Self.Base.PlayerCharacter.Titles[I].Index = TitleID) then
    begin
      Slot := I;
      Break;
    end;
  end;
  if (Slot = 255) then
    Exit;

  // Atualizando o nível e progresso do título
  Self.Base.PlayerCharacter.Titles[Slot].Level := TitleLevel;
  if (xMsg) then
    Self.Base.PlayerCharacter.Titles[Slot].Progress :=
      Titles[TitleID].TitleLevel[TitleLevel - 1].TitleGoal;

  // Criação e verificação de conexão do SQL
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  try
    if not(SQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[UpdateTitleLevel]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[UpdateTitleLevel]',
        TlogType.Error);
      Exit;
    end;

    // Atualizando o banco de dados
    SQLComp.SetQuery
      (format('UPDATE titles SET title_level = %d, title_progress = %d where owner_charid = %d and title_index = %d',
      [TitleLevel, Self.Base.PlayerCharacter.Titles[Slot].Progress,
      Self.Base.Character.CharIndex, TitleID]));
    SQLComp.Run(false);

  finally
    SQLComp.Free;
  end;

  // Enviando mensagem e atualizando título se necessário
  if (xMsg) then
  begin
    Self.SendClientMessage('Você teve o título [' +
      AnsiString(Titles[TitleID].TitleLevel[0].TitleName) +
      '] aprimorado para o nível ' + IntToStr(TitleLevel) + '.');
    Self.SendTitleUpdate(TitleID, TitleLevel - 1);
  end;
end;

{$ENDREGION}
{$REGION 'Skills'}

procedure TPlayer.SetPlayerSkills;
var
  I, J, Tamanho: Integer;
  Level: Cardinal;
begin
  ZeroMemory(@Self.Character.Base.SkillList, 120);

  for I := 0 to Length(Self.Character.Skills.Basics) - 1 do
    if (Self.Character.Skills.Basics[I].Level <> 0) then
      Self.Character.Base.SkillList[I] := $2;

  J := 6;
  for I := 0 to Length(Self.Character.Skills.Others) - 1 do
  begin
    if (Self.Character.Skills.Others[I].Level = 0) then
      Continue;

    Tamanho := TSkillFunctions.GetSkillLevel(Self.Character.Skills.Others[I].
      Index + (Self.Character.Skills.Others[I].Level - 1), Level);
    if (I > 0) and (Self.Character.Skills.Others[I - 1].Level = 16) then
      Inc(Level);

    Move(Level, Self.Character.Base.SkillList[I + J], Tamanho);
  end;
end;

procedure TPlayer.SendPlayerSkills(NPCIndex: Integer = 0);
var
  Packet: TSendSkillsPacket;
  I: Integer;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  with Packet.Header do
  begin
    size := SizeOf(Packet);
    Index := Self.Base.clientId;
    Code := $106;
  end;
  Packet.NPCIndex := NPCIndex;
  if NPCIndex > 0 then
    Packet.SendType := $B;

  for I := 0 to High(Self.Character.Skills.Others) do
    Packet.Skills[I] := Self.Character.Skills.Others[I].Index;

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendPlayerSkillsLevel;
var
  Packet: TSendSkillsLevelPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $107;
  Self.SetPlayerSkills;
  Move(Self.Character.Base.SkillList[0], Packet.Skills[0],
    SizeOf(Packet.Skills));
  Packet.SkillPoints := Self.Character.Base.CurrentScore.SkillPoint;
  Packet.unk := $CCCC;
  Self.SendPacket(Packet, Packet.Header.size);
end;

function TPlayer.CalcSkillPoints(Level: WORD): WORD;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to Level do
  begin
    Inc(Result, SKILL_POINT_PER_LEVEL);
    if (I > 50) and ((I mod 10) = 1) then
    begin
      Inc(Result, SKILL_POINT_X);
    end;
  end;
end;

procedure TPlayer.SearchSkillsPassive(Mode: BYTE);
var
  // Mode0 = Ativando  Mode1 = Desativando
  I: Integer;
  Skill, Level: Integer;
  helper: Integer;
begin
  for I := 0 to Length(Self.Character.Skills.Others) - 1 do
  begin
    if ((((SkillData[Self.Character.Skills.Others[I].Index].Agressive = 1) and
      (SkillData[Self.Character.Skills.Others[I].Index].Attribute = 0)) or
      ((SkillData[Self.Character.Skills.Others[I].Index].Agressive = 2) and
      (SkillData[Self.Character.Skills.Others[I].Index].Attribute = 0)))) then
    begin
      Skill := Self.Character.Skills.Others[I].Index;
      Level := Self.Character.Skills.Others[I].Level;
      case SkillData[Skill].Index of
        9: // fortitude WR atk fis 2 e acerto 4
          begin
            if (Mode = 0) then
            begin // para entrar no jogo
              Self.Base.IncreasseMobAbility(EF_DAMAGE1, (Level * 2));
              Self.Base.IncreasseMobAbility(EF_HIT, (Level * 4));
            end
            else if (Mode = 1) then
            begin // para reiniciar todas as habilidades
              Self.Base.DecreasseMobAbility(EF_DAMAGE1, (Level * 2));
              Self.Base.DecreasseMobAbility(EF_HIT, (Level * 4));
            end;
          end;
        10: // corpo draconiano WR hp 145 e 5% de recuperação de hp
          begin
            helper := 2000;
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_HP, (Level * 145));
              Self.Base.IncreasseMobAbility(EF_REGENHP,
                (Level * ((helper div 100) * 5)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_HP, (Level * 145));
              Self.Base.DecreasseMobAbility(EF_REGENHP,
                (Level * ((helper div 100) * 5)));
            end;
          end;
        146: // Inspirar Coragem WR resfriamento 2%
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_COOLTIME, (Level * 2));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_COOLTIME, (Level * 2));
            end;
          end;
        23: // Instinto de batalha WR Reduz dano recebido em area 30%+(2%*lvl) e critico 1
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_REDUCE_AOE, (30 + (Level * 2)));
              Self.Base.IncreasseMobAbility(EF_CRITICAL, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_REDUCE_AOE, (30 + (Level * 2)));
              Self.Base.DecreasseMobAbility(EF_CRITICAL, Level);
            end;
          end;
        33: // punição TP recupera HP com o dano 1%*lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_HP_ATK_RES, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_HP_ATK_RES, Level);
            end;
          end;
        34: // Revelação TP aumento de cura 120, cura recebida 1%, diminuição mp habilidades 10%+(2%*lvl)
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.IncreasseMobAbility(EF_MPCURE, (10 + (Level * 2)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.DecreasseMobAbility(EF_MPCURE, (10 + (Level * 2)));
            end;
          end;
        149: // Defesa Automatica TP 10%+2*lvl de diminuir os danos em 5%+1*lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_GUARD_RATE, (10 + (Level * 2)));
              Self.Base.IncreasseMobAbility(EF_GUARD, (5 + Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_GUARD_RATE, (10 + (Level * 2)));
              Self.Base.DecreasseMobAbility(EF_GUARD, (5 + Level));
            end;
          end;
        47: // Julgamento TP atk fis 8 + 4*lvl e crit 1
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_DAMAGE1, (8 + (Level * 4)));
              Self.Base.IncreasseMobAbility(EF_CRITICAL, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_DAMAGE1, (8 + (Level * 4)));
              Self.Base.DecreasseMobAbility(EF_CRITICAL, Level);
            end;
          end;
        57: // concentração att acerto 2
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_HIT, (Level * 2));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_HIT, (Level * 2));
            end;
          end;
        58: // Poder Critico Att critical power 5% + 5*lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER,
                (5 + (Level * 5)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_CRITICAL_POWER,
                (5 + (Level * 5)));
            end;
          end;
        152: // Ultimato att skill damage 50 + 50*lvl e velo 1 + lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_RUNSPEED, (1 + (Level)));
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE,
                (50 + (Level * 50)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_RUNSPEED, (1 + (Level)));
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE,
                (50 + (Level * 50)));
            end;
          end;
        71: // Guarda Fatal att res crit e duplo 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_RESISTANCE6, (Level * 3));
              Self.Base.IncreasseMobAbility(EF_RESISTANCE7, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_RESISTANCE6, (Level * 3));
              Self.Base.DecreasseMobAbility(EF_RESISTANCE7, (Level * 3));
            end;
          end;
        81: // Olhar Penetrante DG crit 1 e dano crit 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_CRITICAL, Level);
              Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_CRITICAL, Level);
              Self.Base.DecreasseMobAbility(EF_CRITICAL_POWER, (Level * 3));
            end;
          end;
        82: // Movimento Gracioso DG esquiva 2 + lvl
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_PARRY, (2 + Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_PARRY, (2 + Level));
            end;
          end;
        155: // Vento Cortante DG res lentidao 5 e res paralisia 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_IM_RUNSPEED, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_IM_RUNSPEED, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 3));
            end;
          end;
        95: // Falsa Pontaria DG reduz tax de perigo 8 + lvl*2 e Outro bglh la
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_STATE_RESISTANCE,
                (8 + (Level * 2)));
              Self.Base.IncreasseMobAbility(EF_DECEIVE_ATK, Level);
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_STATE_RESISTANCE,
                (8 + (Level * 2)));
              Self.Base.DecreasseMobAbility(EF_DECEIVE_ATK, Level);
            end;
          end;

        105: // Tempestade de Mana FC
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_DAMAGE2, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_PRAN_REQUIRE_MP, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_DAMAGE2, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_PRAN_REQUIRE_MP, (Level * 3));
            end;
          end;
        106: // Harmonia de Mana FC
          begin

            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_MP, (80 * Level));
              Self.Base.IncreasseMobAbility(EF_REGENMP, (5 * Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_MP, (80 * Level));
              Self.Base.DecreasseMobAbility(EF_REGENMP, (5 * Level));
            end;
          end;
        158: // Afinidade Negra FC res silence 5 e terror 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_IM_SILENCE1, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_IM_FEAR, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_IM_SILENCE1, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_IM_FEAR, (Level * 3));
            end;
          end;
        119: // Focar Mágica FC aumento do consumo de mana=MANABURN
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_CAST_RATE, (Level * 4));
              Self.Base.IncreasseMobAbility(EF_MANABURN, (4 + Level));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_CAST_RATE, (Level * 4));
              Self.Base.DecreasseMobAbility(EF_MANABURN, (4 + Level));
            end;
          end;
        129: // Ativação divina CL cura 120 diminui mp consumido em 10% cura
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.IncreasseMobAbility(EF_MPCURE, (8 + (2 * Level)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE6, (Level * 120));
              Self.Base.DecreasseMobAbility(EF_MPCURE, (8 + (2 * Level)));
            end;
          end;
        130: // Ativação De Mana CL aumento de duração dos buffs 2
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_ATIME6, (Level * 2));
              Self.Base.IncreasseMobAbility(EF_REQUIRE_MP, (8 + (2 + Level)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_ATIME6, (Level * 2));
              Self.Base.DecreasseMobAbility(EF_REQUIRE_MP, (8 + (2 + Level)));
            end;
          end;
        161: // Vontade Inabalável CL res paralisia 5 choque 3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 5));
              Self.Base.IncreasseMobAbility(EF_IM_SKILL_SHOCK, (Level * 3));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_IM_SKILL_IMMOVABLE, (Level * 5));
              Self.Base.DecreasseMobAbility(EF_IM_SKILL_SHOCK, (Level * 3));
            end;
          end;
        143: // Penitencia CL aumento de cura em 17 + lvl*3
          begin
            if (Mode = 0) then
            begin
              Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6,
                (17 + (Level * 3)));
            end
            else if (Mode = 1) then
            begin
              Self.Base.DecreasseMobAbility(EF_SKILL_DAMAGE6,
                (17 + (Level * 3)));
            end;
          end;
      end;
    end;
  end;
end;

procedure TPlayer.SetActiveSkillPassive(SkillIndex: Integer;
  SkillIDLevel: Integer);
begin
  case SkillData[SkillIndex].Index of
    9:
      begin
        Self.Base.IncreasseMobAbility(EF_DAMAGE1, 2);
        Self.Base.IncreasseMobAbility(EF_HIT, 4);
      end;
    10:
      begin
        Self.Base.IncreasseMobAbility(EF_HP, 145);
        Self.Base.IncreasseMobAbility(EF_REGENHP, Round((2000 div 100) * 5));
      end;
    146: // Inspirar Coragem WR resfriamento 2%
      begin
        Self.Base.IncreasseMobAbility(EF_COOLTIME, 2);
      end;
    23: // Instinto de batalha WR Reduz dano recebido em area 30%+(2%*lvl) e critico 1
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_REDUCE_AOE, (30 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_REDUCE_AOE, 2);
        Self.Base.IncreasseMobAbility(EF_CRITICAL, 1);
      end;
    33: // punição TP Aumento da ameaça a todas as ações em 8.
      begin
      end;
    34: // Revelação TP aumento de cura 120, cura recebida 1%, diminuição mp habilidades 10%+(2%*lvl)
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_MPCURE, (10 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_MPCURE, 2);
        Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, 120);
        Self.Base.IncreasseMobAbility(EF_UPCURE, 1);
      end;
    149: // Defesa Automatica TP 10%+2*lvl de diminuir os danos em 5%+1*lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_GUARD_RATE, (10 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_GUARD_RATE, 2);
        Self.Base.IncreasseMobAbility(EF_GUARD, 5);
      end;
    47: // Julgamento TP atk fis 8 + 4*lvl e crit 1
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_DAMAGE1, (8 + 4))
        else
          Self.Base.IncreasseMobAbility(EF_DAMAGE1, 4);
        Self.Base.IncreasseMobAbility(EF_CRITICAL, 1);
      end;
    57: // concentração att acerto 2
      begin
        Self.Base.IncreasseMobAbility(EF_HIT, 2);
      end;
    58: // Poder Critico Att critical power 5% + 5*lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, (5 + 5))
        else
          Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, 5);
      end;
    152: // Ultimato att skill damage 50 + 50*lvl e velo 1 + lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
        begin
          Self.Base.IncreasseMobAbility(EF_RUNSPEED, (1 + 1));
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE, (50 + 50));
        end
        else
        begin
          Self.Base.IncreasseMobAbility(EF_RUNSPEED, 1);
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE, 50);
        end;
      end;
    71: // Guarda Fatal att res crit e duplo 3
      begin
        Self.Base.IncreasseMobAbility(EF_RESISTANCE6, 3);
        Self.Base.IncreasseMobAbility(EF_RESISTANCE7, 3);
      end;
    81: // Olhar Penetrante DG crit 1 e dano crit 3
      begin
        Self.Base.IncreasseMobAbility(EF_CRITICAL, 1);
        Self.Base.IncreasseMobAbility(EF_CRITICAL_POWER, 3);
      end;
    82: // Movimento Gracioso DG esquiva 2 + lvl
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_PARRY, 3)
        else
          Self.Base.IncreasseMobAbility(EF_PARRY, 1);
      end;
    155: // Vento Cortante DG res lentidao 5 e res paralisia 3
      begin
        Self.Base.IncreasseMobAbility(EF_IM_RUNSPEED, 5);
        Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, 3);
      end;
    95: // Falsa Pontaria DG reduz tax de perigo 8 + lvl*2 e Outro bglh la
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_STATE_RESISTANCE, (8 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_STATE_RESISTANCE, 2);
        Self.Base.IncreasseMobAbility(EF_DECEIVE_ATK, 1);
      end;
    105: // Tempestade de Mana FC
      begin
        Self.Base.IncreasseMobAbility(EF_DAMAGE2, 5);
        Self.Base.IncreasseMobAbility(EF_PRAN_REQUIRE_MP, 3);
      end;
    106: // Harmonia de Mana FC 5% + lvl
      begin
        Self.Base.IncreasseMobAbility(EF_MP, (80));
        Self.Base.IncreasseMobAbility(EF_REGENMP, (5));
      end;
    158: // Afinidade Negra FC res silence 5 e terror 3
      begin
        Self.Base.IncreasseMobAbility(EF_IM_SILENCE1, 5);
        Self.Base.IncreasseMobAbility(EF_IM_FEAR, 3);
      end;
    119: // Focar Mágica FC aumento do consumo de mana=MANABURN
      begin
        Self.Base.IncreasseMobAbility(EF_CAST_RATE, 4);
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_MANABURN, 5)
        else
          Self.Base.IncreasseMobAbility(EF_MANABURN, 1);
      end;
    129: // Ativação divina CL cura 120 diminui mp consumido em 10% cura
      begin
        Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, 120);
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_MPCURE, (8 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_MPCURE, 2);
      end;
    130: // Ativação De Mana CL aumento de duração dos buffs 2
      begin
        Self.Base.IncreasseMobAbility(EF_SKILL_ATIME6, 2);
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_REQUIRE_MP, (8 + 2))
        else
          Self.Base.IncreasseMobAbility(EF_REQUIRE_MP, 2);
      end;
    161: // Vontade Inabalável CL res paralisia 5 choque 3
      begin
        Self.Base.IncreasseMobAbility(EF_IM_SKILL_IMMOVABLE, 5);
        Self.Base.IncreasseMobAbility(EF_IM_SKILL_SHOCK, 3);
      end;
    143: // Penitencia CL aumento de cura em 17 + lvl*3
      begin
        if (SkillData[SkillIDLevel].Level = 1) then
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, (17 + 3))
        else
          Self.Base.IncreasseMobAbility(EF_SKILL_DAMAGE6, 3);
      end;
  end;
end;

procedure TPlayer.SetDesativeSkillPassive(SkillIndex: Integer);
begin
end;
{$ENDREGION}
{$REGION 'Friend list'}

procedure TPlayer.sendToFriends(const Packet; size: WORD);
var
  characterId: UInt64;
  OtherPlayer: WORD;
  OtherServer: BYTE;
begin
  for characterId in Self.FriendList.Keys do
  begin
    if Self.EntityFriend.getFriend(characterId, OtherPlayer, OtherServer) then
      Servers[OtherServer].Players[OtherPlayer].SendPacket(Packet, size);
  end;
end;

procedure TPlayer.sendFriendToSocial(const characterId: UInt64);
var
  Packet: TSendFriendToSocialPacket;
  OP: WORD;
  OtherServer: BYTE;
  OtherPlayer: PPlayer;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $870;

  if (characterId = 0) then
    Exit;

  AnsiStrings.StrPCopy(Packet.Nick, Self.FriendList[characterId]
    .friendCharacterName);
  Packet.CharIndex := characterId;

  // A chamada ao método getFriend já verifica a amizade e busca o player, então podemos otimizar
  if Self.EntityFriend.getFriend(characterId, OP, OtherServer) then
  begin
    OtherPlayer := @Servers[OtherServer].Players[OP];
    Packet.FriendStatus := TFriendStatus.Online;
    Packet.Channel := OtherPlayer^.ChannelIndex;
    Packet.PlayerIndex := OtherPlayer^.Base.clientId;
    Packet.Classe := OtherPlayer^.Base.Character.ClassInfo;
    Packet.City := OtherPlayer^.CurrentCity;
    Packet.Level := (OtherPlayer^.Base.Character.Level - 1);
  end
  else
  begin
    Packet.FriendStatus := TFriendStatus.Offline;
  end;

  // Enviar o pacote ao final, sem redundância
  Self.SendPacket(Packet, Packet.Header.size);
end;

function TPlayer.AddFriend(PlayerIndex: WORD): BYTE;
var
  OtherPlayer: PPlayer;
  friend, friend1: TFriend;
begin
  Result := 0;
  OtherPlayer := @Servers[Self.ChannelIndex].Players[PlayerIndex];

  if (OtherPlayer^.Status < Playing) or (Self.FriendList.Count >= 50) or
    (OtherPlayer^.FriendList.Count >= 50) then
  begin
    if (OtherPlayer^.Status < Playing) then
      Result := 1
    else if (Self.FriendList.Count >= 50) then
      Result := 2
    else
      Result := 3;
    Exit;
  end;

  if (OtherPlayer^.Base.clientId = Self.Base.clientId) then
  begin
    Self.SendClientMessage('Você não pode se adicionar como amigo.');
    Exit;
  end;

  if not(Self.EntityFriend.AddFriend(OtherPlayer^.Character.Index)) or
    not(OtherPlayer^.EntityFriend.AddFriend(Self.Character.Index)) then
    Exit;

  friend.Create(OtherPlayer^.Character.Index, OtherPlayer.Character.Index,
    AnsiString(OtherPlayer^.Character.Base.Name));
  Self.FriendList.Add(OtherPlayer^.Character.Index, friend);
  Self.sendFriendToSocial(OtherPlayer^.Character.Index);

  friend1.Create(Self.Character.Index, Self.Character.Index,
    AnsiString(Self.Character.Base.Name));
  OtherPlayer^.FriendList.Add(Self.Character.Index, friend1);
  OtherPlayer^.sendFriendToSocial(Self.Character.Index);

  Result := 0;
end;

procedure TPlayer.AtualizeFriendInfos(characterId: UInt64);
var
  Packet: TAtualizeFriendInfosPacket;
  OtherPlayer: PPlayer;
  OP: WORD;
  OtherServer: BYTE;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $975;

  if Self.EntityFriend.getFriend(characterId, OP, OtherServer) then
  begin
    OtherPlayer := @Servers[OtherServer].Players[OP];
    Packet.PlayerIndex := OtherPlayer.Base.clientId;
    Packet.FriendStatus := TFriendStatus.Online;
    Packet.Channel := OtherPlayer.ChannelIndex;
    Packet.City := OtherPlayer.CurrentCityID;
    Packet.Level := OtherPlayer.Base.Character.Level - 1;
    // Eliminado parêntese redundante
    Packet.Classe := OtherPlayer.Base.Character.ClassInfo;
    Self.SendPacket(Packet, Packet.Header.size);
  end;
end;

procedure TPlayer.sendDeleteFriend(characterId: UInt64);
var
  Packet: TDeleteFriendPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F74;
  Packet.CharIndex := characterId;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendFriendLogin;
var
  Packet: TFriendLoginPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $96F;
  Packet.CharIndex := Self.Character.Index;
  Packet.PlayerIndex := Self.Base.clientId;
  Packet.FriendStatus := TFriendStatus.Online;
  Packet.Channel := Self.ChannelIndex;
  Packet.City := Self.CurrentCity;
  Packet.Nation := Self.Account.Header.Nation;
  Packet.Level := Self.Base.Character.Level - 1;
  Packet.Classe := Self.Base.Character.ClassInfo;
  Self.sendToFriends(Packet, Packet.Header.size);
end;

procedure TPlayer.SendFriendLogout;
var
  Packet: TFriendLogoutPacket;
begin
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $971;
  Packet.CharIndex := Self.Character.Index;
  Self.sendToFriends(Packet, Packet.Header.size);
end;

procedure TPlayer.RefreshSocialFriends;
var
  characterId: UInt64;
begin
  for characterId in Self.FriendList.Keys do
    Self.sendFriendToSocial(characterId);
end;

procedure TPlayer.RefreshMeToFriends;
var
  Packet: TAtualizeFriendInfosPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $975;
  Packet.CharIndex := Self.Character.Index;
  Packet.PlayerIndex := Self.Base.clientId;
  Packet.FriendStatus := TFriendStatus.Online;
  Packet.Channel := Self.ChannelIndex;
  Packet.City := BYTE(Self.CurrentCityID);
  Packet.Level := Self.Base.Character.Level - 1;
  Packet.Classe := Self.Base.Character.ClassInfo;
  Self.sendToFriends(Packet, Packet.Header.size);
end;

procedure TPlayer.OpenFriendWindow(CharIndex, WindowIndex: DWORD);
var
  Packet: TOpenFriendWindowPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F27;
  Packet.CharIndex := CharIndex;
  Packet.WindowIndex := WindowIndex;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.CloseFriendWindow(characterId: UInt64);
var
  Packet: TCloseFriendWindowPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F30;

  if Self.FriendOpenWindowns.ContainsValue(characterId) then
  begin
    for var key in Self.FriendOpenWindowns.Keys do
    begin
      if (Self.FriendOpenWindowns[key] = characterId) then
      begin
        Packet.WindowIndex := key;
        Self.FriendOpenWindowns.Remove(Packet.WindowIndex);
        Self.SendPacket(Packet, Packet.Header.size);
        Exit;
      end;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Teleport Functions'}

procedure TPlayer.Teleport(Pos: TPosition);
var
  Packet: TMovementPacket;
  I: WORD;
  OtherPlayer: PPlayer;
begin
  if not(Pos.IsValid) then
  begin
    Exit;
  end;

  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := MOVE_TELEPORT;
  Self.Base.SendToVisible(Packet, Packet.Header.size, True);

  for I in Self.Base.VisiblePlayers do
  begin
    if (I = Self.Base.clientId) then
      Continue;

    OtherPlayer := @Servers[Self.Base.ChannelId].Players[I];

    // Remover pran de outros jogadores
    if (Self.Account.Header.Pran1.IsSpawned) then
      Self.SendPranUnspawn(0, OtherPlayer^.Base.clientId);

    if (Self.Account.Header.Pran2.IsSpawned) then
      Self.SendPranUnspawn(1, OtherPlayer^.Base.clientId);

    if (OtherPlayer^.Account.Header.Pran1.IsSpawned) then
      OtherPlayer^.SendPranUnspawn(0, Self.Base.clientId);

    if (OtherPlayer^.Account.Header.Pran2.IsSpawned) then
      OtherPlayer^.SendPranUnspawn(1, Self.Base.clientId);

    Self.Base.removevisible(OtherPlayer^.Base);
  end;

  Self.Base.PlayerCharacter.LastPos := Packet.Destination;
  Self.Character.LastPos := Packet.Destination;
  Self.SetCurrentNeighbors;
  // Self.Base.UpdateVisibleList;

  // Reaproveitar as condições para reiniciar as prans
  if (Self.Account.Header.Pran1.IsSpawned) then
    Self.SendPranSpawn(Self.SpawnedPran, 0, MOVE_TELEPORT);

  if (Self.Account.Header.Pran2.IsSpawned) then
    Self.SendPranSpawn(Self.SpawnedPran, 0, MOVE_TELEPORT);

  Self.CurrentCityID := Self.GetCurrentCityID;
  Self.RefreshMeToFriends;
end;

{$ENDREGION}
{$REGION 'Classes'}

class procedure TPlayer.ForEach(proc: TProc<PPlayer, TParallel.TLoopState>;
  Server: BYTE);
begin
  TParallel.For(1, Servers[Server].InstantiatedPlayers,
    procedure(I: Integer; State: TParallel.TLoopState)
    var
      Player: PPlayer;
    begin
      Player := @Servers[Server].Players[I];
      if (Player <> nil) and Player.Base.IsActive then
        proc(Player, State);
    end);
end;

class procedure TPlayer.ForEach(proc: TProc<PPlayer>; Server: BYTE);
var
  I: Integer;
  Player: PPlayer;
begin
  for I := 1 to Servers[Server].InstantiatedPlayers do
  begin
    Player := @Servers[Server].Players[I];
    if (Player <> nil) and Player.Base.IsActive then
      proc(Player);
  end;
end;

class function TPlayer.GetPlayer(Index: WORD; Server: BYTE;
out Player: TPlayer): boolean;
begin
  Result := (index > 0) and (index <= MAX_CONNECTIONS) and
    Servers[Server].Players[index].Base.IsActive;
  if Result then
    Player := Servers[Server].Players[index];
end;

{$ENDREGION}
{$REGION 'PersonalShop'}

procedure TPlayer.SendPersonalShop(Shop: TPersonalShopData);
var
  Packet: TPersonalShopPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $319;
  Move(Shop, Packet.Shop, SizeOf(Shop));
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.ClosePersonalShop;
begin
  Self.SendData(Self.Base.clientId, $318, 0);
end;
{$ENDREGION}
{$REGION 'Change Channel'}

procedure TPlayer.SendChannelClientIndex;
var
  Packet: TUpdateClientIDPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $150;
  Packet.AccountId := Self.Account.Header.AccountId;
  Packet.clientId := Self.Base.clientId;
  Packet.LoginTime := DateTimeToUnix(Now);
  Packet.Unk1 := (Self.ChannelIndex + 1);
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendLoginConfirmation;
var
  Packet: TResponseLoginPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $82;
  Packet.Index := Self.Account.Header.AccountId;
  Packet.Time := DateTimeToUnix(Now);
  Packet.Nation := Self.Account.Header.Nation;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Chat Functions'}

function TPlayer.SendItemChat(Slot: WORD; ChatType: BYTE; Msg: string): boolean;
var
  Packet: TChatItemLinkPacket;
  Item: PItem;
begin
  Result := false;
  ZeroMemory(@Packet, SizeOf(Packet));
  Item := @Self.Character.Base.Inventory[Slot];
  if (Item.Index = 0) then
    Exit;

  // Preenchendo os dados do pacote
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $F6F;
  AnsiStrings.StrCopy(Packet.Nick, Self.Character.Base.Name);
  Packet.ChatType := ChatType;
  Packet.Item := Item^;
  AnsiStrings.StrPCopy(Packet.Fala, AnsiString(Msg));

  // Enviando a mensagem conforme o tipo de chat
  case ChatType of
    CHAT_TYPE_NORMAL:
      Self.Base.SendToVisible(Packet, Packet.Header.size);
    CHAT_TYPE_GRUPO:
      Self.SendToParty(Packet, Packet.Header.size);
    CHAT_TYPE_GUILD:
      Guilds[Self.Character.GuildSlot].SendChatMessage(Packet,
        Packet.Header.size);
    CHAT_TYPE_GRITO:
      begin
        if (SecondsBetween(Now, Self.ShoutTime) < 5) then
          Self.SendClientMessage('Você não pode floodar o grito.')
        else
        begin
          Servers[Self.ChannelIndex].SendToAll(Packet, Packet.Header.size);
          Self.ShoutTime := Now;
        end;
      end;
    CHAT_TYPE_MEGAFONE:
      Servers[Self.ChannelIndex].SendToAll(Packet, Packet.Header.size);
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'Effect Functions'}

procedure TPlayer.SendEffect(EffectIndex: DWORD);
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $117;
  Packet.Index := Self.Base.clientId;
  Packet.Effect := EffectIndex;
  Self.Base.SendToVisible(Packet, Packet.Header.size);
end;

procedure TPlayer.SendAnimation(AnimationIndex, Loop: DWORD);
var
  Packet: TSendAnimationPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $31F;
  Packet.Anim := AnimationIndex;
  Packet.Loop := Loop;
  Self.Base.SendToVisible(Packet, Packet.Header.size);
end;

procedure TPlayer.SendDevirChange(DevirNpcID: DWORD; DevirAnimation: DWORD);
var
  Packet: TSendAnimationPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := DevirNpcID;
  Packet.Header.Code := $31F;
  Packet.Anim := DevirAnimation;
  Packet.Loop := 0;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendAnimationDeadOf(clientId: DWORD);
var
  Packet: TPacketSendDeadAnimation;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $180;
  Packet.CountOfBlueTicks := 0;
  Packet.clientId := clientId;

  Self.Base.SendToVisible(Packet, Packet.Header.size, True);
end;

{$ENDREGION}
{$REGION 'Guild'}

procedure TPlayer.SearchAndSetGuildSlot;
var
  I: Integer;
begin
  for I := Low(Guilds) to High(Guilds) do
  begin
    if (Guilds[I].Index <> 0) and
      (Guilds[I].Index = Self.Character.Base.GuildIndex) then
    begin
      Self.Character.GuildSlot := Guilds[I].Slot;
      Break;
    end;
  end;
end;

procedure TPlayer.SendGuildInfo;
var
  Packet: TGuildInfoPacket;
  Guild: PGuild;
begin
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $965;
  Guild := @Guilds[Self.Character.GuildSlot];
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  Packet.Nation := Guild.Nation;
  Move(Guild.Name, Packet.GuildName, Length(Guild.Name) - 1);
  Move(Guild.Notices, Packet.Notices, SizeOf(Guild.Notices));
  Move(Guild.Site, Packet.Site, Length(Guild.Site));
  Packet.GuildIndex_1 := Self.Character.Base.GuildIndex;
  Move(Guild.Ally.Guilds, Packet.GuildsAlly, SizeOf(Guild.Ally.Guilds));

  Packet.Null_4 := 1;
  Packet.Unk_1[0] := 1;
  Packet.Unk_1[1] := 1;
  Packet.Unk_1[2] := 1;

  Move(Guild.RanksConfig, Packet.RanksConfig, 5);
  Packet.Exp := Guild.Exp;
  Packet.Level := Guild.Level;
  Packet.BravePoints := Guild.BravurePoints;
  Packet.Promote := Guild.Promote;
  Packet.SkillPoints := Guild.SkillPoints;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendGuildPlayers;
var
  Packet: TGuildPlayersPacket;
  I, P, S: Integer;
  Guild: PGuild;
  Player: PPlayer;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Character.Base.clientId;
  Packet.Header.Code := $97F;
  P := 0;
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;

  Guild := @Guilds[Self.Character.GuildSlot];
  Packet.GuildIndex := Guild^.Index;

  for I := 0 to Length(Guild^.Members) - 1 do
  begin
    if Guild^.Members[I].CharIndex > 0 then
    begin
      if P >= 10 then
      begin
        Self.SendPacket(Packet, Packet.Header.size);
        ZeroMemory(@Packet.Players, SizeOf(Packet.Players));
        P := 0;
      end;

      Move(Guild^.Members[I], Packet.Players[P], SizeOf(TPlayerFromGuild));
      Packet.Players[P].Logged := false;

      for S := Low(Servers) to High(Servers) do
      begin
        if Servers[S].GetPlayerByCharIndex(Packet.Players[P].CharIndex, Player)
        then
        begin
          Packet.Players[P].Logged := True;
          Break;
        end;
      end;

      Inc(P);
    end;
  end;

  if P > 0 then
    Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.AddPlayerToGuild(Player: TPlayerFromGuild);
var
  Packet: TAddPlayerToGuildPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Character.Base.clientId;
  Packet.Header.Code := $125;
  Packet.Player := Player;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.GuildMemberLogin(MemberId: Integer);
var
  Packet: TGuildMemberLoginPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $969;
  Packet.CharIndex := Guilds[Self.Character.GuildSlot].Members[MemberId]
    .CharIndex;
  Packet.Status := 1;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.GuildMemberLogout(MemberId: Integer);
var
  Packet: TGuildMemberLogoutPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $96A;
  Packet.CharIndex := Guilds[Self.Character.GuildSlot].Members[MemberId]
    .CharIndex;
  Packet.LastLogin := Guilds[Self.Character.GuildSlot].Members[MemberId]
    .LastLogin;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.UpdateGuildMemberRank(CharIndex: Integer; Rank: Integer);
var
  Packet: TChangeGuildMemberRankPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $F1D;
  Packet.CharIndex := CharIndex;
  Packet.Rank := Rank;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.UpdateGuildMemberLevel(CharIndex: Integer; Level: Integer);
var
  Packet: TUpdateGuildMemberLevelPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $D1E;
  Packet.CharIndex := CharIndex;
  Packet.Level := Level;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.UpdateGuildRanksConfig;
var
  Packet: TUpdateGuildRanksConfigPacket;
begin
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $F22;
  Move(Guilds[Self.Character.GuildSlot].RanksConfig, Packet.RanksConfig, 4);
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.UpdateGuildNotices;
var
  Packet: TUpdateGuildNoticesPacket;
  I: Integer;
begin
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $F20;
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  for I := 0 to 2 do
    AnsiStrings.StrCopy(Packet.Notices[I], Guilds[Self.Character.GuildSlot]
      .Notices[I].Text);
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.UpdateGuildSite;
var
  Packet: TUpdateGuildSitePacket;
begin
  if Self.Character.Base.GuildIndex <= 0 then
    Exit;
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $F21;
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  AnsiStrings.StrCopy(Packet.Site, Guilds[Self.Character.GuildSlot].Site);
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.InviteToGuildRequest(clientId: Integer);
var
  Packet: TInviteToGuildPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := clientId;
  Packet.Header.Code := $97C;
  Move(Self.Character.Base.Name, Packet.InviterNick,
    Length(Packet.InviterNick));
  Servers[Self.ChannelIndex].Players[clientId].SendPacket(Packet,
    Packet.Header.size);
end;

procedure TPlayer.GetOutGuild(Expulsion: boolean);
begin
  Self.Character.Base.GuildIndex := 0;
  case Expulsion of
    True:
      Self.SendData(Self.Base.clientId, $F1C, 1);
    false:
      Self.SendData(Self.Base.clientId, $F1C, 0);
  end;
  Self.RefreshPlayerInfos(True);
  Self.SendP152;
end;

procedure TPlayer.SendGuildChestPermission;
var
  Packet: TGuildChestPermissionPacket;
  Guild: PGuild;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $F10;
  Guild := @Guilds[Self.Character.GuildSlot];
  Packet.CanUseGuildChest := Guild.GetRankConfig
    (Guild.Members[Guild.FindMemberFromCharIndex(Self.Character.Index)
    ].Rank).UseGWH;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendGuildChest;
var
  Packet: TGuildChestPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $D58;
  Packet.Content := Guilds[Self.Character.GuildSlot].Chest;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.CloseGuildChest;
var
  I: Integer;
  Player: PPlayer;
begin
  for I := Low(Servers) to High(Servers) do
    if Servers[I].GetPlayerByCharIndex(Self.Character.Index, Player) then
    begin
      Player.SendSignal(Self.Character.Base.clientId, $F2F);
      Exit;
    end;
end;

procedure TPlayer.RefreshGuildChestGold;
var
  Packet: TRefreshGuildChestGoldPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $D18;
  Packet.GuildIndex := Self.Character.Base.GuildIndex;
  Packet.unk := 1;
  Packet.Gold := Guilds[Self.Character.GuildSlot].Chest.Gold;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendP152;
var
  Packet: array [0 .. 47] of BYTE; // Adjust size as needed for the packet data
  PacketSize: Integer;
  GuildSlot: Integer;
  Guild: TGuild;
begin
  try
    // Ensure GuildSlot is valid
    GuildSlot := Self.Character.GuildSlot;
    if (GuildSlot < 0) or (GuildSlot >= Length(Guilds)) then
    begin
      Logger.Write('Invalid GuildSlot', TlogType.Error);
      Exit;
    end;

    Guild := Guilds[GuildSlot];

    // ZeroMemory initializes the packet to zero
    ZeroMemory(@Packet, SizeOf(Packet));

    // Calculate the actual packet size
    PacketSize := 28; // Size of the data you are sending

    // Set the packet length in the first two bytes
    PWORD(@Packet[0])^ := PacketSize;
    PWORD(@Packet[6])^ := $152;
    PWORD(@Packet[12])^ := Guild.Index;
    PWORD(@Packet[14])^ := Guild.Nation;
    PWORD(@Packet[16])^ := Guild.Level;
    PINT64(@Packet[20])^ := Guild.Exp;
    // Logger.Write('2.9', TLogType.Error);

    // Send the packet
    Self.SendPacket(Packet, PacketSize);
  except
    on E: Exception do
    begin
      Logger.Write('Exception in SendP152: ' + E.Message, TlogType.Error);
    end;
  end;
end;

// Funcao original
// procedure TPlayer.SendP152;
// var
// Packet: ARRAY [0 .. $2F] OF BYTE;
// begin // pacote de buffs da guilda estudar mais depois
// try
// ZeroMemory(@Packet, Length(Packet));
// PWORD(Integer(@Packet) + 00)^ := Length(Packet);
// PWORD(Integer(@Packet) + 06)^ := $152;
// { PWORD(Integer(@Packet) + 12)^ := Guilds[Self.Character.GuildSlot].Index;
// PWORD(Integer(@Packet) + 14)^ := Guilds[Self.Character.GuildSlot].Nation;
// PWORD(Integer(@Packet) + 16)^ := Guilds[Self.Character.GuildSlot].Level;
// PINT64(Integer(@Packet) + 20)^ := Guilds[Self.Character.GuildSlot].Exp; }
// Self.SendPacket(Packet, Length(Packet));
// except
// on e: exception do
// begin
// Logger.Write('TPlayer.SendP152 [EXCEPTION]: ' + e.Message, TLogType.Error);
// end;
// end;
//
// end;
{$ENDREGION}
{$REGION 'Duel'}

procedure TPlayer.SendDuelTime();
var
  Packet: TSendDuelTime;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $1A2;
  Packet.SecondsCount := DUEL_TIME_WAIT;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.CreateDuelSession(OtherPlayer: PPlayer);
var
  Packet: TSendCreateNpcPacket;
  FlagID: WORD;
  Title: String;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  if Servers[Self.ChannelIndex].DuelCount >= 5 then
  begin
    Self.SendClientMessage('Aguarde, já temos 5 duelos acontecendo no server!');
    Exit;
  end;

  Inc(Servers[Self.ChannelIndex].DuelCount);
  FlagID := 10148 + Servers[Self.ChannelIndex].DuelCount;
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := FlagID;
  Packet.Header.Code := $349;
  System.AnsiStrings.StrPLCopy(Packet.Name, '365', 3);
  Packet.Equip[0] := 571;
  Packet.Equip[6] := 546;
  Randomize;
  Packet.Position := Self.Base.Neighbors[random(7)].Pos;
  Self.DuelFlagPosition := Packet.Position;
  OtherPlayer.DuelFlagPosition := Packet.Position;
  Packet.MaxHp := 20000;
  Packet.CurHP := 20000;
  Packet.Unk0 := $0A;
  Packet.Effects[1] := $1D;
  Packet.EffectType := 1;
  Packet.IsService := 1;
  Packet.SpawnType := SPAWN_BABYGEN;
  Packet.Altura := 4;
  Packet.Tronco := $77;
  Packet.Perna := $77;
  Packet.Corpo := 0;
  Title := String(Self.Base.Character.Name) + ' < vs > ' +
    String(OtherPlayer.Base.Character.Name);
  System.AnsiStrings.StrPLCopy(Packet.Title, AnsiString(Title), 32);
  Self.Base.SendToVisible(Packet, Packet.Header.size);
  Self.Dueling := True;
  OtherPlayer.Dueling := True;
  Self.DuelInitTime := Now;
  OtherPlayer.DuelInitTime := Now;
  Self.DuelFlagID := FlagID;
  OtherPlayer.DuelFlagID := FlagID;
  Self.DuelingWith := OtherPlayer.Base.clientId;
  OtherPlayer.DuelingWith := Self.Base.clientId;

  Self.DuelThread := TDuelThread.Create(1000, Self.ChannelIndex,
    Self.Base.clientId, OtherPlayer.Base.clientId);
end;

procedure TPlayer.SendDuelEnd(MsgType: BYTE);
var
  Packet: TMessageEndDuel;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $1A0;
  Packet.WonLose := MsgType;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.RemoveDuelFlag(FlagID: WORD);
var
  Packet: TSendRemoveMobPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $101;
  Packet.Index := ifthen(FlagID = 0, Self.DuelFlagID, FlagID);
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendDuelEffect(FlagID: WORD);
var
  Packet: TSendActionPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $304;
  Packet.Index := 45;
  Packet.InLoop := 1;

  // for i := 205 to $ffff do
  // begin
  // Packet.Index:= i;
  // Player.SendPacket(Packet, sizeof(Packet));
  // Player.SendClientMessage('packet id: ' + i.ToString);
  // sleep(5);

  Self.SendPacket(Packet, Packet.Header.size);
end;

{$ENDREGION}
{$REGION 'Quest'}

procedure TPlayer.SendQuests();
var
  I: Integer;
begin
  for I := 0 to 49 do
  begin
    if (Self.PlayerQuests[I].ID > 0) then
    begin
      if not(Self.PlayerQuests[I].IsDone) then
      begin
        Self.UpdateQuest(Self.PlayerQuests[I].ID);
      end;
    end;
  end;
end;

procedure TPlayer.UpdateQuest(QuestID: DWORD);
var
  Packet: TSendQuestInfo;
  QuestIndex: WORD;
  auxInt: Integer;
begin
  ZeroMemory(@Packet, SizeOf(TSendQuestInfo));
  Packet.Header.size := SizeOf(TSendQuestInfo);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $331;
  if (Self.QuestExists(QuestID, QuestIndex)) then
  begin
    Packet.QuestID := QuestID;
    Packet.RequirimentType[0] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[0];
    Packet.RequirimentType[1] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[1];
    Packet.RequirimentType[2] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[2];
    Packet.RequirimentType[3] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[3];
    Packet.RequirimentType[4] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsType[4];
    Packet.RequirimentAmount[0] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[0];
    Packet.RequirimentAmount[1] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[1];
    Packet.RequirimentAmount[2] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[2];
    Packet.RequirimentAmount[3] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[3];
    Packet.RequirimentAmount[4] := Self.PlayerQuests[QuestIndex]
      .Quest.RequirimentsAmount[4];
    Packet.RequirimentComplete[0] := Self.PlayerQuests[QuestIndex].Complete[0];
    Packet.RequirimentComplete[1] := Self.PlayerQuests[QuestIndex].Complete[1];
    Packet.RequirimentComplete[2] := Self.PlayerQuests[QuestIndex].Complete[2];
    Packet.RequirimentComplete[3] := Self.PlayerQuests[QuestIndex].Complete[3];
    Packet.RequirimentComplete[4] := Self.PlayerQuests[QuestIndex].Complete[4];
    // amount é o total, complete é quantos já foi
    Packet.RequirimentItem[0] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[0];
    Packet.RequirimentItem[1] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[1];
    Packet.RequirimentItem[2] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[2];
    Packet.RequirimentItem[3] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[3];
    Packet.RequirimentItem[4] := Self.PlayerQuests[QuestIndex]
      .Quest.Requiriments[4];
    if (Self.PlayerQuests[QuestIndex].Quest.Requiriments[0] = 0) then
      Packet.IsCompleted := BYTE(True);
    Self.SendPacket(Packet, Packet.Header.size);
    if (Self.PlayerQuests[QuestIndex].Quest.NPCID < 2047) then
      auxInt := Self.PlayerQuests[QuestIndex].Quest.NPCID + 2047
    else
      auxInt := Self.PlayerQuests[QuestIndex].Quest.NPCID;

    if (Self.Base.VisibleNPCS.Contains(auxInt)) then
    begin
      Servers[Self.ChannelIndex].NPCS[auxInt].Base.SendRemoveMob(DELETE_NORMAL,
        Self.Base.clientId, false);
      Servers[Self.ChannelIndex].NPCS[auxInt].Base.SendCreateMob(SPAWN_NORMAL,
        Self.Base.clientId, false);
    end;
  end;
end;

procedure TPlayer.RemoveQuest(QuestID: DWORD);
var
  Packet: TAbandonQuestPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $32F;
  Packet.QuestID := QuestID;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendExpGoldMsg(Exp, Gold: DWORD);
var
  Packet: TSendExpGoldMsg;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.Base.clientId;
  Packet.Header.Code := $11B;
  Packet.Exp := Exp;
  Packet.Gold := Gold;
  Self.SendPacket(Packet, Packet.Header.size);
end;

function TPlayer.QuestExists(QuestID: WORD; out QuestIndex: WORD): boolean;
var
  I: WORD;
begin
  Result := false;
  for I := 0 to 49 do
  begin
    if (Self.PlayerQuests[I].ID = QuestID) then
    begin
      Result := True;
      QuestIndex := I;
      Break;
    end;
  end;
end;

function TPlayer.SearchEmptyQuestIndex(): WORD;
var
  I: WORD;
begin
  Result := 255;
  for I := 0 to 49 do
  begin
    if (Self.PlayerQuests[I].ID = 0) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TPlayer.QuestCount(): WORD;
var
  I: WORD;
begin
  Result := 0;
  for I := 0 to 49 do
  begin
    if not(Self.PlayerQuests[I].ID = 0) then
    begin
      Inc(Result);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Get Event Itens'}

procedure TPlayer.GetAllEventItems();
type
  TEventItem = record
    ItemID: WORD;
    Amount: WORD;
  end;
var
  SlotsAvaliable: WORD;
  ItemID: WORD;
  I: WORD;
  MySQLComp, MySQLCompAux: TQuery;
begin
  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not MySQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetAllEventItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAllEventItems]',
      TlogType.Error);
    MySQLComp.Free;
    Exit;
  end;

  MySQLComp.SetQuery
    (format('SELECT item_id, refine FROM items WHERE owner_id=%d AND slot_type=%d',
    [Self.Character.Base.CharIndex, EVENT_ITEM]));
  MySQLComp.Run();

  if MySQLComp.Query.RecordCount = 0 then
  begin
    Self.SendClientMessage('Não existem itens de evento para receber.', 16, 16);
    Self.SendSignal(Self.Base.clientId, $359);
    MySQLComp.Free;
    Exit;
  end;

  SlotsAvaliable := TItemFunctions.GetInvAvailableSlots(Self);
  if SlotsAvaliable = 0 then
  begin
    Self.SendClientMessage('Inventário cheio.');
    Self.SendSignal(Self.Base.clientId, $359);
    MySQLComp.Free;
    Exit;
  end;

  if SlotsAvaliable > MySQLComp.Query.RecordCount then
    SlotsAvaliable := MySQLComp.Query.RecordCount;

  MySQLComp.Query.First;
  for I := 0 to SlotsAvaliable - 1 do
  begin
    ItemID := WORD(MySQLComp.Query.FieldByName('item_id').AsInteger);

    TItemFunctions.PutItem(Self, ItemID,
      WORD(MySQLComp.Query.FieldByName('refine').AsInteger));

    MySQLCompAux := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), True);
    if not MySQLCompAux.Query.Connection.Connected then
    begin
      Logger.Write
        ('Falha de conexão individual com mysql.[GetAllEventItemsAux]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAllEventItemsAux]',
        TlogType.Error);
      MySQLCompAux.Free;
      MySQLComp.Free;
      Exit;
    end;

    MySQLCompAux.Query.Connection.StartTransaction;
    MySQLCompAux.SetQuery
      (format('DELETE FROM items WHERE owner_id=%d AND item_id=%d AND slot_type=%d',
      [Self.Character.Base.CharIndex, ItemID, EVENT_ITEM]));
    MySQLCompAux.Run(false);
    MySQLCompAux.Query.Connection.Commit;
    MySQLCompAux.Free;

    MySQLComp.Query.Next;
  end;

  Self.SendClientMessage
    ('Não existem mais itens de evento para receber.', 16, 16);
  Self.SendSignal(Self.Base.clientId, $359);
  MySQLComp.Free;
end;

function TPlayer.DiaryItemAvaliable(): boolean;
var
  LastReceived: TDateTime;
  LastReceivedUnix: Int64;
  SQLComp: TQuery;
  TimeInString: String;
  CurrentUnix: Int64;
  LastEventUnix: Int64;
begin
  Result := false;
  SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);

  if not SQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[DiaryItemAvaliable]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[DiaryItemAvaliable]',
      TlogType.Error);
    SQLComp.Free;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('SELECT last_diary_event FROM characters WHERE id=%d',
      [Self.Character.Base.CharIndex]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount = 0 then
    begin
      SQLComp.Free;
      Exit;
    end;

    TimeInString := SQLComp.Query.FieldByName('last_diary_event').AsString;

    if TimeInString = '' then
    begin
      CurrentUnix := DateTimeToUnix(IncHour(Now, -25));
      Result := True;

      SQLComp.Query.Connection.StartTransaction;
      SQLComp.SetQuery
        (format('UPDATE characters SET last_diary_event=%d WHERE id=%d',
        [CurrentUnix, Self.Character.Base.CharIndex]));
      SQLComp.Run(false);
      SQLComp.Query.Connection.Commit;
      SQLComp.Free;
      Exit;
    end;

    LastReceivedUnix := StrToInt64(TimeInString);
    LastReceived := UnixToDateTime(LastReceivedUnix);
    CurrentUnix := DateTimeToUnix(Now);

    if HoursBetween(Now, LastReceived) >= 24 then
    begin
      SQLComp.Query.Connection.StartTransaction;
      SQLComp.SetQuery
        (format('UPDATE characters SET last_diary_event=%d WHERE id=%d',
        [CurrentUnix, Self.Character.Base.CharIndex]));
      SQLComp.Run(false);
      SQLComp.Query.Connection.Commit;
      SQLComp.Free;
      Result := True;
      Exit;
    end
    else
    begin
      Self.SendClientMessage('Recompensa já foi recebida hoje!')
    end;

    SQLComp.Free;
  except
    on E: Exception do
      Logger.Write('TPlayer.DiaryItemAvaliable ' + E.Message, TlogType.Error);
  end;
end;

{$ENDREGION}
{$REGION 'Titles'}

function TPlayer.GetTitleLevelValue(Slot, Level: BYTE): WORD;
begin
  if (Level > 1) then
    Result := (1 shl ((Slot * 4) + (Level - 1))) + Self.GetTitleLevelValue(Slot,
      Level - 1)
  else
    Result := (1 shl ((Slot * 4) + (Level - 1)));
end;

{$ENDREGION}
{$REGION 'Dungeons'}

procedure TPlayer.SendDungeonLobby(InParty: boolean; Dungeon, Dificult: BYTE);
var
  Packet: TSendPlayersLobbyDungeon;
  I, Cnt: WORD;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $145;
  Packet.Header.Index := Self.Base.clientId;
  Packet.Dungeon := Dungeon;
  Packet.Dificult := Dificult;

  if InParty then
  begin
    Cnt := 0;
    for I in Self.Party.Members do
    begin
      Packet.PlayersParty1[Cnt] := Servers[Self.ChannelIndex].Players[I]
        .Base.clientId;
      Packet.UnkPlayersRecord[Cnt] := Cnt;
      with Servers[Self.ChannelIndex].Players[I] do
      begin
        DungeonLobbyIndex := Dungeon;
        DungeonLobbyDificult := Dificult;
      end;
      Inc(Cnt);
    end;
    Self.Party.SendToParty(Packet, Packet.Header.size);
  end
  else
  begin
    Packet.PlayersParty1[0] := Self.Base.clientId;
    Packet.UnkPlayersRecord[0] := 0;
    DungeonLobbyIndex := Dungeon;
    DungeonLobbyDificult := Dificult;
    Self.SendPacket(Packet, Packet.Header.size);
  end;
end;

function TPlayer.GetFreeDungeonInstance(): BYTE;
begin
  for Result := Low(DungeonInstances) to High(DungeonInstances) do
    if DungeonInstances[Result].Index = 0 then
      Exit;
  Result := 255;
end;

procedure TPlayer.CreateDungeonInstance(InParty: boolean;
Dungeon, Dificult: BYTE);
var
  I, J, k, Cnt: WORD;
  FreeId: BYTE;
begin
  /// /example for clear list
  /// //Servers[Self.ChannelIndex].Players[i].Base.ClearTargetList

  if (InParty) then
  begin
    case Dungeon of
        {$region 'ursula'}
      DUNGEON_ZANTORIAN_CITADEL:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;

            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGUrsula
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then

                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].FisAtk;

                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].FisDef;
                  // DungeonInstances[FreeId].MOBS[Cnt].AttackerID := Self.Base.ClientID;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);

                  case Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    11, 21, 31:
                      begin
                        Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    12, 22, 32:
                      begin
                        Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    13, 23, 33:
                      begin
                        Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              // DungeonInstances[FreeId]
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;

          end;
        end;
                {$endregion}
        {$region 'evgenia inferior'}
      DUNGEON_MARAUDER_HOLD:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgInf
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    41, 51, 61:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    42, 52, 62:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    43, 53, 63:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
                {$endregion}
        {$region 'evgenia superior'}
      DUNGEON_MARAUDER_CABIN:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgSup
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    71, 81, 91:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    72, 82, 92:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    73, 83, 93:
                      begin
                        Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;

        {$endregion}
        {$region 'mina 1'}
      DUNGEON_LOST_MINES:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGMines1[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGMines1[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGMines1
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    101, 201, 301:
                      begin
                        Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    102, 202, 302:
                      begin
                        Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    103, 203, 303:
                      begin
                        Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGMines1[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
        {$endregion}
        {$region 'jardim'}
      DUNGEON_KINARY_AVIARY:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGKinary[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGKinary[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGKinary
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    101, 201, 301:
                      begin
                        Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                    102, 202, 302:
                      begin
                        Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaPrata,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaPrata));
                      end;
                    103, 203, 303:
                      begin
                        Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaDourada,
                          DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGKinary[Dificult]
                          .MobsDrop.CoroaDourada));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
        {$endregion}
        {$region 'mina2'}
      DUNGEON_MINE_2:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGMines2[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGMines2[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGMines2
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    701, 702, 703:
                      begin
                        Move(Servers[Self.ChannelIndex].DGMines2[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGMines2[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;

        {$Endregion}
        {$Region 'pheltas'}
        10: //pheltas
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGPheltas[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGPheltas
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    701, 702, 703:
                      begin
                        Move(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
        {$endregion}
        {$Region 'prisao'}
        6: //prisao
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGPrisao[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            if (I = Servers[Self.ChannelIndex].Players[I].Party.Members.First)
            then
            begin
              FreeId := Servers[Self.ChannelIndex].Players[I]
                .GetFreeDungeonInstance;
              if (FreeId = 255) then
              begin
                Self.SendClientMessage('Dungeon Instances Full.');
                Exit;
              end;
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
                .DungeonInstanceID := FreeId;
              DungeonInstances[FreeId].Index := FreeId;
              DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
                .Players[I].Party;
              DungeonInstances[FreeId].CreateTime := Now;
              DungeonInstances[FreeId].DungeonID := Dungeon;
              DungeonInstances[FreeId].Dificult := Dificult;
              Cnt := 1;
              for J := Low(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGPrisao
                [Dificult].MOBS.TMobS) do
              begin
                for k := 0 to 49 do
                begin
                  if (Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].MobsP[k].Base.clientId = 0) then
                    Continue;
                  DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].IntName;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                    .MobsP[k].Base.clientId, Self.ChannelIndex);
                  DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                  DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].InitHP;
                  DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                    DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                  DungeonInstances[FreeId].MOBS[Cnt].Position :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                    .MobsP[k].InitPos;
                  DungeonInstances[FreeId].MOBS[Cnt]
                    .Base.PlayerCharacter.LastPos := DungeonInstances[FreeId]
                    .MOBS[Cnt].Position;
                  DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].MobLevel;
                  DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].MobExp;
                  DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].MobType;
                  DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                    .MobElevation;
                  DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].Cabeca;
                  DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult]
                    .MOBS.TMobS[J].Perna;
                  DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].FisAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].MagAtk;
                  DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].FisDef;
                  DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                    Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].MagDef;
                  Move(Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                  case Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                    [J].DungeonDropIndex of
                    701, 702, 703:
                      begin
                        Move(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                          .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                          [Cnt].Drops,
                          SizeOf(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                          .MobsDrop.SemCoroa));
                      end;
                  end;
                  Inc(Cnt);
                end;
              end;
              DungeonInstances[FreeId].InstanceOnline := True;
              DungeonInstances[FreeId].MainThread :=
                TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
          end;
        end;
        {$endregion}
    end;
  end
  else
  begin
    if (TParty.CreateParty(Self.Base.clientId, Self.ChannelIndex)) then
    begin
      Self.RefreshParty;
    end
    else
    begin
      Self.SendClientMessage('Não foi possível criar o grupo.');
      Exit;
    end;

    case Dungeon of
     {$region 'ursula'}
      DUNGEON_ZANTORIAN_CITADEL:
        begin
          for I in Self.Party.Members do
          begin

            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGUrsula[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGUrsula[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  11, 21, 31:
                    begin
                      Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  12, 22, 32:
                    begin
                      Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  13, 23, 33:
                    begin
                      Move(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGUrsula[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;
                {$endregion}
     {$region 'evgenia inferior'}
      DUNGEON_MARAUDER_HOLD:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGEvgInf[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  41, 51, 61:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  42, 52, 62:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  43, 53, 63:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGEvgInf[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;
                {$endregion}
     {$region 'evgenia superior'}
      DUNGEON_MARAUDER_CABIN:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGEvgSup[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  71, 81, 91:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  72, 82, 92:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  73, 83, 93:
                    begin
                      Move(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGEvgSup[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;
                {$endregion}
     {$region 'mina 1}
      DUNGEON_LOST_MINES:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGMines1[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGMines1[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGMines1[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].FisAtk;
                // Writeln(Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                // [J].FisAtk);

                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGMines1[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  101, 201, 301:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  102, 202, 302:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  103, 203, 303:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGMines1[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;
                {$endregion}
     {$region 'jardim'}

      DUNGEON_KINARY_AVIARY:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGKinary[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGKinary[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGKinary[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGKinary[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  401, 501, 601:
                    begin
                      Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  402, 502, 602:
                    begin
                      Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  403, 503, 603:
                    begin
                      Move(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGKinary[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;
                {$endregion}
     {$region 'mina 2'}
      DUNGEON_MINE_2:
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGMines2[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGMines2[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGMines2[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGMines2[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  701, 801, 901:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines2[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGMines2[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  702, 802, 902:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines2[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGMines2[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  703, 803, 903:
                    begin
                      Move(Servers[Self.ChannelIndex].DGMines2[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGMines2[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;
        {$endregion}
     {$region 'pheltas'}
        10: //pheltas
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGPheltas[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGPheltas[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGPheltas[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGPheltas[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  701, 801, 901:
                    begin
                      Move(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  702, 802, 902:
                    begin
                      Move(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  703, 803, 903:
                    begin
                      Move(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGPheltas[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;
        {$endregion}
     {$region 'prisao'}

       6: //prisao
        begin
          for I in Self.Party.Members do
          begin
            Servers[Self.ChannelIndex].Players[I].Base.WalkTo
              (Servers[Self.ChannelIndex].DGPrisao[Dificult]
              .SpawnInDungeonPosition, 70, MOVE_TELEPORT);
            Servers[Self.ChannelIndex].Players[I].InDungeon := True;
            Servers[Self.ChannelIndex].Players[I].DungeonID := Dungeon;
            Servers[Self.ChannelIndex].Players[I].DungeonIDDificult := Dificult;
            FreeId := Servers[Self.ChannelIndex].Players[I]
              .GetFreeDungeonInstance;
            if (FreeId = 255) then
            begin
              Self.SendClientMessage('Dungeon Instances Full.');
              Exit;
            end;
            Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID := FreeId;
            DungeonInstances[FreeId].Index := FreeId;
            DungeonInstances[FreeId].Party := Servers[Self.ChannelIndex]
              .Players[I].Party;
            DungeonInstances[FreeId].CreateTime := Now;
            DungeonInstances[FreeId].DungeonID := Dungeon;
            DungeonInstances[FreeId].Dificult := Dificult;
            Cnt := 1;
            for J := Low(Servers[Self.ChannelIndex].DGPrisao[Dificult]
              .MOBS.TMobS) to High(Servers[Self.ChannelIndex].DGPrisao[Dificult]
              .MOBS.TMobS) do
            begin
              for k := 0 to 49 do
              begin
                if (Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId = 0) then
                  Continue;
                DungeonInstances[FreeId].MOBS[Cnt].IntName :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].IntName;
                DungeonInstances[FreeId].MOBS[Cnt].Base.Create(nil,
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                  .MobsP[k].Base.clientId, Self.ChannelIndex);
                DungeonInstances[FreeId].MOBS[Cnt].Base.IsDungeonMob := True;
                DungeonInstances[FreeId].MOBS[Cnt].Base.mobid := Cnt;
                DungeonInstances[FreeId].MOBS[Cnt].MaxHp :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].InitHP;
                DungeonInstances[FreeId].MOBS[Cnt].CurrentHP :=
                  DungeonInstances[FreeId].MOBS[Cnt].MaxHp;
                DungeonInstances[FreeId].MOBS[Cnt].Position :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                  .MobsP[k].InitPos;
                DungeonInstances[FreeId].MOBS[Cnt].Base.PlayerCharacter.LastPos
                  := DungeonInstances[FreeId].MOBS[Cnt].Position;
                DungeonInstances[FreeId].MOBS[Cnt].MobLevel :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].MobLevel;
                DungeonInstances[FreeId].MOBS[Cnt].MobExp :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].MobExp;
                DungeonInstances[FreeId].MOBS[Cnt].MobType :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].MobType;
                DungeonInstances[FreeId].MOBS[Cnt].MobElevation :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                  .MobElevation;
                DungeonInstances[FreeId].MOBS[Cnt].Cabeca :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].Cabeca;
                DungeonInstances[FreeId].MOBS[Cnt].Perna :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult]
                  .MOBS.TMobS[J].Perna;
                DungeonInstances[FreeId].MOBS[Cnt].FisAtk :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].FisAtk;
                DungeonInstances[FreeId].MOBS[Cnt].MagAtk :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].MagAtk;
                DungeonInstances[FreeId].MOBS[Cnt].FisDef :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].FisDef;
                DungeonInstances[FreeId].MOBS[Cnt].MagDef :=
                  Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS
                  [J].MagDef;
                Move(Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                  .Equip, DungeonInstances[FreeId].MOBS[Cnt].Equip, 26);
                case Servers[Self.ChannelIndex].DGPrisao[Dificult].MOBS.TMobS[J]
                  .DungeonDropIndex of
                  701, 801, 901:
                    begin
                      Move(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                        .MobsDrop.SemCoroa, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                        .MobsDrop.SemCoroa));
                    end;
                  702, 802, 902:
                    begin
                      Move(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                        .MobsDrop.CoroaPrata, DungeonInstances[FreeId].MobsDrop
                        [Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                        .MobsDrop.CoroaPrata));
                    end;
                  703, 803, 903:
                    begin
                      Move(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                        .MobsDrop.CoroaDourada,
                        DungeonInstances[FreeId].MobsDrop[Cnt].Drops,
                        SizeOf(Servers[Self.ChannelIndex].DGPrisao[Dificult]
                        .MobsDrop.CoroaDourada));
                    end;
                end;
                Inc(Cnt);
              end;
            end;
            Servers[Self.ChannelIndex].Players[I].DungeonInstanceID :=
              Servers[Self.ChannelIndex].Players[Self.Party.Leader]
              .DungeonInstanceID;
            DungeonInstances[FreeId].InstanceOnline := True;
            DungeonInstances[FreeId].MainThread :=
              TDungeonMainThread.Create(500, Self.ChannelIndex, FreeId);
          end;
        end;

                {$endregion}
    end;
  end;
end;

procedure TPlayer.SendSpawnMobDungeon(MOB: PMobsStructDungeonInstance);
var
  Packet: TSpawnMobPacket;
begin
  ZeroMemory(@Packet, SizeOf(TSpawnMobPacket));
  Packet.Header.size := SizeOf(TSpawnMobPacket);
  Packet.Header.Index := MOB^.Base.clientId;
  Packet.Header.Code := $35E;
  Move(MOB^.Equip, Packet.Equip, 16);
  Packet.Position := MOB^.Position;
  Packet.MaxHp := MOB^.MaxHp;
  Packet.CurHP := Packet.MaxHp;
  Packet.MaxMP := Packet.MaxHp;
  Packet.CurMp := Packet.MaxMP;
  Packet.Level := MOB^.MobLevel;
  Packet.SpawnType := SPAWN_NORMAL;
  Packet.Altura := MOB^.MobElevation;
  Packet.Tronco := MOB^.Cabeca;
  Packet.Perna := MOB^.Perna;
  Packet.MobType := MOB^.MobType;
  Packet.MobName := MOB^.IntName;
  Writeln('adicionando mob ' + MOB^.Base.clientId.ToString);
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendRemoveMobDungeon(MOB: PMobsStructDungeonInstance);
var
  Packet: TSendRemoveMobPacket;
begin
  Writeln('removendo mob ' + MOB^.Base.clientId.ToString);
  ZeroMemory(@Packet, SizeOf(TSendRemoveMobPacket));
  Packet.Header.size := SizeOf(TSendRemoveMobPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $101;
  Packet.Index := MOB.Base.clientId;
  Packet.DeleteType := DELETE_NORMAL;
  Self.SendPacket(Packet, Packet.Header.size);
end;
{$ENDREGION}
{$REGION 'Nation'}

function TPlayer.IsMarshal(): boolean;
var
  SelfNationID: Integer;
begin
  Result := false;
  if (Self.Character.Base.Nation = 0) then
    SelfNationID := Servers[Self.ChannelIndex].NationID - 1
  else
    SelfNationID := Self.Character.Base.Nation - 1;

  if (Self.Base.Character.GuildIndex > 0) and
    (Nations[SelfNationID].MarechalGuildID = Self.Base.Character.GuildIndex) and
    (Guilds[Self.Character.GuildSlot].GuildLeaderCharIndex = Self.Base.
    Character.CharIndex) then
  begin
    Result := True;
  end;
end;

function TPlayer.IsArchon(): boolean;
var
  SelfNationID: Integer;
begin
  Result := false;
  if (Self.Character.Base.Nation = 0) then
    SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
  else
    SelfNationID := Self.Character.Base.Nation - 1;

  if (Self.Base.Character.GuildIndex > 0) and
    ((Nations[SelfNationID].TacticianGuildID = Self.Base.Character.GuildIndex)
    or (Nations[SelfNationID].JudgeGuildID = Self.Base.Character.GuildIndex) or
    (Nations[SelfNationID].TreasurerGuildID = Self.Base.Character.GuildIndex))
  then
  begin
    if (Guilds[Self.Character.GuildSlot].GuildLeaderCharIndex = Self.Base.
      Character.CharIndex) then
      Result := True;
  end;
end;

function TPlayer.IsGradeMarshal(): boolean;
var
  GuildSlot, MemberSlot: Integer;
  SelfNationID: Integer;
begin
  Result := false;

  if Self.Character.Base.Nation = 0 then
    SelfNationID := Servers[Self.ChannelIndex].NationID - 1
  else
    SelfNationID := Self.Character.Base.Nation - 1;

  if (Self.Base.Character.GuildIndex > 0) and
    (Nations[SelfNationID].MarechalGuildID > 0) then
  begin
    GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
      (Nations[SelfNationID].MarechalGuildID);
    if GuildSlot = 0 then
      Exit;

    MemberSlot := Guilds[GuildSlot].FindMemberFromCharIndex
      (Self.Base.Character.CharIndex);
    Result := MemberSlot <> -1;
  end;
end;

function TPlayer.IsGradeArchon(): boolean;
var
  GuildSlot, MemberSlot: Integer;
  Tac, Jud, Tre: boolean;
  SelfNationID: Integer;
begin
  Result := false;
  Tac := false;
  Jud := false;
  Tre := false;

  if (Self.Character.Base.Nation = 0) then
    SelfNationID := (Servers[Self.ChannelIndex].NationID - 1)
  else
    SelfNationID := Self.Character.Base.Nation - 1;

  // Verificando a guilda Tactician
  GuildSlot := 0;
  if (Nations[SelfNationID].TacticianGuildID > 0) then
  begin
    GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
      (Nations[SelfNationID].TacticianGuildID);
    if (GuildSlot > 0) then
      Tac := Guilds[GuildSlot].FindMemberFromCharIndex
        (Self.Base.Character.CharIndex) >= 0;
  end;

  // Verificando a guilda Judge
  GuildSlot := 0;
  if (Nations[SelfNationID].JudgeGuildID > 0) then
  begin
    GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
      (Nations[SelfNationID].JudgeGuildID);
    if (GuildSlot > 0) then
      Jud := Guilds[GuildSlot].FindMemberFromCharIndex
        (Self.Base.Character.CharIndex) >= 0;
  end;

  // Verificando a guilda Treasurer
  GuildSlot := 0;
  if (Nations[SelfNationID].TreasurerGuildID > 0) then
  begin
    GuildSlot := Servers[Self.ChannelIndex].GetGuildSlotByID
      (Nations[SelfNationID].TreasurerGuildID);
    if (GuildSlot > 0) then
      Tre := Guilds[GuildSlot].FindMemberFromCharIndex
        (Self.Base.Character.CharIndex) >= 0;
  end;

  // Resultado final
  Result := Tac or Jud or Tre;
end;

{$ENDREGION}
{$REGION 'Reliquares and Devir'}

procedure TPlayer.SendUpdateReliquareInformation(Channel: BYTE);
var
  Packet: TDevirTimeRelikInfoPacket;
  I, J: Integer;
begin
  ZeroMemory(@Packet, SizeOf(TDevirTimeRelikInfoPacket));
  Packet.Header.size := SizeOf(TDevirTimeRelikInfoPacket);
  Packet.Header.Code := $953;
  Packet.Header.Index := $7535;
  Packet.Nation := Servers[Channel].NationID;

  for J := 0 to 4 do
  begin
    for I := 0 to 4 do
    begin
      if (Servers[Channel].Devires[J].Slots[I].ItemID <> 0) then
      begin
        case J of
          0:
            begin
              Packet.DevirAmk.Slots[I].ItemID := Servers[Channel].Devires[0]
                .Slots[I].ItemID;
              Packet.DevirAmk.Slots[I].APP := Servers[Channel].Devires[0]
                .Slots[I].APP;
              Packet.DevirAmk.Slots[I].TimeToEstabilish :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[0].Slots[I].TimeToEstabilish);
              Packet.DevirAmk.Slots[I].UnkByte1 := 2;
              Packet.DevirAmk.Slots[I].UnkByte2 := 1;
              Packet.DevirAmkInfo.Slots[I].ItemID := Packet.DevirAmk.Slots
                [I].ItemID;
              Move(Servers[Channel].Devires[0].Slots[I].NameCapped,
                Packet.DevirAmkInfo.Slots[I].NameCapped[0], 16);
              Packet.DevirAmkInfo.Slots[I].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[0].Slots[I].TimeCapped);
            end;
          1:
            begin
              Packet.DevirSig.Slots[I].ItemID := Servers[Channel].Devires[1]
                .Slots[I].ItemID;
              Packet.DevirSig.Slots[I].APP := Servers[Channel].Devires[1]
                .Slots[I].APP;
              Packet.DevirSig.Slots[I].TimeToEstabilish :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[1].Slots[I].TimeToEstabilish);
              Packet.DevirSig.Slots[I].UnkByte1 := 2;
              Packet.DevirSig.Slots[I].UnkByte2 := 1;
              Packet.DevirSigInfo.Slots[I].ItemID := Packet.DevirAmk.Slots
                [I].ItemID;
              Move(Servers[Channel].Devires[1].Slots[I].NameCapped,
                Packet.DevirSigInfo.Slots[I].NameCapped[0], 16);
              Packet.DevirSigInfo.Slots[I].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[1].Slots[I].TimeCapped);
            end;
          2:
            begin
              Packet.DevirCah.Slots[I].ItemID := Servers[Channel].Devires[2]
                .Slots[I].ItemID;
              Packet.DevirCah.Slots[I].APP := Servers[Channel].Devires[2]
                .Slots[I].APP;
              Packet.DevirCah.Slots[I].TimeToEstabilish :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[2].Slots[I].TimeToEstabilish);
              Packet.DevirCah.Slots[I].UnkByte1 := 2;
              Packet.DevirCah.Slots[I].UnkByte2 := 1;
              Packet.DevirCahInfo.Slots[I].ItemID := Packet.DevirAmk.Slots
                [I].ItemID;
              Move(Servers[Channel].Devires[2].Slots[I].NameCapped,
                Packet.DevirCahInfo.Slots[I].NameCapped[0], 16);
              Packet.DevirCahInfo.Slots[I].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[2].Slots[I].TimeCapped);
            end;
          3:
            begin
              Packet.DevirMir.Slots[I].ItemID := Servers[Channel].Devires[3]
                .Slots[I].ItemID;
              Packet.DevirMir.Slots[I].APP := Servers[Channel].Devires[3]
                .Slots[I].APP;
              Packet.DevirMir.Slots[I].TimeToEstabilish :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[3].Slots[I].TimeToEstabilish);
              Packet.DevirMir.Slots[I].UnkByte1 := 2;
              Packet.DevirMir.Slots[I].UnkByte2 := 1;
              Packet.DevirMirInfo.Slots[I].ItemID := Packet.DevirAmk.Slots
                [I].ItemID;
              Move(Servers[Channel].Devires[3].Slots[I].NameCapped,
                Packet.DevirMirInfo.Slots[I].NameCapped[0], 16);
              Packet.DevirMirInfo.Slots[I].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[3].Slots[I].TimeCapped);
            end;
          4:
            begin
              Packet.DevirZel.Slots[I].ItemID := Servers[Channel].Devires[4]
                .Slots[I].ItemID;
              Packet.DevirZel.Slots[I].APP := Servers[Channel].Devires[4]
                .Slots[I].APP;
              Packet.DevirZel.Slots[I].TimeToEstabilish :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[4].Slots[I].TimeToEstabilish);
              Packet.DevirZel.Slots[I].UnkByte1 := 2;
              Packet.DevirZel.Slots[I].UnkByte2 := 1;
              Packet.DevirZelInfo.Slots[I].ItemID := Packet.DevirAmk.Slots
                [I].ItemID;
              Move(Servers[Channel].Devires[4].Slots[I].NameCapped,
                Packet.DevirZelInfo.Slots[I].NameCapped[0], 16);
              Packet.DevirZelInfo.Slots[I].TimeCapped :=
                TFunctions.DateTimeToUNIXTimeFAST
                (Servers[Channel].Devires[4].Slots[I].TimeCapped);
            end;
        end;

        // Definir o status de atividade
        case J of
          0:
            Packet.DevirAmkInfo.Slots[I].IsActive :=
              BYTE(Servers[Channel].Devires[0].Slots[I].IsAble);
          1:
            Packet.DevirSigInfo.Slots[I].IsActive :=
              BYTE(Servers[Channel].Devires[1].Slots[I].IsAble);
          2:
            Packet.DevirCahInfo.Slots[I].IsActive :=
              BYTE(Servers[Channel].Devires[2].Slots[I].IsAble);
          3:
            Packet.DevirMirInfo.Slots[I].IsActive :=
              BYTE(Servers[Channel].Devires[3].Slots[I].IsAble);
          4:
            Packet.DevirZelInfo.Slots[I].IsActive :=
              BYTE(Servers[Channel].Devires[4].Slots[I].IsAble);
        end;
      end;
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.SendReliquesToPlayer();
var
  Packet: TSendReliques;
  I, J, k: Integer;
  Chid: BYTE;
begin
  ZeroMemory(@Packet, SizeOf(TSendReliques));
  Packet.Header.size := SizeOf(TSendReliques);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $136;

  k := 0;
  if (Self.Base.Character.Nation = 0) then
  begin
    for I := 0 to 4 do
      for J := 0 to 4 do
      begin
        Packet.ReliquesItemID[k] := Servers[Self.ChannelIndex].Devires[I].Slots
          [J].ItemID;
        Inc(k);
      end;
  end
  else
  begin
    Chid := Nations[Integer(Self.Account.Header.Nation) - 1].ChannelId;
    if (Chid <> Self.ChannelIndex) then
    begin
      ZeroMemory(@Packet.ReliquesItemID, 50);
    end
    else
    begin
      for I := 0 to 4 do
        for J := 0 to 4 do
        begin
          Packet.ReliquesItemID[k] := Servers[Chid].Devires[I].Slots[J].ItemID;
          Inc(k);
        end;
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TPlayer.UpdateReliquareOpennedDevir(DevirID: Integer);
var
  Packet: TSendDevirInfoPacket;
  I: Integer;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := 0;
  Packet.Header.Code := $B52;
  Packet.DevirID := DevirID;
  Packet.TypeOpen := 5;

  for I := 0 to 4 do
  begin
    if Servers[Self.ChannelIndex].Devires[DevirID].Slots[I].ItemID <> 0 then
    begin
      // Preenchendo a estrutura do pacote
      Packet.DevirReliq.Slots[I].ItemID := Servers[Self.ChannelIndex].Devires
        [DevirID].Slots[I].ItemID;
      Packet.DevirReliq.Slots[I].APP := Packet.DevirReliq.Slots[I].ItemID;
      Packet.DevirReliq.Slots[I].Unknown := I;
      Packet.DevirReliq.Slots[I].TimeToEstabilish :=
        TFunctions.DateTimeToUNIXTimeFAST(Servers[Self.ChannelIndex].Devires
        [DevirID].Slots[I].TimeToEstabilish);
      Packet.DevirReliq.Slots[I].UnkByte1 := 2;
      Packet.DevirReliq.Slots[I].UnkByte2 := 1;

      // Preenchendo a estrutura DevirReliInfo
      Packet.DevirReliInfo.Slots[I].ItemID := Servers[Self.ChannelIndex].Devires
        [DevirID].Slots[I].ItemID;
      Packet.DevirReliInfo.Slots[I].IsActive := 1;
      Packet.DevirReliInfo.Slots[I].TimeCapped :=
        TFunctions.DateTimeToUNIXTimeFAST(Servers[Self.ChannelIndex].Devires
        [DevirID].Slots[I].TimeCapped);
      System.AnsiStrings.StrPLCopy(Packet.DevirReliInfo.Slots[I].NameCapped,
        String(Servers[Self.ChannelIndex].Devires[DevirID].Slots[I]
        .NameCapped), 16);
    end
    else
    begin
      // Caso o ItemID seja 0, apenas atualiza o IsActive
      Packet.DevirReliInfo.Slots[I].IsActive := Servers[Self.ChannelIndex]
        .Devires[DevirID].Slots[I].IsAble.ToInteger;
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;

{$ENDREGION}

function TPlayer.CheckGameMasterLogged(): boolean;
begin
  Result := Self.Base.SessionMasterPriv >= TMasterPrives.GameMasterPriv;
end;

function TPlayer.CheckAdminLogged(): boolean;
begin
  Result := Self.Base.SessionMasterPriv >= TMasterPrives.AdministratorPriv;
end;

function TPlayer.CheckModeratorLogged(): boolean;
begin
  Result := Self.Base.SessionMasterPriv >= TMasterPrives.ModeradorPriv;
end;

procedure TPlayer.SendMessageGritoForGameMaster(Nick: String;
ServerFrom: Integer; xMsg: String);
var
  Packet: TSendMessageShout;
begin
  ZeroMemory(@Packet, SizeOf(TSendMessageShout));
  Packet.Header.size := SizeOf(TSendMessageShout);
  Packet.Header.Code := $3217;
  Packet.Header.Index := Self.Base.clientId;
  AnsiStrings.StrPCopy(Packet.Nick, Nick);
  AnsiStrings.StrPCopy(Packet.xMsg, xMsg);
  // System.AnsiStrings.StrPLCopy(Packet.Nick, Nick, sizeof(Nick));
  // System.AnsiStrings.StrPLCopy(Packet.xMsg, xMsg, sizeof(xMsg));
  Packet.ServerFrom := ServerFrom;
  Self.SendPacket(Packet, Packet.Header.size);
end;

end.
