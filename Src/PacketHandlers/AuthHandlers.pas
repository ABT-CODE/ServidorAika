unit AuthHandlers;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Winsock2, Windows, Classes,
  StrUtils, SysUtils, DateUtils,
  LoginSocket, AnsiStrings, Player, IdHashMessageDigest;

type
  TAuthHandlers = class(TObject)
  public
    { HTTP Request Functions }
    class function AikaGetToken(Params: TStrings; var Response: string;
      RemoteIP: string): boolean;
    class function AikaGetChrCnt(Params: TStrings;
      var Response: string): boolean;
    class function GetServerPlayers(var Response: string): boolean;
    class function AikaResetFlag(Params: TStrings;
      var Response: string): boolean;
    class function AikaCreateAccount(Params: TStrings;
      var Response: string): boolean;

    { Login Functions }
    class function CheckToken(var Connection: TConnection;
      Buffer: ARRAY OF BYTE): boolean;

    { PingBack Functions }
    class function CheckPingback(Params: TStrings;
      var Response: string): boolean;

    class function AddCash(Params: TStrings; var Response: string): boolean;

    class function RemoverCash(Params: TStrings; var Response: string): boolean;

    class function AddItem(Params: TStrings; var Response: string): boolean;
    class function EnviarPacote(Params: TStrings; var Response: string)
      : boolean;
  end;

implementation

uses
  Functions, GlobalDefs, Log, Packets, EncDec, MMSystem, PlayerData,
  SQL;

{$REGION 'HTTP Request Functions'}

function MD5Hash(const Value: string): string;
var
  MD5: TIdHashMessageDigest5;
begin
  MD5 := TIdHashMessageDigest5.Create;
  try
    Result := MD5.HashStringAsHex(Value); // Calcula o hash MD5 em hexadecimal
  finally
    MD5.Free;
  end;
end;

procedure RegistrarTentativa(const Login: string);
var
  Tentativa: TTentativas;
begin
  if TentativasDict.ContainsKey(Login) then
  begin
    Tentativa := TentativasDict[Login];
    Inc(Tentativa.Erros);
    Tentativa.LastTentativa := Now;
  end
  else
  begin
    Tentativa.Login := Login;
    Tentativa.Erros := 1;
    Tentativa.LastTentativa := Now;
  end;

  TentativasDict.AddOrSetValue(Login, Tentativa);
end;

procedure RegistrarBloqueio(const IP: string);
var
  Bloqueio: TBlockedIps;
begin
  Bloqueio.IP := IP;
  Bloqueio.LastBlock := Now;

  BlockedDict.AddOrSetValue(IP, Bloqueio);
end;

function ObterTentativas(const Login: string): Integer;
begin
  if TentativasDict.ContainsKey(Login) then
    Result := TentativasDict[Login].Erros
  else
    Result := 0;
end;

function EstaBloqueado(const IP: string): boolean;
var
  BlockInfo: TBlockedIps;
begin
  Result := False;
  if BlockedDict.ContainsKey(IP) then
  begin
    BlockInfo := BlockedDict[IP];
    if MinutesBetween(BlockInfo.LastBlock, Now) < 10 then
      Result := True; // Ainda está bloqueado
  end;
end;

class function TAuthHandlers.AikaGetToken(Params: TStrings;
  var Response: string; RemoteIP: string): boolean;
var
  Player: TPlayer;
  Username, Password: string;
  Tentativa: TTentativas;
