class X2Effect_Deadbolt extends X2Effect_Persistent;

function RegisterForEvents(XComGameState_Effect EffectGameState)
{
    local X2EventManager EventMgr;
	local XComGameState_Unit UnitState;
	local Object EffectObj;

	EventMgr = `XEVENTMGR;

	UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(EffectGameState.ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	EffectObj = EffectGameState;

	EventMgr.RegisterForEvent
    (
        EffectObj, 
        'AbilityActivated', 
        class'X2Effect_Deadbolt'.static.ShotMissListener, 
        ELD_OnStateSubmitted, 
        , 
        UnitState
    );
}

private static function EventListenerReturn ShotMissListener(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameStateContext_Ability AbilityContext;
    local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate, DeadboltTemplate;
	local XComGameState NewGameState;
	local XComGameState_Unit UnitState;
    local XComGameState_Item PrimaryWeapon;
    local Jammerware_JSRC_ItemStateService ItemStateService;
    local Jammerware_JSRC_FlyoverService FlyoverService;
    local int Rand;

	AbilityContext = XComGameStateContext_Ability(GameState.GetContext());
    AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();
    Rand = class'Engine'.static.SyncRand(2, "X2Effect_Deadbolt.ShotMissListener");

	if (AbilityContext != none && AbilityContext.InterruptionStatus != eInterruptionStatus_Interrupt && AbilityContext.IsResultContextMiss())
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
		if (AbilityTemplate.Hostility == eHostility_Offensive)
		{
			UnitState = XComGameState_Unit(EventSource);
			if (UnitState != none)
			{
				NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Deadbolt Reload");
				UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
                PrimaryWeapon = UnitState.GetPrimaryWeapon();

                if (PrimaryWeapon.Ammo == 0 || Rand == 1)
                {
                    ItemStateService = new class'Jammerware_JSRC_ItemStateService';
                    ItemStateService.LoadAmmo(PrimaryWeapon, 1, NewGameState);

                    DeadboltTemplate = AbilityTemplateManager.FindAbilityTemplate(class'X2Ability_RunnerAbilitySet'.default.NAME_DEADBOLT);
                    FlyoverService = new class'Jammerware_JSRC_FlyoverService';
                    FlyoverService.FlyoverText = DeadboltTemplate.LocFlyoverText;
                    FlyoverService.FlyoverIcon = DeadboltTemplate.IconImage;

                    //XComGameStateContext_ChangeContainer(NewGameState.GetContext()).BuildVisualizationFn = FlyoverService.VisualizeFlyovers;
                    `TACTICALRULES.SubmitGameState(NewGameState);
                }
			}
		}
	}

	return ELR_NoInterrupt;
}