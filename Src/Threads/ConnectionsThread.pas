unit ConnectionsThread;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  System.Classes, Windows, SysUtils, Winsock2, System.SyncObjs;

type
  TConnectionsThread = class(TThread)
  private
    { Private declarations }
    FDelay: Integer;
    Channel: BYTE;
    fCritSect: TCriticalSection;
  protected
    procedure Execute; override;
  public
    constructor Create(Delay: Integer; ChannelIndex: BYTE);
    destructor Destroy;
  end;

type
  TPlayerThreadGarbage = class(TThread)
  private
    { Private declarations }
    FDelay: Integer;
    Channel: BYTE;
  protected
    // procedure Execute; override;
  public
    constructor Create(Delay: Integer; ChannelIndex: BYTE);
  end;

implementation

uses GlobalDefs, Log, Packets;

constructor TConnectionsThread.Create(Delay: Integer; ChannelIndex: BYTE);
begin
  FDelay := Delay;
  Self.Channel := ChannelIndex;
  fCritSect := TCriticalSection.Create;
  inherited Create(FALSE);
  Self.Priority := tpLower;
end;

constructor TPlayerThreadGarbage.Create(Delay: Integer; ChannelIndex: BYTE);
begin
  inherited Create(FALSE);
  Self.Priority := tpLower;
  FDelay := Delay;
  Self.Channel := ChannelIndex;
end;

destructor TConnectionsThread.Destroy;
begin
  fCritSect.Free;
  inherited;
end;

procedure TConnectionsThread.Execute;
var
  i: Integer;
begin
  while not ServerHasClosed do
  begin
    fCritSect.Enter;
    try

      if not ServerHasClosed then
        Servers[Channel].AcceptConnection;

    except
      on E: Exception do
      begin
        Logger.Write('Error Accept Connection ' + E.Message, TlogTYpe.Error);
        Continue;
      end;
    end;
    fCritSect.Leave;
    TThread.Yield;
    TThread.Sleep(Self.FDelay);
  end;
end;

end.