begin
  Result := False;

  // WriteLn(remoteip);
  /// /if RemoteIP = '' then
  /// /begin
  /// /  writeln('ip vazio');
  /// /end;

  try

    if EstaBloqueado(RemoteIP) then
    begin
      Response := '-11';
      ZeroMemory(@Player, SizeOf(Player));
      Exit;
    end;

    Username := LowerCase(ReplaceStr(Params[0], 'id=', ''));
    Password := ReplaceStr(Params[1], 'pw=', '');

    if Player.LoadAccountSQL(Username) then
    begin
      if ObterTentativas(LowerCase(Username)) >= 10 then
      begin
        RegistrarBloqueio(RemoteIP);
      end;

      if string(Player.Account.Header.Password) <> LowerCase(MD5Hash(Password))
      then
      begin
        RegistrarTentativa(LowerCase(Username));
        // WriteLn('Senha errada');
      end;

      if string(Player.Account.Header.Password) = LowerCase(MD5Hash(Password))
      then
      begin

        case Player.Account.Header.AccountStatus of
          2: // conta cancelada
            Response := '-2';

          8: // usuário banido permanentemente
            if Player.Account.Header.BanDays > 0 then
            begin
              if IncDay(Player.Account.Header.Token.CreationTime,
                Player.Account.Header.BanDays) <= Now then
              begin
                Player.Account.Header.BanDays := 0;
                Player.Account.Header.AccountStatus := 0;
                Response := '-22';
                Player.SaveStatus(Username);
              end
              else
                Response := '-8'; // Conta banida
            end
            else
              Response := '-8'; // Conta banida

          10: // usuário não CBT
            Response := '-10';

        else
          begin

            // Gera o token a partir da senha
            Player.Account.Header.Token.Generate(Password);
            Logger.Write('Token [' + string(Player.Account.Header.Token.Token) +
              '] criado por ' + Username + '.', TlogType.ConnectionsTraffic);
            //

            Response := string(Player.Account.Header.Token.Token);
            Player.SaveAccountToken(Username);
            Result := True;
            // Exit;
          end;
        end;
      end
      else
      begin
        Response := '-1'; // Senha incorreta
      end;
    end
    else
      Response := '0'; // Conta não encontrada

  except
    on E: Exception do
    begin
      Writeln('Ocorreu um erro: ' + E.Message);
    end;
  end;

end;

class function TAuthHandlers.AikaGetChrCnt(Params: TStrings;
  var Response: string): boolean;
var
  Player: TPlayer;
  Username, Password: string;
begin
  Result := False;

  if Player.LoadAccountSQL(LowerCase(ReplaceStr(Params[0], 'id=', ''))) then
  begin
    if string(Player.Account.Header.Token.Token) = ReplaceStr(Params[1],
      'pw=', '') then
    begin
      Response := 'CNT ' + Player.Account.GetCharCount
        (Player.Account.Header.AccountId, 0, @Player).ToString + ' 0 0 0<br>' +
        Integer(Player.Account.Header.Nation).ToString + ' 0 0 0';
      Result := True;
    end
    else
      Response := '-1'; { Incorrect Password }
  end
  else
    Response := '0'; { Account not found }

  ZeroMemory(@Player, SizeOf(Player));
end;

class function TAuthHandlers.GetServerPlayers(var Response: string): boolean;
var
  I: BYTE;
begin
  Result := False;
  Response := '';

  if not(LoginServer.IsActive) then
    Exit;

  for I := Low(Servers) to High(Servers) do
  begin
    if Servers[I].IsActive then
    begin
      if (Servers[I].InstantiatedPlayers = 0) then
        Response := Response + '1 '
      else
        Response := Response + Servers[I].InstantiatedPlayers.ToString + ' ';
    end
    else
      Response := Response + '-1 ';
  end;

  if Response[Length(Response)] = ' ' then
    Delete(Response, Length(Response), 1);

  Result := True;
end;

class function TAuthHandlers.AikaResetFlag(Params: TStrings;
  var Response: string): boolean;
var
  Username, Password: string;
  Player: TPlayer;
begin
  Params[0] := LowerCase(ReplaceStr(Params[0], 'id=', ''));
  Params[1] := ReplaceStr(Params[1], 'pw=', '');

  Result := False;

  if Player.LoadAccountSQL(Params[0]) then
  begin
    if string(Player.Account.Header.Token.Token) = Params[1] then
    begin
      Player.Account.Header.Token.CreationTime := Now;

      Response := string(Player.Account.Header.Token.Token);
      Player.SaveAccountToken(Params[0]);

      Result := True;
    end
    else
      Response := '-1'; { Incorret Password }
  end
  else
    Response := '0'; { Account not found }

  ZeroMemory(@Player, SizeOf(Player));
end;

class function TAuthHandlers.AikaCreateAccount(Params: TStrings;
  var Response: string): boolean;
var
  Username, Password: string;
  Account: TAccountFile;
  AccType: TAccountType;
  MySQLComp: TQuery;
