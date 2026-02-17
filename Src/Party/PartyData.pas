unit PartyData;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Windows, Generics.Collections;
{$OLDTYPELAYOUT ON}
{$REGION 'Party (Grupo) Data'}

type
  TCharName = record
    Name: String;
  end;

type
  PParty = ^TParty;

  TParty = record
    Index: byte;
    Leader: byte;
    Members: TList<byte>;
    MemberName: TList<byte>;
    RequestId: byte;
    ChannelId: byte;
    ExpAlocate: byte;
    ItemAlocate: byte;
    LastSlotItemReceived: byte;
    DungeonLobbyConfirm: Array of WORD;
    { Raid Misc }
    InRaid: Boolean;
    IsRaidLeader: Boolean;
    RaidPartyId: byte;
    PartyAllied: Array [1 .. 3] of WORD;
    PartyRaidCount: byte;
  public
    function AddMember(memberClientId: WORD): Boolean;
    procedure RemoveMember(memberClientId: WORD);
    procedure DestroyParty(ClientId: WORD);
    function GetFreeRaidSpace(): byte;
    procedure RefreshParty;
    procedure RefreshRaid;
    class function CreateParty(ClientId: WORD; ChannelId: byte): Boolean;
      overload; static;
    class function CreateRaid(RequesterID, AcceptID: WORD; ChannelId: byte)
      : Boolean; overload; static;
    class function AddPartyToRaid(RequesterID, AcceptID: WORD; ChannelId: byte)
      : Boolean; overload; static;
    procedure SendToParty(var Packet; size: WORD);
    procedure SendToRaid(var Packet; size: WORD);
  end;
{$ENDREGION}
{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, Log, SysUtils, Packets;
{$REGION 'Party (Grupo) Data'}

function TParty.AddMember(memberClientId: WORD): Boolean;
begin
  Result := False;
  if not(Servers[ChannelId].Players[memberClientId].Base.IsActive) or
    (Self.Members.Count = 6) then
    Exit;
  Self.Members.Add(memberClientId);
  Servers[ChannelId].Players[memberClientId].Party := @Servers[ChannelId]
    .Parties[Self.Index];
  Servers[ChannelId].Players[memberClientId].Base.PartyId := Self.Index;
  Servers[ChannelId].Players[memberClientId].PartyIndex := Self.Index;
  Result := True;
  Self.RefreshParty;
end;

procedure TParty.RemoveMember(memberClientId: WORD);
begin
  try
    if Assigned(Self.Members) and Self.Members.Contains(memberClientId) then
    begin
      if Self.Members.Count <= 2 then
      begin
        Self.DestroyParty(Self.Leader);
        Exit;
      end;

      Self.Members.Remove(memberClientId);
      if Self.Members.Contains(memberClientId) then
      begin
        Servers[ChannelId].Players[memberClientId].PartyIndex := 0;
        Servers[ChannelId].Players[memberClientId].RefreshParty;
      end;

      if Self.Leader = memberClientId then
      begin
        if Assigned(Self.Members) and (Self.Members.Count > 0) then
        begin
          Self.Leader := Self.Members.First;
          if Self.Members.Count < 2 then
          begin
            Self.DestroyParty(Self.Leader);
            Exit;
          end;
        end;
      end;
    end;
    Self.RefreshParty;
  except
    on E: Exception do
    begin
      Self.DestroyParty(Self.Leader);
      Logger.Write('Erro ao remover membro da party [' + E.Message + ']',
        TLogType.Error);
    end;
  end;
end;

procedure TParty.DestroyParty(ClientId: WORD);
var
  i, j: WORD;
begin
  if ClientId = Self.Leader then
  begin
    for i in Self.Members do
    begin
      Servers[ChannelId].Players[i].PartyIndex := 0;
      Servers[ChannelId].Players[i].Base.PartyId := 0;
      Servers[ChannelId].Players[i].RefreshParty;
    end;
    Self.Members.Clear;
    Self.MemberName.Clear;
    Self.InRaid := False;
    Self.IsRaidLeader := False;
    Self.RaidPartyId := 0;
    for i := 1 to 3 do
    begin
      if Self.PartyAllied[i] = 0 then
        Continue;
      for j := 1 to 3 do
      begin
        if Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].PartyAllied[j] = 0
        then
          Continue;
        if Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].PartyAllied[j]
          = Self.Index then
          Servers[Self.ChannelId].Parties[Self.PartyAllied[i]]
            .PartyAllied[j] := 0;
      end;
      Dec(Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].PartyRaidCount);
      Servers[Self.ChannelId].Parties[Self.PartyAllied[i]].RefreshRaid;
    end;
    ZeroMemory(@Self.PartyAllied, sizeof(Self.PartyAllied));
    Self.PartyRaidCount := 0;
  end;
