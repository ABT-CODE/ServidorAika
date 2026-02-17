unit Packets;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  PlayerData, Windows, MiscData, GuildData;
{$OLDTYPELAYOUT ON}
{$REGION 'Packet Header'}

type
  TPlayerKey = record
    ServerID: byte;
    ClientID: byte;
  end;


type
  PPacketHeader = ^TPacketHeader;

  TPacketHeader = packed record
    Size: WORD;
    Key: Byte;
    ChkSum: Byte;
    Index, Code: WORD;
    Time: DWORD;
  end;

type
  TSignalData = packed record
    Header: TPacketHeader;
    Data: DWORD;
  end;
{$ENDREGION}
{$REGION 'Entrar Elter'}

type
  PPacket_0394 = ^TEntrarElter;

  TEntrarElter = packed record
    Header: TPacketHeader;
    Size: WORD;
    Key: Byte;
    ChkSum: Byte;
    Index: WORD;
    Code: WORD;
    Time: DWORD;
  end;

type
  PPacket_394 = ^TShowElterDialog;

  TShowElterDialog = packed record
    Header: TPacketHeader;
    Tempo: DWORD;
  end;

type
  PPacket_01AA = ^TElterPlacar; // $1AA

  TElterPlacar = packed record
    Header: TPacketHeader;
    Status: DWORD;
    // deixar sempre 0 pra nao aparecer o bagulho de pontuar 50 pontos
    Contagem: DWORD; // contagem de tempo
  end;

type
  PPacket_199 = ^TElterFecharPlacar; // $199

  TElterFecharPlacar = packed record
    Header: TPacketHeader;
    Status: DWORD;
    // usar pra fechar o placar enviar "6" usar pra abrir placar enviar "4" e "1" pra liberar skills
    TempoRestante: DWORD;

  end;

type
  PPacket_1AC = ^TElterPontuacao; // $1AC

  TElterPontuacao = packed record
    Header: TPacketHeader;
    TeamRed: DWORD;
    TeamBlue: DWORD;
  end;

type
  PPacket_1AB = ^TElterQuantidade; // $1AB

  TElterQuantidade = packed record
    Header: TPacketHeader;
    TeamRed: DWORD;
    TeamBlue: DWORD;
  end;

{$ENDREGION}

type
  PPacket_310 = ^TJoquempoVisual;

  TJoquempoVisual = packed record { 0xF05 }
    Header: TPacketHeader;
    Padrao: DWORD;
  end;

type
  PPacket_222 = ^TJoquempoStart;

  TJoquempoStart = packed record { 0xF05 }
    Header: TPacketHeader;
    Padrao: DWORD;
  end;

type
  PPacket_233 = ^TJoquempoContagem;

  TJoquempoContagem = packed record { 0xF05 }
    Header: TPacketHeader;
    Padrao: DWORD;
  end;

{$REGION 'Karak Aéreo'}

type
  PPacket_0308 = ^TKarakAereo;

  TKarakAereo = packed record
    Header: TPacketHeader;
    Type1: Byte;
    Type2: Byte;
    Type3: Byte;
    Type4: Byte;
  end;

type
  PPacket_218 = ^TUseMountSkill;

  TUseMountSkill = packed record
    Header: TPacketHeader;
    SkillID: Byte;
    Unk0: Byte;
  end;

{$ENDREGION}
{$REGION 'ClientMessage & Chat Packet'}

type
  PPacket_984 = ^TClientMessagePacket; // size 0x90 [144]

  TClientMessagePacket = packed record
    Header: TPacketHeader;
    Null: Byte; // valor 10+ msg amarela
    Type1: Byte; // relacionado com tamanho
    Type2: Byte; // tbm ou cor
    Null1: Byte;
    Msg: string[128];
  end;

type
  PPacket_22D = ^TLinkItemPacket;

  TLinkItemPacket = packed record
    Header: TPacketHeader;
    LinkItem: Boolean;
    ItemSlot: Byte;
    ChatType: WORD;
    Null_0: ARRAY [0 .. 15] OF Byte;
    Fala: ARRAY [0 .. 127] of AnsiChar;
  end;

type
  PPacket_F6F = ^TChatItemLinkPacket;

  TChatItemLinkPacket = packed record
    Header: TPacketHeader;
    Nick: ARRAY [0 .. 15] of AnsiChar;
    ChatType: DWORD;
    Null_0: DWORD;
    Item: TItem;
    Fala: ARRAY [0 .. 127] of AnsiChar;
  end;

type
  PPacket_F86 = ^TChatPacket;

  TChatPacket = packed record
    Header: TPacketHeader;
    TypeChat: WORD;
    NotUse: Array [0 .. 5] of Byte;
    Color: DWORD;
    Nick: Array [0 .. 15] of AnsiChar; // 16 letras
    Fala: Array [0 .. 127] of AnsiChar; // 128
  end;
{$ENDREGION}
{$REGION 'Login / CharList Packets'}

type
  PPacket_685 = ^TRequestLoginPacket;

  TRequestLoginPacket = packed record
    Header: TPacketHeader;
    AccountId: DWORD;
    Username: ARRAY [0 .. 31] OF AnsiChar;
    Time: DWORD;
    MacAddr: ARRAY [0 .. 13] OF Byte;
    Version: WORD;
    Null: DWORD;
    Token: ARRAY [0 .. 31] OF AnsiChar;
    Null_1: ARRAY [0 .. 991] OF Byte;
  End;

type
  TCharacterListData = packed record
    Name: ARRAY [0 .. 15] OF AnsiChar;
    Nation, ClassInfo: WORD;
    Size: TSizes;
    Equip: ARRAY [0 .. 07] OF WORD;
    Refine: ARRAY [0 .. 11] OF Byte; // Arma [07]
    Attributes: TAttributes;
    Level: WORD;
    Null_1: array [0 .. 5] of Byte;
    Exp, Gold: Int64;
    Null_2: array [0 .. 3] of Byte;
    DeleteTime: DWORD;
    NumericError: Byte;
    NumRegister: Boolean;
    NotUse: ARRAY [0 .. 5] OF Byte;
  end;

type
  PPacket_901 = ^TSendToCharListPacket;

  TSendToCharListPacket = packed record
    Header: TPacketHeader;
    AcountID, Unk, NotUse: DWORD;
    CharactersData: ARRAY [0 .. 2] OF TCharacterListData;
  End;

type
  PPacket_603 = ^TSendToCharListPacket;

  TDeleteCharacterRequestPacket = packed record
    Header: TPacketHeader;
    AcountSerial, SlotIndex: DWORD;
    Delete: LongBool;
    Numeric: ARRAY [0 .. 3] OF AnsiChar;
  end;

Type
  PPacket_3E04 = ^TCreateCharacterRequestPacket;

  TCreateCharacterRequestPacket = packed record
    Header: TPacketHeader;
    AcountID, SlotIndex: DWORD;
    Name: ARRAY [0 .. 15] OF AnsiChar;
    ClassIndex, Cabelo: WORD;
    Null: ARRAY [0 .. 11] OF Byte;
    Local: DWORD;
  end;

type
  PPacket_81 = ^TCheckTokenPacket;

  TCheckTokenPacket = packed record
    Header: TPacketHeader;
    Username: ARRAY [0 .. 31] OF AnsiChar;
    Token: ARRAY [0 .. 31] OF AnsiChar;
    Null_1: ARRAY [0 .. 1039] OF Byte;
  end;

type
  PPacket_82 = ^TResponseLoginPacket;

  TResponseLoginPacket = packed record
    Header: TPacketHeader;
    Index, Time: DWORD;
    Nation: TCitizenship;
    Null_1: DWORD;
  end;

type
  TDeleteChar = packed record
    Header: TPacketHeader;
    Unknown: DWORD;
    Slot: DWORD;
    Numeric: Array [0 .. 3] of AnsiChar;
    UnkBytes: Array [0 .. 31] of Byte;
  end;
{$ENDREGION}
{$REGION 'Numeric Packet'}

type
  PPacket_F02 = ^TNumericTokenPacket;

  TNumericTokenPacket = packed record
    Header: TPacketHeader;
    Slot, RequestChange: DWORD;
    Numeric_1, Numeric_2: ARRAY [0 .. 3] OF AnsiChar;
  End;
{$ENDREGION}
{$REGION 'Spawn & Unspawn'}

type
  PPacket_349_Npc = ^TSendCreateNpcPacket;

  TSendCreateNpcPacket = packed record // PlayerSpawn
    Header: TPacketHeader;
    Name: ARRAY [0 .. 15] OF AnsiChar;
    Equip: Array [0 .. 7] of WORD;
    // ItemEffPedra: WORD;
    // ItemEffMontaria: WORD;
    // ItemEffUnk0: Array [0 .. 2] of Byte;  //aqui que fica algo sobre a montaria
    // ItemEffArmaRefine: byte;
    // ItemEffUnk1: Array [0 .. 3] of Byte;
    /// /    ItemEff: Array [0 .. 5] of WORD;
    ItemEff: Array [0 .. 11] of Byte; // aqui que fica algo sobre a montaria
    Position: TPosition;
    Rotation: DWORD; // Null
    MaxHP, MaxMP, CurHP, CurMP: DWORD;
    Unk0: Byte;
    SpeedMove: Byte;
    SpawnType: Byte;
    Altura, Tronco, Perna, Corpo: Byte;
    IsService: Byte; // 2bytes
    EffectType: WORD;
    SetBuff: WORD; // buff é o do set
    Buffs: Array [0 .. 59] OF WORD; // 60 buffs
    Time: Array [0 .. 59] of DWORD;
    Title: ARRAY [0 .. 31] OF AnsiChar; // 31
    GuildIndexAndNation: WORD;
    Effects: Array [0 .. 3] of WORD;
    Unk: Byte;
    ChaosPoint: Byte;
    Null: LongInt;
    TitleId, TitleLevel: Byte;
    Null1: WORD;
  End;

