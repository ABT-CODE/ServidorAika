program AikaServer;
{$APPTYPE CONSOLE}
{$R *.res}
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}

// Ativa otimização de loops
uses
  System.SysUtils,
  Vcl.Forms,
  DateUtils,
  Windows,
  StrUtils,
  Winsock2,
  Log in 'Src\Functions\Log.pas',
  GlobalDefs in 'Src\Data\GlobalDefs.pas',
  ServerSocket in 'Src\Connections\ServerSocket.pas',
  Load in 'Src\Functions\Load.pas',
  NPC in 'Src\Mob\NPC.pas',
  BaseMob in 'Src\Mob\BaseMob.pas',
  BaseNpc in 'Src\Mob\BaseNpc.pas',
  Player in 'Src\Mob\Player.pas',
  Util in 'Src\Functions\Util.pas',
  Functions in 'Src\Functions\Functions.pas',
  ItemFunctions in 'Src\Functions\ItemFunctions.pas',
  SkillFunctions in 'Src\Functions\SkillFunctions.pas',
  ConnectionsThread in 'Src\Threads\ConnectionsThread.pas',
  PlayerThread in 'Src\Threads\PlayerThread.pas',
  UpdateThreads in 'Src\Threads\UpdateThreads.pas',
  FilesData in 'Src\Data\FilesData.pas',
  MiscData in 'Src\Data\MiscData.pas',
  Packets in 'Src\Data\Packets.pas',
  PlayerData in 'Src\Data\PlayerData.pas',
  PartyData in 'Src\Party\PartyData.pas',
  CharacterMail in 'Src\Mail\CharacterMail.pas',
  MailFunctions in 'Src\Mail\MailFunctions.pas',
  EncDec in 'Src\Connections\EncDec.pas',
  NPCHandlers in 'Src\PacketHandlers\NPCHandlers.pas',
  PacketHandlers in 'Src\PacketHandlers\PacketHandlers.pas',
  LoginSocket in 'Src\Connections\LoginSocket.pas',
  AuthHandlers in 'Src\PacketHandlers\AuthHandlers.pas',
  TokenSocket in 'Src\Connections\TokenSocket.pas',
  CommandHandlers in 'Src\PacketHandlers\CommandHandlers.pas',
  GuildData in 'Src\Guild\GuildData.pas',
  SQL in 'Src\Connections\SQL.pas',
  MOB in 'Src\Mob\MOB.pas',
  PET in 'Src\Mob\PET.pas',
  R_Paneil in 'Src\Functions\R_Paneil.pas',
  EntityMail in 'Src\Data\Entity\EntityMail.pas',
  EntityFriend in 'Src\Data\Entity\EntityFriend.pas',
  SendPacketForm in 'Src\Forms\SendPacketForm.pas' {frmSendPacket},
  Dungeon in 'Src\Dungeons\Dungeon.pas',
  Nation in 'Src\Nation\Nation.pas',
  PingBackForm in 'Src\Forms\PingBackForm.pas' {frmPingback},
  AuctionFunctions in 'Src\Auction\AuctionFunctions.pas',
  Objects in 'Src\Mob\Objects.pas',
  CastleSiege in 'Src\Nation\CastleSiege.pas',
  AccCreateForm in 'Src\Forms\AccCreateForm.pas' {frmAccCreat};

function ConsoleHandler(dwCtrlType: DWORD): BOOL; stdcall;
var
  i: BYTE;
begin
  Result := False;
  if (dwCtrlType = CTRL_CLOSE_EVENT) or (dwCtrlType = CTRL_LOGOFF_EVENT) or
    (dwCtrlType = CTRL_SHUTDOWN_EVENT) then
  begin
    if not(ServerHasClosed) then
    begin
      TFunctions.SaveGuilds;
      for i := Low(Nations) to High(Nations) do
      begin
        Nations[i].SaveNation;
      end;
      for i := Low(Servers) to High(Servers) do
      begin
        Servers[i].CloseServer;
      end;
      Logger.Write('Server Closed Succesfully!', TLogType.ServerStatus);
    end;
    Result := True;
  end;
end;

var
  InputStr: string;
  Uptime: TDateTime;
  timeinit: Integer;
  CreateSendPacketForm: Boolean = True;
  i, j: Integer;
  cmdto: String;

