unit ItemFunctions;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses MiscData, Player, BaseMob, BaseNpc, Windows, PlayerData, PacketHandlers,
  Packets, SQL;

type

TItemFunctions = class(TObject)
  public
    class function CreateSQL: TQuery;
    class function GetResultRefineItem(const item: WORD; Extract: WORD;
      Refine: BYTE): BYTE;
    class function ReinforceItem(var Player: TPlayer; item: DWORD; Item2: DWORD;
      Item3: DWORD): BYTE;
    class procedure GetChances(out Sucesso: Integer; out Reduz: Integer;
      out Quebra: Integer; out Falha: Integer);
    class function ReduceItemLevel(var Player: TPlayer; item: DWORD): BYTE;
    { Item Amount }
    class function GetItemAmount(item: TItem): BYTE; static;
    class procedure SetItemAmount(var item: TItem; quant: WORD;
      Somar: Boolean = False); static;
    class procedure DecreaseAmount(item: PItem; Quanti: WORD = 1); overload;
    class procedure DecreaseAmount(var Player: TPlayer; Slot: BYTE;
      Quanti: WORD = 1); overload;
    class function AgroupItem(SrcItem, DestItem: PItem): Boolean;
    { Item Price }
    class function GetBuyItemPrice(item: TItem; var Price: TItemPrice;
      quant: WORD = 1): Boolean;
    { Item Propertys }
    class function CanAgroup(item: TItem): Boolean; overload;
    class function CanAgroup(item: TItem; Quanti: WORD): Integer; overload;
    { Put e Remove item }
    class function PutItem(var Player: TPlayer; item: TItem;
      StartSlot: BYTE = 0; Notice: Boolean = False): Integer; overload;
    class function PutItem(var Player: TPlayer; Index: WORD; quant: WORD = 1)
      : Integer; overload;
    class function PutEquipament(var Player: TPlayer; Index: Integer;
      Refine: Integer = 0): Integer;
    class function RemoveItem(var Player: TPlayer;
      const SlotType, Slot: Integer): Boolean;
    class function PutItemOnEvent(var Player: TPlayer; ItemIndex: WORD;
      ItemAmount: WORD = 1): Boolean;
    class function PutItemOnEventByCharIndex(var Player: TPlayer;
      CharIndex: Integer; ItemIndex: WORD): Boolean;
    { Item Duration }
    class function SetItemDuration(var item: TItem): Boolean;
    { Conjunt & Equip }
    class function GetItemEquipSlot(Index: Integer): Integer;
    class function GetItemEquipPranSlot(Index: Integer): Integer;
    class function GetConjuntCount(const BaseMB: TBaseMob;
      Index: Integer): Integer;
    class function GetConjuntCountNPC(const BaseMB: TBaseNpc;
      Index: Integer): Integer;
    class function GetItemBySlot(var Player: TPlayer; Slot: BYTE;
      out item: TItem): Boolean;
    class function GetClass(ClassInfo: Integer = 0): Integer;
    { Inventory Slots }
    class function GetInvItemCount(const Player: TPlayer): Integer;
    class function GetInvAvailableSlots(const Player: TPlayer): Integer;
    class function GetInvMaxSlot(const Player: TPlayer): Integer;
    class function GetInvPranMaxSlot(const Player: TPlayer): Integer;
    class function GetEmptySlot(const Player: TPlayer): BYTE; static;
    class function GetEmptyPranSlot(const Player: TPlayer): BYTE; static;
    class function VerifyItemSlot(var Player: TPlayer; Slot: Integer;
      const item: TItem): Boolean;
    class function VerifyBagSlot(const Player: TPlayer; Slot: Integer): Boolean;
    class function GetItemSlot(const Player: TPlayer; item: TItem;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE; static;
    class function GetItemSlot2(const Player: TPlayer; ItemID: WORD)
      : BYTE; static;
    class function GetItemSlotByItemType(const Player: TPlayer; ItemType: WORD;
      SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
    class function GetItemSlotAndAmountByIndex(const Player: TPlayer;
      ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
    class function GetItemReliquareSlot(const Player: TPlayer): BYTE;
    class function GetItemThatExpires(const Player: TPlayer;
      SlotType: BYTE): BYTE;
    { Ramdom Select Functions }
    class function SelectRamdomItem(const Items: ARRAY OF WORD;
      const Chances: ARRAY OF WORD): WORD;
    { Reinforce }
    class function GetArmorReinforceIndex(const item: WORD): WORD;
    class function GetReinforceCust(const Index: WORD): Cardinal;
    class function GetItemReinforce2Index(ItemIndex: WORD): WORD;
    class function GetItemReinforce3Index(ItemIndex: WORD): WORD;
    { Enchant }
    class function Enchantable(item: TItem): Boolean;
    class function GetEmptyEnchant(item: TItem): BYTE;
    class function EnchantItem(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Change App }
    class function Changeable(item: TItem): Boolean;
    class function ChangeApp(var Player: TPlayer; item: DWORD; Athlon: DWORD;
      NewApp: DWORD): BYTE;
    { Mount Enchant }
    class function EnchantMount(var Player: TPlayer; ItemSlot: DWORD;
      Item2: DWORD): BYTE;
    { Premium Inventory Function }
    class function FindPremiumIndex(Index: WORD): WORD;
    { Use item }
    class function UsePremiumItem(var Player: TPlayer; Slot: Integer): Boolean;
    class function SpawnMob(Player: TPlayer; Local: TPosition; ID: Integer;
      AttackerID: Integer; IsBoss: Boolean): Boolean;
    class function SpawnNpc(Player: TPlayer; Local: TPosition; ID: Integer;
      AttackerID: Integer; IsBoss: Boolean): Boolean;
    class function UseItem(var Player: TPlayer; Slot: byte;
      Type1: DWORD = 0): Boolean;
      class procedure AddAuxilyTime(var Player: TPlayer; Dias: byte);
    { Item Reinforce Stats }
    class function GetItemReinforceDamageReduction(Index: WORD;
      Refine: BYTE): WORD;
    class function GetItemReinforceHPMPInc(Index: WORD; Refine: BYTE): WORD;
    class function GetReinforceFromItem(const item: TItem): BYTE;
    { ItemDB Functions }
    class function UpdateMovedItems(var Player: TPlayer;
      SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
      SrcItem, DestItem: PItem): Boolean;
    { Recipe Functions }
    class function GetIDRecipeArray(RecipeItemID: WORD): WORD;

  private
    class var FSucessoChance: Integer;
    class var FReduzChance: Integer;
    class var FQuebraChance: Integer;
    class var FFalhaChance: Integer;
  end;

implementation

uses GlobalDefs, Log, SysUtils, DateUtils, FilesData, Math, Util,
  NPCHandlers;

class function TItemFunctions.CreateSQL: TQuery;
begin
  // Criando a conexão usando as variáveis globais já definidas
  Result := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
end;

{$REGION 'Item Amount'}

class function TItemFunctions.GetItemAmount(item: TItem): BYTE;
begin
  if ItemList[item.Index].CanAgroup then
    Result := item.Refi
  else
    Result := 1;
end;

class procedure TItemFunctions.SetItemAmount(var item: TItem; quant: WORD;
  Somar: Boolean = False);
begin
  if ItemList[item.Index].CanAgroup then
  begin
    if Somar then
      Inc(item.Refi, quant)
    else
      item.Refi := quant;
  end;
end;

class procedure TItemFunctions.DecreaseAmount(item: PItem; Quanti: WORD = 1);
begin
  if (item.Refi - Quanti) > 0 then
    Dec(item.Refi, Quanti)
  else
    ZeroMemory(item, sizeof(TItem));
end;

class procedure TItemFunctions.DecreaseAmount(var Player: TPlayer; Slot: BYTE;
  Quanti: WORD = 1);
begin
  Self.DecreaseAmount(@Player.Character.Base.Inventory[Slot], Quanti);
end;

class function TItemFunctions.AgroupItem(SrcItem: PItem;
  DestItem: PItem): Boolean;
var
  Aux: TItem;
begin
  Result := False;
  if ItemList[SrcItem.Index].CanAgroup then
  begin
    if (SrcItem.Refi + DestItem.Refi) > MAX_SLOT_AMOUNT then
    begin
      if (SrcItem.Refi = 1000) or (DestItem.Refi = 1000) then
      begin
        Move(DestItem^, Aux, sizeof(TItem));
        Move(SrcItem^, DestItem^, sizeof(TItem));
        Move(Aux, SrcItem^, sizeof(TItem));
        Result := True;
        Exit;
      end;
      TItemFunctions.SetItemAmount(SrcItem^, MAX_SLOT_AMOUNT);
      TItemFunctions.SetItemAmount(DestItem^, (SrcItem.Refi + DestItem.Refi) -
        MAX_SLOT_AMOUNT);
    end
    else
    begin
      Inc(SrcItem^.Refi, DestItem^.Refi);
      ZeroMemory(DestItem, sizeof(TItem));
      Result := True;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Item Price'}

class function TItemFunctions.GetBuyItemPrice(item: TItem;
  var Price: TItemPrice; quant: WORD = 1): Boolean;
begin
  if ItemList[item.Index].TypePriceItem > 0 then
  begin
    Price.PriceType := PRICE_ITEM;
    Price.Value1 := ItemList[item.Index].TypePriceItem;
    Price.Value2 := ItemList[item.Index].TypePriceItemValue * quant;
    Result := True;
  end
  else if (ItemList[item.Index].PriceHonor > 0) and
    (ItemList[item.Index].SellPrince = 0) then
  begin
    Price.PriceType := PRICE_HONOR;
    Price.Value1 := ItemList[item.Index].PriceHonor * quant;
    Price.Value2 := ItemList[item.Index].PriceMedal * quant;
    Result := True;
  end
  else if ItemList[item.Index].PriceMedal > 0 then
  begin
    Price.PriceType := PRICE_MEDAL;
    Price.Value1 := ItemList[item.Index].PriceMedal * quant;
    Price.Value2 := ItemList[item.Index].PriceGold * quant;
    Result := True;
  end
  else
  begin
    Price.PriceType := PRICE_GOLD;
    Price.Value1 := ItemList[item.Index].SellPrince * quant;
    Result := True;
  end;
end;
{$ENDREGION}
{$REGION 'Item Propertys'}

class function TItemFunctions.CanAgroup(item: TItem): Boolean;
begin
  Result := ItemList[item.Index].CanAgroup;
end;

class function TItemFunctions.CanAgroup(item: TItem; Quanti: WORD): Integer;
begin
  if not ItemList[item.Index].CanAgroup then
    Result := ITEM_UNAGRUPABLE
  else if item.Refi + Quanti > 1000 then
    Result := ITEM_QUANT_EXCEDE
  else
    Result := ITEM_AGRUPABLE;
end;
{$ENDREGION}
{$REGION 'Put & Remove Item'}

class function TItemFunctions.PutItem(var Player: TPlayer; item: TItem;
  StartSlot: BYTE = 0; Notice: Boolean = False): Integer;
var
  Slot, InInventory: BYTE;
  quant, i: WORD;
  ItemInv: TItem;
begin
  Slot := 0;
  Result := -1;
  InInventory := Self.GetItemSlot(Player, item, INV_TYPE, StartSlot);

  if (ItemList[item.Index].Expires) and not(ItemList[item.Index].CanSealed) then
    Self.SetItemDuration(item);

  if (ItemList[item.Index].CanSealed) then
    item.IsSealed := True;

  case InInventory of
    0 .. 128:
      begin
        case Self.CanAgroup(Player.Character.Base.Inventory[InInventory],
          item.Refi) of
          ITEM_UNAGRUPABLE:
            begin
              Slot := Self.GetEmptySlot(Player);
              if (Slot = 255) then
              begin
                Player.SendClientMessage('Inventário cheio!');
                Exit;
              end;

              if (item.Index = 5300) then
              begin
                for Slot := 120 to 125 do
                begin
                  if (Player.Character.Base.Inventory[Slot].Index = 0) then
                  begin
                    Move(item, Player.Character.Base.Inventory[Slot],
                      sizeof(TItem));
                    Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
                      Player.Character.Base.Inventory[Slot], Notice);
                    Continue;
                  end;
                end;
                Exit;
              end;


              if ((ItemList[item.Index].ItemType >= 1000) and (ItemList[item.Index].ItemType <= 1008)) or ((ItemList[item.Index].ItemType >= 1) and (ItemList[item.Index].ItemType <= 7))  then
              begin
                Randomize;
                item.Min := Random(255);
              end;

              Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, Player.Character.Base.Inventory[Slot], Notice);
            end;

          ITEM_QUANT_EXCEDE:
            begin
              Move(item, ItemInv, sizeof(TItem));
              quant := MAX_SLOT_AMOUNT - Player.Character.Base.Inventory
                [InInventory].Refi;
              if (quant > 0) then
              begin
                Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                  MAX_SLOT_AMOUNT);
                Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                  Player.Character.Base.Inventory[InInventory], Notice);
                Dec(ItemInv.Refi, quant);
              end;
              Result := Self.PutItem(Player, ItemInv, InInventory + 1);
            end;

          ITEM_AGRUPABLE:
            begin

              Self.SetItemAmount(Player.Character.Base.Inventory[InInventory],
                item.Refi, True);
              Player.Base.SendRefreshItemSlot(INV_TYPE, InInventory,
                Player.Character.Base.Inventory[InInventory], Notice);
            end;
        end;
      end;

    255:
      begin
        Slot := Self.GetEmptySlot(Player);
        Move(item, Player.Character.Base.Inventory[Slot], sizeof(TItem));
        Player.Base.SendRefreshItemSlot(INV_TYPE, Slot,
          Player.Character.Base.Inventory[Slot], Notice);

        if ItemList[Player.Character.Base.Inventory[Slot].Index].ItemType = 40
        then
        begin
          for i := Low(Servers) to High(Servers) do
          begin
            var
            CityID := Servers[Player.Base.ChannelId].Players
              [Player.Base.ClientID].GetCurrentCityID;
            var
            Channel_ID := Servers[Player.Base.ChannelId].Players
              [Player.Base.ClientID].ChannelIndex;

            if (CityID >= Low(MapNames)) and (CityID <= High(MapNames)) then
            begin
              var
              CityName := MapNames[CityID];
              if (Channel_ID >= Low(Nacoes)) and (Channel_ID <= High(Nacoes))
              then
              begin
                var
                NationName := Nacoes[Channel_ID];
                if CityName <> '' then
                begin
                  var
                  mensagem3 := '[Mapa]: ' + CityName + ' [Nação]: ' +
                    NationName;
                  Servers[i].SendServerMsg
                    ('O jogador ' + AnsiString(Player.Base.Character.Name) +
                    ' adquiriu a relíquia:', 16, 32, 16);
                  Servers[i].SendServerMsg
                    ('<' + AnsiString(ItemList[Player.Character.Base.Inventory
                    [Slot].Index].Name) + '>.', 16, 32, 16);
                  Servers[i].SendServerMsg(mensagem3, 16, 32, 16);
                end;
              end;
            end;
          end;
          Player.SendEffect(32);
        end;
      end;
  end;

  if (Result = -1) and (Slot <> 255) then
    Result := Slot;
end;

class function TItemFunctions.PutItem(var Player: TPlayer;
  Index, quant: WORD): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(item));
  item.Index := Index;
  item.APP := Index;
  item.Refi := quant;
  item.MIN := ItemList[item.Index].Durabilidade;
  item.MAX := item.MIN;
  Result := Self.PutItem(Player, item, 0, True)
end;

class function TItemFunctions.PutEquipament(var Player: TPlayer; Index: Integer;
  Refine: Integer = 0): Integer;
var
  item: TItem;
