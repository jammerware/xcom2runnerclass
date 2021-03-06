class X2Item_SpireGun extends X2Item 
	config(GameData_WeaponData);

var config int SPIREGUN_ISOUNDRANGE;
var config int SPIREGUN_IENVIRONMENTDAMAGE;

var name NAME_SPIREGUN_CONVENTIONAL;
var config array <WeaponDamageValue> SPIREGUN_CONVENTIONAL_ABILITYDAMAGE;
var config int SPIREGUN_CONVENTIONAL_FIELDRELOADAMMO;
var config int SPIREGUN_CONVENTIONAL_QUICKSILVERCHARGESBONUS;
var config int SPIREGUN_CONVENTIONAL_SHELTERSHIELDBONUS;
var config int SPIREGUN_CONVENTIONAL_TARGETINGARRAYACCURACYBONUS;

var name NAME_SPIREGUN_MAGNETIC;
var config array<WeaponDamageValue> SPIREGUN_MAGNETIC_ABILITYDAMAGE;
var config int SPIREGUN_MAGNETIC_FIELDRELOADAMMO;
var config int SPIREGUN_MAGNETIC_QUICKSILVERCHARGESBONUS;
var config int SPIREGUN_MAGNETIC_SHELTERSHIELDBONUS;
var config int SPIREGUN_MAGNETIC_TARGETINGARRAYACCURACYBONUS;

var name NAME_SPIREGUN_BEAM;
var config array<WeaponDamageValue> SPIREGUN_BEAM_ABILITYDAMAGE;
var config int SPIREGUN_BEAM_FIELDRELOADAMMO;
var config int SPIREGUN_BEAM_QUICKSILVERCHARGESBONUS;
var config int SPIREGUN_BEAM_SHELTERSHIELDBONUS;
var config int SPIREGUN_BEAM_TARGETINGARRAYACCURACYBONUS;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Weapons;

	Weapons.AddItem(CreateTemplate_SpireGun_Conventional());
	Weapons.AddItem(CreateTemplate_SpireGun_Magnetic());
	Weapons.AddItem(CreateTemplate_SpireGun_Beam());

	return Weapons;
}

static function X2DataTemplate CreateTemplate_SpireGun_Conventional()
{
	local X2WeaponTemplate_SpireGun Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate_SpireGun', Template, default.NAME_SPIREGUN_CONVENTIONAL);
	Template.WeaponTech = 'conventional';
	Template.strImage = "img:///UILibrary_Common.ConvSecondaryWeapons.PsiAmp";
	Template.GameArchetype = "Jammerware_JSRC_Weapons.SpireKit.WP_SpireKit_CV";
	Template.Tier = 0;
	Template.StartingItem = true;
	Template.InfiniteAmmo = true;
	Template.iTypicalActionCost = 1;

	Template.ExtraDamage = default.SPIREGUN_CONVENTIONAL_ABILITYDAMAGE;
	Template.iSoundRange = default.SPIREGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_IENVIRONMENTDAMAGE;

	// bonuses for this tier of spire gun
	Template.FieldReloadAmmoGranted = default.SPIREGUN_CONVENTIONAL_FIELDRELOADAMMO;
	Template.QuicksilverChargesBonus = default.SPIREGUN_CONVENTIONAL_QUICKSILVERCHARGESBONUS;
	Template.ShelterShieldBonus = default.SPIREGUN_CONVENTIONAL_SHELTERSHIELDBONUS;
	Template.TargetingArrayAccuracyBonus = default.SPIREGUN_CONVENTIONAL_TARGETINGARRAYACCURACYBONUS;
	
	return Template;
}

static function X2DataTemplate CreateTemplate_SpireGun_Magnetic()
{
	local X2WeaponTemplate_SpireGun Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate_SpireGun', Template, default.NAME_SPIREGUN_MAGNETIC);
	Template.WeaponTech = 'magnetic';
	Template.strImage = "img:///UILibrary_Common.MagSecondaryWeapons.MagPsiAmp";
	Template.GameArchetype = "Jammerware_JSRC_Weapons.SpireKit.WP_SpireKit_MG";
	Template.Tier = 2;
	Template.InfiniteAmmo = true;
	Template.iTypicalActionCost = 1;

	Template.iSoundRange = default.SPIREGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_IENVIRONMENTDAMAGE;

	// bonuses for this tier of spire gun
	Template.ExtraDamage = default.SPIREGUN_MAGNETIC_ABILITYDAMAGE;
	Template.FieldReloadAmmoGranted = default.SPIREGUN_MAGNETIC_FIELDRELOADAMMO;
	Template.QuicksilverChargesBonus = default.SPIREGUN_MAGNETIC_QUICKSILVERCHARGESBONUS;
	Template.ShelterShieldBonus = default.SPIREGUN_MAGNETIC_SHELTERSHIELDBONUS;
	Template.TargetingArrayAccuracyBonus = default.SPIREGUN_MAGNETIC_TARGETINGARRAYACCURACYBONUS;
	
	// upgradey stuff
	Template.CreatorTemplateName = class'X2Item_SpireGunSchematics'.default.NAME_SPIREGUN_SCHEMATIC_MAGNETIC;
	Template.BaseItem = default.NAME_SPIREGUN_CONVENTIONAL;

	return Template;
}

static function X2DataTemplate CreateTemplate_SpireGun_Beam()
{
	local X2WeaponTemplate_SpireGun Template;

	`CREATE_X2TEMPLATE(class'X2WeaponTemplate_SpireGun', Template, default.NAME_SPIREGUN_BEAM);
	Template.WeaponTech = 'beam';
	Template.strImage = "img:///UILibrary_Common.BeamSecondaryWeapons.BeamPsiAmp";
	Template.GameArchetype = "Jammerware_JSRC_Weapons.SpireKit.WP_SpireKit_BM";
	Template.Tier = 4;
	Template.InfiniteAmmo = true;
	Template.iTypicalActionCost = 1;

	Template.iSoundRange = default.SPIREGUN_ISOUNDRANGE;
	Template.iEnvironmentDamage = default.SPIREGUN_IENVIRONMENTDAMAGE;

	// bonuses for this tier of spire gun
	Template.ExtraDamage = default.SPIREGUN_BEAM_ABILITYDAMAGE;
	Template.FieldReloadAmmoGranted = default.SPIREGUN_BEAM_FIELDRELOADAMMO;
	Template.QuicksilverChargesBonus = default.SPIREGUN_BEAM_QUICKSILVERCHARGESBONUS;
	Template.ShelterShieldBonus = default.SPIREGUN_BEAM_SHELTERSHIELDBONUS;
	Template.TargetingArrayAccuracyBonus = default.SPIREGUN_BEAM_TARGETINGARRAYACCURACYBONUS;
	
	// upgradey stuff
	Template.CreatorTemplateName = class'X2Item_SpireGunSchematics'.default.NAME_SPIREGUN_SCHEMATIC_BEAM;
	Template.BaseItem = default.NAME_SPIREGUN_MAGNETIC;

	return Template;
}

defaultproperties 
{
	NAME_SPIREGUN_CONVENTIONAL=Jammerware_JSRC_Item_SpireGun_Conventional
	NAME_SPIREGUN_MAGNETIC=Jammerware_JSRC_Item_SpireGun_Magnetic
	NAME_SPIREGUN_BEAM=Jammerware_JSRC_Item_SpireGun_Beam
}