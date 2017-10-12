class X2Ability_RunnerAbilitySet extends X2Ability
	config(JammerwareRunnerClass);

var config int CREATESPIRE_COOLDOWN;

// ability names
var name NAME_CREATE_SPIRE;
var name NAME_LIGHTNINGROD;
var name NAME_QUICKSILVER;
var name NAME_RECLAIM;
var name NAME_SHELTER;
var name NAME_SOUL_OF_THE_ARCHITECT;

// ability numbers
var float RANGE_SHELTER_SHIELD;

static function array <X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.Length = 0;

	// SQUADDIE!
	Templates.AddItem(AddCreateSpire());
	
	// CORPORAL!
	Templates.AddItem(AddLightningRod());
	Templates.AddItem(AddShelter());
	Templates.AddItem(AddQuicksilver());

	// SERGEANT!
	Templates.AddItem(AddReclaim());

	// COLONEL!
	Templates.AddItem(AddSoulOfTheArchitect());

	return Templates;
}

static function X2AbilityTemplate AddCreateSpire()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2AbilityTarget_Cursor CursorTarget;
	local X2Effect_SpawnSpire SpawnSpireEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_CREATE_SPIRE);

	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;

	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SQUADDIE_PRIORITY;

	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.CREATESPIRE_COOLDOWN;
	Template.AbilityCooldown = Cooldown;

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);
	Template.AddShooterEffectExclusions();

	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);

	CursorTarget = new class'X2AbilityTarget_Cursor';
	Template.AbilityTargetStyle = CursorTarget;
	Template.TargetingMethod = class'X2TargetingMethod_Teleport';

	SpawnSpireEffect = new class'X2Effect_SpawnSpire';
	SpawnSpireEffect.BuildPersistentEffect(1, true);
	Template.AddShooterEffect(SpawnSpireEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = SpawnSpire_BuildVisualization;

	Template.ChosenActivationIncreasePerUse = class'X2AbilityTemplateManager'.default.NonAggressiveChosenActivationIncreasePerUse;
		
	return Template;
}

