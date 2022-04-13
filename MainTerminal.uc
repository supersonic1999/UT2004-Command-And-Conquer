class MainTerminal extends GUIPage
	DependsOn(CCINV);

var CCINV CCINV;
var string Title;
var array<CCImage> CCButton;
var int Slots;

function OnOpen()
{
    local int Num;

	CCINV = CCINV(Playerowner().Pawn.FindInventoryType(class'CCINV'));
    SetTimer(0.1, True);

    while(Num < Slots)
    {
        CreateInventory();
        Num++;
    }
    EnableDisable();
    ChangeComponents();
    UpdateButton();
}

function CreateInventory()
{
	local int i;

    if(CCButton.length == 0)
    {
        CCButton[0] = new class'CCImage';
        CCButton[0].WinTop = 0.040000;
        CCButton[0].WinLeft = 0.040000;
        CCButton[0].WinWidth = 0.200000;
        CCButton[0].WinHeight = 0.200000;
        AppendComponent(CCButton[0], true);
        return;
    }

    i = CCButton.Length;

    CCButton[i] = new class'CCImage';
    if(CCButton[i-1].WinLeft != 0.760000)
    {
        CCButton[i].WinTop = CCButton[i-1].WinTop;
        CCButton[i].WinLeft = CCButton[i-1].WinLeft + 0.240000;
        CCButton[i].WinWidth = 0.200000;
        CCButton[i].WinHeight = 0.200000;
    }
    else
    {
        CCButton[i].WinTop = CCButton[i-1].WinTop + 0.220000;
        CCButton[i].WinLeft = 0.040000;
        CCButton[i].WinWidth = 0.200000;
        CCButton[i].WinHeight = 0.200000;
    }
    AppendComponent(CCButton[i], true);
}

function UpdateButton();
function EnableDisable();

simulated function ChangeComponents()
{
    if(Playerowner() != none && CommandController(Playerowner()) != none)
        GUILabel(Controls[2]).Caption = GUILabel(default.Controls[2]).Caption @ int(CommandController(Playerowner()).Money);
    GUIHeader(Controls[3]).Caption = Title;
}

function ChangeButton(int x, bool Disable)
{
    if(Disable == true)
    {
       if(CCButton.Length > x && CCButton[x].MenuState != MSAT_Disabled)
          CCButton[x].MenuStateChange(MSAT_Disabled);
    }
    else if(CCButton.Length > x && CCButton[x].MenuState == MSAT_Disabled)
       CCButton[x].MenuStateChange(MSAT_Blurry);
}

simulated function Timer()
{
    if(Playerowner().Pawn.Health > 0)
    {
        ChangeComponents();
        EnableDisable();
        UpdateButton();
    }
    else
    {
        CloseClick(none);
        return;
    }
}

function bool CloseClick(GUIComponent Sender)
{
    Controller.CloseMenu(false);
	return true;
}

function bool BackClick(GUIComponent Sender)
{
    if(Controller != none)
    {
        Controller.ReplaceMenu("CommandAndConquer.Terminals");
        Controller.CloseMenu(false);
        return true;
    }
    return false;
}

defaultproperties
{
     Title="Purchase Terminal"
     Slots=6
     bAllowedAsLast=True
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'2K4Menus.NewControls.Display1'
         DropShadow=None
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.020000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=0.980000
         RenderWeight=0.000003
     End Object
     Controls(0)=FloatingImage'commandandconquer.MainTerminal.FloatingFrameBackground'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Back"
         WinTop=0.900000
         WinLeft=0.100000
         WinWidth=0.200000
         OnClick=MainTerminal.BackClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'commandandconquer.MainTerminal.CloseButton'

     Begin Object Class=GUILabel Name=Money
         Caption="Money:"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.850000
         WinHeight=0.025000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(2)=GUILabel'commandandconquer.MainTerminal.Money'

     Begin Object Class=GUIHeader Name=TitleBar
         bUseTextHeight=True
         Caption="Purchase Terminal"
         WinHeight=0.043750
         RenderWeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         bNeverFocus=False
         ScalingType=SCALE_X
     End Object
     Controls(3)=GUIHeader'commandandconquer.MainTerminal.TitleBar'

     WinHeight=1.000000
}
