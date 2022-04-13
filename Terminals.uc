class Terminals extends MainTerminal
	DependsOn(CCINV);

struct MainT
{
    var string ButtonHint, ButtonCaption;
    var name ButtonClick;
};

var config array<MainT> ButtonUse;
var int SuperWeaponCost;

function EnableDisable()
{
    CCINV.CheckBuildings();

    if(CCINV.CB != none && CCINV.CB.bBuilt)
        ChangeButton(5, False);
    else
        ChangeButton(5, True);

    if(CCINV.CheckVehicleAmount() < CCINV.VMax && !CCINV.bBuildingVehicle()
    && (CCINV.VB != none && CCINV.VB.bBuilt
    || CCINV.HeliPad != none && CCINV.HeliPad.bBuilt))
        ChangeButton(6, False);
    else
        ChangeButton(6, True);

    if(CCINV.Adren() < SuperWeaponCost || CCINV.SWB == none)
        ChangeButton(7, True);
    else
        ChangeButton(7, False);
}

simulated function UpdateButton()
{
    local int i;

    for(i=0;i<CCButton.Length;i++)
    {
        if(i == 6 && CCINV.bBuildingVehicle())
            CCButton[i].Caption = "Building...";
        else if(i == 6 && CCINV.CheckVehicleAmount() < CCINV.VMax)
            CCButton[i].Caption = ButtonUse[i].ButtonCaption;
        else if(i == 6)
            CCButton[i].Caption = "Limit Reached";
        else if(i == 0 || i == 1 || i == 2 || i == 3)
        {
            if(PlayerOwner().GetTeamNum() != 0)
            {
                if(CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
                    CCButton[i].Caption = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIBasic[i].default.ClassName;
                else
                    CCButton[i].Caption = class'CCMainController'.default.GDIBasic[i].default.ClassName;
            }
            else
            {
                if(CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
                    CCButton[i].Caption = CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODBasic[i].default.ClassName;
                else
                    CCButton[i].Caption = class'CCMainController'.default.GDIBasic[i].default.ClassName;
            }
        }
        else
            CCButton[i].Caption = ButtonUse[i].ButtonCaption;

        if(i == 0 || i == 1 || i == 2 || i == 3)
        {
            CCButton[i].SetHint(" Gives basic weapons for free!");
        }
        else
            CCButton[i].SetHint(ButtonUse[i].ButtonHint);
        CCButton[i].BNum = i;
    }
    CCButton[0].OnClick = BasicCharChange;
    CCButton[1].OnClick = BasicCharChange;
    CCButton[2].OnClick = BasicCharChange;
    CCButton[3].OnClick = BasicCharChange;
    CCButton[4].OnClick = RefillAmmo;
    CCButton[5].OnClick = CharactersTerminal;
    CCButton[6].OnClick = VehiclesTerminal;
    CCButton[7].OnClick = SuperWep;
}

function bool CharactersTerminal(GUIComponent Sender)
{
    Controller.ReplaceMenu("CommandAndConquer.CharactersTerminal");
    return true;
}

function bool VehiclesTerminal(GUIComponent Sender)
{
    Controller.ReplaceMenu("CommandAndConquer.VehicleTerminals");
    return true;
}

simulated function bool DoTopView(GUIComponent Sender)
{
//    if(PlayerController(Pawn(CCINV.Owner).Controller) == CCReplicationInfo(CCINV.Level.GRI).CommanderRED && Pawn(CCINV.Owner).GetTeamNum() == 0 || PlayerController(Pawn(CCINV.Owner).Controller) == CCReplicationInfo(CCINV.Level.GRI).CommanderBLUE && Pawn(CCINV.Owner).GetTeamNum() != 0)
//    {
//        CCINV.DoTopView();
//        return true;
//    }
	return false;
}

simulated function bool RefillAmmo(GUIComponent Sender)
{
    CCINV.Refill();
    Controller.CloseMenu(false);
	return true;
}

simulated function bool SuperWep(GUIComponent Sender)
{
    CCINV.GiveSuperWeapon(SuperWeaponCost);
    Controller.CloseMenu(false);
	return true;
}

simulated function bool BasicCharChange(GUIComponent Sender)
{
    if(Sender != none && CCImage(Sender) != none)
    {
        if(PlayerOwner().GetTeamNum() != 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
            CCINV.ChangeCharacter(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.GDIBasic[CCImage(Sender).BNum]);
        else if(CCReplicationInfo(PlayerOwner().Level.GRI).MainController != none)
            CCINV.ChangeCharacter(CCReplicationInfo(PlayerOwner().Level.GRI).MainController.NODBasic[CCImage(Sender).BNum]);
        else if(PlayerOwner().GetTeamNum() != 0)
            CCINV.ChangeCharacter(class'CCMainController'.default.GDIBasic[CCImage(Sender).BNum]);
        else
            CCINV.ChangeCharacter(class'CCMainController'.default.NODBasic[CCImage(Sender).BNum]);
        Controller.CloseMenu(false);
        return true;
    }
}

defaultproperties
{
     ButtonUse(0)=(ButtonHint="Gives basic weapons for free!",ButtonCaption="Soldier",ButtonClick="BasicWeap")
     ButtonUse(1)=(ButtonHint="Gives basic weapons for free!",ButtonCaption="Shotgun Trooper",ButtonClick="BasicWeap")
     ButtonUse(2)=(ButtonHint="Gives basic weapons for free!",ButtonCaption="Grenadier",ButtonClick="BasicWeap")
     ButtonUse(3)=(ButtonHint="Gives basic weapons for free!",ButtonCaption="Engineer",ButtonClick="BasicWeap")
     ButtonUse(4)=(ButtonHint="Restocks ammo on all the weapons you are carrying, and restores your health to full.",ButtonCaption="Refill",ButtonClick="RefillAmmo")
     ButtonUse(5)=(ButtonHint="Buy different characters. Only avaliable when you have a barracks or hand of nod.",ButtonCaption="Characters",ButtonClick="CharactersTerminal")
     ButtonUse(6)=(ButtonHint="Buy different vehicles. Only avaliable when you have a war factory or air strip.",ButtonCaption="Vehicles",ButtonClick="VehiclesTerminal")
     ButtonUse(7)=(ButtonHint="Gives you a super weapon!!!!! Cost: 1000",ButtonCaption="Super Weapon",ButtonClick="SuperWep")
     SuperWeaponCost=1000
     Slots=8
     Begin Object Class=GUIButton Name=CloseButton
         Caption="Exit"
         WinTop=0.900000
         WinLeft=0.100000
         WinWidth=0.200000
         OnClick=Terminals.CloseClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'commandandconquer.Terminals.CloseButton'

}