begin
  ZeroMemory(@item, sizeof(TItem));
  item.Index := Index;
  item.APP := Index;
  item.MAX := ItemList[item.Index].Durabilidade;
  item.MIN := item.MAX;
  item.Refi := Refine;
  Result := Self.PutItem(Player, item, 0, True)
end;

class function TItemFunctions.RemoveItem(var Player: TPlayer;
  const SlotType, Slot: Integer): Boolean;
var
  item: PItem;
begin
  Result := False;
  item := Nil;

  case SlotType of
    INV_TYPE:
      if (Slot in [0 .. 125]) then
        item := @Player.Character.Base.Inventory[Slot]
      else
        Exit;

    STORAGE_TYPE:
      if (Slot in [0 .. 83]) then
        item := @Player.Account.Header.Storage.Itens[Slot]
      else
        Exit;

    CASH_TYPE:
      if (Slot in [0 .. 23]) then
        with Player.Account.Header.CashInventory.Items[Slot] do
          item^ := ToItem
      else
        Exit;

    EQUIP_TYPE:
      if (Slot in [0 .. 15]) then
        item := @Player.Character.Base.Equip[Slot]
      else
        Exit;

    PRAN_EQUIP_TYPE:
      if Player.SpawnedPran <> 255 then
        case Player.SpawnedPran of
          0, 1:
            if (Slot in [1 .. 5]) then
              if Player.SpawnedPran = 0 then
                item := @Player.Account.Header.Pran1.Equip[Slot]
              else
                item := @Player.Account.Header.Pran2.Equip[Slot]
            else
              Exit;
        else
          Exit;
        end
      else
        Exit;

    PRAN_INV_TYPE:
      if Player.SpawnedPran <> 255 then
        case Player.SpawnedPran of
          0, 1:
            if (Slot in [0 .. 41]) then
              if Player.SpawnedPran = 0 then
                item := @Player.Account.Header.Pran1.Inventory[Slot]
              else
                item := @Player.Account.Header.Pran2.Inventory[Slot]
            else
              Exit;
        else
          Exit;
        end
      else
        Exit;

  else
    Exit;
  end;

  if item = Nil then
    Exit;

  ZeroMemory(item, sizeof(TItem));
  Player.Base.SendRefreshItemSlot(SlotType, Slot, item^, False);
  Result := True;
end;

class function TItemFunctions.PutItemOnEvent(var Player: TPlayer;
  ItemIndex: WORD; ItemAmount: WORD): Boolean;
var
  SQLComp: TQuery;
  charid: Integer;
begin
  SQLComp := Self.CreateSQL;
  with SQLComp.Query.Connection do
  begin
    if not Connected then
    begin
      Logger.Write('Falha de conexão individual com mysql.[PutItemOnEvent]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEvent]',
        TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;

  try
    charid := IfThen(Player.Base.Character.CharIndex = 0,
      Player.Account.Characters[0].Index, Player.Base.Character.CharIndex);

    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES (%d, %d, %d, %d, 0)',
      [EVENT_ITEM, charid, ItemIndex, ItemAmount]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TlogType.Error);
    end;
  end;

  SQLComp.Destroy;
end;

class function TItemFunctions.PutItemOnEventByCharIndex(var Player: TPlayer;
  CharIndex: Integer; ItemIndex: WORD): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := Self.CreateSQL;
  with SQLComp.Query.Connection do
  begin
    if not Connected then
    begin
      Logger.Write
        ('Falha de conexão individual com mysql.[PutItemOnEventByCharIndex]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[PutItemOnEventByCharIndex]',
        TlogType.Error);
      SQLComp.Destroy;
      Exit;
    end;
  end;
  try
    SQLComp.SetQuery
      (format('INSERT INTO items (slot_type, owner_id, item_id, refine, slot) VALUES '
      + '(%d, %d, %d, %d, 0)', [EVENT_ITEM, CharIndex, ItemIndex, 1]));
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.PutItemOnEvent ' + E.Message,
        TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
end;

{$ENDREGION}
{$REGION 'Item Duration'}

class function TItemFunctions.SetItemDuration(var item: TItem): Boolean;
begin
  Result := False;
  with ItemList[item.Index] do
  begin
    if Expires then
      item.ExpireDate := IncHour(Now, Duration + 2)
    else
      Exit;
  end;
  Result := True;
end;

{$ENDREGION}
{$REGION 'Conjunt & Equip'}

class function TItemFunctions.GetItemEquipSlot(Index: Integer): Integer;
begin
  Result := 0;
  with ItemList[Index] do
  begin

    case ItemType of
      50, 52, 103, 102:
        Result := 15;
      0 .. 16:
        Result := ItemType;
      1000 .. 1011, 1019:
        Result := 6;
    else
      Exit;
    end;
    // if (ItemType = 50) or (ItemType = 52) or (ItemType = 103) or (ItemType = 102) then
    // begin
    // Result := 15;
    // Exit;
    // end;
    //
    // if (ItemType > 0) and (ItemType < 16) then
    // begin
    // Result := ItemType;
    // Exit;
    // end
    // else if (ItemType > 1000) and (ItemType < 1011) or (ItemType = 1019) then
    // begin
    // Result := 6;
    // Exit;
    // end;
  end;
end;

class function TItemFunctions.GetItemEquipPranSlot(Index: Integer): Integer;
begin
  Result := ItemList[Index].ItemType - 18;
end;

class function TItemFunctions.GetConjuntCount(const BaseMB: TBaseMob;
  Index: Integer): Integer;
var
  Conjunt: Integer;
  i: Integer;
begin
  Conjunt := Conjuntos[Index];
  Result := 0;
  for i := 0 to 15 do
    if BaseMB.EQUIP_CONJUNT[i] = Conjunt then
      Inc(Result);
end;

class function TItemFunctions.GetConjuntCountNPC(const BaseMB: TBaseNpc;
  Index: Integer): Integer;
var
  Conjunt: Integer;
  i: Integer;
begin
  Conjunt := Conjuntos[Index];
  Result := 0;
  for i := 0 to 15 do
    if BaseMB.EQUIP_CONJUNT[i] = Conjunt then
      Inc(Result);
end;

class function TItemFunctions.GetItemBySlot(var Player: TPlayer; Slot: BYTE;
  out item: TItem): Boolean;
begin
  if (Slot > 125) then
    Exit(False);

  item := Player.Base.Character.Inventory[Slot];
  Result := True;
end;

class function TItemFunctions.GetClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
  if (ClassInfo >= 1) and (ClassInfo <= 9) then
    Exit(0);
  if (ClassInfo >= 11) and (ClassInfo <= 19) then
    Exit(1);
  if (ClassInfo >= 21) and (ClassInfo <= 29) then
    Exit(2);
  if (ClassInfo >= 31) and (ClassInfo <= 39) then
    Exit(3);
  if (ClassInfo >= 41) and (ClassInfo <= 49) then
    Exit(4);
  if (ClassInfo >= 51) and (ClassInfo <= 59) then
    Exit(5);
end;
{$ENDREGION}
{$REGION 'Inventory Slots'}

class function TItemFunctions.VerifyItemSlot(var Player: TPlayer; Slot: Integer;
  const item: TItem): Boolean;
var
  OriginalItem: TItem;
begin
  ZeroMemory(@OriginalItem, sizeof(TItem));
  OriginalItem := Player.Character.Base.Inventory[Slot];
  Result := CompareMem(@OriginalItem, @item, sizeof(TItem));
end;

class function TItemFunctions.GetInvItemCount(const Player: TPlayer): Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Self.GetInvMaxSlot(Player) do
    if (Player.Character.Base.Inventory[i].Index > 0) then
      Inc(Result);
end;

class function TItemFunctions.GetInvAvailableSlots(const Player
  : TPlayer): Integer;
var
  i: Integer;
  MaxSlots: Integer;
begin
  MaxSlots := 0;

  // Itera pelas bolsas entre 120 e 125
  for i := 120 to 125 do
    MaxSlots := MaxSlots + Ord(Player.Character.Base.Inventory[i].
      Index > 0) * 20;

  // Adiciona os 20 slots da bolsa inicial
  // Result := 20 + MaxSlots - Self.GetInvItemCount(Player);
  Result := MaxSlots - Self.GetInvItemCount(Player);
end;

class function TItemFunctions.GetInvMaxSlot(const Player: TPlayer): Integer;
var
  i: Integer;
  MaxSlots: Integer;
begin
  MaxSlots := 0;

  // Itera pelas bolsas entre 120 e 125
  for i := 120 to 125 do
    MaxSlots := MaxSlots + Ord(Player.Character.Base.Inventory[i].
      Index > 0) * 20;

  // Adiciona os 20 slots da bolsa inicial
  // Result := 20 + MaxSlots;
  Result := MaxSlots;
end;

class function TItemFunctions.GetInvPranMaxSlot(const Player: TPlayer): Integer;
begin
  Result := 19;
  case Player.SpawnedPran of
    0:
      begin
        if (Player.Account.Header.Pran1.Inventory[41].Index > 0) then
          Result := 39;
      end;
    1:
      begin
        if (Player.Account.Header.Pran2.Inventory[41].Index > 0) then
          Result := 39;
      end;
  end;
end;