begin
  Username := LowerCase(ReplaceStr(Params[0], 'id=', ''));
  Password := ReplaceStr(Params[1], 'pw=', '');
  AccType := TAccountType(StrToInt(ReplaceStr(Params[2], 'acctype=', '')));

  Result := False;
  Response := '0';

  MySQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[AikaCreateAccount]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[AikaCreateAccount]',
      TlogType.Error);
    Exit;
  end;

  Logger.Write('AikaCreateAccount', TlogType.Error);
  MySQLComp.SetQuery
    ('INSERT INTO accounts (username, password, password_hash, last_token_creation_time'
    + ', nation, isactive, account_status, account_type, storage_gold, cash, ip_created, time_created'
    + ') VALUES (' + QuotedStr(Username) + ',' + QuotedStr(Password) + ',' +
    QuotedStr(TFunctions.StringToMd5(Password)) + ',' +
    QuotedStr('01/01/0001 00:00:01') + ',2,0,0,0,0,0,' +
    QuotedStr('::0') + ',1)');

  MySQLComp.Run(False);
  { if (TFunctions.FindAccount(Username)) then
    Exit;

    if not(TFunctions.IsLetter(Username)) then
    begin
    Response := '-1';
    Exit;
    end;

    if (Length(Username) > 16) or (Length(Password) > 12) then
    begin
    Response := '-2';
    Exit;
    end;

    ZeroMemory(@Account, SizeOf(Account));

    try
    // Account.Header.AccountId := TFunctions.IncAccountsCount;
    Account.Header.Username := ShortString(Username);
    Account.Header.Password := ShortString(Password);
    Account.Header.AccountType := AccType;
    finally
    TFunctions.SaveAccountFile(Account, Username);
    end; }

  Result := True;
  Response := Account.Header.AccountId.ToString;

  Logger.Write('Conta: ' + string(Account.Header.Username) +
    ' criada com o privilégio: ' + BYTE(Account.Header.AccountType).ToString,
    TlogType.ConnectionsTraffic);

  ZeroMemory(@Account, SizeOf(Account));
end;

{$ENDREGION}
{$REGION 'Login Functions'}

class function TAuthHandlers.CheckToken(var Connection: TConnection;
  Buffer: array of BYTE): boolean;
var
  Packet: TCheckTokenPacket absolute Buffer;
  Pacote: TResponseLoginPacket;
  Player: TPlayer;
begin

  if (Player.LoadAccountSQL(string(Packet.Username))) then
  begin
    // Logger.Write(String(Player.Account.Header.Token.Token), TlogType.Packets);

    // WriteLN('token válido 1 ');

    if (Player.Account.Header.Token.Token = Packet.Token) and
      (SecondsBetween(Now, Player.Account.Header.Token.CreationTime) < 300) then
    begin
      // WriteLN('token válido  2 ');
      if (Player.Account.Header.AccountStatus = 8) then
      begin
        Connection.Destroy;
        // WriteLN('token válido 3');
        Result := False;
      end
      else
      begin
        // WriteLN('token válido 4 ');
        ZeroMemory(@Pacote, SizeOf(TResponseLoginPacket));
        Pacote.Header.Size := SizeOf(TResponseLoginPacket);
        Pacote.Header.Code := $82;

        Pacote.Index := Player.Account.Header.AccountId;
        Pacote.Time := TimeGetTime;
        // WriteLn('nacao ao logar: ' + ord(Player.Account.Header.Nation).ToString);
        Pacote.Nation := Player.Account.Header.Nation;

        Connection.SendPacket(Pacote, Pacote.Header.Size);

        // Logger.Write('Novo login de ' + Packet.Username + ' em ' + '[' +
        // DateTimeToStr(Now) + '].', TlogType.ConnectionsTraffic);   cmd comentado
        Connection.Checked := True;
        Connection.Destroy;
        Result := True;
      end;
    end
    else
    begin
      // WriteLN('token válido 5');
      Logger.Write('Token enviada por ' + Packet.Username + ' está incorreta.',
        TlogType.ConnectionsTraffic);
      Connection.Destroy;
      Result := False;
    end;
  end
  else
  begin
    // WriteLN('token válido 6 ');
    Connection.Destroy;
    Result := False;
  end;

  ZeroMemory(@Player, SizeOf(Player));
end;

{$ENDREGION}
{$REGION 'PingBack Functions'}

class function TAuthHandlers.CheckPingback(Params: TStrings;
  var Response: string): boolean;
var
  TokenReceived, UsernameReceived: String;
  ProductReceived: Integer;
  I: Integer;
  ClientID: Integer;
  ServerID: BYTE;
  BannedUser: Integer;
