unit Functions;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Player, BaseMob, MiscData, Packets, IdHashMessageDigest, PlayerData,
  SysUtils, GuildData, StrUtils, Data.DB, System.AnsiStrings, Windows, SQL;

type
  TByteArr = ARRAY OF BYTE;

type
  TFunctions = class(TObject)
  public
    class procedure DumpBasicCharacterToTxt(const FName: string;
      const BasicCharacter: TBasicCharacter);
    { String Functions }
    class function CreateSQL: TQuery;
    class function IsLetter(Text: String): Boolean;
    class function CharArrayToString(Chars: ARRAY OF AnsiChar): string;
    class function StringToMd5(TextStr: string): string;
    class function ByteArrToString(const Buffer: ARRAY OF BYTE)
      : string; overload;
    class function ByteArrToString(const Buffer: ARRAY OF BYTE; Len: word)
      : string; overload;
    class function StrToFile(Texto: string; FileName: String): Boolean;
    class function StrToArray(const BufferStr: string;
      var Buffer: array of BYTE): Integer;
    class function GetPacketStrLen(const BufferStr: string): Integer;
    { Client ID Functions }
    class function FreeClientId(Server: BYTE): Integer;
    class function ClientId(Server: BYTE; IP: string): Integer;
    // class function FreePetId(Server: BYTE): Integer;
    { Title Functions }
    class function GetTitleLevelValue(Slot, Level: BYTE): UInt32;
    { Pran Functions }
    class function GetPranCreationID(var Player: TPlayer; AccID: Integer;
      CreatedAt: DWORD): Integer;
    class function SavePranCreated(var Player: TPlayer;
      var Pran: TPran): Boolean;
    class function VerifyNameAlreadyExists(var Player: TPlayer;
      Name: String): Boolean;
    { Character File Functions }
    // class procedure SaveCharacterFile(const Player: TPlayer; characterName: string);
    // class function FindCharacter(characterName: string): Boolean;
    class function GetCharacterAccount(characterName: string;
      out Account: string): Boolean;
    class function GetCharacterNation(characterName: string;
      out Nation: TCitizenship): Boolean;
    { Guild File Functions }
    class procedure SaveGuilds(GuildX: Cardinal = 0);
    class function SearchGuildByName(Name: String): PGuild;
    { Account File Functions }
    class procedure SaveAccountFile(const Account: TAccountFile;
      AccountName: string; AccountNamePure: String);
    class function GetAccountsBackup(var Player: TPlayer; TypeOf: Integer;
      AccountName: string): Boolean;
    class procedure ManageAccountsBackupCount(var Player: TPlayer;
      AccountName: string);
    class function FindAccount(AccountName: string): Boolean;
    { Trade Functions }
    class function ExecuteTrade(var Player: TPlayer; var OtherPlayer: TPlayer)
      : Boolean; overload;
    class function ExecuteTrade(var Player: TPlayer; OtherPlayer: PPlayer)
      : Boolean; overload;
    { File Functions }
    class function GetFileSize(const FileName: string): UInt64;
    class function LoadPacket(PacketName: string;
      var Buffer: ARRAY OF BYTE): Boolean;
    class function LoadBasicCharacter(FName: string;
      var Character: TCharacterDB): Boolean;
    class function SaveBasicCharacter(FName: string;
      const Character: TCharacterDB): Boolean;
    class function CreateBasicCharacter(FName: string; Classe: Integer)
      : Boolean;
    class function GetFilesCount(Diretorio, Pesquisa: string): Integer;
    // class function IncAccountsCount: Cardinal;
    class function IncCharactersCount(SelfPlayer: PPlayer): Cardinal;
    class function DecCharactersCount(SelfPlayer: PPlayer): Cardinal;
    { EncDec Files }
    class function EncDecSL(var Buffer: ARRAY OF BYTE; Encrypt: Boolean)
      : Boolean; overload;
    class function EncDecSL(Buffer: Pointer; Size: UInt64; Encrypt: Boolean)
      : Boolean; overload;
    { Load Functions }
    class function LoadSL(FileName: string): Boolean;
    { Save Functions }
    class function SaveSL(FileName: string): Boolean;
    { Time Functions }
    class function Time(): String; static;
    class function UNIXTimeToDateTimeFAST(UnixTime: Int64): TDateTime; static;
    class function DateTimeToUNIXTimeFAST(DelphiTime: TDateTime): Int64; static;
    class function ReTime(Time: String): TDateTime;
    { MakeItems }
    class function SearchMakeItemIDByRewardID(RewardID: word): word;

    { test functions apagar dps }


    class function IFThen(cond: boolean; aTrue: variant; aFalse: variant): variant; overload;
    class function IFThen(cond: boolean): boolean; overload;



    class function IsPlayerPlaying(Player: PPlayer):boolean;
    class procedure SavePlayerPrincipal(Player: PPlayer; CharID: byte);
    class procedure SavePlayerSecundario(Player: PPlayer; CharID: byte);

    // class procedure GetMakeItems();
    // class procedure GetMakeItemsIngredients();
  end;

implementation

uses
  GlobalDefs, Log, Classes, ItemFunctions, PsApi,
  SkillFunctions, FilesData, DateUtils;

{$REGION 'String Functions'}

class function TFunctions.IsLetter(Text: String): Boolean;
const
  ALPHA_CHARS = ['a' .. 'z', 'A' .. 'Z', '0' .. '9'];
var
  i: Integer;
begin
  Result := Length(Text) > 0;
  for i := 1 to Length(Text) do
  begin
    if not(CharInSet(Text[i], ALPHA_CHARS)) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

class function TFunctions.CharArrayToString(Chars: ARRAY OF AnsiChar): string;
begin
  if Length(Chars) > 0 then
    SetString(Result, PAnsiChar(@Chars[0]), Length(Chars))
  else
    Result := '';
  Result := Trim(Result);
end;

class function TFunctions.StringToMd5(TextStr: string): string;
var
  idmd5: TIdHashMessageDigest5;
begin
  idmd5 := TIdHashMessageDigest5.Create;
  try
    Result := LowerCase(idmd5.HashStringAsHex(TextStr));
  finally
    idmd5.Free;
  end;
end;

class function TFunctions.ByteArrToString(const Buffer: array of BYTE): string;
var
  i: Integer;
begin
  for i := 0 to Length(Buffer) - 1 do
    Result := Result + IntToHex(Buffer[i], 2) + ' ';
end;

class function TFunctions.ByteArrToString(const Buffer: array of BYTE;
  Len: word): string;
var
  i: Integer;
begin
  for i := 0 to Len - 1 do
  begin
    Result := Result + IntToHex(Buffer[i], 2) + ' ';
  end;
end;

class function TFunctions.StrToFile(Texto: string; FileName: string): Boolean;
var
  F: TextFile;
begin
  Result := True;
  try
    AssignFile(F, FileName);
    ReWrite(F);
    Writeln(F, Texto);
    CloseFile(F);
  except
    Result := False;
  end;
end;

class function TFunctions.StrToArray(const BufferStr: string;
  var Buffer: array of BYTE): Integer;
var
  i: Integer;
  Data: TStringList;
begin
  Result := 0;
  Data := TStringList.Create;
  if (Length(BufferStr) > 1) then
  begin
    try
      Data.Delimiter := ' ';
      Data.DelimitedText := BufferStr;
      Result := Data.Count;
      if (Data.Count > 0) then
        for i := 0 to (Data.Count - 1) do
          Buffer[i] := StrToInt('$' + Data[i]);
    except
      on E: Exception do
      begin
        Result := 0;
        E.Free;
      end;
    end;
  end;
end;

class function TFunctions.GetPacketStrLen(const BufferStr: string): Integer;
var
  Data: TStringList;
begin
  Data := TStringList.Create;
  try
    Data.Delimiter := ' ';
    Data.DelimitedText := BufferStr;
    Result := Data.Count;
  except
    on E: Exception do
    begin
      Result := 0;
      E.Free;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Client Id Functions'}

class function TFunctions.ClientId(Server: BYTE; IP: string): Integer;
begin
  for Result := 1 to MAX_CONNECTIONS do
    if Servers[Server].Players[Result].IP = IP then
      Exit;
  Result := 0;
end;

class function TFunctions.FreeClientId(Server: BYTE): Integer;
begin
  for Result := 1 to MAX_CONNECTIONS do
    if Servers[Server].Players[Result].Base.ClientId = 0 then
      Exit;
  Result := 0;
end;

// class function TFunctions.FreePetId(Server: BYTE): Integer;
// begin
// for Result := Low(Servers[Server].PETS) to High(Servers[Server].PETS) do
// if not Servers[Server].PETS[Result].Base.IsActive then
// Exit;
// Result := 0;
// end;

{$ENDREGION}
{$REGION 'Title Functions'}

class function TFunctions.GetTitleLevelValue(Slot, Level: BYTE): UInt32;
begin
  if Level > 1 then
    Result := (1 shl ((Slot * 4) + (Level - 1))) + Self.GetTitleLevelValue(Slot,
      Level - 1)
  else
    Result := 1 shl ((Slot * 4) + (Level - 1));
end;

class function TFunctions.CreateSQL: TQuery;
begin
  // Criando a conexão usando as variáveis globais já definidas
  Result := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
end;

{$ENDREGION}
{$REGION 'Pran Functions'}

class function TFunctions.GetPranCreationID(var Player: TPlayer; AccID: Integer;
  CreatedAt: DWORD): Integer;
var
  SQLComp: TQuery;
begin
  Result := -1; // Inicializando com o valor padrão para PranCount
  if CreatedAt = 0 then
    Exit;

  SQLComp := Self.CreateSQL;
  try
    if not SQLComp.Query.Connection.Connected then
    begin
      Logger.Write('Falha de conexão individual com mysql.[GetPranCreationID]',
        TLogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetPranCreationID]',
        TLogType.Error);
      Exit;
    end;

    SQLComp.SetQuery
      (Format('SELECT id FROM prans WHERE acc_id=%d AND created_at=%d',
      [AccID, CreatedAt]));
    SQLComp.Run;
    if SQLComp.Query.RecordCount > 0 then
      Result := SQLComp.Query.Fields[0].AsInteger;
  except
    on E: Exception do
      Logger.Write('TFunctions.GetPranCreationID error MYSQL ' + E.Message +
        ' at ' + DateTimeToStr(Now), TLogType.Error);
  end;
  SQLComp.Free;
end;

class function TFunctions.SavePranCreated(var Player: TPlayer;
  var Pran: TPran): Boolean;
var
  i: Integer;
  SuccessSaved: Boolean;
  PranID: Integer;
  SQLComp: TQuery;
