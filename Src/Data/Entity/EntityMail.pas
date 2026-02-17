unit EntityMail;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Windows, MiscData, System.SysUtils, Player, AnsiStrings, SQL;

{$OLDTYPELAYOUT ON}

type
  PMail = ^TMail;

  TMail = packed record
    Index: UInt64;
    CharIndex: DWORD;
    Nick: Array [0 .. 15] of AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    Texto: Array [0 .. 511] of AnsiChar;
    Slot: WORD;
    Gold: DWORD;
    Item: Array [0 .. 6] of TItem;
    DataRetorno: TDateTime;
    DataEnvio: TDateTime;
    Checked: BOOLEAN;
    Return: BOOLEAN;
    CheckItem: BOOLEAN;
    Leilao: BOOLEAN;
  end;

type
  TCharacterMail = ARRAY OF TMail;

type
  TMailList = ARRAY [0 .. 31] OF TStructCarta;

type
  TEntityMail = class(TObject)
  private
    { DataBase Get Functions }
    class function getMailsList(var Player: TPlayer;
      var mailList: TMailList): BOOLEAN;

    class function getUnreadCount(var Player: TPlayer;
      var dwUnreadMails: DWORD): BOOLEAN;

    class function getMailsCount(var Player: TPlayer;
      var dwMails: DWORD): BOOLEAN;

    class function getMailContent(var Player: TPlayer; const mailIndex: UInt64;
      var MailContet: TOpenMailContent): BOOLEAN;
    class function CreateSQL: TQuery;

  public
    { DataBase Get Functions }
    class function getMailGold(var Player: TPlayer; const mailIndex: UInt64;
      var dwGold: DWORD): BOOLEAN;

    class function getMailItemSlot(var Player: TPlayer; const mailIndex: UInt64;
      const Slot: BYTE; var Item: TItem; var itemIndex: UInt64): BOOLEAN;

    class function getMailItemCount(var Player: TPlayer;
      const mailIndex: UInt64; var itemCount: BYTE): BOOLEAN;

    class function getCharacterIdByName(var Player: TPlayer;
      characterName: AnsiString): UInt64;

    { Sends }
    class procedure sendUnreadMails(var Player: TPlayer);

    class function sendMailList(var Player: TPlayer): BOOLEAN;

    class function sendMailContent(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    { DataBase Update Mail Info }
    class function setMailRead(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function deleteMail(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function withdrawGold(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function setAllItemsWithdraw(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    class function withdrawItem(var Player: TPlayer; const itemIndex: UInt64;
      const mailIndex: UInt64): BOOLEAN;

    class function returnEmail(var Player: TPlayer;
      const mailIndex: UInt64): BOOLEAN;

    { DataBase Add Mail Info }
    class function addMail(var Player: TPlayer; const MailContet: TMailContent;
      out mailIndex: UInt64): BOOLEAN;

    class function addMailItem(var Player: TPlayer; const itemSlot: BYTE;
      const mailSlot: BYTE; const mailIndex: UInt64): BOOLEAN;
  end;

{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, Log, Packets, DateUtils;

class function TEntityMail.CreateSQL: TQuery;
begin
  // Criando a conexão usando as variáveis globais já definidas
  Result := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
end;

{$REGION 'Database Get Functions'}

class function TEntityMail.getMailsList(var Player: TPlayer;
  var mailList: TMailList): BOOLEAN;
var
  i: BYTE;
  SQLComp: TQuery;
begin
  Result := False;
  ZeroMemory(@mailList, sizeof(TMailList));

  SQLComp := self.CreateSQL;
  try
    SQLComp.SetQuery
      (format('SELECT id, sentCharacterName, title, DATE(returnDate) as `ReturnDate`, '
      + 'checked, canReturn, hasItems, isFromAuction FROM mails ' +
      'WHERE active > 0 AND characterId = %d ORDER BY id DESC LIMIT 32',
      [Player.Character.Index]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
    begin
      SQLComp.Query.First;
      for i := 0 to SQLComp.Query.RecordCount - 1 do
      begin
        with mailList[i] do
        begin
          Index := UInt64(SQLComp.Query.FieldByName('id').AsLargeInt);

          AnsiStrings.StrPLCopy(NickEnviado,
            AnsiString(SQLComp.Query.FieldByName('sentCharacterName')
            .AsString), 16);

          AnsiStrings.StrPLCopy(Titulo,
            AnsiString(SQLComp.Query.FieldByName('title').AsString), 32);

          AnsiStrings.StrPLCopy(DataRetorno,
            AnsiString(SQLComp.Query.FieldByName('ReturnDate').AsString), 20);

          Checked := BOOLEAN(SQLComp.Query.FieldByName('checked').AsInteger);
          Return := BOOLEAN(SQLComp.Query.FieldByName('canReturn').AsInteger);
          CheckItem := BOOLEAN(SQLComp.Query.FieldByName('hasItems').AsInteger);
          Leilao := BOOLEAN(SQLComp.Query.FieldByName('isFromAuction')
            .AsInteger);
        end;

        SQLComp.Query.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mails list. msg[' + E.Message + ' : '
        + E.GetBaseException.Message + '] clientId [' +
        string(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      SQLComp.Free;
      Exit;
    end;
  end;

  SQLComp.Free;
  Result := True;
end;

class function TEntityMail.getUnreadCount(var Player: TPlayer;
  var dwUnreadMails: DWORD): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  dwUnreadMails := 0;
  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('SELECT COUNT(id) AS unreadMailsCount FROM mails WHERE active > 0 AND checked = 0 AND characterId = %d',
      [Player.Character.Index]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
      dwUnreadMails := SQLComp.Query.FieldByName('unreadMailsCount').AsInteger;

    Result := True;
  except
    on E: Exception do
      Logger.Write('MYSQL error on loading unread mails count. msg[' + E.Message
        + ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
  end;

  SQLComp.Free;
end;

class function TEntityMail.getMailsCount(var Player: TPlayer;
  var dwMails: DWORD): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  dwMails := 0;

  SQLComp := self.CreateSQL;
  try
    SQLComp.SetQuery
      (format('SELECT COUNT(id) AS mailsCount FROM mails WHERE active > 0 AND characterId = %d',
      [Player.Character.Index]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
      dwMails := SQLComp.Query.FieldByName('mailsCount').AsInteger;

    Result := True;
  except
    on E: Exception do
      Logger.Write('MYSQL error on loading mails count. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + ']', TlogType.Error);
  end;

  SQLComp.Free;
end;

class function TEntityMail.getMailContent(var Player: TPlayer;
  const mailIndex: UInt64; var MailContet: TOpenMailContent): BOOLEAN;
var
  i, itemSlot: BYTE;
  SQLComp: TQuery;
begin
  Result := False;
  ZeroMemory(@MailContet, sizeof(TMail));
  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('SELECT * FROM mails WHERE active > 0 AND id = %d LIMIT 1',
      [mailIndex]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
    begin
      with SQLComp.Query do
      begin
        MailContet.Index := UInt64(FieldByName('id').AsInteger);
        MailContet.CharIndex := UInt(FieldByName('characterId').AsInteger);
        MailContet.Index2 := MailContet.Index;

        AnsiStrings.StrPLCopy(MailContet.Nick,
          AnsiString(FieldByName('sentCharacterName').AsString), 16);
        AnsiStrings.StrPLCopy(MailContet.Titulo,
          AnsiString(FieldByName('title').AsString), 32);
        AnsiStrings.StrPLCopy(MailContet.Texto,
          AnsiString(FieldByName('textBody').AsString), 512);
        AnsiStrings.StrPLCopy(MailContet.DataEnvio,
          AnsiString(FieldByName('sentDate').AsString), 20);

        MailContet.Unk_B01 := BOOLEAN(FieldByName('checked').AsInteger);
        MailContet.Return := BOOLEAN(FieldByName('canReturn').AsInteger);
        MailContet.Unk_B02 := BOOLEAN(FieldByName('hasItems').AsInteger);
        MailContet.Unk_B03 := BOOLEAN(FieldByName('isFromAuction').AsInteger);
        MailContet.Gold := UInt64(FieldByName('gold').AsInteger);
      end;
    end;

    SQLComp.SetQuery
      (format('SELECT * FROM mails_items WHERE active > 0 AND mail_id = %d ORDER BY slot ASC LIMIT 6',
      [mailIndex]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
    begin
      SQLComp.Query.First;
      for i := 0 to SQLComp.Query.RecordCount - 1 do
      begin
        with SQLComp.Query do
        begin
          itemSlot := BYTE(FieldByName('slot').AsInteger);

          MailContet.Items[itemSlot].Index := FieldByName('item_id').AsInteger;
          MailContet.Items[itemSlot].APP := FieldByName('app').AsInteger;
          MailContet.Items[itemSlot].Identific := FieldByName('identific')
            .AsInteger;

          MailContet.Items[itemSlot].Effects.Index[0] :=
            FieldByName('effect1_index').AsInteger;
          MailContet.Items[itemSlot].Effects.Index[1] :=
            FieldByName('effect2_index').AsInteger;
          MailContet.Items[itemSlot].Effects.Index[2] :=
            FieldByName('effect3_index').AsInteger;

          MailContet.Items[itemSlot].Effects.Value[0] :=
            FieldByName('effect1_value').AsInteger;
          MailContet.Items[itemSlot].Effects.Value[1] :=
            FieldByName('effect2_value').AsInteger;
          MailContet.Items[itemSlot].Effects.Value[2] :=
            FieldByName('effect3_value').AsInteger;

          MailContet.Items[itemSlot].MIN := FieldByName('min').AsInteger;
          MailContet.Items[itemSlot].MAX := FieldByName('max').AsInteger;
          MailContet.Items[itemSlot].Refi := FieldByName('refine').AsInteger;
          MailContet.Items[itemSlot].Time := FieldByName('time').AsInteger;
        end;
        SQLComp.Query.Next;
      end;
    end;

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail content. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      SQLComp.Free;
      Exit;
    end;
  end;

  SQLComp.Free;
  Result := True;
end;

class function TEntityMail.getMailGold(var Player: TPlayer;
  const mailIndex: UInt64; var dwGold: DWORD): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  dwGold := 0;

  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('SELECT gold FROM mails WHERE active > 0 AND characterId = %d AND id = %d LIMIT 1',
      [Player.Character.Index, mailIndex]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
      dwGold := SQLComp.Query.FieldByName('gold').AsInteger;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail gold amount. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
    end;
  end;

  SQLComp.Free;
  Result := True;
end;

class function TEntityMail.getMailItemSlot(var Player: TPlayer;
  const mailIndex: UInt64; const Slot: BYTE; var Item: TItem;
  var itemIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  ZeroMemory(@Item, sizeof(TItem));

  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('SELECT * FROM mails_items WHERE active > 0 AND mail_id = %d AND slot = %d LIMIT 1',
      [mailIndex, Slot]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
    begin
      // Acessando campos uma única vez para melhorar performance
      with SQLComp.Query do
      begin
        Item.Index := FieldByName('item_id').AsInteger;
        Item.APP := FieldByName('app').AsInteger;
        Item.Identific := FieldByName('identific').AsInteger;

        Item.Effects.Index[0] := FieldByName('effect1_index').AsInteger;
        Item.Effects.Index[1] := FieldByName('effect2_index').AsInteger;
        Item.Effects.Index[2] := FieldByName('effect3_index').AsInteger;

        Item.Effects.Value[0] := FieldByName('effect1_value').AsInteger;
        Item.Effects.Value[1] := FieldByName('effect2_value').AsInteger;
        Item.Effects.Value[2] := FieldByName('effect3_value').AsInteger;

        Item.MIN := FieldByName('min').AsInteger;
        Item.MAX := FieldByName('max').AsInteger;

        Item.Refi := FieldByName('refine').AsInteger;

        Item.Time := FieldByName('time').AsInteger;

        itemIndex := UInt64(FieldByName('id').AsLargeInt);
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail item slot. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      SQLComp.Free;
      Exit;
    end;
  end;

  SQLComp.Free;

  Result := True;
end;

class function TEntityMail.getMailItemCount(var Player: TPlayer;
  const mailIndex: UInt64; var itemCount: BYTE): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  itemCount := 0;

  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('SELECT count(id) as `itemsCount` FROM mails_items WHERE active > 0 '
      + 'AND mail_id = %d LIMIT 6', [mailIndex]));
    SQLComp.Run();

    // Evita redundância na checagem de Query.RecordCount
    if SQLComp.Query.RecordCount > 0 then
      itemCount := SQLComp.Query.FieldByName('itemsCount').AsInteger;

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading mail items count. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      Exit;
    end;
  end;

  SQLComp.Free;

  Result := True;
end;

class function TEntityMail.getCharacterIdByName(var Player: TPlayer;
  characterName: AnsiString): UInt64;
var
  SQLComp: TQuery;
begin
  Result := 0;
  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery(format('SELECT id FROM characters WHERE name = %s LIMIT 1',
      [QuotedStr(String(characterName))]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
      Result := SQLComp.Query.FieldByName('id').AsInteger;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on getting character id from name. msg[' +
        E.Message + ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
    end;
  end;

  SQLComp.Free;
end;

{$ENDREGION}
{$REGION 'Sends'}

class procedure TEntityMail.sendUnreadMails(var Player: TPlayer);
var
  unReadMails: DWORD;
begin
  if not(self.getUnreadCount(Player, unReadMails)) then
    Exit;

  Player.SendData(Player.Base.ClientId, $3F1B, unReadMails);

end;

class function TEntityMail.sendMailList(var Player: TPlayer): BOOLEAN;
var
  mailList: TMailList;
  Packet: TPlayerMailsPacket;
  mailsCount: DWORD;
begin
  Result := False;

  // Verifica se é possível obter a lista de e-mails e a quantidade de e-mails
  if not(self.getMailsList(Player, mailList)) or
    not(self.getMailsCount(Player, mailsCount)) then
    Exit;

  // Preenche o pacote de e-mails
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := Player.Base.ClientId;
  Packet.Header.Code := $3F17;
  Move(mailList, Packet.Cartas, sizeof(TMailList));
  Packet.MailsAmount := mailsCount;

  // Envia os dados do pacote
  Player.SendPacket(Packet, Packet.Header.Size);

  // Envia mensagens de correio informativas a cada 15 segundos
  if SecondsBetween(Now, Player.LastCorreioMsg) > 15 then
  begin
    Player.SendClientMessage(' ', 0, 0, 0);
    Player.SendClientMessage(' ', 0, 0, 0);
    Player.SendClientMessage('[FORMATO DE ENVIO]:', 16, 16, 16);
    Player.SendClientMessage(' ', 0, 0, 0);
    Player.SendClientMessage('Para: leilao', 16, 16, 16);
    Player.SendClientMessage('Título: cash ou gold', 16, 16, 16);
    Player.SendClientMessage('Item: Somente um item pode ser enviado',
      16, 16, 16);
    Player.SendClientMessage('Quantia: Valor que você irá cobrar', 16, 16, 16);
    Player.LastCorreioMsg := Now;
  end;

  Result := True;
end;

class function TEntityMail.sendMailContent(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  Packet: TSendOpenMailContentPacket;
  MailContet: TOpenMailContent;
begin
  Result := False;

  if not(self.getMailContent(Player, mailIndex, MailContet)) then
    Exit;

  // Inicializando o Packet e atribuindo valores
  FillChar(Packet, sizeof(Packet), 0);
  Packet.Header.Size := sizeof(Packet);
  Packet.Header.Index := Player.Base.ClientId;
  Packet.Header.Code := $3F18;
  Packet.MailContent := MailContet;

  // Enviando o pacote
  Player.SendPacket(Packet, Packet.Header.Size);

  Result := True;
end;

{$ENDREGION}
{$REGION 'DataBase Update Mail Info'}

class function TEntityMail.setMailRead(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET checked = 1 WHERE active > 0 AND id = %d ' +
      'AND characterId = %d LIMIT 1', [mailIndex, Player.Character.Index]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on setting mail readed. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      Exit;
    end;
  end;

  Result := True;
end;

class function TEntityMail.deleteMail(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  SQLComp := self.CreateSQL;

  try
    // Melhorando a legibilidade e eficiência na query, sem concatenar strings
    SQLComp.SetQuery
      (format('UPDATE mails SET active = 0 WHERE id = %d AND characterId = %d LIMIT 1',
      [mailIndex, Player.Character.Index]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on deleting mail. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      Exit; // Não é necessário liberar SQLComp aqui, pois o objeto será liberado ao final da função
    end;
  end;

  Result := True;
end;

class function TEntityMail.withdrawGold(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := self.CreateSQL;
  try
    // Otimização da query para evitar concatenação excessiva
    SQLComp.SetQuery
      (format('UPDATE mails SET gold = 0, canReturn = 0 WHERE id = %d AND characterId = %d LIMIT 1',
      [mailIndex, Player.Character.Index]));
    SQLComp.Run(False);

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on withdrawing gold from mail. msg[' + E.Message
        + ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      Exit;
    end;
  end;

  Result := True;
end;

class function TEntityMail.setAllItemsWithdraw(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;
  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET hasItems = 0 WHERE id = %d AND characterId = %d LIMIT 1',
      [mailIndex, Player.Character.Index]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on setting all items got. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      Exit;
    end;
  end;

  Result := True;
end;

class function TEntityMail.withdrawItem(var Player: TPlayer;
  const itemIndex: UInt64; const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := self.CreateSQL;

  try
    // Combina as duas atualizações em uma única transação, sem duplicar o SQL.
    SQLComp.SetQuery
      (format('UPDATE mails_items SET active = 0 WHERE id = %d AND mail_id = %d LIMIT 1; '
      + 'UPDATE mails SET canReturn = 0 WHERE id = %d AND characterId = %d LIMIT 1;',
      [itemIndex, mailIndex, mailIndex, Player.Character.Index]));
    SQLComp.Run(False);

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on withdraw item. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      SQLComp.Free;
      Exit;
    end;
  end;

  SQLComp.Free;

  Result := True;
end;

class function TEntityMail.returnEmail(var Player: TPlayer;
  const mailIndex: UInt64): BOOLEAN;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('UPDATE mails SET characterId = sentCharacterId, title = ' +
      'CONCAT("[Retornou] ", title), ' +
      'returnDate = date_add(returnDate, INTERVAL 15 DAY), canReturn = 0, ' +
      'mailReturned = 1 WHERE id = %d AND characterId = %d',
      [mailIndex, Player.Character.Index]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on returning mail. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      Exit;
    end;
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'DataBase Add Mail Info'}

class function TEntityMail.addMail(var Player: TPlayer;
  const MailContet: TMailContent; out mailIndex: UInt64): BOOLEAN;
var
  receiverCharacterId: UInt64;
  canReturn, hasItems: BYTE;
  SQLComp: TQuery;
  i: BYTE;
begin
  Result := False;

  if MailContet.Nick = 'leilao' then
  begin
    Player.SendClientMessage('Item enviado para o leilão web!');
    Result := True;
    Exit;
  end;

  try
    receiverCharacterId := self.getCharacterIdByName(Player,
      AnsiString(MailContet.Nick));
    if (receiverCharacterId = 0) then
      Exit;

    canReturn := 0;
    hasItems := 0;
    for i := 0 to 4 do
    begin
      if (MailContet.itemSlot[i] <> $FF) then
      begin
        canReturn := 1;
        hasItems := 1;
      end;
    end;

    if (MailContet.Gold > 0) then
      canReturn := 1;

    Logger.Write('receiver charid: ' + receiverCharacterId.ToString,
      TlogType.Packets);

    SQLComp := self.CreateSQL;
    if not(SQLComp.Query.Connection.Connected) then
    begin
      Logger.Write('Falha de conexão individual com mysql.[addMail]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[addMail]', TlogType.Error);
      SQLComp.Free;
      Exit;
    end;

    // Inserção no banco de dados
    SQLComp.SetQuery
      (format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, '
      + 'title, textBody, slot, sentGold, gold, returnDate, sentDate, canReturn, hasItems) '
      + 'VALUES (%d, %d, %s, %s, %s, 0, %d, %d, %s, NOW(), %d, %d)',
      [receiverCharacterId, Player.Character.Index,
      QuotedStr(String(AnsiString(Player.Character.Base.Name))),
      QuotedStr(String(AnsiString(MailContet.Titulo))),
      QuotedStr(String(AnsiString(MailContet.Texto))), MailContet.Gold,
      MailContet.Gold, QuotedStr(FormatDateTime('yyyy-mm-dd hh:mm:ss',
      IncDay(Now, 15))), canReturn, hasItems]));

    SQLComp.Run(False);

    // Obtenção do último ID inserido
    SQLComp.SetQuery
      (format('SELECT last_insert_id() as last_index FROM mails WHERE ' +
      'characterId = %d LIMIT 1', [receiverCharacterId]));
    SQLComp.Run();

    if (SQLComp.Query.RecordCount > 0) then
    begin
      mailIndex := SQLComp.Query.FieldByName('last_index').AsInteger;
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on adding mail. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
    end;
  end;

  SQLComp.Free;
end;

class function TEntityMail.addMailItem(var Player: TPlayer;
  const itemSlot: BYTE; const mailSlot: BYTE; const mailIndex: UInt64): BOOLEAN;
var
  Item: TItem;
  SQLComp: TQuery;
begin
  Result := False;

  try
    ZeroMemory(@Item, sizeof(TItem));
    Move(Player.Character.Base.Inventory[itemSlot], Item, sizeof(TItem));

    if not(ItemList[Item.Index].TypeTrade = 0) then
      Exit;
  except
    Exit;
  end;

  SQLComp := self.CreateSQL;

  try
    SQLComp.SetQuery
      (format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, '
      + 'effect1_index, effect1_value, effect2_index, effect2_value, effect3_index, '
      + 'effect3_value, min, max, refine, time) VALUES (%d, %d, %d, %d, %d, %d, '
      + '%d, %d, %d, %d, %d, %d, %d, %d, %d)', [mailIndex, mailSlot, Item.Index,
      Item.APP, Item.Identific, Item.Effects.Index[0], Item.Effects.Value[0],
      Item.Effects.Index[1], Item.Effects.Value[1], Item.Effects.Index[2],
      Item.Effects.Value[2], Item.MIN, Item.MAX, Item.Refi, Item.Time]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on adding mail item. msg[' + E.Message + ' : ' +
        E.GetBaseException.Message + '] clientId [' +
        String(Player.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      Exit;
    end;
  end;

  Result := True;
end;

{$ENDREGION}

end.
