/*
    Purpose-wise, this a hot mess, but these conditions always go together and apply to the same
    abilities thanks to the software nightmare that is Soul of the Architect.

    The deal is that this condition goes on abilities that the spires get by default in X2Character_Spire. 
    They can use these abilities only if the architect who summoned them has a corresponding ability. For example,
    the spire automatically gets the ability class'X2Ability_FieldReloadArray'.default.NAME_SPIRE_ABILITY, but it can only go off
    if the architect has class'X2Ability_FieldReloadArray'.default.NAME_ABILITY. When the engine evaluates this condition for
    the spire, we need to go get the architect that summoned it and check for the prerequisite ability.

    The wrinkle is Soul of the Architect. All of these abilities can also go on architects, so we need to account 
    for the case where this ability is being checked for the architect. If the source (the architect, in this case) has the 
    prerequisite ability AND SotA, the check passes.
*/
class X2Condition_SpireAbilityCondition extends X2Condition;

var name RequiredArchitectAbility;
var bool DebugOn;

// this seems to happen on unit begin play, and I think it's an optimization to prevent unnecessary evaluations of other
// condition methods
public function bool CanEverBeValid(XComGameState_Unit SourceUnit, bool bStrategyCheck)
{
    local XComGameState_Unit ArchitectState;
    local Jammerware_JSRC_SpireService SpireService;
    local Jammerware_JSRC_SpireRegistrationService SpireRegistrationService;
    local bool bRequireSotA;

    ConditionalLog("JSRC: can ever be valid");
    SpireService = new class'Jammerware_JSRC_SpireService';
    SpireRegistrationService = new class'Jammerware_JSRC_SpireRegistrationService';

    ConditionalLog("- source state" @ SourceUnit.GetFullName());

    if (SourceUnit == none)
        return false;

    if (SpireService.IsSpire(SourceUnit))
    {
        ConditionalLog("- is spire");
        ArchitectState = SpireRegistrationService.GetRunnerFromSpire(SourceUnit.ObjectID);
        ConditionalLog("- architect:" @ ArchitectState.GetFullName());
    }
    else 
    {
        ConditionalLog("- is architect");
        ArchitectState = SourceUnit;
        bRequireSotA = true;
    }

    ConditionalLog("- architect state" @ ArchitectState.GetFullName());
    ConditionalLog("- affected by required ability" @ ArchitectState.AffectedByEffectNames.Find(RequiredArchitectAbility));
    ConditionalLog("- SotA required" @ bRequireSotA);
    ConditionalLog("- has soul?" @ ArchitectState.AffectedByEffectNames.Find(class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT) != INDEX_NONE);

    if
    (
        ArchitectState == none ||
        ArchitectState.AffectedByEffectNames.Find(RequiredArchitectAbility) == INDEX_NONE ||
        (bRequireSotA && ArchitectState.AffectedByEffectNames.Find(class'X2Ability_RunnerAbilitySet'.default.NAME_SOUL_OF_THE_ARCHITECT) == INDEX_NONE)
    )
    {
        ConditionalLog("value check failed");
        return false;
    }

    ConditionalLog("SUCCESS");
	return true;
}

private function ConditionalLog(string Message)
{
    if (DebugOn)
    {
        `LOG("JSRC: ability condition requiring" @ RequiredArchitectAbility @ "-" @Message);
    }
}