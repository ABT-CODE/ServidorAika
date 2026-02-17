unit BaseNpc;

interface

{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}

// Ativa otimização de loops
uses
  Windows, PlayerData, Diagnostics, Generics.Collections, Packets, SysUtils,
  MiscData, AnsiStrings, FilesData, Math, sql, basemob;
{$OLDTYPELAYOUT ON}

type
  PBaseNpc = ^TBaseNpc;

  TBaseNpc = record
  private
    // _prediction: TPrediction;
    _cooldown: TDictionary<WORD, TTime>;
    _buffs: TDictionary<smallint, TDateTime>;
    // _currentPosition: TPosition;
    procedure AddToVisible(var mob: TBaseNpc; SpawnType: Byte = 0);
    procedure AddVisiblePlayer(var mob: TBaseMob; SpawnType: Byte = 0);
    procedure RemoveFromVisible(mob: TBaseNpc; SpawnType: Byte = 0);
    procedure RemoveFromVisiblePlayer(mob: TBaseMob; SpawnType: Byte = 0);
  public
    IsDead: Boolean;
    ClientID: smallint;
    PranClientID: WORD;
    // PetClientID: WORD;
    Character: PCustomNpc;
    PlayerCharacter: TNpcCharacter;
    AttackSpeed: Byte;
    IsActive: Boolean;
    IsDirty: Boolean;
    Mobbaby: WORD;
    // PartyId: WORD;
    // PartyRequestId: WORD;
    VisibleMobs: TList<Byte>;
    VisibleNPCS: TList<Byte>;
    VisiblePlayers: TList<Byte>;
    TimeForGoldTime: TDateTime;
    VisibleTargets: Array of TMobTarget;
    VisibleTargetsCnt: Byte; // aqui vai ser o controle da lista propia
    LastTimeGarbaged: TDateTime;
    target: PBaseNpc;
    IsDungeonMob: Boolean;
    InClastleVerus: Boolean;
    LastReceivedSkillFromCastle: TDateTime;
    PositionSpawnedInCastle: TPosition;
    NationForCastle: Byte;
    NpcIdGen: smallint;
    NpcQuests: Array [0 .. 7] of TQuestMisc;
    PersonalShopIndex: Byte;
    PersonalShop: TPersonalShopData;
    MOB_EF: ARRAY [0 .. 395] OF Integer;
    EQUIP_CONJUNT: ARRAY [0 .. 15] OF WORD;
    EFF_5: Array [0 .. 2] of WORD; // podemos ter at� 3 efeitos 5
    IsPlayerService: Boolean;
    ChannelId: Byte;
    Neighbors: Array [0 .. 8] of TNeighbor;
    EventListener: Boolean;
    EventAction: Byte;
    EventSkillID: smallint;
    EventSkillEtc1: smallint;
    HPRListener: Boolean; // HPR = HP Recovery
    HPRAction: Byte;
    HPRSkillID: smallint;
    HPRSkillEtc1: smallint;
    SKDListener: Boolean; // SKD = Skill Damage
    SKDAction: Byte;
    SKDSkillID: smallint;
    SKDTarget: smallint;
    SKDSkillEtc1: smallint;
    SKDIsMob: Boolean;
    SDKMobID, SDKSecondIndex: smallint;
    Mobid: smallint;
    SecondIndex: smallint;
    IsBoss: Boolean;
    { Skill }
    Chocado: Boolean; // definir quando usa o choque hidra
    LastBasicAttack: TDateTime;
    // LastAttackMsg: TDateTime;
    // AttackMsgCount: Integer;
    UsingSkill: smallint;
    ResolutoPoints: Byte;
    ResolutoTime: TDateTime;
    DefesaPoints: smallint;
    DefesaPoints2: smallint;
    BolhaPoints: Byte;
    LaminaID: smallint;
    LaminaPoints: smallint;
    Polimorfed: Boolean;
    UsingLongSkill: Boolean;
    LongSkillTimes: smallint;
    UniaoDivina: String;
    SessionOnline: Boolean;
    SessionUsername: String;
    SessionMasterPriv: TMasterPrives;
    MissCount: Byte;
    NegarCuraCount: smallint;
    RevivedTime: TDateTime;
    CurrentAction: Integer;
    LastSplashTime: TDateTime;

    ActiveTitle: Byte;
    LastReceivedAttack: TDateTime;
    LastMovedTime: TDateTime;
    LastMovedMessageHack: TDateTime;
    AttacksAccumulated, AttacksReceivedAccumulated: Byte;
    DroppedCount: Byte;
    { TBaseNpc }

    procedure Create(characterPointer: PCustomNpc; Index: WORD; ChannelId: Byte;
      act: Boolean = false);
    procedure Destroy(Aux: Boolean = false);
    function IsPlayer: Boolean;
    procedure UpdateVisibleList(SpawnType: Byte = 0);
    // function CurrentPosition: TPosition;
    // procedure SetDestination(const Destination: TPosition);
    procedure addvisible(m: TBaseNpc);
    procedure removevisible(m: TBaseNpc);
    procedure AddHP(Value: Integer; ShowUpdate: Boolean);
    procedure AddMP(Value: Integer; ShowUpdate: Boolean);
    procedure RemoveHP(Value: Integer; ShowUpdate: Boolean;
      StayOneHP: Boolean = false);
    procedure RemoveMP(Value: Integer; ShowUpdate: Boolean);
    procedure WalkinTo(Pos: TPosition);
    procedure SetEquipEffect(const Equip: TItem; SetType: Integer;
      ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
    procedure SetConjuntEffect(Index: Integer; SetType: Integer);
    procedure ConfigEffect(Count, ConjuntId: Integer; SetType: Integer);
    procedure SetOnTitleActiveEffect();
    procedure SetOffTitleActiveEffect();
    function MatchClassInfo(ClassInfo: Byte): Boolean;
    function IsCompleteEffect5(out CountEffects: Byte): Boolean;
    function SearchEmptyEffect5Slot(): Byte;
    function GetSlotOfEffect5(CallID: WORD): Byte;
    procedure LureMobsInRange();
    { Send's }
    procedure SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True; Polimorf: WORD = 0);
    procedure SendRemoveMob(delType: Integer = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True);
    procedure SendToVisible(var Packet; size: WORD; sendToSelf: Boolean = True);
    procedure SendPacket(var Packet; size: WORD);
    procedure SendRefreshLevel;
    procedure SendCurrentHPMP(Update: Boolean = false);
    procedure SendCurrentHPMPMob();
    procedure SendStatus;
    procedure SendRefreshPoint;
    procedure SendRefreshKills;
    procedure SendEquipItems(SendSelf: Boolean = True);
    procedure SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
      Notice: Boolean); overload;
    procedure SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean); overload;
    procedure SendSpawnMobs;
    procedure GenerateBabyMob;
    procedure UngenerateBabyMob(ungenEffect: WORD);
    function AddTargetToList(target: PBaseNpc): Boolean;
    function RemoveTargetFromList(target: PBaseNpc): Boolean;
    function ContainsTargetInList(target: PBaseNpc; out id: WORD)
      : Boolean; overload;
    function ContainsTargetInList(ClientID: WORD): Boolean; overload;
    function ContainsTargetInList(ClientID: WORD; out id: WORD)
      : Boolean; overload;
    function GetEmptyTargetInList(out Index: WORD): Boolean;
    function GetTargetInList(ClientID: WORD): PBaseNpc;
    function ClearTargetList(): Boolean;
    function TargetGarbageService(): Boolean;
    { Get's }
    procedure GetCreateMob(out Packet: TSendCreateNpcPacket;
      P1: WORD = 0); overload;
    class function GetMob(Index: WORD; Channel: Byte; out mob: TBaseNpc)
      : Boolean; overload; static;
    class function GetMob(Index: WORD; Channel: Byte; out mob: PBaseNpc)
      : Boolean; overload; static;
    { class function GetMob(Pos: TPosition; Channel: Byte; out mob: TBaseNpc)
      : Boolean; overload; static; }
    function GetMobAbility(eff: Integer): Integer;
    procedure IncreasseMobAbility(eff: Integer; Value: Integer);
    procedure DecreasseMobAbility(eff: Integer; Value: Integer);
    function GetCurrentHP(): DWORD;
    function GetCurrentMP(): DWORD;
    function GetRegenerationHP(): DWORD;
    function GetRegenerationMP(): DWORD;
    function GetEquipedItensHPMPInc: DWORD;
    function GetEquipedItensDamageReduce: DWORD;
    function GetMobClass(ClassInfo: Integer = 0): Integer;
    procedure GetCurrentScore;
    procedure GetEquipDamage(const Equip: TItem);
    procedure GetEquipDefense(const Equip: TItem);
    procedure GetEquipsDefense;
    { Buffs }
    function RefreshBuffs: Integer;
    procedure SendRefreshBuffs;
    procedure SendAddBuff(BuffIndex: WORD);
    procedure AddBuffEffect(Index: WORD);
    procedure RemoveBuffEffect(Index: WORD);
    function GetBuffToRemove(): DWORD;
    function GetDeBuffToRemove(): DWORD;
    function GetDebuffCount(): WORD;
    function GetBuffCount(): WORD;
    procedure RemoveBuffByIndex(Index: WORD);
    function GetBuffSameIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByIndex(BuffIndex: DWORD): Boolean;
    function BuffExistsByID(BuffID: DWORD): Boolean;
    function BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
    function BuffExistsSopa(): Boolean;
    function GetBuffIDByIndex(Index: DWORD): WORD;
    procedure RemoveBuffs(Quant: Byte);
    procedure RemoveDebuffs(Quant: Byte);
    procedure ZerarBuffs();
    { Attack & Skills }
    procedure CheckCooldown(var Packet: TSendSkillUse);
    function CheckCooldown2(SkillID: DWORD): Boolean;
    procedure SendCurrentAllSkillCooldown();
    function AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
      AddTime: Boolean = false; TimeAditional: Integer = 0): Boolean;
    function AddBuffWhenEntering(BuffIndex: Integer;
      BuffTime: TDateTime): Boolean;
    function GetBuffSlot(BuffIndex: WORD): Integer;
    function GetEmptyBuffSlot(): Integer;
    function RemoveBuff(BuffIndex: WORD): Boolean;
    procedure RemoveAllDebuffs();

    procedure SendDamage(Skill, Anim: DWORD; mob: PBaseNpc;
      DataSkill: P_SkillData);
    function GetDamage(Skill: DWORD; mob: PBaseNpc;
      out DnType: TDamageType): UInt64;
    function GetDamageType(Skill: DWORD; IsPhysical: Boolean; mob: PBaseNpc)
      : TDamageType;
    function GetDamageType2(Skill: DWORD; IsPhysical: Boolean; mob: PBaseNpc)
      : TDamageType;
    function GetDamageType3(Skill: DWORD; IsPhysical: Boolean; mob: PBaseNpc)
      : TDamageType;
    procedure CalcAndCure(Skill: DWORD; mob: PBaseNpc);
    function CalcCure(Skill: DWORD; mob: PBaseNpc): Integer;
    function CalcCure2(BaseCure: DWORD; mob: PBaseNpc;
      xSkill: Integer = 0): Integer;
    procedure HandleSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      SelectedPos: TPosition; DataSkill: P_SkillData);
    function ValidAttack(DmgType: TDamageType; DebuffType: Byte = 0;
      mob: PBaseNpc = nil; AuxDano: Integer = 0;
      xisBoss: Boolean = false): Boolean;
    procedure MobKilledInDungeon(mob: PBaseNpc);
    procedure MobKilled(mob: PBaseNpc; out DroppedExp: Boolean;
      out DroppedItem: Boolean; InParty: Boolean = false);
    procedure DropItemFor(PlayerBase: PBaseNpc; mob: PBaseNpc);
    procedure PlayerKilled(mob: PBaseNpc; xRlkSlot: Byte = 0);
    { Parses }
    procedure SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseNpc; Pos: TPosition);
    procedure TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure TargetSkill(Skill, Anim: DWORD; mob: PBaseNpc; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure AreaBuff(Skill, Anim: DWORD; mob: PBaseNpc;
      Packet: TRecvDamagePacket);
    procedure AreaSkill(Skill, Anim: DWORD; mob: PBaseNpc; SkillPos: TPosition;
      DataSkill: P_SkillData; DamagePerc: Single = 0; ElThymos: Integer = 0);
    procedure AttackParse(Skill, Anim: DWORD; mob: PBaseNpc; var Dano: Integer;
      var DmgType: TDamageType; out AddBuff: Boolean; out MobAnimation: Byte;
      DataSkill: P_SkillData);
    procedure AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseNpc;
      var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
      out MobAnimation: Byte);
    procedure Effect5Skill(mob: PBaseNpc; EffCount: Byte;
      xPassive: Boolean = false);
    function IsSecureArea(): Boolean;
    { Skill classes handle }
    procedure WarriorSkill(Skill, Anim: DWORD; mob: PBaseNpc; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure TemplarSkill(Skill, Anim: DWORD; mob: PBaseNpc; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure RiflemanSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure MagicianSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure ClericSkill(Skill, Anim: DWORD; mob: PBaseNpc; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean);
    procedure WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; out MoveToTarget: Boolean);
    procedure TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    procedure ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean);
    { Effect Functions }
    procedure SendEffect(EffectIndex: DWORD);
    { Move/Teleport }
    procedure Teleport(Pos: TPosition); overload;
    procedure Teleport(Posx, Posy: WORD); overload;
    procedure Teleport(Posx, Posy: string); overload;
    procedure WalkTo(Pos: TPosition; speed: WORD = 70; MoveType: Byte = 0);
    procedure WalkAvanced(Pos: TPosition; SkillID: Integer);
    procedure WalkBacked(Pos: TPosition; SkillID: Integer; mob: PBaseNpc);
    { Pets }
    procedure CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD = 0);
    procedure DestroyPet(PetID: WORD);
    { Class }
    // class procedure ForEachInRange(Pos: TPosition; range: Byte;
    // proc: TProc<TPosition, TBaseNpc>; ChannelId: Byte); overload; static;
    // procedure ForEachInRange(range: Byte;
    // proc: TProc<TPosition, TBaseNpc, TBaseNpc>); overload;

  end;
{$REGION 'HP / MP Increment por level'}

const
  HPIncrementPerLevel: array [0 .. 5] of smallint = (75,
    // War (150 reduzido em 50%)
    70, // Tp (140 reduzido em 50%)
    57, // Att (115 reduzido em 50%)
    60, // Dual (120 reduzido em 50%)
    55, // Fc (110 reduzido em 50%)
    65 // Santa (130 reduzido em 50%)
    );

const
  MPIncrementPerLevel: array [0 .. 5] of smallint = (55,
    // War (110 reduzido em 50%)
    65, // Tp (130 reduzido em 50%)
    72, // Att (145 reduzido em 50%)
    75, // Dual (150 reduzido em 50%)
    300, // Fc (330 reduzido em 50%)
    67 // Santa (135 reduzido em 50%)
    );
{$ENDREGION}
{$OLDTYPELAYOUT OFF}

implementation

uses
  Player, GlobalDefs, Util, Log, ItemFunctions, Functions, DateUtils, mob,
  PartyData, PacketHandlers;

{$REGION 'TBaseNpc'}

procedure TBaseNpc.Destroy(Aux: Boolean);
begin
  Self.IsActive := Aux;

  // Liberar as listas de mobs, NPCs e jogadores, uma vez que não são mais necessárias.
  FreeAndNil(VisibleMobs);
  FreeAndNil(VisibleNPCS);
  FreeAndNil(VisiblePlayers);

  // Liberar recursos de cooldown e buffs.
  FreeAndNil(_cooldown);
  FreeAndNil(_buffs);

  // Zerar a referência na lista de Prans.
  Servers[Self.ChannelId].Prans[Self.PranClientID] := 0;

  // Limpar a lista de alvos e o próprio alvo.
  ClearTargetList();
  Self.target := nil;

  // Definir o valor de IsBoss para False.
  Self.IsBoss := false;

  // Apagar os dados internos sem necessidade de outras variáveis intermediárias.
  ZeroMemory(@Self, SizeOf(TBaseNpc));
end;

procedure TBaseNpc.Create(characterPointer: PCustomNpc; Index: WORD;
  ChannelId: Byte; act: Boolean = false);
begin
  ZeroMemory(@Self, SizeOf(TBaseNpc));

  // Inicialização das listas
  VisibleMobs := TList<Byte>.Create;
  VisibleNPCS := TList<Byte>.Create;
  VisiblePlayers := TList<Byte>.Create;
  SetLength(VisibleTargets, 1);

  // Inicialização de variáveis
  LastTimeGarbaged := Now;
  // LastAttackMsg := Now;
  LastBasicAttack := Now;
  // AttackMsgCount := 0;
  // AttacksAccumulated := 0;
  // DroppedCount := 0;
  // AttacksReceivedAccumulated := 0;
  IsActive := True;
  IsDirty := false;
  LastReceivedSkillFromCastle := Now;
  InClastleVerus := false;

  Character := characterPointer;
  // if Index = 3355 then
  // for var i := 0 to 15 do
  // begin
  // writeln('criando npc');
  // Self.PlayerCharacter.Base.Equip[i].Index := 1;
  // end;
  ClientID := Index;
  Self.ChannelId := ChannelId;
  RevivedTime := Now;
  LastSplashTime := Now;

  // Ajuste da NPC ID
  if (Index >= 2048) and (Index <= 3047) then
    Self.NpcIdGen := Index - 2047;


  // if (Index >= 50000) and (Index <= 50010) then
  // Self.NpcIdGen := Index - 2047;

  // Inicialização de dicionários
  _cooldown := TDictionary<WORD, TTime>.Create;
  _buffs := TDictionary<smallint, TDateTime>.Create(40);

  // if act then
  // SetLength(Character^.Inventory, 64)
  // else
  // SetLength(Character^.Inventory, 126);

end;

function TBaseNpc.IsPlayer: Boolean;
begin
  Result := IfThen(ClientID <= MAX_CONNECTIONS);
end;

procedure TBaseNpc.UpdateVisibleList(SpawnType: Byte = 0);
var
  OtherPlayer: PPlayer;
  key: TPlayerKey;
begin

{$REGION PLAYER VISIBLE LIST}

  for Key in ActivePlayers.Keys do
  begin

        if Key.ServerID <> Self.ChannelID  then
        continue;

          // Acessa o jogador associado à chave
          OtherPlayer := @Servers[Key.ServerID].Players[Key.ClientID];

          if not TFunctions.IsPlayerPlaying(OtherPlayer) then
          continue;

      Case Self.ClientID of
        3355 .. 3369:
          begin
            if Servers[Self.ChannelId].DevirGuards[Self.ClientID].PlayerChar.LastPos.InRange(OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) and
              (OtherPlayer^.Base.IsPlayer) and (Servers[Self.ChannelId].DevirGuards[Self.ClientID].PlayerChar.Base.Nation <> OtherPlayer^.Base.Character.Nation) then
            begin
              if not(Servers[Self.ChannelId].DevirGuards[Self.ClientID]
                .Base.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
              begin
                Servers[Self.ChannelId].DevirGuards[Self.ClientID]
                  .Base.AddVisiblePlayer(OtherPlayer^.Base);
              end;

            end
            else
            begin
              if Servers[Self.ChannelId].DevirGuards[Self.ClientID]
                .Base.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
              begin
                Servers[Self.ChannelId].DevirGuards[Self.ClientID]
                  .Base.RemoveFromVisiblePlayer(OtherPlayer^.Base);
              end;
            end;

          end;
        3340 .. 3354:
          begin
            if Servers[Self.ChannelId].DevirStones[Self.ClientID]
              .PlayerChar.LastPos.InRange
              (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) and
              (OtherPlayer^.Base.IsPlayer) and
              (Servers[Self.ChannelId].DevirStones[Self.ClientID]
              .PlayerChar.Base.Nation <> OtherPlayer^.Base.Character.Nation) then
            begin
              if not(Servers[Self.ChannelId].DevirStones[Self.ClientID]
                .Base.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
              begin
                Servers[Self.ChannelId].DevirStones[Self.ClientID]
                  .Base.AddVisiblePlayer(OtherPlayer^.Base);
              end;

            end
            else
            begin
              if Servers[Self.ChannelId].DevirStones[Self.ClientID]
                .Base.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
              begin
                Servers[Self.ChannelId].DevirStones[Self.ClientID]
                  .Base.RemoveFromVisiblePlayer(OtherPlayer^.Base);
              end;
            end;
          end;
        Inicio_Guardas_Royal .. Fim_Guardas_Royal:
          begin
            if Servers[Self.ChannelId].RoyalGuards[Self.ClientID]
              .PlayerChar.LastPos.InRange
              (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) and
              (OtherPlayer^.Base.IsPlayer) and
              (Servers[Self.ChannelId].RoyalGuards[Self.ClientID]
              .PlayerChar.Base.Nation <> OtherPlayer^.Base.Character.Nation) then
            begin
              if not(Servers[Self.ChannelId].RoyalGuards[Self.ClientID]
                .Base.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID)) then
              begin
                Servers[Self.ChannelId].RoyalGuards[Self.ClientID]
                  .Base.AddVisiblePlayer(OtherPlayer^.Base);
              end;

            end
            else
            begin
              if Servers[Self.ChannelId].RoyalGuards[Self.ClientID]
                .Base.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
              begin
                Servers[Self.ChannelId].RoyalGuards[Self.ClientID]
                  .Base.RemoveFromVisiblePlayer(OtherPlayer^.Base);
              end;
            end;

          end;

      End;




	end;

{$ENDREGION}
end;

procedure TBaseNpc.AddToVisible(var mob: TBaseNpc; SpawnType: Byte = 0);
begin
  Writeln(' 1 adicionando npc ao visible ');
  if Self.IsPlayer then
  begin
    if not VisiblePlayers.Contains(mob.ClientID) then
    begin
      VisiblePlayers.Add(mob.ClientID);
      mob.AddToVisible(Self);
      mob.SendCreateMob(SPAWN_NORMAL, Self.ClientID, false);
      if not Self.AddTargetToList(@mob) then
      begin
        Logger.Write('Não foi possível adicionar alvo na lista de targets.',
          TLogType.Error);
      end;
    end;
  end
  else if mob.IsPlayer then
  begin
    VisiblePlayers.Add(mob.ClientID);
    if not mob.VisiblePlayers.Contains(Self.ClientID) then
    begin
      mob.VisiblePlayers.Add(Self.ClientID);
    end;
  end;

end;

procedure TBaseNpc.AddVisiblePlayer(var mob: TBaseMob; SpawnType: Byte = 0);
begin
  Writeln(' 2 adicionando npc ao visible ');
  Self.VisiblePlayers.Add(mob.ClientID);
end;

procedure TBaseNpc.RemoveFromVisible(mob: TBaseNpc; SpawnType: Byte = 0);
begin
  try
    if not mob.IsActive or (mob.ClientID = 0) or not Self.IsActive then
      Exit;

    VisiblePlayers.Remove(mob.ClientID);

    if Self.IsPlayer then
    begin
      mob.SendRemoveMob(0, Self.ClientID);
      Writeln('apagando mob 1');
    end;

    if mob.VisiblePlayers.Contains(Self.ClientID) then
    begin
      mob.RemoveFromVisible(Self);
      mob.RemoveTargetFromList(@Self);
    end;

    Self.RemoveTargetFromList(@mob);

    if (target <> nil) and (target.ClientID = mob.ClientID) then
      target := nil;
  except
    on E: Exception do
      Logger.Write('Error at removefromvisible: ' + E.Message, TLogType.Error);
  end;
end;

procedure TBaseNpc.RemoveFromVisiblePlayer(mob: TBaseMob; SpawnType: Byte = 0);
begin
  try
    if not mob.IsActive or (mob.ClientID = 0) or not Self.IsActive then
      Exit;

    Self.VisiblePlayers.Remove(mob.ClientID);

    if Self.IsPlayer then
    begin
      mob.SendRemoveMob(0, Self.ClientID);
      Writeln('apagando mob 1');
    end;

    if mob.VisiblePlayers.Contains(Self.ClientID) then
    begin
      Self.RemoveFromVisible(Self);
      Self.RemoveTargetFromList(@Self);
    end;

    Self.RemoveTargetFromList(@mob);

    if (target <> nil) and (target.ClientID = mob.ClientID) then
      target := nil;
  except
    on E: Exception do
      Logger.Write('Error at removefromvisible: ' + E.Message, TLogType.Error);
  end;
end;

function TBaseNpc.AddTargetToList(target: PBaseNpc): Boolean;
var
  id, id2: WORD;
begin
  Result := false;
  try
    if not(ContainsTargetInList(target.ClientID, id2)) then
    begin
      VisibleTargetsCnt := Length(VisibleTargets) + 1;
      SetLength(VisibleTargets, VisibleTargetsCnt);

      if (GetEmptyTargetInList(id)) then
      begin
        VisibleTargets[id].ClientID := target.ClientID;

        case target.ClientID of
          1 .. 1000:
            begin
              VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
              VisibleTargets[id].Player := target;
              VisibleTargets[id].TargetType := 0;
            end;
          1001 .. 3339, 3370 .. 3390, 3430 .. 9147:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].MOBS.TMobS
                [target.Mobid].MobsP[target.SecondIndex]
                .Base.PlayerCharacter.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3340 .. 3354:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirStones
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3355 .. 3369:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirGuards
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3391 .. 3429:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirGuards
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
        end;
        Result := True;
      end
      else
      begin
        id := VisibleTargetsCnt - 1;
        VisibleTargets[id].ClientID := target.ClientID;

        case target.ClientID of
          1 .. 1000:
            begin
              VisibleTargets[id].Position := target.PlayerCharacter.LastPos;
              VisibleTargets[id].Player := target;
              VisibleTargets[id].TargetType := 0;
            end;
          1001 .. 3339, 3370 .. 3390, 3430 .. 9147:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].MOBS.TMobS
                [target.Mobid].MobsP[target.SecondIndex]
                .Base.PlayerCharacter.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3340 .. 3354:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirStones
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3355 .. 3369:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirGuards
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
          3391 .. 3429:
            begin
              VisibleTargets[id].Position := Servers[Self.ChannelId].DevirGuards
                [target.ClientID].PlayerChar.LastPos;
              VisibleTargets[id].mob := target;
              VisibleTargets[id].TargetType := 1;
            end;
        end;
        Result := True;
      end;
    end
    else
    begin
      Result := True;
    end;
  except
    on E: Exception do
    begin
      Logger.Write('AddTargetToList: ' + E.Message, TLogType.Error);
    end;
  end;
end;

function TBaseNpc.RemoveTargetFromList(target: PBaseNpc): Boolean;
var
  id: WORD;
begin
  Result := false;
  if ContainsTargetInList(target, id) then
  begin
    with VisibleTargets[id] do
    begin
      ClientID := 0;
      TargetType := 0;
      Position.x := 0;
      Position.y := 0;
      Player := nil;
      mob := nil;
    end;
    dec(VisibleTargetsCnt, 1);
    Result := True;
  end;
end;

function TBaseNpc.ContainsTargetInList(target: PBaseNpc; out id: WORD): Boolean;
var
  i: WORD;
begin
  // Writeln(' contem target em lista ');
  Result := false;

  if Length(VisibleTargets) > 0 then
  begin
    for i := 0 to Length(VisibleTargets) - 1 do
    begin
      if VisibleTargets[i].ClientID = target.ClientID then
      begin
        id := i;
        Result := True;
        Exit;
      end;
    end;
  end;
end;

function TBaseNpc.ContainsTargetInList(ClientID: WORD): Boolean;
var
  i: WORD;
begin
  Result := false;

  if Length(VisibleTargets) > 0 then
  begin
    for i := 0 to Length(VisibleTargets) - 1 do
    begin
      if VisibleTargets[i].ClientID = ClientID then
      begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

function TBaseNpc.ContainsTargetInList(ClientID: WORD; out id: WORD): Boolean;
var
  i: WORD;
begin
  Result := false;

  if Length(VisibleTargets) > 0 then
  begin
    for i := 0 to Length(VisibleTargets) - 1 do
    begin
      if VisibleTargets[i].ClientID = ClientID then
      begin
        Result := True;
        id := i;
        Exit; // Exit imediatamente ao encontrar o alvo
      end;
    end;
  end;
end;

function TBaseNpc.GetEmptyTargetInList(out Index: WORD): Boolean;
var
  i: WORD;
begin
  Result := false;
  for i := Low(VisibleTargets) to High(VisibleTargets) do
  begin
    if (VisibleTargets[i].ClientID = 0) then
    begin
      Index := i;
      Result := True;
      Exit;
    end;
  end;
end;

function TBaseNpc.GetTargetInList(ClientID: WORD): PBaseNpc;
var
  i: WORD;
begin
  Result := nil;

  if Length(VisibleTargets) = 0 then
    Exit;

  for i := 0 to Length(VisibleTargets) - 1 do
    if VisibleTargets[i].ClientID = ClientID then
    begin
      case VisibleTargets[i].TargetType of
        0:
          Result := PBaseNpc(VisibleTargets[i].Player);
        1:
          Result := PBaseNpc(VisibleTargets[i].mob);
      end;
      Break;
    end;
end;

function TBaseNpc.ClearTargetList(): Boolean;
begin
  Result := false;

  SetLength(VisibleTargets, 0);

  VisibleTargetsCnt := 0;
  Result := True;
end;

function TBaseNpc.TargetGarbageService(): Boolean;
var
  OtherList: Array of TMobTarget;
  i, cnt, cnt2: WORD;
begin
  cnt := 0;
  Result := false;

  if (Length(VisibleTargets) = 0) then
  begin
    Result := True;
    Exit;
  end;

  // Pré-calcular o tamanho necessário do array
  SetLength(OtherList, Length(VisibleTargets));

  for i := 0 to Length(VisibleTargets) - 1 do
  begin
    if (VisibleTargets[i].TargetType = 0) then
    begin
      if (VisibleTargets[i].Player <> nil) and (VisibleTargets[i].ClientID > 0)
        and not(PBaseNpc(VisibleTargets[i].Player).IsDead) then
      begin
        OtherList[cnt] := VisibleTargets[i];
        Inc(cnt);
      end;
    end
    else if (VisibleTargets[i].TargetType = 1) then
    begin
      if (VisibleTargets[i].mob <> nil) and (VisibleTargets[i].ClientID > 0) and
        not(PBaseNpc(VisibleTargets[i].mob).IsDead) then
      begin
        OtherList[cnt].ClientID := VisibleTargets[i].ClientID;
        OtherList[cnt].TargetType := VisibleTargets[i].TargetType;

        case VisibleTargets[i].ClientID of
          2001 .. 3339, 3370 .. 3390, 3408 .. 9147:
            OtherList[cnt].Position := Servers[Self.ChannelId].MOBS.TMobS
              [PBaseNpc(VisibleTargets[i].mob).Mobid].MobsP
              [PBaseNpc(VisibleTargets[i].mob).SecondIndex]
              .Base.PlayerCharacter.LastPos;
          3340 .. 3354:
            OtherList[cnt].Position := Servers[Self.ChannelId].DevirStones
              [PBaseNpc(VisibleTargets[i].mob).ClientID].PlayerChar.LastPos;
          3355 .. 3369:
            OtherList[cnt].Position := Servers[Self.ChannelId].DevirGuards
              [PBaseNpc(VisibleTargets[i].mob).ClientID].PlayerChar.LastPos;
          3391 .. 3407:
            OtherList[cnt].Position := Servers[Self.ChannelId].RoyalGuards
              [PBaseNpc(VisibleTargets[i].mob).ClientID].PlayerChar.LastPos;
        else
          OtherList[cnt].Position := VisibleTargets[i].Position;
        end;

        OtherList[cnt].Player := VisibleTargets[i].Player;
        OtherList[cnt].mob := VisibleTargets[i].mob;
        Inc(cnt);
      end;
    end;
  end;

  // Ajustar o tamanho final do array filtrado
  SetLength(OtherList, cnt);

  // Reconstituir VisibleTargets com os valores filtrados
  SetLength(VisibleTargets, cnt);
  for i := 0 to cnt - 1 do
    VisibleTargets[i] := OtherList[i];

  VisibleTargetsCnt := cnt;
  Result := (cnt > 0);
end;

// procedure TBaseNpc.SetDestination(const Destination: TPosition);
// begin
// if (PlayerCharacter.LastPos = Destination) then
// Exit;
// _prediction.Source := PlayerCharacter.LastPos;
// _prediction.Timer.Reset;
// _prediction.Timer.Start;
// _prediction.Destination := Destination;
// _prediction.CalcETA(PlayerCharacter.SpeedMove);
// end;

procedure TBaseNpc.addvisible(m: TBaseNpc);
begin
  Writeln(' adicionando npc ao visible ');
  Self.AddToVisible(m);
end;

procedure TBaseNpc.removevisible(m: TBaseNpc);
begin
  Self.RemoveFromVisible(m);
end;

procedure TBaseNpc.AddHP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Inc(Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex]
      .HP, Value)
  else
    Inc(Self.Character.CurrentScore.CurHP, Value);

  Self.SendCurrentHPMP(ShowUpdate);
end;

