unit UpdateThreads;
//{$OPTIMIZATION ON}  // Ativa otimizações gerais
//{$O+}               // Ativa otimização de loops

interface

uses
  Windows, Classes, ItemFunctions, SQL, System.AnsiStrings, System.SyncObjs, CastleSiege;

type
  TDevirOpennedThread = class(TThread)
  private
    FDelay: word;
    ChannelId: BYTE;
    DevirId: BYTE;
    TempId: BYTE;
    SecureAreaId: BYTE;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: word; ChannelId: BYTE;
      DevId, TempId, SecAid: BYTE);
  end;

type
  PDevirSlot = ^TDevirSlot;
  TDevirSlot = record
    ItemID: word;
    App: word;
    IsAble: Boolean;
    TimeCapped: TDateTime;
    TimeToEstabilish: TDateTime;
    NameCapped: Array [0 .. 15] of AnsiChar;
    TimeFurthed: TDateTime;
    ItemFurthed: DWORD;
    Furthed: Boolean;
  end;

type
  PDevir = ^TDevir;
  TDevir = record
    DevirId: DWORD;
    NationID: DWORD;
    Slots: Array [0 .. 4] of TDevirSlot;
    StonesDied: BYTE;
    GuardsDied: BYTE;
    ReliqCount: BYTE;
    IsOpen: Boolean;
    CollectedReliquare: Boolean;
    OpenTime: TDateTime;
    OpenedThread: TDevirOpennedThread;
    PlayerIndexGettingReliq: BYTE;
  end;

type
  TCheckPackets1 = class(TThread)
  private
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    procedure SendPacket(i, j: BYTE; RecvBuffer: Array of BYTE;
      RecvBytes: word);
    constructor Create;
  end;

type
  TSaveAutomatico = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
    Horarios: array of TDateTime;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;


{$ENDREGION}
{$REGION 'AtualizarHoraMinutoThread'}

  // Declaração da classe TAtualizarHoraMinutoThread
type
  TIniciarContagem = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
    procedure EnviarPacoteInicial;
    function CountPlayers: Integer;
    function CountPlayersBlue: Integer;
    function CountPlayersRed: Integer;
    procedure UpdateQuantidade;
    procedure AnnouncePreElter(Quantidade: byte);
    procedure UpdateQuantidadeKills;
    procedure ChooseMap;
    procedure StartTeleport;
    procedure CheckAfk;
    procedure TeleportBack;
    procedure EnviarRecompensas;
    procedure FinalizarElter;
    procedure AdviseEveryone;
    procedure SpawnBoss1(Canal: Integer; MobID: Integer; IsBoss: Boolean);
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}

type
  TMapa = record
    Nome: string;
    TimeAzulx: word;
    TimeAzuly: word;
    TimeVermelhox: word;
    TimeVermelhoy: word;
  end;

var
  Mapas: array [0 .. 2] of TMapa = (
    (
      Nome: 'Agros Haima'; TimeAzulx: 2616; TimeAzuly: 3550;
    TimeVermelhox: 2778; TimeVermelhoy: 3395), (Nome: 'Estádio Elter';
    TimeAzulx: 2433; TimeAzuly: 3608; TimeVermelhox: 2434; TimeVermelhoy: 3814),
    (Nome: 'Academia de Batalha'; TimeAzulx: 1690; TimeAzuly: 3418;
    TimeVermelhox: 1592; TimeVermelhoy: 3432));

{$REGION 'TUpdateHpMpThread'}

type
  TUpdateHpMpThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}
{$REGION 'TUpdateBuffsThread'}

type
  TUpdateBuffsThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}
{$REGION 'TUpdateMailsThread'}

type
  TUpdateMailsThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}

{$REGION 'UpdateTimeThread'}

type
  TUpdateTimeThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'UpdateEventListenerThread'}

type
  TUpdateEventListenerThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'SkillRegenerateThread'}

type
  TSkillRegenerateThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'SkillDamageThread'}

type
  TSkillDamageThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Verify Item Expired Thread'}

type
  TTimeItensThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
    procedure CheckItens();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Verify Item Quest Thread'}

type
  TQuestItemThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
    procedure CheckInventory();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;
{$ENDREGION}
{$REGION 'Pran Food System'}

type
  TPranFoodThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fcritsec: TCriticalSection;
    procedure CheckFood();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer);
  end;
{$ENDREGION}
{$REGION 'Temples Thread'}

type
  TTemplesManagmentThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
    procedure CheckRoyalGuards();
    procedure CheckGuards();
    procedure CheckStones();
    procedure CheckReliques();
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer);
  end;

type
  TVisibleManagementThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer);
  end;

type
  TPlayerManagementThread = class(TThread)
  private
    FDelay: Integer;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer);
  end;

  TGuardsVisibleManagementThread = class(TThread)
  private
    FDelay: Integer;
    ChannelId: BYTE;
    fCritSec: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer);
  end;

{$ENDREGION}
{$REGION 'Auction Offers System'}

type
  TAuctionOffersThread = class(TThread)
  private
    FDelay: Integer;
    FQuery: TQuery;

    procedure CheckOffers();

    function ReturnOffer(CharacterId: UInt64; AuctionId: UInt64): Boolean;
    function RegisterReturnMail(CharacterId: UInt64; AuctionId: UInt64;
      OUT MailIndex: UInt64): Boolean;

    function CloseOffer(AuctionId: UInt64): Boolean;
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer);
  end;
{$ENDREGION}
{$REGION 'Castle Siege'}

type
  TSiegeStatus = (None = 0, PreStart, Running, OrbsHolded, Sealing, Finished);

type
  TCastleSiegeThread = class(TThread)
  private
    FDelay: Integer;
    FChannelID: BYTE;

    SiegeStatus: TSiegeStatus;

    procedure CheckCastleOrbs(CastleSiege: PCastleSiege);
    procedure RemoveOrbHolder(CastleSiege: PCastleSiege; OrbIndex: BYTE);
    procedure CountOrbsHolding(CastleSiege: PCastleSiege);
    procedure CheckMarshallSeal(CastleSiege: PCastleSiege);

    procedure RemoveSealHolder(CastleSiege: PCastleSiege);

    procedure UpdateSiegeStatus(CastleSiege: PCastleSiege);
  protected
    procedure Execute; override;
  public
    constructor Create(SleepTime: Integer; ChannelId: BYTE);
  end;

{$ENDREGION}

implementation

uses
  GlobalDefs, Log, MiscData, PlayerData, Util, BaseMob,
  EntityMail, DateUtils, SysUtils, Packets, TokenSocket,
  IdHTTPServer, IdCustomHTTPServer, IdServerIOHandler, IdSSL, IdSSLOpenSSL,
  GuildData, Functions, Player, NPC, Objects, EncDec, PacketHandlers, winsock, ServerSocket;

procedure TCheckPackets1.SendPacket(i, j: BYTE; RecvBuffer: Array of BYTE;
  RecvBytes: word);
var
  initialOffset: BYTE;
  Header2: PPacketHeader;
  LastTime: TDateTime;
  MinDelayNormal: BYTE;
  CurrentTime: TDateTime;
  MPlayer: PPlayer;
begin

  MinDelayNormal := 30;
  CurrentTime := now;
  MPlayer := @Servers[i].Players[j];

  if ((RecvBytes >= sizeof(TPacketHeader)) and (RecvBytes <= 22000)) then
  begin
    initialOffset := 0;
    if (MPlayer^.RecvPackets = False) and (RecvBytes > 60) then
    begin
      initialOffset := 4;
      Move(RecvBuffer[initialOffset], RecvBuffer, RecvBytes - initialOffset);
      MPlayer^.RecvPackets := True;
    end;

    TEncDec.Decrypt(RecvBuffer, RecvBytes);
    Header2 := PPacketHeader(@RecvBuffer);
    LastTime := MPlayer^.GetLastPacketTime(Header2.Code);

    // writeLn('6: ' + RecvBuffer[6].ToHexString + ' e 7: ' + RecvBuffer[7].ToHexString + ' total ' + (RecvBuffer[6]+RecvBuffer[7]).ToString + ' total em hex '+  (RecvBuffer[6]+RecvBuffer[7]).ToHexString);

    case Header2.Code of