type
  PPacket_349 = ^TSendCreateMobPacket;

  TSendCreateMobPacket = packed record // PlayerSpawn
    Header: TPacketHeader;
    Name: ARRAY [0 .. 15] OF AnsiChar;
    Equip: Array [0 .. 7] of WORD;

    ItemEffPedra: WORD;
    ItemEffMontaria: WORD;
    ItemEffUnk0: Array [0 .. 2] of Byte; // aqui que fica algo sobre a montaria
    ItemEffArmaRefine: Byte;
    ItemEffUnk1: Array [0 .. 3] of Byte;
    // ItemEff: Array [0 .. 11] of Byte;  //aqui que fica algo sobre a montaria
    Position: TPosition;
    Rotation: DWORD; // Null
    MaxHP, MaxMP, CurHP, CurMP: DWORD;
    Unk0: Byte;
    SpeedMove: Byte;
    SpawnType: Byte;
    Altura, Tronco, Perna, Corpo: Byte;
    IsService: Byte; // 2bytes
    EffectType: WORD;
    SetBuff: WORD; // buff é o do set
    Buffs: Array [0 .. 59] OF WORD; // 60 buffs
    Time: Array [0 .. 59] of DWORD;
    Title: ARRAY [0 .. 31] OF AnsiChar; // 31
    GuildIndexAndNation: WORD;
    Effects: Array [0 .. 3] of WORD;
    Unk: Byte;
    ChaosPoint: Byte;
    Null: LongInt;
    TitleId, TitleLevel: Byte;
    Null1: WORD;
  End;

type
  PPacket_349_2 = ^TSendCreatePranPacket;

  TSendCreatePranPacket = packed record // PlayerSpam
    Header: TPacketHeader; // 0~11
    Name: ARRAY [0 .. 15] OF AnsiChar; // 12~27
    Equip: Array [0 .. 7] of WORD; // 28~43
    ItemEff: Array [0 .. 11] of Byte; // 44~55
    Position: TPosition; // 56~63
    Rotation: DWORD; // 64~67
    MaxHP, MaxMP, CurHP, CurMP: DWORD; // 68~83
    Unk0: Byte; // 84
    SpeedMove: Byte; // 85
    SpawnType: Byte; // 86
    Altura, Tronco, Perna: Byte; // 87~89
    PranClientID: WORD; // 90~91
    EffectType: WORD; // 92~93
    SetBuff: WORD; // buff é o do set //94~95
    Buffs: Array [0 .. 59] OF WORD; // 96~215
    Time: Array [0 .. 59] of DWORD; // 216~455
    Title: ARRAY [0 .. 31] OF AnsiChar; // 456~487
    GuildIndexAndNation: WORD; // 488~489
    Effects: Array [0 .. 3] of WORD; //
    Unk: Byte;
    ChaosPoint: Byte;
    Null: LongInt;
    TitleId, TitleLevel: Byte;
    Null1: WORD;
  End;

type
  PPacket_35E = ^TSpawnMobPacket;

  TSpawnMobPacket = packed record
    Header: TPacketHeader;
    Equip: Array [0 .. 7] of WORD;
    Position: TPosition;
    Rotation: DWORD;
    CurHP, CurMP, MaxHP, MaxMP: DWORD;
    Unk_1: WORD;
    Level: WORD;
    Null_0: WORD; // 00 00
    IsService: WordBool; // 2bytes
    Effects: Array [0 .. 3] of Byte; // 00 00 00 00
    SpawnType: Byte;
    Altura, Tronco, Perna: Byte;
    Corpo: WORD;
    MobType: Byte; { Humanoide, Animal, Planta, etc }
    Nation: Byte;
    MobName: WORD;
    Unk_2: ARRAY [0 .. 2] OF WORD;
  end;

type
  PPacket_101 = ^TSendRemoveMobPacket;

  TSendRemoveMobPacket = packed record
    Header: TPacketHeader;
    Index, DeleteType: DWORD;
  end;

