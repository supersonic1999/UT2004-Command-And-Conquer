class CCReplicationInfo extends GameReplicationInfo;

var PlayerReplicationInfo CommanderRED, CommanderBLUE;
var CCMainController MainController;
var array<PlayerReplicationInfo> CommanderAppliersRED, CommanderAppliersBLUE, NODMutinyVoters, GDIMutinyVoters;
var array<PlayerController> OldCommanders;
var bool bHasInteraction, bAllowCustomSetup, bShieldUp, bClientOldShielded;
var int BuildTime, CommanderApplyTime, ServerTimeSeconds, BuildDisTime, MutinyStartNOD, MutinyVotesNOD, MutinyVotesGDI, MutinyStartGDI, NODFirstApply, GDIFirstApply;
var float NODCommanderMoney, GDICommanderMoney;
var color GDIChat;

var localized string CommanderResigned, CommanderRemoved;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
		BuildTime,ServerTimeSeconds,CommanderApplyTime,MutinyVotesNOD,MutinyVotesGDI,NODCommanderMoney,
        GDICommanderMoney,bShieldUp,CommanderRED,CommanderBLUE,bAllowCustomSetup;
    reliable if(Role<ROLE_Authority)
		GiveCmdMoney,StartTeamMutiny;
}

simulated function PreBeginPlay()
{
//    local CCMainController CMC;

    class'SayMessagePlus'.default.BlueTeamColor = GDIChat;

    Super.PreBeginPlay();
//    log("bAllowCustomSetup" @ bAllowCustomSetup);
//
//    if(MainController == none)
//    {
//        if(bAllowCustomSetup == True)
//        {
//            foreach DynamicActors(class'CCMainController', CMC)
//            {
//                if(CMC != none)
//                {
//                    MainController = CMC;
//                    return;
//                }
//            }
//        }
//        MainController = Spawn(class'CCMainController');
//    }
}

function StartTeamMutiny(PlayerController Other)
{
    if(Other.GetTeamNum() == 0)
    {
        MutinyVotesNOD = 1;
        NODMutinyVoters[NODMutinyVoters.Length] = Other.PlayerReplicationInfo;
        MutinyStartNOD = Level.TimeSeconds;
    }
    else
    {
        MutinyVotesGDI = 1;
        GDIMutinyVoters[GDIMutinyVoters.Length] = Other.PlayerReplicationInfo;
        MutinyStartGDI = Level.TimeSeconds;
    }
}

function GiveCmdMoney(float Amount, byte Team)
{
    if(Team == 0)
    {
        if(Amount < 0 && NODCommanderMoney - Amount < 0)
            Amount = NODCommanderMoney;
        NODCommanderMoney += Amount;
    }
    else
    {
        if(Amount < 0 && GDICommanderMoney - Amount < 0)
            Amount = GDICommanderMoney;
        GDICommanderMoney += Amount;
    }
}

