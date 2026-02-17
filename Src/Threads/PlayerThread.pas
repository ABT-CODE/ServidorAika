unit PlayerThread;

interface

uses
  System.Classes, SysUtils, Winsock2, System.SyncObjs;

type
  PPlayerThread = ^TPlayerThread;

  TPlayerThread = class(TThread)
  private
    FDset: TFDSet;
    Channel: Byte;
    fCritSect: TCriticalSection;

    procedure ProcessPackets(PlayerPointer: Pointer; RecvBuffer: array of Byte; RecvBytes: Word);
  protected
    procedure Execute; override;
  public
    Term: Boolean;
    ClientID: Word;

    constructor Create(const FClientID: Word; const Socket: TSocket; var FChannel: Byte);
    destructor Destroy; override;

    procedure Terminate; overload;
  end;

implementation

uses
  GlobalDefs, Log, Packets, Player, EncDec,
  EntityMail, PacketHandlers, DateUtils, Windows;

{ TPlayerThread }

constructor TPlayerThread.Create(const FClientID: Word; const Socket: TSocket; var FChannel: Byte);
begin
  inherited Create(False);
  fCritSect := TCriticalSection.Create;
  ClientID := FClientID;
  Channel := FChannel;
  FreeOnTerminate := True;
  Term := False;
end;

destructor TPlayerThread.Destroy;
begin
  fCritSect.Free;
  inherited;
end;

procedure TPlayerThread.Terminate;
var
  MPlayer: PPlayer;
begin
  if Term then
    Exit;

  MPlayer := @Servers[Channel].Players[ClientID];

  Servers[Channel].Disconnect(MPlayer^);

  MPlayer^.PlayerThreadActive := False;
  MPlayer^.xdisconnected := True;

  Dec(PlayersThreads);
  Dec(Servers[Channel].InstantiatedPlayers);

  Term := True;

  inherited Terminate;
end;
procedure TPlayerThread.ProcessPackets(PlayerPointer: Pointer; RecvBuffer: array of byte; RecvBytes: Word);
const
  MinDelayNormal: byte = 100;
var
  LastTime, CurrentTime: TDateTime;
  MPlayer: PPlayer;
  Header2: PPacketHeader;
begin

