unit PlayerData;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses MiscData, Windows, Generics.Collections, PartyData;
{$OLDTYPELAYOUT ON}
{$REGION 'Account Type'}

type
  TAccountType = (Player, Founder, Sponser, Moderator, GameMaster, Admin);

{$ENDREGION}
{$REGION 'Nation Data'}
{$ENDREGION}
{$REGION 'Skill List'}

type
  PSkillFromList = ^TSkillFromList;

  TSkillFromList = packed record
    Index: Word;
    Level: Word;
  end;

type
  TSkillsList = packed record
    Basics: ARRAY [0 .. 5] OF TSkillFromList;
    Others: ARRAY [0 .. 39] OF TSkillFromList;

  public
    // function GetSkill(SkillIndex : Integer) : PSkillFromList; overload;
    function GetSkill(SkillIndex: Integer): Integer; overload;
    // function GetSkill1(SkillID: Integer): Integer; overload;

  end;

{$ENDREGION}
{$REGION 'Pran Data'}

Type
  PInventory = ^TInventory;

  TInventory = packed record
    Inventory: Array [0 .. 41] of TITEM;
  end;

type
  TPranPersonality = packed record
    Cute, Smart, Sexy, Energetic, Tough, Corrupt: Word;
  end;

type
  PPran = ^TPran;

  TPran = packed record
    Id: Word; // id for spawn
    Iddb: Integer;
    ItemID: Word; // not id, yes identific
    AccId: Integer;
    Name: Array [0 .. 15] of AnsiChar;
    Level: Byte;
    ClassPran: Byte;
    CurHP, MaxHp: DWORD;
    CurMp, MaxMP: DWORD;
    Exp: DWORD;
    DefFis, DefMag: Word;
    Food: Byte;
    Devotion: Byte;
    Personality: TPranPersonality;
    Width: Byte;
    Chest: Byte;
    Leg: Byte;
    CreatedAt: DWORD;
    Updated_at: DWORD;
    Equip: Array [0 .. 15] of TITEM; // 16 itens
    Inventory: Array [0 .. 41] of TITEM; // 2 bolsas
    Skills: Array [0 .. 9] of TSkillFromList;
    // sao 10 skills mas podem ser 12 (2 novas no futuro)
    ItemBar: Array [0 .. 2] of Byte;
    IsSpawned: Boolean;
    Position: TPosition;
    MovedToCentral: Boolean;
  End;

const
  PRAN_HP_INC_PER_LEVEL = 209;
  PRAN_MP_INC_PER_LEVEL = 356;

{$ENDREGION}
{$REGION 'Character Data'}
{$REGION 'Complemento'}

type
  TSizes = packed record
    Altura, Tronco, Perna, Corpo: Byte; // 07 77 77 Padrao
  end;

type
  TAttributes = packed record
    Str, Agi, Int, Cons, Luck, Status: Word;
  end;

type
  TLife = packed record
    CurHP, MaxHp: DWORD;
    CurMp, MaxMP: DWORD;
  end;

type
  TDamage = packed record
    DNFis, DefFis: Word;
    DNMag, DefMag: Word;
    BonusDMG: Word;
  end;
{$ENDREGION}

type
  TTrade = packed record
    Itens: Array [0 .. 9] of TITEM;
    Slots: Array [0 .. 9] of Byte;
    Null: Word;
    Gold: Int64;
    Ready, Confirm: Boolean;
    OtherClientid: Word;
  end;

type
  TPlayerStatus = (WaitingLogin, CharList, Senha2, Waiting, Playing);

type
  TCitizenship = (None = 0, Server1, Server2, Server3, Server4, Server5,
    Server6, Server7, Server8, Server9, Server10);

type
  PTitleData = ^TTitleData;

  TTitleData = record
    Index: Byte;
    Level: Byte; //
    Progress: Word;
  end;

type
  TTitleList = Array [0 .. 95] of TTitleData;

{$REGION 'Buff List'}

type
  TBuffFromList = packed record
    Index: Word;
    CreationTime: TDateTime;
  end;

type
  TBuffsList = ARRAY [0 .. 59] OF TBuffFromList;

{$ENDREGION}

type
  TQuestsList = Array [0 .. 15] OF Word;

type
  TStatus = packed record
    Str, agility, Int, Cons, Luck, Status: Word;

    Sizes: TSizes;

    MaxHp, CurHP: DWORD;
    MaxMP, CurMp: DWORD;
    ServerReset: DWORD; { Hora em que reseta o Servidor do proximo dia }
    Honor: DWORD;
    KillPoint: DWORD;
    Infamia: DWORD; // chaos time
    EvilPoints: Word;
    SkillPoint: Word;
    Null_3: Array [0 .. 59] of Byte;
    UNK1: Word; // Valor 52
    DNFis, DefFis: Word;
    DNMag, DefMag: Word;
    BonusDMG: Word;
    null_4: Array [0 .. 9] of Byte;
    Critical: Word;
    Esquiva: Word;
    Acerto: Word;
  end;

