unit ConsumableWhitelist;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Log;

type
  TConsumableItem = record
    Value: Word;
    Description: string;
  end;

  TConsumableWhitelist = class
  private
    class var FItemTypes: TList<TConsumableItem>;
    class var FItemIndexes: TList<TConsumableItem>;
    class var FLoaded: Boolean;
    class var FFilePath: string;
  public
    class constructor Create;
    class destructor Destroy;
    
    class procedure LoadFromFile(const FileName: string = 'Data/ConsumableItems.txt');
    class procedure Reload;
    class function IsConsumable(ItemType: Word; ItemIndex: Word): Boolean;
    class procedure AddItemType(Value: Word; Description: string = '');
    class procedure AddItemIndex(Value: Word; Description: string = '');
    class procedure RemoveItemType(Value: Word);
    class procedure RemoveItemIndex(Value: Word);
    class procedure SaveToFile;
    
    class property ItemTypes: TList<TConsumableItem> read FItemTypes;
    class property ItemIndexes: TList<TConsumableItem> read FItemIndexes;
    class property Loaded: Boolean read FLoaded;
  end;

implementation

class constructor TConsumableWhitelist.Create;
begin
  FItemTypes := TList<TConsumableItem>.Create;
  FItemIndexes := TList<TConsumableItem>.Create;
  FLoaded := False;
  FFilePath := 'Data/ConsumableItems.txt';
end;

class destructor TConsumableWhitelist.Destroy;
begin
  FItemTypes.Free;
  FItemIndexes.Free;
end;

class procedure TConsumableWhitelist.LoadFromFile(const FileName: string);
var
  FileLines: TStringList;
  Line, CleanLine, Comment: string;
  CurrentSection: string;
  Value: Integer;
  i, CommentPos: Integer;
  Item: TConsumableItem;
begin
  FFilePath := FileName;
  
  if not FileExists(FileName) then
  begin
    Logger.Write('⚠️ Arquivo de whitelist não encontrado: ' + FileName, TLogType.Warnings);
    Exit;
  end;

  FItemTypes.Clear;
  FItemIndexes.Clear;
  CurrentSection := '';

  FileLines := TStringList.Create;
  try
    FileLines.LoadFromFile(FileName);

    for i := 0 to FileLines.Count - 1 do
    begin
      Line := Trim(FileLines[i]);

      if (Line = '') or ((Length(Line) > 0) and (Line[1] = '#')) then
        Continue;

      if (Length(Line) > 2) and (Line[1] = '[') and (Line[Length(Line)] = ']') then
      begin
        CurrentSection := Copy(Line, 2, Length(Line) - 2);
        Continue;
      end;

      CleanLine := Line;
      Comment := '';
      CommentPos := Pos('#', Line);
      
      if CommentPos > 0 then
      begin
        CleanLine := Trim(Copy(Line, 1, CommentPos - 1));
        Comment := Trim(Copy(Line, CommentPos + 1, MaxInt));
      end;

      if TryStrToInt(CleanLine, Value) then
      begin
        Item.Value := Value;
        Item.Description := Comment;
        
        if CurrentSection = 'ItemTypes' then
          FItemTypes.Add(Item)
        else if CurrentSection = 'ItemIndexes' then
          FItemIndexes.Add(Item);
      end;
    end;

    FLoaded := True;
    Logger.Write('✅ Whitelist carregada: ' + FItemTypes.Count.ToString + 
                 ' ItemTypes, ' + FItemIndexes.Count.ToString + ' Indexes', TLogType.Warnings);

  finally
    FileLines.Free;
  end;
end;

class procedure TConsumableWhitelist.Reload;
begin
  LoadFromFile(FFilePath);
end;

class function TConsumableWhitelist.IsConsumable(ItemType: Word; ItemIndex: Word): Boolean;
var
  Item: TConsumableItem;
begin
  if not FLoaded then
    LoadFromFile(FFilePath);

  Result := False;
  
  for Item in FItemTypes do
  begin
    if Item.Value = ItemType then
      Exit(True);
  end;
  
  for Item in FItemIndexes do
  begin
    if Item.Value = ItemIndex then
      Exit(True);
  end;
end;

class procedure TConsumableWhitelist.AddItemType(Value: Word; Description: string);
var
  Item: TConsumableItem;
  Existing: TConsumableItem;
begin
  for Existing in FItemTypes do
  begin
    if Existing.Value = Value then
      Exit;
  end;
  
  Item.Value := Value;
  Item.Description := Description;
  FItemTypes.Add(Item);
end;

class procedure TConsumableWhitelist.AddItemIndex(Value: Word; Description: string);
var
  Item: TConsumableItem;
  Existing: TConsumableItem;
begin
  for Existing in FItemIndexes do
  begin
    if Existing.Value = Value then
      Exit;
  end;
  
  Item.Value := Value;
  Item.Description := Description;
  FItemIndexes.Add(Item);
end;

class procedure TConsumableWhitelist.RemoveItemType(Value: Word);
var
  i: Integer;
begin
  for i := FItemTypes.Count - 1 downto 0 do
  begin
    if FItemTypes[i].Value = Value then
    begin
      FItemTypes.Delete(i);
      Break;
    end;
  end;
end;

class procedure TConsumableWhitelist.RemoveItemIndex(Value: Word);
var
  i: Integer;
begin
  for i := FItemIndexes.Count - 1 downto 0 do
  begin
    if FItemIndexes[i].Value = Value then
    begin
      FItemIndexes.Delete(i);
      Break;
    end;
  end;
end;

class procedure TConsumableWhitelist.SaveToFile;
var
  FileLines: TStringList;
  Item: TConsumableItem;
begin
  FileLines := TStringList.Create;
  try
    FileLines.Add('# ========================================');
    FileLines.Add('# WHITELIST DE ITENS CONSUMÍVEIS');
    FileLines.Add('# ========================================');
    FileLines.Add('');
    
    FileLines.Add('[ItemTypes]');
    for Item in FItemTypes do
    begin
      if Item.Description <> '' then
        FileLines.Add(Format('%-6d # %s', [Item.Value, Item.Description]))
      else
        FileLines.Add(Item.Value.ToString);
    end;
    
    FileLines.Add('');
    FileLines.Add('[ItemIndexes]');
    for Item in FItemIndexes do
    begin
      if Item.Description <> '' then
        FileLines.Add(Format('%-6d # %s', [Item.Value, Item.Description]))
      else
        FileLines.Add(Item.Value.ToString);
    end;
    
    FileLines.SaveToFile(FFilePath);
    Logger.Write('💾 Whitelist salva em: ' + FFilePath, TLogType.Warnings);
    
  finally
    FileLines.Free;
  end;
end;

end.