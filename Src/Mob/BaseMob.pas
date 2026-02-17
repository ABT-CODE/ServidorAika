unit BaseMob;

interface

{$OPTIMIZATION ON}  // Ativa otimizações gerais
{$O+}

// Ativa otimização de loops
uses
  Windows, PlayerData, Diagnostics, Generics.Collections, Packets, SysUtils,
  MiscData, AnsiStrings, FilesData, Math, sql;
{$OLDTYPELAYOUT ON}

type
  PBaseMob = ^TBaseMob;

  TBaseMob = record
  private
    // _prediction: TPrediction;
    _cooldown: TDictionary<WORD, TTime>;
    _buffs: TDictionary<WORD, TDateTime>;
    // _currentPosition: TPosition;
    procedure AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
    procedure RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);
  public
    IsDead: Boolean;
    ClientID: WORD;
    PranClientID: WORD;
    PetClientID: WORD;
    Character: PCharacter;
    PlayerCharacter: TPlayerCharacter;
    AttackSpeed: WORD;
    IsActive: Boolean;
    IsDirty: Boolean;
    Mobbaby: WORD;
    PartyId: WORD;
    PartyRequestId: WORD;
    VisibleMobs: TList<WORD>;
    VisibleNPCS: TList<WORD>;
    VisiblePlayers: TList<WORD>;
    TimeForGoldTime: TDateTime;
    VisibleTargets: Array of TMobTarget;
    VisibleTargetsCnt: WORD; // aqui vai ser o controle da lista propia
    LastTimeGarbaged: TDateTime;
    target: PBaseMob;
    IsDungeonMob: Boolean;
    InClastleVerus: Boolean;
    LastReceivedSkillFromCastle: TDateTime;
    PositionSpawnedInCastle: TPosition;
    NationForCastle: Byte;
    NpcIdGen: WORD;
    NpcQuests: Array [0 .. 7] of TQuestMisc;
    PersonalShopIndex: DWORD;
    PersonalShop: TPersonalShopData;
    MOB_EF: ARRAY [0 .. 395] OF Integer;
    EQUIP_CONJUNT: ARRAY [0 .. 15] OF WORD;
    EFF_5: Array [0 .. 2] of WORD; // podemos ter at? 3 efeitos 5
    IsPlayerService: Boolean;
    ChannelId: Byte;
    Neighbors: Array [0 .. 8] of TNeighbor;
    EventListener: Boolean;
    EventAction: Byte;
    EventSkillID: WORD;
    EventSkillEtc1: WORD;
    HPRListener: Boolean; // HPR = HP Recovery
    HPRAction: Byte;
    HPRSkillID: WORD;
    HPRSkillEtc1: WORD;
    SKDListener: Boolean; // SKD = Skill Damage
    SKDAction: Byte;
    SKDSkillID: WORD;
    SKDTarget: WORD;
    SKDSkillEtc1: WORD;
    SKDIsMob: Boolean;
    SDKMobID, SDKSecondIndex: WORD;
    Mobid: WORD;
    SecondIndex: WORD;
    IsBoss: Boolean;
    IsNormalBoss: Boolean;
    IsFinalBoss: Boolean;
    { Skill }
    Chocado: Boolean; // definir quando usa o choque hidra
    LastBasicAttack: TDateTime;
    LastAttackMsg: TDateTime;
    AttackMsgCount: Integer;
    UsingSkill: WORD;
    ResolutoPoints: Byte;
    ResolutoTime: TDateTime;
    DefesaPoints: Byte;
    DefesaPoints2: Byte;
    BolhaPoints: Byte;
    LaminaID: WORD;
    LaminaPoints: WORD;
    Polimorfed: Boolean;
    UsingLongSkill: Boolean;
    LongSkillTimes: WORD;
    UniaoDivina: String;
    SessionOnline: Boolean;
    SessionUsername: String;
    SessionMasterPriv: TMasterPrives;
    MissCount: WORD;
    NegarCuraCount: Integer;
    RevivedTime: TDateTime;
    CurrentAction: Integer;
    LastSplashTime: TDateTime;

    ActiveTitle: Integer;
    LastReceivedAttack: TDateTime;
    LastMovedTime: TDateTime;
    LastMovedMessageHack: TDateTime;
    AttacksAccumulated, AttacksReceivedAccumulated: Integer;
    DroppedCount: Integer;
    { TBaseMob }

    procedure Create(characterPointer: PCharacter; Index: WORD; ChannelId: Byte;
      act: Boolean = false); overload;
    procedure Destroy(Aux: Boolean = false);
    function IsPlayer: Boolean;
    procedure UpdateVisibleList(SpawnType: Byte = 0);
    procedure UpdateVisibleLeopold(SpawnType: Byte = 0);
    procedure UpdateVisibleCastle(SpawnType: Byte = 0);
    procedure UpdateVisibleDungeon(SpawnType: Byte = 0);

    procedure UpdateVisibleElter(SpawnType: Byte = 0);
    // function CurrentPosition: TPosition;
    // procedure SetDestination(const Destination: TPosition);
    procedure addvisible(m: TBaseMob);
    procedure removevisible(m: TBaseMob);
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
      SendSelf: Boolean = True; Polimorf: WORD = 0; Custom: Integer = 0);
    procedure SendRemoveMob(delType: Integer = 0; sendTo: WORD = 0;
      SendSelf: Boolean = True);
    procedure SendToVisible(var Packet; size: WORD; sendToSelf: Boolean = True);
    procedure SendPacket(var Packet; size: WORD);
    procedure SendRefreshLevel;
    procedure SendCurrentHPMP(Update: Boolean = false);
    procedure SendCurrentHPMPItem;
    procedure SendCurrentHPMPLogin(Update: Boolean);
    procedure SendCurrentHPMPMob();
    procedure SendStatus;
    procedure SendRefreshPoint;
    procedure SendRefreshKills;
    procedure SendEquipItems(SendSelf: Boolean = True);
    procedure SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
      Notice: Boolean); overload;
    procedure SendRefreshBala(SlotItem: WORD; Item: TItem); overload;

    procedure SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean); overload;
    procedure SendSpawnMobs;
    procedure GenerateBabyMob;
    procedure UngenerateBabyMob(ungenEffect: WORD);
    function AddTargetToList(target: PBaseMob): Boolean;
    function RemoveTargetFromList(target: PBaseMob): Boolean;
    function ContainsTargetInList(target: PBaseMob; out id: WORD)
      : Boolean; overload;
    function ContainsTargetInList(ClientID: WORD): Boolean; overload;
    function ContainsTargetInList(ClientID: WORD; out id: WORD)
      : Boolean; overload;
    function GetEmptyTargetInList(out Index: WORD): Boolean;
    function GetTargetInList(ClientID: WORD): PBaseMob;
    function ClearTargetList(): Boolean;
    function TargetGarbageService(): Boolean;
    { Get's }
    procedure GetCreateMob(out Packet: TSendCreateMobPacket; P1: WORD;
      Custom: Integer = 0); overload;
    class function GetMob(Index: WORD; Channel: Byte; out mob: TBaseMob)
      : Boolean; overload; static;
    class function GetMob(Index: WORD; Channel: Byte; out mob: PBaseMob)
      : Boolean; overload; static;
    { class function GetMob(Pos: TPosition; Channel: Byte; out mob: TBaseMob)
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
    function GetMobClass(ClassInfo: WORD = 0): WORD;
    function GetMobClassPlayer: Byte;
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
    function BuffExistsByIndex(BuffIndex: WORD): Boolean;
    function GetBuffLeveL(BuffIndex: DWORD): Integer;
    function BuffExistsByIndexDungeon(BuffIndex: DWORD;
      Player: PBaseMob): Boolean;
    function BuffExistsByID(BuffID: DWORD): Boolean;
    function BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
    function BuffExistsSopa(): Boolean;
    function GetBuffIDByIndex(Index: DWORD): WORD;
    procedure RemoveBuffs(Quant: Byte);
    procedure RemoveDebuffs(Quant: Byte);
    procedure ZerarBuffs();
    { Attack & Skills }
    procedure CheckCooldown(var Packet: TSendSkillUse);
    function CheckCooldown3(var Packet: TSendSkillUse): Boolean;
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

    procedure SendDamage(Skill: WORD; Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData; Tipo: Byte);
    function GetDamage(Skill: WORD; mob: PBaseMob; out DnType: TDamageType;
      Tipo: Byte): UInt64;
    function GetDamageType(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    function GetDamageType2(Skill: DWORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    function GetDamageType3(Skill: WORD; IsPhysical: Boolean; mob: PBaseMob)
      : TDamageType;
    procedure CalcAndCure(Skill: DWORD; mob: PBaseMob);
    function CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
    function CalcCure2(BaseCure: DWORD; mob: PBaseMob;
      xSkill: Integer = 0): Integer;
    procedure HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
      SelectedPos: TPosition; DataSkill: P_SkillData; Tipo: Byte);
    function ValidAttack(DmgType: TDamageType; DebuffType: Byte = 0;
      mob: PBaseMob = nil; AuxDano: Integer = 0;
      xisBoss: Boolean = false): Boolean;
    procedure MobKilledInDungeon(mob: PBaseMob);
    procedure MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
      out DroppedItem: Boolean; InParty: Boolean = false);
    procedure DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob);
    procedure PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
    { Parses }
    procedure SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob; Pos: TPosition);
    procedure TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
      DataSkill: P_SkillData; Posx: DWORD = 0; Posy: DWORD = 0);
    procedure TargetSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean;
      Tipo: Byte);
    procedure AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
      Packet: TRecvDamagePacket);
    procedure AreaSkill(Skill, Anim: DWORD; mob: PBaseMob; SkillPos: TPosition;
      DataSkill: P_SkillData; DamagePerc: Single = 0; ElThymos: Integer = 0;
      Tipo: Byte = 9);
    procedure AttackParse(Skill: WORD; Anim: DWORD; mob: PBaseMob;
      var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
      out MobAnimation: Byte; DataSkill: P_SkillData; Tipo: Byte);
    procedure AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob;
      var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
      out MobAnimation: Byte);
    procedure Effect5Skill(mob: PBaseMob; EffCount: Byte;
      xPassive: Boolean = false);
    function IsSecureArea(): Boolean;
    { Skill classes handle }
    procedure WarriorSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean;
      Tipo: Byte);
    procedure TemplarSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean;
      Tipo: Byte);
    procedure RiflemanSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    procedure DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    procedure MagicianSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    procedure ClericSkill(Skill, Anim: DWORD; mob: PBaseMob; out Dano: Integer;
      out DmgType: TDamageType; var CanDebuff: Boolean; var Resisted: Boolean;
      Tipo: Byte);
    procedure WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; out MoveToTarget: Boolean; Tipo: Byte);
    procedure TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    procedure RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    procedure DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    procedure MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    procedure ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
      out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
      var Resisted: Boolean; Tipo: Byte);
    { Effect Functions }
    procedure SendEffect(EffectIndex: DWORD);
    procedure SendEffectOther(Tipo: Integer; loop: cardinal);
    { Move/Teleport }
    procedure Teleport(Pos: TPosition); overload;
    procedure Teleport(Posx, Posy: WORD); overload;
    procedure Teleport(Posx, Posy: string); overload;
    procedure WalkTo(Pos: TPosition; speed: WORD = 70; MoveType: Byte = 0);
    procedure WalkAvanced(Pos: TPosition; SkillID: Integer);
    procedure WalkBacked(Pos: TPosition; SkillID: Integer; mob: PBaseMob);
    { Pets }
    // procedure CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD = 0);
    // procedure DestroyPet(PetID: WORD);
    { Class }
    // class procedure ForEachInRange(Pos: TPosition; range: Byte;
    // proc: TProc<TPosition, TBaseMob>; ChannelId: Byte); overload; static;
    // procedure ForEachInRange(range: Byte;
    // proc: TProc<TPosition, TBaseMob, TBaseMob>); overload;

  end;
{$REGION 'HP / MP Increment por level'}

const
  HPIncrementPerLevel: array [0 .. 5] of Integer = (75,
    // War (150 reduzido em 50%)
    70, // Tp (140 reduzido em 50%)
    57, // Att (115 reduzido em 50%)
    60, // Dual (120 reduzido em 50%)
    55, // Fc (110 reduzido em 50%)
    65 // Santa (130 reduzido em 50%)
    );

