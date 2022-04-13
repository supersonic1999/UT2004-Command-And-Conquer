class CCGameType extends xTeamGame
    config(CommandAndConquer);

#exec OBJ LOAD FILE="..\Textures\CommandAndConquerTEX.utx"

var config int BuildTime, CommanderApplyTime, StartingMoney;
var config byte MaxVehicles, MutinyWinAmount;
var config class<BaseCharacterModifier> DefaultCharacterClass;
var config bool bAllowCustomSetup;
var array<string> WebDescString, WebDisplayText;
var(LoadingHints) private localized array<string> CCHints;

function PreBeginPlay()
{
    local SVehicleFactory S;
    local Vehicle V;
    local CACRules G;

    Super.PreBeginPlay();

    CCReplicationInfo(GameReplicationInfo).BuildTime = BuildTime;
    CCReplicationInfo(GameReplicationInfo).CommanderApplyTime = CommanderApplyTime;
    CCReplicationInfo(GameReplicationInfo).bAllowCustomSetup = bAllowCustomSetup;
    CCReplicationInfo(GameReplicationInfo).NODCommanderMoney = StartingMoney;
    CCReplicationInfo(GameReplicationInfo).GDICommanderMoney = StartingMoney;

    foreach DynamicActors(class'SVehicleFactory', S)
    {
        S.VehicleCount += 10;
        S.MaxVehicleCount = 0;
    }

    foreach DynamicActors(class'Vehicle', V)
        V.Destroy();

    G = Spawn(class'CACRules');

	if(Level.Game.GameRulesModifiers != None)
		G.NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = G;
}

function bool AllowTransloc()
{
	return false;
}

static function string GetNextLoadHint( string MapName )
{
	local array<string> Hints;

	if ( Rand(100) < 90 )
		Hints = GetAllLoadHints(true);
	else Hints = GetAllLoadHints();

    log(Hints.Length);

	if ( Hints.Length > 0 )
		return Hints[Rand(Hints.Length)];

	return "";
}

static function array<string> GetAllLoadHints(optional bool bThisClassOnly)
{
	local int i;
	local array<string> Hints;

	if ( !bThisClassOnly )
		Hints = Super.GetAllLoadHints();

	for ( i = 0; i < default.CCHints.Length; i++ )
		Hints[Hints.Length] = default.CCHints[i];

	return Hints;
}

function bool ChangeTeam(Controller Other, int num, bool bNewTeam)
{
    local int i;
    local bool ChangedTeam;

    ChangedTeam = super.ChangeTeam(Other, num, bNewTeam);

    if(ChangedTeam && Other != none)
    {
        if(CommandController(Other) != none)
            CommandController(Other).ResetMoney();

        if(Other.GetTeamNum() == 0)
        {
            for(i=0;i<CCReplicationInfo(GameReplicationInfo).CommanderAppliersRED.Length;i++)
                if(CCReplicationInfo(GameReplicationInfo).CommanderAppliersRED[i] == Other.PlayerReplicationInfo)
                    CCReplicationInfo(GameReplicationInfo).CommanderAppliersRED.Remove(i, 1);

            for(i=0;i<CCReplicationInfo(GameReplicationInfo).NODMutinyVoters.Length;i++)
            {
                if(CCReplicationInfo(GameReplicationInfo).NODMutinyVoters[i] == Other.PlayerReplicationInfo)
                {
                    CCReplicationInfo(GameReplicationInfo).NODMutinyVoters.Remove(i, 1);
                    CCReplicationInfo(GameReplicationInfo).MutinyVotesNOD--;
                }
            }
        }
        else
        {
            for(i=0;i<CCReplicationInfo(GameReplicationInfo).CommanderAppliersBLUE.Length;i++)
                if(CCReplicationInfo(GameReplicationInfo).CommanderAppliersBLUE[i] == Other.PlayerReplicationInfo)
                    CCReplicationInfo(GameReplicationInfo).CommanderAppliersBLUE.Remove(i, 1);

            for(i=0;i<CCReplicationInfo(GameReplicationInfo).GDIMutinyVoters.Length;i++)
            {
                if(CCReplicationInfo(GameReplicationInfo).GDIMutinyVoters[i] == Other.PlayerReplicationInfo)
                {
                    CCReplicationInfo(GameReplicationInfo).GDIMutinyVoters.Remove(i, 1);
                    CCReplicationInfo(GameReplicationInfo).MutinyVotesGDI--;
                }
            }
        }

        if(Other.PlayerReplicationInfo == CCReplicationInfo(GameReplicationInfo).CommanderBLUE
        || Other.PlayerReplicationInfo == CCReplicationInfo(GameReplicationInfo).CommanderRED)
            CommandController(Other).RemoveCommander(Other.GetTeamNum(), false, CCReplicationInfo(GameReplicationInfo).CommanderResigned);
    }
    return ChangedTeam;
}