MPlayer:= PlayerPointer;



      CurrentTime := Now;




          TEncDec.Decrypt(RecvBuffer, RecvBytes);
          Header2:= @RecvBuffer[0];
          LastTime := MPlayer.GetLastPacketTime(Header2.Code);

          case Header2.Code of

        {$REGION 'PACOTES SEM FILTRO'}
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                  end;
                end;
              end;
            $F0B:
              begin
                if (SecondsBetween(CurrentTime, LastTime) > 5) then
                  if (MPlayer^.LoggedByOtherChannel) then
                  begin
                    MPlayer^.LoggedByOtherChannel := FALSE;
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
                          Logger.Write
                            ('Erro na execução de comando do player: [' +
                            E.Message + ' : ' + E.GetBaseException.Message +
                            '] MPlayer^.base.character.name[' +
                            MPlayer^.base.character.name + '] ' +
                            DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                        end;
                      end;
                  end;
              end;
             $302:
             begin
             try

             TPacketHandlers.AttackTarget(MPlayer, PPacket_302(@RecvBuffer[0]),FALSE, 0);
//            /// /            MPlayer^.SetLastPacketTime(Header2.Code);
             except
             on E: Exception do
             begin
             Logger.Write('Erro na execução de comando do player: [' + E.Message + ' : ' +
             E.GetBaseException.Message + '] MPlayer^.base.character.name[' + MPlayer^.base.character.name + '] ' +
             DateTimeToStr(CurrentTime) + '.', TlogType.Error);
             end;
             end;
             end;
             $320:
             begin
//            /// /         if (MPlayer^.IsInstantiated) and (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal) then
             try

              TPacketHandlers.UseSkill(MPlayer, RecvBuffer);
//            /// /            MPlayer^.SetLastPacketTime(Header2.Code);
             except
             on E: Exception do
             begin
             Logger.Write('Erro na execução de comando do player: [' + E.Message + ' : ' +
             E.GetBaseException.Message + '] MPlayer^.base.character.name[' + MPlayer^.base.character.name + '] ' +
             DateTimeToStr(CurrentTime) + '.', TlogType.Error);
             end;
             end;
             end;
            $31D:
              begin
                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try
                    MPlayer^.SetLastPacketTime(Header2.Code);
                    TPacketHandlers.UseItem(MPlayer^, RecvBuffer);

                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $306:
              begin
                try

                  TPacketHandlers.UpdateMobInfo(MPlayer^, RecvBuffer);
                except
                  on E: Exception do
                  begin
                    Logger.Write('Erro na execução de comando do player: [' +
                      E.Message + ' : ' + E.GetBaseException.Message +
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                  end;
                end;
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                  end;
                end;
              end;
{$ENDREGION}
        {$REGION 'PACOTES COM FILTRO'}
            $308:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $218:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $668:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try
                    MPlayer^.Account.Header.IsActive := false;    //Gambiarra pra deslogar a conta, preciso achar o pacote de deslogar
                    MPlayer^.Base.Destroy;
                    MPlayer^.Base.IsActive := False;
                    closesocket(MPlayer^.Socket);
                    //MPlayer^.SendCharList; //modificar para BackToCharList ou modificar o SendCharList
                    MPlayer^.SetLastPacketTime(Header2.Code);

                    Logger.Write('[' + MPlayer^.Account.Header.Username + '] | Personagem [' +
                      String(MPlayer^.Character.Base.Name) + '] | Deslogado em: [' +
                        DateTimeToStr(Now) + ']', TLogType.ConnectionsTraffic);

                    //Logger.Write('Player thread troca personagem', warnings);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $21B:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $20A:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $327:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $202:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $207:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $209:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $21A, $22A:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $224:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $22C:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $22D:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $303:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $304:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $307, $364:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $31C:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $322:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $323:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $324:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $325:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $326:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $329:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $32A:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $32B:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $32C:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $32D:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $32F:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $332:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $333:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $334:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $338:
              begin

                // if (MPlayer^.PartyIndex = 0) or (MPlayer^.Party.Members.Count = 1) then
                // Exit;
                try

                  TPacketHandlers.UpdateMemberPosition(MPlayer^, RecvBuffer);
                  // MPlayer^.SetLastPacketTime(Header2.Code);
                except
                  on E: Exception do
                  begin
                    Logger.Write('Erro na execução de comando do player: [' +
                      E.Message + ' : ' + E.GetBaseException.Message +
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                  end;
                end;
              end;
            $340:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $342, $909:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $343:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $344:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $34A:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $355:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $356:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $359:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $361:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $372:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $38F:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $395:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $396:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $673:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $619:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $67D:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $603:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $B52:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    TPacketHandlers.RequestUpdateReliquare(MPlayer^,
                      RecvBuffer);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $E3A:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $E51:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F1C:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F1D:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F05:
              begin

                if (MPlayer^.IsInstantiated) and (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try
                    MPlayer^.SetLastPacketTime(Header2.Code);
                    TPacketHandlers.ChangeChannel(MPlayer^, RecvBuffer);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $397:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F12:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F20:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F21:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F22:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    TPacketHandlers.UpdateGuildRanksConfig(MPlayer^,
                      RecvBuffer);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F26:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F2D:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F2F:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F27:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F30:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F34:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F59:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F74:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F7B:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F7E:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3E01:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3E04:
              begin
                  try

                    TPacketHandlers.CreateCharacter(MPlayer^, RecvBuffer);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3E02:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F15:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F16:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    TPacketHandlers.checkSendMailRequirements(MPlayer^,
                      RecvBuffer);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F17:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F18:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F1A:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F0D:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F0B:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F11:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    TPacketHandlers.RequestOwnAuctionItems(MPlayer^,
                      RecvBuffer);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F10:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    TPacketHandlers.RequestAuctionOfferCancel(MPlayer^,
                      RecvBuffer);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3F0C:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    TPacketHandlers.RequestAuctionOfferBuy(MPlayer^,
                      RecvBuffer);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F93A:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3E05:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $23FE:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $23FB:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    TPacketHandlers.RequestAllAttributesTarget(MPlayer^,
                      RecvBuffer);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $34B:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $3961, $F79:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try

                    MPlayer^.SendUpdateReliquareInformation
                      (MPlayer^.ChannelIndex);
                    MPlayer^.SetLastPacketTime(Header2.Code);
                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F71:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;
            $F86:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
                  try
                    MPlayer^.SetLastPacketTime(Header2.Code);
                    TPacketHandlers.SendClientSay(MPlayer^, RecvBuffer);

                  except
                    on E: Exception do
                    begin
                      Logger.Write('Erro na execução de comando do player: [' +
                        E.Message + ' : ' + E.GetBaseException.Message +
                        '] MPlayer^.base.character.name[' +
                        MPlayer^.base.character.name + '] ' +
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
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
                      '] MPlayer^.base.character.name[' +
                      MPlayer^.base.character.name + '] ' +
                      DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                  end;
                end;
              end;
            $70F:
              begin

                if (MPlayer^.IsInstantiated) and
                  (MillisecondsBetween(CurrentTime, LastTime) > MinDelayNormal)
                then
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
                        DateTimeToStr(CurrentTime) + '.', TlogType.Error);
                    end;
                  end;
              end;

{$ENDREGION}
          else
            begin

              WriteLn('pacote diferente ' + Header2.Code.ToHexString);

            end;
          end;





end;




procedure TPlayerThread.Execute;
var
  MPlayer: PPlayer;
  Timeout: TTimeVal;
  RecvBuffer: array [0..21999] of Byte;
  RecvBytes: Integer;
  ErrorCode: Integer;
  Freq, StartCount, EndCount: Int64;
  ElapsedTime: Double;
begin
  Timeout.tv_sec := 0;
  Timeout.tv_usec := 10000; // 10ms para evitar polling excessivo

  MPlayer := @Servers[Channel].Players[ClientID];
  MPlayer^.LastTimeSaved := Now;
  MPlayer^.xdisconnected := False;

//  if not QueryPerformanceFrequency(Freq) or (Freq = 0) then
//    Freq := 1000; // fallback ms
//
  while not (Term or MPlayer^.xdisconnected) do
  begin
    FD_ZERO(FDset);
    _FD_SET(MPlayer^.Socket, FDset);

    // Espera até ter dados para receber ou timeout
    if select(0, @FDset, nil, nil, @Timeout) <= 0 then
      Continue;

    fCritSect.Enter;
    try
      RecvBytes := Recv(MPlayer^.Socket, RecvBuffer, SizeOf(RecvBuffer), 0);

      if RecvBytes = SOCKET_ERROR then
      begin
        ErrorCode := WSAGetLastError;
        if ErrorCode <> WSAEWOULDBLOCK then
        begin
          MPlayer^.SocketClosed := True;
          MPlayer^.xdisconnected := True;
          Terminate; // chama método que limpa estado
          Exit;
        end
        else
          Continue; // sem dados prontos, continuar aguardando
      end
      else if RecvBytes <= 0 then
      begin
        MPlayer^.SocketClosed := True;
        MPlayer^.xdisconnected := True;
        Terminate;
        Exit;
      end;

      // Ignorar pacotes de heartbeat/ping (exemplo)
      if ((RecvBytes > 7) and
          (((RecvBuffer[6] = 55) and (RecvBuffer[7] = 3)) or ((RecvBuffer[6] = 5) and (RecvBuffer[7] = 3)))) then
        Continue;

      if (RecvBytes >= 12) and (RecvBytes <= SizeOf(RecvBuffer)) then
      begin
        QueryPerformanceCounter(StartCount);

        if MPlayer^.RecvPackets then
          ProcessPackets(MPlayer, RecvBuffer, RecvBytes)
        else
        begin
          Move(RecvBuffer[4], RecvBuffer, RecvBytes - 4);
          MPlayer^.RecvPackets := True;
          ProcessPackets(MPlayer, RecvBuffer, RecvBytes - 4);
        end;

//        QueryPerformanceCounter(EndCount);
//        ElapsedTime := (EndCount - StartCount) / Freq * 1000; // ms

        // Para debug, ative a linha abaixo se quiser medir tempo:
        // Writeln(Format('Packet processado em %.6f ms.', [ElapsedTime]));
      end
      else
        MPlayer^.RecvPackets := True;

    finally
      fCritSect.Release;
    end;
  end;

  // Garante limpeza e desconexão
  if not Term then
    Terminate;
end;

end.