type
  PCharacter = ^TCharacter;

  TCharacter = packed record
    ClientId: DWORD; // Ou word[sobraria 2bytes]
    FirstLogin: DWORD;
    CharIndex: DWORD; // talvez ID unico do char
    Name: Array [0 .. 15] of AnsiChar;
    Nation: Byte; // valor 5 talvez nação
    ClassInfo: Byte; // é a classe mesmo
    Null_1: Word;
    CurrentScore: TStatus;
    Null_6: DWORD;
    Exp: Int64; // 8Bytes
    Level: Word; // Level-1
    GuildIndex: Word;
    Null_007: Array [0 .. 31] of Byte;
    BuffsId: ARRAY [0 .. 19] OF Word;
    BuffsDuration: Array [0 .. 19] of DWORD; // UnixTime
    Equip: Array [0 .. 15] of TITEM; // 16 Itens
    Null: DWORD;
    Inventory: Array [0 .. 125] of TITEM; // 60 Itens   680~3199
    Gold: Int64; // 8 Bytes   3200~3207
    UnkBytes0: Array [0 .. 191] of Byte;
    // Tem valores desconhecidos    3208~3339
    Quests: Array [0 .. 15] of TQuest; // Max 16 Quests  3399~3623
    UnkBytes1: Array [0 .. 211] of Byte; // 3624~3835

    UNK_BYTE: DWORD; // 3836 3839  //relacionado a algum mapa, sla
    Location: DWORD; // 3840 3843

    Unk_Bytes1: Array [0 .. 127] of Byte; // 3844 3971

    CreationTime: DWORD; { Data de Criação do char }
    UnkBytes2: Array [0 .. 435] of Byte;
    Numeric: Array [0 .. 3] of AnsiChar;
    UnkBytes3: ARRAY [0 .. 211] OF Byte;

    // word1: byte;

    SkillList: ARRAY [0 .. 59] OF Word;
    // UnkBytes4: ARRAY [0 .. 3] OF byte;
    ItemBar: ARRAY [0 .. 39] OF DWORD; // itembar 4716~4875

    NULL_5: DWORD; // 4876~4879
    TitleCategoryLevel: Array [0 .. 11] of DWORD; // 4880 4927
    UNK_8: Array [0 .. 79] of Byte; // 4928 5007
    ActiveTitle: Word; // 5008 5009
    NULL_9: DWORD; // 5010 5011
    TitleProgressType8: Array [0 .. 47] of Word;
    TitleProgressType9: Array [0 .. 1] of Word;
    TitleProgressType4: Word;
    TitleProgressType10: Word;
    TitleProgressType7: Word;
    TitleProgressType11: Word;
    TitleProgressType12: Word;
    TitleProgressType13: Word;
    TitleProgressType15: Word;
    TitleProgress_UNK: Word;
    TitleProgressType16: Array [0 .. 21] of Word;
    TitleProgressType23: Word;

    TitleProgress: Array [0 .. 119] of Word;

    UnkMissions: ARRAY [0 .. 3] of Byte; // 5424 a 5427

    EndDayTime: DWORD; // 5424 a 5427
    Null_8: DWORD; // provavelmente tempo de uso disponivel do sistema de caça
    AutoCaçaTimeUsado: DWORD; // tempo de F12 disponivel
    Null_10: ARRAY [0 .. 51] OF Byte;

    UTC: DWORD;
    LoginTime: DWORD;
    LoginTime1: DWORD;

    UnkBytes7: ARRAY [0 .. 851] OF Byte;
    LoginTime2: DWORD;
    UnkBytes6: ARRAY [0 .. 11] OF Byte;

    PranName: ARRAY [0 .. 1] OF ARRAY [0 .. 15] of AnsiChar;
    Unknow: DWORD;
    // UnkBytes7: ARRAY [0 .. 1023] OF byte;
    { ItemBar: ARRAY [0 .. 031] OF DWORD; // Estranho valor e qtd [4bytes]
      UnkBytes4: ARRAY [0 .. 49] OF Word;

      Titles: ARRAY [0 .. 59] OF TTitle;
      UnkBytes5: ARRAY [0 .. 287] OF byte;
      EndDayTime: DWORD;
      Null_8: DWORD;
      Unk_0: DWORD;
      Null_9: ARRAY [0 .. 51] OF byte;
      UTC: DWORD;
      LoginTime: DWORD;
      UnkBytes6: ARRAY [0 .. 011] OF byte;
      PranName: ARRAY [0 .. 001] OF ARRAY [0 .. 15] of AnsiChar;
      Unknow: DWORD; }
  End;