function NotifyLogout(Controller Exiting)
{
    local int i;

    if(Exiting.GetTeamNum() == 0)
    {
        for(i=0;i<CCReplicationInfo(GameReplicationInfo).CommanderAppliersRED.Length;i++)
            if(CCReplicationInfo(GameReplicationInfo).CommanderAppliersRED[i] == PlayerController(Exiting))
                CCReplicationInfo(GameReplicationInfo).CommanderAppliersRED.Remove(i, 1);

        for(i=0;i<CCReplicationInfo(GameReplicationInfo).NODMutinyVoters.Length;i++)
        {
            if(CCReplicationInfo(GameReplicationInfo).NODMutinyVoters[i] == Exiting)
            {
                CCReplicationInfo(GameReplicationInfo).NODMutinyVoters.Remove(i, 1);
                CCReplicationInfo(GameReplicationInfo).MutinyVotesNOD--;
            }
        }
    }
    else
    {
        for(i=0;i<CCReplicationInfo(GameReplicationInfo).CommanderAppliersBLUE.Length;i++)
            if(CCReplicationInfo(GameReplicationInfo).CommanderAppliersBLUE[i] == PlayerController(Exiting))
                CCReplicationInfo(GameReplicationInfo).CommanderAppliersBLUE.Remove(i, 1);

        for(i=0;i<CCReplicationInfo(GameReplicationInfo).GDIMutinyVoters.Length;i++)
        {
            if(CCReplicationInfo(GameReplicationInfo).GDIMutinyVoters[i] == Exiting)
            {
                CCReplicationInfo(GameReplicationInfo).GDIMutinyVoters.Remove(i, 1);
                CCReplicationInfo(GameReplicationInfo).MutinyVotesGDI--;
            }
        }
    }

    super.NotifyLogout(Exiting);
}

function bool CanEnterVehicle(Vehicle V, Pawn P)
{
    if(V != none && Harvester(V) == none && V.Health > 0 && V.bSpawnProtected && P.Controller != none && V.Owner != P.Controller)
    {
        P.ClientMessage("This is not your vehicle!");
        PlayerController(P.Controller).ClientPlaySound(sound'MenuSounds.Denied1');
        return false;
    }
    return Super.CanEnterVehicle(V, P);
}

function Bot SpawnBot(optional string botName)
{
    local Bot NewBot;
    local RosterEntry Chosen;
    local UnrealTeamInfo BotTeam;

    BotTeam = GetBotTeam();
    Chosen = BotTeam.ChooseBotClass(botName);

    Chosen.PawnClassName = "CommandAndConquer.CCBot";
    Chosen.PawnClass = class'CommandAndConquer.CCBot';

    NewBot = Bot(Spawn(Chosen.PawnClass.default.ControllerClass));

    if(NewBot != None)
        InitializeBot(NewBot,BotTeam,Chosen);
    return NewBot;
}

function GetServerDetails( out ServerResponseLine ServerState )
{
	Super.GetServerDetails( ServerState );
	ServerState.GameType = "ONSOnslaughtGame";
}

function RestartPlayer(Controller aPlayer)
{
    local CCINV Inv;
    local BaseCharacterModifier PClass;

    Super.RestartPlayer(aPlayer);

    if(aPlayer != none && aPlayer.Pawn != none)
    {
        if(xPawn(aPlayer.Pawn) != none)
        {
            xPawn(aPlayer.Pawn).MaxMultiJump = 0;
            xPawn(aPlayer.Pawn).MultiJumpRemaining = 0;
        }
        Inv = CCINV(aPlayer.Pawn.FindInventoryType(class'CCINV'));
    	if(Inv == None)
    	{
    		Inv = aPlayer.Pawn.spawn(class'CCINV', aPlayer.Pawn,,, rot(0,0,0));
    		if(Inv != None)
    		{
        		Inv.giveTo(aPlayer.Pawn);
        		Inv.VMax = MaxVehicles;
    		}
    	}

    	if(aPlayer.GetTeamNum() != 0)
    	    PClass = BaseCharacterModifier(aPlayer.Pawn.FindInventoryType(CCReplicationInfo(GameReplicationInfo).MainController.GDIBasic[0]));
	    else
	        PClass = BaseCharacterModifier(aPlayer.Pawn.FindInventoryType(CCReplicationInfo(GameReplicationInfo).MainController.NODBasic[0]));
    	if(PClass == None)
    	{
    		if(aPlayer.GetTeamNum() != 0)
                PClass = aPlayer.Pawn.spawn(CCReplicationInfo(GameReplicationInfo).MainController.GDIBasic[0], aPlayer.Pawn,,, rot(0,0,0));
            else
                PClass = aPlayer.Pawn.spawn(CCReplicationInfo(GameReplicationInfo).MainController.NODBasic[0], aPlayer.Pawn,,, rot(0,0,0));
    		if(PClass != None)
    		{
        		PClass.giveTo(aPlayer.Pawn);
        		PClass.Instigator = aPlayer.Pawn;
    		}
    	}
	}
}

