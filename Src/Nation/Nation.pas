unit Nation;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Windows, SysUtils, DateUtils, StrUtils, Classes, MiscData, ServerSocket,
  Dialogs;
{$OLDTYPELAYOUT ON}

type
  TNationCerco = packed record
    Defensoras: TGuildsAlly;
    Atacantes: ARRAY [0 .. 3] OF TGuildsAlly;
  end;

type
  TNationData = packed record
    NationID: Integer;
    ChannelName: Array [0 .. 31] of AnsiChar;
    ChannelID: Byte;
    NationRank: Byte;
    MarechalGuildID: Integer;
    TacticianGuildID: Integer;
    JudgeGuildID: Integer;
    TreasurerGuildID: Integer;
    CitizenTax: WORD;
    VisitorTax: WORD;
    Settlement: Integer;
    NationIDAlly: Integer;
    MarechalAllyName: Array [0 .. 31] of AnsiChar;
    AllyDate: DWORD;
    NationGold: Int64;
    Cerco: TNationCerco;
    Server: PServerSocket;
  public
    procedure CreateNation(ChannelID: Byte);
    procedure LoadNation();
    procedure SaveNation();
    procedure SaveNationTaxes();
  end;
{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, Log, System.AnsiStrings, SQL, Functions;

procedure TNationData.CreateNation(ChannelID: Byte);
begin
  Self.ChannelID := ChannelID;
  Self.Server := @Servers[ChannelID];
end;

procedure TNationData.LoadNation;
var
  StringHelper: String;
  NationComp: TQuery;
  i: Integer;
  DevirId: Integer;
  Slot: Integer;
  TimeToEst, DateTimeValue: TDateTime;
  Zone: Integer;
begin
  NationComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  if not(NationComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[LoadNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[LoadNation]', TlogType.Error);
    NationComp.Destroy;
    Exit;
  end;
  try
    NationComp.SetQuery(format('SELECT * FROM nations WHERE channel_id=%d',
      [ChannelID]));
    NationComp.Run();
    if (NationComp.Query.RecordCount = 0) then
    begin
      Logger.Write('O servidor não encontrou o ChannelIndex ' +
        ChannelID.ToString + ' para carregar a nação do MySQL.',
        TlogType.Warnings);
      NationComp.Destroy;
      Exit;
    end;
    Self.NationID := NationComp.Query.FieldByName('nation_id').AsInteger;
    System.AnsiStrings.StrPLCopy(Self.ChannelName,
      AnsiString(NationComp.Query.FieldByName('nation_name').AsString), 32);
    Self.NationRank := NationComp.Query.FieldByName('nation_rank').AsInteger;
    Self.MarechalGuildID := NationComp.Query.FieldByName('guild_id_marshal')
      .AsInteger;
    Self.TacticianGuildID := NationComp.Query.FieldByName('guild_id_tactician')
      .AsInteger;
    Self.JudgeGuildID := NationComp.Query.FieldByName('guild_id_judge')
      .AsInteger;
    Self.TreasurerGuildID := NationComp.Query.FieldByName('guild_id_treasurer')
      .AsInteger;
    Self.CitizenTax := NationComp.Query.FieldByName('citizen_tax').AsInteger;
    Self.VisitorTax := NationComp.Query.FieldByName('visitor_tax').AsInteger;
    Self.Settlement := NationComp.Query.FieldByName('settlement').AsInteger;
    Self.NationIDAlly := NationComp.Query.FieldByName('nation_ally').AsInteger;
    System.AnsiStrings.StrPLCopy(Self.MarechalAllyName,
      AnsiString(NationComp.Query.FieldByName('marechal_ally').AsString), 32);
    Self.AllyDate := NationComp.Query.FieldByName('ally_date').AsInteger;
    Self.NationGold := NationComp.Query.FieldByName('nation_gold').AsInteger;

    { Zona E }
    if (Self.MarechalGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.MarechalGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.LordMarechal,
        AnsiString(StringHelper), 20);
    end;
    if (Self.TacticianGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.TacticianGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.Estrategista,
        AnsiString(StringHelper), 20);
    end;
    if (Self.JudgeGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.JudgeGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.Juiz,
        AnsiString(StringHelper), 20);
    end;
    if (Self.TreasurerGuildID > 0) then
    begin
      StringHelper := Server.GetGuildByIndex(Self.TreasurerGuildID);
      System.AnsiStrings.StrPLCopy(Self.Cerco.Defensoras.Tesoureiro,
        AnsiString(StringHelper), 20);
    end;

    { Zona A, B, C, D }
    for Zone := 1 to 4 do
    begin
      for i := 1 to 4 do
      begin
        var
        FieldName := format('cerco_guildid_attack_%s%d', [Chr(64 + Zone), i]);
        // 'A1', 'A2', 'B1', etc.
        if (NationComp.Query.FieldByName(FieldName).AsInteger > 0) then
        begin
          StringHelper := Server.GetGuildByIndex
            (NationComp.Query.FieldByName(FieldName).AsInteger);
          System.AnsiStrings.StrPLCopy(Self.Cerco.Atacantes[Zone - 1]
            .LordMarechal, AnsiString(StringHelper), 20);
        end;
      end;
    end;

    NationComp.SetQuery(format('SELECT * FROM devires WHERE nation_id=%d',
      [Self.NationID]));
    NationComp.Run();
    if not(NationComp.Query.RecordCount = 0) then
    begin
      NationComp.Query.First;
      while not NationComp.Query.Eof do
      begin
        DevirId := NationComp.Query.FieldByName('devir_id').AsInteger;
        if (Self.NationID > 1) then
          Slot := (DevirId - ((Self.NationID - 1) * 5))
        else
          Slot := DevirId;
        Slot := Slot - 1;

        Server.Devires[Slot].DevirId := DevirId;
        Server.Devires[Slot].NationID := Self.NationID;
        Server.Devires[Slot].IsOpen := False;
        Server.Devires[Slot].StonesDied := 0;
        Server.Devires[Slot].GuardsDied := 0;

        for i := 0 to 4 do
        begin
          Server.Devires[Slot].Slots[i].ItemID :=
            NationComp.Query.FieldByName(format('slot%d_itemid', [i + 1]))
            .AsInteger;
          Server.Devires[Slot].Slots[i].App := Server.Devires[Slot].Slots
            [i].ItemID;
          Server.Devires[Slot].Slots[i].IsAble :=
            Boolean(NationComp.Query.FieldByName(format('slot%d_able', [i + 1]))
            .AsInteger);

          DateTimeValue := EncodeDateTime(2001, 1, 1, 0, 0, 0, 0);
          if TFunctions.UNIXTimeToDateTimeFAST
            (NationComp.Query.FieldByName(format('slot%d_timecap', [i + 1]))
            .AsInteger) <> DateTimeValue then
          begin
            Server.ReliqEffect[ItemList[Server.Devires[Slot].Slots[i].ItemID].EF
              [0]] := Server.ReliqEffect
              [ItemList[Server.Devires[Slot].Slots[i].ItemID].EF[0]] +
              ItemList[Server.Devires[Slot].Slots[i].ItemID].EFV[0];

            Server.Devires[Slot].Slots[i].TimeCapped :=
              TFunctions.UNIXTimeToDateTimeFAST
              (NationComp.Query.FieldByName(format('slot%d_timecap', [i + 1]))
              .AsInteger);
            TimeToEst :=
              IncHour(TFunctions.UNIXTimeToDateTimeFAST
              (NationComp.Query.FieldByName(format('slot%d_timecap', [i + 1]))
              .AsInteger), RELIQ_EST_TIME);
            Server.Devires[Slot].Slots[i].TimeToEstabilish := TimeToEst;
          end;

          System.AnsiStrings.StrPLCopy(Server.Devires[Slot].Slots[i].NameCapped,
            NationComp.Query.FieldByName(format('slot%d_name', [i + 1]))
            .AsString, 16);
        end;

        NationComp.Query.Next;
      end;
    end;
    Logger.Write('Nation ' + String(Self.ChannelName) + ' loaded.',
      TlogType.ServerStatus);

  except
    on E: Exception do
    begin
      Logger.Write('Nation Load Error: ' + E.Message, TlogType.Warnings);
    end;
  end;
  NationComp.Destroy;
end;

procedure TNationData.SaveNation();
var
  NationComp: TQuery;
  cerco_guildid_attack_A1, cerco_guildid_attack_A2, cerco_guildid_attack_A3,
    cerco_guildid_attack_A4, cerco_guildid_attack_B1, cerco_guildid_attack_B2,
    cerco_guildid_attack_B3, cerco_guildid_attack_B4, cerco_guildid_attack_C1,
    cerco_guildid_attack_C2, cerco_guildid_attack_C3, cerco_guildid_attack_C4,
    cerco_guildid_attack_D1, cerco_guildid_attack_D2, cerco_guildid_attack_D3,
    cerco_guildid_attack_D4: Integer;
  i, j: Integer;
begin
  if (Self.NationID = 0) then
    Exit;
  NationComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE), True);
  if not(NationComp.Query.Connection.Connected) then
  begin
    Logger.Write('Falha de conexão individual com mysql.[SaveNation]',
      TlogType.Warnings);
    Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveNation]', TlogType.Error);
    NationComp.Destroy;
    Exit;
  end;

  cerco_guildid_attack_A1 := 0;
  cerco_guildid_attack_A2 := 0;
  cerco_guildid_attack_A3 := 0;
  cerco_guildid_attack_A4 := 0;
  cerco_guildid_attack_B1 := 0;
  cerco_guildid_attack_B2 := 0;
  cerco_guildid_attack_B3 := 0;
  cerco_guildid_attack_B4 := 0;
  cerco_guildid_attack_C1 := 0;
  cerco_guildid_attack_C2 := 0;
  cerco_guildid_attack_C3 := 0;
  cerco_guildid_attack_C4 := 0;
  cerco_guildid_attack_D1 := 0;
  cerco_guildid_attack_D2 := 0;
  cerco_guildid_attack_D3 := 0;
  cerco_guildid_attack_D4 := 0;

  for i := 0 to 3 do
    for j := 0 to 3 do
      if (String(Self.Cerco.Atacantes[i].LordMarechal) <> '') then
      begin
        case j of
          0:
            cerco_guildid_attack_A1 :=
              Server.GetGuildByName
              (String(Self.Cerco.Atacantes[i].LordMarechal));
          1:
            cerco_guildid_attack_A2 :=
              Server.GetGuildByName
              (String(Self.Cerco.Atacantes[i].Estrategista));
          2:
            cerco_guildid_attack_A3 :=
              Server.GetGuildByName(String(Self.Cerco.Atacantes[i].Juiz));
          3:
            cerco_guildid_attack_A4 :=
              Server.GetGuildByName(String(Self.Cerco.Atacantes[i].Tesoureiro));
        end;
      end;

  NationComp.Query.Connection.StartTransaction;
  try
    NationComp.SetQuery('UPDATE nations SET nation_rank=' +
      Self.NationRank.ToString + ', guild_id_marshal=' +
      Self.MarechalGuildID.ToString + ',' + ' guild_id_tactician=' +
      Self.TacticianGuildID.ToString + ', guild_id_judge=' +
      Self.JudgeGuildID.ToString + ',' + ' guild_id_treasurer=' +
      Self.TreasurerGuildID.ToString + ', citizen_tax=' +
      Self.CitizenTax.ToString + ',' + ' visitor_tax=' +
      Self.VisitorTax.ToString + ', nation_ally=' + Self.NationIDAlly.ToString +
      ', marechal_ally="' + String(Self.MarechalAllyName) + '",' + ' ally_date='
      + Self.AllyDate.ToString + ', nation_gold=' + Self.NationGold.ToString +
      ', cerco_guildid_attack_A1=' + cerco_guildid_attack_A1.ToString + ',' +
      ' cerco_guildid_attack_A2=' + cerco_guildid_attack_A2.ToString +
      ', cerco_guildid_attack_A3=' + cerco_guildid_attack_A3.ToString + ',' +
      ' cerco_guildid_attack_A4=' + cerco_guildid_attack_A4.ToString +
      ', cerco_guildid_attack_B1=' + cerco_guildid_attack_B1.ToString + ',' +
      ' cerco_guildid_attack_B2=' + cerco_guildid_attack_B2.ToString +
      ', cerco_guildid_attack_B3=' + cerco_guildid_attack_B3.ToString + ',' +
      ' cerco_guildid_attack_B4=' + cerco_guildid_attack_B4.ToString +
      ', cerco_guildid_attack_C1=' + cerco_guildid_attack_C1.ToString + ',' +
      ' cerco_guildid_attack_C2=' + cerco_guildid_attack_C2.ToString +
      ', cerco_guildid_attack_C3=' + cerco_guildid_attack_C3.ToString + ',' +
      ' cerco_guildid_attack_C4=' + cerco_guildid_attack_C4.ToString +
      ', cerco_guildid_attack_D1=' + cerco_guildid_attack_D1.ToString + ',' +
      ' cerco_guildid_attack_D2=' + cerco_guildid_attack_D2.ToString +
      ', cerco_guildid_attack_D3=' + cerco_guildid_attack_D3.ToString + ',' +
      ' cerco_guildid_attack_D4=' + cerco_guildid_attack_D4.ToString +
      ' WHERE nation_id=' + Self.NationID.ToString + ';');
    NationComp.Run(False);

    NationComp.Query.Connection.Commit;
  except
    on E: Exception do
    begin
      NationComp.Query.Connection.Rollback;
      Logger.Write('Error while saving nation: ' + String(Self.ChannelName) +
        ' ' + E.Message, TlogType.Error);
    end;
  end;
  NationComp.Destroy;
end;

procedure TNationData.SaveNationTaxes();
var
  NationComp: TQuery;
begin
  NationComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));

  try
    if not NationComp.Query.Connection.Connected then
    begin
      Logger.Write('Falha de conexão individual com mysql.[SaveNation]',
        TlogType.Warnings);
      Logger.Write('PERSONAL MYSQL FAILED LOAD.[SaveNation]', TlogType.Error);
      Exit;
    end;

    NationComp.SetQuery
      (format('UPDATE nations SET citizen_tax=%d, visitor_tax=%d,' +
      ' nation_gold=%d WHERE nation_id=%d', [Self.CitizenTax, Self.VisitorTax,
      Self.NationGold, Self.NationID]));

    NationComp.Run(False);

  except
    on E: Exception do
      Logger.Write('Error while saving nation_taxes: ' +
        String(Self.ChannelName) + ' ' + E.Message, TlogType.Error);
  end;

  NationComp.Destroy;
end;

end.