end;

function TParty.GetFreeRaidSpace(): byte;
var
  i: byte;
begin
  Result := 255;
  for i := 1 to 3 do
  begin
    if Self.PartyAllied[i] = 0 then
    begin
      Result := i;
      Break;
    end;
  end;
end;

procedure TParty.RefreshParty;
var
  i, j, k, m, n: WORD;
begin
  if not Self.InRaid then
  begin
    for i in Self.Members do
    begin
      Servers[ChannelId].Players[i].RefreshParty;
      for k in Self.Members do
      begin
        if k = i then
          Continue;
        Servers[ChannelId].Players[i].SendPositionParty(k);
      end;
    end;
  end
  else
  begin
    for i in Self.Members do
    begin
      Servers[ChannelId].Players[i].RefreshParty;
      for k in Self.Members do
      begin
        if k = i then
          Continue;
        Servers[ChannelId].Players[i].SendPositionParty(k);
      end;
    end;
    for j := 1 to 3 do
    begin
      if Self.PartyAllied[j] = 0 then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
      begin
        Servers[ChannelId].Players[i].RefreshParty;
        for k in Self.Members do
        begin
          if k = i then
            Continue;
          Servers[ChannelId].Players[i].SendPositionParty(k);
        end;
        for m := 1 to 3 do
        begin
          if m = j then
            Continue;
          if Self.PartyAllied[m] = 0 then
            Continue;
          for n in Servers[Self.ChannelId].Parties[Self.PartyAllied[m]]
            .Members do
          begin
            Servers[ChannelId].Players[i].SendPositionParty(n);
          end;
        end;
      end;
    end;
  end;
end;

procedure TParty.RefreshRaid;
var
  i, j, k, m, n: WORD;
begin
  if Self.InRaid then
  begin
    for i in Self.Members do
    begin
      Servers[ChannelId].Players[i].RefreshParty;
      for k in Self.Members do
      begin
        if k = i then
          Continue;
        Servers[ChannelId].Players[i].SendPositionParty(k);
      end;
    end;
    for j := 1 to 3 do
    begin
      if Self.PartyAllied[j] = 0 then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
      begin
        Servers[ChannelId].Players[i].RefreshParty;
        for k in Self.Members do
        begin
          if k = i then
            Continue;
          Servers[ChannelId].Players[i].SendPositionParty(k);
        end;
        for m := 1 to 3 do
        begin
          if m = j then
            Continue;
          if Self.PartyAllied[m] = 0 then
            Continue;
          for n in Servers[Self.ChannelId].Parties[Self.PartyAllied[m]]
            .Members do
          begin
            Servers[ChannelId].Players[i].SendPositionParty(n);
          end;
        end;
      end;
    end;
  end;
end;

class function TParty.CreateParty(ClientId: WORD; ChannelId: byte): Boolean;
var
  i: Integer;
  Party: PParty;
begin
  Result := False;
  for i := 1 to Length(Servers[ChannelId].Parties) do
    if Servers[ChannelId].Parties[i].Members.Count = 0 then
    begin
      Party := @Servers[ChannelId].Parties[i];
      Party.Leader := ClientId;
      Party.Members.Add(ClientId);
      Party.LastSlotItemReceived := 0;
      Party.ExpAlocate := 1;
      Party.ItemAlocate := 1;
      Party.IsRaidLeader := True;
      Party.RaidPartyId := 1;
      Party.InRaid := False;
      Party.PartyRaidCount := 1;
      Result := True;
      Servers[ChannelId].Players[ClientId].Party := @Servers[ChannelId]
        .Parties[i];
      Servers[ChannelId].Players[ClientId].Base.PartyId := Party.Index;
      Servers[ChannelId].Players[ClientId].PartyIndex := Party.Index;
      Break;
    end;
end;

class function TParty.CreateRaid(RequesterID, AcceptID: WORD;
  ChannelId: byte): Boolean;
begin
  Result := False;
  if (Servers[ChannelId].Players[RequesterID].PartyIndex = 0) or
    (Servers[ChannelId].Players[AcceptID].PartyIndex = 0) or
    (Servers[ChannelId].Players[RequesterID].Party.InRaid) or
    (Servers[ChannelId].Players[AcceptID].Party.InRaid) then
    Exit;
  Servers[ChannelId].Players[RequesterID].Party.InRaid := True;
  Servers[ChannelId].Players[AcceptID].Party.InRaid := True;
  Servers[ChannelId].Players[RequesterID].Party.IsRaidLeader := True;
  Servers[ChannelId].Players[AcceptID].Party.IsRaidLeader := False;
  Servers[ChannelId].Players[RequesterID].Party.RaidPartyId := 1;
  Servers[ChannelId].Players[AcceptID].Party.RaidPartyId := 2;
  Servers[ChannelId].Players[AcceptID].Party.ExpAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ExpAlocate;
  Servers[ChannelId].Players[AcceptID].Party.ItemAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ItemAlocate;
  Servers[ChannelId].Players[RequesterID].Party.PartyAllied[1] :=
    Servers[ChannelId].Players[AcceptID].Party.Index;
  Servers[ChannelId].Players[AcceptID].Party.PartyAllied[1] :=
    Servers[ChannelId].Players[RequesterID].Party.Index;
  Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount := 2;
  Servers[ChannelId].Players[AcceptID].Party.PartyRaidCount := 2;
  Servers[ChannelId].Players[RequesterID].Party.RefreshRaid;
  Result := True;