simulated function Tick(float deltaTime)
{
	local PlayerController PC;
    local CCMainController CMC;
    local Controller C;
    local int RTN, BTN;

	if(Level.NetMode != NM_DedicatedServer && !bHasInteraction)
	{
        PC = Level.GetLocalPlayerController();
		if(PC != none && PC.Player != none && PC.Player.InteractionMaster != none)
		{
            PC.Player.InteractionMaster.AddInteraction("CommandAndConquer.CCInteraction", PC.Player);
			bHasInteraction = true;
		}
	}

    if(MainController == none && Level.TimeSeconds >= 5)
    {
        if(bAllowCustomSetup == True)
        {
            //log("1");
            foreach DynamicActors(class'CCMainController', CMC)
            {
                if(CMC != none)
                {
                    MainController = CMC;
                    break;
                }
            }
        }

        if(MainController == none)
            MainController = Spawn(class'CCMainController');
        //Log(Level.TimeSeconds @ CMC @ MainController @ bAllowCustomSetup);
    }

	if(ROLE == ROLE_Authority)
	{
	    if(bShieldUp && BuildDisTime < Level.TimeSeconds)
	    {
	        bShieldUp = False;
	        CheckBuildingShields();
        }

        if(MutinyVotesNOD >= 1)
        {
            for(C=Level.ControllerList; C!=None; C=C.NextController)
                if(C.GetTeamNum() == 0 && PlayerController(C) != none)
                    RTN++;
            if(MutinyVotesNOD >= ((RTN/100) * CCGameType(Level.Game).MutinyWinAmount))
            {
                for(C=Level.ControllerList; C!=None; C=C.NextController)
                    if(C.GetTeamNum() == 0 && PlayerController(C) != none)
                        PlayerController(C).ClientMessage(CommanderRED.PlayerName @ "was successfully removed from commander.");
                CommandController(CommanderRED.Owner).RemoveCommander(0, true, CommanderRemoved);
                MutinyVotesNOD = 0;
                NODMutinyVoters.Remove(0, NODMutinyVoters.Length);
            }
        }
        else if(MutinyVotesGDI >= 1)
        {
            for(C=Level.ControllerList; C!=None; C=C.NextController)
                if(C.GetTeamNum() == 0 && PlayerController(C) != none)
                    BTN++;
            if(MutinyVotesGDI >= ((BTN/100) * CCGameType(Level.Game).MutinyWinAmount))
            {
                for(C=Level.ControllerList; C!=None; C=C.NextController)
                    if(C.GetTeamNum() == 0 && PlayerController(C) != none)
                        PlayerController(C).ClientMessage(CommanderRED.PlayerName @ "was successfully removed from commander.");
                CommandController(CommanderBLUE.Owner).RemoveCommander(0, true, CommanderRemoved);
                MutinyVotesGDI = 0;
                GDIMutinyVoters.Remove(0, GDIMutinyVoters.Length);
            }
        }
        else if(MutinyVotesNOD >= 1 && Level.TimeSeconds >= (MutinyStartNOD + 60))
        {
            MutinyVotesNOD = 0;
            NODMutinyVoters.Remove(0, NODMutinyVoters.Length);
        }
        else if(MutinyVotesGDI >= 1 && Level.TimeSeconds >= (MutinyStartGDI + 60))
        {
            MutinyVotesGDI = 0;
            GDIMutinyVoters.Remove(0, GDIMutinyVoters.Length);
        }

    	if(Level.TimeSeconds >= (NODFirstApply + CommanderApplyTime) && CommanderRED == none && CommanderAppliersRED.Length >= 1)
    	{
            CommanderRED = CommanderAppliersRED[rand(CommanderAppliersRED.Length)];
            CommanderAppliersRED.Remove(0, CommanderAppliersRED.Length);
            PlayerController(CommanderRED.Owner).ClientMessage("You are now the commander of the NOD team! Press (insert) to open commander menu.");
    	}
    	else if(Level.TimeSeconds >= (GDIFirstApply + CommanderApplyTime) && CommanderBLUE == none && CommanderAppliersBLUE.Length >= 1)
    	{
            CommanderBLUE = CommanderAppliersBLUE[rand(CommanderAppliersBLUE.Length)];
            CommanderAppliersBLUE.Remove(0, CommanderAppliersBLUE.Length);
            PlayerController(CommanderBLUE.Owner).ClientMessage("You are now the commander of the GDI team! Press (insert) to open commander menu.");
    	}
	}
	super.Tick(DeltaTime);
}

function MatchStarting()
{
    bShieldUp = True;
	BuildDisTime = Level.TimeSeconds + BuildTime;
	CheckBuildingShields();
}

simulated function CheckBuildingShields()
{
	local CCBuildings C;

	if(Level.NetMode == NM_DedicatedServer)
        Return;

	for(C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding)
		C.SetShieldSkin(bShieldUp);
}

simulated function PostNetReceive()
{
	if(bClientOldShielded == bShieldUp)
		Return;

	bClientOldShielded = bShieldUp;
	CheckBuildingShields();
}

defaultproperties
{
     GDIChat=(G=150,R=150,A=255)
     CommanderResigned="You resigned as commander of your team."
     CommanderRemoved="You were removed from your command by your team."
     bNetNotify=True
}
