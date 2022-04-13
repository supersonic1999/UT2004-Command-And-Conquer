class VehicleTerminals extends MainTerminal
	DependsOn(CCINV);

function OnOpen()
{
    if(PlayerOwner().GetTeamNum() == 0 && PlayerOwner() != none && PlayerOwner().Level != none
    && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
        Slots = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles.Length;
    else if(PlayerOwner().GetTeamNum() != 0 && PlayerOwner() != none && PlayerOwner().Level != none
    && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
        Slots = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles.Length;
    Super.OnOpen();
}

function EnableDisable()
{
    local int i, n;

    if(CCINV.PowerPlant != none)
        n = 1;
    else
        n = 2;

    if(PlayerOwner().GetTeamNum() == 0)
    {
        for(i=0;i<CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles.Length;i++)
        {
            if(ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Summon, class'ONSChopperCraft') && CCINV.HeliPad == none
            || ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Summon, class'ONSHoverCraft') && CCINV.HeliPad == none)
            {
                ChangeButton(i, True);
                continue;
            }

            if(ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Summon, class'ONSChopperCraft') == false
            && ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Summon, class'ONSHoverCraft') == false && CCINV.VB == none)
            {
                ChangeButton(i, True);
                continue;
            }

            if(CCINV.Adren() < (CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Cost*n))
                ChangeButton(i, True);
            else
                ChangeButton(i, False);
        }
    }
    else
    {
        for(i=0;i<CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles.Length;i++)
        {
            if(ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Summon, class'ONSChopperCraft') && CCINV.HeliPad == none
            || ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Summon, class'ONSHoverCraft') && CCINV.HeliPad == None)
            {
                ChangeButton(i, True);
                continue;
            }

            if(ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Summon, class'ONSChopperCraft') == false
            && ClassIsChildOf(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Summon, class'ONSHoverCraft') == false && CCINV.VB == none)
            {
                ChangeButton(i, True);
                continue;
            }

            if(CCINV.Adren() < (CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Cost*n))
                ChangeButton(i, True);
            else
                ChangeButton(i, False);
        }
    }
}

simulated function UpdateButton()
{
    local int i, n;

    for(i=0;i<CCButton.Length;i++)
    {
        if(CCINV.PowerPlant != none)
            n = 1;
        else
            n = 2;

        if(PlayerOwner().GetTeamNum() == 0)
        {
            CCButton[i].Caption = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].VName;
            CCButton[i].SetHint("Cost:" @ (CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Cost*n));
        }
        else
        {
            CCButton[i].Caption = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].VName;
            CCButton[i].SetHint("Cost:" @ (CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Cost*n));
        }
        CCButton[i].OnClick = SpawnVehicle;
        CCButton[i].BNum = i;
    }
}

simulated function bool SpawnVehicle(GUIComponent Sender)
{
    local int i;

    if(Sender != none && CCImage(Sender) != none)
    {
        i = CCImage(Sender).BNum;
        if(PlayerOwner().GetTeamNum() == 0)
            CCINV.SpawnVehicle(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Cost, CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODVehicles[i].Summon, i);
        else
            CCINV.SpawnVehicle(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Cost, CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIVehicles[i].Summon, i);
        Controller.CloseMenu(false);
        return true;
    }
}

defaultproperties
{
     Title="Vehicles"
     Slots=8
}
