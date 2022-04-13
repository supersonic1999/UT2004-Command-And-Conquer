class CCInteraction extends Interaction;

var localized string ApplyMessage;
var localized string AlreadyApplied;
var localized string AlreadyCommander;

var color WhiteColor;
var bool bDefaultBindings, bDefaultInsertBinding, bDefaultHelpBindings;
var Font TextFont;

event Initialized()
{
	local EInputKey key;
	local string tmp;

	for(key=IK_None;key<IK_OEMClear;key=EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if(tmp ~= "ApplyCommander")
			bDefaultBindings = false;
		if(!bDefaultBindings)
			break;
	}

	for(key=IK_None;key<IK_OEMClear;key=EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if(tmp ~= "OpenCView")
			bDefaultInsertBinding = false;
		if(!bDefaultInsertBinding)
			break;
	}

    for(key=IK_None;key<IK_OEMClear;key=EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if(tmp ~= "C&CHelpMenu")
			bDefaultHelpBindings = false;
		if(!bDefaultHelpBindings)
			break;
	}

	TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
    local string tmp;
    local CYard CYard;
    local CCBuildings C;

    if(ViewportOwner == none || ViewportOwner.Actor == none || !CommanderSelection(Key, Action, Delta) || Action != IST_Press)
		return super.KeyEvent(Key, Action, Delta);

    tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
    tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);

    if(bDefaultHelpBindings && Key == IK_Delete || tmp ~= "C&CHelpMenu")
        ViewportOwner.GUIController.OpenMenu("CommandAndConquer.InformationGUI");
    else if(!CommandController(ViewportOwner.Actor).bCommandView && (bDefaultInsertBinding && Key == IK_Insert || tmp ~= "OpenCView"))
    {
        for(C=Class'CCBuildings'.Static.PickFirstBuilding(ViewportOwner.Actor.Level); C!=None; C=C.NextBuilding)
        {
            CYard = CYard(C);
            if(CYard != none && CYard.bBuilt && ViewportOwner.Actor.GetTeamNum() == 0
            && ViewportOwner.Actor.PlayerReplicationInfo == CCReplicationInfo(ViewportOwner.Actor.Level.GRI).CommanderRED
            || CYard != none && CYard.bBuilt && ViewportOwner.Actor.GetTeamNum() != 0
            && ViewportOwner.Actor.PlayerReplicationInfo == CCReplicationInfo(ViewportOwner.Actor.Level.GRI).CommanderBLUE)
            {
                if(CYard.Team == ViewportOwner.Actor.GetTeamNum())
                {
                    CommandController(ViewportOwner.Actor).CamLocation.X = CYard.Location.X;
                    CommandController(ViewportOwner.Actor).CamLocation.Y = CYard.Location.Y;
                    ViewportOwner.Actor.bFire = 0;
                	ViewportOwner.Actor.bAltFire = 0;
                	ViewportOwner.Actor.bDuck = 0;
                	ViewportOwner.Actor.bRun = 0;
                	if(Vehicle(ViewportOwner.Actor.Pawn) != none)
                    {
                        Vehicle(ViewportOwner.Actor.Pawn).Throttle = 0;
                        Vehicle(ViewportOwner.Actor.Pawn).Steering = 0;
                    	Vehicle(ViewportOwner.Actor.Pawn).Rise = 0;
                	}
                	CommandController(ViewportOwner.Actor).bCommandView = true;
                	return true;
                }
            }
        }
    }
    else if(CommandController(ViewportOwner.Actor).bCommandView)
    {
        if(bDefaultInsertBinding && Key == IK_Insert || tmp ~= "OpenCView")
        {
            CommandController(ViewportOwner.Actor).RepossesOldBody();
            HudCommandAndConquer(ViewportOwner.Actor.myHud).Mode = 0;
            if(CommandController(ViewportOwner.Actor).CurPlacement != none)
            {
                CommandController(ViewportOwner.Actor).CurPlacement.Destroy();
                CommandController(ViewportOwner.Actor).CurPlacement = none;
            }
            return true;
        }
        else if(Key == IK_LeftMouse)
        {
            HudCommandAndConquer(ViewportOwner.Actor.myHud).DoButtonClick(true);
            return true;
        }
        else if(Key == IK_RightMouse)
        {
            HudCommandAndConquer(ViewportOwner.Actor.myHud).DoButtonClick(false);
             return true;
        }
        else if(Key == IK_MouseWheelUp && CommandController(ViewportOwner.Actor).CamLocation.Z >= 500)
        {
    	    CommandController(ViewportOwner.Actor).CamLocation.Z -= 500;
    	    return true;
   	    }
    	else if(Key == IK_MouseWheelDown && CommandController(ViewportOwner.Actor).CamLocation.Z <= 9500)
    	{
    	    CommandController(ViewportOwner.Actor).CamLocation.Z += 500;
    	    return true;
	    }
    	else if(Key == IK_Left)
    	{
            CommandController(ViewportOwner.Actor).UpdatePlaceRot(False);
            return true;
        }
        else if(Key == IK_Right)
    	{
            CommandController(ViewportOwner.Actor).UpdatePlaceRot(True);
            return true;
        }
    }
	else if(tmp ~= "ApplyCommander" || (bDefaultBindings && Key == IK_PageUp))
        return CommandController(ViewportOwner.Actor).ApplyCommander();
	return false;
}

