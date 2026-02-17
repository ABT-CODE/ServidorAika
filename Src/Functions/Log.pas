unit Log;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses Windows, System.SysUtils;

type
        TLogType = (Packets, ConnectionsTraffic, Warnings, ServerStatus, Error,
          Painel, Hack, Itens);

type
        TLogType1 = (Itens_Querie, Principal);

type
        TLog = class(TObject)
        public
                procedure Write(str: string; logType: TLogType); overload;
                procedure Querie(Querie: string; nick: string;
                  logType: TLogType1); overload;
                // procedure Write(obj: TObject; logType: TLogType); overload;
                procedure Space;
        end;

Procedure LogTxt(str: String);
procedure LogQuerie(str: String; nick: string);

implementation

{ TLog }

procedure LogTxt(str: String);
var
        NomeDoLog: string;
        Arquivo: TextFile;
begin
        NomeDoLog := GetCurrentDir + '\Logs\StatusLog.txt';

        if not(DirectoryExists(GetCurrentDir + '\Logs')) then
                ForceDirectories(GetCurrentDir + '\Logs');

        AssignFile(Arquivo, NomeDoLog);
        if FileExists(NomeDoLog) then
                Append(Arquivo)
                { se existir, apenas adiciona linhas }
        else
                ReWrite(Arquivo);
        { cria um novo se não existir }
        try
                Writeln(Arquivo, str);
                Writeln(Arquivo,
                  '-------------------------------------------------------------------------------');
        finally
                CloseFile(Arquivo)
        end;
end;

procedure LogQuerie(str: String; nick: string);
var
        NomeDoLog: string;
        Arquivo: TextFile;
begin
        NomeDoLog := GetCurrentDir + '\Queries\fail.txt';

        if not(DirectoryExists(GetCurrentDir + '\Logs')) then
                ForceDirectories(GetCurrentDir + '\Logs');

        AssignFile(Arquivo, NomeDoLog);
        if FileExists(NomeDoLog) then
                Append(Arquivo)
                { se existir, apenas adiciona linhas }
        else
                ReWrite(Arquivo);
        { cria um novo se não existir }
        try
                Writeln(Arquivo, str);
                Writeln(Arquivo,
                  '-------------------------------------------------------------------------------');
        finally
                CloseFile(Arquivo)
        end;
end;

procedure LogItens(str: String);
var
        NomeDoLog: string;
        Arquivo: TextFile;
        DataAtual: TDateTime;
begin
        // Obtém a data atual
        DataAtual := Now;

        // Formata o nome do arquivo com a data (dia-mês-ano)
        NomeDoLog := GetCurrentDir + '\Logs\Itens-' +
          FormatDateTime('dd-mm-yyyy', DataAtual) + '.txt';

        // Verifica se o diretório de logs existe, caso não, cria
        if not(DirectoryExists(GetCurrentDir + '\Logs')) then
                ForceDirectories(GetCurrentDir + '\Logs');

        // Atribui o arquivo de log
        AssignFile(Arquivo, NomeDoLog);

        // Se o arquivo existe, abre para anexar conteúdo, se não, cria um novo arquivo
        if FileExists(NomeDoLog) then
                Append(Arquivo) // Se o arquivo existe, apenas adiciona linhas
        else
                ReWrite(Arquivo); // Se não, cria um novo arquivo

        try
                // Escreve a string no arquivo e adiciona uma linha de separação
                Writeln(Arquivo, str);
                Writeln(Arquivo,
                  '-------------------------------------------------------------------------------');
        finally
                // Fecha o arquivo após escrever
                CloseFile(Arquivo);
        end;
end;

procedure LogError(str: String);
var
        NomeDoLog: string;
        Arquivo: TextFile;
begin
        NomeDoLog := GetCurrentDir + '\Logs\ErrorLog.txt';

        if not(DirectoryExists(GetCurrentDir + '\Logs')) then
                ForceDirectories(GetCurrentDir + '\Logs');

        AssignFile(Arquivo, NomeDoLog);
        if FileExists(NomeDoLog) then
                Append(Arquivo)
                { se existir, apenas adiciona linhas }
        else
                ReWrite(Arquivo);
        { cria um novo se não existir }
        try
                Writeln(Arquivo, str);
                Writeln(Arquivo,
                  '-------------------------------------------------------------------------------');
        finally
                CloseFile(Arquivo)
        end;
end;

procedure LogPainel(str: String);
var
        NomeDoLog: string;
        Arquivo: TextFile;
begin
        NomeDoLog := GetCurrentDir + '\Logs\PainelLog.txt';

        if not(DirectoryExists(GetCurrentDir + '\Logs')) then
                ForceDirectories(GetCurrentDir + '\Logs');

        AssignFile(Arquivo, NomeDoLog);
        if FileExists(NomeDoLog) then
                Append(Arquivo)
                { se existir, apenas adiciona linhas }
        else
                ReWrite(Arquivo);
        { cria um novo se não existir }
        try
                Writeln(Arquivo, str);
                Writeln(Arquivo,
                  '-------------------------------------------------------------------------------');
        finally
                CloseFile(Arquivo)
        end;
end;

procedure TLog.Write(str: string; logType: TLogType);
begin
        case logType of
                Packets:
                        begin
                                Writeln(str);
                        end;

                ConnectionsTraffic:
                        begin
                                SetConsoleTextAttribute
                                  (GetStdHandle(STD_OUTPUT_HANDLE),
                                  FOREGROUND_GREEN OR FOREGROUND_INTENSITY);
                                Writeln(str);
                                SetConsoleTextAttribute
                                  (GetStdHandle(STD_OUTPUT_HANDLE),
                                  FOREGROUND_RED OR FOREGROUND_GREEN OR
                                  FOREGROUND_BLUE);
                        end;

                Warnings:
                        begin
                                SetConsoleTextAttribute
                                  (GetStdHandle(STD_OUTPUT_HANDLE),
                                  FOREGROUND_RED OR FOREGROUND_INTENSITY);
                                Writeln(str);
                                SetConsoleTextAttribute
                                  (GetStdHandle(STD_OUTPUT_HANDLE),
                                  FOREGROUND_RED OR FOREGROUND_GREEN OR
                                  FOREGROUND_BLUE);
                        end;

                ServerStatus:
                        begin
                                Writeln(str);
                                LogTxt(str);
                        end;

                Error:
                        begin
                                LogError(str);
                        end;

                Itens:
                        begin

                        end;

                Painel:
                        begin
                                str := str + ' [DATE_TIME: ' +
                                  DateTimeToStr(Now) + ' ].';
                                LogPainel(str);
                        end;
                Hack:
                        begin
                                // hack_ranged_attack(str);  // Chama a função que grava no Itens.txt
                        end;

        end;

end;

procedure TLog.Querie(Querie: string; nick: string; logType: TLogType1);
begin
        case logType of
                Itens_Querie:
                        begin
                                LogQuerie(Querie, nick);
                        end;
                Principal:
                        begin
                                LogQuerie(Querie, nick);
                        end;
        end;

end;

procedure TLog.Space;
begin
        Writeln('-------------------------------------------------------------------------------');
end;

end.