begin
  SuccessSaved := False;
  SQLComp := Self.CreateSQL;

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SavePranCreated]',
      TLogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SavePranCreated]',
      TLogType.Error);
    SQLComp.Free;
    Exit;
  end;

  try
    // Inserção dos dados principais da pran
    SQLComp.SetQuery
      (Format('INSERT INTO prans (acc_id, char_id, name, food, devotion, p_cute, p_smart, '
      + 'p_sexy, p_energetic, p_tough, p_corrupt, level, class, hp, max_hp, mp, max_mp, '
      + 'xp, def_p, def_m, width, chest, leg, updated_at, created_at) VALUES (%d, %d, %s, %d, %d, %d, %d, '
      + '%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
      [Pran.AccID, Player.Character.Base.CharIndex, QuotedStr(String(Pran.Name)
      ), Pran.Food, Pran.Devotion, Pran.Personality.Cute,
      Pran.Personality.Smart, Pran.Personality.Sexy, Pran.Personality.Energetic,
      Pran.Personality.Tough, Pran.Personality.Corrupt, Pran.Level,
      Pran.ClassPran, Pran.CurHP, Pran.MaxHp, Pran.CurMp, Pran.MaxMP, Pran.Exp,
      Pran.DefFis, Pran.DefMag, Pran.Width, Pran.Chest, Pran.Leg,
      Pran.Updated_at, Pran.CreatedAt]));
    SQLComp.Run(False);

    // Obtendo ID da pran criada
    PranID := Self.GetPranCreationID(Player, Pran.AccID, Pran.CreatedAt);
    if PranID > 0 then
    begin
      Pran.Iddb := PranID;
      Pran.ItemID := PranID;

      // Atualiza item_id na pran
      SQLComp.SetQuery(Format('UPDATE prans SET item_id=%d WHERE id=%d',
        [Pran.Iddb, PranID]));
      SQLComp.Run(False);

      SuccessSaved := True;
    end;

  except
    if not SuccessSaved then
    begin
      Player.SendClientMessage('Erro de criação de pran, contate o suporte.');
      ZeroMemory(@Pran, sizeof(TPran));
      SQLComp.Free;
      Exit;
    end;

  end;

  // Inserir equipamentos
  for i := 0 to 15 do
  begin
    with Pran.Equip[i] do
    begin
      if Index = 0 then
        Continue;

      SQLComp.SetQuery
        (Format('INSERT INTO items (slot_type, owner_id, slot, item_id, app, effect1_index, effect1_value, '
        + 'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, time) VALUES '
        + '(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
        [PRAN_EQUIP_TYPE, Pran.Iddb, i, Index, APP, Effects.Index[0],
        Effects.Value[0], Effects.Index[1], Effects.Value[1], Effects.Index[2],
        Effects.Value[2], MIN, MAX, Refi, Time]));
      SQLComp.Run(False);
    end;
  end;

  // Inserir inventário
  for i := 0 to 41 do
  begin
    with Pran.Inventory[i] do
    begin
      if Index = 0 then
        Continue;

      SQLComp.SetQuery
        (Format('INSERT INTO items (slot_type, owner_id, slot, item_id, app, effect1_index, effect1_value, '
        + 'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, time) VALUES '
        + '(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
        [PRAN_INV_TYPE, Pran.Iddb, i, Index, APP, Effects.Index[0],
        Effects.Value[0], Effects.Index[1], Effects.Value[1], Effects.Index[2],
        Effects.Value[2], MIN, MAX, Refi, Time]));
      SQLComp.Run(False);
    end;
  end;

  // Inserir habilidades
  for i := 0 to 9 do
  begin
    with Pran.Skills[i] do
    begin
      if Index = 0 then
        Continue;

      SQLComp.SetQuery
        (Format('INSERT INTO skills (owner_charid, slot, item, level, type) VALUES (%d, %d, %d, %d, %d)',
        [Pran.Iddb, i, Index, Level, 3]));
      SQLComp.Run(False);
    end;
  end;
  SQLComp.Free;
  Result := True;
end;

class function TFunctions.VerifyNameAlreadyExists(var Player: TPlayer;
  Name: String): Boolean;
var
  SQLComp: TQuery;
begin
  Result := False;
  SQLComp := Self.CreateSQL;
  with SQLComp.Query.Connection do
  begin
    if not Connected then
    begin
      Logger.Write
        ('Falha de conexão individual com mysql.[VerifyNameAlreadyExists]',
        TLogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[VerifyNameAlreadyExists]',
        TLogType.Error);
      SQLComp.Free;
      Exit;
    end;
  end;

  try
    SQLComp.SetQuery(Format('SELECT id FROM prans WHERE name=%s',
      [QuotedStr(Name)]));
    SQLComp.Run;
    if SQLComp.Query.RecordCount > 0 then
      Result := True;
  except
    Logger.Write('MySQL Error player PRAN name exists. ' +
      String(Player.Base.Character.Name), TLogType.Error);
  end;

  SQLComp.Free;
end;

{$ENDREGION}
{$REGION 'Character File Functions'}

{
  class function TFunctions.FindCharacter(characterName: string): Boolean;
  var
  local: string;
  begin
  if (IsLetter(characterName)) then
  local := DATABASE_PATH + 'Chars\' + LowerCase(characterName[1]) + '\' +
  Trim(characterName) + '.char'
  else
  local := DATABASE_PATH + 'Chars\etc\' + Trim(characterName) + '.char';
  if (FileExists(local)) then
  Result := True
  else
  Result := False;
  end;
}
class function TFunctions.GetCharacterAccount(characterName: string;
  out Account: string): Boolean;
var
  AccountID: Integer;
  SQLComp: TQuery;
begin
  Result := False;
  SQLComp := Self.CreateSQL;

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetCharacterAccount]',
      TLogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetCharacterAccount]',
      TLogType.Error);
    SQLComp.Free;
    Exit;
  end;

  // Agrupar a consulta e verificação da primeira consulta.
  SQLComp.SetQuery('SELECT owner_accid FROM characters WHERE name=:pname');
  SQLComp.AddParameter('pname', AnsiString(characterName));
  SQLComp.Run();

  if SQLComp.Query.IsEmpty then
  begin
    SQLComp.Free;
    Exit;
  end;

  AccountID := SQLComp.Query.FieldByName('owner_accid').AsInteger;

  // Agrupar a consulta e verificação da segunda consulta.
  SQLComp.SetQuery('SELECT username FROM accounts WHERE id=:pid');
  SQLComp.AddParameter('pid', AnsiString(IntToStr(AccountID)));
  SQLComp.Run();

  if SQLComp.Query.IsEmpty then
  begin
    SQLComp.Free;
    Exit;
  end;

  Account := SQLComp.Query.FieldByName('username').AsString;
  Result := True;
end;

class function TFunctions.GetCharacterNation(characterName: string;
  out Nation: TCitizenship): Boolean;
var
  Player: TPlayer;
  SQLComp: TQuery;
begin
  Result := False;
  ZeroMemory(@Player, sizeof(TPlayer));
  SQLComp := Self.CreateSQL;

  // Verificar se a conexão está ativa de maneira mais eficiente
  if not SQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetCharacterNation]',
      TLogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetCharacterNation]',
      TLogType.Error);
    SQLComp.Free;
    Exit;
  end;

  try
    SQLComp.SetQuery('SELECT accounts.nation as `nation` FROM characters ' +
      'INNER JOIN accounts ON accounts.id = characters.owner_accid ' +
      'WHERE characters.name = :pcharacter_name LIMIT 1');
    SQLComp.AddParameter2('pcharacter_name', characterName);
    SQLComp.Run();

    // Verificar se o registro foi encontrado e atribuir o valor de forma mais eficiente
    if SQLComp.Query.RecordCount > 0 then
    begin
      Nation := TCitizenship(SQLComp.Query.FieldByName('nation').AsInteger);
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on getting character account nation. msg[' +
        E.Message + ' : ' + E.GetBaseException.Message + '] characterName [' +
        String(characterName) + '] ' + DateTimeToStr(Now) + '.',
        TLogType.Error);
    end;
  end;

  SQLComp.Free;
end;

{
  class procedure TFunctions.SaveCharacterFile(const Player: TPlayer;
  characterName: string);
  var
  F: TextFile;
  local: string;
  begin
  if (IsLetter(characterName)) then
  begin
  if not DirectoryExists(DATABASE_PATH + 'Chars\' +
  LowerCase(characterName[1])) then
  forceDirectories(DATABASE_PATH + 'Chars\' + LowerCase(characterName[1]));
  local := DATABASE_PATH + 'Chars\' + LowerCase(characterName[1]) + '\' +
  Trim(characterName) + '.char';
  end
  else
  begin
  if not DirectoryExists(DATABASE_PATH + 'Chars\etc') then
  forceDirectories(DATABASE_PATH + 'Chars\etc');
  local := DATABASE_PATH + 'Chars\etc\' + Trim(characterName) + '.char';
  end;
  AssignFile(F, local);
  ReWrite(F);
  Writeln(F, Player.Account.Header.Username);
  CloseFile(F);
  end;
}
{$ENDREGION}
{$REGION 'Guild File Functions'}

class procedure TFunctions.SaveGuilds(GuildX: Cardinal);
var
  i, m: Integer;
  Member: PPlayerFromGuild;
  Item: PItem;
  MySQLComp: TQuery;
begin
  MySQLComp := Self.CreateSQL;

  if not MySQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SAVE_GUILDS]',
      TLogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SAVE_GUILDS]', TLogType.Error);
    Exit;
  end;

  for i := Low(Guilds) to High(Guilds) do
  begin
    if GuildX > 0 then
    begin
      if GuildX <> i then
        Continue;
    end;

    with Guilds[i] do
    begin
      if Index > 0 then
      begin
        if TotalMembers > 128 then
          TotalMembers := 128;

        MySQLComp.Query.Connection.StartTransaction;
        try
          MySQLComp.SetQuery('UPDATE guilds SET experience=' + Exp.ToString +
            ', level=' + Level.ToString + ', totalmembers=' +
            TotalMembers.ToString + ', bravurepoints=' + BravurePoints.ToString
            + ',' + ' skillpoints=' + SkillPoints.ToString + ', promote=' +
            Promote.ToInteger.ToString + ', notice1="' + String(Notices[0].Text)
            + '",' + ' notice2="' + String(Notices[1].Text) + '",' +
            ' notice3="' + String(Notices[2].Text) + '",' + ' site="' +
            String(Site) + '", rank1=' + RanksConfig[0].ToString + ',' +
            ' rank2=' + RanksConfig[1].ToString + ', rank3=' + RanksConfig[2]
            .ToString + ', rank4=' + RanksConfig[3].ToString + ', rank5=' +
            RanksConfig[4].ToString + ',' + ' ally_leader=' +
            Ally.Leader.ToString + ', guild_ally1_index=' + Ally.Guilds[0].
            Index.ToString + ',' + ' guild_ally1_name="' +
            String(Ally.Guilds[0].Name) + '", ' + ' guild_ally2_index=' +
            Ally.Guilds[1].Index.ToString + ',' + ' guild_ally2_name="' +
            String(Ally.Guilds[1].Name) + '", ' + ' guild_ally3_index=' +
            Ally.Guilds[2].Index.ToString + ',' + ' guild_ally3_name="' +
            String(Ally.Guilds[2].Name) + '", ' + ' guild_ally4_index=' +
            Ally.Guilds[3].Index.ToString + ',' + ' guild_ally4_name="' +
            String(Ally.Guilds[3].Name) + '", ' + ' storage_gold=' +
            Chest.Gold.ToString + ', leader_char_index=' +
            GuildLeaderCharIndex.ToString + ' WHERE id=' +
            Index.ToString + ';');

          MySQLComp.Run(False);
          MySQLComp.Query.Connection.Commit;
        except
          on E: Exception do
          begin
            MySQLComp.Query.Connection.Rollback;
            Logger.Write('Não foi possivel salvar dados da guild: ' +
              String(Name) + ' [Erro MySQL] ' + E.Message, TLogType.Error);
          end;
        end;

        // Save Guild Members
        MySQLComp.Query.Connection.StartTransaction;
        try
          MySQLComp.SetQuery('DELETE FROM guilds_players WHERE guild_index=' +
            Index.ToString + ';');
          MySQLComp.Run(False);

          for m := 0 to 127 do
          begin
            if Members[m].CharIndex = 0 then
              Continue;
            Member := @Members[m];

            MySQLComp.SetQuery
              ('INSERT INTO guilds_players (guild_index, char_index, name, player_rank, '
              + 'classinfo, level, logged, last_login) VALUES (' +
              Index.ToString + ', ' + Member.CharIndex.ToString + ', "' +
              String(Member.Name) + '", ' + Member.Rank.ToString + ', ' +
              Member.ClassInfo.ToString + ', ' + Member.Level.ToString + ', ' +
              Member.Logged.ToInteger.ToString + ', ' +
              Member.LastLogin.ToString + ')');
            MySQLComp.Run(False);
          end;

          MySQLComp.Query.Connection.Commit;
        except
          on E: Exception do
          begin
            MySQLComp.Query.Connection.Rollback;
            Logger.Write('Não foi possivel salvar dados da guild: ' +
              String(Name) + ' [Erro MySQL] ' + E.Message, TLogType.Error);
          end;
        end;

        // Save Guild Items
        MySQLComp.Query.Connection.StartTransaction;
        try
          MySQLComp.SetQuery('DELETE FROM items WHERE slot_type=3 AND owner_id='
            + Index.ToString + ';');
          MySQLComp.Run(False);

          for m := 0 to 49 do
          begin
            if Chest.Items[m].Index = 0 then
              Continue;
            Item := @Chest.Items[m];

            MySQLComp.SetQuery
              ('INSERT INTO items (slot_type, owner_id, slot, item_id, ' +
              'app, effect1_index, effect1_value, effect2_index, effect2_value, '
              + 'effect3_index, effect3_value, min, max, refine, time) VALUES '
              + '(3, ' + Index.ToString + ', ' + m.ToString + ', ' + Item.
              Index.ToString + ', ' + Item.APP.ToString + ', ' + Item.Effects.
              Index[0].ToString + ', ' + Item.Effects.Value[0].ToString + ', ' +
              Item.Effects.Index[1].ToString + ', ' + Item.Effects.Value[1]
              .ToString + ', ' + Item.Effects.Index[2].ToString + ', ' +
              Item.Effects.Value[2].ToString + ', ' + Item.MIN.ToString + ', ' +
              Item.MAX.ToString + ', ' + Item.Refi.ToString + ', ' +
              Item.Time.ToString + ')');
            MySQLComp.Run(False);
          end;

          MySQLComp.Query.Connection.Commit;
        except
          on E: Exception do
          begin
            MySQLComp.Query.Connection.Rollback;
            Logger.Write('Não foi possivel salvar dados da guild: ' +
              String(Name) + ' [Erro MySQL] ' + E.Message, TLogType.Error);
          end;
        end;
      end;
    end;
  end;

  MySQLComp.Free;