const
  MPIncrementPerLevel: array [0 .. 5] of Integer = (55,
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
  Player, GlobalDefs, Util, Log, ItemFunctions, Functions, DateUtils, mob, PET,
  PartyData, Objects, PacketHandlers, BaseNpc, Dungeon, NPC, GuildData;

{$REGION 'TBaseMob'}

procedure TBaseMob.Destroy(Aux: Boolean);
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
  ZeroMemory(@Self, SizeOf(TBaseMob));
end;

procedure TBaseMob.Create(characterPointer: PCharacter; Index: WORD;
  ChannelId: Byte; act: Boolean = false);
begin
  ZeroMemory(@Self, SizeOf(TBaseMob));

  // Inicialização das listas
  VisibleMobs := TList<WORD>.Create;
  VisibleNPCS := TList<WORD>.Create;
  VisiblePlayers := TList<WORD>.Create;
  SetLength(VisibleTargets, 1);

  // Inicialização de variáveis
  LastTimeGarbaged := Now;
  LastAttackMsg := Now;
  LastBasicAttack := Now;
  AttackMsgCount := 0;
  AttacksAccumulated := 0;
  DroppedCount := 0;
  AttacksReceivedAccumulated := 0;
  IsActive := True;
  IsDirty := false;
  LastReceivedSkillFromCastle := Now;
  InClastleVerus := false;

  Character := characterPointer;

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
  _buffs := TDictionary<WORD, TDateTime>.Create(40);

  // if act then
  // SetLength(Character^.Inventory, 64)
  // else
  // SetLength(Character^.Inventory, 126);

end;

function TBaseMob.IsPlayer: Boolean;
begin
  Result := IfThen(ClientID <= MAX_CONNECTIONS);
end;

procedure TBaseMob.UpdateVisibleElter(SpawnType: Byte = 0);
var
  Packet: TSendRemoveMobPacket;
  OtherPlayer, SelfPlayer: PPlayer;
  key: TPlayerKey;
begin
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  for Key in ActivePlayers.Keys do
  begin
  if Key.ServerID <> SelfPlayer^.ChannelIndex then
  continue;

  OtherPlayer:= @Servers[Key.ServerID].Players[Key.ClientID];
  if (OtherPlayer^.Status <> Playing) or
      (OtherPlayer^.Base.ClientID = Self.ClientID) then
      Continue;

      if Self.PlayerCharacter.LastPos.InRange
      (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
    begin

      if not Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
      begin
        Self.AddToVisible(OtherPlayer^.Base);
        if OtherPlayer^.Account.Header.Pran1.IsSpawned then
          OtherPlayer^.SendPranSpawn(0, Self.ClientID, 0);
        if OtherPlayer^.Account.Header.Pran2.IsSpawned then
          OtherPlayer^.SendPranSpawn(1, Self.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran1.IsSpawned then
          SelfPlayer^.SendPranSpawn(0, OtherPlayer^.Base.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran2.IsSpawned then
          SelfPlayer^.SendPranSpawn(1, OtherPlayer^.Base.ClientID, 0);
      end;
    end
    else if Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
    begin
      if SelfPlayer^.Account.Header.Pran1.IsSpawned then
        SelfPlayer^.SendPranUnspawn(0, OtherPlayer^.Base.ClientID);
      if SelfPlayer^.Account.Header.Pran2.IsSpawned then
        SelfPlayer^.SendPranUnspawn(1, OtherPlayer^.Base.ClientID);
      if OtherPlayer^.Account.Header.Pran1.IsSpawned then
        OtherPlayer^.SendPranUnspawn(0, Self.ClientID);
      if OtherPlayer^.Account.Header.Pran2.IsSpawned then
        OtherPlayer^.SendPranUnspawn(1, Self.ClientID);

      Self.RemoveFromVisible(OtherPlayer^.Base);

      if (OtherPlayer^.Base.IsActive = false) then
      begin
        ZeroMemory(@Packet, SizeOf(Packet));
        Packet.Header.size := SizeOf(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := OtherPlayer^.Base.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;

    end;


  end;

end;

procedure TBaseMob.UpdateVisibleDungeon(SpawnType: Byte = 0);
var
  i, j: WORD;
  LoopI: Byte;
  npcMob: PBaseMob;
  BaseNpcNovo: PBaseNpc;
  Packet: TSendRemoveMobPacket;
  SelfPlayer, OtherPlayers: PPlayer;
  SelfParty: PParty;
  MobDungeon: PMobsStructDungeonInstance;

begin
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  SelfParty := DungeonInstances[SelfPlayer^.DungeonInstanceID].Party;

  if (SelfParty.Members.Count > 1) then
  begin
    for i in SelfParty.Members.ToArray do
    begin
      OtherPlayers := @Servers[Self.ChannelId].Players[i];

      if SelfPlayer^.Base.ClientID = OtherPlayers^.Base.ClientID then
        Continue;

      if SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
        (OtherPlayers^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
      begin
        if SelfPlayer^.Base.VisiblePlayers.Contains(OtherPlayers^.Base.ClientID)
        then
          Continue;

        SelfPlayer^.Base.addvisible(OtherPlayers^.Base);

        if OtherPlayers^.Account.Header.Pran1.IsSpawned then
          OtherPlayers^.SendPranSpawn(0, SelfPlayer^.Base.ClientID, 0);

        if OtherPlayers^.Account.Header.Pran2.IsSpawned then
          OtherPlayers^.SendPranSpawn(1, SelfPlayer^.Base.ClientID, 0);

        if SelfPlayer^.Account.Header.Pran1.IsSpawned then
          SelfPlayer^.SendPranSpawn(0, OtherPlayers^.Base.ClientID, 0);

        if SelfPlayer^.Account.Header.Pran2.IsSpawned then
          SelfPlayer^.SendPranSpawn(1, OtherPlayers^.Base.ClientID, 0);
      end
      else
      begin
        if not SelfPlayer^.Base.VisiblePlayers.Contains
          (OtherPlayers^.Base.ClientID) then
          Continue;

        if OtherPlayers^.Account.Header.Pran1.IsSpawned then
          OtherPlayers^.SendPranUnspawn(0, OtherPlayers^.Base.ClientID);

        if OtherPlayers^.Account.Header.Pran2.IsSpawned then
          OtherPlayers^.SendPranUnspawn(1, OtherPlayers^.Base.ClientID);

        if SelfPlayer^.Account.Header.Pran1.IsSpawned then
          SelfPlayer^.SendPranUnspawn(0, SelfPlayer^.Base.ClientID);

        if SelfPlayer^.Account.Header.Pran2.IsSpawned then
          SelfPlayer^.SendPranUnspawn(1, SelfPlayer^.Base.ClientID);

        SelfPlayer^.Base.removevisible(OtherPlayers^.Base);

        if not OtherPlayers^.Base.IsActive then
        begin
          ZeroMemory(@Packet, SizeOf(Packet));
          Packet.Header.size := SizeOf(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $101;
          Packet.Index := OtherPlayers^.Base.ClientID;
          SelfPlayer^.Base.SendPacket(Packet, Packet.Header.size);
        end;
      end;
    end;
  end;

  for j := Low(DungeonInstances[SelfPlayer^.DungeonInstanceID].MOBS)
    to High(DungeonInstances[SelfPlayer^.DungeonInstanceID].MOBS) do
  begin
    MobDungeon := @DungeonInstances[SelfPlayer^.DungeonInstanceID].MOBS[j];
    if (MobDungeon^.IntName = 0) or MobDungeon^.Base.IsDead then
      Continue;

    if SelfPlayer^.Base.PlayerCharacter.LastPos.InRange(MobDungeon^.Position,
      DISTANCE_TO_WATCH) then
    begin
      if MobDungeon^.AttackerID = 0 then
      begin
        if SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
          (MobDungeon^.Position, 40) then
        begin
          MobDungeon^.OrigPos := MobDungeon^.Position;
          MobDungeon^.AttackerID := SelfPlayer^.Base.ClientID;
          MobDungeon^.LastMyAttack := Now;
        end;
      end
      else
      begin
        if not MobDungeon^.Position.InRange(MobDungeon^.OrigPos, 28) then
        begin
          MobDungeon^.Position := MobDungeon^.OrigPos;
          MobDungeon^.MobMove(MobDungeon^.Position,
            SelfPlayer^.DungeonInstanceID, 35);
          MobDungeon^.AttackerID := 0;
        end;
      end;

      if SelfPlayer^.Base.VisibleMobs.Contains(MobDungeon^.Base.ClientID) then
        Continue;

      SelfPlayer^.Base.VisibleMobs.Add(MobDungeon^.Base.ClientID);
      MobDungeon^.Base.VisibleMobs.Add(SelfPlayer^.Base.ClientID);

      if SelfPlayer^.Base.AddTargetToList(@MobDungeon^.Base) then
        SelfPlayer^.SendSpawnMobDungeon
          (@DungeonInstances[SelfPlayer^.DungeonInstanceID].MOBS[j]);
    end
    else
    begin
      if not SelfPlayer^.Base.VisibleMobs.Contains(MobDungeon^.Base.ClientID)
      then
        Continue;

      MobDungeon^.AttackerID := 0;

      SelfPlayer^.Base.VisibleMobs.Remove(MobDungeon^.Base.ClientID);
      MobDungeon^.Base.VisibleMobs.Remove(SelfPlayer^.Base.ClientID);

      if SelfPlayer^.Base.RemoveTargetFromList(@MobDungeon^.Base) then
        SelfPlayer^.SendRemoveMobDungeon
          (@DungeonInstances[SelfPlayer^.DungeonInstanceID].MOBS[j]);
    end;
  end;
  for i := Low(Servers[Self.ChannelId].NPCs)
    to High(Servers[Self.ChannelId].NPCs) do
  begin
    if Servers[Self.ChannelId].NPCs[i].Base.ClientID = 0 then
      Continue;

    BaseNpcNovo := @Servers[Self.ChannelId].NPCs[i].Base;

    if Self.PlayerCharacter.LastPos.InRange
      (BaseNpcNovo^.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
    begin
      if not Self.VisibleNPCS.Contains(BaseNpcNovo^.ClientID) then
      begin
        Self.VisibleNPCS.Add(BaseNpcNovo^.ClientID);
        BaseNpcNovo^.SendCreateMob(SPAWN_NORMAL, Self.ClientID, false);
      end;
    end
    else if Self.VisibleNPCS.Contains(BaseNpcNovo^.ClientID) then
    begin
      Self.VisibleNPCS.Remove(BaseNpcNovo^.ClientID);
      ZeroMemory(@Packet, SizeOf(Packet));
      Packet.Header.size := SizeOf(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := BaseNpcNovo^.ClientID;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

procedure TBaseMob.UpdateVisibleCastle(SpawnType: Byte = 0);
var
  i: WORD;
  Packet: TSendRemoveMobPacket;
  OtherPlayer, SelfPlayer: PPlayer;
  PacketDevirSpawn: TSendCreateNpcPacket;
  key: TPlayerKey;
begin


  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  for Key in ActivePlayers.Keys do
  begin
  if Key.ServerID <> SelfPlayer^.ChannelIndex then
  continue;

  OtherPlayer:= @Servers[Key.ServerID].Players[Key.ClientID];
  if (OtherPlayer^.Status <> Playing) or
      (OtherPlayer^.Base.ClientID = Self.ClientID) then
      Continue;

      if Self.PlayerCharacter.LastPos.InRange
      (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
    begin

      if not Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
      begin
        Self.AddToVisible(OtherPlayer^.Base);
        if OtherPlayer^.Account.Header.Pran1.IsSpawned then
          OtherPlayer^.SendPranSpawn(0, Self.ClientID, 0);
        if OtherPlayer^.Account.Header.Pran2.IsSpawned then
          OtherPlayer^.SendPranSpawn(1, Self.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran1.IsSpawned then
          SelfPlayer^.SendPranSpawn(0, OtherPlayer^.Base.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran2.IsSpawned then
          SelfPlayer^.SendPranSpawn(1, OtherPlayer^.Base.ClientID, 0);
      end;
    end
    else if Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
    begin
      if SelfPlayer^.Account.Header.Pran1.IsSpawned then
        SelfPlayer^.SendPranUnspawn(0, OtherPlayer^.Base.ClientID);
      if SelfPlayer^.Account.Header.Pran2.IsSpawned then
        SelfPlayer^.SendPranUnspawn(1, OtherPlayer^.Base.ClientID);
      if OtherPlayer^.Account.Header.Pran1.IsSpawned then
        OtherPlayer^.SendPranUnspawn(0, Self.ClientID);
      if OtherPlayer^.Account.Header.Pran2.IsSpawned then
        OtherPlayer^.SendPranUnspawn(1, Self.ClientID);

      Self.RemoveFromVisible(OtherPlayer^.Base);

      if (OtherPlayer^.Base.IsActive = false) then
      begin
        ZeroMemory(@Packet, SizeOf(Packet));
        Packet.Header.size := SizeOf(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := OtherPlayer^.Base.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;

    end;


  end;


  for i := Low(Servers[Self.ChannelId].CastleObjects)
    to High(Servers[Self.ChannelId].CastleObjects) do
  begin
    if Self.PlayerCharacter.LastPos.InRange
      (Servers[Self.ChannelId].CastleObjects[i].PlayerChar.LastPos,
      DISTANCE_TO_WATCH) then
    begin
      if not Self.VisibleNPCS.Contains(i) then
      begin
        Self.VisibleNPCS.Add(i);
        ZeroMemory(@PacketDevirSpawn, SizeOf(TSendCreateNpcPacket));
        with PacketDevirSpawn do
        begin
          Header.size := SizeOf(TSendCreateNpcPacket);
          Header.Index := i;
          Header.Code := $349;
          Move(Servers[Self.ChannelId].CastleObjects[i].PlayerChar.Base.Name,
            Name[0], 16);
          Equip[0] := Servers[Self.ChannelId].CastleObjects[i]
            .PlayerChar.Base.Equip[0].Index;
          Position := Servers[Self.ChannelId].CastleObjects[i]
            .PlayerChar.LastPos;
          MaxHP := Servers[Self.ChannelId].CastleObjects[i]
            .PlayerChar.Base.CurrentScore.MaxHP;
          CurHP := MaxHP;
          MaxMP := MaxHP;
          CurMP := MaxHP;
          Altura := Servers[Self.ChannelId].CastleObjects[i]
            .PlayerChar.Base.CurrentScore.Sizes.Altura;
          Tronco := Servers[Self.ChannelId].CastleObjects[i]
            .PlayerChar.Base.CurrentScore.Sizes.Tronco;
          Perna := Servers[Self.ChannelId].CastleObjects[i]
            .PlayerChar.Base.CurrentScore.Sizes.Perna;
          Corpo := Servers[Self.ChannelId].CastleObjects[i]
            .PlayerChar.Base.CurrentScore.Sizes.Corpo;
          EffectType := $1;
          IsService := 1;
          Unk0 := $28;
        end;
        Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);
      end;
    end
    else if Self.VisibleNPCS.Contains(i) then
    begin
      Self.VisibleNPCS.Remove(i);
      ZeroMemory(@Packet, SizeOf(Packet));
      with Packet do
      begin
        Header.size := SizeOf(Packet);
        Header.Index := $7535;
        Header.Code := $101;
        Index := i;
      end;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;

end;
procedure TBaseMob.UpdateVisibleLeopold(SpawnType: Byte = 0);
var
  i, j: WORD;
  k: Byte;
  npcMob: PBaseMob;
  BaseNpcNovo: PBaseNpc;
  Packet: TSendRemoveMobPacket;
  OtherPlayer, SelfPlayer: PPlayer;
  PacketDevirSpawn: TSendCreateNpcPacket;
  PacketDevirMobsSpawn: TSpawnMobPacket;
  xObj: POBJ;
  key: TPlayerKey;
begin
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];


  for Key in ActivePlayers.Keys do
  begin
  if Key.ServerID <> SelfPlayer^.ChannelIndex then
  continue;

  OtherPlayer:= @Servers[Key.ServerID].Players[Key.ClientID];
  if (OtherPlayer^.Status <> Playing) or
      (OtherPlayer^.Base.ClientID = Self.ClientID) then
      Continue;

      if Self.PlayerCharacter.LastPos.InRange
      (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
    begin

      if not Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
      begin
        Self.AddToVisible(OtherPlayer^.Base);
        WriteLn('adding player to visible ' + OtherPlayer^.Base.Character.Name);
        if OtherPlayer^.Account.Header.Pran1.IsSpawned then
          OtherPlayer^.SendPranSpawn(0, Self.ClientID, 0);
        if OtherPlayer^.Account.Header.Pran2.IsSpawned then
          OtherPlayer^.SendPranSpawn(1, Self.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran1.IsSpawned then
          SelfPlayer^.SendPranSpawn(0, OtherPlayer^.Base.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran2.IsSpawned then
          SelfPlayer^.SendPranSpawn(1, OtherPlayer^.Base.ClientID, 0);
      end;
    end
    else if Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
    begin
      if SelfPlayer^.Account.Header.Pran1.IsSpawned then
        SelfPlayer^.SendPranUnspawn(0, OtherPlayer^.Base.ClientID);
      if SelfPlayer^.Account.Header.Pran2.IsSpawned then
        SelfPlayer^.SendPranUnspawn(1, OtherPlayer^.Base.ClientID);
      if OtherPlayer^.Account.Header.Pran1.IsSpawned then
        OtherPlayer^.SendPranUnspawn(0, Self.ClientID);
      if OtherPlayer^.Account.Header.Pran2.IsSpawned then
        OtherPlayer^.SendPranUnspawn(1, Self.ClientID);

      Self.RemoveFromVisible(OtherPlayer^.Base);

      if (OtherPlayer^.Base.IsActive = false) then
      begin
        ZeroMemory(@Packet, SizeOf(Packet));
        Packet.Header.size := SizeOf(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := OtherPlayer^.Base.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;

    end;


  end;

  for i := Low(Servers[Self.ChannelId].NPCs)
    to High(Servers[Self.ChannelId].NPCs) do
  begin
    if Servers[Self.ChannelId].NPCs[i].Base.ClientID = 0 then
      Continue;

    BaseNpcNovo := @Servers[Self.ChannelId].NPCs[i].Base;

    if Self.PlayerCharacter.LastPos.InRange
      (BaseNpcNovo^.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
    begin
      if not Self.VisibleNPCS.Contains(BaseNpcNovo^.ClientID) then
      begin
        Self.VisibleNPCS.Add(BaseNpcNovo^.ClientID);
        BaseNpcNovo^.SendCreateMob(SPAWN_NORMAL, Self.ClientID, false);
      end;
    end
    else if Self.VisibleNPCS.Contains(BaseNpcNovo^.ClientID) then
    begin
      Self.VisibleNPCS.Remove(BaseNpcNovo^.ClientID);
      ZeroMemory(@Packet, SizeOf(Packet));
      Packet.Header.size := SizeOf(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := BaseNpcNovo^.ClientID;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;

  for i := Low(Servers[Self.ChannelId].OBJ)
    to High(Servers[Self.ChannelId].OBJ) do
  begin
    if Servers[Self.ChannelId].OBJ[i].Index <> 0 then
    begin
      xObj := @Servers[Self.ChannelId].OBJ[i];
      if xObj.Position.InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)
      then
      begin
        if not Self.VisibleMobs.Contains(xObj.Index) then
        begin
          Self.VisibleMobs.Add(xObj.Index);
          ZeroMemory(@PacketDevirSpawn, SizeOf(TSendCreateNpcPacket));
          with PacketDevirSpawn do
          begin
            Header.size := SizeOf(TSendCreateNpcPacket);
            Header.Index := i;
            Header.Code := $349;
            System.AnsiStrings.StrPLCopy(Name, IntToStr(xObj.NameID),
              SizeOf(Name));
            Equip[0] := xObj.Face;
            Equip[6] := xObj.Weapon;
            Position := xObj.Position;
            MaxHP := 100000;
            MaxMP := 100000;
            CurHP := 100000;
            CurMP := 100000;
            Altura := 7;
            Tronco := 119;
            Perna := 119;
            Corpo := 1;
            IsService := 1;
            if xObj.Index = 11147 then

              if xObj.Face = 320 then
                System.AnsiStrings.StrPLCopy(Title,
                  ItemList[xObj.ContentItemID].Name, SizeOf(Title));
          end;
          Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);
        end;
      end
      else if Self.VisibleMobs.Contains(xObj.Index) then
      begin
        Self.VisibleMobs.Remove(xObj.Index);
        ZeroMemory(@Packet, SizeOf(Packet));
        with Packet do
        begin
          Header.size := SizeOf(Packet);
          Header.Index := $7535;
          Header.Code := $101;
          Index := i;
        end;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
end;


procedure TBaseMob.UpdateVisibleList(SpawnType: Byte = 0);
var
  i, j: WORD;
  k: Byte;
  npcMob: PBaseMob;
  BaseNpcNovo: PBaseNpc;
  Packet: TSendRemoveMobPacket;
  OtherPlayer, SelfPlayer: PPlayer;
  PacketDevirSpawn: TSendCreateNpcPacket;
  PacketDevirMobsSpawn: TSpawnMobPacket;
  xObj: POBJ;
  key: TPlayerKey;
begin
try
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];


  for Key in ActivePlayers.Keys do
  begin
  if Key.ServerID <> SelfPlayer^.ChannelIndex then
  continue;

  OtherPlayer:= @Servers[Key.ServerID].Players[Key.ClientID];
  if (OtherPlayer^.Status <> Playing) or
      (OtherPlayer^.Base.ClientID = Self.ClientID) then
      Continue;

      if Self.PlayerCharacter.LastPos.InRange
      (OtherPlayer^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
    begin

      if not Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
      begin
        Self.AddToVisible(OtherPlayer^.Base);
        WriteLn('adding player to visible ' + OtherPlayer^.Base.Character.Name);
        if OtherPlayer^.Account.Header.Pran1.IsSpawned then
          OtherPlayer^.SendPranSpawn(0, Self.ClientID, 0);
        if OtherPlayer^.Account.Header.Pran2.IsSpawned then
          OtherPlayer^.SendPranSpawn(1, Self.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran1.IsSpawned then
          SelfPlayer^.SendPranSpawn(0, OtherPlayer^.Base.ClientID, 0);
        if SelfPlayer^.Account.Header.Pran2.IsSpawned then
          SelfPlayer^.SendPranSpawn(1, OtherPlayer^.Base.ClientID, 0);
      end;
    end
    else if Self.VisiblePlayers.Contains(OtherPlayer^.Base.ClientID) then
    begin
      if SelfPlayer^.Account.Header.Pran1.IsSpawned then
        SelfPlayer^.SendPranUnspawn(0, OtherPlayer^.Base.ClientID);
      if SelfPlayer^.Account.Header.Pran2.IsSpawned then
        SelfPlayer^.SendPranUnspawn(1, OtherPlayer^.Base.ClientID);
      if OtherPlayer^.Account.Header.Pran1.IsSpawned then
        OtherPlayer^.SendPranUnspawn(0, Self.ClientID);
      if OtherPlayer^.Account.Header.Pran2.IsSpawned then
        OtherPlayer^.SendPranUnspawn(1, Self.ClientID);

      Self.RemoveFromVisible(OtherPlayer^.Base);

      if (OtherPlayer^.Base.IsActive = false) then
      begin
        ZeroMemory(@Packet, SizeOf(Packet));
        Packet.Header.size := SizeOf(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := OtherPlayer^.Base.ClientID;
        Self.SendPacket(Packet, Packet.Header.size);
      end;

    end;


  end;

  for i := Low(Servers[Self.ChannelId].NPCs)
    to High(Servers[Self.ChannelId].NPCs) do
  begin
    if Servers[Self.ChannelId].NPCs[i].Base.ClientID = 0 then
      Continue;

    BaseNpcNovo := @Servers[Self.ChannelId].NPCs[i].Base;

    if Self.PlayerCharacter.LastPos.InRange
      (BaseNpcNovo^.PlayerCharacter.LastPos, DISTANCE_TO_WATCH) then
    begin
      if not Self.VisibleNPCS.Contains(BaseNpcNovo^.ClientID) then
      begin
        Self.VisibleNPCS.Add(BaseNpcNovo^.ClientID);
        BaseNpcNovo^.SendCreateMob(SPAWN_NORMAL, Self.ClientID, false);
      end;
    end
    else if Self.VisibleNPCS.Contains(BaseNpcNovo^.ClientID) then
    begin
      Self.VisibleNPCS.Remove(BaseNpcNovo^.ClientID);
      ZeroMemory(@Packet, SizeOf(Packet));
      Packet.Header.size := SizeOf(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := BaseNpcNovo^.ClientID;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;

  if SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(3662, 1978), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(2748, 2024), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(1851, 1844), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(3014, 1158), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(2236, 944), DISTANCE_TO_WATCH) then
  begin

    for i := Low(Servers[Self.ChannelId].DevirNPC)
      to High(Servers[Self.ChannelId].DevirNPC) do
    begin
      if Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].DevirNPC
        [i].PlayerChar.LastPos, DISTANCE_TO_WATCH) then
      begin
        if not Self.VisibleNPCS.Contains(i) then
        begin
          SelfPlayer^.Base.VisibleNPCS.Add(i);
          ZeroMemory(@PacketDevirSpawn, SizeOf(TSendCreateNpcPacket));
          PacketDevirSpawn.Header.size := SizeOf(TSendCreateNpcPacket);
          PacketDevirSpawn.Header.Index := i;
          PacketDevirSpawn.Header.Code := $349;
          Move(Servers[Self.ChannelId].DevirNPC[i].PlayerChar.Base.Name,
            PacketDevirSpawn.Name[0], 16);
          PacketDevirSpawn.Equip[0] := Servers[Self.ChannelId].DevirNPC[i]
            .PlayerChar.Base.Equip[0].Index;
          PacketDevirSpawn.Position := Servers[Self.ChannelId].DevirNPC[i]
            .PlayerChar.LastPos;
          PacketDevirSpawn.MaxHP := Servers[Self.ChannelId].DevirNPC[i]
            .PlayerChar.Base.CurrentScore.MaxHP;
          PacketDevirSpawn.CurHP := PacketDevirSpawn.MaxHP;
          PacketDevirSpawn.MaxMP := PacketDevirSpawn.MaxHP;
          PacketDevirSpawn.CurMP := PacketDevirSpawn.MaxHP;
          if Servers[Self.ChannelId].Devires[i - 3335].IsOpen then
            PacketDevirSpawn.ItemEff[0] := $35;
          PacketDevirSpawn.Altura := Servers[Self.ChannelId].DevirNPC[i]
            .PlayerChar.Base.CurrentScore.Sizes.Altura;
          PacketDevirSpawn.Tronco := Servers[Self.ChannelId].DevirNPC[i]
            .PlayerChar.Base.CurrentScore.Sizes.Tronco;
          PacketDevirSpawn.Perna := Servers[Self.ChannelId].DevirNPC[i]
            .PlayerChar.Base.CurrentScore.Sizes.Perna;
          PacketDevirSpawn.Corpo := Servers[Self.ChannelId].DevirNPC[i]
            .PlayerChar.Base.CurrentScore.Sizes.Corpo;
          PacketDevirSpawn.IsService := 1;
          PacketDevirSpawn.EffectType := $1;
          PacketDevirSpawn.Unk0 := $28;
          Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);

          if PacketDevirSpawn.ItemEff[0] = $35 then
            Servers[Self.ChannelId].Players[Self.ClientID]
              .SendDevirChange(i, $1D);
        end;
      end
      else if Self.VisibleNPCS.Contains(i) then
      begin
        Self.VisibleNPCS.Remove(i);
        ZeroMemory(@Packet, SizeOf(Packet));
        Packet.Header.size := SizeOf(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := i;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;

  end;

  if SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(3662, 1978), 80) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(2748, 2024), 80) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(1851, 1844), 80) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(3014, 1158), 80) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(2236, 944), 80) then
  begin

    for i := Low(Servers[Self.ChannelId].DevirGuards)
      to High(Servers[Self.ChannelId].DevirGuards) do
    begin
      if (Servers[Self.ChannelId].DevirGuards[i].Base.IsDead) or
        (Self.VisibleNPCS.Contains(i) and
        not Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
        .DevirGuards[i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
        Continue;

      if Self.PlayerCharacter.LastPos.InRange
        (Servers[Self.ChannelId].DevirGuards[i].PlayerChar.LastPos,
        DISTANCE_TO_WATCH) then
      begin
        if not Self.VisibleNPCS.Contains(i) then
        begin
          Self.VisibleNPCS.Add(i);
          Self.AddTargetToList(@Servers[Self.ChannelId].DevirGuards[i].Base);
          ZeroMemory(@PacketDevirMobsSpawn, SizeOf(TSpawnMobPacket));
          PacketDevirMobsSpawn.Header.size := SizeOf(TSpawnMobPacket);
          PacketDevirMobsSpawn.Header.Index := i;
          PacketDevirMobsSpawn.Header.Code := $35E;

          for k := 0 to 6 do
            PacketDevirMobsSpawn.Equip[k] := Servers[Self.ChannelId].DevirGuards
              [i].PlayerChar.Base.Equip[k].Index;

          PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirGuards
            [i].PlayerChar.LastPos;
          PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.CurrentScore.MaxHP;
          PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.CurrentScore.CurHP;
          PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
          PacketDevirMobsSpawn.Level :=
            (Servers[Self.ChannelId].DevirGuards[i].PlayerChar.Base.Level
            + 1) * 13;
          PacketDevirMobsSpawn.IsService := (Self.Character <> nil) and
            (Self.Character.Nation = Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.Nation);
          PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirGuards
            [i].PlayerChar.DuploAtk;
          PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.CurrentScore.Sizes.Altura;
          PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.CurrentScore.Sizes.Tronco;
          PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.CurrentScore.Sizes.Perna;
          PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.CurrentScore.Sizes.Corpo;
          PacketDevirMobsSpawn.MobType := 0;

          PacketDevirMobsSpawn.MobName :=
            StrToInt(String(Servers[Self.ChannelId].DevirGuards[i]
            .PlayerChar.Base.Name));
          Self.SendPacket(PacketDevirMobsSpawn,
            PacketDevirMobsSpawn.Header.size);
        end;
      end
      else if Self.VisibleNPCS.Contains(i) then
      begin
        Self.VisibleNPCS.Remove(i);
        Self.RemoveTargetFromList(@Servers[Self.ChannelId].DevirGuards[i].Base);
        ZeroMemory(@Packet, SizeOf(Packet));
        Packet.Header.size := SizeOf(Packet);
        Packet.Header.Index := $7535;
        Packet.Header.Code := $101;
        Packet.Index := i;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;

  end;

  for i := Low(Servers[Self.ChannelId].RoyalGuards)
    to High(Servers[Self.ChannelId].RoyalGuards) do
  begin
    if (Servers[Self.ChannelId].RoyalGuards[i].Base.IsDead) or
      (Self.VisibleNPCS.Contains(i) and not Self.PlayerCharacter.LastPos.InRange
      (Servers[Self.ChannelId].RoyalGuards[i].PlayerChar.LastPos,
      DISTANCE_TO_WATCH)) then
      Continue;

    if Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId].RoyalGuards
      [i].PlayerChar.LastPos, DISTANCE_TO_WATCH) then
    begin
      if not Self.VisibleNPCS.Contains(i) then
      begin
        Self.VisibleNPCS.Add(i);
        Self.AddTargetToList(@Servers[Self.ChannelId].RoyalGuards[i].Base);
        ZeroMemory(@PacketDevirMobsSpawn, SizeOf(TSpawnMobPacket));
        PacketDevirMobsSpawn.Header.size := SizeOf(TSpawnMobPacket);
        PacketDevirMobsSpawn.Header.Index := i;
        PacketDevirMobsSpawn.Header.Code := $35E;

        for k := 0 to 6 do
          PacketDevirMobsSpawn.Equip[k] := Servers[Self.ChannelId].RoyalGuards
            [i].PlayerChar.Base.Equip[k].Index;

        PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.LastPos;
        PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.CurrentScore.MaxHP;
        PacketDevirMobsSpawn.CurHP := Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.CurrentScore.CurHP;
        PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
        PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
        PacketDevirMobsSpawn.Level :=
          (Servers[Self.ChannelId].RoyalGuards[i].PlayerChar.Base.Level
          + 1) * 13;
        PacketDevirMobsSpawn.IsService := (Self.Character <> nil) and
          (Self.Character.Nation = Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.Nation);
        PacketDevirMobsSpawn.Effects[0] := 0;
        // PacketDevirMobsSpawn.Effects[1] := 240;
        // PacketDevirMobsSpawn.Effects[2] := 240;
        // PacketDevirMobsSpawn.Effects[3] := 240;

        // PacketDevirMobsSpawn.
        // Packet.ItemEff[7] := Character^.Equip[6].Refi div 16;
        PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.CurrentScore.Sizes.Altura;
        PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.CurrentScore.Sizes.Tronco;
        PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.CurrentScore.Sizes.Perna;
        PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.CurrentScore.Sizes.Corpo;
        PacketDevirMobsSpawn.MobType := 0;

        var
          Nome: Integer;
          // var NomeString: string;

        if TryStrToInt(Servers[Self.ChannelId].RoyalGuards[i]
          .PlayerChar.Base.Name, Nome) and (Nome >= Low(WORD)) and
          (Nome <= High(WORD)) then
        begin
          // WriteLN('deu certo');
          PacketDevirMobsSpawn.MobName := WORD(Nome);
          // PacketDevirMobsSpawn.MobName := Word(TempValue);
        end;
        // PacketDevirMobsSpawn.MobName := Word(StrToInt(Servers[Self.ChannelId].RoyalGuards[i].PlayerChar.Base.Name));
        // end;
        // end;

        Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      end;
    end
    else if Self.VisibleNPCS.Contains(i) then
    begin
      Self.VisibleNPCS.Remove(i);
      Self.RemoveTargetFromList(@Servers[Self.ChannelId].RoyalGuards[i].Base);
      ZeroMemory(@Packet, SizeOf(Packet));
      Packet.Header.size := SizeOf(Packet);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $101;
      Packet.Index := i;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;

  if SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(3662, 1978), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(2748, 2024), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(1851, 1844), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(3014, 1158), DISTANCE_TO_WATCH) or
    SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
    (TPosition.Create(2236, 944), DISTANCE_TO_WATCH) then
  begin

    for i := Low(Servers[Self.ChannelId].DevirStones)
      to High(Servers[Self.ChannelId].DevirStones) do
    begin
      if (Servers[Self.ChannelId].DevirStones[i].Base.IsDead) or
        (not Self.PlayerCharacter.LastPos.InRange(Servers[Self.ChannelId]
        .DevirStones[i].PlayerChar.LastPos, DISTANCE_TO_WATCH)) then
      begin
        if Self.VisibleNPCS.Contains(i) then
        begin
          Self.VisibleNPCS.Remove(i);
          Self.RemoveTargetFromList(@Servers[Self.ChannelId]
            .DevirStones[i].Base);
          ZeroMemory(@Packet, SizeOf(Packet));
          Packet.Header.size := SizeOf(Packet);
          Packet.Header.Index := $7535;
          Packet.Header.Code := $101;
          Packet.Index := i;
          Self.SendPacket(Packet, Packet.Header.size);
        end;
        Continue;
      end;

      if not Self.VisibleNPCS.Contains(i) then
      begin
        Self.VisibleNPCS.Add(i);
        Self.AddTargetToList(@Servers[Self.ChannelId].DevirStones[i].Base);
        ZeroMemory(@PacketDevirMobsSpawn, SizeOf(TSpawnMobPacket));
        PacketDevirMobsSpawn.Header.size := SizeOf(TSpawnMobPacket);
        PacketDevirMobsSpawn.Header.Index := i;
        PacketDevirMobsSpawn.Header.Code := $35E;
        PacketDevirMobsSpawn.Position := Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.LastPos;
        PacketDevirMobsSpawn.Equip[0] := Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.Equip[0].Index;
        PacketDevirMobsSpawn.MaxHP := Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.CurrentScore.MaxHP;
        PacketDevirMobsSpawn.CurHP := PacketDevirMobsSpawn.MaxHP;
        PacketDevirMobsSpawn.MaxMP := PacketDevirMobsSpawn.MaxHP;
        PacketDevirMobsSpawn.CurMP := PacketDevirMobsSpawn.MaxHP;
        PacketDevirMobsSpawn.Level :=
          (Servers[Self.ChannelId].DevirStones[i].PlayerChar.Base.Level
          + 1) * 13;
        PacketDevirMobsSpawn.IsService := Self.Character.Nation = Servers
          [Self.ChannelId].DevirStones[i].PlayerChar.Base.Nation;
        PacketDevirMobsSpawn.Effects[0] := Servers[Self.ChannelId].DevirStones
          [i].PlayerChar.DuploAtk;
        PacketDevirMobsSpawn.Altura := Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.CurrentScore.Sizes.Altura;
        PacketDevirMobsSpawn.Tronco := Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.CurrentScore.Sizes.Tronco;
        PacketDevirMobsSpawn.Perna := Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.CurrentScore.Sizes.Perna;
        PacketDevirMobsSpawn.Corpo := Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.CurrentScore.Sizes.Corpo;
        PacketDevirMobsSpawn.MobType := 1;
        PacketDevirMobsSpawn.MobName :=
          StrToInt(String(Servers[Self.ChannelId].DevirStones[i]
          .PlayerChar.Base.Name));
        Self.SendPacket(PacketDevirMobsSpawn, PacketDevirMobsSpawn.Header.size);
      end;
    end;

  end;

  for i := Low(Servers[Self.ChannelId].OBJ)
    to High(Servers[Self.ChannelId].OBJ) do
  begin
    if Servers[Self.ChannelId].OBJ[i].Index <> 0 then
    begin
      xObj := @Servers[Self.ChannelId].OBJ[i];
      if xObj.Position.InRange(Self.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)
      then
      begin
        if not Self.VisibleMobs.Contains(xObj.Index) then
        begin
          Self.VisibleMobs.Add(xObj.Index);
          ZeroMemory(@PacketDevirSpawn, SizeOf(TSendCreateNpcPacket));
          with PacketDevirSpawn do
          begin
            Header.size := SizeOf(TSendCreateNpcPacket);
            Header.Index := i;
            Header.Code := $349;
            System.AnsiStrings.StrPLCopy(Name, IntToStr(xObj.NameID),
              SizeOf(Name));
            Equip[0] := xObj.Face;
            Equip[6] := xObj.Weapon;
            Position := xObj.Position;
            MaxHP := 100000;
            MaxMP := 100000;
            CurHP := 100000;
            CurMP := 100000;
            Altura := 7;
            Tronco := 119;
            Perna := 119;
            Corpo := 1;
            IsService := 1;
            if xObj.Index = 11147 then

              if xObj.Face = 320 then
                System.AnsiStrings.StrPLCopy(Title,
                  ItemList[xObj.ContentItemID].Name, SizeOf(Title));
          end;
          Self.SendPacket(PacketDevirSpawn, PacketDevirSpawn.Header.size);
        end;
      end
      else if Self.VisibleMobs.Contains(xObj.Index) then
      begin
        Self.VisibleMobs.Remove(xObj.Index);
        ZeroMemory(@Packet, SizeOf(Packet));
        with Packet do
        begin
          Header.size := SizeOf(Packet);
          Header.Index := $7535;
          Header.Code := $101;
          Index := i;
        end;
        Self.SendPacket(Packet, Packet.Header.size);
      end;
    end;
  end;
  except

  WriteLn('erro inesperado');
  end;

end;

procedure TBaseMob.AddToVisible(var mob: TBaseMob; SpawnType: Byte = 0);
begin
  if Self.IsPlayer then
  begin
    if not VisiblePlayers.Contains(mob.ClientID) then
    begin
      VisiblePlayers.Add(mob.ClientID);
      mob.AddToVisible(Self);
      mob.SendCreateMob(SPAWN_NORMAL, Self.ClientID, false);
      Self.AddTargetToList(@mob);
    end;
  end
  else if mob.IsPlayer and not VisiblePlayers.Contains(mob.ClientID) then
  begin
    VisiblePlayers.Add(mob.ClientID);
    if not mob.VisiblePlayers.Contains(Self.ClientID) then
      mob.VisiblePlayers.Add(Self.ClientID);
  end;
end;

procedure TBaseMob.RemoveFromVisible(mob: TBaseMob; SpawnType: Byte = 0);
begin
  try
    if ((mob.IsActive = false) or (mob.ClientID = 0)) then
      Exit;
    // if(mob.ClientID = 0) then
    // Exit;
    if (Self.IsActive = false) then
      Exit;

    VisiblePlayers.Remove(mob.ClientID);

    if Self.IsPlayer then
    begin
      mob.SendRemoveMob(0, Self.ClientID);
      WriteLn('apagando mob 1');
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

function TBaseMob.AddTargetToList(target: PBaseMob): Boolean;
var
  id, id2: WORD;
begin
  Result := false;
  try
    if not ContainsTargetInList(target.ClientID, id2) then
    begin
      VisibleTargetsCnt := Length(VisibleTargets) + 1;
      SetLength(VisibleTargets, VisibleTargetsCnt);

      if GetEmptyTargetInList(id) then
        id := id
      else
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

function TBaseMob.RemoveTargetFromList(target: PBaseMob): Boolean;
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

function TBaseMob.ContainsTargetInList(target: PBaseMob; out id: WORD): Boolean;
var
  i: WORD;
begin
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

function TBaseMob.ContainsTargetInList(ClientID: WORD): Boolean;
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

function TBaseMob.ContainsTargetInList(ClientID: WORD; out id: WORD): Boolean;
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

function TBaseMob.GetEmptyTargetInList(out Index: WORD): Boolean;
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

function TBaseMob.GetTargetInList(ClientID: WORD): PBaseMob;
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
          Result := PBaseMob(VisibleTargets[i].Player);
        1:
          Result := PBaseMob(VisibleTargets[i].mob);
      end;
      Break;
    end;
end;

function TBaseMob.ClearTargetList(): Boolean;
begin
  Result := false;

  SetLength(VisibleTargets, 0);

  VisibleTargetsCnt := 0;
  Result := True;
end;

function TBaseMob.TargetGarbageService(): Boolean;
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
        and not(PBaseMob(VisibleTargets[i].Player).IsDead) then
      begin
        OtherList[cnt] := VisibleTargets[i];
        Inc(cnt);
      end;
    end
    else if (VisibleTargets[i].TargetType = 1) then
    begin
      if (VisibleTargets[i].mob <> nil) and (VisibleTargets[i].ClientID > 0) and
        not(PBaseMob(VisibleTargets[i].mob).IsDead) then
      begin
        OtherList[cnt].ClientID := VisibleTargets[i].ClientID;
        OtherList[cnt].TargetType := VisibleTargets[i].TargetType;

        case VisibleTargets[i].ClientID of
          2001 .. 3339, 3370 .. 9147:
            OtherList[cnt].Position := Servers[Self.ChannelId].MOBS.TMobS
              [PBaseMob(VisibleTargets[i].mob).Mobid].MobsP
              [PBaseMob(VisibleTargets[i].mob).SecondIndex]
              .Base.PlayerCharacter.LastPos;
          3340 .. 3354:
            OtherList[cnt].Position := Servers[Self.ChannelId].DevirStones
              [PBaseMob(VisibleTargets[i].mob).ClientID].PlayerChar.LastPos;
          3355 .. 3369:
            OtherList[cnt].Position := Servers[Self.ChannelId].DevirGuards
              [PBaseMob(VisibleTargets[i].mob).ClientID].PlayerChar.LastPos;
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

// procedure TBaseMob.SetDestination(const Destination: TPosition);
// begin
// if (PlayerCharacter.LastPos = Destination) then
// Exit;
// _prediction.Source := PlayerCharacter.LastPos;
// _prediction.Timer.Reset;
// _prediction.Timer.Start;
// _prediction.Destination := Destination;
// _prediction.CalcETA(PlayerCharacter.SpeedMove);
// end;

procedure TBaseMob.addvisible(m: TBaseMob);
begin
  Self.AddToVisible(m);
end;

procedure TBaseMob.removevisible(m: TBaseMob);
begin
  Self.RemoveFromVisible(m);
end;

procedure TBaseMob.AddHP(Value: Integer; ShowUpdate: Boolean);
begin
  if Self.ClientID >= 3048 then
    Inc(Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex]
      .HP, Value)
  else
    Inc(Self.Character.CurrentScore.CurHP, Value);

  Self.SendCurrentHPMP(ShowUpdate);
end;

procedure TBaseMob.AddMP(Value: Integer; ShowUpdate: Boolean);
begin
  if Self.ClientID < 3048 then
  begin
    Inc(Self.Character.CurrentScore.CurMP, Value);
    Self.SendCurrentHPMP(ShowUpdate);
  end;
end;

procedure TBaseMob.RemoveHP(Value: Integer; ShowUpdate: Boolean;
  StayOneHP: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) then
  begin
    deccardinal(Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].HP, Value);
    if (StayOneHP) then
    begin
      if (Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP[Self.SecondIndex]
        .HP = 0) then
        Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
          [Self.SecondIndex].HP := 1;
    end;
    ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));
    Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
    Packet.Header.Code := $103; // AIKA
    Packet.Header.Index := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
      [Self.SecondIndex].Index;
    if (ShowUpdate) then
      Packet.Null := 1;
    Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
    Packet.MaxMP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
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

  if (StayOneHP) then
  begin
    if (Self.Character.CurrentScore.CurHP = 0) then
      Self.Character.CurrentScore.CurHP := 1;
  end;
  Self.SendCurrentHPMP(ShowUpdate);

  if (Self.BuffExistsByIndex(134)) then
    if (Self.Character.CurrentScore.CurHP <
      (Self.Character.CurrentScore.MaxHP div 2)) then
    begin
      Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
        ('Cura preventiva entrou em a??o e feiti?o foi desfeito.', 0);
      Self.RemoveBuffByIndex(134);
    end;

  if (Self.Character.CurrentScore.CurHP = 0) then
  begin
    Self.SendCurrentHPMP();
    Self.SendEffect($0);
    Exit;
  end;
end;

procedure TBaseMob.RemoveMP(Value: Integer; ShowUpdate: Boolean);
begin
  if Self.ClientID < 3048 then
  begin
    Self.Character.CurrentScore.CurMP :=
      Self.Character.CurrentScore.CurMP - Value;
    Self.SendCurrentHPMP(ShowUpdate);
  end;
end;

procedure TBaseMob.WalkinTo(Pos: TPosition);
begin
  Self.WalkTo(Pos, 70);
end;

procedure TBaseMob.SetEquipEffect(const Equip: TItem; SetType: Integer;
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

procedure TBaseMob.SetConjuntEffect(Index: Integer; SetType: Integer);
var
  CfgEffect: Integer;
begin
  if Index = 0 then
    Exit;

  Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] :=
    Conjuntos[Index];
  CfgEffect := TItemFunctions.GetConjuntCount(Self, Index);

  if (CfgEffect >= 3) and (CfgEffect <= 6) then
    ConfigEffect(CfgEffect, Conjuntos[Index], SetType);

  if SetType = DESEQUIPING_TYPE then
    Self.EQUIP_CONJUNT[TItemFunctions.GetItemEquipSlot(Index)] := 0;
end;

procedure TBaseMob.ConfigEffect(Count: Integer; ConjuntId: Integer;
  SetType: Integer);
var
  i: Integer;
  EmptySlot: Byte;
begin
  EmptySlot := 255;
  for i := 0 to 5 do
  begin
    if SetItem[ConjuntId].EffSlot[i] <> Count then
      Continue;

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

procedure TBaseMob.SetOnTitleActiveEffect();
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
        Continue;

      Self.IncreasseMobAbility(TitleLevel.EF[i], TitleLevel.EFV[i]);
    end;
  end;
end;

procedure TBaseMob.SetOffTitleActiveEffect();
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
        Continue;

      Self.DecreasseMobAbility(Titles[TitleIndex].TitleLevel[TitleLevel - 1].EF
        [i], Titles[TitleIndex].TitleLevel[TitleLevel - 1].EFV[i]);
    end;
  end;
end;

function TBaseMob.MatchClassInfo(ClassInfo: Byte): Boolean;
begin
  Result := (Self.GetMobClass = Self.GetMobClass(ClassInfo));
end;

function TBaseMob.IsCompleteEffect5(out CountEffects: Byte): Boolean;
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

function TBaseMob.SearchEmptyEffect5Slot(): Byte;
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

function TBaseMob.GetSlotOfEffect5(CallID: WORD): Byte;
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

procedure TBaseMob.LureMobsInRange;
var
  i: Integer;
begin
  for i := Low(Self.VisibleTargets) to High(Self.VisibleTargets) do
  begin
    if Self.BuffExistsByIndex(77) or Self.BuffExistsByIndex(53) or
      Self.BuffExistsByIndex(153) or Self.BuffExistsByIndex(386) then
      Continue;

    if (Self.VisibleTargets[i].TargetType = 1) then
    begin
      var
      mob := PBaseMob(Self.VisibleTargets[i].mob);
      with Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobsP
        [mob.SecondIndex] do
      begin
        // WriteLn('meu nick ' + Base.Character.name);
        if (CurrentPos.InRange(Self.PlayerCharacter.LastPos,8)) then
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
                WriteLn('Fui lurado');

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

procedure TBaseMob.SendToVisible(var Packet; size: WORD; sendToSelf: Boolean);
var
  i: WORD;
  xPlayer, SelfPlayer: PPlayer;
begin

  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  sendToSelf := IfThen(sendToSelf, IsPlayer, false);
  if sendToSelf then
    Self.SendPacket(Packet, size);

  if SelfPlayer^.Base.ClientID = 0 then
    Exit;

  if SelfPlayer^.InDungeon or Self.IsDungeonMob then
  begin
    for i in VisiblePlayers do
    begin
      if i <= MAX_CONNECTIONS then
        xPlayer := @Servers[Self.ChannelId].Players[i];
      if xPlayer^.Status >= Playing then
        xPlayer^.SendPacket(Packet, size);
    end;

    Exit;
  end;

  if Self.ClientID <= 3048 then
  begin
    for i in VisiblePlayers do
    begin
      if i > MAX_CONNECTIONS then
        Continue;

      xPlayer := @Servers[Self.ChannelId].Players[i];
      if not xPlayer.SocketClosed and (xPlayer.Status >= Playing) then
        xPlayer.SendPacket(Packet, size);
    end;
  end
  else if (Self.ClientID >= 3355) and (Self.ClientID <= 3369) then
  begin
    if Servers[Self.ChannelId].DevirGuards[Self.ClientID].Base.VisiblePlayers = nil
    then
      Exit;

    for i in Servers[Self.ChannelId].DevirGuards[Self.ClientID]
      .Base.VisiblePlayers do
    begin
      if i > MAX_CONNECTIONS then
        Continue;

      xPlayer := @Servers[Self.ChannelId].Players[i];
      if xPlayer.Status >= Playing then
        xPlayer.SendPacket(Packet, size);
    end;
  end
  else if (Self.ClientID >= 3340) and (Self.ClientID <= 3354) then
  begin
    if Servers[Self.ChannelId].DevirStones[Self.ClientID].Base.VisiblePlayers = nil
    then
      Exit;

    for i in Servers[Self.ChannelId].DevirStones[Self.ClientID]
      .Base.VisiblePlayers do
    begin
      if i > MAX_CONNECTIONS then
        Continue;

      xPlayer := @Servers[Self.ChannelId].Players[i];
      if xPlayer.Status >= Playing then
        xPlayer.SendPacket(Packet, size);
    end;
  end
  else if (Self.ClientID >= 3391) and (Self.ClientID <= 3407) then
  begin
    if Servers[Self.ChannelId].RoyalGuards[Self.ClientID].Base.VisiblePlayers = nil
    then
      Exit;

    for i in Servers[Self.ChannelId].RoyalGuards[Self.ClientID]
      .Base.VisiblePlayers do
    begin
      if i > MAX_CONNECTIONS then
        Continue;

      xPlayer := @Servers[Self.ChannelId].Players[i];
      if xPlayer.Status >= Playing then
        xPlayer.SendPacket(Packet, size);
    end;
  end
  else
  begin
    for i in VisiblePlayers do
    begin
      if i <= MAX_CONNECTIONS then
        xPlayer := @Servers[Self.ChannelId].Players[i];
      if xPlayer^.Status >= Playing then
        xPlayer^.SendPacket(Packet, size);
    end;

    // for i in VisibleMobs do
    // begin
    // if i > MAX_CONNECTIONS then
    // Continue;
    //
    // xPlayer := @channel.Players[i];
    // if xPlayer.Status >= Playing then
    // xPlayer.SendPacket(Packet, size);
    // end;
  end;
end;

procedure TBaseMob.SendPacket(var Packet; size: WORD);
begin
  Servers[ChannelId].SendPacketTo(ClientID, Packet, size);
end;

procedure TBaseMob.SendCreateMob(SpawnType: WORD = 0; sendTo: WORD = 0;
  SendSelf: Boolean = True; Polimorf: WORD = 0; Custom: Integer = 0);
var
  Packet: TSendCreateMobPacket;
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

    // if Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.CurrentScore.Infamia >= 128 then
    // packet.ChaosPoint := 127
    // else
    // packet.ChaosPoint := Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.CurrentScore.Infamia;

    Self.GetCreateMob(Packet, sendTo);

    Packet.SpawnType := SpawnType;

    if (Self.InClastleVerus) then
      Packet.GuildIndexAndNation := Self.NationForCastle * 4096;

    if (sendTo > 0) then
      Servers[Self.ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size)
    else
      Self.SendToVisible(Packet, Packet.Header.size, SendSelf);

    if (Self.ClientID <= MAX_CONNECTIONS) and
      (TItemFunctions.GetItemSlotByItemType(Servers[Self.ChannelId].Players
      [Self.ClientID], 40, INV_TYPE, 0) <> 255) then
      Self.SendEffect(32);
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

procedure TBaseMob.SendRemoveMob(delType: Integer = DELETE_NORMAL;
  sendTo: WORD = 0; SendSelf: Boolean = True);
var
  Packet: TSendRemoveMobPacket;
  mob: TBaseMob;
  i: WORD;
begin
  Packet.Header.size := SizeOf(TSendRemoveMobPacket);
  Packet.Header.Code := $101;
  Packet.Header.Index := $7535;
  Packet.Index := Self.ClientID;
  Packet.DeleteType := delType;

  if (SendSelf) and (Self.IsPlayer) then
    Self.SendPacket(Packet, Packet.Header.size);

  if (sendTo = 0) then
    SendToVisible(Packet, Packet.Header.size, SendSelf)
  else
  begin
    Servers[ChannelId].SendPacketTo(sendTo, Packet, Packet.Header.size);
    Exit;
  end;

  for i in VisiblePlayers do
    if GetMob(i, ChannelId, mob) then
      RemoveFromVisible(mob);

  VisiblePlayers.Clear;
end;

procedure TBaseMob.SendRefreshLevel;
var
  Packet: TSendCurrentLevel;
begin
  if (Self.ClientID >= 3048) then
    Exit;

  Packet.Header.size := SizeOf(TSendCurrentLevel);
  Packet.Header.Code := $108;
  Packet.Header.Index := ClientID;
  Packet.Level := Character.Level - 1;
  Packet.Unk := $CC;
  Packet.Exp := Character.Exp;

  Self.SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendCurrentHPMPItem;
var
  Packet: TSendCurrentHPMPPacket;
begin
  Character.CurrentScore.MaxHP := Self.GetCurrentHP;
  Character.CurrentScore.MaxMP := Self.GetCurrentMP;

  if Character.CurrentScore.CurHP > Character.CurrentScore.MaxHP then
    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;

  if Character.CurrentScore.CurMP > Character.CurrentScore.MaxMP then
    Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;

  ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));
  Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103;
  Packet.Header.Index := ClientID;
  Packet.CurHP := Character.CurrentScore.CurHP;
  Packet.MaxHP := Character.CurrentScore.MaxHP;
  Packet.CurMP := Character.CurrentScore.CurMP;
  Packet.MaxMP := Character.CurrentScore.MaxMP;
  Packet.Null := 1;

  SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendCurrentHPMP(Update: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  Character.CurrentScore.MaxHP := Self.GetCurrentHP;
  Character.CurrentScore.MaxMP := Self.GetCurrentMP;

  if Character.CurrentScore.CurHP > Character.CurrentScore.MaxHP then
    Character.CurrentScore.CurHP := Character.CurrentScore.MaxHP;

  if Character.CurrentScore.CurMP > Character.CurrentScore.MaxMP then
    Character.CurrentScore.CurMP := Character.CurrentScore.MaxMP;

  ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));
  Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103;
  Packet.Header.Index := ClientID;
  Packet.CurHP := Character.CurrentScore.CurHP;
  Packet.MaxHP := Character.CurrentScore.MaxHP;
  Packet.CurMP := Character.CurrentScore.CurMP;
  Packet.MaxMP := Character.CurrentScore.MaxMP;
  Packet.Null := Ord(Update);

  SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendCurrentHPMPLogin(Update: Boolean);
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  Character.CurrentScore.MaxHP := Character.CurrentScore.MaxHP;
  Character.CurrentScore.MaxMP := Character.CurrentScore.MaxHP;

  ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));
  Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103;
  Packet.Header.Index := ClientID;
  Packet.CurHP := Character.CurrentScore.MaxHP;
  Packet.MaxHP := Character.CurrentScore.MaxHP;
  Packet.CurMP := Character.CurrentScore.MaxMP;
  Packet.MaxMP := Character.CurrentScore.MaxMP;
  Packet.Null := Ord(Update);

  SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendCurrentHPMPMob();