{$REGION 'Struct HN'}
  { type PCharacter = ^TCharacter;
    TCharacter = packed record
    ClientId       : DWORD;
    FirstLogin     : LongBool;
    UnkNK          : DWORD;
    Name           : ARRAY [0..15]of AnsiChar;
    Nation         : Byte;
    ClassInfo      : WORD;
    CurrentScore   : TStatus;

    Exp            : DWORD;
    Level          : WORD;
    GuildId        : WORD;
    Null_6         : ARRAY [0..106] OF BYTE;

    Equip          : ARRAY [0..15] OF TItem;
    Null           : DWORD;
    Inventory      : ARRAY [0..63] OF TItem; //60 Itens  4 bolsas

    Gold,
    Gold2          : DWORD;
    UnkBytes0      : ARRAY [0..383] OF Byte;  //Tem valores desconhecidos
    Quests         : ARRAY [0..016] OF TQuest; //Max 16 Quests
    UnkBytes1      : ARRAY [0..487] OF Byte;  //Tem valores desconhecidos
    Numeric        : ARRAY [0..003] OF AnsiChar;
    UnkBytes2      : ARRAY [0..211] OF Byte;
    SkillList      : ARRAY [0..059] OF WORD;
    ItemBar        : ARRAY [0..031] OF DWORD;//Estranho valor e qtd [4bytes]
    UnkBytes3      : ARRAY [0..099] OF Byte;
    Titles         : ARRAY [0..059] OF WORD;
    UnkBytes4      : ARRAY [0..347] OF Byte;
    PranName       : ARRAY [0..001] OF ARRAY [0..15] of AnsiChar;
    Unknow         : LongInt;
    End; }

{$ENDREGION}

type
  PPlayerCharacter = ^TPlayerCharacter;

  TPlayerCharacter = packed record

    Index: DWORD;
    Base: TCharacter;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: Boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    ActiveTitle: TTitleData;
    Titles: TTitleList;


    // BasePran: TPran;

    { Não Salva }
    GuildSlot: Integer;
    DamageCritical: Word;
    ResDamageCritical: Word;
    HabAtk: Word;
    ReduceCooldown: Word;
    MagPenetration, FisPenetration: Word;
    CureTax: Word;
    CritRes, DuploRes: Word;
    PvPDamage, PvPDefense: Word;

    IngameBuffs: TList<TBuffFromList>;

    IsStorageSend, IsStoreOpened: Boolean;
    Trade: TTrade;
    TradingWith: Integer;
  end;
{$ENDREGION}
{$REGION 'Account Data'}

type
  TStoragePlayer = packed record
    Gold: Int64;
    Itens: Array [0 .. 85] of TITEM; // 85 83 + 2 pran
    // Prans: Array [0 .. 1] of TITEM;
  end;

type
  PCashInventory = ^TCashInventory;

  TCashInventory = packed record
    Cash: Cardinal;
    Items: ARRAY [0 .. 23] OF TItemCash;

    function AddItem(Index: Integer): Integer;
    function IsEmpyt(Slot: Byte): Boolean;
  end;

type
  TAccountHeader = packed record // toda conta tem
    AccountId: Integer;
    Username: String[15];
    Password: String[32];
    Token: TPlayerToken;
    Nation: TCitizenship;
    IsActive: Boolean;
    AccountStatus: Byte;
    AccountType: TAccountType;
    PremiumTime: TDateTime;
    BanDays: Integer;
    IsFounder: Boolean;
    FounderLevel: Integer;

    Pran1: TPran;
    Pran2: TPran;

    Storage: TStoragePlayer;
    NumError: Array [0 .. 2] of Byte;
    NumericToken: Array [0 .. 2] of String[4];
    PlayerDelete: Array [0 .. 2] of Boolean;

    CashInventory: TCashInventory;
  end;

type
  TBasicCharacter = packed record
    Index: DWORD;
    Base: TCharacter;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: Boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

  end;

type
  TCharacterDB = packed record
    Index: DWORD;
    Base: TCharacter;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: Boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    ActiveTitle: TTitleData;
  end;

type
  Custom_TCharacterDB = packed record
    Index: DWORD;
    Base: TCharacter;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: Boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    ActiveTitle: TTitleData;
  end;

