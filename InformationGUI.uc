class InformationGUI extends GUIPage;

var array<GUIImage> BuildingImage;
var array<CCBuildings> TeamBuildings;
var array<string> Contents, Chapters;
var string Intro;
var int Page;

var automated GUIButton MutinyButton;
var automated FloatingImage fBackGround;
var automated GUIScrollTextBox HelpBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int Num, i;
    local string HText;
    local CCBuildings CCB;

    super.InitComponent(MyController, MyOwner);

    HText = Intro;

    for(i=0;i<Contents.Length;i++)
        HText = (HText $ Contents[i]);

    for(i=0;i<Chapters.Length;i++)
        HText = (HText $ Chapters[i]);

    TeamBuildings.Remove(0, TeamBuildings.Length);
    HelpBox.SetContent(HText);

    for(CCB=Class'CCBuildings'.Static.PickFirstBuilding(PlayerOwner().Level); CCB!=None; CCB=CCB.NextBuilding)
        if(CCB.Team == PlayerOwner().GetTeamNum())
            TeamBuildings[TeamBuildings.Length] = CCB;

    while(Num < Min(TeamBuildings.Length, 8))
    {
        CreateInformation();
        Num++;
    }
    UpdateButton();
}

function CreateInformation()
{
	local int i;
	local float p;

    if(BuildingImage.length == 0)
    {
        BuildingImage[0] = new class'GUIImage';
        BuildingImage[0].WinTop = 0.020000;
        BuildingImage[0].WinLeft = 0.020000;
        BuildingImage[0].WinWidth = 0.150000;
        BuildingImage[0].WinHeight = 0.150000;
        BuildingImage[0].ImageStyle = ISTY_Scaled;
        AppendComponent(BuildingImage[0], true);
        return;
    }

    i = BuildingImage.Length;
    p = (BuildingImage[0].WinHeight*3)+(BuildingImage[0].WinTop*4);

    BuildingImage[i] = new class'GUIImage';
    if(BuildingImage[i-1].WinTop < (BuildingImage[0].WinHeight*3)+(BuildingImage[0].WinTop*4))
    {
        BuildingImage[i].WinTop = (BuildingImage[i-1].WinTop + BuildingImage[0].WinWidth + BuildingImage[0].WinLeft);
        BuildingImage[i].WinLeft = BuildingImage[i-1].WinLeft;
        BuildingImage[i].WinWidth = BuildingImage[0].WinWidth;
        BuildingImage[i].WinHeight = BuildingImage[0].WinHeight;
        BuildingImage[i].ImageStyle = BuildingImage[0].ImageStyle;
    }
    else
    {
        BuildingImage[i].WinTop = BuildingImage[0].WinTop;
        BuildingImage[i].WinLeft = (BuildingImage[i-1].WinLeft + BuildingImage[0].WinWidth + BuildingImage[0].WinLeft);
        BuildingImage[i].WinWidth = BuildingImage[0].WinWidth;
        BuildingImage[i].WinHeight = BuildingImage[0].WinHeight;
        BuildingImage[i].ImageStyle = BuildingImage[0].ImageStyle;
    }
    //log(p @ BuildingImage[i-1].WinTop @ BuildingImage[i-1].WinTop < p);
    AppendComponent(BuildingImage[i], true);
}

simulated function UpdateButton()
{
    local int i;

    if(PlayerOwner().GetTeamNum() == 0 && CCReplicationInfo(PlayerOwner().Level.GRI).CommanderRED == none
    || PlayerOwner().GetTeamNum() != 0 && CCReplicationInfo(PlayerOwner().Level.GRI).CommanderBLUE == none
    || PlayerOwner().GetTeamNum() == 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MutinyVotesNOD >= 1
    || PlayerOwner().GetTeamNum() != 0 && CCReplicationInfo(PlayerOwner().Level.GRI).MutinyVotesGDI >= 1
    || PlayerOwner().GetTeamNum() == 0 && PlayerOwner().PlayerReplicationInfo == CCReplicationInfo(PlayerOwner().Level.GRI).CommanderRED
    || PlayerOwner().GetTeamNum() != 0 && PlayerOwner().PlayerReplicationInfo == CCReplicationInfo(PlayerOwner().Level.GRI).CommanderBLUE)
        MutinyButton.MenuStateChange(MSAT_Disabled);
    else if(MutinyButton.MenuState != MSAT_Blurry)
        MutinyButton.MenuStateChange(MSAT_Blurry);

    for(i=0;i<BuildingImage.Length;i++)
        if(TeamBuildings[i+Page] != none)
            BuildingImage[i].Image = TeamBuildings[i+Page].BuildingImage;
}

//function bool myOnKeyEvent(out byte Key, out byte Action, float delta)
//{
//    log("myOnKeyEvent()" @ Action);
//
//    if(Key == 46 && Action == 3)
//        Controller.CloseMenu(false);
//    return true;
//}

function bool StartMutiny(GUIComponent Sender)
{
    CCReplicationInfo(PlayerOwner().Level.GRI).StartTeamMutiny(PlayerOwner());
    Controller.CloseMenu(false);
    return true;
}

defaultproperties
{
     Contents(0)="FAQ:||1.What is the objective?|"
     Contents(1)="2.How can i buy things?|"
     Contents(2)="3.Whats a commander?|"
     Contents(3)="4.How do i be a commander?"
     Contents(4)="||"
     Chapters(0)="1)The objective of this gametype is to build your own base and keep it up and running while attacking the enemy base and eventually winning by destroying all of thier buildings of when the time runs out.||"
     Chapters(1)="2)To buy things like vehicles, or classes ect you will need to find a purchase terminal somewhere in one of your teams buildings and press the use key(default e) next to it. This will open a menu where you can choose what to buy if you have enough money by clicking on the item you want.||"
     Chapters(2)="3)A Commander is one person on team team who's 'job' is to build your teams base and use thier superior radar ect to help destroy the enemy base.||"
     Chapters(3)="4)To become a commander first there must not be one of your team then you have to press Page Up on your keyboard or what ever key it is for you to apply to become commander. To change the key type 'set input [key] OpenCView' then reconnect if you are on a server and then by pressing what ever key you bound the command to, will apply you for commander of your team."
     Intro="This is the official help guide for the Command And Conquer gametype made by Super_Sonic. (C)Westwood Studios.||"
     Begin Object Class=GUIButton Name=Mutiny
         Caption="Mutiny"
         WinTop=0.025000
         WinLeft=0.850000
         WinWidth=0.100000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=InformationGUI.StartMutiny
         OnKeyEvent=Mutiny.InternalOnKeyEvent
     End Object
     MutinyButton=GUIButton'commandandconquer.InformationGUI.Mutiny'

     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'2K4Menus.NewControls.Display1'
         DropShadow=None
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.000000
         WinLeft=0.000000
         WinWidth=1.000000
         WinHeight=1.000000
         RenderWeight=0.000003
     End Object
     fBackGround=FloatingImage'commandandconquer.InformationGUI.FloatingFrameBackground'

     Begin Object Class=GUIScrollTextBox Name=GameHelp
         CharDelay=0.002500
         EOLDelay=0.500000
         OnCreateComponent=GameHelp.InternalOnCreateComponent
         WinTop=0.300000
         WinLeft=0.750000
         WinWidth=0.230000
         WinHeight=0.680000
         bTabStop=False
         bNeverFocus=True
     End Object
     HelpBox=GUIScrollTextBox'commandandconquer.InformationGUI.GameHelp'

     bAllowedAsLast=True
     WinHeight=1.000000
}