var
  Packet: TSendCurrentHPMPPacket;
begin
  if (Self.IsDungeonMob) or (Self.Mobid = 0) then
    Exit;

  ZeroMemory(@Packet, SizeOf(TSendCurrentHPMPPacket));
  Packet.Header.size := SizeOf(TSendCurrentHPMPPacket);
  Packet.Header.Code := $103;
  Packet.Header.Index := ClientID;

  Packet.CurHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobsP
    [Self.SecondIndex].HP;
  Packet.MaxHP := Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].InitHP;
  Packet.CurMP := Packet.CurHP; // Possível erro original
  Packet.MaxMP := Packet.MaxHP;

  SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendStatus;
var
  Packet: TSendRefreshStatus;
  temp_buff: Array [0 .. 12] of Byte;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  ZeroMemory(@Packet, $2C);

  With Packet do
  begin
    Packet.Header.size := SizeOf(Packet);
    Packet.Header.Code := $10A;
    Packet.Header.Index := $7535;

    Packet.DNFis := PlayerCharacter.Base.CurrentScore.DNFis;
    Packet.DEFFis := PlayerCharacter.Base.CurrentScore.DEFFis;
    Packet.DNMAG := PlayerCharacter.Base.CurrentScore.DNMAG;
    Packet.DEFMAG := PlayerCharacter.Base.CurrentScore.DEFMAG;
    Packet.Critico := PlayerCharacter.Base.CurrentScore.Critical;
    Packet.Esquiva := PlayerCharacter.Base.CurrentScore.Esquiva;
    Packet.Acerto := PlayerCharacter.Base.CurrentScore.Acerto;

    Packet.SpeedMove := PlayerCharacter.SpeedMove;
    Packet.Duplo := PlayerCharacter.DuploAtk;
    Packet.Resist := PlayerCharacter.Resistence;
  end;

  SendPacket(Packet, Packet.Header.size);

  ZeroMemory(@temp_buff, 12);
  TPacketHandlers.RequestAllAttributes(Servers[Self.ChannelId].Players
    [Self.ClientID], temp_buff);
end;

procedure TBaseMob.SendRefreshPoint;
var
  Packet: TSendRefreshPoint;
begin
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Exit;

  ZeroMemory(@Packet, SizeOf(TSendRefreshPoint));
  with Packet do
  begin
    Packet.Header.size := SizeOf(TSendRefreshPoint);
    Packet.Header.Code := $109;
    Packet.Header.Index := $7535;

    Move(PlayerCharacter.Base.CurrentScore, Packet.Pontos,
      SizeOf(Packet.Pontos));
    Packet.SkillsPoint := Self.Character.CurrentScore.SkillPoint;
    Packet.StatusPoint := Self.Character.CurrentScore.Status;
  end;

  SendPacket(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendRefreshKills;
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

procedure TBaseMob.SendEquipItems(SendSelf: Boolean = True);
begin
end;

procedure TBaseMob.SendRefreshBala(SlotItem: WORD; Item: TItem);
var
  Packet: TRefreshItemPacket;
begin

  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(TRefreshItemPacket);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $F0E;
  Packet.Notice := True;
  Packet.TypeSlot := EQUIP_TYPE;
  Packet.Slot := 15;
  Packet.Item := Item;
  Self.SendPacket(Packet, Packet.Header.size);

end;

procedure TBaseMob.SendRefreshItemSlot(SlotType, SlotItem: WORD; Item: TItem;
  Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
  Packet3: TRefreshItemPranPacket;
begin
  case SlotType of
    INV_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Inventory[SlotItem].Index) of
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
              Packet2.Item.Time := Item.Time;
              Packet2.Item.MIN := Item.MIN;
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
            ZeroMemory(@Packet, SizeOf(Packet));
            Packet.Header.size := SizeOf(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    EQUIP_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot
          (Self.Character.Equip[SlotItem].Index) of
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
            ZeroMemory(@Packet, SizeOf(Packet));
            Packet.Header.size := SizeOf(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
    STORAGE_TYPE:
      begin
        case TItemFunctions.GetItemEquipSlot(Servers[Self.ChannelId].Players
          [Self.ClientID].Account.Header.Storage.Itens[SlotItem].Index) of
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
            ZeroMemory(@Packet, SizeOf(Packet));
            Packet.Header.size := SizeOf(TRefreshItemPacket);
            Packet.Header.Index := $7535;
            Packet.Header.Code := $F0E;
            Packet.Notice := Notice;
            Packet.TypeSlot := SlotType;
            Packet.Slot := SlotItem;
            Packet.Item := Item;
            Self.SendPacket(Packet, Packet.Header.size);
          end;
        end;
      end;
  else
    begin
      ZeroMemory(@Packet, SizeOf(Packet));
      Packet.Header.size := SizeOf(TRefreshItemPacket);
      Packet.Header.Index := $7535;
      Packet.Header.Code := $F0E;
      Packet.Notice := Notice;
      Packet.TypeSlot := SlotType;
      Packet.Slot := SlotItem;
      Packet.Item := Item;
      Self.SendPacket(Packet, Packet.Header.size);
    end;
  end;
end;

procedure TBaseMob.SendRefreshItemSlot(SlotItem: WORD; Notice: Boolean);
var
  Packet: TRefreshItemPacket;
  Packet2: TRefreshMountPacket;
begin
  if not(TItemFunctions.GetItemEquipSlot(Self.Character.Inventory[SlotItem].
    Index) = 9) then
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
    Packet2.Item.Index := Self.Character.Inventory[SlotItem].Index;
    Packet2.Item.APP := Self.Character.Inventory[SlotItem].APP;
    Packet2.Item.Slot1 := Self.Character.Inventory[SlotItem].Effects.Index[0];
    Packet2.Item.Slot2 := Self.Character.Inventory[SlotItem].Effects.Index[1];
    Packet2.Item.Slot3 := Self.Character.Inventory[SlotItem].Effects.Index[2];
    Packet2.Item.Enc1 := Self.Character.Inventory[SlotItem].Effects.Value[0];
    Packet2.Item.Enc2 := Self.Character.Inventory[SlotItem].Effects.Value[1];
    Packet2.Item.Enc3 := Self.Character.Inventory[SlotItem].Effects.Value[2];
    Packet2.Item.Time := Self.Character.Inventory[SlotItem].Time;
    Self.SendPacket(Packet2, Packet2.Header.size);
  end;
end;

procedure TBaseMob.SendSpawnMobs;
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

procedure TBaseMob.GenerateBabyMob;
// var pos: TPosition; i, j: BYTE; mIndex, id: WORD;
// party : PParty;
// var
// babyId, babyClientId: WORD;
// party : PParty;
// i, j: Byte;
// pos: TPosition;
begin
end;

procedure TBaseMob.UngenerateBabyMob(ungenEffect: WORD);
// evok pode ser usado pra skill de att
// var pos: TPosition; i,j: BYTE; party : PParty; find: boolean;
begin
end;
{$ENDREGION}
{$REGION 'Gets'}

procedure TBaseMob.GetCreateMob(out Packet: TSendCreateMobPacket; P1: WORD;
  Custom: Integer = 0);
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
  // Packet.Equip[0] := 223;

  // if Self.BuffExistsByID(9119) then
  // begin
  // Packet.Equip[0] := 1105;
  // Packet.Equip[1] := Character^.Equip[1].Index;
  //
  //
  // for i := 2 to 7 do
  // begin
  // if (Character^.Equip[i].APP = 0) or not(Self.IsPlayer) then
  // Packet.Equip[i] := Character^.Equip[i].Index
  // else
  // Packet.Equip[i] := Character^.Equip[i].APP;
  // end;
  // end
  // else
  // begin
  //
  // Packet.Equip[0] := Character^.Equip[0].Index;
  // Packet.Equip[1] := Character^.Equip[1].Index;
  //
  //
  // for i := 2 to 7 do
  // begin
  // if (Character^.Equip[i].APP = 0) or not(Self.IsPlayer) then
  // Packet.Equip[i] := Character^.Equip[i].Index
  // else
  // Packet.Equip[i] := Character^.Equip[i].APP;
  // end;
  // end;

  // Exit;

  Packet.Equip[0] := Character^.Equip[0].Index;
  Packet.Equip[1] := Character^.Equip[1].Index;

  for i := 2 to 7 do
  begin
    if (Character^.Equip[i].APP = 0) then
    begin
      Packet.Equip[i] := Character^.Equip[i].Index;
      Continue;
    end;
    Packet.Equip[i] := Character^.Equip[i].APP;
  end;

  Packet.SpeedMove := Self.PlayerCharacter.SpeedMove;
  Packet.MaxHP := Character^.CurrentScore.MaxHP;
  Packet.MaxMP := Character^.CurrentScore.MaxHP;

  Packet.ChaosPoint := Servers[Self.ChannelId].Players[Self.ClientID]
    .Base.Character.CurrentScore.Infamia;
  //
  if Servers[Self.ChannelId].Players[Self.ClientID].Base.Character.CurrentScore.
    Infamia >= 128 then
    Packet.ChaosPoint := 127
  else
    Packet.ChaosPoint := Servers[Self.ChannelId].Players[Self.ClientID]
      .Base.Character.CurrentScore.Infamia;

  Packet.MaxHP := Self.GetCurrentHP;
  Packet.MaxMP := Self.GetCurrentMP;
  Packet.TitleId := Self.ActiveTitle;
  Packet.Unk0 := $0A;
  // Packet.Unk0
  // Packet.Effects[0] := Custom;
  Packet.Effects[1] := $1D;
  // Packet.Effects[1] := $ff;

  // Packet.Effects[0]:= custom;
  // Packet.Effects[1]:= custom;

  // WriteLn('mexer aqui para remover esses efeitos malucos ');

  // Packet.Effects[0] := $4A;
  // Packet.Effects[1] := 240;
  // Packet.Effects[2] := 240;
  // Packet.Effects[3] := 240;

  Packet.GuildIndexAndNation := Character^.Nation * 4096;
  if (Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.Base.GuildIndex) > 0 then
  begin
    AnsiStrings.StrPCopy(Packet.Title,
      AnsiString(Guilds[Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.GuildSlot].Name));
    Packet.GuildIndexAndNation := StrToInt('$' + IntToStr(Character.Nation) +
      IntToHex(Servers[Self.ChannelId].Players[Self.ClientID]
      .Character.Base.GuildIndex, 3));
  end;


  // Processamento do valor e armazenamento em ItemEff
  // var Valor :=
  // var HexValor := IntToHex(Valor, 4);

  Packet.ItemEffPedra := Character^.Equip[8].Index; // efeito da pedra    00 01
  Packet.ItemEffMontaria := Character^.Equip[9].Index;
  // efeito da montaria  02 03

  Packet.ItemEffArmaRefine := 15; // Item effect 07

  // Packet.ItemEff[2] := StrToInt('$' + HexValor[3] + HexValor[4]);  // Byte de A6
  // Packet.ItemEff[3] := StrToInt('$' + HexValor[1] + HexValor[2]);  // Byte de 03
  //
  //
  // var Valor1 := Character^.Equip[8].index;
  /// /  var Valor1 := custom;
  // var HexValor1 := IntToHex(Valor1, 4);

  //
  // Packet.ItemEff[0] := StrToInt('$' + HexValor1[3] + HexValor1[4]);  // Byte de A6
  // Packet.ItemEff[1] := StrToInt('$' + HexValor1[1] + HexValor1[2]);  // Byte de 03

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

end;

class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: TBaseMob): Boolean;
begin
  Result := false;
  if (Index = 0) or (Index > MAX_SPAWN_ID) then
    Exit;

  if (mob.Character = nil) or not mob.IsActive then
    Exit;

  Result := True;
end;

class function TBaseMob.GetMob(Index: WORD; Channel: Byte;
  out mob: PBaseMob): Boolean;
begin
  if (index = 0) then
    Exit(false);

  if (index <= MAX_CONNECTIONS) then
    mob := @Servers[Channel].Players[index].Base
  else if (Index > MAX_CONNECTIONS) AND (index < 3391) then
    mob := @Servers[Channel].NPCs[index].Base
  else
    mob := @Servers[Channel].RoyalGuards[index].Base;

  Result := mob.IsActive;
end;

function TBaseMob.GetMobAbility(eff: Integer): Integer;
begin
  Result := Self.MOB_EF[eff];
end;

procedure TBaseMob.IncreasseMobAbility(eff: Integer; Value: Integer);
begin
  Inc(Self.MOB_EF[eff], Value);
end;

procedure TBaseMob.DecreasseMobAbility(eff: Integer; Value: Integer);
begin
  if Value < 0 then
    Inc(Self.MOB_EF[eff], -Value)
  else
    decInt(Self.MOB_EF[eff], Value);
end;

function TBaseMob.GetCurrentHP(): DWORD;
var
  hp_inc, hp_perc, mob_class, cons_score, Level, hp_increment_per_level,
    equiped_hp_inc: DWORD;
  nation_id, reliq_effect: DWORD;
begin
  // Armazenar valores constantes em variáveis locais
  mob_class := GetMobClass(Character.ClassInfo);
  Level := Character.Level;
  cons_score := PlayerCharacter.Base.CurrentScore.CONS;
  hp_increment_per_level := HPIncrementPerLevel[mob_class];
  equiped_hp_inc := Self.GetEquipedItensHPMPInc;

  // Calcular hp_inc inicial
  hp_inc := GetMobAbility(EF_HP);
  Inc(hp_inc, (Round(hp_increment_per_level * 1.5) * Level));
  Inc(hp_inc, (cons_score * 27));
  Inc(hp_inc, equiped_hp_inc);

  // Aplicar porcentagens de incremento
  hp_perc := GetMobAbility(EF_MARSHAL_PER_HP);
  Inc(hp_inc, (hp_perc * (hp_inc div 100)));

  // Verificar efeito de relíquia
  if (Self.Character <> nil) then
  begin
    nation_id := Self.Character.Nation;
    if (Servers[Self.ChannelId].NationID = nation_id) then
    begin
      reliq_effect := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
      Inc(hp_inc, (reliq_effect * (hp_inc div 100)));
    end;
  end;

  // Aplicar porcentagem final de HP
  hp_perc := GetMobAbility(EF_PER_HP);
  Inc(hp_inc, (hp_perc * (hp_inc div 100)));

  // Garantir que hp_inc seja pelo menos 1
  if (hp_inc <= 0) then
    hp_inc := 1;

  Result := hp_inc;
end;

function TBaseMob.GetCurrentMP(): DWORD;
var
  mp_inc, mp_perc, base_mp, luck_bonus, level_bonus, equip_bonus: DWORD;
  mob_class: Integer;
begin
  // Calcular valores base uma vez
  mob_class := GetMobClass(Character.ClassInfo);
  base_mp := GetMobAbility(EF_MP);
  luck_bonus := PlayerCharacter.Base.CurrentScore.luck * 27;
  level_bonus := Round(MPIncrementPerLevel[mob_class] * 0.5) * Character.Level;
  equip_bonus := Self.GetEquipedItensHPMPInc;

  // Somar todos os incrementos base
  mp_inc := base_mp + level_bonus + luck_bonus + equip_bonus;

  // Aplicar porcentagens
  mp_perc := GetMobAbility(EF_MARSHAL_PER_MP);
  Inc(mp_inc, (mp_perc * (mp_inc div 100)));

  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  begin
    mp_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_HP];
    Inc(mp_inc, (mp_perc * (mp_inc div 100)));
  end;

  mp_perc := GetMobAbility(EF_PER_MP);
  Inc(mp_inc, (mp_perc * (mp_inc div 100)));

  // Garantir que o valor mínimo seja 1
  if (mp_inc <= 0) then
    mp_inc := 1;

  Result := mp_inc;
end;

function TBaseMob.GetRegenerationHP(): DWORD;
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

function TBaseMob.GetRegenerationMP(): DWORD;
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

function TBaseMob.GetEquipedItensHPMPInc: DWORD;
var
  i, Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) or (Self.Character.Equip[i].Time > 0) then
      Continue;

    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine > 0) then
      Inc(Result, TItemFunctions.GetItemReinforceHPMPInc(Self.Character.Equip[i]
        .Index, Refine - 1));
  end;
end;

function TBaseMob.GetEquipedItensDamageReduce: DWORD;
var
  i, Refine: Byte;
begin
  Result := 0;
  for i := 2 to 7 do
  begin
    if (i = 6) or (Self.Character.Equip[i].Time > 0) then
      Continue;

    Refine := TItemFunctions.GetReinforceFromItem(Self.Character.Equip[i]);
    if (Refine > 0) then
      Inc(Result, TItemFunctions.GetItemReinforceDamageReduction
        (Self.Character.Equip[i].Index, Refine - 1));
  end;
end;

function TBaseMob.GetMobClass(ClassInfo: WORD = 0): WORD;
begin
  if (Self.ClientID <= MAX_CONNECTIONS) then
  begin
    if (ClassInfo = 0) then
      ClassInfo := Self.Character.ClassInfo;
    Result := ClassInfo div 10;
  end
  else
    Result := 0;
end;

function TBaseMob.GetMobClassPlayer: Byte;
var
  ClassInfo: Byte;
begin
  ClassInfo := Self.Character.ClassInfo;
  Result := ClassInfo div 10;
end;

procedure TBaseMob.GetEquipDamage(const Equip: TItem);
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

procedure TBaseMob.GetEquipDefense(const Equip: TItem);
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

procedure TBaseMob.GetEquipsDefense;
var
  i: Integer;