begin
  Logger := TLog.Create;
  SetConsoleTitleA('Aika Server');
  Logger.Write(HourOf(StrToDateTime('29/11/2022 23:58:33')).ToString,
    TLogType.Packets);

  try

    Uptime := Now;
    WebServerClosed := False;
    xServerClosed := False;
    TLoad.InitCharacters;
    TLoad.InitItemList;
    TLoad.InitSkillData;
    TLoad.InitSetItem;
    TLoad.InitConjunts;
    TLoad.InitReinforce;
    TLoad.InitPremiumItems;
    TLoad.InitExpList;
    TLoad.InitPranExpList;
    TLoad.InitServerConf;
    TLoad.InitServerList;
    TLoad.LoadNPCOptions;
    TLoad.InitMapsData;
    TLoad.InitScrollPositions;
    TLoad.InitQuestList;
    TLoad.InitQuests;
    TLoad.InitTitles;
    TLoad.InitDropList;
    TLoad.InitRecipes;
    TLoad.InitMakeItems;
    Logger.Space; { Space }
    TLoad.InitServers; { Channels Load }
    Logger.Space; { Space }
    TLoad.InitAuthServer;
    Logger.Space; { Space }
    TLoad.InitNPCS;
    TLoad.InitGuilds;
    // TLoad.SaveMapsDataFromCSV;

    // MANTIDO EXATAMENTE COMO ESTAVA NO ORIGINAL
    for i := Low(Servers) to High(Servers) do
    begin
      Servers[i].ServerHasClosed := False;
      Servers[i].StartThreads;
      // Ajuste para garantir a carga correta das nações
      if (i <= 100) then
      // Garante que estamos dentro do limite de nações existentes
      begin
        Nations[Servers[i].NationID - 1].CreateNation(Servers[i].ChannelID);
        Nations[Servers[i].NationID - 1].LoadNation();
        Servers[i].UpdateReliquareEffects();
      end
      else
      begin
        Logger.Write('Erro: Tentativa de carregar uma nação inexistente.',
          TLogType.Warnings);
      end;
    end;

    // TAuctionOffersThread.Create(60000);
    timeinit := MilliSecondsBetween(Now, Uptime);
    Logger.Write('Servidor levou ' + IntToStr(Round(timeinit / 1000)) +
      ' segundos para carregar completamente.', TLogType.ServerStatus);
    Logger.Space;
    ReportMemoryLeaksOnShutdown := True;
    SetConsoleCtrlHandler(@ConsoleHandler, True);

    // CORREÇÃO 1: Comentado pois bloqueia o while(True)
    {
    if CreateSendPacketForm then
    begin
       Application.Initialize;
      // Application.CreateForm(TfrmSendPacket, frmSendPacket);
      // Application.CreateForm(TfrmPingback, frmPingback);
      // frmPingback.Show; // ou frmPingback.ShowModal
      Application.CreateForm(TfrmAccCreat, frmAccCreat);
      frmAccCreat.Show;
      Application.Run;
    end;
    }

    while (True) do
    begin

      ReadLn(cmdto);

      case AnsiIndexStr(cmdto, ['close', 'savecsvmob', 'reloadskill',
        'reloaditem', 'reloadserverconf', 'reloadmobs', 'reloaddrops',
        'reloadpremiumshop', 'reloadquestsserver', 'reloadquestclient',
        'reloadtitles', 'reloadrecipes', 'reloadmakeitem']) of
        0:
          begin
            for i := Low(Servers) to High(Servers) do
            begin
              closesocket(Servers[i].Sock);
              Servers[i].Sock := INVALID_SOCKET;
            end;
            ServerHasClosed := True;
            Logger.Write('Fechando o servidor, aguarde...',
              TLogType.ConnectionsTraffic);

            TFunctions.SaveGuilds;

            Logger.Write('GUILDAS SALVAS..', TLogType.ConnectionsTraffic);

            // CORREÇÃO 2: Try-except corrigido
            for i := Low(Nations) to High(Nations) do
            begin
              try
                Nations[i].SaveNation;
              except
                on E: Exception do
                  Logger.Write('Erro ao salvar nação: ' + E.Message,
                    TLogType.Warnings);
              end;
            end;

            Logger.Write('NAÇÕES SALVAS..', TLogType.ConnectionsTraffic);

            for i := Low(Servers) to High(Servers) do
            begin
              closesocket(Servers[i].Sock);
              Servers[i].Sock := INVALID_SOCKET;
            end;

            Logger.Write('SOCKETS FECHADOS..', TLogType.ConnectionsTraffic);

            for i := Low(Servers) to High(Servers) do
            begin
              Servers[i].ServerHasClosed := True;
              Sleep(1000);
              Servers[i].CloseServer;
              Sleep(1000);
              for j := 1 to MAX_CONNECTIONS do
              begin
                if (Servers[i].Players[j].Status >= TPlayerStatus.CharList) then
                  Servers[i].Disconnect(Servers[i].Players[j]);
              end;
            end;

            xServerClosed := True;
            Logger.Write('Server Closed Succesfully!', TLogType.ServerStatus);
            Logger.Write('Feche a janela deste console. Tudo foi salvo!',
              TLogType.ConnectionsTraffic);

            // CORREÇÃO 3: Adiciona Break para sair do loop
            Break;
          end;

        1:
          begin

          end;

        2:
          begin
            ZeroMemory(@SkillData, sizeof(SkillData));
            TLoad.InitSkillData;
          end;
        3:
          begin
            ZeroMemory(@ItemList, sizeof(ItemList));
            TLoad.InitItemList;
          end;
        4: // reloadserverconf
          begin
            TLoad.InitServerConf;
          end;
        5: // reloadmobs
          begin
            for i := Low(Servers) to High(Servers) do
            begin
              Servers[i].StartMobs;
            end;
          end;

        6: // reloaddrops
          begin
            TLoad.InitDropList;
          end;
        7: // reloadpremiumshop
          begin
            TLoad.InitPremiumItems;
          end;
        8: // reloadquestsserver
          begin
            TLoad.InitQuests;
          end;
        9: // reloadquestclient
          begin
            TLoad.InitQuestList;
          end;
        10: // reloadtitles
          begin
            TLoad.InitTitles;
          end;
        11: // reloadrecipes
          begin
            TLoad.InitRecipes;
          end;
        12: // reloadmakeitems
          begin
            TLoad.InitMakeItems;
          end;
      else
        begin
          for i := Low(Servers) to High(Servers) do
          begin
            Servers[i].SendServerMsg(AnsiString('[SERVER] ' + cmdto), 32, 16);
          end;
        end;
      end;
    end;

    // CORREÇÃO 4: Código duplicado removido (nunca seria executado)
    {
     if (CreateSendPacketForm) then
      begin
      Application.Initialize;
      //Application.CreateForm(TfrmSendPacket, frmSendPacket);
      // Application.CreateForm(TfrmPingback, frmPingback);
      Application.CreateForm(TfrmAccCreat, frmAccCreat);
      Application.Run;
      end;
    }
  except
    on E: Exception do
    begin
      Logger.Write(E.ClassName + ': ' + E.Message, TLogType.error);
      ReadLn(InputStr);
    end;
  end;

end.