class function TItemFunctions.GetEmptySlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;
begin
  Result := 255; // Valor padrão indicando que não há slots disponíveis
  MAX_SLOT := GetInvMaxSlot(Player);
  // Obtém o número máximo de slots disponíveis

  for i := 0 to MAX_SLOT - 1 do
  begin
    // Verifica se o slot está vazio
    if Player.Character.Base.Inventory[i].Index <> 0 then
      Continue;

    case i of
      0 .. 19: // Bolsa inicial (slots 0 a 19)
        begin
          if (Player.Character.Base.Inventory[120].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      20 .. 39: // Bolsa 1 (120)
        begin
          if (Player.Character.Base.Inventory[121].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      40 .. 59: // Bolsa 2 (121)
        begin
          if (Player.Character.Base.Inventory[122].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      60 .. 79: // Bolsa 3 (122)
        begin
          if (Player.Character.Base.Inventory[123].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      80 .. 99: // Bolsa 4 (123)
        begin
          if (Player.Character.Base.Inventory[124].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
      100 .. 119: // Bolsa 5 (124)
        begin
          if (Player.Character.Base.Inventory[125].Index > 0) then
          begin
            Result := i;
            Exit;
          end;
        end;
    end;
  end;
end;

class function TItemFunctions.GetEmptyPranSlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
  MAX_SLOT: BYTE;
begin
  Result := 255;
  MAX_SLOT := GetInvPranMaxSlot(Player);

  case Player.SpawnedPran of
    0:
      begin
        with Player.Account.Header.Pran1 do
        begin
          for i := 0 to MAX_SLOT do
          begin
            if Inventory[i].Index <> 0 then
              Continue;

            case i of
              0 .. 19:
                begin
                  Result := i;
                  Exit;
                end;
              20 .. 39:
                begin
                  if Inventory[41].Index <> 0 then
                  begin
                    Result := i;
                    Exit;
                  end;
                end;
            end;
          end;
        end;
      end;
    1:
      begin
        with Player.Account.Header.Pran2 do
        begin
          for i := 0 to MAX_SLOT do
          begin
            if Inventory[i].Index <> 0 then
              Continue;

            case i of
              0 .. 19:
                begin
                  Result := i;
                  Exit;
                end;
              20 .. 39:
                begin
                  if Inventory[41].Index <> 0 then
                  begin
                    Result := i;
                    Exit;
                  end;
                end;
            end;
          end;
        end;
      end;
  end;
end;

class function TItemFunctions.VerifyBagSlot(const Player: TPlayer;
  Slot: Integer): Boolean;
begin
  Result := False;

  case Slot of
    0 .. 19: // Bolsa inicial
      Result := True;
    20 .. 39: // Bolsa 1 (120)
      if (Player.Character.Base.Inventory[120].Index > 0) then
        Result := True;
    40 .. 59: // Bolsa 2 (121)
      if (Player.Character.Base.Inventory[121].Index > 0) then
        Result := True;
    60 .. 79: // Bolsa 3 (122)
      if (Player.Character.Base.Inventory[122].Index > 0) then
        Result := True;
    80 .. 99: // Bolsa 4 (123)
      if (Player.Character.Base.Inventory[123].Index > 0) then
        Result := True;
    100 .. 119: // Bolsa 5 (124)
      if (Player.Character.Base.Inventory[124].Index > 0) then
        Result := True;
  end;
end;

class function TItemFunctions.GetItemSlot(const Player: TPlayer; item: TItem;
  SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: Integer;
begin
  case SlotType of
    INV_TYPE:
      for i := StartSlot to 125 do
        if Player.Character.Base.Inventory[i].Index = item.Index then
          Exit(i);
    EQUIP_TYPE:
      for i := StartSlot to 15 do
        if Player.Character.Base.Equip[i].Index = item.Index then
          Exit(i);
    STORAGE_TYPE:
      for i := StartSlot to 85 do
        if Player.Account.Header.Storage.Itens[i].Index = item.Index then
          Exit(i);
  end;
  Result := 255;
end;

class function TItemFunctions.GetItemSlot2(const Player: TPlayer;
  ItemID: WORD): BYTE;
var
  i: BYTE;
begin
  for i := 0 to 119 do
    if (Player.Character.Base.Inventory[i].Index = ItemID) then
      Exit(i);
  Result := 255;
end;

class function TItemFunctions.GetItemSlotByItemType(const Player: TPlayer;
  ItemType: WORD; SlotType: BYTE; StartSlot: BYTE = 0): BYTE;
var
  i: byte;
begin
  case SlotType of
    INV_TYPE:
      for i := StartSlot to 125 do
        if ItemList[Player.Character.Base.Inventory[i].Index].ItemType = ItemType
        then
          Exit(i);
    EQUIP_TYPE:
      for i := StartSlot to 15 do
        if ItemList[Player.Character.Base.Equip[i].Index].ItemType = ItemType
        then
          Exit(i);
    STORAGE_TYPE:
      for i := StartSlot to 85 do
        if ItemList[Player.Account.Header.Storage.Itens[i].Index].ItemType = ItemType
        then
          Exit(i);
  end;
  Result := 255;
end;

class function TItemFunctions.GetItemSlotAndAmountByIndex(const Player: TPlayer;
  ItemIndex: WORD; out Slot, Refi: BYTE): Boolean;
var
  i: WORD;
begin
  Result := False;
  for i := 0 to 119 do
    if (Player.Base.Character.Inventory[i].Index = ItemIndex) then
    begin
      Slot := i;
      Refi := Player.Base.Character.Inventory[i].Refi;
      Exit(True);
    end;
end;

class function TItemFunctions.GetItemReliquareSlot(const Player: TPlayer): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 119 do
  begin
    if (Player.Base.Character.Inventory[i].Index <> 0) and
      (ItemList[Player.Base.Character.Inventory[i].Index].ItemType = 40) then
    begin
      Result := i;
      Break;
    end;
  end;
end;

class function TItemFunctions.GetItemThatExpires(const Player: TPlayer;
  SlotType: BYTE): BYTE;
var
  i: BYTE;
  item: PItem;
begin
  Result := 255;
  case SlotType of
    INV_TYPE:
      for i := 0 to 119 do
      begin
        item := @Player.Base.Character.Inventory[i];
        if (item.Index <> 0) and (ItemList[item.Index].Expires) then
        begin
          Result := i;
          Break;
        end;
      end;
    EQUIP_TYPE:
      for i := 0 to 15 do
      begin
        item := @Player.Base.Character.Equip[i];
        if (item.Index <> 0) and (ItemList[item.Index].Expires) then
        begin
          Result := i;
          Break;
        end;
      end;
  end;
end;

{$ENDREGION}
{$REGION 'Ramdom Select Functions'}

class function TItemFunctions.SelectRamdomItem(const Items: ARRAY OF WORD;
  const Chances: ARRAY OF WORD): WORD;
var
  RandomTax, cnt, RamdomSlot: BYTE;
  RamdomArray: ARRAY OF WORD;
  i: Integer;
begin
  Result := 0;
  try
    Randomize;
    RandomTax := Random(100);
    cnt := 0;
    for i := 0 to Length(Items) - 1 do
    begin
      if (RandomTax <= Chances[i]) then
      begin
        SetLength(RamdomArray, cnt + 1);
        RamdomArray[cnt] := Items[i];
        Inc(cnt);
      end;
    end;

    // Se não há itens válidos em RamdomArray, seleciona aleatoriamente entre todos os itens
    if Length(RamdomArray) = 0 then
      RamdomSlot := RandomRange(0, Length(Items))
    else
      RamdomSlot := RandomRange(0, Length(RamdomArray));

    // Atribui o resultado
    if Length(RamdomArray) = 0 then
      Result := Items[RamdomSlot]
    else
      Result := RamdomArray[RamdomSlot];

  except
    on E: Exception do
    begin
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TlogType.Error);
      Logger.Write('TItemFunctions.SelectRamdomItem ' + E.Message,
        TlogType.Warnings);
    end;
  end;
end;

{$ENDREGION}

class function TItemFunctions.GetResultRefineItem(const item: WORD;
  Extract: WORD; Refine: BYTE): BYTE;
var
  RandomChance: Integer;
begin
  Result := 0; // Valor padrão: Sucesso
  RandomChance := Random(1000000); // Gera número entre 0 e 999,999

  // Exibe valores iniciais no console
  Writeln('Item: ', item, ', Extract: ', ItemList[Extract].ItemType,
    ', Refine: ', Refine);
  Writeln('RandomChance gerado: ', RandomChance);

  case ItemList[item].ItemType of
    1001, 1002, 1005, 1006, 1007, 1008, 2, 3, 4, 5, 7: // armas
      begin
        case ItemList[item].UseEffect of
          0 .. 12:
            begin
              // Cálculo das probabilidades com base no Refine e Extract
              case ItemList[Extract].ItemType of
                0: // Sem extrato
                  case Refine of
                    0 .. 4:
                      begin
                        if (RandomChance >= 0) then // 100% Sucesso
                          Result := 2; // Sucesso
                      end;
                    5 .. 11:
                      begin
                        if (RandomChance < 700000) then // 70% Quebra
                          Result := 0 // Quebra
                        else // 30% Sucesso
                          Result := 2; // Sucesso
                      end;
                  end;

                63, 65: // Extrato normal
                  case Refine of
                    0 .. 4:
                      begin
                        if (RandomChance >= 0) then // 100% Sucesso
                          Result := 2; // Sucesso
                      end;
                    5 .. 11:
                      begin
                        if RandomChance < 200000 then // 20% Sucesso
                          Result := 2 // Sucesso
                        else if (RandomChance >= 200000) and
                          (RandomChance < 800000) then
                          // Próximos 60% para Redução
                          Result := 1 // Redução
                        else // Últimos 20% para Falha
                          Result := 3; // Falha
                      end;
                  end;

                64, 66: // Extrato enriquecido
                  case Refine of
                    0 .. 4:
                      begin
                        if (RandomChance >= 0) then // 100% Sucesso
                          Result := 2; // Sucesso
                      end;
                    5 .. 11:
                      begin
                        if RandomChance < 10000 then // 1% Sucesso
                          Result := 2 // Sucesso
                        else // Próximos 70% para Falha
                          Result := 3; // Falha
                      end;
                  end;
              end;
            end;

          13 .. 100:
            begin
              // Cálculo das probabilidades com base no Refine e Extract
              case ItemList[Extract].ItemType of
                0: // Sem extrato
                  case Refine of
                    0 .. 2:
                      begin
                        if (RandomChance >= 0) then // 100% Sucesso
                          Result := 2; // Sucesso
                      end;
                    3 .. 11:
                      begin
                        if (RandomChance < 700000) then // 70% Quebra
                          Result := 0 // Quebra
                        else // 30% Sucesso
                          Result := 2; // Sucesso
                      end;
                  end;

                63, 65: // Extrato normal
                  case Refine of
                    0 .. 2:
                      begin
                        if (RandomChance >= 0) then // 100% Sucesso
                          Result := 2; // Sucesso
                      end;
                    3 .. 11:
                      begin
                        if RandomChance < 200000 then // 20% Sucesso
                          Result := 2 // Sucesso
                        else if (RandomChance >= 200000) and
                          (RandomChance < 800000) then
                          // Próximos 60% para Redução
                          Result := 1 // Redução
                        else // Últimos 20% para Falha
                          Result := 3; // Falha
                      end;
                  end;

                64, 66: // Extrato enriquecido
                  case Refine of
                    0 .. 2:
                      begin
                        if (RandomChance >= 0) then // 100% Sucesso
                          Result := 2; // Sucesso
                      end;
                    3 .. 11:
                      begin
                        if RandomChance < 10000 then // 1% Sucesso
                          Result := 2 // Sucesso
                        else // Próximos 70% para Falha
                          Result := 3; // Falha
                      end;
                  end;
              end;
            end;
        end;
      end;
  end;

  // Exibe o resultado final
  Writeln('Resultado final: ', Result);
end;

class function TItemFunctions.ReduceItemLevel(var Player: TPlayer;
  item: DWORD): BYTE;
var
  ItemIndex: Integer;
begin
  Result := 2; // Valor padrão: sucesso
  ItemIndex := Player.Character.Base.Inventory[item].Index;

  Dec(Player.Base.Character.Gold, Self.GetReinforceCust(ItemIndex));

  // dec(Player.Character.Base.Inventory[item].MIN, $1);
  // dec(Player.Character.Base.Inventory[item].MAX, $1);
  Inc(Player.Character.Base.Inventory[item].Refi, 16);
  Dec(Player.Character.Base.Inventory[item].Refi, 15);

  // criar logica pra limimitar a 15 niveis, se tentar acima do 15, dar exit.

end;

class procedure TItemFunctions.GetChances(out Sucesso: Integer;
  out Reduz: Integer; out Quebra: Integer; out Falha: Integer);
begin
  Sucesso := FSucessoChance;
  Reduz := FReduzChance;
  Quebra := FQuebraChance;
  Falha := FFalhaChance;
end;

class function TItemFunctions.ReinforceItem(var Player: TPlayer; item: DWORD;
  Item2: DWORD; Item3: DWORD): BYTE;
var
  ItemIndex: Integer;
  HiraKaize: PItem;
  Extract: Integer;
  Refine: Integer;
  Sucesso, Reduz, Quebra, Falha: Integer;
begin
  Result := 4; // Valor padrão: falha
  ItemIndex := Player.Character.Base.Inventory[item].Index;
  HiraKaize := @Player.Character.Base.Inventory[Item2];

  if (Item3 = $FFFFFFFF) then
    Extract := 0
  else
    Extract := Player.Character.Base.Inventory[Item3].Index;

{$REGION 'Checagens Importantes'}
  if (ItemList[HiraKaize.Index].Rank < ItemList[ItemIndex].Rank) then
    Exit;
  if (Extract > 0) and (ItemList[Extract].Rank < ItemList[ItemIndex].Rank) then
    Exit;
  if (Self.GetReinforceCust(ItemIndex) > Player.Character.Base.Gold) then
  begin
    Result := 5; // Falha por falta de ouro
    Exit;
  end;
  var
    ClassInfo: Integer;
  var
    EquipSlot: BYTE;

  ClassInfo := Self.GetClass(ItemList[item].Classe);
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);

  Writeln('Tipo de item ' + ItemList[HiraKaize.Index].ItemType.ToString);
  Writeln('Tipo de item ' + EquipSlot.ToString);

  if (ItemList[HiraKaize.Index].ItemType = 61) and (EquipSlot = 6) and
    (Player.Character.Base.Inventory[item].Index <> 0) then
  begin
    // Log para o arquivo logs/refines_cheat.txt
    var
      LogPath: string := 'logs/cheats/refines_cheat.txt';
    var
      LogFile: TextFile;

    AssignFile(LogFile, LogPath);
    try
      if FileExists(LogPath) then
        Append(LogFile)
      else
        Rewrite(LogFile);
      Writeln(LogFile,
        format('Horário: [%s] - O Jogador: %s tentou refinar um(a): %s [ARMA] usando [KAIZE] e foi removido',
        [DateTimeToStr(Now), Player.Character.Base.Name,
        ItemList[ItemIndex].Name]));
      CloseFile(LogFile);
    except
      on E: Exception do
        Player.SendClientMessage('Erro ao gravar no log de refines.');
    end;

    Player.SendClientMessage('Proíbido uso de Kaize no refine de Armas');
    // Mensagem para o jogador
    ZeroMemory(@Player.Character.Base.Inventory[item], sizeof(TItem));
    Player.Base.SendRefreshItemSlot(INV_TYPE, item,
      Player.Character.Base.Inventory[item], False);

    Self.DecreaseAmount(HiraKaize);

    if (Extract > 0) and (Player.Character.Base.Inventory[Item3].Refi > 0) then
      Self.DecreaseAmount(Player, Item3);

    Result := 9;
    Exit;
  end;

  if (ItemList[HiraKaize.Index].ItemType = 60) and (EquipSlot <> 6) and
    (Player.Character.Base.Inventory[item].Index <> 0) then
  begin
    // Log para o arquivo logs/refines_cheat.txt
    var
      LogPath: string := 'logs/cheats/refines_cheat.txt';
    var
      LogFile: TextFile;

    AssignFile(LogFile, LogPath);
    try
      if FileExists(LogPath) then
        Append(LogFile)
      else
        Rewrite(LogFile);
      Writeln(LogFile,
        format('Horário: [%s] - O Jogador: %s tentou refinar um(a): %s [ARMADURA] usando [HIRA] e foi removido',
        [DateTimeToStr(Now), Player.Character.Base.Name,
        ItemList[ItemIndex].Name]));
      CloseFile(LogFile);
    except
      on E: Exception do
        Player.SendClientMessage('Erro ao gravar no log de refines.');
    end;

    Player.SendClientMessage('Proíbido uso de Hira no refine de Armaduras');
    // Adicione seu código aqui, se necessário
    ZeroMemory(@Player.Character.Base.Inventory[item], sizeof(TItem));
    Player.Base.SendRefreshItemSlot(INV_TYPE, item,
      Player.Character.Base.Inventory[item], False);

    Self.DecreaseAmount(HiraKaize);
    // ZeroMemory(@Player.Character.Base.Inventory[Item2], sizeof(TItem));
    // Player.Base.SendRefreshItemSlot(INV_TYPE, item, Player.Character.Base.Inventory[Item2], False);

    if (Extract > 0) and (Player.Character.Base.Inventory[Item3].Refi > 0) then
      Self.DecreaseAmount(Player, Item3);

    //
    // if Item3 <> 0 then
    // begin
    // ZeroMemory(@Player.Character.Base.Inventory[Item3], sizeof(TItem));
    // Player.Base.SendRefreshItemSlot(INV_TYPE, item, Player.Character.Base.Inventory[Item3], False);
    // end;
    Result := 9;
    Exit;
  end;

  if (EquipSlot = 6) and not(Extract = 0) and ((Extract = 64) or (Extract = 66))
    and (Player.Character.Base.Inventory[item].Index <> 0) then // armas
  begin
    Player.SendClientMessage('Rico/Extrato inválido pra refinar armas');
    // Adicione seu código aqui, se necessário
    // Log para o arquivo logs/refines_cheat.txt
    var
      LogPath: string := 'logs/cheats/refines_cheat.txt';
    var
      LogFile: TextFile;

    AssignFile(LogFile, LogPath);
    try
      if FileExists(LogPath) then
        Append(LogFile)
      else
        Rewrite(LogFile);
      Writeln(LogFile,
        format('Horário: [%s] - O Jogador: %s tentou refinar um(a): %s [ARMA] usando [KAIZE] e foi removido',
        [DateTimeToStr(Now), Player.Character.Base.Name,
        ItemList[ItemIndex].Name]));
      CloseFile(LogFile);
    except
      on E: Exception do
        Player.SendClientMessage('Erro ao gravar no log de refines.');
    end;
    Result := 9;
    Exit;
  end;
  if (EquipSlot <> 6) and not(Extract = 0) and ((Extract = 63) or (Extract = 65)
    ) and (Player.Character.Base.Inventory[item].Index <> 0) then // armaduras
  begin
    // Log para o arquivo logs/refines_cheat.txt
    var
      LogPath: string := 'logs/cheats/refines_cheat.txt';
    var
      LogFile: TextFile;

    AssignFile(LogFile, LogPath);
    try
      if FileExists(LogPath) then
        Append(LogFile)
      else
        Rewrite(LogFile);
      Writeln(LogFile,
        format('Horário: [%s] - O Jogador: %s tentou refinar um(a): %s [ARMADURA] usando [HIRA] e foi removido',
        [DateTimeToStr(Now), Player.Character.Base.Name,
        ItemList[ItemIndex].Name]));
      CloseFile(LogFile);
    except
      on E: Exception do
        Player.SendClientMessage('Erro ao gravar no log de refines.');
    end;
    Player.SendClientMessage('Rico/Extrato inválido pra refinar armaduras');
    // Adicione seu código aqui, se necessário
    Result := 9;
    Exit;
  end;

  if (Player.Character.Base.Inventory[item].Index = 0) then
  begin
    Player.Base.SendRefreshItemSlot(INV_TYPE, item,
      Player.Character.Base.Inventory[item], True);
    Player.SendClientMessage('Erro, item inexistente');
    Exit;
  end;

  if (Player.Character.Base.Inventory[item].Refi >= 192) and
    not(Player.Character.Base.Inventory[item].Refi = 0) and
    not(Player.Character.Base.Inventory[item].Index = 0) then
  begin
    Result := 6; // Limite de refinamento atingido
    Player.SendClientMessage('Limite de refine atingido!');
    Exit;
  end;
{$ENDREGION}
  if not ItemList[ItemIndex].Fortification then
  begin
    if (HiraKaize.Refi <= 0) then
      Exit;

    if (Extract > 0) and (Player.Character.Base.Inventory[Item3].Refi > 0) then
      Self.DecreaseAmount(Player, Item3)
    else if (Extract > 0) then
      Exit;

    // Consome o item necessário para refinar
    Self.DecreaseAmount(HiraKaize);
    Dec(Player.Base.Character.Gold, Self.GetReinforceCust(ItemIndex));

    // Calcula o nível de refino
    Refine := Trunc(Player.Character.Base.Inventory[item].Refi / $10);

    // Obtém o resultado usando a nova função `GetResultRefineItem`
    Result := Self.GetResultRefineItem(ItemIndex, Extract, Refine);

    // // Obtém as probabilidades calculadas
    // Self.GetChances(Sucesso, Reduz, Quebra, Falha);

    // Envia as probabilidades para o jogador
    // Envia as probabilidades para o jogador
    // Player.SendClientMessage(Format(
    // 'Chances: Sucesso: %d%%, Redução: %d%%, Quebra: %d%%, Falha: %d%%',
    // [Sucesso, Reduz, Quebra, Falha]
    // ));

    case Result of
      0: // Quebra
        begin
          var
            LogPath: string := 'logs/refine/quebra.txt';
          var
            LogFile: TextFile;

          AssignFile(LogFile, LogPath);
          try
            if FileExists(LogPath) then
              Append(LogFile)
            else
              Rewrite(LogFile);

            case ItemList[Extract].ItemType of
              64, 66:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s quebrou um(a) %s + %d com Extrato Enriquecido',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine]));
              63, 65:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s quebrou um(a) %s + %d com Extrato Normal',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine]));
              0:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s quebrou um(a) %s + %d na sorte, sem rico/extrato',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine]));
            end;

            CloseFile(LogFile);
          except
            on E: Exception do
              Player.SendClientMessage('Erro ao gravar no log de refines.');
          end;

          Player.SendClientMessage('O Item foi quebrado!');
          ZeroMemory(@Player.Character.Base.Inventory[item], sizeof(TItem));
        end;

      1: // Redução
        begin
          var
            LogPath: string := 'logs/refine/reducao.txt';
          var
            LogFile: TextFile;

          AssignFile(LogFile, LogPath);
          try
            if FileExists(LogPath) then
              Append(LogFile)
            else
              Rewrite(LogFile);

            case ItemList[Extract].ItemType of
              64, 66:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s voltou um(a) %s pra + %d foi perdido 1 refine usando Extrato Enriquecido',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine - 1]));
              63, 65:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s voltou um(a) %s pra + %d foi perdido 1 refine usando Extrato Normal',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine - 1]));
            end;

            CloseFile(LogFile);
          except
            on E: Exception do
              Player.SendClientMessage('Erro ao gravar no log de refines.');
          end;

          Player.SendClientMessage('O Item voltou 1 refine!');
          Dec(Player.Character.Base.Inventory[item].Refi, $10);
        end;

      2: // Sucesso
        begin
          Inc(Player.Character.Base.Inventory[item].Refi, $10);
          var
            LogPath: string := 'logs/refine/sucesso.txt';
          var
            LogFile: TextFile;

          AssignFile(LogFile, LogPath);
          try
            if FileExists(LogPath) then
              Append(LogFile)
            else
              Rewrite(LogFile);

            case ItemList[Extract].ItemType of
              64, 66:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s refinou um(a) %s pra + %d e teve o refine aumentado com Extrato Enriquecido',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine + 1]));
              63, 65:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s refinou um(a) %s pra + %d e teve o refine aumentado com Extrato Normal',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine + 1]));
              0:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s refinou um(a) %s pra + %d e teve o refine aumentado na sorte, sem Extrato',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine + 1]));
            end;

            CloseFile(LogFile);
          except
            on E: Exception do
              Player.SendClientMessage('Erro ao gravar no log de refines.');
          end;
        end;

      3: // Falha sem destruição
        begin
          var
            LogPath: string := 'logs/refine/falha.txt';
          var
            LogFile: TextFile;

          AssignFile(LogFile, LogPath);
          try
            if FileExists(LogPath) then
              Append(LogFile)
            else
              Rewrite(LogFile);

            case ItemList[Extract].ItemType of
              64, 66:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s falhou um(a) %s pra + %d e manteve o refine usando Extrato Enriquecido',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine]));
              63, 65:
                Writeln(LogFile,
                  format('Horário: [%s] - O Jogador: %s falhou um(a) %s pra + %d e manteve o refine usando Extrato Normal',
                  [DateTimeToStr(Now), Player.Character.Base.Name,
                  ItemList[ItemIndex].Name, Refine]));
            end;

            CloseFile(LogFile);
          except
            on E: Exception do
              Player.SendClientMessage('Erro ao gravar no log de refines.');
          end;

          Player.SendClientMessage('O refine falhou e manteve o valor atual!');
        end;

      9: // Falha sem destruição
        begin
          TNPCHandlers.ShowReinforce(Player);
          // comentar caso nao queira q resete a tela
          Exit;
        end;

    end;
    Writeln('Resultado geral:' + Result.ToString);
  end
  else
  begin
    Player.SendClientMessage('Esse item não pode ser refinado.');
    Exit;
  end;

  if (Result = 0) then
    TNPCHandlers.ShowReinforce(Player);

  if (Player.Character.Base.Inventory[item].Index = 0) then
  begin

    Player.Base.SendRefreshItemSlot(INV_TYPE, item,
      Player.Character.Base.Inventory[item], False);
    Servers[Player.ChannelIndex].SendServerMsg
      (AnsiString(Player.Character.Base.Name + ' acabou de quebrar um ' +
      ItemList[ItemIndex].Name + ' +' + Refine.ToString), 16, 0, 0, False,
      Player.Base.ClientID);
  end
  else
  begin
    Refine := Round(Player.Character.Base.Inventory[item].Refi / 16);
    if (Result = 2) and (Refine >= 1) then
    begin

      Player.SendClientMessage('Item refinado com sucesso!');
      Servers[Player.ChannelIndex].SendServerMsg
        (AnsiString(Player.Character.Base.Name + ' refinou com sucesso ' +
        ItemList[ItemIndex].Name + ' +' + Refine.ToString), 16, 0, 0, False,
        Player.Base.ClientID);
    end;
  end;
end;

{$ENDREGION}

class function TItemFunctions.GetArmorReinforceIndex(const item: WORD): WORD;
  function GetRefineClass(Classe: BYTE): BYTE;
  begin
    Result := 6;
    case Classe of
      01 .. 10:
        Result := 1;
      11 .. 20:
        Result := 0;
      21 .. 30:
        Result := 2;
      31 .. 40:
        Result := 3;
      41 .. 50:
        Result := 4;
      51 .. 60:
        Result := 5;
    end;
  end;

var
  ItemType: WORD;
begin
  Result := 0;
  if not(ItemList[item].ItemType in [2 .. 7]) then
    Exit;

  ItemType := ItemList[item].ItemType;
  if ItemType = 7 then
    ItemType := 6;

  Result := ((ItemType - 2) * 30) + ItemList[item].UseEffect;
end;

class function TItemFunctions.GetReinforceCust(const Index: WORD): Cardinal;
begin
  case Self.GetItemEquipSlot(Index) of
    2 .. 5:
      Result := ReinforceA01[ItemList[Index].UseEffect - 1].ReinforceCust;
    6:
      Result := ReinforceW01[ItemList[Index].UseEffect - 1].ReinforceCust;
    7:
      Result := ReinforceA01[ItemList[Index].UseEffect - 1].ReinforceCust;
  else
    Result := 0;
  end;
end;

class function TItemFunctions.GetItemReinforce2Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  ClassInfo: BYTE;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;

  case ItemUseEffect of
    0 .. 35:
      ReinforceIndex := reinforce2sectionSize * 0;
    36 .. 70:
      begin
        ReinforceIndex := reinforce2sectionSize * 1;
        Dec(ReinforceIndex, 35);
      end;
    71 .. 105:
      begin
        ReinforceIndex := reinforce2sectionSize * 2;
        Dec(ReinforceIndex, 70);
      end;
  end;

  ClassInfo := Self.GetClass(ItemList[ItemIndex].Classe);
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);

  if EquipSlot = 6 then
  begin
    case ClassInfo of
      0:
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Sword));
      1:
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Blade));
      2:
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Rifle));
      3:
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Pistol));
      4:
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Staff));
      5:
        Inc(ReinforceIndex, WORD(Reinforce2_Area_Wand));
    end;
    Result := ReinforceIndex + ItemUseEffect;
    Exit;
  end;

  case EquipSlot of
    2:
      Inc(ReinforceIndex, WORD(Reinforce2_Area_Helmet) + (ClassInfo * 30));
    3:
      Inc(ReinforceIndex, WORD(Reinforce2_Area_Armor) + (ClassInfo * 30));
    4:
      Inc(ReinforceIndex, WORD(Reinforce2_Area_Gloves) + (ClassInfo * 30));
    5:
      Inc(ReinforceIndex, WORD(Reinforce2_Area_Shoes) + (ClassInfo * 30));
    7:
      Inc(ReinforceIndex, WORD(Reinforce2_Area_Shield));
  end;

  Result := ReinforceIndex + ItemUseEffect;