begin
  Self.PlayerCharacter.Base.CurrentScore.DEFMAG := 0;
  Self.PlayerCharacter.Base.CurrentScore.DEFFis := 0;

  for i := 2 to 7 do
  begin
    if (i = 6) then
      Continue;

    if Self.Character.Equip[i].MIN = 0 then
      Continue;

    Self.GetEquipDefense(Self.Character.Equip[i]);
  end;
end;

procedure TBaseMob.GetCurrentScore;
var
  Damage_perc, Def_perc: WORD;
begin
  if (Self.ClientID > MAX_CONNECTIONS) then
    Exit;

  // Zerar os valores iniciais
  ZeroMemory(@PlayerCharacter.Base.CurrentScore,
    SizeOf(PlayerCharacter.Base.CurrentScore));
  with PlayerCharacter do
  begin
    DuploAtk := 0;
    SpeedMove := 0;
    Resistence := 0;
    HabAtk := 0;
    DamageCritical := 0;
    ResDamageCritical := 0;
    MagPenetration := 0;
    FisPenetration := 0;
    CureTax := 0;
    CritRes := 0;
    DuploRes := 0;
    ReduceCooldown := 0;
    PvPDamage := 0;
    PvPDefense := 0;
  end;

  // Atualizar Status Points
  with PlayerCharacter.Base.CurrentScore do
  begin
    IncCritical(Str, Character.CurrentScore.Str + Self.GetMobAbility(EF_STR));
    IncCritical(agility, Character.CurrentScore.agility +
      Self.GetMobAbility(EF_DEX));
    IncCritical(Int, Character.CurrentScore.Int + Self.GetMobAbility(EF_INT));
    IncCritical(CONS, Character.CurrentScore.CONS + Self.GetMobAbility(EF_CON));
    IncCritical(luck, Character.CurrentScore.luck + Self.GetMobAbility(EF_SPI));
  end;

  // SpeedMove
  IncSpeedMove(PlayerCharacter.SpeedMove, 40 + Self.GetMobAbility(EF_RUNSPEED));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncSpeedMove(PlayerCharacter.SpeedMove, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_RUNSPEED]);

  // Duplo Atk
  IncCritical(PlayerCharacter.DuploAtk,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.21));
  IncCritical(PlayerCharacter.DuploAtk, Servers[Self.ChannelId].ReliqEffect
    [EF_RELIQUE_DOUBLE]);
  IncCritical(PlayerCharacter.DuploAtk, Self.GetMobAbility(EF_DOUBLE));

  // Critical
  IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.13));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_CRITICAL]);
  IncCritical(PlayerCharacter.Base.CurrentScore.Critical,
    Self.GetMobAbility(EF_CRITICAL));

  // Damage Critical
  IncCritical(PlayerCharacter.DamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.2));
  IncCritical(PlayerCharacter.DamageCritical,
    Self.GetMobAbility(EF_CRITICAL_POWER));

  // Penetration Fis and Mag
  IncCooldown(PlayerCharacter.FisPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.04));
  IncCooldown(PlayerCharacter.MagPenetration,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.34));
  IncCooldown(PlayerCharacter.FisPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE1));
  IncCooldown(PlayerCharacter.MagPenetration,
    Self.GetMobAbility(EF_PIERCING_RESISTANCE2));

  // PvP Damage
  IncWORD(PlayerCharacter.PvPDamage, Self.GetMobAbility(EF_ATK_NATION2));

  // PvP Defense
  IncWORD(PlayerCharacter.PvPDefense, Self.GetMobAbility(EF_DEF_NATION2));

  // Hab Skill Atk
  IncWORD(PlayerCharacter.HabAtk, PlayerCharacter.Base.CurrentScore.luck * 6);
  IncWORD(PlayerCharacter.HabAtk, Self.GetMobAbility(EF_SKILL_DAMAGE));

  // Cure Tax
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.3));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.1));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 0.1));
  IncCritical(PlayerCharacter.CureTax,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.1));

  // Res Crit
  IncCritical(PlayerCharacter.CritRes,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.15));
  IncCritical(PlayerCharacter.CritRes,
    Trunc(PlayerCharacter.Base.CurrentScore.luck * 0.2));
  IncCritical(PlayerCharacter.CritRes, Self.GetMobAbility(EF_RESISTANCE6));

  // Res Damage Crit
  IncCritical(PlayerCharacter.ResDamageCritical,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.2));
  IncCritical(PlayerCharacter.ResDamageCritical,
    Self.GetMobAbility(EF_CRITICAL_DEFENCE));

  // Res Duplo
  IncCritical(PlayerCharacter.DuploRes,
    Trunc(PlayerCharacter.Base.CurrentScore.CONS * 0.34));
  IncCritical(PlayerCharacter.DuploRes, Self.GetMobAbility(EF_RESISTANCE7));

  // Acerto
  IncWORD(PlayerCharacter.Base.CurrentScore.Acerto,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.5));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncWORD(PlayerCharacter.Base.CurrentScore.Acerto,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_HIT]);
  IncWORD(PlayerCharacter.Base.CurrentScore.Acerto, Self.GetMobAbility(EF_HIT));

  // Esquiva
  IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 0.021));
  IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PRAN_PARRY));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PARRY]);
  IncWORD(PlayerCharacter.Base.CurrentScore.Esquiva,
    Self.GetMobAbility(EF_PARRY));

  // Resistence
  IncCritical(PlayerCharacter.Resistence,
    Round(PlayerCharacter.Base.CurrentScore.luck * 0.1));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCritical(PlayerCharacter.Resistence, Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_STATE_RESISTANCE]);
  IncCritical(PlayerCharacter.Resistence,
    Self.GetMobAbility(EF_STATE_RESISTANCE));

  // Cooldown Time
  IncCooldown(PlayerCharacter.ReduceCooldown,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 0.25));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    IncCooldown(PlayerCharacter.ReduceCooldown,
      Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_COOLTIME]);
  IncCooldown(PlayerCharacter.ReduceCooldown, Self.GetMobAbility(EF_COOLTIME));

  // Get Def
  Self.GetEquipsDefense;

  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE1);
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFFis,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFFis div 100)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE1];

  Def_perc := Self.GetMobAbility(EF_PER_RESISTANCE2);
  IncWORD(PlayerCharacter.Base.CurrentScore.DEFMAG,
    Trunc(Def_perc * (PlayerCharacter.Base.CurrentScore.DEFMAG div 100)));
  if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    Def_perc := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_RESISTANCE2];

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

  // Get Atk
  Self.GetEquipDamage(Self.Character.Equip[6]);

  // Atk Fis
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc(PlayerCharacter.Base.CurrentScore.Str * 2.6));
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc(PlayerCharacter.Base.CurrentScore.agility * 2.6));
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Self.GetMobAbility(EF_PRAN_DAMAGE1));

  Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE1);
  IncWORD(PlayerCharacter.Base.CurrentScore.DNFis,
    Trunc((PlayerCharacter.Base.CurrentScore.DNFis div 100) * Damage_perc));
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

  // Atk Mag
  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc(PlayerCharacter.Base.CurrentScore.Int * 3.2));
  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Self.GetMobAbility(EF_PRAN_DAMAGE2));

  Damage_perc := Self.GetMobAbility(EF_PER_DAMAGE2);
  IncWORD(PlayerCharacter.Base.CurrentScore.DNMAG,
    Trunc((PlayerCharacter.Base.CurrentScore.DNMAG div 100) * Damage_perc));
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
end;
{$ENDREGION}
{$REGION 'Buffs'}

procedure TBaseMob.SendRefreshBuffs();
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
      (SkillData[Index].Duration)));
    Inc(i);
  end;
  if (Self.ClientID >= 3048) or (Self.IsDungeonMob) then
    Self.SendToVisible(Packet, Packet.Header.size, false)
  else
    Self.SendToVisible(Packet, Packet.Header.size);
end;

procedure TBaseMob.SendAddBuff(BuffIndex: WORD);
var
  Packet: TUpdateBuffPacket;
  EndTime: TDateTime;
begin
  ZeroMemory(@Packet, SizeOf(Packet));
  Packet.Header.size := SizeOf(Packet);
  Packet.Header.Code := $16F;
  Packet.Buff := BuffIndex;
  EndTime := IncSecond(Self._buffs[BuffIndex], (SkillData[BuffIndex].Duration));
  Packet.EndTime := DateTimeToUnix(EndTime);
  if (Self.ClientID >= 3048) then
    Self.SendToVisible(Packet, Packet.Header.size, false)
  else
    Self.SendPacket(Packet, Packet.Header.size);
  Self.SendRefreshBuffs;
  Self.SendRefreshPoint;
  Self.SendStatus;
end;

function TBaseMob.RefreshBuffs: Integer;
var
  Index: WORD;
  EndTime: TDateTime;
  // TimeNow: TDateTime;
  i: Integer;
begin
  Result := 0;
  for Index in Self._buffs.Keys do
  begin
    EndTime := IncSecond(Self._buffs[Index], SkillData[Index].Duration);
    // TimeNow := Now;
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

  // mod se der merda foi aqui por conta verificar if clientid <= max_connections
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

function TBaseMob.AddBuff(BuffIndex: WORD; Refresh: Boolean = True;
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
    if Self.GetBuffLeveL(SkillData[BuffIndex].Index) > SkillData[BuffIndex].Level
    then
      Exit;
    // begin
    // Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage('Buff de status maior(level mais alto) mantido');

    // end;

    Self.RemoveBuffByIndex(SkillData[BuffIndex].Index);
  end;

  // if (Self.Character <> nil) and (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
  // begin
  // TimeAditional := TimeAditional + ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] * SkillData[BuffIndex].Duration) div 100);
  // end;

  if (Self._buffs.ContainsKey(BuffIndex)) then
  begin
    Result := True;
    if (Self.Character <> nil) then
    begin // arrumar pro debuff n?o aumentar em nation mas sim no inimigo
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;

      { if((SkillData[BuffIndex].Duration >= 600) and
        (SkillData[BuffIndex].MP > 0)) then
        begin
        if(Self.GetMobAbility(EF_SKILL_ATIME6) > 0) then
        begin
        TimeAditional := TimeAditional +
        (Self.GetMobAbility(EF_SKILL_ATIME6) * 60);
        end;
        end; }
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
    begin // arrumar pro debuff n?o aumentar em nation mas sim no inimigo
      if (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
      begin
        TimeAditional := TimeAditional +
          ((Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_SKILL_ATIME0] *
          SkillData[BuffIndex].Duration) div 100);
      end;

      { if((SkillData[BuffIndex].Duration >= 600) and
        (SkillData[BuffIndex].MP > 0)) then
        begin
        if(Self.GetMobAbility(EF_SKILL_ATIME6) > 0) then
        begin
        TimeAditional := TimeAditional +
        (Self.GetMobAbility(EF_SKILL_ATIME6) * 60);
        end;
        end; }
    end;
    Self._buffs.Add(BuffIndex, IncSecond(Now, TimeAditional));
    Self.AddBuffEffect(BuffIndex);

      Logger.Write('=-=-=-=-=-=-=-=-=-=-=-', Warnings);
      Logger.Write('Name: [' + SkillData[BuffIndex].Name + ']', Warnings);
      Logger.Write('Index: [' + SkillData[BuffIndex].Index.ToString + ']', Warnings);
      Logger.Write('Efeito 1: [' + SkillData[BuffIndex].EF[0].ToString + '] Valor: [' + SkillData[BuffIndex].EFV[0].ToString + ']', Warnings);
      Logger.Write('Efeito 2: [' + SkillData[BuffIndex].EF[1].ToString + '] Valor: [' + SkillData[BuffIndex].EFV[1].ToString + ']', Warnings);
      Logger.Write('Efeito 3: [' + SkillData[BuffIndex].EF[2].ToString + '] Valor: [' + SkillData[BuffIndex].EFV[2].ToString + ']', Warnings);
      Logger.Write('=-=-=-=-=-=-=-=-=-=-=-', Warnings);

    Self.GetCurrentScore;
    BuffSlot := Self.GetEmptyBuffSlot;
    if (BuffSlot >= 0) then
    begin
      Self.PlayerCharacter.Buffs[BuffSlot].Index := BuffIndex;
      Self.PlayerCharacter.Buffs[BuffSlot].CreationTime :=
        Self._buffs[BuffIndex];
    end;
  end;
  if (Refresh) then
  begin
    Self.SendAddBuff(BuffIndex);
  end;
end;

function TBaseMob.AddBuffWhenEntering(BuffIndex: Integer;
  BuffTime: TDateTime): Boolean;
begin
  Result := True;
  if not Self._buffs.ContainsKey(BuffIndex) then
  begin
    Self._buffs.Add(BuffIndex, BuffTime);
    Self.AddBuffEffect(BuffIndex);
  end;
end;

function TBaseMob.GetBuffSlot(BuffIndex: WORD): Integer;
var
  i: Integer;
begin
  Result := -1;
  if (Self.ClientID <= MAX_CONNECTIONS) then
  begin
    for i := 0 to 59 do
      if (Self.PlayerCharacter.Buffs[i].Index = BuffIndex) then
      begin
        Result := i;
        Break;
      end;
  end;
end;

function TBaseMob.GetEmptyBuffSlot(): Integer;
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

function TBaseMob.RemoveBuff(BuffIndex: WORD): Boolean;
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
    Result := True;
  end;

  if Result then
  begin
    Self.GetCurrentScore;
    Self.SendStatus;
    Self.SendRefreshPoint;
    Self.SendRefreshBuffs;
  end;

  case SkillData[BuffIndex].Index of
    35: // uniao divina
      Self.UniaoDivina := '';
    42:
      Self.HPRListener := false;
    49, 73: // contagem regressiva e mjolnir
      begin
        Randomize;
        Self.RemoveHP((RandomRange(15, 90) + SkillData[BuffIndex].EFV[0]),
          True, True);
      end;
    65: // x14
      begin
        // Self.DestroyPet(Self.PetClientID);
        Self.PetClientID := 0;
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

procedure TBaseMob.RemoveAllDebuffs();
var
  i: WORD;
begin
  if Self._buffs.Count = 0 then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].BuffDebuff in [3, 4]) then
      Self.RemoveBuff(i);
  end;
end;

procedure TBaseMob.AddBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if Self.IsDungeonMob then
    Exit;

  for i := 0 to 3 do
  begin
    if (i = EF_RUNSPEED) and (Self.MOB_EF[EF_RUNSPEED] + SkillData[Index].EFV[i]
      >= 13) then
      Self.MOB_EF[EF_RUNSPEED] := 13
    else
      Self.IncreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
  end;
end;

procedure TBaseMob.RemoveBuffEffect(Index: WORD);
var
  i: Integer;
begin
  if Self.IsDungeonMob then
    Exit;

  for i := 0 to 3 do
    Self.DecreasseMobAbility(SkillData[Index].EF[i], SkillData[Index].EFV[i]);
end;

function TBaseMob.GetBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if SkillData[i].BuffDebuff = 1 then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TBaseMob.GetDeBuffToRemove(): DWORD;
var
  i: WORD;
begin
  Result := 0;
  for i in Self._buffs.Keys do
  begin
    if SkillData[i].BuffDebuff in [3, 4] then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

function TBaseMob.GetDebuffCount(): WORD;
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

function TBaseMob.GetBuffCount(): WORD;
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

procedure TBaseMob.RemoveBuffByIndex(Index: WORD);
var
  i: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (SkillData[i].Index = Index) then
    begin
      Self.RemoveBuff(i);
      Exit;
    end;
  end;
end;

function TBaseMob.GetBuffSameIndex(BuffIndex: DWORD): Boolean;
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
      Exit;
    end;
  end;
end;

function TBaseMob.GetBuffLeveL(BuffIndex: DWORD): Integer;
var
  i: Integer;
