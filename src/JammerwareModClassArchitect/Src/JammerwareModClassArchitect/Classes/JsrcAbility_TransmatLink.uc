class JsrcAbility_TransmatLink extends X2Ability
	config(JammerwareModClassArchitect);

var name NAME_ABILITY;
var config int COOLDOWN_TRANSMAT_LINK;

public static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	Templates.AddItem(CreateTransmatLink());
	return Templates;
}

private static function X2DataTemplate CreateTransmatLink()
{
    local X2AbilityTemplate Template;
	local X2AbilityCooldown Cooldown;

	// general properties
	`CREATE_X2ABILITY_TEMPLATE(Template, default.NAME_ABILITY);
	Template.Hostility = eHostility_Neutral;

	// hud behavior
	Template.IconImage = "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_Exchange";
	Template.AbilitySourceName = 'eAbilitySource_Perk';
	Template.eAbilityIconBehaviorHUD = eAbilityIconBehavior_AlwaysShow;
	Template.bDisplayInUITacticalText = false;
	Template.ShotHUDPriority = class'UIUtilities_Tactical'.const.CLASS_MAJOR_PRIORITY;
	Template.bLimitTargetIcons = true;

	// cost
	Template.AbilityCosts.AddItem(default.FreeActionCost);
	
	// Cooldown
	Cooldown = new class'X2AbilityCooldown';
	Cooldown.iNumTurns = default.COOLDOWN_TRANSMAT_LINK;
	Template.AbilityCooldown = Cooldown;

	// targeting style (how targets are determined by game rules)
	Template.AbilityTargetStyle = default.SimpleSingleTarget;

	// hit chance
	Template.AbilityToHitCalc = default.DeadEye;

	// conditions
	Template.AbilityShooterConditions.AddItem(default.LivingShooterProperty);

	Template.AbilityTargetConditions.AddItem(default.GameplayVisibilityCondition);
	Template.AbilityTargetconditions.AddItem(new class'X2Condition_OwnedSpire');
	
	// triggering
	Template.AbilityTriggers.AddItem(default.PlayerInputTrigger);
	
	// game state and visualization
	Template.CinescriptCameraType = "Templar_Invert";
	Template.BuildNewGameStateFn = TransmatLink_BuildGameState;
	Template.BuildVisualizationFn = TransmatLink_BuildVisualization;
	Template.bShowActivation = true;

	return Template;
}

static simulated function XComGameState TransmatLink_BuildGameState(XComGameStateContext Context)
{
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState	NewGameState;
	local XComGameState_Unit ShooterUnit, TargetUnit;
	local XComGameState_Ability AbilityState;
	local XComGameState_Item WeaponState;
	local X2EventManager EventManager;
	local TTile ShooterDesiredLoc;
	local TTile TargetDesiredLoc;
	local XComWorldData WorldData;

	WorldData = `XWORLD;

	NewGameState = `XCOMHISTORY.CreateNewGameState(true, Context);
	AbilityContext = XComGameStateContext_Ability(NewGameState.GetContext());

	ShooterUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.SourceObject.ObjectID));
	TargetUnit = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', AbilityContext.InputContext.PrimaryTarget.ObjectID));
	AbilityState = XComGameState_Ability(NewGameState.ModifyStateObject(class'XComGameState_Ability', AbilityContext.InputContext.AbilityRef.ObjectID));
	if (AbilityContext.InputContext.ItemObject.ObjectID > 0)
	{
		WeaponState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', AbilityContext.InputContext.ItemObject.ObjectID));
	}

	ShooterDesiredLoc = TargetUnit.TileLocation;
	TargetDesiredLoc = ShooterUnit.TileLocation;

	ShooterDesiredLoc.Z = WorldData.GetFloorTileZ(ShooterDesiredLoc, true);
	TargetDesiredLoc.Z = WorldData.GetFloorTileZ(TargetDesiredLoc, true);

	ShooterUnit.SetVisibilityLocation(ShooterDesiredLoc);
	TargetUnit.SetVisibilityLocation(TargetDesiredLoc);

	EventManager = `XEVENTMGR;
	EventManager.TriggerEvent('ObjectMoved', ShooterUnit, ShooterUnit, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', ShooterUnit, ShooterUnit, NewGameState);
	EventManager.TriggerEvent('ObjectMoved', TargetUnit, TargetUnit, NewGameState);
	EventManager.TriggerEvent('UnitMoveFinished', TargetUnit, TargetUnit, NewGameState);
	
	AbilityState.GetMyTemplate().ApplyCost(AbilityContext, AbilityState, ShooterUnit, WeaponState, NewGameState);

	return NewGameState;
}

simulated function TransmatLink_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability Context;
	local VisualizationActionMetadata SourceTrack, TargetTrack;
    local XComGameState_Unit SourceUnit, TargetUnit;
	local X2Action_Delay DelayAction;

	History = `XCOMHISTORY;
	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());

    SourceUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.SourceObject.ObjectID));
    TargetUnit = XComGameState_Unit(VisualizeGameState.GetGameStateForObjectID(Context.InputContext.PrimaryTarget.ObjectID));

	// set up the tracks
	SourceTrack.StateObject_OldState = History.GetGameStateForObjectID(SourceUnit.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	SourceTrack.StateObject_NewState = SourceUnit;
	SourceTrack.VisualizeActor = History.GetVisualizer(SourceUnit.ObjectID);

	TargetTrack.StateObject_OldState = History.GetGameStateForObjectID(TargetUnit.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	TargetTrack.StateObject_NewState = TargetUnit;
	TargetTrack.VisualizeActor = History.GetVisualizer(TargetUnit.ObjectID);

    // Build the tracks
	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(SourceTrack, Context);
	class'X2Action_SyncVisualizer'.static.AddToVisualizationTree(TargetTrack, Context, false, SourceTrack.LastActionAdded);
	class'X2Action_AbilityPerkStart'.static.AddToVisualizationTree(SourceTrack, Context);
	DelayAction = X2Action_Delay(class'X2Action_Delay'.static.AddToVisualizationTree(SourceTrack, Context));
	DelayAction.Duration = 5;
	class'X2Action_AbilityPerkEnd'.static.AddToVisualizationTree(SourceTrack, Context);
}

DefaultProperties
{
    NAME_ABILITY=Jammerware_JSRC_Ability_TransmatLink;
}