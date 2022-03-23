/// Rune class, with static variables so one can reference runes by name.
class Rune {
  //Precision
  static const int _Precision = 8000;

  static const int PressTheAttack = 8005;
  static const int LethalTempo = 8008;
  static const int FleetFootwork = 8021;
  static const int Conqueror = 8010;

  static const int Overheal = 9101;
  static const int Triumph = 9111;
  static const int PresenceOfMind = 8009;

  static const int LegendAlacrity = 9104;
  static const int LegendTenacity = 9105;
  static const int LegendBloodline = 9103;

  static const int CoupDeGrace = 8014;
  static const int CutDown = 8017;
  static const int LastStand = 8299;

  //Domination
  static const int _Domination = 8100;

  static const int Electrocute = 8112;
  static const int Predator = 8124;
  static const int DarkHarvest = 8128;
  static const int HailOfBlades = 9923;

  static const int CheapShot = 8126;
  static const int TasteOfBlood = 8139;
  static const int SuddenImpact = 8143;

  static const int ZombieWard = 8136;
  static const int GhostPoro = 8120;
  static const int EyeballCollection = 8138;

  static const int RavenousHunter = 8135;
  static const int IngeniousHunter = 8134;
  static const int RelentlessHunter = 8105;
  static const int UltimateHunter = 8106;

  //Sorcery
  static const int _Sorcery = 8200;

  static const int SummonAery = 8214;
  static const int ArcaneComet = 8229;
  static const int PhaseRush = 8230;

  static const int NullifyingOrb = 8224;
  static const int ManaflowBand = 8226;
  static const int NimbusCloak = 8275;

  static const int Transcendence = 8210;
  static const int Celerity = 8234;
  static const int AbsoluteFocus = 8233;

  static const int Scorch = 8237;
  static const int Waterwalking = 8232;
  static const int GatheringStorm = 8236;

  //Resolve
  static const int _Resolve = 8400;

  static const int GraspOfTheUndying = 8437;
  static const int Aftershock = 8439;
  static const int Guardian = 8465;

  static const int Demolish = 8446;
  static const int FontOfLife = 8463;
  static const int ShieldBash = 8401;

  static const int Conditioning = 8429;
  static const int SecondWind = 8444;
  static const int BonePlating = 8473;

  static const int Overgrowth = 8451;
  static const int Revitalize = 8453;
  static const int Unflinching = 8242;

  //Inspiration
  static const int _Inspiration = 8300;

  static const int GlacialAugment = 8351;
  static const int UnsealedSpellbook = 8360;
  static const int FirstStrike = 8369;

  static const int HextechFlashtraption = 8306;
  static const int MagicalFootwear = 8304;
  static const int PerfectTiming = 8313;

  static const int FuturesMarket = 8321;
  static const int MinionDematerializer = 8316;
  static const int BiscuitDelivery = 8345;

  static const int CosmicInsight = 8347;
  static const int ApproachVelocity = 8410;
  static const int TimeWarpTonic = 8352;

  static const List<int> _PrecisionList = [
    PressTheAttack,
    LethalTempo,
    FleetFootwork,
    Conqueror,
    Overheal,
    Triumph,
    PresenceOfMind,
    LegendAlacrity,
    LegendTenacity,
    LegendBloodline,
    CoupDeGrace,
    CutDown,
    LastStand
  ];

  static const List<int> _DominationList = [
    Electrocute,
    Predator,
    DarkHarvest,
    HailOfBlades,
    CheapShot,
    TasteOfBlood,
    SuddenImpact,
    ZombieWard,
    GhostPoro,
    EyeballCollection,
    RavenousHunter,
    IngeniousHunter,
    RelentlessHunter,
    UltimateHunter
  ];

  static const List<int> _SorceryList = [
    SummonAery,
    ArcaneComet,
    PhaseRush,
    NullifyingOrb,
    ManaflowBand,
    NimbusCloak,
    Transcendence,
    Celerity,
    AbsoluteFocus,
    Scorch,
    Waterwalking,
    GatheringStorm
  ];

  static const List<int> _ResolveList = [
    GraspOfTheUndying,
    Aftershock,
    Guardian,
    Demolish,
    FontOfLife,
    ShieldBash,
    Conditioning,
    SecondWind,
    BonePlating,
    Overgrowth,
    Revitalize,
    Unflinching
  ];

  static const List<int> _InspirationList = [
    GlacialAugment,
    UnsealedSpellbook,
    FirstStrike,
    HextechFlashtraption,
    MagicalFootwear,
    PerfectTiming,
    FuturesMarket,
    MinionDematerializer,
    BiscuitDelivery,
    CosmicInsight,
    ApproachVelocity,
    TimeWarpTonic
  ];