type
  TAccountFile = packed record
    Header: TAccountHeader;
    Characters: ARRAY [0 .. 2] OF TCharacterDB;
    CharactersDelete: Array [0 .. 2] of Boolean;
    CharactersDeleteTime: Array [0 .. 2] of String[32];
    PranEvoCnt: Byte;

  public
    function GetCharCount(AccId: Integer; ch: Word; Player: Pointer): Byte;
  end;

{$REGION 'Change Channel'}

type
  TChangeChannelToken = packed record
    CharSlot: Byte;
    ChangeTime: TTime;
    OldClientID: Word;
    OldChannelID: Byte;
    PartyTeleport: TParty;
    PartiesTeleport: Array [0 .. 3] of TParty;
    PartiesLeader: Array [0 .. 3] of Integer;
    AccountStatus: Byte;
    accFromOther: TAccountFile;
    charFromOther: TPlayerCharacter;
    buffFromOther: TBuffsList;
  end;

type
  TPlayerData1 = record
    Name: string[16]; // Até 16 caracteres para o nome
    Action: Integer;
  end;

type
  TTentativas = record
    Login: string[16]; // Até 16 caracteres para o nome
    Erros: Integer;
    LastTentativa: TDateTime;
  end;

type
  TBlockedIps = record
    IP: string[60]; // Até 16 caracteres para o nome
    LastBlock: TDateTime;
  end;

type
  TMudandoCanal = record
    Nome: string;
  end;

  // type
  // TLogados = record
  // ClientID: Integer;
  // ChannelIndex: Integer;
  // end;
type
  TSkillEnviada = record
    Nome: String;
    SkillID: Integer;
    Horario: TDateTime;
  end;

{$ENDREGION}
{$ENDREGION}
{$REGION 'NPC Data'}

type
  PCustomNpc = ^TCustomNpc;

  TCustomNpc = packed record
    ClientId: DWORD; // Ou word[sobraria 2bytes]
    FirstLogin: DWORD;
    CharIndex: DWORD; // talvez ID unico do char
    Name: Array [0 .. 15] of AnsiChar;
    Nation: Byte; // valor 5 talvez nação
    ClassInfo: Byte; // é a classe mesmo
    Null_1: Word;
    CurrentScore: TStatus;

    Null_6: DWORD;
    Exp: Int64; // 8Bytes
    Level: Word; // Level-1
    GuildIndex: Word;
    Null_007: Array [0 .. 31] of Byte;
    BuffsId: ARRAY [0 .. 19] OF Word;
    BuffsDuration: Array [0 .. 19] of DWORD; // UnixTime
    Equip: Array [0 .. 15] of TITEM; // 16 Itens
    Null: DWORD;
    Inventory: Array [0 .. 63] of TITEM; // 60 Itens
    Gold: Int64; // 8 Bytes
    UnkBytes0: Array [0 .. 191] of Byte; // Tem valores desconhecidos
    Quests: Array [0 .. 15] of TQuest; // Max 16 Quests
    UnkBytes1: Array [0 .. 211] of Byte;

    UNK_BYTE: DWORD;
    Location: DWORD;

    Unk_Bytes1: Array [0 .. 127] of Byte;

    CreationTime: DWORD; { Data de Criação do char }
    UnkBytes2: Array [0 .. 435] of Byte;
    Numeric: Array [0 .. 3] of AnsiChar;
    UnkBytes3: ARRAY [0 .. 211] OF Byte;
    SkillList: ARRAY [0 .. 59] OF Word;
    ItemBar: ARRAY [0 .. 23] OF DWORD;
    // Estranho valor e qtd [4bytes] era 24 no c++
    NULL_5: DWORD;
    TitleCategoryLevel: Array [0 .. 11] of DWORD;
    UNK_8: Array [0 .. 79] of Byte;
    ActiveTitle: Word;
    NULL_9: DWORD;
    TitleProgressType8: Array [0 .. 47] of Word;
    TitleProgressType9: Array [0 .. 1] of Word;
    TitleProgressType4: Word;
    TitleProgressType10: Word;
    TitleProgressType7: Word;
    TitleProgressType11: Word;
    TitleProgressType12: Word;
    TitleProgressType13: Word;
    TitleProgressType15: Word;
    TitleProgress_UNK: Word;
    TitleProgressType16: Array [0 .. 21] of Word;
    TitleProgressType23: Word;

    TitleProgress: Array [0 .. 119] of Word;
    EndDayTime: DWORD;
    Null_8: DWORD;
    Unk_0: DWORD;
    Null_10: ARRAY [0 .. 51] OF Byte;
    UTC: DWORD;
    LoginTime: DWORD;
    UnkBytes6: ARRAY [0 .. 11] OF Byte;
    PranName: ARRAY [0 .. 1] OF ARRAY [0 .. 15] of AnsiChar;
    Unknow: DWORD;

  End;