begin // checar token que vier
  BannedUser := 0;

  UsernameReceived := ReplaceStr(Params[0], 'user=', '');
  TokenReceived := ReplaceStr(Params[1], 'token=', '');

  if (Length(TokenReceived) <> Length(ASAAS_TOKEN_PINGBACK)) then
  begin
    Response := '{ "error": "Provided token length is invalid" }';
    Exit;
  end;

  if (TokenReceived <> ASAAS_TOKEN_PINGBACK) then
  begin
    Response := '{ "error": "Invalid token provided" }';
    Exit;
  end;

  if (trim(UsernameReceived) = '') or (Length(UsernameReceived) < 4) then
  begin
    Response := '{ "error": "Invalid username provided" }';
    Exit;
  end;

  try
    ProductReceived := StrToInt(ReplaceStr(Params[2], 'value=', ''));
  except
    on E: Exception do
    begin
      Response := '{ "error": "Value is not a integer" }';
      Exit;
    end;
  end;

  BannedUser := StrToInt(ReplaceStr(Params[3], 'ban=', ''));

  ServerID := 255;

  for I := Low(Servers) to High(Servers) do
  begin
    ClientID := Servers[I].GetPlayerByUsername(UsernameReceived);

    if (ClientID <> 0) then
    begin
      ServerID := I;
      break;
    end;
  end;

  if (ServerID <> 255) then
  begin
    case ProductReceived of
      10000, -10000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if (ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Suas [10.000 iNiz Coins] foram entregues, confira apertando J.',
              16, 32, 16)
          else
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Você teve seu saldo retirado em 10.000 iNiz Coins.',
              16, 32, 16);
        end;
      20000, -20000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if (ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Suas [20.000 iNiz Coins] foram entregues, confira apertando J.',
              16, 32, 16)
          else
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Você teve seu saldo retirado em 20.000 iNiz Coins.',
              16, 32, 16);
        end;
      50000, -50000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if (ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Suas [50.000 iNiz Coins] foram entregues, confira apertando J.',
              16, 32, 16)
          else
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Você teve seu saldo retirado em 50.000 iNiz Coins.',
              16, 32, 16);
        end;
      100000, -100000:
        begin
          Servers[ServerID].Players[ClientID].AddCash(ProductReceived);
          if (ProductReceived > 0) then
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Suas [100.000 iNiz Coins] foram entregues, confira apertando J.',
              16, 32, 16)
          else
            Servers[ServerID].Players[ClientID].SendClientMessage
              ('Você teve seu saldo retirado em 100.000 iNiz Coins.',
              16, 32, 16);
        end;
    else
      begin
        Response := '{ "error": "Invalid value." }';
        Exit;
      end;
    end;

    if (BannedUser = 1) then
    begin
      Servers[ServerID].Players[ClientID].Account.Header.AccountStatus := 8;
      Servers[ServerID].Players[ClientID].SendCloseClient;
    end
    else if (BannedUser = 2) then
    begin
      Servers[ServerID].Players[ClientID].Account.Header.AccountStatus := 10;
      Servers[ServerID].Players[ClientID].SendCloseClient;
    end
  end
  else
  begin
    Response := '{ "error": "User isn' + #39 + 't online." }';
    Exit;
  end;

  Response := '{ "success": "VALUE_INSERTED" }';
  if (BannedUser = 1) then
    Response := Response + #13 + '{ "success": "USER_BANNED" }';
end;

{$ENDREGION}

class function TAuthHandlers.EnviarPacote(Params: TStrings;
  var Response: string): boolean;
var
  I: Integer;
  UsernameReceived, Packet: string;
  PacketArray: TBytes;
  Len: Integer;
begin
  Result := False; // Inicializa como falso, indicando falha por padrão
  UsernameReceived := ReplaceStr(Params[0], 'user=', '');
  Packet := ReplaceStr(Params[1], 'packet=', ''); // Captura o valor de Packet

  try
    // Converte o Packet (string hex) em um array de bytes
    Len := TFunctions.StrToArray(Packet, PacketArray);

    for I := 0 to Length(Servers) - 1 do
    begin
      var
      ClientID := Servers[I].GetPlayerByName(UsernameReceived);
      if ClientID > 0 then
      begin
        // Envia o array de bytes convertido
        Servers[I].Players[ClientID].SendPacket(PacketArray[0], Len);
        Result := True; // Indica que o envio foi bem-sucedido
        break;
      end;
    end;

  except
    on E: Exception do
    begin
      Response := 'Erro ao processar o pacote: ' + E.Message;
      Exit;
    end;
  end;

  // Retorna uma mensagem de resposta
  if Result then
    Response := 'Pacote enviado com sucesso.'
  else
    Response := 'Jogador não encontrado ou erro no envio do pacote.';