procedure TBaseNpc.AddMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  Inc(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;

procedure TBaseNpc.RemoveHP(Value: Integer; ShowUpdate: Boolean;
  StayOneHP: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) then
  begin
    deccardinal(Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP, Value);
    if StayOneHP and (Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP = 0) then
    begin
      Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
        [Self.SecondIndex].HP := 1;
    end;

    ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));
    Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
    Packet.Header.Code := $103; // AIKA
    Packet.Header.Index := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].Index;

    if ShowUpdate then
      Packet.Null := 1;

    Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
    Packet.MaxMP := Packet.MaxHP;
    Packet.CurHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP;
    Packet.CurMP := Packet.MaxMP;

    Self.SendToVisible(Packet, Packet.Header.size, false);
    Exit;
  end;

  deccardinal(Self.Character.CurrentScore.CurHP, Value);

  if (Self.Character.CurrentScore.CurHP <=
    Trunc((Self.Character.CurrentScore.MaxHP / 100) * 50)) then
  begin
    Self.RemoveBuffByIndex(108);
  end;

  if StayOneHP and (Self.Character.CurrentScore.CurHP = 0) then
    Self.Character.CurrentScore.CurHP := 1;

  Self.SendCurrentHPMP(ShowUpdate);

  if (Self.BuffExistsByIndex(134)) and
    (Self.Character.CurrentScore.CurHP <
    (Self.Character.CurrentScore.MaxHP div 2)) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Cura preventiva entrou em ação e feitiço foi desfeito.', 0);
    Self.RemoveBuffByIndex(134);
  end;

  if Self.Character.CurrentScore.CurHP = 0 then
  begin
    Self.SendCurrentHPMP();
    Self.SendEffect($0);
    Exit;
  end;
end;

procedure TBaseNpc.RemoveMP(Value: Integer; ShowUpdate: Boolean);
begin
  if (Self.ClientID >= 3048) then
    Exit;
  deccardinal(Self.Character.CurrentScore.CurMP, Value);
  Self.SendCurrentHPMP(ShowUpdate);
end;

procedure TBaseNpc.WalkinTo(Pos: TPosition);
begin
  Self.WalkTo(Pos, 70);
end;

procedure TBaseNpc.SetEquipEffect(const Equip: TItem; SetType: Integer;
  ChangeConjunt: Boolean = True; VerifyExpired: Boolean = True);
var
  i, ResultOf, EmptySlot: Integer;
begin
  if (ItemList[Equip.Index].ItemType = 10) then
    Exit;

  if (VerifyExpired and (ItemList[Equip.Index].Expires) and not(Equip.IsSealed))
  then
  begin
    ResultOf := CompareDateTime(Now, Equip.ExpireDate);
    // se o item está expirado (roupa pran ou montaria)
    if (ResultOf = 1) or ((Equip.Time = $FFFF) and
      (TItemFunctions.GetItemEquipSlot(Equip.Index) = 9)) then
      Exit;
  end;

  if (Conjuntos[Equip.Index] > 0) and ChangeConjunt then
    SetConjuntEffect(Equip.Index, SetType);

  case SetType of
    EQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            Inc(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            Inc(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);
        end;

        if (ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := SearchEmptyEffect5Slot();
          if EmptySlot <> 255 then
            Self.EFF_5[EmptySlot] := ItemList[Equip.Index].MeshIDEquip;
        end;
      end;
    DESEQUIPING_TYPE:
      begin
        for i := 0 to 2 do
        begin
          if Equip.Effects.Index[i] > 0 then
            dec(Self.MOB_EF[Equip.Effects.Index[i]],
              Equip.Effects.Value[i] * 2);
          if ItemList[Equip.Index].EF[i] > 0 then
            dec(Self.MOB_EF[ItemList[Equip.Index].EF[i]],
              ItemList[Equip.Index].EFV[i]);
        end;

        if (ItemList[Equip.Index].ItemType = 8) then
        begin
          EmptySlot := GetSlotOfEffect5(ItemList[Equip.Index].MeshIDEquip);
          if EmptySlot <> 255 then
            Self.EFF_5[EmptySlot] := 0;
        end;
      end;
    SAME_ITEM_TYPE:
      begin
        // Alterar apenas os atributos de acordo com o refine;
      end;
  end;
end;

procedure TBaseNpc.SetConjuntEffect(Index: Integer; SetType: Integer);
var
  CfgEffect: Integer;
begin
  if Index = 0 then
    Exit;

  Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] :=
    Conjuntos[Index];
  CfgEffect := TItemFunctions.GetConjuntCountNPC(Self, Index);

  if (CfgEffect >= 3) and (CfgEffect <= 6) then
    ConfigEffect(CfgEffect, Conjuntos[Index], SetType);

  if SetType = DESEQUIPING_TYPE then
    Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] := 0;
end;

procedure TBaseNpc.ConfigEffect(Count: Integer; ConjuntId: Integer;
  SetType: Integer);
var
  i: Integer;
  EmptySlot: Byte;
begin
  EmptySlot := 255;
  for i := 0 to 5 do
  begin
    if SetItem[ConjuntId].EffSlot[i] <> Count then
      continue;

    case SetType of
      EQUIPING_TYPE:
        begin
          Inc(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := SearchEmptyEffect5Slot();
            if (EmptySlot <> 255) then
              Self.EFF_5[EmptySlot] := SetItem[ConjuntId].EFV[i];
          end;
        end;
      DESEQUIPING_TYPE:
        begin
          dec(Self.MOB_EF[SetItem[ConjuntId].EF[i]], SetItem[ConjuntId].EFV[i]);
          if (SetItem[ConjuntId].EF[i] = EF_CALLSKILL) then
          begin // se for eff_5
            EmptySlot := GetSlotOfEffect5(SetItem[ConjuntId].EFV[i]);
            if (EmptySlot <> 255) then
              Self.EFF_5[EmptySlot] := 0;
          end;
        end;
    end;
  end;
end;

procedure TBaseNpc.SetOnTitleActiveEffect();
var
  i: Integer;
  ActiveTitleIndex: Integer;
begin
  ActiveTitleIndex := Self.PlayerCharacter.ActiveTitle.Index;
  if ActiveTitleIndex > 0 then
  begin
    var
    TitleLevel := Titles[ActiveTitleIndex].TitleLevel
      [Self.PlayerCharacter.ActiveTitle.Level - 1];
    for i := 0 to 2 do
    begin
      if TitleLevel.EF[i] = 0 then
        continue;

      Self.IncreasseMobAbility(TitleLevel.EF[i], TitleLevel.EFV[i]);
    end;
  end;
end;

procedure TBaseNpc.SetOffTitleActiveEffect();
var
  i: Integer;
  TitleIndex, TitleLevel: Integer;
begin
  TitleIndex := Self.PlayerCharacter.ActiveTitle.Index;
  TitleLevel := Self.PlayerCharacter.ActiveTitle.Level;

  if (TitleIndex > 0) then
  begin
    for i := 0 to 2 do
    begin
      if (Titles[TitleIndex].TitleLevel[TitleLevel - 1].EF[i] = 0) then
        continue;

      Self.DecreasseMobAbility(Titles[TitleIndex].TitleLevel[TitleLevel - 1].EF
        [i], Titles[TitleIndex].TitleLevel[TitleLevel - 1].EFV[i]);
    end;
  end;
end;

function TBaseNpc.MatchClassInfo(ClassInfo: Byte): Boolean;
begin
  Result := (Self.GetMobClass = Self.GetMobClass(ClassInfo));
end;

function TBaseNpc.IsCompleteEffect5(out CountEffects: Byte): Boolean;
var
  i: Byte;
begin
  Result := false;
  CountEffects := 0;

  for i := 0 to 2 do
  begin
    if (EFF_5[i] > 0) then
    begin
      Inc(CountEffects);
      Result := True;
    end;
  end;

  if (Self.GetMobAbility(EF_CALLSKILL) > 0) then
    Result := True;
end;

function TBaseNpc.SearchEmptyEffect5Slot(): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
    if (Self.EFF_5[i] = 0) then
    begin
      Result := i;
      Exit;
    end;
end;

function TBaseNpc.GetSlotOfEffect5(CallID: WORD): Byte;
var
  i: Byte;
begin
  Result := 255;
  for i := 0 to 2 do
    if (Self.EFF_5[i] = CallID) then
    begin
      Result := i;
      Exit;
    end;
end;

procedure TBaseNpc.LureMobsInRange;
var
  i: Integer;
begin
  for i := Low(Self.VisibleTargets) to High(Self.VisibleTargets) do
  begin
    if (Self.VisibleTargets[i].TargetType = 1) then
    begin
      var
      mob := PBaseNpc(Self.VisibleTargets[i].mob);
      with Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
        [mob.SecondIndex] do
      begin
        if (CurrentPos.Distance(Self.PlayerCharacter.LastPos) <= 8) then
        begin
          if (not isGuard and not isMutant) then
          begin
            if (AnsiPos('Max', String(Servers[Self.ChannelId].MOBS.TMobS
              [mob.Mobid].Name)) = 0) then
            begin
              if (not IsAttacked) then
              begin
                IsAttacked := True;
                AttackerID := Self.ClientID;
                FirstPlayerAttacker := Self.ClientID;
                Writeln('Fui lurado');
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

{$ENDREGION}
{$REGION 'Sends'}

procedure TBaseNpc.SendToVisible(var Packet; size: WORD; sendToSelf: Boolean);
var
  i: WORD;
  xPlayer: PPlayer;
begin
    // Processar mobs visíveis
    for i in VisibleMobs do
    begin
      if i <= MAX_CONNECTIONS then
      begin
        xPlayer := @Servers[Self.ChannelId].Players[i];
        if (xPlayer.Status = Playing) then
          xPlayer.SendPacket(Packet, size); // erro no pacote
      end;
    end;
end;

procedure TBaseNpc.SendPacket(var Packet; size: WORD);
begin
  Servers[ChannelId].SendPacketTo(ClientID, Packet, size);
end;

procedure TBaseNpc.SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
  SendSelf: Boolean = True; Polimorf: WORD = 0);
var
  Packet: TSendCreateNpcPacket;
  Packet2: TSpawnMobPacket;
  PacketAct: TSendActionPacket;
  i: Integer;
begin
  ZeroMemory(@Packet, SizeOf(Packet));

  if (Polimorf > 0) then
  begin
    ZeroMemory(@Packet2, SizeOf(Packet2));

    Packet2.Header.size := SizeOf(Packet2);
    Packet2.Header.Code := $35E;
    Packet2.Header.Index := Self.ClientID;

    Packet2.Position := Self.PlayerCharacter.LastPos;
    Packet2.Rotation := Self.PlayerCharacter.Rotation;
    Packet2.CurHP := Self.Character.CurrentScore.CurHP;
    Packet2.CurMP := Self.Character.CurrentScore.CurMP;
    Packet2.MaxHP := Self.Character.CurrentScore.MaxHP;
    Packet2.MaxMP := Self.Character.CurrentScore.MaxMP;

    Packet2.Level := Self.Character.Level;
    Packet2.SpawnType := 0;
    Packet2.Equip[0] := Polimorf;
    Packet2.Equip[1] := Polimorf;
    Packet2.Equip[6] := 0;
    Packet2.Equip[7] := 0;
    Packet2.Altura := 7;
    Packet2.Tronco := 119;
    Packet2.Perna := 119;
    Packet2.Corpo := 0;
    Packet2.IsService := false;
    Packet2.MobType := 1;
    Packet2.Nation := Self.Character.Nation;
    Packet2.MobName := $7535;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet2, Packet2.Header.size)
    else
    begin
      Self.SendPacket(Packet2, Packet2.Header.size);
      for i in Self.VisiblePlayers do
      begin
        if (Servers[Self.ChannelId].Players[i].Base.Character.Nation = Self.
          Character.Nation) then
          Packet2.Nation := 0
        else
          Packet2.Nation := Self.Character.Nation;

        Servers[Self.ChannelId].Players[i].SendPacket(Packet2,
          Packet2.Header.size);
      end;
    end;
  end
  else
  begin
    if (Self.PlayerCharacter.PlayerKill) then
      Inc(SpawnType, $80);

    Self.GetCreateMob(Packet, sendTo);
    Packet.SpawnType := SpawnType;

    if (Self.InClastleVerus) then
      Packet.GuildIndexAndNation := Self.NationForCastle * 4096;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size)
    else
      Self.SendToVisible(Packet, Packet.Header.size, SendSelf);

    if (Self.ClientID <= MAX_CONNECTIONS) then
    begin
      if (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players
        [Self.ClientID], 40, INV_TYPE, 0) <> 255) then
        Self.SendEffect(32);
    end;

    if (Self.CurrentAction <> 0) and (sendTo > 0) then
    begin
      ZeroMemory(@PacketAct, SizeOf(PacketAct));
      PacketAct.Header.size := SizeOf(PacketAct);
      PacketAct.Header.Index := Self.ClientID;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Self.CurrentAction;
      PacketAct.InLoop := 1;

      Servers[Self.ChannelId].SendPacketTo(sendTo, PacketAct,
        PacketAct.Header.size);
    end
    else if (Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction <> 0)
    then
    begin
      ZeroMemory(@PacketAct, SizeOf(PacketAct));
      PacketAct.Header.size := SizeOf(PacketAct);
      PacketAct.Header.Index := sendTo;
      PacketAct.Header.Code := $304;

      PacketAct.Index := Servers[Self.ChannelId].Players[sendTo]
        .Base.CurrentAction;
      if (Servers[Self.ChannelId].Players[sendTo].Base.CurrentAction = 65) then
        PacketAct.InLoop := 1;

      Self.SendPacket(PacketAct, PacketAct.Header.size);
    end;
  end;
end;

procedure TBaseNpc.SendRemoveMob(delType: Integer = DELETE_NORMAL;
  sendTo: WORD = 0; SendSelf: Boolean = True);
var
  Packet: TSendRemoveMobPacket;
  mob: TBaseNpc;
  i: WORD;
begin
  Packet.Header.size := SizeOf(TSendRemoveMobPacket);
  Packet.Header.Code := $101; // aika
  Packet.Header.Index := $7535;
  Packet.Index := Self.ClientID;
  Packet.DeleteType := delType;

  if (SendSelf) and (Self.IsPlayer) then
    Self.SendPacket(Packet, Packet.Header.size);

  if (sendTo = 0) then
  begin
    SendToVisible(Packet, Packet.Header.size, SendSelf);
  end
  else
  begin
    Servers[ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size);
    Exit;
  end;

  for i in VisiblePlayers do
  begin
    if GetMob(i, ChannelId, mob) then
      RemoveFromVisible(mob);
  end;

  VisiblePlayers.Clear;
  Writeln('apagando mob 3');
end;

procedure TBaseNpc.SendRefreshLevel;
var
  Packet: TSendCurrentLevel;
begin
  if (Self.ClientID >= 3048) then
    Exit;

  Packet.Header.size := SizeOf(TSendCurrentLevel);
  Packet.Header.Code := $108; // AIKA
  Packet.Header.Index := ClientID;
  Packet.Level := Character.Level - 1;
  Packet.Unk := $CC;
  Packet.Exp := Character.Exp;

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseNpc.SendCurrentHPMP(Update: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin

  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  // Obtem os valores e ajusta os atuais diretamente
  Character.CurrentScore.MaxHP := Self.GetCurrentHP;
  Character.CurrentScore.MaxMP := Self.GetCurrentMP;

  if Character.CurrentScore.CurHP > Character.CurrentScore.MaxHP then
    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;

  if Character.CurrentScore.CurMP > Character.CurrentScore.MaxMP then
    Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;

  // Prepara o pacote em uma única etapa
  ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));
  Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;
  Packet.CurHP := Character.CurrentScore.CurHP;
  Packet.MaxHP := Character.CurrentScore.MaxHP;
  Packet.CurMP := Character.CurrentScore.CurMP;
  Packet.MaxMP := Character.CurrentScore.MaxMP;
  Packet.Null := Ord(Update); // Evita if/else com atribuição direta
  // Envia o pacote
  SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseNpc.SendCurrentHPMPMob();
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.IsDungeonMob) then
    Exit;

  if (Self.Mobid = 0) then
    Exit;

  ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));

  Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103; // AIKA
  Packet.Header.Index := ClientID;

  // Referência para evitar múltiplos acessos ao mesmo objeto
  var
  MobData := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
    [Self.SecondIndex];

  // Atualiza HP e MP diretamente com os dados obtidos
  Packet.CurHP := MobData.HP;
  Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
  Packet.CurMP := MobData.HP;
  // Note que o código usa HP no lugar de MP, possivelmente um erro original
  Packet.MaxMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;

  SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseNpc.SendStatus;
var
  Packet: TSendRefreshStatus;
  temp_buff: Array [0 .. 12] of Byte;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  ZeroMemory(@Packet, $2C);
  Packet.Header.size := $2C;
  Packet.Header.Code := $10A; // AIKA
  Packet.Header.Index := $7535;

  // Atualizando os valores diretamente de PlayerCharacter.Base.CurrentScore para Packet
  with PlayerCharacter.Base.CurrentScore do
  begin
    Packet.DNFis := DNFis;
    Packet.DEFFis := DEFFis;
    Packet.DNMAG := DNMAG;
    Packet.DEFMAG := DEFMAG;
    Packet.Critico := Critical;
    Packet.Esquiva := Esquiva;
    Packet.Acerto := Acerto;
  end;

  Packet.SpeedMove := PlayerCharacter.SpeedMove;
  Packet.Duplo := PlayerCharacter.DuploAtk;
  Packet.Resist := PlayerCharacter.Resistence;

  SendPacket(Packet, Packet.Header.size);

  ZeroMemory(@temp_buff, 12);
  TPacketHandlers.RequestAllAttributes(Servers[Self.ChannelId].Players
    [Self.ClientID], temp_buff);
end;

procedure TBaseNpc.SendRefreshPoint;
var
  Packet: TSendRefreshPoint;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  ZeroMemory(@Packet, SizeOf(TSendRefreshPoint));

  // Preenchendo o cabeçalho
  with Packet.Header do
  begin
    size := SizeOf(TSendRefreshPoint);
    Code := $109; // AIKA
    Index := $7535;
  end;

  // Movendo os dados de pontos
  Move(PlayerCharacter.Base.CurrentScore, Packet.Pontos, SizeOf(Packet.Pontos));

  // Atribuindo valores diretamente
  Packet.SkillsPoint := Self.Character.CurrentScore.SkillPoint;
  Packet.StatusPoint := Self.Character.CurrentScore.Status;

  // Enviando o pacote
  SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseNpc.SendRefreshKills;
var
  Packet: TUpdateHonorAndKills;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $12A;
  Packet.Honor := Self.Character.CurrentScore.Honor;
  Packet.Kills := Self.Character.CurrentScore.KillPoint;
  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseNpc.SendEquipItems(SendSelf: Boolean = True);
begin
end;

procedure TBaseNpc.SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
  Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
  Packet3: TRefreshItemPranPacket;
  EquipSlotIndex: WORD;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(TRefreshItemPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $F0E;
  Packet.Notice := Notice;
  Packet.TypeSlot := SlotType;
  Packet.Slot := SlotItem;
  Packet.Item := Item;

  case SlotType of
    INV_TYPE, EQUIP_TYPE, STORAGE_TYPE:
      begin
        // Determina o índice de equipamento com base no tipo de Slot
        if SlotType = INV_TYPE then
          EquipSlotIndex := Self.Character.Inventory[SlotItem].Index
        else if SlotType = EQUIP_TYPE then
          EquipSlotIndex := Self.Character.Equip[SlotItem].Index
        else // STORAGE_TYPE
          EquipSlotIndex := Servers[Self.ChannelId].Players[Self.ClientID]
            .Account.Header.Storage.Itens[SlotItem].Index;

        case TItemFunctions.GetItemEquipSlot(EquipSlotIndex) of
          9: // mount item
            begin
              ZeroMemory(@Packet2, SizeOf(Packet2));
              Packet2.Header.size := SizeOf(Packet2);
              Packet2.Header.Index := $7535;
              Packet2.Header.Code := $F0E;
              Packet2.Notice := Notice;
              Packet2.TypeSlot := SlotType;
              Packet2.Slot := SlotItem;
              Packet2.Item.Index := Item.Index;
              Packet2.Item.APP := Item.APP;
              Packet2.Item.Slot1 := Item.Effects.Index[0];
              Packet2.Item.Slot2 := Item.Effects.Index[1];
              Packet2.Item.Slot3 := Item.Effects.Index[2];
              Packet2.Item.Enc1 := Item.Effects.Value[0];
              Packet2.Item.Enc2 := Item.Effects.Value[1];
              Packet2.Item.Enc3 := Item.Effects.Value[2];
              Packet2.Item.MIN := Item.MIN;
              Packet2.Item.Time := Item.Time;
              Self.SendPacket(Packet2, Packet2.Header.size);
            end;
          10: // pran item
            begin
              ZeroMemory(@Packet3, SizeOf(Packet3));
              Packet3.Header.size := SizeOf(TRefreshItemPranPacket);
              Packet3.Header.Index := $7535;
              Packet3.Header.Code := $F0E;
              Packet3.Notice := Notice;
              Packet3.TypeSlot := SlotType;
              Packet3.Slot := SlotItem;
              Packet3.Item.Index := Item.Index;
              Packet3.Item.APP := Item.APP;
              Packet3.Item.Identific := Item.Identific;

              if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran1.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran1.Level;
              end
              else if (Item.Identific = Servers[Self.ChannelId].Players
                [Self.ClientID].Account.Header.Pran2.ItemID) then
              begin
                Packet3.Item.CreationTime := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.CreatedAt;
                Packet3.Item.Devotion := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Devotion;
                Packet3.Item.State := 00;
                Packet3.Item.Level := Servers[Self.ChannelId].Players
                  [Self.ClientID].Account.Header.Pran2.Level;
                Packet3.Item.NotUse[0] := 1;
              end;

              Self.SendPacket(Packet3, Packet3.Header.size);
            end;
        else
          begin
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
  else
    begin
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

procedure TBaseNpc.SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
begin
  // Verificando o tipo de item (montaria ou outro item)
  if TItemFunctions.GetItemEquipSlot(Self.Character.Inventory[SlotItem].
    Index) <> 9 then
  begin
    ZeroMemory(@Packet, SizeOf(Packet));
    Packet.Header.size := SizeOf(TRefreshItemPacket);
    Packet.Header.Index := $7535;
    Packet.Header.Code := $F0E;
    Packet.Notice := Notice;
    Packet.TypeSlot := $1;
    Packet.Slot := SlotItem;
    Packet.Item := Self.Character.Inventory[SlotItem];
    Self.SendPacket(Packet, Packet.Header.size);
  end
  else
  begin
    ZeroMemory(@Packet2, SizeOf(Packet2));
    Packet2.Header.size := SizeOf(Packet2);
    Packet2.Header.Index := $7535;
    Packet2.Header.Code := $F0E;
    Packet2.Notice := Notice;
    Packet2.TypeSlot := $1;
    Packet2.Slot := SlotItem;

    // Preenchendo os dados do item de montaria
    with Self.Character.Inventory[SlotItem] do
    begin
      Packet2.Item.Index := Index;
      Packet2.Item.APP := APP;
      Packet2.Item.Slot1 := Effects.Index[0];
      Packet2.Item.Slot2 := Effects.Index[1];
      Packet2.Item.Slot3 := Effects.Index[2];
      Packet2.Item.Enc1 := Effects.Value[0];
      Packet2.Item.Enc2 := Effects.Value[1];
      Packet2.Item.Enc3 := Effects.Value[2];
      Packet2.Item.Time := Time;
    end;

    Self.SendPacket(Packet2, Packet2.Header.size);
  end;
end;

procedure TBaseNpc.SendSpawnMobs;
var
  i: Integer;
begin
  for i in Self.VisibleMobs do
  begin
    if (i = 0) OR (i = Self.ClientID) then
    begin
      Exit;
    end;
    if (i <= MAX_CONNECTIONS) then
    begin
      // Servers[ChannelId].Players[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end
    else
    begin
      // NPCs[i].Base.SendCreateMob(SPAWN_NORMAL, Self.ClientId);
    end;
  end;
end;

procedure TBaseNpc.GenerateBabyMob;
// var pos: TPosition; i, j: BYTE; mIndex, id: WORD;
// party : PParty;
// var
// babyId, babyClientId: WORD;
// party : PParty;
// i, j: Byte;
// pos: TPosition;
begin
end;

procedure TBaseNpc.UngenerateBabyMob(ungenEffect: WORD);
// evok pode ser usado pra skill de att
// var pos: TPosition; i,j: BYTE; party : PParty; find: boolean;
begin
end;
{$ENDREGION}
{$REGION 'Gets'}

procedure TBaseNpc.GetCreateMob(out Packet: TSendCreateNpcPacket; P1: WORD);
type
  A = record
    hi, lo: Byte;
  end;
var
  i, j, k: Integer;
  Index: WORD;
  Count, Count2: Integer;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := ClientID;
  Packet.Header.Code := $349;
  Packet.Rotation := PlayerCharacter.Rotation;
  Move(Character^.Name, Packet.Name[0], 16);
  Packet.Equip[0] := Character^.Equip[0].Index;
  Packet.Equip[1] := Character^.Equip[1].Index;

  for i := 2 to 7 do
  begin
    if (Character^.Equip[i].APP = 0) or not(Self.IsPlayer) then
      Packet.Equip[i] := Character^.Equip[i].Index
    else
      Packet.Equip[i] := Character^.Equip[i].APP;
  end;

  Packet.SpeedMove := Self.PlayerCharacter.SpeedMove;
  Packet.MaxHP := Character^.CurrentScore.MaxHP;
  Packet.MaxMP := Character^.CurrentScore.MaxHP;

  Packet.EffectType := $1;
  Packet.IsService := 1;
  Packet.Unk0 := $28;
  if (Self.ClientID <= 3047) then
    AnsiStrings.StrPCopy(Packet.Title,
      AnsiString(Servers[ChannelId].NPCs[Self.ClientID].NPCFile.Header.Title));


  // Packet.ItemEffPedra:= Character^.Equip[8].index; //efeito da pedra    00 01
  // Packet.ItemEffMontaria:= Character^.Equip[9].index; //efeito da montaria  02 03

  Packet.Position := PlayerCharacter.LastPos;
  Packet.CurHP := Character^.CurrentScore.CurHP;
  Packet.CurMP := Character^.CurrentScore.CurMP;

  if Packet.CurHP > Packet.MaxHP then
    Packet.CurHP := Packet.MaxHP;

  if Packet.CurMP > Packet.MaxMP then
    Packet.CurMP := Packet.MaxMP;

  Packet.Altura := Character^.CurrentScore.Sizes.Altura;
  Packet.Tronco := Character^.CurrentScore.Sizes.Tronco;
  Packet.Perna := Character^.CurrentScore.Sizes.Perna;
  Packet.Corpo := Character^.CurrentScore.Sizes.Corpo;
  Packet.TitleId := Self.PlayerCharacter.ActiveTitle.Index;
  Packet.TitleLevel := Self.PlayerCharacter.ActiveTitle.Level - 1;

  if (PersonalShop.Index > 0) and (PersonalShop.Name <> '') then
  begin
    AnsiStrings.StrCopy(Packet.Title, Self.PersonalShop.Name);
    Packet.Corpo := 3;
    Packet.EffectType := 2;
  end;

  // Processar buffs
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      SkillData[Index].Duration));
    Inc(i);
  end;

  if ((Self.ClientID >= 2048) and (Self.ClientID <= 3047)) then
  begin
    Packet.EffectType := 0;
    for i := Low(Self.NpcQuests) to High(Self.NpcQuests) do
    begin
      if (Self.NpcQuests[i].QuestID = 0) then
        continue;

      if (Self.NpcQuests[i].LevelMin > Servers[Self.ChannelId].Players[P1]
        .Base.Character.Level) then
      begin
        if (Packet.EffectType = 0) then
          Packet.EffectType := 07;
        continue;
      end;

      Count := 0;
      Count2 := 0;
      for k := Low(Servers[Self.ChannelId].Players[P1].PlayerQuests)
        to High(Servers[Self.ChannelId].Players[P1].PlayerQuests) do
      begin
        if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
          .Quest.QuestID = Self.NpcQuests[i].QuestID) then
        begin
          for j := 0 to 4 do
          begin
            if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
              .Quest.RequirimentsAmount[j] = 0) then
              continue
            else
              Inc(Count2);

            if (Servers[Self.ChannelId].Players[P1].PlayerQuests[k].Complete[j]
              >= Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
              .Quest.RequirimentsAmount[j]) then
            begin
              if not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k]
                .Complete[j] = 0) then
                Inc(Count);
            end;
          end;

          if not(Servers[Self.ChannelId].Players[P1].PlayerQuests[k].IsDone)
          then
          begin
            Packet.EffectType := IfThen(Count = Count2, 4, 3);
          end
          else
            Packet.EffectType := Self.NpcQuests[i].QuestMark;

          Break;
        end;
      end;

      if (Packet.EffectType in [3, 4]) then
        Break;
    end;
  end;
end;

class function TBaseNpc.GetMob(Index: WORD; Channel: Byte;
  out mob: TBaseNpc): Boolean;
begin
  Result := false;
  if (Index = 0) or (Index > MAX_SPAWN_ID) then
    Exit;

  if (Index >= 2048) and (Index <= 3047) then
    mob := Servers[Channel].NPCs[Index].Base;

  if (mob.Character = nil) or not mob.IsActive then
    Exit;

  Result := True;
end;

class function TBaseNpc.GetMob(Index: WORD; Channel: Byte;
  out mob: PBaseNpc): Boolean;
begin
  if (index = 0) then
    Exit(false);

  if (index <= MAX_CONNECTIONS) then
    mob := @Servers[Channel].Players[index].Base
  else
    mob := @Servers[Channel].NPCs[index].Base;

  Result := mob.IsActive;
end;

function TBaseNpc.GetMobAbility(eff: Integer): Integer;
begin
  Result := Self.MOB_EF[eff];
end;

procedure TBaseNpc.IncreasseMobAbility(eff: Integer; Value: Integer);
begin
  Inc(Self.MOB_EF[eff], Value);
end;

procedure TBaseNpc.DecreasseMobAbility(eff: Integer; Value: Integer);
begin
  if Value < 0 then
    Inc(Self.MOB_EF[eff], -Value)
  else
    decInt(Self.MOB_EF[eff], Value);
end;

function TBaseNpc.GetCurrentHP(): DWORD;
var
  hp_inc, hp_perc: DWORD; // ainda no esquema do WYD
begin
  hp_inc := GetMobAbility(EF_HP);
  Inc(hp_inc, (Round(HPIncrementPerLevel[GetMobClass(Character.ClassInfo)] *
    1.5) * Character.Level));
  Inc(hp_inc, (PlayerCharacter.Base.CurrentScore.CONS * 27));
  Inc(hp_inc, Self.GetEquipedItensHPMPInc);

  hp_perc := GetMobAbility(EF_MARSHAL_PER_HP);
  Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));

  if (Self.Character <> nil) and
    (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    hp_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
    Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));
  end;

  hp_perc := GetMobAbility(EF_PER_HP);
  Inc(hp_inc, (hp_perc * Round(hp_inc div 100)));

  if (hp_inc <= 0) then
    hp_inc := 1;

  Result := hp_inc;
end;

function TBaseNpc.GetCurrentMP(): DWORD;
var
  mp_inc, mp_perc: DWORD;
begin
  mp_inc := GetMobAbility(EF_MP);
  Inc(mp_inc, (Round(MPIncrementPerLevel[GetMobClass(Character.ClassInfo)] *
    0.5) * Character.Level));
  Inc(mp_inc, (PlayerCharacter.Base.CurrentScore.luck * 27));
  Inc(mp_inc, Self.GetEquipedItensHPMPInc);

  mp_perc := GetMobAbility(EF_MARSHAL_PER_MP);
  Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));

  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    mp_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
    Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));
  end;

  mp_perc := GetMobAbility(EF_PER_MP);
  Inc(mp_inc, (mp_perc * Round(mp_inc div 100)));

  if (mp_inc <= 0) then
    mp_inc := 1;

  Result := mp_inc;
end;

function TBaseNpc.GetRegenerationHP(): DWORD;
var
  hp_inc: Integer;
  hp_perc: Single;
  CurHP: DWORD;
const
  REC_BASE: Single = 0.05; // antes de 30/04/2021 era 0.05
begin
  hp_inc := Self.GetMobAbility(EF_PRAN_REGENHP) +
    (PlayerCharacter.Base.CurrentScore.CONS * 2);
  if (hp_inc < 0) then
    hp_inc := 0;

  hp_perc := REC_BASE + ((hp_inc div 100) div 10);
  CurHP := Self.GetCurrentHP;

  hp_inc := hp_inc + Self.GetMobAbility(EF_REGENHP);
  Result := Trunc(CurHP * hp_perc);
  if (Result > Trunc(CurHP * 0.15)) then
    Result := Trunc(CurHP * 0.15);
end;

function TBaseNpc.GetRegenerationMP(): DWORD;
var
  mp_inc: Integer;
  mp_perc: Single;
  CurMP: DWORD;
const
  REC_BASE: Single = 0.03;
begin
  mp_inc := Self.GetMobAbility(EF_PRAN_REGENMP) +
    (PlayerCharacter.Base.CurrentScore.luck * 2);
  if (mp_inc < 0) then
    mp_inc := 0;

  mp_perc := REC_BASE + ((mp_inc div 100) div 10);
  CurMP := Self.GetCurrentMP;

  mp_inc := mp_inc + Self.GetMobAbility(EF_REGENMP);
  Result := Trunc(CurMP * mp_perc);

  if (Result > Trunc(CurMP * 0.15)) then
    Result := Trunc(CurMP * 0.15);
end;

function TBaseNpc.GetEquipedItensHPMPInc: DWORD;
var
  i, Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) or (Self.Character.Equip[i].Time > 0) then
      continue;

    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine > 0) then
      Inc(Result, TItemFunctions.GetItemReinforceHPMPInc(Self.Character.Equip[i]
        .Index, Refine - 1));
  end;
end;

function TBaseNpc.GetEquipedItensDamageReduce: DWORD;
var
  i, Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) or (Self.Character.Equip[i].Time > 0) then
      continue;

    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine > 0) then
      Inc(Result, TItemFunctions.GetItemReinforceDamageReduction
        (Self.Character.Equip[i].Index, Refine - 1));
  end;
end;

