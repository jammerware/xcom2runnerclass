class X2Character_Spire extends X2Character config(JammerwareRunnerClass);

var name NAME_CHARACTER_SPIRE;

static function array<X2DataTemplate> CreateTemplates()
{
    local array<X2DataTemplate> Templates;

    Templates.AddItem(CreateSpire());

    return Templates;
}

static function X2CharacterTemplate CreateSpire()
{
    local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, default.NAME_CHARACTER_SPIRE);
	CharTemplate.BehaviorClass = class'XGAIBehavior';
    CharTemplate.strPawnArchetypes.AddItem("GameUnit_LostTowersTurret.ARC_GameUnit_LostTowersTurretM1");
	CharTemplate.DefaultLoadout='Jammerware_JSRC_Loadout_Spire_Conventional';

	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = false;
	CharTemplate.bCanTakeCover = false;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = false;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = true;
	CharTemplate.bIsSoldier = false;
	CharTemplate.bIsTurret = true;

	CharTemplate.UnitSize = 1;
	CharTemplate.VisionArcDegrees = 360;

	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = false;

	CharTemplate.bAllowSpawnFromATT = false;
	CharTemplate.bSkipDefaultAbilities = true;
	CharTemplate.bBlocksPathingWhenDead = true;

	CharTemplate.ImmuneTypes.AddItem('Fire');
	CharTemplate.ImmuneTypes.AddItem('Poison');
	CharTemplate.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.ParthenogenicPoisonType);
	CharTemplate.ImmuneTypes.AddItem('Panic');

	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_Turret;
	CharTemplate.bDisablePodRevealMovementChecks = true;

    return CharTemplate;
}

defaultproperties
{
	NAME_CHARACTER_SPIRE=Jammerware_JSRC_Character_Spire
}