begin
  if (BuffIndex = 0) or (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (BuffIndex = SkillData[i].Index) then
    begin
      Result := SkillData[i].Level;
      // WriteLn('resultado 1 ' + result.ToString);
      Exit;
    end;
  end;
end;

function TBaseMob.BuffExistsByIndex(BuffIndex: WORD): Boolean;
var
  i: Byte;
begin
  Result := false;
  if (BuffIndex = 0) or (Self._buffs.Count = 0) then
    Exit;

  for i in Self._buffs.Keys do
  begin
    if (BuffIndex = SkillData[i].Index) then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TBaseMob.BuffExistsByIndexDungeon(BuffIndex: DWORD;
  Player: PBaseMob): Boolean;
begin
  Result := BuffExistsByIndex(BuffIndex); // Reutiliza a função existente
end;

function TBaseMob.BuffExistsByID(BuffID: DWORD): Boolean;
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
      Exit;
    end;
  end;
end;

function TBaseMob.BuffExistsInArray(const BuffList: Array of DWORD): Boolean;
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
        Exit; // Retorna imediatamente quando encontra um buff correspondente
      end;
    end;
  end;
end;

function TBaseMob.BuffExistsSopa(): Boolean;
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
      Exit;
    end;
  end;
end;

function TBaseMob.GetBuffIDByIndex(Index: DWORD): WORD;
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
      Exit;
    end;
  end;
end;

procedure TBaseMob.RemoveBuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;

  cnt := 0;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      Exit;

    if (SkillData[i].BuffDebuff = 1) and (Self.RemoveBuff(i)) then
      Inc(cnt);
  end;
end;

procedure TBaseMob.RemoveDebuffs(Quant: Byte);
var
  i, cnt: WORD;
begin
  if (Self._buffs.Count = 0) then
    Exit;

  cnt := 0;
  for i in Self._buffs.Keys do
  begin
    if (cnt >= Quant) then
      Exit;

    if ((SkillData[i].BuffDebuff in [3, 4]) and (Self.RemoveBuff(i))) then
      Inc(cnt);
  end;
end;

procedure TBaseMob.ZerarBuffs();
var
  i: Integer;
begin
  for i in Self._buffs.Keys do
    Self.RemoveBuff(i);
end;

{$ENDREGION}
{$REGION 'Attack & Skills'}

procedure TBaseMob.CheckCooldown(var Packet: TSendSkillUse);
begin
  if (Self._cooldown.ContainsKey(Packet.Skill)) and
    (IncMillisecond(Self._cooldown[Packet.Skill],
    SkillData[Packet.Skill].Cooldown) >= Now) then
    Exit;

  Self.UsingSkill := Packet.Skill;
  Self.SendToVisible(Packet, Packet.Header.size, True);
end;

function TBaseMob.CheckCooldown3(var Packet: TSendSkillUse): Boolean;
begin
  Result := not((Self._cooldown.ContainsKey(Packet.Skill)) and
    (IncMillisecond(Self._cooldown[Packet.Skill],
    SkillData[Packet.Skill].Cooldown) >= Now));

  if Result then
  begin
    Self.UsingSkill := Packet.Skill;
    Self.SendToVisible(Packet, Packet.Header.size, True);
  end;
end;

procedure TBaseMob.SendCurrentAllSkillCooldown();
var
  Packet: Tp12C;
  i: Integer;
  CurrTime: TTime;
  OPlayer: PPlayer;
  SkillID: DWORD;
begin
  ZeroMemory(@Packet, SizeOf(Tp12C));
  Packet.Header.size := SizeOf(Tp12C);
  Packet.Header.Index := $7535;
  Packet.Header.Code := $12C;

  OPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  for i := 0 to 5 do
  begin
    SkillID := OPlayer.Character.Skills.Basics[i].
      Index + OPlayer.Character.Skills.Basics[i].Level - 1;
    if (Self._cooldown.ContainsKey(SkillID)) then
    begin
      Self._cooldown.TryGetValue(SkillID, CurrTime);
      Packet.Skills[i] := SkillData[SkillID].Duration -
        ((SkillData[SkillID].Duration div 100) *
        Self.PlayerCharacter.ReduceCooldown) - SecondsBetween(CurrTime, Now);
    end;
  end;

  for i := 0 to 39 do
  begin
    SkillID := OPlayer.Character.Skills.Others[i].
      Index + OPlayer.Character.Skills.Others[i].Level - 1;
    if (Self._cooldown.ContainsKey(SkillID)) then
    begin
      Self._cooldown.TryGetValue(SkillID, CurrTime);
      Packet.Skills[i] := SkillData[SkillID].Duration -
        ((SkillData[SkillID].Duration div 100) *
        Self.PlayerCharacter.ReduceCooldown) - SecondsBetween(CurrTime, Now);
    end;
  end;

  Self.SendPacket(Packet, Packet.Header.size);
end;

function TBaseMob.CheckCooldown2(SkillID: DWORD): Boolean;
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
    begin
      // Self.SendCurrentAllSkillCooldown;
      Result := false
    end
    else
      Self._cooldown[SkillID] := Now;
  end
  else
    Self._cooldown.Add(SkillID, Now);
end;

procedure TBaseMob.SendDamage(Skill: WORD; Anim: DWORD; mob: PBaseMob;
  DataSkill: P_SkillData; Tipo: Byte);
var
  Packet: TRecvDamagePacket;
  Add_Buff: Boolean;
  j: Integer;
  DropExp, DropItem: Boolean;
  MobsP: PMobSPoisition;
  xDano, helper: Integer;
  DungeonPointer: PDungeonInstance;
  SelfPlayer, OtherPlayer: PPlayer;
  SelfBase: PBaseMob;
  RoyalGuarda: PNpc;
  RoyalGuardaPlayerChar: PCustomNpc;
  DevirGuardas: PNpc;
  DevirNpcs: PNpc;
  DevirNpcHelper: PNpc;
  OtherPlayerMobLoop: PPlayer;
  Freq: Int64;
  StartCount, EndCount: Int64;
  ElapsedTime: System.Double;

begin
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  SelfBase := @Servers[Self.ChannelId].Players[Self.ClientID].Base;

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

  xDano := Self.GetDamage(Skill, mob, Packet.DnType, Tipo);

  if xDano > 0 then
  begin
    Self.AttackParse(Skill, Anim, mob, xDano, Packet.DnType, Add_Buff,
      Packet.MobAnimation, DataSkill, Tipo);
    if xDano > 0 then
      Inc(xDano, (RandomRange((xDano div 20), (xDano div 10)) + 13));
  end
  else if xDano < 0 then
    xDano := 0;

  Packet.Dano := xDano;

  // Ajusta o dano com base na classe do jogador
  case SelfPlayer^.Base.GetMobClassPlayer of
    0:
      Packet.Dano := Trunc(Packet.Dano / 1.6);
    1:
      Packet.Dano := Packet.Dano + Trunc(Packet.Dano / 1.8);
    2:
      Packet.Dano := Trunc(Packet.Dano / 1.2);
    3:
      Packet.Dano := Trunc(Packet.Dano * 1.2);
  end;

  case Tipo of
    1: // players
      begin
        OtherPlayer := @Servers[Self.ChannelId].Players[mob^.ClientID];

        // Verifica se o alvo acabou de nascer
        if SecondsBetween(Now, OtherPlayer^.Base.RevivedTime) <= 7 then
        begin
          SelfPlayer^.SendClientMessage('Alvo acabou de nascer.');
          Exit;
        end;

        if Packet.Dano < mob^.Character.CurrentScore.CurHP then
        begin
          Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP - dword(Packet.DANO);
          SelfBase^.SendToVisible(Packet, Packet.Header.size, True);
          
          if Packet.Dano > 0 then
            mob^.RemoveHP(Packet.Dano, false);

          if OtherPlayer^.CollectingReliquare then
            OtherPlayer^.SendCancelCollectItem(OtherPlayer^.CollectingID);

          mob^.LastReceivedAttack := Now;

        end
        else
        begin
          // Se o mob for derrotado
          if not OtherPlayer^.Dueling then
          begin
          mob^.IsDead := True;
          Packet.MobAnimation := 30;
          Packet.MobCurrHP := 0;
          Self.SendToVisible(Packet, Packet.Header.size);
          
            mob^.Character.CurrentScore.CurHP := 0;
            mob^.SendEffect($0);
            
              if OtherPlayer^.CollectingReliquare then
              OtherPlayer^.SendCancelCollectItem(OtherPlayer^.CollectingID);
              mob^.LastReceivedAttack := Now;
              mob^.SendEffectOther($3F, 1);
              Self.PlayerKilled(mob);            
            


              
          
          end
          else
          begin
            Packet.MobCurrHP := 0;
            Self.SendToVisible(Packet, Packet.Header.size);
            mob^.Character.CurrentScore.CurHP := 10;
          end;
        end;
        Exit;
      end;

    2, 6: // mob normal e mob extra spawnado via cmd ou item
      begin
        MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[0].MobsP[1];
        if (mob^.SecondIndex > 0) then
          MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
            [mob^.SecondIndex];

        if not MobsP^.IsAttacked then
          MobsP^.FirstPlayerAttacker := SelfBase^.ClientID;

        if Packet.Dano < MobsP^.HP then
        begin
        Packet.MobCurrHP := MobsP^.HP - dword(Packet.DANO);
        SelfBase^.SendToVisible(Packet, Packet.Header.size, True);

        MobsP^.HP := MobsP^.HP - dword(Packet.DANO);
        mob^.LastReceivedAttack := Now;

        Exit;
        end
        else
        begin

          mob^.IsDead := True;
          Packet.MobAnimation := 30;
          Packet.MobCurrHP := 0;
          SelfBase^.SendToVisible(Packet, Packet.Header.size, True);

          mob^.LastReceivedAttack := Now;
          MobsP^.HP := 0;
          MobsP^.IsAttacked := false;
          MobsP^.AttackerID := 0;
          MobsP^.deadTime := Now;

          MobsP^.Base.SendEffect($0);
          mob^.SendCurrentHPMPMob;

          if Self.VisibleMobs.Contains(mob^.ClientID) then
          begin
            Self.VisibleMobs.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
          end;

          for j := Low(Servers[Self.ChannelId].Players)
            to High(Servers[Self.ChannelId].Players) do
          begin
            OtherPlayerMobLoop := @Servers[SelfBase^.ChannelId].Players[j];
            if (OtherPlayerMobLoop^.Status <> Playing) or OtherPlayerMobLoop^.SocketClosed
            then
              Continue;

            if OtherPlayerMobLoop^.Base.VisibleMobs.Contains(mob^.ClientID) then
            begin
              OtherPlayerMobLoop^.Base.VisibleMobs.Remove(mob^.ClientID);
              OtherPlayerMobLoop^.Base.RemoveTargetFromList(mob);
            end;
          end;

              if mob^.SecondIndex > 0 then
              begin
                if (mob^.ClientID >= 3049) and (mob^.ClientID <= 9147) then
                begin
                  if Servers[Self.ChannelId].MOBS.TMobS[mob^.Mobid].IsActiveToSpawn then
                    SelfBase^.MobKilled(mob, DropExp, DropItem, false);
                end;
              end;

          mob^.VisibleMobs.Clear;

        Exit;
        end;


      end;
    8: // dungeon mobs
      begin

        DungeonPointer := @DungeonInstances
          [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID];
        if Packet.Dano < DungeonPointer^.MOBS[mob^.Mobid].CurrentHP then
        begin
          DungeonPointer^.MOBS[mob^.Mobid].CurrentHP := DungeonPointer^.MOBS
            [mob^.Mobid].CurrentHP - dword(Packet.DANO);
        end
        else
        begin
          DungeonPointer^.MOBS[mob^.Mobid].Base.IsDead := True;
          DungeonPointer^.MOBS[mob^.Mobid].CurrentHP := 0;
          DungeonPointer^.MOBS[mob^.Mobid].IsAttacked := false;
          DungeonPointer^.MOBS[mob^.Mobid].AttackerID := 0;
          DungeonPointer^.MOBS[mob^.Mobid].deadTime := Now;
          if Self.VisibleMobs.Contains(mob^.ClientID) then
            Self.VisibleMobs.Remove(mob^.ClientID);
          Self.MobKilledInDungeon(mob);
          Packet.MobAnimation := 30;
        end;

        mob^.LastReceivedAttack := Now;
        Packet.MobCurrHP := DungeonPointer^.MOBS[mob^.Mobid].CurrentHP;
        SelfBase^.SendToVisible(Packet, Packet.Header.size);
        Exit;

      end;

    7: // royal guards
      begin

        RoyalGuarda := @Servers[SelfBase^.ChannelId].RoyalGuards[mob^.ClientID];
        RoyalGuardaPlayerChar := @Servers[SelfBase^.ChannelId].RoyalGuards[mob^.ClientID].PlayerChar.Base;

        if (Packet.Dano < RoyalGuardaPlayerChar^.CurrentScore.CurHP) and
          not mob^.IsDead then
        begin
                Packet.MobCurrHP := RoyalGuardaPlayerChar^.CurrentScore.CurHP - dword(Packet.DANO);
        SelfBase^.SendToVisible(Packet, Packet.Header.size);

          RoyalGuardaPlayerChar^.CurrentScore.CurHP := RoyalGuardaPlayerChar^.CurrentScore.CurHP - dword(Packet.DANO);
         mob^.LastReceivedAttack := Now;

        Exit;

        end
        else
        begin
          mob^.IsDead := True;
          Packet.MobAnimation := 30;
          Packet.MobCurrHP := 0;
          SelfBase^.SendToVisible(Packet, Packet.Header.size);

          RoyalGuardaPlayerChar^.CurrentScore.CurHP := 0;
          RoyalGuarda^.IsAttacked := false;
          RoyalGuarda^.AttackerID := 0;
          RoyalGuarda^.deadTime := Now;
          RoyalGuarda^.KillGuard(mob^.ClientID, Self.ClientID);

          if Self.VisibleNPCS.Contains(mob^.ClientID) then
          begin
            Self.VisibleNPCS.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
          end;

          for j in Self.VisiblePlayers do
          begin
            OtherPlayerMobLoop := @Servers[SelfBase^.ChannelId].Players[j];
            if (OtherPlayerMobLoop^.Status <> Playing) or OtherPlayerMobLoop^.SocketClosed
            then

              if OtherPlayerMobLoop^.Base.VisibleNPCS.Contains(mob^.ClientID)
              then
              begin
                OtherPlayerMobLoop^.Base.VisibleNPCS.Remove(mob^.ClientID);
                OtherPlayerMobLoop^.Base.RemoveTargetFromList(mob);
              end;
            Continue;

          end;

          RoyalGuarda^.Base.VisibleMobs.Clear;

           mob^.LastReceivedAttack := Now;

          Exit;
        end;


      end;

    4:
      begin
        DevirNpcs := @Servers[Self.ChannelId].DevirStones[mob^.ClientID];
        if ((Packet.Dano < DevirNpcs^.PlayerChar.Base.CurrentScore.CurHP) and
          not(mob^.IsDead)) then
        begin
                  Packet.MobCurrHP := DevirNpcs^.PlayerChar.Base.CurrentScore.CurHP - dword(Packet.DANO);
          SelfBase^.SendToVisible(Packet, Packet.Header.size);
          DevirNpcs^.PlayerChar.Base.CurrentScore.CurHP :=
            DevirNpcs^.PlayerChar.Base.CurrentScore.CurHP - dword(Packet.DANO);

          mob^.LastReceivedAttack := Now;


          if (Now >= IncSecond(mob^.LastReceivedAttack, 2)) then
          begin
            Helper := Servers[Self.ChannelId].DevirGuards[j]
              .GetDevirIdByStoneOrGuardId(mob^.ClientID);
            Servers[Self.ChannelId].SendServerMsgForNation
              ('O Pedra do Devir de ' + AnsiString(Servers[Self.ChannelId]
              .DevirNPC[Helper + 3335].DevirName) + ' está sendo atacado.',
              Servers[Self.ChannelId].NationID);

          end;
          Exit;


        end
        else
        begin

          mob^.IsDead := True;
                    Packet.MobAnimation := 30;
          Packet.MobCurrHP := 0;
          SelfBase^.SendToVisible(Packet, Packet.Header.size);
          DevirNpcs^.PlayerChar.Base.CurrentScore.CurHP := 0;
          DevirNpcs^.IsAttacked := false;
          DevirNpcs^.AttackerID := 0;
          DevirNpcs^.deadTime := Now;
          DevirNpcs^.KillStone(mob^.ClientID, Self.ClientID);
          if (Self.VisibleNPCS.Contains(mob^.ClientID)) then
          begin
            Self.VisibleNPCS.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
            // essa skill tem retorno no caso de erro
          end;
          for j in Self.VisiblePlayers do
          begin
            OtherPlayerMobLoop := @Servers[Self.ChannelId].Players[j];
            if (OtherPlayerMobLoop^.Base.VisibleNPCS.Contains(mob^.ClientID))
            then
            begin
              OtherPlayerMobLoop^.Base.VisibleNPCS.Remove(mob^.ClientID);
              OtherPlayerMobLoop^.Base.RemoveTargetFromList(mob);
            end;
          end;
          DevirNpcs^.Base.VisiblePlayers.Clear;

          mob^.LastReceivedAttack := Now;

          Exit;
        end;

      end;

    5:
      begin

        DevirGuardas := @Servers[SelfBase^.ChannelId].DevirGuards
          [mob^.ClientID];

        if ((Packet.Dano < DevirGuardas^.PlayerChar.Base.CurrentScore.CurHP) and
          not(mob^.IsDead)) then
        begin
                Packet.MobCurrHP := DevirGuardas^.PlayerChar.Base.CurrentScore.CurHP - dword(Packet.DANO);
        SelfBase^.SendToVisible(Packet, Packet.Header.size);

          DevirGuardas^.PlayerChar.Base.CurrentScore.CurHP :=
            DevirGuardas^.PlayerChar.Base.CurrentScore.CurHP - dword(Packet.DANO);

                    mob^.LastReceivedAttack := Now;



          if (Now >= IncSecond(mob^.LastReceivedAttack, 2)) then
          begin
            Helper := DevirGuardas^.GetDevirIdByStoneOrGuardId(mob^.ClientID);
            Servers[Self.ChannelId].SendServerMsgForNation
              ('O Totem de ' + AnsiString(Servers[Self.ChannelId].DevirNPC
              [Helper + 3335].DevirName) + ' está sendo atacado.',
              Servers[Self.ChannelId].NationID);
          end;

        end
        else
        begin

          mob^.IsDead := True;
          Packet.MobAnimation := 30;
          Packet.MobCurrHP := 0;
          SelfBase^.SendToVisible(Packet, Packet.Header.size);
          DevirGuardas^.PlayerChar.Base.CurrentScore.CurHP := 0;
          DevirGuardas^.IsAttacked := false;
          DevirGuardas^.AttackerID := 0;
          DevirGuardas^.deadTime := Now;
          DevirGuardas^.KillGuard(mob^.ClientID, SelfBase^.ClientID);
          if (SelfBase^.VisibleNPCS.Contains(mob^.ClientID)) then
          begin
            SelfBase^.VisibleNPCS.Remove(mob^.ClientID);
            SelfBase^.RemoveTargetFromList(mob);
            // essa skill tem retorno no caso de erro
          end;
          for j in Self.VisiblePlayers do
          begin
            OtherPlayerMobLoop := @Servers[SelfBase^.ChannelId].Players[j];
            if (OtherPlayerMobLoop^.Base.VisibleNPCS.Contains(mob^.ClientID))
            then
            begin
              OtherPlayerMobLoop^.Base.VisibleNPCS.Remove(mob^.ClientID);
              OtherPlayerMobLoop^.Base.RemoveTargetFromList(mob);
            end;
          end;
          DevirGuardas^.Base.VisibleMobs.Clear;
          // Self.MobKilled(mob, DropExp, DropItem, False);

                  mob^.LastReceivedAttack := Now;

        Exit;
        end;

      end;

  end;

  Exit;

end;

function TBaseMob.GetDamage(Skill: WORD; mob: PBaseMob; out DnType: TDamageType;
  Tipo: Byte): UInt64;
var
  ResultDamage, MobDef, defHelp, DamageReduction: Integer;
  IsPhysical: Boolean;
  MobAbility: WORD;
  PlayerBase: PCharacter; // Cache para evitar acesso repetido
  SelfBaseMob: PBaseMob;
  SelfPlayerCharacter: PPlayerCharacter;
  Freq: Int64;
  StartCount, EndCount: Int64;
  ElapsedTime: System.Double;
begin

  Result := 0;

  // Verifica imunidade do mob
  if mob^.GetMobAbility(EF_IMMUNITY) > 0 then
  begin
    DnType := TDamageType.Immune;
    Exit;
  end;

  SelfBaseMob := @Self;
  // Verifica buffs de bloqueio ou esquiva
  if mob^.BuffExistsByIndex(19) or mob^.BuffExistsByIndex(91) then
  begin
    MobAbility := SelfBaseMob^.GetMobAbility(EF_COUNT_HIT);
    if MobAbility > 0 then
    begin
      if mob^.BuffExistsByIndex(19) then
        mob^.RemoveBuffByIndex(19)
      else if mob^.BuffExistsByIndex(91) then
        mob^.RemoveBuffByIndex(91);
      SelfBaseMob^.DecreasseMobAbility(EF_COUNT_HIT, 1);
    end
    else
    begin
      if mob^.BuffExistsByIndex(19) then
      begin
        mob^.RemoveBuffByIndex(19);
        DnType := TDamageType.Block;
      end
      else if mob^.BuffExistsByIndex(91) then
      begin
        mob^.RemoveBuffByIndex(91);
        DnType := TDamageType.Miss2;
      end;
      Exit;
    end;
  end;

  // Cache de PlayerCharacter.Base para evitar acesso repetido
  PlayerBase := @Self.PlayerCharacter.Base;
  SelfPlayerCharacter := @Self.PlayerCharacter;

  // Determina se o ataque é físico ou mágico
  IsPhysical := (Tipo = 1) and ((Self.GetMobClassPlayer in [0 .. 3]) or
    (Skill = 0)) or (Tipo <> 1) and ((Self.GetMobClass in [0 .. 3]) or
    (Skill = 0));

  // Cálculo de dano físico ou mágico
  if IsPhysical then
  begin
    ResultDamage := PlayerBase^.CurrentScore.DNFis;
    MobDef := mob^.PlayerCharacter.Base.CurrentScore.DEFFis;
    defHelp := SelfPlayerCharacter^.FisPenetration;
  end
  else
  begin
    ResultDamage := PlayerBase^.CurrentScore.DNMAG;
    MobDef := mob^.PlayerCharacter.Base.CurrentScore.DEFMAG;
    defHelp := SelfPlayerCharacter^.MagPenetration;
  end;

  // Aplica penetração de defesa (se houver)
  if defHelp > 0 then
    MobDef := MobDef - (MobDef * defHelp div 100);

  // Determina o tipo de dano
  DnType := SelfBaseMob^.GetDamageType3(Skill, IsPhysical, mob);

  // Verifica se o ataque foi um "miss"
  if (DnType = Miss) and (Tipo = 1) then
  begin
    mob^.SendEffectOther($17, 1);
    Exit;
  end;

  // Redução do dano com base na defesa do mob
  ResultDamage := ResultDamage - (MobDef shr 3);

  // Aplica redução de dano de itens equipados (apenas para Tipo = 1)
  if Tipo = 1 then
  begin
    DamageReduction :=
      (ResultDamage * mob^.GetEquipedItensDamageReduce) div 1000;
    ResultDamage := ResultDamage - DamageReduction;
  end;

  // Garante que o dano mínimo seja 1
  if ResultDamage < 1 then
    ResultDamage := 1;

  // Adiciona um fator aleatório ao dano
  Result := ResultDamage + RandomRange(10, 120) + 15;

end;

function TBaseMob.GetDamageType(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseMob): TDamageType;
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

function TBaseMob.GetDamageType2(Skill: DWORD; IsPhysical: Boolean;
  mob: PBaseMob): TDamageType;
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

function TBaseMob.GetDamageType3(Skill: WORD; IsPhysical: Boolean;
  mob: PBaseMob): TDamageType;
var
  RandValue: Byte;
  ProbabilidadeAcerto, ProbabilidadeCritico, ProbabilidadeDuplo,
    ProbabilidadeDuploCritico: Integer;
  SelfPlayerCharacterBase: PCharacter;
  SelfPlayerCharacter: PPlayerCharacter;
  SelfBase: PBaseMob;
begin
  SelfBase := @Self;
  SelfPlayerCharacterBase := @Self.PlayerCharacter.Base;
  SelfPlayerCharacter := @Self.PlayerCharacter;
  Result := TDamageType.Normal;

  // Gera um único número aleatório para todas as comparações
  RandValue := RandomRange(1, 101);

  // Calculando Acerto x Esquiva
  ProbabilidadeAcerto := 70 + (SelfPlayerCharacterBase^.CurrentScore.Acerto *
    8 div 10) - (mob^.PlayerCharacter.Base.CurrentScore.Esquiva * 6 div 10);
  ProbabilidadeAcerto := EnsureRange(ProbabilidadeAcerto, 0, 100);

  if RandValue > ProbabilidadeAcerto then
  begin
    Result := TDamageType.Miss;
    SelfBase^.MissCount := 0;
    Exit;
  end;

  Inc(Self.MissCount);

  // Calculando Critico x Resistencia Critico
  ProbabilidadeCritico := 15 + (SelfPlayerCharacterBase^.CurrentScore.Critical *
    8 div 10) - (mob^.PlayerCharacter.CritRes * 6 div 10);
  ProbabilidadeCritico := EnsureRange(ProbabilidadeCritico, 0, 100);

  if RandValue <= ProbabilidadeCritico then
  begin
    Result := TDamageType.Critical;
  end;

  // Calculando Duplo x Resistencia Duplo
  if Result <> TDamageType.Miss then
  begin
    ProbabilidadeDuplo := 10 + (SelfPlayerCharacter^.DuploAtk * 8 div 10) -
      (mob^.PlayerCharacter.DuploRes * 6 div 10);
    ProbabilidadeDuplo := EnsureRange(ProbabilidadeDuplo, 0, 100);

    if RandValue <= ProbabilidadeDuplo then
    begin
      Result := TDamageType.Double;
    end;
  end;

  // Calculando Duplo Crítico (Crítico + Duplo)
  if Result = TDamageType.Critical then
  begin
    ProbabilidadeDuploCritico := 8 + (SelfPlayerCharacter^.DuploAtk * 8 div 10)
      - (mob^.PlayerCharacter.DuploRes * 6 div 10);
    ProbabilidadeDuploCritico := EnsureRange(ProbabilidadeDuploCritico, 0, 100);

    if RandValue <= ProbabilidadeDuploCritico then
    begin
      Result := TDamageType.DoubleCritical;
    end;
  end;
end;

procedure TBaseMob.CalcAndCure(Skill: DWORD; mob: PBaseMob);
var
  Cure: cardinal;
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

function TBaseMob.CalcCure(Skill: DWORD; mob: PBaseMob): Integer;
var
  Cure: cardinal;
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

function TBaseMob.CalcCure2(BaseCure: DWORD; mob: PBaseMob;
  xSkill: Integer): Integer;
var
  Cure: cardinal;
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

procedure TBaseMob.HandleSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SelectedPos: TPosition; DataSkill: P_SkillData; Tipo: Byte);
var
  Packet: TRecvDamagePacket;
  gotDano: Integer;
  gotDMGType: TDamageType;
  Add_Buff: Boolean;
  Resisted: Boolean;
  DropExp, DropItem: Boolean;
  j: Integer;
  Helper2: Byte;
  SelfPlayer, OtherPlayer: PPlayer;
  MobsP: PMobSPoisition;
  Rand: byte;

  DungeonMobPointer: PMobsStructDungeonInstance;
  DevirPointer: PNpc;
  DevirGuardPointer: PNpc;
  RoyalGuardPointer: PNpc;

begin
  ZeroMemory(@Packet, sizeof(Packet));
  Packet.Header.size := sizeof(Packet);
  Packet.Header.Index := Self.ClientID;
  Packet.Header.Code := $102;
  Packet.SkillID := Skill;
  Packet.AttackerPos := Self.PlayerCharacter.LastPos;
  Packet.AttackerID := Self.ClientID;
  Packet.Animation := Anim;
  Packet.AttackerHP := Self.Character.CurrentScore.CurHP;
  Packet.TargetID := IfThen(mob^.ClientID = Self.ClientID, Self.ClientID, mob^.ClientID);
  Packet.MobAnimation := DataSkill^.TargetAnimation;

  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  if (DataSkill^.SuccessRate = 1) and (DataSkill^.range = 0) then
  begin
    Resisted := false;
    case Self.GetMobClass of
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
    Self.TargetSkill(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff,
      Resisted, Tipo);

    if (gotDano > 0) then
    begin
      Self.AttackParse(Skill, Anim, mob, gotDano, gotDMGType, Add_Buff,
        Packet.MobAnimation, DataSkill, Tipo);

      if (gotDano > 0) then
        Inc(gotDano, RandomRange((gotDano div 20), (gotDano div 10)) + 13);
    end
    else if not(gotDMGType in ([Critical, Normal, Double])) then
      Add_Buff := false;
    if (Add_Buff and not Resisted) then
      Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);

    Packet.Dano := gotDano;
    Packet.DnType := gotDMGType;

    Case tipo of
      1:
      begin

        OtherPlayer := @Servers[mob^.ChannelId].Players[mob^.ClientID];

        if (DataSkill^.Index = PANCADA) and (Packet.Dano > (Self.Character.CurrentScore.MaxHP div 3)) then
          Packet.Dano := (Self.Character.CurrentScore.MaxHP div 2);

        if (Packet.Dano < mob^.Character.CurrentScore.CurHP) then
        begin
          Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);

          if (Packet.Dano > 0) then
            mob^.RemoveHP(Packet.Dano, false);

          if (OtherPlayer^.CollectingReliquare) then
            OtherPlayer^.SendCancelCollectItem(OtherPlayer^.CollectingID);

          mob^.LastReceivedAttack := Now;
        end
        else
        begin

          if not OtherPlayer^.Dueling then
          begin
          
          mob^.IsDead := true;
          Packet.MobCurrHP := 0;
          Self.SendToVisible(Packet, Packet.Header.size);
          Self.PlayerKilled(mob);
          mob.SendEffectOther($3F, 1);
          if (OtherPlayer^.CollectingReliquare) then
            OtherPlayer^.SendCancelCollectItem(OtherPlayer^.CollectingID);
          Exit;


          end;

          Packet.MobCurrHP := 10;
          Self.SendToVisible(Packet, Packet.Header.size);
          mob^.Character.CurrentScore.CurHP := 10;          
          mob^.LastReceivedAttack := Now;
          if (OtherPlayer^.CollectingReliquare) then
            OtherPlayer^.SendCancelCollectItem(OtherPlayer^.CollectingID);
            
          Exit;
        end;


      end;
      8:
      begin

            DungeonMobPointer:= @DungeonInstances[SelfPlayer^.DungeonInstanceID].MOBS[mob^.Mobid];
            if (Packet.Dano < DungeonMobPointer^.CurrentHP) then
            begin
            Packet.MobCurrHP := DungeonMobPointer^.CurrentHP;
            SelfPlayer^.Base.SendToVisible(Packet, Packet.Header.size);
            DungeonMobPointer^.Base.LastReceivedAttack := Now;
            DungeonMobPointer^.CurrentHP := DungeonMobPointer^.CurrentHP - dword(Packet.DANO);
            end
            else
            begin
              DungeonMobPointer^.CurrentHP := 0;
              DungeonMobPointer^.IsAttacked := false;
              DungeonMobPointer^.AttackerID := 0;
              if (Self.VisibleMobs.Contains(DungeonMobPointer^.base.ClientID)) then
                Self.VisibleMobs.Remove(DungeonMobPointer^.base.ClientID);
              DungeonMobPointer^.base.VisibleMobs.Clear;
              SelfPlayer^.Base.MobKilledInDungeon(mob);
              Packet.MobAnimation := 30;
              Packet.MobCurrHP := DungeonMobPointer^.CurrentHP;
              SelfPlayer^.Base.SendToVisible(Packet, Packet.Header.size);
              DungeonMobPointer^.Base.LastReceivedAttack := Now;
              DungeonMobPointer^.base.IsDead := True;
              Exit;
            end;

      end;

      2,6:
      begin

       MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP
            [mob.SecondIndex];

          if not(MobsP.IsAttacked) then
            MobsP.FirstPlayerAttacker := Self.ClientID;

          if (Packet.Dano < MobsP^.HP) then
          begin
            Packet.MobCurrHP := MobsP^.HP;
            Self.SendToVisible(Packet, Packet.Header.size);
            deccardinal(MobsP^.HP, Packet.Dano);
            mob^.LastReceivedAttack := Now;

          end
          else
          begin
            MobsP.Base.SendEffect($0);
            Packet.MobAnimation := 30;
            Packet.MobCurrHP := 0;
            Self.SendToVisible(Packet, Packet.Header.size);


            MobsP^.HP := 0;
            MobsP^.IsAttacked := false;
            MobsP^.AttackerID := 0;
            MobsP^.deadTime := Now;


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
                Servers[Self.ChannelId].Players[j]
                  .Base.RemoveTargetFromList(mob);
              end;
            end;
            mob^.VisibleMobs.Clear;
            mob^.IsDead := True;
            Self.MobKilled(mob, DropExp, DropItem, false);
            mob^.LastReceivedAttack := Now;
            Exit;
          end;

      end;

      4:
      begin

        DevirPointer := @Servers[Self.ChannelId].DevirStones[mob^.ClientID];
        if (Packet.Dano < DevirPointer^.PlayerChar.Base.CurrentScore.CurHP) then
        begin

          Packet.MobCurrHP := DevirPointer^.PlayerChar.Base.CurrentScore.CurHP;
          Self.SendToVisible(Packet, Packet.Header.size);
          DevirPointer^.PlayerChar.Base.CurrentScore.CurHP := DevirPointer^.PlayerChar.Base.CurrentScore.CurHP - dword(Packet.DANO);
          mob^.LastReceivedAttack := Now;
        end
        else
        begin
          mob^.IsDead := True;
          Packet.MobAnimation := 30;
          Packet.MobCurrHP := 0;
          Self.SendToVisible(Packet, Packet.Header.size);


          DevirPointer^.PlayerChar.Base.CurrentScore.CurHP := 0;
          DevirPointer^.IsAttacked := False;
          DevirPointer^.AttackerID := 0;
          DevirPointer^.deadTime := Now;
          DevirPointer^.KillStone(mob^.ClientID, Self.ClientID);

          if Self.VisibleNPCS.Contains(mob^.ClientID) then
          begin
            Self.VisibleNPCS.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
          end;

          for j in Self.VisiblePlayers do
          begin
            if Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Contains(mob^.ClientID) then
            begin
              Servers[Self.ChannelId].Players[j].Base.VisibleNPCS.Remove(mob^.ClientID);
              Servers[Self.ChannelId].Players[j].Base.RemoveTargetFromList(mob);
            end;
          end;

          mob^.VisibleMobs.Clear;
          mob^.LastReceivedAttack := Now;
          Exit;
        end;

      end;
      5:
      begin

        DevirGuardPointer := @Servers[Self.ChannelId].DevirGuards[mob^.ClientID];

        if (Packet.Dano < DevirGuardPointer^.PlayerChar.Base.CurrentScore.CurHP) then
        begin
            Packet.MobCurrHP := DevirGuardPointer^.PlayerChar.Base.CurrentScore.CurHP - dword(Packet.DANO);
            Self.SendToVisible(Packet, Packet.Header.size);
            mob^.LastReceivedAttack := Now;
            DevirGuardPointer^.PlayerChar.Base.CurrentScore.CurHP := Packet.MobCurrHP;
        end
        else
        begin
            mob^.IsDead := True;
            mob^.LastReceivedAttack := Now;
            Packet.MobAnimation := 30;
            Packet.MobCurrHP := DevirGuardPointer^.PlayerChar.Base.CurrentScore.CurHP;
            Self.SendToVisible(Packet, Packet.Header.size);

            DevirGuardPointer^.PlayerChar.Base.CurrentScore.CurHP := 0;
            DevirGuardPointer^.IsAttacked := False;
            DevirGuardPointer^.AttackerID := 0;
            DevirGuardPointer^.deadTime := Now;
            DevirGuardPointer^.KillGuard(mob^.ClientID, Self.ClientID);

            if Self.VisibleNPCS.Contains(mob^.ClientID) then
            begin
                Self.VisibleNPCS.Remove(mob^.ClientID);
                Self.RemoveTargetFromList(mob);
            end;

            for j in Self.VisiblePlayers do
            begin
                with Servers[Self.ChannelId].Players[j].Base do
                begin
                    if VisibleNPCS.Contains(mob^.ClientID) then
                    begin
                        VisibleNPCS.Remove(mob^.ClientID);
                        RemoveTargetFromList(mob);
                    end;
                end;
            end;
            mob^.VisibleMobs.Clear;
            Exit;
        end;


      end;


      7:
      begin

        RoyalGuardPointer := @Servers[Self.ChannelId].RoyalGuards[mob^.ClientID];

        if Packet.Dano < RoyalGuardPointer^.PlayerChar.Base.CurrentScore.CurHP then
        begin
          RoyalGuardPointer^.PlayerChar.Base.CurrentScore.CurHP := RoyalGuardPointer^.PlayerChar.Base.CurrentScore.CurHP - dword(Packet.DANO);
          Packet.MobCurrHP := RoyalGuardPointer^.PlayerChar.Base.CurrentScore.CurHP;
          mob^.LastReceivedAttack := Now;
          Self.SendToVisible(Packet, Packet.Header.size);
        end
        else
        begin
          mob^.LastReceivedAttack := Now;
          mob^.IsDead := True;
          RoyalGuardPointer^.PlayerChar.Base.CurrentScore.CurHP := 0;
          RoyalGuardPointer^.IsAttacked := False;
          RoyalGuardPointer^.AttackerID := 0;
          RoyalGuardPointer^.deadTime := Now;
          Packet.MobAnimation := 30;
          Packet.MobCurrHP := 0;
          Self.SendToVisible(Packet, Packet.Header.size);

          if Self.VisibleNPCS.Contains(mob^.ClientID) then
          begin
            Self.VisibleNPCS.Remove(mob^.ClientID);
            Self.RemoveTargetFromList(mob);
          end;

          for j in Self.VisiblePlayers do
          begin
            with Servers[Self.ChannelId].Players[j].Base do
            begin
              if VisibleNPCS.Contains(mob^.ClientID) then
              begin
                VisibleNPCS.Remove(mob^.ClientID);
                RemoveTargetFromList(mob);
              end;
            end;
          end;

          mob^.VisibleMobs.Clear;
          Exit;
        end;


      end;
    end;
  End;

  if (DataSkill^.SuccessRate = 0) then
  begin
    Randomize; // Inicializa o gerador de números aleatórios uma única vez

    if (DataSkill^.range = 0) then
    begin // skills de buff single[Self div Target]
      Packet.DnType := TDamageType.None;
      Packet.Dano := 0;
      Packet.MobCurrHP := mob^.Character.CurrentScore.CurHP;

      if (Self.IsCompleteEffect5(Helper2)) then
      begin
        Rand := RandomRange(1, 101);
        if (Rand <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
        begin
          Self.Effect5Skill(@Self, Helper2, True);
        end;
      end;

      if (DataSkill^.TargetType = 1) then
      begin // [Self]
        Self.SelfBuffSkill(Skill, Anim, mob, SelectedPos);
      end
      else
      begin // [Target]
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
        Self.TargetBuffSkill(Skill, Anim, mob, DataSkill);
      end;
      Self.SendToVisible(Packet, Packet.Header.size);
      // Centraliza a chamada aqui
    end
    else if (DataSkill^.range > 0) then
    begin // skills de buff em area [ou em party]
      if (Self.IsCompleteEffect5(Helper2)) then
      begin
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

function TBaseMob.ValidAttack(DmgType: TDamageType; DebuffType: Byte;
  mob: PBaseMob; AuxDano: Integer; xisBoss: Boolean): Boolean;
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
    dec(mob^.BolhaPoints, 1);
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

procedure TBaseMob.MobKilledInDungeon(mob: PBaseMob);
var
  MobExp, ExpAcquired, NIndex, Helper: Integer;
  i, l, RandomClientID, j, k: WORD;
  NearbyCount: Integer;
  SelfPlayer: PPlayer;
  PranExpAcquired: Int64;
  m: Integer;
begin
  ExpAcquired := 0;
  MobExp := DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
    .DungeonInstanceID].MOBS[mob.Mobid].MobExp;
  NearbyCount := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  var
  HelperX := (DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
    .DungeonInstanceID].MOBS[mob.Mobid].MobLevel - Self.Character.Level);
  case HelperX of
    - 255 .. -8:
      MobExp := IfThen(SelfPlayer.InDungeon, Round(MobExp * 0.1), 1);
    -7 .. -3:
      MobExp := Round(MobExp * 0.5);
    -2 .. 2:
      MobExp := MobExp;
    3 .. 5:
      MobExp := Round(MobExp * 1.5);
    6 .. 255:
      MobExp := Round(MobExp * 0.2);
  else
    MobExp := MobExp;
  end;

  // if not SelfPlayer.InDungeon and (MobExp <> 1) then
  // MobExp := MobExp * 4;

  if (Self.Character <> nil) and
    (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    MobExp := MobExp + ((MobExp div 100) * Servers[Self.ChannelId].ReliqEffect
      [EF_RELIQUE_PER_EXP]);

  if (SelfPlayer.Party.ExpAlocate = 1) then
  begin
    for l in SelfPlayer.Party.Members do
    begin
      if (SelfPlayer.Base.PlayerCharacter.LastPos.InRange((Servers[Self.ChannelId].Players[l].Base.PlayerCharacter.LastPos), 60))
      then
      begin
        Inc(NearbyCount);
      end;
    end;

    if NearbyCount > 0 then
    begin
      MobExp := MobExp div NearbyCount;

      for i in SelfPlayer.Party.Members do
      begin
        if (SelfPlayer.Base.PlayerCharacter.LastPos.InRange(
          (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos), 60)) and (not Servers[Self.ChannelId].Players[i].Base.IsDead) then
        begin
          ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp,
            Helper, EXP_TYPE_MOB);
        end;
      end;
    end;
  end
  else if (SelfPlayer.Party.ExpAlocate = 2) and
    (i = DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
    .DungeonInstanceID].MOBS[mob.Mobid].FirstPlayerAttacker) then
  begin
    ExpAcquired := Servers[Self.ChannelId].Players[i].AddExp(MobExp, Helper,
      EXP_TYPE_MOB);
  end;

  for i in Servers[Self.ChannelId].Players[Self.ClientID].Party.Members do
  begin
    case Servers[Self.ChannelId].Players[Self.ClientID].Party.ItemAlocate of
      1:
        if i = Servers[Self.ChannelId].Players[Self.ClientID].Party.Leader then
        begin
          NIndex := Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.LastSlotItemReceived;
          var
          Player1 := Servers[Self.ChannelId].Players[Self.ClientID];
          var
          Player2 := Servers[Self.ChannelId].Players
            [Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.Members.ToArray[NIndex]];

          if (Player1.Base.PlayerCharacter.LastPos.InRange((Player2.Base.PlayerCharacter.LastPos), 60)) and
            not(Player2.Base.IsDead) then
          begin
            Self.DropItemFor(@Player2.Base, mob);
          end
          else
          begin
            var
            Found := false;
            for m := 0 to Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.Members.Count - 1 do
            begin

              var
              NextPlayerIndex := (NIndex + m) mod Servers[Self.ChannelId]
                .Players[Self.ClientID].Party.Members.Count;
              var
              PlayerNext := Servers[Self.ChannelId].Players
                [Servers[Self.ChannelId].Players[Self.ClientID]
                .Party.Members.ToArray[NextPlayerIndex]];

              if (Player1.Base.PlayerCharacter.LastPos.InRange((PlayerNext.Base.PlayerCharacter.LastPos),60)) and
                not(PlayerNext.Base.IsDead) then
              begin
                Self.DropItemFor(@PlayerNext.Base, mob);
                Found := True;
                Break;
              end;
            end;

            if not Found then
              Self.DropItemFor(@Player1.Base, mob);
          end;

          Inc(Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.LastSlotItemReceived);
          if Servers[Self.ChannelId].Players[Self.ClientID]
            .Party.LastSlotItemReceived >= Servers[Self.ChannelId].Players
            [Self.ClientID].Party.Members.Count then
            Servers[Self.ChannelId].Players[Self.ClientID]
              .Party.LastSlotItemReceived := 0;
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

    if not(ExpAcquired = 0) then
    begin
      try
        case SelfPlayer^.SpawnedPran of
          0:
            begin
              case SelfPlayer^.Account.Header.Pran1.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[4];
                      for m := SelfPlayer^.Account.Header.Pran1.Level to 3 do
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
                      PranExpAcquired := (ExpAcquired div 5);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.
                        Exp) > PranExpList[20]) then
                      begin
                        SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                        for m := SelfPlayer^.Account.Header.Pran1.Level to 18 do
                          SelfPlayer^.AddPranLevel(0);
                      end
                      else
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    end;
                  end;
                5 .. 18: // pran criança
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[19];
                      for m := SelfPlayer^.Account.Header.Pran1.Level to 18 do
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
                      PranExpAcquired := (ExpAcquired div 5);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.
                        Exp) > PranExpList[50]) then
                      begin
                        SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[49];
                        for m := SelfPlayer^.Account.Header.Pran1.Level to 48 do
                          SelfPlayer^.AddPranLevel(0);
                      end
                      else
                        SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran1.Exp)
                      > PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran1.Exp := PranExpList[49];
                      for m := SelfPlayer^.Account.Header.Pran1.Level to 48 do
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
                      PranExpAcquired := (ExpAcquired div 5);
                      SelfPlayer^.AddPranExp(0, PranExpAcquired);
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
                    SelfPlayer^.AddPranExp(0, PranExpAcquired);
                  end;
              end;
            end;
          1:
            begin
              case SelfPlayer^.Account.Header.Pran2.Level of
                0 .. 3: // pran fada
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[5]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[4];
                      for m := SelfPlayer^.Account.Header.Pran2.Level to 3 do
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
                      PranExpAcquired := (ExpAcquired div 5);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.
                        Exp) > PranExpList[20]) then
                      begin
                        SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                        for m := SelfPlayer^.Account.Header.Pran2.Level to 18 do
                          SelfPlayer^.AddPranLevel(1);
                      end
                      else
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    end;
                  end;
                5 .. 18: // pran criança
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[20]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[19];
                      for m := SelfPlayer^.Account.Header.Pran2.Level to 18 do
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
                      PranExpAcquired := (ExpAcquired div 5);
                      if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.
                        Exp) > PranExpList[50]) then
                      begin
                        SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                        for m := SelfPlayer^.Account.Header.Pran2.Level to 48 do
                          SelfPlayer^.AddPranLevel(1);
                      end
                      else
                        SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    end;
                  end;
                20 .. 48: // pran adolescente
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
                    if ((PranExpAcquired + SelfPlayer^.Account.Header.Pran2.Exp)
                      > PranExpList[50]) then
                    begin
                      SelfPlayer^.Account.Header.Pran2.Exp := PranExpList[49];
                      for m := SelfPlayer^.Account.Header.Pran2.Level to 48 do
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
                      PranExpAcquired := (ExpAcquired div 5);
                      SelfPlayer^.AddPranExp(1, PranExpAcquired);
                    end;
                  end;
                50 .. 69: // pran adulta
                  begin
                    PranExpAcquired := (ExpAcquired div 5);
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

    for j := 0 to 49 do
    begin
      with Servers[Self.ChannelId].Players[i].PlayerQuests[j] do
      begin
        if (id > 0) and (not IsDone) then
        begin
          for k := 0 to 4 do
          begin
            if (Quest.RequirimentsType[k] = 1) and
              (Quest.Requiriments[k] = DungeonInstances
              [Servers[Self.ChannelId].Players[i].DungeonInstanceID].MOBS
              [mob.Mobid].IntName) then
            begin
              Inc(Complete[k]);
              if Complete[k] >= Quest.RequirimentsAmount[k] then
              begin
                Complete[k] := Quest.RequirimentsAmount[k];
                Servers[Self.ChannelId].Players[i].SendClientMessage
                  ('Você completou a quest [' +
                  AnsiString(Quests[Quest.QuestID].Titulo) + ']');
              end;
              Servers[Self.ChannelId].Players[i].UpdateQuest(id);
            end;
          end;
        end;
      end;
    end;
  end;