function TBaseNpc.GetMobClass(ClassInfo: Integer = 0): Integer;
begin
  Result := 0;
  if (Self.ClientID > MAX_CONNECTIONS) then
  begin
    Exit;
  end;
  if (ClassInfo = 0) then
    ClassInfo := Self.Character.ClassInfo;

  // Identificar a classe com base no intervalo de valores
  case ClassInfo div 10 of
    0 .. 0:
      Result := 0; // war
    1 .. 1:
      Result := 1; // templar
    2 .. 2:
      Result := 2; // att
    3 .. 3:
      Result := 3; // dual
    4 .. 4:
      Result := 4; // mago
    5 .. 5:
      Result := 5; // cleriga
  end;
end;

procedure TBaseNpc.GetEquipDamage(const Equip: TItem);
var
  FisAtk: WORD;
  MagAtk: WORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisAtk := 0;
  MagAtk := 0;

  if Equip.Index = 0 then
    Exit;

  if Equip.MIN = 0 then
    Exit;

  if Equip.Refi < 16 then
  begin
    FisAtk := ItemList[Equip.Index].ATKFis;
    MagAtk := ItemList[Equip.Index].MagAtk;
  end
  else
  begin
    if Equip.Time <= 0 then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;
      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);
      Inc(FisAtk, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagAtk, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisAtk := ItemList[Equip.Index].ATKFis;
      MagAtk := ItemList[Equip.Index].MagAtk;
    end;
  end;

  PlayerCharacter.Base.CurrentScore.DNMAG := MagAtk;
  PlayerCharacter.Base.CurrentScore.DNFis := FisAtk;
end;

procedure TBaseNpc.GetEquipDefense(const Equip: TItem);
var
  FisDef: DWORD;
  MagDef: DWORD;
  RefineIndex: WORD;
  Reinforce: Byte;
begin
  FisDef := 0;
  MagDef := 0;

  if Equip.Index = 0 then
    Exit;

  if Equip.Refi < 16 then
  begin
    FisDef := ItemList[Equip.Index].DEFFis;
    MagDef := ItemList[Equip.Index].DEFMAG;
  end
  else
  begin
    if Equip.Time <= 0 then
    begin
      Reinforce := Round(Equip.Refi div 16) - 1;
      RefineIndex := TItemFunctions.GetItemReinforce2Index(Equip.Index);
      Inc(FisDef, Reinforce2[RefineIndex].AttributeFis[Reinforce]);
      Inc(MagDef, Reinforce2[RefineIndex].AttributeMag[Reinforce]);
    end
    else
    begin
      FisDef := ItemList[Equip.Index].DEFFis;
      MagDef := ItemList[Equip.Index].DEFMAG;
    end;
  end;

  Inc(PlayerCharacter.Base.CurrentScore.DEFMAG, MagDef);
  Inc(PlayerCharacter.Base.CurrentScore.DEFFis, FisDef);
end;

procedure TBaseNpc.GetEquipsDefense;
var
  i: Integer;
begin
  Self.PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  Self.PlayerCharacter.Base.CurrentScore.DEFFis := 0;

  for i := 2 to 7 do
  begin
    if (i = 6) then
      continue;

    if Self.Character.Equip[i].MIN = 0 then
      continue;

    Self.GetEquipDefense(Self.Character.Equip[i]);
  end;
end;

procedure TBaseNpc.GetCurrentScore;
var
  Damage_perc: WORD;
  Def_perc: WORD;
begin
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;
  ZeroMemory(@PlayerCharacter.Base.CurrentScore, 10);
  PlayerCharacter.Base.CurrentScore.DNFis := 0;
  PlayerCharacter.Base.CurrentScore.DNMAG := 0;
  PlayerCharacter.Base.CurrentScore.DEFFis := 0;
  PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  PlayerCharacter.Base.CurrentScore.BonusDMG := 0;
  PlayerCharacter.Base.CurrentScore.Critical := 0;
  PlayerCharacter.Base.CurrentScore.Esquiva := 0;
  PlayerCharacter.Base.CurrentScore.Acerto := 0;
  PlayerCharacter.DuploAtk := 0;
  PlayerCharacter.SpeedMove := 0;
  PlayerCharacter.Resistence := 0;
  PlayerCharacter.HabAtk := 0;
  PlayerCharacter.DamageCritical := 0;
  PlayerCharacter.ResDamageCritical := 0;
  PlayerCharacter.MagPenetration := 0;
  PlayerCharacter.FisPenetration := 0;
  PlayerCharacter.CureTax := 0;
  PlayerCharacter.CritRes := 0;
  PlayerCharacter.DuploRes := 0;
  PlayerCharacter.ReduceCooldown := 0;
  PlayerCharacter.PvPDamage := 0;
  PlayerCharacter.PvPDefense := 0;
{$REGION 'Get Status Points'}
  IncCritical(PlayerCharacter.Base.CurrentScore.Str, Character.CurrentScore.Str
    + Self.GetMobAbility(EF_STR));
  IncCritical(PlayerCharacter.Base.CurrentScore.agility,
    Character.CurrentScore.agility + Self.GetMobAbility(EF_DEX));
  IncCritical(PlayerCharacter.Base.CurrentScore.Int, Character.CurrentScore.Int
    + Self.GetMobAbility(EF_INT));
  IncCritical(PlayerCharacter.Base.CurrentScore.CONS,
    Character.CurrentScore.CONS + Self.GetMobAbility(EF_CON));
  IncCritical(PlayerCharacter.Base.CurrentScore.luck,
    Character.CurrentScore.luck + Self.GetMobAbility(EF_SPI));
{$ENDREGION}
{$REGION 'Get Others Status'}
{$REGION 'SpeedMove'}
  IncSpeedMove(PlayerCharacter.SpeedMove,
    (40 + Self.GetMobAbility(EF_RUNSPEED)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    IncSpeedMove(PlayerCharacter.SpeedMove, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_RUNSPEED]);
  end;
{$ENDREGION}
{$REGION 'Duplo Atk'}
  IncCritical(PlayerCharacter.DuploAtk,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.21));
  // IncCritical(PlayerCharacter.DuploAtk,
  // Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.25));
  IncCritical(PlayerCharacter.DuploAtk, Servers[Self.ChannelId].ReliqEffect
    [EF_RELIQUE_DOUBLE]);
  IncCritical(PlayerCharacter.DuploAtk, Self.GetMobAbility(EF_DOUBLE));
{$ENDREGION}
{$REGION 'Critical'}
  IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.13));
  // IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
  // Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_CRITICAL]);
  IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Self.GetMobAbility(EF_CRITICAL));
{$ENDREGION}
{$REGION 'Damage Critical'}
  IncCritical(PlayerCharacter.DamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2));
  // IncCritical(PlayerCharacter.DamageCritical,
  // Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.2));
  IncCritical(PlayerCharacter.DamageCritical,
    Self.GetMobAbility(EF_CRITICAL_POWER));
{$ENDREGION}
{$REGION 'Penetration Fis and Mag'}
  IncCooldown(PlayerCharacter.FisPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.04));
  IncCooldown(PlayerCharacter.MagPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.34));
  IncCooldown(PlayerCharacter.FisPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE1));
  IncCooldown(PlayerCharacter.MagPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE2));
{$ENDREGION}
{$REGION 'PvP Damage'}
  IncWORD(PlayerCharacter.PvPDamage, Self.GetMobAbility(EF_ATK_NATION2));
{$ENDREGION}
{$REGION 'PvP Defense'}
  IncWORD(PlayerCharacter.PvPDefense, Self.GetMobAbility(EF_DEF_NATION2));
{$ENDREGION}
{$REGION 'Hab Skill Atk'}
  IncWORD(PlayerCharacter.HabAtk, (PlayerCharacter.Base.CurrentScore.luck * 6));
  // IncWORD(PlayerCharacter.HabAtk, (PlayerCharacter.Base.CurrentScore.Cons * 2));
  IncWORD(PlayerCharacter.HabAtk, Self.GetMobAbility(EF_SKILL_DAMAGE));
{$ENDREGION}
{$REGION 'Cure Tax'}
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.3));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.1));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.1));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.1));
  // IncCritical(PlayerCharacter.CureTax,
  // Self.GetMobAbility(EF_SKILL_DAMAGE6));
{$ENDREGION}
{$REGION 'Res Crit'}
  IncCritical(PlayerCharacter.CritRes,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.15));
  // 10 cons = 3 rescrit
  IncCritical(PlayerCharacter.CritRes,
    Trunc(PlayerCharacter.Base.CurrentScore.luck * 0.2)); // 10 luck = 2 rescrit
  IncCritical(PlayerCharacter.CritRes, Self.GetMobAbility(EF_RESISTANCE6));
{$ENDREGION}
{$REGION 'Res Damage Crit'}
  IncCritical(PlayerCharacter.ResDamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.2));
  // 10 cons = 2 res damaag crit
  IncCritical(PlayerCharacter.ResDamageCritical,
    Self.GetMobAbility(EF_CRITICAL_DEFENCE));
{$ENDREGION}
{$REGION 'Res Duplo'}
  IncCritical(PlayerCharacter.DuploRes,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.34));
  // 10 cons = 2 res duplo
  IncCritical(PlayerCharacter.DuploRes, Self.GetMobAbility(EF_RESISTANCE7));
{$ENDREGION}
{$REGION 'Acerto'}
  IncWORD(PlayerCharacter.Base.CurrentScore.Acerto,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.5));
  // IncByte(PlayerCharacter.Base.CurrentScore.Acerto,
  // Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.4));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncWORD(PlayerCharacter.Base.CurrentScore.Acerto,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_HIT]);
  IncWORD(PlayerCharacter.Base.CurrentScore.Acerto, Self.GetMobAbility(EF_HIT));
{$ENDREGION}
{$REGION 'Esquiva'}
  IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.021));
  // IncByte(PlayerCharacter.Base.CurrentScore.Esquiva,
  // Trunc(PlayerCharacter.Base.CurrentScore.luck * 0.3));
  IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PRAN_PARRY));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PARRY]);
  IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PARRY));
{$ENDREGION}
{$REGION 'Resistence'}
  IncCritical(PlayerCharacter.Resistence,
    // resistencia a status anormais, colocar no valid atk
    Round(PlayerCharacter.Base.CurrentScore.luck * 0.1));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Resistence, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_STATE_RESISTANCE]);
  IncCritical(PlayerCharacter.Resistence,
    Self.GetMobAbility(EF_STATE_RESISTANCE));
{$ENDREGION}
{$REGION 'Cooldown Time'}
  IncCooldown(PlayerCharacter.ReduceCooldown,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.25));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCooldown(PlayerCharacter.ReduceCooldown,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_COOLTIME]);
  IncCooldown(PlayerCharacter.ReduceCooldown, Self.GetMobAbility(EF_COOLTIME));
{$ENDREGION}
{$ENDREGION}
{$REGION 'Get Def'}
  Self.GetEquipsDefense;

  // IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
  // Trunc(PlayerCharacter.Base.CurrentScore.Str * 1.3));
  // IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
  // Trunc(PlayerCharacter.Base.CurrentScore.Luck * 1.6));
  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE1);
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFFis,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFFis div 100)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE1];
  // IncWord(PlayerCharacter.Base.CurrentScore.DEFFis,
  // Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFFis div 100)));

  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE2);
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFMAG div 100)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE2];
  // IncWord(PlayerCharacter.Base.CurrentScore.DEFMAG,
  // Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFMAG div 100)));

  IncWORD(PlayerCharacter.Base.CurrentScore.DEFFis,
    Self.GetMobAbility(EF_RESISTANCE1));
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Self.GetMobAbility(EF_RESISTANCE2));
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFFis,
    Self.GetMobAbility(EF_PRAN_RESISTANCE1));
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Self.GetMobAbility(EF_PRAN_RESISTANCE2));
  if (Self.GetMobAbility(EF_UNARMOR) > 0) then
  begin
    PlayerCharacter.Base.CurrentScore.DEFFis := 0;
    PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  end;
{$ENDREGION}
{$REGION 'Get Atk'}
  Self.GetEquipDamage(Self.Character.Equip[6]);
{$REGION 'Atk Fis'}
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 2.6));
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 2.6));

  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Self.GetMobAbility(EF_PRAN_DAMAGE1));

  Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE1);
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc));
  { Reliquia }
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE1];
    IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
      Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc));
  end;

  decword(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) *
    Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1)));

  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Self.GetMobAbility(EF_DAMAGE1));
{$ENDREGION}
{$REGION 'Atk Mag'}
  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 3.2));

  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Self.GetMobAbility(EF_PRAN_DAMAGE2));

  Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE2);
  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc));
  { Reliquia }
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    Damage_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_DAMAGE2];
    IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
      Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc));
  end;

  decword(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) *
    Self.GetMobAbility(EF_DECREASE_PER_DAMAGE2)));

  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Self.GetMobAbility(EF_DAMAGE2));

{$ENDREGION}
{$ENDREGION}
end;

{$ENDREGION}
{$REGION 'Buffs'}

procedure TBaseNpc.SendRefreshBuffs();
var
  Packet: TSendBuffsPacket;
  i: Integer;
  Index: WORD;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $16E;
  Packet.Header.Index := Self.ClientID;
  Self.RefreshBuffs;
  i := 0;
  for Index in Self._buffs.Keys do
  begin
    Packet.Buffs[i] := Index;
    Packet.Time[i] := DateTimeToUnix(IncSecond(Self._buffs[Index],
      SkillData[Index].Duration));
    Inc(i);
  end;
  Self.SendToVisible(Packet, Packet.Header.size, (Self.ClientID < 3048) and
    not Self.IsDungeonMob);
end;

procedure TBaseNpc.SendAddBuff(BuffIndex: WORD);
var
  Packet: TUpdateBuffPacket;
  EndTime: TDateTime;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $16F;
  Packet.Buff := BuffIndex;
  EndTime := IncSecond(Self._buffs[BuffIndex], SkillData[BuffIndex].Duration);
  Packet.EndTime := DateTimeToUnix(EndTime);

  Self.SendPacket(Packet, Packet.Header.size);
  Self.SendRefreshBuffs;
  Self.SendRefreshPoint;
  Self.SendStatus;
end;

function TBaseNpc.RefreshBuffs: Integer;
var
  Index: WORD;
  EndTime: TDateTime;
  i: Integer;
begin
  Result := 0;
  for Index in Self._buffs.Keys do
  begin
    EndTime := IncSecond(Self._buffs[Index], SkillData[Index].Duration);
    if (EndTime < Now) then
    begin
      if (Self.RemoveBuff(Index)) then
      begin
        Inc(Result);
      end;
    end;
  end;
  if (Result > 0) then
  begin
    Self.SendCurrentHPMP(True);
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;

  if (Self.ClientID <= MAX_CONNECTIONS) then
  begin
    for i := Low(Self.PlayerCharacter.Buffs)
      to High(Self.PlayerCharacter.Buffs) do
    begin
      EndTime := IncSecond(Self.PlayerCharacter.Buffs[i].CreationTime,
        SkillData[Self.PlayerCharacter.Buffs[i].Index].Duration);
      if (EndTime <= Now) then
      begin
        ZeroMemory(@Self.PlayerCharacter.Buffs[i],
          SizeOf(Self.PlayerCharacter.Buffs[i]));
      end;
    end;
  end;
end;

function TBaseNpc.AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
  AddTime: Boolean = false; TimeAditional: Integer = 0): Boolean;
var
  BuffSlot: Integer;
begin
  Result := false;
  if (Self._buffs.Count >= 60) then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Não foi possível adicionar novos buffs. Limite: 60 Buffs.');
    Exit;
  end;

  if (BuffIndex = 7257) or (BuffIndex = 9133) then
    Exit;

  if (Self.BuffExistsByIndex(SkillData[BuffIndex].Index)) then
  begin
    Self.RemoveBuffByIndex(SkillData[BuffIndex].Index);
  end;

  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Result := True;
    if (Self.Character <> nil) then
    begin
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;
    end;
    if (TimeAditional > 0) then
      Self._buffs[BuffIndex] := IncSecond(Now, TimeAditional)
    else
      Self._buffs[BuffIndex] := Now;
    Self.SendRefreshBuffs;
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end
  else
  begin
    Result := True;
    if (Self.Character <> nil) then
    begin
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;
    end;
    Self._buffs.Add(BuffIndex, IncSecond(Now, TimeAditional));
    BuffSlot := Self.GetEmptyBuffSlot;
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := BuffIndex;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end;

  if (Refresh) then
    Self.SendAddBuff(BuffIndex);
end;

function TBaseNpc.AddBuffWhenEntering(BuffIndex: Integer;
  BuffTime: TDateTime): Boolean;
begin
  Result := True;
  if (Self._buffs.ContainsKey(BuffIndex)) then
    Exit;
  Self._buffs.Add(BuffIndex, BuffTime);
  Self.AddBuffEffect(BuffIndex);
end;

function TBaseNpc.GetBuffSlot(BuffIndex: WORD): Integer;
var
  i: Integer;
begin
  Result := -1;
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;
  for i := 0 to 59 do
    if (Self.PlayerCharacter.Buffs[i].Index = BuffIndex) then
    begin
      Result := i;
      Break;
    end;
end;

function TBaseNpc.GetEmptyBuffSlot(): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to 59 do
    if (Self.PlayerCharacter.Buffs[i].Index = 0) then
    begin
      Result := i;
      Break;
    end;
end;

function TBaseNpc.RemoveBuff(BuffIndex: WORD): Boolean;
var
  BuffSlot: Integer;
begin
  Result := false;
  if Self._buffs.ContainsKey(BuffIndex) then
  begin
    Self.RemoveBuffEffect(BuffIndex);
    Self._buffs.Remove(BuffIndex);
    BuffSlot := Self.GetBuffSlot(BuffIndex);
    if BuffSlot >= 0 then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := 0;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime := 0;
    end;
  end;

  if not Self._buffs.ContainsKey(BuffIndex) then
    Result := True;

  Self.GetCurrentScore;
  Self.SendStatus;
  Self.SendRefreshPoint;
  Self.SendRefreshBuffs;

  case SkillData[BuffIndex].Index of
    35: // uniao divina
      Self.UniaoDivina := '';
    42:
      Self.HPRListener := false;
    49: // contagem regressiva
      begin
        Randomize;
        Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0]),
          True, True);
      end;
    65: // x14
      begin
        // Self.DestroyPet(Self.PetClientID);
        // Self.PetClientID := 0;
      end;
    73: // mjolnir
      begin
        Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0]),
          True, True);
      end;
    99: // polimorfo
      Self.SendCreateMob(SPAWN_NORMAL);
    108: // eclater
      begin
        Randomize;
        if Self.GetMobAbility(EF_ACCELERATION1) > 0 then
          Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0] +
            SkillData[BuffIndex].Damage), True, True)
        else
          Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0]),
            True, True);
      end;
    120, 125: // HPRListener off
      Self.HPRListener := false;
    134: // cura preventiva
      Self.CalcAndCure(BuffIndex, @Self);
  end;
end;

procedure TBaseNpc.RemoveAllDebuffs();
var
  i, cnt: WORD;
begin
  cnt := 0;
  if Self._buffs.Count = 0 then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff in [3, 4]) then
    begin
      Self.RemoveBuff(i);
      Inc(cnt);
    end;
  end;

  if cnt > 0 then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;

procedure TBaseNpc.AddBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if Self.IsDungeonMob then
    Exit;

  for i := 0 to 3 do
  begin
    if i = EF_RUNSPEED then
    begin
      if (Self.MOB_EF[EF_RUNSPEED] + SkillData[Index].EFV[i]) >= 13 then
        Self.MOB_EF[EF_RUNSPEED] := 13
      else
        Self.IncreasseMobAbility(SkillData[Index].EF[i],
          SkillData[Index].EFV[i]);
    end
    else
      Self.IncreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;
end;

procedure TBaseNpc.RemoveBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if Self.IsDungeonMob then
    Exit;

  for i := 0 to 3 do
    Self.DecreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
end;

function TBaseNpc.GetBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if SkillData[i].BuffDebuff = 1 then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TBaseNpc.GetDeBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if SkillData[i].BuffDebuff in [3, 4] then
    begin
      Result := i;
      Break;
    end;
  end;
end;

function TBaseNpc.GetDebuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if SkillData[i].BuffDebuff in [3, 4] then
      Inc(Result);
  end;
end;

function TBaseNpc.GetBuffCount(): WORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if SkillData[i].BuffDebuff = 1 then
      Inc(Result);
  end;
end;

procedure TBaseNpc.RemoveBuffByIndex(Index: WORD);
var
  i: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].Index = Index) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Self.SendRefreshBuffs;
        Self.SendCurrentHPMP;
        Self.SendStatus;
        Self.SendRefreshPoint;
      end;
      Break;
    end;
  end;
end;

function TBaseNpc.GetBuffSameIndex(BuffIndex: DWORD): Boolean;
var
  j: DWORD;
begin
  Result := false;
  if (Self._buffs.Count = 0) then
    Exit;

  for j in Self._buffs.Keys do
  begin
    if (SkillData[BuffIndex].Index = SkillData[j].Index) then
    begin
      Self.RemoveBuff(j);
      Result := True;
      Break; // "break" aqui é mais eficiente que o "continue" no final
    end;
  end;
end;

function TBaseNpc.BuffExistsByIndex(BuffIndex: DWORD): Boolean;
var
  i: Integer;