{$REGION PACOTES SEM FILTRO}
      $301:
        begin
          try
            // if (MillisecondsBetween(CurrentTime, LastTime) > 20) then
            TPacketHandlers.MovementCommand(MPlayer, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $305:
        begin
          try
            // if (MillisecondsBetween(CurrentTime, LastTime) > 20) then
            TPacketHandlers.UpdateRotation(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $F0B:
        begin
          if (secondsBetween(CurrentTime, LastTime) > 5) then
            if (MPlayer^.LoggedByOtherChannel) then
            begin
              MPlayer^.LoggedByOtherChannel := False;
            end
            else
            begin
              if not(MPlayer^.IsInstantiated) then
                try

                  MPlayer^.SendToWorldSends;
                  MPlayer^.SetLastPacketTime(Header2.Code);
                except
                  on E: Exception do
                  begin
                    Logger.Write('Erro na execução de comando do player: [' +
                      E.Message + ' : ' + E.GetBaseException.Message +
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TLogType.Error);
                  end;
                end;
            end;
        end;
      $302:
        begin
          try
            TPacketHandlers.AttackTarget(MPlayer, PPacket_302(@RecvBuffer[0]),
              False, 0);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;

        end;

      $320:
        begin
          try
            TPacketHandlers.UseSkill(MPlayer, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $31D:
        begin
          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UseItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $306:
        begin
          exit;
          // TEncDec.Encrypt(RecvBuffer, Sizeof(RecvBuffer));
          // writeln('strings ' + Recvbuffer[6].ToString + '  ' + RecvBuffer[7].ToString);
        end;
      $213:
        begin
          try

            TPacketHandlers.GetStatusPoint(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $685:
        begin
          try

            TPacketHandlers.CheckLogin(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $348:
        begin
          try

            TPacketHandlers.CloseNPCOption(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $F02:
        begin
          try

            TPacketHandlers.NumericToken(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $F06:
        begin
          try

            TPacketHandlers.LoginIntoChannel(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $336:
        begin
          try

            TPacketHandlers.CollectMapItem(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $33A:
        begin
          try

            TPacketHandlers.CancelCollectMapItem(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $313:
        begin
          try

            TPacketHandlers.BuyNPCItens(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $314:
        begin
          try

            TPacketHandlers.SellNPCItens(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $315:
        begin
          try

            TPacketHandlers.TradeRequest(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $316:
        begin
          try

            TPacketHandlers.TradeResponse(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $317:
        begin
          try

            TPacketHandlers.TradeRefresh(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $318:
        begin
          try

            TPacketHandlers.TradeCancel(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $319:
        begin
          try

            TPacketHandlers.CreatePersonalShop(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $31A:
        begin
          try

            TPacketHandlers.OpenPersonalShop(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $31B:
        begin
          try

            TPacketHandlers.BuyPersonalShopItem(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $341:
        begin
          try

            TPacketHandlers.CreateGuild(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $30F:
        begin
          try

            TPacketHandlers.OpenNPC(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
{$ENDREGION}
{$REGION PACOTES COM FILTRO}
      $308:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.KarakAereo(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $218:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UseMountSkill(MPlayer, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $668:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              MPlayer^.BackToCharList;
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $21B:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UseBuffItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $20A:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              MPlayer^.SendPlayerCash;
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $327:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.CancelSkillLaunching(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $202:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestServerTime(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $207:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.GiveLeaderRaid(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $209:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.BuyItemCash(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $21A, $22A:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RenoveItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $224:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UnsealItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $22C:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestCharInfo(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $22D:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.SendItemChat(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $303:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RevivePlayer(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $304:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UpdateAction(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $307, $364:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.PKMode(MPlayer^);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $31C:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.LearnSkill(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $322:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.SendParty(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $323:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.AcceptParty(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $324:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.KickParty(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $325:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.DestroyParty(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $326:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.PartyAlocateConfig(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $329:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RemoveBuff(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $32A:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ResetSkills(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $32B:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.MakeItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $32C:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.DeleteItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $32D:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ChangeItemAttribute(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $32F:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.AbandonQuest(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $332:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.AgroupItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $333:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UngroupItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $334:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestEnterDungeon(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $338:
        begin

          // if (MPlayer^.PartyIndex = 0) or (MPlayer^.Party.Members.Count = 1) then
          // Exit;
          try
            if MPlayer^.Party.Members.Count = 1 then
              exit;

            TPacketHandlers.UpdateMemberPosition(MPlayer^, RecvBuffer);
            // MPlayer^.SetLastPacketTime(Header2.Code);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $340:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RepairItens(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $342, $909:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.SendRaid(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $343:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.AcceptRaid(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $344:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ExitRaid(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $34A:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.TeleportSetPosition(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $355:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.DungeonLobbyConfirm(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $356:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.SendGift(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $359:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ReceiveEventItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $361:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UpdateActiveTitle(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $372:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.AddFriendRequest(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $38F:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.AddSelfParty(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $395:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.SendRequestDuel(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $396:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.DuelResponse(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $673:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.AddFriendResponse(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $619:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ChangeMasterGuild(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $67D:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.InviteToGuildAccept(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $603:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestDeleteChar(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $B52:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestUpdateReliquare(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $E3A:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UpdateNationTaxes(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $E51:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.MoveItemToReliquare(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F1C:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ExitGuild(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F1D:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ChangeGuildMemberRank(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F05:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ChangeChannel(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $397:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.StartF12(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F12:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestGuildToAlly(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F20:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UpdateGuildNotices(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F21:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UpdateGuildSite(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F22:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UpdateGuildRanksConfig(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F26:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.SendFriendSay(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F2D:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.KickMemberOfGuild(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F2F:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.CloseGuildChest(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F27:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.OpenFriendWindow(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F30:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.CloseFriendWindow(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F34:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.UpdateNationGold(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F59:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ChangeGold(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F74:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.DeleteFriend(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F7B:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.InviteToGuildRequest(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F7E:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.InviteToGuildDeny(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3E01:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.DeleteChar(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3E04:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.CreateCharacter(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3E02:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RenamePran(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F15:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.sendCharacterMail(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F16:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.checkSendMailRequirements(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F17:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TEntityMail.sendMailList(MPlayer^);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F18:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.OpenMail(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F1A:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.withdrawMailItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F0D:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestAuctionItems(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F0B:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestRegisterItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F11:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestOwnAuctionItems(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F10:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestAuctionOfferCancel(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3F0C:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestAuctionOfferBuy(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F93A:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestServerPing(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3E05:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.ReclaimCoupom(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $23FE:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestAllAttributes(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $23FB:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.RequestAllAttributesTarget(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $34B:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.GiveLeaderParty(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $3961, $F79:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              MPlayer^.SendUpdateReliquareInformation(MPlayer^.ChannelIndex);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F71:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.EntrarElter(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $F86:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.SendClientSay(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;
      $31E:
        begin

          try

            TPacketHandlers.ChangeItemBar(MPlayer^, RecvBuffer);
          except
            on E: Exception do
            begin
              Logger.Write('Erro na execução de comando do player: [' +
                E.Message + ' : ' + E.GetBaseException.Message +
                '] MPlayer^.base.character.name[' + MPlayer^.base.character.name
                + '] ' + DateTimeToStr(CurrentTime) + '.', TLogType.Error);
            end;
          end;
        end;
      $70F:
        begin

          if (MPlayer^.IsInstantiated) and
            (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
            try

              TPacketHandlers.MoveItem(MPlayer^, RecvBuffer);
              MPlayer^.SetLastPacketTime(Header2.Code);
            except
              on E: Exception do
              begin
                Logger.Write('Erro na execução de comando do player: [' +
                  E.Message + ' : ' + E.GetBaseException.Message +
                  '] MPlayer^.base.character.name[' +
                  MPlayer^.base.character.name + '] ' +
                  DateTimeToStr(CurrentTime) + '.', TLogType.Error);
              end;
            end;
        end;

{$ENDREGION}
    else
      begin
        Writeln('pacote diferente ' + Header2.Code.ToHexString + ' aa ' +
          RecvBytes.ToString);
        // Servers[Channel].PacketControl(MPlayer^, HeaderSize, RecvBuffer, initialOffset);
      end;
    end;

  end
  else
  begin
    MPlayer^.RecvPackets := True;
  end;

end;

constructor TCheckPackets1.Create;
begin
  Self.FreeOnTerminate := True;
  fCritSec := TCriticalSection.Create;
  inherited Create(False); // Inicia a thread em segundo plano
  Self.Priority := tpLower;
end;

procedure TCheckPackets1.Execute;
var
  i, j: BYTE;
  initialOffset, HeaderSize, RecvBytes: word;
  RecvBuffer, RecvBuffer2: array [0 .. 21999] of BYTE;
  Header2: PPacketHeader;
  MPlayer: PPlayer;
begin
  while 1 = 1 do
  begin
    for i := 0 to 3 do
    begin
      if not Servers[i].IsActive then
        Continue;

      for j := 1 to 100 do
      begin
        fCritSec.Enter;
        try
          MPlayer := @Servers[i].Players[j];

          if MPlayer^.SocketClosed or MPlayer^.xdisconnected then
            Continue;

          if MPlayer^.Socket = 0 then
            Continue;

          ZeroMemory(@RecvBuffer, 22000);
          ZeroMemory(@RecvBuffer2, 22000);
          ZeroMemory(@Header2, sizeof(Header2));
          RecvBytes := 0;

          RecvBytes := Recv(MPlayer^.Socket, RecvBuffer, 22000, 0);

          if (RecvBytes <= 0) then
          begin
            if (WSAGetLastError = WSAEWOULDBLOCK) then
            begin
              Continue;
            end;
            closesocket(MPlayer^.Socket);
            MPlayer^.SocketClosed := True;
            Servers[i].Disconnect(MPlayer^);
            Servers[i].InstantiatedPlayers :=
              Servers[i].InstantiatedPlayers - 1;

            Continue;
          end;

          Header2 := PPacketHeader(@RecvBuffer);
          if (Header2.Code = $306) or
            ((Header2.Code = $305) and (Header2.Code = $326) and
            (MPlayer^.Party.Members.Count > 1)) then
            Continue;

          if RecvBytes = 65535 then
            Continue;

          SendPacket(i, j, RecvBuffer, RecvBytes);

        finally
          fCritSec.Leave;
        end;

      end;
    end;
    TThread.Yield;
    TThread.sleep(30);
  end;
  Writeln('fechando thread');
  Self.Terminate;
end;

constructor TDevirOpennedThread.Create(SleepTime: word; ChannelId: BYTE;
  DevId, TempId, SecAid: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  Self.DevirId := DevId;
  Self.TempId := TempId;
  Self.SecureAreaId := SecAid;

  inherited Create(False);
          Self.Priority := tpLower;
//  Self.Priority := tpTimeCritical;
end;

procedure TDevirOpennedThread.Execute; // tempo para fechar devir e resetar
begin
  while Servers[Self.ChannelId].Devires[Self.DevirId].IsOpen do
  begin
    if (Self.DevirId = 4) then
      break;

    { Verificando o tempo para fechar o templo e resetar }
    if now >= IncSecond(Servers[Self.ChannelId].Devires[Self.DevirId].OpenTime, 600) then
    begin
      Servers[Self.ChannelId].CloseDevir(Self.DevirId, Self.TempId, 0);
      Servers[Self.ChannelId].Devires[Self.DevirId].PlayerIndexGettingReliq := 0;
    end;

    TThread.sleep(FDelay);
  end;
end;

constructor TSaveAutomatico.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime; // Tempo de espera (1 minuto)
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSec := TCriticalSection.Create;
  inherited Create(False); // Inicia a thread em segundo plano
  Self.Priority := tpLower;
//        Self.Priority := tpLower;
//  Self.Priority := tpTimeCritical;
end;

procedure TSaveAutomatico.Execute;
var
  xPlayer: PPlayer;
  key: TPlayerKey;
begin
  while not Servers[0].ServerHasClosed do
  begin

      for Key in ActivePlayers.Keys do
      begin
        fCritSec.Enter;
        try
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

          TFunctions.SavePlayerPrincipal(xPlayer, xPlayer^.SelectedCharacterIndex);

          TFunctions.SavePlayerSecundario(xPlayer, xPlayer^.SelectedCharacterIndex);

          xPlayer^.LastTimeSaved:= now;


        finally
          fCritSec.Leave;
        end;
      end;

    TThread.Yield;
    TThread.Sleep(FDelay);
  end;
end;


procedure EnviarRecompensa(xPlayer: PPlayer; titulo, mensagem: string;
  premioItem, premioQuantidade: Integer);
var
  QueryString: string;
  AcquisitionMailId: Int64;
  PlayerSQLComp: TQuery;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  try
    // Inserir na tabela "mails"
    QueryString :=
      Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, '
      + 'textBody, slot, sentGold, gold, returnDate, sentDate, isFromAuction, canReturn, hasItems) '
      + 'VALUES (%d, 1, "Evento Elter", "%s", "%s", 0, 0, 0, "%s", "%s", 1, 0, 1); SELECT LAST_INSERT_ID() AS LastMailId;',
      [xPlayer.base.character.CharIndex, titulo, mensagem,
      FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(now, 90)),
      FormatDateTime('yyyy-mm-dd hh:nn:ss', now)]);
    PlayerSQLComp.SetQuery(QueryString);
    PlayerSQLComp.Query.Connection.StartTransaction;
    PlayerSQLComp.Run(True); // Executa e captura o resultado
    PlayerSQLComp.Query.Connection.Commit;

    // Obter o Mail ID gerado
    AcquisitionMailId := PlayerSQLComp.Query.FieldByName('LastMailId')
      .AsLargeInt;

    // Inserir na tabela "mails_items"
    QueryString :=
      Format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, effect1_index, effect1_value, '
      + 'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, `time`) '
      + 'VALUES (%d, 0, %d, %d, 0, 0, 0, 0, 0, 0, 0, 160, 160, %d, 0);',
      [AcquisitionMailId, premioItem, premioItem, premioQuantidade]);
    PlayerSQLComp.SetQuery(QueryString);
    PlayerSQLComp.Query.Connection.StartTransaction;
    PlayerSQLComp.Run(False); // Executa a consulta
    PlayerSQLComp.Query.Connection.Commit;

  finally
    PlayerSQLComp.Free; // Garante que a conexão é liberada ao final
  end;
end;

constructor TIniciarContagem.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime; // Tempo de espera (1 minuto)
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSec := TCriticalSection.Create;
  inherited Create(False); // Inicia a thread em segundo plano
  Self.Priority := tpLower;
end;

procedure TIniciarContagem.EnviarPacoteInicial;
var
  x, y, z: Integer;
begin

end;

function TIniciarContagem.CountPlayers: Integer;
var
  PlayerSQLComp: TQuery;
begin
  Result := -1;
  try
    PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE));
    PlayerSQLComp.SetQuery('SELECT COUNT(id) AS TotalPlayers FROM elter');
    PlayerSQLComp.Run;
    Result := PlayerSQLComp.Query.Fields[0].AsInteger;
    PlayerSQLComp.Free;
  except
    on E: Exception do
    begin
      Logger.Write('Erro na função da elter CountPlayers ' + E.Message,
        TLogType.Error);
      Result := -1;
    end;

  end;
end;

function TIniciarContagem.CountPlayersBlue: Integer;
var
  xPlayer: PPlayer;
  Count: word;
  key: TPlayerKey;
begin
  Result := 0;
  Count := 0;

        for Key in ActivePlayers.Keys do
        begin
          if Key.ServerID <> 3 then
          continue;
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];



          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;


          try
            if (xPlayer^.Team1 = 4) then
            begin
              inc(Count);
            end;
          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao contar jogadores do time azul', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;


        end;


  Result := Count;

end;

function TIniciarContagem.CountPlayersRed: Integer;
var
  xPlayer: PPlayer;
  Count: word;
  key: TPlayerKey;
begin
  Result := 0;
  Count := 0;

        for Key in ActivePlayers.Keys do
        begin
          if Key.ServerID <> 3 then
          continue;
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];



          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

          try
            if (xPlayer^.Team1 = 5) then
            begin
              inc(Count);
            end;
          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao contar jogadores do time vermelho', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;

        end;

  Result := Count;
end;

procedure TIniciarContagem.UpdateQuantidade;
var
  ElterQuantidade: TElterQuantidade;
  xPlayer: PPlayer;
  count_azul, count_red: word;
  key: TPlayerKey;
begin
  count_azul := 0;
  count_red := 0;
  {$REGION 'CALCULA JOGADORES NA ELTER'}
  for Key in ActivePlayers.Keys do
  begin
   if Key.ServerID <> 3 then
    continue;

    // Acessa o jogador associado à chave
    xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


    if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

    try

      case xPlayer^.Team1 of
      4: inc(count_azul);
      5: inc(count_red);
      end;




    except
      on E: Exception do
      begin
        Logger.Write(Format('Erro ao contar quantidade de kills ', [E.Message]), TLogType.Error);
        Continue;
      end;
    end;

  end;

  {$ENDREGION}


  {$REGION 'Envia a quantidade de usuarios calculada'}
    for Key in ActivePlayers.Keys do
  begin
    if Key.ServerID <> 3 then
    continue;
    // Acessa o jogador associado à chave
    xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];



        if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

    try
        if (xPlayer^.Waiting1 <> 0) then
        begin

          ElterQuantidade.Header.Size := sizeof(TElterQuantidade);
          ElterQuantidade.Header.Code := $1AB;
          ElterQuantidade.TeamRed := count_red;
          ElterQuantidade.TeamBlue := count_azul;

          ElterQuantidade.Header.Index := xPlayer^.base.ClientID;
          xPlayer.SendPacket(ElterQuantidade, sizeof(TElterQuantidade));

        end;



    except
      on E: Exception do
      begin
        Logger.Write(Format('Erro ao enviar quantidade usuarios ', [E.Message]), TLogType.Error);
        Continue;
      end;
    end;

  end;

  {$ENDREGION}

    Servers[3].Quantidade_Azul := count_azul;
      Servers[3].Quantidade_Vermelho := count_red;


end;

procedure TIniciarContagem.UpdateQuantidadeKills;
var
  ElterQuantidade: TElterPontuacao;
  xPlayer: PPlayer;
   key: TPlayerKey;
begin

  ElterQuantidade.Header.Size := sizeof(TElterPontuacao);
  ElterQuantidade.Header.Code := $1AC;
  ElterQuantidade.TeamRed := Servers[3].Kills_Vermelho;
  ElterQuantidade.TeamBlue := Servers[3].Kills_Azul;


        for Key in ActivePlayers.Keys do
        begin
          if Key.ServerID <> 3 then
          continue;
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];



          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

          if xPlayer^.Waiting1 = 0 then
          continue;

          try


                  ElterQuantidade.Header.Index := xPlayer^.base.ClientID;
                  xPlayer.SendPacket(ElterQuantidade, sizeof(TElterPontuacao));


           except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao enviar contagem de kills da elter ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;


        end;

end;

procedure TIniciarContagem.AnnouncePreElter(Quantidade: byte);
var
  xPlayer: PPlayer;
  key: TPlayerKey;
  mensagem, mensagem1: string;
begin

  mensagem := 'Quantidade de players na elter ' + Quantidade.ToString + '!';
  mensagem1 := 'A elter não será a mesma sem você, acesse!';



        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

          try

                            if (xPlayer^.Waiting1 = 0) and (Key.ServerID <> 3) then
                            begin

                                      xPlayer.SendClientMessage(mensagem, 0, 0, 0);
                                      xPlayer.SendClientMessage(mensagem1, 0, 0, 0);

                            end;

                            if (xPlayer^.Waiting1 > 1) and (Key.ServerID = 3) then
                            begin
                               xPlayer.SendClientMessage(mensagem, 0, 0, 0);
                            end;


          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao enviar mensagem de participação da elter', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;


        end;



end;

procedure TIniciarContagem.ChooseMap;
var
  MapaEscolhido: TMapa;
begin

  Randomize;
  MapaEscolhido := Mapas[Random(Length(Mapas))];

  Servers[3].MapSelected := True;
  Servers[3].MapName := MapaEscolhido.Nome;
  Servers[3].TimeAzulx := MapaEscolhido.TimeAzulx;
  Servers[3].TimeAzuly := MapaEscolhido.TimeAzuly;
  Servers[3].TimeVermelhox := MapaEscolhido.TimeVermelhox;
  Servers[3].TimeVermelhoy := MapaEscolhido.TimeVermelhoy;
  Servers[3].Kills_Azul := 0;
  Servers[3].Kills_Vermelho := 0;

end;

procedure TIniciarContagem.StartTeleport;
var
  xPlayer: PPlayer;
  Packets: TElterPlacar;
  key: TPlayerKey;
begin
  Servers[3].FinishedCadastro := True;

  // TThread.Sleep(50);


        for Key in ActivePlayers.Keys do
        begin

           if Key.ServerID <> 3 then
            continue;
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

          if not(xPlayer^.Waiting1 = 1) then
            Continue;

          try

            case xPlayer^.base.character.Nation of

              4:
              begin
                xPlayer^.base.LastMovedTime := now;
                xPlayer^.Waiting1 := 2;
                xPlayer.Teleport(TPosition.Create(Servers[3].TimeAzulx,
                  Servers[3].TimeAzuly));
                xPlayer.SendClientMessage('A luta começou! Você está no time azul!',
                  16, 16, 16);

                Packets.Header.Size := sizeof(TElterPlacar);
                Packets.Header.Index := xPlayer^.base.ClientID;
                Packets.Header.Code := $1AA;
                Packets.Status := 0;
                Packets.Contagem := 600;

                xPlayer.SendPacket(Packets, sizeof(TElterPlacar));
              end;

              5:
              begin
                xPlayer^.base.LastMovedTime := now;
                xPlayer^.Waiting1 := 2;
                xPlayer.Teleport(TPosition.Create(Servers[3].TimeVermelhox,
                  Servers[3].TimeVermelhoy));
                xPlayer.SendClientMessage('A luta começou! Você está no time vermelho!',
                  16, 16, 16);

                Packets.Header.Size := sizeof(TElterPlacar);
                Packets.Header.Index := xPlayer^.base.ClientID;
                Packets.Header.Code := $1AA;
                Packets.Status := 0;
                Packets.Contagem := 600;

                xPlayer.SendPacket(Packets, sizeof(TElterPlacar));
              end;

            end;


          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao teleportar jogadores da elter ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;


        end;



end;


procedure TIniciarContagem.CheckAfk;
var
  xPlayer: PPlayer;
  KickPlayer: byte;
  Packets: TElterPlacar;
  ChangeChannelPacket: TChangeChannelPacket;
  key: TPlayerKey;
begin
  if (Elter_Inatividade_Kick = 1) then
  begin


        for Key in ActivePlayers.Keys do
        begin
        if Key.ServerID <> 3 then
        continue;

          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(xPlayer) then
           continue;

          if (xPlayer^.Waiting1 <> 2) or xPlayer^.Removido then
            continue;


          try
              KickPlayer := secondsBetween(now, xPlayer^.base.LastMovedTime);

              if (KickPlayer >= Elter_Inatividade_Kick_Tempo) and (xPlayer^.Avisado < Elter_Inatividade_Kick_Avisos) then
              begin
                xPlayer.SendClientMessage('Mova-se ou você será removido da batalha', 16, 16, 16);
                xPlayer^.base.LastMovedTime := now;
                inc(xPlayer^.Avisado);
              end;

              if (xPlayer^.Avisado >= Elter_Inatividade_Kick_Avisos) and
                (xPlayer^.Removido = False) then
              begin
                xPlayer^.Removido := True;
                xPlayer.SendClientMessage('Você foi removido da batalha por inatividade', 16, 16, 16);

                Packets.Header.Size := sizeof(TElterPlacar);
                Packets.Header.Index := xPlayer^.base.ClientID;
                Packets.Header.Code := $199;
                Packets.Status := 4;

                xPlayer.SendPacket(Packets, sizeof(TElterPlacar));

                Packets.Header.Size := sizeof(TElterPlacar);
                Packets.Header.Index := xPlayer^.base.ClientID;
                Packets.Header.Code := $1AA;
                Packets.Status := 4;

                xPlayer.SendPacket(Packets, sizeof(TElterPlacar));

                ChangeChannelPacket.Header.Size := sizeof(TChangeChannelPacket);
                ChangeChannelPacket.Header.Index := xPlayer^.base.ClientID;
                ChangeChannelPacket.Header.Code := $F05;
                ChangeChannelPacket.Info1 := xPlayer.OldNation - 1;

                case xPlayer^.Team1 of

                  4:
                    begin
                      Servers[3].Quantidade_Azul := Servers[3].Quantidade_Azul - 1;
                    end;

                  5:
                    begin
                      Servers[3].Quantidade_Vermelho := Servers[3].Quantidade_Vermelho - 1;
                    end;

                end;
                TPacketHandlers.ChangeChannelOther(xPlayer^, ChangeChannelPacket, 101);

              end;

          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao dar check afk nos players ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;
        end;


  end;
end;

procedure TIniciarContagem.TeleportBack;
var
  i: Integer;
  xPlayer: PPlayer;
  ChangeChannelPacket: TChangeChannelPacket;
  Packets: TElterPlacar;
  key: TPlayerKey;
begin

        for Key in ActivePlayers.Keys do
        begin

        if Key.ServerID <> 3 then
        continue;

          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

          if (xPlayer^.Waiting1 = 0) then
          continue;

          try
              Packets.Header.Size := sizeof(TElterPlacar);
              Packets.Header.Index := xPlayer^.base.ClientID;
              Packets.Header.Code := $199;
              Packets.Status := 4;

              xPlayer.SendPacket(Packets, sizeof(TElterPlacar));

              Packets.Header.Size := sizeof(TElterPlacar);
              Packets.Header.Index := xPlayer^.base.ClientID;
              Packets.Header.Code := $1AA;
              Packets.Status := 4;

              xPlayer.SendPacket(Packets, sizeof(TElterPlacar));

              ChangeChannelPacket.Header.Size := sizeof(TChangeChannelPacket);
              ChangeChannelPacket.Header.Index := xPlayer^.base.ClientID;
              ChangeChannelPacket.Header.Code := $F05;
              ChangeChannelPacket.Info1 := xPlayer^.OldNation - 1;

              TPacketHandlers.ChangeChannelOther(xPlayer^, ChangeChannelPacket, xPlayer^.OldNation + 1);

          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao teleportar os players da elter de volta para suas nações ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;


        end;

end;

procedure TIniciarContagem.EnviarRecompensas;
var
  xPlayer: PPlayer;
  VermelhoVenceu, AzulVenceu, Empate: Boolean;
  key: TPlayerKey;
begin
  // Determinar o resultado da batalha
  VermelhoVenceu := Servers[3].Kills_Vermelho > Servers[3].Kills_Azul;
  AzulVenceu := Servers[3].Kills_Azul > Servers[3].Kills_Vermelho;
  Empate := Servers[3].Kills_Azul = Servers[3].Kills_Vermelho;


        for Key in ActivePlayers.Keys do
        begin
        if Key.ServerID <> 3 then
        continue;

          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;

          try

              if xPlayer^.Team1 = 5 then // Time Vermelho
              begin
                if VermelhoVenceu then
                begin
                  xPlayer.SendDuelEnd(1);
                  xPlayer.SendClientMessage('Seu time ganhou!', 16, 16, 16);
                  EnviarRecompensa(xPlayer, 'Recompensa de Vitória',
                    'Você recebeu um prêmio pela vitória na batalha.',
                    Premio_Elter_Vitoria, Premio_Elter_Quantidade_Vitoria);
                end
                else if Empate then
                begin
                  xPlayer.SendDuelEnd(0);
                  xPlayer.SendClientMessage('A Elter acabou em empate!', 16, 16, 16);
                  EnviarRecompensa(xPlayer, 'Recompensa de Empate',
                    'Você recebeu um prêmio pelo empate na batalha.', Premio_Elter_Empate,
                    Premio_Elter_Quantidade_Empate);
                end
                else
                begin
                  xPlayer.SendDuelEnd(0);
                  xPlayer.SendClientMessage('Seu time perdeu!', 16, 16, 16);
                  EnviarRecompensa(xPlayer, 'Recompensa de Consolação',
                    'Você recebeu um prêmio por participar da batalha.',
                    Premio_Elter_Derrota, Premio_Elter_Quantidade_Derrota);
                end;
              end
              else if xPlayer^.Team1 = 4 then // Time Azul
              begin
                if AzulVenceu then
                begin
                  xPlayer.SendDuelEnd(1);
                  xPlayer.SendClientMessage('Seu time ganhou!', 16, 16, 16);
                  EnviarRecompensa(xPlayer, 'Recompensa de Vitória',
                    'Você recebeu um prêmio pela vitória na batalha.',
                    Premio_Elter_Vitoria, Premio_Elter_Quantidade_Vitoria);
                end
                else if Empate then
                begin
                  xPlayer.SendDuelEnd(0);
                  xPlayer.SendClientMessage('A Elter acabou em empate!', 16, 16, 16);
                  EnviarRecompensa(xPlayer, 'Recompensa de Empate',
                    'Você recebeu um prêmio pelo empate na batalha.', Premio_Elter_Empate,
                    Premio_Elter_Quantidade_Empate);
                end
                else
                begin
                  xPlayer.SendDuelEnd(0);
                  xPlayer.SendClientMessage('Seu time perdeu!', 16, 16, 16);
                  EnviarRecompensa(xPlayer, 'Recompensa de Consolação',
                    'Você recebeu um prêmio por participar da batalha.',
                    Premio_Elter_Derrota, Premio_Elter_Quantidade_Derrota);
                end;
              end;

          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao enviar recompensas para os jogadores na elter ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;


        end;


end;

procedure TIniciarContagem.FinalizarElter;
var
  mensagem: string;
  xPlayer: PPlayer;
  ChangeChannelPacket: TChangeChannelPacket;
  Packets: TElterPlacar;
  key: TPlayerKey;
begin

  mensagem := 'Luta Finalizada, teleportando de volta!';


        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          if Key.ServerID <> 3 then
          continue;

          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;
          if (xPlayer^.Waiting1 = 0) then
          continue;

          try

          xPlayer.SendClientMessage(mensagem, 16, 16, 16);

          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao teleportar os jogadores de volta ao finalizar a elter 1', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;

        end;

        sleep(5000);

        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          if Key.ServerID <> 3 then
          continue;

          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;
          if (xPlayer^.Waiting1 = 0) then
          continue;

          try

                Packets.Header.Size := sizeof(TElterPlacar);
                Packets.Header.Index := xPlayer^.base.ClientID;
                Packets.Header.Code := $199;
                Packets.Status := 4;

                xPlayer.SendPacket(Packets, sizeof(TElterPlacar));

                Packets.Header.Size := sizeof(TElterPlacar);
                Packets.Header.Index := xPlayer^.base.ClientID;
                Packets.Header.Code := $1AA;
                Packets.Status := 4;

                xPlayer.SendPacket(Packets, sizeof(TElterPlacar));

                ChangeChannelPacket.Header.Size := sizeof(TChangeChannelPacket);
                ChangeChannelPacket.Header.Index := xPlayer^.base.ClientID;
                ChangeChannelPacket.Header.Code := $F05;
                ChangeChannelPacket.Info1 := xPlayer^.OldNation - 1;

                TPacketHandlers.ChangeChannelOther(xPlayer^, ChangeChannelPacket, 101);

          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro ao teleportar os jogadores de volta ao finalizar a elter 2', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;

        end;

end;

procedure TIniciarContagem.AdviseEveryone;
var
  xPlayer: PPlayer;
  packet: TShowElterDialog;
  key: TPlayerKey;
begin

        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;
          if(xPlayer^.Waiting1 <> 0) then
          continue;

          try
                 packet.Header.Size := sizeof(TShowElterDialog);
                 packet.Header.Index := xPlayer^.base.ClientID;
                 packet.Header.Code := $394;
                 packet.Tempo := abs(Servers[3].RemainingTime - 10);

                 xPlayer.SendPacket(packet, sizeof(TShowElterDialog));

          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro no advise everyone ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;

        end;

end;

procedure TIniciarContagem.SpawnBoss1(Canal: Integer; MobID: Integer;
  IsBoss: Boolean);
var
  s, i: Integer;
  xPlayer: PPlayer;
  packet: TShowElterDialog;
  helper, helper1: byte;
begin
  Writeln('spawnando boss mundial');
  for i := 1 to 5 do
  begin
    if (Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.ClientID <> 0) then
      Continue;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].Index := ((MobID + i) + 9148);
    Writeln('client id ' + Servers[Canal].MOBS.TMobS[MobID].MobsP[i].
      Index.ToString);
//    Randomize;

        Helper := 5;
        Helper1 := 5;

    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].InitPos :=
      TPosition.Create(2922 + Helper, 1618 + Helper1);
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].DestPos :=
      TPosition.Create(2915 + Helper1, 1659 + Helper);

    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.Create(nil,
      ((MobID + i) + 9148), Canal);

    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.MobID := MobID;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.IsActive := True;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.ClientID :=
      (MobID + i) + 9148;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.SecondIndex := i;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].MovedTo := TypeMobLocation.Init;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].LastMyAttack := now;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].LastSkillAttack := now;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].CurrentPos :=
      Servers[Canal].MOBS.TMobS[MobID].MobsP[i].InitPos;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.LastPos :=
      Servers[Canal].MOBS.TMobS[MobID].MobsP[i].CurrentPos;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].XPositionsToMove := 1;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].YPositionsToMove := 1;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].NeighborIndex := -1;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].HP := Servers[Canal].MOBS.TMobS
      [MobID].InitHP;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].MP := Servers[Canal].MOBS.TMobS
      [MobID].InitHP;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.base.
      CurrentScore.DNFis := i + 250;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.base.
      CurrentScore.DNMag := Servers[Canal].MOBS.TMobS[MobID].MobsP[i]
      .base.PlayerCharacter.base.CurrentScore.DNFis;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.base.
      CurrentScore.DefFis := i + 250;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.base.
      CurrentScore.DefMag := Servers[Canal].MOBS.TMobS[MobID].MobsP[i]
      .base.PlayerCharacter.base.CurrentScore.DefFis;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.base.
      CurrentScore.Esquiva := MOB_ESQUIVA; // estava 0
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.CritRes :=
      MOB_CRIT_RES;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.DuploRes :=
      MOB_DUPLO_RES;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].base.PlayerCharacter.base.nation
      := Canal; // Self.ChannelId + 1;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].LastMyAttack := now;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].isTemp := False;
    Servers[Canal].MOBS.TMobS[MobID].MobsP[i].GeneratedAt := now;
    Servers[Canal].MOBS.TMobS[MobID].IsActiveToSpawn := True;

    break;

  end;

end;

procedure TIniciarContagem.Execute;
var
  startTime, elterStartTime: TDateTime;
  elapsedTime, RemainingTime, elapsed10Minutes: Integer;
  currentMinute, TotalVermelho, TotalAzul, TotalPlayers, i: Integer;
  IsCounting10Minutes: Boolean;
  NumeroAleatorio: Integer;
  national: string;
begin
  if (Elter_Status = 0) then
    exit;
  IsCounting10Minutes := False;
  Servers[3].FinishedCadastro := False;
  startTime := 0;

  while (Servers[0].IsActive) do
  begin

    fCritSec.Enter;
    currentMinute := MinuteOf(now);

    if (currentMinute = 59) and PrimeBoss1Spawned then
    begin

    end;

    if (currentMinute = 1) and not PrimeBoss1Spawned then
    begin

      try
        Randomize;
        NumeroAleatorio := Random(3); // Gera um número aleatório entre 0 e 2

        case NumeroAleatorio of
          0:
            national := 'Tibérica';
          1:
            national := 'Odeon';
          2:
            national := 'Elsinore';
        end;

        for i := 0 to 3 do
        begin
          Servers[i].SendServerMsg('Boss Mundial Spawnado', 16, 16, 16);
          Servers[i].SendServerMsg('Nação: ' + national + ' Mapa: Halperin',
            16, 16, 16);
        end;

        PrimeBoss1Spawned := True;

        for i := 0 to 500 do
        begin

          if (Servers[NumeroAleatorio].MOBS.TMobS[i].IntName = 1221) then
            Self.SpawnBoss1(NumeroAleatorio, i, True);

        end;

      except
        on E: Exception do
        begin

          Logger.Write('Erro ao spawnar prime boss 1: ' + E.Message,
            TLogType.Error);
          Continue;
        end;
      end;

    end;

    if (currentMinute = 0) and (startTime = 0) or StartElter then
    begin
      startTime := now;
      StartElter := False;
      RegisterElterOld := True;
      ElterHappening := True;
    end;

    if startTime > 0 then
    begin

      elapsedTime := secondsBetween(now, startTime);

      // Lógica principal (225 segundos e inicialização do evento)
      if not IsCounting10Minutes then
      begin
        // Calcula o tempo restante para 225 segundos
        RemainingTime := 225 - elapsedTime;

        if RemainingTime > 0 then
        begin

          // obtem contagem de players ativos
          // obtem a contagem de players ativos
          Self.UpdateQuantidade;
          // envia pacote atualizando a quantidade de players na partida
          if RemainingTime > 10 then
          begin
            TotalVermelho := Self.CountPlayersRed;
            // obtem a quantidade de players no time vermelho
            TotalAzul := Self.CountPlayersBlue;
            // obtem a quantidade de players no time azul
            TotalPlayers := abs(TotalVermelho + TotalAzul);
            // calculo o total de players para enviar como msg ou outros
            Self.AnnouncePreElter(TotalPlayers);
            // anuncios pré elter, para efetuarem cadastros, envia o total de players cadastrados
          end;
          // Escolha do mapa quando faltam 224 segundos
          if (RemainingTime < 225) and not Servers[3].MapSelected then
          // se n tiver sido selecionado mapa, ele seleciona um randomicamente
          begin
            Self.ChooseMap;
          end;
          if (RemainingTime < 10) and not Servers[3].FinishedCadastro then
          // fecha o cadastro qnd tiver faltando 10 segundos
          begin
            Servers[3].FinishedCadastro := True;
            RegisterElterOld := False;
          end;
          Servers[3].RemainingTime := RemainingTime;

          if not Servers[3].Avised then
          begin

            Self.AdviseEveryone;
            Servers[3].Avised := True;
          end;

        end
        else
        begin

          if TotalPlayers <= 1 then
          begin

            startTime := 0; // Prepara para a próxima hora
            for i := 0 to 3 do
            begin
              Servers[i].SendServerMsg
                ('Elter cancelada devido falta de jogadores!', 16, 16, 16);
            end;
            Self.TeleportBack;
            ElterHappening := False;

          end
          else
          begin

            IsCounting10Minutes := True;
            elterStartTime := now;
            Self.StartTeleport;

          end;
        end;
      end
      else
      begin
        elapsed10Minutes := secondsBetween(now, elterStartTime);
        if elapsed10Minutes < 600 then
        begin

          Self.CheckAfk;
          Self.UpdateQuantidade;
          Self.UpdateQuantidadeKills;

        end
        else
        begin

          ElterHappening := False;
          Self.EnviarRecompensas;
          Self.FinalizarElter;
          IsCounting10Minutes := False;
          startTime := 0;

        end;
      end;
    end;
    fCritSec.Leave;
    TThread.Yield;
    TThread.sleep(FDelay);
  end;

end;

{$ENDREGION}

{$REGION 'TUpdateHpMpThread'}

constructor TUpdateHpMpThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TUpdateHpMpThread.Execute;
var
  hpMp: DWORD;
  dirtyHpMp: Boolean;
  i: word;
  Player: PPlayer;
  l: BYTE;
  Result: Integer;
  DiffInSeconds: Integer;
  Equip: PItem;
  Decrement: Integer;
  loop: Integer;
  k: Integer;
  packet: TStartF12;
  Packet1: TF12Effect;
  key: TPlayerKey;
begin
  while (Servers[0].IsActive) do
  begin
    fCritSec.Enter;

       try

        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(Player) then
          continue;


          try



                  // SOBRE F12
                  {$REGION  'SOBRE F12 TEMPOS/PLAYERS USANDO F12, ETC.'}
                  if Player^.F12Ativo and
                    (Player^.F12TempoRestante <= 1) then
                  begin

                    packet.Header.Size := sizeof(packet);
                    packet.Header.Code := $397;
                    packet.Header.Index := Player^.base.ClientID;
                    packet.Status := 0;
                    packet.TempoRestante := Player^.F12TempoRestante;
                    packet.Unk1 := Player^.F12TempoAtivo; // tempo usado
                    Player^.F12Ativo := False;
                    Player.base.SendPacket(packet, sizeof(packet));

                    Packet1.Header.Size := sizeof(packet);
                    Packet1.Header.Index := $7535;
                    Packet1.ClientID := Player^.base.ClientID;
                    Packet1.Header.Code := $114;
                    Packet1.EffectId := $0;
                    Player.base.SendToVisible(Packet1, sizeof(Packet1), True);

                    Player.SendClientMessage
                      ('Desativando o auto caça devido ter expirado seu tempo disponível.');
                  end;

                  if Player^.F12Ativo and
                    (Player^.F12TempoRestante >= 1) then
                  begin
                    Player^.F12TempoAtivo :=
                      Player^.F12TempoAtivo + 1;
                    Player^.F12TempoRestante :=
                      Player^.F12TempoRestante - 1;
                  end;

                  {$ENDREGION}

                  // ATUALIZACAO DO SOCIAL E PARTY
                  {$REGION 'UPDATE DE PARTY POSITION E SOCIAL'}
                  if (Player^.PartyIndex <> 0) and (Player^.Party.Members.Count > 1) then
                  begin
                    for k in Player^.Party.Members do
                    begin
                      if k <> Player^.base.ClientID then
                        Player.SendPositionParty(k);
                    end;
                  end;

                  if Player^.GetCurrentCity <> Player^.CurrentCity then
                  begin
                    Player^.CurrentCityID := Player^.GetCurrentCityID;
                    Player.RefreshMeToFriends;
                  end;

                  {$ENDREGION}

                  // REDUCAO DE DURABILIDADE
                  {$REGION 'REDUÇÃO DE DURABILIDADE'}
                  if Player^.base.AttacksAccumulated >= 16 then
                  begin
                    if not Player.base.BuffExistsByIndex(303) then
                    begin
                      Equip := @Player^.base.character.Equip[6];
                      Decrement := IfThen((Equip^.Refi >= 1) and (Equip^.Refi <= 80), 1,
                        IfThen((Equip^.Refi >= 81) and (Equip^.Refi <= 160), 2,
                        IfThen((Equip^.Refi >= 161) and (Equip^.Refi <= 240), 3, 0)));

                      if Decrement > 0 then
                        Dec(Equip^.MIN, Decrement);
                    end;

                    Player^.base.AttacksAccumulated := 0;
                    Player.base.SendRefreshItemSlot(EQUIP_TYPE, 6,
                      Equip^, False);
                  end;

                  if Player^.base.AttacksReceivedAccumulated >= 16 then
                  begin
                    for loop := 2 to 7 do
                    begin
                      if (loop <> 6) and (Player^.base.character.Equip[loop].Index > 0)
                      then
                      begin
                        Equip := @Player^.base.character.Equip[loop];
                        if not Player.base.BuffExistsByIndex(303) then
                        begin
                          Decrement := IfThen((Equip^.Refi >= 1) and (Equip^.Refi <= 80),
                            1, IfThen((Equip^.Refi >= 81) and (Equip^.Refi <= 160), 2,
                            IfThen((Equip^.Refi >= 161) and (Equip^.Refi <= 240), 3, 0)));

                          if Decrement > 0 then
                            Dec(Equip^.MIN, Decrement);
                        end;

                        Player^.base.AttacksReceivedAccumulated := 0;
                        Player.base.SendRefreshItemSlot(EQUIP_TYPE, loop, Equip^, False);
                      end;
                    end;
                  end;
                  {$ENDREGION}

                  // ATAQUE EM PLAYER DE PROPRIA NAÇÃO (PK)
                  {$REGION  'ATAQUE "PK"'}
                  if secondsBetween(now, Player^.LastAttackSent) <= 30 then
                  begin
                    Result := 255;

                    for l := 0 to 119 do
                    begin
                      if (Player^.base.character.inventory[l].Index = 0) then
                        Continue;

                      if (ItemList[Player^.base.character.inventory[l].Index]
                        .ItemType = 40) then
                      begin
                        Result := l;
                        break;
                      end;
                    end;

                    if (Result <> 255) and (Player^.EffectSent <> 800) then
                    begin
                      Player.SendEffect(800);
                      Player^.EffectSent := 800;
                    end;

                    if (Result = 255) and (Player^.EffectSent <> 400) then
                    begin
                      Player.SendEffect(400);
                      Player^.EffectSent := 400;
                    end;

                    Player^.AttackingNation := True;
                  end
                  else
                  begin
                    if (not Player^.AttackingNation) then
                    begin
                      Result := 255;

                      for l := 0 to 119 do
                      begin
                        if (Player^.base.character.inventory[l].Index = 0) then
                          Continue;

                        if (ItemList[Player^.base.character.inventory[l].Index]
                          .ItemType = 40) then
                        begin
                          Result := l;
                          break;
                        end;
                      end;

                      if (Result <> 255) and (Player^.EffectSent = 800) then
                      begin
                        Player.SendEffect(32);
                        Player^.EffectSent := 32;
                      end
                      else if (Result = 255) and (Player^.EffectSent <> 0) then
                      begin
                        Player.SendEffect(0);
                        Player^.EffectSent := 0;
                      end;
                    end
                    else
                    begin
                      Player^.AttackingNation := False;
                    end;
                  end;

                  {$ENDREGION}

                  {$REGION 'Regeneração de HP/MP'}
                  if (secondsBetween(now, Player^.base.LastReceivedAttack) <= 10) or (secondsBetween(now, Player^.LastAttackSents) <= 10) or Player^.base.IsDead then
                    Continue;

                  if (Player^.character.base.CurrentScore.CurMP < Player.base.GetCurrentMP) then
                  begin
                    dirtyHpMp := True;
                    hpMp := Player^.character.base.CurrentScore.CurMP + Player.base.GetRegenerationMP;
                    hpMp := IfThen(hpMp > Player^.base.GetCurrentMP, Player^.base.GetCurrentMP, hpMp);
                    Player^.character.base.CurrentScore.CurMP := hpMp;
                  end;

                  if (Player^.character.base.CurrentScore.CurHP < Player.base.GetCurrentHP) then
                  begin
                    dirtyHpMp := True;
                    hpMp := Player^.character.base.CurrentScore.CurHP + Player.base.GetRegenerationHP;
                    hpMp := IfThen(hpMp > Player.base.GetCurrentHP, Player.base.GetCurrentHP, hpMp);
                    Player^.character.base.CurrentScore.CurHP := hpMp;
                  end;

                  if (dirtyHpMp) then
                  begin
                    Player.base.SendCurrentHPMP();
                  end;

                  {$ENDREGION}


          except
            on E: Exception do
            begin
              Logger.Write('Erro na thread TUpdateHPMPThread ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

       finally
       fCritSec.Leave;
       end;

       TThread.Yield;
       TThread.sleep(FDelay);

  end;
end;

{$ENDREGION}
{$REGION 'TUpdateBuffsThread'}

constructor TUpdateBuffsThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(False);
        Self.Priority := tpLower;
//  Self.Priority := tpTimeCritical;
end;

procedure TUpdateBuffsThread.Execute;
var
  Player: PPlayer;
  key: TPlayerKey;
begin
  while not (Servers[0].ServerHasClosed) do
  begin
       fCritSec.Enter;
       try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          try
            if (Player^.Status <> PLAYING) or Player^.Unlogging or Player^.SocketClosed or Player^.base.IsDead or Player^.ChangingChannel then
                Continue;

              if (Player.Base.RefreshBuffs = 0) then
               Continue;

          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro no update buffsthread ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;
        end;

       finally
        fCritSec.Leave;
        TThread.Yield;
        TThread.sleep(FDelay);
       end;
  end;
end;

{$ENDREGION}
{$REGION 'TUpdateMailsThread'}

constructor TUpdateMailsThread.Create(SleepTime: Integer; ChannelId: BYTE);
// nao ta sendo usada
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSec:= TCriticalSection.Create;
  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TUpdateMailsThread.Execute; // nao ta sendo usada
var
  key: TPlayerKey;
  xPlayer: PPlayer;
begin
  while not (Servers[0].ServerHasClosed) do
  begin

    fCritSec.Enter;

    try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          try
            if Assigned(xPlayer) and (xPlayer^.Status = Playing) and not (xPlayer^.SocketClosed) then
            begin
            TEntityMail.SendUnreadMails(xPlayer^);
            end;
          except
            on E: Exception do
            begin
              Logger.Write(Format('Erro no update send unread mails thread ', [E.Message]), TLogType.Error);
              Continue;
            end;
          end;


        end;

    finally
       fCritSec.Leave;
       TThread.Yield;
       TThread.sleep(FDelay);
    end;
  end;
end;

{$ENDREGION}
{ TUpdateTimeThread }
{$REGION 'UpdateTimeThread'}

function IsWeekend(const ADateTime: TDateTime): Boolean;
begin
  Result := (DayOfWeek(ADateTime) in [6, 7, 1]);
  // Sexta-feira, Sábado e Domingo
end;

constructor TUpdateTimeThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSec := TCriticalSection.Create;

  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TUpdateTimeThread.Execute;
var
  ItemSLot: BYTE;
  i, j: Integer;
  xPlayer: PPlayer;
  Key: TPlayerKey;
begin
  while not (Servers[0].ServerHasClosed) do
  begin
       fCritSec.Enter;
       try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


          try

            if not TFunctions.IsPlayerPlaying(xPlayer) then
            continue;


            if (SecondsBetween(now, xPlayer^.LastUpdateTimeThread) < 10) then
            continue;


            xPlayer^.character.LoggedTime := secondsBetween(now, xPlayer^.base.TimeForGoldTime);

            if (xPlayer^.character.LoggedTime >= 600) then
            begin
              if xPlayer^.base.character.CurrentScore.Infamia >= 1 then
              begin
                xPlayer.base.SendCreateMob(0, 0, True, 0, 0);
                xPlayer^.base.character.CurrentScore.Infamia := xPlayer^.base.character.CurrentScore.Infamia - 1;
                xPlayer.SendClientMessage('1 Ponto de Infâmia removido, ainda restam: ' + IntToStr(xPlayer^.base.character.CurrentScore.Infamia));
              end;

              xPlayer^.base.TimeForGoldTime := now;
            end;

            ItemSLot := TItemFunctions.GetItemSlotByItemType(xPlayer^, 715, INV_TYPE);

            if (ItemSLot <> 255) then
            begin
              if (xPlayer^.base.character.inventory[ItemSLot].Time <> 0) and not(xPlayer.base.BuffExistsByID(ItemList[xPlayer^.base.character.inventory[ItemSlot].Index].UseEffect)) and
                not(SkillData[ItemList[xPlayer^.base.character.inventory[ItemSlot].
                Index].UseEffect].Index = 163) then
                xPlayer.base.AddBuff(ItemList[xPlayer^.base.character.inventory[ItemSlot].Index].UseEffect);
            end
            else if (xPlayer.base.BuffExistsByID
              (ItemList[xPlayer^.base.character.inventory[ItemSLot].Index].UseEffect))
            then
              xPlayer.base.RemoveBuff
                (ItemList[xPlayer^.base.character.inventory[ItemSLot].Index]
                .UseEffect);

            ItemSLot := TItemFunctions.GetItemSlotByItemType(xPlayer^, 716,
              INV_TYPE);
            if (ItemSLot <> 255) then
            begin
              if (xPlayer^.base.character.inventory[ItemSLot].Time <> 0) and
                not(xPlayer.base.BuffExistsByID
                (ItemList[xPlayer^.base.character.inventory[ItemSLot].Index]
                .UseEffect)) and
                not(SkillData[ItemList[xPlayer^.base.character.inventory[ItemSLot].
                Index].UseEffect].Index = 163) then
                xPlayer.base.AddBuff
                  (ItemList[xPlayer^.base.character.inventory[ItemSLot].Index]
                  .UseEffect);
            end
            else if (xPlayer.base.BuffExistsByID
              (ItemList[xPlayer^.base.character.inventory[ItemSLot].Index].UseEffect))
            then
              xPlayer.base.RemoveBuff(ItemList[xPlayer^.base.character.inventory[ItemSLot].Index].UseEffect);

            TEntityMail.SendUnreadMails(xPlayer^);
            xPlayer^.LastUpdateTimeThread := now;




          except
            on E: Exception do
            begin
              Logger.Write('Erro na thread TUpdateTimeThread ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

       finally
       fCritSec.Leave;
       end;

       TThread.Yield;
       TThread.sleep(FDelay);
  end;
end;
{$ENDREGION}
{$REGION 'UpdateTimeThread'}

constructor TUpdateEventListenerThread.Create(SleepTime: Integer;
  ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TUpdateEventListenerThread.Execute;
var
  Player: PPlayer;
  key: TPlayerKey;
begin
  while (Servers[0].IsActive) do
  begin

       try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(Player) then
          continue;

          try
            if Player.base.EventListener then
            begin
              if Player^.base.EventAction = 1 then
              begin
                Player^.Laps := SkillData[Player^.base.LaminaID].Duration;

                if Player^.Cycles > Player^.Laps then
                begin
                  Player^.base.EventListener := False;
                  Player^.base.EventAction := 0;
                  Player^.base.LaminaPoints := 0;
                  Player^.base.LaminaID := 0;
                  Player^.Laps := 0;
                  Player^.Cycles := 0;
                end
                else
                begin
                  Player.base.AreaSkill(Player^.base.LaminaPoints, 0, @Player^.base,
                    Player^.base.PlayerCharacter.LastPos,
                    @SkillData[Player^.base.LaminaID]);

                  inc(Player^.Cycles);
                end;
              end;
            end;
          except
            on E: Exception do
            begin
              Logger.Write('Erro na thread TUpdateEventListenerThread ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

       finally
       end;

       TThread.Yield;
       TThread.sleep(FDelay);
       continue;

  end;
end;
{$ENDREGION}
{$REGION 'TSkillRegenerateThread'}
{ TSkillRegenerateThread }

constructor TSkillRegenerateThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(False);
      Self.Priority := tpLower;
//  Self.Priority := tpTimeCritical;
end;

procedure TSkillRegenerateThread.Execute;
var
  Player: PPlayer;
  key: TPlayerKey;
begin
  while (Servers[0].IsActive) do
  begin

    fCritSec.Enter;
       try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          try
            if not TFunctions.IsPlayerPlaying(Player) then
             continue;

            if ((Player^.base.HPRAction <> 0) or Player^.base.HPRListener) then
            begin

             Player^.HPRLaps := SkillData[Player^.base.HPRSkillID].Duration;

              if (Player^.HPRCycles > Player^.HPRLaps) then
              begin
                Player^.base.HPRListener := False;
                Player^.base.HPRAction := 0;
                Player^.base.HPRSkillID := 0;
                Player^.base.HPRSkillEtc1 := 0;
                Player^.HPRLaps := 0;
                Player^.HPRCycles := 0;
                Continue;
              end;

              if not Player^.base.IsDead then
              begin
                case Player^.base.HPRAction of
                  1: // revitalizar wr
                    Player.base.AddHP
                      (((Player^.base.character.CurrentScore.MaxHp div 100) *
                      1), True);

                  2: // aegis tp
                    begin
                      if (SkillData[Player^.base.HPRSkillID].Index = 125) then
                      begin
                        if (Player.base.GetMobAbility(EF_ANTICURE) > 0) then
                        begin
                          if (Player^.base.NegarCuraCount = 0) then
                          begin
                            Player^.base.NegarCuraCount := 3;
                          end;

                          Player.base.RemoveHP
                            (((Player^.base.HPRSkillEtc1 div 100) *
                            Player.base.GetMobAbility(EF_ANTICURE)), True, True);
                          Player^.base.LastReceivedAttack := now;
                          Player^.base.NegarCuraCount :=
                            Player^.base.NegarCuraCount - 1;

                          if (Player^.base.NegarCuraCount = 0) then
                          begin
                            Player.base.RemoveBuffByIndex(88);
                          end;
                        end
                        else
                        begin
                          Player.base.AddHP(Player^.base.HPRSkillEtc1, True);
                        end;
                      end
                      else
                      begin
                        Player.base.AddHP(Player^.base.HPRSkillEtc1, True);
                      end;
                    end;

                  3: // Libertação de mana CL
                    Player.base.AddMP(Player^.base.HPRSkillEtc1, True);

                  4: // gloria de execelsis cl
                    Player.base.AddHP(Player^.base.HPRSkillEtc1, True);
                end;
              end;

              inc(Player^.HPRCycles);

            end;
          except
                        on E: Exception do
            begin
              Logger.Write('Erro na thread TSkillRegenerateThread ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

       finally
       fCritSec.Leave;
       end;

           TThread.Yield;
       TThread.sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'TSkillDamageThread'}
{ TSkillDamageThread }

constructor TSkillDamageThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;

  fCritSec := TCriticalSection.Create;

  inherited Create(False);
  Self.Priority := tpLower;

end;

procedure TSkillDamageThread.Execute;
var
  i, j: Integer;
  Player, Target: PPlayer;
  key: TPlayerKey;
begin
  while (Servers[0].IsActive) do
  begin


       fCritSec.Enter;

       try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(Player) then
          continue;
          try
               if (Player^.base.IsDead) then
                  Continue;

                if (Player^.base.SKDAction = 0) or not(Player^.base.SKDListener) or
                  (Player^.base.SKDSkillID = 0) or (Player^.base.SKDSkillID > 11998)
                then
                  Continue;

                case Player^.base.SKDAction of
                  1, 2: // estocada wr e outra ação
                    begin
                      Player^.SKDLaps := SkillData[Player.base.SKDSkillID].Duration;

                      if (Player^.SKDCycles > Player^.SKDLaps) then
                      begin
                        Player^.base.SKDListener := False;
                        Player^.base.SKDAction := 0;
                        Player^.base.SKDSkillID := 0;
                        Player^.base.SKDSkillEtc1 := 0;
                        Player^.SKDLaps := 0;
                        Player^.SKDCycles := 0;
                        Player^.base.SKDIsMob := False;
                        Player^.base.SDKMobID := 0;
                        Player^.base.SDKSecondIndex := 0;
                        Continue;
                      end;

                      if (Player^.base.SKDIsMob) then
                      begin
                        if (Player^.base.SDKSecondIndex = 0) then
                          Continue;

                        if not(Servers[Player^.ChannelIndex].MOBS.TMobS
                          [Player.base.SDKMobID].MobsP[Player^.base.SDKSecondIndex]
                          .base.IsDead) then
                          Servers[Player^.ChannelIndex].MOBS.TMobS
                            [Player.base.SDKMobID].MobsP[Player^.base.SDKSecondIndex]
                            .base.RemoveHP(Player^.base.SKDSkillEtc1, True, True);
                      end
                      else
                      begin
                        if (Player^.base.SKDTarget = 0) then
                          Continue;

                        Target := @Servers[Player^.ChannelIndex].Players[Player^.base.SKDTarget];

                        if (Target^.SocketClosed) or (Target^.Status < PLAYING) or
                          (Target^.base.IsDead) then
                          Continue;

                        Target.base.RemoveHP(Player^.base.SKDSkillEtc1, True, True);
                        Target.base.LastReceivedAttack := now;
                      end;

                      inc(Player.SKDCycles);
                    end;
                end;



          except
                        on E: Exception do
            begin
              Logger.Write('Erro na thread TSkillDamageThread ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

       finally
       fCritSec.Leave;
       end;

       TThread.Yield;
       TThread.sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'Verify Item Expired Thread'}

procedure TTimeItensThread.CheckItens;
var
  j: byte;
  ResultOf: Integer;
  ItemName: String;
  Player: PPlayer;
  key: TPlayerKey;
begin

//      fCritSec.Enter;
       try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(Player) then
          continue;

          try
            if (secondsBetween(now, Player^.LastTTimeItensThread) <= 10) then
               Continue;

            Player^.LastTTimeItensThread := now;

              for j := 0 to 125 do
              begin
                if (Player^.base.character.inventory[j].Index = 0) then
                  Continue;

                if (ItemList[Player^.base.character.inventory[j].Index].Expires) and
                  not(Player^.base.character.inventory[j].IsSealed) then
                begin
                  ResultOf := CompareDateTime(now, Player^.base.character.inventory[j].ExpireDate);

                  if (ResultOf = 1) then
                  begin
                    ItemName := String(ItemList[Player^.base.character.inventory[j].Index].name);

                    if (ItemList[Player^.base.character.inventory[j].Index].ItemType = 716) then
                    begin
                      Player.base.RemoveBuff(ItemList[Player^.base.character.inventory[j].Index].UseEffect);
                    end;

                    if (TItemFunctions.GetItemEquipSlot
                      (Player^.base.character.inventory[j].Index) = 9) then
                    begin
                      Player^.base.character.inventory[j].Time := $FFFF;
                      Player.base.SendRefreshItemSlot(INV_TYPE, j,Player^.base.character.inventory[j], False);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                    end
                    else if (ItemList[Player^.base.character.inventory[j].Index].Classe
                      >= 100) and (ItemList[Player^.base.character.inventory[j].Index]
                      .Classe <= 104) then
                    begin
                      Player^.base.character.inventory[j].MIN := $FF;
                      Player^.base.character.inventory[j].Max := $FF;
                      Player.base.SendRefreshItemSlot(INV_TYPE, j,
                        Player^.base.character.inventory[j], False);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                    end
                    else
                    begin
                      TItemFunctions.RemoveItem(Player^, INV_TYPE, j);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                    end;
                  end;
                end;
              end;

              for j := 0 to 15 do
              begin
                if (Player^.base.character.Equip[j].Index = 0) or
                  (Player^.base.character.Equip[j].Time = 0) then
                  Continue;

                if (ItemList[Player^.base.character.Equip[j].Index].Expires) and
                  not(Player^.base.character.Equip[j].IsSealed) then
                begin
                  ResultOf := CompareDateTime(now, Player^.base.character.Equip[j]
                    .ExpireDate);

                  if (ResultOf = 1) then
                  begin
                    ItemName :=
                      String(ItemList[Player^.base.character.Equip[j].Index].name);

                    if (TItemFunctions.GetItemEquipSlot(Player^.base.character.Equip[j]
                      .Index) = 9) then
                    begin
                      Player^.base.character.Equip[j].Time := $FFFF;
                      Player.base.SendRefreshItemSlot(EQUIP_TYPE, j,
                        Player^.base.character.Equip[j], False);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                      Player.base.SetEquipEffect(Player^.base.character.Equip[j],
                        DESEQUIPING_TYPE, True, False);
                      Player.base.GetCurrentScore;
                      Player.base.SendRefreshPoint;
                      Player.base.SendStatus;
                      Player.base.SendCurrentHPMP();
                    end
                    else if (ItemList[Player^.base.character.Equip[j].Index].Classe >=
                      100) and (ItemList[Player^.base.character.Equip[j].Index].Classe
                      <= 104) then
                    begin
                      Player^.base.character.Equip[j].MIN := $FF;
                      Player^.base.character.Equip[j].Max := $FF;
                      Player.base.SendRefreshItemSlot(EQUIP_TYPE, j,
                        Player^.base.character.Equip[j], False);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                      Player.base.SetEquipEffect(Player^.base.character.Equip[j],
                        DESEQUIPING_TYPE, True, False);
                      Player.base.GetCurrentScore;
                      Player.base.SendRefreshPoint;
                      Player.base.SendStatus;
                      Player.base.SendCurrentHPMP();
                    end
                    else
                    begin
                      TItemFunctions.RemoveItem(Player^, EQUIP_TYPE, j);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                    end;
                  end;
                end;
              end;

              for j := 0 to 83 do
              begin
                if (Player^.Account.Header.Storage.Itens[j].Index = 0) then
                  Continue;

                if (ItemList[Player^.Account.Header.Storage.Itens[j].Index].Expires)
                  and not(Player^.Account.Header.Storage.Itens[j].IsSealed) then
                begin
                  ResultOf := CompareDateTime(now, Player^.Account.Header.Storage.Itens
                    [j].ExpireDate);

                  if (ResultOf = 1) then
                  begin
                    ItemName :=
                      String(ItemList[Player^.Account.Header.Storage.Itens[j].
                      Index].name);

                    if (TItemFunctions.GetItemEquipSlot
                      (Player^.Account.Header.Storage.Itens[j].Index) = 9) then
                    begin
                      Player^.Account.Header.Storage.Itens[j].Time := $FFFF;
                      Player.base.SendRefreshItemSlot(STORAGE_TYPE, j,
                        Player^.Account.Header.Storage.Itens[j], False);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                    end
                    else if (ItemList[Player^.Account.Header.Storage.Itens[j].Index]
                      .Classe >= 100) and
                      (ItemList[Player^.Account.Header.Storage.Itens[j].Index].Classe
                      <= 104) then
                    begin
                      Player^.Account.Header.Storage.Itens[j].MIN := $FF;
                      Player^.Account.Header.Storage.Itens[j].Max := $FF;
                      Player.base.SendRefreshItemSlot(STORAGE_TYPE, j,
                        Player^.Account.Header.Storage.Itens[j], False);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                    end
                    else
                    begin
                      TItemFunctions.RemoveItem(Player^, STORAGE_TYPE, j);
                      Player.SendClientMessage('O item [' + AnsiString(ItemName) +
                        '] expirou.');
                    end;
                  end;
                end;
              end;

              case Player.SpawnedPran of
                0:
                  begin
                    for j := 1 to 5 do
                    begin
                      if (Player^.Account.Header.Pran1.Equip[j].Index = 0) then
                        Continue;

                      if (ItemList[Player^.Account.Header.Pran1.Equip[j].Index]
                        .Expires) and
                        not(Player^.Account.Header.Pran1.Equip[j].IsSealed) then
                      begin
                        ResultOf := CompareDateTime(now,
                          Player^.Account.Header.Pran1.Equip[j].ExpireDate);

                        if (ResultOf = 1) then
                        begin
                          ItemName :=
                            String(ItemList[Player^.Account.Header.Pran1.Equip[j].
                            Index].name);

                          if (ItemList[Player^.Account.Header.Pran1.Equip[j].Index]
                            .Classe >= 100) and
                            (ItemList[Player^.Account.Header.Pran1.Equip[j].Index]
                            .Classe <= 104) then
                          begin
                            Player^.Account.Header.Pran1.inventory[j].Max := $FF;
                            Player^.Account.Header.Pran1.inventory[j].MIN := $FF;
                            Player.base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, j,
                              Player^.Account.Header.Pran1.Equip[j], False);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                            Player.base.SetEquipEffect
                              (Player^.Account.Header.Pran1.Equip[j], DESEQUIPING_TYPE,
                              True, False);
                            Player.base.GetCurrentScore;
                            Player.base.SendRefreshPoint;
                            Player.base.SendStatus;
                            Player.base.SendCurrentHPMP();
                          end
                          else
                          begin
                            TItemFunctions.RemoveItem(Player^, PRAN_EQUIP_TYPE, j);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end;
                        end;
                      end;
                    end;

                    for j := 0 to 41 do
                    begin
                      if (Player^.Account.Header.Pran1.inventory[j].Index = 0) then
                        Continue;

                      if (ItemList[Player^.Account.Header.Pran1.inventory[j].Index]
                        .Expires) and
                        not(Player^.Account.Header.Pran1.inventory[j].IsSealed) then
                      begin
                        ResultOf := CompareDateTime(now,
                          Player^.Account.Header.Pran1.inventory[j].ExpireDate);

                        if (ResultOf = 1) then
                        begin
                          ItemName :=
                            String(ItemList[Player^.Account.Header.Pran1.inventory[j].
                            Index].name);

                          if (TItemFunctions.GetItemEquipSlot
                            (Player^.Account.Header.Pran1.inventory[j].Index) = 9) then
                          begin
                            Player^.Account.Header.Pran1.inventory[j].Time := $FFFF;
                            Player.base.SendRefreshItemSlot(PRAN_INV_TYPE, j,
                              Player^.Account.Header.Pran1.inventory[j], False);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end
                          else if (ItemList[Player^.Account.Header.Pran1.inventory[j].
                            Index].Classe >= 100) and
                            (ItemList[Player^.Account.Header.Pran1.inventory[j].Index]
                            .Classe <= 104) then
                          begin
                            Player^.Account.Header.Pran1.inventory[j].Max := $FF;
                            Player^.Account.Header.Pran1.inventory[j].MIN := $FF;
                            Player.base.SendRefreshItemSlot(PRAN_INV_TYPE, j,
                              Player^.Account.Header.Pran1.inventory[j], False);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end
                          else
                          begin
                            TItemFunctions.RemoveItem(Player^, PRAN_INV_TYPE, j);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end;
                        end;
                      end;
                    end;
                  end;

                1:
                  begin
                    for j := 1 to 5 do
                    begin
                      if (Player^.Account.Header.Pran2.Equip[j].Index = 0) then
                        Continue;

                      if (ItemList[Player^.Account.Header.Pran2.Equip[j].Index]
                        .Expires) and
                        not(Player^.Account.Header.Pran2.Equip[j].IsSealed) then
                      begin
                        ResultOf := CompareDateTime(now,
                          Player^.Account.Header.Pran2.Equip[j].ExpireDate);

                        if (ResultOf = 1) then
                        begin
                          ItemName :=
                            String(ItemList[Player^.Account.Header.Pran2.Equip[j].
                            Index].name);

                          if (ItemList[Player^.Account.Header.Pran2.Equip[j].Index]
                            .Classe >= 100) and
                            (ItemList[Player^.Account.Header.Pran2.Equip[j].Index]
                            .Classe <= 104) then
                          begin
                            Player^.Account.Header.Pran2.inventory[j].Max := $FF;
                            Player^.Account.Header.Pran2.inventory[j].MIN := $FF;
                            Player.base.SendRefreshItemSlot(PRAN_EQUIP_TYPE, j,
                              Player^.Account.Header.Pran2.Equip[j], False);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                            Player.base.SetEquipEffect
                              (Player^.Account.Header.Pran2.Equip[j], DESEQUIPING_TYPE,
                              True, False);
                            Player.base.GetCurrentScore;
                            Player.base.SendRefreshPoint;
                            Player.base.SendStatus;
                            Player.base.SendCurrentHPMP();
                          end
                          else
                          begin
                            TItemFunctions.RemoveItem(Player^, PRAN_EQUIP_TYPE, j);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end;
                        end;
                      end;
                    end;

                    for j := 0 to 41 do

                    begin
                      if (Player^.Account.Header.Pran2.inventory[j].Index = 0)
                      { or (Player.Account.
                        Header.Pran2.Inventory[j].Time = ) } then
                        Continue;

                      // if(ItemList[Player.Account.Header.Pran2.Inventory[j].Index].Classe >= 100) and
                      // (ItemList[Player.Account.Header.Pran2.Inventory[j].Index].Classe <= 104) then
                      // Continue;

                      if ((ItemList[Player^.Account.Header.Pran2.inventory[j].Index]
                        .Expires) and not(Player^.Account.Header.Pran2.inventory[j]
                        .IsSealed)) then
                      begin
                        ResultOf := CompareDateTime(now,
                          Player^.Account.Header.Pran2.inventory[j].ExpireDate);

                        if (ResultOf = 1) then
                        begin
                          ItemName :=
                            String(ItemList[Player^.Account.Header.Pran2.inventory[j].
                            Index].name);

                          if (TItemFunctions.GetItemEquipSlot
                            (Player^.Account.Header.Pran2.inventory[j].Index) = 9) then
                          begin // montaria não deleta, só expira mesmo
                            Player^.Account.Header.Pran2.inventory[j].Time := $FFFF;
                            // Player.Account.
                            // Header.Pran2.Inventory[j].MIN := $FF;
                            Player.base.SendRefreshItemSlot(PRAN_INV_TYPE, j,
                              Player^.Account.Header.Pran2.inventory[j], False);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end
                          else if (ItemList[Player^.Account.Header.Pran2.inventory[j].
                            Index].Classe >= 100) and
                            (ItemList[Player^.Account.Header.Pran2.inventory[j].Index]
                            .Classe <= 104) then
                          begin // roupa de pran não deleta, só expira mesmo
                            Player^.Account.Header.Pran2.inventory[j].Max := $FF;
                            Player^.Account.Header.Pran2.inventory[j].MIN := $FF;
                            Player.base.SendRefreshItemSlot(PRAN_INV_TYPE, j,
                              Player^.Account.Header.Pran2.inventory[j], False);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end
                          else
                          begin
                            TItemFunctions.RemoveItem(Player^, PRAN_INV_TYPE, j);
                            Player.SendClientMessage('O item [' + AnsiString(ItemName)
                              + '] expirou.');
                          end;
                        end;
                      end;
                    end;
                  end;
              end;



          except
                        on E: Exception do
            begin
              Logger.Write('Erro na thread TTimeItemsThread ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

       finally
//       fCritSec.Leave;
       end;

           TThread.Yield;
       TThread.sleep(FDelay);
    Exit;
end;

constructor TTimeItensThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSec:= TCriticalSection.Create;
  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TTimeItensThread.Execute;
var
  i, j: Integer;
  Player: PPlayer;
begin
  while not (Servers[0].ServerHasClosed) do
  begin
    fCritSec.enter;
    try
    Self.CheckItens;
    finally
    fCritSec.Leave;
    end;

    TThread.Yield;
    TThread.sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'Verify Item Quest Thread'}

procedure TQuestItemThread.CheckInventory();
var
  ItemID: word;
  Item: PItem;
  OldValue: word;
  Helper: word;
  j, k, l: byte;
  i: word;
  Player: PPlayer;
  key: TPlayerKey;
begin

        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(Player) then
          continue;

          try
            if (secondsBetween(now, Player^.LastTQuestItensThread) < 10) then
            begin

            Player^.LastTQuestItensThread := now;

                for j := 0 to 49 do
                begin
                  if (Player^.PlayerQuests[j].ID > 0) and not(Player^.PlayerQuests[j].IsDone)
                  then
                  begin // quest ainda não entregue
                    for k := 0 to 4 do
                    begin
                      if (Player^.PlayerQuests[j].Quest.RequirimentsType[k] = 2) then
                      begin // se a quest tiver algum requerimento de pegar item
                        ItemID := Player^.PlayerQuests[j].Quest.Requiriments[k];

                        case Player^.PlayerQuests[j].Quest.QuestID of
                          1297: // quest da relíquia
                            begin
                              Helper := TItemFunctions.GetItemSlotByItemType(Player^, 713,
                                INV_TYPE);
                              if Helper <> 255 then
                              begin
                                Item := @Player^.base.character.inventory[Helper];
                                OldValue := Player^.PlayerQuests[j].Complete[k];
                                Player^.PlayerQuests[j].Complete[k] := Item.Refi;
                              end
                              else
                              begin
                                Player^.PlayerQuests[j].Complete[k] := 0;
                              end;
                            end;
                        else
                          begin
                            Item := nil;
                            for l := 0 to 125 do
                            begin
                              if (Player^.base.character.inventory[l].Index = ItemID) then
                              begin
                                Item := @Player^.base.character.inventory[l];
                                break;
                              end;
                            end;

                            OldValue := Player^.PlayerQuests[j].Complete[k];
                            if (Item = nil) then
                              Player^.PlayerQuests[j].Complete[k] := 0
                            else
                              Player^.PlayerQuests[j].Complete[k] := Item.Refi;
                          end;
                        end;

                        // Verificar se o valor mudou e atualizar
                        if (OldValue <> Player^.PlayerQuests[j].Complete[k]) then
                        begin
                          Player.UpdateQuest(Player^.PlayerQuests[j].ID);
                        end;
                      end;
                    end;
                  end;
                end;

            end;
          except
                        on E: Exception do
            begin
              Logger.Write('Erro na thread TQuestItemThread ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;
       exit;


 {
  for o := 0 to 3 do
  begin
    Self.ChannelId := o;
    if not(Servers[o].IsActive) then
      Continue;

    if (Servers[o].InstantiatedPlayers = 0) then
      Continue;

    for i := 1 to MAX_CONNECTIONS DO
    begin

      Player := @Servers[o].Players[i];

      if not(Player.Status = PLAYING) then
        Continue;

      if (Player.SocketClosed) or (Player.Unlogging) then
        Continue;

      if secondsBetween(now, Player.LastTQuestItensThread) <= 2 then
        Continue;


    end;
  end; }

end;

constructor TQuestItemThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.ChannelId := ChannelId;
  fCritSec:= TCriticalSection.Create;
  inherited Create(False);
    Self.Priority := tpLower;
//  Self.Priority := tpTimeCritical;
end;

procedure TQuestItemThread.Execute;
begin
  while not (Servers[0].ServerHasClosed) do
  begin

    try
      fCritSec.Enter;
      Self.CheckInventory;
      fCritSec.Leave;
    except
       on E: Exception do
       begin
         Logger.Write('Erro na thread TQuestItem.Execute ' + E.Message, TLogType.Error);
           continue;
       end;
    end;
    TThread.Yield;
    TThread.sleep(FDelay);
  end;
end;

{$ENDREGION}
{$REGION 'Pran Food System'}

constructor TPranFoodThread.Create(SleepTime: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  fCritSec:= TCriticalSection.create;
  inherited Create(False);
  Self.Priority := tpLower;

end;


procedure TPranFoodThread.Execute;
begin
  while (Servers[0].IsActive) do
  begin
     fCritSec.Enter;
    try
     Self.CheckFood;

    finally
      fCritSec.Leave;
    end;

    TThread.Yield;

    TThread.sleep(FDelay);
  end;
end;

procedure TPranFoodThread.CheckFood;
var
  destItem, srcItem: PItem;
  Player: PPlayer;
  key: TPlayerKey;
begin


        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          Player := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(Player) then
          continue;

          try
                  if (Player^.Account.Header.Pran1.IsSpawned) then
                  begin
                    if not(Player^.Account.Header.Pran1.Food = 0) then
                    begin
                      if (Player^.Account.Header.Pran1.Food <= 3) then
                        Player^.Account.Header.Pran1.Food := 0
                      else
                        Player^.Account.Header.Pran1.Food :=
                          Player^.Account.Header.Pran1.Food - 3;

                      if (Player^.Account.Header.Pran1.Food < 25) then
                      begin
                        Player.SendClientMessage('Pran está com fome.', 16, 32);
                      end;
                    end
                    else
                    begin
                      { if not(Player
                        .Account.Header.Pran1.Devotion = 0) then
                        Player.Account.Header.Pran1.Devotion :=
                        Player.Account.Header.Pran1.Devotion - 1
                        else
                        begin }
                      { if not(Player
                        .Account.Header.Pran1.MovedToCentral) then
                        begin
                        Player.SendClientMessage
                        ('Sua pran foi enviada para a estação pran');

                        Player.Account.Header.Pran1.
                        MovedToCentral := True;
                        Player.Account.Header.Pran1.
                        IsSpawned := FALSE;
                        Player.Account.Header.Pran1.Food := 10;
                        Player.SpawnedPran := 255;
                        Player.Account.Header.Pran1.
                        Devotion := 68;
                        // familiaridade pran cai pra 30% apos ela ser mandada pra estação pran

                        Player.SetPranEquipAtributes(0, FALSE);

                        if (Player.Account.Header.Storage.Itens
                        [84].Index = 0) then
                        begin
                        srcItem := @Player
                        .Base.Character.Equip[10];
                        destItem := @Player
                        .Account.Header.Storage.Itens[84];

                        //Move(destItem^, Aux, sizeof(TItem));
                        Move(srcItem^, destItem^, sizeof(TItem));
                        //Move(Aux, srcItem^, sizeof(TItem));

                        // Move(Player.Base.Character.Equip[10],
                        // Player.Account.Header.Storage.Itens
                        // [84], sizeof(TItem));

                        Player.Base.SendRefreshItemSlot
                        (EQUIP_TYPE, 10, Player
                        .Base.Character.Equip[10], FALSE);
                        Player.Base.SendRefreshItemSlot
                        (STORAGE_TYPE, 84, Player
                        .Account.Header.Storage.Itens[84], FALSE);
                        end
                        else if (Player
                        .Account.Header.Storage.Itens[85].Index = 0) then
                        begin
                        srcItem := @Player
                        .Base.Character.Equip[10];
                        destItem := @Player
                        .Account.Header.Storage.Itens[85];

                        //Move(destItem^, Aux, sizeof(TItem));
                        Move(srcItem^, destItem^, sizeof(TItem));
                        //Move(Aux, srcItem^, sizeof(TItem));

                        // Move(Player.Base.Character.Equip[10],
                        // Player.Account.Header.Storage.Itens
                        // [85], sizeof(TItem));

                        Player.Base.SendRefreshItemSlot
                        (EQUIP_TYPE, 10, Player
                        .Base.Character.Equip[10], FALSE);
                        Player.Base.SendRefreshItemSlot
                        (STORAGE_TYPE, 85, Player
                        .Account.Header.Storage.Itens[85], FALSE);
                        end;

                        Player.spawnedPran := 255;
                        Player.SendPranToWorld(255);
                        Player.SendPranUnspawn(0);
                        Player.SetPranPassiveSkill(0, 0);
                        Player.SetPranEquipAtributes(0, False);
                        Player.Base.GetCurrentScore;
                        Player.Base.SendStatus;
                        Player.Base.SendRefreshPoint;
                        Player.Base.SendCurrentHPMP;

                        Player.SendEffect(0);

                        Continue;
                        end; }
                      // end;
                    end;

                    if (Player^.Account.Header.Pran1.Food >= 72) then
                    begin
                      if not(Player^.Account.Header.Pran1.Devotion >= 226) then
                        Player^.Account.Header.Pran1.Devotion :=
                          Player^.Account.Header.Pran1.Devotion + 1;
                    end
                    else
                    begin
                      Player^.Account.Header.Pran1.Devotion :=
                        Player^.Account.Header.Pran1.Devotion - 1;
                    end;

                    Player.SendPranToWorld(0);
                  end;

                  if (Player^.Account.Header.Pran2.IsSpawned) then
                  begin
                    if not(Player^.Account.Header.Pran2.Food = 0) then
                    begin
                      if (Player^.Account.Header.Pran2.Food <= 3) then
                        Player^.Account.Header.Pran2.Food := 0
                      else
                        Player^.Account.Header.Pran2.Food :=
                          Player^.Account.Header.Pran2.Food - 3;

                      if (Player^.Account.Header.Pran2.Food < 25) then
                      begin
                        Player.SendClientMessage('Pran está com fome.', 16, 32);
                      end;
                    end
                    else
                    begin
                      { if not(Player
                        .Account.Header.Pran2.Devotion = 0) then
                        Player.Account.Header.Pran2.Devotion :=
                        Player.Account.Header.Pran2.Devotion - 1
                        else
                        begin }
                      { if not(Player
                        .Account.Header.Pran2.MovedToCentral) then
                        begin
                        Player.SendClientMessage
                        ('Sua pran foi enviada para a estação pran');

                        Player.Account.Header.Pran2.
                        MovedToCentral := True;
                        Player.Account.Header.Pran2.
                        IsSpawned := FALSE;
                        Player.SpawnedPran := 255;
                        Player.Account.Header.Pran2.
                        Devotion := 68;
                        Player.Account.Header.Pran2.Food := 10;
                        // familiaridade pran cai pra 30% apos ela ser mandada pra estação pran

                        Player.SetPranEquipAtributes(1, FALSE);

                        if (Player.Account.Header.Storage.Itens
                        [84].Index = 0) then
                        begin
                        srcItem := @Player
                        .Base.Character.Equip[10];
                        destItem := @Player
                        .Account.Header.Storage.Itens[84];

                        //Move(destItem^, Aux, sizeof(TItem));
                        Move(srcItem^, destItem^, sizeof(TItem));
                        //Move(Aux, srcItem^, sizeof(TItem));

                        // Move(Player.Base.Character.Equip[10],
                        // Player.Account.Header.Storage.Itens
                        // [84], sizeof(TItem));

                        Player.Base.SendRefreshItemSlot
                        (EQUIP_TYPE, 10, Player
                        .Base.Character.Equip[10], FALSE);
                        Player.Base.SendRefreshItemSlot
                        (STORAGE_TYPE, 84, Player
                        .Account.Header.Storage.Itens[84], FALSE);
                        end
                        else if (Player
                        .Account.Header.Storage.Itens[85].Index = 0) then
                        begin
                        srcItem := @Player
                        .Base.Character.Equip[10];
                        destItem := @Player
                        .Account.Header.Storage.Itens[85];

                        //Move(destItem^, Aux, sizeof(TItem));
                        Move(srcItem^, destItem^, sizeof(TItem));
                        // Move(Aux, srcItem^, sizeof(TItem));

                        // Move(Player.Base.Character.Equip[10],
                        // Player.Account.Header.Storage.Itens
                        // [85], sizeof(TItem));
                        Player.Base.SendRefreshItemSlot
                        (EQUIP_TYPE, 10, Player
                        .Base.Character.Equip[10], FALSE);
                        Player.Base.SendRefreshItemSlot
                        (STORAGE_TYPE, 85, Player
                        .Account.Header.Storage.Itens[85], FALSE);
                        end;

                        Player.spawnedPran := 255;
                        Player.SendPranToWorld(255);
                        Player.SendPranUnspawn(1);
                        Player.SetPranPassiveSkill(1, 0);
                        Player.Base.GetCurrentScore;
                        Player.Base.SendStatus;
                        Player.Base.SendRefreshPoint;
                        Player.Base.SendCurrentHPMP;
                        Player.SendEffect(0);

                        Continue;
                        end; }
                      // end;
                    end;

                    if (Player^.Account.Header.Pran2.Food >= 72) then
                    begin
                      if not(Player^.Account.Header.Pran2.Devotion >= 226) then
                        Player^.Account.Header.Pran2.Devotion :=
                          Player^.Account.Header.Pran2.Devotion + 1;
                    end
                    else
                    begin
                      Player^.Account.Header.Pran2.Devotion :=
                        Player^.Account.Header.Pran2.Devotion - 1;
                    end;

                    Player.SendPranToWorld(1);
                  end;



          except
              on E: Exception do
              begin
                Logger.Write('Erro na thread TPranFoodThread ' + E.Message, TLogType.Error);
                  continue;
              end;
          end;


        end;
       exit;


end;

{$ENDREGION}

constructor TPlayerManagementThread.Create(SleepTime: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;

  fCritSec := TCriticalSection.Create;

  inherited Create(False);
end;

procedure TPlayerManagementThread.Execute;
var
  xPlayer: PPlayer;
  Bala: PItem;
  packet: TRefreshItemPacket;
  key: TPlayerKey;
begin
  while (Servers[0].IsActive) do
  begin
    fCritSec.Enter;

    try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;


          try

              if (xPlayer^.base.IsDead) and not(xPlayer^.DeathSendByThread) then
              begin
                xPlayer^.base.character.CurrentScore.CurHP := 0;
                xPlayer.base.SendCurrentHPMP();
                xPlayer.base.SendEffect($0);
                xPlayer^.DeathSendByThread := True;
              end;

              if MillisecondsBetween(now, xPlayer^.LastAttackSents) < 2000 then
              begin

                if (xPlayer.base.GetMobClass = 2) or (xPlayer.base.GetMobClass = 3)
                then
                begin
                  Bala := @xPlayer^.base.character.Equip[15];
                  if (Bala^.Index >= 1) and (ItemList[Bala^.Index].ItemType = 50) then
                  begin
                    packet.Header.Size := sizeof(packet);
                    packet.Header.Index := $7535;
                    packet.Header.Code := $F0E;
                    packet.Notice := True;
                    packet.TypeSlot := 0;
                    packet.Slot := 15;
                    packet.Item := Bala^;
                    xPlayer.base.SendPacket(packet, packet.Header.Size);
                  end
                  else if (Bala^.Index = 0) then
                  begin
                    packet.Header.Size := sizeof(packet);
                    packet.Header.Index := $7535;
                    packet.Header.Code := $F0E;
                    packet.Notice := True;
                    packet.TypeSlot := 0;
                    packet.Slot := 15;
                    packet.Item := Bala^;
                    xPlayer.base.SendPacket(packet, packet.Header.Size);
                  end;
                end;

              end;

          except
            on E: Exception do
            begin
              Logger.Write('Erro no player management ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

    finally
      fCritSec.Leave;
      TThread.Yield;
      TThread.sleep(FDelay);
    end;


  end;

end;

constructor TVisibleManagementThread.Create(SleepTime: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  fCritSec := TCriticalSection.Create;
  inherited Create(False);
end;

procedure TVisibleManagementThread.Execute;
var
  xPlayer: PPlayer;
  key: TPlayerKey;
begin

  while true do
  begin

    fCritSec.Enter;
    try
        for Key in ActivePlayers.Keys do
        begin
          // Acessa o jogador associado à chave
          xPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(xPlayer) then
          continue;
          if (MillisecondsBetween(now, xPlayer^.LastUpdateVisible) < 200) then
          continue;


          try
              xPlayer^.LastUpdateVisible := now;
              if ElterHappening and (xPlayer^.Waiting1 > 0) then
              begin
                xPlayer.base.UpdateVisibleElter;
              end
              else if xPlayer^.InDungeon then
              begin
                xPlayer.base.UpdateVisibleDungeon;
              end
              else if (xPlayer^.GetCurrentCityID = 3) and xPlayer^.base.InClastleVerus then
              begin
                xPlayer.base.UpdateVisibleCastle;
              end
              else if (xPlayer^.ChannelIndex = 3) and (xPlayer^.Waiting1 = 0) then
              begin
               xPlayer.base.UpdateVisibleLeopold;
              end
              else
              begin
                xPlayer.base.UpdateVisibleList;
              end;

              xPlayer.SetCurrentNeighbors;



          except
            on E: Exception do
            begin
              Logger.Write('Erro no update visible ' + E.Message, TLogType.Error);
                continue;
            end;
          end;


        end;

    finally
       fCritSec.Leave;
       TThread.Yield;
       TThread.sleep(FDelay);
    end;


  end;

end;


constructor TGuardsVisibleManagementThread.Create(SleepTime: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;

  fCritSec := TCriticalSection.Create;

  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TGuardsVisibleManagementThread.Execute;
var
  l: byte;
  i: word;
  Player: PPlayer;
begin
  while not (Servers[0].ServerHasClosed) do
  begin

    for l := 0 to 2 do
    begin


      //devir guardas
      for i := Low(Servers[l].DevirGuards) to High(Servers[l].DevirGuards) do
      begin
        try
          Servers[l].DevirGuards[i].base.UpdateVisibleList;
        except
          on E: Exception do
          begin
            Logger.Write('erro customizado devir guards ' + E.Message, TLogType.Error);
          end;
        end;
      end;


      //devir stones
      for i := Low(Servers[l].DevirStones) to High(Servers[l].DevirStones) do
      begin
        try
          Servers[l].DevirStones[i].base.UpdateVisibleList;
        except
          on E: Exception do
          begin
            Logger.Write('erro customizado devir stones ' + E.Message, TLogType.Error);
          end;
        end;
      end;


      //royal guards (opera em todos os guardas, deixar separado em breve)
      for i := Low(Servers[l].RoyalGuards) to High(Servers[l].RoyalGuards) do
      begin

        try
          Servers[l].RoyalGuards[i].base.UpdateVisibleList;

        except
          on E: Exception do
          begin
            Logger.Write('erro customizado royal guards' + E.Message, TLogType.Error);
          end;
        end;
      end;

    end;

    TThread.Yield;
    TThread.sleep(FDelay);
  end;
end;

{$REGION 'Temples Thread'}

constructor TTemplesManagmentThread.Create(SleepTime: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  fCritSec := TCriticalSection.Create;
  inherited Create(False);
  // Self.Priority := tpLower;
end;

procedure TTemplesManagmentThread.Execute;
begin
  while true do
  begin

    fCritSec.Enter;
    try
//      self.CheckRoyalGuards;
//      Self.CheckGuards;

//      Self.CheckStones;
//      Self.CheckReliques;
    finally
      fCritSec.Leave;
    end;

//    TThread.Yield;
    TThread.sleep(FDelay);
  end;
end;


procedure TTemplesManagmentThread.CheckRoyalGuards;
var
  OtherPlayer: PPlayer; //ponteiro de jogadores
  Rand: byte; //gerador de random para randomizar a posição que o guarda se move pra proximo do neighbor player
  c: byte; //iteracao sobre canais/servidores
  j: word; //iteracao sobre guardas
  i: byte; //iteracao sobre players
  d: byte; //resposta sobre devir ID
  key: TPlayerKey;
begin

        for c := 0 to 2 do
        begin

          if not Servers[c].IsActive then
          continue;

          for j := Low(Servers[c].RoyalGuards) to High(Servers[c].RoyalGuards) do
          begin
//           if Servers[c].RoyalGuards[j].Base.ClientID = 0 then
//           continue;

            try

              if (Servers[c].RoyalGuards[j].base.IsDead) then
              begin
                // verifica o tempo de reespawn
                if ((now >= IncSecond(Servers[c].RoyalGuards[j].DeadTime, 180)))
                then
                begin
                  Servers[c].RoyalGuards[j].base.IsDead := False;
                  Servers[c].RoyalGuards[j].PlayerChar.base.CurrentScore.CurHP := Servers[c].RoyalGuards[j].PlayerChar.base.CurrentScore.MaxHp;
                  Servers[c].RoyalGuards[j].IsAttacked := False;
                  Servers[c].RoyalGuards[j].AttackerID := 0;
                  Servers[c].RoyalGuards[j].FirstPlayerAttacker := 0;

                  Servers[c].RoyalGuards[j].PlayerChar.LastPos := Servers[c].RoyalGuards[j].FirstPosition;

                end;

                Continue;
              end;

            except

                  on E: Exception do
                  begin
                    Logger.Write('Erro no bloco do Check Royal Guard, Erro exatamente no bloco se o guarda está morto: ' + E.Message,
                      TLogType.Warnings);
                  end;
            end;

            { Nao Foi atacado }
            if not(Servers[c].RoyalGuards[j].IsAttacked) then
            begin
                           { Verificar se tem alguém ao redor para atacar }
                for Key in ActivePlayers.Keys do
                begin

                          try
                           if Key.ServerID <> c then
                           continue;
                                  // Acessa o jogador associado à chave
                                  OtherPlayer := @Servers[Key.ServerID].Players[Key.ClientID];


                                  if not TFunctions.IsPlayerPlaying(OtherPlayer) then //verifica se o pointer existe
                                  continue;

                                  if (OtherPlayer^.Base.ChannelId <> c) or (OtherPlayer^.Account.Header.Nation = TCitizenShip.None) then //nao verifica player q tiver no canal diferente
                                  continue;

                                  if OtherPlayer^.Base.IsDead then  //se tiver morto, ignora e nem faz nada com o guarda, evitando gasto de recursos.
                                  continue;

                          except
                            on E: Exception do
                            begin
                              Logger.Write('Erro no bloco do Check Royal Guard, Erro exatamente no bloco da iteração quanto aos players 1: ' + E.Message,
                                TLogType.Warnings);
                            end;
                          end;


                          try
                           if (Byte(OtherPlayer^.Account.Header.nation) <> c+1) then
                           begin

                            if not Servers[c].RoyalGuards[j].base.VisibleMobs.Contains(key.ClientID) and OtherPlayer^.base.PlayerCharacter.LastPos.InRange(Servers[c].RoyalGuards[j].PlayerChar.LastPos, 20) then
                            begin

                              if not OtherPlayer^.base.BuffExistsInArray([153, 53, 77, 386]) then
                              begin
                                Servers[c].RoyalGuards[j].IsAttacked := True;
                                Servers[c].RoyalGuards[j].AttackerID := key.ClientID;
                                Servers[c].RoyalGuards[j].FirstPlayerAttacker := key.ClientID;
                                Servers[c].RoyalGuards[j].PlayerChar.CurrentPos := Servers[c].RoyalGuards[j].PlayerChar.LastPos;
                              end;

                              Servers[c].RoyalGuards[j].base.VisibleMobs.Add(key.ClientID);
                            end;

                            if Servers[c].RoyalGuards[j].base.VisibleMobs.Contains(key.ClientID) and not OtherPlayer^.base.PlayerCharacter.LastPos.InRange(Servers[c].RoyalGuards[j].PlayerChar.LastPos, 20) then
                            begin
                             Servers[c].RoyalGuards[j].base.VisibleMobs.Remove(key.ClientID);
                            end;


                                        //se nao tiver no range e tiver o cara no visiblemobs

                                        //se tiver no range e não conter o cara no visiblemobs, add ele

//                                          if (OtherPlayer^.base.PlayerCharacter.LastPos.InRange(Servers[c].RoyalGuards[j].PlayerChar.LastPos, 20)) then
//                                          begin
//
//
//                                            if not(Servers[c].RoyalGuards[j].base.VisibleMobs.Contains(key.ClientID)) then
//                                              Servers[c].RoyalGuards[j].base.VisibleMobs.Add(key.ClientID);
//                                          end
//                                          else
//                                          begin
//                                            if () then
//
//
//                                          end;


                           end;


                              except
                              on E: Exception do
                              begin
                                Logger.Write('Erro no bloco do Check Royal Guard, Erro exatamente no bloco da iteração quanto aos players 2: ' + 'id do guarda ' + Servers[c].RoyalGuards[j].base.ClientID.ToString +  ' msg de erro: '  + E.Message,
                                  TLogType.Warnings);
                              end;

                         	end;

                end;

              try

              if not Servers[c].RoyalGuards[j].PlayerChar.LastPos.InRange(Servers[c].RoyalGuards[j].FirstPosition, 60) then
              begin
                if not(Servers[c].RoyalGuards[j].IsAttacked) then
                begin // guarda matou player, mas não achou ninguem para atacar mais
                  Servers[c].RoyalGuards[j].PlayerChar.LastPos := Servers[c].RoyalGuards[j].FirstPosition;

                  Servers[c].RoyalGuards[j].MobMove(Servers[c].RoyalGuards[j].PlayerChar.LastPos, 70);
                end;
              end;

              if (Servers[c].RoyalGuards[j].PlayerChar.base.CurrentScore.CurHP
                < Servers[c].RoyalGuards[j].PlayerChar.base.CurrentScore.MaxHp)
              then
              begin
                inc(Servers[c].RoyalGuards[j].PlayerChar.base.CurrentScore.CurHP, 100);
              end;

              if (Servers[c].DevirGuards[j].PlayerChar.base.CurrentScore.CurHP
                > Servers[c].DevirGuards[j].PlayerChar.base.CurrentScore.MaxHp)
              then
              begin
               Servers[c].RoyalGuards[j].PlayerChar.base.CurrentScore.CurHP := Servers[c].RoyalGuards[j].PlayerChar.base.CurrentScore.MaxHp;
              end;

              try
                Servers[c].RoyalGuards[j].UpdateHPForVisibles();
              except
                on E: Exception do
                begin
                  Logger.Write('erro customizado 4' + E.Message, TLogType.Error);
                end;
              end;

              except

                  on E: Exception do
                  begin
                    Logger.Write('Erro no bloco do Check Royal Guard, Erro exatamente no bloco 1: ' + E.Message,
                      TLogType.Warnings);
                  end;
            end;
            end
            else
            begin

              try
              OtherPlayer := @Servers[c].Players[Servers[c].RoyalGuards[j].AttackerID];

              if (Servers[c].RoyalGuards[j].base.RefreshBuffs > 0) then
              begin
                Servers[c].RoyalGuards[j].base.SendRefreshBuffs;
              end;

              if not Servers[c].RoyalGuards[j].PlayerChar.LastPos.inrange(OtherPlayer^.base.PlayerCharacter.LastPos, 4) then
              begin // mover guarda para perto
                Randomize;

                Rand := Random(7);

                Servers[c].RoyalGuards[j].PlayerChar.LastPos := OtherPlayer^.base.Neighbors[Rand].pos;

                Servers[c].RoyalGuards[j].MobMove(OtherPlayer^.base.Neighbors[Rand].pos, 45);

              end
              else // atacar
              begin
                if (now >= IncSecond(Servers[c].RoyalGuards[j].LastMyAttack,
                  3)) and not(OtherPlayer^.base.BuffExistsInArray([153, 53, 77, 386]))
                then
                begin
                  if not(Servers[c].RoyalGuards[j].base.GetMobAbility
                    (EF_SKILL_STUN) = 0) then
                    Continue;
                  if not(Servers[c].RoyalGuards[j].base.GetMobAbility
                    (EF_SKILL_IMMOVABLE) = 0) then
                    Continue;
                  if not(Servers[c].RoyalGuards[j].base.GetMobAbility
                    (EF_SILENCE1) = 0) then
                    Continue;
                  if not(Servers[c].RoyalGuards[j].base.GetMobAbility
                    (EF_SILENCE2) = 0) then
                    Continue;
                  if not(Servers[c].RoyalGuards[j].base.GetMobAbility
                    (EF_SKILL_SHOCK) = 0) then
                    Continue;
                  if not(Servers[c].RoyalGuards[j].base.GetMobAbility
                    (EF_SKILL_SLEEP) = 0) then
                    Continue;

                  Servers[c].RoyalGuards[j].LastMyAttack := now;
                  Servers[c].RoyalGuards[j].AttackPlayer(OtherPlayer, MOB_GUARD_DEVIR_ATK, 0);
                end;
              end;

              if ((not Servers[c].DevirGuards[j].PlayerChar.LastPos.InRange(
                (Servers[c].DevirGuards[j].FirstPosition), 60)) or
                (OtherPlayer^.base.IsDead)) then
              begin // mover-se para a posição original zerar perseguicao
                Servers[c].DevirGuards[j].PlayerChar.LastPos :=
                  Servers[c].DevirGuards[j].FirstPosition;

                Servers[c].DevirGuards[j].IsAttacked := False;
                Servers[c].DevirGuards[j].AttackerID := 0;
                Servers[c].DevirGuards[j].FirstPlayerAttacker := 0;

                Servers[c].DevirGuards[j]
                  .MobMove(Servers[c].DevirGuards[j].PlayerChar.LastPos, 70);
              end;

              // abandonar target se ele morrer
              if (OtherPlayer^.base.IsDead) or OtherPlayer^.base.BuffExistsInArray
                ([153, 53, 77, 386]) then
              begin
                if not(Servers[c].RoyalGuards[j].PlayerChar.LastPos = Servers[c].RoyalGuards[j].FirstPosition) then
                begin
                  Servers[c].RoyalGuards[j].PlayerChar.LastPos := Servers[c].RoyalGuards[j].FirstPosition;
                  Servers[c].RoyalGuards[j].MobMove(Servers[c].RoyalGuards[j].PlayerChar.LastPos, 70);
                end;

                Servers[c].RoyalGuards[j].IsAttacked := False;
                Servers[c].RoyalGuards[j].AttackerID := 0;
                Servers[c].RoyalGuards[j].FirstPlayerAttacker := 0;
              end;
                        except

                  on E: Exception do
                  begin
                    Logger.Write('Erro no bloco do Check Royal Guard, Erro exatamente no bloco 2: ' + E.Message,
                      TLogType.Warnings);
                  end;
             end;

            end;
          end;
        end;

end;


procedure TTemplesManagmentThread.CheckGuards;
var
  i: byte;
  j: WORD;
  OtherPlayer: PPlayer;
  Rand: Integer;
  DevirName: String;
  c, did: byte;
begin
	for c:= 0 to 2 do
  begin
    for j := Low(Servers[c].DevirGuards)
      to High(Servers[c].DevirGuards) do
    begin
      if (Servers[c].DevirGuards[j].Base.IsDead) then
      begin
        // verifica o tempo de reespawn
        if ((Now >= IncSecond(Servers[c].DevirGuards[j].DeadTime,
          180))) then
        begin
          Servers[c].DevirGuards[j].Base.IsDead := FALSE;
          Servers[c].DevirGuards[j].PlayerChar.Base.CurrentScore.
            CurHP := Servers[c].DevirGuards[j]
            .PlayerChar.Base.CurrentScore.MaxHp;
          Servers[c].DevirGuards[j].IsAttacked := FALSE;
          Servers[c].DevirGuards[j].AttackerID := 0;
          Servers[c].DevirGuards[j].FirstPlayerAttacker := 0;

          did := Servers[c].DevirGuards[j]
            .GetDevirIdByStoneOrGuardId(j);

          if not(did = 255) then
          begin
            Dec(Servers[c].Devires[did].GuardsDied, 1);
          end;

          Servers[c].DevirGuards[j].PlayerChar.LastPos :=
            Servers[c].DevirGuards[j].FirstPosition;

        end;

        Continue;
      end;

      { Nao Foi atacado }
      if not(Servers[c].DevirGuards[j].IsAttacked) then
      begin
        { Verificar se tem alguém ao redor para atacar }
        for i := 1 to MAX_CONNECTIONS do
        begin
          if not (TFunctions.IsPlayerPlaying(@Servers[c].Players[i])) then
            continue;


            if (byte(Servers[c].Players[i].Account.Header.Nation) = Servers[c].DevirGuards[j].PlayerChar.Base.Nation) then
              Continue;

            if (Servers[c].Players[i].Base.PlayerCharacter.LastPos.InRange(Servers[c].DevirGuards[j].PlayerChar.LastPos, 20)) then
            begin
            if not Servers[c].Players[i].Base.BuffExistsInArray([153,53,77,386]) then
             begin
              Servers[c].DevirGuards[j].IsAttacked := True;
              Servers[c].DevirGuards[j].AttackerID := i;
              Servers[c].DevirGuards[j].FirstPlayerAttacker := i;
              Servers[c].DevirGuards[j].PlayerChar.CurrentPos :=
                Servers[c].DevirGuards[j].PlayerChar.LastPos;
             end;

              if not(Servers[c].DevirGuards[j]
                .Base.VisibleMobs.Contains(i)) then
                Servers[c].DevirGuards[j].Base.VisibleMobs.Add(i);

                if not Servers[c].Players[i].Base.BuffExistsInArray([153,53,77,386]) then
             begin

              did := Servers[c].DevirGuards[j]
                .GetDevirIdByStoneOrGuardId(j);

              if not(did = 255) then
              begin
                //System.AnsiStrings.StrPLCopy(DevirName, String(Servers[c].DevirNpc[did]
                  //.PlayerChar.Base.PranName[0]), sizeof(String(Servers[c].DevirNpc[did]
                  //.PlayerChar.Base.PranName[0])));

                DevirName := Servers[c].DevirNpc[did+3335].DevirName; //talvez esteja dando erro pois ele não consegue acessar um array dentro de outro array

                Servers[c].SendServerMsgForNation
                  ('O Totem de ' + AnsiString(DevirName) + ' está sob ameaça.',
                  Servers[c].NationID);
              end;
             end;
            end
            else
            begin
              if (Servers[c].DevirGuards[j]
                .Base.VisibleMobs.Contains(i)) then
                Servers[c].DevirGuards[j].Base.VisibleMobs.Remove(i);

            end;
        end;

        if not (Servers[c].DevirGuards[j].PlayerChar.LastPos.InRange(servers[c].DevirGuards[j].FirstPosition, 60)) then
        begin
          if not(Servers[c].DevirGuards[j].IsAttacked) then
          begin // guarda matou player, mas não achou ninguem para atacar mais
            Servers[c].DevirGuards[j].PlayerChar.LastPos :=
              Servers[c].DevirGuards[j].FirstPosition;

            Servers[c].DevirGuards[j]
              .MobMove(Servers[c].DevirGuards[j]
              .PlayerChar.LastPos, 70);
          end;
        end;

        if (Servers[c].DevirGuards[j].PlayerChar.Base.CurrentScore.
          CurHP < Servers[c].DevirGuards[j]
          .PlayerChar.Base.CurrentScore.MaxHp) then
        begin
          Servers[c].DevirGuards[j].PlayerChar.Base.CurrentScore.
            CurHP := Servers[c].DevirGuards[j]
            .PlayerChar.Base.CurrentScore.CurHP + 100;
        end;

        if (Servers[c].DevirGuards[j].PlayerChar.Base.CurrentScore.
          CurHP > Servers[c].DevirGuards[j]
          .PlayerChar.Base.CurrentScore.MaxHp) then
        begin
          Servers[c].DevirGuards[j].PlayerChar.Base.CurrentScore.
            CurHP := Servers[c].DevirGuards[j]
            .PlayerChar.Base.CurrentScore.MaxHp;
        end;

        try
          //Servers[c].DevirGuards[j].UpdateHPForVisibles();
        except

        end;
      end
      else
      begin
        OtherPlayer := @Servers[c].Players
          [Servers[c].DevirGuards[j].AttackerID];

        if (Servers[c].DevirGuards[j].Base.RefreshBuffs > 0) then
        begin
          Servers[c].DevirGuards[j].Base.SendRefreshBuffs;
        end;

        if not (Servers[c].DevirGuards[j].PlayerChar.LastPos.InRange((OtherPlayer^.Base.PlayerCharacter.LastPos), 4)) then
        begin // mover guarda para perto
          Randomize;

          Rand := Random(7);

          Servers[c].DevirGuards[j].PlayerChar.LastPos :=
            OtherPlayer^.Base.Neighbors[Rand].pos;

          Servers[c].DevirGuards[j]
            .MobMove(Servers[c].DevirGuards[j]
            .PlayerChar.LastPos, 45);
        end
        else // atacar
        begin
          if (Now >= IncSecond(Servers[c].DevirGuards[j]
            .LastMyAttack, 3)) and not (OtherPlayer.Base.BuffExistsInArray([153,53,77,386])) then
          begin
            if not(Servers[c].DevirGuards[j].Base.GetMobAbility(EF_SKILL_STUN) = 0) then
              Continue;
            if not(Servers[c].DevirGuards[j].Base.GetMobAbility(EF_SKILL_IMMOVABLE) = 0) then
              Continue;
            if not(Servers[c].DevirGuards[j].Base.GetMobAbility(EF_SILENCE1) = 0) then
              Continue;
            if not(Servers[c].DevirGuards[j].Base.GetMobAbility(EF_SILENCE2) = 0) then
              Continue;
            if not(Servers[c].DevirGuards[j].Base.GetMobAbility(EF_SKILL_SHOCK) = 0) then
              Continue;
            if not(Servers[c].DevirGuards[j].Base.GetMobAbility(EF_SKILL_SLEEP) = 0) then
              Continue;

            Servers[c].DevirGuards[j].LastMyAttack := Now;
            Servers[c].DevirGuards[j].AttackPlayer(OtherPlayer,
              MOB_GUARD_DEVIR_ATK, 0);
          end;
        end;

        if not ((Servers[c].DevirGuards[j].PlayerChar.LastPos.InRange((Servers[c].DevirGuards[j].FirstPosition), 60)) or (
          OtherPlayer^.Base.IsDead)) then
        begin // mover-se para a posição original zerar perseguicao
          Servers[c].DevirGuards[j].PlayerChar.LastPos :=
            Servers[c].DevirGuards[j].FirstPosition;

          Servers[c].DevirGuards[j].IsAttacked := FALSE;
          Servers[c].DevirGuards[j].AttackerID := 0;
          Servers[c].DevirGuards[j].FirstPlayerAttacker := 0;

          Servers[c].DevirGuards[j]
            .MobMove(Servers[c].DevirGuards[j]
            .PlayerChar.LastPos, 70);
        end;

        // abandonar target se ele morrer
        if (OtherPlayer.Base.IsDead)or OtherPlayer.Base.BuffExistsInArray([153,53,77,386]) then
        begin
        if not ( Servers[c].DevirGuards[j].PlayerChar.LastPos = Servers[c].DevirGuards[j].FirstPosition)  then
          begin
           Servers[c].DevirGuards[j].PlayerChar.LastPos :=
           Servers[c].DevirGuards[j].FirstPosition;
           Servers[c].DevirGuards[j].MobMove(Servers[c].DevirGuards[j]
             .PlayerChar.LastPos, 70);
          end;

          Servers[c].DevirGuards[j].IsAttacked := FALSE;
          Servers[c].DevirGuards[j].AttackerID := 0;
          Servers[c].DevirGuards[j].FirstPlayerAttacker := 0;
        end;
      end;
    end;
  end;
end;

procedure TTemplesManagmentThread.CheckStones;
var

  j, i, k, Rand: Integer;

  StonesIds: TIdsArray;




  c, did: byte; //canal
  key: TPlayerKey;
  OtherPlayer: PPlayer;
begin
  for c := 0 to 2 do
  begin
    for j := Low(Servers[c].DevirStones)
      to High(Servers[c].DevirStones) do
    begin
      if (Servers[c].DevirStones[j].base.IsDead) then
      begin
        did := Servers[c].DevirStones[j]
          .GetDevirIdByStoneOrGuardId(j);

        if (did = 255) then
        begin
          Continue;
        end;

        if not(Servers[c].Devires[did].IsOpen) then
        begin
          if (Servers[c].Devires[did].StonesDied >= 3) and
            (Servers[c].Devires[did].CollectedReliquare) then
          begin // fechar o templo que estava aberto
            Servers[c].Devires[did].StonesDied := 0;
            Servers[c].Devires[did].GuardsDied := 0;

            Servers[c].Devires[did].IsOpen := False;

            StonesIds := Servers[c].GetTheStonesFromDevir(did);

            for k := 0 to 2 do
            begin
              Servers[c].DevirStones[StonesIds[k]]
                .base.IsDead := False;
              Servers[c].DevirStones[StonesIds[k]]
                .PlayerChar.base.CurrentScore.CurHP := Servers[c]
                .DevirStones[StonesIds[k]].PlayerChar.base.CurrentScore.MaxHp;
              Servers[c].DevirStones[StonesIds[k]]
                .IsAttacked := False;
              Servers[c].DevirStones[StonesIds[k]].AttackerID := 0;
              Servers[c].DevirStones[StonesIds[k]]
                .FirstPlayerAttacker := 0;


            end;
          end
          else
          begin // renascer a pedra
            if (Servers[c].Devires[did].StonesDied >= 1) then
            begin
              if (now >= IncSecond(Servers[c].DevirStones[j]
                .DeadTime, 10)) then
              begin
                Servers[c].DevirStones[j].base.IsDead := False;
                Servers[c].DevirStones[j]
                  .PlayerChar.base.CurrentScore.CurHP := Servers[c]
                  .DevirStones[j].PlayerChar.base.CurrentScore.MaxHp;
                Servers[c].DevirStones[j].IsAttacked := False;
                Servers[c].DevirStones[j].AttackerID := 0;
                Servers[c].DevirStones[j].FirstPlayerAttacker := 0;

                Servers[c].Devires[did].StonesDied :=
                  Servers[c].Devires[did].StonesDied - 1;

              end;
            end;
          end;
        end;

        Continue;
      end;

      { Nao Foi atacado }
      if not(Servers[c].DevirStones[j].IsAttacked) then
      begin
        { Verificar se tem alguém ao redor para atacar }

        for Key in ActivePlayers.Keys do
        begin
        if Key.ServerID <> c then
        continue;
          // Acessa o jogador associado à chave
          OtherPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(OtherPlayer) then
            continue;

            if (Integer(OtherPlayer^.Account.Header.nation) = Servers[c].DevirStones[j].PlayerChar.base.nation) then
              Continue;

              if (OtherPlayer^.base.PlayerCharacter.LastPos.InRange(Servers[c].DevirStones[j].PlayerChar.LastPos, 20)) then
            begin
              if (OtherPlayer^.base.IsDead) then
                Continue;

              if (Servers[c].DevirStones[j].IsAttacked = False)
              then
              begin
                if not OtherPlayer^.base.BuffExistsInArray
                  ([153, 53, 77, 386]) then
                begin
                  Servers[c].DevirStones[j].IsAttacked := True;
                  Servers[c].DevirStones[j].AttackerID := Key.ClientID;
                  Servers[c].DevirStones[j].FirstPlayerAttacker := Key.ClientID;
                  Servers[c].DevirStones[j].PlayerChar.CurrentPos := Servers[c].DevirStones[j].PlayerChar.LastPos;
                end;
              end;

              if not(Servers[c].DevirStones[j]
                .base.VisibleMobs.Contains(key.ClientID)) then
                Servers[c].DevirStones[j].base.VisibleMobs.Add(key.ClientID);
            end
            else
            begin
              if (Servers[c].DevirStones[j]
                .base.VisibleMobs.Contains(key.ClientID)) then
                Servers[c].DevirStones[j]
                  .base.VisibleMobs.Remove(key.ClientID);

            end;


	      end;

        if (Servers[c].DevirStones[j].PlayerChar.base.CurrentScore.
          CurHP < Servers[c].DevirStones[j]
          .PlayerChar.base.CurrentScore.MaxHp) then
        begin
          Servers[c].DevirStones[j].PlayerChar.base.CurrentScore.
            CurHP := Servers[c].DevirStones[j]
            .PlayerChar.base.CurrentScore.CurHP + 100;
        end;

        if (Servers[c].DevirStones[j].PlayerChar.base.CurrentScore.
          CurHP > Servers[c].DevirStones[j]
          .PlayerChar.base.CurrentScore.MaxHp) then
        begin
          Servers[c].DevirStones[j].PlayerChar.base.CurrentScore.
            CurHP := Servers[c].DevirStones[j]
            .PlayerChar.base.CurrentScore.MaxHp;
        end;

        try
          Servers[c].DevirStones[j].UpdateHPForVisibles();
        except
          on E: Exception do
          begin
            Logger.Write('erro ao dar update no hp ' + E.Message,
              TLogType.Error);
          end;
        end;

      end
      else
      begin
        OtherPlayer := @Servers[c].Players
          [Servers[c].DevirStones[j].AttackerID];

        if (Servers[c].DevirStones[j].base.RefreshBuffs > 0) then
        begin
          Servers[c].DevirStones[j].base.SendRefreshBuffs;
        end;

        if ((not Servers[c].DevirStones[j].PlayerChar.LastPos.InRange(
          (OtherPlayer^.base.PlayerCharacter.LastPos), 15)) or
          (OtherPlayer^.base.IsDead)) or OtherPlayer^.base.BuffExistsInArray
          ([153, 53, 77, 386]) then
        begin // resetar para atacar outro
          Servers[c].DevirStones[j].IsAttacked := False;
          Servers[c].DevirStones[j].AttackerID := 0;
          Servers[c].DevirStones[j].FirstPlayerAttacker := 0;
        end
        else // atacar
        begin
          if (now >= IncSecond(Servers[c].DevirStones[j]
            .LastMyAttack, 3)) then
          begin
            if not(Servers[c].DevirStones[j].base.GetMobAbility
              (EF_SKILL_STUN) = 0) then
              Continue;
            if not(Servers[c].DevirStones[j].base.GetMobAbility
              (EF_SKILL_IMMOVABLE) = 0) then
              Continue;
            if not(Servers[c].DevirStones[j].base.GetMobAbility
              (EF_SILENCE1) = 0) then
              Continue;
            if not(Servers[c].DevirStones[j].base.GetMobAbility
              (EF_SILENCE2) = 0) then
              Continue;
            if not(Servers[c].DevirStones[j].base.GetMobAbility
              (EF_SKILL_SHOCK) = 0) then
              Continue;
            if not(Servers[c].DevirStones[j].base.GetMobAbility
              (EF_SKILL_SLEEP) = 0) then
              Continue;
            Servers[c].DevirStones[j].LastMyAttack := now;
            Servers[c].DevirStones[j].AttackPlayer(OtherPlayer,
              MOB_STONE_DEVIR_ATK, 6465);
          end;
        end;

        if (OtherPlayer^.base.IsDead or OtherPlayer^.base.BuffExistsInArray([153,
          53, 77, 386])) then
        begin
          Servers[c].DevirStones[j].IsAttacked := False;
          Servers[c].DevirStones[j].AttackerID := 0;
          Servers[c].DevirStones[j].FirstPlayerAttacker := 0;
        end;
      end;
    end;
  end;
end;

procedure TTemplesManagmentThread.CheckReliques();
var
  checked: Boolean;
  xPacket: TSendRemoveMobPacket;
  MPlayer, OtherPlayer: PPlayer;
  DevirSlots: PDevirSlot;
  xPOBJ: POBJ;
  xrlkslot, c, i, j, k, l, m: byte;
  o: word;

  key: TPlayerKey;
begin
  for c := 0 to 2 do
  begin
      for i := 0 to 4 do
        for j := 0 to 4 do
        begin
          DevirSlots := @Servers[c].Devires[i].Slots[j];
          if DevirSlots^.Furthed and (SecondsBetween(Now, IncHour(DevirSlots^.TimeFurthed, -3)) >= 1200) then
          begin
            checked := False;
            DevirSlots^.ItemID := DevirSlots^.ItemFurthed;
            DevirSlots^.App := DevirSlots^.ItemID;
            DevirSlots^.TimeToEstabilish := DevirSlots^.TimeFurthed;
            DevirSlots^.Furthed := False;

            for k := 0 to 2 do
            begin

              for Key in ActivePlayers.Keys do
              begin


                    if key.ServerID <> k then
                    continue;

                      // Acessa o jogador associado à chave
                      OtherPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

                  if not TFunctions.IsPlayerPlaying(OtherPlayer) then
                      continue;

                  xrlkslot := TItemFunctions.GetItemSlot2(OtherPlayer^, DevirSlots^.ItemID);
                  if xrlkslot <> 255 then
                  begin
                    ZeroMemory(@OtherPlayer^.base.character.inventory[xrlkslot], SizeOf(TItem));
                    OtherPlayer^.base.SendRefreshItemSlot(INV_TYPE, xrlkslot, OtherPlayer^.base.character.inventory[xrlkslot], False);
                    OtherPlayer^.base.SendEffect(0);
                    Servers[c].SendServerMsg('O tesouro sagrado [' + AnsiString(ItemList[DevirSlots^.ItemID].name) + '] foi retornado ao templo.');
                    Servers[c].SaveTemplesDB(OtherPlayer);
                    Inc(Servers[c].ReliqEffect[ItemList[DevirSlots^.ItemID].EF[0]], ItemList[DevirSlots^.ItemID].EFV[0]);
                    Servers[c].UpdateReliquaresForAll;
                    checked := True;
                    Break;
                  end;
             	end;

              if checked then Break;
            end;

            if not checked then
            begin
              for k := 0 to 2 do
                for o := Low(Servers[k].OBJ) to High(Servers[k].OBJ) do
                begin
                  xPOBJ := @Servers[k].OBJ[o];
                  if (xPOBJ^.ContentItemID = DevirSlots^.ItemID) then
                  begin
                    ZeroMemory(@xPacket, SizeOf(xPacket));
                    with xPacket.Header do
                    begin
                      Size := SizeOf(xPacket);
                      Index := $7535;
                      Code := $101;
                    end;
                    xPacket.Index := xPOBJ^.Index;
                    ZeroMemory(xPOBJ, SizeOf(xPOBJ^));


                    for Key in ActivePlayers.Keys do
                    begin
                    if Key.ServerID <> k then
                    continue;

                            // Acessa o jogador associado à chave
                            OtherPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

                            if not TFunctions.IsPlayerPlaying(OtherPlayer) then
                            continue;

                            OtherPlayer^.SendPacket(xPacket, xPacket.Header.Size);
                            if OtherPlayer^.base.VisibleMobs.Contains(xPacket.Index) then
                              OtherPlayer^.base.VisibleMobs.Remove(xPacket.Index);




	                  end;

                    Servers[c].SendServerMsg('O tesouro sagrado [' + AnsiString(ItemList[DevirSlots^.ItemID].name) + '] foi retornado ao templo.');
                    Servers[c].SaveTemplesDB(MPlayer);
                    Inc(Servers[c].ReliqEffect[ItemList[DevirSlots^.ItemID].EF[0]], ItemList[DevirSlots^.ItemID].EFV[0]);
                    Servers[c].UpdateReliquaresForAll;
                    Break;
                  end;
                end;
            end;
          end;
        end;
  end;
end;

{$ENDREGION}
{$REGION 'Auction Offers System'}

constructor TAuctionOffersThread.Create(SleepTime: Integer);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;

  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TAuctionOffersThread.Execute;
begin
  while not(xServerClosed) do
  begin
    Self.CheckOffers();

    sleep(Self.FDelay);
  end;
end;

procedure TAuctionOffersThread.CheckOffers();
var
  QueryString: string;
  i: Integer;
  MySQLQuery: TQuery;
begin



  MySQLQuery :=  TFunctions.CreateSQL;
  QueryString := 'SELECT AuctionId, CharacterId FROM vwauction_getactiveoffers WHERE NOW() > ExpireDate;';

  MySQLQuery.SetQuery(QueryString);
  MySQLQuery.Run();

  if (MySQLQuery.Query.RecordCount = 0) then
  begin
    MySQLQuery.Free;
    exit;
  end;

  for i := 0 to MySQLQuery.Query.RecordCount - 1 do
  begin
    Self.ReturnOffer(MySQLQuery.Query.FieldByName('CharacterId').AsLargeInt,
      MySQLQuery.Query.FieldByName('AuctionId').AsLargeInt);
    MySQLQuery.Query.Next;
  end;

  MySQLQuery.Free;
end;

function TAuctionOffersThread.ReturnOffer(CharacterId: UInt64;
  AuctionId: UInt64): Boolean;
var
  QueryString: string;
  ReturnMailId, ReturnMailItemId: UInt64;
begin
  Result := True;
  ReturnMailId := 0;
  ReturnMailItemId := 0;

  try
    if not(Self.RegisterReturnMail(CharacterId, AuctionId, ReturnMailId)) then
    begin
      Self.FQuery.Destroy;
      exit(False);
    end;

    Self.FQuery := TFunctions.CreateSQL;

    QueryString :=
      Format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, effect1_index, effect1_value, '
      + 'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, `time`) '
      + 'SELECT %d AS MailIndex, 0, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, EffectValue_1, EffectId_2, EffectValue_2, '
      + 'EffectId_3, EffectValue_3, DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime '
      + 'FROM vwauction_getactiveoffers WHERE AuctionId=%d; UPDATE auction SET Active=0 WHERE AuctionId=%d;',
      [ReturnMailId, AuctionId, AuctionId]);

    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Query.Connection.StartTransaction;
    Self.FQuery.Run(False);
    Self.FQuery.Query.Connection.Commit;

    if (Self.FQuery.Query.RowsAffected = 0) then
    begin
      Self.FQuery.Destroy;
      exit(False);
    end;

    QueryString := 'SELECT max(id) as idx from mails_items;';
    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Run;

    if (Self.FQuery.Query.RecordCount = 0) then
    begin
      Self.FQuery.Destroy;
      exit(False);
    end;

    ReturnMailItemId := Self.FQuery.Query.FieldByName('idx').AsLargeInt;

    if ReturnMailItemId = 0 then
    begin
      Self.FQuery.Destroy;
      exit(False);
    end;

    if not(Self.CloseOffer(AuctionId)) then
    begin
      Self.FQuery.Destroy;
      exit(False);
    end;
  except
    begin
      Self.FQuery.Destroy;
      Result := False;
    end;
  end;
end;

function TAuctionOffersThread.RegisterReturnMail(CharacterId: UInt64;
  AuctionId: UInt64; OUT MailIndex: UInt64): Boolean;
var
  QueryString: string;
begin
  Result := True;

  Self.FQuery :=  TFunctions.CreateSQL;
  try
    QueryString :=
      Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, '
      + 'textBody, slot, sentGold, gold, returnDate, ' +
      'sentDate, isFromAuction, canReturn, hasItems) VALUES (%d, 1, "Casa de Leilões", '
      + '"Item retornou", "Entrega de item expirado da casa de leilões", 0, ' +
      '0, 0, "%s", "%s", 1, 0, 1);',
      [CharacterId, FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(now, 90)),
      FormatDateTime('yyyy-mm-dd hh:nn:ss', now)]);

    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Query.Connection.StartTransaction;
    Self.FQuery.Run(False);
    Self.FQuery.Query.Connection.Commit;

    if (Self.FQuery.Query.RowsAffected = 0) then
      exit(False);

    QueryString := 'SELECT max(id) as idx from mails;';
    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Run();

    MailIndex := UInt64(Self.FQuery.Query.FieldByName('idx').AsLargeInt);

    if MailIndex = 0 then
      exit(False);

  except
    Result := False;
  end;

  Self.FQuery.Destroy;
end;

function TAuctionOffersThread.CloseOffer(AuctionId: UInt64): Boolean;
var
  QueryString: string;
begin
  Result := True;

  Self.FQuery := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);

  try
    QueryString :=
      Format('UPDATE auction SET Active = 0 WHERE AuctionId=%d LIMIT 1',
      [AuctionId]);

    Self.FQuery.SetQuery(QueryString);
    Self.FQuery.Query.Connection.StartTransaction;
    Self.FQuery.Run(False);
    Self.FQuery.Query.Connection.Commit;

    if Self.FQuery.Query.RowsAffected = 0 then
      Result := False;
  except
    Result := False;
  end;

  Self.FQuery.Destroy;
end;

{$ENDREGION}
{$REGION 'Castle Siege System'}

constructor TCastleSiegeThread.Create(SleepTime: Integer; ChannelId: BYTE);
begin
  Self.FDelay := SleepTime;
  Self.FreeOnTerminate := True;
  Self.FChannelID := ChannelId;

  inherited Create(False);
  Self.Priority := tpLower;
end;

procedure TCastleSiegeThread.Execute;
var
  Server: PServerSocket;
  CastleSiege: PCastleSiege;
begin
  Server := @Servers[FChannelID];
  CastleSiege := @Server.CastleSiegeHandler;

  CastleSiege.WarTimeInit := now;

  while (CastleSiege.WarInProgress) do
  begin
    CheckCastleOrbs(CastleSiege);
    CountOrbsHolding(CastleSiege);
    CheckMarshallSeal(CastleSiege);
    UpdateSiegeStatus(CastleSiege);

    TThread.sleep(FDelay);
  end;
end;

procedure TCastleSiegeThread.CheckCastleOrbs(CastleSiege: PCastleSiege);
var
  i: Integer;
  Player: PPlayer;
begin
  for i := 0 to 2 do
  begin
    Player := CastleSiege.OrbHolder[i];

    if (CastleSiege.OrbHolder[i] = nil) then
      Continue;

    if not(Player.base.IsActive) then
    begin
      RemoveOrbHolder(CastleSiege, i);
    end;

    if (Player.base.IsDead) then
    begin
      RemoveOrbHolder(CastleSiege, i);
    end;

    if (secondsBetween(Player.base.LastReceivedSkillFromCastle, now) <= 3) then
    begin
      RemoveOrbHolder(CastleSiege, i);
    end;

    case i of
      0:
        begin
          if not(Player.base.PlayerCharacter.LastPos.InRange
            (TPosition.Create(3551, 2759), 1)) then
          begin
            RemoveOrbHolder(CastleSiege, i);
          end;
        end;
      1:
        begin
          if not(Player.base.PlayerCharacter.LastPos.InRange
            (TPosition.Create(3616, 2759), 1)) then
          begin
            RemoveOrbHolder(CastleSiege, i);
          end;
        end;
      2:
        begin
          if not(Player.base.PlayerCharacter.LastPos.InRange
            (TPosition.Create(3584, 2860), 1)) then
          begin
            RemoveOrbHolder(CastleSiege, i);
          end;
        end;
    end;
  end;
end;

procedure TCastleSiegeThread.RemoveOrbHolder(CastleSiege: PCastleSiege;
  OrbIndex: BYTE);
begin
  if (SiegeStatus = TSiegeStatus.OrbsHolded) then
  begin
    SiegeStatus := TSiegeStatus.Running;
  end;

  if (SiegeStatus = TSiegeStatus.Sealing) then
  begin
    if (CastleSiege.OrbsHolded = 3) then
    begin
      SiegeStatus := TSiegeStatus.OrbsHolded;
    end
    else
    begin
      SiegeStatus := TSiegeStatus.Running;
    end;
  end;

  CastleSiege.OrbHolder[OrbIndex].SendSignal($7535, $33A);
  CastleSiege.OrbHolder[OrbIndex] := nil;
end;

procedure TCastleSiegeThread.CountOrbsHolding(CastleSiege: PCastleSiege);
var
  i: Integer;
  OrbsHolded: Integer;
  Player: PPlayer;
begin
  OrbsHolded := 0;

  for i := 0 to 2 do
  begin
    if not(CastleSiege.OrbHolder[i] = nil) then
    begin
      inc(OrbsHolded);
    end;
  end;

  if (SiegeStatus >= TSiegeStatus.Sealing) then
  begin
    if (CastleSiege.SealHolder <> nil) then
      SiegeStatus := TSiegeStatus.Sealing;
  end;

  CastleSiege.OrbsHolded := OrbsHolded;
end;

procedure TCastleSiegeThread.CheckMarshallSeal(CastleSiege: PCastleSiege);
var
  Player: PPlayer;
begin
  if (SiegeStatus < TSiegeStatus.Sealing) then
    exit;

  Player := CastleSiege.SealHolder;

  if not(Player.base.IsActive) then
  begin
    RemoveSealHolder(CastleSiege);
  end;

  if (Player.base.IsDead) then
  begin
    RemoveSealHolder(CastleSiege);
  end;

  if (secondsBetween(Player.base.LastReceivedSkillFromCastle, now) <= 3) then
  begin
    RemoveSealHolder(CastleSiege);
  end;

  if not(Player.base.PlayerCharacter.LastPos.InRange(TPosition.Create(3584,
    2804.75), 3)) then
  begin
    RemoveSealHolder(CastleSiege);
  end;
end;

procedure TCastleSiegeThread.RemoveSealHolder(CastleSiege: PCastleSiege);
begin
  if (SiegeStatus = TSiegeStatus.OrbsHolded) then
  begin
    SiegeStatus := TSiegeStatus.Running;
  end;

  if (SiegeStatus = TSiegeStatus.Sealing) then
  begin
    if (CastleSiege.OrbsHolded = 3) then
    begin
      SiegeStatus := TSiegeStatus.OrbsHolded;
    end
    else
    begin
      SiegeStatus := TSiegeStatus.Running;
    end;
  end;

  CastleSiege.SealHolder.SendSignal($7535, $33A);
  CastleSiege.SealHolder := nil;
  CastleSiege.SealBeingHold := False;
end;

procedure TCastleSiegeThread.UpdateSiegeStatus(CastleSiege: PCastleSiege);
var
  TempGuild, xGuild, OtherGuild1, OtherGuild2, OtherGuild3: PGuild;
  i, j, k: Integer;
  AnotherPlayer: PPlayer;
  OldAlliance: TGuildAlly;
begin
  xGuild := nil;
  OtherGuild1 := nil;
  OtherGuild2 := nil;
  OtherGuild3 := nil;
  TempGuild := nil;
  ZeroMemory(@OldAlliance, sizeof(TGuildAlly));

  if (MinutesBetween(CastleSiege.WarTimeInit, now) >= 60) then
  begin
    Move(Nations[Servers[FChannelID].NationID - 1].Cerco.Defensoras,
      OldAlliance, sizeof(TGuildAlly));

    for i := 0 to 3 do
    begin
      if (String(Nations[Servers[FChannelID].NationID - 1].Cerco.Atacantes[i]
        .LordMarechal) <> '') then
      begin
        for j := 0 to 127 do
        begin
          TempGuild := @Guilds
            [Servers[FChannelID].GetGuildSlotByID(Servers[FChannelID]
            .GetGuildByName(String(Nations[Servers[FChannelID].NationID - 1]
            .Cerco.Atacantes[i].LordMarechal)))];

          if (TempGuild.Members[j].Logged) then
          begin
            if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j]
              .CharIndex, AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou e não há vencedores.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;
      if (String(Nations[Servers[FChannelID].NationID - 1].Cerco.Atacantes[i]
        .Estrategista) <> '') then
      begin
        for j := 0 to 127 do
        begin
          TempGuild := @Guilds
            [Servers[FChannelID].GetGuildSlotByID(Servers[FChannelID]
            .GetGuildByName(String(Nations[Servers[FChannelID].NationID - 1]
            .Cerco.Atacantes[i].Estrategista)))];

          if (TempGuild.Members[j].Logged) then
          begin
            if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j]
              .CharIndex, AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou e não há vencedores.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;
      if (String(Nations[Servers[FChannelID].NationID - 1].Cerco.Atacantes[i]
        .Juiz) <> '') then
      begin
        for j := 0 to 127 do
        begin
          TempGuild := @Guilds
            [Servers[FChannelID].GetGuildSlotByID(Servers[FChannelID]
            .GetGuildByName(String(Nations[Servers[FChannelID].NationID - 1]
            .Cerco.Atacantes[i].Juiz)))];

          if (TempGuild.Members[j].Logged) then
          begin
            if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j]
              .CharIndex, AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou e não há vencedores.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;
      if (String(Nations[Servers[FChannelID].NationID - 1].Cerco.Atacantes[i]
        .Tesoureiro) <> '') then
      begin
        for j := 0 to 127 do
        begin
          TempGuild := @Guilds
            [Servers[FChannelID].GetGuildSlotByID(Servers[FChannelID]
            .GetGuildByName(String(Nations[Servers[FChannelID].NationID - 1]
            .Cerco.Atacantes[i].Tesoureiro)))];

          if (TempGuild.Members[j].Logged) then
          begin
            if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[j]
              .CharIndex, AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou e não há vencedores.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;
    end;

    ZeroMemory(@Nations[Servers[FChannelID].NationID - 1].Cerco.Atacantes,
      sizeof(Nations[Servers[FChannelID].NationID - 1].Cerco.Atacantes));

    if (OldAlliance.Guilds[0].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds
          [Servers[FChannelID].GetGuildSlotByID(OldAlliance.Guilds[0].Index)];

        if (TempGuild.Members[i].Logged) then
        begin
          if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i]
            .CharIndex, AnotherPlayer)) then
          begin
            AnotherPlayer.SendGuildInfo;
            AnotherPlayer.SendClientMessage
              ('A guerra acabou e não há vencedores.');

            AnotherPlayer.SendNationInformation;
            AnotherPlayer.base.GetCurrentScore;
            AnotherPlayer.base.SendRefreshPoint;
            AnotherPlayer.base.SendStatus;
            AnotherPlayer.base.SendRefreshLevel;
            AnotherPlayer.base.SendCurrentHPMP();

            if (AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
            else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

            AnotherPlayer.base.InClastleVerus := False;
          end;
        end;
      end;
    end;
    if (OldAlliance.Guilds[1].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds
          [Servers[FChannelID].GetGuildSlotByID(OldAlliance.Guilds[1].Index)];

        if (TempGuild.Members[i].Logged) then
        begin
          if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i]
            .CharIndex, AnotherPlayer)) then
          begin
            AnotherPlayer.SendGuildInfo;
            AnotherPlayer.SendClientMessage
              ('A guerra acabou e não há vencedores.');

            AnotherPlayer.SendNationInformation;
            AnotherPlayer.base.GetCurrentScore;
            AnotherPlayer.base.SendRefreshPoint;
            AnotherPlayer.base.SendStatus;
            AnotherPlayer.base.SendRefreshLevel;
            AnotherPlayer.base.SendCurrentHPMP();

            if (AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
            else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

            AnotherPlayer.base.InClastleVerus := False;
          end;
        end;
      end;
    end;
    if (OldAlliance.Guilds[2].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds
          [Servers[FChannelID].GetGuildSlotByID(OldAlliance.Guilds[2].Index)];

        if (TempGuild.Members[i].Logged) then
        begin
          if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i]
            .CharIndex, AnotherPlayer)) then
          begin
            AnotherPlayer.SendGuildInfo;
            AnotherPlayer.SendClientMessage
              ('A guerra acabou e não há vencedores.');

            AnotherPlayer.SendNationInformation;
            AnotherPlayer.base.GetCurrentScore;
            AnotherPlayer.base.SendRefreshPoint;
            AnotherPlayer.base.SendStatus;
            AnotherPlayer.base.SendRefreshLevel;
            AnotherPlayer.base.SendCurrentHPMP();

            if (AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
            else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

            AnotherPlayer.base.InClastleVerus := False;
          end;
        end;
      end;
    end;
    if (OldAlliance.Guilds[3].Index <> 0) then
    begin
      for i := 0 to 127 do
      begin
        TempGuild := @Guilds
          [Servers[FChannelID].GetGuildSlotByID(OldAlliance.Guilds[3].Index)];

        if (TempGuild.Members[i].Logged) then
        begin
          if (Servers[FChannelID].GetPlayerByCharIndex(TempGuild.Members[i]
            .CharIndex, AnotherPlayer)) then
          begin
            AnotherPlayer.SendGuildInfo;
            AnotherPlayer.SendClientMessage
              ('A guerra acabou e não há vencedores.');

            AnotherPlayer.SendNationInformation;
            AnotherPlayer.base.GetCurrentScore;
            AnotherPlayer.base.SendRefreshPoint;
            AnotherPlayer.base.SendStatus;
            AnotherPlayer.base.SendRefreshLevel;
            AnotherPlayer.base.SendCurrentHPMP();

            if (AnotherPlayer.SavedPos.IsValid) then
              AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
            else
              AnotherPlayer.Teleport(TPosition.Create(3450, 690));

            AnotherPlayer.base.InClastleVerus := False;
          end;
        end;
      end;
    end;

    Nations[Servers[FChannelID].NationID - 1].SaveNation;

    for i := 1 to High(Servers[FChannelID].Players) do
    begin
      AnotherPlayer := @Servers[FChannelID].Players[i];

      if (AnotherPlayer.Status < PLAYING) then
        Continue;

      AnotherPlayer.SendNationInformation;

      AnotherPlayer.SendClientMessage
        ('A guerra de castelo foi finalizada. A liderança atual conseguiu sustentar seu poder.');
    end;

    for i := 0 to 2 do
    begin
      Self.RemoveOrbHolder(CastleSiege, i);
    end;
    CastleSiege.WarInProgress := False;
    CastleSiege.OrbHolder[0] := nil;
    CastleSiege.OrbHolder[1] := nil;
    CastleSiege.OrbHolder[2] := nil;
    CastleSiege.SealHolder := nil;
    exit;
  end;

  if (CastleSiege.OrbsHolded < 3) then
  begin
    SiegeStatus := TSiegeStatus.Running;
    exit;
  end;

  if not(CastleSiege.SealBeingHold) then
  begin
    SiegeStatus := TSiegeStatus.OrbsHolded;
    exit;
  end;

  SiegeStatus := TSiegeStatus.Sealing;
  CastleSiege.SealHoldingSeconds :=
    secondsBetween(CastleSiege.SealHoldingStart, now);

  Servers[FChannelID].SendServerMsg('Selo do Marechal: ' +
    (120 - CastleSiege.SealHoldingSeconds).ToString + ' seg. restantes.',
    32, 16, 32);

  if (CastleSiege.SealHoldingSeconds >= 120) then
  begin
    Move(Nations[CastleSiege.SealHolder.base.character.nation - 1]
      .Cerco.Defensoras, OldAlliance, sizeof(TGuildAlly));

    xGuild := @Guilds[CastleSiege.SealHolder.character.GuildSlot];

    if (xGuild.Index > 0) then
    begin
      if (xGuild.Ally.Guilds[1].Index > 0) then
      begin
        OtherGuild1 := @Guilds
          [Servers[FChannelID].GetGuildSlotByID(xGuild.Ally.Guilds[1].Index)];
      end;

      if (xGuild.Ally.Guilds[2].Index > 0) then
      begin
        OtherGuild2 := @Guilds
          [Servers[FChannelID].GetGuildSlotByID(xGuild.Ally.Guilds[2].Index)];
      end;

      if (xGuild.Ally.Guilds[3].Index > 0) then
      begin
        OtherGuild3 := @Guilds
          [Servers[FChannelID].GetGuildSlotByID(xGuild.Ally.Guilds[3].Index)];
      end;

      Nations[CastleSiege.SealHolder.base.character.nation - 1].MarechalGuildID
        := xGuild.Index;
      System.AnsiStrings.StrPLCopy
        (Nations[CastleSiege.SealHolder.base.character.nation - 1]
        .Cerco.Defensoras.LordMarechal, String(xGuild.name), 18);

      if (OtherGuild1 <> nil) then
      begin
        Nations[CastleSiege.SealHolder.base.character.nation - 1]
          .TacticianGuildID := OtherGuild1.Index;
        System.AnsiStrings.StrPLCopy
          (Nations[CastleSiege.SealHolder.base.character.nation - 1]
          .Cerco.Defensoras.Estrategista, String(OtherGuild1.name), 18);
      end;
      if (OtherGuild2 <> nil) then
      begin
        Nations[CastleSiege.SealHolder.base.character.nation - 1].JudgeGuildID
          := OtherGuild2.Index;
        System.AnsiStrings.StrPLCopy
          (Nations[CastleSiege.SealHolder.base.character.nation - 1]
          .Cerco.Defensoras.Juiz, String(OtherGuild2.name), 18);
      end;
      if (OtherGuild3 <> nil) then
      begin
        Nations[CastleSiege.SealHolder.base.character.nation - 1]
          .TreasurerGuildID := OtherGuild3.Index;
        System.AnsiStrings.StrPLCopy
          (Nations[CastleSiege.SealHolder.base.character.nation - 1]
          .Cerco.Defensoras.Tesoureiro, String(OtherGuild3.name), 18);
      end;

      for i := 0 to 3 do
      begin
        if (String(Nations[CastleSiege.SealHolder.character.base.nation - 1]
          .Cerco.Atacantes[i].LordMarechal) <> '') then
        begin
          for j := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildSlotByID(Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildByName(String(Nations
              [CastleSiege.SealHolder.character.base.nation - 1].Cerco.Atacantes
              [i].LordMarechal)))];

            if (TempGuild.Members[j].Logged) then
            begin
              if (Servers[CastleSiege.SealHolder.ChannelIndex]
                .GetPlayerByCharIndex(TempGuild.Members[j].CharIndex,
                AnotherPlayer)) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage
                  ('A guerra acabou. Os vencedores foram definidos.');

                AnotherPlayer.SendNationInformation;
                AnotherPlayer.base.GetCurrentScore;
                AnotherPlayer.base.SendRefreshPoint;
                AnotherPlayer.base.SendStatus;
                AnotherPlayer.base.SendRefreshLevel;
                AnotherPlayer.base.SendCurrentHPMP();

                if (AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                AnotherPlayer.base.InClastleVerus := False;
              end;
            end;
          end;
        end;
        if (String(Nations[CastleSiege.SealHolder.character.base.nation - 1]
          .Cerco.Atacantes[i].Estrategista) <> '') then
        begin
          for j := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildSlotByID(Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildByName(String(Nations
              [CastleSiege.SealHolder.character.base.nation - 1].Cerco.Atacantes
              [i].Estrategista)))];

            if (TempGuild.Members[j].Logged) then
            begin
              if (Servers[CastleSiege.SealHolder.ChannelIndex]
                .GetPlayerByCharIndex(TempGuild.Members[j].CharIndex,
                AnotherPlayer)) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage
                  ('A guerra acabou. Os vencedores foram definidos.');

                AnotherPlayer.SendNationInformation;
                AnotherPlayer.base.GetCurrentScore;
                AnotherPlayer.base.SendRefreshPoint;
                AnotherPlayer.base.SendStatus;
                AnotherPlayer.base.SendRefreshLevel;
                AnotherPlayer.base.SendCurrentHPMP();

                if (AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                AnotherPlayer.base.InClastleVerus := False;
              end;
            end;
          end;
        end;
        if (String(Nations[CastleSiege.SealHolder.character.base.nation - 1]
          .Cerco.Atacantes[i].Juiz) <> '') then
        begin
          for j := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildSlotByID(Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildByName(String(Nations
              [CastleSiege.SealHolder.character.base.nation - 1].Cerco.Atacantes
              [i].Juiz)))];

            if (TempGuild.Members[j].Logged) then
            begin
              if (Servers[CastleSiege.SealHolder.ChannelIndex]
                .GetPlayerByCharIndex(TempGuild.Members[j].CharIndex,
                AnotherPlayer)) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage
                  ('A guerra acabou. Os vencedores foram definidos.');

                AnotherPlayer.SendNationInformation;
                AnotherPlayer.base.GetCurrentScore;
                AnotherPlayer.base.SendRefreshPoint;
                AnotherPlayer.base.SendStatus;
                AnotherPlayer.base.SendRefreshLevel;
                AnotherPlayer.base.SendCurrentHPMP();

                if (AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                AnotherPlayer.base.InClastleVerus := False;
              end;
            end;
          end;
        end;
        if (String(Nations[CastleSiege.SealHolder.character.base.nation - 1]
          .Cerco.Atacantes[i].Tesoureiro) <> '') then
        begin
          for j := 0 to 127 do
          begin
            TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildSlotByID(Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetGuildByName(String(Nations
              [CastleSiege.SealHolder.character.base.nation - 1].Cerco.Atacantes
              [i].Tesoureiro)))];

            if (TempGuild.Members[j].Logged) then
            begin
              if (Servers[CastleSiege.SealHolder.ChannelIndex]
                .GetPlayerByCharIndex(TempGuild.Members[j].CharIndex,
                AnotherPlayer)) then
              begin
                AnotherPlayer.SendGuildInfo;
                AnotherPlayer.SendClientMessage
                  ('A guerra acabou. Os vencedores foram definidos.');

                AnotherPlayer.SendNationInformation;
                AnotherPlayer.base.GetCurrentScore;
                AnotherPlayer.base.SendRefreshPoint;
                AnotherPlayer.base.SendStatus;
                AnotherPlayer.base.SendRefreshLevel;
                AnotherPlayer.base.SendCurrentHPMP();

                if (AnotherPlayer.SavedPos.IsValid) then
                  AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
                else
                  AnotherPlayer.Teleport(TPosition.Create(3450, 690));

                AnotherPlayer.base.InClastleVerus := False;
              end;
            end;
          end;
        end;
      end;

      ZeroMemory(@Nations[CastleSiege.SealHolder.base.character.nation - 1]
        .Cerco.Atacantes,
        sizeof(Nations[CastleSiege.SealHolder.base.character.nation - 1]
        .Cerco.Atacantes));

      if (OldAlliance.Guilds[0].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
            .GetGuildSlotByID(OldAlliance.Guilds[0].Index)];

          if (TempGuild.Members[i].Logged) then
          begin
            if (Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetPlayerByCharIndex(TempGuild.Members[i].CharIndex,
              AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou. Os vencedores foram definidos.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;
      if (OldAlliance.Guilds[1].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
            .GetGuildSlotByID(OldAlliance.Guilds[1].Index)];

          if (TempGuild.Members[i].Logged) then
          begin
            if (Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetPlayerByCharIndex(TempGuild.Members[i].CharIndex,
              AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou. Os vencedores foram definidos.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;
      if (OldAlliance.Guilds[2].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
            .GetGuildSlotByID(OldAlliance.Guilds[2].Index)];

          if (TempGuild.Members[i].Logged) then
          begin
            if (Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetPlayerByCharIndex(TempGuild.Members[i].CharIndex,
              AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou. Os vencedores foram definidos.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;
      if (OldAlliance.Guilds[3].Index <> 0) then
      begin
        for i := 0 to 127 do
        begin
          TempGuild := @Guilds[Servers[CastleSiege.SealHolder.ChannelIndex]
            .GetGuildSlotByID(OldAlliance.Guilds[3].Index)];

          if (TempGuild.Members[i].Logged) then
          begin
            if (Servers[CastleSiege.SealHolder.ChannelIndex]
              .GetPlayerByCharIndex(TempGuild.Members[i].CharIndex,
              AnotherPlayer)) then
            begin
              AnotherPlayer.SendGuildInfo;
              AnotherPlayer.SendClientMessage
                ('A guerra acabou. Os vencedores foram definidos.');

              AnotherPlayer.SendNationInformation;
              AnotherPlayer.base.GetCurrentScore;
              AnotherPlayer.base.SendRefreshPoint;
              AnotherPlayer.base.SendStatus;
              AnotherPlayer.base.SendRefreshLevel;
              AnotherPlayer.base.SendCurrentHPMP();

              if (AnotherPlayer.SavedPos.IsValid) then
                AnotherPlayer.Teleport(AnotherPlayer.SavedPos)
              else
                AnotherPlayer.Teleport(TPosition.Create(3450, 690));

              AnotherPlayer.base.InClastleVerus := False;
            end;
          end;
        end;
      end;

      Nations[CastleSiege.SealHolder.base.character.nation - 1].SaveNation;

      for i := 1 to High(Servers[CastleSiege.SealHolder.ChannelIndex]
        .Players) do
      begin
        AnotherPlayer := @Servers[CastleSiege.SealHolder.ChannelIndex]
          .Players[i];

        if (AnotherPlayer.Status < PLAYING) then
          Continue;

        AnotherPlayer.SendNationInformation;

        AnotherPlayer.SendClientMessage
          ('A guerra de castelo foi finalizada. Confira os novos líderes de sua nação.');
      end;

      for i := 0 to 2 do
      begin
        Self.RemoveOrbHolder(CastleSiege, i);
      end;

      CastleSiege.WarInProgress := False;
      CastleSiege.OrbHolder[0] := nil;
      CastleSiege.OrbHolder[1] := nil;
      CastleSiege.OrbHolder[2] := nil;
      CastleSiege.SealHolder := nil;
    end;
  end;
  // verificar tempo>=120 setar marechal, salvar, teleportar todos para local salvo
  // limpar cadastro de guerra, limpar titulos e adicionar novos aos vencedores

end;

{$ENDREGION}

end.
