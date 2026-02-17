unit TokenSocket;
{$OPTIMIZATION ON}
{$O+}

interface

uses
  IdHTTPServer, IdCustomHTTPServer, IdContext, Classes,
  SysUtils, StrUtils, Windows;

type
  TTokenServer = class(TObject)
  private
    FRequests: TIdHTTPServer;
    FAllowedURLs: TArray<string>;
    function GetActive: boolean;
    procedure SetActive(const Active: boolean);
  public
    constructor Create;
    destructor Destroy; override;
    procedure OnGetCommand(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure OnCommandError(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo;
      AException: Exception);
    function StartServer: boolean;
    function RequestControl(const URL: string; Param: TStrings; var IsJson: boolean;
      const RemoteIP: string): string;
    property IsActive: boolean read GetActive write SetActive;
  end;

implementation

uses
  AuthHandlers, GlobalDefs, Log;

constructor TTokenServer.Create;
begin
  inherited Create;
  FAllowedURLs := TArray<string>.Create(
    '/member/aika_get_token.asp',
    '/servers/aika_get_chrcnt.asp',
    '/servers/serv00.asp',
    '/servers/aika_reset_flag.asp',
    '/gateway/v999/' + ASAAS_LINK_GATEWAY + '.asp',
    '/leilao/removecash/' + ASAAS_LINK_GATEWAY + '.asp',
    '/leilao/additem/' + ASAAS_LINK_GATEWAY + '.asp',
    '/leilao/addcash/' + ASAAS_LINK_GATEWAY + '.asp',
    '/enviarpacote.asp'
  );
  FRequests := TIdHTTPServer.Create(nil);
  FRequests.DefaultPort := 8090;
  FRequests.OnCommandGet := OnGetCommand;
  FRequests.OnCommandError := OnCommandError;

end;

destructor TTokenServer.Destroy;
begin
  FRequests.Free;
  inherited Destroy;
end;

function TTokenServer.StartServer: boolean;
begin
  SetActive(True);
  Result := GetActive;

  if Result then
    Logger.Write('Token Server iniciado com sucesso [Porta: 8090].', TLogType.ServerStatus)
  else
    Logger.Write('Erro ao iniciar o TokenServer.', TLogType.Warnings);
end;

procedure TTokenServer.OnGetCommand(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  CmdUpper: string;
  IsJson: boolean;
begin
  IsJson := False;
  CmdUpper := UpperCase(Trim(ARequestInfo.Command));

  if CmdUpper = '' then
    Exit;

  if CmdUpper = 'POST' then
  begin
    try
      AResponseInfo.ContentText := RequestControl(ARequestInfo.Document,
        ARequestInfo.Params, IsJson, ARequestInfo.RemoteIP);

      if IsJson then
        AResponseInfo.ContentType := 'application/json'
      else
        AResponseInfo.ContentType := 'text/plain; charset=utf-8';
    except
      on E: Exception do
      begin
        Logger.Write('Error at OnGetCommand TokenServer :: ' + E.Message +
          ' t: ' + DateTimeToStr(Now), TLogType.Error);
        AResponseInfo.ContentText := 'Internal Server Error';
        AResponseInfo.ResponseNo := 500;
      end;
    end;
  end
  else
  begin
    AResponseInfo.ContentText := 'NGNIX iNiz Games © 2023 - 503 Forbidden';
    AResponseInfo.ResponseNo := 403;
  end;
end;

procedure TTokenServer.OnCommandError(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo;
  AException: Exception);
begin
  Logger.Write('Error at OnGetCommand TokenServer :: ' + AException.Message +
    ' t: ' + DateTimeToStr(Now), TLogType.Error);
end;

function TTokenServer.GetActive: boolean;
begin
  Result := FRequests.Active;
end;

procedure TTokenServer.SetActive(const Active: boolean);
begin
  FRequests.Active := Active;
end;

function TTokenServer.RequestControl(const URL: string; Param: TStrings; var IsJson: Boolean;
  const RemoteIP: string): string;
var
  Idx: Integer;
begin
  Result := '';
  if xServerClosed or ServerHasClosed then
    Exit;

  Idx := IndexText(URL, FAllowedURLs);
  case Idx of
    0: TAuthHandlers.AikaGetToken(Param, Result, RemoteIP);
    1: TAuthHandlers.AikaGetChrCnt(Param, Result);
    2: TAuthHandlers.GetServerPlayers(Result);
    3: TAuthHandlers.AikaResetFlag(Param, Result);
    4:
      begin
        TAuthHandlers.CheckPingback(Param, Result);
        IsJson := True;
      end;
    5:
      begin
        TAuthHandlers.RemoverCash(Param, Result);
        IsJson := True;
      end;
    6:
      begin
        TAuthHandlers.AddItem(Param, Result);
        IsJson := True;
      end;
    7:
      begin
        TAuthHandlers.AddCash(Param, Result);
        IsJson := True;
      end;
    8:
      begin
        TAuthHandlers.EnviarPacote(Param, Result);
        IsJson := True;
      end;
  else
    Result := 'Invalid endpoint';
  end;
end;

end.