end;

class function TAuthHandlers.AddCash(Params: TStrings;
  var Response: string): boolean;
var
  TokenReceived, UsernameReceived: String;
  ProductReceived: Integer;
  I: Integer;
  ClientID: Integer;
  ServerID: BYTE;
  AuctionID: Integer;
var
  SQLComp: TQuery;
var
  QueryString: string;
var
  AcquisitionMailId: UInt64;
var
  AcquisitionMailItemId: UInt64;
begin // checar token que vier

  UsernameReceived := ReplaceStr(Params[0], 'user=', '');
  TokenReceived := ReplaceStr(Params[1], 'token=', '');

  if (Length(TokenReceived) <> Length(ASAAS_TOKEN_PINGBACK)) then
  begin
    Response := '{ "error": "Provided token length is invalid" }';
    Exit;
  end;

  if (TokenReceived <> ASAAS_TOKEN_PINGBACK) then
  begin
    Response := '{ "error": "Invalid token provided" }';
    Exit;
  end;

  if (trim(UsernameReceived) = '') or (Length(UsernameReceived) < 4) then
  begin
    Response := '{ "error": "Invalid username provided" }';
    Exit;
  end;

  try
    ProductReceived := StrToInt(ReplaceStr(Params[2], 'value=', ''));
  except
    on E: Exception do
    begin
      Response := '{ "error": "Value is not a integer" }';
      Exit;
    end;
  end;
  ServerID := 255;
  for I := Low(Servers) to High(Servers) do
  begin
    ClientID := Servers[I].GetPlayerByUsername(UsernameReceived);

    if (ClientID <> 0) then
    begin
      ServerID := I;
      break;
    end;
  end;

  if (ServerID <> 255) then
  begin

    if (ProductReceived > 0) then
    begin
      Servers[ServerID].Players[ClientID].SendClientMessage
        ('Foi adicionado: ' + ProductReceived.ToString +
        ' de cash devido o item já ter sido vendido', 16, 32, 16);
      Servers[ServerID].Players[ClientID].AddCash(ProductReceived);

    end;
  end
  else
  begin
    Response := '{ "error": "User isn' + #39 + 't online." }';
    Exit;
  end;

  Response := '{ "success": "VALUE_REMOVED" }';
end;

class function TAuthHandlers.RemoverCash(Params: TStrings;
  var Response: string): boolean;
var
  TokenReceived, UsernameReceived: String;
  ProductReceived: Integer;
  I: Integer;
  ClientID: Integer;
  ServerID: BYTE;
  AuctionID: Integer;
var
  SQLComp: TQuery;
var
  QueryString: string;
var
  AcquisitionMailId: UInt64;
var
  AcquisitionMailItemId: UInt64;
begin // checar token que vier

  UsernameReceived := ReplaceStr(Params[0], 'user=', '');
  TokenReceived := ReplaceStr(Params[1], 'token=', '');

  if (Length(TokenReceived) <> Length(ASAAS_TOKEN_PINGBACK)) then
  begin
    Response := '{ "error": "Provided token length is invalid" }';
    Exit;
  end;

  if (TokenReceived <> ASAAS_TOKEN_PINGBACK) then
  begin
    Response := '{ "error": "Invalid token provided" }';
    Exit;
  end;

  if (trim(UsernameReceived) = '') or (Length(UsernameReceived) < 4) then
  begin
    Response := '{ "error": "Invalid username provided" }';
    Exit;
  end;

  try
    ProductReceived := StrToInt(ReplaceStr(Params[2], 'value=', ''));
  except
    on E: Exception do
    begin
      Response := '{ "error": "Value is not a integer" }';
      Exit;
    end;
  end;
  ServerID := 255;
  for I := Low(Servers) to High(Servers) do
  begin
    ClientID := Servers[I].GetPlayerByUsername(UsernameReceived);

    if (ClientID <> 0) then
    begin
      ServerID := I;
      break;
    end;
  end;

  if (ServerID <> 255) then
  begin

    if (ProductReceived > 0) then
    begin
      Servers[ServerID].Players[ClientID].SendClientMessage
        ('Foi removido: ' + ProductReceived.ToString + ' de cash', 16, 32, 16);
      Servers[ServerID].Players[ClientID].DecCash(ProductReceived);

    end;
  end
  else
  begin
    Response := '{ "error": "User isn' + #39 + 't online." }';
    Exit;
  end;

  Response := '{ "success": "VALUE_REMOVED" }';
