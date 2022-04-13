class TiberiumRef extends CCBuildings;

var Harvester H;
var vector HarvLoc;
var() float HarvesterRespawnTime;
var float HarvesterDisappearTime;
var bool bBeenMissing,bMatchHasBegun;

simulated function Destroyed()
{
	local CCBuildings C;

	Super.Destroyed();
	if(Level.NetMode != NM_Client)
	{
		if(H != none && H.Health > 0)
			H.GibbedBy(None);

		if(TActor == None)
            Return;

		for(C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding)
			if(C != self && C.Team == Team && C.CanHoldTiberium())
				Return;
		TActor.Destroy();
	}
}

function NavigationPoint PickMoveGoal( Controller Seeker )
{
	local NavigationPoint N,BN;
	local float D,BD;

	for(N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint)
	{
		if(N.PathList.Length > 0 && N.Region.Zone == Region.Zone)
		{
			D = VSize(N.Location-Location);
			if(BN == None || D < BD)
			{
				BN = N;
				BD = D;
			}
		}
	}
	Return BN;
}

function Timer()
{
	if(ClientBuildingState == 1)
	{
		ClientBuildingState = 0;
		FullyBuilt();
		Return;
	}
	else if(ClientBuildingState == 2)
	{
		CCReplicationInfo(Level.GRI).GiveCmdMoney((BuildCost/2)*((1.f/default.Health)*Health), Team);
		Destroy();
	}
	else if(bIsInitialActor && bMatchHasBegun)
	{
		bIsInitialActor = False;
		SpawnHarvester(True);
		SetTimer(1,True);
	}
	else if(H != none)
	{
		bBeenMissing = False;
		HarvLoc = H.Location;
	}
	else if(H == None || H.Health <= 0)
	{
		if( bBeenMissing && HarvesterDisappearTime<Level.TimeSeconds )
			SpawnHarvester(False);
		else if(!bBeenMissing)
		{
			bBeenMissing = True;
			HarvesterDisappearTime = Level.TimeSeconds+HarvesterRespawnTime;
		}
	}
}

simulated function bool CanHoldTiberium()
{
	Return True;
}

function FullyBuilt()
{
	super.FullyBuilt();
	SpawnHarvester(True);
}

function MatchStarting()
{
	bMatchHasBegun = True;
	if(ClientBuildingState == 0)
		SetTimer(0.1,False);
}

function SpawnHarvester(bool bFirstSpawn)
{
	local VehicleBuilding ClosestVB, TeamVB;
	local CCBuildings C;
	local float Distance, SavedDistance;

	if(bIsInitialActor && !bMatchHasBegun || H != none)
		Return;

	if(bFirstSpawn)
		if(SpawnHarvesterAt(SpawnOffsets[0], GetViewRotation()) != none)
			return;

	for(C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding)
	{
		TeamVB = VehicleBuilding(C);
		if(TeamVB != none && TeamVB.Team == Team && TeamVB.bBuilt)
		{
			Distance = VSize(TeamVB.Location - HarvLoc);
			if(ClosestVB == none || Distance < SavedDistance)
			{
				SavedDistance = Distance;
				ClosestVB = TeamVB;
			}
		}
	}

	if(ClosestVB != none)
		SpawnHarvesterAt(ClosestVB.SpawnOffsets[0],ClosestVB.GetViewRotation());
}

function Harvester SpawnHarvesterAt( vector Position, rotator R )
{
	local XPawn Ha;

	H = Spawn(class'Harvester',self,,Position,R);

	if(H == none)
		return None;

	Ha = Spawn(class'SpawnPawn',,,H.Location);
	if(Ha == none)
	{
		H.Destroy();
		Return None;
	}
	else if(HA.Controller == none)
	{
		HA.Controller = Spawn(HA.ControllerClass);
		HA.Controller.Pawn = HA;
	}
	H.KDriverEnter(Ha);
	H.Controller.Restart();
	H.SpawnTeam = Team;
	H.SetTeamNum(Team);
	H.Team = Team;
	return H;
}

defaultproperties
{
     HarvesterRespawnTime=30.000000
     Door(0)=(DoorOffset=(X=356.000000,Y=-149.000000,Z=-968.000000))
     Door(1)=(DoorOffset=(X=-262.000000,Y=878.000000,Z=-968.000000))
     PlayerStartLoc(0)=(PLocation=(X=-141.000000,Y=648.000000,Z=-1025.000000))
     PlayerStartLoc(1)=(PLocation=(X=-141.000000,Y=925.000000,Z=-1025.000000))
     PlayerStartLoc(2)=(PLocation=(X=126.000000,Y=647.000000,Z=-1025.000000))
     PlayerStartLoc(3)=(PLocation=(X=126.000000,Y=647.000000,Z=-1025.000000))
     PlayerStartLoc(4)=(PLocation=(X=-120.000000,Y=77.000000,Z=-1025.000000))
     PlayerStartLoc(5)=(PLocation=(X=125.000000,Y=78.000000,Z=-1025.000000))
     RedSkin=Texture'CommandAndConquerTEX.BuildingTEX.RefTEX'
     BlueSkin=Texture'CommandAndConquerTEX.BuildingTEX.RefTEXGDI'
     BuildingImage=Texture'CommandAndConquerTEX.BuildingPICS.TiberiumRefPIC'
     BuildingName="Tiberium Refinery"
     RequestedTimerRate=1.000000
     StartPositionNum=2000
     EndPositionNum=1050
     BuildDuration=10
     MaxAmount=-1
     BuildCost=2000
     Health=3500
     MCTOffset=(X=-129.000000,Y=541.000000,Z=-986.000000)
     MCTRotation=(Yaw=-49152)
     SwitchOffsets(0)=(X=18.000000,Y=390.000000,Z=-960.000000)
     SwitchOffsets(1)=(X=146.000000,Y=1005.000000,Z=-960.000000)
     SwitchOffsets(2)=(X=-115.000000,Y=1005.000000,Z=-960.000000)
     SpawnOffsets(0)=(X=800.000000,Y=200.000000,Z=-500.000000)
     TerminalRot(1)=(Yaw=-16384)
     TerminalRot(2)=(Yaw=-16384)
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.TiberiumRef'
     CollisionRadius=1500.000000
}