function bool CommanderSelection(EInputKey Key, EInputAction Action, float Delta)
{
    local vector ALocation, BLocation, DragVector, MouseVector, AHitLocation, BHitLocation, HitNormal;
    local Pawn C;

    if(CommandController(ViewportOwner.Actor).bCommandView
    && CommandController(ViewportOwner.Actor).MouseTouchingActor == none
    && HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartX == 0
    && Key == IK_LeftMouse && Action == IST_Press)
    {
        HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartX = ViewportOwner.WindowsMouseX;
        HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartY = ViewportOwner.WindowsMouseY;
        return true;
    }
    else if(CommandController(ViewportOwner.Actor).bCommandView
    && HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartX != 0
    && Key == IK_LeftMouse && Action == IST_Release)
    {
        DragVector.X = HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartX;
        DragVector.Y = HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartY;
        MouseVector.X = ViewportOwner.WindowsMouseX;
        MouseVector.Y = ViewportOwner.WindowsMouseY;

        ALocation = ScreenToWorld(DragVector);
        ViewportOwner.Actor.Trace(AHitLocation, HitNormal, (CommandController(ViewportOwner.Actor).CamLocation + (ALocation * 50000)),
        CommandController(ViewportOwner.Actor).CamLocation, False);

        BLocation = ScreenToWorld(MouseVector);
        ViewportOwner.Actor.Trace(BHitLocation, HitNormal, (CommandController(ViewportOwner.Actor).CamLocation + (BLocation * 50000)),
        CommandController(ViewportOwner.Actor).CamLocation, False);

        foreach ViewportOwner.Actor.DynamicActors(class'Pawn', C)
            if(C != none
            && C.GetTeamNum() == ViewportOwner.Actor.GetTeamNum()
            && C.Location.X >= Min(AHitLocation.X, BHitLocation.X)
            && C.Location.X <= Max(AHitLocation.X, BHitLocation.X)
            && C.Location.Y >= Min(AHitLocation.Y, BHitLocation.Y)
            && C.Location.Y <= Max(AHitLocation.Y, BHitLocation.Y))
                HudCommandAndConquer(ViewportOwner.Actor.myHud).SelectedActor[HudCommandAndConquer(ViewportOwner.Actor.myHud).SelectedActor.Length] = C;

        HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartX = 0;
        HudCommandAndConquer(ViewportOwner.Actor.myHud).DragStartY = 0;
    }
    return true;
}

defaultproperties
{
     ApplyMessage="You have applied to be the commander of your team!"
     AlreadyApplied="You have already applied to be the commander of your team."
     AlreadyCommander="There is already a commander!"
     WhiteColor=(B=255,G=255,R=255,A=255)
     bDefaultBindings=True
     bDefaultInsertBinding=True
     bDefaultHelpBindings=True
     bVisible=True
}