end;

class function TAuthHandlers.AddItem(Params: TStrings;
  var Response: string): boolean;
var
  TokenReceived, UsernameReceived, Login: String;
  ProductReceived: Integer;
  I: Integer;
  ClientID, ClientID1: Integer;
  ServerID: BYTE;
  AuctionID: Integer;
  Valor: Integer;
  SQLComp: TQuery;
  QueryString: string;
  AcquisitionMailId: UInt64;
  AcquisitionMailItemId: UInt64;
  CharacterID: Integer;
  PlayerStatus: boolean;
  PlayerCash: Integer;
  PlayerCash1: Integer;
  Quantidade: Integer;
  Status, vendedor: string;
begin // checar token que vier
  AuctionID := 0;

  UsernameReceived := ReplaceStr(Params[0], 'user=', '');
  TokenReceived := ReplaceStr(Params[1], 'token=', '');
  AuctionID := StrToInt(ReplaceStr(Params[3], 'auctionid=', ''));
  Login := ReplaceStr(Params[4], 'login=', '');
  vendedor := ReplaceStr(Params[5], 'vendedor=', '');

  // aqui vai verificar se o player tá logado no jogo
  PlayerStatus := False;
  ServerID := 255;
  for I := Low(Servers) to High(Servers) do
  begin
    ClientID := Servers[I].GetPlayerByName(UsernameReceived);
    ClientID1 := Servers[I].GetPlayerByUsername(Login);
    if (ClientID <> 0) then
    begin
      ServerID := I;
      break;
    end;
    if (ClientID1 <> 0) then
    begin
      ServerID := I;
      break;
    end;

  end;

  if (ServerID = 255) then
  begin

    Writeln('Player deslogado');
    PlayerStatus := False;

  end
  else
  begin

    if ClientID1 > 0 then
      Status := 'seleção'
    else if ClientID > 0 then
      Status := 'jogo';

    Writeln('Player logado');
    PlayerStatus := True;

  end;





  // aqui só serve pra setar o playerstts e o serverid e o clientid


  // Valor := StrToInt(ReplaceStr(Params[4], 'valor=', ''));

  if (Length(TokenReceived) <> Length(ASAAS_TOKEN_PINGBACK)) then
  begin
    Response := '{ "error": "TOKEN_INVALIDO1" }';
    Exit;
  end;

  if (TokenReceived <> ASAAS_TOKEN_PINGBACK) then
  begin
    Response := '{ "error": "TOKEN_INVALIDO2" }';
    Exit;
  end;

  if (trim(UsernameReceived) = '') or (Length(UsernameReceived) < 4) then
  begin
    Response := '{ "error": "INVALID_USERNAME" }';
    Exit;
  end;

  try
    ProductReceived := StrToInt(ReplaceStr(Params[2], 'value=', ''));
  except
    on E: Exception do
    begin
      Response := '{ "error": "VALOR_INVALIDO" }';
      Exit;
    end;
  end;

  try
    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), True);

    // Montar a consulta SQL para buscar o id do usuário
    QueryString := 'SELECT id FROM characters WHERE name = :UsernameReceived';

    // Definir a consulta
    SQLComp.SetQuery(QueryString);

    // Definir o parâmetro da consulta
    SQLComp.Query.ParamByName('UsernameReceived').AsString := UsernameReceived;

    // Executar a consulta
    SQLComp.Run(True);

    // Verificar se há resultados na consulta
    if SQLComp.Query.EOF then
    begin
      Response := '{ "error": "USUARIO_DESCONHECIDO" }';
      Exit;
    end
    else
    begin
      CharacterID := SQLComp.Query.FieldByName('id').AsInteger;
      // // Obter o CharacterID após verificar que a consulta retornou resultados
      //
      // Response := 'CharacterId: ' + CharacterID.ToString + ' Username: ' + UsernameReceived;
      // Exit;
    end;

  finally
    SQLComp.Free;
  end;

  try

    // Criar o objeto de consulta
    SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
      AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
      AnsiString(MYSQL_DATABASE), True);

    // Verificar se a conexão foi estabelecida
    if not SQLComp.Query.Connection.Connected then
    begin
      Logger.Write
        ('Falha de conexão individual com MySQL.[VerificarLeilaoAtivo]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[VerificarLeilaoAtivo]',
        TlogType.Error);
      SQLComp.Free;
      Exit;
    end;

    // Montar a consulta SQL
    QueryString :=
      'SELECT COUNT(*) AS Total FROM leilao_site WHERE AuctionId = :AuctionId AND Active = 1';

    // Definir a consulta
    SQLComp.SetQuery(QueryString);
    var
      AuctionIDS: Integer;
      // Definir o parâmetro da consulta
    SQLComp.Query.ParamByName('AuctionId').AsInteger := AuctionID;

    // Executar a consulta
    SQLComp.Run(True);

    // Obter o resultado da consulta
    var
    Total := SQLComp.Query.FieldByName('Total').AsInteger;

    // Verificar se existe algum registro correspondente
    Result := Total > 0;

    // Retornar erro caso não exista nenhum registro
    if Total = 0 then
    begin
      Response := '{ "error": "ITEM_INDISPONIVEL" }';
      Exit;
    end;
  finally
    // Garantir a liberação do recurso
    SQLComp.Free;
  end;

  if (1 = 1) then
  begin
    if (ProductReceived > 0) then
    begin