end;

class function TItemFunctions.GetItemReinforce3Index(ItemIndex: WORD): WORD;
var
  ReinforceIndex: WORD;
  ItemUseEffect: WORD;
  EquipSlot: BYTE;
begin
  ReinforceIndex := 0;
  ItemUseEffect := ItemList[ItemIndex].UseEffect;

  // Calculando ReinforceIndex com base no ItemUseEffect
  if ItemUseEffect <= 35 then
    ReinforceIndex := reinforce3sectionSize * 0
  else if ItemUseEffect <= 70 then
    ReinforceIndex := reinforce3sectionSize * 1 - 35
  else if ItemUseEffect <= 105 then
    ReinforceIndex := reinforce3sectionSize * 2 - 70;

  // Ajustando ReinforceIndex conforme EquipSlot
  EquipSlot := Self.GetItemEquipSlot(ItemIndex);
  case EquipSlot of
    2:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Helmet));
    3:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Armor));
    4:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Gloves));
    5:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shoes));
    7:
      Inc(ReinforceIndex, WORD(Reinforce3_Area_Shield));
  end;

  Result := ReinforceIndex + ItemUseEffect;
end;

{$ENDREGION}
{$REGION 'Enchant'}

class function TItemFunctions.Enchantable(item: TItem): Boolean;
var
  i: BYTE;
begin
  Result := False;
  for i := 0 to 2 do
    if (item.Effects.Index[i] = 0) then
    begin
      Result := True;
      Break;
    end;
end;

class function TItemFunctions.GetEmptyEnchant(item: TItem): BYTE;
var
  i: BYTE;
begin
  Result := 255;
  for i := 0 to 2 do
    if (item.Effects.Index[i] = 0) then
    begin
      Result := i;
      Break;
    end;
end;

class function TItemFunctions.EnchantItem(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
var
  EmptyEnchant, EnchantIndex, EnchantValue, R1, RandomEnch, OldRandomEnch,
    ItemSlotType, i: Integer;
begin
  Result := 0;
  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) or
    (Player.Base.Character.Inventory[Item2].Index = 0) then
    Exit;

  if Self.Enchantable(Player.Base.Character.Inventory[ItemSlot]) then
  begin
    if (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType = 508)
    then
    begin
      if (ItemList[Player.Base.Character.Inventory[Item2].Index].EF[0] = 0) then
      begin
        ItemSlotType := Self.GetItemEquipSlot(Player.Base.Character.Inventory
          [ItemSlot].Index);
        Randomize;
        RandomEnch := 0;

        case ItemSlotType of
          2 .. 5, 7:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  RandomEnch := VaizanP_Set
                    [RandomRange(0, Length(VaizanP_Set))];
                5321:
                  RandomEnch := VaizanM_Set
                    [RandomRange(0, Length(VaizanM_Set))];
                5322:
                  RandomEnch := VaizanG_Set
                    [RandomRange(0, Length(VaizanG_Set))];
              end;
            end;
          6:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  RandomEnch := VaizanP_Wep
                    [RandomRange(0, Length(VaizanP_Wep))];
                5321:
                  RandomEnch := VaizanM_Wep
                    [RandomRange(0, Length(VaizanM_Wep))];
                5322:
                  RandomEnch := VaizanG_Wep
                    [RandomRange(0, Length(VaizanG_Wep))];
              end;
            end;
          11 .. 14:
            begin
              case Player.Base.Character.Inventory[Item2].Index of
                5320:
                  RandomEnch := VaizanP_Acc
                    [RandomRange(0, Length(VaizanP_Acc))];
                5321:
                  RandomEnch := VaizanM_Acc
                    [RandomRange(0, Length(VaizanM_Acc))];
                5322:
                  RandomEnch := VaizanG_Acc
                    [RandomRange(0, Length(VaizanG_Acc))];
              end;
            end;
        end;

        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;

        for i := 0 to 2 do
        begin
          if (Player.Character.Base.Inventory[ItemSlot].Effects.
            Index[i] = ItemList[RandomEnch].EF[0]) then
          begin
            OldRandomEnch := RandomEnch;

            case ItemSlotType of
              2 .. 5, 7:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      RandomEnch := VaizanP_Set
                        [RandomRange(0, Length(VaizanP_Set))];
                    5321:
                      RandomEnch := VaizanM_Set
                        [RandomRange(0, Length(VaizanM_Set))];
                    5322:
                      RandomEnch := VaizanG_Set
                        [RandomRange(0, Length(VaizanG_Set))];
                  end;
                end;
              6:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      RandomEnch := VaizanP_Wep
                        [RandomRange(0, Length(VaizanP_Wep))];
                    5321:
                      RandomEnch := VaizanM_Wep
                        [RandomRange(0, Length(VaizanM_Wep))];
                    5322:
                      RandomEnch := VaizanG_Wep
                        [RandomRange(0, Length(VaizanG_Wep))];
                  end;
                end;
              11 .. 14:
                begin
                  case Player.Base.Character.Inventory[Item2].Index of
                    5320:
                      RandomEnch := VaizanP_Acc
                        [RandomRange(0, Length(VaizanP_Acc))];
                    5321:
                      RandomEnch := VaizanM_Acc
                        [RandomRange(0, Length(VaizanM_Acc))];
                    5322:
                      RandomEnch := VaizanG_Acc
                        [RandomRange(0, Length(VaizanG_Acc))];
                  end;
                end;
            end;

            // Ajuste para evitar duplicação de encantamentos
            if (RandomEnch = OldRandomEnch) then
              RandomEnch := IfThen(R1 > 0, VaizanP_Set[R1 - 1],
                VaizanP_Set[R1 + 1]);

            // Enchanting item
            EnchantIndex := ItemList[RandomEnch].EF[0];
            EnchantValue := ItemList[RandomEnch].EFV[0];
            Player.Character.Base.Inventory[ItemSlot].Effects.
              Index[EmptyEnchant] := EnchantIndex;
            Player.Character.Base.Inventory[ItemSlot].Effects.Value
              [EmptyEnchant] := EnchantValue;
            Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
            Exit;
          end;
        end;
      end
      else
      begin
        EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
          [ItemSlot]);
        if (EmptyEnchant = 255) then
        begin
          Result := 1; // SendPlayerError
          Exit;
        end;

        for i := 0 to 2 do
        begin
          if (Player.Character.Base.Inventory[ItemSlot].Effects.
            Index[i] = ItemList[Player.Base.Character.Inventory[Item2].Index]
            .EF[0]) then
          begin
            if not(ItemList[Player.Base.Character.Inventory[Item2].Index]
              .ItemType = 33) then
            begin
              Result := 3; // SendPlayerMessage
              Exit;
            end;
          end;
        end;

        // Ajuste para evitar duplicação de encantamentos
        if (RandomEnch = OldRandomEnch) then
          RandomEnch := IfThen(R1 > 0, VaizanP_Set[R1 - 1],
            VaizanP_Set[R1 + 1]);

        EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EF[0];
        EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
          Index].EFV[0];
        Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
          EnchantIndex;
        Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
          EnchantValue;
        Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
      end;

      Result := 2;
      Exit;
    end;

    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);
    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;

    for i := 0 to 2 do
    begin
      if (Player.Character.Base.Inventory[ItemSlot].Effects.
        Index[i] = ItemList[Player.Base.Character.Inventory[Item2].Index].EF[0])
      then
      begin
        if not(ItemList[Player.Base.Character.Inventory[Item2].Index]
          .ItemType = 33) then
        begin
          Result := 3; // SendPlayerMessage
          Exit;
        end;
      end;
    end;

    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];
    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;
    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end;

  Result := 2;
end;

{$ENDREGION}
{$REGION 'Change APP'}

class function TItemFunctions.Changeable(item: TItem): Boolean;
begin
  Result := (item.APP = 0) or (item.Index = item.APP);
end;

class function TItemFunctions.ChangeApp(var Player: TPlayer;
  item, Athlon, NewApp: DWORD): BYTE;
