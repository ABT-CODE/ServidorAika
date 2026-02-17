unit AccCreateForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Grids;

type
  TfrmAccCreat = class(TForm)
    {$REGION 'PALLETS DOS FORMS'}
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    ComboBox1: TComboBox;
    Label4: TLabel;
    Button1: TButton;
    Label5: TLabel;
    ComboBox2: TComboBox;
    Label6: TLabel;
    ComboBox3: TComboBox;
    StringGrid1: TStringGrid;
    Edit4: TEdit;
    Label7: TLabel;
    Edit5: TEdit;
    Label8: TLabel;
    Edit6: TEdit;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Edit8: TEdit;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Edit11: TEdit;
    Edit12: TEdit;
    Label12: TLabel;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    GroupBox2: TGroupBox;
    PageControl2: TPageControl;
    TabSheet1: TTabSheet;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Edit7: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Label19: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit20: TEdit;
    Edit21: TEdit;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    TabSheet2: TTabSheet;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Edit22: TEdit;
    Edit23: TEdit;
    Edit24: TEdit;
    Label28: TLabel;
    Edit25: TEdit;
    Edit26: TEdit;
    Label29: TLabel;
    Edit27: TEdit;
    Label30: TLabel;
    Label31: TLabel;
    Edit28: TEdit;
    Edit29: TEdit;
    Edit30: TEdit;
    Label32: TLabel;
    Label33: TLabel;
    Label34: TLabel;
    Label35: TLabel;
    Label36: TLabel;
    Edit31: TEdit;
    Edit32: TEdit;
    Edit33: TEdit;
    Label37: TLabel;
    Edit34: TEdit;
    Label38: TLabel;
    Edit35: TEdit;
    Label39: TLabel;
    Edit36: TEdit;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Edit37: TEdit;
    Edit38: TEdit;
    Edit39: TEdit;
    Label43: TLabel;
    Edit40: TEdit;
    Label44: TLabel;
    Edit41: TEdit;
    Label45: TLabel;
    Edit42: TEdit;
    Label46: TLabel;
    Edit43: TEdit;
    Label47: TLabel;
    Edit44: TEdit;
    Label48: TLabel;
    Label49: TLabel;
    Edit45: TEdit;
    Edit46: TEdit;
    Edit47: TEdit;
    Label50: TLabel;
    Label51: TLabel;
    Edit48: TEdit;
    Label52: TLabel;
    Label53: TLabel;
    Edit49: TEdit;
    Edit50: TEdit;
    Edit51: TEdit;
    Label54: TLabel;
    Label55: TLabel;
    Edit52: TEdit;
    Label56: TLabel;
    Label57: TLabel;
    Edit53: TEdit;
    Edit54: TEdit;
    Label58: TLabel;
    Edit55: TEdit;
    Label59: TLabel;
    Edit56: TEdit;
    Label60: TLabel;
    Edit57: TEdit;
    Label61: TLabel;
    Edit58: TEdit;
    Label62: TLabel;
    Edit59: TEdit;
    Label63: TLabel;
    Edit60: TEdit;
    Edit61: TEdit;
    Label64: TLabel;
    Label65: TLabel;
    Edit62: TEdit;
    Label66: TLabel;
    Edit63: TEdit;
    Label67: TLabel;
    Edit64: TEdit;
    Edit65: TEdit;
    Label68: TLabel;
    Label69: TLabel;
    Edit66: TEdit;
    Button8: TButton;
    TabSheet3: TTabSheet;
    Edit67: TEdit;
    Label70: TLabel;
    Label71: TLabel;
    Edit68: TEdit;
    Label72: TLabel;
    Edit69: TEdit;
    Label73: TLabel;
    Edit70: TEdit;
    Edit71: TEdit;
    Label74: TLabel;
    Label75: TLabel;
    Edit72: TEdit;
    Label76: TLabel;
    Edit73: TEdit;
    Label77: TLabel;
    Edit74: TEdit;
    Label78: TLabel;
    Edit75: TEdit;
    Label79: TLabel;
    Edit76: TEdit;
    Label80: TLabel;
    Edit77: TEdit;
    Label81: TLabel;
    Edit78: TEdit;
    Label82: TLabel;
    Edit79: TEdit;
    Label83: TLabel;
    Edit80: TEdit;
    Label84: TLabel;
    Edit81: TEdit;
    Label85: TLabel;
    Edit82: TEdit;
    Label86: TLabel;
    Edit83: TEdit;
    Label87: TLabel;
    Edit84: TEdit;
    Label88: TLabel;
    Edit85: TEdit;
    Label89: TLabel;
    Edit86: TEdit;
    Label90: TLabel;
    Edit87: TEdit;
    Label91: TLabel;
    Edit88: TEdit;
    Label92: TLabel;
    Edit89: TEdit;
    Label93: TLabel;
    Edit90: TEdit;
    Label94: TLabel;
    Edit91: TEdit;
    Label95: TLabel;
    Edit92: TEdit;
    Label96: TLabel;
    Edit93: TEdit;
    Label97: TLabel;
    Edit94: TEdit;
    Label98: TLabel;
    Edit95: TEdit;
    Label99: TLabel;
    Edit96: TEdit;
    Label100: TLabel;
    Edit97: TEdit;
    Label101: TLabel;
    Edit98: TEdit;
    Label102: TLabel;
    Edit99: TEdit;
    Label103: TLabel;
    Edit100: TEdit;
    Label104: TLabel;
    Edit101: TEdit;
    Label105: TLabel;
    Edit102: TEdit;
    Label106: TLabel;
    Edit103: TEdit;
    Label107: TLabel;
    Edit104: TEdit;
    Label108: TLabel;
    Edit105: TEdit;
    Label109: TLabel;
    Edit106: TEdit;
    Label110: TLabel;
    Edit107: TEdit;
    Label111: TLabel;
    Edit108: TEdit;
    Label112: TLabel;
    Edit109: TEdit;
    Label113: TLabel;
    Edit110: TEdit;
    Label114: TLabel;
    Edit111: TEdit;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    Label115: TLabel;
    Edit112: TEdit;
    Label116: TLabel;
    Edit113: TEdit;
    Label117: TLabel;
    Label118: TLabel;
    ComboBox7: TComboBox;
    Label119: TLabel;
    ComboBox8: TComboBox;
    Label120: TLabel;
    Edit115: TEdit;
    Label121: TLabel;
    Edit116: TEdit;
    Label122: TLabel;
    Edit117: TEdit;
    Label123: TLabel;
    Edit118: TEdit;
    Button14: TButton;
    Button15: TButton;
    PageControl1: TPageControl;
    TabSheet6: TTabSheet;
    TabSheet7: TTabSheet;
    TabSheet8: TTabSheet;
    Button16: TButton;
    ComboBox9: TComboBox;
    StringGrid2: TStringGrid;
    Button17: TButton;
    Button18: TButton;
    StringGrid3: TStringGrid;
    Button19: TButton;
    Button20: TButton;
    StringGrid4: TStringGrid;
    Button21: TButton;
    Button22: TButton;
    TabSheet9: TTabSheet;
    PageControl3: TPageControl;
    TabSheet10: TTabSheet;
    TabSheet11: TTabSheet;
    TabSheet12: TTabSheet;
    StringGrid5: TStringGrid;
    Button23: TButton;
    Button24: TButton;
    StringGrid6: TStringGrid;
    Button25: TButton;
    Button26: TButton;
    StringGrid7: TStringGrid;
    Button27: TButton;
    Button28: TButton;
    Label124: TLabel;
    Edit114: TEdit;
    Label125: TLabel;
    Edit119: TEdit;
    Label126: TLabel;
    Edit120: TEdit;
    {$ENDREGION}
    procedure Button1Click(Sender: TObject);
    procedure CarregarUsuarios;
    procedure FormCreate(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmAccCreat: TfrmAccCreat;
  CharIDSlot0_Global: Integer;

implementation

uses
  SQL, GlobalDefs, Log, Functions, Packets, Winapi.WinSock;

{$R *.dfm}
{$REGION 'GET IP'}
function GetLocalIP: string;
var
  WSAData: TWSAData;
  HostEnt: PHostEnt;
  HostName: array[0..255] of AnsiChar;
begin
  Result := '0.0.0.0';
  if WSAStartup($101, WSAData) <> 0 then
    Exit;
  try
    if gethostname(HostName, SizeOf(HostName)) = 0 then
    begin
      HostEnt := gethostbyname(HostName);
      if HostEnt <> nil then
        Result := string(inet_ntoa(PInAddr(HostEnt^.h_addr_list^)^));
    end;
  finally
    WSACleanup;
  end;
end;
{$ENDREGION}

{$REGION 'CRIAR CONTA/BUTTONS'}
{$REGION 'BUTTON 1'}
procedure TfrmAccCreat.Button1Click(Sender: TObject);
var
  SQLComp: TQuery;
  LastID, NationValue, Cash, AccType: Integer;
  Username, Password, PasswordHash, Email, BaseDir, LogsDir, FilePath, LogText, NationName: string;
  CreationDateTime, ClientIP: string;
begin
  Username := Trim(Edit1.Text);
  Password := Trim(Edit2.Text);
  Email    := Trim(Edit3.Text);

  // ==============================
  // VALIDAR COMBOBOX (NAÇÃO)
  // ==============================
  if ComboBox1.ItemIndex = -1 then
  begin
    ShowMessage('Selecione uma nação antes de criar a conta.');
    Exit;
  end;

  case ComboBox1.ItemIndex of
    0: NationValue := 1; // Elsinore
    1: NationValue := 2; // Odeon
    2: NationValue := 3; // Tibérica
  else
    NationValue := 0; // fallback, mas em teoria nunca cai aqui
  end;

  // ==============================
  // VALIDAR COMBOBOX (CASH)
  // ==============================
  case ComboBox2.ItemIndex of
    0: Cash := 10000;
    1: Cash := 100000;
    2: Cash := 1000000;
  else
    Cash := 0;
  end;

  // ==============================
  // VALIDAR COMBOBOX (AccountType)
  // ==============================
  case ComboBox3.ItemIndex of
    0: AccType := 0;
    1: AccType := 5;
    else
    AccType := 0;
  end;

  // ==============================
  // VALIDAÇÕES DE USERNAME
  // ==============================
  if (Length(Username) < 5) or (Length(Username) > 10) then
  begin
    ShowMessage('O nome de usuário deve ter entre 5 e 10 caracteres.');
    Exit;
  end;

  // Só letras e números (usa IsLetter já pronta em Functions)
  if not TFunctions.IsLetter(Username) then
  begin
    ShowMessage('O nome de usuário só pode conter letras e números (sem caracteres especiais).');
    Exit;
  end;

  // ==============================
  // VALIDAÇÕES DE SENHA
  // ==============================
  if (Length(Password) < 5) or (Length(Password) > 25) then
  begin
    ShowMessage('A senha deve ter entre 5 e 25 caracteres.');
    Exit;
  end;

  // ==============================
  // VALIDAÇÕES DE EMAIL
  // ==============================
  if (Pos('@', Email) = 0) or
     (Pos('@', Email) = 1) or
     (Pos('@', Email) = Length(Email)) then
  begin
    ShowMessage('E-mail inválido.');
    Exit;
  end;

  // ==============================
  // CONEXÃO COM BANCO
  // ==============================
  SQLComp := TFunctions.CreateSQL;
  try
    if not SQLComp.Query.Connection.Connected then
    begin
      ShowMessage('Falha de conexão com o banco de dados.');
      Exit;
    end;

    // ==============================
    // VERIFICAR SE USERNAME JÁ EXISTE (case-insensitive)
    // ==============================
    SQLComp.SetQuery(
      'SELECT id FROM accounts ' +
      'WHERE LOWER(username) = LOWER(:pusername) ' +
      'LIMIT 1'
    );
    SQLComp.Query.ParamByName('pusername').AsString := Username;
    SQLComp.Run;

    if SQLComp.Query.RecordCount > 0 then
    begin
      ShowMessage('Usuário já existe.');
      Exit;
    end;

    // ==============================
    // VERIFICAR SE EMAIL JÁ EXISTE (case-insensitive)
    // ==============================
    SQLComp.SetQuery(
      'SELECT id FROM accounts ' +
      'WHERE LOWER(mail) = LOWER(:pmail) ' +
      'LIMIT 1'
    );
    SQLComp.Query.ParamByName('pmail').AsString := Email;
    SQLComp.Run;

    if SQLComp.Query.RecordCount > 0 then
    begin
      ShowMessage('Já existe uma conta cadastrada com esse e-mail.');
      Exit;
    end;

    // ==============================
    // PEGAR ÚLTIMO ID E SOMAR +1
    // ==============================
    SQLComp.SetQuery('SELECT MAX(id) AS LastID FROM accounts');
    SQLComp.Run;

    LastID := SQLComp.Query.FieldByName('LastID').AsInteger + 1;
    if LastID <= 0 then
      LastID := 1;

    // ==============================
    // PREPARAR HASH DA SENHA
    // ==============================
    PasswordHash := TFunctions.StringToMd5(Password);

    // ==============================
    // INSERIR NA TABELA ACCOUNTS
    // ==============================
    SQLComp.Query.Connection.StartTransaction;
    try
      SQLComp.SetQuery(
        'INSERT INTO accounts (id, forum_id, username, password_hash, mail, nation, account_type, cash) ' +
        'VALUES (:pid, :pforum_id, :pusername, :ppassword, :pmail, :pnation, :paccount_type, :pcash)'
      );

      SQLComp.Query.ParamByName('pid').AsInteger := LastID;
      SQLComp.Query.ParamByName('pforum_id').AsInteger := LastID;
      SQLComp.Query.ParamByName('pusername').AsString := Username;
      SQLComp.Query.ParamByName('ppassword').AsString := PasswordHash;
      SQLComp.Query.ParamByName('pmail').AsString     := Email;
      SQLComp.Query.ParamByName('pnation').AsInteger  := NationValue;
      SQLComp.Query.ParamByName('paccount_type').AsInteger  := AccType;
      SQLComp.Query.ParamByName('pcash').AsInteger  := Cash;

      SQLComp.Run(False);
      SQLComp.Query.Connection.Commit;

      ShowMessage('Conta criada com sucesso!');
      Logger.Write('Nova conta criada com sucesso: ' + Username, Warnings);

      // =======================================
      // CRIAR LOG: bin\Logs\<USERNAME>\Account.txt
      // =======================================
      case NationValue of
        1: NationName := 'Elsinore';
        2: NationName := 'Odeon';
        3: NationName := 'Tibérica';
      else
        NationName := 'Desconhecida';
      end;

      CreationDateTime := FormatDateTime('dd/mm/yyyy hh:nn:ss', Now);
      ClientIP := GetLocalIP;

      // Pasta onde está o .exe (geralmente ...\bin\)
      BaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
      // Pasta Logs\<username>
      LogsDir := BaseDir + 'Logs\Contas\' + Username;
      ForceDirectories(LogsDir);

      // Caminho completo do arquivo Account.txt
      FilePath := LogsDir + '\Account.txt';

      // Conteúdo do log
      LogText :=
        'Account ID: ' + IntToStr(LastID) + sLineBreak +
        'Username: ' + Username + sLineBreak +
        'Password (normal): ' + Password + sLineBreak +
        'Password (MD5): ' + PasswordHash + sLineBreak +
        'E-mail: ' + Email + sLineBreak +
        'Nation: ' + NationName + ' (' + IntToStr(NationValue) + ')' + sLineBreak +
        'Criada em: ' + CreationDateTime + sLineBreak +
        'IP: ' + ClientIP + sLineBreak;

      // Usa função já existente em Functions
      TFunctions.StrToFile(LogText, FilePath);

      // Recarregar a StringGrid1 com os novos dados
      CarregarUsuarios;  // Aqui recarregamos a StringGrid1

      // se quiser, pode limpar os campos:
      Edit1.Clear;
      Edit2.Clear;
      Edit3.Clear;
      ComboBox1.ItemIndex := -1;
      ComboBox2.ItemIndex := -1;
      ComboBox3.ItemIndex := -1;
    except
      on E: Exception do
      begin
        SQLComp.Query.Connection.Rollback;
        ShowMessage('Erro ao criar conta: ' + E.Message);
      end;
    end;

  finally
    SQLComp.Free;
  end;

end;
{$ENDREGION}
{$REGION 'BOTÃO 2'}
procedure TfrmAccCreat.Button2Click(Sender: TObject);
var
  SQLComp: TQuery;
begin
  // Validar se existe personagem selecionado no SLOT 0
  if CharIDSlot0_Global <= 0 then
  begin
    //ShowMessage('Nenhum personagem encontrado no Slot 0.');
    Exit;
  end;

  SQLComp := TFunctions.CreateSQL;
  try
    if not SQLComp.Query.Connection.Connected then
    begin
      ShowMessage('Falha de conexão com o banco de dados.');
      Exit;
    end;

    SQLComp.SetQuery(
      'UPDATE characters SET ' +
      'name = :name, ' +
      'level = :level, ' +
      'experience = :experience, ' +
      'gold = :gold, ' +
      'posx = :posx, ' +
      'posy = :posy ' +
      'WHERE id = :character_id'
    );

    SQLComp.Query.ParamByName('name').AsString       := Edit4.Text;
    SQLComp.Query.ParamByName('level').AsString      := Edit8.Text;
    SQLComp.Query.ParamByName('experience').AsString := Edit7.Text;
    SQLComp.Query.ParamByName('gold').AsString       := Edit13.Text;
    SQLComp.Query.ParamByName('posx').AsString       := Edit16.Text;
    SQLComp.Query.ParamByName('posy').AsString       := Edit17.Text;

    // USANDO O ID REAL DO PERSONAGEM
    SQLComp.Query.ParamByName('character_id').AsInteger := CharIDSlot0_Global;

    SQLComp.Run(False);

    ShowMessage(Edit4.Text + ' atualizado(a) com sucesso!');
  finally
    SQLComp.Free;
  end;
end;
{$ENDREGION}

{$ENDREGION}

procedure TfrmAccCreat.Button16Click(Sender: TObject);
begin
  CarregarUsuarios;
  ShowMessage('Tabela de contas atualizadas com sucesso!');
end;

{$REGION 'FORM CREATE'}
procedure TfrmAccCreat.FormCreate(Sender: TObject);
begin
  // Configurações de cabeçalho
  StringGrid1.Cells[0, 0] := 'ID';
  StringGrid1.Cells[1, 0] := 'Username';
  StringGrid1.ColWidths[1] := 480;

  // Configuração das colunas
  StringGrid2.Cells[0, 0] := 'Slot';   // Coluna Slot
  StringGrid2.Cells[1, 0] := 'ID';     // Coluna ID
  StringGrid2.Cells[2, 0] := 'App';    // Coluna App
  StringGrid2.Cells[3, 0] := 'Refine'; // Coluna Refine
  StringGrid2.Cells[4, 0] := 'Eff 1'; // Coluna efeito 1
  StringGrid2.Cells[5, 0] := 'Val 1'; // Coluna Valor 1
  StringGrid2.Cells[6, 0] := 'Eff 2'; // Coluna efeito 1
  StringGrid2.Cells[7, 0] := 'Val 2'; // Coluna Valor 1
  StringGrid2.Cells[8, 0] := 'Eff 3'; // Coluna efeito 1
  StringGrid2.Cells[9, 0] := 'Val 3'; // Coluna Valor 1

  // Configuração das colunas
  StringGrid3.Cells[0, 0] := 'Slot';   // Coluna Slot
  StringGrid3.Cells[1, 0] := 'ID';     // Coluna ID
  StringGrid3.Cells[2, 0] := 'App';    // Coluna App
  StringGrid3.Cells[3, 0] := 'Refine'; // Coluna Refine
  StringGrid3.Cells[4, 0] := 'Eff 1'; // Coluna efeito 1
  StringGrid3.Cells[5, 0] := 'Val 1'; // Coluna Valor 1
  StringGrid3.Cells[6, 0] := 'Eff 2'; // Coluna efeito 1
  StringGrid3.Cells[7, 0] := 'Val 2'; // Coluna Valor 1
  StringGrid3.Cells[8, 0] := 'Eff 3'; // Coluna efeito 1
  StringGrid3.Cells[9, 0] := 'Val 3'; // Coluna Valor 1

  // Configuração das colunas
  StringGrid4.Cells[0, 0] := 'Slot';   // Coluna Slot
  StringGrid4.Cells[1, 0] := 'ID';     // Coluna ID
  StringGrid4.Cells[2, 0] := 'App';    // Coluna App
  StringGrid4.Cells[3, 0] := 'Refine'; // Coluna Refine
  StringGrid4.Cells[4, 0] := 'Eff 1'; // Coluna efeito 1
  StringGrid4.Cells[5, 0] := 'Val 1'; // Coluna Valor 1
  StringGrid4.Cells[6, 0] := 'Eff 2'; // Coluna efeito 1
  StringGrid4.Cells[7, 0] := 'Val 2'; // Coluna Valor 1
  StringGrid4.Cells[8, 0] := 'Eff 3'; // Coluna efeito 1
  StringGrid4.Cells[9, 0] := 'Val 3'; // Coluna Valor 1

  // Configuração das colunas
  StringGrid5.Cells[0, 0] := 'Página';  // Coluna Página
  StringGrid5.Cells[1, 0] := 'Skill';  // Coluna Skill
  StringGrid5.Cells[2, 0] := 'Nível';  // Coluna Nível
  StringGrid5.Cells[3, 0] := 'Tipo';   // Coluna Tipo

  // Configuração das colunas
  StringGrid6.Cells[0, 0] := 'Página';  // Coluna Página
  StringGrid6.Cells[1, 0] := 'Skill';  // Coluna Skill
  StringGrid6.Cells[2, 0] := 'Nível';  // Coluna Nível
  StringGrid6.Cells[3, 0] := 'Tipo';   // Coluna Tipo

  // Configuração das colunas
  StringGrid7.Cells[0, 0] := 'Página';  // Coluna Página
  StringGrid7.Cells[1, 0] := 'Skill';  // Coluna Skill
  StringGrid7.Cells[2, 0] := 'Nível';  // Coluna Nível
  StringGrid7.Cells[3, 0] := 'Tipo';   // Coluna Tipo

  // Chama a função para carregar os usuários
  CarregarUsuarios;
end;
{$ENDREGION}

{$REGION 'CARREGAR USUÁRIOS'}
procedure TfrmAccCreat.CarregarUsuarios;
var
  SQLComp: TQuery;
  i: Integer;
begin
   // Limpar a StringGrid antes de carregar os dados
  StringGrid1.RowCount := 1;  // Defina RowCount inicialmente para 1 (apenas o cabeçalho)

  // Configurações da consulta
  SQLComp := TFunctions.CreateSQL;
  try
    if not SQLComp.Query.Connection.Connected then
    begin
      ShowMessage('Falha de conexão com o banco de dados.');
      Exit;
    end;

    // Consulta SQL para pegar o ID e Username
    SQLComp.SetQuery('SELECT id, username FROM accounts');
    SQLComp.Run;

    // Verifica se a consulta retornou dados
    if SQLComp.Query.RecordCount = 0 then
    begin
      ShowMessage('Nenhum dado encontrado na tabela "accounts".');
      Exit;
    end;

    // Confirma que dados estão sendo retornados
    //ShowMessage('Tabela de usuários atualizada! [' + IntToStr(SQLComp.Query.RecordCount) + '] contas cadastradas!');

    // Agora, ajusta o RowCount com base no número de registros retornados
    StringGrid1.RowCount := SQLComp.Query.RecordCount + 1;  // +1 para o cabeçalho

    // Configurações de cabeçalho
    StringGrid1.Cells[0, 0] := 'ID';
    StringGrid1.Cells[1, 0] := 'Username';

    // Preenche a StringGrid com os dados do banco
    i := 1; // Começa na linha 1, já que a linha 0 é para o cabeçalho
    while not SQLComp.Query.EOF do
    begin
      // Preencher as células da StringGrid
      StringGrid1.Cells[0, i] := SQLComp.Query.FieldByName('id').AsString;
      StringGrid1.Cells[1, i] := SQLComp.Query.FieldByName('username').AsString;

      // Avança para a próxima linha da StringGrid
      Inc(i);
      SQLComp.Query.Next;
    end;

  finally
    SQLComp.Free;
  end;
end;
{$ENDREGION}

procedure TfrmAccCreat.StringGrid1SelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
var
  SQLComp, SQLItems: TQuery;
  AccountID, SlotValue, ClassInfo: Integer;
  CharacterName, Level, Experience, Gold, PosX, PosY, Status: string;
  Strength, Agility, Intelligence, Constitution, Luck, Altura, Tronco, Perna, Corpo, Honor, KillPoint, Infamia, SkillPoint: string;
  ItemID, ItemSlot, SlotType: Integer;
  CharIDSlot0, CharIDSlot1, CharIDSlot2: Integer;
  BaseDir, LogsDir, FilePath, Line, Username: string;
  SL: TStringList;
  i, P: Integer;
begin
  // Verifica se a linha selecionada não é a primeira (cabeçalho)
  if ARow > 0 then
  begin
    // Pega o ID da conta da linha selecionada
    AccountID := StrToIntDef(StringGrid1.Cells[0, ARow], 0);  // Primeiro valor da linha é o ID

    if AccountID > 0 then
    begin

      {$REGION 'LIMPEZAS'}
    // Sempre limpar campos
      Edit4.Clear;
      Edit5.Clear;
      Edit6.Clear;
      Edit8.Clear;
      Edit7.Clear;
      Edit9.Clear;
      Edit10.Clear;
      Edit11.Clear;
      Edit12.Clear;
      Edit13.Clear;
      Edit14.Clear;
      Edit15.Clear;
      Edit16.Clear;
      Edit17.Clear;
      Edit18.Clear;
      Edit19.Clear;
      Edit20.Clear;
      Edit21.Clear;
      Edit22.Clear;
      Edit23.Clear;
      Edit24.Clear;
      Edit25.Clear;
      Edit26.Clear;
      Edit27.Clear;
      Edit28.Clear;
      Edit29.Clear;
      Edit30.Clear;
      Edit31.Clear;
      Edit32.Clear;
      Edit33.Clear;
      Edit34.Clear;
      Edit35.Clear;
      Edit36.Clear;
      Edit37.Clear;
      Edit38.Clear;
      Edit39.Clear;
      Edit40.Clear;
      Edit41.Clear;
      Edit42.Clear;
      Edit43.Clear;
      Edit44.Clear;
      Edit45.Clear;
      Edit46.Clear;
      Edit47.Clear;
      Edit48.Clear;
      Edit49.Clear;
      Edit50.Clear;
      Edit51.Clear;
      Edit52.Clear;
      Edit53.Clear;
      Edit54.Clear;
      Edit55.Clear;
      Edit56.Clear;
      Edit57.Clear;
      Edit58.Clear;
      Edit59.Clear;
      Edit60.Clear;
      Edit61.Clear;
      Edit62.Clear;
      Edit63.Clear;
      Edit64.Clear;
      Edit65.Clear;
      Edit66.Clear;
      Edit67.Clear;
      Edit68.Clear;
      Edit69.Clear;
      Edit70.Clear;
      Edit71.Clear;
      Edit72.Clear;
      Edit73.Clear;
      Edit74.Clear;
      Edit75.Clear;
      Edit76.Clear;
      Edit77.Clear;
      Edit78.Clear;
      Edit79.Clear;
      Edit80.Clear;
      Edit81.Clear;
      Edit82.Clear;
      Edit83.Clear;
      Edit84.Clear;
      Edit85.Clear;
      Edit86.Clear;
      Edit87.Clear;
      Edit88.Clear;
      Edit89.Clear;
      Edit90.Clear;
      Edit91.Clear;
      Edit92.Clear;
      Edit93.Clear;
      Edit94.Clear;
      Edit95.Clear;
      Edit96.Clear;
      Edit97.Clear;
      Edit98.Clear;
      Edit99.Clear;
      Edit100.Clear;
      Edit101.Clear;
      Edit102.Clear;
      Edit103.Clear;
      Edit104.Clear;
      Edit105.Clear;
      Edit106.Clear;
      Edit107.Clear;
      Edit108.Clear;
      Edit109.Clear;
      Edit110.Clear;
      Edit111.Clear;
      Edit112.Clear;
      Edit113.Clear;
      Edit115.Clear;
      Edit116.Clear;
      Edit117.Clear;
      Edit118.Clear;
      ComboBox4.ItemIndex := -1;
      ComboBox5.ItemIndex := -1;
      ComboBox6.ItemIndex := -1;
      ComboBox7.ItemIndex := -1;
      ComboBox8.ItemIndex := -1;
      ComboBox9.ItemIndex := -1;
      TabSheet6.Caption := 'Personagem 1';
      TabSheet7.Caption := 'Personagem 2';
      TabSheet8.Caption := 'Personagem 3';
      TabSheet10.Caption := 'Personagem 1';
      TabSheet11.Caption := 'Personagem 2';
      TabSheet12.Caption := 'Personagem 3';

      // Limpar a StringGrid2 antes de adicionar novos itens
      StringGrid2.RowCount := 1;  // Defina RowCount inicialmente para 1 (apenas o cabeçalho)
      // Limpar a StringGrid2 antes de adicionar novos itens
      StringGrid3.RowCount := 1;  // Defina RowCount inicialmente para 1 (apenas o cabeçalho)
      // Limpar a StringGrid2 antes de adicionar novos itens
      StringGrid4.RowCount := 1;  // Defina RowCount inicialmente para 1 (apenas o cabeçalho)
      // Limpar a StringGrid5 antes de adicionar novos itens
      StringGrid5.RowCount := 1;  // Defina RowCount inicialmente para 1 (apenas o cabeçalho)
      // Limpar a StringGrid6 antes de adicionar novos itens
      StringGrid6.RowCount := 1;  // Defina RowCount inicialmente para 1 (apenas o cabeçalho)
      // Limpar a StringGrid7 antes de adicionar novos itens
      StringGrid7.RowCount := 1;  // Defina RowCount inicialmente para 1 (apenas o cabeçalho)

      CharIDSlot0 := 0;
      CharIDSlot1 := 0;
      CharIDSlot2 := 0;
{$ENDREGION}

    // Consulta para buscar o nome, slot, classinfo e outras informações do personagem
    SQLComp := TFunctions.CreateSQL;
    try
      if not SQLComp.Query.Connection.Connected then
      begin
        ShowMessage('Falha de conexão com o banco de dados.');
        Exit;
      end;

      {$REGION 'DADOS TABELA ACCOUNTS'}
        // ================================
        // CARREGAR DADOS DA TABELA ACCOUNTS
        // ================================
        SQLComp.SetQuery(
          'SELECT username, nation, account_status, account_type, ' +
          '       isactive, cash, storage_gold, mail ' +
          'FROM accounts WHERE id = :id'
        );
        SQLComp.Query.ParamByName('id').AsInteger := AccountID;
        SQLComp.Run;

        if not SQLComp.Query.EOF then
        begin
          // Edits com dados crus da conta
          Edit112.Text := SQLComp.Query.FieldByName('username').AsString;
          Edit116.Text := SQLComp.Query.FieldByName('cash').AsString;
          Edit115.Text := SQLComp.Query.FieldByName('isactive').AsString;
          Edit117.Text := SQLComp.Query.FieldByName('storage_gold').AsString;
          Edit118.Text := SQLComp.Query.FieldByName('mail').AsString;

          // ==========================
          // ComboBox9 - Nation
          // nation: 1 -> item 0 | 2 -> item 1 | 3 -> item 2
          // ==========================
          case SQLComp.Query.FieldByName('nation').AsInteger of
            1: ComboBox9.ItemIndex := 0; // nation = 1
            2: ComboBox9.ItemIndex := 1; // nation = 2
            3: ComboBox9.ItemIndex := 2; // nation = 3
          else
            ComboBox9.ItemIndex := -1;
          end;

          // ==========================
          // ComboBox7 - account_status
          // 0 -> item 0 | 9 -> item 1
          // ==========================
          case SQLComp.Query.FieldByName('account_status').AsInteger of
            0: ComboBox7.ItemIndex := 0;
            9: ComboBox7.ItemIndex := 1;
          else
            ComboBox7.ItemIndex := -1;
          end;

          // ==========================
          // ComboBox8 - account_type
          // 0 -> item 0 | 5 -> item 1
          // ==========================
          case SQLComp.Query.FieldByName('account_type').AsInteger of
            0: ComboBox8.ItemIndex := 0;
            5: ComboBox8.ItemIndex := 1;
          else
            ComboBox8.ItemIndex := -1;
          end;

          // ==========================
          // Edit115 - isactive
          // 0 -> Off | 1 -> On
          // ==========================
          case SQLComp.Query.FieldByName('isactive').AsInteger of
            0: Edit115.Text := 'Deslogado';
            1: Edit115.Text := 'Logado';
          else
            ComboBox8.ItemIndex := -1;
          end;

           // ==========================================
          // CARREGAR SENHA NORMAL NO Edit113 (LOGS)
          // Logs\Contas\<username>\Account.txt
          // ==========================================
          Username := Trim(Edit112.Text);
          if Username = '' then
            Username := Trim(StringGrid1.Cells[1, ARow]); // fallback pelo grid, se precisar

          if Username <> '' then
          begin
            BaseDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
            LogsDir := BaseDir + 'Logs\Contas\' + Username;
            FilePath := LogsDir + '\Account.txt';

            Edit113.Clear;

            if FileExists(FilePath) then
            begin
              SL := TStringList.Create;
              try
                SL.LoadFromFile(FilePath);

                for i := 0 to SL.Count - 1 do
                begin
                  Line := SL[i];

                  // Procurar pela linha: "Password (normal): kakakaka123"
                  if Pos('Password (normal):', Line) = 1 then
                  begin
                    P := Length('Password (normal):') + 1;
                    Edit113.Text := Trim(Copy(Line, P, MaxInt));
                    Break;
                  end;
                end;

              finally
                SL.Free;
              end;
            end;
          end;
        end;
       {$ENDREGION}

      {$REGION 'STATUS DO PERSONAGEM'}
    // Consulta SQL para buscar o nome, slot, classinfo e outras informações do personagem
    SQLComp.SetQuery('SELECT name, slot, level, experience, gold, posx, posy, classinfo, ' +
                     'strength, agility, intelligence, constitution, luck, status, altura, tronco, ' +
                     'perna, corpo, honor, killpoint, infamia, skillpoint, id ' +
                     'FROM characters WHERE owner_accid = :account_id LIMIT 3');  // Mudança para pegar slots 0, 1 e 2
    SQLComp.Query.ParamByName('account_id').AsInteger := AccountID;
    SQLComp.Run;

    // Verifica se encontrou algum nome de personagem
    if SQLComp.Query.RecordCount > 0 then
    begin
      // Lógica para preencher os slots 0, 1 e 2
      while not SQLComp.Query.EOF do
      begin
        SlotValue := SQLComp.Query.FieldByName('slot').AsInteger;
        CharacterName := SQLComp.Query.FieldByName('name').AsString;
        Level := SQLComp.Query.FieldByName('level').AsString;
        Experience := SQLComp.Query.FieldByName('experience').AsString;
        Gold := SQLComp.Query.FieldByName('gold').AsString;
        PosX := SQLComp.Query.FieldByName('posx').AsString;
        PosY := SQLComp.Query.FieldByName('posy').AsString;
        ClassInfo := SQLComp.Query.FieldByName('classinfo').AsInteger;
        Strength := SQLComp.Query.FieldByName('strength').AsString;
        Agility := SQLComp.Query.FieldByName('agility').AsString;
        Intelligence := SQLComp.Query.FieldByName('intelligence').AsString;
        Constitution := SQLComp.Query.FieldByName('constitution').AsString;
        Luck := SQLComp.Query.FieldByName('luck').AsString;
        Status := SQLComp.Query.FieldByName('status').AsString;
        Altura := SQLComp.Query.FieldByName('altura').AsString;
        Tronco := SQLComp.Query.FieldByName('tronco').AsString;
        Perna := SQLComp.Query.FieldByName('perna').AsString;
        Corpo := SQLComp.Query.FieldByName('corpo').AsString;
        Honor := SQLComp.Query.FieldByName('honor').AsString;
        KillPoint := SQLComp.Query.FieldByName('killpoint').AsString;
        Infamia := SQLComp.Query.FieldByName('infamia').AsString;
        SkillPoint := SQLComp.Query.FieldByName('skillpoint').AsString;
        ItemID := SQLComp.Query.FieldByName('id').AsInteger;  // Obtém o ID do personagem

        // Preenche Edit4, Edit5, Edit6 com base no slot
        case SlotValue of
          0:
            begin
              Edit4.Text := CharacterName;  // Slot 0
              Edit8.Text := Level;
              Edit7.Text := Experience;
              Edit13.Text := Gold;
              Edit16.Text := PosX;
              Edit17.Text := PosY;
              Edit22.Text := CharacterName;
              Edit67.Text := CharacterName;
              TabSheet6.Caption := CharacterName;
              TabSheet10.Caption := CharacterName;

              // Preenche os STATUS
              Edit25.Text := Strength;      // Preenche Edit25 com strength
              Edit26.Text := Agility;       // Preenche Edit26 com agility
              Edit27.Text := Intelligence;  // Preenche Edit27 com intelligence
              Edit28.Text := Constitution;  // Preenche Edit28 com constitution
              Edit29.Text := Luck;          // Preenche Edit29 com luck
              Edit30.Text := Status;        // Preenche Edit30 com status
              Edit43.Text := Altura;        // Preenche Edit43 com altura
              Edit44.Text := Tronco;        // Preenche Edit44 com tronco
              Edit45.Text := Perna;         // Preenche Edit45 com perna
              Edit46.Text := Corpo;         // Preenche Edit46 com corpo
              Edit55.Text := Honor;         // Preenche Edit55 com honor
              Edit56.Text := KillPoint;     // Preenche Edit56 com killpoint
              Edit57.Text := Infamia;       // Preenche Edit57 com infamia
              Edit58.Text := SkillPoint;    // Preenche Edit58 com skillpoint

              CharIDSlot0 := ItemID;  // Guardar ID do personagem do slot 0 pra carregar os itens depois
              CharIDSlot0_Global := ItemID;

              Case ClassInfo of
                1: ComboBox4.ItemIndex := 0;  // classinfo = 1, mostra item 1
                2: ComboBox4.ItemIndex := 1;  // classinfo = 2, mostra item 2
                3: ComboBox4.ItemIndex := 2;  // classinfo = 3, mostra item 3
                11: ComboBox4.ItemIndex := 4; // classinfo = 11, mostra item 5
                12: ComboBox4.ItemIndex := 5; // classinfo = 12, mostra item 6
                13: ComboBox4.ItemIndex := 6; // classinfo = 13, mostra item 7
                21: ComboBox4.ItemIndex := 8; // classinfo = 21, mostra item 9
                22: ComboBox4.ItemIndex := 9; // classinfo = 22, mostra item 10
                23: ComboBox4.ItemIndex := 10; // classinfo = 23, mostra item 11
                31: ComboBox4.ItemIndex := 12; // classinfo = 31, mostra item 13
                32: ComboBox4.ItemIndex := 13; // classinfo = 32, mostra item 14
                33: ComboBox4.ItemIndex := 14; // classinfo = 33, mostra item 15
                41: ComboBox4.ItemIndex := 16; // classinfo = 41, mostra item 17
                42: ComboBox4.ItemIndex := 17; // classinfo = 42, mostra item 18
                43: ComboBox4.ItemIndex := 18; // classinfo = 43, mostra item 19
                51: ComboBox4.ItemIndex := 20; // classinfo = 51, mostra item 21
                52: ComboBox4.ItemIndex := 21; // classinfo = 52, mostra item 22
                53: ComboBox4.ItemIndex := 22; // classinfo = 53, mostra item 23
              End;

            end;
          1:
          begin
            Edit5.Text := CharacterName;  // Slot 1
            Edit23.Text := CharacterName;
            Edit68.Text := CharacterName;
            TabSheet7.Caption := CharacterName;
            TabSheet11.Caption := CharacterName;
            Edit11.Text := Level;
            Edit9.Text := Experience;
            Edit14.Text := Gold;
            Edit19.Text := PosX;
            Edit18.Text := PosY;

            CharIDSlot1 := ItemID;

            // Preenche os STATUS
            Edit31.Text := Strength;      // Preenche Edit25 com strength
            Edit32.Text := Agility;       // Preenche Edit26 com agility
            Edit33.Text := Intelligence;  // Preenche Edit27 com intelligence
            Edit34.Text := Constitution;  // Preenche Edit28 com constitution
            Edit35.Text := Luck;          // Preenche Edit29 com luck
            Edit36.Text := Status;        // Preenche Edit30 com status
            Edit47.Text := Altura;        // Preenche Edit43 com altura
            Edit48.Text := Tronco;        // Preenche Edit44 com tronco
            Edit49.Text := Perna;         // Preenche Edit45 com perna
            Edit50.Text := Corpo;         // Preenche Edit46 com corpo
            Edit59.Text := Honor;         // Preenche Edit55 com honor
            Edit62.Text := KillPoint;     // Preenche Edit56 com killpoint
            Edit60.Text := Infamia;       // Preenche Edit57 com infamia
            Edit61.Text := SkillPoint;    // Preenche Edit58 com skillpoint

            Case ClassInfo of
                1: ComboBox5.ItemIndex := 0;  // classinfo = 1, mostra item 1
                2: ComboBox5.ItemIndex := 1;  // classinfo = 2, mostra item 2
                3: ComboBox5.ItemIndex := 2;  // classinfo = 3, mostra item 3
                11: ComboBox5.ItemIndex := 4; // classinfo = 11, mostra item 5
                12: ComboBox5.ItemIndex := 5; // classinfo = 12, mostra item 6
                13: ComboBox5.ItemIndex := 6; // classinfo = 13, mostra item 7
                21: ComboBox5.ItemIndex := 8; // classinfo = 21, mostra item 9
                22: ComboBox5.ItemIndex := 9; // classinfo = 22, mostra item 10
                23: ComboBox5.ItemIndex := 10; // classinfo = 23, mostra item 11
                31: ComboBox5.ItemIndex := 12; // classinfo = 31, mostra item 13
                32: ComboBox5.ItemIndex := 13; // classinfo = 32, mostra item 14
                33: ComboBox5.ItemIndex := 14; // classinfo = 33, mostra item 15
                41: ComboBox5.ItemIndex := 16; // classinfo = 41, mostra item 17
                42: ComboBox5.ItemIndex := 17; // classinfo = 42, mostra item 18
                43: ComboBox5.ItemIndex := 18; // classinfo = 43, mostra item 19
                51: ComboBox5.ItemIndex := 20; // classinfo = 51, mostra item 21
                52: ComboBox5.ItemIndex := 21; // classinfo = 52, mostra item 22
                53: ComboBox5.ItemIndex := 22; // classinfo = 53, mostra item 23
              End;
          end;
          2:
          begin
            Edit6.Text := CharacterName;  // Slot 2
            Edit24.Text := CharacterName;
            Edit69.Text := CharacterName;
            TabSheet8.Caption := CharacterName;
            TabSheet12.Caption := CharacterName;
            Edit12.Text := Level;
            Edit10.Text := Experience;
            Edit15.Text := Gold;
            Edit21.Text := PosX;
            Edit20.Text := PosY;

            CharIDSlot2 := ItemID;

            // Preenche os STATUS
            Edit37.Text := Strength;      // Preenche Edit25 com strength
            Edit38.Text := Agility;       // Preenche Edit26 com agility
            Edit39.Text := Intelligence;  // Preenche Edit27 com intelligence
            Edit40.Text := Constitution;  // Preenche Edit28 com constitution
            Edit41.Text := Luck;          // Preenche Edit29 com luck
            Edit42.Text := Status;        // Preenche Edit30 com status
            Edit51.Text := Altura;        // Preenche Edit43 com altura
            Edit52.Text := Tronco;        // Preenche Edit44 com tronco
            Edit53.Text := Perna;         // Preenche Edit45 com perna
            Edit54.Text := Corpo;         // Preenche Edit46 com corpo
            Edit63.Text := Honor;         // Preenche Edit55 com honor
            Edit66.Text := KillPoint;     // Preenche Edit56 com killpoint
            Edit64.Text := Infamia;       // Preenche Edit57 com infamia
            Edit65.Text := SkillPoint;    // Preenche Edit58 com skillpoint

            Case ClassInfo of
                1: ComboBox6.ItemIndex := 0;  // classinfo = 1, mostra item 1
                2: ComboBox6.ItemIndex := 1;  // classinfo = 2, mostra item 2
                3: ComboBox6.ItemIndex := 2;  // classinfo = 3, mostra item 3
                11: ComboBox6.ItemIndex := 4; // classinfo = 11, mostra item 5
                12: ComboBox6.ItemIndex := 5; // classinfo = 12, mostra item 6
                13: ComboBox6.ItemIndex := 6; // classinfo = 13, mostra item 7
                21: ComboBox6.ItemIndex := 8; // classinfo = 21, mostra item 9
                22: ComboBox6.ItemIndex := 9; // classinfo = 22, mostra item 10
                23: ComboBox6.ItemIndex := 10; // classinfo = 23, mostra item 11
                31: ComboBox6.ItemIndex := 12; // classinfo = 31, mostra item 13
                32: ComboBox6.ItemIndex := 13; // classinfo = 32, mostra item 14
                33: ComboBox6.ItemIndex := 14; // classinfo = 33, mostra item 15
                41: ComboBox6.ItemIndex := 16; // classinfo = 41, mostra item 17
                42: ComboBox6.ItemIndex := 17; // classinfo = 42, mostra item 18
                43: ComboBox6.ItemIndex := 18; // classinfo = 43, mostra item 19
                51: ComboBox6.ItemIndex := 20; // classinfo = 51, mostra item 21
                52: ComboBox6.ItemIndex := 21; // classinfo = 52, mostra item 22
                53: ComboBox6.ItemIndex := 22; // classinfo = 53, mostra item 23
              End;
          end;
        end;

        SQLComp.Query.Next;
      end;
    end;
  finally
    SQLComp.Free;
    end;
    {$ENDREGION}

      {$REGION 'ITENS DO PERSONAGEM'}
    // Agora carrega os ITENS do personagem do slot 0, se existir
      if CharIDSlot0 > 0 then
      begin
        SQLItems := TFunctions.CreateSQL;
        try
          if not SQLItems.Query.Connection.Connected then
            Exit;

          // Buscamos também o slot_type
          SQLItems.SetQuery(
            'SELECT item_id, slot, slot_type, app, refine, effect1_index, effect2_index, effect3_index, effect1_value, ' +
            'effect2_value, effect3_value ' +
            'FROM items WHERE owner_id = :owner_id'
          );
          SQLItems.Query.ParamByName('owner_id').AsInteger := CharIDSlot0;
          SQLItems.Run;

          while not SQLItems.Query.EOF do
          begin
            // Primeiro verifica o tipo de slot
            SlotType := SQLItems.Query.FieldByName('slot_type').AsInteger;

            // Só preenche os edits 70..83 se slot_type = 0
            if SlotType = 0 then
            begin
              ItemSlot := SQLItems.Query.FieldByName('slot').AsInteger;
              ItemID   := SQLItems.Query.FieldByName('item_id').AsInteger;

              case ItemSlot of
                0:  Edit70.Text := IntToStr(ItemID);
                1:  Edit71.Text := IntToStr(ItemID);
                2:  Edit72.Text := IntToStr(ItemID);
                3:  Edit73.Text := IntToStr(ItemID);
                4:  Edit74.Text := IntToStr(ItemID);
                5:  Edit75.Text := IntToStr(ItemID);
                6:  Edit76.Text := IntToStr(ItemID);
                7:  Edit77.Text := IntToStr(ItemID);
                8:  Edit78.Text := IntToStr(ItemID);
                9:  Edit79.Text := IntToStr(ItemID);
                11: Edit80.Text := IntToStr(ItemID);
                12: Edit81.Text := IntToStr(ItemID);
                13: Edit82.Text := IntToStr(ItemID);
                14: Edit83.Text := IntToStr(ItemID);
              end;
            end;

            if SlotType = 1 then
            begin
            StringGrid2.RowCount := StringGrid2.RowCount + 1;

            StringGrid2.Cells[0, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('slot').AsString;  // Coluna Slot
            StringGrid2.Cells[1, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('item_id').AsString;  // Coluna ID
            StringGrid2.Cells[2, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('app').AsString;  // Coluna App
            StringGrid2.Cells[3, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('refine').AsString;  // Coluna Refine
            StringGrid2.Cells[4, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('effect1_index').AsString;  // Coluna eff 1
            StringGrid2.Cells[5, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('effect1_value').AsString;  // Coluna Veff 1
            StringGrid2.Cells[6, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('effect2_index').AsString;  // Coluna eff 2
            StringGrid2.Cells[7, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('effect2_value').AsString;  // Coluna Veff 2
            StringGrid2.Cells[8, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('effect3_index').AsString;  // Coluna eff 3
            StringGrid2.Cells[9, StringGrid2.RowCount - 1] := SQLItems.Query.FieldByName('effect3_value').AsString;  // Coluna Veff 3

            end;


            SQLItems.Query.Next;
          end;
        finally
          SQLItems.Free;
        end;

        // ============================================
        // CARREGAR HABILIDADES DO PERSONAGEM (Tabela skills)
        // ============================================
        SQLItems := TFunctions.CreateSQL;
        try
          if not SQLItems.Query.Connection.Connected then
            Exit;

          // Consulta para pegar as habilidades do personagem
          SQLItems.SetQuery(
            'SELECT slot, item, level, type ' +
            'FROM skills WHERE owner_charid = :owner_charid'
          );
          SQLItems.Query.ParamByName('owner_charid').AsInteger := CharIDSlot0;
          SQLItems.Run;

          // Preenche a StringGrid5 com as habilidades
          while not SQLItems.Query.EOF do
          begin
            // Adiciona uma nova linha na StringGrid5
            StringGrid5.RowCount := StringGrid5.RowCount + 1;

            // Preenche os valores das colunas
            StringGrid5.Cells[0, StringGrid5.RowCount - 1] := SQLItems.Query.FieldByName('slot').AsString;  // Coluna Página
            StringGrid5.Cells[1, StringGrid5.RowCount - 1] := SQLItems.Query.FieldByName('item').AsString;  // Coluna Skill
            StringGrid5.Cells[2, StringGrid5.RowCount - 1] := SQLItems.Query.FieldByName('level').AsString;  // Coluna Nível
            StringGrid5.Cells[3, StringGrid5.RowCount - 1] := SQLItems.Query.FieldByName('type').AsString;   // Coluna Tipo

            SQLItems.Query.Next;
          end;

        finally
          SQLItems.Free;
        end;
      end;

      // Agora carrega os ITENS do personagem do slot 1, se existir
      if CharIDSlot1 > 0 then
      begin
        SQLItems := TFunctions.CreateSQL;
        try
          if not SQLItems.Query.Connection.Connected then
            Exit;

          // Buscamos também o slot_type
          SQLItems.SetQuery(
            'SELECT item_id, slot, slot_type, app, refine, effect1_index, effect2_index, effect3_index, effect1_value, ' +
            'effect2_value, effect3_value ' +
            'FROM items WHERE owner_id = :owner_id'
          );
          SQLItems.Query.ParamByName('owner_id').AsInteger := CharIDSlot1;
          SQLItems.Run;

          while not SQLItems.Query.EOF do
          begin
            // Primeiro verifica o tipo de slot
            SlotType := SQLItems.Query.FieldByName('slot_type').AsInteger;

            // Só preenche os edits 84..97 se slot_type = 0
            if SlotType = 0 then
            begin
              ItemSlot := SQLItems.Query.FieldByName('slot').AsInteger;
              ItemID   := SQLItems.Query.FieldByName('item_id').AsInteger;

              case ItemSlot of
                0:  Edit84.Text := IntToStr(ItemID);
                1:  Edit91.Text := IntToStr(ItemID);
                2:  Edit85.Text := IntToStr(ItemID);
                3:  Edit92.Text := IntToStr(ItemID);
                4:  Edit86.Text := IntToStr(ItemID);
                5:  Edit93.Text := IntToStr(ItemID);
                6:  Edit87.Text := IntToStr(ItemID);
                7:  Edit94.Text := IntToStr(ItemID);
                8:  Edit88.Text := IntToStr(ItemID);
                9:  Edit95.Text := IntToStr(ItemID);
                11: Edit89.Text := IntToStr(ItemID);
                12: Edit96.Text := IntToStr(ItemID);
                13: Edit90.Text := IntToStr(ItemID);
                14: Edit97.Text := IntToStr(ItemID);
              end;
            end;

            if SlotType = 1 then
            begin
            StringGrid3.RowCount := StringGrid3.RowCount + 1;

            StringGrid3.Cells[0, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('slot').AsString;  // Coluna Slot
            StringGrid3.Cells[1, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('item_id').AsString;  // Coluna ID
            StringGrid3.Cells[2, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('app').AsString;  // Coluna App
            StringGrid3.Cells[3, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('refine').AsString;  // Coluna Refine
            StringGrid3.Cells[4, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('effect1_index').AsString;  // Coluna eff 1
            StringGrid3.Cells[5, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('effect1_value').AsString;  // Coluna Veff 1
            StringGrid3.Cells[6, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('effect2_index').AsString;  // Coluna eff 2
            StringGrid3.Cells[7, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('effect2_value').AsString;  // Coluna Veff 2
            StringGrid3.Cells[8, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('effect3_index').AsString;  // Coluna eff 3
            StringGrid3.Cells[9, StringGrid3.RowCount - 1] := SQLItems.Query.FieldByName('effect3_value').AsString;  // Coluna Veff 3

            end;

            SQLItems.Query.Next;
          end;
        finally
          SQLItems.Free;
        end;

        // ============================================
        // CARREGAR HABILIDADES DO PERSONAGEM (Tabela skills)
        // ============================================
        SQLItems := TFunctions.CreateSQL;
        try
          if not SQLItems.Query.Connection.Connected then
            Exit;

          // Consulta para pegar as habilidades do personagem
          SQLItems.SetQuery(
            'SELECT slot, item, level, type ' +
            'FROM skills WHERE owner_charid = :owner_charid'
          );
          SQLItems.Query.ParamByName('owner_charid').AsInteger := CharIDSlot1;
          SQLItems.Run;

          // Preenche a StringGrid6 com as habilidades
          while not SQLItems.Query.EOF do
          begin
            // Adiciona uma nova linha na StringGrid6
            StringGrid6.RowCount := StringGrid6.RowCount + 1;

            // Preenche os valores das colunas
            StringGrid6.Cells[0, StringGrid6.RowCount - 1] := SQLItems.Query.FieldByName('slot').AsString;  // Coluna Página
            StringGrid6.Cells[1, StringGrid6.RowCount - 1] := SQLItems.Query.FieldByName('item').AsString;  // Coluna Skill
            StringGrid6.Cells[2, StringGrid6.RowCount - 1] := SQLItems.Query.FieldByName('level').AsString;  // Coluna Nível
            StringGrid6.Cells[3, StringGrid6.RowCount - 1] := SQLItems.Query.FieldByName('type').AsString;   // Coluna Tipo

            SQLItems.Query.Next;
          end;

        finally
          SQLItems.Free;
        end;
      end;

      // Agora carrega os ITENS do personagem do slot 2, se existir
      if CharIDSlot2 > 0 then
      begin
        SQLItems := TFunctions.CreateSQL;
        try
          if not SQLItems.Query.Connection.Connected then
            Exit;

          // Buscamos também o slot_type
          SQLItems.SetQuery(
            'SELECT item_id, slot, slot_type, app, refine, effect1_index, effect2_index, effect3_index, effect1_value, ' +
            'effect2_value, effect3_value ' +
            'FROM items WHERE owner_id = :owner_id'
          );
          SQLItems.Query.ParamByName('owner_id').AsInteger := CharIDSlot2;
          SQLItems.Run;

          while not SQLItems.Query.EOF do
          begin
            // Primeiro verifica o tipo de slot
            SlotType := SQLItems.Query.FieldByName('slot_type').AsInteger;

            // Só preenche os edits 98..111 se slot_type = 0
            if SlotType = 0 then
            begin
              ItemSlot := SQLItems.Query.FieldByName('slot').AsInteger;
              ItemID   := SQLItems.Query.FieldByName('item_id').AsInteger;

              case ItemSlot of
                0:  Edit98.Text := IntToStr(ItemID);
                1:  Edit105.Text := IntToStr(ItemID);
                2:  Edit99.Text := IntToStr(ItemID);
                3:  Edit106.Text := IntToStr(ItemID);
                4:  Edit100.Text := IntToStr(ItemID);
                5:  Edit107.Text := IntToStr(ItemID);
                6:  Edit101.Text := IntToStr(ItemID);
                7:  Edit108.Text := IntToStr(ItemID);
                8:  Edit102.Text := IntToStr(ItemID);
                9:  Edit109.Text := IntToStr(ItemID);
                11: Edit103.Text := IntToStr(ItemID);
                12: Edit110.Text := IntToStr(ItemID);
                13: Edit104.Text := IntToStr(ItemID);
                14: Edit111.Text := IntToStr(ItemID);
              end;
            end;

            if SlotType = 1 then
            begin
            StringGrid4.RowCount := StringGrid4.RowCount + 1;

            StringGrid4.Cells[0, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('slot').AsString;  // Coluna Slot
            StringGrid4.Cells[1, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('item_id').AsString;  // Coluna ID
            StringGrid4.Cells[2, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('app').AsString;  // Coluna App
            StringGrid4.Cells[3, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('refine').AsString;  // Coluna Refine
            StringGrid4.Cells[4, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('effect1_index').AsString;  // Coluna eff 1
            StringGrid4.Cells[5, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('effect1_value').AsString;  // Coluna Veff 1
            StringGrid4.Cells[6, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('effect2_index').AsString;  // Coluna eff 2
            StringGrid4.Cells[7, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('effect2_value').AsString;  // Coluna Veff 2
            StringGrid4.Cells[8, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('effect3_index').AsString;  // Coluna eff 3
            StringGrid4.Cells[9, StringGrid4.RowCount - 1] := SQLItems.Query.FieldByName('effect3_value').AsString;  // Coluna Veff 3

            end;

            SQLItems.Query.Next;
          end;
        finally
          SQLItems.Free;
        end;

        // ============================================
        // CARREGAR HABILIDADES DO PERSONAGEM (Tabela skills)
        // ============================================
        SQLItems := TFunctions.CreateSQL;
        try
          if not SQLItems.Query.Connection.Connected then
            Exit;

          // Consulta para pegar as habilidades do personagem
          SQLItems.SetQuery(
            'SELECT slot, item, level, type ' +
            'FROM skills WHERE owner_charid = :owner_charid'
          );
          SQLItems.Query.ParamByName('owner_charid').AsInteger := CharIDSlot2;
          SQLItems.Run;

          // Preenche a StringGrid7 com as habilidades
          while not SQLItems.Query.EOF do
          begin
            // Adiciona uma nova linha na StringGrid7
            StringGrid7.RowCount := StringGrid7.RowCount + 1;

            // Preenche os valores das colunas
            StringGrid7.Cells[0, StringGrid7.RowCount - 1] := SQLItems.Query.FieldByName('slot').AsString;  // Coluna Página
            StringGrid7.Cells[1, StringGrid7.RowCount - 1] := SQLItems.Query.FieldByName('item').AsString;  // Coluna Skill
            StringGrid7.Cells[2, StringGrid7.RowCount - 1] := SQLItems.Query.FieldByName('level').AsString;  // Coluna Nível
            StringGrid7.Cells[3, StringGrid7.RowCount - 1] := SQLItems.Query.FieldByName('type').AsString;   // Coluna Tipo

            SQLItems.Query.Next;
          end;

        finally
          SQLItems.Free;
        end;
      end;
      {$ENDREGION}

  end;

  end;
end;


end.