{$REGION EFETUA A COBRANÇA}
      if (PlayerStatus = False) then
      // aqui vai fazer ação se o player tiver deslogado
      begin
        // Response := '{ "error": "cheguei aq" }';
        // Exit;
        // if (ClientID <> 0) or (ClientID1 <> 0) then
        // begin
        // //aqui vai fazer a redução via db
        // end;
        //

        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE), True);

        QueryString := 'SELECT cash FROM accounts WHERE username = :Login;';
        SQLComp.SetQuery(QueryString);

        SQLComp.Query.ParamByName('Login').AsString := Login;

        SQLComp.Run(True); // Execute e capture o resultado da consulta

        Quantidade := SQLComp.Query.FieldByName('cash').AsInteger;

        if (ProductReceived > Quantidade) then
        begin
          Writeln(PlayerCash.ToString);
          Response := '{ "error": "CASH_INSUFICIENTE" }';
          Exit; // Saindo sem executar a remoção
        end
        else
        begin

          QueryString :=
            'UPDATE accounts SET cash = cash - :QuantidadeRemover WHERE username = :Login;';
          SQLComp.SetQuery(QueryString);

          SQLComp.Query.ParamByName('Login').AsString := Login;
          SQLComp.Query.ParamByName('QuantidadeRemover').AsInteger :=
            ProductReceived;

          SQLComp.Run(False); // Execute a consulta

        end;

        SQLComp.Free;
        // aqui vai remover o cash com o player deslogado, usando o valor login pra fazer o where na db e reduzir via query
      end
      else
      begin // aqui vai fazer a ação se o player tiver logado

        PlayerCash := Servers[ServerID].Players[ClientID1]
          .Account.Header.CashInventory.Cash;

        // Verificando se o valor a ser recebido é maior que o saldo do jogador
        if (ProductReceived > PlayerCash) then
        begin
          Writeln(PlayerCash.ToString);
          Response := '{ "error": "CASH_INSUFICIENTE" }';
          Exit; // Saindo sem executar a remoção
        end;

        if Status = 'seleção' then
        begin
          Writeln('removendo na tela de seleção');
          Servers[ServerID].Players[ClientID1].SendClientMessage
            ('Item comprado no leilão web, abra seu correio!', 16, 32, 16);
          Servers[ServerID].Players[ClientID1].DecCash(ProductReceived);
        end
        else if Status = 'jogo' then
        begin
          Writeln('removendo com o personagem em jogo');
          Servers[ServerID].Players[ClientID].SendClientMessage
            ('Item comprado no leilão web, abra seu correio!', 16, 32, 16);
          Servers[ServerID].Players[ClientID].DecCash(ProductReceived);
        end
        else
        begin
          Exit;
          // Caso não seja nem 'seleção' nem 'jogo', você pode adicionar uma lógica adicional aqui, caso necessário
        end;

      end;