function CheckScore(PlayerReplicationInfo Scorer);

function CheckBuildingsDestroyed()
{
	local int RedBuildingCount, BlueBuildingCount;
    local CCBuildings Buildings;
    local PlayerReplicationInfo Winner;
    local Actor TeamWinner;
    local Controller P;

    foreach DynamicActors(class'CCBuildings', Buildings)
    {
        if(Buildings != none && Buildings.Health > 0 && Buildings.bNeedsToBeDestroyed)
        {
            if(Buildings.Team == 0)
                RedBuildingCount++;
            else
                BlueBuildingCount++;
        }
    }

    if(RedBuildingCount == 0 || BlueBuildingCount == 0)
    {
    	if(RedBuildingCount == 0)
            TeamWinner = Teams[1];
        else
            TeamWinner = Teams[0];

        if(Winner == none)
    	{
    		for(P=Level.ControllerList; P!=None; P=P.nextController )
    			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == TeamWinner)
    				&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)))
    			{
    				Winner = P.PlayerReplicationInfo;
    			}
    	}
        EndGame(Winner, "BuildingsDestroyed");
    }
}

function int ReduceDamage( int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType )
{
    if(ONSVehicle(injured) != none && !ONSVehicle(injured).bNonHumanControl
    && !ONSVehicle(injured).bSpawnProtected && ONSVehicle(injured).NumPassengers() == 0)
        return Damage;
    return Super.ReduceDamage( Damage,injured,instigatedBy,HitLocation,Momentum,DamageType );
}

//function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
//{
//	local Controller P;
//	local int RedBuildingCount, BlueBuildingCount;
//    local CCBuildings Buildings;
//
//    log("CheckEndGame()" @ Reason);
//    if(Reason ~= "BuildingsDestroyed")
//    {
//    	if ((GameRulesModifiers != None) && !GameRulesModifiers.CheckEndGame(Winner, Reason) )
//    		return false;
//
//        foreach DynamicActors(class'CCBuildings', Buildings)
//        {
//            if(Buildings != none && Buildings.Health > 0 && Buildings.bNeedsToBeDestroyed == True)
//            {
//                if(Buildings.Team == 0)
//                    RedBuildingCount++;
//                else
//                    BlueBuildingCount++;
//            }
//        }
//
//        if(RedBuildingCount == 0 || BlueBuildingCount == 0)
//        {
//        	if(RedBuildingCount == 0)
//                GameReplicationInfo.Winner = Teams[1];
//            else
//                GameReplicationInfo.Winner = Teams[0];
//
//        	if(Winner == none)
//        	{
//        		for(P=Level.ControllerList; P!=None; P=P.nextController )
//        			if ( (P.PlayerReplicationInfo != None) && (P.PlayerReplicationInfo.Team == GameReplicationInfo.Winner)
//        				&& ((Winner == None) || (P.PlayerReplicationInfo.Score > Winner.Score)))
//        			{
//        				Winner = P.PlayerReplicationInfo;
//        			}
//        	}
//
//        	EndTime = Level.TimeSeconds + EndTimeDelay;
//            bGameEnded = true;
//            TriggerEvent('EndGame', self, None);
//            GotoState('MatchOver');
//            EndLogging("Base Destoyed");
//        	SetEndGameFocus(Winner);
//        	return true;
//    	}
//    	else
//    	    return false;
//	}
//	else
//	    return Super.CheckEndGame(Winner, Reason);
//}

