unit Util;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses System.Threading, GLobalDefs, Math;
function IFThen(cond: boolean; aTrue: variant; aFalse: variant)
  : variant; overload;
function IFThen(cond: boolean): boolean; overload;
function IncWord(var Variable: Word; Value: Integer): boolean; overload;
// function IncDWord(var Variable: Word; Value: Integer): boolean; overload;
function IncByte(var Variable: Byte; Value: Integer): boolean; overload;
function IntMV(var x: Integer; Value: Integer): boolean; overload;
function Dec(var x: Integer; Value: Integer): boolean; overload;
function DecCardinal(var x: Cardinal; Value: Integer): boolean; overload;
function DecInt(var x: Integer; Value: Integer): boolean; overload;
function DecWORD(var x: Word; Value: Integer): boolean; overload;
function Dec(var x: Word; Value: Integer): boolean; overload;
function Dec(var x: Byte; Value: Integer): boolean; overload;
function Dec(var x: Int64; Value: variant): boolean; overload;
function DecUInt64(var x: UInt64; Value: variant): boolean; overload;
function IncSpeedMove(var Variable: Word; Value: Integer): boolean; overload;
function IncCooldown(var Variable: Word; Value: Integer): boolean; overload;
function IncCritical(var Variable: Word; Value: Integer): boolean; overload;
function CalculateChance(var Tax: Integer; HelpForTheWinner: Word): boolean;

type
  DWORD = Longword;
  TLoopState = TParallel.TLoopState;

implementation

function IFThen(cond: boolean; aTrue: variant; aFalse: variant): variant;
begin
  if cond then
    Result := aTrue
  else
    Result := aFalse;
end;

function IFThen(cond: boolean): boolean;
begin
  Result := IFThen(cond, true, false);
end;

function IncWord(var Variable: Word; Value: Integer): boolean;
begin
  if (Variable + Value) >= MAX_WORD_SIZE then
    Variable := MAX_WORD_SIZE
  else if (Variable + Value) <= MIN_WORD_SIZE then
    Variable := MIN_WORD_SIZE
  else
    Variable := Variable + Value;

  Result := true;
end;

// function IncDword(var Variable: DWord; Value: Integer): Boolean;
// const
// MAX_DWORD_SIZE = High(DWord); // Valor máximo para DWord (4294967295)
// MIN_DWORD_SIZE = Low(DWord);  // Valor mínimo para DWord (0)
// begin
// if (Variable + Value) >= MAX_DWORD_SIZE then
// Variable := MAX_DWORD_SIZE
// else if (Variable + Value) <= MIN_DWORD_SIZE then
// Variable := MIN_DWORD_SIZE
// else
// Variable := Variable + Value;
//
// Result := True;
// end;
//

function IncByte(var Variable: Byte; Value: Integer): boolean;

var
  Res: Integer;
begin
  Res := Variable + Value;
  if (Res >= MAX_BYTE_SIZE) then
  begin
    Variable := MAX_BYTE_SIZE;
  end
  else if (Res <= MIN_BYTE_SIZE) then
  begin
    Variable := MIN_BYTE_SIZE;
  end
  else
    Variable := Res;
  Result := true;
end;

function IntMV(var x: Integer; Value: Integer): boolean;

var
  Res: Integer;
begin
  // if()
end;

function Dec(var x: Integer; Value: Integer): boolean;

begin
  x := x - Value;
  Result := true;
end;



function DecCardinal(var x: Cardinal; Value: Integer): boolean;

var
  Res: Integer;
begin
  Res := x - Value;
  if (Res < MIN_WORD_SIZE) then
  begin
    x := 0;
  end
  else
    x := Res;
  Result := true;
end;

function DecInt(var x: Integer; Value: Integer): boolean; overload;
begin
  if (x - Value < MIN_WORD_SIZE) then
    x := 0
  else
    x := x - Value;
  Result := true;
end;

function DecWORD(var x: Word; Value: Integer): boolean;
begin
  x := x - Value;
  if (x < MIN_WORD_SIZE) then
    x := 0
  else if (x > MAX_WORD_SIZE) then
    x := MAX_WORD_SIZE;
  Result := true;
end;

function Dec(var x: Word; Value: Integer): boolean;
begin
  x := x - Value;
  if x < MIN_WORD_SIZE then
    x := 0
  else if x > MAX_WORD_SIZE then
    x := MAX_WORD_SIZE;
  Result := true;
end;

function Dec(var x: Byte; Value: Integer): boolean;
begin
  x := x - Value;
  if (x < MIN_BYTE_SIZE) then
    x := MIN_BYTE_SIZE
  else if (x > MAX_BYTE_SIZE) then
    x := MAX_BYTE_SIZE;
  Result := true;
end;

function Dec(var x: Int64; Value: variant): boolean;
begin
  if (x - Value < MIN_BYTE_SIZE) then
    x := 0
  else
    x := x - Value;
  Result := true;
end;

function DecUInt64(var x: UInt64; Value: variant): boolean;
begin
  if (x - Value < MIN_BYTE_SIZE) then
    x := 0
  else
    x := x - Value;
  Result := true;
end;

function IncSpeedMove(var Variable: Word; Value: Integer): boolean; overload;
begin
  if (Variable + Value >= 70) then
    Variable := 70
  else if (Variable + Value <= 15) then
    Variable := 15
  else
    Variable := Variable + Value;

  Result := true;
end;

function IncCooldown(var Variable: Word; Value: Integer): boolean; overload;
begin
  if (Variable + Value >= 70) then
    Variable := 70
  else if (Variable + Value <= 0) then
    Variable := 0
  else
    Variable := Variable + Value;

  Result := true;
end;

function IncCritical(var Variable: Word; Value: Integer): boolean; overload;
begin
  if (Variable + Value >= 500) then
    Variable := 500
  else if (Variable + Value <= 0) then
    Variable := 0
  else
    Variable := Variable + Value;

  Result := true;
end;

function CalculateChance(var Tax: Integer; HelpForTheWinner: Word): boolean;

var
  TaxaRand: Integer;
begin
  Result := false;

  // Garantir que Tax não seja negativo e que o valor de Tax nunca ultrapasse 100
  if (Tax < 0) then
    Tax := Abs(Tax); // Torna Tax positivo caso seja negativo

  if Tax > MAX_PERCENTAGE then
    Tax := MAX_PERCENTAGE; // Limita Tax a 100%

  // Ajuste de Tax com base em HelpForTheWinner para evitar chance excessiva
  if Tax < HelpForTheWinner then
  begin
    // Se Tax for muito menor que HelpForTheWinner, podemos definir um valor mínimo
    if Tax < 10 then
    begin
      Tax := 10; // Garante que a chance mínima de sucesso seja 10%
    end
    else
    begin
      Tax := HelpForTheWinner;
      // Caso contrário, ajusta Tax para HelpForTheWinner
    end;
  end;

  // Calcula a chance gerando um valor aleatório entre 1 e 100
  Randomize;
  TaxaRand := RandomRange(1, 101); // Gera um número entre 1 e 100

  // Se o valor gerado aleatoriamente for menor ou igual à Tax, então o sucesso ocorre
  if Tax >= TaxaRand then
    Result := true; // A chance foi bem-sucedida
end;

end.