{$ENDREGION}
      AcquisitionMailId := 0;

      SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE), True);
      if not(SQLComp.Query.Connection.Connected) then
      begin
        Logger.Write('Falha de conexão individual com mysql.[RequestBuyItem]',
          TlogType.Warnings);
        Logger.Write('PERSONAL MYSQL FAILED LOAD.[RequestBuyItem]',
          TlogType.Error);
        SQLComp.Free;
        Exit;
      end;

      // Inserir o registro em "mails" e obter o ID gerado automaticamente
      QueryString :=
        Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, '
        + 'textBody, slot, sentGold, gold, returnDate, sentDate, isFromAuction, canReturn, hasItems) '
        + 'VALUES (%d, 1, "Marketplace", "Item Comprado", "Entrega de item adquirido no Marketplace", 0, '
        + '0, 0, "%s", "%s", 1, 0, 1); SELECT LAST_INSERT_ID() AS LastMailId;',
        [CharacterID, FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(Now, 90)),
        FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]);
      // Writeln('Query: ' + QueryString);
      SQLComp.SetQuery(QueryString);
      SQLComp.Query.Connection.StartTransaction;
      SQLComp.Run(True); // Execute e capture o resultado da consulta
      SQLComp.Query.Connection.Commit;

      // Obter o Mail ID gerado
      AcquisitionMailId := SQLComp.Query.FieldByName('LastMailId').AsLargeInt;
      if AcquisitionMailId = 0 then
      begin
        SQLComp.Free;
        Exit(False);
      end;
      SQLComp.Free;

      // Inserir os itens relacionados ao "mail" no "mails_items"
      SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE), True);

      QueryString :=
        Format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, effect1_index, effect1_value, '
        + 'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, `time`) '
        + 'SELECT %d AS MailIndex, 0, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, EffectValue_1, EffectId_2, EffectValue_2, '
        + 'EffectId_3, EffectValue_3, DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime '
        + 'FROM %s.leilao_site WHERE AuctionId=%d;',
        [AcquisitionMailId, MYSQL_DATABASE, AuctionID]);

      // Writeln('Query: ' + QueryString);
      SQLComp.SetQuery(QueryString);
      SQLComp.Query.Connection.StartTransaction;
      SQLComp.Run(False);
      SQLComp.Query.Connection.Commit;

      if (SQLComp.Query.RowsAffected = 0) then
      begin
        SQLComp.Free;
        Exit(False);
      end;
      SQLComp.Free;

      // Atualizar o status do leilão
      SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
        AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
        AnsiString(MYSQL_DATABASE), True);

      QueryString :=
        Format('UPDATE leilao_site SET Active=0 WHERE AuctionId=%d;',
        [AuctionID]);
      SQLComp.SetQuery(QueryString);
      SQLComp.Query.Connection.StartTransaction;
      SQLComp.Run(False);
      SQLComp.Query.Connection.Commit;

      if (SQLComp.Query.RowsAffected = 0) then
      begin
        SQLComp.Free;
        Exit(False);
      end;
      SQLComp.Free;

      if (2 = 2) then // entrega o preço pro vendedor
      begin
        SQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE), True);

        // Montar a consulta SQL para buscar o id do usuário
        QueryString :=
          'SELECT id FROM characters WHERE name = :UsernameReceived';

        // Definir a consulta
        SQLComp.SetQuery(QueryString);

        // Definir o parâmetro da consulta
        SQLComp.Query.ParamByName('UsernameReceived').AsString := vendedor;

        // Executar a consulta
        SQLComp.Run(True);

        var
        Vendedor1 := SQLComp.Query.FieldByName('id').AsInteger;

        QueryString :=
          Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, '
          + 'textBody, slot, sentGold, gold, returnDate, sentDate, isFromAuction, canReturn, hasItems) '
          + 'VALUES (%d, 1, "leilao", "Item Vendido", "Item vendido no Web Leilao", 0, '
          + '0, %d, "%s", "%s", 1, 0, 1);', [Vendedor1, ProductReceived,
          FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(Now, 90)),
          FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]);
        // Writeln('Query: ' + QueryString);
        SQLComp.SetQuery(QueryString);
        SQLComp.Run(False); // Execute e capture o resultado da consulta

        SQLComp.Free;

      end;

    end;
  end
  else
  begin
    Response := '{ "error": "User isn' + #39 + 't online." }';
    Exit;
  end;
  // Servers[ServerID].Players[ClientID].Base.Character.CharIndex
  Response := '{ "success": "ITEM_ADDED" }' + CharacterID.ToString;
end;

end.