function EndGame(PlayerReplicationInfo Winner, string Reason)
{
    //log("EndGame()" @ Reason);
    if(Reason ~= "BuildingsDestroyed")
    {
        super(UnrealMPGameInfo).EndGame(Winner,Reason);
        if(bGameEnded)
            GotoState('MatchOver');
    }
    else
        super.EndGame(Winner,Reason);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

    Super.FillPlayInfo(PlayInfo);
	PlayInfo.AddSetting(default.GameGroup, "BuildTime", default.WebDisplayText[i++], 10, 1, "Text", "300;0:1200",,,True);
	PlayInfo.AddSetting(default.GameGroup, "MaxVehicles", default.WebDisplayText[i++], 10, 1, "Text", "5;0:16",,,True);
	PlayInfo.AddSetting(default.GameGroup, "CommanderApplyTime", default.WebDisplayText[i++], 10, 1, "Text", "60;60:1200",,,True);
	PlayInfo.AddSetting(default.GameGroup, "bAllowCustomSetup", default.WebDisplayText[i++], 10, 1, "Check");
	PlayInfo.AddSetting(default.GameGroup, "StartingMoney", default.WebDisplayText[i++], 10, 1, "Text", "4000;0:30000",,,True);
	PlayInfo.AddSetting(default.GameGroup, "MutinyWinAmount", default.WebDisplayText[i++], 10, 1, "Text", "50;1:100",,,True);
}

static event string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "BuildTime": return default.WebDescString[0];
		case "MaxVehicles": return default.WebDescString[1];
		case "CommanderApplyTime": return default.WebDescString[2];
		case "bAllowCustomSetup": return default.WebDescString[3];
		case "StartingMoney": return default.WebDescString[4];
		case "MutinyWinAmount": return default.WebDescString[5];
	}
	return Super.GetDescriptionText(PropName);
}

defaultproperties
{
     BuildTime=300
     CommanderApplyTime=60
     StartingMoney=4000
     MaxVehicles=10
     MutinyWinAmount=51
     DefaultCharacterClass=Class'commandandconquer.SoldierModifier'
     bAllowCustomSetup=True
     WebDescString(0)="The time allowed to get resources without risking loosing your base."
     WebDescString(1)="The max vehicles a team can get."
     WebDescString(2)="The time starting from the start of the level from which you can apply to be commander."
     WebDescString(3)="Allows the maker of the map to place a actor in the map to change what can be build and costs ect..."
     WebDescString(4)="The amount of money avaliable to the commander of the team at game start."
     WebDescString(5)="The percentage of votes there must be for a successful mutiny."
     WebDisplayText(0)="Protect Buildings Time"
     WebDisplayText(1)="Max Vehicles Per Team"
     WebDisplayText(2)="Commander Apply Time"
     WebDisplayText(3)="Allow Custom Terminal Setup?"
     WebDisplayText(4)="Commander Starting Money"
     WebDisplayText(5)="Mutiny Vote Win(%)"
     CCHints(0)="If there is no commander you can apply by pressing PAGE UP."
     CCHints(1)="If you are commander pressing INSERT will open the commander view, which is how your team builds buildings."
     CCHints(2)="The objective of this gametype is to destroy the enemy base before they destroy yours."
     CCHints(3)="Attacking the Master Control Terminal inside buildings does much more damage than attacking the shell."
     CCHints(4)="To buy vehicles / weapons ect you need to press %Use% near a purchase terminal in one of your teams buildings which will open the purchase menu."
     CCHints(5)="Take the harvester to the nearest tiberium field and wait till its full, then return to your teams Tiberium Refinery to get lots of money."
     CCHints(6)="Destroying the enemies Power Plant makes thier main base defence and radar not work and it also double the cost of vehicles and characters they can buy."
     CCHints(7)="The Construction Yard is the main building for each team, without it they will no longer be able to build buildings."
     CCHints(8)="Without a Barracks or Hand Of Nod you cannot build any better characters."
     CCHints(9)="Without a War Factory or Air Strip you cannot build any ground vehicles."
     CCHints(10)="Without a Helipad you cannot build any air vehicles."
     bSpawnInTeamArea=True
     DefaultEnemyRosterClass="CommandAndConquer.CCRoster"
     bAllowVehicles=True
     DefaultPlayerClassName="CommandAndConquer.CCPawn"
     ScoreBoardType="CommandAndConquer.ScoreBoardCommandConquer"
     HUDType="CommandAndConquer.HudCommandAndConquer"
     MapPrefix="CnC"
     PlayerControllerClass=Class'commandandconquer.CommandController'
     GameReplicationInfoClass=Class'commandandconquer.CCReplicationInfo'
     GameName="Command And Conquer"
     Description="Two teams battle for the domination of a battlefield with everything from Nukes to Pistols at thier disposal."
     Acronym="CnC"
}