type
  PPacket_304 = ^TSendActionPacket;

  TSendActionPacket = packed record
    Header: TPacketHeader;
    Index: DWORD;
    InLoop: DWORD;
  end;
{$ENDREGION}
{$REGION 'SendToWord Packet's'}

  // {$MINENUMSIZE 4}
  // {$ALIGN ON}
type
  PPacket_925 = ^TSendToWorldPacket;

  TSendToWorldPacket = packed record
    Header: TPacketHeader;
    AcountSerial: DWORD;
    Character: TCharacter;
  end;

  PPacket_139 = ^TSendUnkNovo2;

  TSendUnkNovo2 = packed record
    Header: TPacketHeader;
    Unk1: WORD;
  end;

type
  PPacket_3F1B = ^TSendUnkNovo1; // correios atuais

  TSendUnkNovo1 = packed record
    Header: TPacketHeader;
    Unk1: WORD;
  end;

type
  PPacket_103 = ^TSendCurrentHPMPPacket; // 0x20

  TSendCurrentHPMPPacket = packed record
    Header: TPacketHeader;
    MaxHP, CurHP: DWORD;
    MaxMP, CurMP: DWORD;
    Null: DWORD;
  End;

type
  PPacket_106 = ^TSendSkillsPacket; // pacote skills zerar cd da barra

  TSendSkillsPacket = packed record
    Header: TPacketHeader;
    NPCIndex: WORD;
    SendType: WORD;
    Skills: ARRAY [0 .. 39] OF WORD;
  end;

type
  PPacket_107 = ^TSendSkillsLevelPacket;

  TSendSkillsLevelPacket = packed record
    Header: TPacketHeader;
    Skills: ARRAY [0 .. 59] OF WORD;
    SkillPoints: WORD;
    Unk: WORD; { 0xCCCC }
  end;

type
  PPacket_108 = ^TSendCurrentLevel;

  TSendCurrentLevel = packed record
    Header: TPacketHeader;
    Level: WORD;
    Unk: WORD; // CCCC
    Exp: UInt64;
  End;

type
  TPoints = packed record
    Forç, AGI, INTE, CON, SORT, Status: WORD;
  end;

type
  PPacket_109 = ^TSendRefreshPoint;

  TSendRefreshPoint = packed record
    Header: TPacketHeader;
    Pontos: TPoints;
    StatusPoint: WORD;
    SkillsPoint: WORD;
  End;

type
  PPacket_10A = ^TSendRefreshStatus;

  TSendRefreshStatus = packed record
    Header: TPacketHeader;
    DNFis, DefFis: WORD;
    DNMag, DEFMag: WORD;
    Null1: Array [0 .. 11] of Byte;

    SpeedMove: WORD;
    Null2: Array [0 .. 7] of Byte;
    Critico: WORD;
    Null3: Array [0 .. 1] of Byte;
    Esquiva, Acerto: WORD;
    Duplo, Resist: WORD;

  End;

type
  PPacket_10D = ^Tp10D;

  Tp10D = packed record
    Header: TPacketHeader; // pacote de pontos de exclamacao das quest
    Unk1, { C5 08 } // npcid??
    Unk2: DWORD; { 05 } // npc option??
  end;

type
  PPacket_117 = ^TSendClientIndexPacket;

  TSendClientIndexPacket = packed record
    Header: TPacketHeader;
    Index, Effect: DWORD;
  end;

type
  PPacket_11F = ^Tp11F;

  Tp11F = packed record
    Header: TPacketHeader;
    Unk, Null: DWORD;
  end;

type
  PPacket_12C = ^Tp12C;

  Tp12C = packed record
    Header: TPacketHeader; // aqui o pacote do reset skill dual (clientid =0)
    NPCIndex: WORD; // vai 00
    SendType: WORD; // vai 00
    Skills: ARRAY [0 .. 39] OF WORD; // 24
  end;

type
  PPacket_131 = ^Tp131;

  Tp131 = packed record
    Header: TPacketHeader;
    Unk_1, { FF FF FF FF }
    Unk_2: DWORD;
  end;

type
  PPacket_186 = ^Tp186;

  Tp186 = packed record
    Header: TPacketHeader;
    Unk_0: DWORD;
    Unk_1: DWORD;
    Unk_2: DWORD;
    Unk: ARRAY [0 .. 115] OF Byte;
  end;

type
  PPacket_227 = ^Tp227;

  Tp227 = packed record
    Header: TPacketHeader;
    Unk_0: WORD;
    Unk_1: WORD;
    Unk_2: DWORD;
    Unk_3: DWORD;
    Unk_4: DWORD;
  end;

type
  PPacket_33D = ^Tp33D;

  Tp33D = packed record
    Header: TPacketHeader;
    Unk: ARRAY [0 .. 39] OF Byte;
  end;

type
  PPacket_357 = ^Tp357;

  Tp357 = packed record
    Header: TPacketHeader;
    Null, Null1, { 80 90 }
    Null2: DWORD;
  end;

type
  PPacket_3A2 = ^Tp3A2;

  Tp3A2 = packed record
    Header: TPacketHeader;
    Null, Null1: DWORD;
  end;

type
  PPacket_94C = ^Tp94C;

  Tp94C = packed record
    Header: TPacketHeader;
    Unk: ARRAY [0 .. 151] OF Byte;
  end;

type
  TNumbers = packed record
    Null_0: WORD;
    Index: WORD;
    Null_1: ARRAY [0 .. 8] OF DWORD;
  end;

type
  PPacket_D41 = ^TSendNumbersPacket;

  TSendNumbersPacket = packed record
    Header: TPacketHeader;
    AccountId: DWORD;
    Null_0: ARRAY [0 .. 15] OF Byte;
    Numbers: ARRAY [0 .. 11] OF TNumbers;
  end;

{$ENDREGION}
{$REGION 'Pran Packets'}

type
  TPranPutName = packed record
    Header: TPacketHeader;
    Unknown: DWORD;
    Name: Array [0 .. 15] of AnsiChar;
    Unknown2: DWORD;
  end;

type
  PPacket_3E02 = ^TRenamePranPacket;

  TRenamePranPacket = packed record
    Header: TPacketHeader;
    Slot: DWORD;
    Name: Array [0 .. 15] of AnsiChar;
    AccountId: DWORD;
  end;

type
  PPacket_1A1 = ^TSendPranView;

  TSendPranView = packed record
    Header: TPacketHeader;
    Name: Array [0 .. 15] of AnsiChar;
    PranClass: Byte;
    // 61 fire / 71 water / 81 air           Byte: 3F VALOR 63 da classe
    Food: Byte; // Byte: 4c VALOR 63%
    Personality: WORD; // Byte: 01 00 personalidade
    Devotion: DWORD; // Byte: 6F 00 00 00 familiaridade valor 49%
    MaxHP, CurHP, MaxMP, CurMP: DWORD;
    // 2C 19 00 00 - 6444 - 2C 19 00 00  3F 29 00 00 - 10559 - 3F 29 00 00
    Exp: DWORD; // 09 BE 10 00 - 1097225
    DefFis, DEFMag: WORD; // EF 00   //68 00
    Unk: Array [0 .. 19] of Byte;
    // 69 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    Equip1: Array [1 .. 7] of TItem;
    // 69 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    // Equips: Array [0..6] of TItem; // 00 00 80 26 00 00 00 00 00 00 0F 0F 0F 02 02 02
    // Unk1: Byte;
    Unk1: Byte;
    Unk2: Byte;
    Unk3: Byte;
  end;

type
  PPacket_907 = ^TSendPranToWorld;

  TSendPranToWorld = packed record
    Header: TPacketHeader;
    Name: Array [0 .. 15] of AnsiChar;
    PranClass: Byte; // 61 fire / 71 water / 81 air
    Food: Byte;
    Personality: WORD;
    Devotion: DWORD;
    MaxHP, CurHP, MaxMP, CurMP: DWORD;
    Exp: DWORD;
    DefFis, DEFMag: WORD;
    Unk: Array [0 .. 15] of Byte;
    Equips: Array [0 .. 15] of TItem;
    Inventory: Array [0 .. 41] of TItem; // 40 itens + 2 bags
    PranSkillBar: Array [0 .. 2] of Byte;
    Unk2: Array [0 .. 40] of Byte;
  end;

type
  PPacket_18E = ^TSeeInventory;

  TSeeInventory = packed record
    Header: TPacketHeader;
    Inventory: Array [0 .. 125] of TItem; // 60 Itens   680~3199
    Unk: DWORD; // 60 Itens   680~3199
    Gold: Int64;
  end;

type
  PMoveSkillPranBar_31E = ^TMoveSkillPranBar;

  TMoveSkillPranBar = packed record
    Header: TPacketHeader;
    Slot: DWORD; // 00 / 01 / 02
    TypeItem: DWORD; // Sempre com valor 03, deve ser o tipo da barra
    SkillBarID: DWORD;
  end;

type
  PRefreshPranDevotionFoodPacket_96B = ^TRefreshPranDevotionFoodPacket;

  TRefreshPranDevotionFoodPacket = packed record
    Header: TPacketHeader;
    Devotion: WORD; // 127
    Food: WORD; // 120 (xp string)
  end;

type
  PRefreshPranLevelExpPacket_116 = ^TRefreshPranLevelExpPacket;

  // index = $7535
  TRefreshPranLevelExpPacket = packed record
    Header: TPacketHeader;
    Level: DWORD;
    Exp: Int64;
  end;
{$ENDREGION}
{$REGION 'Fishing Packets'}

type
  PPacket_362 = ^TStartFishing; // qnd inicia a pesca via call da skill

  TStartFishing = packed record
    Header: TPacketHeader;
    Position: TPosition;
    barX1, barX2: WORD;
    Null1: DWORD;
    // provavelmente quando tá 1 é porquê é item automatico tipo isca de facion
    Null2: DWORD;
  end;

type
  PPacket_363 = ^TEndFishing;
  // qnd cancela de alguma forma a pesca, andando, dando espaço, etc

  TEndFishing = packed record
    Header: TPacketHeader;
    Result: DWORD;
  end;
{$ENDREGION}
{$REGION 'Dungeon Packets'}

type
  PPacket_119 = ^TSendDungeonDialog;

  TSendDungeonDialog = packed record
    Header: TPacketHeader;
    Dungeon: DWORD;
    Entering: Byte;
    LevelMin: Byte;
    Unk2: Array [0 .. 5] of Byte;
  end;

type
  PPacket_334 = ^TSelectDungeonToEnter;

  TSelectDungeonToEnter = packed record
    Header: TPacketHeader;
    Dificult: DWORD;
  end;

type
  PPacket_145 = ^TSendPlayersLobbyDungeon;

  TSendPlayersLobbyDungeon = packed record
    Header: TPacketHeader;
    Dungeon: WORD;
    Dificult: WORD;
    PlayersParty1: Array [0 .. 5] of DWORD;
    PlayersParty2: Array [0 .. 5] of DWORD;
    PlayersParty3: Array [0 .. 5] of DWORD;
    PlayersParty4: Array [0 .. 5] of DWORD;
    UnkPlayersRecord: Array [0 .. 23] of DWORD;
  end;

type
  PPacket_355 = ^TConfirmDungeonEnter;

  TConfirmDungeonEnter = packed record
    Header: TPacketHeader;
    Index: DWORD;
  end;

type
  TRequestDgPacket = record
    Header: TPacketHeader;
    Difficulty: DWORD;
  end;

type
  TReadyDgPacket = record
    Header: TPacketHeader;
    Accept: DWORD;
  end;
{$ENDREGION}
{$REGION 'Moviment Packet'}

type
  PPacket_301 = ^TMovementPacket;

  TMovementPacket = packed record
    Header: TPacketHeader;
    Destination: TPosition;
    Null: Array [0 .. 5] of Byte;
    MoveType: Byte;
    Speed: Byte;
    Unk: DWORD;
  end;
{$ENDREGION}
{$REGION 'Item & Inventory Packets'}

type
  PPacket_32B = ^TMakeItemPacket;

  TMakeItemPacket = packed record
    Header: TPacketHeader;
    ItemID: WORD;
    Null: WORD;
    Amount: WORD;
    Null2, Null3, Null4: WORD; // null3 = 1 quando desmontando item
  end;

type
  PPacket_32C = ^TDeleteItemPacket;

  TDeleteItemPacket = packed record
    Header: TPacketHeader;
    Slot, TypeSlot: DWORD;
  end;

type
  PPacket_332 = ^TAgroupItemPacket;

  TAgroupItemPacket = packed record
    Header: TPacketHeader;
    SrcSlot, DestSlot: DWORD;
  end;

type
  PPacket_333 = ^TUngroupItemPacket;

  TUngroupItemPacket = packed record
    Header: TPacketHeader;
    Slot, Quantidade, SlotType: DWORD;
  end;

type
  PPacket_70F = ^TMoveItemPacket;

  TMoveItemPacket = packed record
    Header: TPacketHeader;
    DestType, DestSlot, SrcType, SrcSlot: WORD;
  end;

type
  TMountItem = packed record
    Index, APP: WORD;
    Identific: LongInt;
    Slot1, Slot2, Slot3: WORD;
    Enc1, Enc2, Enc3: Byte;
    MIN: Byte;
    Time: WORD;
  end;

type
  TPranItem = packed record
    Index, APP: WORD;
    Identific: LongInt;
    CreationTime: DWORD;
    Devotion: Byte; // ? % 0~127?
    State: Byte; // 00 normal / 01 fada / 02 fire / 03 water / 04 air
    Level: Byte;
    NotUse: Array [0 .. 4] of Byte;
    // na vdd usa sim. [0] tem haver com os nomes das prans
  end;

type
  PPacket_F0E = ^TRefreshItemPacket;

  TRefreshItemPacket = packed record
    Header: TPacketHeader;
    Notice: Boolean;
    TypeSlot: Byte;
    Slot: WORD;
    Item: TItem;
  End;

type
  PPacket_F0E_1 = ^TRefreshMountPacket;

  TRefreshMountPacket = packed Record
    Header: TPacketHeader;
    Notice: Boolean;
    TypeSlot: Byte;
    Slot: WORD;
    Item: TMountItem;
  end;

type
  PPacket_F0E_2 = ^TRefreshItemPranPacket;

  TRefreshItemPranPacket = packed record
    Header: TPacketHeader;
    Notice: Boolean;
    TypeSlot: Byte;
    Slot: WORD;
    Item: TPranItem;
  end;

type
  PPacket_312 = ^TRefreshMoneyPacket;

  TRefreshMoneyPacket = packed record
    Header: TPacketHeader;
    Unk: DWORD;
    InventoryGold: UInt64;
    ChestGold: UInt64;
  end;

type
  PPacket_F59 = ^TChangeChestGoldPacket;

  TChangeChestGoldPacket = packed record
    Header: TPacketHeader;
    ChestType: DWORD;
    Value: Int64;
  end;

type
  PPacket_137 = ^TStoragePacket;

  TStoragePacket = packed record
    Header: TPacketHeader;
    Index: LongInt; // Pode ser Tipo
    Storage: TStoragePlayer;
  End;

type
  PPacket_31D = ^TUseItemPacket;

  TUseItemPacket = packed record
    Header: TPacketHeader;
    TypeSlot, Slot, Type1: DWORD;
  end;

type
  PPacket_21B = ^TUseBuffItemPacket;

  TUseBuffItemPacket = packed record
    Header: TPacketHeader;
    Slot: DWORD;
  end;

type
  PPacket_336 = ^TCollectItem;

  TCollectItem = packed record
    Header: TPacketHeader;
    Index: DWORD;
    Time: DWORD; // use only 1 byte (1sec to 255 sec (4 min))
    Null: DWORD;
  end;

type
  PPacket_33A = ^TCancelCollectItem;

  TCancelCollectItem = packed record
    Header: TPacketHeader;
    Index: DWORD;
  end;
{$ENDREGION}
{$REGION 'NPC Packets'}

type
  PPacket_30F = ^TOpenNPCPacket;

  TOpenNPCPacket = packed record
    Header: TPacketHeader;
    Index, Type1, Type2: DWORD;
  end;

type
  PPacket_112 = ^TShowOptionsPacket;

  TShowOptionsPacket = packed record
    Header: TPacketHeader;
    Option, Null: DWORD;
    Name: Array [0 .. 63] of AnsiChar;
    Show: DWORD;
  end;

type
  TShowShopPacket = packed record
    Header: TPacketHeader;
    Index, DefByte: WORD;
    Items: ARRAY [0 .. 39] OF WORD;
  end;

type
  PPacket_313 = ^TBuyNPCItemPacket;

  TBuyNPCItemPacket = packed record
    Header: TPacketHeader;
    Index, Slot, Quantidade: DWORD;
  end;

type
  PPacket_314 = ^TSellNPCItemPacket;

  TSellNPCItemPacket = packed record
    Header: TPacketHeader;
    Index: DWORD;
    Slot: DWORD;
  end;

type
  PPacket_32D = ^TChangeItemAttPacket;

  TChangeItemAttPacket = packed record
    Header: TPacketHeader;
    ChangeType: DWORD;
    ItemSlot: DWORD;
    Item2: DWORD;
    Item3: DWORD;
  end;
{$ENDREGION}
{$REGION 'Trade Packets'}

type
  PPacket_316 = ^TResponseTradePacket;

  TResponseTradePacket = packed record
    Header: TPacketHeader;
    OtherClient, Response: DWORD;
  end;

type
  PPacket_317 = ^TTradePacket;

  TTradePacket = packed record
    Header: TPacketHeader;
    Trade: TTrade;
  end;
{$ENDREGION}
{$REGION 'Reinforce/Change Item Packets'}

type
  PPacket_32E = ^TReinforceResponse;

  TReinforceResponse = packed record
    Header: TPacketHeader;
    Unk1: DWORD;
    ReinforceResult: DWORD;
  end;

type
  p33D = packed record
    Header: TPacketHeader;
    Unk: ARRAY [0 .. 19] OF WORD;
  end;
{$ENDREGION}
{$REGION 'Skill/Item Bar Packets'}

type
  TChangeItemBarPacket = packed record
    Header: TPacketHeader;
    DestSlot, SrcType, SrcIndex: DWORD;
  end;
{$ENDREGION}
{$REGION 'Guild Packets'}

type
  PPacket_341 = ^TCreateGuildDialogPacket;

  TCreateGuildDialogPacket = packed record
    Header: TPacketHeader;
    Stage: DWORD;
    Rate: UInt64;
    GuildName: ARRAY [0 .. 23] OF AnsiChar;
  end;

type
  PPacket_130 = ^TRefreshPlayerInfosPacket;

  TRefreshPlayerInfosPacket = packed record
    Header: TPacketHeader;
    Index: DWORD;
    Nation, GuildIndex: WORD;
    MarechalGuildIndex: DWORD;
    GuildName: ARRAY [0 .. 19] OF AnsiChar;
  end;

type
  PPacket_932 = ^TUpdateGuildMessagePacket;

  TUpdateGuildMessagePacket = packed record
    Header: TPacketHeader;
    GuildIndex: DWORD;
    Msg: ARRAY [0 .. 127] OF AnsiChar;
  end;

type
  PPacket_965 = ^TGuildInfoPacket;

  TGuildInfoPacket = packed record
    Header: TPacketHeader;
    GuildIndex: WORD;
    Null_1, Nation: Byte;
    GuildName: ARRAY [0 .. 17] OF AnsiChar;
    Notices: ARRAY [0 .. 02] OF TGuildNotice;
    Null_2: WORD;
    Site: ARRAY [0 .. 37] OF AnsiChar;
    NULL_BYTES: ARRAY [0 .. 5] OF Byte;
    GuildIndex_1: WORD;
    Null_3: DWORD;
    GuildsAlly: ARRAY [0 .. 03] OF TGuildAllyItem;
    Null_4: WORD;
    Exp: DWORD;
    Level: Byte;
    Unk_1: ARRAY [0 .. 2] OF Byte;
    // 01 00 00   Unk_1[2] = 1 quando castelo tiver acontecendo
    RanksConfig: ARRAY [0 .. 4] OF Byte;
    MsgTaxa: ARRAY [0 .. 127] OF AnsiChar;
    NOT_USE: ARRAY [0 .. 2] OF Byte;
    BravePoints: DWORD; { Pontos de bravura }
    Promote: Boolean; { Quando a guild esta pra passar de nivel }
    SkillPoints: Byte;
    Null_5: ARRAY [0 .. 45] OF Byte;
  end;

type
  PPacket_97F = ^TGuildPlayersPacket;

  TGuildPlayersPacket = packed record
    Header: TPacketHeader;
    Players: ARRAY [0 .. 9] OF TPlayerFromGuild;
    GuildIndex: DWORD;
  end;

type
  PPacket_97C = ^TInviteToGuildPacket;

  TInviteToGuildPacket = packed record
    Header: TPacketHeader;
    InviterNick: ARRAY [0 .. 15] OF AnsiChar;
  end;

type
  PPacket_125 = ^TAddPlayerToGuildPacket;

  TAddPlayerToGuildPacket = packed record
    Header: TPacketHeader;
    Player: TPlayerFromGuild;
  end;

type
  PPacket_D18 = ^TRefreshGuildChestGoldPacket;

  TRefreshGuildChestGoldPacket = packed record
    Header: TPacketHeader;
    GuildIndex: WORD;
    Unk: WORD;
    Gold: UInt64;
  end;

type
  PPacket_D58 = ^TGuildChestPacket;

  TGuildChestPacket = packed record
    Header: TPacketHeader;
    Content: TGuildChest;
  end;

type
  PPacket_F10 = ^TGuildChestPermissionPacket;

  TGuildChestPermissionPacket = packed record
    Header: TPacketHeader;
    CanUseGuildChest: Boolean;
    Null: ARRAY [0 .. 10] OF Byte;
  end;

type
  PPacket_F20 = ^TUpdateGuildNoticesPacket;

  TUpdateGuildNoticesPacket = packed record
    Header: TPacketHeader;
    Notices: ARRAY [0 .. 2] OF ARRAY [0 .. 35] OF AnsiChar;
    GuildIndex: DWORD;
  end;

type
  PPacket_F21 = ^TUpdateGuildSitePacket;

  TUpdateGuildSitePacket = packed record
    Header: TPacketHeader;
    Site: ARRAY [0 .. 39] OF AnsiChar;
    GuildIndex: DWORD;
  end;

type
  PPacket_F22 = ^TUpdateGuildRanksConfigPacket;

  TUpdateGuildRanksConfigPacket = packed record
    Header: TPacketHeader;
    RanksConfig: ARRAY [0 .. 3] OF Byte;
    GuildIndex: DWORD;
  end;

type
  PPacket_F1D = ^TChangeGuildMemberRankPacket;

  TChangeGuildMemberRankPacket = packed record
    Header: TPacketHeader;
    CharIndex, Rank: Integer;
  end;

type
  PPacket_D1E = ^TUpdateGuildMemberLevelPacket;

  TUpdateGuildMemberLevelPacket = packed record
    Header: TPacketHeader;
    Level, CharIndex: Integer;
  end;

type
  PPacket_96A = ^TGuildMemberLogoutPacket;

  TGuildMemberLogoutPacket = packed record
    Header: TPacketHeader;
    CharIndex, LastLogin: Integer;
  end;

type
  PPacket_969 = ^TGuildMemberLoginPacket;

  TGuildMemberLoginPacket = packed record
    Header: TPacketHeader;
    CharIndex, Status: Integer;
  end;

type
  PPacket_F12_1 = ^TGuildRequestAllyPacket;

  TGuildRequestAllyPacket = packed record
    Header: TPacketHeader;
    SlotAlly: DWORD; { 01 }
    GuildName: ARRAY [0 .. 19] OF AnsiChar;
  end;

type
  PPacket_F12_2 = ^TGuildRequestAllyRecv;

  TGuildRequestAllyRecv = packed record
    Header: TPacketHeader;
    Guilds: ARRAY [0 .. 3] OF ARRAY [0 .. 19] OF AnsiChar;
  end;

type
  PPacket_911 = ^TGuildAllyInfo;

  TGuildAllyInfo = packed record
    Header: TPacketHeader;
    Ally: TGuildAlly;
    Unk: DWORD;
  end;

type
  PPacket_619 = ^TChangeMasterGuild;

  TChangeMasterGuild = packed record
    Header: TPacketHeader;
    CharIndex: DWORD;
  end;

type
  PPacket_661 = ^TDepositGoldForGuild;

  TDepositGoldForGuild = packed record
    Header: TPacketHeader;
    Null: DWORD;
    Gold: Int64;
  end;
{$ENDREGION}
{$REGION 'Mob Packets'}

type
  PPacket_306 = ^TRequestMobInfoPacket;

  TRequestMobInfoPacket = packed record
    Header: TPacketHeader;
    Index: DWORD;
    Type1: DWORD; { 0 = Player | 1 = NPC }
  end;

type
  PPacket_30bf = ^TMobMovimentPacket;

  TMobMovimentPacket = packed record
    Header: TPacketHeader;
    Destination: TPosition;
    Null: Array [0 .. 5] of Byte;
    MoveType: Byte;
    Speed: Byte;
    Unk: DWORD;
  end;
{$ENDREGION}
{$REGION 'Attack/Skill/Buffs Packets'}

type
  PPacket_302 = ^TSendAtkPacket;

  TSendAtkPacket = packed record
    Header: TPacketHeader;
    Index: WORD;
    Null_0: Array [0 .. 13] of Byte;
    Anim, Skill: WORD;
    MyPos, TargetPos: TPosition;
  end;

type
  PPacket_320 = ^TSendSkillUse;

  TSendSkillUse = packed record
    Header: TPacketHeader;
    Skill: DWORD;
    Index: DWORD;
    Pos: TPosition;
  end;

type
  PPacket_102 = ^TRecvDamagePacket;

  TRecvDamagePacket = packed record
    Header: TPacketHeader;
    SkillID: DWORD;
    AttackerPos: TPosition;
    NotUse_2: DWORD; // branco
    AttackerID: WORD;
    Null: Byte;
    Animation: Byte; // Deve ser a animação
    NotUse_3: Array [0 .. 11] of Byte;
    AttackerHP: DWORD; // HP de quem atacou
    NotUse_4: Array [0 .. 7] of Byte;
    TargetID: WORD;
    DNType: TDamageType;
    MobAnimation: Byte;
    DANO: UInt64;
    NotUse_5: DWORD;
    MobCurrHP: DWORD;
    DeathPos: TPosition;
  end;

type
  PPacket_16E = ^TSendBuffsPacket;

  TSendBuffsPacket = packed record
    Header: TPacketHeader;
    Buffs: Array [0 .. 39] of WORD;
    Time: Array [0 .. 39] of DWORD;
  End;

type
  PPacket_10B = ^TSendBuffsPacket_2;
  // ??? mesmo pacote porem com tamanhos e opcode diferente

  TSendBuffsPacket_2 = packed record
    Header: TPacketHeader;
    Buffs: Array [0 .. 59] of WORD;
    Time: Array [0 .. 59] of DWORD;
  End;

type
  PPacket_16F = ^TUpdateBuffPacket;

  TUpdateBuffPacket = packed record
    Header: TPacketHeader;
    Buff: DWORD;
    EndTime: DWORD;
    Unk: DWORD;
  end;

type
  PPacket_31C = ^TLearnSkillPacket;

  TLearnSkillPacket = packed record
    Header: TPacketHeader;
    SkillIndex: DWORD;
    NPCIndex: DWORD;
  end;

type
  PPacket_329 = ^TRemoveBuffPacket;

  TRemoveBuffPacket = packed record
    Header: TPacketHeader;
    BuffIndex: DWORD;
  end;
{$ENDREGION}
{$REGION 'Nação Info Packets'}

  // Governo
type
  PPacket_936 = ^TGuildsGradePacket;

  TGuildsGradePacket = packed record // 160
    Header: TPacketHeader;
    Guilds: TGuildsAlly;
    GuildsId: ARRAY [0 .. 03] OF WORD;
    Nation: DWORD;
    RegisterBonus: Int64; { Bonus em gold ao registrar na nação }
    Null_0: Byte;
    CitizenTax: Byte; { Imposto para cidadão }
    NoCitizenTax: Byte; { Imposto para não cidadão }
    NationAlly: Byte;
    AllyanceDate: DWORD; { 4F 91 F5 57 }
    Null_1: DWORD;
    MarshalAlly: Array [0 .. 15] of AnsiChar; { Talvez seja string }
    UnkBytes: Array [0 .. 11] of Byte;
    RankNation: Byte; { Rank da nação }
    Estabilization: Byte; { Porcentagem para estabilização do altar }
    UnkBytes2: Array [0 .. 5] of Byte;
  end;

type
  PPacket_91A = ^TGuildsSiegePacket; { Cerco }

  TGuildsSiegePacket = packed record
    Header: TPacketHeader;
    Defensoras: TGuildsAlly;
    Atacantes: ARRAY [0 .. 3] OF TGuildsAlly;
  end;

type
  PPacket_967 = ^TAllyanceInfoPacket;

  TAllyanceInfoPacket = packed record
    Header: TPacketHeader;
    Nation, NationAlly: WORD;
    AllyDate: DWORD;
    MarshalAlly: ARRAY [0 .. 15] OF AnsiChar;
  end;

type
  PPacket_F34 = ^TUpdateNationTreasure;

  TUpdateNationTreasure = packed record
    Header: TPacketHeader;
    Unknown: DWORD;
    Gold: Int64;
  end;

type
  PPacket_E3A = ^TUpdateNationTaxes;

  TUpdateNationTaxes = packed record
    Header: TPacketHeader;
    CitizenTax, VisitorTax: WORD;
  end;
{$ENDREGION}
{$REGION 'Loja Cash Packets'}

type
  PPacket_138 = ^TUpdateCashInventory;

  TUpdateCashInventory = packed record
    Header: TPacketHeader;
    Items: ARRAY [0 .. 23] OF TItemCash;
  end;

type
  PPacket_356 = ^TSendGiftPacket;

  TSendGiftPacket = packed record
    Header: TPacketHeader;
    Target: WORD;
    Slot: WORD;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
  end;
{$ENDREGION}
{$REGION 'Party(Grupo) Packets'}

type
  PPacket_11D = ^TPartyMemberCoordPacket;

  TPartyMemberCoordPacket = packed record // size 0x18
    Header: TPacketHeader;
    Index: DWORD;
    PosX: DWORD;
    PosY: DWORD;
  end;

type
  PPacket_322 = ^TSendPartyPacket;

  TSendPartyPacket = packed record
    Header: TPacketHeader;
    PlayerIndex: DWORD;
    Name: ARRAY [0 .. 15] OF AnsiChar;
  end;

type
  PPacket_323 = ^TAcceptPartyPacket;

  TAcceptPartyPacket = packed record
    Header: TPacketHeader;
    AceptType: DWORD;
  end;

type
  PPacket_324 = ^TKickPartyPacket;

  TKickPartyPacket = packed record
    Header: TPacketHeader;
    PlayerIndex: DWORD; // Index de quem foi Kickado
  end;

type
  PPacket_325 = ^TDestroyPartyPacket;

  TDestroyPartyPacket = packed record
    Header: TPacketHeader;
    PlayerIndex: DWORD; // Index ddo lider (próprio no caso)
  end;

type
  PPacket_326 = ^TUpdatePartyPacket;

  TUpdatePartyPacket = packed record
    Header: TPacketHeader;
    Name: ARRAY [0 .. 5] OF ARRAY [0 .. 15] OF AnsiChar;
    PlayerIndex: ARRAY [0 .. 5] OF WORD;
    ClassInfo: ARRAY [0 .. 5] OF Byte;
    Level: ARRAY [0 .. 5] OF Byte;
    CurHP: ARRAY [0 .. 5] OF DWORD;
    MaxHP: ARRAY [0 .. 5] OF DWORD;
    CurMP: ARRAY [0 .. 5] OF DWORD;
    MaxMP: ARRAY [0 .. 5] OF DWORD;
    LeaderIndex: WORD;
    ExpAllocate: Byte;
    ItemAllocate: Byte;
    PartyInRaidIndex: Byte;
    // 0=self 1..3 //index da party que está sendo atualizada na raid
    IsPartyLeaderOfRaid: Byte; // boolean or byte raid id??
    Unk_last: ARRAY [0 .. 1] OF Byte;
  end;

type
  PPacket_326_2 = ^TUpdatePartyAlocate;

  TUpdatePartyAlocate = packed record
    Header: TPacketHeader;
    ExpAlocate: DWORD; // 1 = igualmente   2 = individual
    ItemAlocate: DWORD;
    // 1 = em ordem  2 = aleatorio  3 = individual  4 = lider
  end;

type
  PPacket_338 = ^TPartyMemberPositionPacket;

  TPartyMemberPositionPacket = packed record
    Header: TPacketHeader;
    PlayerIndex: DWORD;
    Unk: ARRAY [0 .. 23] OF Byte;
  end;

type
  PPacket_34B = ^TGiveLeaderPartyPacket;

  TGiveLeaderPartyPacket = packed record
    Header: TPacketHeader;
    PlayerIndex: DWORD; // Index de quem recebe lider.
  end;
{$ENDREGION}
{$REGION 'Raid Packets'}

type
  PPacket_342 = ^TSendInviteToRaid;

  TSendInviteToRaid = packed record
    Header: TPacketHeader;
    SendTo: DWORD;
  end;

type
  PPacket_343 = ^TInviteToRaidResponse;

  TInviteToRaidResponse = packed record
    Header: TPacketHeader;
    Accept: Integer;
    Unkown: Integer;
  end;

type
  PPacket_207 = ^TGiveRaidLeader;

  TGiveRaidLeader = packed record
    Header: TPacketHeader;
    GiveTo: WORD;
    Unk: WORD;
  end;

type
  PPacket_344 = ^TRemovePartyFromRaid;

  TRemovePartyFromRaid = packed record
    Header: TPacketHeader;
    PartyInRaidIndex: DWORD;
    // when its coming 0, delete all raid, minus the parties
  end;
{$ENDREGION}
{$REGION 'Leilão / Action House  Packets'}

type
  PPacket_3F0B = ^TAuctionRegisterItemPacket;

  TAuctionRegisterItemPacket = packed record
    Header: TPacketHeader;
    Price: DWORD;
    Slot: WORD;
    Time: WORD; { 6, 12, 18 , 24 - Hours }
  end;

  PPacket_3F0D = ^TRequestAuctionItemsPacket;

  TRequestAuctionItemsPacket = packed record // client
    Header: TPacketHeader;
    ItemType: DWORD;
    LevelMin: WORD;
    LevelMax: WORD;
    Null_1: WORD;
    ReinforceMin: Byte;
    ReinforceMax: Byte;
    SearchByName: DWORD;
  end;

  TAuctionItemData = packed record
    SellerCharacterIndex: DWORD;
    AuctionIndex: UInt64;
    ItemPrice: DWORD;
    SellerCharacterName: ARRAY [0 .. 15] OF AnsiChar;
    ExpireDate: ARRAY [0 .. 11] OF AnsiChar;
    Item: TItem;
  end;

  TSendAuctionItemsPacket = packed record // server  0x3f0d
    Header: TPacketHeader;
    Items: ARRAY [0 .. 39] OF TAuctionItemData;
    Unk_1: DWORD;
    ItemCount: DWORD;
    Unk_2: DWORD;
  end;

  PPacket_3F11 = ^TCadastredItemsPacket;

  TCadastredItemsPacket = packed record
    Header: TPacketHeader;
    Items: ARRAY [0 .. 11] OF TAuctionItemData;
    ItemCount: DWORD;
  end;

  PPacket_3F10 = ^TAuctionCancelOfferPacket;

  TAuctionCancelOfferPacket = packed record
    Header: TPacketHeader;
    CharacterId: DWORD;
    AuctionOfferId: UInt64;
    ResponseStatus: UInt64;
  end;

  PPacket_3F0C = ^TAuctionBuyOfferPacket;

  TAuctionBuyOfferPacket = packed record
    Header: TPacketHeader;
    CharacterId: DWORD;
    AuctionOfferId: UInt64;
    ResponseStatus: UInt64;
  end;
{$ENDREGION}
{$REGION 'Correio Packets'}

type
  PPacket_3F15 = ^TContentMailPacket;

  TContentMailPacket = packed record
    Header: TPacketHeader;
    Content: TMailContent;
  End;

type
  PPacket_3F16 = ^TSendMailPacket; // Destinario OPCODE 0x3F16  Size: 0x24 (36)

  TSendMailPacket = packed record
    Header: TPacketHeader;
    Nick: Array [0 .. 15] of AnsiChar;
    Send: DWORD;
    Nation: DWORD;
  end;

  PPacket_3F17 = ^TPlayerMailsPacket;

  TPlayerMailsPacket = Record
    Header: TPacketHeader;
    Null: DWORD;
    Cartas: Array [0 .. 31] of TStructCarta;
    MailsAmount: DWORD;
    Unk: DWORD;
  end;

type
  PPacket_3F18 = ^TOpenMailPacket;

  TOpenMailPacket = packed record
    Header: TPacketHeader;
    Null: DWORD;
    Index: UInt64; { Index da carta }
    CharIndex: DWORD;
    Slot: Byte;
    OpenType: Byte;
    Delete: BOOL;
    Unk_2: Byte;
  End;

  TRecvOpenMailPacket = packed record
    Header: TPacketHeader;
    Null: DWORD;
    Index: UInt64; { Index da carta }
    CharIndex: DWORD;
    Slot: WORD;
    OpenType: WORD;
    Index2: UInt64; { Repete o index }
    Nick: ARRAY [0 .. 15] OF AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    Texto: ARRAY [0 .. 511] OF AnsiChar;
    DataEnvio: ARRAY [0 .. 19] OF AnsiChar;
    Items: ARRAY [0 .. 4] OF TItem;
    Gold: DWORD;
    Return: Boolean;
    Unk_B01: Boolean;
    Unk_B02: Boolean;
    Unk_B03: Boolean;
  End;

  TSendOpenMailContentPacket = packed record
    Header: TPacketHeader;
    Null: DWORD;
    MailContent: TOpenMailContent;
  End;

type
  PPacket_3F1A = ^TGetMailContentPacket;

  TGetMailContentPacket = packed record
    Header: TPacketHeader;
    Null_0: DWORD;
    Index: UInt64;
    Slot: DWORD;
    Null_1: DWORD;
  end;
{$ENDREGION}
{$REGION 'Friends Packets'}

type
  PPacket_372 = ^TAddFriendRequestPacket;

  TAddFriendRequestPacket = packed record // Size = 32 // Code = $372
    Header: TPacketHeader;
    ID: DWORD;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
  end;

type
  PPacket_673 = ^TAddFriendResponsePacket;

  TAddFriendResponsePacket = packed record // Size = 32 // Code = $673
    Header: TPacketHeader;
    Response: WORD;
    ID: WORD;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
  end;

type
  PPacket_96F = ^TFriendLoginPacket;

  TFriendLoginPacket = packed record // Size = 24 // Code = $96F
    Header: TPacketHeader;
    CharIndex: DWORD;
    PlayerIndex: WORD;
    FriendStatus: TFriendStatus;
    Channel: Byte;
    City: TCity;
    Level: Byte;
    Nation: TCitizenship;
    Classe: Byte;
  end;

type
  PPacket_971 = ^TFriendLogoutPacket;

  TFriendLogoutPacket = packed record // Size = 16 // Code = $971
    Header: TPacketHeader;
    CharIndex: DWORD;
  end;

type
  PPacket_870 = ^TSendFriendToSocialPacket;

  TSendFriendToSocialPacket = packed record // Size = 40 // Code = $870
    Header: TPacketHeader;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
    CharIndex: DWORD;
    FriendStatus: TFriendStatus;
    Channel: Byte;
    PlayerIndex: WORD;
    Classe: Byte;
    City: TCity;
    Level: Byte;
    Unk: Byte;
  end;

type
  PPacket_975 = ^TAtualizeFriendInfosPacket;

  TAtualizeFriendInfosPacket = packed record // Size = 24 // Code = $975
    Header: TPacketHeader;
    CharIndex: DWORD;
    PlayerIndex: WORD;
    FriendStatus: TFriendStatus;
    Channel: Byte;
    City: Byte;
    Level: Byte;
    Nation: Byte;
    Classe: Byte;
  end;

type
  PPacket_F74 = ^TDeleteFriendPacket;

  TDeleteFriendPacket = packed record // Size = 16 // Code = $F74
    Header: TPacketHeader;
    CharIndex: DWORD;
  end;

type
  PPacket_F26 = ^TSendFriendChatPacket;

  TSendFriendChatPacket = packed record
    Header: TPacketHeader;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
    Fala: ARRAY [0 .. 127] OF AnsiChar;
    WindowIndex: DWORD;
  end;

type
  PPacket_F27 = ^TOpenFriendWindowPacket;

  TOpenFriendWindowPacket = packed record
    Header: TPacketHeader;
    CharIndex: DWORD;
    WindowIndex: DWORD;
  end;

type
  PPacket_F30 = ^TCloseFriendWindowPacket;

  TCloseFriendWindowPacket = packed record
    Header: TPacketHeader;
    WindowIndex: DWORD;
  end;
{$ENDREGION}
{$REGION 'Ver info Packets'}

type
  PPacket_19E = ^TCharInfoResponsePacket;

  TCharInfoResponsePacket = packed record
    Header: TPacketHeader;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
    GuildName: ARRAY [0 .. 19] OF AnsiChar;
    Classe: Byte;
    Nacao: Byte;
    Infamia: WORD;
    Honra: DWORD;
    Pvp: DWORD;
    Str, AGI, Int, Cons, Sorte, Status: WORD;
    Critico: Byte;
    Unk7: WORD;
    Unk8: Byte;
    Esquiva: WORD;
    Acerto: WORD;
    AtkFis: WORD;
    DefFis: WORD;
    AtkMag: WORD;
    DEFMag: WORD;
    Movimento: WORD;
    Unk1: WORD;
    Resistencia: WORD;
    AtkDuplo: WORD;
    Exp: UInt64;
    BonusDMG: WORD;
    Level: WORD;
    Equips: ARRAY [0 .. 8] OF TItem;
    MountEquip: TMountItem;
    PranEquip: TPranItem;
    Equips2: Array [11 .. 15] of TItem;
    PranName: ARRAY [0 .. 15] OF AnsiChar;
    Null2: WORD;
    Null3: WORD;

  end;

type
  PPacket_22C = ^TRequestCharInfoPacket;

  TRequestCharInfoPacket = packed record
    Header: TPacketHeader;
    Index: DWORD;
    Nick: ARRAY [0 .. 15] OF AnsiChar;
  end;
{$ENDREGION}
{$REGION 'PersonalShop Packets}

  // (SignalData) Fechar loja = Opcode $318; Size $10
  // (SignalData) Excluir loja = Opcode $318; Size $10
type
  TPersonalShopPacket = packed record // Opcode $319; Size $170
    Header: TPacketHeader;
    Shop: TPersonalShopData;
  end;

  // (SignalData) Abrir loja = Opcode $31A; Size $10
type
  TBuyPersonalShopItemPacket = packed record // Opcode $31B; Size $38
    Header: TPacketHeader;
    Index: DWORD;
    Slot: DWORD;
    Null: DWORD;
    Product: TPersonalShopItem;
  end;
{$ENDREGION}
{$REGION 'Change Channel'}

type
  PPacket_F05 = ^TChangeChannelPacket;

  TChangeChannelPacket = packed record { 0xF05 }
    Header: TPacketHeader;
    Info1, TypeChanel: DWORD;
  end;

type
  PPacket_397 = ^TStartF12;

  TStartF12 = packed record { 0x397 }
    Header: TPacketHeader;
    Status: DWORD;
    TempoRestante: DWORD;
    Unk1: DWORD;
    Unk2: DWORD;
  end;

  PPacket_114 = ^TF12Effect;

  TF12Effect = packed record { 0x397 }
    Header: TPacketHeader;
    ClientId: DWORD;
    EffectId: DWORD;
    Unk: DWORD;
  end;

type
  PPacket_F06 = ^TChannelSendInfoPacket;

  TChannelSendInfoPacket = packed record { 0xF06 }
    Header: TPacketHeader;
    Serial: DWORD;
    Username: ARRAY [0 .. 31] OF AnsiChar;
    MacAddr: ARRAY [0 .. 11] OF Byte;
  end;

type
  PPacket_150 = ^TUpdateClientIDPacket;

  TUpdateClientIDPacket = packed record
    Header: TPacketHeader;
    AccountId, ClientId, LoginTime, Unk1: DWORD; // talvez o channel type
  end;
{$ENDREGION}
{$REGION 'Devir & Reliquias Information'}

type
  PPacket_B52 = ^TRequestDevirInfoPacket;

  TRequestDevirInfoPacket = packed record
    Header: TPacketHeader;
    Channel: DWORD;
  end;

type
  PPacket_B52_2 = ^TRequestDevirInfoPacket;

  TSendDevirInfoPacket = packed record
    Header: TPacketHeader;
    DevirID: WORD;
    TypeOpen: WORD; // 01 entregar 05 é puxar
    DevirReliq: TDevirForPacket;
    DevirReliInfo: TDevirInfoForPacket;
  end;

type
  PPacket_E51 = ^TRequestDevirInfoPacket;

  TMoveItemToReliquare = packed record
    Header: TPacketHeader;
    DevirClientID: DWORD;
    DestSlot: WORD;
    SrcSlot: WORD;
    Unk1: DWORD;
  end;

type
  PPacket_953 = ^TDevirTimeRelikInfoPacket;

  TDevirTimeRelikInfoPacket = packed record
    Header: TPacketHeader;
    Nation: DWORD;
    DevirAmk: TDevirForPacket;
    DevirSig: TDevirForPacket;
    DevirCah: TDevirForPacket;
    DevirMir: TDevirForPacket;
    DevirZel: TDevirForPacket;
    DevirAmkInfo: TDevirInfoForPacket;
    DevirSigInfo: TDevirInfoForPacket;
    DevirCahInfo: TDevirInfoForPacket;
    DevirMirInfo: TDevirInfoForPacket;
    DevirZelInfo: TDevirInfoForPacket;
    // OtherBytesInReliquareInfo: Array [0..23] of Byte;
  end;

type
  PPacket_136 = ^TSendReliques;

  TSendReliques = packed record
    Header: TPacketHeader;
    ReliquesItemID: Array [0 .. 24] of WORD;
    Unk: WORD;
    TriggerEvent: WORD;
    // 01 significa que a reliquia foi selada e perdeu tudo os efeito //02 significa que foi ativado bonus, 00 significa nada
  end;

type
  TSendUpgradeStruct = packed record
    RelicId: WORD;
    Locked: Byte; // 0 para locked e 1 para liberado o upgrade
    Level: Byte; // 0 se já tiver full upado e 1 se ainda der pra upar
    Doado: DWORD; // valor doado eu acho, n sei como funfa
    TimeCap: DWORD; // é o horario na qual foi capado eu acho
    NameCap: Array [0 .. 15] of AnsiChar; // nome de quem capou
  end;

type
  PPacket_957 = ^TSendUpgradeRelics;

  TSendUpgradeRelics = packed record
    Header: TPacketHeader;
    AmkRelics: Array [0 .. 4] of TSendUpgradeStruct;
    SigRelics: Array [0 .. 4] of TSendUpgradeStruct;
    CahRelics: Array [0 .. 4] of TSendUpgradeStruct;
    MirRelics: Array [0 .. 4] of TSendUpgradeStruct;
  end;

{$ENDREGION}
{$REGION 'Other Packets'}

type
  TAgrosSuporte = packed record
    Nome: Array [0 .. 15] of AnsiChar;
    Nation: WORD;
    Kills: WORD;
    Deaths: WORD;
    Level: Byte;
    Null: Byte;
  end;

type
  PPacket_353 = ^TAgrosTabela;

  TAgrosTabela = packed record
    Header: TPacketHeader;
    TimeAzul: Array [0 .. 23] of TAgrosSuporte;
    TimeRed: Array [0 .. 23] of TAgrosSuporte;
  end;

type
  PPacket_213 = ^TGetStatusPointPacket;

  TGetStatusPointPacket = packed record
    Header: TPacketHeader;
    StatusIndex: DWORD;
    StatusAmount: DWORD;
  end;

type
  PPacket_34A = ^TTeleportFcPacket;

  TTeleportFcPacket = packed record
    Header: TPacketHeader;
    Slot: DWORD; // client envia o slot 00=1st
    PosX, PosY: DWORD; // ele envia como 0, server envia a posição atual do cara
  end;

type // 0x12a
  TUpdateHonorAndKills = packed record
    Header: TPacketHeader;
    Honor: DWORD;
    Kills: DWORD;
  end;

type // 0x111
  TSendMobTalkAnimation = packed record
    Header: TPacketHeader;
    Index: DWORD;
  end;

type // 0x14F
  TSendAccountStatus = packed record
    Header: TPacketHeader;
    Status: DWORD;
  end;

type // 0x361
  TUpdateActiveTitlePacket = packed record
    Header: TPacketHeader;
    TitleIndex: DWORD;
    TitleLevel: DWORD;
  end;

type // 0x17D
  TUpdateTitleListPacket = packed record
    Header: TPacketHeader;
    IDAcquire: DWORD;
    IDLeveled: DWORD;
  end;

type
  PPacket_31F = ^TSendAnimationPacket;

  TSendAnimationPacket = packed record
    Header: TPacketHeader;
    Anim: DWORD;
    Loop: DWORD;
  end;

type
  PPacket_180 = ^TPacketSendDeadAnimation;

  TPacketSendDeadAnimation = packed record
    Header: TPacketHeader;
    CountOfBlueTicks: DWORD;
    ClientId: DWORD;
  end;

type
  PPacket_0x340 = ^TPacketRepareItens;

  TPacketRepareItens = packed record
    Header: TPacketHeader;
    Unk: DWORD;
    ItensToRepareSlot: Array [0 .. 9] of Byte;
    ItensToRepareSlotType: Array [0 .. 9] of Byte;
  end;

type
  PPacket_21A = ^TPacketRenoveItem;

  TPacketRenoveItem = packed record
    Header: TPacketHeader;
    SlotItem1: DWORD;
    SlotItemToRenove: DWORD;
  end;

type
  PPacket_22A = ^TPacketRenoveItem;

  TPacketRenoveItemPran = packed record
    Header: TPacketHeader;
    SlotItem1: DWORD;
    SlotItemToRenove: DWORD;
  end;

type
  PPacket_3E05 = ^TPacketReclaimCoupom;

  TPacketReclaimCoupom = packed record
    Header: TPacketHeader;
    Null: DWORD;
    Coupom: Array [0 .. 15] of AnsiChar;
    Null2: DWORD;
    Null3: DWORD;
  end;
{$ENDREGION}
{$REGION 'Duel Packets'}

type // 0x395  [cl1] -> [sv] -> [cl2]
  TSendDuelResquest = packed record
    Header: TPacketHeader;
    ClientId: DWORD;
    Nick: Array [0 .. 15] of AnsiChar;
  end;

type // 0x396 [cl2] -> [sv]
  TSendDuelResponse = packed record
    Header: TPacketHeader;
    Response: DWORD; // 00 n 01 sim
  end;

type // 0x1a2 [sv] -> c1 e c2
  TSendDuelTime = packed record
    Header: TPacketHeader;
    SecondsCount: DWORD; // 10 no original
  end;

type // 0x1a0 mandar win pro vencedor e lose pro perdedor
  TMessageEndDuel = packed record
    Header: TPacketHeader;
    WonLose: DWORD; // 00 for lose 01 for won
  end;
{$ENDREGION}
{$REGION 'Quest Packets'}

type // 0x32f
  TAbandonQuestPacket = packed record
    Header: TPacketHeader;
    QuestID: DWORD;
  end;

type // 0x331
  TSendQuestInfo = packed record
    Header: TPacketHeader;
    QuestID: WORD;
    RequirimentType: Array [0 .. 4] of Byte;
    RequirimentComplete: Array [0 .. 4] of Byte;
    RequirimentAmount: Array [0 .. 4] of Byte;
    Unk: Byte;
    RequirimentItem: Array [0 .. 4] of WORD;
    IsCompleted: Byte;
    IsOld: Byte;
    Unk2: WORD;
  end;

type // 0x11b
  TSendExpGoldMsg = packed record
    Header: TPacketHeader;
    Exp: DWORD;
    Gold: DWORD;
  end;

type // 0x11b
  TSendExpBaseMsg = packed record
    Header: TPacketHeader;
    Exp: DWORD;
    ExpExtra: DWORD;
    ExpBatalhao: DWORD;

  end;

type // 0x11b
  TPadrao = packed record
    Header: TPacketHeader;
    Valor1: DWORD;
    Valor2: DWORD;
    Valor3: DWORD;
  end;

{$ENDREGION}
{$REGION 'GM Tool Packets'}

type
  PPacketLoginIntoServer_0x3202 = ^TPacketLoginIntoServer;

  TPacketLoginIntoServer = packed record
    Header: TPacketHeader;
    Username: Array [0 .. 15] of AnsiChar;
    Password: Array [0 .. 31] of AnsiChar;
    GameUsername: Array [0 .. 31] of AnsiChar;
  end;

type
  PPacketLoginIntoServerResponse_0x3203 = ^TPacketLoginIntoServerResponse;

  TPacketLoginIntoServerResponse = packed record
    Header: TPacketHeader;
    Response: Integer;
  end;

type
  PMovePacket_0x3204 = ^TMovePacket;

  TMovePacket = packed record
    Header: TPacketHeader;
    NickName: Array [0 .. 31] of AnsiChar;
    Position: TPosition;
  end;

type
  PPacket_3205 = ^TClientMessagePacket2;

  TClientMessagePacket2 = packed record
    Header: TPacketHeader;
    Nick: Array [0 .. 15] of AnsiChar;
    Null: Byte; // valor 10+ msg amarela
    Type1: Byte; // relacionado com tamanho
    Type2: Byte; // tbm ou cor
    Null1: Byte;
    Msg: string[128];
  end;

type
  PPacket_3206 = ^TSendGoldAddRemove;

  TSendGoldAddRemove = packed record
    Header: TPacketHeader;
    Gold: UInt64;
    Add: Boolean;
    RemoveAllGold: Boolean;
    TargetID: WORD;
    NickName: Array [0 .. 15] of AnsiChar;
  end;

type
  PPacket_3207 = ^TSendGoldAddRemove;

  TSendCashAddRemove = packed record
    Header: TPacketHeader;
    Cash: UInt64;
    Add: Boolean;
    RemoveAllCash: Boolean;
    TargetID: WORD;
    NickName: Array [0 .. 15] of AnsiChar;
  end;

type
  PPacket_3208 = ^TSendLevelAddRemove;

  TSendLevelAddRemove = packed record
    Header: TPacketHeader;
    Level: WORD;
    Add: Boolean;
    RemoveAllLevel: Boolean;
    TargetID: WORD;
    NickName: Array [0 .. 15] of AnsiChar;
  end;

type
  PPacket_3209 = ^TSendBuffAddRemove;

  TSendBuffAddRemove = packed record
    Header: TPacketHeader;
    BuffID: WORD;
    TargetID: WORD;
    Add: Byte;
    RemoveAllBuff: Byte;
    Null: DWORD;
  end;

type
  PPacket_3210 = ^TSendDisconnect;

  TSendDisconnect = packed record
    Header: TPacketHeader;
    TargetID: WORD;
    NickName: Array [0 .. 15] of AnsiChar;
  end;

type
  PPacket_3211 = ^TSendBan;

  TSendBan = packed record
    Header: TPacketHeader;
    TargetID: WORD;
    NickName: Array [0 .. 15] of AnsiChar;
    Days: WORD;
    Reason: Array [0 .. 127] of AnsiChar;
  end;

type
  PPacket_3212 = ^TSendItemEventOne;

  TSendItemEventOne = packed record
    Header: TPacketHeader;
    TargetID: DWORD;
    NickName: Array [0 .. 15] of AnsiChar;
    ItemID: DWORD;
    Amount: DWORD;
    Null: DWORD;
    Reason: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_3299 = ^TSendItemEventForAll;

  TSendItemEventForAll = packed record
    Header: TPacketHeader;
    ItemID: DWORD;
    Amount: DWORD;
    Null: DWORD;
  end;

type
  PPacket_3214 = ^TSendRequestForServerInfo;

  TSendRequestForServerInfo = packed record
    Header: TPacketHeader;
    Null: DWORD;
  end;

type
  PPacket_3215 = ^TSendServerInfos;

  TSendServerInfos = packed record
    Header: TPacketHeader;
    Server01Online, Server02Online, Server03Online, Server04Online,
      Server05Online: DWORD;
    Server01Reliq, Server02Reliq, Server03Reliq, Server04Reliq,
      Server05Reliq: DWORD;
    Null: DWORD;
  end;

type
  PPacket_3217 = ^TSendMessageShout;

  TSendMessageShout = packed record
    Header: TPacketHeader;
    Nick: Array [0 .. 15] of AnsiChar;
    ServerFrom: DWORD;
    xMsg: Array [0 .. 127] of AnsiChar;
    Null: DWORD;
  end;

type
  PPacket_3219 = ^TSendSpawnMob;

  TSendSpawnMob = packed record
    Header: TPacketHeader;
    MobID: DWORD;
    Position: TPosition;
    Null: DWORD;
  end;

type
  PPacket_3221 = ^TRequestSearchAccountFile;

  TRequestSearchAccountFile = packed record
    Header: TPacketHeader;
    TypeOfCommand: DWORD;
    Username: Array [0 .. 15] of AnsiChar;
  end;

type
  PPacket_3223 = ^TRequestSearchAccountFile;

  TReceivePlayerAccountFiles = packed record
    Header: TPacketHeader;
    FileName: Array [0 .. 255] of AnsiChar;
    AccountBackup: TAccountFile;
  end;

type
  PPacket_3225 = ^TSendAccountRecovery;

  TSendAccountRecovery = packed record
    Header: TPacketHeader;
    FileName: Array [0 .. 255] of AnsiChar;
    AccountBackup: TAccountFile;
  end;

type
  PPacket_3227 = ^TSendAccountRecoveryReturn;

  TSendAccountRecoveryReturn = packed record
    Header: TPacketHeader;
    Response: DWORD;
  end;

type
  PPacket_3229 = ^TSendAutorizSearchCommands;

  TSendAutorizSearchCommands = packed record
    Header: TPacketHeader;
    GMUsername: Array [0 .. 15] of AnsiChar;
    InitDate, FinalDate: TDateTime;
    TypeOfView: DWORD;
  end;

type
  PPacket_322B = ^TReceiveAutorizCommandFromServer;

  TReceiveAutorizCommandFromServer = packed record
    Header: TPacketHeader;
    GMID: DWORD;
    GMUsername: Array [0 .. 15] of AnsiChar;
    CommandType: WORD;
    CommandSQL: Array [0 .. 1024] of AnsiChar; // 20480 = 20kb de SQL
    CreatedAt: TDateTime;
    TargetName: Array [0 .. 15] of AnsiChar;
    TargetItemID: WORD;
    TargetItemCnt: WORD;
    ReasonCreate: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_322D = ^TSendRequestGMUsernames;

  TSendRequestGMUsernames = packed record
    Header: TPacketHeader;
    Data: DWORD;
  end;

type
  PPacket_322F = ^TSendGMUsernameToClient;

  TSendGMUsernameToClient = packed record
    Header: TPacketHeader;
    GMUsernameTo: Array [0 .. 15] of AnsiChar;
  end;

type
  PPacket_3232 = ^TMessageToPainelPacket;

  TMessageToPainelPacket = packed record
    Header: TPacketHeader;
    Null: Byte; // valor 10+ msg amarela
    Type1: Byte; // relacionado com tamanho
    Type2: Byte; // tbm ou cor
    Null1: Byte;
    Msg: Array [0 .. 127] of AnsiChar;
  end;

type
  PPacket_3234 = ^TRefuseCommandPacket;

  TRefuseCommandPacket = packed record
    Header: TPacketHeader;
    CommandID: DWORD;
    Reason: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_3236 = ^TRefuseCommandPacket;

  TAcceptCommandPacket = packed record
    Header: TPacketHeader;
    CommandID: DWORD;
    Reason: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_3238 = ^TSendAddEffectGMPacket;

  TSendAddEffectGMPacket = packed record
    Header: TPacketHeader;
    TargetID: DWORD;
    EffectId: DWORD;
  end;

type
  PPacket_323A = ^TSendAddEffectGMPacket;

  TSendCreateCoupomRequest = packed record
    Header: TPacketHeader;
    GMUsername: Array [0 .. 15] of AnsiChar;
    PinCodeType: DWORD;
    ItemID: DWORD;
    ItemAmount: DWORD;
    Reason: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_323C = ^TSendAddEffectGMPacket;

  TSendRequestCoupons = packed record
    Header: TPacketHeader;
    GMUsername: Array [0 .. 15] of AnsiChar;
  end;

type
  PPacket_323E = ^TSendAddEffectGMPacket;

  TCoupomReceive = packed record
    Header: TPacketHeader;
    CommandID: Integer;
    GMID: DWORD;
    GMUsername: Array [0 .. 15] of AnsiChar;
    CommandType: WORD;
    CommandSQL: Array [0 .. 1024] of AnsiChar; // 20480 = 20kb de SQL
    CreatedAt: TDateTime;
    TargetName: Array [0 .. 15] of AnsiChar;
    TargetItemID: WORD;
    TargetItemCnt: WORD;
    ReasonCreate: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_3240 = ^TSearchComprovantByID;

  TSearchComprovantByID = packed record
    Header: TPacketHeader;
    TransactionID: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_3242 = ^TSearchComprovantByID;

  TSearchComprovantByName = packed record
    Header: TPacketHeader;
    NameOfComprovant: Array [0 .. 255] of AnsiChar;
  end;

type
  PPacket_3244 = ^TSearchComprovantByID;

  TComprovantReceive = packed record
    Header: TPacketHeader;
    ComprovantDBID: Integer;
    TransactionID: Array [0 .. 255] of AnsiChar;
    NameOfComprovant: Array [0 .. 255] of AnsiChar;
    DateOfComprovant: TDate;
    ValueOfComprovant: Single;
    IsValidated: Boolean;
    ValidatedBy: Array [0 .. 63] of AnsiChar;
    CoupomAttributed: Array [0 .. 63] of AnsiChar;
  end;

type
  PPacket_3246 = ^TSearchComprovantByID;

  TComprovantCreate = packed record
    Header: TPacketHeader;
    TransactionID: Array [0 .. 255] of AnsiChar;
    NameOfComprovant: Array [0 .. 255] of AnsiChar;
    DateOfComprovant: TDate;
    ValueOfComprovant: Single;
  end;

type
  PPacket_3248 = ^TSearchComprovantByID;

  TComprovantValidate = packed record
    Header: TPacketHeader;
    ComprovantDBID: Integer;
  end;

type
  PPacket_324A = ^TPacketSendDeletePrans;

  TPacketSendDeletePrans = packed record
    Header: TPacketHeader;
    AccountIndex: Integer;
    CharacterIndex: Integer;
  end;

{$ENDREGION}
{$REGION 'Aika Other Attributes'}

type
  pTRequestAllAttributes_0x23FE = ^TRequestAllAttributes;

  TRequestAllAttributes = packed record
    Header: TPacketHeader;
  end;

type
  pTRequestAllAttributesTarget_0x23FB = ^TRequestAllAttributesTarget;

  TRequestAllAttributesTarget = packed record
    Header: TPacketHeader;
    TargetID: DWORD;
  end;

type
  pTResponseAllAttributes_0x23FF = ^TResponseAllAttributes;

  TResponseAllAttributes = packed record
    Header: TPacketHeader;
    Resfriamento: WORD;
    DanoHab: WORD;
    Cura: WORD;
    DanoPvp: WORD;
    DefPvp: WORD;
    PerFis: WORD;
    PerMag: WORD;
    RecHP: WORD;
    RecMP: WORD;
    DanoCrit: WORD;
    ResisCrit: WORD;
    ResisDuplo: WORD;
    DiminDanoCrit: WORD;
    ResisLent: WORD;
    ResisStun: WORD;
    ResisSilence: WORD;
    ResisChoque: WORD;
    ResisImobi: WORD;
    ResisMedo: WORD;
  end;

type
  pTResponseAllAttributesTarget_0x23FC = ^TResponseAllAttributesTarget;

  TResponseAllAttributesTarget = packed record
    Header: TPacketHeader;
    Resfriamento: WORD;
    DanoHab: WORD;
    Cura: WORD;
    DanoPvp: WORD;
    DefPvp: WORD;
    PerFis: WORD;
    PerMag: WORD;
    RecHP: WORD;
    RecMP: WORD;
    DanoCrit: WORD;
    ResisCrit: WORD;
    ResisDuplo: WORD;
    DiminDanoCrit: WORD;
    ResisLent: WORD;
    ResisStun: WORD;
    ResisSilence: WORD;
    ResisChoque: WORD;
    ResisImobi: WORD;
    ResisMedo: WORD;
  end;
{$ENDREGION}
{$OLDTYPELAYOUT OFF}

implementation

end.