  static const List<int> _Keystones = [
    PressTheAttack,
    LethalTempo,
    FleetFootwork,
    Conqueror,
    Electrocute,
    Predator,
    DarkHarvest,
    HailOfBlades,
    SummonAery,
    ArcaneComet,
    PhaseRush,
    GraspOfTheUndying,
    Aftershock,
    Guardian,
    GlacialAugment,
    UnsealedSpellbook,
    FirstStrike
  ];

  static const List<int> _MinorTier1 = [
    Overheal,
    Triumph,
    PresenceOfMind,
    CheapShot,
    TasteOfBlood,
    SuddenImpact,
    NullifyingOrb,
    ManaflowBand,
    NimbusCloak,
    Demolish,
    FontOfLife,
    ShieldBash,
    HextechFlashtraption,
    MagicalFootwear,
    PerfectTiming
  ];
  static const List<int> _MinorTier2 = [
    LegendAlacrity,
    LegendTenacity,
    LegendBloodline,
    ZombieWard,
    GhostPoro,
    EyeballCollection,
    Transcendence,
    Celerity,
    AbsoluteFocus,
    Conditioning,
    SecondWind,
    BonePlating,
    FuturesMarket,
    MinionDematerializer,
    BiscuitDelivery
  ];
  static const List<int> _MinorTier3 = [
    CoupDeGrace,
    CutDown,
    LastStand,
    RavenousHunter,
    IngeniousHunter,
    RelentlessHunter,
    UltimateHunter,
    Scorch,
    Waterwalking,
    GatheringStorm,
    Overgrowth,
    Revitalize,
    Unflinching,
    CosmicInsight,
    ApproachVelocity,
    TimeWarpTonic
  ];

  static const int HealthPerk = 5001;
  static const int AbilityHastePerk = 5007;
  static const int AttackSpeedPerk = 5005;
  static const int MagicResistPerk = 5003;
  static const int ArmorPerk = 5002;
  static const int AdaptiveForcePerk = 5008;

  static const List<List<int>> _PerkTiers = [
    [AdaptiveForcePerk, AttackSpeedPerk, AbilityHastePerk],
    [AdaptiveForcePerk, ArmorPerk, MagicResistPerk],
    [HealthPerk, ArmorPerk, MagicResistPerk]
  ];

  /// Validates a candidate page layout to make sure it's an allowed configuration.
  static bool validate(int keystone, int primary1, int primary2, int primary3,
      int secondary1, int secondary2, int perk1, int perk2, int perk3) {
    int primaryTree = Rune.treeId(keystone);
    int secondaryTree = Rune.treeId(secondary1);
    if (Rune.treeId(primary1) != primaryTree ||
        Rune.treeId(primary2) != primaryTree ||
        Rune.treeId(primary3) != primaryTree) return false;

    if (Rune.treeId(secondary2) != secondaryTree) return false;

    if (primaryTree == secondaryTree) return false;

    if (Rune.runeTier(keystone) != 0 ||
        Rune.runeTier(primary1) != 1 ||
        Rune.runeTier(primary2) != 2 ||
        Rune.runeTier(primary3) != 3) return false;

    if (Rune.runeTier(secondary1) >= Rune.runeTier(secondary2)) return false;

    if (!(Rune.perkTierValidate(perk1, 0) &&
        Rune.perkTierValidate(perk2, 1) &&
        Rune.perkTierValidate(perk3, 2))) return false;

    return true;
  }

  /// Gets the tier of a rune. Keystone: 0, rows of minor runes 1-3. Returns -1 on error.
  static int runeTier(int rune) {
    if (Rune._Keystones.contains(rune)) return 0;
    if (Rune._MinorTier1.contains(rune)) return 1;
    if (Rune._MinorTier2.contains(rune)) return 2;
    if (Rune._MinorTier3.contains(rune))
      return 3;
    else
      return -1;
  }

  /// Validates the minor perks. True on valid perk for the row, false on invalid.
  static bool perkTierValidate(int perk, int tier) {
    if (Rune._PerkTiers[tier].contains(perk))
      return true;
    else
      return false;
  }

  /// Returns the numeric ID of the tree for a given rune. Eg Taste Of Blood -> id of Domination tree.
  static int treeId(int rune) {
    if (Rune._PrecisionList.contains(rune))
      return Rune._Precision;
    else if (Rune._DominationList.contains(rune))
      return Rune._Domination;
    else if (Rune._SorceryList.contains(rune))
      return Rune._Sorcery;
    else if (Rune._ResolveList.contains(rune))
      return Rune._Resolve;
    else if (Rune._InspirationList.contains(rune))
      return Rune._Inspiration;
    else
      return -1;
  }
}