type
  TNPCHeader = packed record
    Title: string[35];
    Options: ARRAY [0 .. 9] OF Byte;
    Reserved: ARRAY [0 .. 511] OF Byte;
  end;

type
  TBasicNpc = packed record
    Index: DWORD;
    Base: TCustomNpc;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: Boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    // BasePran: TPran;
  end;

type
  TNPCFile = packed record
    Header: TNPCHeader;
    Base: TBasicNpc;
  end;

type
  PNpcCharacter = ^TNpcCharacter;

  TNpcCharacter = packed record

    Index: DWORD;
    Base: TCustomNpc;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: Boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    ActiveTitle: TTitleData;
    Titles: TTitleList;


    // BasePran: TPran;

    { Não Salva }
    GuildSlot: Integer;
    DamageCritical: Word;
    ResDamageCritical: Word;
    HabAtk: Word;
    ReduceCooldown: Word;
    MagPenetration, FisPenetration: Word;
    CureTax: Word;
    CritRes, DuploRes: Word;
    PvPDamage, PvPDefense: Word;

    IngameBuffs: TList<TBuffFromList>;

    IsStorageSend, IsStoreOpened: Boolean;
    Trade: TTrade;
    TradingWith: Integer;
  end;

type
  TNpcDB = packed record
    Index: DWORD;
    Base: TCustomNpc;
    SpeedMove: Word;
    DuploAtk: Word;
    Rotation: Word;
    Resistence: Word;

    LastAction: TTime;
    LastLogin: TDateTime;
    LoggedTime: Cardinal;

    PlayerKill: Boolean; // PK
    LastPos: TPosition; // Ultima coordenada
    CurrentPos: TPosition; // Atual

    Skills: TSkillsList;
    Buffs: TBuffsList;
    Quests: TQuestsList;

    ActiveTitle: TTitleData;
  end;

{$ENDREGION}
{$REGION 'Friend List Data'}

type
  TFriend = packed record
    Index: DWORD;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
  end;

  TFriendListFile = ARRAY [0 .. 49] OF TFriend;

type
  TFriendStatus = (BlockedOff, BlockedOn, Offline, Online);

{$ENDREGION}
{$REGION 'City e Location Data'}

type
  TCity = (NoneLocation, Regenshein, Verband, Crac_des_Chevelier, Amarkand,
    Ursula, HeklaCave, Halperin, Sigmund, Mina_Lenfer, Basilan, Mt_Hessen,
    Cahil, Agross);

{$ENDREGION}

type
  TMobTarget = record
    ClientId: smallint;
    TargetType: Byte; // 0 para player, 1 para mobs
    Position: TPosition;

    Player: Pointer;
    Mob: Pointer;
  end;

{$OLDTYPELAYOUT OFF}

implementation

uses
  GlobalDefs, SysUtils, Player, Log, SQL;

{$REGION 'Account Data'}

function TAccountFile.GetCharCount(AccId: Integer; ch: Word;
  Player: Pointer): Byte;
var
  SQLComp: TQuery;
begin
  SQLComp := TQuery.Create(MYSQL_SERVER, MYSQL_PORT, MYSQL_USERNAME,
    MYSQL_PASSWORD, MYSQL_DATABASE);

  try
    SQLComp.SetQuery
      ('SELECT * FROM characters WHERE owner_accid = :powner_accid');
    SQLComp.AddParameter('powner_accid', IntToStr(AccId));
    SQLComp.Run();
    Result := SQLComp.Query.RecordCount;
  finally
    SQLComp.Free;
  end;
end;

{$REGION 'Cash Inventory'}

function TCashInventory.AddItem(Index: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to 23 do
    if Self.Items[i].Index = 0 then
    begin
      Self.Items[i].Index := Index;
      Result := i;
      Break;
    end;
end;

function TCashInventory.IsEmpyt(Slot: Byte): Boolean;
begin
  Result := Self.Items[Slot].Index = 0;
end;

{$ENDREGION}
{$ENDREGION}
{$REGION 'Skills'}

function TSkillsList.GetSkill(SkillIndex: Integer): Integer;
var
  i: Integer;
begin
  Result := -1;

  for i := 0 to Length(Self.Others) - 1 do
  begin
    if (Self.Others[i].Index = SkillIndex - (SkillData[SkillIndex].Level + 1))
    then
    begin
      Result := i;
      Break;
    end;
  end;
end;

{$ENDREGION}

end.
