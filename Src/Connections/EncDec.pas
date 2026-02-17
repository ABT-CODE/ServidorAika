unit EncDec;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

Type
  TEncDec = Class
  public
    class procedure Encrypt(src: pointer; Len: Word); overload; static;

    class procedure Encrypt(var src: array of Byte; Len: Word);
      overload; static;
    class function Decrypt(var src: array of Byte; Len: Word): boolean; static;
  end;

implementation

Uses SysUtils, MMSystem;

{$REGION 'Keys'}

const
  EncDecKeys: array [0 .. 511] of Byte = ($52, $B3, $F7, $20, $34, $FB, $8E,
    $4C, $21, $2A, $64, $E9, $2F, $89, $E7, $B9, $F1, $F2, $DF, $79, $F9, $40,
    $09, $FF, $9A, $04, $02, $85, $F3, $7A, $67, $45, $28, $BB, $3B, $46, $F3,
    $33, $89, $75, $5C, $56, $4A, $F7, $C4, $8F, $88, $BE, $28, $79, $C4, $5A,
    $A4, $52, $96, $12, $36, $AD, $93, $34, $C5, $66, $73, $A9, $62, $DB, $74,
    $CC, $CD, $59, $F9, $7D, $3B, $D5, $77, $70, $56, $DD, $91, $CB, $86, $CE,
    $82, $F1, $6F, $46, $BC, $98, $BB, $DC, $CE, $22, $19, $0F, $8B, $2A, $85,
    $7D, $69, $5D, $CB, $56, $27, $8B, $46, $0F, $B3, $FD, $EE, $5B, $4A, $0A,
    $92, $57, $E1, $E5, $61, $04, $C4, $B9, $AF, $FB, $7D, $F8, $F6, $5C, $F7,
    $F0, $1B, $08, $E3, $9F, $F3, $10, $5B, $C8, $06, $6D, $C5, $46, $93, $F1,
    $FB, $A1, $D4, $7D, $A9, $DF, $82, $75, $F6, $9C, $9C, $71, $66, $5D, $65,
    $35, $FE, $22, $AC, $E4, $AA, $3A, $4F, $70, $DD, $5B, $02, $55, $77, $F2,
    $4D, $87, $EB, $B8, $D4, $A8, $A1, $86, $DB, $7F, $99, $6A, $09, $A6, $52,
    $FA, $6C, $82, $EA, $E8, $BE, $78, $86, $D7, $E7, $5E, $F4, $6D, $C2, $30,
    $8F, $AA, $24, $05, $63, $78, $1B, $41, $92, $83, $73, $0B, $F7, $4A, $7F,
    $02, $08, $77, $16, $2B, $01, $6B, $DB, $2E, $3F, $1E, $C1, $C3, $E9, $26,
    $CF, $67, $D6, $15, $21, $53, $AB, $08, $30, $AE, $44, $7D, $53, $02, $56,
    $65, $85, $ED, $52, $7B, $68, $19, $8C, $D3, $8A, $6D, $9C, $B6, $E7, $85,
    $04, $AD, $B0, $60, $14, $DC, $4B, $59, $0B, $91, $9B, $59, $7F, $1D, $81,
    $4A, $FF, $E3, $A3, $CF, $F6, $AE, $6C, $32, $D2, $48, $54, $9E, $66, $48,
    $61, $8E, $8D, $2B, $ED, $85, $11, $A6, $AB, $00, $CB, $3B, $E5, $A8, $07,
    $CD, $3A, $EB, $61, $10, $BD, $B9, $29, $5F, $1D, $F1, $BF, $27, $65, $7B,
    $35, $C4, $CC, $C7, $0F, $3D, $94, $1C, $47, $2E, $32, $2D, $95, $05, $AF,
    $EE, $ED, $71, $4E, $A5, $48, $18, $6F, $44, $A7, $89, $B3, $F6, $55, $71,
    $61, $F8, $6D, $11, $09, $AA, $9D, $EF, $67, $E6, $29, $CC, $89, $90, $33,
    $D7, $34, $6E, $39, $20, $85, $3A, $DF, $4F, $D4, $F6, $EF, $96, $DD, $80,
    $9E, $E4, $22, $66, $11, $5C, $8B, $FB, $1F, $05, $50, $AB, $59, $C3, $18,
    $8B, $47, $86, $63, $34, $F5, $C1, $25, $D2, $AE, $1E, $B3, $78, $08, $70,
    $E3, $B7, $21, $E8, $6F, $6E, $27, $8D, $9B, $E3, $1E, $E6, $18, $13, $DD,
    $F9, $27, $47, $5A, $7A, $02, $E8, $28, $3C, $77, $94, $3E, $EB, $D6, $71,
    $FA, $FD, $0D, $C2, $66, $E6, $12, $B8, $B9, $8B, $81, $8A, $21, $FA, $87,
    $C8, $BF, $58, $FE, $EC, $F3, $1A, $D9, $32, $DB, $79, $C3, $A9, $16, $1F,
    $03, $8A, $CE, $27, $A3, $C9, $F5, $44, $D1, $EB, $CE, $40, $85, $17, $B0,
    $A9, $64, $6F, $07, $C7, $E5, $A1, $9B, $D0, $B2, $B8, $15, $5F, $51, $39,
    $BF, $23, $03, $6B, $8B, $D4, $EC, $F6, $57, $6C);
{$ENDREGION}

