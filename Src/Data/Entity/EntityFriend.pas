unit EntityFriend;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Windows, Generics.Collections, SQL;

{$OLDTYPELAYOUT ON}

type
  TFriend = packed record
  private
    bActive: Boolean;
  public
    id: UInt64;
    friendCharacterId: UInt64;
    friendCharacterName: AnsiString;

    procedure delete();
    procedure create(const id: UInt64; const friendCharacterId: UInt64;
      const friendCharacterName: AnsiString);
  end;

type
  TFriendList = TDictionary<UInt64, TFriend>;

type
  TEntityFriend = class(TObject)
  private
    fPlayer: Pointer;

    { add & remove friends }
    function setDisableFriend(const characterId: UInt64;
      const friendCharacterId: UInt64): Boolean;
    class function CreateSQL: TQuery;
  public
    { construct & destruct }
    constructor create(TargetPlayer: Pointer);

    { load  & save friends }
    function readFriendList(Player: Pointer): Boolean;

    { add & remove friends }
    function addFriend(characterIndex: UInt64): Boolean;
    function removeFriend(characterIndex: UInt64): Boolean;

    { get friend }
    function getFriend(const characterIndex: UInt64; out xPlayer: WORD;
      out xServer: Byte): Boolean;
  end;

{$OLDTYPELAYOUT OFF}

implementation

uses
  Player, SysUtils, Log, GlobalDefs;

{$REGION 'TFriend'}

procedure TFriend.delete;
begin
  self.bActive := False;
end;

procedure TFriend.create(const id: UInt64; const friendCharacterId: UInt64;
  const friendCharacterName: AnsiString);
begin
  self.bActive := True;

  self.id := id;
  self.friendCharacterId := friendCharacterId;
  self.friendCharacterName := friendCharacterName;
end;

{$ENDREGION}
{$REGION 'construct & destruct'}

class function TEntityFriend.CreateSQL: TQuery;
begin
  // Criando a conexão usando as variáveis globais já definidas
  Result := TQuery.create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
end;

constructor TEntityFriend.create(TargetPlayer: Pointer);
var
  Player: PPlayer;
begin
  inherited create;

  self.fPlayer := TargetPlayer;

  Player := (TargetPlayer); // tinha PPlayer()
  Player.FriendList := TFriendList.create(50);
  Player.FriendList.Clear();
end;

{$ENDREGION}
{$REGION 'load  & save friends'}

function TEntityFriend.readFriendList(Player: Pointer): Boolean;
var
  SPlayer: PPlayer;
  currentFriend: TFriend;
  i: Byte;
  SQLComp: TQuery;
begin
  Result := False;
  SPlayer := Player;
  SQLComp := self.CreateSQL;

  try
    SPlayer^.FriendList.Clear;

    SQLComp.SetQuery
      (format('SELECT friends.id, friends.friend_characterId, characters.name '
      + 'FROM friend_list AS friends ' +
      'INNER JOIN characters ON friends.friend_characterId = characters.id ' +
      'WHERE active > 0 AND friends.owner_characterId = %d ' +
      'ORDER BY friends.id DESC LIMIT 50',
      [SPlayer^.Character.Base.CharIndex]));
    SQLComp.Run();

    if SQLComp.Query.RecordCount > 0 then
    begin
      SQLComp.Query.First;
      for i := 0 to SQLComp.Query.RecordCount - 1 do
      begin
        ZeroMemory(@currentFriend, SizeOf(TFriend));
        currentFriend.create(UInt64(SQLComp.Query.FieldByName('id').AsLargeInt),
          UInt64(SQLComp.Query.FieldByName('friend_characterId').AsLargeInt),
          AnsiString(SQLComp.Query.FieldByName('name').AsString));

        if not SPlayer^.FriendList.ContainsKey(currentFriend.friendCharacterId)
        then
          SPlayer^.FriendList.Add(currentFriend.friendCharacterId,
            currentFriend);

        SQLComp.Query.Next;
      end;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on loading friend list. msg[' + E.Message +
        ' : ' + E.GetBaseException.Message + '] clientId [' +
        String(SPlayer^.Character.Base.ClientId.ToString) + '] ' +
        DateTimeToStr(Now) + '.', TlogType.Error);
      SQLComp.Free;
      Exit;
    end;
  end;

  SQLComp.Free;
  Result := True;
