unit ServerSocket;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses winsock2, Windows, PlayerThread, Player, BaseMob, NPC, PlayerData,
  UpdateThreads, MiscData, PartyData, Generics.Collections, AnsiStrings,
  ConnectionsThread, GuildData, SQL, MOB, PET, Objects, classes, Dungeon,
  CastleSiege;
{$OLDTYPELAYOUT ON}

type
  PServerSocket = ^TServerSocket;

  TServerSocket = class
    ServerAddr: TSockAddrIn;
    Name: AnsiString;
    Ip: AnsiString;
    ServerName: string;
    IsActive: Boolean;
    InstantiatedPlayers: integer;
    ServerHasClosed: Boolean;
    NationID: byte;
    NationType: byte;
    DuelCount: byte;
    ChannelId: byte;
    ActivePlayersNowHere: word;
    AltarStolen: Boolean;
    ActiveReliquaresOnTemples: byte;
    MapSelected: Boolean;
    MapName: string;
    TimeAzulX: word;
    TimeAzulY: word;
    TimeVermelhoX: word;
    TimeVermelhoY: word;
    Quantidade_Azul: byte;
    Quantidade_Vermelho: byte;
    Kills_Azul: byte;
    Kills_Vermelho: byte;
    FinishedCadastro: Boolean;
    RemainingTime: word;
    Avised: Boolean;
    Players: ARRAY [1 .. 200] OF TPlayer; // reserved 1-2000
    NPCS: ARRAY [2048 .. 2720] OF TNpc; // reserved 2048-3048
    MOBS: TMobStruct; // reserved 3048 + 6099 mob spawns
    OBJ: Array [10148 .. 11147] of TOBJ;
    Prans: Array [44241 .. 45240] of byte;
    // Bosses: Array [30000 .. 30500] of TMobStruct;
    // DungeonsNPCs: Array [50000 .. 50010] of TNpc;
    // Incremento: integer;
    // colocar o iddb(integer) (clientid = slot)
    // 10241 ~ 11240 reserved for prans
    // numero de pets tem que ser igual ao de players (200) e [futuramente] (2000)
    // atencao ao tamanho dessas structs ai pra nao dar erro de out of memory
    // mobgrid: array [0..4095] of array [0..4095] of array of WORD;
    DGUrsula: Array [0 .. 3] of TDungeon; // 0..3
    DGEvgInf: Array [0 .. 3] of TDungeon;
    DGEvgSup: Array [0 .. 3] of TDungeon;
    DGMines1: Array [0 .. 3] of TDungeon;
    DGKinary: Array [0 .. 3] of TDungeon;
    DGMines2: Array [0 .. 0] of TDungeon;
    DGPheltas: Array [0 .. 0] of TDungeon;
    DGPrisao: Array [0 .. 3] of TDungeon;
    Parties: ARRAY [1 .. 99] OF TParty;
    Devires: Array [0 .. 4] of TDevir;
    DevirNpc: Array [3335 .. 3339] of TNpc;
    DevirGuards: Array [3355 .. 3369] of TNpc;
    DevirStones: Array [3340 .. 3354] of TNpc;
    RoyalGuards: Array [3391 .. 3569] of TNpc;
    Altar: Array [3430 .. 3430] of TNpc;
    ReliqEffect: ARRAY [0 .. 395] OF integer;
    CastleObjects: Array [3370 .. 3390] of TNpc;
    CastleSiegeHandler: TCastleSiege;
    ConnectionThread: TConnectionsThread;
    UpdateHpMpThread: TUpdateHpMpThread;
    UpdateBuffsThread: TUpdateBuffsThread;
    UpdateMailsThread: TUpdateMailsThread;
//    UpdateVisibleThread: TUpdateVisibleThread;
    UpdateTimeThread: TUpdateTimeThread;
    UpdateEventListenerThread: TUpdateEventListenerThread;
    SkillRegenerateThread: TSkillRegenerateThread;
    SkillDamageThread: TSkillDamageThread;
    MobSpawnThread1: TMobSpawnThread1;
    MobHandlerThread1: TMobHandlerThread1;
    MobMovimentThread1: TMobMovimentThread1;
    TimeItensThread: TTimeItensThread;
    ItemQuestThread: TQuestItemThread;
    PranFoodThread: TPranFoodThread;
    TemplesManagmentThread: TTemplesManagmentThread;
    VisibleManagement: TVisibleManagementThread;
    GuardsVisibleManagement: TGuardsVisibleManagementThread;
    CastleSiegeThread: TCastleSiegeThread;
    PlayerManagement: TPlayerManagementThread;
//    Iocpthread: TIOCPThread;
  var
    Sock: TSocket;
    ResetTime: LongInt;
  private
    IniciarContagem: TIniciarContagem;
    class function CreateSQL: TQuery;
  public
    { TServerSocket }
    function StartSocket(): Boolean;
    function StartServer(): Boolean;
    procedure AcceptConnection;
    procedure CloseServer;
    procedure StartThreads;
    procedure StartPartys;
    procedure StartMobs;
    procedure InitDungeons;

    { Player Functions }
    function GetPlayer(const ClientId: word): PPlayer; overload;
    function GetPlayer(const CharacterName: string): PPlayer; overload;

    { Disconnect Functions }
    procedure DisconnectAll;
    procedure Disconnect(var Player: TPlayer); overload;
    procedure Disconnect(ClientId: word); overload;
    procedure Disconnect(userName: string); overload;
    { Send Functions }
    procedure SendPacketTo(ClientId: integer; var Packet; Size: word;
      Encrypt: Boolean = true);
    procedure SendSignalTo(ClientId: integer; pIndex, opCode: word);
    procedure SendToVisible(var Base: TBaseMob; var Packet; Size: word);
    procedure SendToAll(var Packet; Size: word);
    procedure SendServerMsg(Mensg: AnsiString; MsgType: integer = $10;
      Null: integer = 0; Type2: integer = 0; SendToSelf: Boolean = true;
      MyClientID: word = 0);
    procedure SendElterMsg(Mensg: AnsiString; MsgType: integer = 16;
      Null: integer = 0; Type2: integer = 0; SendToSelf: Boolean = true;
      MyClientID: word = 0);
    procedure SendServerMsgForNation(Mensg: AnsiString; aNation: byte;
      MsgType: integer = $10; Null: integer = 0; Type2: integer = 0;
      SendToSelf: Boolean = true; MyClientID: word = 0);
    { PacketControl }
    function PacketControl(var Player: TPlayer; var Size: word;
      var Buffer: array of byte; initialOffset: integer): Boolean;
    { ServerTime }
    function GetResetTime: LongInt;
    function CheckResetTime: Boolean;
    function GetEndDayTime: LongInt;
    { Players }
    function GetPlayerByName(Name: string; out Player: PPlayer)
      : Boolean; overload;
    function GetPlayerByName(Name: string): integer; overload;
    function GetPlayerByUsername(userName: string): integer;
    function GetPlayerByUsername1(userName: string): integer;
    function GetPlayerByUsernameAux(userName: string; CidAux: word): integer;
    function GetPlayerByCharIndex(CharIndex: DWORD; out Player: PPlayer)
      : Boolean; overload;
    function GetPlayerByCharIndex(CharIndex: DWORD; out Player: TPlayer)
      : Boolean; overload;
    { Get Guild }
    function GetGuildByIndex(GuildIndex: integer): String;
    function GetGuildByName(GuildName: String): integer;
    function GetGuildSlotByID(GuildIndex: integer): integer;
    { Prans }
    function GetFreePranClientID(): integer;
    { Pets }
    // function GetFreePetClientID(): Integer;
    { Temples }
    function GetFreeTempleSpace(): TSpaceTemple;
    function GetFreeTempleSpaceByIndex(id: integer): TSpaceTemple;
    procedure SaveTemplesDB(Player: PPlayer);
    procedure UpdateReliquaresForAll();
    procedure UpdateReliquareInfosForAll();
    procedure UpdateReliquareEffects();
    function OpenDevir(DevId: integer; TempID: integer;
      WhoKilledLast: integer): Boolean;
    function CloseDevir(DevId: integer; TempID: integer;
      WhoGetReliq: integer): Boolean;
    function GetTheStonesFromDevir(DevId: integer): TIdsArray;
    function GetTheGuardsFromDevir(DevId: integer): TIdsArray;
    function GetEmptySecureArea(): byte;
    function RemoveSecureArea(AreaSlot: byte): Boolean; overload;
    function RemoveSecureArea(DevId: integer): Boolean; overload;
    function RemoveSecureArea(TempID: word): Boolean; overload;
    function CreateMapObject(OtherPlayer: PPlayer; OBJID: word;
      ContentID: word = 0): Boolean;
    function GetFreeObjId(): word;
    procedure CollectReliquare(Player: PPlayer; Index: word);
  protected
    // procedure OnContextConnected(AContext: TDiocpContext); override;
    // procedure OnContextDisconnected(AContext: TDiocpContext); override;
    // procedure OnContextReceived(AContext: TDiocpContext; buf: Pointer; len: Integer); override;
  end;
{$OLDTYPELAYOUT OFF}

implementation

uses GlobalDefs, SysUtils, DateUtils, Log,
  PacketHandlers, StrUtils, Packets,
  Functions, MailFunctions,
  FilesData, Load, EntityMail, AuthHandlers, EncDec;

class function TServerSocket.CreateSQL: TQuery;
begin
  // Criando a conexão usando as variáveis globais já definidas
  Result := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
end;

{$REGION 'TServerSocket'}

procedure TServerSocket.AcceptConnection;
var
  ClientInfo: PSockAddr;
  Clid: word;
  FSock: Cardinal;
  Margv: Cardinal;
  Xargv: AnsiChar;