class procedure TEncDec.Encrypt(var src: array of Byte; Len: Word);
var
  I: Cardinal;
  Pos, key, rand_key, P: integer;
  sum1, sum2: integer;
  BufferDest: array of Byte;
  Buffer: LongInt;
  Uptime: Cardinal;
  pSrc, pDest: PByte;
  pBuffer: PLongInt;
begin
  SetLength(BufferDest, Len);
  sum1 := 0;
  sum2 := 0;
  I := 1;
  P := 4;
  Randomize;
  rand_key := Random(255);

  pDest := @BufferDest[0];
  pSrc := @src[0];

  pDest^ := WordRec(Len).Lo;
  Inc(pDest);
  pDest^ := WordRec(Len).Hi;
  Inc(pDest);
  pDest^ := rand_key;
  Inc(pDest);
  pDest^ := 0;
  Inc(pDest);

  Uptime := TimeGetTime;
  Move(Uptime, pDest^, 4);
  Inc(pDest, 4);

  Pos := EncDecKeys[rand_key * 2];

  while (I < (Len shr 2)) do
  begin
    key := EncDecKeys[((Pos and $FF) * 2) + 1];
    pBuffer := PLongInt(pSrc + P);
    Buffer := pBuffer^;
    sum1 := sum1 + Buffer;

    case (I and 3) of
      0:
        begin
          key := key * 4;
          Buffer := (Buffer + key);
        end;

      1:
        begin
          key := key shr 1;
          Buffer := (Buffer - key);
        end;

      2:
        begin
          key := key + key;
          Buffer := (Buffer + key);
        end;

      3:
        begin
          key := key shr 2;
          Buffer := (Buffer - key);
        end;
    end;

    pBuffer := PLongInt(pDest + P);
    pBuffer^ := Buffer;

    Inc(sum2, Buffer);
    Inc(I);
    Inc(Pos);
    Inc(P, 4);
  end;

  sum1 := sum1 and $FF;
  sum2 := sum2 and $FF;
  BufferDest[3] := ((sum2 - sum1) and 255);

  Move(BufferDest[0], src[0], Length(BufferDest));
end;

class procedure TEncDec.Encrypt(src: pointer; Len: Word);
var
  I, Pos, rand_key: integer;
  key, sum1, sum2: Int64;
  Buffer: PLongInt;
  Uptime: Cardinal;
  P: PByte;
begin
  sum1 := 0;
  sum2 := 0;

  // Gerar a chave aleatória fora da função, se possível
  rand_key := Random(255);

  // Move o comprimento e a chave aleatória para o início do buffer
  PWord(src)^ := Len;
  PByte(PByte(src) + 3)^ := rand_key;

  Uptime := TimeGetTime;
  PCardinal(PByte(src) + 8)^ := Uptime;

  Pos := EncDecKeys[rand_key * 2];
  P := PByte(PByte(src) + 4);

  for I := 1 to (Len shr 2) - 1 do
  begin
    key := Int64(EncDecKeys[((Pos and $FF) * 2) + 1]); // Garantir que key seja Int64
    Buffer := PLongInt(P);

    Inc(sum1, Buffer^);

    case (I and 3) of
      0: key := key shl 2; // Multiplica key por 4
      1: key := key shr 1; // Desloca key para a direita em 1
      2: key := key * 2;   // Dobra key (equivalente a `shl 1`)
      3: key := key shr 2; // Desloca key para a direita em 2
    end;

    if (I and 1) = 0 then
      Inc(Buffer^, key)
    else
      Dec(Buffer^, key);

    Inc(sum2, Buffer^);

    Inc(Pos);
    Inc(P, 4);
  end;

  // Calcular soma final
  PByte(PByte(src) + 2)^ := Byte((sum2 - sum1) and $FF);
end;

class function TEncDec.Decrypt(var src: array of Byte; Len: Word): Boolean;
var
  Pos, Offset, I: Integer;
  key: Integer;
  sum1, sum2: Int64;
  pBuffer: PInteger;
  endIndex: Integer;
begin
  sum1 := 0;
  sum2 := 0;

  Pos := EncDecKeys[(src[3] shl 1) and $1FF]; // garantir índice no range

  Offset := 4;
  endIndex := (Len shr 2) - 1;
  I := 1;

  // Loop manual, enquanto I <= endIndex
  while I <= endIndex do
  begin
    pBuffer := PInteger(@src[Offset]);
    key := EncDecKeys[((Pos and $FF) shl 1) + 1];

    sum1 := sum1 + Int64(pBuffer^);

    case I and 3 of
      0: Dec(pBuffer^, key shl 2);
      1: Inc(pBuffer^, key shr 1);
      2: Dec(pBuffer^, key shl 1);
      3: Inc(pBuffer^, key shr 2);
    end;

    sum2 := sum2 + Int64(pBuffer^);

    Inc(Pos);
    Inc(Offset, 4);
    Inc(I);
  end;

  sum1 := sum1 and $FF;
  sum2 := sum2 and $FF;

  // Retorna true se checksum estiver incorreto
  Result := (src[2] <> Byte((sum1 - sum2) and $FF));
end;

end.