end;

class function TParty.AddPartyToRaid(RequesterID, AcceptID: WORD;
  ChannelId: byte): Boolean;
var
  FreeSlot, FreeSlot2, i, j: byte;
begin
  Result := False;
  if (Servers[ChannelId].Players[RequesterID].PartyIndex = 0) or
    (Servers[ChannelId].Players[AcceptID].PartyIndex = 0) or
    not(Servers[ChannelId].Players[RequesterID].Party.InRaid) or
    (Servers[ChannelId].Players[AcceptID].Party.InRaid) or
    (Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount >= 4) then
    Exit;
  FreeSlot := Servers[ChannelId].Players[RequesterID].Party.GetFreeRaidSpace;
  if FreeSlot = 255 then
    Exit;
  Servers[ChannelId].Players[RequesterID].Party.PartyAllied[FreeSlot] :=
    Servers[ChannelId].Players[AcceptID].Party.Index;
  Servers[ChannelId].Players[AcceptID].Party.PartyAllied[1] :=
    Servers[ChannelId].Players[RequesterID].Party.Index;
  Inc(Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount);
  Servers[ChannelId].Players[AcceptID].Party.PartyRaidCount :=
    Servers[ChannelId].Players[RequesterID].Party.PartyRaidCount;
  j := 2;
  for i := 1 to 3 do
  begin
    if (Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i] = 0) or
      (Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i] = Servers
      [ChannelId].Players[AcceptID].Party.Index) then
      Continue;
    Servers[ChannelId].Parties[Servers[ChannelId].Players[RequesterID]
      .Party.PartyAllied[i]].PartyRaidCount := Servers[ChannelId].Players
      [RequesterID].Party.PartyRaidCount;
    Servers[ChannelId].Players[AcceptID].Party.PartyAllied[j] :=
      Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i];
    Inc(j);
    FreeSlot2 := Servers[ChannelId].Parties
      [Servers[ChannelId].Players[RequesterID].Party.PartyAllied[i]]
      .GetFreeRaidSpace;
    Servers[ChannelId].Parties[Servers[ChannelId].Players[RequesterID]
      .Party.PartyAllied[i]].PartyAllied[FreeSlot2] := Servers[ChannelId]
      .Players[AcceptID].Party.Index;
  end;
  Servers[ChannelId].Players[AcceptID].Party.InRaid := True;
  Servers[ChannelId].Players[AcceptID].Party.IsRaidLeader := False;
  Servers[ChannelId].Players[AcceptID].Party.RaidPartyId := FreeSlot;
  Servers[ChannelId].Players[AcceptID].Party.ExpAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ExpAlocate;
  Servers[ChannelId].Players[AcceptID].Party.ItemAlocate :=
    Servers[ChannelId].Players[RequesterID].Party.ItemAlocate;
  Servers[ChannelId].Players[RequesterID].Party.RefreshRaid;
  Result := True;
end;

procedure TParty.SendToParty(var Packet; size: WORD);
var
  i, j: WORD;
begin
  if not Self.InRaid then
  begin
    for i in Self.Members do
      Servers[ChannelId].Players[i].SendPacket(Packet, size);
  end
  else
  begin
    for i in Self.Members do
      Servers[ChannelId].Players[i].SendPacket(Packet, size);
    for j := 1 to 3 do
    begin
      if Self.PartyAllied[j] = 0 then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
        Servers[ChannelId].Players[i].SendPacket(Packet, size);
    end;
  end;
end;

procedure TParty.SendToRaid(var Packet; size: WORD);
var
  i, j: WORD;
begin
  if Self.InRaid then
  begin
    for i in Self.Members do
      Servers[ChannelId].Players[i].SendPacket(Packet, size);
    for j := 1 to 3 do
    begin
      if Self.PartyAllied[j] = 0 then
        Continue;
      for i in Servers[Self.ChannelId].Parties[Self.PartyAllied[j]].Members do
        Servers[ChannelId].Players[i].SendPacket(Packet, size);
    end;
  end;
end;

end.
