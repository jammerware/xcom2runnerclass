class X2Ability_FieldReloadArray extends X2Ability;

var name NAME_ABILITY;
var name NAME_SPIRE_ABILITY;
var string ICON;

public static function X2DataTemplate CreateFieldReloadArray()
{
    return PurePassive(default.NAME_ABILITY, default.ICON);
}

public static function X2DataTemplate CreateSpireFieldReloadArray()
{
    local X2AbilityTemplate Template;
    local X2AbilityTrigger_EventListener SpireSpawnTrigger;
	local X2Condition_TargetWeapon WeaponCondition;
	
	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_SPIRE_ABILITY);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = default.ICON;
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_NeverShow;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_CORPORAL_PRIORITY;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityMultiTargetStyle = new class'X2AbilityMultiTargetStyle_PBAoE';

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// triggering
	SpireSpawnTrigger = new class'X2AbilityTrigger_EventListener';
	SpireSpawnTrigger.ListenerData.Deferral = ELD_OnStateSubmitted;
	SpireSpawnTrigger.ListenerData.EventID = class'X2Effect_SpawnSpire'.default.NAME_SPAWN_SPIRE_TRIGGER;
	SpireSpawnTrigger.ListenerData.EventFn = class'XComGameState_Ability'.static.AbilityTriggerEventListener_SelfWithAdditionalTargets;
	Template.AbilityTriggers.AddItem(SpireSpawnTrigger);

	// conditions
	WeaponCondition = new class'X2Condition_TargetWeapon';
	WeaponCondition.CanReload = true;
	Template.AbilityMultiTargetConditions.AddItem(WeaponCondition);

	// effects
	Template.AddMultiTargetEffect(new class'X2Effect_FieldReload');
	
	// game state and visualization
	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	Template.BuildVisualizationFn = TypicalAbility_BuildVisualization;
	Template.bShowActivation = true;
	Template.bSkipFireAction = true;

	return Template;
}

DefaultProperties
{
    ICON="img:///UILibrary_PerkIcons.UIPerk_reload"
    NAME_ABILITY=Jammerware_JSRC_Ability_FieldReloadModule
    NAME_SPIRE_ABILITY=Jammerware_JSRC_Ability_SpireFieldReloadModule
}