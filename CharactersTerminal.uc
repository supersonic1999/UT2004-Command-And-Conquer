class CharactersTerminal extends MainTerminal
	DependsOn(CCINV);

function OnOpen()
{
    if(PlayerOwner() != none && PlayerOwner().Level != none)
    {
        if(PlayerOwner().GetTeamNum() != 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
            Slots = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIWeapon.Length;
        else if(CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
            Slots = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODWeapon.Length;
        else if(PlayerOwner().GetTeamNum() != 0)
            Slots = class'CCMainController'.default.GDIWeapon.Length;
        else
            Slots = class'CCMainController'.default.NODWeapon.Length;
    }
    Super.OnOpen();
}

simulated function UpdateButton()
{
    local int i;

    for(i=0;i<CCButton.Length;i++)
    {
        if(PlayerOwner().GetTeamNum() != 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none
        && CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIWeapon.Length > i)
        {
            CCButton[i].Caption = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIWeapon[i].default.ClassName;
            CCButton[i].SetHint("Cost:" @ CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIWeapon[i].default.ClassCost);
            CCButton[i].OnClick = SpawnWeapon;
            CCButton[i].BNum = i;
        }
        else if(CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none
        && CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODWeapon.Length > i)
        {
            CCButton[i].Caption = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODWeapon[i].default.ClassName;
            CCButton[i].SetHint("Cost:" @ CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODWeapon[i].default.ClassCost);
            CCButton[i].OnClick = SpawnWeapon;
            CCButton[i].BNum = i;
        }
        else if(PlayerOwner().GetTeamNum() != 0 && class'CCMainController'.default.GDIWeapon.Length > i)
        {
            CCButton[i].Caption = class'CCMainController'.default.GDIWeapon[i].default.ClassName;
            CCButton[i].SetHint("Cost:" @ class'CCMainController'.default.GDIWeapon[i].default.ClassCost);
            CCButton[i].OnClick = SpawnWeapon;
            CCButton[i].BNum = i;
        }
        else if(class'CCMainController'.default.NODWeapon.Length > i)
        {
            CCButton[i].Caption = class'CCMainController'.default.NODWeapon[i].default.ClassName;
            CCButton[i].SetHint("Cost:" @ class'CCMainController'.default.NODWeapon[i].default.ClassCost);
            CCButton[i].OnClick = SpawnWeapon;
            CCButton[i].BNum = i;
        }
    }
}

function EnableDisable()
{
    local int i;

    for(i=0;i<CCButton.Length;i++)
    {
        if(PlayerOwner().GetTeamNum() != 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none
        && CCINV.Adren() < CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIWeapon[i].default.ClassCost)
            ChangeButton(i,True);
        else if(PlayerOwner().GetTeamNum() == 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none
        && CCINV.Adren() < CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODWeapon[i].default.ClassCost)
            ChangeButton(i,True);
        else if(PlayerOwner().GetTeamNum() != 0 && CCINV.Adren() < class'CCMainController'.default.GDIWeapon[i].default.ClassCost)
            ChangeButton(i,True);
        else if(PlayerOwner().GetTeamNum() == 0 && CCINV.Adren() < class'CCMainController'.default.NODWeapon[i].default.ClassCost)
            ChangeButton(i,True);
        else
            ChangeButton(i,False);
    }
}

simulated function bool SpawnWeapon(GUIComponent Sender)
{
    local int i;

    if(Sender != none && CCImage(Sender) != none)
    {
        i = CCImage(Sender).BNum;
        if(PlayerOwner().GetTeamNum() != 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
            CCINV.ChangeCharacter(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIWeapon[i]);
        else if(CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
            CCINV.ChangeCharacter(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODWeapon[i]);
        else if(PlayerOwner().GetTeamNum() != 0)
            CCINV.ChangeCharacter(class'CCMainController'.default.GDIWeapon[i]);
        else
            CCINV.ChangeCharacter(class'CCMainController'.default.NODWeapon[i]);
        Controller.CloseMenu(false);
	    return true;
    }
}

defaultproperties
{
     Title="Characters"
     Slots=8
}