end;


procedure TBaseMob.MobKilled(mob: PBaseMob; out DroppedExp: Boolean;
  out DroppedItem: Boolean; InParty: Boolean);
var
  i, j: Integer;
  ExpAcquired, PranExpAcquired: Int64;
  MobExp, CalcAux, CalcAuxRlq: Integer;
  DropExp, DropItem: Boolean;
  A, HelperX { B } : Integer;
  NIndex: WORD;
  RandomClientID: Integer;
  SelfPlayer, OtherPlayer: PPlayer;
  MobsP: PMobSPoisition;
  Pran: ^TPran;
  PranIndex: Byte;
  MaxExp: Integer;
begin
  ExpAcquired := 0;
  PranExpAcquired := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  MobsP := @Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobsP[mob^.SecondIndex];

  // Verifica se o jogador está em um grupo e processa recompensas para os membros do grupo
  if (SelfPlayer^.PartyIndex <> 0) and (not InParty) then
  begin
    A := 0;
    for i in SelfPlayer^.Party.Members do
    begin
      DropExp := false;
      DropItem := false;
      Servers[Self.ChannelId].Players[i].Base.MobKilled(mob, DropExp, DropItem, True);
      if DropExp then Inc(A);
    end;

    // Se nenhum membro do grupo recebeu EXP, verifica o primeiro atacante
    if (A = 0) and (MobsP^.FirstPlayerAttacker > 0) and (MobsP^.FirstPlayerAttacker <> Self.ClientID) then
    begin
      DropExp := false;
      DropItem := false;
      Servers[Self.ChannelId].Players[MobsP^.FirstPlayerAttacker].Base.MobKilled(mob, DropExp, DropItem, false);
    end;
    Exit;
  end;

  // Verifica se o inventário está cheio
  if (TItemFunctions.GetEmptySlot(SelfPlayer^) = 255) then
    SelfPlayer.SendClientMessage('Seu inventário está cheio. Recompensas não serão recebidas.');

  // Calcula a diferença de nível entre o mob e o jogador
  HelperX := Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobLevel - Self.Character.Level;
  MobExp := Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].MobExp;

  // Ajusta a experiência com base na diferença de nível
  case HelperX of
    -255 .. -8: MobExp := Round(MobExp * 0.1);
    -7 .. -3: MobExp := Round(MobExp * 0.5);
    -2 .. 2: ; // Mantém o valor original de MobExp
    3 .. 5: MobExp := Round(MobExp * 1.5);
    6 .. 255: MobExp := Round(MobExp * 0.2);
  end;

  // Ajusta a experiência se o jogador não estiver em uma dungeon
  if not SelfPlayer^.InDungeon and (MobExp <> 1) then
    MobExp := MobExp * 4;

  // Aplica bônus de experiência se o jogador estiver na mesma nação do servidor
  if (Self.Character <> nil) and (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    MobExp := MobExp + ((MobExp div 100) * Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_PER_EXP]);

  try
    if InParty then
    begin
      if not MobsP^.CurrentPos.InRange(Self.PlayerCharacter.LastPos, 25) then
        Exit;

      case SelfPlayer^.Party.ExpAlocate of
        1: // igualmente
          begin
            j := 0;
            for i in SelfPlayer^.Party.Members do
            begin
              if Self.PlayerCharacter.LastPos.Distance
                (Servers[Self.ChannelId].Players[i]
                .Base.PlayerCharacter.LastPos) <= DISTANCE_TO_WATCH then
              begin
                if not Servers[Self.ChannelId].Players[i].Base.IsDead then
                  Inc(j);
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

      if Servers[mob^.ChannelId].MOBS.TMobS[mob^.Mobid].InitHP > 999999 then
      begin
        for i in Servers[mob^.ChannelId].Players[Self.ClientID].Party.Members do
        begin
          Randomize;
          if RandomRange(0, 2) = 1 then
          begin
            DroppedItem := True;
            Self.DropItemFor(@Servers[mob^.ChannelId].Players[i].Base, mob);
          end;
        end;

        for i := 1 to 3 do
        begin
          if Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied
            [i] = 0 then
            Continue;
          for j in Servers[mob^.ChannelId].Parties
            [Servers[mob^.ChannelId].Players[Self.ClientID].Party.PartyAllied[i]
            ].Members do
          begin
            Randomize;
            if RandomRange(0, 2) = 1 then
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
              var
              MemberCount := SelfPlayer^.Party.Members.Count;
              if MemberCount = 0 then
                Exit;

              for i := 0 to MemberCount - 1 do
              begin
                var
                CurrentIndex := (NIndex + i) mod MemberCount;
                var
                MemberID := SelfPlayer^.Party.Members.ToArray[CurrentIndex];
                var
                CurrentMember := Servers[Self.ChannelId].Players[MemberID].Base;

                if Self.PlayerCharacter.LastPos.Distance
                  (CurrentMember.PlayerCharacter.LastPos) <= 60 then
                begin
                  SelfPlayer^.Party.LastSlotItemReceived := (CurrentIndex + 1)
                    mod MemberCount;
                  DroppedItem := True;

                  if (SelfPlayer^.IsAuxilyUser and SelfPlayer^.F12Ativo) or
                    not SelfPlayer^.F12Ativo then
                  begin
                    Self.DropItemFor(@CurrentMember, mob);
                  end;

                  Break;
                end;
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

                if (SelfPlayer^.IsAuxilyUser and SelfPlayer^.F12Ativo) or
                  not SelfPlayer^.F12Ativo then
                begin
                  Self.DropItemFor(@Servers[Self.ChannelId].Players
                    [RandomClientID].Base, mob);
                end;

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
                  if (SelfPlayer^.IsAuxilyUser and SelfPlayer^.F12Ativo) or
                    not SelfPlayer^.F12Ativo then
                  begin
                    Self.DropItemFor(@Self, mob);
                    DroppedItem := True;
                  end;
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
                if (SelfPlayer^.IsAuxilyUser and SelfPlayer^.F12Ativo) or
                  not SelfPlayer^.F12Ativo then
                begin
                  Self.DropItemFor(@Self, mob);
                  DroppedItem := True;
                end;
              end;
            end;

          4: // lider
            begin
              if (Self.ClientID = SelfPlayer^.Party.Leader) then
              begin
                if (SelfPlayer^.IsAuxilyUser and SelfPlayer^.F12Ativo) or
                  not SelfPlayer^.F12Ativo then
                begin
                  Self.DropItemFor(@Self, mob);
                  DroppedItem := True;
                end;
              end;
            end;
        end;
      end;
    end
    else // não está em grupo
    begin
      if (SelfPlayer^.IsAuxilyUser and SelfPlayer^.F12Ativo) or not SelfPlayer^.F12Ativo
      then
      begin
        ExpAcquired := SelfPlayer^.AddExp(MobExp, CalcAuxRlq, EXP_TYPE_MOB);
        Self.DropItemFor(@Self, mob);
      end;
    end;
  except
    Logger.Write('erro na entrega em grupo de xp / solo', TLogType.Error);
  end;

    try
      if ExpAcquired <> 0 then
      begin
        try


          // Define qual Pran está ativa
          case SelfPlayer^.SpawnedPran of
            0: begin
                 Pran := @SelfPlayer^.Account.Header.Pran1;
                 PranIndex := 0;

                  // Calcula a experiência adquirida pela Pran
                  PranExpAcquired := ExpAcquired div 3;

                  // Verifica se a Pran precisa evoluir antes de ganhar experiência
                  if (Pran^.Level = 4) and (Pran^.ClassPran in [61, 71, 81]) or
                     (Pran^.Level = 19) and (Pran^.ClassPran in [62, 72, 82]) or
                     (Pran^.Level = 49) and (Pran^.ClassPran in [63, 73, 83]) then
                  begin
                    SelfPlayer^.SendClientMessage('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                    PranExpAcquired := 0;
                  end
                  else
                  begin
                    // Define o limite de experiência com base no nível da Pran
                    case Pran^.Level of
                      0 .. 3: MaxExp := PranExpList[5];
                      4 .. 18: MaxExp := PranExpList[20];
                      19 .. 48: MaxExp := PranExpList[50];
                      49 .. 69: MaxExp := High(Integer); // Não há limite para níveis 50+
                    end;

                    // Verifica se a experiência ultrapassa o limite
                    if (PranExpAcquired + Pran^.Exp) > MaxExp then
                    begin
                      // Ajusta a experiência para o valor máximo permitido
                      Pran^.Exp := PranExpList[MaxExp - 1];
                      // Adiciona níveis até o limite
                      for i := Pran^.Level to (MaxExp - 1) do
                        SelfPlayer^.AddPranLevel(PranIndex);
                    end
                    else
                    begin
                      // Adiciona a experiência normalmente
                      SelfPlayer^.AddPranExp(PranIndex, PranExpAcquired);
                    end;
                  end;
               end;
            1: begin
                 Pran := @SelfPlayer^.Account.Header.Pran2;
                 PranIndex := 1;

                         // Calcula a experiência adquirida pela Pran
                  PranExpAcquired := ExpAcquired div 3;

                  // Verifica se a Pran precisa evoluir antes de ganhar experiência
                  if (Pran^.Level = 4) and (Pran^.ClassPran in [61, 71, 81]) or
                     (Pran^.Level = 19) and (Pran^.ClassPran in [62, 72, 82]) or
                     (Pran^.Level = 49) and (Pran^.ClassPran in [63, 73, 83]) then
                  begin
                    SelfPlayer^.SendClientMessage('A sua pran precisa evoluir para ganhar exp.', 0, 1);
                    PranExpAcquired := 0;
                  end
                  else
                  begin
                    // Define o limite de experiência com base no nível da Pran
                    case Pran^.Level of
                      0 .. 3: MaxExp := PranExpList[5];
                      4 .. 18: MaxExp := PranExpList[20];
                      19 .. 48: MaxExp := PranExpList[50];
                      49 .. 69: MaxExp := High(Integer); // Não há limite para níveis 50+
                    end;

                    // Verifica se a experiência ultrapassa o limite
                    if (PranExpAcquired + Pran^.Exp) > MaxExp then
                    begin
                      // Ajusta a experiência para o valor máximo permitido
                      Pran^.Exp := PranExpList[MaxExp - 1];
                      // Adiciona níveis até o limite
                      for i := Pran^.Level to (MaxExp - 1) do
                        SelfPlayer^.AddPranLevel(PranIndex);
                    end
                    else
                    begin
                      // Adiciona a experiência normalmente
                      SelfPlayer^.AddPranExp(PranIndex, PranExpAcquired);
                    end;
                  end;
               end;
          end;


        except
          on E: Exception do
            WriteLN(E.Message);
        end;
      end;
    except
      on E: Exception do
        WriteLN(E.Message);
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
              SelfPlayer^.SendClientMessage('Você completou a quest [' +
                AnsiString(Quests[SelfPlayer^.PlayerQuests[i].Quest.QuestID]
                .Titulo) + ']');
            end;
            SelfPlayer^.UpdateQuest(SelfPlayer^.PlayerQuests[i].id);
          end;
  except
    Logger.Write('erro na contagem da quest pra atualizar', TLogType.Error);
  end;

end;

procedure TBaseMob.DropItemFor(PlayerBase: PBaseMob; mob: PBaseMob);
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

procedure TBaseMob.PlayerKilled(mob: PBaseMob; xRlkSlot: Byte = 0);
var
  TitleGoaled: Boolean;
  i, j, n, m: Byte;
  SelfParty, AlliedRaids: PParty;
  PartyMembers, OtherPlayers, SelfPlayer, RaidMembers, GuildMembers: PPlayer;
  NextBuffID, BuffID, HonorReduction: WORD;
  BuffFound: Boolean;
  DiffInSeconds: Byte;
  GuildPointer, CheckGuildPointer: PGuild;
begin
  OtherPlayers := @Servers[mob.ChannelId].Players[mob^.ClientID];
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];

  if OtherPlayers^.Waiting1 <> 0 then
  begin
    if OtherPlayers^.Team1 <> SelfPlayer^.Team1 then
    begin
      if OtherPlayers^.Team1 = 4 then
      begin
        Inc(Servers[3].Kills_Vermelho);
        TItemFunctions.PutItem(SelfPlayer^, 11285, SKULL_MULTIPLIER);
        Servers[3].SendElterMsg('O jogador ' + SelfPlayer^.Base.Character.Name +
          ' pontuou para o time vermelho!');
        Exit;
      end
      else if OtherPlayers^.Team1 = 5 then
      begin
        Inc(Servers[3].Kills_Azul);
        TItemFunctions.PutItem(SelfPlayer^, 11285, SKULL_MULTIPLIER);
        Servers[3].SendElterMsg('O jogador ' + SelfPlayer^.Base.Character.Name +
          ' pontuou para o time azul!');
        Exit;
      end;
    end;
  end
  else if (SelfPlayer^.Base.Character.Nation = OtherPlayers^.Base.Character.
    Nation) and not SelfPlayer^.Base.InClastleVerus then
  begin
    DiffInSeconds := SecondsBetween(Now, OtherPlayers^.LastAttackSent);
    if DiffInSeconds <= 30 then
      Exit;

    if (SelfPlayer^.Base.BuffExistsByID(6600) or SelfPlayer^.Base.BuffExistsByID
      (6601)) and not SelfPlayer^.Base.InClastleVerus then
    begin
      if SecondsBetween(Now, OtherPlayers^.LastAttackSent) > 30 then
        Inc(SelfPlayer^.Base.Character.CurrentScore.Infamia);
      Exit;
    end;

    if not(SelfPlayer^.Base.BuffExistsByID(6600) or
      SelfPlayer^.Base.BuffExistsByID(6601)) or
      (SelfPlayer^.Base.Character.CurrentScore.Infamia >= 0) then
    begin
      BuffFound := false;
      for BuffID in [6454, 6455, 6456, 6457, 6458] do
      begin
        if SelfPlayer^.Base.BuffExistsByID(BuffID) then
        begin
          BuffFound := True;
          case BuffID of
            6454:
              NextBuffID := 6455;
            6455:
              NextBuffID := 6456;
            6456:
              NextBuffID := 6457;
            6457:
              NextBuffID := 6458;
            6458:
              NextBuffID := 6458;
          else
            NextBuffID := BuffID;
          end;

          Self.RemoveBuffByIndex(BuffID);
          Self.AddBuff(NextBuffID, True, false, IfThen(BuffID = 6454, 1200,
            IfThen(BuffID = 6455, 1200, IfThen(BuffID = 6456, 1800,
            IfThen(BuffID = 6457, 2400, 3000)))));

          Inc(SelfPlayer^.Base.Character.CurrentScore.Infamia);

          case BuffID of
            6454:
              HonorReduction := 250;
            6455:
              HonorReduction := 350;
            6456:
              HonorReduction := 450;
            6457:
              HonorReduction := 500;
            6458:
              HonorReduction := 1000;
          else
            HonorReduction := 0;
          end;

          if SelfPlayer^.Base.Character.CurrentScore.Honor >= HonorReduction
          then
            SelfPlayer^.Base.Character.CurrentScore.Honor :=
              SelfPlayer^.Base.Character.CurrentScore.Honor - HonorReduction
          else
            SelfPlayer^.Base.Character.CurrentScore.Honor := 0;

          SelfPlayer^.SendClientMessage
            ('Seus pontos de caos foram incrementados');
          SelfPlayer^.SendClientMessage(HonorReduction.ToString +
            ' de honra reduzidas');
          SelfPlayer^.Base.SendRefreshKills();
          SelfPlayer^.Killnation := 0;

          if BuffID = 6458 then
            Servers[SelfPlayer^.Base.ChannelId].SendServerMsg
              ('O Jogador ' + SelfPlayer^.Base.Character.Name +
              ' Atingiu nivel 4 de caos!', 16, 16, 16);

          Exit;
        end;
      end;

      if not BuffFound then
      begin
        SelfPlayer^.Base.AddBuff(6454, True, false, 1200);
        Inc(SelfPlayer^.Base.Character.CurrentScore.Infamia);
        HonorReduction := 250;

        if SelfPlayer^.Base.Character.CurrentScore.Honor >= HonorReduction then
          SelfPlayer^.Base.Character.CurrentScore.Honor :=
            SelfPlayer^.Base.Character.CurrentScore.Honor - HonorReduction
        else
          SelfPlayer^.Base.Character.CurrentScore.Honor := 0;

        SelfPlayer^.SendClientMessage
          ('Seus pontos de caos foram incrementados');
        SelfPlayer^.SendClientMessage(HonorReduction.ToString +
          ' de honra reduzidas');
        SelfPlayer^.Base.SendRefreshKills();
        SelfPlayer^.Killnation := 0;
      end;
    end;

    if not Self.BuffExistsByID(MARECHAL_BUFF) or
      (SelfPlayer^.Base.Character.CurrentScore.Infamia >= 0) then
    begin
      if (Servers[Self.ChannelId].Players[mob^.ClientID].Base.Character.Nation >
        0) and (Self.Character.Nation > 0) and
        (Servers[Self.ChannelId].Players[mob^.ClientID]
        .Base.Character.Nation = Self.Character.Nation) then
      begin
        for BuffID in [6454, 6455, 6456, 6457, 6458] do
        begin
          if Self.BuffExistsByID(BuffID) then
          begin
            BuffFound := True;
            case BuffID of
              6454:
                NextBuffID := 6455;
              6455:
                NextBuffID := 6456;
              6456:
                NextBuffID := 6457;
              6457:
                NextBuffID := 6458;
              6458:
                NextBuffID := 6458;
            else
              NextBuffID := BuffID;
            end;

            Self.RemoveBuffByIndex(BuffID);
            Self.AddBuff(NextBuffID, True, false, IfThen(BuffID = 6454, 1200,
              IfThen(BuffID = 6455, 1200, IfThen(BuffID = 6456, 1800,
              IfThen(BuffID = 6457, 2400, 3000)))));

            Inc(SelfPlayer^.Base.Character.CurrentScore.Infamia);

            case BuffID of
              6454:
                HonorReduction := 250;
              6455:
                HonorReduction := 350;
              6456:
                HonorReduction := 450;
              6457:
                HonorReduction := 500;
              6458:
                HonorReduction := 1000;
            else
              HonorReduction := 0;
            end;

            if SelfPlayer^.Base.Character.CurrentScore.Honor >= HonorReduction
            then
              SelfPlayer^.Base.Character.CurrentScore.Honor :=
                SelfPlayer^.Base.Character.CurrentScore.Honor - HonorReduction
            else
              SelfPlayer^.Base.Character.CurrentScore.Honor := 0;

            SelfPlayer^.SendClientMessage
              ('Seus pontos de caos foram incrementados');
            SelfPlayer^.SendClientMessage(HonorReduction.ToString +
              ' de honra reduzidas');
            Self.SendRefreshKills();
            SelfPlayer^.Killnation := 0;

            if BuffID = 6458 then
              Servers[Self.ChannelId].SendServerMsg
                ('O Jogador ' + SelfPlayer^.Base.Character.Name +
                ' Atingiu nivel 4 de caos!', 16, 16, 16);

            Exit;
          end;
        end;

        if not BuffFound then
        begin
          Self.AddBuff(6454, True, false, 1200);
          Inc(SelfPlayer^.Base.Character.CurrentScore.Infamia);
          HonorReduction := 250;

          if SelfPlayer^.Base.Character.CurrentScore.Honor >= HonorReduction
          then
            SelfPlayer^.Base.Character.CurrentScore.Honor :=
              SelfPlayer^.Base.Character.CurrentScore.Honor - HonorReduction
          else
            SelfPlayer^.Base.Character.CurrentScore.Honor := 0;

          SelfPlayer^.SendClientMessage
            ('Seus pontos de caos foram incrementados');
          SelfPlayer^.SendClientMessage(HonorReduction.ToString +
            ' de honra reduzidas');
          Self.SendRefreshKills();
          SelfPlayer^.Killnation := 0;
        end;
      end;
    end;

    Exit;
  end
  else if SelfPlayer^.Base.InClastleVerus then
  begin
    // Handle castle-specific logic here
  end
  else
  begin
    OtherPlayers^.CheckInventoryRelic(True);

    if OtherPlayers^.Base.BuffExistsByIndex(126) or
      SelfPlayer^.Base.BuffExistsByIndex(126) then
    begin
      if OtherPlayers^.Base.BuffExistsByIndex(126) then
        SelfPlayer^.SendClientMessage
          ('Alvo está sob Efeito Duradouro. Impossível receber PvP/Honra.')
      else
        SelfPlayer^.SendClientMessage
          ('Você está sob Efeito Duradouro. Impossível receber PvP/Honra.');
      Exit;
    end;

    OtherPlayers^.Base.AddBuff(6471);

    if OtherPlayers^.Base.Character.Level < 25 then
    begin
      SelfPlayer^.SendClientMessage
        ('Você só pode receber PvP de alvos acima do Nv. 25');
      Exit;
    end;

    Inc(SelfPlayer^.Base.Character.CurrentScore.Honor, HONOR_PER_KILL);
    Inc(SelfPlayer^.Base.Character.CurrentScore.KillPoint);
    TItemFunctions.PutItem(SelfPlayer^, 11285, 1);
    SelfPlayer^.SendClientMessage
      ('Adquiriu ' + AnsiString(HONOR_PER_KILL.ToString) + ' pontos de honra.');
    SelfPlayer^.Base.SendRefreshKills();

    if SelfPlayer^.PartyIndex <> 0 then
    begin

      SelfParty := @Servers[SelfPlayer^.Base.ChannelId].Parties
        [SelfPlayer^.PartyIndex];

      for i in SelfParty^.Members do
      begin
        PartyMembers := @Servers[SelfPlayer^.Base.ChannelId].Players[i];
        if (i <> SelfPlayer^.Base.ClientID) and
          (SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
          (PartyMembers^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)) then
        begin
          Inc(PartyMembers^.Base.Character.CurrentScore.Honor,
            HONOR_PER_KILL div 2);
          Inc(PartyMembers^.Base.Character.CurrentScore.KillPoint);
          TItemFunctions.PutItem(PartyMembers^, 11285, 1);
          PartyMembers^.SendClientMessage
            ('Adquiriu ' + AnsiString((HONOR_PER_KILL div 2).ToString) +
            ' pontos de honra.');
          PartyMembers^.Base.SendRefreshKills();
        end;
      end;

      if SelfPlayer^.Party.InRaid then
      begin
        for j := 1 to 3 do
        begin
          if SelfParty^.PartyAllied[j] = 0 then
            Continue;

          AlliedRaids := @Servers[SelfPlayer^.ChannelIndex].Parties
            [SelfParty^.PartyAllied[j]];

          for i in AlliedRaids^.Members do
          begin
            RaidMembers := @Servers[SelfPlayer^.Base.ChannelId].Players[i];
            if SelfPlayer^.Base.PlayerCharacter.LastPos.InRange
              (RaidMembers^.Base.PlayerCharacter.LastPos, DISTANCE_TO_WATCH)
            then
            begin
              Inc(RaidMembers^.Base.Character.CurrentScore.Honor,
                HONOR_PER_KILL div 3);
              Inc(RaidMembers^.Base.Character.CurrentScore.KillPoint);
              TItemFunctions.PutItem(RaidMembers^, 11285, 1);
              RaidMembers^.SendClientMessage
                ('Adquiriu ' + AnsiString((HONOR_PER_KILL div 3).ToString) +
                ' pontos de honra.');
              RaidMembers^.Base.SendRefreshKills();
            end;
          end;
        end;
      end;
    end;

    TitleGoaled := false;

    for j := 0 to 95 do
    begin
      if SelfPlayer^.Base.PlayerCharacter.Titles[j].Index = 0 then
        Continue;

      if SelfPlayer^.Base.PlayerCharacter.Titles[j].Index = 27 then
      begin
        Inc(SelfPlayer^.Base.PlayerCharacter.Titles[j].Progress);

        if SelfPlayer^.Base.PlayerCharacter.Titles[j].Progress >= Titles[27]
          .TitleLevel[SelfPlayer^.Base.PlayerCharacter.Titles[j].Level].TitleGoal
        then
        begin
          SelfPlayer^.UpdateTitleLevel(27,
            SelfPlayer^.Base.PlayerCharacter.Titles[j].Level + 1, True);
          SelfPlayer^.SendClientMessage('Seu título [' + Titles[27].TitleLevel
            [SelfPlayer^.Base.PlayerCharacter.Titles[j].Level].TitleName +
            '] foi atualizado.');
        end
        else
        begin
          SelfPlayer^.UpdateTitleLevel(27,
            SelfPlayer^.Base.PlayerCharacter.Titles[j].Level, false);
        end;

        TitleGoaled := True;
        Break;
      end;
    end;

    if not TitleGoaled then
    begin
      SelfPlayer^.AddTitle(27, 0, false);
    end;

    if SelfPlayer^.Character.Base.GuildIndex <> 0 then
    begin
      GuildPointer := @Guilds[Servers[SelfPlayer^.Base.ChannelId].Players
        [SelfPlayer^.Base.ClientID].Character.GuildSlot];
      Inc(GuildPointer^.Exp, PvP_Exp_Guild);

      for m := 0 to 3 do
      begin
        if Servers[m].IsActive then
        begin
          for n := Low(Servers[m].Players) to High(Servers[m].Players) do
          begin
            GuildMembers := @Servers[m].Players[n];

            if not GuildMembers^.SocketClosed and
              (GuildMembers^.Status = Playing) and
              (GuildMembers^.Character.Base.GuildIndex <> 0) then
            begin
              CheckGuildPointer :=
                @Guilds[Servers[GuildMembers^.Base.ChannelId].Players
                [GuildMembers^.Base.ClientID].Character.GuildSlot];

              if CheckGuildPointer = GuildPointer then
              begin
                GuildMembers^.SendClientMessage
                  ('Pontos de experiência da legião foram incrementados em ' +
                  PvP_Exp_Guild.ToString + ' pontos.');
                GuildMembers^.SendGuildInfo;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TBaseMob.SelfBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
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
        if Self.PetClientID > 0 then
        begin
          Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
            ('Você não pode possuir dois PETs ao mesmo tempo.');
          Exit;
        end;

        // Self.CreatePet(X14, Pos, Skill);
        // Servers[Self.ChannelId].Players[Self.ClientID].SpawnPet(Self.PetClientID);
        Self.AddBuff(Skill);
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