begin
  ClientInfo := nil;
  FSock := accept(Self.Sock, ClientInfo, nil);
  try
    if ((FSock <> INVALID_SOCKET) and not(Self.ServerHasClosed)) then
    begin
      Clid := TFunctions.FreeClientId(Self.ChannelId);
      if not(Clid = 0) then
      begin
        Margv := 1;
        if (ioctlsocket(FSock, FIONBIO, Margv) < 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para Non-Blocking.',
            TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end;
        Xargv := '1';
        if (setsockopt(FSock, IPPROTO_TCP, TCP_NODELAY, @Xargv, 1) <> 0) then
        begin
          Logger.Write
            ('Ocorreu um erro ao configurar o socket para TCP_NODELAY. ' +
              WSAGetLastError.ToString,
            TLogType.Warnings);
          closesocket(FSock);
          FSock := INVALID_SOCKET;
          exit;
        end;

          ZeroMemory(@Self.Players[Clid], SizeOf(TPlayer));
          with Self.Players[Clid] do
          begin
            socket := FSock;
            Authenticated := False;
            ConnectionedTime := Now;
            Create(Clid, Self.ChannelId);
            Base.TimeForGoldTime := Now;
            LastTimeSaved := Now;
            xdisconnected := False;
          end;

          // Cria a thread do jogador com IOCP
          TPlayerThread.Create(Clid, FSock, Self.ChannelId);
          Inc(Servers[Self.ChannelId].InstantiatedPlayers);
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at AcceptConnection ' + E.Message + chr(13) + E.StackTrace, TLogType.Error);
    end;
  end;
end;

function TServerSocket.StartSocket;
var
  wsa: TWsaData;
  Margv: Cardinal;
  Xargv: AnsiChar;
begin
  Result := false;
  ZeroMemory(@Self.Players, sizeof(Self.Players));
  if (WSAStartup(MAKEWORD(2, 2), wsa) <> 0) then
  begin
    Logger.Write('Ocorreu um erro ao inicializar o Winsock 2.',
      TLogType.ServerStatus);
    exit;
  end;
  Self.Sock := socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  Self.ServerAddr.sin_family := AF_INET;
  Self.ServerAddr.sin_port := htons(8822); // port
  Self.ServerAddr.sin_addr.S_addr := inet_addr(PAnsiChar(Self.Ip));

  Xargv := '1';
  if (setsockopt(Self.Sock, IPPROTO_TCP, TCP_NODELAY, @Xargv, 1) <> 0) then
  begin
    Logger.Write
      ('Ocorreu um erro ao configurar o socket para TCP_NODELAY. ' +
        WSAGetLastError.ToString,
      TLogType.Warnings);
    closesocket(Self.Sock);
    Self.Sock := INVALID_SOCKET;
    exit;
  end;

  if (bind(Sock, TSockAddr(ServerAddr), sizeof(ServerAddr)) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao configurar o socket.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    exit;
  end;
  if (listen(Sock, MAX_CONNECTIONS) = -1) then
  begin
    Logger.Write('Ocorreu um erro ao colocar o socket em modo de escuta.',
      TLogType.ServerStatus);
    closesocket(Sock);
    Sock := INVALID_SOCKET;
    exit;
  end;
  Result := true;
end;
function TServerSocket.StartServer: Boolean;
var
  SQLComp: TQuery;
  i: byte;
begin
  Result := False;
//   if Self.ChannelId = 3 then
//   begin
//   for i := 1 to 1 do
//   UpdateThreads.TCheckPackets1.Create;
//   end;

  if not(Self.StartSocket) then
    Exit;

  InstantiatedPlayers := 0;

  SQLComp := Self.CreateSQL;

  // Executar consultas em sequência
  SQLComp.SetQuery('TRUNCATE TABLE elter');
  SQLComp.Run(False);
  SQLComp.SetQuery('UPDATE accounts SET isactive = 0');
  SQLComp.Run(False);

  SQLComp.Free;

  // Inicializações
  IsActive := true;
  ZeroMemory(@Self.Players, SizeOf(Self.Players));
  ZeroMemory(@Self.MOBS, SizeOf(Self.MOBS));
  ZeroMemory(@Self.Parties, SizeOf(Self.Parties));
  ZeroMemory(@Self.DGUrsula, SizeOf(TDungeon));
  ZeroMemory(@Self.DGEvgInf, SizeOf(TDungeon));
  ZeroMemory(@Self.DGEvgSup, SizeOf(TDungeon));
  ZeroMemory(@Self.DGMines1, SizeOf(TDungeon));
  ZeroMemory(@Self.DGKinary, SizeOf(TDungeon));
  ZeroMemory(@Self.DGMines2, SizeOf(TDungeon));
  // ZeroMemory(@Self.PETS, sizeof(Self.PETS));
  ZeroMemory(@Self.OBJ, SizeOf(Self.OBJ));

  // Iniciar threads e outros elementos
  Self.StartPartys;
  Self.StartMobs;

  CastleSiegeHandler := TCastleSiege.Create();

  // Inicializar dungeons se necessário
  if Dungeon_Status = 1 then
    Self.InitDungeons;

  // Log
  Logger.Write(ServerList[Self.ChannelId].Name +
    ' iniciado com sucesso [Porta: 8822].', TLogType.ServerStatus);

  Self.ResetTime := Self.GetResetTime;

  Result := true;
end;

procedure TServerSocket.CloseServer;
var
  i: integer;
  SQLComp: TQuery;
begin
  Self.IsActive := False;
  for i := Low(Self.Players) to High(Self.Players) do
  begin
    Self.Players[i].SocketClosed := true;
  end;

  SQLComp := Self.CreateSQL;

  // Executando as queries em sequência sem redundância
  SQLComp.SetQuery('TRUNCATE TABLE elter');
  SQLComp.Run(False);

  SQLComp.SetQuery('UPDATE accounts SET isactive = 0');
  SQLComp.Run(False);

  SQLComp.Free;
end;

procedure TServerSocket.StartThreads;
const
  ThreadIntervals: array [0 .. 13] of integer = (ACCEPT_CONNECTIONS_DELAY, 2000,
    1000, 500, 600000, 1000, 1500, 1000, 5000, 1000, 1000, 1000, 500, 2000);
var
  i: integer;
begin

  ConnectionThread := TConnectionsThread.Create(1500, Self.ChannelId);

    for i := 0 to High(ThreadIntervals) do
    begin
      case i of
        0:
          begin

            // //       if self.NationID = 15 then    // só carrega a thread qnd for executar leopold
            // if Self.ChannelId = 0 then
            // begin
            // WriteLn('criando thread da conexao');

            // end;
          end;
        1:
          begin
            if Self.ChannelId = 0 then
            begin
              UpdateHpMpThread := TUpdateHpMpThread.Create(1000,
                Self.ChannelId);
              WriteLn('criando thread da updatehpmp');
            end;
          end;
        2:
          begin
            if Self.ChannelId = 0 then
            begin
              UpdateBuffsThread := TUpdateBuffsThread.Create(1000,
                Self.ChannelId);
              WriteLn('criando thread dos buffs');
            end;
          end;
        3:
          begin
            if Self.ChannelId = 0 then
            begin
              UpdateTimeThread := TUpdateTimeThread.Create(10000,
                Self.ChannelId);
              WriteLn('thread do update time criada');
            end;
          end;
        4:
          begin
            if Self.ChannelId = 0 then
            begin
              UpdateEventListenerThread := TUpdateEventListenerThread.Create
                (1000, Self.ChannelId);
            end;
          end;
        5:
          begin
            if Self.ChannelId = 0 then
              SkillRegenerateThread := TSkillRegenerateThread.Create(1000,
                Self.ChannelId);
          end;
                  6:
          begin
            if Self.ChannelId = 0 then
              SkillDamageThread := TSkillDamageThread.Create(1000,
                Self.ChannelId);
          end;
          7:begin
            if Self.ChannelId = 0 then
              UpdateEventListenerThread := TUpdateEventListenerThread.Create(1000,
                Self.ChannelId);
          end;

        // 6: PetHandler := TPetHandler.Create(ThreadIntervals[i], Self.ChannelId);
        // 7: PetSpawner := TPetSpawner.Create(ThreadIntervals[i], Self.ChannelId);
        8:
          begin
            if Self.ChannelId = 0 then
              TimeItensThread := TTimeItensThread.Create(10000, Self.ChannelId);
          end;
        9:
          begin
            if Self.ChannelId = 0 then
              ItemQuestThread := TQuestItemThread.Create(10000, Self.ChannelId);
          end;
        10:
          begin
            if Self.ChannelId = 0 then
              // só carrega a thread qnd for executar leopold
              PranFoodThread := TPranFoodThread.Create(60000);
          end;
        11:
          begin
            if Self.ChannelId = 3 then
            // só carrega a thread qnd for executar leopold
            begin
              TemplesManagmentThread := TTemplesManagmentThread.Create(1500);
            end;
          end;
        12:
          begin
            if Self.ChannelId = 0 then
            // só carrega a thread qnd for executar leopold
            begin
              VisibleManagement := TVisibleManagementThread.Create(700);
            end;
          end;
        13:
          begin
            if Self.ChannelId = 0 then
            // só carrega a thread qnd for executar leopold
            begin
              GuardsVisibleManagement :=
                TGuardsVisibleManagementThread.Create(1500);
            end;
          end;
      end;
    end;

    if Self.ChannelId = 0 then
    begin
      TSaveAutomatico.Create(5000, Self.ChannelId);
    end;

    if Self.ChannelId = 0 then // só carrega a thread qnd for executar leopold
    begin
      PlayerManagement := TPlayerManagementThread.Create(500);
    end;


  if (Elter_Status = 1) then
  begin
    if Self.ChannelId = 0 then
    begin
      // AtualizarHoraMinutoThread := TAtualizarHoraMinutoThread.Create(1000, Self.ChannelId);  // 60000 milissegundos = 1 minuto
      IniciarContagem := TIniciarContagem.Create(1000, Self.ChannelId);
      // 60000 milissegundos = 1 minuto
    end;
  end;

end;

procedure TServerSocket.StartPartys;
var
  i: integer;
begin
  for i := 1 to Length(Self.Parties) do
  begin
    with Self.Parties[i] do
    begin
      index := i;
      Leader := 0;
      ChannelId := Self.ChannelId;
      Members := TList<byte>.Create;
      MemberName := TList<byte>.Create;
    end;
  end;
end;

procedure TServerSocket.StartMobs;
  function IfGuard(IntName: word): Boolean;
  begin
    Result := False;
    case IntName of
      81, 82, 117, 485, 486, 739, 888, 889, 890, 897, 901, 915, 924, 1935, 1936,
        1925, 1926, 1927, 1922, 1923, 2595:
        begin
          Result := true;
          Exit;
        end;
    end;
  end;

var
  Path: String;
  DataFile, F: TextFile;
  FileStrings: TStringList;
  Count: DWORD;
  LineFile: String;
  MobNameInit: String;
  MobN: String;
  id, id2: integer;
  idGen: integer;
  i, j: integer;
begin
  Path := GetCurrentDir + '\Data\Mobs\MonsterListCSV.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo MonsterList.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  Count := 0;
  id := 0;
  idGen := 1;
  MobNameInit := 'Max_Filhote';
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    if (Trim(LineFile) = '') then
      Continue;
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    MobN := FileStrings[4];


    if (MobNameInit = MobN) then // same mob
    begin
      MOBS.TMobS[id].IndexGeneric := id;
      // CopyMemory(@MOBS.TMobS[id].Name, @MobN, sizeof(MobN));
      System.AnsiStrings.StrPLCopy(MOBS.TMobS[id].Name, AnsiString(MobN), 64);
      MOBS.TMobS[id].MobsP[idGen].Index := Count + 3048;
      if ((pos('Mutante', MobN) <> 0) or (pos('Crenon', MobN) <> 0)) then
      begin // mutantes não andam
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[10].ToSingle();
        if not(pos('Crenon', MobN) <> 0) then
          MOBS.TMobS[id].MobsP[idGen].isMutant := true;
      end
      else
      begin
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.X :=
          FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.Y :=
          FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := MOBS.TMobS[id].MobsP[idGen]
          .DestPos.X + 5;
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := MOBS.TMobS[id].MobsP[idGen]
          .DestPos.Y + 5;
      end;
      MOBS.TMobS[id].MobsP[idGen].InitAttackRange :=
        FileStrings[11].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].InitMoveWait := FileStrings[12].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestAttackRange :=
        FileStrings[16].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestMoveWait := FileStrings[17].ToInteger();
      MOBS.TMobS[id].MoveSpeed := 22;
      MOBS.TMobS[id].MobsP[idGen].Base.Create(nil, (Count + 3048),
        Self.ChannelId);
      MOBS.TMobS[id].MobsP[idGen].Base.Mobid := id;
      MOBS.TMobS[id].MobsP[idGen].Base.IsActive := true;
      MOBS.TMobS[id].MobsP[idGen].Base.ClientId := Count + 3048;
      MOBS.TMobS[id].MobsP[idGen].Base.SecondIndex := idGen;
      MOBS.TMobS[id].MobsP[idGen].MovedTo := TypeMobLocation.Init;
      MOBS.TMobS[id].MobsP[idGen].LastMyAttack := Now;
      MOBS.TMobS[id].MobsP[idGen].LastSkillAttack := Now;
      MOBS.TMobS[id].MobsP[idGen].CurrentPos := MOBS.TMobS[id].MobsP
        [idGen].InitPos;
      MOBS.TMobS[id].MobsP[idGen].XPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].YPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].NeighborIndex := -1;
    end
    else
    begin // mob change
      MobNameInit := MobN;
      Inc(id);
      idGen := 1;
      MOBS.TMobS[id].IndexGeneric := id;
      System.AnsiStrings.StrPLCopy(MOBS.TMobS[id].Name, AnsiString(MobN), 64);
      MOBS.TMobS[id].MobsP[idGen].Index := Count + 3048;
      if ((pos('Mutante', MobN) <> 0) or (pos('Crenon', MobN) <> 0)) then
      begin // mutantes não andam
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[10].ToSingle();
        if not(pos('Crenon', MobN) <> 0) then
          MOBS.TMobS[id].MobsP[idGen].isMutant := true;
      end
      else
      begin
        MOBS.TMobS[id].MobsP[idGen].InitPos.X := FileStrings[9].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].InitPos.Y := FileStrings[10].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.X :=
          FileStrings[14].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].FirstDestPos.Y :=
          FileStrings[15].ToSingle();
        MOBS.TMobS[id].MobsP[idGen].DestPos.X := MOBS.TMobS[id].MobsP[idGen]
          .DestPos.X + 5;
        MOBS.TMobS[id].MobsP[idGen].DestPos.Y := MOBS.TMobS[id].MobsP[idGen]
          .DestPos.Y + 5;
      end;
      MOBS.TMobS[id].MobsP[idGen].InitAttackRange :=
        FileStrings[11].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].InitMoveWait := FileStrings[12].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestAttackRange :=
        FileStrings[16].ToInteger();
      MOBS.TMobS[id].MobsP[idGen].DestMoveWait := FileStrings[17].ToInteger();
      MOBS.TMobS[id].MoveSpeed := 22;
      MOBS.TMobS[id].MobsP[idGen].Base.Create(nil, (Count + 3048),
        Self.ChannelId);
      MOBS.TMobS[id].MobsP[idGen].Base.Mobid := id;
      MOBS.TMobS[id].MobsP[idGen].Base.IsActive := true;
      MOBS.TMobS[id].MobsP[idGen].Base.ClientId := Count + 3048;
      MOBS.TMobS[id].MobsP[idGen].Base.SecondIndex := idGen;
      MOBS.TMobS[id].MobsP[idGen].MovedTo := TypeMobLocation.Init;
      MOBS.TMobS[id].MobsP[idGen].LastMyAttack := Now;
      MOBS.TMobS[id].MobsP[idGen].LastSkillAttack := Now;
      MOBS.TMobS[id].MobsP[idGen].CurrentPos := MOBS.TMobS[id].MobsP
        [idGen].InitPos;
      MOBS.TMobS[id].MobsP[idGen].XPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].YPositionsToMove := 1;
      MOBS.TMobS[id].MobsP[idGen].NeighborIndex := -1;
    end;
    FileStrings.Clear;
    Inc(Count);
    Inc(idGen);
  end;
  Path := GetCurrentDir + '\Data\Mobs\AllMobsInfo.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo AllMobsInfo.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;
  AssignFile(F, Path);
  Reset(F);
  FileStrings.Clear;
  id2 := 0;
  while not EOF(F) do
  begin
    ReadLn(F, LineFile);
    if (Trim(LineFile) = '') then
      Continue;
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    MobN := FileStrings[1];
    MobN := StringReplace(MobN, ' ', '_', [rfReplaceAll, rfIgnoreCase]);

    for i := 0 to 449 do
    begin


      if (MobN = String(MOBS.TMobS[i].Name)) then
      begin
        MOBS.TMobS[i].IntName := FileStrings[0].ToInteger();
        MOBS.TMobS[i].Equip[0] := word(FileStrings[2].ToInteger());
        MOBS.TMobS[i].Equip[1] := word(FileStrings[3].ToInteger());
        MOBS.TMobS[i].Equip[6] := word(FileStrings[4].ToInteger());
        MOBS.TMobS[i].InitHP := FileStrings[5].ToInteger();
        if (MOBS.TMobS[i].InitHP = 0) then
        begin
          MOBS.TMobS[i].InitHP := 3500;
        end;
        MOBS.TMobS[i].Rotation := FileStrings[6].ToInteger();
        MOBS.TMobS[i].MobLevel := FileStrings[7].ToInteger();
        MOBS.TMobS[i].MobElevation := word(FileStrings[8].ToInteger());
        MOBS.TMobS[i].Cabeca := FileStrings[9].ToInteger();
        MOBS.TMobS[i].Perna := FileStrings[10].ToInteger();
        MOBS.TMobS[i].MobType := FileStrings[11].ToInteger();
        MOBS.TMobS[i].SpawnType := FileStrings[12].ToInteger();
        MOBS.TMobS[i].IsService := WordBool(FileStrings[13].ToInteger);

        MOBS.TMobS[i].ReespawnTime := FileStrings[18].ToInteger();
        MOBS.TMobS[i].Skill01 := FileStrings[19].ToInteger();
        MOBS.TMobS[i].Skill02 := FileStrings[20].ToInteger();
        MOBS.TMobS[i].Skill03 := FileStrings[21].ToInteger();
        MOBS.TMobS[i].Skill04 := FileStrings[22].ToInteger();
        MOBS.TMobS[i].Skill05 := FileStrings[23].ToInteger();

        MOBS.TMobS[i].MobExp := FileStrings[24].ToInteger();
        MOBS.TMobS[i].DropIndex := FileStrings[25].ToInteger();

        MOBS.TMobS[i].IsActiveToSpawn := Boolean(FileStrings[26].ToInteger());

        // MOBS.TMobS[i].Equip[2] := WORD(FileStrings[27].ToInteger()); // Cabeça
        // MOBS.TMobS[i].Equip[3] := WORD(FileStrings[28].ToInteger()); // Armadura
        // MOBS.TMobS[i].Equip[4] := WORD(FileStrings[29].ToInteger()); // Luvas
        // MOBS.TMobS[i].Equip[5] := WORD(FileStrings[30].ToInteger()); // Botas
        // MOBS.TMobS[i].Equip[7] := WORD(FileStrings[31].ToInteger()); // Escudo

        { MOBS.TMobS[i].FisAtk :=
          RandomRange(15, (MOBS.TMobS[i].MobLevel * 6)+15);
          MOBS.TMobS[i].MagAtk :=
          RandomRange(15, (MOBS.TMobS[i].MobLevel * 6)+15);
          MOBS.TMobS[i].FisDef
          := RandomRange(15, (MOBS.TMobS[i].MobLevel * 12)+15);
          MOBS.TMobS[i].MagDef
          := RandomRange(15, (MOBS.TMobS[i].MobLevel * 12)+15); }

        Randomize;
        for j := 0 to 49 do
        begin
          if (MOBS.TMobS[i].MobsP[j].Index = 0) then
            Continue;

          if (MOBS.TMobS[i].InitHP > 1000000) then
          begin
            MOBS.TMobS[i].MobsP[j].Base.IsBoss := true;
          end;

          MOBS.TMobS[i].MobsP[j].HP := MOBS.TMobS[i].InitHP;
          MOBS.TMobS[i].MobsP[j].MP := MOBS.TMobS[i].InitHP;

          MOBS.TMobS[i].MobsP[j].LastSkillUsedByMob := Now;

          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNFis :=
            FileStrings[14].ToInteger();
          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNMag :=
            FileStrings[15].ToInteger();
          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefFis
            := FileStrings[16].ToInteger();
          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefMag
            := FileStrings[17].ToInteger();

          if (pos('Mutante', MobN) <> 0) then
          begin
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.
              Esquiva := MOB_ESQUIVA * 3; // estava 0
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.CritRes :=
              MOB_CRIT_RES * 3;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.DuploRes :=
              MOB_DUPLO_RES * 3;
          end
          else
          begin
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.
              Esquiva := MOB_ESQUIVA; // estava 0
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.DuploRes :=
              MOB_DUPLO_RES;
          end;

          MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.Nation :=
            Self.NationID; // Self.ChannelId + 1;
          MOBS.TMobS[i].MobsP[j].LastMyAttack := Now;
          MOBS.TMobS[i].MobsP[j].UpdatedMobSpawn := Now;
          MOBS.TMobS[i].MobsP[j].UpdatedMobHandler := Now;
          MOBS.TMobS[i].MobsP[j].UpdatedMobMoviment := Now;
          if (IfGuard(MOBS.TMobS[i].IntName) = true) then
          begin
            MOBS.TMobS[i].MobsP[j].isGuard := true;
            MOBS.TMobS[i].MobsP[j].CurrentPos := MOBS.TMobS[i].MobsP[j].InitPos;
            MOBS.TMobS[i].MobsP[j].DestPos := MOBS.TMobS[i].MobsP[j].InitPos;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNFis
              := MOB_GUARD_PATK;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DNMag
              := MOB_GUARD_MATK;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefFis
              := MOB_GUARD_PDEF;
            MOBS.TMobS[i].MobsP[j].Base.PlayerCharacter.Base.CurrentScore.DefMag
              := MOB_GUARD_MDEF;
          end;
        end;
        break;
      end
      else
      begin
        Continue;
      end;
    end;
    Inc(id2);
    FileStrings.Clear;
  end;

    if Self.ChannelId in [0,1,2]  then //se for canal menor que 4 =
    begin

      if (MobSpawnThread1 = nil) then
        MobSpawnThread1 := TMobSpawnThread1.Create(1500, Self.ChannelId, 0);

      if (MobHandlerThread1 = nil) then
        MobHandlerThread1 := TMobHandlerThread1.Create(1000, Self.ChannelId, 0);

      if (MobMovimentThread1 = nil) then
        MobMovimentThread1 := TMobMovimentThread1.Create(3000, Self.ChannelId, 0);

    end;

  FileStrings.Free;
  Logger.Write('[Server Mobs Init ] Mobs iniciados com sucesso. Mobs: ' +
    id.ToString + ' Spawns: ' + Count.ToString, TLogType.ServerStatus);
  CloseFile(DataFile);
  CloseFile(F);