begin
  Result := false;

  if (BuffIndex = 0) or (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (BuffIndex = SkillData[i].Index) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TBaseNpc.BuffExistsByID(BuffID: DWORD): Boolean;
var
  i: Integer;
begin
  Result := false;

  if (BuffID = 0) or (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (BuffID = i) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TBaseNpc.BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
var
  i, j: Integer;
begin
  Result := false;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    for j in BuffList do
    begin
      if (SkillData[i].Index = j) then
      begin
        Result := True;
        Break; // "break" aqui é mais eficiente que o "continue" no final
      end;
    end;
    if Result then
      Break;
  end;
end;

function TBaseNpc.BuffExistsSopa(): Boolean;
var
  i: Integer;
begin
  Result := false;

  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (Copy(String(SkillData[i].Name), 0, 4) = 'Sopa') then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TBaseNpc.GetBuffIDByIndex(Index: DWORD): WORD;
var
  i: WORD;
begin
  Result := 0;

  if (Index = 0) or (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (Index = SkillData[i].Index) then
    begin
      Result := i;
      // Corrigido: a variável id não estava sendo atribuída corretamente
      Break;
    end;
  end;
end;

procedure TBaseNpc.RemoveBuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;

  cnt := 0;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      Break;

    if (SkillData[i].BuffDebuff = 1) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
      end;
    end;
  end;

  if (cnt > 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;

procedure TBaseNpc.RemoveDebuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;

  cnt := 0;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      Break;

    if ((SkillData[i].BuffDebuff = 3) or (SkillData[i].BuffDebuff = 4)) then
    begin
      if (Self.RemoveBuff(i)) then
      begin
        Inc(cnt);
      end;
    end;
  end;

  if (cnt > 0) then
  begin
    Self.SendRefreshBuffs;
    Self.SendCurrentHPMP;
    Self.SendStatus;
    Self.SendRefreshPoint;
  end;
end;

procedure TBaseNpc.ZerarBuffs();
var
  i: Integer;
begin
  for i in Self._buffs.Keys do
  begin
    Self.RemoveBuff(i);
  end;
end;

{$ENDREGION}
{$REGION 'Attack & Skills'}

procedure TBaseNpc.CheckCooldown(var Packet: TSendSkillUse);
var
  EndTime: TTime;
begin
  if (Self._cooldown.ContainsKey(Packet.Skill)) then
  begin
    EndTime := IncMillisecond(Self._cooldown[Packet.Skill],
      SkillData[Packet.Skill].Cooldown);
    if EndTime >= Now then
      Exit;
  end;

  Self.UsingSkill := Packet.Skill;
  Self.SendToVisible(Packet, Packet.Header.size, True);
end;

procedure TBaseNpc.SendCurrentAllSkillCooldown();
var
  Packet: Tp12C;
  i: Integer;
  CurrTime: TTime;
  OPlayer: PPlayer;
begin
  ZeroMemory(@Packet, SizeOf(Tp12C));
  Packet.Header.size := SizeOf(Tp12C);
  Packet.Header.Index := $7535; // era 0
  Packet.Header.Code := $12C;

  OPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  for i := 0 to 5 do
  begin
    if (Self._cooldown.ContainsKey(OPlayer.Character.Skills.Basics[i].
      Index + OPlayer.Character.Skills.Basics[i].Level - 1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Basics[i].
        Index + OPlayer.Character.Skills.Basics[i].Level - 1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Basics[i].
        Index + OPlayer.Character.Skills.Basics[i].Level - 1].Duration -
        ((SkillData[OPlayer.Character.Skills.Basics[i].
        Index + OPlayer.Character.Skills.Basics[i].Level - 1].Duration div 100)
        * Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  for i := 0 to 39 do
  begin
    if (Self._cooldown.ContainsKey(OPlayer.Character.Skills.Others[i].
      Index + OPlayer.Character.Skills.Others[i].Level - 1)) then
    begin
      Self._cooldown.TryGetValue(OPlayer.Character.Skills.Others[i].
        Index + OPlayer.Character.Skills.Others[i].Level - 1, CurrTime);
      Packet.Skills[i] := SkillData[OPlayer.Character.Skills.Others[i].
        Index + OPlayer.Character.Skills.Others[i].Level - 1].Duration -
        ((SkillData[OPlayer.Character.Skills.Others[i].
        Index + OPlayer.Character.Skills.Others[i].Level - 1].Duration div 100)
        * Self.PlayerCharacter.ReduceCooldown) -
        (SecondsBetween(CurrTime, Now));
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;

function TBaseNpc.CheckCooldown2(SkillID: DWORD): Boolean;
var
  EndTime: TTime;
  CD: DWORD;
begin
  Result := True;

  if (Self._cooldown.ContainsKey(SkillID)) then
  begin
    if (Self.GetMobClass() = 3) then
      CD := ((SkillData[SkillID].Cooldown * PlayerCharacter.ReduceCooldown +
        50) div 100)
    else
      CD := ((SkillData[SkillID].Cooldown *
        PlayerCharacter.ReduceCooldown) div 100);

    EndTime := IncMillisecond(Self._cooldown[SkillID],
      (SkillData[SkillID].Cooldown - CD));
    if EndTime >= Now then
      Result := false
    else
    begin
      Self._cooldown[SkillID] := Now;
      Result := True;
    end;
  end
  else
  begin
    Self._cooldown.Add(SkillID, Now);
    Result := True;
  end;
end;

procedure TBaseNpc.SendDamage(Skill, Anim: DWORD; mob: PBaseNpc;
  DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  Add_Buff: Boolean;
  j: Integer;
  DropExp: Boolean;
  DropItem: Boolean;
  MobsP: PMobSPoisition;
  xDano, helper: Integer;
  id, id2: WORD;
  i: WORD;
  OtherPlayerLastPos: TPosition;
  playerLastPos, OtherLastPos: TPosition;
  mobCurrentPos: TPosition;
  OtherPlayer, SelfPlayer: PPlayer;
  attackRange: WORD;
  maxRangeX, maxRangeY: Single;
  deltaX, deltaY: Single;
  RangeTotal: Single;
  hack_ranged_attack: string; // Variável para armazenar o nome do item
  OtherPlayerDC: PPlayer;
  margem: Single;
begin

  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.TargetID := mob^.ClientID;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  xDano := Self.GetDamage(Skill, mob, Packet.DnType);
  if (xDano > 0) then
  begin
    Self.AttackParse(Skill, Anim, mob, xDano, Packet.DnType, Add_Buff,
      Packet.MobAnimation, DataSkill);

    if (xDano > 0) then
      Inc(xDano, (RandomRange((xDano div 20), (xDano div 10)) + 13));
  end
  else if (xDano < 0) then
    xDano := 0;

  Packet.Dano := xDano;

  // Armazenar os valores necessários em variáveis locais
  var
  EquipItem := Self.Character.Equip[15];
  var
  EquipItemType := ItemList[EquipItem.Index].ItemType;
  var
  MobClass := Self.GetMobClass();

  // Verificar se o MobClass é relevante para processamento
  if (MobClass in [0, 1, 2, 3]) then
  begin
    // Se o MobClass for 1 ou 2

    if ((MobClass = 2) or (MobClass = 3)) and (EquipItem.Index >= 1) then
    begin
      // Writeln('atirador ou dual');

      // Verificar se o item está esgotado
      if EquipItem.Index = 0 then
      begin
        var
        HelperItem := TItemFunctions.GetItemSlotByItemType
          (Servers[Self.ChannelId].Players[Self.ClientID], 50, INV_TYPE);

        // Verificar se o item auxiliar é válido e compatível
        if (HelperItem <> 255) and
          (ItemList[Self.Character.Inventory[HelperItem].Index]
          .Classe = Self.Character.ClassInfo) then
        begin
          // Realizar o movimento do item
          Move(Self.Character.Inventory[HelperItem], Self.Character.Equip[15],
            SizeOf(TItem));
          Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
            Self.Character.Equip[15], false);
          ZeroMemory(@Self.Character.Inventory[HelperItem], SizeOf(TItem));
          Self.SendRefreshItemSlot(INV_TYPE, HelperItem,
            Self.Character.Inventory[HelperItem], false);

          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Suas balas acabaram e foram equipadas novas balas a partir do inventário.');
        end;
      end;

      // Verificar se o item equipado é do tipo bala (50)
      if EquipItemType = 50 then
      begin
        // Reduzir a quantidade de balas conforme MobClass
        var
        DecreaseAmount := 0;
        if (MobClass = 3) then
        begin
          DecreaseAmount := 2;
          if (Self.BuffExistsByIndex(77)) then
          begin // inv dual
            Self.RemoveBuffByIndex(77);
          end;
        end
        else if MobClass = 2 then
        begin
          DecreaseAmount := 1;
          if (Self.BuffExistsByIndex(53)) then
          begin // inv att
            Self.RemoveBuffByIndex(53);
          end;
          if (mob^.BuffExistsByIndex(153)) then
          begin // predador
            mob^.RemoveBuffByIndex(153);
          end;
        end;
        // Writeln('removendo bala');
        TItemFunctions.DecreaseAmount(@Self.Character.Equip[15],
          DecreaseAmount);
        Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
          Self.Character.Equip[15], false);
      end;

      if (EquipItem.Index = 0) then
      begin
        Exit;
      end;
    end;
    if mob.ClientID <= MAX_CONNECTIONS then
      // Aplicar dano baseado no MobClass
      case MobClass of
        // aqui que manipula os danos do atk basico
        0:
          Packet.Dano := Trunc(Packet.Dano / 1.6); // case do war
        1:
          Packet.Dano := Packet.Dano + Trunc(Packet.Dano / 1.8); // case da tp
        2:
          Packet.Dano := Trunc(Packet.Dano / 1.2); // case do att
        3:
          Packet.Dano := Trunc(Packet.Dano * 1.2); // case da dual
        // 4: Packet.Dano := Trunc(Packet.Dano * 1.2); //case do fc
        // 5: Packet.Dano := Trunc(Packet.Dano * 1.2); //case da santa

      end;
  end;

  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
  begin
    if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
      [Self.ClientID].DungeonInstanceID].MOBS[mob.Mobid].CurrentHP) then
    begin
      mob.IsDead := True;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP := 0;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[mob.Mobid].IsAttacked := false;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[mob.Mobid].AttackerID := 0;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[mob.Mobid].deadTime := Now;
      if (Self.VisibleMobs.Contains(mob.ClientID)) then
        Self.VisibleMobs.Remove(mob.ClientID);
      Self.MobKilledInDungeon(mob);
      Packet.MobAnimation := 30;
    end
    else
    begin
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP :=
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP - Packet.Dano;
    end;
    mob.LastReceivedAttack := Now;
    Packet.MobCurrHP := DungeonInstances
      [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].MOBS
      [mob.Mobid].CurrentHP;
    Self.SendToVisible(Packet, Packet.Header.size);
    Exit;
  end;

  MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[0].MobsP[1];
  if (mob^.SecondIndex > 0) then
    MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
      [mob^.SecondIndex];

  if (mob^.ClientID >= 3048) and (mob^.ClientID <= 9147) then
  begin
    case mob^.ClientID of
      3340 .. 3354: // Stones
        begin
          with Servers[Self.ChannelId].DevirStones[mob^.ClientID] do
          begin
            if (Packet.Dano >= PlayerChar.Base.CurrentScore.CurHP) and not mob^.IsDead
            then
            begin
              mob^.IsDead := True;
              PlayerChar.Base.CurrentScore.CurHP := 0;
              IsAttacked := false;
              AttackerID := 0;
              deadTime := Now;
              KillStone(mob^.ClientID, Self.ClientID);

              // Remove mob from visible players
              if Self.VisibleNPCS.Contains(mob^.ClientID) then
              begin
                Self.VisibleNPCS.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
              end;

              for j in Self.VisiblePlayers do
                with Servers[Self.ChannelId].Players[j].Base do
                  if VisibleNPCS.Contains(mob^.ClientID) then
                  begin
                    VisibleNPCS.Remove(mob^.ClientID);
                    // RemoveTargetFromList(mob);
                  end;

              mob^.VisibleMobs.Clear;
              Packet.MobAnimation := 30;
            end
            else
            begin
              PlayerChar.Base.CurrentScore.CurHP :=
                PlayerChar.Base.CurrentScore.CurHP - Packet.Dano;
              if (Now >= IncSecond(mob^.LastReceivedAttack, 2)) then
              begin
                case mob^.ClientID of
                  3340 .. 3344:
                    begin
                      Helper := Servers[Self.ChannelId].DevirGuards[j]
                        .GetDevirIdByStoneOrGuardId(mob^.ClientID);
                      Servers[Self.ChannelId].SendServerMsgForNation
                        ('O Pedra do Devir de ' +
                        AnsiString(Servers[Self.ChannelId].DevirNpc[Helper +
                        3335].DevirName) + ' está sendo atacado.',
                        Servers[Self.ChannelId].NationID);
                    end;
                end;
              end;
            end;
          end;

          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          Exit;
        end;

      3355 .. 3369: // Guards
        begin
          with Servers[Self.ChannelId].DevirGuards[mob^.ClientID] do
          begin
            if (Packet.Dano >= PlayerChar.Base.CurrentScore.CurHP) and not mob^.IsDead
            then
            begin
              mob^.IsDead := True;
              PlayerChar.Base.CurrentScore.CurHP := 0;
              IsAttacked := false;
              AttackerID := 0;
              deadTime := Now;
              KillGuard(mob^.ClientID, Self.ClientID);

              // Remove mob from visible players
              if Self.VisibleNPCS.Contains(mob^.ClientID) then
              begin
                Self.VisibleNPCS.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
              end;

              for j in Self.VisiblePlayers do
                with Servers[Self.ChannelId].Players[j].Base do
                  if VisibleNPCS.Contains(mob^.ClientID) then
                  begin
                    VisibleNPCS.Remove(mob^.ClientID);
                    // RemoveTargetFromList(mob);
                  end;

              mob^.VisibleMobs.Clear;
              Packet.MobAnimation := 30;
            end
            else
            begin
              PlayerChar.Base.CurrentScore.CurHP :=
                PlayerChar.Base.CurrentScore.CurHP - Packet.Dano;
              if (Now >= IncSecond(mob^.LastReceivedAttack, 2)) then
              begin
                Helper := Servers[Self.ChannelId].DevirGuards[j]
                  .GetDevirIdByStoneOrGuardId(mob^.ClientID);
                Servers[Self.ChannelId].SendServerMsgForNation
                  ('O Totem de ' + AnsiString(Servers[Self.ChannelId].DevirNpc
                  [Helper + 3335].DevirName) + ' está sendo atacado.',
                  Servers[Self.ChannelId].NationID);
              end;
            end;
          end;

          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
            .PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          Exit;
        end;

    else // Default handling for other mobs
      if not MobsP^.IsAttacked then
        MobsP^.FirstPlayerAttacker := Self.ClientID;

      if Packet.Dano >= MobsP^.HP then
      begin
        mob^.IsDead := True;
        MobsP^.HP := 0;
        MobsP^.IsAttacked := false;
        MobsP^.AttackerID := 0;
        MobsP^.deadTime := Now;

        MobsP^.Base.SendEffect($0);
        mob.SendCurrentHPMPMob;

        if Self.VisibleMobs.Contains(mob^.ClientID) then
        begin
          Self.VisibleMobs.Remove(mob^.ClientID);
          Self.RemoveTargetFromList(mob);
        end;

        for j := Low(Servers[Self.ChannelId].Players)
          to High(Servers[Self.ChannelId].Players) do
        begin
          if (Servers[Self.ChannelId].Players[j].Status < Playing) or
            Servers[Self.ChannelId].Players[j].SocketClosed then
            continue;

          if Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains
            (mob^.ClientID) then
          begin
            Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
              (mob^.ClientID);
            // Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
          end;
        end;

        try
          if not Servers[Self.ChannelId].Players[Self.ClientID].SocketClosed
          then
          begin
            if mob^.SecondIndex > 0 then
            begin
              if (mob^.ClientID >= 3049) and (mob^.ClientID <= 9147) then
              begin
                if Servers[Self.ChannelId].MOBS.TMobS[mob^.Mobid].IsActiveToSpawn
                then
                  Self.MobKilled(mob, DropExp, DropItem, false);
              end;
            end;
          end;
        except
          on E: Exception do
            Logger.Write('Erro no MobKiller: ' + E.Message + 't ' +
              DateTimeToStr(Now), TLogType.Error);
        end;

        mob^.VisibleMobs.Clear;
        Packet.MobAnimation := 30;
      end
      else
        MobsP^.HP := MobsP^.HP - Packet.Dano;

      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := MobsP^.HP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
    end;
  end;

  if SecondsBetween(Now, mob.RevivedTime) <= 7 then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Alvo acabou de nascer.');
    Exit;
  end;

  if Packet.Dano >= mob^.Character.CurrentScore.CurHP then
  begin
    if Servers[Self.ChannelId].Players[mob^.ClientID].Dueling then
      mob^.Character.CurrentScore.CurHP := 10
    else
    begin
      mob^.Character.CurrentScore.CurHP := 0;
      mob^.SendEffect($0);
      Packet.MobAnimation := 30;
      mob^.IsDead := True;

      if Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare then
        Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
          (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);

      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := 0;
      // mob^.Character.CurrentScore.CurHP já é 0 neste ponto
      Self.SendToVisible(Packet, Packet.Header.size);

      // Condição combinada para Nation
      if ((mob^.Character.Nation > 0) and (Self.Character.Nation > 0) and
        ((mob^.Character.Nation <> Self.Character.Nation) or
        Self.InClastleVerus)) or
        ((Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation >
        0) and (Self.Character.Nation > 0) and
        (Servers[Self.ChannelId].Players[mob^.ClientID]
        .Base.Character.Nation = Self.Character.Nation) and
        not Self.InClastleVerus and
        (Servers[Self.ChannelId].Players[Self.ClientID].Waiting1 = 0)) or
        ((Self.Character.Nation = 0) and
        (Servers[Self.ChannelId].Players[mob^.ClientID]
        .Base.ChannelId = Self.ChannelId) and not Self.InClastleVerus and
        (Servers[Self.ChannelId].Players[Self.ClientID].Waiting1 = 0)) then
      begin
        Self.PlayerKilled(mob);
      end;
    end;
  end
  else
  begin
    if Packet.Dano > 0 then
      mob^.RemoveHP(Packet.Dano, false);

    if Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare then
      Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
        (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);

    mob^.LastReceivedAttack := Now;
    Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;
end;

function TBaseNpc.GetDamage(Skill: DWORD; mob: PBaseNpc;
  out DnType: TDamageType): UInt64;
var
  ResultDamage, MobDef, defHelp, DamageReduction: Integer;
  IsPhysical: Boolean;
  IsImmune, IsBuff19, IsBuff91: Boolean;
begin
  try
    Result := 0;
    Randomize; // Chamar Randomize uma vez no início

    // Verifica se o mob é imune ou tem buffs específicos
    IsImmune := (mob^.GetMobAbility(EF_IMMUNITY) > 0);
    IsBuff19 := mob^.BuffExistsByIndex(19);
    IsBuff91 := mob^.BuffExistsByIndex(91);

    if IsImmune then
    begin
      DnType := TDamageType.Immune;
      Exit;
    end;

    // Lógica para Buff 19
    if IsBuff19 then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(19);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(19);
        DnType := TDamageType.Block;
        Exit;
      end;
    end;

    // Lógica para Buff 91
    if IsBuff91 then
    begin
      if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
      begin
        mob^.RemoveBuffByIndex(91);
        Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
      end
      else
      begin
        mob^.RemoveBuffByIndex(91);
        DnType := TDamageType.Miss2;
        Exit;
      end;
    end;

    // Determina se o ataque é físico ou mágico
    case Self.GetMobClass of
      0 .. 3:
        IsPhysical := True;
    else
      IsPhysical := (Skill = 0);
    end;

    // Cálculo de dano físico ou mágico
    if IsPhysical then
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNFis;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFFis;
      defHelp := Self.PlayerCharacter.FisPenetration;
      if defHelp > 0 then
        dec(MobDef, (mob.PlayerCharacter.Base.CurrentScore.DEFFis div 100)
          * defHelp);
    end
    else
    begin
      ResultDamage := Self.PlayerCharacter.Base.CurrentScore.DNMAG;
      MobDef := mob.PlayerCharacter.Base.CurrentScore.DEFMAG;
      defHelp := Self.PlayerCharacter.MagPenetration;
      if defHelp > 0 then
        dec(MobDef, (mob.PlayerCharacter.Base.CurrentScore.DEFMAG div 100)
          * defHelp);
    end;

    DnType := Self.GetDamageType3(Skill, IsPhysical, mob);
    if DnType = Miss then
    begin
      Result := 0;
      Exit;
    end;

    // Redução do dano com base na defesa do mob
    ResultDamage := ResultDamage - (MobDef shr 3);
    if mob^.ClientID <= MAX_CONNECTIONS then
    begin
      DamageReduction := (ResultDamage div 100) *
        (mob.GetEquipedItensDamageReduce div 10);
      dec(ResultDamage, DamageReduction);
    end;

    if ResultDamage <= 0 then
      ResultDamage := 1;

    Result := ResultDamage + (RandomRange(10, 120) + 15);

  except
    on E: Exception do
    begin
      Logger.Write('TBaseNpc.GetDamage Error: ' + E.Message, TLogType.Error);
      Result := (((Self.PlayerCharacter.Base.CurrentScore.DNFis +
        Self.PlayerCharacter.Base.CurrentScore.DNMAG) div 2) -
        (((mob^.PlayerCharacter.Base.CurrentScore.DEFMAG +
        mob^.PlayerCharacter.Base.CurrentScore.DEFFis) div 2) shr 3));
      DnType := TDamageType.Normal;
      Result := Result + (RandomRange(10, 120) + 15);
    end;
  end;
end;

function TBaseNpc.GetDamageType(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseNpc): TDamageType;
var
  RamdomArray: ARRAY [0 .. 999] OF Byte;
  RamdomSlot: WORD;
  Chance: Integer;
  DuploChance, CritChance, CritHelp, DuploHelp, MissHelp: WORD;
  AllChance: WORD;
  xRes: TDamageType;

  procedure SetChance(Chance: WORD; const Type1: Byte);
  var
    i, cnt: Integer;
  begin
    if (Chance = 0) then
      Exit;

    cnt := 0;
    for i := 0 to 999 do
    begin
      if (cnt >= Chance) then
        Break;
      if (RamdomArray[i] = 0) then
      begin
        RamdomArray[i] := Type1;
        Inc(cnt);
      end;
    end;
    AllChance := AllChance + Chance;
  end;

begin
  ZeroMemory(@RamdomArray, 1000);
  Randomize;

  // Set basic damage type chances
  if IsPhysical then
    Chance := 20
  else
    Chance := 30;
  SetChance(Chance, Byte(TDamageType.Critical));
  SetChance(Chance div 2, Byte(TDamageType.Miss));

  // Set chances based on mob stats
  CritHelp := mob^.GetMobAbility(EF_RESISTANCE6) + mob^.PlayerCharacter.CritRes;
  if CritHelp > Self.PlayerCharacter.Base.CurrentScore.Critical then
    CritChance := 0
  else
  begin
    CritChance := Self.PlayerCharacter.Base.CurrentScore.Critical;
    decword(CritChance, CritHelp);
  end;
  SetChance(CritChance, Byte(TDamageType.Critical));

  if IsPhysical then
  begin
    SetChance(10, Byte(TDamageType.Double));
    SetChance(20, Byte(TDamageType.DoubleCritical));

    DuploHelp := mob^.GetMobAbility(EF_RESISTANCE7) +
      mob^.PlayerCharacter.DuploRes;
    if DuploHelp > Self.PlayerCharacter.DuploAtk then
      DuploChance := 0
    else
    begin
      DuploChance := Self.PlayerCharacter.DuploAtk;
      decword(DuploChance, DuploHelp);
    end;

    DuploHelp :=
      ((Self.PlayerCharacter.DuploAtk + Self.PlayerCharacter.Base.CurrentScore.
      Critical) div 3);
    if CritHelp >= DuploHelp then
      DuploHelp := 10;
    SetChance(DuploHelp, Byte(TDamageType.DoubleCritical));
    SetChance(DuploChance, Byte(TDamageType.Double));
  end
  else
  begin
    SetChance(20, Byte(TDamageType.DoubleCritical));

    DuploHelp :=
      ((Self.PlayerCharacter.DuploAtk + Self.PlayerCharacter.Base.CurrentScore.
      Critical) div 2);
    if DuploHelp <= CritHelp then
      DuploHelp := 20;
    SetChance(DuploHelp, Byte(TDamageType.DoubleCritical));
  end;

  MissHelp := mob^.PlayerCharacter.Base.CurrentScore.Esquiva;
  decword(MissHelp, Self.PlayerCharacter.Base.CurrentScore.Acerto);
  SetChance(MissHelp, Byte(TDamageType.Miss));

  if (AllChance > 998) then
    AllChance := 998;

  // Get random damage type
  xRes := TDamageType(RamdomArray[RandomRange(1, AllChance + 1)]);

  if (xRes = TDamageType.Double) and (Skill > 0) and IsPhysical then
    xRes := TDamageType.Normal;

  Result := xRes;
end;

function TBaseNpc.GetDamageType2(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseNpc): TDamageType;
var
  MissRate, HitRate, CritRate, ResCritRate, DuploCritRate, DuploRate,
    DuploResRate: Integer;
  Helper: Integer;
begin
  Result := TDamageType.Normal;
  Randomize;

  // Verificando a chance de Miss
  Helper := RandomRange(1, 101);
  MissRate := ((mob^.PlayerCharacter.Base.CurrentScore.Esquiva div 500) * 100);
  if (MissRate > 80) then
    MissRate := 80; // 20% de margem de erro 1/5
  if (Helper <= MissRate) then
  begin
    // Verificando a chance de Acerto após o Miss
    HitRate := ((Self.PlayerCharacter.Base.CurrentScore.Acerto div 500) * 100);
    if (HitRate > 60) then
      HitRate := 60;
    Helper := RandomRange(1, 101);
    if (Helper <= HitRate) then
    begin
      Result := TDamageType.Normal;
    end
    else
    begin
      Result := TDamageType.Miss;
      Exit;
    end;
  end
  else
  begin
    // Verificando a chance de Crítico
    CritRate :=
      ((Self.PlayerCharacter.Base.CurrentScore.Critical div 500) * 100);
    if (CritRate > 80) then
      CritRate := 80; // 20% de critico imperfeito
    Helper := RandomRange(1, 101);
    if (Helper <= CritRate) then
    begin
      // Verificando se o alvo resiste ao Crítico
      ResCritRate :=
        (((mob^.GetMobAbility(EF_RESISTANCE6) + mob^.PlayerCharacter.CritRes)
        div 500) * 100);
      if (ResCritRate > 60) then
        ResCritRate := 60; // 40% de resistência a crítico imperfeito
      Helper := RandomRange(1, 101);
      if (Helper <= ResCritRate) then
      begin
        // Verificando a chance de Duplo após resistir ao Crítico
        DuploRate := ((Self.PlayerCharacter.DuploAtk div 500) * 100);
        if (DuploRate > 80) then
          DuploRate := 80;
        Helper := RandomRange(1, 101);
        if (Helper <= DuploRate) then
        begin
          DuploResRate :=
            (((mob^.GetMobAbility(EF_RESISTANCE7) +
            mob^.PlayerCharacter.DuploRes) div 500) * 100);
          if (DuploResRate > 60) then
            DuploResRate := 60;
          Helper := RandomRange(1, 101);
          if (Helper <= DuploResRate) then
          begin
            Result := TDamageType.Normal;
            Exit;
          end
          else
          begin
            Result := TDamageType.Double;
            Exit;
          end;
        end;
      end
      else
      begin
        // Se o Crítico passou, verificando o Duplo Crítico
        DuploCritRate :=
          ((((Self.PlayerCharacter.Base.CurrentScore.Critical +
          Self.PlayerCharacter.DuploAtk) div 2) div 500) * 100);
        if (DuploCritRate > 60) then
          DuploCritRate := 60; // 40% de duplo crítico imperfeito
        Helper := RandomRange(1, 101);
        if (Helper <= DuploCritRate) then
        begin
          Result := TDamageType.Critical;
        end
        else
        begin
          Result := TDamageType.DoubleCritical;
        end;
        Exit;
      end;
    end;
  end;
end;

function TBaseNpc.GetDamageType3(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseNpc): TDamageType;
var
  Esquiva, Acerto: WORD;
  Critico, ResistenciaCrit: WORD;
  Duplo, ResistenciaDuplo: WORD;
  DuploCritico, ResistenciaDuploCritico: WORD;
  TaxaCritica, TaxaMiss, TaxaDuplo, TaxaDuploCritico: Integer;
  AlwaysCrit: Boolean;
  Acertos, Esquivas, Tentativas, RandValue, ProbabilidadeAcerto, AjusteDeChance,
    ProbabilidadeCritico, ProbabilidadeDuplo, ProbabilidadeDuploCritico
    : Integer;
begin
  AlwaysCrit := false;
  Result := TDamageType.Normal;

{$REGION 'Calculando Acerto x Esquiva'}
  Esquiva := mob.PlayerCharacter.Base.CurrentScore.Esquiva;
  // Esquiva do alvo (mob)
  Acerto := Self.PlayerCharacter.Base.CurrentScore.Acerto; // Acerto do jogador

  // Definindo a probabilidade base de acerto para 33%
  ProbabilidadeAcerto := 70;

  // Ajuste de chance com base no valor de acerto e esquiva
  AjusteDeChance := (Acerto * 8) div 10 - (Esquiva * 6) div 10;
  ProbabilidadeAcerto := ProbabilidadeAcerto + AjusteDeChance;
  // Incrementa ou decrementa a chance de acerto

  // Garantir que a probabilidade de acerto não ultrapasse 100% nem seja inferior a 0%
  if ProbabilidadeAcerto > 100 then
    ProbabilidadeAcerto := 100;
  if ProbabilidadeAcerto < 0 then
    ProbabilidadeAcerto := 0;

  // Aqui você pode calcular o resultado final de acerto ou esquiva
  Randomize;
  RandValue := RandomRange(1, 101); // Gera um número aleatório entre 1 e 100

  // Se o valor aleatório for menor ou igual à probabilidade de acerto, é um sucesso
  if RandValue <= ProbabilidadeAcerto then
  begin
    Result := TDamageType.Normal; // Acerto
    Self.MissCount := Self.MissCount + 1;
    // inc(Self.MissCount, 1);  // Aumenta o contador de acertos
  end
  else
  begin
    Result := TDamageType.Miss; // Esquiva
    Self.MissCount := 0; // Reinicia o contador de misses
    Exit; // Se for esquiva, não continue para os outros cálculos
  end;
{$ENDREGION}
{$REGION 'Calculando Critico x Resistencia Critico'}
  if Result <> TDamageType.Miss then
  begin
    Critico := Self.PlayerCharacter.Base.CurrentScore.Critical;
    ResistenciaCrit := mob.PlayerCharacter.CritRes;

    // Definindo a probabilidade base de crítico
    ProbabilidadeCritico := 15;

    // Ajuste de chance com base no valor de crítico e resistência de crítico
    AjusteDeChance := (Critico * 8) div 10 - (ResistenciaCrit * 6) div 10;
    ProbabilidadeCritico := ProbabilidadeCritico + AjusteDeChance;

    // Garantir que a probabilidade de crítico não ultrapasse 100% nem seja inferior a 0%
    if ProbabilidadeCritico > 100 then
      ProbabilidadeCritico := 100;
    if ProbabilidadeCritico < 0 then
      ProbabilidadeCritico := 0;

    // Aqui você pode calcular o resultado final de crítico
    Randomize;
    RandValue := RandomRange(1, 101); // Gera um número aleatório entre 1 e 100

    if RandValue <= ProbabilidadeCritico then
    begin
      Result := TDamageType.Critical;
      // Se o valor aleatório for menor ou igual à probabilidade de crítico, é um crítico
    end;
  end;
{$ENDREGION}
{$REGION 'Calculando Duplo x Resistencia Duplo'}
  if Result <> TDamageType.Miss then
  begin
    Duplo := Self.PlayerCharacter.DuploAtk;
    ResistenciaDuplo := mob.PlayerCharacter.DuploRes;

    // Definindo a probabilidade base de duplo
    ProbabilidadeDuplo := 10;

    // Ajuste de chance com base no valor de duplo e resistência de duplo
    AjusteDeChance := (Duplo * 8) div 10 - (ResistenciaDuplo * 6) div 10;
    ProbabilidadeDuplo := ProbabilidadeDuplo + AjusteDeChance;

    // Garantir que a probabilidade de duplo não ultrapasse 100% nem seja inferior a 0%
    if ProbabilidadeDuplo > 100 then
      ProbabilidadeDuplo := 100;
    if ProbabilidadeDuplo < 0 then
      ProbabilidadeDuplo := 0;

    // Aqui você pode calcular o resultado final de duplo
    Randomize;
    RandValue := RandomRange(1, 101); // Gera um número aleatório entre 1 e 100

    if RandValue <= ProbabilidadeDuplo then
    begin
      Result := TDamageType.Double;
      // Se o valor aleatório for menor ou igual à probabilidade de duplo, é um duplo
    end;
  end;
{$ENDREGION}
{$REGION 'Calculando Duplo Crítico (Crítico + Duplo)'}
  if (Result = TDamageType.Critical) then
  begin
    Duplo := Self.PlayerCharacter.DuploAtk;
    ResistenciaDuplo := mob.PlayerCharacter.DuploRes;

    // Definindo a probabilidade base de duplo crítico
    ProbabilidadeDuploCritico := 8;

    // Ajuste de chance com base no valor de duplo e resistência de duplo
    AjusteDeChance := (Duplo * 8) div 10 - (ResistenciaDuplo * 6) div 10;
    ProbabilidadeDuploCritico := ProbabilidadeDuploCritico + AjusteDeChance;

    // Garantir que a probabilidade de duplo crítico não ultrapasse 100% nem seja inferior a 0%
    if ProbabilidadeDuploCritico > 100 then
      ProbabilidadeDuploCritico := 100;
    if ProbabilidadeDuploCritico < 0 then
      ProbabilidadeDuploCritico := 0;

    // Aqui você pode calcular o resultado final de duplo crítico
    Randomize;
    RandValue := RandomRange(1, 101); // Gera um número aleatório entre 1 e 100

    if RandValue <= ProbabilidadeDuploCritico then
    begin
      Result := TDamageType.DoubleCritical;
      // Se o valor aleatório for menor ou igual à probabilidade de duplo crítico, é um duplo crítico
    end;
  end;
{$ENDREGION}
end;

procedure TBaseNpc.CalcAndCure(Skill: DWORD; mob: PBaseNpc);
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);
  Inc(Cure, SkillData[Skill].Damage);
  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));

  if (Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));
  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));
  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  deccardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;
    Exit;
  end
  else if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0))
  then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;

    if (mob.NegarCuraCount = 0) then
      mob.RemoveBuffByIndex(88);

    Exit;
  end;

  mob.AddHP(Cure, True);

  if (mob.ClientID = Self.ClientID) then
  begin
    Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
      ('Seu HP foi restaurado em ' + AnsiString(Cure.ToString), 16);
  end
  else
  begin
    Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
      ('Seu HP foi restaurado em ' + AnsiString(Cure.ToString) + ' por [' +
      AnsiString(Self.Character.Name) + '].', 16);
  end;
end;

function TBaseNpc.CalcCure(Skill: DWORD; mob: PBaseNpc): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);
  Inc(Cure, SkillData[Skill].Damage);
  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));

  if (Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));
  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));
  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_PER_CURE_PREPARE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  deccardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
  begin
    mob.NegarCuraCount := 3;
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;
    Exit;
  end
  else if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0))
  then
  begin
    mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)), True, True);
    mob.LastReceivedAttack := Now;
    mob.NegarCuraCount := mob.NegarCuraCount - 1;

    if (mob.NegarCuraCount = 0) then
      mob.RemoveBuffByIndex(88);

    Exit;
  end;

  Result := Cure;
end;

function TBaseNpc.CalcCure2(BaseCure: DWORD; mob: PBaseNpc;
  xSkill: Integer): Integer;
var
  Cure: Cardinal;
  curePerc: Integer;
begin
  Result := 0;

  Cure := (Self.PlayerCharacter.Base.CurrentScore.DNMAG div 2);
  Cure := Cure + BaseCure;

  if (xSkill > 0) then
    Inc(Cure, SkillData[xSkill].Damage);

  Inc(Cure, ((Cure div 40) * Self.GetMobAbility(EF_DAMAGE6)));
  Inc(Cure, (Self.GetMobAbility(EF_SKILL_DAMAGE6)));

  if (Self.ClientID <> mob.ClientID) then
  begin
    Inc(Cure, ((Cure div 40) * mob.GetMobAbility(EF_DAMAGE6)));
    Inc(Cure, (mob.GetMobAbility(EF_SKILL_DAMAGE6)));
  end;

  Inc(Cure, ((Cure div 100) * mob.PlayerCharacter.CureTax));
  Inc(Cure, ((Cure div 100) * mob.GetMobAbility(EF_UPCURE)));

  Randomize;
  curePerc := ((RandomRange(20, 299) div 2) + 35);
  Inc(Cure, curePerc);

  deccardinal(Cure, ((Cure div 100) * mob.GetMobAbility(EF_DECURE)));

  if (SkillData[xSkill].Index <> 125) then
  begin
    if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount = 0)) then
    begin
      mob.NegarCuraCount := 3;
      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)),
        True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount - 1;
      Exit;
    end
    else if ((mob.GetMobAbility(EF_ANTICURE) > 0) and (mob.NegarCuraCount > 0))
    then
    begin
      mob.RemoveHP(((Cure div 100) * mob.GetMobAbility(EF_ANTICURE)),
        True, True);
      mob.LastReceivedAttack := Now;
      mob.NegarCuraCount := mob.NegarCuraCount - 1;

      if (mob.NegarCuraCount = 0) then
        mob.RemoveBuffByIndex(88);

      Exit;
    end;
  end;

  Result := Cure;
end;

procedure TBaseNpc.HandleSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  SelectedPos: TPosition; DataSkill: P_SkillData);
var
  Packet: TRecvDamagePacket;
  gotDano: Integer;
  gotDMGType: TDamageType;
  Add_Buff: Boolean;
  Resisted: Boolean;
  DropExp, DropItem: Boolean;
  j: Integer;
  s: Integer;
  Helper2: Byte;
  SelfPlayer, OtherPlayer: PPlayer;
  // Mobs: PMobSa;
  MobsP: PMobSPoisition;
  Rand: Integer;
  OtherPlayerLastPos: TPosition;
  playerLastPos, OtherLastPos: TPosition;
  attackRange: WORD;
  maxRangeX, maxRangeY: Integer;
  deltaX, deltaY: Single;
  RangeTotal: Single;
  i: WORD;
  xDano, helper: Integer;
  mobCurrentPos: TPosition;
  margem: Single;
