unit SkillFunctions;
{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}               // Ativa otimização de loops

interface

uses
  Player, SysUtils;

type
  TSkillFunctions = class(TObject)
  public
    class function GetSkillLevel(SkillIndex: WORD; out Level: Cardinal)
      : Integer;
    class function GetSkillPranLevel(SkillIndex, SkillLevel: WORD;
      out Level: Cardinal): Integer;
    class function GetSkillIndex(Classe, Skill, Level: Integer): Integer;
    class function GetClassSkillIndex(Classe, Skill: Integer): Integer;

    class function IncremmentSkillLevel(var Player: TPlayer;
      const Skill: Integer; out SkillID: Integer): Boolean;

    class function GetSkillIndexOnBar(SkillIndex: Cardinal): Cardinal;
    class function GetFromBarSkillIndex(BarIndex: Cardinal): Cardinal;

    class function IsSkillOnBar(const Player: TPlayer; SkillIndex: Integer;
      out BarIndex: Integer): Boolean;

    class function UpdateAllOnBar(var Player: TPlayer; SkillIndex: Integer;
      NewSkillIndex: Integer; out BarIndex: Integer): Boolean;
  end;

implementation

uses
  GlobalDefs, Math, PlayerData, Log, Windows;

class function TSkillFunctions.GetSkillLevel(SkillIndex: WORD;
  out Level: Cardinal): Integer;
begin
  Result := 0;

  Level := Trunc(Power(2, SkillData[SkillIndex].Level + 1) - 2);

  case Level of
    0 .. 65535:
      Result := 2;
    65536 .. 131080:
      Result := 4;
  end;
end;

class function TSkillFunctions.GetSkillPranLevel(SkillIndex, SkillLevel: WORD;
  out Level: Cardinal): Integer;
var
  l: Cardinal;
  a: Cardinal;
begin
  Result := 1;

  l := Round(Power(2, SkillLevel)) - 1;

  if (SkillIndex = 0) then
  begin
    Level := l;
  end
  else
  begin
    a := Round(Power(SkillIndex, 4));

    if a = 1 then
      a := 4;

    Level := l * a;

    case Level of
      0 .. 255:
        Result := 1;
      256 .. 65535:
        Result := 2;
    end;
  end;
end;

class function TSkillFunctions.GetSkillIndex(Classe: Integer; Skill: Integer;
  Level: Integer): Integer;
begin
  Result := 1;

  if Classe > 1 then
    Result := (Classe - 1) * 960;

  if Skill > 1 then
    inc(Result, (Skill - 1) * 16);

  if (Classe = 1) and (Level > 1) then
    inc(Result, Level - 1)
  else if (Classe > 1) and (Level > 1) then
    inc(Result, Level - 1)
  else
    inc(Result, Level);
end;

class function TSkillFunctions.GetClassSkillIndex(Classe,
  Skill: Integer): Integer;
begin
  Result := 1;

  if Classe > 1 then
    Result := (Skill mod (960 * (Classe - 1))) div 16;
end;

class function TSkillFunctions.IncremmentSkillLevel(var Player: TPlayer;
  const Skill: Integer; out SkillID: Integer): Boolean;
var
  dwSkill: Integer;
  i: Integer;
begin
  Result := False;

  // Verifica nas Skills.Basics
  for i := 0 to Length(Player.Character.Skills.Basics) - 1 do
  begin
    dwSkill := Player.Character.Skills.Basics[i].Index;
    if (Skill >= dwSkill) and (Skill <= dwSkill + 15) then
    begin
      inc(Player.Character.Skills.Basics[i].Level);
      SkillID := Player.Character.Skills.Basics[i].Index;
      Result := True;
      Break;
    end;
  end;

  // Se não encontrou nas Basics, verifica nas Skills.Others
  if not Result then
  begin
    for i := 0 to Length(Player.Character.Skills.Others) - 1 do
    begin
      dwSkill := Player.Character.Skills.Others[i].Index;
      if (Skill >= dwSkill) and (Skill <= dwSkill + 15) then
      begin
        inc(Player.Character.Skills.Others[i].Level);
        SkillID := Player.Character.Skills.Others[i].Index;
        Result := True;
        Break;
      end;
    end;
  end;
end;

class function TSkillFunctions.GetSkillIndexOnBar(SkillIndex: Cardinal): Cardinal;
begin
  Result := (SkillIndex * 16) + 2;
end;

class function TSkillFunctions.GetFromBarSkillIndex(BarIndex: Cardinal): Cardinal;
begin
  Result := Round((BarIndex - 2) / 16);
end;

class function TSkillFunctions.IsSkillOnBar(const Player: TPlayer;
  SkillIndex: Integer; out BarIndex: Integer): Boolean;
var
  i: Integer;
  BarSkillIndex: Integer;
begin
  Result := False;

  for i := 0 to Length(Player.Character.Base.ItemBar) - 1 do
  begin
    BarSkillIndex := Self.GetFromBarSkillIndex
      (Player.Character.Base.ItemBar[i]);
    if BarSkillIndex = SkillIndex then
    begin
      Result := True;
      BarIndex := i;
      Break;
    end;
  end;
end;

class function TSkillFunctions.UpdateAllOnBar(var Player: TPlayer;
  SkillIndex: Integer; NewSkillIndex: Integer; out BarIndex: Integer): Boolean;
var
  i: Integer;
begin
  Result := False;

  for i := 0 to Length(Player.Character.Base.ItemBar) - 1 do
  begin
    if Self.GetFromBarSkillIndex(Player.Character.Base.ItemBar[i]) = SkillIndex
    then
    begin
      Result := True;
      BarIndex := i;
      Player.Character.Base.ItemBar[BarIndex] :=
        GetSkillIndexOnBar(NewSkillIndex);
      Player.RefreshItemBarSlot(BarIndex, 2, NewSkillIndex);
      Break; // Interrompe o loop após encontrar o primeiro índice correspondente
    end;
  end;
end;

end.
