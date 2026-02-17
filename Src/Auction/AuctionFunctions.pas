unit AuctionFunctions;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Windows, Packets, Player, MiscData, SQL;

type
  TAuctionFunctions = class(TObject)
  public
    class function GetAuctionItems(var Player: TPlayer; itemType: DWORD;
      LevelMin: WORD; LevelMax: WORD; ReinforceMin: BYTE; ReinforceMax: BYTE;
      SearchByName: DWORD): Boolean;
    class function RegisterAuctionItem(var Player: TPlayer; Price: DWORD;
      Slot: WORD; Time: WORD): Boolean;
    class function GetSelfAuctionItems(var Player: TPlayer): Boolean;
    class function CancelItemOffer(var Player: TPlayer;
      AuctionOfferId: UInt64): Boolean;
    class function RequestBuyItem(var Player: TPlayer;
      AuctionOfferId: UInt64): Boolean;
    class function CheckAuctionItems(): Boolean;

  private
    class function CreateSQL: TQuery;
    class function SendAuctionItems(var Player: TPlayer;
      Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
    class function GetAuctionItemComission(AuctionRegisterTime: WORD;
      SellingPrice: DWORD): DWORD;
    class function RegisterItemDatabase(var Player: TPlayer; Item: TItem;
      OUT AuctionItemIndex: UInt64): Boolean;
    class function RegisterOfferDatabase(var Player: TPlayer; Item: TItem;
      SellingPrice: DWORD; RegisterTime: WORD; AuctionItemIndex: UInt64;
      OUT AuctionOfferIndex: UInt64): Boolean;
    class function SendSelfAuctionItems(var Player: TPlayer;
      Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
    class procedure SendCancelResult(var Player: TPlayer;
      AuctionOfferId: UInt64);
    class procedure SendBuyResult(var Player: TPlayer; AuctionOfferId: UInt64);
    class function RegisterAquisitionMail(var Player: TPlayer;
      AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
    class function RegisterSellerAquisitionMail(var Player: TPlayer;
      AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
    class function RegisterReturnMail(OUT MailIndex: UInt64): Boolean;

  end;

implementation

uses
  SysUtils, GlobalDefs, AnsiStrings, ItemFunctions, DateUtils, Log;
{$REGION 'View auction items'}

class function TAuctionFunctions.CreateSQL: TQuery;
begin
  // Criando a conexão usando as variáveis globais já definidas
  Result := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
end;

class function TAuctionFunctions.GetAuctionItems(var Player: TPlayer;
  itemType: DWORD; LevelMin: WORD; LevelMax: WORD; ReinforceMin: BYTE;
  ReinforceMax: BYTE; SearchByName: DWORD): Boolean;
var
  ItemsBuffer: ARRAY [0 .. 39] OF TAuctionItemData;
  GetQuery: string;
  QueryField: string;
  auxCounter: Integer;
  pageCount: Integer;
  SQLComp: TQuery;
  Conexao: TQuery;
  xPlayer: PPlayer;
  RecordIndex: Integer;
begin
  Result := True;
  ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));

  xPlayer := @Player;

  if (xPlayer = nil) then
  begin
    Exit(false);
  end;

  SQLComp := Self.CreateSQL;

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[GetAuctionItems]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[GetAuctionItems]',
      TlogType.Error);
    SQLComp.Free;
    Exit;
  end;

  if SearchByName >= 1 then // pesquisa por tipo de item
  begin
    if itemType = 21 then
      itemType := 26
    else if itemType = 22 then
      itemType := 33
    else if itemType = 23 then
      itemType := 34
    else if itemType = 33 then
      itemType := 230
    else if itemType = 34 then
      itemType := 301
    else if itemType = 1007 then
      itemType := 1008
    else if itemType = 1008 then
      itemType := 1007;

    QueryField := 'ItemType';

    GetQuery :=
      Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
      'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
      'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
      'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' + 'FROM ' +
      MYSQL_DATABASE + '.vwauction_getactiveoffers ' + 'WHERE %s = %d ' +
      'AND (ItemLevel >= %d AND ItemLevel <= %d) ' +
      'AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) AND Active = 1 ' +
      'ORDER BY SellingPrice ASC', [QueryField, itemType, LevelMin, LevelMax,
      ReinforceMin, ReinforceMax]);
  end
  else
  begin
    QueryField := 'ItemId'; // Atribui o nome do campo para a consulta

    GetQuery :=
      Format('SELECT AuctionId, CharacterId, CharacterName, ExpireDate, ' +
      'SellingPrice, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, ' +
      'EffectId_2, EffectId_3, EffectValue_1, EffectValue_2, EffectValue_3, ' +
      'DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime ' + 'FROM ' +
      MYSQL_DATABASE + '.vwauction_getactiveoffers ' + 'WHERE %s = %d ' +
      // Usando o QueryField que foi atribuído
      'AND (ItemLevel >= %d AND ItemLevel <= %d) ' +
      'AND (ReinforceLevel >= %d AND ReinforceLevel <= %d) AND Active = 1 ' +
      'ORDER BY SellingPrice ASC', [QueryField, itemType, LevelMin, LevelMax,
      ReinforceMin, ReinforceMax]);
  end;

  SQLComp.SetQuery(GetQuery);
  SQLComp.Run();
  ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));

  if (SQLComp.Query.RecordCount = 0) then
  begin
    Self.SendAuctionItems(Player, ItemsBuffer, 0);
    SQLComp.Free;
    Exit;
  end;

  auxCounter := 0;
  pageCount := 1;
  SQLComp.Query.First;

  for RecordIndex := 0 to SQLComp.Query.RecordCount - 1 do
  begin
    ItemsBuffer[auxCounter].SellerCharacterIndex :=
      SQLComp.Query.FieldByName('CharacterId').AsInteger;
    ItemsBuffer[auxCounter].AuctionIndex := SQLComp.Query.FieldByName
      ('AuctionId').AsInteger;
    AnsiStrings.StrPLCopy(ItemsBuffer[auxCounter].SellerCharacterName,
      AnsiString(SQLComp.Query.FieldByName('CharacterName').AsString), 16);
    AnsiStrings.StrPLCopy(ItemsBuffer[auxCounter].ExpireDate,
      AnsiString(FormatDateTime('mm-dd hh:nn',
      SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);
    ItemsBuffer[auxCounter].ItemPrice := SQLComp.Query.FieldByName
      ('SellingPrice').AsInteger;
    ItemsBuffer[auxCounter].Item.Index := SQLComp.Query.FieldByName('ItemId')
      .AsInteger;
    ItemsBuffer[auxCounter].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
      .AsInteger;
    ItemsBuffer[auxCounter].Item.Identific :=
      SQLComp.Query.FieldByName('IdentificableAddOns').AsInteger;
    ItemsBuffer[auxCounter].Item.Effects.Index[0] :=
      SQLComp.Query.FieldByName('EffectId_1').AsInteger;
    ItemsBuffer[auxCounter].Item.Effects.Index[1] :=
      SQLComp.Query.FieldByName('EffectId_2').AsInteger;
    ItemsBuffer[auxCounter].Item.Effects.Index[2] :=
      SQLComp.Query.FieldByName('EffectId_3').AsInteger;
    ItemsBuffer[auxCounter].Item.Effects.Value[0] :=
      SQLComp.Query.FieldByName('EffectValue_1').AsInteger;
    ItemsBuffer[auxCounter].Item.Effects.Value[1] :=
      SQLComp.Query.FieldByName('EffectValue_2').AsInteger;
    ItemsBuffer[auxCounter].Item.Effects.Value[2] :=
      SQLComp.Query.FieldByName('EffectValue_3').AsInteger;
    ItemsBuffer[auxCounter].Item.Min := SQLComp.Query.FieldByName
      ('DurabilityMin').AsInteger;
    ItemsBuffer[auxCounter].Item.Max := SQLComp.Query.FieldByName
      ('DurabilityMax').AsInteger;
    ItemsBuffer[auxCounter].Item.Refi := SQLComp.Query.FieldByName
      ('Amount_Reinforce').AsInteger;
    ItemsBuffer[auxCounter].Item.Time := SQLComp.Query.FieldByName('ItemTime')
      .AsInteger;

    Inc(auxCounter);

    if (auxCounter = 39) then
    begin
      Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
      ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));
      Inc(pageCount);
      auxCounter := 0;
    end;

    SQLComp.Query.Next;
  end;

  Self.SendAuctionItems(Player, ItemsBuffer, pageCount);
  SQLComp.Free;