begin
  margem := 3.0;
  s := SizeOf(Packet);
  ZeroMemory(@Packet, s);
  Packet.Header.size := s;
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;

  OtherLastPos := Servers[mob^.ChannelId].Players[mob^.ClientID]
    .Base.PlayerCharacter.LastPos;
  mobCurrentPos := Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
    [mob.SecondIndex].CurrentPos;

  Packet.TargetID := IfThen(mob^.ClientID = Self.ClientID, Self.ClientID,
    mob^.ClientID);
  Packet.MobAnimation := DataSkill^.TargetAnimation;

  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  if (DataSkill^.SuccessRate = 1) and (DataSkill^.range = 0) then
  begin
    Resisted := false;
    case Self.GetMobClass() of
      2:
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
        begin
          TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
          Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
            Self.Character.Equip[15], false);
        end;
      3:
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
        begin
          TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 2);
          Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
            Self.Character.Equip[15], false);
        end;
    end;
    Writeln('cheguei até aqui -1');
    Self.TargetSkill(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff, Resisted);
    Writeln('cheguei até aqui 0');

    if (gotDano > 0) then
    begin
      Self.AttackParse(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff,
        Packet.MobAnimation, DataSkill);
      Writeln('cheguei até aqui 1');

      if (gotDano > 0) then
        Inc(gotDano, RandomRange((gotDano div 20), (gotDano div 10)) + 13);
    end
    else if not(gotDMGType in [Critical, Normal, Double]) then
      Add_Buff := false;

    if (Add_Buff and not Resisted) then
    begin
      Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
      Writeln('cheguei até aqui 2');
    end;

    Packet.Dano := gotDano;
    Packet.DnType := gotDMGType;

    if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
    begin
      if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
        [Self.ClientID].DungeonInstanceID].MOBS[mob.Mobid].CurrentHP) then
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP := 0;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].IsAttacked := false;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].AttackerID := 0;
        { DungeonInstances
          [Servers[Self.ChannelId].Players[Self.ClientId].DungeonInstanceID]
          .Mobs[mob.Mobid].deadTime := Now; }
        if (Self.VisibleMobs.Contains(mob.ClientID)) then
          Self.VisibleMobs.Remove(mob.ClientID);
        mob.VisibleMobs.Clear;
        Self.MobKilledInDungeon(mob);
        Packet.MobAnimation := 30;
        mob.IsDead := True;
      end
      else
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP :=
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP - Packet.Dano;
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := DungeonInstances
        [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].MOBS
        [mob.Mobid].CurrentHP;
      Self.SendToVisible(Packet, Packet.Header.size);
      Exit;
    end;

    MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[0].MobsP[1];
    if (mob^.SecondIndex > 0) then
      MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
        [mob^.SecondIndex];

    if (mob^.ClientID <= MAX_CONNECTIONS) then
    begin
      if (SecondsBetween(Now, mob.RevivedTime) <= 7) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('Alvo acabou de nascer.');
        Logger.Write('Teste dano mob 7', TLogType.Error);
        Exit;
      end;

      if ((DataSkill^.Index = PANCADA) and
        (Packet.Dano > (Self.Character.CurrentScore.MaxHP div 3))) then
      begin
        Packet.Dano := (Self.Character.CurrentScore.MaxHP div 2);
      end;

      OtherPlayer := @Servers[mob^.ChannelId].Players[mob^.ClientID];
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
      begin
        if (OtherPlayer^.Dueling) then
        begin
          mob^.Character.CurrentScore.CurHP := 10;
        end
        else
        begin
          mob^.Character.CurrentScore.CurHP := 0;
          mob^.SendEffect($0);
          Packet.MobAnimation := 30;
          mob^.IsDead := True;
          if (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare)
          then
            Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
              (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          Logger.Write('Teste dano mob 8', TLogType.Error);
          if (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
          begin
            if ((mob^.Character.Nation <> Self.Character.Nation) or
              (Self.InClastleVerus)) then
            begin
              Self.PlayerKilled(mob);
            end;
          end;
        end;
      end
      else
      begin
        if (Packet.Dano > 0) then
          mob^.RemoveHP(Packet.Dano, false);
        if (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingReliquare)
        then
          Servers[Self.ChannelId].Players[mob^.ClientID].SendCancelCollectItem
            (Servers[Self.ChannelId].Players[mob^.ClientID].CollectingID);
        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
        Self.SendToVisible(Packet, Packet.Header.size);
        Logger.Write('Teste dano mob 9', TLogType.Error);
      end;

      Exit;
    end
    else if (((mob^.ClientID >= 3048) and (mob^.ClientID < 9148)) or
      (MobsP.isTemp)) then
    begin
      // Mobs := @Servers[mob^.ChannelId].Mobs.TMobS[mob^.Mobid];
      case mob^.ClientID of
        3340 .. 3354:
          begin // stones
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
              not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .IsAttacked := false;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .KillStone(mob^.ClientID, Self.ClientID);
              if (Self.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCS.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if (Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains
                  (mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Remove
                    (mob^.ClientID);
                  // Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirStones[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;

          end;
        3355 .. 3369:
          begin // guards
            if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
              not(mob^.IsDead)) then
            begin
              mob^.IsDead := True;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .IsAttacked := false;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .AttackerID := 0;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .deadTime := Now;
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .KillGuard(mob^.ClientID, Self.ClientID);
              if (Self.VisibleNPCS.Contains(mob^.ClientID)) then
              begin
                Self.VisibleNPCS.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
                // essa skill tem retorno no caso de erro
              end;
              for j in Self.VisiblePlayers do
              begin
                if (Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains
                  (mob^.ClientID)) then
                begin
                  Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Remove
                    (mob^.ClientID);
                  // Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
                end;
              end;
              mob^.VisibleMobs.Clear;
              // Self.MobKilled(mob, DropExp, DropItem, False);
              Packet.MobAnimation := 30;
            end
            else
            begin
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := Servers[Self.ChannelId]
                .DevirGuards[mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP -
                Packet.Dano;
            end;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);
            // Sleep(1);
            Exit;
          end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];

          if not(MobsP.IsAttacked) then
          begin
            MobsP.FirstPlayerAttacker := Self.ClientID;
          end;

          if (Packet.Dano >= MobsP^.HP) then
          begin
            MobsP^.HP := 0;
            MobsP^.IsAttacked := false;
            MobsP^.AttackerID := 0;
            MobsP^.deadTime := Now;

            MobsP.Base.SendEffect($0);
            Logger.Write('Teste dano mob 10', TLogType.Error);
            if (Self.VisibleMobs.Contains(mob^.ClientID)) then
            begin
              Self.VisibleMobs.Remove(mob^.ClientID);
              Self.RemoveTargetFromList(mob);
            end;
            for j in Self.VisiblePlayers do
            begin
              if (Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Contains
                (mob^.ClientID)) then
              begin
                Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
                  (mob^.ClientID);
                // Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
              end;
            end;
            // ver aquele bang de tirar na lista propia
            mob^.VisibleMobs.Clear;
            mob^.IsDead := True;
            { Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
              ('Adquiriu ' + AnsiString(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid]
              .MobExp.ToString) + ' + ' +
              AnsiString((Servers[Self.ChannelId].Players[Self.ClientId]
              .AddExp(Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp,
              EXP_TYPE_MOB) - Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobExp)
              .ToString) + ' exp.', 0); }
            Self.MobKilled(mob, DropExp, DropItem, false);
            Packet.MobAnimation := 30;
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end
          else
          begin
            deccardinal(MobsP^.HP, Packet.Dano);
            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
          end;

          // Sleep(1);
          Exit;
        end;
      end;
    end
    else if (mob^.ClientID >= 9148) then
    begin
      // Servers[Self.ChannelId].PETS[mob.ClientID].IsAttacked := True;
      // Servers[Self.ChannelId].PETS[mob.ClientID].AttackerID := Self.ClientID;
      if (Packet.Dano >= mob.PlayerCharacter.Base.CurrentScore.CurHP) then
      begin
        mob.PlayerCharacter.Base.CurrentScore.CurHP := 0;
        Packet.MobAnimation := 30;
        mob.IsDead := True;
        { for j in mob.VisibleMobs do
          begin
          if not(j >= 3048) then
          begin
          Servers[Self.ChannelId].Players[j].UnSpawnPet(mob.ClientID);
          end;
          end; }

        // if(Servers[Self.ChannelId].PETS[mob.ClientID].IntName > 0) then
        // begin
        // if(Servers[Self.ChannelId].PETS[mob.ClientID].Base.IsActive) then
        // Servers[Self.ChannelId].Players[Self.ClientID].Base.DestroyPet(
        // mob.ClientID);
        // end;
        // Servers[Self.ChannelId].PETS[mob.ClientID].Base.Destroy;
        // ZeroMemory(@Servers[Self.ChannelId].PETS[mob.ClientID], sizeof(TPet));
      end
      else
      begin
        deccardinal(mob.PlayerCharacter.Base.CurrentScore.CurHP, Packet.Dano);
        // :=
        // mob.PlayerCharacter.Base.CurrentScore.CurHP - Packet.Dano;
      end;
      mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob.PlayerCharacter.Base.CurrentScore.CurHP;
      // Self.SendCurrentHPMP;
      Self.SendToVisible(Packet, Packet.Header.size);
      // Sleep(1);
      Exit;
    end;
  end;
  if (DataSkill^.SuccessRate = 0) then
  begin
    if (DataSkill^.range = 0) then
    begin // skills de buff single[Self div Target]
      Packet.DnType := TDamageType.None;
      Packet.Dano := 0;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;

      if (Self.IsCompleteEffect5(Helper2)) then
      begin
        Randomize;
        Rand := RandomRange(1, 101);
        if (Rand <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
        begin
          Self.Effect5Skill(@Self, Helper2, True);
        end;
      end;

      if (DataSkill^.TargetType = 1) then
      begin // [Self]
        // Self.SendCurrentHPMP;
        Self.SendToVisible(Packet, Packet.Header.size);
        Self.SelfBuffSkill(Skill, Anim, mob, SelectedPos);
      end
      else
      begin // [Target]
        // Self.SendCurrentHPMP;
        if (DataSkill^.Classe >= 61) and (DataSkill^.Classe <= 84) then
        begin // skills de pran
          case SelfPlayer^.Account.Header.Pran1.ClassPran of
            61:
              begin
                SelfPlayer^.SendClientMessage('Pran modo fada!', 16, 0, 0);
                Exit;
              end;
            71, 81:
              begin
                Exit;
              end;
          end;

          case SelfPlayer^.SpawnedPran of
            0:
              begin
                Packet.AttackerPos := SelfPlayer^.Account.Header.Pran1.Position;
                Packet.AttackerID := SelfPlayer^.Account.Header.Pran1.id;
                Packet.TargetID := Self.ClientID;
                if (Self.BuffExistsByID(6454) or Self.BuffExistsByID(6455) or
                  Self.BuffExistsByID(6456) or Self.BuffExistsByID(6457) or
                  Self.BuffExistsByID(6458)) then
                begin
                  SelfPlayer^.SendClientMessage
                    ('Pran se recusou por conta do nível de caos');
                  Exit;
                end;

                Randomize;
                Rand := RandomRange(1, 225);
                if (Rand > SelfPlayer^.Account.Header.Pran1.Devotion) then
                begin
                  SelfPlayer^.SendClientMessage
                    ('Pran se recusou por conta da familiaridade.');
                  Self.SendToVisible(Packet, Packet.Header.size);
                  Exit;
                end;
              end;
            1:
              begin
                Packet.AttackerPos := SelfPlayer^.Account.Header.Pran2.Position;
                Packet.AttackerID := SelfPlayer^.Account.Header.Pran2.id;
                Packet.TargetID := Self.ClientID;
                Randomize;
                Rand := RandomRange(1, 225);
                if (Rand > SelfPlayer^.Account.Header.Pran2.Devotion) then
                begin
                  SelfPlayer^.SendClientMessage
                    ('Pran se recusou por conta da familiaridade.');
                  Self.SendToVisible(Packet, Packet.Header.size);
                  Exit;
                end;
              end;
          end;
        end;
        Self.SendToVisible(Packet, Packet.Header.size);
        Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
      end;
    end
    else if (DataSkill^.range > 0) then
    begin // skills de buff em area [ou em party]
      if (Self.IsCompleteEffect5(Helper2)) then
      begin
        Randomize;
        Rand := RandomRange(1, 101);
        if (Rand <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
        begin
          Self.Effect5Skill(@Self, Helper2, True);
        end;
      end;

      Packet.DnType := TDamageType.None;
      Packet.Dano := 0;
      Packet.MobCurrHP := mob.Character.CurrentScore.CurHP;
      Packet.DeathPos := SelectedPos;
      Packet.TargetID := Self.ClientID;
      Self.SendToVisible(Packet, Packet.Header.size);
      Self.AreaBuff(Skill, Anim, mob, Packet);
    end;
    Exit;
  end;

end;

function TBaseNpc.ValidAttack(DmgType: TDamageType; DebuffType: Byte;
  mob: PBaseNpc; AuxDano: Integer; xisBoss: Boolean): Boolean;
var
  Rate: Integer;
  Rand: Integer;
  VerifyToCastle: Boolean;
begin
  Result := false;
  VerifyToCastle := false;

  case DmgType of
    Normal, Critical, Double, DoubleCritical:
      Result := True;
    Miss:
      Exit;
  end;

  if (mob = nil) then
    Exit;

  if (mob^.ClientID >= 3048) or (mob^.IsDungeonMob) then
  begin
    if (mob.IsBoss and not xisBoss) then
      Exit;
  end;

  if not(Result) then
    Exit;

  if (AuxDano > 0) and (mob^.BuffExistsByIndex(36)) then
    Exit(false);

  if (AuxDano <= 0) and (mob^.BuffExistsByIndex(36)) then
  begin
    // dec(mob^.BolhaPoints, 1);
    mob^.BolhaPoints := mob^.BolhaPoints - 1;
    if (mob^.BolhaPoints = 0) then
    begin
      mob^.RemoveBuffByIndex(36);
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao de ataque de [' + AnsiString(Self.Character.Name) +
        '] Proteção desativada.', 16, 1, 1);
    end
    else
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) +
        '] resistiu à sua habilidade de ataque.', 16, 1, 1);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você resistiu ao ataque de [' + AnsiString(Self.Character.Name) +
        '] restam ' + mob.BolhaPoints.ToString + ' ticks.', 16, 1, 1);
    end;
    Exit(false);
  end;

  if (DebuffType = 0) then
    Exit;

  Randomize;
  Rand := RandomRange(1, 255);
  Rate := Trunc(Self.PlayerCharacter.Resistence / 5) +
    Self.GetMobAbility(EF_STATE_RESISTANCE);

  case DebuffType of
    STUN_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_STUN);
        if (Rand <= Rate) then
        begin
          Result := false;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de stun.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de stun de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
          VerifyToCastle := True;
      end;
    SILENCE_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_SILENCE1);
        if (Rand <= Rate) then
        begin
          Result := false;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de silêncio.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de silêncio de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
          VerifyToCastle := True;
      end;
    FEAR_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_FEAR);
        if (Rand <= Rate) then
        begin
          Result := false;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de medo.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de medo de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
          VerifyToCastle := True;
      end;
    LENT_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_RUNSPEED);
        if (Rand <= Rate) then
        begin
          Result := false;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de lentidão.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de lentidão de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
          VerifyToCastle := True;
      end;
    CHOCK_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_SHOCK);
        if (Rand <= Rate) then
        begin
          Result := false;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de choque.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de choque de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
          VerifyToCastle := True;
      end;
    PARALISYS_TYPE:
      begin
        Rate := Rate + mob^.GetMobAbility(EF_IM_SKILL_IMMOVABLE);
        if (Rand <= Rate) then
        begin
          Result := false;
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('[' + AnsiString(mob^.Character.Name) +
            '] resistiu à sua habilidade de paralisia.');
          Servers[mob^.ChannelId].Players[mob^.ClientID].SendClientMessage
            ('Você resistiu à habilidade de paralisia de [' +
            AnsiString(Self.Character.Name) + '].');
        end
        else
          VerifyToCastle := True;
      end;
  end;

  if VerifyToCastle and mob^.InClastleVerus then
    mob^.LastReceivedSkillFromCastle := Now;
end;

procedure TBaseNpc.MobKilledInDungeon(mob: PBaseNpc);
var
  MobExp, ExpAcquired, NIndex, Helper: Integer;
  i, RandomClientID, j, k: WORD;
begin
  ExpAcquired := 0;
  MobExp := DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
    .DungeonInstanceID].MOBS[mob.Mobid].MobExp;

  for i in Servers[Self.ChannelId].Players[Self.ClientID].Party.Members do
  begin
    if Servers[Self.ChannelId].Players[Self.ClientID].Party.ExpAlocate = 1 then
    begin
      MobExp := MobExp div Servers[Self.ChannelId].Players[Self.ClientID]
        .Party.Members.Count;
      ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp, Helper,
        EXP_TYPE_MOB);
    end
    else if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Party.ExpAlocate = 2) and
      (i = DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
      .DungeonInstanceID].MOBS[mob.Mobid].FirstPlayerAttacker) then
    begin
      ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp, Helper,
        EXP_TYPE_MOB);
    end;

    case Servers[Self.ChannelId].Players[Self.ClientID].Party.ItemAlocate of
      1:
        begin
          NIndex := Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.LastSlotItemReceived;
          if i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader
          then
          begin
            Self.DropItemFor(@Servers[Self.ChannelId].Players
              [Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.Members.ToArray[NIndex]].Base, mob);
            Inc(Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.LastSlotItemReceived);
            if Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.LastSlotItemReceived >= Servers[Self.ChannelId].Players
              [Self.ClientID].Party.Members.Count then
              Servers[Self.ChannelId].Players[Self.ClientID]
                .Party.LastSlotItemReceived := 0;
          end;
        end;
      2:
        if i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader then
        begin
          Randomize;
          RandomClientID := Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.Members.ToArray
            [RandomRange(0, Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.Members.Count)];
          Self.DropItemFor(@Servers[Self.ChannelId].Players[RandomClientID]
            .Base, mob);
        end;
      3:
        if i = DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].FirstPlayerAttacker then
        begin
          Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
        end;
      4:
        if i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader then
        begin
          Self.DropItemFor(@Servers[Self.ChannelId].Players[i].Base, mob);
        end;
    end;

    if ExpAcquired > 0 then
    begin
      Servers[Self.ChannelId].Players[i].SendClientMessage
        ('Adquiriu ' + AnsiString(IntToStr(ExpAcquired)) + ' exp.', 0);
      if Servers[Self.ChannelId].Players[i].SpawnedPran <> 255 then
      begin
        Servers[Self.ChannelId].Players[i].SendClientMessage
          ('Voc� e sua pran n�o podem adquirir experi�ncia em calabou�os. ', 0);
      end;
    end;

    for j := 0 to 49 do
    begin
      if Servers[Self.ChannelId].Players[i].PlayerQuests[j].id > 0 then
      begin
        if not Servers[Self.ChannelId].Players[i].PlayerQuests[j].IsDone then
        begin
          for k := 0 to 4 do
          begin
            if (Servers[Self.ChannelId].Players[i].PlayerQuests[j]
              .Quest.RequirimentsType[k] = 1) and
              (Servers[Self.ChannelId].Players[i].PlayerQuests[j]
              .Quest.Requiriments[k] = DungeonInstances
              [Servers[Self.ChannelId].Players[i].DungeonInstanceID].MOBS
              [mob.Mobid].IntName) then
            begin
              Inc(Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                .Complete[k]);
              if Servers[Self.ChannelId].Players[i].PlayerQuests[j].Complete[k]
                >= Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                .Quest.RequirimentsAmount[k] then
              begin
                Servers[Self.ChannelId].Players[i].PlayerQuests[j].Complete[k]
                  := Servers[Self.ChannelId].Players[i].PlayerQuests[j]
                  .Quest.RequirimentsAmount[k];
                Servers[Self.ChannelId].Players[i].SendClientMessage
                  ('Voc� completou a quest [' +
                  AnsiString(Quests[Servers[Self.ChannelId].Players[i]
                  .PlayerQuests[j].Quest.QuestID].Titulo) + ']');
              end;
              Servers[Self.ChannelId].Players[i].UpdateQuest
                (Servers[Self.ChannelId].Players[i].PlayerQuests[j].id);
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TBaseNpc.MobKilled(mob: PBaseNpc; out DroppedExp: Boolean;
  out DroppedItem: Boolean; InParty: Boolean);
var
  i, j: Integer;
  ExpAcquired, PranExpAcquired: Int64;
  MobExp, CalcAux, CalcAuxRlq: Integer;
  DropExp, DropItem: Boolean;
  A, HelperX { B } : Integer;
  NIndex: WORD;
  // ClientIDReceiveItem: WORD;
  RandomClientID: Integer;
  // ItemReceived: Boolean;
  SelfPlayer, OtherPlayer: PPlayer;
  MobsP: PMobSPoisition;
begin // aqui ser� a fun��o que verificar� quest e dar� drop/exp
  ExpAcquired := 0;
  PranExpAcquired := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  if (mob^.ClientID > MAX_CONNECTIONS) then
  begin
    if (mob^.ClientID >= 3048) and (mob^.ClientID <= 9147) then
      MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
        [mob^.SecondIndex]
    else
      Exit;
  end
  else
    Exit;

  if (SelfPlayer^.PartyIndex <> 0) and (InParty = false) then
  begin
    A := 0;
    for i in SelfPlayer^.Party.Members do
    begin
      DropExp := false;
      DropItem := false;
      // Servers[Self.ChannelId].Players[i].Base.MobKilled(mob, DropExp, DropItem, True);
      if DropExp then
        Inc(A);
    end;
    if (A = 0) and (MobsP^.FirstPlayerAttacker <> 0) and
      (MobsP^.FirstPlayerAttacker <> Self.ClientID) then
    begin
      DropExp := false;
      DropItem := false;
      // Servers[Self.ChannelId].Players[MobsP^.FirstPlayerAttacker].Base.MobKilled(mob, DropExp, DropItem, False);
    end;
    Exit;
  end;

  if (TItemFunctions.GetEmptySlot(SelfPlayer^) = 255) then
  begin
    SelfPlayer.SendClientMessage
      ('Seu invent�rio est� cheio. Recompensas n�o ser�o recebidas.');
    // Exit; //verificar isso -- 15/12 talvez continuando, ele dê algum bug na hora de efetuar as outras ações de dar item
  end;

  if (SelfPlayer^.InDungeon) or (not SelfPlayer^.InDungeon) then
  begin
    HelperX := (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobLevel -
      Self.Character.Level);
    case HelperX of
      - 255 .. -8:
        MobExp := IfThen(SelfPlayer^.InDungeon,
          Round(Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobExp *
          0.1), 1);
      -7 .. -3:
        MobExp := Round(Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid]
          .MobExp * 0.5);
      -2 .. 2:
        MobExp := Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobExp;
      3 .. 5:
        MobExp := Round(Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid]
          .MobExp * 1.5);
      6 .. 255:
        MobExp := Round(Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid]
          .MobExp * 0.2);
    else
      MobExp := Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobExp;
    end;
  end;

  if not SelfPlayer^.InDungeon and (MobExp <> 1) then
    MobExp := MobExp * 4;

  if (Self.Character <> nil) and
    (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    MobExp := MobExp + ((MobExp div 100) * Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_PER_EXP]);

  try
    if (InParty) then
    begin
      if not(MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 25)) then
        Exit;
      case SelfPlayer^.Party.ExpAlocate of
        1: // igualmente
          begin
            j := 0;
            for i in SelfPlayer^.Party.Members do
            begin
              if (Self.PlayerCharacter.LastPos.Distance(Servers[Self.ChannelId]
                .Players[i].Base.PlayerCharacter.LastPos) <= DISTANCE_TO_WATCH)
              then
              begin
                j := j + 1;
              end;
            end;

            j := Max(j, 1);
            MobExp := Max(MobExp div j, 1);
            ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
            DroppedExp := True;
          end;
        2: // individualmente
          begin
            if (SelfPlayer^.InDungeon) then
            begin
              if (Self.ClientID = DungeonInstances
                [Servers[Self.ChannelId].Players[Self.ClientID]
                .DungeonInstanceID].MOBS[mob.Mobid].FirstPlayerAttacker) then
              begin
                ExpAcquired := Servers[Self.ChannelId].Players[Self.ClientID]
                  .AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
                DroppedExp := True;
              end;
            end
            else if (MobsP^.FirstPlayerAttacker = 0) or
              (Self.ClientID = MobsP^.FirstPlayerAttacker) then
            begin
              ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq,
                EXP_TYPE_MOB);
              DroppedExp := True;
            end;
          end;
      end;

      if (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].InitHP > 999999) then
      begin
        for i in Servers[mob^.ChannelId].Players[Self.ClientID].Party.Members do
        begin
          Randomize;
          if (RandomRange(0, 2) = 1) then
          begin
            DroppedItem := True;
            Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
          end;
        end;

        for i := 1 to 3 do
        begin
          if (Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied
            [i] = 0) then
            continue;
          for j in Servers[mob^.ChannelId].Parties
            [Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied[i]
            ].Members do
          begin
            Randomize;
            if (RandomRange(0, 2) = 1) then
            begin
              DroppedItem := True;
              Self.DropItemFor(@Servers[mob^.ChannelId].Players[j].Base, mob);
            end;
          end;
        end;
      end
      else
      begin
        case SelfPlayer^.Party.ItemAlocate of
          1: // em ordem
            begin
              NIndex := SelfPlayer^.Party.LastSlotItemReceived;
              if (SelfPlayer^.Party.Members.ToArray[NIndex] = Self.ClientID)
              then
              begin
                Inc(SelfPlayer^.Party.LastSlotItemReceived);
                DroppedItem := True;
                Self.DropItemFor(@Self, mob);
                if (NIndex >= (SelfPlayer^.Party.Members.Count - 1)) then
                  SelfPlayer^.Party.LastSlotItemReceived := 0;
              end;
            end;
          2: // aleatorio
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                Randomize;
                RandomClientID := SelfPlayer^.Party.Members.ToArray
                  [RandomRange(0, SelfPlayer^.Party.Members.Count)];
                DroppedItem := True;
                Self.DropItemFor(@Servers[Self.ChannelId].Players
                  [RandomClientID].Base, mob);
              end;
            end;
          3: // individual
            begin
              if (SelfPlayer^.InDungeon) then
              begin
                if (Self.ClientID = DungeonInstances
                  [Servers[Self.ChannelId].Players[Self.ClientID]
                  .DungeonInstanceID].MOBS[mob.Mobid].FirstPlayerAttacker) then
                begin
                  Self.DropItemFor(@Self, mob);
                  DroppedItem := True;
                end;
              end
              else if (Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
                [mob.SecondIndex].FirstPlayerAttacker > 0) and
                (Servers[Self.ChannelId].Players
                [Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
                [mob.SecondIndex].FirstPlayerAttacker].Status >= Playing) and
                not(Servers[Self.ChannelId].Players
                [Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
                [mob.SecondIndex].FirstPlayerAttacker].SocketClosed) then
              begin
                Self.DropItemFor(@Self, mob);
                DroppedItem := True;
              end;
            end;
          4: // lider
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                Self.DropItemFor(@Self, mob);
                DroppedItem := True;
              end;
            end;
        end;
      end;
    end
    else // não está em grupo
    begin
      ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
      Self.DropItemFor(@Self, mob);
    end;
  except
    Logger.Write('erro na entrega em grupo de xp / solo', TLogType.Error);
  end;

  try
    if not(ExpAcquired = 0) then
    begin
      try
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              case SelfPlayer^.Account.Header.Pran1.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 3 do
                        SelfPlayer^.AddPranLevel(0);
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                  end;
                4: // pran fada ~ pran criança
                  begin
                    if (SelfPlayer^.Account.Header.Pran1.ClassPran
                      in [61, 71, 81]) then
                    begin
                      SelfPlayer^.SendClientMessage
                        ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                      PranExpAcquired := 0;
                    end
                    else
                    begin
                      PranExpAcquired := (ExpAcquired div 3);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.
                        Exp) > PranExpList[20]) then
                      begin
                        SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                        for i := SelfPlayer^.Account.Header.Pran1.Level to 18 do
                          SelfPlayer^.AddPranLevel(0);
                      end
                      else
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    end;
                  end;
                5 .. 18: // pran criança
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 18 do
                        SelfPlayer^.AddPranLevel(0);
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                  end;
                19: // pran criança ~ pran adolescente
                  begin
                    if (SelfPlayer^.Account.Header.Pran1.ClassPran
                      in [62, 72, 82]) then
                    begin
                      SelfPlayer^.SendClientMessage
                        ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                      PranExpAcquired := 0;
                    end
                    else
                    begin
                      PranExpAcquired := (ExpAcquired div 3);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.
                        Exp) > PranExpList[50]) then
                      begin
                        SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[49];
                        for i := SelfPlayer^.Account.Header.Pran1.Level to 48 do
                          SelfPlayer^.AddPranLevel(0);
                      end
                      else
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran1.Level to 48 do
                        SelfPlayer^.AddPranLevel(0);
                    end
                    else
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                  end;
                49: // pran adolescente ~ pran adulta
                  begin
                    if (SelfPlayer^.Account.Header.Pran1.ClassPran
                      in [63, 73, 83]) then
                    begin
                      SelfPlayer^.SendClientMessage
                        ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                      PranExpAcquired := 0;
                    end
                    else
                    begin
                      PranExpAcquired := (ExpAcquired div 3);
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(0, PranExpAcquired);
                  end;
              end;
            end;
          1:
            begin
              case SelfPlayer^.Account.Header.Pran2.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[4];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 3 do
                        SelfPlayer^.AddPranLevel(1);
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                  end;
                4: // pran fada ~ pran criança
                  begin
                    if (SelfPlayer^.Account.Header.Pran2.ClassPran
                      in [61, 71, 81]) then
                    begin
                      SelfPlayer^.SendClientMessage
                        ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                      PranExpAcquired := 0;
                    end
                    else
                    begin
                      PranExpAcquired := (ExpAcquired div 3);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.
                        Exp) > PranExpList[20]) then
                      begin
                        SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                        for i := SelfPlayer^.Account.Header.Pran2.Level to 18 do
                          SelfPlayer^.AddPranLevel(1);
                      end
                      else
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    end;
                  end;
                5 .. 18: // pran criança
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 18 do
                        SelfPlayer^.AddPranLevel(1);
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                  end;
                19: // pran criança ~ pran adolescente
                  begin
                    if (SelfPlayer^.Account.Header.Pran2.ClassPran
                      in [62, 72, 82]) then
                    begin
                      SelfPlayer^.SendClientMessage
                        ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                    end
                    else
                    begin
                      PranExpAcquired := (ExpAcquired div 3);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.
                        Exp) > PranExpList[50]) then
                      begin
                        SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                        for i := SelfPlayer^.Account.Header.Pran2.Level to 48 do
                          SelfPlayer^.AddPranLevel(1);
                      end
                      else
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                      for i := SelfPlayer^.Account.Header.Pran2.Level to 48 do
                        SelfPlayer^.AddPranLevel(1);
                    end
                    else
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                  end;
                49: // pran adolescente ~ pran adulta
                  begin
                    if (SelfPlayer^.Account.Header.Pran2.ClassPran
                      in [63, 73, 83]) then
                    begin
                      SelfPlayer^.SendClientMessage
                        ('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                      PranExpAcquired := 0;
                    end
                    else
                    begin
                      PranExpAcquired := (ExpAcquired div 3);
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 3);
                    SelfPlayer^.AddPranExp(1, PranExpAcquired);
                  end;
              end;
            end;
        end;
      except
        on E: Exception do
          SelfPlayer^.SendClientMessage(E.Message, 0, 1);
      end;
    end;
  except
    on E: Exception do
      SelfPlayer^.SendClientMessage(E.Message, 0, 1);
  end;

  try
    for i := 0 to 49 do
      if (SelfPlayer^.PlayerQuests[i].id > 0) and
        not(SelfPlayer^.PlayerQuests[i].IsDone) then
        for j := 0 to 4 do
          if (SelfPlayer^.PlayerQuests[i].Quest.RequirimentsType[j] = 1) and
            (SelfPlayer^.PlayerQuests[i].Quest.Requiriments[j] = Servers
            [mob^.ChannelId].MOBS.TMobS[mob^.Mobid].IntName) then
          begin
            Inc(SelfPlayer^.PlayerQuests[i].Complete[j]);
            if (SelfPlayer^.PlayerQuests[i].Complete[j] >=
              SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j]) then
            begin
              SelfPlayer^.PlayerQuests[i].Complete[j] :=
                SelfPlayer^.PlayerQuests[i].Quest.RequirimentsAmount[j];
              SelfPlayer^.SendClientMessage('Voc� completou a quest [' +
                AnsiString(Quests[SelfPlayer^.PlayerQuests[i].Quest.QuestID]
                .Titulo) + ']');
            end;
            SelfPlayer^.UpdateQuest(SelfPlayer^.PlayerQuests[i].id);
          end;
  except
    Logger.Write('erro na contagem da quest pra atualizar', TLogType.Error);
  end;

end;

procedure TBaseNpc.DropItemFor(PlayerBase: PBaseNpc; mob: PBaseNpc);
var
  DropTax, ReceiveFrom, ItemTypeFrom, ItemTax, MaxLen, RandomItem, Helper,
    ItemID, cnt, i, j, k: Integer;
  OtherPlayer: PPlayer;
  MobT: PMobSa;
  ItemName: string;
label
  ReCase,
  ReCase1;
begin
  if Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid].MobsP[mob.SecondIndex].isGuard
  then
    Exit;

  Randomize;
  ItemTypeFrom := DROP_NORMAL_ITEM;
  ItemID := 0;
  MaxLen := 0;
  ReceiveFrom := 0;
  DropTax := RandomRange(1, 101);
  OtherPlayer := @Servers[PlayerBase.ChannelId].Players[PlayerBase.ClientID];
  MobT := @Servers[mob.ChannelId].MOBS.TMobS[mob.Mobid];

  if Self.Character <> nil then
  begin
    if Servers[Self.ChannelId].NationID = Self.Character.Nation then
      Inc(DropTax, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DROP_RATE] *
        (DropTax div 100));

    Inc(DropTax, Self.GetMobAbility(EF_PARTY_PER_DROP_RATE) div 2);

    Inc(Self.DroppedCount);
    if DroppedCount >= 4 then
    begin
      Inc(DropTax, 50);
      DroppedCount := 0;
    end;
  end;

  if DropTax > 70 then
  begin
    case MobT^.MobLevel of
      0 .. 20:
        ReceiveFrom := MONSTERS_0_20;
      21 .. 40:
        ReceiveFrom := MONSTERS_21_40;
      41 .. 60, 256 .. 65535:
        if (MobT^.IntName >= 1373) and (MobT^.IntName <= 1378) then
          case MobT^.IntName of
            1373:
              ReceiveFrom := MONSTERS_PLANTA;
            1374:
              ReceiveFrom := MONSTERS_CROSHU_AZUL;
            1375:
              ReceiveFrom := MONSTERS_BUTO;
            1376:
              ReceiveFrom := MONSTERS_CROSHU_VERM;
            1377:
              ReceiveFrom := MONSTERS_PENZA;
            1378:
              ReceiveFrom := MONSTERS_VERIT;
          end
        else
          ReceiveFrom := MONSTERS_41_60;
      61 .. 80:
        ReceiveFrom := MONSTERS_61_80;
      81 .. 255:
        ReceiveFrom := MONSTERS_81_99;
    end;

    ItemTax := RandomRange(1, 101);
    if (Self.Character <> nil) and
      (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      dec(ItemTax, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DROP_RATE]);
    if ItemTax = 0 then
      ItemTax := 2;

    case ItemTax of
      1:
        ItemTypeFrom := DROP_LEGENDARY_ITEM;
      2 .. 13:
        ItemTypeFrom := DROP_RARE_ITEM;
      14 .. 33:
        ItemTypeFrom := DROP_SUPERIOR_ITEM;
      34 .. 255:
        ItemTypeFrom := DROP_NORMAL_ITEM;
    end;

    if MaxLen = 0 then
    begin
      ItemTypeFrom := DROP_NORMAL_ITEM;
      MaxLen := High(Drops[MobT^.DropIndex].NormalItems);
    end;

    if Length(Drops[MobT^.DropIndex].NormalItems) > 0 then
    begin
      RandomItem := RandomRange(0,
        High(Drops[MobT^.DropIndex].NormalItems) + 1);
      ItemID := Drops[MobT^.DropIndex].NormalItems[RandomItem];
    end;

    ItemName := String(ItemList[ItemID].Name);
    Logger.Write('O jogador ' + String(PlayerBase.Character.Name) +
      ' recebeu o item: ' + ItemName + ' ' +
      FormatDateTime('dd-mm-yyyy hh:nn:ss', Now), TLogType.Itens);

    if ItemList[ItemID].ItemType = 713 then
    begin
      for k := Low(Servers) to High(Servers) do
      begin
        for i := 0 to 4 do
          for j := 0 to 4 do
            if (Servers[k].Devires[i].Slots[j].ItemID <> 0) and
              (ItemList[Servers[k].Devires[i].Slots[j].ItemID]
              .UseEffect = ItemList[ItemID].UseEffect) then
              Exit;

        for i := Low(Servers[k].OBJ) to High(Servers[k].OBJ) do
          if (Servers[k].OBJ[i].ContentItemID <> 0) and
            (ItemList[Servers[k].OBJ[i].ContentItemID].UseEffect = ItemList
            [ItemID].UseEffect) then
            Exit;

        for i := Low(Servers[k].Players) to High(Servers[k].Players) do
          if (Servers[k].Players[i].Status >= Playing) then
            for j := 0 to 119 do
              if (Servers[k].Players[i].Base.Character.Inventory[j].
                Index = ItemID) or
                ((ItemList[Servers[k].Players[i].Base.Character.Inventory[j].
                Index].ItemType = 40) and
                (ItemList[Servers[k].Players[i].Base.Character.Inventory[j].
                Index].UseEffect = ItemList[ItemID].UseEffect)) then
                Exit;

        Helper := TItemFunctions.GetItemSlotByItemType(Servers[k].Players[i],
          40, INV_TYPE, 0);
        if (Helper <> 255) and
          (ItemList[Servers[k].Players[i].Base.Character.Inventory[Helper].
          Index].UseEffect = ItemList[ItemID].UseEffect) then
          Exit;
      end;

      Servers[Self.ChannelId].SendServerMsg('Jogador <' + Self.Character.Name +
        '> encontrou o [' + ItemList[ItemID].Name + '].', 32, 0, 16);
    end;

    if TItemFunctions.GetItemEquipSlot(ItemID) = 0 then
      TItemFunctions.PutItem(OtherPlayer^, ItemID, 1)
    else
      TItemFunctions.PutEquipament(OtherPlayer^, ItemID);
  end;
end;

procedure Pontuar(Player: TPlayer);
var
  QueryString: string;
  PlayerSQLComp: TQuery;