var
  MItem, MAthlon, MNewApp: TItem;
begin
  Result := 0;
  MItem := Player.Character.Base.Inventory[item];
  MAthlon := Player.Character.Base.Inventory[Athlon];
  MNewApp := Player.Character.Base.Inventory[NewApp];

  if (MItem.Index = 0) or (MAthlon.Index = 0) or (MNewApp.Index = 0) then
    Exit;

  if not(Player.Base.GetMobClass(ItemList[MNewApp.Index].Classe)
    = Player.Base.GetMobClass(ItemList[MItem.Index].Classe)) then
  begin
    Result := 1;
    Exit;
  end;

  if ItemList[MItem.Index].CanAgroup or ItemList[MNewApp.Index].CanAgroup then
  begin
    Result := 1;
    Exit;
  end;

  if Self.Changeable(MItem) then
  begin
    Player.Character.Base.Inventory[item].APP := MNewApp.Index;
    ZeroMemory(@Player.Character.Base.Inventory[NewApp], sizeof(TItem));
    Self.DecreaseAmount(@Player.Character.Base.Inventory
      [Self.GetItemSlot2(Player, MAthlon.Index)]);
    Player.Base.SendRefreshItemSlot(Self.GetItemSlot2(Player,
      MAthlon.Index), False);
    Result := 2;
  end;
end;

{$ENDREGION}
{$REGION 'Enchant Mount'}

class function TItemFunctions.EnchantMount(var Player: TPlayer;
  ItemSlot, Item2: DWORD): BYTE;
type
  TSpecialRefi = record
    hi, lo: BYTE;
  end;
var
  EmptyEnchant: BYTE;
  EnchantIndex, EnchantValue: WORD;
begin
  Result := 0;

  if (Player.Base.Character.Inventory[ItemSlot].Index = 0) or
    (Player.Base.Character.Inventory[Item2].Index = 0) or
    (ItemList[Player.Base.Character.Inventory[Item2].Index].ItemType <> 518)
  then
    Exit;

  if (Self.Enchantable(Player.Base.Character.Inventory[ItemSlot])) then
  begin
    EmptyEnchant := Self.GetEmptyEnchant(Player.Base.Character.Inventory
      [ItemSlot]);

    if (EmptyEnchant = 255) then
    begin
      Result := 1; // SendPlayerError
      Exit;
    end;

    EnchantIndex := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EF[0];
    EnchantValue := ItemList[Player.Base.Character.Inventory[Item2].
      Index].EFV[0];

    Player.Character.Base.Inventory[ItemSlot].Effects.Index[EmptyEnchant] :=
      EnchantIndex;
    Player.Character.Base.Inventory[ItemSlot].Effects.Value[EmptyEnchant] :=
      EnchantValue;

    Self.DecreaseAmount(@Player.Character.Base.Inventory[Item2]);
  end
  else
  begin
    Result := 1;
  end;

  Result := 2;
end;
{$ENDREGION}
{$REGION 'Premium Inventory Function'}

class function TItemFunctions.FindPremiumIndex(Index: WORD): WORD;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to Length(PremiumItems) - 1 do
  begin
    if (PremiumItems[i].Index = Index) then
    begin
      Result := i;
      Break;
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Use Item'}

class function TItemFunctions.UsePremiumItem(var Player: TPlayer;
  Slot: Integer): Boolean;
var
  item: TItem;
  Premium: PItemCash;
begin
  if (Self.GetInvAvailableSlots(Player) = 0) then
  begin
    Player.SendClientMessage('Inventário cheio.');
    Exit;
  end;

  Premium := @Player.Account.Header.CashInventory.Items[Slot];
  ZeroMemory(@item, sizeof(TItem));

  item.Index := PremiumItems[Premium.Index].ItemIndex;
  Self.SetItemAmount(item, PremiumItems[Premium.Index].Amount);

  if (ItemList[item.Index].Expires) then
    Self.SetItemAmount(item, 0);

  Self.PutItem(Player, item, 0, True);
  ZeroMemory(@item, sizeof(TItem));
  ZeroMemory(Premium, sizeof(TItemCash));

  Player.Base.SendRefreshItemSlot(CASH_TYPE, Slot, item, False);

  Result := (Premium.Index = 0);
end;
{$ENDREGION}

class function TItemFunctions.SpawnNpc(Player: TPlayer; Local: TPosition;
  ID: Integer; AttackerID: Integer; IsBoss: Boolean): Boolean;
var
  Packet: TSendSpawnMob;
  spawned: Boolean;
  i, helper, Channel_ID, CityID: Integer;
  mensagem1, mensagem2, mensagem3, NationName: string;
begin
  Result := False;
  Packet.MobID := ID;

  if Player.Base.PlayerCharacter.CurrentPos.IsValid then
  begin
    for i := 1 to 25 do
    begin
      if (Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.ClientID <> 0) then
        Continue;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Index :=
        ((Packet.MobID + i) + 9148);

      // Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].Name := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].Name;
      Writeln('client id ' + Servers[Player.ChannelIndex].MOBS.TMobS
        [Packet.MobID].MobsP[i].Index.ToString);
      Randomize;
      Helper := RandomRange(1, 8);
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.X
        := Player.Base.Neighbors[Helper].pos.X;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.Y
        := Player.Base.Neighbors[Helper].pos.Y;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.X
        := Player.Base.Neighbors[Helper].pos.X;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.Y
        := Player.Base.Neighbors[Helper].pos.Y;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.Create(nil, ((Packet.MobID + i) + 9148), Player.ChannelIndex);

      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.MobID
        := Packet.MobID;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.IsActive := True;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.ClientID := (Packet.MobID + i) + 9148;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.SecondIndex := i;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MovedTo :=
        TypeMobLocation.Init;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .LastMyAttack := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .LastSkillAttack := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].CurrentPos
        := Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP
        [i].InitPos;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.LastPos := Servers[Player.ChannelIndex].MOBS.TMobS
        [Packet.MobID].MobsP[i].CurrentPos;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .XPositionsToMove := 1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .YPositionsToMove := 1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .NeighborIndex := -1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].HP :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MP :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DNFis :=
        i + RandomRange(200, 299);
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DNMag :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DNFis;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DefFis :=
        i + RandomRange(200, 299);
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DefMag :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DefFis;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.Esquiva := MOB_ESQUIVA;
      // estava 0
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.Nation := Player.Base.Character.Nation;
      // Self.ChannelId + 1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .isGuard := True;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .LastMyAttack := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .isTemp := True;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .GeneratedAt := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID]
        .IsActiveToSpawn := True;
      spawned := True;

      CityID := Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
        .GetCurrentCityID;
      Channel_ID := Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
        .ChannelIndex;

      if (CityID >= Low(MapNames)) and (CityID <= High(MapNames)) then
      begin
        var
        CityName := MapNames[CityID];

        if (Channel_ID >= Low(Nacoes)) and (Channel_ID <= High(Nacoes)) then
        begin
          NationName := Nacoes[Channel_ID];

          // Verifica se o nome do mapa não está vazio
          if (CityName <> '') then
            mensagem3 := '[Mapa]: ' + CityName + ' [Nação]: ' + NationName;
        end;
      end
      else
        mensagem3 := '';

      mensagem1 := 'Jogador ' + AnsiString(Player.Base.Character.Name) +
        ' acabou de spawnar:';
      mensagem2 := '<' + Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID]
        .Name + '>';

      Servers[Player.ChannelIndex].SendServerMsg(mensagem1, 16, 32, 16);
      Servers[Player.ChannelIndex].SendServerMsg(mensagem2, 16, 32, 16);
      Servers[Player.ChannelIndex].SendServerMsg(mensagem3, 16, 32, 16);

      Result := True;
      Break;

    end;

  end;

  if (spawned = False) then
  begin
    Result := False;
  end;

end;

class function TItemFunctions.SpawnMob(Player: TPlayer; Local: TPosition;
  ID: Integer; AttackerID: Integer; IsBoss: Boolean): Boolean;
var
  Packet: TSendSpawnMob;
  spawned: Boolean;
  i, helper, Channel_ID, CityID: Integer;
  mensagem1, mensagem2, mensagem3, NationName: string;
begin
  Result := False;
  Packet.MobID := ID;

  if Player.Base.PlayerCharacter.CurrentPos.IsValid then
  begin
    for i := 1 to 25 do
    begin
      if (Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.ClientID <> 0) then
        Continue;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Index :=
        ((Packet.MobID + i) + 9148);

      // Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].Name := Servers[player.ChannelIndex].MOBS.TMobS[Packet.MobID].Name;
      Writeln('client id ' + Servers[Player.ChannelIndex].MOBS.TMobS
        [Packet.MobID].MobsP[i].Index.ToString);
      Randomize;
      Helper := RandomRange(1, 8);
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.X
        := Player.Base.Neighbors[Helper].pos.X;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].InitPos.Y
        := Player.Base.Neighbors[Helper].pos.Y;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.X
        := Player.Base.Neighbors[Helper].pos.X;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].DestPos.Y
        := Player.Base.Neighbors[Helper].pos.Y;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.Create(nil, ((Packet.MobID + i) + 9148), Player.ChannelIndex);

      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].Base.MobID
        := Packet.MobID;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.IsActive := True;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.ClientID := (Packet.MobID + i) + 9148;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.SecondIndex := i;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MovedTo :=
        TypeMobLocation.Init;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .LastMyAttack := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .LastSkillAttack := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].CurrentPos
        := Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP
        [i].InitPos;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.LastPos := Servers[Player.ChannelIndex].MOBS.TMobS
        [Packet.MobID].MobsP[i].CurrentPos;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .XPositionsToMove := 1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .YPositionsToMove := 1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .NeighborIndex := -1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].HP :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i].MP :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].InitHP;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DNFis :=
        i + RandomRange(200, 299);
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DNMag :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DNFis;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DefFis :=
        i + RandomRange(200, 299);
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DefMag :=
        Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.DefFis;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.CurrentScore.Esquiva := MOB_ESQUIVA;
      // estava 0
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.CritRes := MOB_CRIT_RES;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.DuploRes := MOB_DUPLO_RES;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .Base.PlayerCharacter.Base.Nation := Player.Base.Character.Nation;
      // Self.ChannelId + 1;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .LastMyAttack := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .isTemp := True;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID].MobsP[i]
        .GeneratedAt := Now;
      Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID]
        .IsActiveToSpawn := True;
      spawned := True;

      CityID := Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
        .GetCurrentCityID;
      Channel_ID := Servers[Player.ChannelIndex].Players[Player.Base.ClientID]
        .ChannelIndex;

      if (CityID >= Low(MapNames)) and (CityID <= High(MapNames)) then
      begin
        var
        CityName := MapNames[CityID];

        if (Channel_ID >= Low(Nacoes)) and (Channel_ID <= High(Nacoes)) then
        begin
          NationName := Nacoes[Channel_ID];

          // Verifica se o nome do mapa não está vazio
          if (CityName <> '') then
            mensagem3 := '[Mapa]: ' + CityName + ' [Nação]: ' + NationName;
        end;
      end
      else
        mensagem3 := '';

      mensagem1 := 'Jogador ' + AnsiString(Player.Base.Character.Name) +
        ' acabou de spawnar:';
      mensagem2 := '<' + Servers[Player.ChannelIndex].MOBS.TMobS[Packet.MobID]
        .Name + '>';

      Servers[Player.ChannelIndex].SendServerMsg(mensagem1, 16, 32, 16);
      Servers[Player.ChannelIndex].SendServerMsg(mensagem2, 16, 32, 16);
      Servers[Player.ChannelIndex].SendServerMsg(mensagem3, 16, 32, 16);

      Result := True;
      Break;

    end;

  end;

  if (spawned = False) then
  begin
    Result := False;
  end;

end;

class procedure TItemFunctions.AddAuxilyTime(var Player: TPlayer; Dias: byte);
var
  NationName: AnsiString;
  l: byte;
  PlayerSQLComp: TQuery;
  AddPremiumTime, CurrentPremiumTime, NewPremiumTime: TDateTime;
begin

          case Player.Base.Character.Nation of

                    0:
                    begin
                     NationName := 'Sem nação';
                    end;

                    1:
                    begin
                     NationName := 'Tibérica';
                    end;

                    2:
                    begin
                     NationName := 'Odeon';
                    end;

                    3:
                    begin
                     NationName := 'Elsinore';
                    end;

          end;

          PlayerSQLComp := Self.CreateSQL;

          try
            if not(PlayerSQLComp.Query.Connection.Connected) then
            begin
              Logger.Write('Falha de conexão com o banco de dados.[ItemFunctions]', TlogType.Warnings);
              Logger.Write('MYSQL CONNECTION FAILED.[ItemFunctions]', TlogType.Error);
              PlayerSQLComp.Free;
              Exit;
            end;

            // Calcula os 15 dias para adicionar
            AddPremiumTime:= IncDay(Now, Dias);

              // Verifica se o jogador já possui um premium_time
            PlayerSQLComp.SetQuery('SELECT premium_time FROM premium_account WHERE username = "' + Player.Account.Header.Username + '"');
            PlayerSQLComp.Run;

            // Se o jogador não existe, insira um novo premium_time
            if PlayerSQLComp.Query.IsEmpty then
            begin
              // Se não existe, insere o premium_time inicial
              PlayerSQLComp.SetQuery
                ('INSERT INTO premium_account (username, premium_time) ' +
                'VALUES ("' + Player.Account.Header.Username + '", "' +
                FormatDateTime('yyyy-mm-dd hh:nn:ss', AddPremiumTime) + '")');
              PlayerSQLComp.Query.ExecSQL;

              if PlayerSQLComp.Query.RowsAffected = 0 then
              begin
                Logger.Write('Erro ao inserir o premium_time para o jogador: ' +
                  Player.Account.Header.Username, TlogType.Error);
                PlayerSQLComp.Free;
                Exit;
              end;
            end
            else
            begin
              // Se já existe, pega o premium_time atual e adiciona os 15 dias
              CurrentPremiumTime:= PlayerSQLComp.Query.FieldByName
                  ('premium_time').AsDateTime;

                // Se o premium_time atual for no passado, definimos o próximo prazo como 15 dias a partir de agora
              if CurrentPremiumTime < Now then
                NewPremiumTime := AddPremiumTime
              else
                NewPremiumTime := IncDay(CurrentPremiumTime, Dias);
              // Incrementa 15 dias

              // Atualiza o premium_time no banco de dados
              PlayerSQLComp.SetQuery('UPDATE premium_account ' +
                'SET premium_time = "' + FormatDateTime('yyyy-mm-dd hh:nn:ss',
                NewPremiumTime) + '" ' + 'WHERE username = "' +
                Player.Account.Header.Username + '"');
              PlayerSQLComp.Query.ExecSQL;

              if PlayerSQLComp.Query.RowsAffected = 0 then
              begin
                Logger.Write('Erro ao atualizar o premium_time para o jogador: '
                  + Player.Account.Header.Username, TlogType.Error);
                PlayerSQLComp.Free;
                Exit;
              end;
              Logger.Write('premium_time atualizado para o jogador: ' +
                Player.Account.Header.Username, TlogType.Error);
            end;

          except
            on E: Exception do
            begin
              Logger.Write
                ('Erro ao atualizar o premium_time no banco de dados. Msg[' +
                E.Message + ']', TlogType.Error);
              PlayerSQLComp.Free;
              Exit;
            end;
          end;