procedure TBaseMob.TargetBuffSkill(Skill, Anim: DWORD; mob: PBaseMob;
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
          Helper2 := IfThen(mob^.Character.CurrentScore.CurHP >= Helper,
            RandomRange(60, 120), RandomRange(30, 59));
        end
        else
        begin
          Helper2 := RandomRange((Self.Character.CurrentScore.DNFis div 2),
            Self.Character.CurrentScore.DNFis + 1);
          if (Helper2 > 1000) and (DataSkill^.Index = 15) then
            Helper2 := 1000 + RandomRange(1, 200);
          Self.SDKMobID := mob.Mobid;
          Self.SDKSecondIndex := mob.SecondIndex;
          Self.SKDIsMob := True;
        end;

        Self.SKDSkillEtc1 := IfThen(DataSkill^.Index = 133,
          (DataSkill^.EFV[0] div 2) + Helper2,
          IfThen(DataSkill^.Index in [55, 79, 74, 250],
          (DataSkill^.EFV[0] + Helper2) div DataSkill^.Duration,
          DataSkill^.EFV[0] + Helper2));

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
        if (mob^.ClientID <= MAX_CONNECTIONS) and
          (mob^.Character.CurrentScore.CurHP >
          (mob^.Character.CurrentScore.MaxHP div 2)) then
          mob^.Character.CurrentScore.CurHP :=
            (mob^.Character.CurrentScore.MaxHP div 2);
        mob^.SendCreateMob(SPAWN_NORMAL, 0, True, 283);
        mob^.AddBuff(Skill);
      end;

    140:
      mob^.RemoveDebuffs(1);

    125, 248, 128:
      begin
        mob^.HPRListener := True;
        mob^.HPRAction := 2;
        mob^.HPRSkillID := Skill;
        mob^.HPRSkillEtc1 := IfThen(DataSkill^.Index = 128,
          Self.CalcCure2(DataSkill^.EFV[0], mob, Skill) + DataSkill^.EFV[0],
          IfThen(DataSkill^.Index = 248, DataSkill^.EFV[0],
          Round(Self.CalcCure2(DataSkill^.EFV[0], mob, Skill) /
          DataSkill^.Duration)));
        mob^.AddBuff(Skill);
      end;

    RESSUREICAO:
      if mob.IsDead then
      begin
        if (Self.PartyId = 0) or (mob.PartyId = 0) then
          Exit;
        if Servers[Self.ChannelId].Players[Self.ClientID].Party.InRaid then
        begin
          if mob.PartyId <> Self.PartyId then
          begin
            BoolHelper := false;
            for i := 1 to 3 do
              if Servers[Self.ChannelId].Players[Self.ClientID]
                .Party.PartyAllied[i] = mob.PartyId then
              begin
                BoolHelper := True;
                Break;
              end;
            if not BoolHelper then
              Exit;
          end;
        end
        else if mob.PartyId <> Self.PartyId then
          Exit;

        mob.IsDead := false;
        mob.Character.CurrentScore.CurHP :=
          ((mob.Character.CurrentScore.MaxHP div 100) * SkillData
          [Skill].Damage);
        mob.SendEffect(1);
        mob.SendCurrentHPMP(True);
        if Servers[mob.ChannelId].Players[ClientID].InDungeon then
          Servers[mob.ChannelId].Players[ClientID].TavaEmDG := false;
        Servers[mob.ChannelId].Players[mob.ClientID].SendClientMessage
          ('Você foi ressuscitado pelo jogador ' +
          AnsiString(Self.Character.Name) + '.');
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
        Logger.Write('Error at mob.AddBuff ' + E.Message, TLogType.Error);
    end;
  end;
end;

procedure TBaseMob.TargetSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  case SkillData[Skill].Classe of
    1, 2:
      Self.WarriorSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
        Resisted, Tipo);
    11, 12:
      Self.TemplarSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
        Resisted, Tipo);
    21, 22:
      Self.RiflemanSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
        Resisted, Tipo);
    31, 32:
      Self.DualGunnerSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
        Resisted, Tipo);
    41, 42:
      Self.MagicianSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
        Resisted, Tipo);
    51, 52:
      Self.ClericSkill(Skill, Anim, mob, Dano, DmgType, CanDebuff,
        Resisted, Tipo);
  end;
end;

procedure TBaseMob.AreaBuff(Skill, Anim: DWORD; mob: PBaseMob;
  Packet: TRecvDamagePacket);
var
  i, cnt: Integer;
  PrePosition: TPosition;
begin
  if ((Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = 0) or
    (SkillData[Skill].Index = LAMINA_PROMESSA)) then
  begin // Se n?o estiver em party, buffa s? em si mesmo
    Self.SelfBuffSkill(Skill, Anim, mob, Packet.DeathPos);
    // Logger.Write(Packet.DeathPos.X.ToString, TLogType.Packets);
  end
  else
  begin
    cnt := 0;
    // Se estiver em party, vai buffar em si mesmo + Party
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
        if (Servers[Self.ChannelId].Players[i].Status < Playing) or
          (Servers[Self.ChannelId].Players[i].Base.IsDead) then
          Continue;
        if (Servers[Self.ChannelId].Players[i].PartyIndex = 0) then
          Continue;
        if (cnt = 0) then
        begin
          PrePosition := Self.PlayerCharacter.LastPos;
          Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players
            [Self.ClientID].Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
            Trunc(Packet.DeathPos.y));
          cnt := 1;
        end;
        if (Servers[Self.ChannelId].Players[Self.ClientID].Party.
          Index <> Servers[Self.ChannelId].Players[i].Party.Index) then
          Continue;

        if not(PrePosition.InRange(Servers[Self.ChannelId].Players[i]
          .Base.PlayerCharacter.LastPos, Trunc(SkillData[Skill].range * 1.5)))
        then
          Continue;

        Self.TargetBuffSkill(Skill, Anim, @Servers[Self.ChannelId].Players[i]
          .Base, @SkillData[Skill], Trunc(Packet.DeathPos.x),
          Trunc(Packet.DeathPos.y));
        Packet.Animation := 0;
        Packet.TargetID := i;
        Packet.AttackerHP := Servers[Self.ChannelId].Players[i]
          .Base.Character.CurrentScore.CurHP;
        // Packet.DeathPos := Servers[Self.ChannelId].Players[i]
        // .Base.PlayerCharacter.LastPos;
        Self.SendToVisible(Packet, Packet.Header.size);
      end;
    end;
  end;
  if (SkillData[Skill].Index = 167) then
    Self.UsingLongSkill := True;
end;

procedure TBaseMob.AreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  SkillPos: TPosition; DataSkill: P_SkillData; DamagePerc: Single = 0;
  ElThymos: Integer = 0; Tipo: Byte = 9);
var
  Dano: Integer;
  DmgType: TDamageType;
  SelfPlayer: PPlayer;
  OtherPlayer: PPlayer;
  NewMob, mob_teleport: PBaseMob;
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

  if (Servers[Self.ChannelId].Players[Self.ClientID].InDungeon) then
  begin
    var
      MobAtacado: Integer := 0;

      // Loop de targets visíveis
    for i := Low(VisibleTargets) to High(VisibleTargets) do
    begin

      if (VisibleTargets[i].ClientID = 0) then
        Continue;

      // Obtenha o mob correspondente ao alvo
      NewMob := Self.GetTargetInList(VisibleTargets[i].ClientID);
      if (NewMob = nil) or (NewMob^.IsDead) then
        Continue;

      // Verifique se o mob está dentro do alcance da skill
      if (DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[NewMob^.Mobid].Position.Distance(SkillPos) >=
        (DataSkill^.range * 1.5)) then
        Continue;

      // Mob está dentro do alcance, podemos continuar com o processo
      Mobid := NewMob^.Mobid;

      // Verificar se o mob foi atacado antes

      if not DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[Mobid].IsAttacked then
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].IsAttacked := True;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].FirstPlayerAttacker := Self.ClientID;
      end;
      DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
        .DungeonInstanceID].MOBS[Mobid].AttackerID := Self.ClientID;

      // Aplica a skill
      Packet.TargetID := NewMob^.ClientID;
      Resisted := false;

      // Verifique a classe e aplique a skill correspondente
      case DataSkill^.Classe of
        1, 2:
          begin
            Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
              Resisted, MoveTarget, Tipo);
            Self.PlayerCharacter.CurrentPos := SkillPos;
          end;
        11, 12:
          begin
            Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
              Resisted, Tipo);
            Self.PlayerCharacter.CurrentPos := SkillPos;
          end;
        21, 22:
          Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Resisted, Tipo);
        31, 32:
          begin
            Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
              Add_Buff, Resisted, Tipo);
            Self.PlayerCharacter.CurrentPos := SkillPos;
          end;
        41, 42:
          Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Resisted, Tipo);
        51, 52:
          Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
            Resisted, Tipo);
      end;

      Inc(MobAtacado);

      if (Dano > 0) then
      begin
        // Aplica o dano ao mob
        Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
          Packet.MobAnimation, DataSkill, Tipo);
        Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));
      end;

      if (Add_Buff) and not Resisted then
        Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);

      // Atualiza o HP do mob e verifica se ele morreu
      Packet.Dano := Dano;
      Packet.DnType := DmgType;

      if (Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players
        [Self.ClientID].DungeonInstanceID].MOBS[Mobid].CurrentHP) then
      begin
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].CurrentHP := 0;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].IsAttacked := false;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].AttackerID := 0;
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].deadTime := Now;

        if (Self.VisibleMobs.Contains(NewMob^.ClientID)) then
          Self.VisibleMobs.Remove(NewMob^.ClientID);
        NewMob^.VisibleMobs.Clear;
        Self.MobKilledInDungeon(NewMob);
        Packet.MobAnimation := 30;
        NewMob^.IsDead := True;
        Self.RemoveTargetFromList(NewMob);
        Self.MobKilled(NewMob, DropExp, DropItem, false);
        WriteLn('dropped exp ' + DropExp.ToString);
        WriteLn('dropped item ' + DropItem.ToString);

      end
      else
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].CurrentHP :=
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[Mobid].CurrentHP - dword(Packet.DANO);

      // Writeln('Client id do atacado ' + DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[Mobid].Base.ClientID.ToString);

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
      WriteLn('nenhum mob atacado');
      Packet.TargetID := 0;
      Packet.Dano := 0;
      Packet.DnType := TDamageType.Normal;
      Packet.AttackerPos := SkillPos;
      Packet.DeathPos := SkillPos;
      Self.SendToVisible(Packet, Packet.Header.size);
    end;

    Exit;
  end;

  cnt := 0;
  SelfPlayer := @Servers[Self.ChannelId].Players[Self.ClientID];
  for i := Low(VisibleTargets) to High(VisibleTargets) do
  begin
    if (VisibleTargets[i].ClientID = 0) then
      Continue;

    if (ElThymos > 0) then
    begin
      if (VisibleTargets[i].ClientID = mob.ClientID) then
        Continue;
    end;

    case VisibleTargets[i].TargetType of
      0:
        begin
          if (VisibleTargets[i].Player = nil) then
            Continue;

          NewMob := VisibleTargets[i].Player;
          OtherPlayer := @Servers[Self.ChannelId].Players
            [VisibleTargets[i].ClientID];
          if (NewMob^.IsDead) then
            Continue;
          if (OtherPlayer.SocketClosed) then
            Continue;
          if (OtherPlayer.Status < Playing) then
            Continue;
          if (SkillPos.InRange(NewMob^.PlayerCharacter.LastPos,
            Trunc(DataSkill^.range * 1.5))) then
          begin
            if (TPosition.Create(2947, 1664)
              .InRange(NewMob^.PlayerCharacter.LastPos, 10)) then
              Continue;
            if ((SelfPlayer^.Character.Base.GuildIndex > 0) and
              (SelfPlayer.Character.Base.GuildIndex = OtherPlayer^.Character.
              Base.GuildIndex) and not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.PartyIndex > 0) and
              (SelfPlayer.PartyIndex = OtherPlayer^.PartyIndex) then
              Continue;
            if ((Self.Character.Nation = NewMob^.Character.Nation) and
              (SelfPlayer^.Character.PlayerKill = false) and
              not(SelfPlayer^.Dueling)) then
              Continue;
            if (SelfPlayer^.Dueling) then
            begin
              if (NewMob^.ClientID <> SelfPlayer^.DuelingWith) then
                Continue;
              if (SecondsBetween(Now, SelfPlayer^.DuelInitTime) <= 15) then
                Continue;
            end;

            if ((SelfPlayer^.Character.GuildSlot > 0) and
              (Servers[SelfPlayer^.ChannelIndex].Players[NewMob^.ClientID]
              .Character.GuildSlot > 0)) then
            begin
              if (Guilds[SelfPlayer^.Character.GuildSlot].Ally.Leader = Guilds
                [Servers[SelfPlayer^.ChannelIndex].Players[NewMob^.ClientID]
                .Character.GuildSlot].Ally.Leader) then
                Exit;
            end;

            if (SecondsBetween(Now, NewMob.RevivedTime) <= 7) then
            begin
              Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
                ('Alvo acabou de nascer.');
              Continue;
            end;
            Inc(cnt);
            Packet.TargetID := NewMob^.ClientID;
            Resisted := false;
            case DataSkill^.Classe of
              1, 2: // warrior skill
                begin
                  Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, MoveTarget, Tipo);
                end;
              11, 12: // templar skill
                begin
                  Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, Tipo);
                end;
              21, 22: // rifleman skill
                begin
                  Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, Tipo);
                end;
              31, 32: // dualgunner skill
                begin
                  Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, Tipo);
                end;
              41, 42: // magician skill
                begin
                  Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, Tipo);
                end;
              51, 52: // cleric skill
                begin
                  Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                    Add_Buff, Resisted, Tipo);
                end;
            end;
            if (Dano > 0) then
            begin
              if (ElThymos > 0) then
              begin
                Self.AttackParse(0, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill, Tipo);
              end
              else
              begin
                Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                  Packet.MobAnimation, DataSkill, Tipo);
              end;

              if (Dano > 0) then
              begin
                Inc(Dano, ((RandomRange((Dano div 20), (Dano div 10))) + 13));

                if (DamagePerc > 0) then
                begin
                  Dano := Trunc((Dano div 100) * DamagePerc);
                end;
              end;
            end
            else
            begin
              if not(DmgType in [Critical, Normal, Double]) then
                Add_Buff := false;
            end;
            if (Add_Buff = True) then
            begin
              if not(Resisted) then
                Self.TargetBuffSkill(Skill, Anim, NewMob, DataSkill);
            end;
            if ((ElThymos > 0) and (Dano > 0)) then
            begin
              Dano := Round((Dano / 100) * DamagePerc);
            end;
            if (DmgType = Miss) then
              Dano := 0;

            Packet.Dano := Dano;
            Packet.DnType := DmgType;
            if (Packet.Dano >= NewMob^.Character.CurrentScore.CurHP) then
            begin
              if (OtherPlayer^.Dueling) then
              begin
                NewMob^.Character.CurrentScore.CurHP := 10;
              end
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
                if (NewMob^.Character.Nation > 0) and (Self.Character.Nation > 0)
                then
                begin
                  if ((NewMob^.Character.Nation <> Self.Character.Nation) or
                    (Self.InClastleVerus)) then
                  begin

                    Self.PlayerKilled(NewMob);

                    NewMob.SendEffectOther($3F, 1);
                  end;
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
            end;

            // Sleep(1);
          end;
        end;
      1:
        begin
          if (VisibleTargets[i].mob = nil) then
            Continue;
          NewMob := VisibleTargets[i].mob;
          if (NewMob.ClientID > 9147) then
            Continue;
          if not(Servers[Self.ChannelId].MOBS.TMobS[NewMob.Mobid]
            .IsActiveToSpawn) then
            Continue;
          if (NewMob^.IsDead) then
            Continue;
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
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := false;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget, Tipo);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted, Tipo);
                      end;
                  end;
                  if (Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType,
                      Add_Buff, Packet.MobAnimation, DataSkill, Tipo);

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
                        Servers[Self.ChannelId].Players[j]
                          .Base.RemoveTargetFromList(NewMob);
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
                    Continue;
                  Inc(cnt);
                  Packet.TargetID := NewMob^.ClientID;
                  Resisted := false;
                  case DataSkill^.Classe of
                    1, 2: // warrior skill
                      begin
                        Self.WarriorAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, MoveTarget, Tipo);
                      end;
                    11, 12: // templar skill
                      begin
                        Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    21, 22: // rifleman skill
                      begin
                        Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    31, 32: // dualgunner skill
                      begin
                        Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    41, 42: // magician skill
                      begin
                        Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano,
                          DmgType, Add_Buff, Resisted, Tipo);
                      end;
                    51, 52: // cleric skill
                      begin
                        Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                          Add_Buff, Resisted, Tipo);
                      end;
                  end;
                  if (Dano > 0) then
                  begin
                    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType,
                      Add_Buff, Packet.MobAnimation, DataSkill, Tipo);

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
                        Servers[Self.ChannelId].Players[j]
                          .Base.RemoveTargetFromList(NewMob);
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
                  Continue;

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
                        Add_Buff, Resisted, MoveTarget, Tipo);
                    end;
                  11, 12: // templar skill
                    begin
                      Self.TemplarAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, Tipo);
                    end;
                  21, 22: // rifleman skill
                    begin
                      Self.RiflemanAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, Tipo);
                    end;
                  31, 32: // dualgunner skill
                    begin
                      Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano,
                        DmgType, Add_Buff, Resisted, Tipo);
                    end;
                  41, 42: // magician skill
                    begin
                      Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, Tipo);
                    end;
                  51, 52: // cleric skill
                    begin
                      Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
                        Add_Buff, Resisted, Tipo);
                    end;
                end;
                if (Dano > 0) then
                begin
                  Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
                    Packet.MobAnimation, DataSkill, Tipo);

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
                      Servers[Self.ChannelId].Players[j]
                        .Base.RemoveTargetFromList(NewMob);
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
  // tem que continuar transformando tudo em pointer pra isso ficar dinamico
  // tem que terminar de completar a funcao acima de player
  // fazer a de mobs
  // ver se o dungeons la em cima pode encaixar junto
  // dps excluir aqui embaixo
  // 16/03/2021
  {
    if (Self.VisiblePlayers.Count > 0) then
    begin
    for i in Self.VisiblePlayers do
    begin
    if (Servers[Self.ChannelId].Players[i].Base.ClientID = Self.ClientID) then
    Continue;
    if (Servers[Self.ChannelId].Players[i].Base.PlayerCharacter.LastPos.
    InRange(SkillPos, (SkillData[Skill].range * 2.5))) then
    begin
    NewMob := @Servers[Self.ChannelId].Players[i].Base;
    if (NewMob.IsDead) then
    Continue;
    if ((Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.Base.GuildIndex > 0) and
    (Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.Base.GuildIndex = Servers[Self.ChannelId].Players[i]
    .Character.Base.GuildIndex) and
    not(Servers[Self.ChannelId].Players[Self.ClientID].Dueling)) then
    Continue; // mesma guild, se nao tiver duelando
    if (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex > 0) and
    (Servers[Self.ChannelId].Players[Self.ClientID].PartyIndex = Servers
    [Self.ChannelId].Players[i].PartyIndex) then
    Continue; // mesma party
    if ((Self.Character.Nation = NewMob.Character.Nation) and
    (Servers[Self.ChannelId].Players[Self.ClientID]
    .Character.PlayerKill = False) and
    not(Servers[Self.ChannelId].Players[Self.ClientID].Dueling)) then
    Continue; // mesma na??o e pk desligado, se nao tiver duelando
    if (Servers[Self.ChannelId].Players[Self.ClientID].Dueling) then
    begin
    if (i <> Servers[Self.ChannelId].Players[Self.ClientID].DuelingWith)
    then
    Continue;
    if (SecondsBetween(Now, Servers[Self.ChannelId].Players[Self.ClientID]
    .DuelInitTime) <= 15) then
    // fix de atk em area antes do tempo acabar
    Continue;
    end;
    Packet.TargetID := NewMob.ClientID;
    Resisted := False;
    case SkillData[Skill].Classe of
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
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    41, 42: // magician skill
    begin
    Self.MagicianAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
    end;
    51, 52: // cleric skill
    begin
    Self.ClericAreaSkill(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Resisted);
    end;
    end;
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    if (Packet.Dano >= NewMob.Character.CurrentScore.CurHP) then
    begin
    if (Servers[Self.ChannelId].Players[NewMob.ClientID].Dueling) then
    begin
    NewMob.Character.CurrentScore.CurHP := 10;
    end
    else
    begin
    NewMob.Character.CurrentScore.CurHP := 0;
    NewMob.SendEffect($0);
    Packet.MobAnimation := 30;
    NewMob.IsDead := True;
    if (NewMob.Character.Nation > 0) and (Self.Character.Nation > 0)
    then
    begin
    if (NewMob.Character.Nation <> Self.Character.Nation) then
    begin
    Self.PlayerKilled(NewMob);
    end;
    end;
    // Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
    // Servers[Self.ChannelId].Players[Self.ClientId].SendClientMessage
    // ('Seus pontos de PvP foram incrementados em 1.');
    // Self.SendRefreshKills;
    // Self.SendRefreshPoint;
    end;
    end
    else
    begin
    NewMob.RemoveHP(Packet.Dano, False);
    end;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := NewMob.Character.CurrentScore.CurHP;
    Packet.AttackerPos := Self.PlayerCharacter.LastPos;
    Packet.DeathPos := SkillPos;
    // Self.SendCurrentHPMP;
    { if (cnt = 0) then
    Self.SendToVisible(Packet, Packet.Header.size)
    else
    Self.SendToVisible(Packet, Packet.Header.size, False);
    Inc(cnt); }
  { end;
    end;
    end;
    if (Self.VisibleMobs.Count > 0) then
    begin
    for i in Self.VisibleMobs do
    begin
    if ((i >= 3048) and (i <= 9147)) then
    begin
    Mobid := TMobFuncs.GetMobGeralID(Self.ChannelId, i, mobpid);
    if (Mobid = -1) then
    Continue;
    /// /////////
    NewMob := @Servers[Self.ChannelId].Mobs.TMobS[Mobid].MobsP[mobpid].Base;
    if (NewMob.IsDead) then
    Continue;
    if ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].CurrentPos.Distance(SkillPos) <=
    (SkillData[Skill].range * 2.5))) { or
    ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].CurrentPos.Distance(Self.PlayerCharacter.LastPos)
    <= (SkillData[Skill].range)) and (Self.GetMobClass = 2)))
  } { then
    begin
    if ((Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].isGuard) and
    (Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].Base.PlayerCharacter.Base.Nation = Self.
    Character.Nation)) then
    Continue;
    Packet.TargetID := i;
    Resisted := False;
    case SkillData[Skill].Classe of
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
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
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
    Inc(cnt);
    try
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    except
    on E: Exception do
    begin // apagar dps isso e mais 2 exceptions
    Logger.Write('Error at AttackParse mob area attack: ' + E.Message,
    TLogType.Warnings);
    end;
    end;
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].IsAttacked := True;
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].AttackerID := Self.ClientID;
    if (Packet.Dano >= Servers[mob.ChannelId].Mobs.TMobS[NewMob.Mobid]
    .MobsP[NewMob.SecondIndex].HP) then
    begin
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [mob.SecondIndex].HP := 0;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].IsAttacked := False;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].AttackerID := 0;
    Servers[NewMob.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].deadTime := Now;
    if (Self.VisibleMobs.Contains(Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].Index)) then
    begin
    Self.VisibleMobs.Remove(Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].Index);
    end;
    NewMob.VisibleMobs.Clear;
    Self.MobKilled(NewMob, DropExp, DropItem, False);
    Packet.MobAnimation := 30;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := 0;
    Self.SendToVisible(Packet, Packet.Header.size);
    NewMob.IsDead := True;
    end
    else
    begin
    Servers[Self.ChannelId].Mobs.TMobS[NewMob.Mobid].MobsP
    [NewMob.SecondIndex].HP := Servers[Self.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].HP - Packet.Dano;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := Servers[NewMob.ChannelId].Mobs.TMobS
    [NewMob.Mobid].MobsP[NewMob.SecondIndex].HP;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    end;
    end;
    end
    else if (mob.ClientID >= 9148) then
    begin
    NewMob := @Servers[Self.ChannelId].PETS[mob.ClientID].Base;
    if (NewMob.IsDead) then
    Continue;
    if (Servers[Self.ChannelId].PETS[NewMob.ClientID]
    .Base.PlayerCharacter.LastPos.Distance(SkillPos) <=
    (SkillData[Skill].range)) then
    begin
    Packet.TargetID := NewMob.ClientID;
    Resisted := False;
    case SkillData[Skill].Classe of
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
    Self.DualGunnerAreaSkill(Skill, Anim, NewMob, Dano, DmgType,
    Add_Buff, Resisted);
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
    Inc(cnt);
    Self.AttackParse(Skill, Anim, NewMob, Dano, DmgType, Add_Buff,
    Packet.MobAnimation);
    if (Add_Buff = True) then
    begin
    if not(Resisted) then
    Self.TargetBuffSkill(Skill, Anim, NewMob);
    end;
    Packet.Dano := Dano;
    Packet.DnType := DmgType;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].IsAttacked := True;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].AttackerID :=
    Self.ClientID;
    if (Packet.Dano >= NewMob.Character.CurrentScore.CurHP) then
    begin
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP := 0;
    Packet.MobAnimation := 30;
    NewMob.IsDead := True;
    for j in NewMob.VisibleMobs do
    begin
    if not(j >= 3048) then
    begin
    Servers[Self.ChannelId].Players[j].UnSpawnPet(NewMob.ClientID);
    end;
    end;
    Inc(Self.PlayerCharacter.Base.CurrentScore.KillPoint);
    Self.SendRefreshKills;
    Servers[Self.ChannelId].PETS[NewMob.ClientID].Base.Destroy;
    ZeroMemory(@Servers[Self.ChannelId].PETS[NewMob.ClientID],
    sizeof(TPet));
    end
    else
    begin
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP :=
    NewMob.PlayerCharacter.Base.CurrentScore.CurHP - Packet.Dano;
    end;
    NewMob.LastReceivedAttack := Now;
    Packet.MobCurrHP := NewMob.PlayerCharacter.Base.CurrentScore.CurHP;
    // Self.SendCurrentHPMP;
    Self.SendToVisible(Packet, Packet.Header.size);
    end;
    Continue;
    end;
    end;
    end;
    if (cnt = 0) then
    begin
    Logger.Write('Sem alvo disponivel.', TLogType.Packets);
    Packet.TargetID := Self.ClientID;
    /// ////era $7535
    Packet.Dano := 0;
    Packet.DnType := TDamageType.Normal;
    Packet.AttackerPos := SkillPos;
    Packet.DeathPos := SkillPos;
    Self.SendToVisible(Packet, Packet.Header.size);
    end; }
