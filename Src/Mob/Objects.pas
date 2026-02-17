unit Objects;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Windows, SysUtils, MiscData;

{$OLDTYPELAYOUT ON}
{$REGION 'OBJECTS Threads'}
{$ENDREGION}
{$REGION 'Objects Data'}

type
  POBJ = ^TOBJ;

  TOBJ = record
    Index: word;
    Position: TPosition;
    ContentType: Byte;
    ContentAmount: Byte; // quantidade de itens depois de coletar
    ContentItemID: word;
    ContentCollectTime: Byte; // in seconds
    ReSpawn: Boolean;
    CreateTime: TDateTime;
    Face: smallint;
    Weapon: smallint;
    NameID: smallint;
  end;
{$ENDREGION}
{$OLDTYPELAYOUT OFF}

implementation

end.