end;

class function TAuctionFunctions.SendAuctionItems(var Player: TPlayer;
  Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
var
  Packet: TSendAuctionItemsPacket;
begin

  if Length(Items) > 40 then
  begin
    Exit(false);
  end;
  Result := True;
  Packet := Default (TSendAuctionItemsPacket);
  Packet.Header.Size := sizeof(TSendAuctionItemsPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F0D;
  move(Items, Packet.Items, sizeof(Packet.Items));
  Packet.ItemCount := Page;
  Player.SendPacket(Packet, Packet.Header.Size);

end;
{$ENDREGION}
{$REGION 'View self auction items'}

class function TAuctionFunctions.GetSelfAuctionItems
  (var Player: TPlayer): Boolean;
var
  QueryString: string;
  ItemsBuffer: ARRAY [0 .. 11] OF TAuctionItemData;
  I, j: Integer;
  SQLComp: TQuery;
begin
  Result := True;
  SQLComp := Self.CreateSQL;

  // Modificando a consulta SQL para incluir o nome do personagem
  QueryString := Format('SELECT v.AuctionId, v.CharacterId, v.CharacterName, ' +
    'v.SellingPrice, v.ItemType, v.ItemLevel, v.ReinforceLevel, v.ExpireDate, '
    + 'v.ItemId, v.ItemLookId, v.IdentificableAddOns, ' +
    'v.EffectId_1, v.EffectId_2, v.EffectId_3, ' +
    'v.EffectValue_1, v.EffectValue_2, v.EffectValue_3, v.DurabilityMin, v.DurabilityMax, '
    + 'v.Amount_Reinforce, v.ItemTime, v.Active ' +
    'FROM vwauction_getactiveoffers v ' +
    'WHERE v.CharacterName = ''%s'' AND v.SellingPrice > 0 AND v.Active = 1 ' +
    'ORDER BY v.SellingPrice ASC LIMIT 12', [Player.Base.Character.Name]);

  // Executando a consulta SQL
  SQLComp.SetQuery(QueryString);
  SQLComp.Run();

  // Zerando o buffer dos itens
  ZeroMemory(@ItemsBuffer, sizeof(ItemsBuffer));

  // Caso não haja registros retornados pela consulta
  if (SQLComp.Query.RecordCount = 0) then
  begin
    Self.SendSelfAuctionItems(Player, ItemsBuffer, 0);
    SQLComp.Free;
    Exit;
  end;

  SQLComp.Query.First;
  for I := 0 to SQLComp.Query.RecordCount - 1 do
  begin
    // Atribuindo os dados do leilão
    ItemsBuffer[I].SellerCharacterIndex := SQLComp.Query.FieldByName
      ('CharacterId').AsInteger;
    ItemsBuffer[I].AuctionIndex := SQLComp.Query.FieldByName('AuctionId')
      .AsInteger;

    // Copiando o nome do vendedor para o buffer
    AnsiStrings.StrPLCopy(ItemsBuffer[I].SellerCharacterName,
      AnsiString(SQLComp.Query.FieldByName('CharacterName').AsString), 16);

    // Atribuindo o preço e outros dados do item
    ItemsBuffer[I].ItemPrice := SQLComp.Query.FieldByName('SellingPrice')
      .AsInteger;

    // Atribuindo outros dados do item
    ItemsBuffer[I].Item.Index := SQLComp.Query.FieldByName('ItemId').AsInteger;
    ItemsBuffer[I].Item.APP := SQLComp.Query.FieldByName('ItemLookId')
      .AsInteger;
    ItemsBuffer[I].Item.Identific := SQLComp.Query.FieldByName
      ('IdentificableAddOns').AsInteger;

    // Efeitos do item
    ItemsBuffer[I].Item.Effects.Index[0] := SQLComp.Query.FieldByName
      ('EffectId_1').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[1] := SQLComp.Query.FieldByName
      ('EffectId_2').AsInteger;
    ItemsBuffer[I].Item.Effects.Index[2] := SQLComp.Query.FieldByName
      ('EffectId_3').AsInteger;

    ItemsBuffer[I].Item.Effects.Value[0] := SQLComp.Query.FieldByName
      ('EffectValue_1').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[1] := SQLComp.Query.FieldByName
      ('EffectValue_2').AsInteger;
    ItemsBuffer[I].Item.Effects.Value[2] := SQLComp.Query.FieldByName
      ('EffectValue_3').AsInteger;

    // Outros dados do item
    ItemsBuffer[I].Item.Min := SQLComp.Query.FieldByName('DurabilityMin')
      .AsInteger;
    ItemsBuffer[I].Item.Max := SQLComp.Query.FieldByName('DurabilityMax')
      .AsInteger;
    ItemsBuffer[I].Item.Refi := SQLComp.Query.FieldByName('Amount_Reinforce')
      .AsInteger;
    ItemsBuffer[I].Item.Time := SQLComp.Query.FieldByName('ItemTime').AsInteger;

    // Lógica para calcular a data de expiração
    AnsiStrings.StrPLCopy(ItemsBuffer[I].ExpireDate,
      AnsiString(FormatDateTime('mm-dd hh:nn',
      SQLComp.Query.FieldByName('ExpireDate').AsDateTime)), 12);

    SQLComp.Query.Next;
  end;

  // Envia os itens para o jogador
  j := SQLComp.Query.RecordCount;
  Self.SendSelfAuctionItems(Player, ItemsBuffer, j);
  SQLComp.Free;
end;

class function TAuctionFunctions.SendSelfAuctionItems(var Player: TPlayer;
  Items: ARRAY OF TAuctionItemData; Page: DWORD): Boolean;
var
  Packet: TCadastredItemsPacket;
begin
  if Length(Items) > 12 then
  begin
    Exit(false);
  end;
  Result := True;
  ZeroMemory(@Packet, sizeof(TCadastredItemsPacket));
  Packet.Header.Size := sizeof(TCadastredItemsPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F11;
  try
    move(Items, Packet.Items, sizeof(Packet.Items));
  except
    Result := false;
  end;
  Packet.ItemCount := Page;
  Player.SendPacket(Packet, Packet.Header.Size);
end;
{$ENDREGION}
{$REGION 'Register auction item'}

class function TAuctionFunctions.RegisterAuctionItem(var Player: TPlayer;
  Price: DWORD; Slot: WORD; Time: WORD): Boolean;
var
  RegisterTax: DWORD;
  RegisterItem: PItem;
  AuctionItemIndex, AuctionOfferIndex: UInt64;
begin
  Result := false;
  // Inicializando o resultado como False para simplificar o fluxo.

  RegisterItem := @Player.Base.Character.Inventory[Slot];
  if (RegisterItem.Index = 0) then
  begin
    Player.SendClientMessage('Item não encontrado!'); // Mensagem mais clara.
    Exit;
  end;

  RegisterTax := Self.GetAuctionItemComission(Time, Price);
  if (RegisterTax > Player.Base.Character.Gold) then
  begin
    Player.SendClientMessage('Ouro insuficiente!');
    Exit;
  end;

  if (ItemList[RegisterItem.Index].TypeTrade > 0) then
  begin
    Player.SendClientMessage('Item não comercializável!');
    Exit;
  end;

  if not(Self.RegisterItemDatabase(Player, RegisterItem^, AuctionItemIndex)) or
    not(Self.RegisterOfferDatabase(Player, RegisterItem^, Price, Time,
    AuctionItemIndex, AuctionOfferIndex)) then
  begin
    Exit;
  end;

  ZeroMemory(RegisterItem, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(Slot, false);
  Player.DecGold(RegisterTax);
  Player.SendData(Player.Base.ClientID, $3F0B, 1);

  Self.GetSelfAuctionItems(Player);

  Result := True; // Definindo o resultado como True ao final da função.
end;

class function TAuctionFunctions.GetAuctionItemComission(AuctionRegisterTime
  : WORD; SellingPrice: DWORD): DWORD;
var
  sellPriceCalculated: DWORD;
begin
  sellPriceCalculated := Trunc(SellingPrice / 1000);
  if (SellingPrice < 1000) then
  begin
    sellPriceCalculated := Round(SellingPrice / 1000);
  end;
  Result := Round(sellPriceCalculated * (AuctionRegisterTime / 3));
end;

class function TAuctionFunctions.RegisterItemDatabase(var Player: TPlayer;
  Item: TItem; OUT AuctionItemIndex: UInt64): Boolean;
var
  QueryString: string;
  SQLComp: TQuery;
begin
  Result := True;
  AuctionItemIndex := 0;
  SQLComp := Self.CreateSQL;
  try
    // Query para inserir o item
    QueryString :=
      Format('INSERT INTO auction_items (item_id, app, identific, effect1_index,'
      + 'effect2_index, effect3_index, effect1_value, effect2_value, effect3_value, '
      + 'min, max, refine, time) VALUES (%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d);',
      [Item.Index, Item.APP, Item.Identific, Item.Effects.Index[0],
      Item.Effects.Index[1], Item.Effects.Index[2], Item.Effects.Value[0],
      Item.Effects.Value[1], Item.Effects.Value[2], Item.Min, Item.Max,
      Item.Refi, Item.Time]);

    SQLComp.Query.Connection.StartTransaction;
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(false);
    SQLComp.Query.Connection.Commit;

    // verificação se a inserção foi bem-sucedida
    if (SQLComp.Query.RowsAffected = 0) then
      Exit(false);

    // Query para obter o último id inserido
    QueryString := 'SELECT max(id) as idx from auction_items;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run;
    AuctionItemIndex := SQLComp.Query.FieldByName('idx').AsInteger;

    // verificação se o id foi recuperado
    if AuctionItemIndex = 0 then
      Exit(false);

  finally
    SQLComp.Free; // Garantir que SQLComp será destruído no final
  end;
end;

class function TAuctionFunctions.RegisterOfferDatabase(var Player: TPlayer;
  Item: TItem; SellingPrice: DWORD; RegisterTime: WORD;
  AuctionItemIndex: UInt64; OUT AuctionOfferIndex: UInt64): Boolean;
var
  QueryString: string;
  ItemLevel: WORD;
  ItemReinforce: WORD;
  SQLComp: TQuery;
begin
  Result := false; // Inicializa como False, indicando falha por padrão
  AuctionOfferIndex := 0;
  SQLComp := Self.CreateSQL; // Criação do SQLComp uma única vez

  try
    // Definir nível do item
    ItemLevel := ItemList[Item.Index].Level;
    if ItemLevel = 0 then
      ItemLevel := 1;

    // Verificar se o item pode ser reforçado
    if (ItemList[Item.Index].Fortification) and (ItemList[Item.Index].Classe > 0)
    then
      ItemReinforce := Trunc(Item.Refi / 18)
    else
      ItemReinforce := 1;

    // Contrução da consulta SQL para inserção
    QueryString :=
      Format('INSERT INTO auction (CharacterId, ItemType, ItemLevel, ReinforceLevel, '
      + 'RegisterDate, RegisterTime, SellingPrice, auction_itemsId) VALUES (%d, %d, %d, %d, "%s", %d, %d, %d);',
      [Player.Base.Character.CharIndex, ItemList[Item.Index].itemType,
      ItemLevel, ItemReinforce, FormatDateTime('yyyy-mm-dd hh:nn:ss', Now()),
      RegisterTime, SellingPrice, AuctionItemIndex]);

    // Iniciar transação e executar a query
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(false);

    // Se não houve alteração nas linhas, retorna False
    if SQLComp.Query.RowsAffected = 0 then
      Exit(false);

    // Consultar o último ID da oferta de leilão inserido
    QueryString := 'SELECT max(AuctionId) as idx from auction;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();

    // Obter o índice da oferta de leilão
    AuctionOfferIndex := SQLComp.Query.FieldByName('idx').AsInteger;
    if AuctionOfferIndex = 0 then
      Exit(false); // Retorna False em caso de falha

    // Se chegou até aqui, a operação foi bem-sucedida
    Result := True;
  finally
    // Garantir que o SQLComp seja destruído, seja em caso de sucesso ou falha
    SQLComp.Query.Connection.Commit;
    // Commit a transação, se a execução foi bem-sucedida
    SQLComp.Free;
  end;
end;

{$ENDREGION}
{$REGION 'Cancel item offer'}

class function TAuctionFunctions.CancelItemOffer(var Player: TPlayer;
  AuctionOfferId: UInt64): Boolean;
var
  QueryString: string;
  Item: TItem;
  SQLComp: TQuery;
begin
  Result := false; // Inicializa como False, caso haja algum erro

  // Criar a consulta uma vez
  SQLComp := Self.CreateSQL;

  try
    // Consulta para verificar se o item está ativo
    QueryString :=
      Format('SELECT ItemId, ItemLookId, IdentificableAddOns, EffectId_1, EffectId_2, EffectId_3, '
      + 'EffectValue_1, EffectValue_2, EffectValue_3, DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime, Active '
      + 'FROM ' + MYSQL_DATABASE + '.vwauction_getactiveoffers ' +
      'WHERE CharacterId = %d AND AuctionId = %d',
      [Player.Base.Character.CharIndex, AuctionOfferId]);

    SQLComp.SetQuery(QueryString);
    SQLComp.Run;

    // Verificar se o item está inativo ou se não existe
    if (SQLComp.Query.FieldByName('Active').AsInteger = 0) or
      (SQLComp.Query.RecordCount = 0) then
    begin
      Exit(false); // Retorna False em caso de erro
    end;

    // Preencher os dados do item
    ZeroMemory(@Item, sizeof(TItem));
    Item.Index := SQLComp.Query.FieldByName('ItemId').AsInteger;
    Item.APP := SQLComp.Query.FieldByName('ItemLookId').AsInteger;
    Item.Identific := SQLComp.Query.FieldByName('IdentificableAddOns')
      .AsInteger;
    Item.Effects.Index[0] := SQLComp.Query.FieldByName('EffectId_1').AsInteger;
    Item.Effects.Index[1] := SQLComp.Query.FieldByName('EffectId_2').AsInteger;
    Item.Effects.Index[2] := SQLComp.Query.FieldByName('EffectId_3').AsInteger;
    Item.Effects.Value[0] := SQLComp.Query.FieldByName('EffectValue_1')
      .AsInteger;
    Item.Effects.Value[1] := SQLComp.Query.FieldByName('EffectValue_2')
      .AsInteger;
    Item.Effects.Value[2] := SQLComp.Query.FieldByName('EffectValue_3')
      .AsInteger;
    Item.Min := SQLComp.Query.FieldByName('DurabilityMin').AsInteger;
    Item.Max := SQLComp.Query.FieldByName('DurabilityMax').AsInteger;
    Item.Refi := SQLComp.Query.FieldByName('Amount_Reinforce').AsInteger;
    Item.Time := SQLComp.Query.FieldByName('ItemTime').AsInteger;

    // Atualizar o estado do item para inativo no banco
    QueryString := Format('UPDATE auction SET Active = 0 WHERE AuctionId = %d',
      [AuctionOfferId]);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(false);
    SQLComp.Query.Connection.Commit;

    // Verificar se a atualização foi bem-sucedida
    if SQLComp.Query.RowsAffected > 0 then
    begin
      Self.SendCancelResult(Player, AuctionOfferId);
      TItemFunctions.PutItem(Player, Item, 0, True);
      Result := True; // Sucesso
    end;
  finally
    SQLComp.Free; // Garantir a destruição do SQLComp ao final
  end;

end;

class procedure TAuctionFunctions.SendCancelResult(var Player: TPlayer;
  AuctionOfferId: UInt64);
var
  Packet: TAuctionCancelOfferPacket;
begin
  ZeroMemory(@Packet, sizeof(TAuctionCancelOfferPacket));
  Packet.Header.Size := sizeof(TAuctionCancelOfferPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F10;
  Packet.AuctionOfferId := AuctionOfferId;
  Packet.ResponseStatus := 1;
  Player.SendPacket(Packet, Packet.Header.Size);
end;
{$ENDREGION}
{$REGION 'Buy item offer'}

class function TAuctionFunctions.RequestBuyItem(var Player: TPlayer;
  AuctionOfferId: UInt64): Boolean;
var
  QueryString: string;
  AcquisitionMailId, AcquisitionMailItemId, AcquisitionSellerMailId: UInt64;
  SellingPrice: DWORD;
  SQLComp: TQuery;
begin
  Result := True;
  AcquisitionMailId := 0;
  SQLComp := Self.CreateSQL;
  try
    // Verificar se há ofertas ativas
    QueryString :=
      Format('SELECT 1 FROM vwauction_getactiveoffers WHERE AuctionId = %d AND Active = 0',
      [AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();

    if SQLComp.Query.RecordCount = 1 then
    begin
      Player.SendClientMessage('Espertinho, ta usando hack, GM foi avisado.');
      Exit(false);
    end;

    // Registrar as aquisições de correio
    if not(Self.RegisterAquisitionMail(Player, AuctionOfferId,
      AcquisitionMailId)) then
    begin
      Exit(false);
    end;

    if not(Self.RegisterSellerAquisitionMail(Player, AuctionOfferId,
      AcquisitionSellerMailId)) then
    begin
      Exit(false);
    end;

    // Iniciar transação e realizar operações de inserção e atualização
    SQLComp.Query.Connection.StartTransaction;

    // Inserir o item comprado
    QueryString :=
      Format('INSERT INTO mails_items (mail_id, slot, item_id, app, identific, effect1_index, effect1_value, '
      + 'effect2_index, effect2_value, effect3_index, effect3_value, min, max, refine, `time`) '
      + 'SELECT %d AS MailIndex, 0, ItemId, ItemLookId, IdentificableAddOns, EffectId_1, EffectValue_1, '
      + 'EffectId_2, EffectValue_2, EffectId_3, EffectValue_3, DurabilityMin, DurabilityMax, Amount_Reinforce, ItemTime '
      + 'FROM vwauction_getactiveoffers WHERE AuctionId=%d;',
      [AcquisitionMailId, AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(false);

    if SQLComp.Query.RowsAffected = 0 then
    begin
      SQLComp.Query.Connection.Rollback;
      Exit(false);
    end;

    // Atualizar o status do leilão e oferta
    QueryString := Format('UPDATE auction SET Active = 0 WHERE AuctionId = %d;',
      [AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(false);
    if SQLComp.Query.RowsAffected = 0 then
    begin
      SQLComp.Query.Connection.Rollback;
      Exit(false);
    end;

    QueryString :=
      Format('UPDATE vwauction_getactiveoffers SET Active = 0 WHERE AuctionId = %d;',
      [AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Run(false);
    if SQLComp.Query.RowsAffected = 0 then
    begin
      SQLComp.Query.Connection.Rollback;
      Exit(false);
    end;

    // Obter ID do item inserido
    QueryString := 'SELECT max(id) AS idx FROM mails_items;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    AcquisitionMailItemId := SQLComp.Query.FieldByName('idx').AsLargeInt;

    if AcquisitionMailItemId = 0 then
    begin
      SQLComp.Query.Connection.Rollback;
      Exit(false);
    end;

    // Verificar preço de venda
    QueryString :=
      Format('SELECT SellingPrice FROM auction WHERE AuctionId = %d',
      [AuctionOfferId]);
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();

    if SQLComp.Query.RecordCount = 0 then
    begin
      SQLComp.Query.Connection.Rollback;
      Exit(false);
    end;

    SellingPrice := SQLComp.Query.FieldByName('SellingPrice').AsLargeInt;
    if SellingPrice > Player.Base.Character.Gold then
    begin
      SQLComp.Query.Connection.Rollback;
      Player.SendClientMessage('Gold insuficiente! estranho !!!!!');
      Exit(false);
    end;

    // Subtrair ouro do jogador
    Player.DecGold(SellingPrice);

    // Finalizar transação e enviar resultado
    SQLComp.Query.Connection.Commit;
    Self.SendBuyResult(Player, AuctionOfferId);
    Player.SendClientMessage('O item comprado será entregue por correio');
  except
    on E: Exception do
    begin
      SQLComp.Query.Connection.Rollback;
      Result := false;
    end;
  end;

  SQLComp.Free;
end;

class procedure TAuctionFunctions.SendBuyResult(var Player: TPlayer;
  AuctionOfferId: UInt64);
var
  Packet: TAuctionBuyOfferPacket;
begin
  ZeroMemory(@Packet, sizeof(TAuctionBuyOfferPacket));
  Packet.Header.Size := sizeof(TAuctionBuyOfferPacket);
  Packet.Header.Index := Player.Base.ClientID;
  Packet.Header.Code := $3F0C;
  Packet.AuctionOfferId := AuctionOfferId;
  Packet.ResponseStatus := 256;
  Player.SendPacket(Packet, Packet.Header.Size);
end;

class function TAuctionFunctions.RegisterAquisitionMail(var Player: TPlayer;
  AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
var
  QueryString: string;
  SQLComp: TQuery;
begin
  Result := false; // Assume falha até ser comprovado sucesso
  SQLComp := Self.CreateSQL;

  try

    // Verifica se o auctionId existe
    QueryString :=
      'SELECT CharacterId FROM auction WHERE AuctionId = :AuctionOfferId';
    SQLComp.SetQuery(QueryString);
    SQLComp.Query.ParamByName('AuctionOfferId').AsInteger := AuctionOfferId;
    SQLComp.Run();

    if SQLComp.Query.RecordCount = 0 then
    begin
      Exit;
    end;

    // Verifica se o jogador está tentando comprar seu própio item
    if Player.Base.Character.CharIndex = SQLComp.Query.Fields[0].AsInteger then
    begin
      Player.SendClientMessage('Você não pode comprar seu própio item.');
      Exit;
    end;

    // Insere a mensagem de aquisição
    QueryString :=
      Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, textBody, slot, sentGold, gold, returnDate, sentDate, isFromAuction, canReturn, hasItems) '
      + 'VALUES (%d, 1, "Casa de leilões", "Item Comprado", "Entrega de item adquirido na casa de leilões", 0, 0, 0, "%s", "%s", 1, 0, 1);',
      [Player.Base.Character.CharIndex, FormatDateTime('yyyy-mm-dd hh:nn:ss',
      IncDay(Now, 90)), FormatDateTime('yyyy-mm-dd hh:nn:ss', Now)]);

    SQLComp.SetQuery(QueryString);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.Run(false);

    // Comita a transação
    SQLComp.Query.Connection.Commit;

    // Verifica se a inserção foi bem-sucedida
    if SQLComp.Query.RowsAffected = 0 then
      Exit;

    // obtém o último ID de e-mail inserido
    QueryString := 'SELECT MAX(id) AS idx FROM mails';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();

    MailIndex := UInt64(SQLComp.Query.FieldByName('idx').AsLargeInt);
    if MailIndex = 0 then
      Exit;

    Result := True; // Sucesso

  except
    SQLComp.Free; // Garante que o objeto SQLComp será destruído
  end;

end;

class function TAuctionFunctions.RegisterSellerAquisitionMail
  (var Player: TPlayer; AuctionOfferId: UInt64; OUT MailIndex: UInt64): Boolean;
var
  QueryString: string;
  SQLComp: TQuery;
begin
  Result := True;
  MailIndex := 0;
  SQLComp := Self.CreateSQL;
  try
    QueryString :=
      Format('INSERT INTO mails (characterId, sentCharacterId, sentCharacterName, title, '
      + 'textBody, slot, sentGold, gold, returnDate, ' +
      'sentDate, isFromAuction, canReturn) SELECT CharacterId, 1, "Casa de leilões", '
      + '"Item Vendido", "Entrega de gold por venda na casa de leilões", 0, ' +
      'SellingPrice, SellingPrice, "%s", "%s", 1, 0 FROM ' + MYSQL_DATABASE +
      '.vwauction_getactiveoffers WHERE AuctionId=%d;',
      [FormatDateTime('yyyy-mm-dd hh:nn:ss', IncDay(Now, 90)),
      FormatDateTime('yyyy-mm-dd hh:nn:ss', Now), AuctionOfferId]);

    SQLComp.SetQuery(QueryString);
    SQLComp.Query.Connection.StartTransaction;
    SQLComp.Run(false);
    SQLComp.Query.Connection.Commit;
    if (SQLComp.Query.RowsAffected = 0) then
    begin
      SQLComp.Free;
      Result := false;
      Exit;
    end;
    QueryString := 'SELECT max(id) as idx from mails;';
    SQLComp.SetQuery(QueryString);
    SQLComp.Run();
    MailIndex := UInt64(SQLComp.Query.FieldByName('idx').AsLargeInt);
    if MailIndex = 0 then
    begin
      SQLComp.Free;
      Result := false;
      Exit;
    end;
  except
    begin
      SQLComp.Free;
      Result := false;
      Exit;
    end;
  end;
  SQLComp.Free;
end;

{$ENDREGION}
{$REGION 'Check offer expire time'}

class function TAuctionFunctions.CheckAuctionItems(): Boolean;
begin
  // checa se há itens via query mysql com data de expiracao menor que agora e pega todos os ids e envia pra função register return mail
end;

class function TAuctionFunctions.RegisterReturnMail(OUT MailIndex
  : UInt64): Boolean;
begin
  // Lógica, ve se ta ativo, depois pega e reenvia o item de volta pro jogador
end;
{$ENDREGION}

end.