end;

procedure TBaseMob.AttackParse(Skill: WORD; Anim: DWORD; mob: PBaseMob;
  var Dano: Integer; var DmgType: TDamageType; out AddBuff: Boolean;
  out MobAnimation: Byte; DataSkill: P_SkillData; Tipo: Byte);
const
  // Constantes pré-calculadas para evitar recalculos
  CRITICAL_MULTIPLIER = 1.1;
  DOUBLE_CRITICAL_MULTIPLIER = 2.1;
  ONE_PERCENT_DIVISOR = 100;
  SPLASH_SKILL_ID = 177;
  MAX_DAMAGE = 999999;
var
  Helper, Help1, Help2: Integer;
  HelperInByte: Byte;
  OnePercentOfTheDamage: Integer;
  RandomValue: Integer;
  SkillIndex: Integer;
  NationID: Integer;
  ReliqEffect: Integer;
  MobAbility: Integer;
  BuffIndex: WORD;
  CurrentTime: TDateTime;
  IsCritical: Boolean;
  IsDoubleCritical: Boolean;
  IsDoubleDamage: Boolean;
  OtherPlayer: PPlayer;
begin
  CurrentTime := Now;
  RandomValue := Random(100) + 1;
  // Substitui RandomRange por operação mais direta

  // Pré-calcular flags para evitar verificações repetidas
  IsCritical := (DmgType = Critical);
  IsDoubleCritical := (DmgType = DoubleCritical);
  IsDoubleDamage := (DmgType = Double);

  if Skill > 0 then
  begin
    Inc(Dano, (DataSkill^.Damage + Self.PlayerCharacter.HabAtk) div 2);
    Inc(Dano, Self.GetMobAbility(EF_PRAN_SKILL_DAMAGE));

    if (Self.Character <> nil) and
      (Servers[Self.ChannelId].NationID = Self.Character.Nation) then
    begin
      ReliqEffect := Servers[Self.ChannelId].ReliqEffect
        [EF_RELIQUE_SKILL_PER_DAMAGE];
      Inc(Dano, ReliqEffect * (Dano div ONE_PERCENT_DIVISOR));
    end;
  end
  else if (Self.GetMobAbility(EF_SPLASH) > 0) and
    (SecondsBetween(CurrentTime, LastSplashTime) >= 1) then
  begin
    LastSplashTime := CurrentTime;
    Self.AreaSkill(SPLASH_SKILL_ID, SkillData[SPLASH_SKILL_ID].Anim, mob,
      Self.PlayerCharacter.LastPos, @SkillData[SPLASH_SKILL_ID],
      Self.GetMobAbility(EF_SPLASH), 1);
  end;

  if (Skill > 0) and ((Self.GetMobClass() = 2) or (Self.GetMobClass() = 4)) and
    (SkillData[Skill].Adicional > 0) then
  begin
    if SkillData[Skill].Adicional <= RandomValue then
      DmgType := Critical;
  end;

  case DmgType of
    Critical, DoubleCritical:
      begin
        OnePercentOfTheDamage := Dano div ONE_PERCENT_DIVISOR;
        if IsCritical then
          Dano := Trunc(Dano * CRITICAL_MULTIPLIER)
        else if IsDoubleCritical then
          Dano := Trunc(Dano * DOUBLE_CRITICAL_MULTIPLIER);

        Helper := Self.PlayerCharacter.DamageCritical -
          mob^.PlayerCharacter.ResDamageCritical;
        if Helper < 0 then
          dec(Dano, OnePercentOfTheDamage * Abs(Helper))
        else
          Inc(Dano, OnePercentOfTheDamage * Helper);
      end;
    Double:
      Dano := Dano * 2;
  end;

  MobAbility := mob^.GetMobAbility(EF_AMP_PHYSICAL);
  if MobAbility > 0 then
    Inc(Dano, (Dano div ONE_PERCENT_DIVISOR) * MobAbility);

  if mob^.GetMobAbility(EF_TYPE45) > 0 then
    Inc(Dano, (Dano div ONE_PERCENT_DIVISOR) * 10);

  for BuffIndex in [432, 123, 131, 142] do
    if mob^.BuffExistsByIndex(BuffIndex) then
    begin
      Help1 := mob^.GetMobAbility(IfThen(BuffIndex = 142, EF_SKILL_ABSORB2,
        EF_SKILL_ABSORB1));
      if Help1 > Dano then
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
        dec(Dano, Help1);
        mob^.RemoveBuffByIndex(BuffIndex);
      end;
    end;

  if mob^.Polimorfed then
  begin
    DmgType := TDamageType.DoubleCritical;
    mob^.Polimorfed := false;
    if mob^.ClientID <= MAX_CONNECTIONS then
    begin
      mob^.RemoveBuffByIndex(99);
      mob^.SendCreateMob(SPAWN_NORMAL);
    end;
  end;

  MobAbility := Self.GetMobAbility(EF_DRAIN_HP);
  if MobAbility > 0 then
    Self.AddHP((Dano div ONE_PERCENT_DIVISOR) * MobAbility, True);

  MobAbility := Self.GetMobAbility(EF_DRAIN_MP);
  if MobAbility > 0 then
    Self.AddMP((Dano div ONE_PERCENT_DIVISOR) * MobAbility, True);

  MobAbility := Self.GetMobAbility(EF_HP_ATK_RES);
  if MobAbility > 0 then
    Self.AddHP((Dano div ONE_PERCENT_DIVISOR) * MobAbility, True);

  if mob^.BuffExistsByIndex(101) then
  begin
    Help1 := (Dano div ONE_PERCENT_DIVISOR) * mob^.GetMobAbility
      (EF_HP_CONVERSION);
    Help2 := Trunc(Help1 * (mob^.GetMobAbility(EF_MP_EFFICIENCY) /
      ONE_PERCENT_DIVISOR));

    if Help2 >= mob^.Character.CurrentScore.CurMP then
      mob^.RemoveBuffByIndex(101);

    mob^.RemoveMP(Help2, True);
    dec(Dano, Help1);
  end;

  for BuffIndex in [111, 86, 63, 153] do
    if mob^.BuffExistsByIndex(BuffIndex) then
      mob^.RemoveBuffByIndex(BuffIndex);

  if mob^.ClientID <= MAX_CONNECTIONS then
  begin
    if (mob^.Character.Nation <> Self.Character.Nation) and
      (mob^.Character.Nation > 0) and (Self.Character.Nation > 0) then
    begin
      Inc(Dano, Self.PlayerCharacter.PvPDamage);
      dec(Dano, mob.PlayerCharacter.PvPDefense);

      if Servers[Self.ChannelId].NationID = Self.Character.Nation then
      begin
        ReliqEffect := Servers[Self.ChannelId].ReliqEffect
          [EF_RELIQUE_ATK_NATION];
        Inc(Dano, ReliqEffect * (Dano div ONE_PERCENT_DIVISOR));
      end;

      Helper := Dano;
      Inc(Dano, ((Helper div ONE_PERCENT_DIVISOR) *
        Self.GetMobAbility(EF_MARSHAL_ATK_NATION)));
      dec(Dano, ((Helper div ONE_PERCENT_DIVISOR) *
        mob.GetMobAbility(EF_MARSHAL_DEF_NATION)));

      if Servers[Self.ChannelId].NationID = mob.Character.Nation then
      begin
        ReliqEffect := Servers[Self.ChannelId].ReliqEffect
          [EF_RELIQUE_DEF_NATION];
        dec(Dano, ReliqEffect * (Dano div ONE_PERCENT_DIVISOR));
      end;
    end;
  end
  else if Servers[Self.ChannelId].NationID = Self.Character.Nation then
  begin
    ReliqEffect := Servers[Self.ChannelId].ReliqEffect[EF_RELIQUE_ATK_MONSTER];
    Inc(Dano, ReliqEffect * (Dano div ONE_PERCENT_DIVISOR));
  end;

  HelperInByte := 0;
  if Self.IsCompleteEffect5(HelperInByte) and
    (RandomValue <= (RATE_EFFECT5 * Length(Self.EFF_5))) then
    Self.Effect5Skill(mob, HelperInByte);

  MobAbility := Self.GetMobAbility(EF_DECREASE_PER_DAMAGE1);
  if MobAbility > 0 then
    dec(Dano, ((Dano div ONE_PERCENT_DIVISOR) * MobAbility));

  MobAbility := mob^.GetMobAbility(EF_HP_CONVERSION);
  if MobAbility > 0 then
    dec(Dano, ((Dano div ONE_PERCENT_DIVISOR) * MobAbility));

  if mob^.BuffExistsByIndex(337) and not((SkillData[Skill].Index = 8) or
    (SkillData[Skill].Index = 90) or mob^.BuffExistsByIndex(8) or
    mob^.BuffExistsByIndex(90)) then
  begin
    AddBuff := false;
    Servers[Self.ChannelId].Players[Self.ClientID].SendClientMessage
      ('[' + AnsiString(mob.Character.Name) + '] resistiu.');
    Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
      ('Você resistiu.');
  end;

  if mob^.BuffExistsByIndex(38) then
  begin
    Help1 := mob^.GetMobAbility(EF_REFLECTION2);
    Self.RemoveHP(((Dano div ONE_PERCENT_DIVISOR) * Help1), True, True);
    mob^.RemoveBuffByIndex(38);
    Dano := 0;
    DmgType := TDamageType.None;
  end;

  if Dano > 0 then
  begin
    Helper := mob^.GetMobAbility(EF_REFLECTION1);
    if Helper > 0 then
    begin
      Self.RemoveHP(Helper, false, True);
      Self.SendCurrentHPMP(True);
    end;

    if mob^.BuffExistsByIndex(222) then
    begin
      Helper := mob^.GetMobAbility(EF_SKILL_ABSORB1);
      if Helper > 0 then
      begin
        if Dano >= Helper then
        begin
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Helper);
          mob^.RemoveBuffByIndex(222);
        end
        else
          mob^.DecreasseMobAbility(EF_SKILL_ABSORB1, Dano);
        dec(Dano, Helper);
      end;
    end;
  end;

  if mob^.BuffExistsByIndex(32) then
  begin
    dec(Dano, ((Dano div ONE_PERCENT_DIVISOR) *
      mob.GetMobAbility(EF_POINT_DEFENCE)));
    dec(mob^.DefesaPoints, 1);
    if mob^.DefesaPoints = 0 then
      mob^.RemoveBuffByIndex(32);
  end;

  if mob^.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '') then
  begin
    Helper := Dano;
    dec(Dano, ((Dano div ONE_PERCENT_DIVISOR) *
      mob.GetMobAbility(EF_TRANSFER)));
    dec(Helper, Dano);
    OtherPlayer := Servers[Self.ChannelId].GetPlayer(mob.UniaoDivina);

    if (OtherPlayer <> nil) and not OtherPlayer.Base.IsDead and
      (OtherPlayer.Status >= Playing) and not OtherPlayer.SocketClosed then
    begin
      OtherPlayer.Base.RemoveHP(Helper, True, True);
      OtherPlayer.Base.LastReceivedAttack := CurrentTime;
      OtherPlayer.SendClientMessage('Seu HP foi consumido.');
    end
    else
    begin
      mob.RemoveBuffByIndex(35);
      mob.UniaoDivina := '';
    end;
  end;

  if mob^.BuffExistsByIndex(36) and (Skill > 0) then
  begin
    dec(mob^.BolhaPoints, IfThen(DataSkill^.Index = 136, DataSkill^.Damage, 1));

    if mob^.BolhaPoints = 0 then
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

  if (Dano <> 0) and (mob^.ClientID < 3048) then
  begin
    if mob^.BuffExistsByIndex(460) and (Dano > mob^.Character.CurrentScore.CurHP)
    then
    begin
      mob^.RemoveBuffByIndex(460);
      mob^.RemoveAllDebuffs;
      mob^.ResolutoPoints := 0;
      mob^.Character.CurrentScore.CurHP :=
        ((mob^.Character.CurrentScore.MaxHP div ONE_PERCENT_DIVISOR) * 30);
      mob^.Character.CurrentScore.CurMP :=
        ((mob^.Character.CurrentScore.MaxMP div ONE_PERCENT_DIVISOR) * 25);
      mob^.SendCurrentHPMP(True);
      Servers[Self.ChannelId].Players[mob^.ClientID].SendClientMessage
        ('Você foi revivido.');
    end;
  end;

  if mob.BuffExistsByIndex(154) then
    mob.Chocado := false;

  MobAbility := mob^.GetMobAbility(EF_ADD_DAMAGE1);
  if MobAbility > 0 then
    Inc(Dano, (MobAbility * 2));

  if mob^.BuffExistsByIndex(90) and (IsCritical or IsDoubleCritical) then
    Self.TargetBuffSkill(6279, 0, mob, @SkillData[6279]);

  if mob^.ResolutoPoints > 0 then
  begin
    if SecondsBetween(CurrentTime, mob^.ResolutoTime) >= 8 then
      mob^.ResolutoPoints := 0
    else if (mob^.ResolutoPoints > 1) and (mob.Mobid = 0) then
    begin
      Helper := Random(3) - 1; // Substitui RandomRange por operação mais direta
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
    MobAbility := Self.GetMobAbility(EF_ATK_MONSTER);
    if MobAbility > 0 then
      Inc(Dano, Round((Dano / ONE_PERCENT_DIVISOR) * MobAbility));

    if mob.GetMobAbility(197) > 0 then
    begin
      MobAbility := Self.GetMobAbility(EF_ATK_UNDEAD);
      if MobAbility > 0 then
        Inc(Dano, Round((Dano / ONE_PERCENT_DIVISOR) * MobAbility));

      MobAbility := Self.GetMobAbility(EF_ATK_DEMON);
      if MobAbility > 0 then
        Inc(Dano, Round((Dano / ONE_PERCENT_DIVISOR) * MobAbility));
    end;

    if (Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid].MobType >= 1024) then
    begin
      SkillIndex := Servers[Self.ChannelId].MOBS.TMobS[mob.Mobid]
        .MobType - 1024;
      if (SkillIndex >= 0) and (SkillIndex <= 7) then
      begin
        MobAbility := Self.GetMobAbility(EF_ATK_ALIEN + SkillIndex);
        if MobAbility > 0 then
          Inc(Dano, Round((Dano / ONE_PERCENT_DIVISOR) * MobAbility));
      end
      else
      begin
        MobAbility := Self.GetMobAbility(EF_ATK_UNDEAD);
        if MobAbility > 0 then
          Inc(Dano, Round((Dano / ONE_PERCENT_DIVISOR) * MobAbility));

        MobAbility := Self.GetMobAbility(EF_ATK_DEMON);
        if MobAbility > 0 then
          Inc(Dano, Round((Dano / ONE_PERCENT_DIVISOR) * MobAbility));
      end;
    end;
  end;

  if (Dano > MAX_DAMAGE) or (Dano < 0) then
    Dano := 1;
end;

procedure TBaseMob.AttackParseForMobs(Skill, Anim: DWORD; mob: PBaseMob;
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

  if Dano > 0 then
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
        Dano := Dano - Help1;
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
        Dano := Dano - Help1;
        mob.RemoveBuffByIndex(142);
      end;
    end;

    if mob.BuffExistsByIndex(101) then
    begin
      Help1 := (Dano div 100) * mob.GetMobAbility(EF_HP_CONVERSION);
      mob.RemoveMP(Help1 * (mob.GetMobAbility(EF_MP_EFFICIENCY) div 100), True);
      if DWORD(Help1) >= mob.Character.CurrentScore.CurMP then
        mob.RemoveBuffByIndex(101);
      Dano := Dano - Help1;
    end;

    if mob.BuffExistsByIndex(32) then
    begin
      Dano := Dano - (Dano div 100) * mob.GetMobAbility(EF_POINT_DEFENCE);
      dec(mob.DefesaPoints, 1);
      if mob.DefesaPoints = 0 then
        mob.RemoveBuffByIndex(32);
    end;

    if mob.BuffExistsByIndex(35) and (Trim(mob.UniaoDivina) <> '') then
    begin
      Helper := Dano;

      Dano := Dano - (Dano div 100) * mob.GetMobAbility(EF_TRANSFER);
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
        dec(mob.ResolutoPoints, 1);
        MobAnimation := 26;
        mob.TargetBuffSkill(6879, 0, mob, @SkillData[6879]);
      end;
    end;
  end;

  case Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobType - 1024 of
    0 .. 7:
      begin
        case Servers[Self.ChannelId].MOBS.TMobS[Self.Mobid].MobType - 1024 of
          0:
            Help1 := EF_DEF_ALIEN;
          1:
            Help1 := EF_DEF_BEAST;
          2:
            Help1 := EF_DEF_PLANT;
          3:
            Help1 := EF_DEF_INSECT;
          4:
            Help1 := EF_DEF_DEMON;
          5:
            Help1 := EF_DEF_UNDEAD;
          6:
            Help1 := EF_DEF_COMPLEX;
          7:
            Help1 := EF_DEF_STRUCTURE;
        end;
        if mob.GetMobAbility(Help1) > 0 then
          Dano := (Dano - Round((Dano / 100) * mob.GetMobAbility(Help1)));
      end;
  end;

  if Dano < 0 then
    Dano := 1;
end;

procedure TBaseMob.Effect5Skill(mob: PBaseMob; EffCount: Byte;
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

    if Servers[Self.ChannelId].Players[Self.ClientID].InDungeon then
    begin

      // if Packet.Dano >= DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP then
      // begin
      // mob.IsDead := True;
      // DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP := 0;
      // DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].IsAttacked := False;
      // DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].AttackerID := 0;
      // DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].deadTime := Now;
      // if Self.VisibleMobs.Contains(mob.ClientID) then
      // Self.VisibleMobs.Remove(mob.ClientID);
      // Self.MobKilledInDungeon(mob);
      // Packet.MobAnimation := 30;
      // end
      // else
      // DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP := DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].Mobs[mob.Mobid].CurrentHP - Packet.Dano;
      //

      if Packet.Dano >= DungeonInstances
        [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].MOBS
        [mob.Mobid].CurrentHP then
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
        if Self.VisibleMobs.Contains(mob.ClientID) then
          Self.VisibleMobs.Remove(mob.ClientID);
        Self.MobKilledInDungeon(mob);
        Packet.MobAnimation := 30;
      end
      else
        DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP :=
          DungeonInstances[Servers[Self.ChannelId].Players[Self.ClientID]
          .DungeonInstanceID].MOBS[mob.Mobid].CurrentHP - dword(Packet.DANO);

      // mob.LastReceivedAttack := Now;
      Packet.MobCurrHP := DungeonInstances
        [Servers[Self.ChannelId].Players[Self.ClientID].DungeonInstanceID].MOBS
        [mob.Mobid].CurrentHP;
      Packet.TargetID := mob.ClientID;
      Self.SendToVisible(Packet, Packet.Header.size, True);
      Exit;
    end;

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

function TBaseMob.IsSecureArea(): Boolean;
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

procedure TBaseMob.WarriorSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  case SkillData[Skill].Index of
    ATAQUE_PODEROSO:
      Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);

    AVANCO_PODEROSO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType, STUN_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;

        if Servers[Self.ChannelId].Players[Self.ClientID].InDungeon then
        begin
          Self.WalkAvanced(DungeonInstances[Servers[Self.ChannelId].Players
            [Self.ClientID].DungeonInstanceID].MOBS[mob.Mobid].Position, Skill);
          Exit;
        end;

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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType) then
          CanDebuff := True;
      end;

    RESOLUTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType, SILENCE_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    PANCADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType, 0) then
          Inc(Dano, (Self.Character.CurrentScore.CurHP div 100) *
            SkillData[Skill].Adicional);
      end;
  end;
end;

procedure TBaseMob.TemplarSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);

  case SkillData[Skill].Index of
    STIGMA, NEMESIS, TRAVAR_ALVO:
      if Self.ValidAttack(DmgType) then
        CanDebuff := True;

    PROFICIENCIA:
      if Self.ValidAttack(DmgType, STUN_TYPE, mob) then
      begin
        CanDebuff := True;
        if mob.ClientID <= 1000 then
          Servers[Self.ChannelId].Players[mob.ClientID]
            .Base.SendEffectOther($22, 1);
      end
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

procedure TBaseMob.RiflemanSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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

procedure TBaseMob.DualGunnerSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
var
  Helper: Int64;
begin
  case SkillData[Skill].Index of
    MJOLNIR, TIRO_DESCONTROLADO, VENENO_LENTIDAO, ESTRIPADOR, DOR_PREDADOR,
      BOMBA_MALDITA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);

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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType)) then
        begin
          // a cada debuff = Dano + (Adicional * qnt de debuff)
        end;
      end;
  end;
end;

procedure TBaseMob.MagicianSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  case SkillData[Skill].Index of
    CHAMA_CAOTICA, INFERNO_CAOTICO, IMPEDIMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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
        Self.GetDamage(Skill, mob, DmgType, Tipo);
        DmgType := Self.GetDamageType3(Skill, false, mob);
        if (Self.ValidAttack(DmgType, 0, mob, 0, True)) then
        begin
          CanDebuff := True;
        end;
      end;

    ONDA_CHOQUE, LANCA_RAIO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType)) then
        begin
          CanDebuff := True;
        end;
      end;

    CORROER:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType)) then
        begin
          Inc(Self.Character.CurrentScore.CurHP,
            (Dano div 100) * SkillData[Skill].Adicional);
          Self.SendCurrentHPMP(True);
        end;
      end;

    VINCULO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType)) then
        begin
          Self.RemoveHP((Dano div 100) * SkillData[Skill].Adicional, True);
        end;
      end;

    CRISTALIZAR_MANA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType)) then
        begin
          Inc(Dano, (Self.Character.CurrentScore.CurMP div 100) *
            SkillData[Skill].Adicional);
        end;
        Dano := Dano * 3;
      end;
  end;
end;

procedure TBaseMob.ClericSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  case SkillData[Skill].Index of
    FLECHA_SAGRADA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType) then
          Inc(Dano, (Dano div 100) * SkillData[Skill].Adicional);
      end;

    RETORNO_MAGICA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType) then
        begin
          Inc(Dano, SkillData[Skill].Adicional);
          mob.RemoveBuffs(SkillData[Skill].Damage);
        end;
      end;
  end;
end;

procedure TBaseMob.WarriorAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; out MoveToTarget: Boolean; Tipo: Byte);
begin
  case SkillData[Skill].Index of
    TEMPESTADE_LAMINA, SALTO_IMPACTO, LAMINA_CARREGADA, PODER_ABSOLUTO,
      POSTURA_FINAL:
      Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);

    AREA_IMPACTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType, LENT_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    CANCAO_GUERRA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType, STUN_TYPE, mob) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    GRITO_MEDO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, mob, DmgType, Tipo);

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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);

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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if Self.ValidAttack(DmgType) then
          CanDebuff := True;
      end;
  end;
end;

procedure TBaseMob.TemplarAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  case SkillData[Skill].Index of
    INCITAR_MULTIDAO:
      begin
        Dano := 0;
        Self.GetDamage(Skill, mob, DmgType, Tipo);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType, SILENCE_TYPE, mob)) then
          CanDebuff := True
        else
          Resisted := True;
      end;

    LAMINA_PROMESSA:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
      end;

    SANTUARIO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True;
      end;

    CRUZ_JULGAMENTO:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
      end;

    ESCUDO_VINGADOR:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
      end;
  end;
end;

procedure TBaseMob.RiflemanAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  // Calcula o dano uma única vez
  Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);

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

procedure TBaseMob.DualGunnerAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
  // A única chamada para GetDamage

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

procedure TBaseMob.MagicianAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
begin
  Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
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

procedure TBaseMob.ClericAreaSkill(Skill, Anim: DWORD; mob: PBaseMob;
  out Dano: Integer; out DmgType: TDamageType; var CanDebuff: Boolean;
  var Resisted: Boolean; Tipo: Byte);
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
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
      end;
    CRUZ_PENITENCIAL, EDEN_PIEDOSO, DIXIT:
      begin
        Dano := Self.GetDamage(Skill, mob, DmgType, Tipo);
        if (Self.ValidAttack(DmgType)) then
          CanDebuff := True;
      end;
  end;
end;

{$ENDREGION}
{$REGION 'Effect Functions'}

procedure TBaseMob.SendEffect(EffectIndex: DWORD);
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

procedure TBaseMob.SendEffectOther(Tipo: Integer; loop: cardinal);
var
  PacketAct: TSendActionPacket;
begin

  ZeroMemory(@PacketAct, SizeOf(PacketAct));
  PacketAct.Header.size := SizeOf(PacketAct);
  PacketAct.Header.Index := Self.ClientID;
  PacketAct.Header.Code := $304;

  Self.CurrentAction := Tipo;
  PacketAct.Index := Tipo;
  PacketAct.InLoop := loop;
  Self.SendToVisible(PacketAct, PacketAct.Header.size, True);

end;

{$ENDREGION}
{$REGION 'Move/Teleport'}

procedure TBaseMob.Teleport(Pos: TPosition);
begin
  if not(Pos.IsValid) then
    Exit;
  Self.PlayerCharacter.LastPos := Pos;
  Self.SendCreateMob;
  // Self.UpdateVisibleList;
end;

procedure TBaseMob.Teleport(Posx, Posy: WORD);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;

procedure TBaseMob.Teleport(Posx, Posy: string);
begin
  Self.Teleport(TPosition.Create(Posx.ToSingle, Posy.ToSingle));
end;

procedure TBaseMob.WalkTo(Pos: TPosition; speed: WORD; MoveType: Byte);
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
  // Writeln('passando pela funcao WalkTo no BaseMob');
end;

procedure TBaseMob.WalkAvanced(Pos: TPosition; SkillID: Integer);
var
  Packet: TMovementPacket;
begin
  if not(Pos.IsValid) or (Self.PlayerCharacter.LastPos.Distance(Pos) > 18) then
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
  WriteLn('passando pela funcao WalkAvanced no BaseMob');
end;

procedure TBaseMob.WalkBacked(Pos: TPosition; SkillID: Integer; mob: PBaseMob);
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
  WriteLn('passando pela funcao WalkBacked no BaseMob');
end;

{$ENDREGION}
{$REGION 'Pets'}
// procedure TBaseMob.CreatePet(PetType: TPetType; Pos: TPosition; SkillID: DWORD);
// var
// pId: Integer;
// pet: TPet;
// begin
// Exit;
// pId := TFunctions.FreePetId(Self.ChannelId);
/// /  pet := Servers[Self.ChannelId].PETS[pId];
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
// end;

// procedure TBaseMob.DestroyPet(PetID: WORD);
// var
// i: Integer;
// begin
/// /  Servers[Self.ChannelId].Players[Self.ClientID].UnSpawnPet(PetID);
/// /  for i in Self.VisiblePlayers do
/// /    Servers[Self.ChannelId].Players[i].UnSpawnPet(PetID);
/// /
/// /  ZeroMemory(@Servers[Self.ChannelId].PETS[PetID], sizeof(TPet));
// end;

{$ENDREGION}
{$REGION 'TPrediction'}
// procedure TPrediction.Create;
// begin
// Timer := TStopwatch.Create;
// end;
//
// function TPrediction.Delta: Single;
// begin
// if ETA > 0 then
// Result := Elapsed / ETA
// else
// Result := 1;
// end;
//
// function TPrediction.Elapsed: Integer;
// begin
// Result := Timer.ElapsedTicks;
// end;
//
// function TPrediction.CanPredict: Boolean;
// begin
// Result := (ETA > 0) and Source.IsValid and Destination.IsValid;
// end;
//
// function TPrediction.Interpolate(out d: Single): TPosition;
// begin
// d := Delta;
// if d >= 1 then
// begin
// ETA := 0;
// Result := Destination;
// end
// else
// Result := TPosition.Lerp(Source, Destination, d);
// end;
//
// procedure TPrediction.CalcETA(speed: Byte);
// begin
// ETA := AI_DELAY_MOVIMENTO + (Source.Distance(Destination) * (1000 - speed * 190));
// end;
{$ENDREGION}

end.