end;
class function TItemFunctions.UseItem(var Player: TPlayer; Slot: byte; Type1: DWORD): Boolean;
var
  item, SecondItem: PItem;
  i: word;
  RandomTax, RecipeIndex, EmptySlot: WORD;
  CapaceteIndex, ArmaduraIndex, LuvasIndex, BotasIndex, ArmaIndex,EscudoIndex: word;
  Aparencia: AnsiString;
  valor, ItemSlot, ItemAmount: byte;
  Capacete, Armadura, Luvas, Botas, Arma, Escudo: PItem;
  l: byte; //sobre auxilio
  NationName: AnsiString; //anuncio do auxilio
  PlayerSQLComp: TQuery; //variavel de MYSQL
  AddPremiumTime, CurrentPremiumTime, NewPremiumTime: TDateTime; //variavel de tempo que será added
  TotalBasePoints: word;
  TotalBasePointsCalc: word;
  ItemExists, HaveAmount: Boolean;
  RandomAgain, RandomDuplication: Integer;
begin
  Result := False;
  
  item := @Player.Character.Base.Inventory[Slot];
  
  if Player.Character.Base.Level < ItemList[item.Index].Level then
    Exit;

  case ItemList[item.Index].ItemType of

    {$REGION 'Poção de HP/MP'}
        ITEM_TYPE_HP_POTION:
          begin
            Inc(Player.Character.Base.CurrentScore.CurHP,
              ItemList[item.Index].UseEffect);
            Player.Base.SendCurrentHPMPItem;
            
              Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
              
          end;

        ITEM_TYPE_HPMP_LAGRIMAS:
          begin
            Inc(Player.Character.Base.CurrentScore.CurHP,
              ItemList[item.Index].UseEffect);
            Inc(Player.Character.Base.CurrentScore.CurMP,
              ItemList[item.Index].UseEffect);
            Player.Base.SendCurrentHPMPItem;
                          Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
          end;
    {$ENDREGION}

    {$REGION 'Poção de HP'}
        ITEM_TYPE_HPMP_POTION:
          begin
            Inc(Player.Character.Base.CurrentScore.CurHP,
              ItemList[item.Index].UseEffect);
            Inc(Player.Character.Base.CurrentScore.CurMP,
              ItemList[item.Index].UseEffect);
            Player.Base.SendCurrentHPMPItem;
                          Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
          end;

    {$ENDREGION}

    {$REGION 'Poção de MP'}
        ITEM_TYPE_MP_POTION:
          begin
            Inc(Player.Character.Base.CurrentScore.CurMP,
              ItemList[item.Index].UseEffect);
            Player.Base.SendCurrentHPMPItem;
                          Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
          end;

    {$ENDREGION}
 
    {$REGION 'Pergaminho do portal'}
        208:
          begin
            
            if (SecondsBetween(Now, Player.Base.LastReceivedAttack) <= 10) then
            begin
              Player.SendClientMessage('Você não pode usar esse item em modo ataque!');
              Exit;
            end;

            if (Player.Base.InClastleVerus) then
            begin
              Player.SendClientMessage('Impossível usar em guerra. Use o teleporte.');
              Exit;
            end;

            try
            
              Player.CheckInventoryRelic(true);

              if (Player.Base.Character.Nation > 0) and
                ((Player.Base.Character.Nation <> Player.ChannelIndex + 1) or
                (Player.Waiting1 <> 0)) then
                Exit;

              if TPosition.Create(ScrollTeleportPosition[Type1].PosX, ScrollTeleportPosition[Type1].PosY).IsValid then
                Player.Teleport(TPosition.Create(ScrollTeleportPosition[Type1].PosX, ScrollTeleportPosition[Type1].PosY));

            except
              on E: Exception do
              begin
                Player.Teleport(Player.Base.PlayerCharacter.LastPos);
                Logger.Write('erro ao se teleportar. ' + E.Message, TlogType.Error);
                Exit;
              end;

            end;
          end;

    {$ENDREGION}

    {$REGION 'Pergaminho:Regenchain'}
        202:
          begin
          
            Player.CheckInventoryRelic(true);
            if (SecondsBetween(Now, Player.Base.LastReceivedAttack) <= 10) then
            begin
              Player.SendClientMessage
                ('Você não pode usar esse item em modo ataque!');
              Exit;
            end;

            if (Player.Base.InClastleVerus) then
            begin
              Player.SendClientMessage
                ('Impossível usar em guerra. Use o teleporte.');
              Exit;
            end;

            if (Player.Base.Character.Nation > 0) and (Player.Base.Character.Nation <> Servers[Player.ChannelIndex].NationID) then
            begin
                Player.SendClientMessage
                  ('Impossível usar este item no canal desejado.');
                Exit;
            end;
            Player.SendPlayerToCityPosition();
                          Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
            
          end;
    {$ENDREGION}

    {$REGION 'Pergaminho:CidadeSalva'}
        204:
          begin
            Player.CheckInventoryRelic(true);
            
            if (SecondsBetween(Now, Player.Base.LastReceivedAttack) <= 10) then
            begin
              Player.SendClientMessage
                ('Você não pode usar esse item em modo ataque!');
              Exit;
            end;

            if (Player.Base.InClastleVerus) then
            begin
              Player.SendClientMessage
                ('Impossível usar em guerra. Use o teleporte.');
              Exit;
            end;

            if (Player.Base.Character.Nation > 0) and (Player.Base.Character.Nation <> Servers[Player.ChannelIndex].NationID) then
            begin
                  Player.SendClientMessage
                    ('Impossível usar este item no canal desejado.');
                  Exit;
            end;
            
              Player.SendPlayerToSavedPosition();
              Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
          end;
    {$ENDREGION}
 
    {$region 'joquempo'}
        301: // joquempo
          begin

            Player.SendData(Player.Base.ClientID, $310, $21);
            Result := True;
            Exit;

          end;
    {$endregion}

    {$region 'marionete'}
        90: // marionete
          begin
            Player.F12TempoRestante := Player.F12TempoRestante + (ItemList[item.Index].UseEffect * 60);
            Player.AddAutoFarmTime(Player.Base.Character.Name, Player.F12TempoRestante);
            Player.SendClientMessage('Adicionados ' + ItemList[item.Index].UseEffect.ToString + ' minutos extras de auto-caça.');
              Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
          end;
    {$endregion}

    {$REGION 'Pergaminho dimensional'}
        206:  //perga dimensional
          begin
            Player.CheckInventoryRelic(true);
            
            if (SecondsBetween(Now, Player.Base.LastReceivedAttack) <= 10) then
            begin
              Player.SendClientMessage('Você não pode usar esse item em modo ataque!');
              Exit;
            end;

            if (Player.PartyIndex = 0) or (Servers[Player.ChannelIndex].Players[Type1].PartyIndex = 0) then
            begin
              Player.SendClientMessage('Necessário estar em um grupo para utilizar o pergaminho');
              Exit;
            end;

            if Servers[Player.ChannelIndex].Players[Type1].Party.Leader <> Player.Party.Leader then
            begin
              Player.SendClientMessage('O usuário não está no mesmo grupo que o seu.');
              Exit;
            end;

            if Servers[Player.ChannelIndex].Players[Type1].InDungeon then
            begin

              Type1 := Servers[Player.ChannelIndex].Players[Type1].Base.ClientID;

              Player.DungeonLobbyIndex := Servers[Player.ChannelIndex].Players
                [Type1].DungeonLobbyIndex;
              Player.DungeonLobbyDificult := Servers[Player.ChannelIndex].Players
                [Type1].DungeonLobbyDificult;
              Player.DungeonID := Servers[Player.ChannelIndex].Players[Type1]
                .DungeonID;
              Player.DungeonIDDificult := Servers[Player.ChannelIndex].Players
                [Type1].DungeonIDDificult;
              Player.DungeonInstanceID := Servers[Player.ChannelIndex].Players
                [Type1].DungeonInstanceID;
              Player.InDungeon := Servers[Player.ChannelIndex].Players[Type1]
                .InDungeon;

              if Servers[Player.ChannelIndex].Players[Type1]
                .Base.PlayerCharacter.LastPos.IsValid then
                Player.Teleport(Servers[Player.ChannelIndex].Players[Type1]
                  .Base.PlayerCharacter.LastPos)
              else
                Player.SendClientMessage('Erro, contate o suporte para devolver o seu item que foi consumido.(Pergaminho Dimensional)');
            end;

              Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);

          end;
          {$ENDREGION}

    {$REGION 'Comida de pran'}

        230: //tipo digestivo pran
          begin // Digestivo da pran
            if (Player.Account.Header.Pran1.IsSpawned) then
            begin
              if (Player.Account.Header.Pran1.Food <= 13) then
              begin
                Player.SendClientMessage
                  ('Sua pran está com muita fome para usar o Digestivo.');
                Exit;
              end;

              Player.Account.Header.Pran1.Food :=
                Player.Account.Header.Pran1.Food div 2;

              Player.SendPranToWorld(0);
              Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
            end
            else if (Player.Account.Header.Pran2.IsSpawned) then
            begin
              if (Player.Account.Header.Pran2.Food <= 13) then
              begin
                Player.SendClientMessage
                  ('Sua pran está com muita fome para usar o Digestivo.');
                Exit;
              end;

              Player.Account.Header.Pran2.Food :=
                Player.Account.Header.Pran2.Food div 2;

              Player.SendPranToWorld(1);
              Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
            end;
              
          end;

    {$ENDREGION}

    {$REGION 'Baús e Caixas'}
        ITEM_TYPE_BAU:
          begin
            case ItemList[item.Index].UseEffect of
        
    {$REGION 'Caixa cristais de roupa pran'}
              910:
                begin
                  if (Self.GetInvAvailableSlots(Player) = 0) then
                  begin
                    Player.SendClientMessage('Inventário cheio.');
                    Exit;
                  end;

                  RandomTax := Self.SelectRamdomItem([9451, 9452, 9456, 9457, 9458,
                    9459, 9460, 9461, 9462, 9463, 9464, 9465],
                    [5, 5, 25, 25, 25, 25, 25, 15, 15, 5, 5, 30]);

                  if (RandomTax = 0) then
                  begin
                    Player.SendClientMessage('Erro randomico, contate o suporte.');
                    Exit;
                  end;

                  Self.PutItem(Player, RandomTax);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                end;

    {$ENDREGION}
    {$REGION 'Bau do cristal sagrado'}
              1130, 950:
                begin
                  if (Self.GetInvAvailableSlots(Player) = 0) then
                  begin
                    Player.SendClientMessage('Inventário cheio.');
                    Exit;
                  end;

                  RandomTax := Self.SelectRamdomItem([5329, 5332, 5335, 5338, 5341,
                    5344, 5348, 5492, 5495, 5350, 5353, 5356, 5359, 5362, 5365,
                    5368, 5371, 5374, 5497, 5396, 5398, 5402, 5405, 5408, 5411,
                    5413, 5416, 5419, 5422, 5425, 5446, 5449, 5499, 5500, 5490,
                    5498], [25, 25, 25, 15, 15, 5, 15, 15, 15, 15, 5, 20, 15, 15,
                    15, 15, 5, 5, 20, 20, 25, 25, 5, 5, 20, 15, 25, 25, 25, 25, 25,
                    5, 5, 5, 5, 5]);

                  if (RandomTax = 0) then
                  begin
                    Player.SendClientMessage('Erro randomico, contate o suporte.');
                    Exit;
                  end;

                  Self.PutItem(Player, RandomTax);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                end;

    {$ENDREGION}

            end;
          end;
    {$ENDREGION}

    {$REGION 'Símbolo da Confiança'}
        ITEM_TYPE_STORAGE_OPEN:
          begin
            Player.OpennedOption := 7;
            Player.OpennedNPC := Player.Base.ClientID;
            Player.SendStorage(STORAGE_TYPE_PLAYER);
            Exit;
          end;
    {$ENDREGION}

    {$REGION 'Símbolo do vendedor'}
        ITEM_TYPE_SHOP_OPEN:
          begin
            Player.OpennedOption := 5;
            Player.OpennedNPC := 2070;
            TNPCHandlers.ShowShop(Player, Servers[Player.ChannelIndex].NPCS[2070]);
            Exit;
          end;
    {$ENDREGION}

    {$REGION 'Poções que dão buff'}
        702:
          begin
            if (Copy(String(ItemList[item.Index].Name), 0, 4) = 'Sopa') then
            begin
              if not(Player.Base.BuffExistsSopa) then
              begin
                Player.Base.AddBuff(ItemList[item.Index].UseEffect);
                Self.DecreaseAmount(item);
                Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                Result := True;
                Exit;
              end
              else
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[item.Index].UseEffect].Name
                  + '].'));
                Exit;
              end;
            end;

            if (SkillData[ItemList[item.Index].UseEffect].Index = 251) then
            begin
              if (Player.Base.BuffExistsByIndex(251)) then
              begin
                Player.SendClientMessage('Não é combinável com [' +
                  AnsiString(SkillData[ItemList[item.Index].UseEffect].Name
                  + '].'));
                Exit;
              end;
            end;

            case SkillData[ItemList[item.Index].UseEffect].Index of
              298:
                begin
                  if (Player.Base.BuffExistsByIndex(176)) then
                    Exit;
                end;
              493: // poção valor de batalha
                begin
                  if (Player.Base.BuffExistsInArray([494, 495, 496, 497])) then
                  begin
                    Player.SendClientMessage('Não é combinável com [' +
                      AnsiString(SkillData[ItemList[item.Index].UseEffect]
                      .Name + '].'));
                    Exit;
                  end;
                end;

              494: // poção valor de batalha
                begin
                  if (Player.Base.BuffExistsInArray([493, 495, 496, 497])) then
                  begin
                    Player.SendClientMessage('Não é combinável com [' +
                      AnsiString(SkillData[ItemList[item.Index].UseEffect]
                      .Name + '].'));
                    Exit;
                  end;
                end;

              495: // poção valor de batalha
                begin
                  if (Player.Base.BuffExistsInArray([494, 493, 496, 497])) then
                  begin
                    Player.SendClientMessage('Não é combinável com [' +
                      AnsiString(SkillData[ItemList[item.Index].UseEffect]
                      .Name + '].'));
                    Exit;
                  end;
                end;

              496: // poção valor de batalha
                begin
                  if (Player.Base.BuffExistsInArray([494, 495, 493, 497])) then
                  begin
                    Player.SendClientMessage('Não é combinável com [' +
                      AnsiString(SkillData[ItemList[item.Index].UseEffect]
                      .Name + '].'));
                    Exit;
                  end;
                end;

              497: // poção valor de batalha
                begin // poção de batalha pvp
                  if (Player.Base.BuffExistsInArray([494, 495, 496, 493])) then
                  begin
                    Player.SendClientMessage('Não é combinável com [' +
                      AnsiString(SkillData[ItemList[item.Index].UseEffect]
                      .Name + '].'));
                    Exit;
                  end;
                end;

            end;

            Player.Base.AddBuff(ItemList[item.Index].UseEffect);
            Self.DecreaseAmount(item);
              Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
              Exit(true);
          end;

    {$ENDREGION}

    {$REGION 'RECEITAS'}
    ITEM_TYPE_RECIPE:
      begin
        RecipeIndex := Self.GetIDRecipeArray(item.Index);

        if (RecipeIndex = 3000) then
        begin
          Player.SendClientMessage('A receita não existe no banco de dados.');
          Exit;
        end;

        // Verifica se o jogador tem gold suficiente
        if (Player.Base.Character.Gold < Recipes[RecipeIndex].Null2) then
        begin
          Player.SendClientMessage('Você não tem gold suficiente para criar esta receita.');
          Exit;
        end;

        if (Recipes[RecipeIndex].LevelMin > Player.Base.Character.Level) then
        begin
          Player.SendClientMessage('Level mínimo da receita é ' +
            AnsiString(Recipes[RecipeIndex].LevelMin.ToString) + '.');
          Exit;
        end;

        ItemExists := True;
        HaveAmount := True;

        for i := 0 to 11 do
        begin
          if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
            Continue;

          if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
            Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

          if not(Self.GetItemSlotAndAmountByIndex(Player,
            Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount)) then
          begin
            ItemExists := False;

            Player.SendClientMessage('Você não possui [' +
              AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
              .Name) + '].');
            Break;
          end
          else
          begin
            if (ItemAmount < Recipes[RecipeIndex].ItemRequiredAmount[i]) then
            begin
              HaveAmount := False;

              Player.SendClientMessage('Você precisa de ' +
                AnsiString(Recipes[RecipeIndex].ItemRequiredAmount[i].ToString)
                + ' do item [' +
                AnsiString(ItemList[Recipes[RecipeIndex].ItemIDRequired[i]]
                .Name) + ']. Separe a quantidade correta em apenas UM slot.');
              Break;
            end;
          end;
        end;

        if (not(ItemExists) or not(HaveAmount)) then
        begin
          Exit;
        end;

        EmptySlot := GetEmptySlot(Player);

        if (EmptySlot = 255) then
        begin
          Player.SendClientMessage('Seu inventário está cheio.');
          Exit;
        end;

        Randomize;
        RandomTax := RandomRange(1, 100);

        if (RandomTax <= (Recipes[RecipeIndex].SuccessTax div 10)) then
        begin // success

          // Verifica se a recompensa "RewardAgain" deve ser dada se Null3 > 0
          if (Recipes[RecipeIndex].Null3 > 0) then
          begin
            Randomize;
            RandomAgain := RandomRange(1, 100);

          if (RandomAgain <= Recipes[RecipeIndex].Null3 div 10) then
          begin

            for i := 0 to 11 do
          begin
            if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
              Continue;

            if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
              Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

            if (Self.GetItemSlotAndAmountByIndex(Player,
              Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount))
            then
            begin
              SecondItem := @Player.Base.Character.Inventory[ItemSlot];
              if((TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) >= 2) and
                (TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) <= 14)) then
              begin
                TItemFunctions.RemoveItem(Player, INV_TYPE, ItemSlot);
              end
              else
              begin
                Self.DecreaseAmount(SecondItem,
                  Recipes[RecipeIndex].ItemRequiredAmount[i]);
                Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
                  SecondItem^, False);
              end;
            end;
          end;

            Self.PutItem(Player, Recipes[RecipeIndex].RewardAgain, Recipes[RecipeIndex].RewardAmount);

            // Envia a mensagem ao servidor e ao jogador
             Player.SendClientMessage(Format('%s, está com sorte hoje, recebeu [%s].',
               [Player.Base.Character.Name, ItemList[Recipes[RecipeIndex].RewardAgain].Name]));
          end;
          end;

          if (Recipes[RecipeIndex].Null3 = 0) or (RandomAgain >= Recipes[RecipeIndex].Null3 div 10) then
          begin
          Player.SendClientMessage('Receita bem sucedida.');

          Self.PutItem(Player, Recipes[RecipeIndex].Reward,
            Recipes[RecipeIndex].RewardAmount);


          for i := 0 to 11 do
          begin
            if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
              Continue;

            if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
              Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

            if (Self.GetItemSlotAndAmountByIndex(Player,
              Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount))
            then
            begin
              SecondItem := @Player.Base.Character.Inventory[ItemSlot];
              if((TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) >= 2) and
                (TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) <= 14)) then
              begin
                TItemFunctions.RemoveItem(Player, INV_TYPE, ItemSlot);
              end
              else
              begin
                Self.DecreaseAmount(SecondItem,
                  Recipes[RecipeIndex].ItemRequiredAmount[i]);
                Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
                  SecondItem^, False);
              end;
            end;
          end;
          end;
          // Remove o gold do jogador após a criação bem-sucedida
          Player.DecGold(Recipes[RecipeIndex].Null2);

          // Verifica se a duplicação deve ocorrer
          if (Recipes[RecipeIndex].Null4 > 0) then
          begin
          Randomize;
          RandomDuplication := RandomRange(1, 100);

          if (RandomDuplication <= Recipes[RecipeIndex].Null4 div 10) then
          begin
             // Duplicação bem-sucedida
            Player.SendClientMessage(Format('%s Está sortudo hoje, Recebeu 2x [%s] da [Receita: %s].',
              [Player.Base.Character.Name, ItemList[Recipes[RecipeIndex].Reward].Name, ItemList[Recipes[RecipeIndex].Reward].Name]));

            // Dobra a quantidade da recompensa
            Self.PutItem(Player, Recipes[RecipeIndex].RewardAgain,
            Recipes[RecipeIndex].RewardAmount);  // Adiciona a recompensa duplicada
          end;
          end;

        end
        else // quebrar receita
        begin
          Player.SendClientMessage('Receita falhou e foi perdida.');

          Player.DecGold(Recipes[RecipeIndex].Null2);

          for i := 0 to 11 do
          begin
              if (Recipes[RecipeIndex].ItemIDRequired[i] = 0) then
                Continue;

              if(Recipes[RecipeIndex].ItemIDRequired[i] = 4202) then
                Recipes[RecipeIndex].ItemIDRequired[i] := 4204;

              if (Self.GetItemSlotAndAmountByIndex(Player,
                Recipes[RecipeIndex].ItemIDRequired[i], ItemSlot, ItemAmount)) then
              begin
                  SecondItem := @Player.Base.Character.Inventory[ItemSlot];
                if((TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) >= 2) and
                  (TItemFunctions.GetItemEquipSlot(Recipes[RecipeIndex].ItemRequiredAmount[i]) <= 14)) then
                begin
                  TItemFunctions.RemoveItem(Player, INV_TYPE, ItemSlot);
                end
                else
                begin
                  Self.DecreaseAmount(SecondItem,
                    Recipes[RecipeIndex].ItemRequiredAmount[i]);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, ItemSlot,
                    SecondItem^, False);
                end;
              end;
          end;
        end;
      end;

    {$ENDREGION}
  end;

  Case item.Index of
  
  {$region 'comida de pran'}
              8105: // sopa de batata doce (cute)
                begin
                  if (Player.SpawnedPran = 0) then
                  begin
                    if (Player.Account.Header.Pran1.Food >= 121) then
                    begin
                      Player.Account.Header.Pran1.Food := 121;
                      Player.SendClientMessage('Sua pran não consegue comer mais.');
                      Exit;
                    end;
                    Inc(Player.Account.Header.Pran1.Personality.Cute, 2);

                    DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                    DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                    DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                    DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                    DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
                    if not(Player.Account.Header.Pran1.Devotion >= 226) then
                      Player.Account.Header.Pran1.Devotion := Player.Account.Header.Pran1.Devotion + 1;
                    if (Player.Account.Header.Pran1.MovedToCentral = True) then
                      Player.Account.Header.Pran1.MovedToCentral := False;
                  
                    if ((Player.Account.Header.Pran1.Food + 15) > 121) then
                      Player.Account.Header.Pran1.Food := 121
                     else
                    Inc(Player.Account.Header.Pran1.Food, 15);

                    Player.SendPranToWorld(0);
                    Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                  end;

                  if (Player.SpawnedPran = 1) then
                  begin
                    if (Player.Account.Header.Pran2.Food >= 121) then
                    begin
                      Player.Account.Header.Pran2.Food := 121;
                      Player.SendClientMessage('Sua pran não consegue comer mais.');
                      Exit;
                    end;
                    Inc(Player.Account.Header.Pran2.Personality.Cute, 2);

                    DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                    DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                    DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                    DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                    DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
                    if not(Player.Account.Header.Pran2.Devotion >= 226) then
                      Player.Account.Header.Pran2.Devotion := Player.Account.Header.Pran2.Devotion + 1;
                    if (Player.Account.Header.Pran2.MovedToCentral = True) then
                      Player.Account.Header.Pran2.MovedToCentral := False;
                  
                    if ((Player.Account.Header.Pran2.Food + 15) > 121) then
                      Player.Account.Header.Pran2.Food := 121
                     else
                    Inc(Player.Account.Header.Pran2.Food, 15);

                    Player.SendPranToWorld(1);
                  end;
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                end;

              8106: // perfait de cereja (sexy)
                begin
                
                  if Player.SpawnedPran = 0 then                
                  begin
                  if (Player.Account.Header.Pran1.Food >= 121) then
                  begin
                    Player.Account.Header.Pran1.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                  Inc(Player.Account.Header.Pran1.Personality.Sexy, 2);

                  DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran1.Devotion >= 226) then
                    Player.Account.Header.Pran1.Devotion := Player.Account.Header.Pran1.Devotion + 1;
                  if (Player.Account.Header.Pran1.MovedToCentral = True) then
                    Player.Account.Header.Pran1.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran1.Food + 15) > 121) then
                    Player.Account.Header.Pran1.Food := 121
                   else
                  Inc(Player.Account.Header.Pran1.Food, 15);

                  Player.SendPranToWorld(0);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                  end;

                  if Player.SpawnedPran = 1 then                
                  begin
                  if (Player.Account.Header.Pran2.Food >= 121) then
                  begin
                    Player.Account.Header.Pran2.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                  Inc(Player.Account.Header.Pran2.Personality.Sexy, 2);

                  DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran2.Devotion >= 226) then
                    Player.Account.Header.Pran2.Devotion := Player.Account.Header.Pran2.Devotion + 1;
                  if (Player.Account.Header.Pran2.MovedToCentral = True) then
                    Player.Account.Header.Pran2.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran2.Food + 15) > 121) then
                    Player.Account.Header.Pran2.Food := 121
                   else
                  Inc(Player.Account.Header.Pran2.Food, 15);

                  Player.SendPranToWorld(1);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                  end;
                end;

              8107: // salada de caviar (smart)
                begin

                 if Player.SpawnedPran = 0 then
                 begin
                  if (Player.Account.Header.Pran1.Food >= 121) then
                  begin
                    Player.Account.Header.Pran1.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran1.Personality.Smart, 2);

                  DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran1.Devotion >= 226) then
                    Player.Account.Header.Pran1.Devotion := Player.Account.Header.Pran1.Devotion + 1;
                  if (Player.Account.Header.Pran1.MovedToCentral = True) then
                    Player.Account.Header.Pran1.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran1.Food + 15) > 121) then
                    Player.Account.Header.Pran1.Food := 121
                   else
                  Inc(Player.Account.Header.Pran1.Food, 15);

                  Player.SendPranToWorld(0);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                 end;

                 if Player.SpawnedPran = 1 then
                 begin
                  if (Player.Account.Header.Pran2.Food >= 121) then
                  begin
                    Player.Account.Header.Pran2.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran2.Personality.Smart, 2);

                  DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran2.Devotion >= 226) then
                    Player.Account.Header.Pran2.Devotion := Player.Account.Header.Pran2.Devotion + 1;
                  if (Player.Account.Header.Pran2.MovedToCentral = True) then
                    Player.Account.Header.Pran2.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran2.Food + 15) > 121) then
                    Player.Account.Header.Pran2.Food := 121
                   else
                  Inc(Player.Account.Header.Pran2.Food, 15);

                  Player.SendPranToWorld(1);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                 end;
                end;

              8108: // espetinho de camarao (energetic)
                begin
                 if Player.SpawnedPran = 0  then
                 begin
                  if (Player.Account.Header.Pran1.Food >= 121) then
                  begin
                    Player.Account.Header.Pran1.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran1.Personality.Energetic, 2);

                  DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran1.Devotion >= 226) then
                    Player.Account.Header.Pran1.Devotion := Player.Account.Header.Pran1.Devotion + 1;
                  if (Player.Account.Header.Pran1.MovedToCentral = True) then
                    Player.Account.Header.Pran1.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran1.Food + 15) > 121) then
                    Player.Account.Header.Pran1.Food := 121
                   else
                  Inc(Player.Account.Header.Pran1.Food, 15);

                  Player.SendPranToWorld(0);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                  end;

                  if Player.SpawnedPran = 1 then
                  begin
                                  if (Player.Account.Header.Pran2.Food >= 121) then
                  begin
                    Player.Account.Header.Pran2.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran2.Personality.Energetic, 2);

                  DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran2.Devotion >= 226) then
                    Player.Account.Header.Pran2.Devotion := Player.Account.Header.Pran2.Devotion + 1;
                  if (Player.Account.Header.Pran2.MovedToCentral = True) then
                    Player.Account.Header.Pran2.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran2.Food + 15) > 121) then
                    Player.Account.Header.Pran2.Food := 121
                   else
                  Inc(Player.Account.Header.Pran2.Food, 15);

                  Player.SendPranToWorld(1);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);


                  end;
                end;

              8109: // churrasco de york (tough)
                begin
                 if Player.SpawnedPran = 0  then
                 begin
                  if (Player.Account.Header.Pran1.Food >= 121) then
                  begin
                    Player.Account.Header.Pran1.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran1.Personality.Tough, 2);

                  DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran1.Devotion >= 226) then
                    Player.Account.Header.Pran1.Devotion := Player.Account.Header.Pran1.Devotion + 1;
                  if (Player.Account.Header.Pran1.MovedToCentral = True) then
                    Player.Account.Header.Pran1.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran1.Food + 15) > 121) then
                    Player.Account.Header.Pran1.Food := 121
                   else
                  Inc(Player.Account.Header.Pran1.Food, 15);

                  Player.SendPranToWorld(0);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                 end;

                                if Player.SpawnedPran = 1  then
                 begin
                  if (Player.Account.Header.Pran2.Food >= 121) then
                  begin
                    Player.Account.Header.Pran2.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran2.Personality.Tough, 2);

                  DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Corrupt, 3);
                  if not(Player.Account.Header.Pran2.Devotion >= 226) then
                    Player.Account.Header.Pran2.Devotion := Player.Account.Header.Pran2.Devotion + 1;
                  if (Player.Account.Header.Pran2.MovedToCentral = True) then
                    Player.Account.Header.Pran2.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran2.Food + 15) > 121) then
                    Player.Account.Header.Pran2.Food := 121
                   else
                  Inc(Player.Account.Header.Pran2.Food, 15);

                  Player.SendPranToWorld(1);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                 end;
                end;

              8110: // peixe duvidoso assado (corrupt)
                begin
                 if Player.SpawnedPran = 0 then
                 begin
                  if (Player.Account.Header.Pran1.Food >= 121) then
                  begin
                    Player.Account.Header.Pran1.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran1.Personality.Corrupt, 2);

                  DecWord(Player.Account.Header.Pran1.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran1.Personality.Cute, 3);
                  if not(Player.Account.Header.Pran1.Devotion >= 226) then
                    Player.Account.Header.Pran1.Devotion := Player.Account.Header.Pran1.Devotion + 1;
                  if (Player.Account.Header.Pran1.MovedToCentral = True) then
                    Player.Account.Header.Pran1.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran1.Food + 15) > 121) then
                    Player.Account.Header.Pran1.Food := 121
                   else
                  Inc(Player.Account.Header.Pran1.Food, 15);

                  Player.SendPranToWorld(0);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                 end;

                                if Player.SpawnedPran = 1 then
                 begin
                  if (Player.Account.Header.Pran2.Food >= 121) then
                  begin
                    Player.Account.Header.Pran2.Food := 121;
                    Player.SendClientMessage('Sua pran não consegue comer mais.');
                    Exit;
                  end;
                    Inc(Player.Account.Header.Pran2.Personality.Corrupt, 2);

                  DecWord(Player.Account.Header.Pran2.Personality.Sexy, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Smart, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Energetic, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Tough, 3);
                  DecWord(Player.Account.Header.Pran2.Personality.Cute, 3);
                  if not(Player.Account.Header.Pran2.Devotion >= 226) then
                    Player.Account.Header.Pran2.Devotion := Player.Account.Header.Pran2.Devotion + 1;
                  if (Player.Account.Header.Pran2.MovedToCentral = True) then
                    Player.Account.Header.Pran2.MovedToCentral := False;
                  
                  if ((Player.Account.Header.Pran2.Food + 15) > 121) then
                    Player.Account.Header.Pran2.Food := 121
                   else
                  Inc(Player.Account.Header.Pran2.Food, 15);

                  Player.SendPranToWorld(1);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
                 end;
                end;
  {$endregion}

  {$Region 'cidadania'}
      4438: //símbolo de cidadania
      begin
               
                  if Player.Account.Header.Nation <> TCitizenship.None then
                    Exit;

                  Player.Character.Base.Nation := ServerList[Player.ChannelIndex]
                    .NationIndex;
                  Player.Account.Header.Nation :=
                    TCitizenship(ServerList[Player.ChannelIndex].NationIndex);
                  Player.RefreshPlayerInfos;
                  Player.AddTitle(18, 1);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
      end;
      {$endregion}

  {$region 'voltar lakia'}
      8073:
       begin
            Player.OpennedNPC := 0;
            Player.OpennedOption := 0;
            Self.DecreaseAmount(item);
            Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
            TPacketHandlers.TeleportLakia(Player);
            Exit(true);
       end;

       {$endregion}

  {$region 'ir para leopold'}
      // pergaminho para telar para leopold
      8080:
        begin
          Player.OpennedNPC := 0;
          Player.OpennedOption := 0;

          if (Player.ChannelIndex = 3) then
          begin
            Player.SendClientMessage('Não pode ser usado em Leopold.');
            Exit;
          end;

          Self.DecreaseAmount(item);
          Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);       
          TPacketHandlers.TeleportLeopold(Player);
          Exit(true);
        end;

  {$endregion}

  {$region 'auxilio poderoso'}
      8250:  // Auxílio poderoso 15 dias
      begin
         // Decreases the item amount and updates the player's inventory
            Self.DecreaseAmount(item);
            Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
            Player.IsAuxilyUser := True;
            Self.AddAuxilyTime(Player, 15);
                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
      end;

      8051: // Auxílio poderoso 30 dias
        begin
         // Decreases the item amount and updates the player's inventory
            Self.DecreaseAmount(item);
            Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
            Player.IsAuxilyUser := True;
            Self.AddAuxilyTime(Player, 15);
                              Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
        end;
  {$endregion}

  {$region 'reset status points'}
      8192:
        begin
           TotalBasePoints :=
              Player.Base.Character.CurrentScore.Str + Player.Base.Character.CurrentScore.agility +
              Player.Base.Character.CurrentScore.Int + Player.Base.Character.CurrentScore.Cons +
              Player.Base.Character.CurrentScore.Luck;

            case Player.Base.GetMobClassPlayer of

              0:
              begin
                Player.Base.Character.CurrentScore.Str := 15;
                Player.Base.Character.CurrentScore.agility := 09;
                Player.Base.Character.CurrentScore.Int := 05;
                Player.Base.Character.CurrentScore.Cons := 16;
              end;

              1:
              begin
                Player.Base.Character.CurrentScore.Str := 14;
                Player.Base.Character.CurrentScore.agility := 10;
                Player.Base.Character.CurrentScore.Int := 06;
                Player.Base.Character.CurrentScore.Cons := 16;
              end;
              2:
              begin
                Player.Base.Character.CurrentScore.Str := 08;
                Player.Base.Character.CurrentScore.agility := 16;
                Player.Base.Character.CurrentScore.Int := 09;
                Player.Base.Character.CurrentScore.Cons := 12;
                Player.Base.Character.CurrentScore.Luck := 05;
              end;

              3:
              begin
                Player.Base.Character.CurrentScore.Str := 08;
                Player.Base.Character.CurrentScore.agility := 14;
                Player.Base.Character.CurrentScore.Int := 10;
                Player.Base.Character.CurrentScore.Cons := 12;
                Player.Base.Character.CurrentScore.Luck := 06;
              end;
              4:
              begin
                           Player.Base.Character.CurrentScore.Str := 07;
                Player.Base.Character.CurrentScore.agility := 09;
                Player.Base.Character.CurrentScore.Int := 16;
                Player.Base.Character.CurrentScore.Cons := 08;
                Player.Base.Character.CurrentScore.Luck := 10;
              end;
              5:
              begin
                Player.Base.Character.CurrentScore.Str := 07;
                Player.Base.Character.CurrentScore.agility := 10;
                Player.Base.Character.CurrentScore.Int := 15;
                Player.Base.Character.CurrentScore.Cons := 09;
                Player.Base.Character.CurrentScore.Luck := 09;
              end;

            end;

              TotalBasePointsCalc :=
              Player.Base.Character.CurrentScore.Str + Player.Base.Character.CurrentScore.agility +
              Player.Base.Character.CurrentScore.Int + Player.Base.Character.CurrentScore.Cons +
              Player.Base.Character.CurrentScore.Luck;


              // Adicionar os pontos ao campo Status
              Player.Base.Character.CurrentScore.Status := Player.Base.Character.CurrentScore.Status + abs(TotalBasePoints - TotalBasePointsCalc);

              // Opcional: Enviar mensagem para o jogador sobre a redistribuição
              Player.SendClientMessage('Pontos base redistribuídos, relogue!');
              Player.Base.SendRefreshKills();
               Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
        end;
        {$endregion}

  {$region 'spawn boss item ticket'}
        16021:
              begin

                if (Player.InDungeon) or (Player.GetCurrentCityID in [1, 10, 14])
                then
                begin
                  Player.SendClientMessage
                    ('Uso proíbido dentro de cidades ou dungeons.');
                  Exit;
                end;

                for i := 350 to 450 do
                begin
                  if Servers[Player.ChannelIndex].MOBS.TMobS[i].IntName <> 2418
                  then
                    Continue;

                  TItemFunctions.SpawnMob(Player,
                    Player.Base.PlayerCharacter.CurrentPos, i,
                    Player.Base.ClientID, True);
                  Result := True;
                  Exit;

                end;

                if not SpawnMob(Player, Player.Base.PlayerCharacter.CurrentPos,
                  373, Player.Base.ClientID, False) then
                begin
                  Player.SendClientMessage('Erro ao spawnar o boss');
                  Exit;
                end
                else
                  Player.SendClientMessage('Boss Spawnado com sucesso');
                Player.Base.SendEffectOther($3E, 0);

                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);

              end;
  {$endregion}

  {$region 'Caixa de App Aleatória'}
              25185:
              begin

                Capacete := @Player.Character.Base.Equip[2];
                Armadura := @Player.Character.Base.Equip[3];
                Luvas := @Player.Character.Base.Equip[4];
                Botas := @Player.Character.Base.Equip[5];
                Arma := @Player.Character.Base.Equip[6];
                Escudo := @Player.Character.Base.Equip[7];

                Randomize;
                valor := Random(2) + 1; // Gera 1 ou 2

                if Player.Base.GetMobClass = 2 then // atirador
                begin

                  case valor of
                    1: // Academia Azul
                      begin
                        CapaceteIndex := 12616;
                        ArmaduraIndex := 12646;
                        LuvasIndex := 12676;
                        BotasIndex := 12706;
                        ArmaIndex := 12210;
                        EscudoIndex := 0;
                        Aparencia := 'Aparência Academia [Azul]';
                      end;
                    2: // Academia Vermelho
                      begin
                        CapaceteIndex := 12617;
                        ArmaduraIndex := 12647;
                        LuvasIndex := 12677;
                        BotasIndex := 12707;
                        ArmaIndex := 12211;
                        EscudoIndex := 0;
                        Aparencia := 'Aparência Academia [Vermelho]';
                      end;
                  end;

                  if Capacete^.Index > 0 then
                  begin
                    Capacete^.APP := CapaceteIndex;
                    Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 2,
                      Capacete^, False);
                  end;

                  if Armadura^.Index > 0 then
                  begin
                    Armadura^.APP := ArmaduraIndex;
                    Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 3,
                      Armadura^, False);
                  end;

                  if Luvas^.Index > 0 then
                  begin
                    Luvas^.APP := LuvasIndex;
                    Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 4, Luvas^, False);
                  end;

                  if Botas^.Index > 0 then
                  begin
                    Botas^.APP := BotasIndex;
                    Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 5, Botas^, False);
                  end;

                  if Arma^.Index > 0 then
                  begin
                    Arma^.APP := ArmaIndex;
                    Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 6, Arma^, False);
                  end;

                  if Escudo^.Index > 0 then
                  begin
                    Escudo^.APP := EscudoIndex;
                    Player.Base.SendRefreshItemSlot(EQUIP_TYPE, 7,
                      Escudo^, False);
                  end;
                  Player.Base.SendCreateMob(SPAWN_NORMAL);
                end;

                Player.SendClientMessage('Você obteve ' + Aparencia +
                  ' nos itens equipados');

                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
              end;
  {$endregion}            

  {$REGION 'Baú Perdido do Cristal Sagrado [Pran]'}
            16004:
              begin
                if (Self.GetInvAvailableSlots(Player) = 0) then
                begin
                  Player.SendClientMessage('Inventário cheio.');
                  Exit;
                end;

                RandomTax := Self.SelectRamdomItem([9451, 9452, 9462, 9461, 9465,
                  9464, 9463], [2, 2, 30, 30, 48, 48, 48]);

                if (RandomTax = 0) then
                begin
                  Player.SendClientMessage('Erro randomico, contate o suporte.');
                  Exit;
                end;

                Self.PutItem(Player, RandomTax);

                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
              end;
  {$ENDREGION}

  {$REGION 'Baú Perdido do Cristal Sagrado [Montaria]'}
            16003:
              begin
                if (Self.GetInvAvailableSlots(Player) = 0) then
                begin
                  Player.SendClientMessage('Inventário cheio.');
                  Exit;
                end;

                RandomTax := Self.SelectRamdomItem([4234, 4228, 4250, 4249, 4236,
                  4232, 4233], [4, 30, 30, 30, 48, 48, 48]);

                if (RandomTax = 0) then
                begin
                  Player.SendClientMessage('Erro randomico, contate o suporte.');
                  Exit;
                end;

                Self.PutItem(Player, RandomTax);
                                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
              end;
  {$ENDREGION}

  {$REGION 'Baú Perdido do Cristal Sagrado [Arma]'}
            16000:
              begin
                if (Self.GetInvAvailableSlots(Player) = 0) then
                begin
                  Player.SendClientMessage('Inventário cheio.');
                  Exit;
                end;

                RandomTax := Self.SelectRamdomItem([5348, 9388, 9389, 5349, 5338,
                  5342, 15716, 5495, 5494, 5343, 5339, 5335, 5492, 15723],
                  [1, 2, 2, 4, 4, 4, 16, 16, 48, 48, 48, 48, 48, 48]);

                if (RandomTax = 0) then
                begin
                  Player.SendClientMessage('Erro randomico, contate o suporte.');
                  Exit;
                end;

                if (RandomTax = 0) then
                begin
                  Player.SendClientMessage('Erro randomico, contate o suporte.');
                  Exit;
                end;

                Self.PutItem(Player, RandomTax);
                                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
              end;
  {$ENDREGION}

  {$REGION 'Baú Perdido do Cristal Sagrado [Armadura]'}
            16001:
              begin
                if (Self.GetInvAvailableSlots(Player) = 0) then
                begin
                  Player.SendClientMessage('Inventário cheio.');
                  Exit;
                end;

                RandomTax := Self.SelectRamdomItem([5360, 5363, 5368, 9396, 9395,
                  5459, 5458, 5467, 5466, 9398, 9399, 9750],
                  [1, 2, 2, 4, 4, 8, 8, 16, 16, 48, 48, 48]);

                if (RandomTax = 0) then
                begin
                  Player.SendClientMessage('Erro randomico, contate o suporte.');
                  Exit;
                end;

                Self.PutItem(Player, RandomTax);
                                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
              end;
              {$ENDREGION}

  {$REGION 'Baú Perdido do Cristal Sagrado [Acessório]'}
            16002:
              begin
                if (Self.GetInvAvailableSlots(Player) = 0) then
                begin
                  Player.SendClientMessage('Inventário cheio.');
                  Exit;
                end;

                RandomTax := Self.SelectRamdomItem([9403, 9402, 5404, 5402, 5395,
                  5401, 5411, 5413, 5416, 5419, 5422, 5425, 9357, 9358, 9359,
                  9360, 9361, 9362], [8, 8, 8, 2, 1, 1, 2, 2, 16, 16, 16, 16, 16,
                  8, 8, 8, 8, 8, 8]);

                if (RandomTax = 0) then
                begin
                  Player.SendClientMessage('Erro randomico, contate o suporte.');
                  Exit;
                end;

                Self.PutItem(Player, RandomTax);
                                  Self.DecreaseAmount(item);
                  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
                  Exit(true);
              end;
  {$ENDREGION}

  end;
  
  Self.DecreaseAmount(item);
  Player.Base.SendRefreshItemSlot(INV_TYPE, Slot, item^, False);
  Result := True;