end;

procedure TServerSocket.InitDungeons;
var
  Path: String;
  PathMobsInfo, PathMobsPos: String;
  PathMobsDropNon, PathMobsDropPrata, PathMobsDropDourada: String;
  DataFile, F: TextFile;
  FileStrings, MobFileStrings: TStringList;
  Count, count2, CountMob: DWORD;
  LineFile, LineMobFile: String;
  i, j: byte;
begin
  Path := GetCurrentDir + '\Data\Dungeons.csv';
  if not(FileExists(Path)) then
  begin
    Logger.Write('O arquivo Dungeons.csv não foi encontrado.',
      TLogType.Warnings);
    Exit;
  end;

  AssignFile(DataFile, Path);
  Reset(DataFile);
  FileStrings := TStringList.Create;
  Count := 0;
  while not EOF(DataFile) do
  begin
    ReadLn(DataFile, LineFile);
    ExtractStrings([','], [' '], PChar(LineFile), FileStrings);
    case Count of
      0: // ursula
        begin
          for i := 0 to 3 do
          begin
            Self.DGUrsula[i].Index := FileStrings[0].ToInteger();
            Self.DGUrsula[i].Dificult := i;
            Self.DGUrsula[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGUrsula[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGUrsula[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());

            // Logger.Write('DGUrsula Pos:' + String(Self.DGUrsula[i].SpawnInDungeonPosition.Create
            // (FileStrings[5].ToInteger(), FileStrings[6].ToInteger())), TLogType.Warnings);

            case Self.DGUrsula[i].Dificult of
              0:
                begin
                  Self.DGUrsula[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Zantorian Citadel_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Zantorian Citadel_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\zantorian\11.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\zantorian\12.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\zantorian\13.txt';
                end;
              1:
                begin
                  Self.DGUrsula[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Zantorian Citadel_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Zantorian Citadel_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\zantorian\21.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\zantorian\22.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\zantorian\23.txt';
                end;
              2:
                begin
                  Self.DGUrsula[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Zantorian Citadel_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Zantorian Citadel_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\zantorian\31.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\zantorian\32.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\zantorian\33.txt';
                end;
              3:
                begin
                  Self.DGUrsula[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Zantorian Citadel_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Zantorian Citadel_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\zantorian\31.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\zantorian\32.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\zantorian\33.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGUrsula[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();

              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Perna := 119;

              if (Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGUrsula[i].MOBS.TMobS[CountMob].Equip[0];

              Self.DGUrsula[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGUrsula[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGUrsula[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGUrsula[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGUrsula[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGUrsula[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGUrsula[i].MOBS.TMobS[j].cntControl;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGUrsula[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;

                  // if (MobFileStrings[7].ToInteger) = 2 then
                  // Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].isFinalBoss:= true;
                  //
                  // if (MobFileStrings[7].ToInteger) = 1 then
                  // Self.DGUrsula[i].MOBS.TMobS[j].MobsP[CountMob].isNormalBoss:= true;

                  Inc(Self.DGUrsula[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGUrsula[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGUrsula[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGUrsula[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Ursula ' + TDungeonDificultNames
              [Self.DGUrsula[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);

            CloseFile(F);
          end;
        end;
      1: // marauder hold
        begin
          for i := 0 to 3 do
          begin
            Self.DGEvgInf[i].Index := FileStrings[0].ToInteger();
            Self.DGEvgInf[i].Dificult := i;
            Self.DGEvgInf[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGEvgInf[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGEvgInf[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGEvgInf[i].Dificult of
              0:
                begin
                  Self.DGEvgInf[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Hold_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Hold_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_hold\41.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_hold\42.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_hold\43.txt';
                end;
              1:
                begin
                  Self.DGEvgInf[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Hold_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Hold_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_hold\51.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_hold\52.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_hold\53.txt';
                end;
              2:
                begin
                  Self.DGEvgInf[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Hold_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Hold_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_hold\61.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_hold\62.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_hold\63.txt';
                end;
              3:
                begin
                  Self.DGEvgInf[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Hold_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Hold_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_hold\61.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_hold\62.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_hold\63.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGEvgInf[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgInf[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGEvgInf[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGEvgInf[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGEvgInf[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGEvgInf[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGEvgInf[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGEvgInf[i].MOBS.TMobS[j].cntControl;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGEvgInf[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGEvgInf[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;
                  Inc(Self.DGEvgInf[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgInf[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgInf[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgInf[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Inf ' + TDungeonDificultNames
              [Self.DGEvgInf[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
      2: // marauder cabin
        begin
          for i := 0 to 3 do
          begin
            Self.DGEvgSup[i].Index := FileStrings[0].ToInteger();
            Self.DGEvgSup[i].Dificult := i;
            Self.DGEvgSup[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGEvgSup[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGEvgSup[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGEvgSup[i].Dificult of
              0:
                begin
                  Self.DGEvgSup[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Cabin_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Cabin_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\71.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\72.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\73.txt';
                end;
              1:
                begin
                  Self.DGEvgSup[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Cabin_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Cabin_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\81.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\82.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\83.txt';
                end;
              2:
                begin
                  Self.DGEvgSup[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Cabin_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Cabin_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\91.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\92.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\93.txt';
                end;
              3:
                begin
                  Self.DGEvgSup[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Marauder Cabin_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Marauder Cabin_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\91.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\92.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\marauder_cabin\93.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGEvgSup[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGUrsula[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGEvgSup[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGEvgSup[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGEvgInf[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGEvgSup[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGEvgSup[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGEvgSup[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGEvgSup[i].MOBS.TMobS[j].cntControl;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGEvgSup[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGEvgSup[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;
                  Inc(Self.DGEvgSup[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgSup[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgSup[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGEvgSup[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Evg Sup ' + TDungeonDificultNames
              [Self.DGEvgSup[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
      3: // Lost Mine 1
        begin
          for i := 0 to 3 do
          begin
            Self.DGMines1[i].Index := FileStrings[0].ToInteger();
            Self.DGMines1[i].Dificult := i;
            Self.DGMines1[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGMines1[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGMines1[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGMines1[i].Dificult of
              0:
                begin
                  Self.DGMines1[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines1\101.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines1\102.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines1\103.txt';
                end;
              1:
                begin
                  Self.DGMines1[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines1\201.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines1\202.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines1\203.txt';
                end;
              2:
                begin
                  Self.DGMines1[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines1\301.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines1\302.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines1\303.txt';
                end;
              3:
                begin
                  Self.DGMines1[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines1\301.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines1\302.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines1\303.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGMines1[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGMines1[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGMines1[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGMines1[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGMines1[i].MOBS.TMobS[CountMob].Equip[0];

              Self.DGMines1[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk;

              Self.DGMines1[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGMines1[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGMines1[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGMines1[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGMines1[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGMines1[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGMines1[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGMines1[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGMines1[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Info OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGMines1[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGMines1[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGMines1[i].MOBS.TMobS[j].cntControl;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGMines1[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGMines1[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;
                  Inc(Self.DGMines1[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Position OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines1[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Drops [Mobs sem Coroa] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines1[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines1[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine1 ' +
              TDungeonDificultNames[Self.DGMines1[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
      4: // kinary aviary
        begin
          for i := 0 to 3 do
          begin
            Self.DGKinary[i].Index := FileStrings[0].ToInteger();
            Self.DGKinary[i].Dificult := i;
            Self.DGKinary[i].EntranceNPCID := FileStrings[2].ToInteger();
            Self.DGKinary[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());
            Self.DGKinary[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());
            case Self.DGKinary[i].Dificult of
              0:
                begin
                  Self.DGKinary[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Kynari Aviary_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Kynari Aviary_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\kinary\401.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\kinary\402.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\kinary\403.txt';
                end;
              1:
                begin
                  Self.DGKinary[i].LevelMin := FileStrings[8].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Kynari Aviary_Dificil.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Kynari Aviary_Dificil.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\kinary\501.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\kinary\502.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\kinary\503.txt';
                end;
              2:
                begin
                  Self.DGKinary[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Kynari Aviary_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Kynari Aviary_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\kinary\601.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\kinary\602.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\kinary\603.txt';
                end;
              3:
                begin
                  Self.DGKinary[i].LevelMin := FileStrings[9].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Kynari Aviary_Elite.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Kynari Aviary_Elite.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\kinary\601.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\kinary\602.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\kinary\603.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGKinary[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGKinary[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGKinary[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGKinary[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGKinary[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGKinary[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGKinary[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGKinary[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGKinary[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGKinary[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGKinary[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGKinary[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobExp :=
              // Round(Self.DGMines1[i].MOBS.TMobS[CountMob].InitHP * 1.8);
                Round(Self.DGKinary[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGKinary[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGKinary[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] + ' Mobs Info OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGKinary[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGKinary[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGKinary[i].MOBS.TMobS[j].cntControl;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGKinary[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGKinary[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;
                  Inc(Self.DGKinary[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] + ' Mobs Position OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGKinary[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] + ' Mobs Drops [Mobs sem Coroa] OK.',
              TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGKinary[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGKinary[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Kinary ' + TDungeonDificultNames
              [Self.DGKinary[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;

      5: // Lost Mine 2
        begin
          for i := 0 to 0 do
          begin
            Self.DGMines2[i].Index := FileStrings[0].ToInteger();

            Self.DGMines2[i].Dificult := i;

            Self.DGMines2[i].EntranceNPCID := FileStrings[2].ToInteger();

            Self.DGMines2[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());

            Self.DGMines2[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());

            case Self.DGMines2[i].Dificult of
              0:
                begin
                  Self.DGMines2[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine2_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine2_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines2\701.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines2\702.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines2\703.txt';
                end;
              1:
                begin
                  Self.DGMines2[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine2_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine2_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines2\701.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines2\702.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines2\703.txt';
                end;
              2:
                begin
                  Self.DGMines2[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine2_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine2_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines2\701.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines2\702.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines2\703.txt';
                end;
              3:
                begin
                  Self.DGMines2[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine2_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine2_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines2\701.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines2\702.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines2\703.txt';
                end;
            end;
            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGMines2[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGMines2[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGMines2[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGMines2[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGMines2[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGMines2[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGMines2[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGMines2[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGMines2[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGMines2[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGMines2[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGMines2[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGMines2[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGMines2[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGMines2[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGMines2[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGMines2[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGMines2[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGMines2[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGMines2[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGMines2[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGMines2[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine2 ' +
              TDungeonDificultNames[Self.DGMines2[i].Dificult] +
              ' Mobs Info OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGMines2[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGMines2[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGMines2[i].MOBS.TMobS[j].cntControl;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGMines2[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGMines2[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;
                  Inc(Self.DGMines2[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine2 ' +
              TDungeonDificultNames[Self.DGMines2[i].Dificult] +
              ' Mobs Position OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines2[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine2 ' +
              TDungeonDificultNames[Self.DGMines2[i].Dificult] +
              ' Mobs Drops [Mobs sem Coroa] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines2[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine2 ' +
              TDungeonDificultNames[Self.DGMines2[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGMines2[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Lost Mine2 ' +
              TDungeonDificultNames[Self.DGMines2[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
        6: // Pheltas
        begin
          for i := 0 to 0 do
          begin
            Self.DGPheltas[i].Index := FileStrings[0].ToInteger();

            Self.DGPheltas[i].Dificult := i;

            Self.DGPheltas[i].EntranceNPCID := FileStrings[2].ToInteger();

            Self.DGPheltas[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());

            Self.DGPheltas[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());


                  Self.DGPheltas[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine2_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine2_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines2\701.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines2\702.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines2\703.txt';

            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGPheltas[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGPheltas[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGPheltas[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGPheltas[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGPheltas[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGPheltas[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGPheltas[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGPheltas[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGPheltas[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGPheltas[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGPheltas[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGPheltas[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGPheltas[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGPheltas[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGPheltas[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGPheltas[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGPheltas[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGPheltas[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGPheltas[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGPheltas[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGPheltas[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGPheltas[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine2 ' +
              TDungeonDificultNames[Self.DGPheltas[i].Dificult] +
              ' Mobs Info OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGPheltas[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGPheltas[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGPheltas[i].MOBS.TMobS[j].cntControl;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGPheltas[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGPheltas[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;
                  Inc(Self.DGPheltas[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Pheltas ' +
              TDungeonDificultNames[Self.DGPheltas[i].Dificult] +
              ' Mobs Position OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGPheltas[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Pheltas ' +
              TDungeonDificultNames[Self.DGPheltas[i].Dificult] +
              ' Mobs Drops [Mobs sem Coroa] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGPheltas[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Pheltas ' +
              TDungeonDificultNames[Self.DGPheltas[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGPheltas[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Pheltas ' +
              TDungeonDificultNames[Self.DGPheltas[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
        7: // prisao
        begin
          for i := 0 to 0 do
          begin
            Self.DGPrisao[i].Index := FileStrings[0].ToInteger();

            Self.DGPrisao[i].Dificult := i;

            Self.DGPrisao[i].EntranceNPCID := FileStrings[2].ToInteger();

            Self.DGPrisao[i].EntrancePosition.Create(FileStrings[3].ToInteger(),
              FileStrings[4].ToInteger());

            Self.DGPrisao[i].SpawnInDungeonPosition.Create
              (FileStrings[5].ToInteger(), FileStrings[6].ToInteger());


                  Self.DGPrisao[i].LevelMin := FileStrings[7].ToInteger();
                  PathMobsInfo := GetCurrentDir +
                    '\Data\MobsDungeon\MobInfo_Lost Mine2_Normal.csv';
                  PathMobsPos := GetCurrentDir +
                    '\Data\MobsDungeon\MobsPosition_Lost Mine2_Normal.csv';
                  PathMobsDropNon := GetCurrentDir +
                    '\Data\Drops\mines2\701.txt';
                  PathMobsDropPrata := GetCurrentDir +
                    '\Data\Drops\mines2\702.txt';
                  PathMobsDropDourada := GetCurrentDir +
                    '\Data\Drops\mines2\703.txt';

            if not(FileExists(PathMobsInfo)) then
            begin
              Logger.Write(PathMobsInfo + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsInfo);
            Reset(F);
            MobFileStrings := TStringList.Create;
            CountMob := 0;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              Self.DGPrisao[i].MOBS.TMobS[CountMob].IntName :=
                MobFileStrings[0].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].IndexGeneric :=
                CountMob + 2600;
              System.AnsiStrings.StrPLCopy(Self.DGPrisao[i].MOBS.TMobS[CountMob]
                .Name, AnsiString(MobFileStrings[1]), 64);
              Self.DGPrisao[i].MOBS.TMobS[CountMob].Equip[0] :=
                MobFileStrings[2].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].Equip[1] :=
                MobFileStrings[3].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].Equip[6] :=
                MobFileStrings[4].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].MobElevation := 7;
              Self.DGPrisao[i].MOBS.TMobS[CountMob].Cabeca := 119;
              Self.DGPrisao[i].MOBS.TMobS[CountMob].Perna := 119;
              if (Self.DGPrisao[i].MOBS.TMobS[CountMob].Equip[6] > 0) then
                Self.DGPrisao[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGPrisao[i].MOBS.TMobS[CountMob].Equip[6]
              else
                Self.DGPrisao[i].MOBS.TMobS[CountMob].FisAtk :=
                  Self.DGPrisao[i].MOBS.TMobS[CountMob].Equip[0];
              Self.DGPrisao[i].MOBS.TMobS[CountMob].MagAtk :=
                Self.DGPrisao[i].MOBS.TMobS[CountMob].FisAtk;
              Self.DGPrisao[i].MOBS.TMobS[CountMob].FisDef :=
                (Self.DGPrisao[i].MOBS.TMobS[CountMob].FisAtk * 2);
              Self.DGPrisao[i].MOBS.TMobS[CountMob].MagDef :=
                Self.DGPrisao[i].MOBS.TMobS[CountMob].FisDef;
              Self.DGPrisao[i].MOBS.TMobS[CountMob].MoveSpeed := 25;
              Self.DGPrisao[i].MOBS.TMobS[CountMob].InitHP :=
                MobFileStrings[5].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].MobExp :=
                Round(Self.DGPrisao[i].MOBS.TMobS[CountMob].InitHP * 1.8);
              Self.DGPrisao[i].MOBS.TMobS[CountMob].MobLevel :=
                MobFileStrings[7].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].Rotation :=
                MobFileStrings[6].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].MobType :=
                MobFileStrings[11].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].cntControl := 0;
              Self.DGPrisao[i].MOBS.TMobS[CountMob].SpawnType :=
                MobFileStrings[16].ToInteger();
              Self.DGPrisao[i].MOBS.TMobS[CountMob].DungeonDropIndex :=
                MobFileStrings[18].ToInteger();
              Inc(CountMob);
              MobFileStrings.Clear;
            end;
            Logger.Write('[Server Mobs Init] Lost Mine2 ' +
              TDungeonDificultNames[Self.DGPrisao[i].Dificult] +
              ' Mobs Info OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsPos)) then
            begin
              Logger.Write(PathMobsPos + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsPos);
            Reset(F);
            MobFileStrings := TStringList.Create;
            while not EOF(F) do
            begin
              ReadLn(F, LineMobFile);
              MobFileStrings.Clear;
              ExtractStrings([','], [' '], PChar(LineMobFile), MobFileStrings);
              for j := 0 to 44 do
              begin
                if (Self.DGPrisao[i].MOBS.TMobS[j].IntName = 0) then
                  Continue;
                if (Self.DGPrisao[i].MOBS.TMobS[j].IntName = MobFileStrings[6]
                  .ToInteger()) then
                begin
                  CountMob := Self.DGPrisao[i].MOBS.TMobS[j].cntControl;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].Index :=
                    MobFileStrings[0].ToInteger();
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].HP :=
                    MobFileStrings[2].ToInteger();
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].MP :=
                    Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].HP;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].InitPos.Create
                    (MobFileStrings[3].ToInteger(),
                    MobFileStrings[4].ToInteger());
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].DestPos :=
                    Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].InitPos;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .InitAttackRange := 20;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .DestAttackRange := 20;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Create(nil, Self.DGPrisao[i].MOBS.TMobS[j].MobsP
                    [CountMob].Index, Self.ChannelId);
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.IsActive := true;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].Base.ClientId
                    := Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob].Index;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.Mobid := j;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.SecondIndex := CountMob;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.CurrentScore.Esquiva :=
                    MOB_ESQUIVA;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .Base.PlayerCharacter.Base.Nation := Self.ChannelId + 1;
                  Self.DGPrisao[i].MOBS.TMobS[j].MobsP[CountMob]
                    .LastMyAttack := Now;
                  Inc(Self.DGPrisao[i].MOBS.TMobS[j].cntControl);
                  break;
                end
                else
                  Continue;
              end;
            end;
            Logger.Write('[Server Mobs Init] Prisao ' +
              TDungeonDificultNames[Self.DGPrisao[i].Dificult] +
              ' Mobs Position OK.', TLogType.ServerStatus);
            CloseFile(F);
            MobFileStrings.Free;
            if not(FileExists(PathMobsDropNon)) then
            begin
              Logger.Write(PathMobsDropNon + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropNon);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGPrisao[i].MobsDrop.SemCoroa[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Pheltas ' +
              TDungeonDificultNames[Self.DGPrisao[i].Dificult] +
              ' Mobs Drops [Mobs sem Coroa] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropPrata)) then
            begin
              Logger.Write(PathMobsDropPrata + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropPrata);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGPrisao[i].MobsDrop.CoroaPrata[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Pheltas ' +
              TDungeonDificultNames[Self.DGPrisao[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Prata] OK.', TLogType.ServerStatus);
            CloseFile(F);
            if not(FileExists(PathMobsDropDourada)) then
            begin
              Logger.Write(PathMobsDropDourada + ' não foi encontrado.',
                TLogType.Warnings);
              Exit;
            end;
            AssignFile(F, PathMobsDropDourada);
            Reset(F);
            count2 := 0;
            while not(EOF(F)) do
            begin
              ReadLn(F, LineMobFile);
              Self.DGPrisao[i].MobsDrop.CoroaDourada[count2] :=
                StrToInt(LineMobFile);
              Inc(count2);
            end;
            Logger.Write('[Server Mobs Init] Pheltas ' +
              TDungeonDificultNames[Self.DGPrisao[i].Dificult] +
              ' Mobs Drops [Mobs Coroa Dourada] OK.', TLogType.ServerStatus);
            CloseFile(F);
          end;
        end;
    end;
    FileStrings.Clear;
    Inc(Count);
  end;
  CloseFile(DataFile);
end;
// procedure TServerSocket.AcceptConnection;
// var
// ClientInfo: PSockAddr;
// Clid: Integer;
// FSock: Cardinal;
// Margv: Cardinal;
// Xargv: AnsiChar;
// begin
// ClientInfo := nil;
// FSock := accept(Self.Sock, ClientInfo, nil);
// try
// if (FSock = INVALID_SOCKET) or (Self.ServerHasClosed) then
// Exit;
//
// Clid := TFunctions.FreeClientId(Self.ChannelId);
// if Clid = 0 then
// Exit;
//
// Margv := 1;
// if ioctlsocket(FSock, FIONBIO, Margv) < 0 then
// begin
// Logger.Write('Erro ao configurar o socket para Non-Blocking.', TLogType.Warnings);
// closesocket(FSock);
// Exit;
// end;
//
// Xargv := '1';
// if setsockopt(FSock, IPPROTO_TCP, TCP_NODELAY, @Xargv, 1) <> 0 then
// begin
// Logger.Write('Erro ao configurar o socket para TCP_NODELAY. ' + WSAGetLastError.ToString, TLogType.Warnings);
// closesocket(FSock);
// Exit;
// end;
//
// ZeroMemory(@Self.Players[Clid], SizeOf(TPlayer));
//
// Self.Players[Clid].socket := FSock;
// Self.Players[Clid].Authenticated := False;
// Self.Players[Clid].ConnectionedTime := Now;
//
// WriteLn('tentando criar thread');
/// /      PlayerThreadPool.Queue(TPlayerThread.Create(Clid, FSock, Self.ChannelId));
// TPlayerThread.Create(Clid, FSock, Self.ChannelId);
/// /        PlayerThreadPool.Queue(TPlayerThread.Create(Clid, FSock, Self.ChannelId));
//
//
// except
// on E: Exception do
// begin
// Logger.Write('Erro em AcceptConnection: ' + E.Message + Chr(13) + E.StackTrace, TLogType.Error);
// end;
// end;
// end;

{$ENDREGION}
{$REGION 'Player Functions'}

function TServerSocket.GetPlayer(const ClientId: word): PPlayer;
begin
  if ((Self.Players[ClientId].Base.ClientId > 0) and
    not(Self.Players[ClientId].SocketClosed)) then
  begin
    Result := @Self.Players[ClientId];
  end
  else
  begin
    Result := nil;
  end;
end;

function TServerSocket.GetPlayer(const CharacterName: string): PPlayer;
var
  i: integer;
begin
  Result := Nil;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Self.Players[i].Character.Base.Name = '') then
      Continue;
    if (string(Players[i].Character.Base.Name) = CharacterName) then
    begin
      Result := @Self.Players[i];
      break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Disconnect Functions'}

procedure TServerSocket.DisconnectAll;
var
  i: word;
  cnt: word;
begin
  cnt := 0;
  for i := 1 to MAX_CONNECTIONS do
    if Self.Players[i].Base.IsActive then
    begin
      // Self.PlayerThreads[i].Term := true;
      // Self.Players[i].PlayerThreadActive := false;
      Self.Disconnect(Self.Players[i]);
      Inc(cnt, 1);
    end;
  if (cnt > 0) then
    Logger.Write('[' + string(ServerList[ChannelId].Name) +
      ']: Foram desconectados ' + IntToStr(cnt) + ' jogadores.',
      TLogType.ConnectionsTraffic);
end;

procedure TServerSocket.Disconnect(ClientId: word);
begin
  if (ClientId = 0) then
    Exit;
  if not(Players[ClientId].Base.IsActive) then
    Exit;
  Self.Disconnect(Players[ClientId]);
end;

procedure TServerSocket.Disconnect(var Player: TPlayer);
var
  cid: word;
begin
  if (Trim(String(Player.Account.Header.userName)) = '') then
    Exit;
  if (Player.Base.ClientId = 0) then
    Exit;
  cid := Player.Base.ClientId;
  if not(Player.xdisconnected) then
  begin
    Player.Destroy;
    // Logger.Write('[' + string(ServerList[ChannelId].Name) + ']: O jogador ' +
    // string(Player.Account.Header.userName) + ' [ClientId: ' +
    // IntToStr(cid) + '] se desconectou.', ConnectionsTraffic);
  end; // cmd comentado
  Player.Party := nil;
end;

procedure TServerSocket.Disconnect(userName: string);
var
  i: integer;
begin
  for i := 1 to (MAX_CONNECTIONS) do
  begin
    if not(Players[i].Base.IsActive) then
      Continue;
    if (string(Players[i].Account.Header.userName) = userName) then
    begin
      Players[i].SocketClosed := true;
      break;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Send Functions'}

procedure TServerSocket.SendPacketTo(ClientId: integer; var Packet; Size: word;
  Encrypt: Boolean);
begin
  if Self.Players[ClientId].Base.IsActive then
    Self.Players[ClientId].SendPacket(Packet, Size, Encrypt);
end;

procedure TServerSocket.SendSignalTo(ClientId: integer; pIndex, opCode: word);
var
  Signal: TPacketHeader;
begin
  if (ClientId <= MAX_CONNECTIONS) and Self.Players[ClientId].Base.IsActive then
  begin
    ZeroMemory(@Signal, SizeOf(TPacketHeader));
    Signal.Size := 12;
    Signal.Index := pIndex;
    Signal.Code := opCode;
    Self.Players[ClientId].SendPacket(Signal, Signal.Size, true);
  end;
end;

procedure TServerSocket.SendToVisible(var Base: TBaseMob; var Packet;
  Size: word);
var
  i: integer;
begin
  for i in Base.VisiblePlayers do
  begin
    with Self.Players[i] do
    begin
      if (Status = Playing) and not SocketClosed then
        SendPacket(Packet, Size);
    end;
  end;
end;

procedure TServerSocket.SendToAll(var Packet; Size: word);
var
  i: integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    with Self.Players[i] do
    begin
      if (Status = Playing) and not SocketClosed then
        SendPacket(Packet, Size);
    end;
  end;
end;

procedure TServerSocket.SendServerMsg(Mensg: AnsiString; MsgType: integer = 16;
  Null: integer = 0; Type2: integer = 0; SendToSelf: Boolean = true;
  MyClientID: word = 0);
var
  i: integer;
  key: TPlayerKey;
  xPlayer: PPlayer;

begin

  for Key in ActivePlayers.Keys do
  begin

    if Key.ServerID <> Self.ChannelId then
    continue;

    // Acessa o jogador associado à chave
    xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

    if not TFunctions.IsPlayerPlaying(xPlayer) then
    continue;

    if not(SendToSelf) and (i = MyClientID) then
    continue;

     xPlayer.SendClientMessage(Mensg, MsgType, Null, Type2);


	end;

        {
  for i := 1 to MAX_CONNECTIONS do
  begin
    // Condições combinadas para otimizar o laço
    if (Self.Players[i].Status <> Playing) or (Self.Players[i].SocketClosed) or
      ((not SendToSelf) and (i = MyClientID)) then
      Continue;

    Self.Players[i].SendClientMessage(Mensg, MsgType, Null, Type2);
  end; }
end;

procedure TServerSocket.SendElterMsg(Mensg: AnsiString; MsgType: integer = 16;
  Null: integer = 0; Type2: integer = 0; SendToSelf: Boolean = true;
  MyClientID: word = 0);
var
  i: integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    // Condições combinadas para otimizar o laço
    if (Self.Players[i].Status <> Playing) or (Self.Players[i].SocketClosed) or
      ((not SendToSelf) and (i = MyClientID)) or (Self.Players[i].Waiting1 <> 0)
    then
      Continue;

    Self.Players[i].SendClientMessage(Mensg, MsgType, Null, Type2);
  end;
end;

procedure TServerSocket.SendServerMsgForNation(Mensg: AnsiString; aNation: byte;
  MsgType: integer = $10; Null: integer = 0; Type2: integer = 0;
  SendToSelf: Boolean = true; MyClientID: word = 0);
var
  i: integer;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    // Condições combinadas para otimizar o laço
    if (Self.Players[i].Status <> Playing) or (Self.Players[i].SocketClosed) or
      ((not SendToSelf) and (i = MyClientID)) then
      Continue;

    if (Self.Players[i].Base.Character.Nation = aNation) then
      Self.Players[i].SendClientMessage(Mensg, MsgType, Null, Type2);
  end;
end;

{$ENDREGION}
{$REGION 'PacketControl'}

function TServerSocket.PacketControl(var Player: TPlayer; var Size: word;
  var Buffer: array of byte; initialOffset: integer): Boolean;
var
  Header: TPacketHeader;
  Log: String;
  i: integer;
  LastTime: TDateTime;

begin
  ZeroMemory(@Header, SizeOf(TPacketHeader));
  Move(Buffer, Header, SizeOf(TPacketHeader));
  Header.Index := Player.Base.ClientId;
  Result := true;

  // Imprimir o nome da função
  case Header.Code of

    $362: // inicia a pescaria
      try
        begin
          Player.SetLastPacketTime(Header.Code);

          if (Player.IsInstantiated) then
            TPacketHandlers.StartFishing(Player, Buffer);

        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: StartFishing error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar Player
          // Player.SocketClosed := True;
        end;
      end;

    $363: // finaliza a pescaria
      try
        begin
          Player.SetLastPacketTime(Header.Code);

          if (Player.IsInstantiated) then
            TPacketHandlers.EndFishing(Player, Buffer);

        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: StartFishing error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar Player
          // Player.SocketClosed := True;
        end;
      end;

    $222: // inicia a pescaria
      try
        begin
          Player.SetLastPacketTime(Header.Code);

          if (Player.IsInstantiated) then
            TPacketHandlers.StartJoquempo(Player, Buffer);

        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: StartJoquempo error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar Player
          // Player.SocketClosed := True;
        end;
      end;

    $F71: // novo entrar elter via botao BA
      try
        Player.SetLastPacketTime(Header.Code);
        WriteLn('tentando acessar elter via novo pacote');
        if (Player.IsInstantiated) then
          TPacketHandlers.EntrarElter(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: Elter error. msg[' + E.Message + ' : ' +
            E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar Player
          // Player.SocketClosed := True;
        end;
      end;

    $394: // entrar na elter
      try
        WriteLn('entrando na elter via metodo antigo');
        Player.SetLastPacketTime(Header.Code);
        if (Player.IsInstantiated) then
          TPacketHandlers.EntrarElter(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: Elter error. msg[' + E.Message + ' : ' +
            E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar Player
          // Player.SocketClosed := True;
        end;
      end;
    $308: // registrar karak aereo
      try
        if (Player.IsInstantiated) and not Player.ChangingChannel then
          TPacketHandlers.KarakAereo(Player, Buffer);

      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: Karak Aereo error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar Player
          // Player.SocketClosed := True;
        end;
      end;
    // $320:         //uso de skill
    // try
    // begin
    // Player.SetLastPacketTime(Header.Code);
    //
    // if (Player.IsInstantiated) then
    // TPacketHandlers.UseSkill(Player, Buffer);
    //
    // end;
    // except
    // on E: Exception do
    // begin
    // Logger.Write('PacketControl: UseSkill error. msg[' + E.Message + ' : '
    // + E.GetBaseException.Message + '] username[' +
    // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
    // '.', TLogType.Error);
    // //Disconectar Player
    // //Player.SocketClosed := True;
    // end;
    // end;
    // $302:         //ataque basico
    // try
    // begin
    // Player.SetLastPacketTime(Header.Code);
    //
    // if (Player.IsInstantiated) then
    // TPacketHandlers.AttackTarget(Player, Buffer);
    //
    // end;
    // except
    // on E: Exception do
    // begin
    // Logger.Write('PacketControl: AttackTarget error. msg[' + E.Message +
    // ' : ' + E.GetBaseException.Message + '] username[' +
    // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
    // '.', TLogType.Error);
    // //Disconectar player add dia 08/07/2024
    // //Player.SocketClosed := True;
    // end;
    // end;
    $364: // PkMdeNovo
      try
        begin
          WriteLn('tentando ativar pk via novo pacote');
          Player.SetLastPacketTime(Header.Code);

          if (Player.IsInstantiated) then
            TPacketHandlers.PKMode(Player);

        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: PKModeNovo error. msg[' + E.Message +
            ' : ' + E.GetBaseException.Message + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar player add dia 08/07/2024
          // Player.SocketClosed := True;
        end;
      end;

    // $301: //pacote de movimento, não mexer nesse com filtro de pacotes
    // try
    // Player.SetLastPacketTime(Header.Code);
    // if (Player.IsInstantiated) then
    // TPacketHandlers.MovementCommand(Player, Buffer);
    //
    // except
    // on E: Exception do
    // begin
    // Logger.Write('PacketControl: MovementCommand error. msg[' + E.Message
    // + ' : ' + chr(13) + E.StackTrace + '] username[' +
    // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
    // '.', TLogType.Error);
    // Player.SocketClosed := True;
    // abort;
    // end;
    // end;
    $70F: // move o item de slot
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;

        if (Player.IsInstantiated) and not Player.ChangingChannel then
        begin
          TPacketHandlers.MoveItem(Player, Buffer);
        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: MoveItem error. msg[' + E.Message + ' : '
            + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // add dia 08/07/2024
          // Disconectar player
          Player.SocketClosed := true;
        end;
      end;

    $31D: // uso de item
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        if (Player.IsInstantiated) then
          TPacketHandlers.UseItem(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: UseItem error. msg[' + E.Message + ' : '
            + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar player add dia 08/07/2024
          Player.SocketClosed := true;
        end;
      end;
    $21B: // uso de buffitem
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        if (Player.IsInstantiated) then
          TPacketHandlers.UseBuffItem(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: UseBuffItem error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar player add dia 08/07/2024
          Player.SocketClosed := true;
        end;

      end;
    $305: // nao mexer, rotação do player
      try
        Player.SetLastPacketTime(Header.Code);
        TPacketHandlers.UpdateRotation(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: UpdateRotation error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar player add dia 08/07/2024
          Player.SocketClosed := true;
        end;
      end;
    // $218:                                   //pacote de enviar skill da montaria
    // try
    // Player.SetLastPacketTime(Header.Code);
    // if (Player.IsInstantiated) then
    // TPacketHandlers.UseMountSkill(Player, Buffer);
    // Writeln('Usando skill de montaria');
    //
    //
    //
    // except
    // on E: Exception do
    // begin
    // Logger.Write('PacketControl: UseMountSkill error. msg[' + E.Message + ' : '
    // + chr(13) + E.StackTrace + '] username[' +
    // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
    // '.', TLogType.Error);
    // //Disconectar player add dia 08/07/2024
    // Player.SocketClosed := True;
    // end;
    // end;
    $30F: // pacote envia funcao de abre o npc
      try
        Player.SetLastPacketTime(Header.Code);
        if (Player.IsInstantiated) then
          TPacketHandlers.OpenNPC(Player, Buffer);

      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: OpenNPC error. msg[' + E.Message + ' : '
            + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Disconectar player add dia 08/07/2024
          Player.SocketClosed := true;
        end;
      end;
    $31E: // pacote muda o item na barra de skills
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        if (Player.IsInstantiated) then
          TPacketHandlers.ChangeItemBar(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: ChangeItemBar error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $668: // pacote de voltar pra selecao de personagem
      try
        // Player.SocketClosed := True;
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        Player.SendClientMessage
          ('Essa função foi temporariamente desativada. DESATIVE O QUANTO ANTES!!!');
        Player.BackToCharList;
        Player.SendClientMessage
          ('Essa função foi temporariamente desativada. DESATIVE O QUANTO ANTES!!!');
      except
        on E: Exception do
        begin
          Player.SocketClosed := true;
          Logger.Write('PacketControl: BackToCharList error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
        end;
      end;

    $F0B: // mensagem de inicio + send to world
      try
        Player.SetLastPacketTime(Header.Code);
        if (Player.LoggedByOtherChannel) then
        begin
          Player.LoggedByOtherChannel := False;
        end
        else
          Player.SendToWorldSends;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: SendToWorldSends error. msg[' + E.Message
            + ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
          abort;
        end;
      end;
    $F86:
      try
        // Atualiza o tempo do último pacote enviado
        Player.SetLastPacketTime(Header.Code);

        if (Player.IsInstantiated) then
          TPacketHandlers.SendClientSay(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: SendClientSay error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
          abort;
        end;
      end;
    $20A: // botar cash
      try
        Player.SetLastPacketTime(Header.Code);
        Player.SendPlayerCash;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: SendPlayerCash error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
          abort;
        end;
      end;
    $327: // cancela o lançamento de skills
      try
        Player.SetLastPacketTime(Header.Code);
        TPacketHandlers.CancelSkillLaunching(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: CancelSkillLaunching error. msg[' +
            E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
          abort;
        end;
      end;
    $202:
      try
        Player.SetLastPacketTime(Header.Code);
        TPacketHandlers.RequestServerTime(Player, Buffer);
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: RequestServerTime error. msg[' +
            E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          Player.SocketClosed := true;
          abort;
        end;
      end;
    $207:
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        TPacketHandlers.GiveLeaderRaid(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GiveLeaderRaid error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $209:
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        if (Player.IsInstantiated) then
          TPacketHandlers.BuyItemCash(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: BuyItemCash error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $213:
      try
        Player.SetLastPacketTime(Header.Code);
        TPacketHandlers.GetStatusPoint(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: GetStatusPoint error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;

    $21A:
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        TPacketHandlers.RenoveItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenoveItem error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $22A:
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        TPacketHandlers.RenoveItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RenoveItem error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $224:
      try
        Player.SetLastPacketTime(Header.Code);
        if Player.ChangingChannel then
        begin
          Player.SendClientMessage
            ('Aguarde um momento até efetuar uma ação após trocar de canal');
          Exit;
        end;
        TPacketHandlers.UnsealItem(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: UnsealItem error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $22C:
      try
        Player.SetLastPacketTime(Header.Code);
        if not(TPacketHandlers.RequestCharInfo(Player, Buffer)) then
        begin
          Player.SendClientMessage('Alvo não está logado.');
        end;
      except
        on E: Exception do
        begin
          Logger.Write('PacketControl: RequestCharInfo error. msg[' + E.Message
            + ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
          // Player.SocketClosed := True;
        end;
      end;
    $22D:
      try
        Player.SetLastPacketTime(Header.Code);
        if (Player.IsInstantiated) then
          TPacketHandlers.SendItemChat(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: SendItemChat error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $303:
      try
        Player.SetLastPacketTime(Header.Code);
        TPacketHandlers.RevivePlayer(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: RevivePlayer error. msg[' + E.Message +
            ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $304:
      try
        Player.SetLastPacketTime(Header.Code);
        TPacketHandlers.UpdateAction(Player, Buffer);
      except
        on E: Exception do
          Logger.Write('PacketControl: CharacterActionSend(0x304) error. msg[' +
            E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
            String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now) +
            '.', TLogType.Error);
      end;
    $306:
      try
        Player.SetLastPacketTime(Header.Code);
        if (Player.IsInstantiated) then
          // TPacketHandlers.UpdateMobInfo(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateMobInfo(0x306) error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $307:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.PKMode(Player);
        except
          on E: Exception do
            Logger.Write('PacketControl: PKMode error. msg[' + E.Message + ' : '
              + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $313:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.BuyNPCItens(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: BuyNPCItens error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $314:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.SellNPCItens(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SellNPCItens error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $315:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.TradeRequest(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: TradeRequest error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $316:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.TradeResponse(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: TradeResponse error. msg[' + E.Message
              + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $317:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.TradeRefresh(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: TradeRefresh error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $318:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.TradeCancel(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: TradeCancel error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $319:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.CreatePersonalShop(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: CreatePersonalShop error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $31A:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.OpenPersonalShop(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: OpenPersonalShop error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $31B:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.BuyPersonalShopItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: BuyPersonalShopItem error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $31C:
        try
          TPacketHandlers.LearnSkill(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: LearnSkill error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $322:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.SendParty(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SendParty error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $323:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.AcceptParty(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AcceptParty error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $324:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.KickParty(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: KickParty error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $325:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.DestroyParty(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: DestroyParty error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $326:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.PartyAlocateConfig(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: PartyAlocateConfig error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $329:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.RemoveBuff(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RemoveBuff error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $32A:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.ResetSkills(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ResetSkills error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $32B:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.MakeItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: MakeItem error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $32C:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.DeleteItem(Player, Buffer);
        except
          on E: Exception do
          begin
            Logger.Write('PacketControl: DeleteItem error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
            Player.SocketClosed := true;
            abort;
          end;
        end;
      $32D:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.ChangeItemAttribute(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ChangeItemAttribute error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $32F:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.AbandonQuest(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AbandonQuest error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $332:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.AgroupItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AgroupItem error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $333:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.UngroupItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UngroupItem error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $334:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.RequestEnterDungeon(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $336:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.CollectMapItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $338:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.UpdateMemberPosition(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateMemberPosition error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $33A:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.CancelCollectMapItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestEnterDungeon error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $340:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.RepairItens(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: CreateGuild error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $341:
        try
          Player.SetLastPacketTime(Header.Code);
          if (Player.IsInstantiated) then
            TPacketHandlers.CreateGuild(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: CreateGuild error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $342:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.SendRaid(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SendRaid error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $909:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.SendRaid(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SendRaid error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $343:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.AcceptRaid(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AcceptRaid error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $344:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.ExitRaid(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ExitRaid error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $348: // nao mexer
        try
          begin
            Player.SetLastPacketTime(Header.Code);
            // Player.OpennedNPC := 0; descomentar
            // Player.OpennedOption := 0;
            TPacketHandlers.CloseNPCOption(Player, Buffer);
          end;
        except
          on E: Exception do
            Logger.Write('PacketControl: CloseNPCOption error. msg[' + E.Message
              + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $34A:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.TeleportSetPosition(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: TeleportSetPosition error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $34B:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.GiveLeaderParty(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: GiveLeaderParty error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $355:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.DungeonLobbyConfirm(Player, Buffer);

        except
          on E: Exception do
            Logger.Write('PacketControl: DungeonLobbyConfirm error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $356:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.SendGift(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SendGift error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $359:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.ReceiveEventItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ReceiveEventItem error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $361:
        try
          Player.SetLastPacketTime(Header.Code);
          if (Player.IsInstantiated) then
            TPacketHandlers.UpdateActiveTitle(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateActiveTitle error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $372:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.AddFriendRequest(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AddFriendRequest error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $38F:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.AddSelfParty(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AddSelfParty error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $395:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.SendRequestDuel(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SendRequestDuel error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $396:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.DuelResponse(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: DuelResponse error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $397:
        try
          Player.SetLastPacketTime(Header.Code);
          if (Player.IsInstantiated) then
            TPacketHandlers.StartF12(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: Auto-Caça error. msg[' + E.Message +
              ' : ' + E.GetBaseException.Message + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $673:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.AddFriendResponse(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AddFriendResponse error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $619:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.ChangeMasterGuild(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: AddFriendResponse error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $67D:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.InviteToGuildAccept(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: InviteToGuildAccept error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $685:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.CheckLogin(Player, Buffer);
        except
          on E: Exception do
          begin
            Logger.Write('PacketControl: CheckLogin error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
          end;
        end;

      $603:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.RequestDeleteChar(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestDeleteChar error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $B52:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.RequestUpdateReliquare(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestUpdateReliquare error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3961: // quando aperta u, ele atualiza
        try
          var
            Channel: integer;
            // Player.SetLastPacketTime(Header.Code);
          if (Servers[Player.ChannelIndex].Players[Player.Base.ClientId]
            .ChannelIndex = 0) then
            Channel := 0;

          Player.SendUpdateReliquareInformation(Player.ChannelIndex);
          Player.SendUpdateReliquareInformation(Channel);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestUpdateReliquare error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $E3A:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.UpdateNationTaxes(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateNationTaxes error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $E51:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          TPacketHandlers.MoveItemToReliquare(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: MoveItemToReliquare error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;

      $F02:
        try
          Player.SetLastPacketTime(Header.Code);

          TPacketHandlers.NumericToken(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: NumericToken error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F05:
        try
          Player.SetLastPacketTime(Header.Code);
          if (Player.IsInstantiated) then
            TPacketHandlers.ChangeChannel(Player, Buffer);
          if (SecondsBetween(Now, Player.Base.LastReceivedAttack) <= 10) or
            (SecondsBetween(Now, Player.LastAttackSents) <= 10) then
          begin
            Player.SendClientMessage
              ('Você não pode mudar de canal em modo ataque!');
            Exit;
          end;
        except
          on E: Exception do
            Logger.Write('PacketControl: ChangeChannel error. msg[' + E.Message
              + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F06:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.LoginIntoChannel(Player, Buffer);
        except
          on E: Exception do
          begin
            Logger.Write('PacketControl: LoginIntoChannel error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
            Player.SocketClosed := true;
            abort;
          end;
        end;
      $F1C:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.ExitGuild(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ExitGuild error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F1D:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.ChangeGuildMemberRank(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ChangeGuildMemberRank error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F12:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.RequestGuildToAlly(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestGuildAlliance error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F20:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.UpdateGuildNotices(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateGuildNotices error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F21:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.UpdateGuildSite(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateGuildSite error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F22:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.UpdateGuildRanksConfig(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateGuildRanksConfig error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F26:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.SendFriendSay(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SendFriendSay error. msg[' + E.Message
              + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F2D:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.KickMemberOfGuild(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: KickMemberOfGuild error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F2F:
        try
          begin
            Player.SetLastPacketTime(Header.Code);
            TPacketHandlers.CloseGuildChest(Player, Buffer);
            WriteLn('fechou npc bau guild');
          end;
        except
          on E: Exception do
            Logger.Write('PacketControl: CloseGuildChest error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F27:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.OpenFriendWindow(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: OpenFriendWindow error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F30:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.CloseFriendWindow(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: CloseFriendWindow error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F34:
        try
          TPacketHandlers.UpdateNationGold(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: UpdateNationGold error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F59:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.ChangeGold(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ChangeGold error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F74:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.DeleteFriend(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: DeleteFriend error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F7B:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.InviteToGuildRequest(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: InviteToGuildRequest error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $F7E:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.InviteToGuildDeny(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: InviteToGuildDeny error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3E01:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.DeleteChar(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: DeleteChar error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3E04:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.CreateCharacter(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: CreateCharacter error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3E02:
        try
          Player.SetLastPacketTime(Header.Code);
          if (Player.IsInstantiated) then
            TPacketHandlers.RenamePran(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RenamePran error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F15:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.sendCharacterMail(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: SendCharacterMail error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F16:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.checkSendMailRequirements(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: checkSendMailRequirements error. msg['
              + E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F17:
        try
          Player.SetLastPacketTime(Header.Code);
          TEntityMail.sendMailList(Player);
        except
          on E: Exception do
            Logger.Write('PacketControl: sendMailList error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F18:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.OpenMail(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: OpenMail error. msg[' + E.Message +
              ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F1A:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.withdrawMailItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: withdrawMailItem error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F0D:
        try
          Player.SetLastPacketTime(Header.Code);
          if (Player.IsInstantiated) then
            TPacketHandlers.RequestAuctionItems(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestAuctionItems error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F0B:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.RequestRegisterItem(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestRegisterItem error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F11:
        try
          Player.SetLastPacketTime(Header.Code);
          if (Player.IsInstantiated) then
            TPacketHandlers.RequestOwnAuctionItems(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestOwnAuctionItems error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F10:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.RequestAuctionOfferCancel(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestAuctionOfferCancel error. msg['
              + E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $3F0C:
        try
          Player.SetLastPacketTime(Header.Code);
          if Player.ChangingChannel then
          begin
            Player.SendClientMessage
              ('Aguarde um momento até efetuar uma ação após trocar de canal');
            Exit;
          end;
          if (Player.IsInstantiated) then
            TPacketHandlers.RequestAuctionOfferBuy(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestAuctionOfferBuy error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;

      $F93A:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.RequestServerPing(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestServerPing error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;

      $3E05:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.ReclaimCoupom(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: ReclaimCoupom error. msg[' + E.Message
              + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;

      $925:
        begin
          // exit;
        end;

      $F79:
        begin
          // exit;
        end;

{$REGION 'Packets from GM TOOL'}
        // $3202:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.CheckGMLogin(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: CheckGMLogin error. msg[' + E.Message +
        // ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3204:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMPlayerMove(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMPlayerMove error. msg[' + E.Message +
        // ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3205:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMSendChat(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMSendChat error. msg[' + E.Message +
        // ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3206:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMGoldManagment(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMGoldManagment error. msg[' +
        // E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3207:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMCashManagment(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMCashManagment error. msg[' +
        // E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3208:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMLevelManagment(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMLevelManagment error. msg[' +
        // E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3209:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMBuffsManagment(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMBuffsManagment error. msg[' +
        // E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3210:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMDisconnect(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMDisconnect error. msg[' + E.Message +
        // ' : ' + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3211:
        // try
        // Player.SetLastPacketTime(Header.Code);
        // TPacketHandlers.GMBan(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMBan error. msg[' + E.Message + ' : '
        // + Chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
        // + '.', TLogType.Error);
        // end;
        // $3212:
        // try
        // TPacketHandlers.GMEventItem(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMEventItem error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        // $3299:
        // try
        // TPacketHandlers.GMEventItemForAll(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMEventItemForAll error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        // $3214:
        // try
        // TPacketHandlers.GMRequestServerInformation(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestServerInformation error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        // $3219:
        // try
        // TPacketHandlers.GMSendSpawnMob(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMSendSpawnMob error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        //
        // $3221:
        // try
        // TPacketHandlers.GMRequestPlayerAccount(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestPlayerAccount error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        //
        // $3225:
        // try
        // TPacketHandlers.GMReceiveAccBackup(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMReceiveAccBackup error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        //
        // $3229:
        // try
        // TPacketHandlers.GMRequestCommandsAutoriz(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestCommandsAutoriz error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        //
        // $322D:
        // try
        // TPacketHandlers.GMRequestGMUsernames(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestGMUsernames error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        //
        // $3234:
        // try
        // TPacketHandlers.GMReproveCommand(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMReproveCommand error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        //
        // $3236:
        // try
        // TPacketHandlers.GMApproveCommand(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMApproveCommand error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        // end;
        //
        // $3238:
        // try
        // TPacketHandlers.GMSendAddEffect(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMSendAddEffect error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        //
        // end;
        //
        // $323A:
        // try
        // TPacketHandlers.GMRequestCreateCoupom(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestCreateCoupom error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        //
        // end;
        //
        // $3240:
        // try
        // TPacketHandlers.GMRequestComprovantSearchID(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestComprovantSearchID error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        //
        // end;
        //
        // $3242:
        // try
        // TPacketHandlers.GMRequestComprovantSearchName(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestComprovantSearchName error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        //
        // end;
        //
        // $3246:
        // try
        // TPacketHandlers.GMRequestCreateComprovant(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestCreateComprovant error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        //
        // end;
        //
        // $3248:
        // try
        // TPacketHandlers.GMRequestComprovantValidate(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestComprovantValidate error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        //
        // end;
        //
        // $324A:
        // try
        // TPacketHandlers.GMRequestDeletePrans(Player, Buffer);
        // except
        // on E: Exception do
        // Logger.Write('PacketControl: GMRequestDeletePrans error. msg[' + E.Message
        // + ' : ' + chr(13) + E.StackTrace + '] username[' +
        // String(Player.Account.Header.userName) + '] ' + DateTimeToStr(now) +
        // '.', TLogType.Error);
        //
        // end;
{$ENDREGION}
{$REGION 'Pacotes Aika Other Attributes'}
      $23FE:
        try
          Player.SetLastPacketTime(Header.Code);
          TPacketHandlers.RequestAllAttributes(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestAllAttributes error. msg[' +
              E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
      $23FB:
        try
          TPacketHandlers.RequestAllAttributesTarget(Player, Buffer);
        except
          on E: Exception do
            Logger.Write('PacketControl: RequestAllAttributesTarget error. msg['
              + E.Message + ' : ' + Chr(13) + E.StackTrace + '] username[' +
              String(Player.Account.Header.userName) + '] ' + DateTimeToStr(Now)
              + '.', TLogType.Error);
        end;
{$ENDREGION}
      else
        WriteLn('[ServerSocket] ----- Outro pacote desconhecido recebido: ' +
          Header.Code.ToString);
    begin
      // Player.SendCharList(1);
      // Log := '[' + string(ServerList[Player.ChannelIndex].Name) +
      // ']: Recv - Code: ' + Format('0x%x', [Header.Size]) + ' / Size: ' +
      // IntToStr(Size) + ' / ClientId: ' + IntToStr(Header.index);
      // Writeln(Header.Size + Header.Key + Header.ChkSum + Header.Index + Header.Code + Header.Time);
      // Logger.Write(Log, TLogType.Packets);
      LogPackets := False;
    end;
  end;

  if (LogPackets) then
  begin
    if not(DirectoryExists(GetCurrentDir + '\Packets')) then
      ForceDirectories(GetCurrentDir + '\Packets');
    TFunctions.StrToFile(TFunctions.ByteArrToString(Buffer, Header.Size),
      GetCurrentDir + '\Packets\' + TFunctions.DateTimeToUNIXTimeFAST(Now)
      .ToString + '_0x' + Header.Code.ToHexString + '.txt');
    // Writeln(TFunctions.ByteArrToString(Buffer, Header.Size));
    LogPackets := False;
  end;
end;

{$ENDREGION}
{$REGION 'ServerTime'}

function TServerSocket.GetResetTime;
begin
  Result := DateTimeToUnix(IncHour(EncodeDate(YearOf(Now), MonthOf(Now),
    DayOf(IncDay(Now, 1))), 6));
end;

function TServerSocket.CheckResetTime;
begin
  Result := Now > Self.ResetTime;
end;

function TServerSocket.GetEndDayTime;
begin
  Result := DateTimeToUnix(EncodeDate(YearOf(Now), MonthOf(Now),
    DayOf(IncDay(Now, 1))));
end;

{$ENDREGION}
{$REGION 'Players'}

function TServerSocket.GetPlayerByName(Name: string;
  out Player: PPlayer): Boolean;
var
  i: integer;
begin
  Result := False;
  for i := Low(Players) to High(Players) do
  begin
    if Self.Players[i].Base.IsActive and
      (string(Self.Players[i].Character.Base.Name) = Name) then
    begin
      Player := @Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByName(Name: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Base.IsActive and
      (string(Self.Players[i].Character.Base.Name) = Name) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByUsername(userName: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Base.IsActive and
      (string(Self.Players[i].Account.Header.userName) = userName) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByUsername1(userName: string): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Base.IsActive and
      (string(Self.Players[i].Account.Header.userName) = userName) then
    begin
      // Result := Self.Players[i].Base.Character.;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByUsernameAux(userName: string;
  CidAux: word): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to MAX_CONNECTIONS do
  begin
    if Self.Players[i].Base.IsActive and
      (string(Self.Players[i].Account.Header.userName) = userName) and
      (i <> CidAux) then
    begin
      Result := i;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByCharIndex(CharIndex: DWORD;
  out Player: PPlayer): Boolean;
var
  i: word;
begin
  Result := False;
  for i := Low(Players) to High(Players) do
  begin
    if Self.Players[i].Base.IsActive and
      (Self.Players[i].Character.Base.CharIndex = CharIndex) then
    begin
      Player := @Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;

function TServerSocket.GetPlayerByCharIndex(CharIndex: DWORD;
  out Player: TPlayer): Boolean;
var
  i: word;
begin
  Result := False;
  for i := Low(Players) to High(Players) do
  begin
    if Self.Players[i].Base.IsActive and
      (Self.Players[i].Character.Base.CharIndex = CharIndex) then
    begin
      Player := Self.Players[i];
      Result := true;
      break;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'guild gets'}

function TServerSocket.GetGuildByIndex(GuildIndex: integer): String;
var
  i: integer;
begin
  Result := '';
  if GuildIndex = 0 then
    Exit;

  for i := Low(Guilds) to High(Guilds) do
    if Guilds[i].Index = DWORD(GuildIndex) then
    begin
      Result := String(Guilds[i].Name);
      break;
    end;
end;

function TServerSocket.GetGuildByName(GuildName: String): integer;
var
  i: integer;
begin
  Result := 0;
  if GuildName = '' then
    Exit;

  for i := Low(Guilds) to High(Guilds) do
    if String(Guilds[i].Name) = GuildName then
    begin
      Result := Guilds[i].Index;
      break;
    end;
end;

function TServerSocket.GetGuildSlotByID(GuildIndex: integer): integer;
var
  i: integer;
begin
  Result := 0;
  if GuildIndex = 0 then
    Exit;

  for i := Low(Guilds) to High(Guilds) do
    if Guilds[i].Index = DWORD(GuildIndex) then
    begin
      Result := Guilds[i].Slot;
      break;
    end;
end;

function TServerSocket.GetFreePranClientID(): integer;
var
  i: integer;
begin
  Result := 0;
  for i := Low(Self.Prans) to High(Self.Prans) do
    if Self.Prans[i] = 0 then
    begin
      Result := i;
      break;
    end;
end;

// function TServerSocket.GetFreePetClientID(): Integer;
// var
// i: Integer;
// begin
// Result := 0;
// for i := Low(Self.PETS) to High(Self.PETS) do
// if Self.PETS[i].IntName = 0 then
// begin
// Result := i;
// break;
// end;
// end;

{$ENDREGION}
{$REGION 'Temples'}

function TServerSocket.GetFreeTempleSpace(): TSpaceTemple;
var
  i, j: integer;
begin
  Result.DevirId := 255;
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      with Self.Devires[i].Slots[j] do
      begin
        if IsAble and (ItemID = 0) then
        begin
          Result.DevirId := i;
          Result.SlotID := j;
          Exit; // Exit from both loops immediately after finding the free slot
        end;
      end;
    end;
  end;
end;

function TServerSocket.GetFreeTempleSpaceByIndex(id: integer): TSpaceTemple;
var
  j: integer;
begin
  Result.DevirId := 255;
  for j := 0 to 4 do
  begin
    with Self.Devires[id].Slots[j] do
    begin
      if IsAble and (ItemID = 0) then
      begin
        Result.DevirId := id;
        Result.SlotID := j;
        Exit; // Exit after finding the free slot
      end;
    end;
  end;
end;

procedure TServerSocket.SaveTemplesDB(Player: PPlayer);
var
  i, j: integer;
  FieldNameItemID, FieldNameName, FieldTimeCap, FieldIsAble: String;
  SQLComp: TQuery;
begin
  SQLComp := Self.CreateSQL;

  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      FieldNameItemID := 'slot' + IntToStr(j + 1) + '_itemid';
      FieldNameName := 'slot' + IntToStr(j + 1) + '_name';
      FieldTimeCap := 'slot' + IntToStr(j + 1) + '_timecap';
      FieldIsAble := 'slot' + IntToStr(j + 1) + '_able';

      with Self.Devires[i].Slots[j] do
      begin
        SQLComp.SetQuery(Format('UPDATE devires SET ' + FieldNameItemID +
          '=%d, ' + FieldNameName + '=%s, ' + FieldTimeCap + '=%s, ' +
          FieldIsAble + '=%d WHERE devir_id=%d',
          [ItemID, QuotedStr(String(NameCapped)),
          QuotedStr(TFunctions.DateTimeToUNIXTimeFAST(TimeCapped).ToString()),
          IsAble.ToInteger, Self.Devires[i].DevirId]));
        SQLComp.Run(False);
      end;
    end;
  end;

  SQLComp.Free;
end;

procedure TServerSocket.UpdateReliquaresForAll();
var
  i: word;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Players[i].Status >= Playing) then
    begin
      // Enviar as reliques e outras atualizações do jogador em um único bloco
      Players[i].SendReliquesToPlayer;
      Players[i].Base.GetCurrentScore;
      Players[i].Base.SendStatus;
      Players[i].Base.SendRefreshPoint;
      Players[i].Base.SendCurrentHPMP;
    end;
  end;
end;

procedure TServerSocket.UpdateReliquareInfosForAll();
var
  i: word;
begin
  for i := 1 to MAX_CONNECTIONS do
  begin
    if (Players[i].Status >= Playing) then
    begin
      // Atualizar as informações de reliquário para os jogadores válidos
      Players[i].SendUpdateReliquareInformation(Self.ChannelId);
    end;
  end;
end;

procedure TServerSocket.UpdateReliquareEffects();
var
  i, j, effectIndex: integer;
begin
  ZeroMemory(@Self.ReliqEffect, SizeOf(Self.ReliqEffect));
  for i := 0 to 4 do
  begin
    for j := 0 to 4 do
    begin
      if (Self.Devires[i].Slots[j].ItemID <> 0) then
      begin
        // Acessando o índice do efeito uma única vez
        effectIndex := ItemList[Self.Devires[i].Slots[j].ItemID].EF[0];
        Self.ReliqEffect[effectIndex] := Self.ReliqEffect[effectIndex] +
          ItemList[Self.Devires[i].Slots[j].ItemID].EFV[0];

        // Garantir que o efeito esteja dentro dos limites definidos
        if (Self.ReliqEffect[effectIndex] >= 20) then
          Self.ReliqEffect[effectIndex] := 50
        else if (Self.ReliqEffect[effectIndex] <= 0) then
          Self.ReliqEffect[effectIndex] := 0;
      end;
    end;
  end;
end;

function TServerSocket.OpenDevir(DevId: integer; TempID: integer;
  WhoKilledLast: integer): Boolean;
var
  i: byte;
  key: TPlayerKey;
begin
  Result := False;

  // Envia para o jogador que matou e seus jogadores visíveis
  Self.Players[WhoKilledLast].SendDevirChange(TempID, $1D);
  for i in Self.Players[WhoKilledLast].Base.VisiblePlayers do
    Self.Players[i].SendDevirChange(TempID, $1D);

  // Atualiza as variáveis de estado
  Self.Devires[DevId].CollectedReliquare := False;
  Self.Devires[DevId].OpenedThread := TDevirOpennedThread.Create(1000,
    Self.ChannelId, DevId, TempID, 0);
  // SecureId não é utilizado, então removido da chamada
end;

function TServerSocket.CloseDevir(DevId: integer; TempID: integer;
  WhoGetReliq: integer): Boolean;
var
  GuardsIds, StonesIds: TIdsArray;
  i: integer;
begin
  GuardsIds := Self.GetTheGuardsFromDevir(DevId);
  StonesIds := Self.GetTheStonesFromDevir(DevId);
  for i := 0 to 2 do
  begin
    // Definindo DeadTime e atualizando propriedades de Guard e Stone de forma mais eficiente
    with Self.DevirGuards[GuardsIds[i]] do
      DeadTime := StrToDateTime('30/12/1899');

    with Self.DevirStones[StonesIds[i]] do
    begin
      DeadTime := StrToDateTime('30/12/1899');
      Base.IsDead := False;
      PlayerChar.Base.CurrentScore.CurHP := PlayerChar.Base.CurrentScore.MaxHp;
    end;
  end;

  // Atualizando a Devir sem redundâncias
  with Self.Devires[DevId] do
  begin
    OpenTime := StrToDateTime('30/12/1899');
    IsOpen := False;
    StonesDied := 0;
    GuardsDied := 0;
    CollectedReliquare := False;
  end;

  // Enviando mudanças para o jogador
  Self.Players[WhoGetReliq].SendDevirChange(TempID, $10);
  for i in Self.Players[WhoGetReliq].Base.VisiblePlayers do
    Self.Players[i].SendDevirChange(TempID, $10);
end;

function TServerSocket.GetTheStonesFromDevir(DevId: integer): TIdsArray;
begin
  case DevId of
    0:
      begin
        Result[0] := 3340;
        Result[1] := 3345;
        Result[2] := 3350;
      end;
    1:
      begin
        Result[0] := 3341;
        Result[1] := 3346;
        Result[2] := 3351;
      end;
    2:
      begin
        Result[0] := 3342;
        Result[1] := 3347;
        Result[2] := 3352;
      end;
    3:
      begin
        Result[0] := 3343;
        Result[1] := 3348;
        Result[2] := 3353;
      end;
    4:
      begin
        Result[0] := 3344;
        Result[1] := 3349;
        Result[2] := 3354;
      end;
  end;
end;

function TServerSocket.GetTheGuardsFromDevir(DevId: integer): TIdsArray;
begin
  case DevId of
    0:
      begin
        Result[0] := 3355;
        Result[1] := 3360;
        Result[2] := 3365;
      end;
    1:
      begin
        Result[0] := 3356;
        Result[1] := 3361;
        Result[2] := 3366;
      end;
    2:
      begin
        Result[0] := 3357;
        Result[1] := 3362;
        Result[2] := 3367;
      end;
    3:
      begin
        Result[0] := 3358;
        Result[1] := 3363;
        Result[2] := 3368;
      end;
    4:
      begin
        Result[0] := 3359;
        Result[1] := 3364;
        Result[2] := 3369;
      end;
  end;
end;

function TServerSocket.GetEmptySecureArea(): byte;
var
  i: integer;
begin
  Result := 255;
  for i := 0 to 9 do
  begin
  end;
end;

function TServerSocket.RemoveSecureArea(AreaSlot: byte): Boolean;
begin
end;

function TServerSocket.RemoveSecureArea(DevId: integer): Boolean;
begin
end;

function TServerSocket.RemoveSecureArea(TempID: word): Boolean;
begin
end;

function TServerSocket.CreateMapObject(OtherPlayer: PPlayer; OBJID: word;
  ContentID: word = 0): Boolean;
var
  NewId: word;
  newOBJ: POBJ;
begin
  // if OtherPlayer = nil then
  // Exit;

  if OBJID = 350 then
  begin
    newOBJ := @Self.OBJ[11147];
    newOBJ.Index := 11147;
    newOBJ.CreateTime := Now;
  end
  else if OBJID = 351 then // teleporte
  begin
    newOBJ := @Self.OBJ[11000];
    newOBJ.Index := 11000;
    newOBJ.CreateTime := Now;
  end
  else
  begin

    NewId := Self.GetFreeObjId;
    if NewId = 0 then
    begin
      OtherPlayer.SendClientMessage
        ('Erro ao criar o objeto no mapa. ERR_01 Send ticket for support.');
      Exit;
    end;

    newOBJ := @Self.OBJ[NewId];
    newOBJ.Index := NewId;

    newOBJ.CreateTime := Now;

  end;

  case OBJID of
    320: // item id do bau das relíquias
      begin
        newOBJ.Position := OtherPlayer^.Base.Neighbors[5].pos;
        newOBJ.ContentType := OBJECT_RELIQUARE;
        newOBJ.ContentAmount := 1;
        newOBJ.ContentCollectTime := 10;
        newOBJ.ContentItemID := ContentID;
        newOBJ.ReSpawn := False;
        newOBJ.Face := 320;
        newOBJ.NameID := 914;
      end;
    325: // item id do bau de itens
      begin
        // (não há nada a fazer para esse caso ainda)
      end;
    331: // item id do bau de gold
      begin
        // (não há nada a fazer para esse caso ainda)
      end;
    332: // item id do bau de evento
      begin
        // (não há nada a fazer para esse caso ainda)
      end;
    350: // item id do bau de evento
      begin
        newOBJ.Position.X := 3499;
        newOBJ.Position.Y := 935;
        newOBJ.ContentType := OBJECT_BOX_ALTAR;
        newOBJ.ContentCollectTime := 10;
        newOBJ.ReSpawn := False;
        newOBJ.Face := 320;
        newOBJ.NameID := 212;
      end;
    351: // item id do bau de evento
      begin

        newOBJ.Position := TPosition.Create(3424, 3760);
        newOBJ.ContentType := OBJECT_BOX_TELEPORT;
        newOBJ.ContentCollectTime := 3;
        newOBJ.ReSpawn := true;
        newOBJ.Face := 215;
        newOBJ.NameID := 1006;
      end;
  else
    begin
      // (não há ações específicas para outros casos)
    end;
  end;
end;

function TServerSocket.GetFreeObjId(): word;
begin
  for Result := 10148 to 11146 do
    if (Self.OBJ[Result].Index = 0) then
      Exit;
  Result := 0;
end;

procedure TServerSocket.CollectReliquare(Player: PPlayer; Index: word);
var
  Packet: TCollectItem;
begin
  ZeroMemory(@Packet, SizeOf(TCollectItem));
  Packet.Header.Size := SizeOf(TCollectItem);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $336;
  Packet.Index := Index;
  Packet.Time := 3;
  Player.SendPacket(Packet, Packet.Header.Size);

  case index of
    11147: // id da caixa
      begin
        Player.CollectingAltar := true;
        Player.CollectingID := Index;
        Player.CollectInitTime := Now;
      end;
    11000: // id da caixa
      begin
        Player.Teleporting := true;
        Player.CollectingID := Index;
        Player.CollectInitTime := Now;
      end
  else
    begin
      Player.CollectingReliquare := true;
      Player.CollectingID := Index;
      Player.CollectInitTime := Now;
    end;

  end;

end;
{$ENDREGION}

end.
