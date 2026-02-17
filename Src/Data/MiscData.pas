unit MiscData;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses SysUtils, Windows;
{$OLDTYPELAYOUT ON}





{$REGION 'Quest Data'}

type
  TQuest = packed record
    ID: WORD;
    Unk: ARRAY [0 .. 9] OF BYTE;
  end;

{$ENDREGION}
{$REGION 'Item Data'}

type
  TItemEffect = packed record
    Index: Array [0 .. 2] of BYTE;
    Value: Array [0 .. 2] of BYTE;
  End;
  {
    type
    TOrigItem = packed record
    Index, APP: WORD;
    Identific: LongInt;
    Effects: TItemEffect;
    MIN, MAX: BYTE;
    Refi: WORD; // REFI[1Byte]/LVL[1Byte]/(QNT[2 bytes]) //acho que esse lvl são 2 bytes, 1 pra cada level(min e max) usado no nivelamento
    Time: WORD; // Licença/TEMPO PRA EXPIRAR
    end; }

type
  PItem = ^TItem;

  TItem = packed record
    Index, APP: WORD;
    Identific: LongInt;
    Effects: TItemEffect;
    MIN, MAX: BYTE;
    Refi: WORD;
    // REFI[1Byte]/LVL[1Byte]/(QNT[2 bytes]) //acho que esse lvl são 2 bytes, 1 pra cada level(min e max) usado no nivelamento
    Time: WORD;
    // Licença/TEMPO PRA EXPIRAR
    // não fará parte do item, pois para mover usando sizeof(TITEM_SIZE) const
    { Iddb: UInt64;
      IsActive: Boolean; //item ativo=1 (existente) item desativado=0 (deletado)
      GeneratedIn: Byte; //vai ter consts para isso, de onde foi gerado
      GeneratedTime: TDateTime; //data e hora de geramento
      GeneratorAccountID: UInt64; //acciddb de quem gerou
      DeletedTime: TDateTime; //isso aqui vai ser nulo na db, até ter active=0
      DeleterAccountID: UInt64; //isso aqui vai ser nulo na db, até ter active=0 }

  private
    function GetExpire: TDateTime;
    procedure SetExpire(Time: TDateTime);

    function GetIsSealed: Boolean;
    procedure SetIsSealed(Selado: Boolean);
  public
    property ExpireDate: TDateTime read GetExpire write SetExpire;
    property IsSealed: Boolean read GetIsSealed write SetIsSealed;

    function GetEquipSellPrice: DWORD;
  end;

type
  TItemPrice = record
    PriceType: BYTE;
    Value1, Value2: DWORD;
  end;

type
  PItemCash = ^TItemCash;

  TItemCash = packed record
    Index, APP: WORD;
    Identific: LongInt;
    function ToItem: TItem;
  end;

{$ENDREGION}
{$REGION 'Position Data'}

type
  TPosition = record
  public
    X, Y: Single;
    constructor Create(X, Y: Single);
    function Distance(const pos: TPosition): WORD;
    function InRange(const pos: TPosition; range: BYTE): Boolean;
    function IsValid: Boolean;
    class operator Equal(pos1, pos2: TPosition): Boolean;
    class operator NotEqual(pos1, pos2: TPosition): Boolean;
    class operator Subtract(pos1, pos2: TPosition): TPosition;
  end;

{$ENDREGION}
{$REGION 'HeightMap Data'}

type
  THeightMap = record
    p: array [0 .. 4095] of array [0 .. 4095] of BYTE;
  End;

{$ENDREGION}
{$REGION 'Token Data'}

type
  TPlayerToken = packed record
    Token: ARRAY [0 .. 31] OF AnsiChar;
    CreationTime: TDateTime;

  public
    procedure Generate(Password: string);
  end;

{$ENDREGION}
{$REGION 'Nation Data'}

type
  TGuildsAlly = packed record
    LordMarechal: Array [0 .. 19] of AnsiChar;
    Estrategista: Array [0 .. 19] of AnsiChar;
    Juiz: Array [0 .. 19] of AnsiChar;
    Tesoureiro: Array [0 .. 19] of AnsiChar;
  end;

{$ENDREGION}
{$REGION 'Title Data'}

type
  TTitle = packed record
    Index, Level: BYTE;
  end;

{$ENDREGION}
{$REGION 'PersonalShop Data'}

type
  PPersonalShopItem = ^TPersonalShopItem;

  TPersonalShopItem = packed record
    Price: UInt64;
    Slot: DWORD;
    Item: TItem;
  end;

type
  TPersonalShopData = packed record
    Index: DWORD;
    Name: ARRAY [0 .. 31] OF AnsiChar;
    Products: ARRAY [0 .. 9] OF TPersonalShopItem;
  end;

{$ENDREGION}
{$REGION 'Mail Data'}

type
  TMailContent = packed record
    Nick: Array [0 .. 15] of AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    Texto: Array [0 .. 511] of AnsiChar;
    Gold: DWORD;
    ItemSlot: Array [0 .. 6] of BYTE; // 4 slots mas sobra 3
  end;

type
  TStructCarta = packed record
    Index: UInt64;
    NickEnviado: Array [0 .. 15] of AnsiChar;
    Titulo: Array [0 .. 31] of AnsiChar;
    DataRetorno: Array [0 .. 19] of AnsiChar;
    Checked: Boolean;
    Return: Boolean;
    CheckItem: Boolean;
    Leilao: Boolean;
  end;

type
  TOpenMailContent = packed record
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
  end;

{$ENDREGION}
{$REGION 'Damage Data'}

type
  TDamageType = (Normal, Critical, Double, DoubleCritical, Immune,
    ImmuneCritical, ImmuneDouble, ImmuneDoubleCritical, Miss, MissCritical,
    MissDouble, MissCritical2, Miss2, Miss2Critical, Miss2Double,
    Miss2Critical2, Block, BlockCritical, BlockDouble, BlockCritical2, Immune2,
    Immune2Critical, Immune2Double, Immune2Critical2, Miss3, Miss3Critical,
    Miss3Double, Miss3Critical2, Miss4, Miss4Critical, Miss4Double,
    Miss4Critical2, None);

{$ENDREGION}
{$REGION 'Reliquare Data'}

type
  TReliquareForPacket = packed record
    ItemID: WORD;
    APP: WORD;
    Unknown: DWORD;
    TimeToEstabilish: DWORD;
    Unknown2: WORD;
    UnkByte1: BYTE; // valor 2
    UnkByte2: BYTE; // valor 1
    Unknown3: DWORD;
  end;

type
  TReliquareInfoForPacket = packed record
    ItemID: DWORD;
    NameCapped: Array [0 .. 15] of AnsiChar;
    TimeCapped: DWORD;
    IsActive: BYTE;
    Unk: Array [0 .. 2] of BYTE;
  end;

type
  TDevirForPacket = packed record
    Slots: Array [0 .. 4] of TReliquareForPacket;
  end;

type
  TDevirInfoForPacket = packed record
    Slots: Array [0 .. 4] of TReliquareInfoForPacket;
  end;

type
  TSpaceTemple = record
    DevirID: BYTE;
    SlotID: BYTE;
  end;

type
  TSecureArea = record
    SecureClientID: WORD;
    IsActive: Boolean;
    SecureType: BYTE;
    SecureDevir: Boolean;
    DevirID: BYTE;
    TempId: WORD;
    Position: TPosition;
    TimeInit: TDateTime;
    TotemFace: WORD;
    Effect: BYTE;
    WhoInitiated: Array [0 .. 15] of AnsiChar;
  end;

type
  TIdsArray = Array [0 .. 2] of Integer;

{$ENDREGION}

type
  TNeighbor = record
    Occuped: Boolean;
    pos: TPosition;
  end;

type
  TypeMobLocation = (Init, dest);

type
  Guards = (Guarda_Verband = 81, Guarda_Amarkand = 82, Guarda_Hekla = 117,
    Guarda_Regenchain = 485, Guarda_Amark_Devir = 486, Guarda_Mirza = 739,
    Guarda_Basilan = 888, Guarda_Sigmund = 889, Guarda_bat_Amark = 890,
    Guarda_bat_Verband = 897, Pedra_Guardia = 901, Guarda_bat_Mirza = 915,
    Guarda_Altar = 924, Guarda_bat_Basilan = 1935, Mago_bat_MIG = 1936,
    Guarda_real_Amark = 1925, Guarda_real_Sig = 1926, Guarda_bat_Hekla = 1927,
    Guarda_Bat_Mirza2 = 1922, Guarda_real_Verband = 1923, Guarda_Disc = 2595);

type
  TPetType = (X14, NORMAL_PET);

var
  TDungeonDificultNames: Array [0 .. 3] of String;

type
  TMasterPrives = (NonPriv, NonPriv2, NonPriv3, ModeradorPriv, GameMasterPriv,
    AdministratorPriv);

{$OLDTYPELAYOUT OFF}

implementation

uses
  Functions, GlobalDefs, DateUtils, AnsiStrings, Log;

{$REGION 'TPosition'}

constructor TPosition.Create(X, Y: Single);
begin
  self.X := X;
  self.Y := Y;
end;

function TPosition.IsValid: Boolean;
begin
  Result := not(self.X.IsInfinity or self.Y.IsInfinity or self.X.IsNan or
    self.Y.IsNan);
end;

function TPosition.Distance(const pos: TPosition): WORD;
var
  dif: TPosition;
  RR: Single;
begin
  Result := 65354;

  // Verifique se ambos são válidos antes de realizar o cálculo
  if (pos.IsValid) and (self.IsValid) then
  begin
    dif := self - pos; // Subtração direta
    RR := Sqrt(dif.X * dif.X + dif.Y * dif.Y); // Cálculo direto da distância

    // Elimina verificações desnecessárias
    if (RR <= 65354) then
      Result := Round(RR); // Limita a distância para 65354
  end;
end;

function TPosition.InRange(const pos: TPosition; range: BYTE): Boolean;
begin
  // Verifica se a distância está dentro do limite
  Result := (Distance(pos) <= range);
end;

class operator TPosition.Equal(pos1, pos2: TPosition): Boolean;
begin
  Result := (pos1.X = pos2.X) and (pos1.Y = pos2.Y);
end;

class operator TPosition.NotEqual(pos1, pos2: TPosition): Boolean;
begin
  Result := not(pos1 = pos2);
end;

class operator TPosition.Subtract(pos1, pos2: TPosition): TPosition;
begin
  Result.X := pos1.X - pos2.X;
  Result.Y := pos1.Y - pos2.Y;
end;

{$ENDREGION}
{$REGION 'Token Data'}

procedure TPlayerToken.Generate(Password: string);
begin
  AnsiStrings.StrPCopy(self.Token,
    AnsiString(TFunctions.StringToMd5(TFunctions.StringToMd5(Password) +
    TFunctions.StringToMd5(DateTimeToStr(Now)))));
  self.CreationTime := Now;
end;

{$ENDREGION}
{$REGION 'Item'}

function TItemCash.ToItem: TItem;
begin
  Result.Index := self.Index;
  Result.APP := self.APP;
  Result.Identific := self.Identific;
end;

function TItem.GetExpire: TDateTime;
begin
  Result := StrToDateTime(BASE_DATETIME);

  case ItemList[self.Index].ItemType of
    9:
      Result := IncDay(Result, self.Time);
  else
    Move(PDWORD(LPARAM(@self.Time) - 1)^, PDWORD(LPARAM(@Result) + 1)^, 3);
    // Corrigido o erro e otimizado o código
    Result := UnixToDateTime(PDWORD(LPARAM(@Result) + 1)^);
  end;
end;

procedure TItem.SetExpire(Time: TDateTime);
var
  UnixDate: Cardinal;
begin
  case ItemList[self.Index].ItemType of
    9:
      begin
        self.Time := DaysBetween(Time, StrToDateTime(BASE_DATETIME));
      end;
  else
    begin
      UnixDate := DateTimeToUnix(Time);
      Move(PDWORD(LPARAM(@UnixDate) + 1)^, PDWORD(LPARAM(@self.Time) - 1)^, 3);
    end;
  end;
end;

function TItem.GetIsSealed: Boolean;
begin
  Result := (PCardinal(@self.Refi)^ = 0);
end;

procedure TItem.SetIsSealed(Selado: Boolean);
begin

  if Selado then
  begin
    var
      Cardinal: Cardinal;
    Cardinal := 0;
    Move(Cardinal, self.Refi, sizeof(DWORD))
  end
  else
  begin
    self.Refi := 0;
    self.ExpireDate := IncHour(Now, ItemList[self.Index].Duration + 2);
  end;
end;

function TItem.GetEquipSellPrice: DWORD;
begin
  Result := Round(ItemList[self.Index].PriceGold * (self.MIN / self.MAX));
end;

{$ENDREGION}
{ TUpdateHpMpThread }

initialization

TDungeonDificultNames[0] := 'Normal';
TDungeonDificultNames[1] := 'Dificil';
TDungeonDificultNames[2] := 'Elite';
TDungeonDificultNames[3] := 'Infernal';

end.