end;

class function TFunctions.SearchGuildByName(Name: String): PGuild;
var
  i: Integer;
begin
  Result := nil;
  Name := Name.ToUpper; // Transforma 'Name' para maiúsculo uma vez

  for i := Low(Guilds) to High(Guilds) do
  begin
    with Guilds[i] do
    begin
      if (Index = 0) then
        Continue;
      if (String(Name) = Name) then
      // Compara diretamente com o 'Name' já convertido
      begin
        Result := @Guilds[i];
        Break; // Encerra o loop ao encontrar a guilda
      end;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Account File Functions'}

class procedure TFunctions.SaveAccountFile(const Account: TAccountFile;
  AccountName: string; AccountNamePure: String);
var
  F: File of TAccountFile;
  FileName: string;
begin
  try
    if not DirectoryExists('Data\ACCS\' + AccountNamePure) then
      ForceDirectories('Data\ACCS\' + AccountNamePure);

    FileName := 'Data\ACCS\' + AccountNamePure + '\' + AccountName + '.acc';

    AssignFile(F, FileName);
    try
      ReWrite(F);
      Write(F, Account);
    finally
      CloseFile(F);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.SaveAccountFile ' + E.Message + ' t: ' +
        DateTimeToStr(Now), TLogType.Error);
    end;
  end;
end;

class function TFunctions.GetAccountsBackup(var Player: TPlayer;
  TypeOf: Integer; AccountName: string): Boolean;
type
  TAccountsBackup = packed record
    xfileName: String;
    xAcc: TAccountFile;
  end;
var
  F: TSearchRec;
  Ret, j, quest_cnt, xCnt: Integer;
  TempNome: String;
  xAccount: TAccountFile;
  xF: File of TAccountFile;
  xAccs: Array of TAccountsBackup;
  i: BYTE;
  Packet: TReceivePlayerAccountFiles;
  MySQLComp: TQuery;
begin
  if (TypeOf = 1) then
  begin
    MySQLComp := Self.CreateSQL;
    if not(MySQLComp.Query.Connection.Connected) then
    begin
      Logger.Write
        ('Falha de conexão individual com mysql.[Functions::GetAccountsBackup]',
        TLogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[Functions::GetAccountsBackup]',
        TLogType.Error);
      Exit;
    end;

    MySQLComp.SetQuery
      ('SELECT a.username from characters c inner join accounts a on a.id = c.owner_accid'
      + ' WHERE c.name = ' + QuotedStr(AccountName));
    MySQLComp.Run();

    if (MySQLComp.Query.RecordCount > 0) then
    begin
      AccountName := MySQLComp.Query.FieldByName('username').AsString;
    end;
  end;

  try
    Ret := FindFirst(DATABASE_PATH + 'ACCS\' + AccountName + '\*.acc',
      faAnyFile, F);
    xCnt := 1;

    while Ret = 0 do
    begin
      TempNome := ReplaceStr(F.Name, '.acc', '');

      ZeroMemory(@xAccount, sizeof(xAccount));

      AssignFile(xF, DATABASE_PATH + 'ACCS\' + AccountName + '\' + F.Name);
      Reset(xF);
      Read(xF, xAccount);
      CloseFile(xF);

      SetLength(xAccs, xCnt);
      xAccs[high(xAccs)].xAcc := xAccount;
      xAccs[high(xAccs)].xfileName := TempNome;
      Inc(xCnt);
      Ret := FindNext(F);
    end;

    for i := Low(xAccs) to High(xAccs) do
    begin
      with Packet do
      begin
        ZeroMemory(@Packet, sizeof(Packet));
        Header.Size := sizeof(Packet);
        Header.code := $3223;
        Header.Index := $7535;
        System.AnsiStrings.StrPLCopy(FileName, xAccs[i].xfileName, 255);
        AccountBackup := xAccs[i].xAcc;
      end;

      Player.SendPacket(Packet, Packet.Header.Size);
      Sleep(20);
    end;
  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.GetAccountsBackup ' + E.Message + ' t: '
        + DateTimeToStr(Now), TLogType.Error);
    end;
  end;
end;

class procedure TFunctions.ManageAccountsBackupCount(var Player: TPlayer;
  AccountName: string);
var
  fileDate: Integer;
  fileDateTime: TDateTime;
  F: TSearchRec;
  Ret, xCnt: Integer;
begin
  try
    Ret := FindFirst(DATABASE_PATH + 'ACCS\' + AccountName + '\*.acc',
      faAnyFile, F);
    if Ret <> 0 then
      Exit;

    xCnt := 0;
    repeat
      fileDate := F.Time;
      fileDateTime := FileDateToDateTime(fileDate);
      if DaysBetween(fileDateTime, Now) >= 3 then
      begin
        DeleteFile(PChar(DATABASE_PATH + 'ACCS\' + AccountName + '\' + F.Name));
        Inc(xCnt);
      end;
      Ret := FindNext(F);
    until Ret <> 0;

  except
    on E: Exception do
      Logger.Write('Error at TFunctions.ManageAccountsBackupCount ' + E.Message
        + ' t: ' + DateTimeToStr(Now), TLogType.Error);
  end;
end;

class function TFunctions.FindAccount(AccountName: string): Boolean;
begin
  try
    Result := FileExists(DATABASE_PATH + 'ACCS\' + AccountName + '\' +
      AccountName + '.acc');
  except
    on E: Exception do
      Logger.Write('Error at TFunctions.FindAccount ' + E.Message + ' t: ' +
        DateTimeToStr(Now), TLogType.Error);
  end;
end;

{$ENDREGION}
{$REGION 'Trade Functions'}

class function TFunctions.ExecuteTrade(var Player: TPlayer;
  var OtherPlayer: TPlayer): Boolean;
var
  i: Integer;
  Packet: TSignalData;
begin
  Result := False;
  ZeroMemory(@Packet, sizeof(TSignalData));
  Packet.Header.Size := sizeof(TSignalData);
  Packet.Header.code := $318;

  // Enviar pacotes para ambos os jogadores
  Packet.Header.Index := Player.Base.ClientId;
  Player.SendPacket(Packet, Packet.Header.Size);
  Packet.Header.Index := OtherPlayer.Base.ClientId;
  OtherPlayer.SendPacket(Packet, Packet.Header.Size);

  // Processar os itens trocados
  for i := 0 to 9 do
  begin
    if Player.Character.Trade.Itens[i].Index > 0 then
    begin
      // Troca dos itens entre os jogadores
      TItemFunctions.PutItem(OtherPlayer, Player.Character.Base.Inventory
        [Player.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(Player, INV_TYPE,
        Player.Character.Trade.Slots[i]);

      TItemFunctions.PutItem(Player, OtherPlayer.Character.Base.Inventory
        [OtherPlayer.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(OtherPlayer, INV_TYPE,
        OtherPlayer.Character.Trade.Slots[i]);
    end;
  end;

  // Troca de ouro
  if Player.Character.Trade.Gold > 0 then
  begin
    if Player.Character.Base.Gold >= Player.Character.Trade.Gold then
    begin
      OtherPlayer.AddGold(Player.Character.Trade.Gold);
      Player.DecGold(Player.Character.Trade.Gold);
    end
    else
      Exit;
  end;

  if OtherPlayer.Character.Trade.Gold > 0 then
  begin
    if OtherPlayer.Character.Base.Gold >= OtherPlayer.Character.Trade.Gold then
    begin
      Player.AddGold(OtherPlayer.Character.Trade.Gold);
      OtherPlayer.DecGold(OtherPlayer.Character.Trade.Gold);
    end
    else
      Exit;
  end;

  // Limpar os dados de trade
  ZeroMemory(@OtherPlayer.Character.Trade, sizeof(TTrade));
  ZeroMemory(@Player.Character.Trade, sizeof(TTrade));

  Result := True;
end;

class function TFunctions.ExecuteTrade(var Player: TPlayer;
  OtherPlayer: PPlayer): Boolean;
var
  i: BYTE;
begin
  Result := False;
  for i := 0 to 9 do
  begin
    if (Player.Character.Trade.Itens[i].Index > 0) then
    begin
      TItemFunctions.PutItem(OtherPlayer^, Player.Character.Base.Inventory
        [Player.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(Player, INV_TYPE,
        Player.Character.Trade.Slots[i]);
    end;
    if (OtherPlayer.Character.Trade.Itens[i].Index > 0) then
    begin
      TItemFunctions.PutItem(Player, OtherPlayer.Character.Base.Inventory
        [OtherPlayer.Character.Trade.Slots[i]]);
      TItemFunctions.RemoveItem(OtherPlayer^, INV_TYPE,
        OtherPlayer.Character.Trade.Slots[i]);
    end;
  end;
  if (Player.Character.Trade.Gold > 0) then
  begin
    if (Player.Character.Base.Gold >= Player.Character.Trade.Gold) then
    begin
      OtherPlayer.AddGold(Player.Character.Trade.Gold);
      Player.DecGold(Player.Character.Trade.Gold);
    end
    else
      Exit;
  end;
  if (OtherPlayer.Character.Trade.Gold > 0) then
  begin
    if (OtherPlayer.Character.Base.Gold >= OtherPlayer.Character.Trade.Gold)
    then
    begin
      Player.AddGold(OtherPlayer.Character.Trade.Gold);
      OtherPlayer.DecGold(OtherPlayer.Character.Trade.Gold);
    end
    else
      Exit;
  end;
  ZeroMemory(@OtherPlayer.Character.Trade, sizeof(TTrade));
  ZeroMemory(@Player.Character.Trade, sizeof(TTrade));
  Result := True;
end;
{$ENDREGION}
{$REGION 'File Functions'}

class function TFunctions.GetFileSize(const FileName: string): UInt64;
var
  SearchRec: TSearchRec;
begin
  if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then
    Result := SearchRec.Size
  else
    Result := 0;
  SysUtils.FindClose(SearchRec);
end;

class function TFunctions.LoadPacket(PacketName: string;
  var Buffer: ARRAY OF BYTE): Boolean;
var
  FSize: Integer;
  F: TFileStream;
  FName: string;
begin
  FName := GetCurrentDir + '\Packets\' + PacketName + '.packet';
  if not FileExists(FName) then
    Exit(False);

  F := TFileStream.Create(FName, fmOpenRead);
  try
    FSize := F.Size;
    F.Position := 0;
    F.ReadBuffer(Buffer[0], FSize);
  finally
    F.Free;
  end;

  Result := True;
end;

class procedure TFunctions.DumpBasicCharacterToTxt(const FName: string;
  const BasicCharacter: TBasicCharacter);
var
  TxtFile: TextFile;
  DumpFileName: string;
begin
  DumpFileName := 'Data\BaseAccs\Dumps\' + FName + '.txt';

  // Certifique-se de que o diretório de dumps existe
  if not DirectoryExists('Data\BaseAccs\Dumps\') then
    ForceDirectories('Data\BaseAccs\Dumps\');

  AssignFile(TxtFile, DumpFileName);
  try
    ReWrite(TxtFile);

    // Escreva os dados do registro
    Writeln(TxtFile, 'Index: ', BasicCharacter.Index);
    Writeln(TxtFile, 'Base.Name: ', BasicCharacter.Base.Name);
    Writeln(TxtFile, 'SpeedMove: ', BasicCharacter.SpeedMove);
    Writeln(TxtFile, 'DuploAtk: ', BasicCharacter.DuploAtk);
    Writeln(TxtFile, 'Rotation: ', BasicCharacter.Rotation);
    Writeln(TxtFile, 'Resistence: ', BasicCharacter.Resistence);
    Writeln(TxtFile, 'LastAction: ', DateTimeToStr(BasicCharacter.LastAction));
    Writeln(TxtFile, 'LastLogin: ', DateTimeToStr(BasicCharacter.LastLogin));
    Writeln(TxtFile, 'LoggedTime: ', BasicCharacter.LoggedTime);
    Writeln(TxtFile, 'PlayerKill: ',
      BoolToStr(BasicCharacter.PlayerKill, True));
    Writeln(TxtFile, 'LastPos.X: ', BasicCharacter.LastPos.X);
    Writeln(TxtFile, 'LastPos.Y: ', BasicCharacter.LastPos.Y);
    Writeln(TxtFile, 'CurrentPos.X: ', BasicCharacter.CurrentPos.X);
    Writeln(TxtFile, 'CurrentPos.Y: ', BasicCharacter.CurrentPos.Y);

    // Writeln(TxtFile, '1: ', string(BasicCharacter.Base.Inventory));


    // Exemplo para Skills (ajuste conforme necessário)
    // Adicione um loop para listar as habilidades, se aplicável

    // Continue adicionando informações conforme necessário
  finally
    CloseFile(TxtFile);
  end;
end;

class function TFunctions.LoadBasicCharacter(FName: string;
  var Character: TCharacterDB): Boolean;
var
  F: File of TBasicCharacter;
  BasicCharacter: TBasicCharacter;
begin
  Result := False;
  ZeroMemory(@BasicCharacter, sizeof(TBasicCharacter));

  try
    Self.CreateBasicCharacter(FName, AnsiIndexStr(FName,
      ['Guerreiro', 'Templaria', 'Atirador', 'Pistoleira', 'Feiticeiro',
      'Cleriga']) + 1);

  except
    on E: Exception do
    begin
      // Trata erros e registra informações relevantes
      Writeln(Format('erro ao criar um novo arquivo', [FName, E.Message]));
    end;
  end;

  try
    // Verifica se o arquivo existe, e se não existir, cria um novo personagem básico
    if not FileExists('Data\BaseAccs\' + FName + '.acc') then
      Self.CreateBasicCharacter(FName, AnsiIndexStr(FName,
        ['Guerreiro', 'Templaria', 'Atirador', 'Pistoleira', 'Feiticeiro',
        'Cleriga']) + 1);

    // Converte os dados para um arquivo de texto (opcional, dependendo do uso)
    // TFunctions.DumpBasicCharacterToTxt(FName, BasicCharacter);

    // Associa e abre o arquivo
    try
      AssignFile(F, 'Data\BaseAccs\' + FName + '.acc');
      Reset(F);
    except
      on E: Exception do
      begin
        // Trata erros e registra informações relevantes
        Writeln(Format('1 Erro ao dar assign %s %s', [FName, E.Message]));
      end;
    end;

    try
      // Lê os dados do arquivo
      try
        Read(F, BasicCharacter);
      except
        on E: Exception do
        begin
          // Trata erros e registra informações relevantes
          Writeln(Format('2 Erro ao ler para character %s',
            [FName, E.Message]));
        end;
      end;

      try
        Move(BasicCharacter, Character, sizeof(TBasicCharacter));
      except
        on E: Exception do
        begin
          // Trata erros e registra informações relevantes
          Writeln(Format('3 Erro ao mover para character %s',
            [FName, E.Message]));
        end;
      end;
      Result := True;
    finally
      // Garante que o arquivo será fechado
      CloseFile(F);
    end;

  except
    on E: Exception do
    begin
      // Trata erros e registra informações relevantes
      Writeln(Format('4 Erro ao carregar o personagem básico "%s": %s',
        [FName, E.Message]));
    end;
  end;
end;

class function TFunctions.SaveBasicCharacter(FName: string;
  const Character: TCharacterDB): Boolean;
var
  F: File of TBasicCharacter;
  BasicCharacter: TBasicCharacter;
begin
  Result := False;

  if not DirectoryExists('Data\BaseAccs\') then
    ForceDirectories('Data\BaseAccs\');

  Move(Character, BasicCharacter, sizeof(TBasicCharacter));
  AssignFile(F, 'Data\BaseAccs\' + FName + '.acc');
  try
    ReWrite(F);
    Write(F, BasicCharacter);
  finally
    CloseFile(F);
  end;
end;

class function TFunctions.CreateBasicCharacter(FName: string;
  Classe: Integer): Boolean;
var
  F: TCharacterDB;
  i: Integer;
begin
  Result := False;
  if (Classe < 1) or (Classe > 6) then
    Exit;
  ZeroMemory(@F, sizeof(TCharacterDB));
  F.SpeedMove := 40;
  F.Base.CurrentScore.Sizes.Altura := $07;
  F.Base.CurrentScore.Sizes.Tronco := $77;
  F.Base.CurrentScore.Sizes.Perna := $77;
  F.Base.CurrentScore.Sizes.Corpo := $00;
  F.Skills.Basics[0].Level := 1;
  F.Skills.Basics[1].Level := 1;
  F.Skills.Basics[2].Level := 1;
  F.Skills.Basics[3].Level := 1;
  F.Skills.Basics[4].Level := 1;
  F.Skills.Basics[5].Level := 1;
  F.Skills.Others[0].Level := 1;
  F.Base.Level := 1;
  for i := 0 to 5 do
    F.Skills.Basics[i].Index := TSkillFunctions.GetSkillIndex(Classe, i + 1, 1);
  for i := 0 to (Length(F.Skills.Others) - 1) do
    F.Skills.Others[i].Index := TSkillFunctions.GetSkillIndex(Classe, i + 7, 1);
  case Classe of
{$REGION 'Warrior'}
    1:
      begin
        F.Base.CurrentScore.str := 15;
        F.Base.CurrentScore.Int := 05;
        F.Base.CurrentScore.agility := 09;
        F.Base.CurrentScore.Cons := 16;
        F.Base.Equip[2].Index := 2834;
        F.Base.Equip[2].Refi := 192;
        F.Base.Equip[2].MIN := 255;
        F.Base.Equip[2].MAX := 255;
        F.Base.Equip[2].APP := 2834;

        F.Base.Equip[3].Index := 2864;
        F.Base.Equip[3].Refi := 192;
        F.Base.Equip[3].MIN := 255;
        F.Base.Equip[3].MAX := 255;
        F.Base.Equip[3].APP := 2864;

        F.Base.Equip[4].Index := 2894;
        F.Base.Equip[4].Refi := 192;
        F.Base.Equip[4].MIN := 255;
        F.Base.Equip[4].MAX := 255;
        F.Base.Equip[4].APP := 2894;

        F.Base.Equip[5].Index := 2924;
        F.Base.Equip[5].Refi := 192;
        F.Base.Equip[5].MIN := 255;
        F.Base.Equip[5].MAX := 255;
        F.Base.Equip[5].APP := 2924;

        F.Base.Equip[6].Index := 2579;
        F.Base.Equip[6].Refi := 192;
        F.Base.Equip[6].MIN := 255;
        F.Base.Equip[6].MAX := 255;
        F.Base.Equip[6].APP := 2579;

        F.Base.Equip[11].Index := 13217;
        F.Base.Equip[11].APP := 13217;
        F.Base.Equip[12].Index := 13218;
        F.Base.Equip[12].APP := 13218;
        F.Base.Equip[13].Index := 13216;
        F.Base.Equip[13].APP := 13216;
        F.Base.Equip[14].Index := 13219;
        F.Base.Equip[14].APP := 13219;
        F.Base.ItemBar[3] := TSkillFunctions.GetSkillIndexOnBar
          (F.Skills.Basics[3].Index);
        F.Base.ClassInfo := 1;
      end;
{$ENDREGION}
{$REGION 'Templaria'}
    2:
      begin
        F.Base.CurrentScore.str := 14;
        F.Base.CurrentScore.Int := 06;
        F.Base.CurrentScore.agility := 10;
        F.Base.CurrentScore.Cons := 14;
        F.Base.Equip[2].Index := 2954;
        F.Base.Equip[2].Refi := 192;
        F.Base.Equip[2].MIN := 255;
        F.Base.Equip[2].MAX := 255;
        F.Base.Equip[2].APP := 2954;

        F.Base.Equip[3].Index := 2984;
        F.Base.Equip[3].Refi := 192;
        F.Base.Equip[3].MIN := 255;
        F.Base.Equip[3].MAX := 255;
        F.Base.Equip[3].APP := 2984;

        F.Base.Equip[4].Index := 3014;
        F.Base.Equip[4].Refi := 192;
        F.Base.Equip[4].MIN := 255;
        F.Base.Equip[4].MAX := 255;
        F.Base.Equip[4].APP := 3014;

        F.Base.Equip[5].Index := 3044;
        F.Base.Equip[5].Refi := 192;
        F.Base.Equip[5].MIN := 255;
        F.Base.Equip[5].MAX := 255;
        F.Base.Equip[5].APP := 3044;

        F.Base.Equip[6].Index := 2544;
        F.Base.Equip[6].Refi := 192;
        F.Base.Equip[6].MIN := 255;
        F.Base.Equip[6].MAX := 255;
        F.Base.Equip[6].APP := 2544;

        F.Base.Equip[7].Index := 2804;
        F.Base.Equip[7].Refi := 192;
        F.Base.Equip[7].MIN := 255;
        F.Base.Equip[7].MAX := 255;
        F.Base.Equip[7].APP := 2804;
        F.Base.Equip[11].Index := 13217;
        F.Base.Equip[11].APP := 13217;
        F.Base.Equip[12].Index := 13218;
        F.Base.Equip[12].APP := 13218;
        F.Base.Equip[13].Index := 13216;
        F.Base.Equip[13].APP := 13216;
        F.Base.Equip[14].Index := 13219;
        F.Base.Equip[14].APP := 13219;

        F.Base.ClassInfo := 11;
      end;
{$ENDREGION}
{$REGION 'Atirador'}
    3:
      begin
        F.Base.CurrentScore.str := 08;
        F.Base.CurrentScore.Int := 09;
        F.Base.CurrentScore.agility := 16;
        F.Base.CurrentScore.Cons := 12;
        F.Base.CurrentScore.Luck := 05;
        F.Base.Equip[2].Index := 3074;
        F.Base.Equip[2].Refi := 192;
        F.Base.Equip[2].MIN := 255;
        F.Base.Equip[2].MAX := 255;
        F.Base.Equip[2].APP := 3074;

        F.Base.Equip[3].Index := 3104;
        F.Base.Equip[3].Refi := 192;
        F.Base.Equip[3].MIN := 255;
        F.Base.Equip[3].MAX := 255;
        F.Base.Equip[3].APP := 3104;

        F.Base.Equip[4].Index := 3134;
        F.Base.Equip[4].Refi := 192;
        F.Base.Equip[4].MIN := 255;
        F.Base.Equip[4].MAX := 255;
        F.Base.Equip[4].APP := 3134;

        F.Base.Equip[5].Index := 3164;
        F.Base.Equip[5].Refi := 192;
        F.Base.Equip[5].MIN := 255;
        F.Base.Equip[5].MAX := 255;
        F.Base.Equip[5].APP := 3164;

        F.Base.Equip[6].Index := 2719;
        F.Base.Equip[6].Refi := 192;
        F.Base.Equip[6].MIN := 255;
        F.Base.Equip[6].MAX := 255;
        F.Base.Equip[6].APP := 2719;
        F.Base.Equip[11].Index := 13217;
        F.Base.Equip[11].APP := 13217;
        F.Base.Equip[12].Index := 13218;
        F.Base.Equip[12].APP := 13218;
        F.Base.Equip[13].Index := 13216;
        F.Base.Equip[13].APP := 13216;
        F.Base.Equip[14].Index := 13219;
        F.Base.Equip[14].APP := 13219;
        F.Base.ClassInfo := 21;
      end;
{$ENDREGION}
{$REGION 'Pistoleira'}
    4:
      begin
        F.Base.CurrentScore.str := 08;
        F.Base.CurrentScore.Int := 10;
        F.Base.CurrentScore.agility := 14;
        F.Base.CurrentScore.Cons := 12;
        F.Base.CurrentScore.Luck := 06;
        F.Base.Equip[2].Index := 3194;
        F.Base.Equip[2].Refi := 192;
        F.Base.Equip[2].MIN := 255;
        F.Base.Equip[2].MAX := 255;
        F.Base.Equip[2].APP := 3194;

        F.Base.Equip[3].Index := 3224;
        F.Base.Equip[3].Refi := 192;
        F.Base.Equip[3].MIN := 255;
        F.Base.Equip[3].MAX := 255;
        F.Base.Equip[3].APP := 3224;

        F.Base.Equip[4].Index := 3254;
        F.Base.Equip[4].Refi := 192;
        F.Base.Equip[4].MIN := 255;
        F.Base.Equip[4].MAX := 255;
        F.Base.Equip[4].APP := 3254;

        F.Base.Equip[5].Index := 3284;
        F.Base.Equip[5].Refi := 192;
        F.Base.Equip[5].MIN := 255;
        F.Base.Equip[5].MAX := 255;
        F.Base.Equip[5].APP := 3284;

        F.Base.Equip[6].Index := 2684;
        F.Base.Equip[6].Refi := 192;
        F.Base.Equip[6].MIN := 255;
        F.Base.Equip[6].MAX := 255;
        F.Base.Equip[6].APP := 2684;

        F.Base.Equip[11].Index := 13217;
        F.Base.Equip[11].APP := 13217;
        F.Base.Equip[12].Index := 13218;
        F.Base.Equip[12].APP := 13218;
        F.Base.Equip[13].Index := 13216;
        F.Base.Equip[13].APP := 13216;
        F.Base.Equip[14].Index := 13219;
        F.Base.Equip[14].APP := 13219;

        F.Base.ClassInfo := 31;
      end;
{$ENDREGION}
{$REGION 'Feiticeiro'}
    5:
      begin
        F.Base.CurrentScore.str := 07;
        F.Base.CurrentScore.Int := 16;
        F.Base.CurrentScore.agility := 09;
        F.Base.CurrentScore.Cons := 08;
        F.Base.CurrentScore.Luck := 10;
        F.Base.Equip[2].Index := 3314;
        F.Base.Equip[2].Refi := 192;
        F.Base.Equip[2].MIN := 255;
        F.Base.Equip[2].MAX := 255;
        F.Base.Equip[2].APP := 3314;

        F.Base.Equip[3].Index := 3344;
        F.Base.Equip[3].Refi := 192;
        F.Base.Equip[3].MIN := 255;
        F.Base.Equip[3].MAX := 255;
        F.Base.Equip[3].APP := 3344;

        F.Base.Equip[4].Index := 3374;
        F.Base.Equip[4].Refi := 192;
        F.Base.Equip[4].MIN := 255;
        F.Base.Equip[4].MAX := 255;
        F.Base.Equip[4].APP := 3374;

        F.Base.Equip[5].Index := 3404;
        F.Base.Equip[5].Refi := 192;
        F.Base.Equip[5].MIN := 255;
        F.Base.Equip[5].MAX := 255;
        F.Base.Equip[5].APP := 3404;

        F.Base.Equip[6].Index := 2789;
        F.Base.Equip[6].Refi := 192;
        F.Base.Equip[6].MIN := 255;
        F.Base.Equip[6].MAX := 255;
        F.Base.Equip[6].APP := 2789;

        F.Base.Equip[11].Index := 13217;
        F.Base.Equip[11].APP := 13217;
        F.Base.Equip[12].Index := 13218;
        F.Base.Equip[12].APP := 13218;
        F.Base.Equip[13].Index := 13216;
        F.Base.Equip[13].APP := 13216;
        F.Base.Equip[14].Index := 13219;
        F.Base.Equip[14].APP := 13219;
        F.Base.ClassInfo := 41;
      end;
{$ENDREGION}
{$REGION 'Clériga'}
    6:
      begin
        F.Base.CurrentScore.str := 07;
        F.Base.CurrentScore.Int := 15;
        F.Base.CurrentScore.agility := 10;
        F.Base.CurrentScore.Cons := 09;
        F.Base.CurrentScore.Luck := 09;
        F.Base.Equip[2].Index := 3434;
        F.Base.Equip[2].Refi := 192;
        F.Base.Equip[2].MIN := 255;
        F.Base.Equip[2].MAX := 255;
        F.Base.Equip[2].APP := 3434;

        F.Base.Equip[3].Index := 3464;
        F.Base.Equip[3].Refi := 192;
        F.Base.Equip[3].MIN := 255;
        F.Base.Equip[3].MAX := 255;
        F.Base.Equip[3].APP := 3464;

        F.Base.Equip[4].Index := 3494;
        F.Base.Equip[4].Refi := 192;
        F.Base.Equip[4].MIN := 255;
        F.Base.Equip[4].MAX := 255;
        F.Base.Equip[4].APP := 3494;

        F.Base.Equip[5].Index := 3524;
        F.Base.Equip[5].Refi := 192;
        F.Base.Equip[5].MIN := 255;
        F.Base.Equip[5].MAX := 255;
        F.Base.Equip[5].APP := 3524;

        F.Base.Equip[6].Index := 2754;
        F.Base.Equip[6].Refi := 192;
        F.Base.Equip[6].MIN := 255;
        F.Base.Equip[6].MAX := 255;
        F.Base.Equip[6].APP := 2754;

        F.Base.Equip[11].Index := 13217;
        F.Base.Equip[11].APP := 13217;
        F.Base.Equip[12].Index := 13218;
        F.Base.Equip[12].APP := 13218;
        F.Base.Equip[13].Index := 13216;
        F.Base.Equip[13].APP := 13216;
        F.Base.Equip[14].Index := 13219;
        F.Base.Equip[14].APP := 13219;
        F.Base.ItemBar[3] := TSkillFunctions.GetSkillIndexOnBar
          (F.Skills.Basics[3].Index);
        F.Base.ClassInfo := 51;
      end;
{$ENDREGION}
  end;
  F.Base.ItemBar[0] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Basics[0].Index);
  F.Base.ItemBar[1] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Others[0].Index);
  F.Base.ItemBar[2] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Basics[2].Index);
  F.Base.ItemBar[7] := TSkillFunctions.GetSkillIndexOnBar
    (F.Skills.Basics[1].Index);
  F.Base.Inventory[0].Index := 4350;
  F.Base.Inventory[0].Refi := 10;
  F.Base.Inventory[1].Index := 4390;
  F.Base.Inventory[1].Refi := 10;
  F.Base.Inventory[2].Index := 10044;
  F.Base.Inventory[2].Refi := 1;
  F.Base.Inventory[3].Index := 4433;
  F.Base.Inventory[3].Refi := 1000;

  F.Base.Inventory[4].Index := 11286;
  F.Base.Inventory[4].Refi := 1000;
  F.Base.Inventory[5].Index := 11285;
  F.Base.Inventory[5].Refi := 1000;

  F.Base.Inventory[6].Index := 11286;
  F.Base.Inventory[6].Refi := 50000;
  F.Base.Inventory[7].Index := 11285;
  F.Base.Inventory[7].Refi := 50000;

  Result := Self.SaveBasicCharacter(FName, F);
end;

class function TFunctions.GetFilesCount(Diretorio, Pesquisa: string): Integer;
var
  F: TSearchRec;
  r: Integer;
begin
  Diretorio := Trim(Diretorio);
  Result := 0;
  if (Diretorio <> '') and (Diretorio[Length(Diretorio)] <> '\') then
    Diretorio := Diretorio + '\';

  if DirectoryExists(Diretorio) then
  begin
    r := FindFirst(Diretorio + Pesquisa, faAnyFile, F);
    while r = 0 do
    begin
      with F do
      begin
        if (Name <> '.') and (Name <> '..') then
          Inc(Result);
      end;
      r := FindNext(F);
    end;
  end;
end;

{
  class function TFunctions.IncAccountsCount: Cardinal;
  var
  F: File of DWORD;
  FName: string;
  begin
  if not(DirectoryExists(DATABASE_PATH + 'ACCS')) then
  forceDirectories(DATABASE_PATH + 'ACCS');
  Result := 0;
  FName := DATABASE_PATH + 'ACCS\LastIndex.t3c';
  AssignFile(F, FName);
  if (FileExists(FName)) then
  begin
  Reset(F);
  Read(F, Result);
  CloseFile(F);
  end;
  Inc(Result);
  ReWrite(F);
  Write(F, Result);
  CloseFile(F);
  end; }
class function TFunctions.IncCharactersCount(SelfPlayer: PPlayer): Cardinal;
var
  CurrentCnt: Int64;
  SQLComp: TQuery;
begin
  SQLComp := Self.CreateSQL;
  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[IncCharactersCount]',
      TLogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[IncCharactersCount]',
      TLogType.Error);
    SQLComp.Free;
    Exit;
  end;

  try
    SQLComp.SetQuery
      ('SELECT character_count FROM server_info WHERE server_id = 4');
    SQLComp.Run;
    with SQLComp.Query do
    begin
      CurrentCnt := FieldByName('character_count').AsLargeInt;
    end;

    Inc(CurrentCnt);
    SQLComp.SetQuery
      (Format('UPDATE server_info SET character_count=%d WHERE server_id=1',
      [CurrentCnt]));
    SQLComp.Run(False);

  except
    on E: Exception do
    begin
      Logger.Write('Error at TFunctions.DecCharacterCount MySQL ' + E.Message,
        TLogType.Error);
    end;
  end;

  SQLComp.Free;
  Result := CurrentCnt;
end;

class function TFunctions.DecCharactersCount(SelfPlayer: PPlayer): Cardinal;
var
  CurrentCnt: Int64;
  SQLComp: TQuery;
begin
  SQLComp := Self.CreateSQL;
  with SQLComp do
  begin
    if not Query.Connection.Connected then
    begin
      Logger.Write('Falha de conexão individual com mysql.[DecCharactersCount]',
        TLogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[DecCharactersCount]',
        TLogType.Error);
      SQLComp.Free;
      Exit;
    end;

    try
      SetQuery('SELECT character_count FROM server_info WHERE server_id = 4');
      Run;
      CurrentCnt := Query.FieldByName('character_count').AsLargeInt;
      Dec(CurrentCnt);

      SetQuery(Format
        ('UPDATE server_info SET character_count=%d WHERE server_id=1',
        [CurrentCnt]));
      Run(False);
    except
      on E: Exception do
      begin
        Logger.Write('Error at TFunctions.DecCharacterCount MySQL ' + E.Message,
          TLogType.Error);
      end;
    end;
  end;

  SQLComp.Free;
  Result := CurrentCnt;
end;

{$ENDREGION}
{$REGION 'EncDec Files'}

class function TFunctions.EncDecSL(var Buffer: ARRAY OF BYTE;
  Encrypt: Boolean): Boolean;
var
  sign, j: Integer;
  par: Boolean;
begin
  Result := False;
  if (Length(Buffer) mod 2) = 0 then
    par := True
  else
    par := False;
  j := 0;
  if (Encrypt) then
    sign := -1
  else
    sign := 1;
  while j < Length(Buffer) - 1 do
  begin
    Buffer[j] := Buffer[j] - sign * (j mod 5);
    Inc(j);
    Buffer[j] := Buffer[j] - sign * (j mod 5);
    Inc(j);
    if not par then
    begin
      Buffer[j] := Buffer[j] - sign * (j mod 5);
      Inc(j);
    end;
    Result := True;
  end;
end;

class function TFunctions.EncDecSL(Buffer: Pointer; Size: UInt64;
  Encrypt: Boolean): Boolean;
var
  sign, j: Integer;
  par: Boolean;
begin
  Result := False;
  if (Size mod 2) = 0 then
    par := True
  else
    par := False;
  j := 0;
  if (Encrypt) then
    sign := -1
  else
    sign := 1;
  while (j < (Size - 1)) do
  begin
    PBYTE(Integer(Buffer) + j)^ := PBYTE(Integer(Buffer) + j)^ - sign *
      (j mod 5);
    Inc(j);
    PBYTE(Integer(Buffer) + j)^ := PBYTE(Integer(Buffer) + j)^ - sign *
      (j mod 5);
    Inc(j);
    if not par then
    begin
      PBYTE(Integer(Buffer) + j)^ := PBYTE(Integer(Buffer) + j)^ - sign *
        (j mod 5);
      Inc(j);
    end;
    Result := True;
  end;
end;
{$ENDREGION}
{$REGION 'Load Functions'}

class function TFunctions.LoadSL(FileName: string): Boolean;
  function ReadFile(FName: string; var SL: TServerList): Boolean;
  var
    Buffer: ARRAY OF BYTE;
    F: TFileStream;
    // F2: TFileStream;
  begin
    Result := False;
    if (FileExists(FName)) then
    begin
      F := TFileStream.Create(FName, fmOpenRead);
      SetLength(Buffer, F.Size);
      F.ReadBuffer(Buffer[0], F.Size);
      if (Self.EncDecSL(Buffer, False)) then
      begin
        { F2 := TFileStream.Create(GetCurrentDir + '\SL_dcr.bin', fmCreate);
          F2.Write(Buffer[0], F.Size);
          F2.Free; }
        Move(Buffer[0], SL[0], F.Size);
        Result := True;
      end;
      F.Free;
    end;
  end;

var
  FSize: UInt64;
  Len: DWORD;
begin
  Result := False;
  if not(FileExists(FileName)) then
    Exit;
  FSize := Self.GetFileSize(FileName);
  Len := Trunc(FSize / 72);
  SetLength(ServerList, Len);
  Result := ReadFile(FileName, ServerList);
end;
{$ENDREGION}
{$REGION 'Save Functions'}

class function TFunctions.SaveSL(FileName: string): Boolean;
var
  Buffer: ARRAY OF BYTE;
  F: TFileStream;
begin
  Result := False;
  if not(FileExists(FileName)) then
  begin
    Exit;
  end;
  F := TFileStream.Create(FileName, fmOpenWrite);
  SetLength(Buffer, F.Size);
  Move(ServerList[0], Buffer[0], F.Size);
  if (Self.EncDecSL(Buffer, True)) then
  begin
    F.WriteBuffer(Buffer[0], F.Size);
    Result := True;
  end;
  F.Free;
end;
{$ENDREGION}
{$REGION 'Time Functions'}

class function TFunctions.Time: String;
begin
  Result := Format('%.2d%.2d%.2d%.2d%.2d%.4d', [HourOf(Now), MinuteOf(Now),
    SecondOf(Now), DayOf(Now), MonthOf(Now), YearOf(Now)]);
end;

class function TFunctions.UNIXTimeToDateTimeFAST(UnixTime: Int64): TDateTime;
begin
  Result := (UnixTime div 86400) + 25569;
end;

class function TFunctions.DateTimeToUNIXTimeFAST(DelphiTime: TDateTime): Int64;
begin
  Result := Trunc((DelphiTime - 25569) * 86400);
end;

class function TFunctions.ReTime(Time: String): TDateTime;
begin
  Result := StrToDateTime(Copy(Time, 7, 8) + ' ' + Copy(Time, 1, 2) + ':' +
    Copy(Time, 3, 2) + ':' + Copy(Time, 5, 2));
end;

{$ENDREGION}
{$REGION 'MakeItems funcs'}

class function TFunctions.SearchMakeItemIDByRewardID(RewardID: word): word;
var
  i: word;
begin
  Result := 3000;
  for i := Low(MakeItems) to High(MakeItems) do
    if (RewardID = MakeItems[i].ResultItemID) then
    begin
      Result := i;
      Break;
    end;
end;

{$ENDREGION}

{
  class procedure TFunctions.GetMakeItems();
  var
  SelfSql: TQuery;
  ItemLine, LineWrite: String;
  MakeItems: TStringList;
  i, ItemAmount: Integer;
  F: TextFile;
  Path: String;
  begin
  try
  SelfSql := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
  AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
  AnsiString('aikaemu_game'));
  if not(SelfSql.MySQL.Connected) then
  Logger.Write('Erro: not mysql connection', TlogType.Packets);
  MakeItems := TStringList.Create;
  SelfSql.SetQuery('SELECT * FROM data_exp WHERE 1');
  SelfSql.Run();                  //data_make_items
  ItemAmount := SelfSql.Query.RecordCount;
  Logger.Write(ItemAmount.ToString, TlogType.Packets);
  {
  for i := 0 to (ItemAmount - 1) do
  begin
  ItemLine := IntToStr(SelfSql.Query.FieldByName('id').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('result_sup_item_id').AsInteger) +
  ',' + IntToStr(SelfSql.Query.FieldByName('level').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('price').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('quantity').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('rate').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('rate_sup').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('rate_double').AsInteger);
  MakeItems.Add(ItemLine);
  if (ItemAmount > 1) then
  SelfSql.Query.Next;
  end;
  Path := GetCurrentDir + '\Data\MakeItems.csv';
  AssignFile(F, Path);
  Rewrite(F);
  for i := 0 to (MakeItems.Count - 1) do
  begin
  Writeln(F, MakeItems.Strings[i]);
  end;
  CloseFile(F); }   {
  except
  on E: Exception do
  begin
  Logger.Write('Erro: ' + E.Message, TlogType.Packets);
  end;
  end;
  end;
  class procedure TFunctions.GetMakeItemsIngredients();
  var
  SelfSql: TQuery;
  ItemLine, LineWrite: String;
  MakeItems: TStringList;
  i, ItemAmount: Integer;
  F: TextFile;
  Path: String;
  begin
  try
  SelfSql := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
  AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
  AnsiString('aikaemu_game'));
  MakeItems := TStringList.Create;
  SelfSql.SetQuery('SELECT * FROM data_make_item_ingredients');
  SelfSql.Run();
  ItemAmount := SelfSql.Query.RecordCount;
  for i := 0 to (ItemAmount - 1) do
  begin
  ItemLine := IntToStr(SelfSql.Query.FieldByName('id').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('item_id').AsInteger) + ',' +
  IntToStr(SelfSql.Query.FieldByName('quantity').AsInteger);
  MakeItems.Add(ItemLine);
  if (ItemAmount > 1) then
  SelfSql.Query.Next;
  end;
  Path := GetCurrentDir + '\Data\MakeItemsIngredients.csv';
  AssignFile(F, Path);
  Rewrite(F);
  for i := 0 to (MakeItems.Count - 1) do
  begin
  Writeln(F, MakeItems.Strings[i]);
  end;
  CloseFile(F);
  except
  on E: Exception do
  begin
  Logger.Write('Erro: ' + E.Message, TlogType.Packets);
  end;
  end;
  end; }





  //minhas criações after

class function TFunctions.IFThen(cond: boolean; aTrue: variant; aFalse: variant): variant;
begin
  if cond then
    Result := aTrue
  else
    Result := aFalse;
end;

class function TFunctions.IFThen(cond: boolean): boolean;
begin
  Result := IFThen(cond, true, false);
end;

class function TFunctions.IsPlayerPlaying(Player: PPlayer): boolean;  //if false = cancel action and continue
begin

if Assigned(Player) and
(Player^.status = Playing) and
(not Player^.SocketClosed) and
(not Player^.Unlogging) and
(Player^.Base.ClientID <> 0) then
  exit(true);

result:= false;


end;


class procedure TFunctions.SavePlayerPrincipal(Player: PPlayer; CharID: byte);
var
  ID, I, Cnt: byte;
  Item: PItem;
  ItemC: PItemCash;
  VarQuery: TStringBuilder;
  MySQLComp: TQuery;

begin
  ID := Player^.Base.Character.CharIndex;
  MySQLComp := Self.CreateSQL;
  if not MySQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveInGame]', TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveInGame]', TlogType.Error);
    Exit;
  end;



  try
    MySQLComp.Query.Connection.StartTransaction;

    { Equips }
    MySQLComp.SetQuery('DELETE FROM items WHERE owner_id=' + ID.ToString + ' AND slot_type=0;');
    MySQLComp.Run(False);

    VarQuery := TStringBuilder.Create;
    try
      VarQuery.Append('INSERT INTO items (slot_type, owner_id, slot, item_id, app, identific, effect1_index, effect1_value, effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, time) VALUES ');
      Cnt := 0;
      for I := 0 to 15 do
      begin
        Item := @Player.Character.Base.Equip[I];
        if Item^.Index = 0 then
          Continue;

        if Cnt > 0 then
          VarQuery.Append(', ');

        VarQuery.AppendFormat('(0, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [ID, I, Item^.Index, Item^.APP, Item^.Identific, Item^.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.Index[2], Item^.Effects.Value[2],
          Item^.MIN, Item^.MAX, Item^.Refi, Item^.Time]);

        Inc(Cnt);
      end;

      if Cnt > 0 then
      begin
        MySQLComp.SetQuery(VarQuery.ToString);
        MySQLComp.Run(False);
      end;
    finally
      VarQuery.Free;
    end;

    { Character Info }
    MySQLComp.SetQuery(
      'UPDATE characters SET ' +
      'curhp=' + Player^.Character.Base.CurrentScore.CurHP.ToString + ', ' +
      'curmp=' + Player^.Character.Base.CurrentScore.CurMp.ToString + ', ' +
      'honor=' + Player^.Character.Base.CurrentScore.Honor.ToString + ', ' +
      'killpoint=' + Player^.Character.Base.CurrentScore.KillPoint.ToString + ', ' +
      'infamia=' + Player^.Character.Base.CurrentScore.Infamia.ToString + ', ' +
      'skillpoint=' + Player^.Character.Base.CurrentScore.SkillPoint.ToString + ', ' +
      'experience=' + Player^.Character.Base.Exp.ToString + ', ' +
      'level=' + Player^.Character.Base.Level.ToString + ', ' +
      'guildindex=' + Player^.Character.Base.GuildIndex.ToString + ', ' +
      'gold=' + Player^.Character.Base.Gold.ToString + ', ' +
      'posx=' + Round(Player^.Base.PlayerCharacter.LastPos.X).ToString + ', ' +
      'posy=' + Round(Player^.Base.PlayerCharacter.LastPos.Y).ToString + ', ' +
      'active_title=' + Player^.Base.PlayerCharacter.ActiveTitle.Index.ToString + ', ' +
      'name="' + String(Player^.Character.Base.Name) + '", ' +
      'rotation=' + Player^.Character.Rotation.ToString + ', ' +
      'lastlogin="' + Self.DateTimeToUNIXTimeFAST(Now).ToString() + '", ' +
      'playerkill=' + Player^.Character.PlayerKill.ToInteger.ToString + ', ' +
      'classinfo=' + Player^.Character.Base.ClassInfo.ToString + ', ' +
      'strength=' + Player^.Character.Base.CurrentScore.Str.ToString + ', ' +
      'agility=' + Player^.Character.Base.CurrentScore.Agility.ToString + ', ' +
      'intelligence=' + Player^.Character.Base.CurrentScore.Int.ToString + ', ' +
      'constitution=' + Player^.Character.Base.CurrentScore.Cons.ToString + ', ' +
      'luck=' + Player^.Character.Base.CurrentScore.Luck.ToString + ', ' +
      'status=' + Player^.Character.Base.CurrentScore.Status.ToString + ' ' +
      'WHERE id=' + ID.ToString + ';'
    );
    MySQLComp.Run(False);

    { Inventory }
    MySQLComp.SetQuery('DELETE FROM items WHERE owner_id=' + ID.ToString + ' AND slot_type=1;');
    MySQLComp.Run(False);

    VarQuery := TStringBuilder.Create;
    try
      VarQuery.Append('INSERT INTO items (slot_type, owner_id, slot, item_id, app, identific, effect1_index, effect1_value, effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, time) VALUES ');
      Cnt := 0;
      for I := 0 to 125 do
      begin
        Item := @Player^.Character.Base.Inventory[I];
        if Item^.Index = 0 then
          Continue;

        if Cnt > 0 then
          VarQuery.Append(', ');

        VarQuery.AppendFormat('(1, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [ID, I, Item^.Index, Item^.APP, Item^.Identific, Item^.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.Index[2], Item^.Effects.Value[2],
          Item^.MIN, Item^.MAX, Item^.Refi, Item^.Time]);

        Inc(Cnt);
      end;

      if Cnt > 0 then
      begin
        MySQLComp.SetQuery(VarQuery.ToString);
        MySQLComp.Run(False);
      end;
    finally
      VarQuery.Free;
    end;

    { Premium Inventory }
    MySQLComp.SetQuery('DELETE FROM items WHERE owner_id=' + Player^.Account.Header.AccountId.ToString + ' AND slot_type=10;');
    MySQLComp.Run(False);

    VarQuery := TStringBuilder.Create;
    try
      VarQuery.Append('INSERT INTO items (slot_type, owner_id, slot, item_id, app, identific) VALUES ');
      Cnt := 0;
      for I := 0 to 23 do
      begin
        ItemC := @Player^.Account.Header.CashInventory.Items[I];
        if ItemC^.Index = 0 then
          Continue;

        if Cnt > 0 then
          VarQuery.Append(', ');

        VarQuery.AppendFormat('(10, %d, %d, %d, %d, %d)',
          [Player^.Account.Header.AccountId, I, ItemC^.Index, ItemC^.APP, ItemC^.Identific]);

        Inc(Cnt);
      end;

      if Cnt > 0 then
      begin
        MySQLComp.SetQuery(VarQuery.ToString);
        MySQLComp.Run(False);
      end;
    finally
      VarQuery.Free;
    end;

    { Storage }
    MySQLComp.SetQuery('DELETE FROM items WHERE owner_id=' + Player^.Account.Header.AccountId.ToString + ' AND slot_type=2;');
    MySQLComp.Run(False);

    VarQuery := TStringBuilder.Create;
    try
      VarQuery.Append('INSERT INTO items (slot_type, owner_id, slot, item_id, app, identific, effect1_index, effect1_value, effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, time) VALUES ');
      Cnt := 0;
      for I := 0 to 85 do
      begin
        Item := @Player^.Account.Header.Storage.Itens[I];
        if Item^.Index = 0 then
          Continue;

        if Cnt > 0 then
          VarQuery.Append(', ');

        VarQuery.AppendFormat('(2, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
          [Player^.Account.Header.AccountId, I, Item^.Index, Item^.APP, Item^.Identific, Item^.Effects.Index[0], Item^.Effects.Value[0],
          Item^.Effects.Index[1], Item^.Effects.Value[1], Item^.Effects.Index[2], Item^.Effects.Value[2],
          Item^.MIN, Item^.MAX, Item^.Refi, Item^.Time]);

        Inc(Cnt);
      end;

      if Cnt > 0 then
      begin
        MySQLComp.SetQuery(VarQuery.ToString);
        MySQLComp.Run(False);
      end;
    finally
      VarQuery.Free;
    end;

    { Prans }
    if Player^.Account.Header.Pran1.Iddb > 0 then
    begin
      MySQLComp.SetQuery(
        'UPDATE prans SET ' +
        'name="' + String(Player^.Account.Header.Pran1.Name) + '", ' +
        'food=' + Player^.Account.Header.Pran1.Food.ToString + ', ' +
        'devotion=' + Player^.Account.Header.Pran1.Devotion.ToString + ', ' +
        'p_cute=' + Player^.Account.Header.Pran1.Personality.Cute.ToString + ', ' +
        'p_smart=' + Player^.Account.Header.Pran1.Personality.Smart.ToString + ', ' +
        'p_sexy=' + Player^.Account.Header.Pran1.Personality.Sexy.ToString + ', ' +
        'p_energetic=' + Player^.Account.Header.Pran1.Personality.Energetic.ToString + ', ' +
        'p_tough=' + Player^.Account.Header.Pran1.Personality.Tough.ToString + ', ' +
        'p_corrupt=' + Player^.Account.Header.Pran1.Personality.Corrupt.ToString + ', ' +
        'level=' + Player^.Account.Header.Pran1.Level.ToString + ', ' +
        'class=' + Player^.Account.Header.Pran1.ClassPran.ToString + ', ' +
        'hp=' + Player^.Account.Header.Pran1.CurHP.ToString + ', ' +
        'max_hp=' + Player^.Account.Header.Pran1.MaxHp.ToString + ', ' +
        'mp=' + Player^.Account.Header.Pran1.CurMp.ToString + ', ' +
        'max_mp=' + Player^.Account.Header.Pran1.MaxMP.ToString + ', ' +
        'xp=' + Player^.Account.Header.Pran1.Exp.ToString + ', ' +
        'def_p=' + Player^.Account.Header.Pran1.DefFis.ToString + ', ' +
        'def_m=' + Player^.Account.Header.Pran1.DefMag.ToString + ' ' +
        'WHERE id=' + Player^.Account.Header.Pran1.Iddb.ToString + ';'
      );
      MySQLComp.Run(False);

      { Pran Equip }
      MySQLComp.SetQuery('DELETE FROM items WHERE owner_id=' + Player^.Account.Header.Pran1.Iddb.ToString + ' AND slot_type=' + PRAN_EQUIP_TYPE.ToString + ';');
      MySQLComp.Run(False);

      VarQuery := TStringBuilder.Create;
      try
        VarQuery.Append('INSERT INTO items (slot_type, owner_id, slot, item_id, app, identific, effect1_index, effect1_value, effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, time) VALUES ');
        Cnt := 0;
        for I := 0 to 15 do
        begin
          Item := @Player^.Account.Header.Pran1.Equip[I];
          if Item^.Index = 0 then
            Continue;

          if Cnt > 0 then
            VarQuery.Append(', ');

          VarQuery.AppendFormat('(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
            [PRAN_EQUIP_TYPE, Player^.Account.Header.Pran1.Iddb, I, Item^.Index, Item^.APP, Item^.Identific,
            Item^.Effects.Index[0], Item^.Effects.Value[0], Item^.Effects.Index[1], Item^.Effects.Value[1],
            Item^.Effects.Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi, Item^.Time]);

          Inc(Cnt);
        end;

        if Cnt > 0 then
        begin
          MySQLComp.SetQuery(VarQuery.ToString);
          MySQLComp.Run(False);
        end;
      finally
        VarQuery.Free;
      end;

      { Pran Inventory }
      MySQLComp.SetQuery('DELETE FROM items WHERE owner_id=' + Player^.Account.Header.Pran1.Iddb.ToString + ' AND slot_type=' + PRAN_INV_TYPE.ToString + ';');
      MySQLComp.Run(False);

      VarQuery := TStringBuilder.Create;
      try
        VarQuery.Append('INSERT INTO items (slot_type, owner_id, slot, item_id, app, identific, effect1_index, effect1_value, effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, time) VALUES ');
        Cnt := 0;
        for I := 0 to 41 do
        begin
          Item := @Player^.Account.Header.Pran1.Inventory[I];
          if Item^.Index = 0 then
            Continue;

          if Cnt > 0 then
            VarQuery.Append(', ');

          VarQuery.AppendFormat('(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)',
            [PRAN_INV_TYPE, Player^.Account.Header.Pran1.Iddb, I, Item^.Index, Item^.APP, Item^.Identific,
            Item^.Effects.Index[0], Item^.Effects.Value[0], Item^.Effects.Index[1], Item^.Effects.Value[1],
            Item^.Effects.Index[2], Item^.Effects.Value[2], Item^.MIN, Item^.MAX, Item^.Refi, Item^.Time]);

          Inc(Cnt);
        end;

        if Cnt > 0 then
        begin
          MySQLComp.SetQuery(VarQuery.ToString);
          MySQLComp.Run(False);
        end;
      finally
        VarQuery.Free;
      end;

      { Pran Skills }
      MySQLComp.SetQuery('DELETE FROM skills WHERE owner_charid=' + Player^.Account.Header.Pran1.Iddb.ToString + ' AND type=3;');
      MySQLComp.Run(False);

      VarQuery := TStringBuilder.Create;
      try
        VarQuery.Append('INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ');
        Cnt := 0;
        for I := 0 to 9 do
        begin
          if Player^.Account.Header.Pran1.Skills[I].Index = 0 then
            Continue;

          if Cnt > 0 then
            VarQuery.Append(', ');

          VarQuery.AppendFormat('(%d, %d, %d, %d, 3)',
            [Player^.Account.Header.Pran1.Iddb, I, Player^.Account.Header.Pran1.Skills[I].Index, Player^.Account.Header.Pran1.Skills[I].Level]);

          Inc(Cnt);
        end;

        if Cnt > 0 then
        begin
          MySQLComp.SetQuery(VarQuery.ToString);
          MySQLComp.Run(False);
        end;
      finally
        VarQuery.Free;
      end;

      { Pran Skill Bar }
      MySQLComp.SetQuery('DELETE FROM itembars WHERE owner_charid=' + (Player^.Account.Header.Pran1.Iddb + 1024000).ToString + ';');
      MySQLComp.Run(False);

      VarQuery := TStringBuilder.Create;
      try
        VarQuery.Append('INSERT INTO itembars (owner_charid, slot, item) VALUES ');
        Cnt := 0;
        for I := 0 to 2 do
        begin
          if Player^.Account.Header.Pran1.ItemBar[I] = 0 then
            Continue;

          if Cnt > 0 then
            VarQuery.Append(', ');

          VarQuery.AppendFormat('(%d, %d, %d)',
            [Player^.Account.Header.Pran1.Iddb + 1024000, I + 100, Player^.Account.Header.Pran1.ItemBar[I]]);

          Inc(Cnt);
        end;

        if Cnt > 0 then
        begin
          MySQLComp.SetQuery(VarQuery.ToString);
          MySQLComp.Run(False);
        end;
      finally
        VarQuery.Free;
      end;
    end;



    MySQLComp.Query.Connection.Commit;


  except
    on E: Exception do
    begin
      Logger.Write('Erro ao salvar para o jogador: ' + Player^.base.Character.Name + ' possível rollback. ERRO: ' + E.Message + ' ' + DateTimeToStr(Now) + '.', TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;

  MySQLComp.Destroy;


end;



class procedure TFunctions.SavePlayerSecundario(Player: PPlayer; CharID: byte);
var
  ID, i, Cnt: byte;
  Item: PItem;
  ItemC: PItemCash;
  VarQuery: String;
  MySQLComp: TQuery;
begin
  ID := Player^.Base.Character.CharIndex;

  MySQLComp:= Self.CreateSQL;

  if not(MySQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveInGame]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveInGame]', TlogType.Error);
    Exit;
  end;

  // ACCOUNT INFO TABLE ACCOUNTS
{$REGION ACCOUNT INFO TABLE ´ACCOUNTS´}
  try
    { Account Info }
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery('UPDATE accounts SET isactive=' +
      IntToStr(self.IFThen(Player^.Account.Header.IsActive, 1, 0)) + ', nation=' +
      Integer(Player^.Account.Header.Nation).ToString + ', storage_gold=' +
      Player^.Account.Header.Storage.Gold.ToString + ', cash=' +
      Player^.Account.Header.CashInventory.Cash.ToString + ', account_status=' +
      Player^.Account.Header.AccountStatus.ToString + ', ban_days=' +
      Player^.Account.Header.BanDays.ToString + ' WHERE id=' +
      Player^.Account.Header.AccountId.ToString + ';');

      MySQLComp.Run(false);
      MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: AccountInfo error. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] username[' +
        String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
{$ENDREGION}


  // TABLE AUTO TIME (F12 CAÇA AUTOMATICA)
{$REGION AutoCaça}
  try
    MySQLComp.Query.Connection.StartTransaction;

    MySQLComp.SetQuery
      ('SELECT last_free_day FROM auto_time WHERE `character` = ''' +
      Player^.Base.Character.Name + '''');
    MySQLComp.Run();

    var AutoTime := MySQLComp.Query.FieldByName('last_free_day').AsDateTime;

    MySQLComp.SetQuery('DELETE FROM auto_time WHERE `character` = "' +
      Player^.Base.Character.Name + '"');
    MySQLComp.Run(false);

    VarQuery :=
      'INSERT INTO auto_time (`character`, time, time_used, last_free_day) ' +
      'VALUES ("' + Player^.Base.Character.Name + '", ' +
      IntToStr(Player^.F12TempoRestante) + ', ' + IntToStr(Player^.F12TempoAtivo) +
      ', "' + string(FormatDateTime('yyyy-mm-dd hh:nn:ss', AutoTime)) + '")';
    MySQLComp.SetQuery(VarQuery);
    MySQLComp.Run(false);
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Autotime error. msg[' + E.Message + ' : '
        + E.GetBaseException.Message + '] username[' +
        String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;

{$ENDREGION}




  // INFORMAÇÕES DO PERSONAGEM TABLE ´CHARACTER´
{$REGION Character Info }
  MySQLComp.Query.Connection.StartTransaction;
  try
    MySQLComp.SetQuery('UPDATE characters SET curhp=' +
      Player^.Character.Base.CurrentScore.CurHP.ToString + ',' + ' curmp=' +
      Player^.Character.Base.CurrentScore.CurMp.ToString + ', honor=' +
      Player^.Character.Base.CurrentScore.Honor.ToString + ', killpoint=' +
      Player^.Character.Base.CurrentScore.KillPoint.ToString + ', infamia=' +
      Player^.Character.Base.CurrentScore.Infamia.ToString + ',' + ' skillpoint=' +
      Player^.Character.Base.CurrentScore.SkillPoint.ToString + ', experience=' +
      Player^.Character.Base.Exp.ToString + ', level=' +
      Player^.Character.Base.Level.ToString + ',' + ' guildindex=' +
      Player^.Character.Base.GuildIndex.ToString + ', gold=' +
      Player^.Character.Base.Gold.ToString + ', posx=' +
      Round(Player^.Base.PlayerCharacter.LastPos.X).ToString + ', posy=' +
      Round(Player^.Base.PlayerCharacter.LastPos.Y).ToString + ', active_title=' +
      Player^.Base.PlayerCharacter.ActiveTitle.Index.ToString + ' WHERE id=' +
      ID.ToString + ';');
    MySQLComp.Run(false);
    MySQLComp.SetQuery('UPDATE characters SET name="' +
      String(Player^.Character.Base.Name) + '", rotation=' +
      Player^.Character.Rotation.ToString + ',' + ' lastlogin="' +
      Self.DateTimeToUNIXTimeFAST(Now).ToString() + '", playerkill=' +
      Player^.Character.PlayerKill.ToInteger.ToString + ', classinfo=' +
      Player^.Character.Base.ClassInfo.ToString + ',' + ' strength=' +
      Player^.Character.Base.CurrentScore.Str.ToString + ', agility=' +
      Player^.Character.Base.CurrentScore.agility.ToString + ', intelligence=' +
      Player^.Character.Base.CurrentScore.Int.ToString + ',' + ' constitution=' +
      Player^.Character.Base.CurrentScore.Cons.ToString + ', luck=' +
      Player^.Character.Base.CurrentScore.Luck.ToString + ', status=' +
      Player^.Character.Base.CurrentScore.Status.ToString + ' WHERE id=' +
      ID.ToString + ';');

    MySQLComp.Run(false);
    MySQLComp.Query.Connection.Commit;

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: CharacterInfo error. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] username[' +
        String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
{$ENDREGION}



  // save de skills table skills
{$REGION Skills }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery('DELETE FROM skills WHERE owner_charid=' + ID.ToString +
      ' and type in (1,2);');
    MySQLComp.Run(false);
    Cnt := 0;
    VarQuery :=
      'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
    for I := 0 to 5 do
    begin
      if (Player^.Character.Skills.Basics[I].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (' + ID.ToString + ', ' + I.ToString + ', ' +
          Player^.Character.Skills.Basics[I].Index.ToString + ', ' +
          Player^.Character.Skills.Basics[I].Level.ToString + ', 1)';
      end
      else
      begin
        VarQuery := VarQuery + '(' + ID.ToString + ', ' + I.ToString + ', ' +
          Player^.Character.Skills.Basics[I].Index.ToString + ', ' +
          Player^.Character.Skills.Basics[I].Level.ToString + ', 1)';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(false);
    end;
    Cnt := 0;
    VarQuery :=
      'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
    for I := 0 to 39 do
    begin
      if (Player^.Character.Skills.Others[I].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (' + ID.ToString + ', ' + I.ToString + ', ' +
          Player^.Character.Skills.Others[I].Index.ToString + ', ' +
          Player^.Character.Skills.Others[I].Level.ToString + ', 2)';
      end
      else
      begin
        VarQuery := VarQuery + '(' + ID.ToString + ', ' + I.ToString + ', ' +
          Player^.Character.Skills.Others[I].Index.ToString + ', ' +
          Player^.Character.Skills.Others[I].Level.ToString + ', 2)';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(false);
    end;
    { Cnt := 0;
      VarQuery :=
      'INSERT INTO skills (owner_charid, slot, item, level, type) VALUES ';
      for i := 20 to 39 do
      begin
      if (Self.Character.Skills.Others[i].Index = 0) then
      begin
      Continue;
      end;
      if (Cnt > 0) then
      begin
      VarQuery := VarQuery + format(', (%d, %d, %d, %d, 2)',
      [ID, i, Self.Character.Skills.Others[i].Index,
      Self.Character.Skills.Others[i].Level]);
      end
      else
      begin
      VarQuery := VarQuery + format('(%d, %d, %d, %d, 2)',
      [ID, i, Self.Character.Skills.Others[i].Index,
      Self.Character.Skills.Others[i].Level]);
      end;
      Inc(Cnt);
      end;
      if (Cnt > 0) then
      begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
      end; }
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Skills error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
{$ENDREGION}

  // SAVE DE SKILLS NA BARRA, TABLE ITEMSBAR
{$REGION Skills On Bar }
  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery('DELETE FROM itembars WHERE owner_charid=' +
      ID.ToString + ';');
    MySQLComp.Run(false);
    Cnt := 0;
    VarQuery := 'INSERT INTO itembars (owner_charid, slot, item) VALUES ';
    for I := 0 to 39 do
    begin
      if (Player^.Base.Character.ItemBar[I] = 0) then
      // Self.Character.Base.ItemBar[i]
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (' + ID.ToString + ', ' + I.ToString + ', ' +
          Player^.Base.Character.ItemBar[I].ToString + ')';
      end
      else
      begin
        VarQuery := VarQuery + '(' + ID.ToString + ', ' + I.ToString + ', ' +
          Player^.Base.Character.ItemBar[I].ToString + ')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(false);
    end;
    { Cnt := 0;
      VarQuery := 'INSERT INTO itembars (owner_charid, slot, item) VALUES ';
      for i := 12 to 23 do
      begin
      if (Self.Base.Character.ItemBar[i] = 0) then
      begin
      Continue;
      end;
      if (Cnt > 0) then
      begin
      VarQuery := VarQuery + format(', (%d, %d, %d)',
      [ID, i, Self.Base.Character.ItemBar[i]]);
      end
      else
      begin
      VarQuery := VarQuery + format('(%d, %d, %d)',
      [ID, i, Self.Base.Character.ItemBar[i]]);
      end;
      Inc(Cnt);
      end;
      if (Cnt > 0) then
      begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(False);
      end; }
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Skills On Bar error. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] username[' +
        String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;

{$ENDREGION}
{$REGION save dos buffs table buffs }
  { Buffs }

  try
    MySQLComp.Query.Connection.StartTransaction;
    MySQLComp.SetQuery('DELETE FROM buffs WHERE owner_charid=' +
      ID.ToString + ';');
    MySQLComp.Run(false);
    Cnt := 0;
    VarQuery :=
      'INSERT INTO buffs (buff_index, buff_time, owner_charid) VALUES ';
    for I := 0 to 59 do
    begin
      if (Player^.Base.PlayerCharacter.Buffs[I].Index = 0) then
      begin
        Continue;
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ', (' + Player^.Base.PlayerCharacter.Buffs[I].
          Index.ToString + ', "' + Self.DateTimeToUNIXTimeFAST
          (Player^.Base.PlayerCharacter.Buffs[I].CreationTime).ToString() + '", ' +
          ID.ToString + ')';
      end
      else
      begin
        VarQuery := VarQuery + '(' + Player^.Base.PlayerCharacter.Buffs[I].
          Index.ToString + ', "' + Self.DateTimeToUNIXTimeFAST
          (Player^.Base.PlayerCharacter.Buffs[I].CreationTime).ToString() + '", ' +
          ID.ToString + ')';
      end;
      Inc(Cnt);
    end;
    if (Cnt > 0) then
    begin
      VarQuery := VarQuery + ';';
      MySQLComp.SetQuery(VarQuery);
      MySQLComp.Run(false);
    end;
    MySQLComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Buffs error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;

{$ENDREGION}
{$REGION save de quests table quests }
  { Quests }
  try
    if not(Player^.QuestCount = 0) then
    begin
      MySQLComp.Query.Connection.StartTransaction;
      MySQLComp.SetQuery('DELETE FROM quests WHERE charid=' +
        ID.ToString + ';');
      MySQLComp.Run(false);
      Cnt := 0;
      VarQuery :=
        'INSERT INTO quests (charid, questid, req1, req2, req3, req4, ' +
        'req5, isdone, updated_at, created_at) VALUES ';
      for I := 0 to 49 do
      begin
        if (Player^.PlayerQuests[I].Quest.QuestID = 0) then
        begin
          Continue;
        end;
        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ', (' + ID.ToString + ', ' + Player^.PlayerQuests
            [I].ID.ToString + ', ' + Player^.PlayerQuests[I].Complete[0].ToString +
            ', ' + Player^.PlayerQuests[I].Complete[1].ToString + ', ' +
            Player^.PlayerQuests[I].Complete[2].ToString + ', ' + Player^.PlayerQuests
            [I].Complete[3].ToString + ', ' + Player^.PlayerQuests[I].Complete[4]
            .ToString + ', ' + Player^.PlayerQuests[I].IsDone.ToInteger.ToString +
            ', ' + Self.DateTimeToUNIXTimeFAST
            (Player^.PlayerQuests[I].UpdatedAt).ToString + ', ' +
            Self.DateTimeToUNIXTimeFAST(Player^.PlayerQuests[I].CreatedAt)
            .ToString + ')';
        end
        else
        begin
          VarQuery := VarQuery + '(' + ID.ToString + ', ' + Player^.PlayerQuests[I]
            .ID.ToString + ', ' + Player^.PlayerQuests[I].Complete[0].ToString +
            ', ' + Player^.PlayerQuests[I].Complete[1].ToString + ', ' +
            Player^.PlayerQuests[I].Complete[2].ToString + ', ' + Player^.PlayerQuests
            [I].Complete[3].ToString + ', ' + Player^.PlayerQuests[I].Complete[4]
            .ToString + ', ' + Player^.PlayerQuests[I].IsDone.ToInteger.ToString +
            ', ' + Self.DateTimeToUNIXTimeFAST
            (Player^.PlayerQuests[I].UpdatedAt).ToString + ', ' +
            Self.DateTimeToUNIXTimeFAST(Player^.PlayerQuests[I].CreatedAt)
            .ToString + ')';
        end;
        Inc(Cnt);
      end;
      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ';';
        MySQLComp.SetQuery(VarQuery);
        MySQLComp.Run(false);
      end;
      MySQLComp.Query.Connection.Commit;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL SaveInGame: Quests error. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] username[' +
        String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) + '.',
        TlogType.Error);
      MySQLComp.Query.Connection.Rollback;
    end;
  end;
{$ENDREGION}
  // Verifica se existem títulos válidos antes de deletar
  Cnt := 0;
  for I := 0 to 95 do
  begin
    if (Player^.Base.PlayerCharacter.Titles[I].Index <> 0) then
      Inc(Cnt);
  end;

  if (Cnt > 0) then
  begin
    try
      MySQLComp.Query.Connection.StartTransaction;
      MySQLComp.SetQuery('DELETE FROM titles WHERE owner_charid=' +
        ID.ToString + ';');
      MySQLComp.Run(false);

      Cnt := 0;
      VarQuery :=
        'INSERT INTO titles (title_index, title_level, title_progress, owner_charid) VALUES ';

      for I := 0 to 95 do
      begin
        if (Player^.Base.PlayerCharacter.Titles[I].Index = 0) then
        begin
          Continue;
        end;

        if (Cnt > 0) then
        begin
          VarQuery := VarQuery + ', (' + Player^.Base.PlayerCharacter.Titles[I].
            Index.ToString + ', ' + Player^.Base.PlayerCharacter.Titles[I]
            .Level.ToString + ', ' + Player^.Base.PlayerCharacter.Titles[I]
            .Progress.ToString + ', ' + ID.ToString + ')';
        end
        else
        begin
          VarQuery := VarQuery + '(' + Player^.Base.PlayerCharacter.Titles[I].
            Index.ToString + ', ' + Player^.Base.PlayerCharacter.Titles[I]
            .Level.ToString + ', ' + Player^.Base.PlayerCharacter.Titles[I]
            .Progress.ToString + ', ' + ID.ToString + ')';
        end;

        Inc(Cnt);
      end;

      if (Cnt > 0) then
      begin
        VarQuery := VarQuery + ';';
        MySQLComp.SetQuery(VarQuery);
        MySQLComp.Run(false);
      end;

      MySQLComp.Query.Connection.Commit;
    except
      on E: Exception do
      begin
        Logger.Write('MYSQL SaveInGame: Titles error. msg[' + E.Message + ' : '
          + E.GetBaseException.Message + '] username[' +
          String(Player^.Account.Header.Username) + '] ' + DateTimeToStr(Now) +
          '.', TlogType.Error);
        MySQLComp.Query.Connection.Rollback;
      end;
    end;
  end;

  MySQLComp.Destroy;
end;




end.