simulated function SpawnSpire_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata SourceTrack, SpireTrack;
	local XComGameState_Unit SpireSourceUnit, SpawnedUnit;
	local UnitValue SpawnedUnitValue;
	local X2Effect_SpawnSpire SpawnSpireEffect;
	local X2Action_MimicBeaconThrow FireAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	SourceTrack = EmptyTrack;
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	SourceTrack.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	class'X2Action_ExitCover'.static.AddToVisualizationTree(SourceTrack, Context);
	FireAction = X2Action_MimicBeaconThrow(class'X2Action_MimicBeaconThrow'.static.AddToVisualizationTree(SourceTrack, Context));
	class'X2Action_EnterCover'.static.AddToVisualizationTree(SourceTrack, Context);

	// Configure the visualization track for the spire
	//******************************************************************************************
	SpireSourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID));
	`assert(SpireSourceUnit != none);
	SpireSourceUnit.GetUnitValue(class'X2Effect_SpawnUnit'.default.SpawnedUnitValueName, SpawnedUnitValue);

	SpireTrack = EmptyTrack;
	SpireTrack.StateObject_OldState = History.GetGameStateForObjectID(SpawnedUnitValue.fValue, eReturnType_Reference, VisualizeGameState.HistoryIndex);
	SpireTrack.StateObject_NewState = SpireTrack.StateObject_OldState;
	SpawnedUnit = XComGameState_Unit(SpireTrack.StateObject_NewState);
	`assert(SpawnedUnit != none);
	SpireTrack.VisualizeActor = History.GetVisualizer(SpawnedUnit.ObjectID);

	// Set the Throwing Unit's FireAction to reference the spawned unit
	FireAction.MimicBeaconUnitReference = SpawnedUnit.GetReference();
	// Set the Throwing Unit's FireAction to reference the spawned unit
	class'X2Action_WaitForAbilityEffect'.static.AddToVisualizationTree(SpireTrack, Context);

	// Only one target effect and it is X2Effect_SpawnSpire
	SpawnSpireEffect = X2Effect_SpawnSpire(Context.ResultContext.ShooterEffectResults.Effects[0]);
	
	if (SpawnSpireEffect == none)
	{
		`RedScreen("JSRC: Spire_BuildVisualization: Missing X2Effect_SpawnSpire");
		return;
	}

	SpawnSpireEffect.AddSpawnVisualizationsToTracks(Context, SpawnedUnit, SpireTrack, SpireSourceUnit, SourceTrack);
	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(SpireTrack, Context);
}

static function X2AbilityTemplate AddLightningRod()
{
	return PurePassive(default.NAME_LIGHTNINGROD, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_volt");
}

static function X2AbilityTemplate AddShelter()
{
	return PurePassive(default.NAME_SHELTER, "img:///UILibrary_PerkIcons.UIPerk_adventshieldbearer_energyshield");
}

static function X2AbilityTemplate AddQuicksilver()
{
	return PurePassive(default.NAME_QUICKSILVER, "img:///UILibrary_PerkIcons.UIPerk_runandgun");
}

static function X2AbilityTemplate AddReclaim()
{
	local X2AbilityTemplate Template;
	local X2AbilityCost_ActionPoints ActionPointCost;
	local X2AbilityCooldown Cooldown;
	local X2Condition_UnitProperty RangeCondition;
	local X2Condition_UnitType UnitTypeCondition;
	local X2Effect_KillUnit KillSpireEffect;
	local X2Effect_GrantActionPoints GrantAPEffect;
	local X2Effect_ReduceCooldowns CreateSpireCooldownResetEffect;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_RECLAIM);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.str_holotargeting";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_SERGEANT_PRIORITY;
	Template.bLimitTargetIcons = true;

	// cost
	ActionPointCost = new class'X2AbilityCost_ActionPoints';
	ActionPointCost.iNumPoints = 1;
	ActionPointCost.bConsumeAllPoints = false;
	Template.AbilityCosts.AddItem(ActionPointCost);

	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = 5;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	UnitTypeCondition = new class'X2Condition_UnitType';
	UnitTypeCondition.IncludeTypes.AddItem(class'X2Character_Spire'.default.NAME_CHARACTERGROUP_SPIRE);
	Template.AbilityTargetConditions.AddItem(UnitTypeCondition);

	RangeCondition = new class'X2Condition_UnitProperty';
	RangeCondition.ExcludeFriendlyToSource = false;
	RangeCondition.RequireWithinRange = true;
	RangeCondition.WithinRange = `METERSTOUNITS(class'XComWorldData'.const.WORLD_Melee_Range_Meters);
	Template.AbilityTargetConditions.AddItem(RangeCondition);

	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// effects
	KillSpireEffect = new class'X2Effect_KillUnit';
	Template.AddTargetEffect(KillSpireEffect);

	GrantAPEffect = new class'X2Effect_GrantActionPoints';
	GrantAPEffect.NumActionPoints = 1;
	GrantAPEffect.PointType = class'X2CharacterTemplateManager'.default.StandardActionPoint;
	GrantAPEffect.bSelectUnit = true;
	Template.AddShooterEffect(GrantAPEffect);

	CreateSpireCooldownResetEffect = new class 'X2Effect_ReduceCooldowns';
	CreateSpireCooldownResetEffect.ReduceAll = true;
	CreateSpireCooldownResetEffect.AbilitiesToTick.AddItem(default.NAME_CREATE_SPIRE);
	Template.AddShooterEffect(CreateSpireCooldownResetEffect);
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

static function X2AbilityTemplate AddSoulOfTheArchitect()
{
	local X2AbilityTemplate Template;

	Template = PurePassive(default.NAME_SOUL_OF_THE_ARCHITECT, "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Pillar");
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_LIGHTNINGROD);
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_SHELTER);
	Template.AdditionalAbilities.AddItem(class'X2Ability_SpireAbilitySet'.default.NAME_SPIRE_QUICKSILVER);

	return Template;
}

// these are the abilities that are granted to the spire if the runner has them
static function array<name> GetSpireSharedAbilities()
{
	local array<name> SpireAbilities;

	SpireAbilities.AddItem(default.NAME_SHELTER);

	return SpireAbilities;
}

defaultproperties 
{
	NAME_CREATE_SPIRE=Jammerware_JSRC_Ability_CreateSpire
	NAME_LIGHTNINGROD=Jammerware_JSRC_Ability_LightningRod
	NAME_QUICKSILVER=Jammerware_JSRC_Ability_Quicksilver
	NAME_RECLAIM=Jammerware_JSRC_Ability_Reclaim
	NAME_SHELTER=Jammerware_JSRC_Ability_Shelter
	NAME_SOUL_OF_THE_ARCHITECT=Jammerware_JSRC_Ability_SoulOfTheArchitect
}