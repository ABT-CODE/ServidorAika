unit SQL;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses Data.DB, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.DataSet, FireDAC.Comp.Client,
  FireDAC.Phys.MySQLDef, FireDAC.Phys.MySQL, Log, System.SysUtils;

type
  TQuery = class(TObject)
    Query: TFDQuery;
    constructor Create(Server: AnsiString; Port: Integer;
      Login, Senha, DB: AnsiString; OnlyTransaction: Boolean = False);
    destructor Destroy; override;
    procedure SetQuery(Query: String);
    procedure AddParameter(Param, Value: AnsiString);
    procedure AddParameter2(Param: AnsiString; Value: Variant);
    procedure Run(Consult: Boolean = True);
  private
    procedure ConfigureConnection;
    procedure RecreateQuery;
  end;

implementation

uses GlobalDefs;

constructor TQuery.Create(Server: AnsiString; Port: Integer; Login: AnsiString;
  Senha: AnsiString; DB: AnsiString; OnlyTransaction: Boolean = False);
begin
  Query := TFDQuery.Create(nil);
  Query.Connection := TFDConnection.Create(nil);
  ConfigureConnection;

  Query.Connection.ResourceOptions.AutoReconnect := True;
  Query.Connection.TxOptions.AutoCommit := not OnlyTransaction;
  Query.FetchOptions.Mode := fmAll;

  while not Query.Connection.Connected do
  begin
    try
      Query.Connection.Open();
    except
      on E: Exception do
      begin
        if Query.Connection.Connected then
          Query.Connection.Close();
        RecreateQuery; // Refatora a criação da query
        Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Error);
        Continue;
      end;
    end;
  end;
end;

destructor TQuery.Destroy;
begin
  try
    FreeAndNil(Query.Connection);
    FreeAndNil(Query);
  except
    on E: Exception do
      Logger.Write(E.ClassName + ': ' + E.Message, TLogType.Warnings);
  end;
end;

procedure TQuery.ConfigureConnection;
begin
  with Query.Connection.Params do
  begin
    Add('DriverID=MySQL');
    Add('Server=' + String(MYSQL_SERVER));
    Add('Port=' + IntToStr(MYSQL_PORT));
    Add('Database=' + String(MYSQL_DATABASE));
    Add('User_Name=' + String(MYSQL_USERNAME));
    Add('Password=' + String(MYSQL_PASSWORD));
    Add('Charset=utf8mb4');
    Add('Collate=utf8mb4_unicode_ci');
  end;
end;

procedure TQuery.RecreateQuery;
begin
  FreeAndNil(Query); // Libera o recurso da query
  Query := TFDQuery.Create(nil);
  Query.Connection := TFDConnection.Create(nil);
  ConfigureConnection;
end;

procedure TQuery.SetQuery(Query: String);
begin
  with Self.Query do
  begin
    Close;
    SQL.Text := Query;
  end;
end;

procedure TQuery.AddParameter(Param: AnsiString; Value: AnsiString);
begin
  Self.Query.ParamByName(String(Param)).Value := Value;
end;

procedure TQuery.AddParameter2(Param: AnsiString; Value: Variant);
begin
  Self.Query.ParamByName(String(Param)).Value := Value;
end;

procedure TQuery.Run(Consult: Boolean = True);
var
  Confirmed: Boolean;
  triedtimes: Integer;
const
  MaxRetries = 1; // Número máximo de tentativas
begin
  Confirmed := False;
  triedtimes := 0;
  while not Confirmed and (triedtimes <= MaxRetries) do
  begin
    try
      Inc(triedtimes);

      if triedtimes > MaxRetries then
      begin
        // Logger.Write('Número máximo de tentativas atingido em Query.ExecSQL. Abortando operação.', TLogType.Error);
        Exit;
      end;

      if Consult then
      begin
        Query.Open();
      end
      else
      begin
        if not Query.Connection.InTransaction then
        begin
          if not Query.Connection.TxOptions.AutoCommit then
          begin
            Query.Connection.StartTransaction;
          end;
        end;
        Query.ExecSQL();
      end;

      Confirmed := True;
    except
      on E: EFDException do
      begin
        if Pos('Duplicate entry', E.Message) > 0 then
        begin
          // Logger.Write(Format('Erro ao executar Query: Duplicated Entry - %s', [E.Message]), TLogType.Error);
          Exit;
        end
        else if Pos('Deadlock', E.Message) > 0 then
        begin
          Logger.Write('Erro de Deadlock: Reiniciando transação',
            TLogType.Error);
          Query.Connection.Rollback;
          Continue; // Tentar novamente a transação
        end
        else
        begin
          Logger.Write(Format('Erro ao executar Query: %s', [E.Message]),
            TLogType.Error);
          RecreateQuery; // Refatora a criação da query
          Continue;
        end;
      end;
    end;
  end;
end;

end.