begin
  PlayerSQLComp := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
    AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
    AnsiString(MYSQL_DATABASE));
  try
    with PlayerSQLComp do
    begin
      SetQuery('UPDATE elter SET kills = kills + 1 WHERE nome_antigo = ''' +
        Player.Base.Character.Name + '''');
      Query.Connection.StartTransaction;
      Query.ExecSQL;
      Query.Connection.Commit;
    end;
  finally
    PlayerSQLComp.Free;
  end;
end;

procedure TBaseNpc.PlayerKilled(mob: PBaseNpc; xRlkSlot: Byte = 0);
var
  i, j, k: Integer;
  Party: PParty;
  Honor: Integer;
  GuildPlayer: PPlayer;
  RandomTax: Integer;
  RlkSlot: Byte;
  Item: PItem;
  TitleGoaled: Boolean;
  Player: TPlayer;
  mensagem1, mensagem2, mensagem3, QueryString1: string;
  PlayerSQLComp1: TQuery;
begin

  for i := Low(Servers) to High(Servers) do
    Servers[i].SendServerMsg('PvP: ' + Servers[Self.ChannelId].Players
      [Self.ClientID].Base.Character.Name + ' sabugou ' +
      Servers[Self.ChannelId].Players[mob^.ClientID]
      .Base.Character.Name, 0, 0, 0);

  if (xRlkSlot = 0) then
    RlkSlot := TItemFunctions.GetItemSlotByItemType
      (Servers[Self.ChannelId].Players[mob^.ClientID], 40, INV_TYPE, 0)
  else
    RlkSlot := xRlkSlot;

  if (RlkSlot <> 255) then
  begin
    Item := @mob^.Character.Inventory[RlkSlot];
    Servers[Self.ChannelId].CreateMapObject(@Servers[Self.ChannelId].Players
      [Self.ClientID], 320, Item.Index);

    var
    CityID := Servers[Self.ChannelId].Players[mob^.ClientID].GetCurrentCityID;
    var
    Channel_ID := Servers[Self.ChannelId].Players[mob^.ClientID].ChannelIndex;

    if (CityID >= Low(MapNames)) and (CityID <= High(MapNames)) then
    begin
      var
      CityName := MapNames[CityID];

      if (ChannelId >= Low(Nacoes)) and (ChannelId <= High(Nacoes)) then
      begin
        var
        NationName := Nacoes[Channel_ID];

        // Verifica se o nome do mapa não está vazio
        if (CityName <> '') then
          mensagem3 := '[Mapa]: ' + CityName + ' [Nação]: ' + NationName;
      end;
    end
    else
      mensagem3 := '';

    mensagem1 := 'O jogador ' + AnsiString(mob^.Character.Name) +
      ' dropou a relíquia:';
    mensagem2 := '<' + AnsiString(ItemList[Item.Index].Name) + '>.';

    Servers[Self.ChannelId].SendServerMsg(mensagem1, 16, 32, 16);
    Servers[Self.ChannelId].SendServerMsg(mensagem2, 16, 32, 16);
    Servers[Self.ChannelId].SendServerMsg(mensagem3, 16, 32, 16);

    ZeroMemory(Item, SizeOf(TItem));
    mob.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, false);

    RlkSlot := TItemFunctions.GetItemSlotByItemType
      (Servers[Self.ChannelId].Players[mob^.ClientID], 40, INV_TYPE, 0);

    if (RlkSlot <> 255) then
    begin
      Self.PlayerKilled(mob, RlkSlot);
      // loopzin pra dropar todas as relíquias que tiver
      Exit;
    end;

    Servers[Self.ChannelId].Players[mob^.ClientID].SendEffect(0);
  end;

  if (Self.BuffExistsByID(MARECHAL_BUFF) or Self.BuffExistsByID(ARCHON_BUFF) or
    Self.BuffExistsByID(CAVALEIROS_MARECHAL) or
    Self.BuffExistsByID(CAVALEIROS_ARCHON)) and
    (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation > 0)
    and (Self.Character.Nation > 0) and
    (Servers[Self.ChannelId].Players[mob^.ClientID]
    .Base.Character.Nation = Self.Character.Nation) and
    not Self.InClastleVerus and (Player.Waiting1 = 0) then
  begin
    if SecondsBetween(Now, Servers[Self.ChannelId].Players[mob^.ClientID]
      .LastAttackSent) > 30 then
      Inc(Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.Character.CurrentScore.Infamia, 1);
  end;

  if not(Self.BuffExistsByID(MARECHAL_BUFF) or Self.BuffExistsByID(ARCHON_BUFF)
    or Self.BuffExistsByID(CAVALEIROS_MARECHAL) or
    Self.BuffExistsByID(CAVALEIROS_ARCHON)) or
    (Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.CurrentScore.
    Infamia >= 3) then
  begin
    if (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation >
      0) and (Self.Character.Nation > 0) and
      (Servers[Self.ChannelId].Players[mob^.ClientID]
      .Base.Character.Nation = Self.Character.Nation) and
      not Self.InClastleVerus and (Player.Waiting1 = 0) then
    begin
      var
        DiffInSeconds: Integer;
      DiffInSeconds := SecondsBetween(Now, Servers[Self.ChannelId].Players
        [mob^.ClientID].LastAttackSent);
      if DiffInSeconds <= 30 then
        Exit;

      for var BuffID in [6454, 6455, 6456, 6457, 6458] do
      begin
        if Self.BuffExistsByID(BuffID) then
        begin
          var
            NextBuffID: Integer;
            case BuffID of 6454: NextBuffID := 6455;
            6455: NextBuffID := 6456;
            6456: NextBuffID := 6457;
            6457: NextBuffID := 6458;
            6458: NextBuffID := 6458;
        else
          NextBuffID := BuffID;
      end;

      Self.RemoveBuffByIndex(BuffID);
      Self.AddBuff(NextBuffID, True, false, IfThen(BuffID = 6454, 1200,
        IfThen(BuffID = 6455, 1200, IfThen(BuffID = 6456, 1800,
        IfThen(BuffID = 6457, 2400, 3000)))));

      Inc(Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.Character.CurrentScore.Infamia, 1);

      var
        HonorReduction: Integer;
        case BuffID of 6454: HonorReduction := 250;
        6455: HonorReduction := 350;
        6456: HonorReduction := 450;
        6457: HonorReduction := 500;
        6458: HonorReduction := 1000;
    else
      HonorReduction := 0;
  end;

  if Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.CurrentScore.
    Honor >= HonorReduction then
    Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.CurrentScore.
      Honor := Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.Honor - HonorReduction
  else
    Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.CurrentScore.
      Honor := 0;

  Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
    ('Seus pontos de caos foram incrementados');
  Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
    (HonorReduction.ToString + ' de honra reduzidas');
  Self.SendRefreshKills();
  Servers[Self.ChannelId].Players[Self.ClientID].Killnation := 0;

  if BuffID = 6458 then
    Servers[Self.ChannelId].SendServerMsg('O Jogador ' + Servers[Self.ChannelId]
      .Players[Self.ClientID].Base.Character.Name + ' Atingiu nivel 4 de caos!',
      16, 16, 16);

  Exit;
end;
end;
end;
end;

if (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation = Self.
  Character.Nation) then
begin
  Exit;
end;
if (Servers[Self.ChannelId].Players[Self.ClientID].Waiting1 = 2) and
  (Servers[Self.ChannelId].Players[mob^.ClientID].Waiting1 = 2) then
begin
  // Verifica o time do jogador adversário e realiza as ações necessárias
  case Servers[Self.ChannelId].Players[mob^.ClientID].Team1 of
    4:
      begin
        Player.SendClientMessage('Pontuou para time vermelho!');
        Pontuar(Servers[Self.ChannelId].Players[Self.ClientID]);

        // Inicia a conexão com o banco de dados
        PlayerSQLComp1 := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE), True);

        try
          // Início da transação
          PlayerSQLComp1.Query.Connection.StartTransaction;
          try
            QueryString1 :=
              'UPDATE elter_vars SET kills_vermelho = kills_vermelho + 1 WHERE id = 1';
            PlayerSQLComp1.Query.sql.Text := QueryString1;
            PlayerSQLComp1.Query.ExecSQL;

            // Commit da transação
            PlayerSQLComp1.Query.Connection.Commit;
          except
            on E: Exception do
            begin
              PlayerSQLComp1.Query.Connection.Rollback;
              // Reverte em caso de erro
              Logger.Write('Erro ao atualizar kills_vermelho. Msg: ' +
                E.Message, TLogType.Error);
              raise; // Repassa a exceção
            end;
          end;

          // Mensagem de sucesso
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Parabéns, você pontuou para seu time!');

        finally
          PlayerSQLComp1.Free; // Libera os recursos
        end;
      end;

    5:
      begin
        Player.SendClientMessage('Pontuou para time azul!');
        Pontuar(Servers[Self.ChannelId].Players[Self.ClientID]);

        // Inicia a conexão com o banco de dados
        PlayerSQLComp1 := TQuery.Create(AnsiString(MYSQL_SERVER), MYSQL_PORT,
          AnsiString(MYSQL_USERNAME), AnsiString(MYSQL_PASSWORD),
          AnsiString(MYSQL_DATABASE), True);

        try
          // Início da transação
          PlayerSQLComp1.Query.Connection.StartTransaction;
          try
            QueryString1 :=
              'UPDATE elter_vars SET kills_azul = kills_azul + 1 WHERE id = 1';
            PlayerSQLComp1.Query.sql.Text := QueryString1;
            PlayerSQLComp1.Query.ExecSQL;

            // Commit da transação
            PlayerSQLComp1.Query.Connection.Commit;
          except
            on E: Exception do
            begin
              PlayerSQLComp1.Query.Connection.Rollback;
              // Reverte em caso de erro
              Logger.Write('Erro ao atualizar kills_azul. Msg: ' + E.Message,
                TLogType.Error);
              raise; // Repassa a exceção
            end;
          end;

          // Mensagem de sucesso
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Parabéns, você pontuou para seu time!');

        finally
          PlayerSQLComp1.Free; // Libera os recursos
        end;
      end;
  end;
end;

if (mob^.BuffExistsByIndex(126)) or (Self.BuffExistsByIndex(126)) then
begin
  if (mob^.BuffExistsByIndex(126)) then
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Alvo está sob Efeito Duradouro. Impossível receber PvP/Honra.')
  else
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('VocÊ está sob Efeito Duradouro. Impossível receber PvP/Honra.');
  Exit;
end;

if (PvP_Debuff_Status = 1) and (Player.Waiting1 = 0) then
begin
  if not(mob.InClastleVerus) and
    (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation <>
    Self.Character.Nation) then
    mob^.AddBuff(6471);
end;

if (mob.Character.Level < PvP_Min_Level) then
begin
  Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
    ('Você só pode receber PvP de alvos acima do Nv ' + PvP_Min_Level.ToString);
  Exit;
end;

if (Self.Character.Level < PvP_Min_Level) then
begin
  Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
    ('Você só pode receber PvP de alvos acima do Nv ' + PvP_Min_Level.ToString);
  Exit;
end;

Player := Servers[Self.ChannelId].Players[Self.ClientID];

if (Player.PartyIndex <> 0) then
begin

{$REGION EM GRUPO NÃO RAID}
  if not(Player.Party.InRaid) and
    (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation <>
    Self.Character.Nation) then
  begin
    Party := Player.Party;
    for i in Party.Members do
    begin
      if (Elter_PvP_Acquire_Group = 0) and (Player.Waiting1 <> 0) then
        Exit;

      if not(i = Self.ClientID) then
      begin
        if not(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
          InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
          continue;
      end;

      if (Player.Waiting1 <> 0) then
      begin
        if (Elter_Acquire_PvP = 0) then
          continue;

        if (Elter_Honor_Value <> 0) and
          (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
          <> Self.Character.Nation) then
        begin
          Honor := Elter_Honor_Value;
          Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
            Honor, Honor);
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
          Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
        end
        else if (Elter_Item_Perkill_Status <> 0) and
          (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
          <> Self.Character.Nation) then
        begin
          TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i],
            Elter_Item_Perkill_Item, Elter_Item_Perkill_Item_Quantidade);
        end;
      end
      else if (Servers[Self.ChannelId].Players[mob^.ClientID]
        .Base.Character.Nation <> Self.Character.Nation) then
      begin
        Honor := HONOR_PER_KILL;
        Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
          Honor, Honor);
        Servers[Self.ChannelId].Players[i].SendClientMessage
          ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
        Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();

        TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285,
          SKULL_MULTIPLIER);
      end;
    end;
  end
{$ENDREGION}
  else
  begin
{$REGION PVP RAID}
    if (Elter_PvP_Acquire_Raid = 0) and (Player.Waiting1 <> 0) then
      Exit;

    Party := Player.Party;
    for i in Party.Members do
    begin
      if not(i = Self.ClientID) then
      begin
        if not(Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
          InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
          continue;
      end;

      if (Player.Waiting1 <> 0) then
      begin
        if (Elter_PvP_Acquire_Raid = 0) then
          continue;
      end
      else
      begin
        if (Servers[Self.ChannelId].Players[mob^.ClientID]
          .Base.Character.Nation = Self.Character.Nation) then
          continue
        else
        begin
          Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
            KillPoint, 1);
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Seus pontos de PvP foram incrementados.');
        end;

        if (Player.Waiting1 <> 0) and (Elter_Honor_Value = 0) then
          continue
        else if (Player.Waiting1 <> 0) and (Elter_Honor_Value <> 0) and
          (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
          <> Self.Character.Nation) then
        begin
          Honor := Elter_Honor_Value;
          Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
            Honor, Honor);
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
          Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
        end
        else if (Player.Waiting1 = 0) and
          (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
          <> Self.Character.Nation) then
        begin
          Honor := HONOR_PER_KILL;
          Inc(Servers[Self.ChannelId].Players[i].Base.Character.CurrentScore.
            Honor, Honor);
          Servers[Self.ChannelId].Players[i].SendClientMessage
            ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
          Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
        end;

        if (Player.Waiting1 <> 0) and (Elter_Item_Perkill_Status = 0) then
          continue
        else if (Player.Waiting1 <> 0) and (Elter_Item_Perkill_Status <> 0) and
          (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
          <> Self.Character.Nation) then
        begin
          TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i],
            Elter_Item_Perkill_Item, Elter_Item_Perkill_Item_Quantidade);
        end
        else if (Player.Waiting1 = 0) and
          (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
          <> Self.Character.Nation) then
        begin
          TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285,
            SKULL_MULTIPLIER);
        end;
      end;
    end;

    for j := 1 to 3 do
    begin
      if (Player.Party.PartyAllied[j] = 0) then
        continue;

      for i in Servers[Player.ChannelIndex].Parties[Player.Party.PartyAllied[j]]
        .Members do
      begin
        if (Servers[Player.ChannelIndex].Players[i]
          .Base.PlayerCharacter.LastPos.InRange
          (Player.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
        begin
          if (Player.Waiting1 <> 0) and (Elter_PvP_Acquire_Raid = 0) then
            continue
          else
          begin
            if (Servers[Self.ChannelId].Players[mob^.ClientID]
              .Base.Character.Nation = Self.Character.Nation) then
              continue
            else
            begin
              Inc(Servers[Self.ChannelId].Players[i]
                .Base.Character.CurrentScore.KillPoint, 1);
              Servers[Self.ChannelId].Players[i].SendClientMessage
                ('Seus pontos de PvP foram incrementados.');
            end;

            if (Player.Waiting1 <> 0) and (Elter_Honor_Value = 0) then
              continue
            else if (Player.Waiting1 <> 0) and (Elter_Honor_Value <> 0) and
              (Servers[Self.ChannelId].Players[mob^.ClientID]
              .Base.Character.Nation <> Self.Character.Nation) then
            begin
              Honor := Elter_Honor_Value;
              Inc(Servers[Self.ChannelId].Players[i]
                .Base.Character.CurrentScore.Honor, Honor);
              Servers[Self.ChannelId].Players[i].SendClientMessage
                ('Adquiriu ' + AnsiString(Honor.ToString) +
                ' pontos de honra.');
              Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
            end
            else if (Player.Waiting1 = 0) and
              (Servers[Self.ChannelId].Players[mob^.ClientID]
              .Base.Character.Nation <> Self.Character.Nation) then
            begin
              Honor := HONOR_PER_KILL;
              Inc(Servers[Self.ChannelId].Players[i]
                .Base.Character.CurrentScore.Honor, Honor);
              Servers[Self.ChannelId].Players[i].SendClientMessage
                ('Adquiriu ' + AnsiString(Honor.ToString) +
                ' pontos de honra.');
              Servers[Self.ChannelId].Players[i].Base.SendRefreshKills();
            end;

            if (Player.Waiting1 <> 0) and (Elter_Item_Perkill_Status = 0) then
              continue
            else if (Player.Waiting1 <> 0) and (Elter_Item_Perkill_Status <> 0)
              and (Servers[Self.ChannelId].Players[mob^.ClientID]
              .Base.Character.Nation <> Self.Character.Nation) then
            begin
              TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i],
                Elter_Item_Perkill_Item, Elter_Item_Perkill_Item_Quantidade);
            end
            else if (Player.Waiting1 = 0) then
            begin
              TItemFunctions.PutItem(Servers[Self.ChannelId].Players[i], 11285,
                SKULL_MULTIPLIER);
            end;
          end;
        end;
      end;
    end;
  end;
{$ENDREGION}
end
else
begin
{$REGION PVP SOLO}
  if (Elter_PvP_Acquire_Solo = 0) and (Player.Waiting1 <> 0) then
  begin
    Exit;
  end;

  if (Player.Waiting1 <> 0) then
  begin
    if (Elter_PvP_Acquire_Solo = 0) then
    begin
      // Nenhuma ação necessária aqui
    end
    else if (Elter_Honor_Value <> 0) and
      (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation <>
      Self.Character.Nation) then
    begin
      Honor := Elter_Honor_Value;
      Inc(Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.Character.CurrentScore.Honor, Honor);
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
      Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshKills();
    end
    else if (Elter_Honor_Value = 0) then
    begin
      // Nenhuma ação necessária se Elter_Honor_Value for 0
    end;

    if (Elter_Item_Perkill_Status <> 0) and
      (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation <>
      Self.Character.Nation) then
    begin
      TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
        Elter_Item_Perkill_Item, Elter_Item_Perkill_Item_Quantidade);
    end
    else if (Elter_Item_Perkill_Status = 0) then
    begin
      // Nenhuma ação necessária se Elter_Item_Perkill_Status for 0
    end;
  end
  else if (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
    <> Self.Character.Nation) then
  begin
    Writeln('Pvp adquirido fora da elter');
    Honor := HONOR_PER_KILL;
    Inc(Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.Honor, Honor);
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('Adquiriu ' + AnsiString(Honor.ToString) + ' pontos de honra.');
    Servers[Self.ChannelId].Players[Self.ClientID].Base.SendRefreshKills();

    TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
      11285, SKULL_MULTIPLIER);
  end;

  TitleGoaled := false;

  for j := 0 to 95 do
  begin
    if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.PlayerCharacter.Titles[j].Index = 0) then
      continue;

    if (Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.PlayerCharacter.Titles[j].Index = 27) then
    begin
      Inc(Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.PlayerCharacter.Titles[j].Progress, 1);

      if (Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.PlayerCharacter.Titles[j].Progress >= Titles[27].TitleLevel
        [Servers[Self.ChannelId].Players[Self.ClientID]
        .Base.PlayerCharacter.Titles[j].Level].TitleGoal) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27,
          Servers[Self.ChannelId].Players[Self.ClientID]
          .Base.PlayerCharacter.Titles[j].Level + 1, True);
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('Seu título [' + Titles[27].TitleLevel
          [Servers[Self.ChannelId].Players[Self.ClientID]
          .Base.PlayerCharacter.Titles[j].Level].TitleName +
          '] foi atualizado.');
      end
      else
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].UpdateTitleLevel(27,
          Servers[Self.ChannelId].Players[Self.ClientID]
          .Base.PlayerCharacter.Titles[j].Level, false);
      end;

      TitleGoaled := True;
      Break;
    end;
  end;

  if not TitleGoaled then
  begin
    Servers[Self.ChannelId].Players[Self.ClientID].AddTitle(27, 0, false);
  end;

  if (Servers[Self.ChannelId].Players[Self.ClientID].Character.Base.GuildIndex >
    0) and (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation
    <> Self.Character.Nation) then
  begin
    Inc(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.GuildSlot].Exp, PvP_Exp_Guild);

    for var m := Low(Servers) to High(Servers) do
    begin
      if not(Servers[m].IsActive) then
        continue; // Ignora servidores inativos

      for var n := 0 to 127 do
      begin
        if (Guilds[Servers[m].Players[Self.ClientID].Character.GuildSlot]
          .Members[n].Logged) then
        begin
          Writeln('membro ' + n.ToString + ' logado no servidor ' + m.ToString);

          for i := Low(Servers[m].Players) to High(Servers[m].Players) do
          begin
            if not Servers[m].Players[i].SocketClosed then
            begin
              Servers[m].Players[i].SendClientMessage
                ('Pontos de experiência da legião foram incrementados em');
              Servers[m].Players[i].SendClientMessage(PvP_Exp_Guild.ToString +
                ' pontos.');
              Servers[m].Players[i].SendGuildInfo;
            end;
          end;
        end;
      end;
    end;
  end;

end;
{$ENDREGION}
end;

procedure TBaseNpc.SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  Pos: TPosition);
var
  h1, h2: Integer;
  Item: PItem;
  RlkSlot: Byte;
begin

  if not((SkillData[Skill].Classe >= 61) and (SkillData[Skill].Classe <= 84))
  then
  begin
    if Self.BuffExistsByIndex(53) or Self.BuffExistsByIndex(77) then
    begin
      Self.RemoveBuffByIndex(53);
      Self.RemoveBuffByIndex(77);
    end;
  end;

  case SkillData[Skill].Index of
    124, 127, 137, 160:
      Self.AddBuff(Skill, True, True, Self.GetMobAbility(EF_SKILL_ATIME6) * 60);

    32:
      begin
        Self.DefesaPoints := 3;
        Self.AddBuff(Skill);
      end;

    36:
      begin
        Self.BolhaPoints := SkillData[Skill].EFV[0];
        Self.AddBuff(Skill);
      end;

    42:
      begin
        Self.HPRListener := True;
        Self.HPRAction := 2;
        Self.HPRSkillID := Skill;
        Self.HPRSkillEtc1 := SkillData[Skill].EFV[2] div 2;
        Self.AddBuff(Skill);
      end;

    53, 77:
      begin
        while TItemFunctions.GetItemSlotByItemType
          (Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE,
          0) <> 255 do
        begin
          RlkSlot := TItemFunctions.GetItemSlotByItemType
            (Servers[Self.ChannelId].Players[Self.ClientID], 40, INV_TYPE, 0);
          if RlkSlot <> 255 then
          begin
            Item := @Servers[Self.ChannelId].Players[Self.ClientID]
              .Base.Character.Inventory[RlkSlot];
            Servers[Self.ChannelId].CreateMapObject(@Self, 320, Item.Index);
            ZeroMemory(Item, SizeOf(TItem));
            Servers[Self.ChannelId].Players[Self.ClientID]
              .Base.SendRefreshItemSlot(INV_TYPE, RlkSlot, Item^, false);
          end;
        end;
        Self.AddBuff(Skill);
      end;

    72:
      begin
        if TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255 then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar com relíquia.');
          Exit;
        end;

        if Self.InClastleVerus then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar em guerra. Use o teleporte.');
          Exit;
        end;

        if (Self.Character.Nation > 0) and
          (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar em outros países.');
          Exit;
        end;

        Servers[Self.ChannelId].Players[Self.ClientID]
          .Teleport(TPosition.Create(3450, 690));
      end;

    150:
      begin
        Self.LaminaPoints := SkillData[Skill].EFV[0];
        Self.LaminaPoints := Self.LaminaPoints div 1;
        Self.LaminaID := Skill;
        Self.EventListener := True;
        Self.EventAction := 1;
        Self.AddBuff(Skill);
      end;

    201:
      begin
        h1 := Self.Character.CurrentScore.MaxMP div 2;
        Randomize;

        case Self.PlayerCharacter.Base.CurrentScore.Int of
          0 .. 20:
            h2 := Random(10);
          21 .. 40:
            h2 := Random(20);
          41 .. 60:
            h2 := Random(30);
          61 .. 80:
            h2 := Random(40);
        else
          h2 := Random(50);
        end;

        Self.AddMP(h1 + ((Self.Character.CurrentScore.MaxMP div 100) *
          h2), True);
      end;

    208:
      begin
        if SkillData[Skill].Damage = 200 then
          Self.AddMP((Self.Character.CurrentScore.MaxMP div 100) * 15, True)
        else if SkillData[Skill].Damage = 300 then
          Self.AddHP((Self.Character.CurrentScore.MaxHP div 100) * 15, True)
        else
          Self.AddBuff(Skill);
      end;

    337:
      begin
        Self.RemoveAllDebuffs;
        Self.AddBuff(Skill);
      end;

    131:
      begin
        Self.CalcAndCure(Skill, mob);
        Self.AddBuff(Skill);
      end;

    128:
      begin
        mob.HPRListener := True;
        mob.HPRAction := 3;
        mob.HPRSkillID := Skill;
        mob.HPRSkillEtc1 := (Self.Character.CurrentScore.DNMAG shr 3) +
          SkillData[Skill].EFV[0];
        mob.AddBuff(Skill);
      end;

    457:
      begin
        if TItemFunctions.GetInvAvailableSlots(Servers[Self.ChannelId].Players
          [Self.ClientID]) = 0 then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Inventário cheio.');
          Exit;
        end;

        TItemFunctions.PutItem(Servers[Self.ChannelId].Players[Self.ClientID],
          SkillData[Skill].Damage);
      end;

    DEMOLICAO_X14:
      begin
        // if Self.PetClientID > 0 then
        // begin
        // Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Você não pode possuir dois PETs ao mesmo tempo.');
        // Exit;
        // end;
        //
        // Self.CreatePet(X14, Pos, Skill);
        // Servers[Self.ChannelId].Players[Self.ClientID].SpawnPet(Self.PetClientID);
        // Self.AddBuff(Skill);
      end;

    113:
      begin
        if Self.InClastleVerus or
          (TItemFunctions.GetItemReliquareSlot(Servers[Self.ChannelId].Players
          [Self.ClientID]) <> 255) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar em guerra ou com relíquia.');
          Exit;
        end;

        if (Self.Character.Nation > 0) and
          (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar em outros países.');
          Exit;
        end;

        Self.WalkTo(Pos, 70, MOVE_TELEPORT);
      end;

    89, 153:
      begin
        Servers[Self.ChannelId].Players[Self.ClientID]
          .DisparosRapidosBarReset(Skill);
        Self._cooldown.Clear;
        Self.AddBuff(Skill);
      end;

    196, 220, 244:
      begin
        h1 := Servers[Self.ChannelId].Players[Self.ClientID].SpawnedPran;

        if not Servers[Self.ChannelId].Players[Self.ClientID].FaericForm then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranUnspawn(h1, 0);
          Servers[Self.ChannelId].Players[Self.ClientID].FaericForm := True;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn
            (h1, 0, 0);
        end
        else
        begin
          Self.SendEffect(0);
          Servers[Self.ChannelId].Players[Self.ClientID].FaericForm := false;
          Servers[Self.ChannelId].Players[Self.ClientID].SendPranSpawn
            (h1, 0, 0);
        end;
      end;

  else
    begin
      Self.AddBuff(Skill);
    end;
  end;
end;

procedure TBaseNpc.TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  DataSkill: P_SkillData; Posx, Posy: DWORD);
var
  Helper, Helper2: Integer;
  i: Integer;
  BoolHelper: Boolean;
begin
  case DataSkill^.Index of
    124, 127, 137, 160:
      mob^.AddBuff(Skill, True, True,
        (Self.GetMobAbility(EF_SKILL_ATIME6) * 60));

    15, 55, 79, 74, 250, 133:
      begin
        if mob^.Character <> nil then
        begin
          Randomize;
          Helper := ((mob^.Character.CurrentScore.MaxHP div 100) * 80);
          if mob^.Character.CurrentScore.CurHP >= Helper then
            Helper2 := RandomRange(60, 120)
          else
            Helper2 := RandomRange(30, 59);
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis + 1);
          if (Helper2 > 1000) and (DataSkill^.Index = 15) then
          begin
            Randomize;
            Helper2 := 1000 + RandomRange(1, 200);
          end;
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;

        if DataSkill^.Index = 133 then
          Self.SKDSkillEtc1 := ((DataSkill^.EFV[0] div 2) + Helper2)
        else if DataSkill^.Index in [55, 79, 74, 250] then
          Self.SKDSkillEtc1 :=
            ((DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration)
        else
          Self.SKDSkillEtc1 := (DataSkill^.EFV[0] + Helper2);

        Self.SKDTarget := mob^.ClientID;
        Self.SKDListener := True;
        Self.SKDAction := 1;
        Self.SKDSkillID := Skill;
        mob^.AddBuff(Skill);
      end;

    26, 122, 138, 162, 458:
      Self.CalcAndCure(Skill, mob);

    35:
      begin
        mob.UniaoDivina := String(Self.Character.Name);
        mob^.AddBuff(Skill);
      end;

    39:
      begin
        Self.RemoveMP(Self.Character.CurrentScore.CurMP, True);
        mob^.Character.CurrentScore.CurHP := mob^.Character.CurrentScore.MaxHP;
        mob^.SendCurrentHPMP(True);
      end;

    154:
      begin
        mob^.Chocado := True;
        mob^.AddBuff(Skill);
      end;

    99:
      begin
        mob^.Polimorfed := True;
        if mob^.ClientID <= MAX_CONNECTIONS then
        begin
          if mob^.Character.CurrentScore.CurHP >
            (mob^.Character.CurrentScore.MaxHP div 2) then
            mob^.Character.CurrentScore.CurHP :=
              (mob^.Character.CurrentScore.MaxHP div 2);
          mob^.SendCreateMob(SPAWN_NORMAL, 0, True, 283);
          mob^.AddBuff(Skill);
        end;
      end;

    140:
      mob^.RemoveDebuffs(1);

    125, 248, 128:
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 2;
        mob^.HPRSkillID := Skill;
        if DataSkill^.Index = 128 then
          mob^.HPRSkillEtc1 := (Self.CalcCure2(DataSkill^.EFV[0], mob, Skill) +
            DataSkill^.EFV[0])
        else if DataSkill^.Index = 248 then
          mob^.HPRSkillEtc1 := DataSkill^.EFV[0]
        else
          mob^.HPRSkillEtc1 := Round(Self.CalcCure2(DataSkill^.EFV[0], mob,
            Skill) / DataSkill^.Duration);
        mob^.AddBuff(Skill);
      end;

    RESSUREICAO:
      if mob.IsDead then
      begin
        // if (Self.PartyId = 0) or (mob.PartyId = 0) then Exit;
        // if Servers[Self.ChannelId].Players[Self.ClientID].Party.InRaid then
        // begin
        // if mob.PartyId <> Self.PartyId then
        // begin
        // BoolHelper := False;
        // for i := 1 to 3 do
        // if (Servers[Self.ChannelId].Players[Self.ClientID].Party.PartyAllied[i] = mob.PartyId) then
        // begin
        // BoolHelper := True;
        // Break;
        // end;
        // if not BoolHelper then Exit;
        // end;
        // end
        // else if mob.PartyId <> Self.PartyId then Exit;
        //
        // mob.IsDead := False;
        // mob.Character.CurrentScore.CurHP := ((mob.Character.CurrentScore.MaxHp div 100) * SkillData[Skill].Damage);
        // mob.SendEffect(1);
        // mob.SendCurrentHPMP(True);
        // if Servers[mob.ChannelId].Players[ClientID].InDungeon then
        // Servers[mob.ChannelId].Players[ClientID].TavaEmDG := False;
        // Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage(
        // 'Você foi ressuscitado pelo jogador ' + AnsiString(Self.Character.Name) + '.');
      end;

    131, 167:
      begin
        mob^.RemoveDebuffs(1);
        Self.CalcAndCure(Skill, mob);
        mob^.AddBuff(Skill);
      end;

    337:
      begin
        mob^.RemoveDebuffs(1);
        mob^.AddBuff(Skill);
        if mob^.IsPlayer and not((Skill = 226) or (Skill = 393) or (Skill = 159)
          or (Skill = 99)) then
          mob^.AddBuff(221);

      end;

    459:
      mob^.AddHP(Self.CalcCure2(DataSkill^.Damage, mob), True);

    113:
      begin
        Helper := TItemFunctions.GetItemReliquareSlot
          (Servers[mob^.ChannelId].Players[mob.ClientID]);
        if (Helper <> 255) or mob.InClastleVerus then
        begin
          Servers[mob^.ChannelId].Players[mob.ClientID].SendClientMessage
            ('Impossível usar nesta situação.');
          Exit;
        end;
        if (Self.Character.Nation > 0) and
          (Self.Character.Nation <> Servers[Self.ChannelId].NationID) then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Impossível usar em outros países.');
          Exit;
        end;
        mob^.WalkTo(TPosition.Create(Posx, Posy), 70, MOVE_TELEPORT);
      end;

  else
    try
      mob^.AddBuff(Skill);
    except
      on E: Exception do
        Logger.Write('Error at NPC.AddBuff ' + E.Message, TLogType.Error);
    end;
  end;
end;

procedure TBaseNpc.TargetSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Classe of
    1, 2:
      begin
        Self.WarriorSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    11, 12: // templar skill
      begin
        Self.TemplarSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
    21, 22: // rifleman skill
      begin
        Self.RiflemanSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    31, 32: // dualgunner skill
      begin
        Self.DualGunnerSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    41, 42: // magician skill
      begin
        Self.MagicianSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
          Resisted);
      end;
    51, 52: // cleric skill
      begin
        Self.ClericSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff, Resisted);
      end;
  end;
end;

procedure TBaseNpc.AreaBuff(Skill, Anim: DWORD; mob: PBaseNpc;
  Packet: TRecvDamagePacket);
var
  i, cnt: Integer;
  PrePosition: TPosition;
begin
  if ((Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = 0) or
    (SkillData[Skill].Index = LAMINA_PROMESSA)) then
  begin
    Self.SelfBuffSkill(Skill, Anim, mob, Packet.DeathPos);
  end
  else
  begin
    cnt := 0;

    if (Self.VisiblePlayers.Count = 0) then
    begin
      Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
        [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
        Trunc(Packet.DeathPos.y));
    end
    else
    begin
      for i in Self.VisiblePlayers do
      begin
        with Servers[Self.ChannelId].Players[i] do
        begin
          if (Status < Playing) or (Base.IsDead) or (PartyIndex = 0) or
            (Servers[Self.ChannelId].Players[Self.ClientID].Party.
            Index <> Party.Index) or not Self.PlayerCharacter.LastPos.InRange
            (Base.PlayerCharacter.LastPos, Trunc(SkillData[Skill].range * 1.5))
          then
            continue;

          if (cnt = 0) then
          begin
            PrePosition := Self.PlayerCharacter.LastPos;
            Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
              [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
              Trunc(Packet.DeathPos.y));
            cnt := 1;
          end;

          Self.TargetBuffSkill(Skill, Anim, @Base, @SkillData[Skill],
            Trunc(Packet.DeathPos.x), Trunc(Packet.DeathPos.y));
          Packet.Animation := 0;
          Packet.TargetID := i;
          Packet.AttackerHP := Base.Character.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
        end;
      end;
    end;
  end;

  if (SkillData[Skill].Index = 167) then
    Self.UsingLongSkill := True;
end;

procedure TBaseNpc.AreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  SkillPos: TPosition; DataSkill: P_SkillData; DamagePerc: Single;
  ElThymos: Integer);
var
  Dano: Integer;
  DmgType: TDamageType;
  SelfPlayer: PPlayer;
  OtherPlayer: PPlayer;
  NewMob, mob_teleport: PBaseNpc;
  NewMobSP: PMobSPoisition;
  NewMobid1: Integer;
  Packet: TRecvDamagePacket;
  i, j, cnt: Integer;
  Add_Buff: Boolean;
  Resisted: Boolean;
  Mobid, mobpid: Integer;
  MoveTarget: Boolean;
  DropExp, DropItem: Boolean;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.DeathPos := SkillPos;
  if ((SkillData[Skill].range > 0) { and (SkillData[Skill].CastTime > 0) } )
  then
  begin // SkillData[Skill]
    Packet.AttackerPos := SkillPos;
  end
  else
  begin
    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  end;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := DataSkill^.TargetAnimation;
  Self.UsingLongSkill := false;

  if (ElThymos > 0) then
  begin
    Packet.SkillID := 0;
    Packet.Animation := 0;
    Packet.MobAnimation := 26;
  end;

  if (SkillData[Skill].Index = DEMOLICAO_X14) then
  begin
    Self.SelfBuffSkill(Skill, Anim, mob, SkillPos);
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.None;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    Exit;
  end;

  case Self.GetMobClass() of
    2, 3:
      begin
        if not(ItemList[Self.Character.Equip[15].Index].ItemType = 52) then
        begin
          TItemFunctions.DecreaseAmount(@Self.Character.Equip[15], 1);
          Self.SendRefreshItemSlot(EQUIP_TYPE, 15,
            Self.Character.Equip[15], false);
        end;
      end;
  end;

  // Inicializa o contador de mobs atacados
  var
    MobAtacado: Integer := 0;

    // Loop de targets visíveis
  for i := Low(VisibleTargets) to High(VisibleTargets) do
  begin
    if (VisibleTargets[i].ClientID = 0) then
      continue;

    // Obtenha o mob correspondente ao alvo
    NewMob := Self.GetTargetInList(VisibleTargets[i].ClientID);
    if (NewMob = nil) or (NewMob^.IsDead) then
      continue;

    // Verifique se o mob está dentro do alcance da skill
    if (DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
      .DungeonInstanceID].MOBS[NewMob^.Mobid].Position.Distance(SkillPos) >
      (DataSkill^.range * 1.5)) then
      continue;

    // Mob está dentro do alcance, podemos continuar com o processo
    Mobid := NewMob^.Mobid;

    // Verificar se o mob foi atacado antes
    with DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
      .DungeonInstanceID].MOBS[Mobid] do
    begin
      if not IsAttacked then
      begin
        IsAttacked := True;
        FirstPlayerAttacker := Self.ClientID;
      end;
      AttackerID := Self.ClientID;
    end;

    // Aplica a skill
    Packet.TargetID := NewMob^.ClientID;
    Resisted := false;

    // Verifique a classe e aplique a skill correspondente
    case DataSkill^.Classe of
      1, 2:
        begin
          Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Resisted, MoveTarget);
          Self.PlayerCharacter.CurrentPos := SkillPos;
        end;
      11, 12:
        begin
          Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Resisted);
          Self.PlayerCharacter.CurrentPos := SkillPos;
        end;
      21, 22:
        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
          Resisted);
      31, 32:
        begin
          Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Resisted);
          Self.PlayerCharacter.CurrentPos := SkillPos;
        end;
      41, 42:
        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
          Resisted);
      51, 52:
        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
          Resisted);
    end;

    Inc(MobAtacado);

    if (Dano > 0) then
    begin
      // Aplica o dano ao mob
      Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
        Packet.MobAnimation, DataSkill);
      Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));
    end;

    if (Add_Buff) and not Resisted then
      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);

    // Atualiza o HP do mob e verifica se ele morreu
    Packet.Dano := Dano;
    Packet.DnType := DmgType;

    with DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
      .DungeonInstanceID].MOBS[Mobid] do
    begin
      if (Packet.Dano >= CurrentHP) then
      begin
        CurrentHP := 0;
        IsAttacked := false;
        AttackerID := 0;
        deadTime := Now;

        if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
          Self.VisibleMobs.Remove(NewMob^.ClientID);
        NewMob^.VisibleMobs.Clear;
        Self.MobKilledInDungeon(NewMob);
        Packet.MobAnimation := 30;
        NewMob^.IsDead := True;
        Self.RemoveTargetFromList(NewMob);
        Self.MobKilled(NewMob, DropExp, DropItem, false);
        Writeln(DropExp.ToString);
        Writeln(DropItem.ToString);
      end
      else
        CurrentHP := CurrentHP - Packet.Dano;
    end;

    NewMob.LastReceivedAttack := Now;

    // Envia o pacote de atualização
    Packet.MobCurrHP := DungeonInstances
      [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].MOBS
      [Mobid].CurrentHP;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;

  // Se nenhum mob foi atacado, envia pacote sem dano
  if (MobAtacado = 0) then
  begin
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;

  // contra players
  cnt := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  for i := Low(VisibleTargets) to High(VisibleTargets) do
  begin
    if (VisibleTargets[i].ClientID = 0) then
      continue;

    if (ElThymos > 0) then
    begin
      if (VisibleTargets[i].ClientID = mob.ClientID) then
        continue;
    end;

    case VisibleTargets[i].TargetType of
      0:
        begin
          if (VisibleTargets[i].Player = nil) then
            continue;
          NewMob := VisibleTargets[i].Player;
          OtherPlayer := @Servers[Self.ChannelId].Players
            [VisibleTargets[i].ClientID];

          if (NewMob^.IsDead) or (OtherPlayer.SocketClosed) or
            (OtherPlayer.Status < Playing) then
            continue;

          if not(SkillPos.InRange(NewMob^.PlayerCharacter.LastPos,
            Trunc(DataSkill^.range * 1.5))) then
          begin
            if (TPosition.Create(2947, 1664)
              .InRange(NewMob^.PlayerCharacter.LastPos, 10)) then
              continue;
            if ((SelfPlayer^.Character.Base.GuildIndex > 0) and
              (SelfPlayer.Character.Base.GuildIndex = OtherPlayer^.Character.
              Base.GuildIndex) and not(SelfPlayer^.Dueling)) then
              continue;
            if (SelfPlayer^.PartyIndex > 0) and
              (SelfPlayer.PartyIndex = OtherPlayer^.PartyIndex) then
              continue;
            if ((Self.Character.Nation = NewMob^.Character.Nation) and
              (SelfPlayer^.Character.PlayerKill = false) and
              not(SelfPlayer^.Dueling)) then
              continue;

            if SelfPlayer^.Dueling then
            begin
              if (NewMob^.ClientID <> SelfPlayer^.DuelingWith) or
                (SecondsBetween(Now, SelfPlayer^.DuelInitTime) <= 15) then
                continue;
            end;

            if ((SelfPlayer^.Character.GuildSlot > 0) and
              (Servers[SelfPlayer^.ChannelIndex].Players[NewMob^.ClientID]
              .Character.GuildSlot > 0) and
              (Guilds[SelfPlayer^.Character.GuildSlot].Ally.Leader = Guilds
              [Servers[SelfPlayer^.ChannelIndex].Players[NewMob^.ClientID]
              .Character.GuildSlot].Ally.Leader)) then
              Exit;

            if (SecondsBetween(Now, NewMob.RevivedTime) <= 7) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('Alvo acabou de nascer.');
              continue;
            end;

            Inc(cnt);
            Packet.TargetID := NewMob^.ClientID;
            Resisted := false;

            case DataSkill^.Classe of
              1, 2:
                Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                  Add_Buff, Resisted, MoveTarget);
              11, 12:
                Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                  Add_Buff, Resisted);
              21, 22:
                Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                  Add_Buff, Resisted);
              31, 32:
                Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                  Add_Buff, Resisted);
              41, 42:
                Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                  Add_Buff, Resisted);
              51, 52:
                Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                  Add_Buff, Resisted);
            end;

            if (Dano > 0) then
            begin
              if (ElThymos > 0) then
                Self.AttackParse(0, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill)
              else
                Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill);

              Inc(Dano, RandomRange((Dano div 20), (Dano div 10)) + 13);

              if (DamagePerc > 0) then
                Dano := Trunc((Dano div 100) * DamagePerc);
            end
            else
            begin
              if not(DmgType in [Critical, Normal, Double]) then
                Add_Buff := false;
            end;

            if (Add_Buff) and not(Resisted) then
              Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);

            if ((ElThymos > 0) and (Dano > 0)) then
              Dano := Round((Dano / 100) * DamagePerc);

            if (DmgType = Miss) then
              Dano := 0;

            Packet.Dano := Dano;
            Packet.DnType := DmgType;

            if (Packet.Dano >= NewMob^.Character.CurrentScore.CurHP) then
            begin
              if (OtherPlayer^.Dueling) then
                NewMob^.Character.CurrentScore.CurHP := 10
              else
              begin
                NewMob^.Character.CurrentScore.CurHP := 0;
                NewMob^.SendEffect($0);
                Packet.MobAnimation := 30;
                NewMob^.IsDead := True;
                if (Servers[Self.ChannelId].Players[NewMob^.ClientID]
                  .CollectingReliquare) then
                  Servers[Self.ChannelId].Players[NewMob^.ClientID]
                    .SendCancelCollectItem(Servers[Self.ChannelId].Players
                    [NewMob^.ClientID].CollectingID);

                NewMob^.LastReceivedAttack := Now;
                Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;

                if (cnt > 1) then
                  Packet.AttackerID := Self.ClientID
                else
                  Packet.AttackerID := Self.ClientID;

                if ((SkillData[Skill].range > 0)) then
                begin
                  Packet.AttackerPos := SkillPos;
                  Packet.DeathPos := Servers[Self.ChannelId].Players
                    [Self.ClientID].LastPositionLongSkill;
                end
                else
                begin
                  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                  Packet.DeathPos := SkillPos;
                end;

                Self.SendToVisible(Packet, Packet.Header.size);

                if (NewMob^.Character.Nation > 0) and (Self.Character.Nation > 0)
                then
                begin
                  if ((NewMob^.Character.Nation <> Self.Character.Nation) or
                    (Self.InClastleVerus)) then
                    Self.PlayerKilled(NewMob);
                end;
              end;
            end
            else
            begin
              if (Packet.Dano > 0) then
                NewMob^.RemoveHP(Packet.Dano, false);
              if (Servers[Self.ChannelId].Players[NewMob^.ClientID]
                .CollectingReliquare) then
                Servers[Self.ChannelId].Players[NewMob^.ClientID]
                  .SendCancelCollectItem(Servers[Self.ChannelId].Players
                  [NewMob^.ClientID].CollectingID);

              NewMob^.LastReceivedAttack := Now;
              Packet.MobCurrHP := NewMob^.Character.CurrentScore.CurHP;

              if (cnt > 1) then
                Packet.AttackerID := Self.ClientID
              else
                Packet.AttackerID := Self.ClientID;

              if ((SkillData[Skill].range > 0)) then
              begin
                Packet.AttackerPos := SkillPos;
                Packet.DeathPos := Servers[Self.ChannelId].Players
                  [Self.ClientID].LastPositionLongSkill;
              end
              else
              begin
                Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                Packet.DeathPos := SkillPos;
              end;

              Self.SendToVisible(Packet, Packet.Header.size);
            end;
          end;

        end;
      1:
        begin
          if (VisibleTargets[i].mob = nil) then
            continue;
          NewMob := VisibleTargets[i].mob;
          if (NewMob.ClientID > 9147) then
            continue;
          if not(Servers[Self.ChannelId].MOBS.TMobS[NewMob.Mobid]
            .IsActiveToSpawn) then
            continue;
          if (NewMob^.IsDead) then
            continue;
          case NewMob^.ClientID of
            3340 .. 3354:
              begin // stones
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirStones
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1.5))) then
                begin
                  if (Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.ChannelId]
                    .Players[Self.ClientID].Account.Header.Nation)) then
                    continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := false;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if (Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType,
                      Add_Buff, Packet.MobAnimation, DataSkill);

                    if (Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20),
                        (Dano div 10))) + 13));

                      if (DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if ((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
                    not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .IsAttacked := false;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirStones[NewMob^.ClientID]
                      .KillStone(NewMob^.ClientID, Self.ClientID);
                    if (Self.VisibleNPCS.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCS.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if (Servers[Self.ChannelId].Players[j]
                        .Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j]
                          .Base.VisibleNPCS.Remove(NewMob^.ClientID);
                        // Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirStones
                      [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP,
                      Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  // Sleep(1);
                end;
              end;
            3355 .. 3369:
              begin // guards
                if (SkillPos.InRange(Servers[Self.ChannelId].DevirGuards
                  [NewMob^.ClientID].PlayerChar.LastPos,
                  Trunc(DataSkill^.range * 1.5))) then
                begin
                  if (Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .PlayerChar.Base.Nation = Integer(Servers[Self.ChannelId]
                    .Players[Self.ClientID].Account.Header.Nation)) then
                    continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := false;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted);
                      end;
                  end;
                  if (Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType,
                      Add_Buff, Packet.MobAnimation, DataSkill);

                    if (Dano > 0) then
                    begin
                      Inc(Dano, ((RandomRange((Dano div 20),
                        (Dano div 10))) + 13));

                      if (DamagePerc > 0) then
                      begin
                        Dano := Trunc((Dano div 100) * DamagePerc);
                      end;
                    end;
                  end;
                  if (Add_Buff = True) then
                  begin
                    if not(Resisted) then
                      Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                  end;
                  if (DmgType = Miss) then
                    Dano := 0;
                  if ((ElThymos > 0) and (Dano > 0)) then
                  begin
                    Dano := Round((Dano / 100) * DamagePerc);
                  end;

                  Packet.Dano := Dano;
                  Packet.DnType := DmgType;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .IsAttacked := True;
                  Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                    .AttackerID := Self.ClientID;
                  if ((Packet.Dano >= Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) and
                    not(NewMob^.IsDead)) then
                  begin
                    NewMob^.IsDead := True;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .PlayerChar.Base.CurrentScore.CurHP := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .IsAttacked := false;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .AttackerID := 0;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .deadTime := Now;
                    Servers[Self.ChannelId].DevirGuards[NewMob^.ClientID]
                      .KillGuard(NewMob^.ClientID, Self.ClientID);
                    if (Self.VisibleNPCS.Contains(NewMob^.ClientID)) then
                    begin
                      Self.VisibleNPCS.Remove(NewMob^.ClientID);
                      Self.RemoveTargetFromList(NewMob);
                      // essa skill tem retorno no caso de erro
                    end;
                    for j in Self.VisiblePlayers do
                    begin
                      if (Servers[Self.ChannelId].Players[j]
                        .Base.VisibleNPCS.Contains(NewMob^.ClientID)) then
                      begin
                        Servers[Self.ChannelId].Players[j]
                          .Base.VisibleNPCS.Remove(NewMob^.ClientID);
                        // Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                      end;
                    end;
                    NewMob^.VisibleMobs.Clear;
                    // Self.MobKilled(mob, DropExp, DropItem, False);
                    Packet.MobAnimation := 30;
                  end
                  else
                  begin
                    deccardinal(Servers[Self.ChannelId].DevirGuards
                      [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP,
                      Packet.Dano);
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
                    [NewMob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  // Sleep(1);
                end;
              end
          else
            begin
              NewMobSP := @Servers[Self.ChannelId].MOBS.TMobS[NewMob^.Mobid]
                .MobsP[NewMob^.SecondIndex];
              if (SkillPos.InRange(NewMobSP^.CurrentPos,
                Trunc(DataSkill^.range * 1.5))) then
              begin
                if ((NewMobSP^.isGuard) and
                  ((NewMob^.PlayerCharacter.Base.Nation = Self.Character.Nation)
                  or (Self.Character.Nation = 0))) then
                  continue;

                if not(NewMobSP.IsAttacked) then
                begin
                  NewMobSP.FirstPlayerAttacker := Self.ClientID;
                end;

                Inc(cnt);
                Packet.TargetID := NewMob^.ClientID;
                Resisted := false;
                case DataSkill^.Classe of
                  1, 2: // warrior skill
                    begin
                      Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, MoveTarget);
                    end;
                  11, 12: // templar skill
                    begin
                      Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  21, 22: // rifleman skill
                    begin
                      Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  31, 32: // dualgunner skill
                    begin
                      Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                        DmgType, Add_Buff, Resisted);
                    end;
                  41, 42: // magician skill
                    begin
                      Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                  51, 52: // cleric skill
                    begin
                      Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted);
                    end;
                end;
                if (Dano > 0) then
                begin
                  Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                    Packet.MobAnimation, DataSkill);

                  if (Dano > 0) then
                  begin
                    Inc(Dano, ((RandomRange((Dano div 20),
                      (Dano div 10))) + 13));

                    if (DamagePerc > 0) then
                    begin
                      Dano := Trunc((Dano div 100) * DamagePerc);
                    end;
                  end;
                end;
                if (Add_Buff = True) then
                begin
                  if not(Resisted) then
                    Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
                end;
                if (DmgType = Miss) then
                  Dano := 0;
                if ((ElThymos > 0) and (Dano > 0)) then
                begin
                  Dano := Round((Dano / 100) * DamagePerc);
                end;
                Packet.Dano := Dano;
                Packet.DnType := DmgType;
                NewMobSP^.IsAttacked := True;
                NewMobSP^.AttackerID := Self.ClientID;
                if (Packet.Dano >= NewMobSP^.HP) then
                begin
                  NewMobSP^.HP := 0;
                  NewMobSP^.IsAttacked := false;
                  NewMobSP^.AttackerID := 0;
                  NewMobSP^.deadTime := Now;
                  NewMob.SendEffect($0);
                  NewMob^.IsDead := True;
                  NewMob.SendCurrentHPMPMob;
                  if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
                  begin
                    Self.VisibleMobs.Remove(NewMob^.ClientID);
                    Self.RemoveTargetFromList(NewMob);
                  end;
                  for j in Self.VisiblePlayers do
                  begin
                    if (Servers[Self.ChannelId].Players[j]
                      .Base.VisibleMobs.Contains(NewMob^.ClientID)) then
                    begin
                      Servers[Self.ChannelId].Players[j].Base.VisibleMobs.Remove
                        (NewMob^.ClientID);
                      // Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(NewMob);
                    end;
                  end;
                  NewMob^.VisibleMobs.Clear;
                  Self.MobKilled(NewMob, DropExp, DropItem, false);
                  Packet.MobAnimation := 30;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  NewMob^.LastReceivedAttack := Now;
                  Packet.MobCurrHP := 0;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  // Sleep(1);
                end
                else
                begin

                  deccardinal(NewMobSP^.HP, Packet.Dano);
                  Packet.MobCurrHP := NewMobSP^.HP;
                  NewMob^.LastReceivedAttack := Now;
                  if (cnt > 1) then
                  begin
                    Packet.AttackerID := Self.ClientID;
                    Packet.Animation := 0;
                  end
                  else
                  begin
                    Packet.AttackerID := Self.ClientID;
                  end;
                  if ((SkillData[Skill].range > 0)
                    { and (SkillData[Skill].CastTime > 0) } ) then
                  begin // SkillData[Skill]
                    Packet.AttackerPos := SkillPos;
                    Packet.DeathPos := Servers[Self.ChannelId].Players
                      [Self.ClientID].LastPositionLongSkill;
                  end
                  else
                  begin
                    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
                    Packet.DeathPos := SkillPos;
                  end;
                  Self.SendToVisible(Packet, Packet.Header.size);
                  NewMob.SendCurrentHPMPMob;
                  // Sleep(1);
                end;
              end;
            end;
          end;
        end;
    end;
  end;
  if ((cnt = 0) and (ElThymos = 0)) then
  begin
    Packet.TargetID := 0;
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
  end;
end;

procedure TBaseNpc.AttackParse(Skill, Anim: DWORD; mob: PBaseNpc;
  var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
  out MobAnimation: Byte; DataSkill: P_SkillData);
var
  HpPerc, MpPerc: Integer;
  // CriticalResTax: Integer;
  Helper: Integer;
  HelperInByte: Byte;
  Help1, Help2: Integer;
  OtherPlayer: PPlayer;
  BoolHelp: Boolean;
  OnePercentOfTheDamage: Integer;
begin
  // AddBuff := True;
  if (Skill > 0) then
  begin
    Inc(Dano, (DataSkill^.Damage + Self.PlayerCharacter.HabAtk) div 2);
    Inc(Dano, Self.GetMobAbility(EF_PRAN_SKILL_DAMAGE));

    if (Self.Character <> nil) and
      (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_PER_DAMAGE]
        * (Dano div 100));
  end
  else if (Self.GetMobAbility(EF_SPLASH) > 0) and
    (SecondsBetween(Now, LastSplashTime) >= 1) then
  begin
    LastSplashTime := Now;
    Self.AreaSkill(177, SkillData[177].Anim, mob, Self.PlayerCharacter.LastPos,
      @SkillData[177], Self.GetMobAbility(EF_SPLASH), 1);
  end;

  if (Skill > 0) and ((Self.GetMobClass() = 2) or (Self.GetMobClass() = 4)) and
    (SkillData[Skill].Adicional > 0) then
  begin
    Randomize;
    if (SkillData[Skill].Adicional <= RandomRange(1, 101)) then
      DmgType := Critical;
  end;

  case DmgType of
    Critical, DoubleCritical:
      begin
        OnePercentOfTheDamage := Dano div 100;
        Dano := Trunc(Dano * IfThen(DmgType = Critical, 1.1, 2.1));

        Helper := Self.PlayerCharacter.DamageCritical -
          mob^.PlayerCharacter.ResDamageCritical;
        if (Helper < 0) then
          decInt(Dano, OnePercentOfTheDamage * Abs(Helper))
        else
          Inc(Dano, OnePercentOfTheDamage * Helper);
      end;
    Double:
      Dano := Dano * 2;
  end;

  if (mob^.GetMobAbility(EF_AMP_PHYSICAL) > 0) then
    Inc(Dano, (Dano div 100) * mob^.GetMobAbility(EF_AMP_PHYSICAL));

  if (mob^.GetMobAbility(EF_TYPE45) > 0) then
    Inc(Dano, (Dano div 100) * 10);

  for var BuffIndex in [432, 123, 131, 142] do
    if (mob^.BuffExistsByIndex(BuffIndex)) then
    begin
      Help1 := mob^.GetMobAbility(IfThen(BuffIndex = 142, EF_SKILL_ABSORB2,
        EF_SKILL_ABSORB1));
      if (Help1 > Dano) then
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('O alvo absorveu seu ataque.');
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você absorveu ' + Dano.ToString + ' pontos de ataque.');
        mob^.DecreasseMobAbility(IfThen(BuffIndex = 142, EF_SKILL_ABSORB2,
          EF_SKILL_ABSORB1), Dano);
        Dano := 0;
        DmgType := TDamageType.None;
      end
      else
      begin
        Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
          ('O alvo absorveu seu ataque em partes.', 0);
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você absorveu ' + Help1.ToString + ' pontos de ataque.');
        decInt(Dano, Help1);
        mob^.RemoveBuffByIndex(BuffIndex);
      end;
    end;

  if (mob^.Polimorfed) then
  begin
    DmgType := TDamageType.DoubleCritical;
    mob^.Polimorfed := false;
    if (mob^.ClientID <= MAX_CONNECTIONS) then
    begin
      mob^.RemoveBuffByIndex(99);
      mob^.SendCreateMob(SPAWN_NORMAL);
    end;
  end;

  if (Self.GetMobAbility(EF_DRAIN_HP) > 0) then
    Self.AddHP((Dano div 100) * Self.GetMobAbility(EF_DRAIN_HP), True);

  if (Self.GetMobAbility(EF_DRAIN_MP) > 0) then
    Self.AddMP((Dano div 100) * Self.GetMobAbility(EF_DRAIN_MP), True);

  if (Self.GetMobAbility(EF_HP_ATK_RES) > 0) then
    Self.AddHP((Dano div 100) * Self.GetMobAbility(EF_HP_ATK_RES), True);

  if (mob^.BuffExistsByIndex(101)) then
  begin
    Help1 := (Dano div 100) * mob^.GetMobAbility(EF_HP_CONVERSION);
    Help2 := Trunc(Help1 * (mob^.GetMobAbility(EF_MP_EFFICIENCY) / 100));

    if (Help2 >= mob^.Character.CurrentScore.CurMP) then
      mob^.RemoveBuffByIndex(101);

    mob^.RemoveMP(Help2, True);
    decInt(Dano, Help1);
  end;

  for var BuffIndex in [111, 86, 63, 153] do
    if (mob^.BuffExistsByIndex(BuffIndex)) then
      mob^.RemoveBuffByIndex(BuffIndex);

  if (mob^.ClientID <= MAX_CONNECTIONS) then
  begin
    if ((mob^.Character.Nation <> Self.Character.Nation) and
      (mob^.Character.Nation > 0) and (Self.Character.Nation > 0)) then
    begin
      Inc(Dano, Self.PlayerCharacter.PvPDamage);
      decInt(Dano, mob.PlayerCharacter.PvPDefense);

      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
        Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_NATION] *
          (Dano div 100));

      Helper := Dano;
      Inc(Dano, ((Helper div 100) * Self.GetMobAbility(EF_MARSHAL_ATK_NATION)));
      decInt(Dano, ((Helper div 100) * mob.GetMobAbility
        (EF_MARSHAL_DEF_NATION)));

      if (Servers[Self.ChannelId].NationID = mob.Character.Nation) then
        decInt(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_DEF_NATION]
          * (Dano div 100));
    end;
  end
  else if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Inc(Dano, Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_MONSTER] *
      (Dano div 100));

  HelperInByte := 0;
  if (Self.IsCompleteEffect5(HelperInByte)) and
    (RandomRange(1, 101) <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
    Self.Effect5Skill(mob, HelperInByte);

  if (Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1) > 0) then
    decInt(Dano, ((Dano div 100) * Self.GetMobAbility
      (EF_DECREASE_PER_DAMAGE1)));

  if (mob^.GetMobAbility(EF_HP_CONVERSION) > 0) then
    decInt(Dano, ((Dano div 100) * mob^.GetMobAbility(EF_HP_CONVERSION)));

  if (mob^.BuffExistsByIndex(337)) and
    not((SkillData[Skill].Index = 8) or (SkillData[Skill].Index = 90) or
    mob^.BuffExistsByIndex(8) or mob^.BuffExistsByIndex(90)) then
  begin
    AddBuff := false;
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('[' + AnsiString(mob.Character.Name) + '] resistiu.');
    Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
      ('Você resistiu.');
  end;

  if (mob^.BuffExistsByIndex(38)) then
  begin
    Help1 := mob^.GetMobAbility(EF_REFLECTION2);
    Self.RemoveHP(((Dano div 100) * Help1), True, True);
    mob^.RemoveBuffByIndex(38);
    Dano := 0;
    DmgType := TDamageType.None;
  end;

  if (Dano > 0) then
  begin
    Helper := mob^.GetMobAbility(EF_REFLECTION1);
    if (Helper > 0) then
    begin
      Self.RemoveHP(Helper, false, True);
      Self.SendCurrentHPMP(True);
    end;

    if (mob^.BuffExistsByIndex(222)) then
    begin
      Helper := mob^.GetMobAbility(EF_SKILL_ABSORB1);
      if (Helper > 0) then
      begin
        if (Dano >= Helper) then
        begin
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
          mob^.RemoveBuffByIndex(222);
        end
        else
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
        decInt(Dano, Helper);
      end;
    end;
  end;

  if (mob^.BuffExistsByIndex(32)) then
  begin
    dec(Dano, ((Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE)));
    mob^.DefesaPoints := mob^.DefesaPoints - 1;
    // Dec(mob^.DefesaPoints,1);
    if (mob^.DefesaPoints = 0) then
      mob^.RemoveBuffByIndex(32);
  end;

  if (mob^.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '')) then
  begin
    Helper := Dano;
    decInt(Dano, ((Dano div 100) * mob.GetMobAbility(EF_TRANSFER)));
    decInt(Helper, Dano);
    OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);

    if (OtherPlayer <> nil) and not(OtherPlayer.Base.IsDead) and
      (OtherPlayer.Status >= Playing) and not(OtherPlayer.SocketClosed) then
    begin
      OtherPlayer.Base.RemoveHP(Helper, True, True);
      OtherPlayer.Base.LastReceivedAttack := Now;
      OtherPlayer.SendClientMessage('Seu HP foi consumido.');
    end
    else
    begin
      mob.RemoveBuffByIndex(35);
      mob.UniaoDivina := '';
    end;
  end;

  if (mob^.BuffExistsByIndex(36) and not(DataSkill^.Index = 0) and (Skill > 0))
  then
  begin
    mob^.BolhaPoints := mob^.BolhaPoints - 1;
    IfThen(DataSkill^.Index = 136, DataSkill^.Damage, 1);

    if (mob^.BolhaPoints = 0) then
    begin
      mob^.RemoveBuffByIndex(36);
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := false;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) + '] resistiu.');
    end
    else
    begin
      Dano := 0;
      DmgType := TDamageType.None;
      AddBuff := false;
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('[' + AnsiString(mob.Character.Name) + '] resistiu.');
    end;
  end;

  if not(Dano = 0) and not(mob^.ClientID >= 3048) then
  begin
    if (mob^.BuffExistsByIndex(460)) and
      (Dano > mob^.Character.CurrentScore.CurHP) then
    begin
      mob^.RemoveBuffByIndex(460);
      mob^.RemoveAllDebuffs;
      mob^.ResolutoPoints := 0;
      mob^.Character.CurrentScore.CurHP :=
        ((mob^.Character.CurrentScore.MaxHP div 100) * 30);
      mob^.Character.CurrentScore.CurMP :=
        ((mob^.Character.CurrentScore.MaxMP div 100) * 25);
      mob^.SendCurrentHPMP(True);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você foi revivido.');
    end;
  end;

  if (mob.BuffExistsByIndex(154)) then
    mob.Chocado := false; // Veneno Hidra

  if (mob^.GetMobAbility(EF_ADD_DAMAGE1) > 0) then
    Inc(Dano, (mob^.GetMobAbility(EF_ADD_DAMAGE1) * 2));

  if (mob^.BuffExistsByIndex(90)) and
    ((DmgType = Critical) or (DmgType = DoubleCritical)) then
    Self.TargetBuffSkill(6279, 0, mob, @SkillData[6279]);

  if (mob^.ResolutoPoints > 0) then
  begin
    Writeln(mob^.ResolutoPoints);
    Writeln(SecondsBetween(Now, mob^.ResolutoTime));

    if (SecondsBetween(Now, mob^.ResolutoTime) >= 8) then
      mob^.ResolutoPoints := 0
    else if (mob^.ResolutoPoints > 1) and (mob.Mobid = 0) then
    begin
      Randomize;
      Helper := RandomRange(-1, 2);

      Self.WalkBacked(TPosition.Create(mob.PlayerCharacter.LastPos.x + Helper,
        mob.PlayerCharacter.LastPos.y + Helper), 209, mob);
    end;
  end;
  if (Self.GetMobClass() = 4) and (DataSkill.Adicional > 0) and
    ((mob.GetMobAbility(EF_ACCELERATION1) > 0) or
    (mob.GetMobAbility(EF_ACCELERATION2) > 0) or
    (mob.GetMobAbility(EF_ACCELERATION3) > 0)) then
    Inc(Dano, DataSkill.Adicional);

  if (mob.ClientID >= 3048) and (mob.ClientID <= 9147) then
  begin
    if (Self.GetMobAbility(EF_ATK_MONSTER) > 0) then
      Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_MONSTER)));

    if (mob.GetMobAbility(197) > 0) then
    begin
      if (Self.GetMobAbility(EF_ATK_UNDEAD) > 0) or
        (Self.GetMobAbility(EF_ATK_DEMON) > 0) then
      begin
        if (Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
          Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
        if (Self.GetMobAbility(EF_ATK_DEMON) > 0) then
          Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
      end;
    end;

    if (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType >= 1024) then
      case (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType - 1024) of
        0 .. 7:
          if (Self.GetMobAbility(EF_ATK_ALIEN +
            (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType - 1024)) > 0)
          then
            Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_ALIEN +
              (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType - 1024))));
      else
        if (Self.GetMobAbility(EF_ATK_UNDEAD) > 0) or
          (Self.GetMobAbility(EF_ATK_DEMON) > 0) then
        begin
          if (Self.GetMobAbility(EF_ATK_UNDEAD) > 0) then
            Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_UNDEAD)));
          if (Self.GetMobAbility(EF_ATK_DEMON) > 0) then
            Inc(Dano, Round((Dano / 100) * Self.GetMobAbility(EF_ATK_DEMON)));
        end;
      end;
  end;

  if (Dano > 999999) or (Dano < 0) then
    Dano := 1;

end;

procedure TBaseNpc.AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseNpc;
  var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
  out MobAnimation: Byte);
var
  HpPerc, MpPerc: Integer;
  Helper: Integer;
  HelperInByte: Byte;
  Help1: Integer;
  OtherPlayer: PPlayer;
begin
  if mob.GetMobAbility(EF_AMP_PHYSICAL) > 0 then
    Inc(Dano, (Dano div 100) * mob.GetMobAbility(EF_AMP_PHYSICAL));

  if mob.GetMobAbility(EF_TYPE45) > 0 then
    Inc(Dano, (Dano div 100) * 10);

  if (Dano > 0) then
  begin
    if mob.BuffExistsByIndex(432) or mob.BuffExistsByIndex(123) or
      mob.BuffExistsByIndex(131) then
    begin
      Help1 := mob.GetMobAbility(EF_SKILL_ABSORB1);
      if Help1 > Dano then
      begin
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você absorveu o ataque em ' + Dano.ToString + ' pontos.');
        mob.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
        Dano := 0;
        DmgType := TDamageType.None;
      end
      else
      begin
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você absorveu o ataque em ' + Help1.ToString + ' pontos.');
        decInt(Dano, Help1);
        mob.RemoveBuffByIndex(432);
      end;
    end;

    if mob.BuffExistsByIndex(142) then
    begin
      Help1 := mob.GetMobAbility(EF_SKILL_ABSORB2);
      if Help1 > Dano then
      begin
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você absorveu o ataque em ' + Dano.ToString + ' pontos.');
        mob.DecreasseMobAbility(EF_SKILL_ABSORB2, Dano);
        Dano := 0;
        DmgType := TDamageType.None;
      end
      else
      begin
        Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você absorveu o ataque em ' + Help1.ToString + ' pontos.');
        decInt(Dano, Help1);
        mob.RemoveBuffByIndex(142);
      end;
    end;

    if mob.BuffExistsByIndex(101) then
    begin
      Help1 := (Dano div 100) * mob.GetMobAbility(EF_HP_CONVERSION);
      if DWORD(Help1) >= mob.Character.CurrentScore.CurMP then
      begin
        mob.RemoveMP(Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY)
          div 100), True);
        mob.RemoveBuffByIndex(101);
      end
      else
        mob.RemoveMP(Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY)
          div 100), True);

      decInt(Dano, Help1);
    end;

    if mob.BuffExistsByIndex(32) then
    begin
      decInt(Dano, (Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE));
      mob.DefesaPoints := mob.DefesaPoints - 1;
      if mob.DefesaPoints = 0 then
        mob.RemoveBuffByIndex(32);
    end;

    if mob.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '') then
    begin
      Helper := Dano;
      decInt(Dano, (Dano div 100) * mob.GetMobAbility(EF_TRANSFER));
      decInt(Helper, Dano);

      OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);
      if Assigned(OtherPlayer) and not OtherPlayer.Base.IsDead and
        (OtherPlayer.Status >= Playing) then
      begin
        OtherPlayer.Base.RemoveHP(Helper, True, True);
        OtherPlayer.SendClientMessage('Seu HP foi consumido em ' +
          Helper.ToString + ' pontos pelo buff [União Divina] no membro <' +
          AnsiString(OtherPlayer.Base.Character.Name) + '>.', 16);
      end;

      decInt(mob.MOB_EF[EF_TRANSFER_LIMIT], Helper);
      if mob.MOB_EF[EF_TRANSFER_LIMIT] = 0 then
      begin
        mob.RemoveBuffByIndex(35);
        mob.UniaoDivina := '';
      end;
    end;

    if mob.BuffExistsByIndex(460) and (Dano > mob.Character.CurrentScore.CurHP)
    then
    begin
      mob.RemoveBuffByIndex(460);
      mob.RemoveAllDebuffs;
      mob.ResolutoPoints := 0;
      mob.Character.CurrentScore.CurHP :=
        (mob.Character.CurrentScore.MaxHP div 100) * 30;
      mob.Character.CurrentScore.CurMP :=
        (mob.Character.CurrentScore.MaxMP div 100) * 25;
      mob.SendCurrentHPMP(True);
      Servers[Self.ChannelId].Players[mob.ClientID].SendClientMessage
        ('Você foi revivido graças ao buff [Pedra da Alma].');
    end;

    if mob.BuffExistsByIndex(80) then
      Inc(Dano, mob.GetMobAbility(EF_ADD_DAMAGE1));

    if mob.ResolutoPoints > 0 then
    begin
      if SecondsBetween(Now, mob.ResolutoTime) >= 8 then
        mob.ResolutoPoints := 0
      else if AddBuff then
      begin
        mob.ResolutoPoints := mob.ResolutoPoints - 1;
        MobAnimation := 26;
        mob.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
      end;
    end;
  end;

  case Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobType - 1024 of
    0:
      if mob.GetMobAbility(EF_DEF_ALIEN) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_ALIEN)));
    1:
      if mob.GetMobAbility(EF_DEF_BEAST) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_BEAST)));
    2:
      if mob.GetMobAbility(EF_DEF_PLANT) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_PLANT)));
    3:
      if mob.GetMobAbility(EF_DEF_INSECT) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_INSECT)));
    4:
      if mob.GetMobAbility(EF_DEF_DEMON) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_DEMON)));
    5:
      if mob.GetMobAbility(EF_DEF_UNDEAD) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_UNDEAD)));
    6:
      if mob.GetMobAbility(EF_DEF_COMPLEX) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_COMPLEX)));
    7:
      if mob.GetMobAbility(EF_DEF_STRUCTURE) > 0 then
        decInt(Dano, Round((Dano / 100) * mob.GetMobAbility(EF_DEF_STRUCTURE)));
  end;

  if Dano < 0 then
    Dano := 1;
end;

procedure TBaseNpc.Effect5Skill(mob: PBaseNpc; EffCount: Byte;
  xPassive: Boolean);
var
  Packet: TRecvDamagePacket;
  Skill: Integer;
  i, cnt: Integer;
  FRand: Integer;
  PList: Array [0 .. 2] of WORD;
  MobsP: PMobSPoisition;
begin
  if (EffCount > 1) then
  begin
    ZeroMemory(@PList, 6);
    cnt := 0;
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        PList[cnt] := EFF_5[i];
        Inc(cnt);
      end;
    end;
    Randomize;
    FRand := RandomRange(1, (cnt + 1));
    Skill := PList[FRand - 1];
  end
  else
  begin
    for i := 0 to 2 do
    begin
      if (EFF_5[i] > 0) then
      begin
        Skill := EFF_5[i];
        Break;
      end;
    end;
  end;

  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := SkillData[Skill].Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.MobAnimation := SkillData[Skill].TargetAnimation;

  if ((SkillData[Skill].TargetType = 21) and not(xPassive)) then
  begin
    Packet.TargetID := mob^.ClientID;
    Self.TargetBuffSkill(Skill, SkillData[Skill].Anim, mob, @SkillData[Skill]);
    Packet.Dano := (PlayerCharacter.Base.CurrentScore.DNFis +
      PlayerCharacter.Base.CurrentScore.DNMAG) div 3;

    if (SkillData[Skill].Damage > 0) then
      Packet.Dano := Packet.Dano + SkillData[Skill].Damage;

    Packet.DnType := TDamageType.Critical;

    if (SkillData[Skill].Adicional > 0) then
      Packet.Dano := Packet.Dano * 2;

    if (Packet.Dano >= 20000) then
      Packet.Dano := 20000;

    Randomize;
    Packet.Dano := Packet.Dano + RandomRange(20, 200);

    if (SkillData[Skill].Index = 180) then
      mob.RemoveBuff(mob.GetBuffToRemove);

    if (mob^.ClientID >= 3048) then
    begin
      case mob^.ClientID of
        3340 .. 3354: // stones
          begin
            if (Packet.Dano >= Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) then
              Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100
            else
              deccardinal(Servers[Self.ChannelId].DevirStones[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);

            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Packet.TargetID := Servers[Self.ChannelId].DevirStones
              [mob^.ClientID].Base.ClientID;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;
          end;

        3355 .. 3369: // guards
          begin
            if (Packet.Dano >= Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP) then
              Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP := 100
            else
              deccardinal(Servers[Self.ChannelId].DevirGuards[mob^.ClientID]
                .PlayerChar.Base.CurrentScore.CurHP, Packet.Dano);

            mob^.LastReceivedAttack := Now;
            Packet.MobCurrHP := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].PlayerChar.Base.CurrentScore.CurHP;
            Packet.TargetID := Servers[Self.ChannelId].DevirGuards
              [mob^.ClientID].Base.ClientID;
            Self.SendToVisible(Packet, Packet.Header.size);
            Exit;
          end;
      else
        begin
          MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];
          if (Packet.Dano >= MobsP^.HP) then
            MobsP^.HP := 10
          else
            deccardinal(MobsP^.HP, Packet.Dano);

          mob^.LastReceivedAttack := Now;
          Packet.MobCurrHP := MobsP^.HP;
          Packet.TargetID := MobsP.Base.ClientID;
          Self.SendToVisible(Packet, Packet.Header.size, True);
        end;
      end;
    end
    else
    begin
      if (Packet.Dano >= mob^.Character.CurrentScore.CurHP) then
        mob^.Character.CurrentScore.CurHP := 100
      else
        mob^.RemoveHP(Packet.Dano, false);

      mob^.LastReceivedAttack := Now;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
      Packet.TargetID := mob.ClientID;
      Self.SendToVisible(Packet, Packet.Header.size, True);
    end;
  end
  else
  begin
    if not(SkillData[Skill].TargetType = 21) then
    begin
      Packet.TargetID := Self.ClientID;
      Packet.AttackerID := 0;
      Packet.Dano := 0;
      Packet.DnType := TDamageType.None;
      Packet.MobAnimation := SkillData[Skill].TargetAnimation;
      Self.SelfBuffSkill(Skill, SkillData[Skill].Anim, mob,
        TPosition.Create(0, 0));
      Packet.MobCurrHP := Self.Character.CurrentScore.CurHP;
      Self.SendToVisible(Packet, Packet.Header.size);
    end;
  end;
end;

function TBaseNpc.IsSecureArea(): Boolean;
var
  i: Integer;
begin
  Result := false;
  for i := 0 to 9 do
  begin
    { if(Servers[Self.ChannelId].SecureAreas[i].IsActive) then
      begin
      if(Servers[Self.ChannelId].SecureAreas[i].Position.InRange(
      Self.PlayerCharacter.LastPos, 8)) then
      begin
      Result := True;
      end;
      end; }
  end;
end;

procedure TBaseNpc.WarriorSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    ATAQUE_PODEROSO:
      Dano := Self.GetDamage(Skill, mob, DmgType);

    AVANCO_PODEROSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType, STUN_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;

        case mob.ClientID of
          1 .. 1000:
            Self.WalkAvanced(mob.PlayerCharacter.LastPos, Skill);
          3048 .. 9147:
            case mob.ClientID of
              3340 .. 3354:
                Self.WalkAvanced(Servers[Self.ChannelId].DevirStones
                  [mob.ClientID].PlayerChar.LastPos, Skill);
              3355 .. 3369:
                Self.WalkAvanced(Servers[Self.ChannelId].DevirGuards
                  [mob.ClientID].PlayerChar.LastPos, Skill);
            else
              Self.WalkAvanced(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid]
                .MobsP[mob.SecondIndex].CurrentPos, Skill);
            end;
        end;
      end;

    QUEBRAR_ARMADURA, INCITAR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType) then
          CanDebuff := True;
      end;

    RESOLUTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType, 0, mob, Dano) then
        begin
          mob.ResolutoPoints := SkillData[Skill].Damage;
          mob.ResolutoTime := Now;
          mob.TargetBuffSkill(209, 0, mob, @SkillData[209]);
        end;
      end;

    ESTOCADA:
      begin
        Dano := 0;
        if Self.ValidAttack(DmgType, 0, mob, Dano) then
        begin
          mob.TargetBuffSkill(321, Anim, mob, @SkillData[321]);
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;

    FERIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType, SILENCE_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    PANCADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType, 0) then
          Inc(Dano, (Self.Character.CurrentScore.CurHP div 100) *
            SkillData[Skill].Adicional);
      end;
  end;
end;

procedure TBaseNpc.TemplarSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  Dano := Self.GetDamage(Skill, mob, DmgType);

  case SkillData[Skill].Index of
    STIGMA, NEMESIS, TRAVAR_ALVO:
      if Self.ValidAttack(DmgType) then
        CanDebuff := True;

    PROFICIENCIA:
      if Self.ValidAttack(DmgType, STUN_TYPE, mob) then
        CanDebuff := True
      else
        Resisted := True;

    ATRACAO_DIVINA:
      begin
        if Self.ValidAttack(DmgType, STUN_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;

        if mob.ClientID >= 3048 then
          Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
            [mob.SecondIndex].CurrentPos)
        else
          Self.WalkinTo(mob.PlayerCharacter.LastPos);
      end;

    CARGA_DIVINA:
      begin
        if Self.ValidAttack(DmgType) then
          CanDebuff := True;

        case mob.ClientID of
          1 .. 1000:
            Self.WalkinTo(mob.PlayerCharacter.LastPos);

          3048 .. 9147:
            case mob.ClientID of
              3340 .. 3354:
                Self.WalkinTo(Servers[Self.ChannelId].DevirStones[mob.ClientID]
                  .PlayerChar.LastPos);

              3355 .. 3369:
                Self.WalkinTo(Servers[Self.ChannelId].DevirGuards[mob.ClientID]
                  .PlayerChar.LastPos);

            else
              Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
                [mob.SecondIndex].CurrentPos);
            end;
        end;
      end;
  end;
end;

procedure TBaseNpc.RiflemanSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;
begin
  case SkillData[Skill].Index of
    ELIMINACAO, MARCA_PERSEGUIDOR:
      begin
        Dano := 0;
        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;
        if (mob.BuffExistsByIndex(19) or mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(IfThen(mob.BuffExistsByIndex(19), 19, 91));
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(IfThen(mob.BuffExistsByIndex(19), 19, 91));
            DmgType := IfThen(mob.BuffExistsByIndex(19), TDamageType.Block,
              TDamageType.Miss2);
            Exit;
          end;
        end;

        DmgType := Self.GetDamageType3(Skill, True, mob);

        if (SkillData[Skill].Index = ELIMINACAO) then
        begin
          if (ValidAttack(DmgType, 0, mob, 0)) then
            mob.RemoveBuffs(1);
        end
        else if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
          CanDebuff := True;
      end;

    TIRO_FATAL, TIRO_ANGULAR, TIRO_NA_PERNA, PRIMEIRO_ENCONTRO, PONTO_VITAL,
      ELIMINAR_ALVO, CONTRA_GOLPE, ATAQUE_ATORDOANTE, INSPIRAR_MATANCA,
      SENTENCA, POSTURA_FANTASMA, DESTINO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, IfThen(SkillData[Skill].Index
          in [PRIMEIRO_ENCONTRO, PONTO_VITAL, TIRO_NA_PERNA, ATAQUE_ATORDOANTE],
          STUN_TYPE, 0), mob)) then
        begin
          CanDebuff := True;

          case SkillData[Skill].Index of
            CONTRA_GOLPE:
              begin
                Helper := ((Dano div 100) * SkillData[Skill].Adicional);
                Inc(Dano, Helper);
                DmgType := TDamageType.Critical;
              end;
            INSPIRAR_MATANCA:
              begin
                Helper := ((Dano div 100) * SkillData[Skill].Adicional);
                Inc(Self.Character.CurrentScore.CurHP, Helper);
                if (mob.ClientID <= MAX_CONNECTIONS) and
                  (Dano >= mob.Character.CurrentScore.CurHP) then
                begin
                  Inc(Self.Character.CurrentScore.CurHP,
                    ((Self.Character.CurrentScore.MaxHP div 100) * 25));
                end;
                Self.SendCurrentHPMP(True);
              end;
            SENTENCA:
              begin
                Randomize;
                if (Random(100) <= UInt64(SkillData[Skill].DamageRange - 20))
                then
                  Dano := Dano + Dano;
                Dano := Dano * 4;
              end;
            POSTURA_FANTASMA, DESTINO:
              begin
                Self.SelfBuffSkill(SkillData[Skill].Adicional, Anim, mob,
                  TPosition.Create(0, 0));
                if SkillData[Skill].Index = DESTINO then
                  Inc(Dano, (mob.Character.CurrentScore.DEFFis shr 3));
              end;
          end;
        end
        else if SkillData[Skill].Index in [TIRO_NA_PERNA, PRIMEIRO_ENCONTRO,
          ATAQUE_ATORDOANTE, PONTO_VITAL] then
          Resisted := True;
      end;
  end;
end;

procedure TBaseNpc.DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
var
  Helper: Int64;
begin
  case SkillData[Skill].Index of
    MJOLNIR, TIRO_DESCONTROLADO, VENENO_LENTIDAO, ESTRIPADOR, DOR_PREDADOR,
      BOMBA_MALDITA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True;
      end;

    ESPINHO_VENENOSO, REQUIEM, NEGAR_CURA:
      begin
        Dano := 0;
        DmgType := Self.GetDamageType3(Skill, True, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    VENENO_MANA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Helper := SkillData[Skill].Adicional;
          Inc(Dano, Helper);
          mob.RemoveMP(Helper, True);
          Self.AddMP(Helper, True);
          CanDebuff := True;
        end;
      end;

    CHOQUE_SUBITO:
      begin
        Dano := 0;
        DmgType := Normal;

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
          DmgType := TDamageType.Immune;

        if (mob.BuffExistsByIndex(19)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;

        if (mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if (Self.ValidAttack(DmgType, CHOCK_TYPE, mob, Dano)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    VENENO_HIDRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);

        if Skill = 219 then
        begin
          CanDebuff := True;
          Resisted := false;
        end
        else if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    CHOQUE_HIDRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, CHOCK_TYPE, mob)) then
        begin
          if mob^.Chocado then
          begin
            Helper := (Dano div 100) * SkillData[Skill].Adicional;
            Inc(Dano, Helper);
          end
          else
            CanDebuff := True;
        end
        else
          Resisted := True;

        Dano := Dano * 4;
      end;

    MORTE_DECIDIDA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Randomize;
          Helper := Random(100);
          if (Helper < 30) then
            Helper := 30;
          Helper := (((SkillData[Skill].Damage + 1000) div 100) * Helper);
          Inc(Dano, Helper);
        end;
      end;

    REACAO_CADEIA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          // a cada debuff = Dano + (Adicional * qnt de debuff)
        end;
      end;
  end;
end;

procedure TBaseNpc.MagicianSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    CHAMA_CAOTICA, INFERNO_CAOTICO, IMPEDIMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, IfThen(SkillData[Skill].
          Index = IMPEDIMENTO, SILENCE_TYPE, STUN_TYPE), mob)) then
        begin
          CanDebuff := True;
        end
        else
          Resisted := True;
      end;

    SOFRIMENTO, POLIMORFO, MAO_ESCURIDAO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, false, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;

    ONDA_CHOQUE, LANCA_RAIO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;

    CORROER:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Inc(Self.Character.CurrentScore.CurHP,
            (Dano div 100) * SkillData[Skill].Adicional);
          Self.SendCurrentHPMP(True);
        end;
      end;

    VINCULO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Self.RemoveHP((Dano div 100) * SkillData[Skill].Adicional, True);
        end;
      end;

    CRISTALIZAR_MANA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
        begin
          Inc(Dano, (Self.Character.CurrentScore.CurMP div 100) *
            SkillData[Skill].Adicional);
        end;
        Dano := Dano * 3;
      end;
  end;
end;

procedure TBaseNpc.ClericSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    FLECHA_SAGRADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType) then
          Inc(Dano, (Dano div 100) * SkillData[Skill].Adicional);
      end;

    RETORNO_MAGICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType) then
        begin
          Inc(Dano, SkillData[Skill].Adicional);
          mob.RemoveBuffs(SkillData[Skill].Damage);
        end;
      end;
  end;
end;

procedure TBaseNpc.WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; out MoveToTarget: Boolean);
begin
  case SkillData[Skill].Index of
    TEMPESTADE_LAMINA, SALTO_IMPACTO, LAMINA_CARREGADA, PODER_ABSOLUTO,
      POSTURA_FINAL:
      Dano := Self.GetDamage(Skill, mob, DmgType);

    AREA_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType, LENT_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    CANCAO_GUERRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType, STUN_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    GRITO_MEDO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, mob, DmgType);

        if mob.GetMobAbility(EF_IMMUNITY) > 0 then
          DmgType := TDamageType.Immune;

        if mob.BuffExistsByIndex(19) then
        begin
          if Self.GetMobAbility(EF_COUNT_HIT) > 0 then
          begin
            mob.RemoveBuffByIndex(19);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            DmgType := TDamageType.Block;
          end;
        end;

        if mob.BuffExistsByIndex(91) then
        begin
          if Self.GetMobAbility(EF_COUNT_HIT) > 0 then
          begin
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Miss2;
          end;
        end;

        if Self.ValidAttack(DmgType, FEAR_TYPE, mob, Dano) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    INVESTIDA_MORTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);

        if (mob.ClientID >= 3355) and (mob.ClientID <= 3369) then
          Exit;

        if Self.ValidAttack(DmgType, LENT_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;

        Self.WalkinTo(mob.PlayerCharacter.LastPos);

        if (mob.ClientID >= 1) and (mob.ClientID <= 1000) then
          Self.WalkinTo(mob.PlayerCharacter.LastPos)
        else if (mob.ClientID >= 3048) and (mob.ClientID <= 9147) then
        begin
          if (mob.ClientID >= 3340) and (mob.ClientID <= 3354) then
            Self.WalkinTo(Servers[Self.ChannelId].DevirStones[mob.ClientID]
              .PlayerChar.LastPos)
          else if not((mob.ClientID >= 3355) and (mob.ClientID <= 3369)) then
            Self.WalkinTo(Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
              [mob.SecondIndex].CurrentPos);
        end;
      end;

    LIMITE_BRUTAL:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if Self.ValidAttack(DmgType) then
          CanDebuff := True;
      end;
  end;
end;

procedure TBaseNpc.TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    INCITAR_MULTIDAO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, mob, DmgType);
        DmgType := Self.GetDamageType3(Skill, True, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
          DmgType := TDamageType.Immune;

        // Verificação de BuffExistsByIndex para 19 e 91
        if mob.BuffExistsByIndex(19) or mob.BuffExistsByIndex(91) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            if mob.BuffExistsByIndex(19) then
              mob.RemoveBuffByIndex(19);
            if mob.BuffExistsByIndex(91) then
              mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            if mob.BuffExistsByIndex(19) then
              mob.RemoveBuffByIndex(19);
            if mob.BuffExistsByIndex(91) then
              mob.RemoveBuffByIndex(91);

            // Define o DmgType dependendo do Buff
            if mob.BuffExistsByIndex(19) then
              DmgType := TDamageType.Block
            else if mob.BuffExistsByIndex(91) then
              DmgType := TDamageType.Miss2;
          end;
        end;

        if (Self.ValidAttack(DmgType, 0, mob, Dano, True)) then
        begin
          if (mob.BuffExistsByIndex(53)) then
            mob.RemoveBuffByIndex(53);
          if (mob.BuffExistsByIndex(77)) then
            mob.RemoveBuffByIndex(77);
        end;
      end;

    EMISSAO_DIVINA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    LAMINA_PROMESSA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;

    SANTUARIO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True;
      end;

    CRUZ_JULGAMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;

    ESCUDO_VINGADOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
  end;
end;

procedure TBaseNpc.RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  // Calcula o dano uma única vez
  Dano := Self.GetDamage(Skill, mob, DmgType);

  case SkillData[Skill].Index of
    CONTAGEM_REGRESSIVA, TIRO_ANGULAR_AREA, GOLPE_FANTASMA, NAPALM,
      ARMADILHA_MULTIPLA:
      begin
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True;
      end;

    DETONACAO, RAJADA_SONICA:
      begin
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;
  end;
end;

procedure TBaseNpc.DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  Dano := Self.GetDamage(Skill, mob, DmgType); // A única chamada para GetDamage

  case SkillData[Skill].Index of
    FUMACA_SANGRENTA, DISPARO_DEMOLIDOR:
      begin
        // Não há lógica adicional, já coberto pela atribuição de Dano
      end;
    EXPLOSAO_RADIANTE:
      begin
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;
    PONTO_CEGO, FESTIVAL_BALAS:
      begin
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True;
      end;
  end;
end;

procedure TBaseNpc.MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  Dano := Self.GetDamage(Skill, mob, DmgType);
  // Calcula o dano de forma geral no início

  case SkillData[Skill].Index of
    INFERNO_CAOTICO, ESPLENDOR_CAOTICO, QUEDA_NEGRA, PROEMINECIA, TEMPESTADE:
      begin
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    ENXAME_ESCURIDAO, EXPLOSAO_TREVAS, TROVAO_RUINOSO, PORTAO_ABISSAL:
      begin
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    ECLATER:
      begin
        DmgType := Self.GetDamageType3(Skill, false, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
          CanDebuff := True;
      end;

    BRUMA:
      begin
        DmgType := Self.GetDamageType3(Skill, false, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
          DmgType := TDamageType.Immune;

        if (mob.BuffExistsByIndex(19) or mob.BuffExistsByIndex(91)) then
        begin
          // Remoção de buffs e contagem de hits
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            if (mob.BuffExistsByIndex(19)) then
              mob.RemoveBuffByIndex(19);
            if (mob.BuffExistsByIndex(91)) then
              mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            if (mob.BuffExistsByIndex(19)) then
              mob.RemoveBuffByIndex(19);
            if (mob.BuffExistsByIndex(91)) then
              mob.RemoveBuffByIndex(91);
            DmgType := TDamageType.Block;
          end;
        end;

        if (Self.ValidAttack(DmgType, STUN_TYPE, mob, Dano, True)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    PECADOS_MORTAIS:
      begin
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
        begin
          CanDebuff := True;
          Self.SKDListener := True;
          Self.SKDAction := 2;
          Self.SKDSkillID := Skill;
          Self.SKDTarget := mob.ClientID;
          Self.SKDSkillEtc1 := SkillData[Skill].EFV[0];
        end
        else
          Resisted := True;
      end;

    TEMPESTADE_RAIOS:
      begin
        Self.UsingLongSkill := True;
        if (Self.ValidAttack(DmgType, LENT_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    FURACAO_NEGRO:
      begin
        if (Self.ValidAttack(DmgType, STUN_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;
  end;
end;

procedure TBaseNpc.ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseNpc;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean);
begin
  case SkillData[Skill].Index of
    SENSOR_MAGICO, RAIO_SOLAR:
      begin
        Dano := 0;
        DmgType := Self.GetDamageType3(Skill, false, mob);

        if (mob.GetMobAbility(EF_IMMUNITY) > 0) then
        begin
          DmgType := TDamageType.Immune;
          Exit;
        end;

        if (mob.BuffExistsByIndex(19) or mob.BuffExistsByIndex(91)) then
        begin
          if (Self.GetMobAbility(EF_COUNT_HIT) > 0) then
          begin
            mob.RemoveBuffByIndex(19);
            mob.RemoveBuffByIndex(91);
            Self.DecreasseMobAbility(EF_COUNT_HIT, 1);
          end
          else
          begin
            mob.RemoveBuffByIndex(19);
            mob.RemoveBuffByIndex(91);
            if (mob.BuffExistsByIndex(19)) then
              DmgType := TDamageType.Block;
            if (mob.BuffExistsByIndex(91)) then
              DmgType := TDamageType.Miss2;
            Exit;
          end;
        end;

        if (Skill = RAIO_SOLAR) then
        begin
          if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
            CanDebuff := True;
        end
        else if (Self.ValidAttack(DmgType, 0, mob, Dano)) then
        begin
          if (mob.BuffExistsByIndex(53)) then
            mob.RemoveBuffByIndex(53);
          if (mob.BuffExistsByIndex(77)) then
            mob.RemoveBuffByIndex(77);
        end;
      end;
    UEGENES_LUX:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
      end;
    CRUZ_PENITENCIAL, EDEN_PIEDOSO, DIXIT:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType);
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True;
      end;
  end;
end;

{$ENDREGION}
{$REGION 'Effect Functions'}

procedure TBaseNpc.SendEffect(EffectIndex: DWORD);
var
  Packet: TSendClientIndexPacket;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $117;
  Packet.Index := Self.ClientID;
  Packet.Effect := EffectIndex;
  Self.SendToVisible(Packet, Packet.Header.size);
end;

{$ENDREGION}
{$REGION 'Move/Teleport'}

procedure TBaseNpc.Teleport(Pos: TPosition);
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  Self.SendCreateMob;
  // Self.UpdateVisibleList;
end;

procedure TBaseNpc.Teleport(Posx, Posy: WORD);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;

procedure TBaseNpc.Teleport(Posx, Posy: string);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;

procedure TBaseNpc.WalkTo(Pos: TPosition; speed: WORD; MoveType: Byte);
var
  Packet: TMovementPacket;
begin
  if not(Pos.IsValid) then
    Exit;

  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := MoveType;
  Packet.speed := speed;

  Self.SendToVisible(Packet, Packet.Header.size, True);
  // Self.UpdateVisibleList;
  Writeln('passando pela funcao WalkTo no BaseMob');
end;

procedure TBaseNpc.WalkAvanced(Pos: TPosition; SkillID: Integer);
var
  Packet: TMovementPacket;
begin
  if not(Pos.IsValid) then
    Exit;

  if (Self.PlayerCharacter.LastPos.Distance(Pos) > 18) then
    Exit;

  Self.PlayerCharacter.LastPos := Pos;
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $301;
  Packet.Destination := Pos;
  Packet.MoveType := 0;
  Packet.Unk := SkillID;
  Packet.speed := 125; // era 125

  Self.SendToVisible(Packet, Packet.Header.size, True);
  // Self.UpdateVisibleList;
  Writeln('passando pela funcao WalkAvanced no BaseMob');
end;

procedure TBaseNpc.WalkBacked(Pos: TPosition; SkillID: Integer; mob: PBaseNpc);
var
  PacketAtk: TRecvDamagePacket;
  PacketMove: TMovementPacket;
begin
  ZeroMemory(@PacketMove, SizeOf(PacketMove));
  PacketMove.Header.size := SizeOf(PacketMove);
  PacketMove.Header.Index := mob.ClientID;
  PacketMove.Header.Code := $301;
  PacketMove.Destination := Pos;
  mob.PlayerCharacter.LastPos := Pos;
  PacketMove.MoveType := 0;
  PacketMove.Unk := SkillID;
  PacketMove.speed := 15;

  ZeroMemory(@PacketAtk, SizeOf(PacketAtk));
  PacketAtk.Header.size := SizeOf(PacketAtk);
  PacketAtk.Header.Index := Self.ClientID;
  PacketAtk.Header.Code := $102;
  PacketAtk.SkillID := SkillID;
  PacketAtk.AttackerPos := Self.PlayerCharacter.LastPos;
  PacketAtk.AttackerID := Self.ClientID;
  PacketAtk.Animation := SkillData[SkillID].Anim;
  PacketAtk.AttackerHP := Self.Character.CurrentScore.CurHP;
  PacketAtk.TargetID := mob.ClientID;
  PacketAtk.MobAnimation := SkillData[SkillID].TargetAnimation;
  PacketAtk.DnType := TDamageType.None;
  PacketAtk.Dano := 0;
  PacketAtk.MobCurrHP := mob.Character.CurrentScore.CurHP;
  PacketAtk.DeathPos := mob.PlayerCharacter.LastPos;

  Self.SendToVisible(PacketAtk, PacketAtk.Header.size, True);
  mob.SendToVisible(PacketMove, PacketMove.Header.size, True);
  // mob.UpdateVisibleList;
  Writeln('passando pela funcao WalkBacked no BaseMob');
end;

{$ENDREGION}
{$REGION 'Pets'}

procedure TBaseNpc.CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD);
var
  pId: Integer;
  // pet: TPet;
begin
  // Exit;
  // pId := TFunctions.FreePetId(Self.ChannelId);
  // pet := Servers[Self.ChannelId].PETS[pId];
  // ZeroMemory(@pet, sizeof(TPet));
  // Self.PetClientID := pId;
  // pet.Base.Create(nil, pId, Self.ChannelId);
  // pet.Base.PlayerCharacter.Base.ClientID := pet.Base.ClientID;
  //
  // case PetType of
  // X14:
  // begin
  // with pet.Base.PlayerCharacter.Base do
  // begin
  // CurrentScore.MaxHP := (SkillData[SkillID].Attribute div 5);
  // CurrentScore.CurHP := CurrentScore.MaxHP;
  // CurrentScore.MaxMP := CurrentScore.MaxHP;
  // CurrentScore.CurMP := CurrentScore.MaxMP;
  // CurrentScore.DNFis := ((SkillData[SkillID].Attribute div 10) div 4);
  // CurrentScore.DNMAG := CurrentScore.DNFis;
  // CurrentScore.DEFFis := ((SkillData[SkillID].Attribute div 10) div 2);
  // CurrentScore.DEFMAG := CurrentScore.DEFFis;
  // Equip[0].Index := 328; // x14 face
  // Equip[1].Index := 328;
  // CurrentScore.Sizes.Altura := 7;
  // CurrentScore.Sizes.Tronco := $77;
  // CurrentScore.Sizes.Perna := $77;
  // CurrentScore.Sizes.Corpo := 0;
  // Exp := 1;
  // Level := Self.PlayerCharacter.Base.Level;
  // end;
  //
  // pet.PetType := X14;
  // pet.Duration := SkillData[SkillID].Duration;
  // pet.IntName := SkillData[SkillID].EFV[0];
  // end;
  // NORMAL_PET:
  // begin
  // with pet.Base.PlayerCharacter.Base do
  // begin
  // CurrentScore.MaxHP := ItemList[SkillID].HP;
  // CurrentScore.CurHP := CurrentScore.MaxHP;
  // CurrentScore.MaxMP := CurrentScore.MaxHP;
  // CurrentScore.CurMP := CurrentScore.MaxMP;
  // CurrentScore.DNFis := ItemList[SkillID].ATKFis * 2;
  // CurrentScore.DNMAG := CurrentScore.DNFis;
  // CurrentScore.DEFFis := ItemList[SkillID].MagATK * 2;
  // CurrentScore.DEFMAG := CurrentScore.DEFFis;
  // Equip[0].Index := ItemList[SkillID].Duration; // duration will be the mob face
  // Equip[1].Index := ItemList[SkillID].Duration;
  // CurrentScore.Sizes.Altura := ItemList[SkillID].TextureID;
  // CurrentScore.Sizes.Tronco := ItemList[SkillID].TextureID * ItemList[SkillID].MeshIDWeapon;
  // CurrentScore.Sizes.Perna := ItemList[SkillID].TextureID * ItemList[SkillID].MeshIDWeapon;
  // CurrentScore.Sizes.Corpo := ItemList[SkillID].TextureID * ItemList[SkillID].MeshIDWeapon;
  // Exp := 1;
  // Level := 50;
  // end;
  //
  // pet.PetType := NORMAL_PET;
  // pet.Duration := 0;
  // pet.IntName := ItemList[SkillID].DelayUse;
  // end;
  // end;
  //
  // pet.Base.PlayerCharacter.LastPos := Pos;
  // pet.MasterClientID := Self.ClientID;
end;

procedure TBaseNpc.DestroyPet(PetID: WORD);
var
  i: Integer;
begin
  // Servers[Self.ChannelId].Players[Self.ClientID].UnSpawnPet(PetID);
  // for i in Self.VisiblePlayers do
  // Servers[Self.ChannelId].Players[i].UnSpawnPet(PetID);
  //
  // ZeroMemory(@Servers[Self.ChannelId].PETS[PetID], sizeof(TPet));
end;

{$ENDREGION}

end.