end;
{$ENDREGION}
{$REGION 'Item Reinforce Stats'}

class function TItemFunctions.GetItemReinforceDamageReduction(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].DamageReduction[Refine];
end;

class function TItemFunctions.GetItemReinforceHPMPInc(Index: WORD;
  Refine: BYTE): WORD;
begin
  Result := Reinforce3[Self.GetItemReinforce3Index(Index)
    ].HealthIncrementPoints[Refine];
end;

class function TItemFunctions.GetReinforceFromItem(const item: TItem): BYTE;
begin
  if (item.Refi = 0) then
    Exit(0);
  Result := Round(item.Refi / 16);
end;

{$ENDREGION}
{$REGION 'ItemDB Functions'}

class function TItemFunctions.UpdateMovedItems(var Player: TPlayer;
  SrcItemSlot, DestItemSlot: BYTE; SrcSlotType, DestSlotType: BYTE;
  SrcItem, DestItem: PItem): Boolean;
var
  SQLComp: TQuery;
begin
  SQLComp := Self.CreateSQL;
  try
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', SrcSlotType);
    SQLComp.AddParameter2('pslot', SrcItemSlot);
    SQLComp.Run(False);
    SQLComp.SetQuery
      ('UPDATE items SET slot_type=:pslot_type, slot=:pslot WHERE id=:pid');
    SQLComp.AddParameter2('pslot_type', DestSlotType);
    SQLComp.AddParameter2('pslot', DestItemSlot);
    SQLComp.Run(False);
  except
    on E: Exception do
    begin
      Logger.Write('Erro ao salvar os itens movidos acc[' +
        String(Player.Account.Header.Username) + '] items[' +
        String(ItemList[SrcItem.Index].Name) + ' -> ' +
        String(ItemList[DestItem.Index].Name) + '] slot [' +
        SrcItemSlot.ToString + ' -> ' + DestItemSlot.ToString + '] error [' +
        E.Message + '] time [' + DateTimeToStr(Now) + ']', TlogType.Error);
    end;
  end;
  SQLComp.Destroy;
  Result := True;
end;
{$ENDREGION}
{$REGION 'ENCONTRAR RECEITA'}

class function TItemFunctions.GetIDRecipeArray(RecipeItemID: WORD): WORD;
var
  i: WORD;
begin
  Result := 3000;
  for i := Low(Recipes) to High(Recipes) do
    if (Recipes[i].ItemRecipeID <> 0) and
      (Recipes[i].ItemRecipeID = RecipeItemID) then
    begin
      Result := i;
      Break;
    end;
end;

{$ENDREGION}

end.