end;

{$ENDREGION}
{$REGION 'add & remove friends'}

function TEntityFriend.setDisableFriend(const characterId: UInt64;
  const friendCharacterId: UInt64): Boolean;
var
  SQLComp: TQuery;
begin
  Result := False;

  SQLComp := self.CreateSQL;

  if not SQLComp.Query.Connection.Connected then
  begin
    Logger.Write('Falha de conexão individual com mysql.[setDisableFriend]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[setDisableFriend]',
      TlogType.Error);
    SQLComp.Free;
    Exit;
  end;

  try
    SQLComp.SetQuery
      (format('UPDATE friend_list SET active = 0, lastUpdateDate = NOW() ' +
      'WHERE owner_characterId = %d AND friend_characterId = %d',
      [characterId, friendCharacterId]));
    SQLComp.Run(False);
    Result := True;
  except
    on E: Exception do
      Writeln('erro no entitty friend');
  end;

  SQLComp.Free;
end;

function TEntityFriend.addFriend(characterIndex: UInt64): Boolean;
var
  Player: PPlayer;
  SQLComp: TQuery;
begin
  Result := False;

  Player := self.fPlayer;

  SQLComp := self.CreateSQL;

  if not(SQLComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[addFriend]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[addFriend]', TlogType.Error);
    SQLComp.Free;
    Exit;
  end;

  try
    // Player.FriendList.Clear;

    SQLComp.SetQuery
      (format('INSERT INTO friend_list (owner_characterId, friend_characterId, registerDate, lastUpdateDate)'
      + ' VALUES (%d, %d, NOW(), NOW())', [Player.Character.Index,
      characterIndex]));

    // Player.PlayerSQL.AddParameter2('owner_characterId', Player.Character.Index);
    // Player.PlayerSQL.AddParameter2('friend_characterId', characterIndex);
    SQLComp.Run(False);

  except
    on E: Exception do
    begin
      Logger.Write('MYSQL error on adding friend to list. msg[' + E.Message +
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

function TEntityFriend.removeFriend(characterIndex: UInt64): Boolean;
var
  Player: PPlayer;
  OtherPlayer: WORD;
  OtherServer: Byte;
begin
  Result := False;

  Player := self.fPlayer;

  try
    if not(self.setDisableFriend(Player^.Character.Index, characterIndex)) or
      not(self.setDisableFriend(characterIndex, Player^.Character.Index)) then
      Exit;

    Player^.sendDeleteFriend(characterIndex);
    Player^.CloseFriendWindow(characterIndex);

    if self.getFriend(characterIndex, OtherPlayer, OtherServer) then
    begin
      with Servers[OtherServer].Players[OtherPlayer] do
      begin
        sendDeleteFriend(Player^.Character.Index);
        CloseFriendWindow(Player^.Character.Index);
        FriendList.Remove(Player^.Character.Index);
      end;
    end;

    Player^.FriendList.Remove(characterIndex);
  except
    on E: Exception do
    begin
      Logger.Write
        (format('Error on deleting friend. msg[%s : %s] clientId [%s] %s.',
        [E.Message, E.GetBaseException.Message,
        String(Player^.Character.Base.ClientId.ToString), DateTimeToStr(Now)]),
        TlogType.Error);
      Exit;
    end;
  end;

  Result := True;
end;

{$ENDREGION}
{$REGION 'get friend'}

function TEntityFriend.getFriend(const characterIndex: UInt64;
  out xPlayer: WORD; out xServer: Byte): Boolean;
var
  i: Byte;
  PlayerOut: TPlayer;
begin
  for i := Low(Servers) to High(Servers) do
  begin
    if Servers[i].GetPlayerByCharIndex(characterIndex, TPlayer(PlayerOut)) then
    begin
      xPlayer := PlayerOut.Base.ClientId; // tinha pointer()
      xServer := i;
      Exit(True);
    end;
  end;

  Result := False;
end;

{$ENDREGION}

end.
