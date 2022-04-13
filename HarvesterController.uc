class HarvesterController extends AIController;

var TiberiumTreeSpawn TibCrystal;
var TiberiumCrystal CollectingCrystal;
var TiberiumRef BestTarRef;
var vector CampingPos;
var float CampingTime,ForceTime,SuicideTime;
var bool bBeenVehicle,bRecentlySpawned,bThrottelTrubbel;

function Possess(Pawn aPawn)
{
	local Pawn OlPawn;

	OlPawn = Pawn;
	Super.Possess(aPawn);
	if( bBeenVehicle )
	{
		if( Vehicle(OlPawn)!=None && OlPawn.Health>0 )
			OlPawn.GibbedBy(None);
		if( !aPawn.IsA('Vehicle') )
			aPawn.GibbedBy(None);
		Destroy();
	}
	if( Vehicle(aPawn)!=None )
		bBeenVehicle = True;
}
simulated function int GetTeamNum()
{
	if( Vehicle(Pawn)==None )
		Return 0;
	return Vehicle(Pawn).Team;
}
function bool PickDestination(Actor MoveGoal)
{
	if( MoveGoal==None )
		Return False;
	if( ActorReachable(MoveGoal) )
		return True;
	bHunting = False;
	MoveTarget = FindPathToward(MoveGoal);
	return False;
}
function Actor FindClosestCrystal()
{
	local TiberiumTreeSpawn TC;
	local float Distance, SavedDistance;

	if( TibCrystal!=none && TibCrystal.HasResources() )
		return TibCrystal;

	TibCrystal = None;
	foreach DynamicActors(class'TiberiumTreeSpawn', TC)
	{
		if( TC.HasResources() )
		{
			Distance = TC.GetFieldPriority(Pawn.Location);
			if( TibCrystal==None || Distance>SavedDistance )
			{
				SavedDistance = Distance;
				TibCrystal = TC;
			}
		}
	}
	return TibCrystal;
}

function TiberiumRef FindClosestRefinery()
{
	local CCBuildings C,CC;
	local float Distance, SavedDistance;

	For( C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding )
	{
		if( C.Team==GetTeamNum() && C.bBuilt && TiberiumRef(C)!=None )
		{
			Distance = VSize(C.Location - Pawn.Location);
			if( CC==None || Distance<SavedDistance )
			{
				SavedDistance = Distance;
				CC = C;
			}
		}
	}
	Return TiberiumRef(CC);
}

state StartHarvesting
{
	function Timer()
	{
		if(Harvester(Pawn).Money >= Harvester(Pawn).MoneyMax)
			GoToState('EndHarvesting');
		if( CheckForCamping() )
			GoToState('StartHarvesting','UnGlitchMe');
	}
	function BeginState()
	{
		Vehicle(Pawn).ServerPlayHorn(0);
	}
Begin:
	if( !bRecentlySpawned )
	{
		MoveTo(Pawn.Location+vector(Pawn.Rotation)*(200+FRand()*1500));
		bRecentlySpawned = True;
	}
	BestTarRef = None;
	if(Harvester(Pawn).Money >= Harvester(Pawn).MoneyMax)
		GoToState('EndHarvesting');
	FindClosestCrystal();
	if( TibCrystal==None )
	{
		FocalPoint = Pawn.Location+vector(Pawn.Rotation)*2000;
		CampingTime = Level.TimeSeconds+10;
		Sleep(1);
	}
	else if( HasDirectSightTo(TibCrystal.Location,TibCrystal) )
	{
		MoveTo(PickMoveTowardSpot(TibCrystal.Location-Normal(TibCrystal.Location-Pawn.Location)*650,True));
		if( VSize(TibCrystal.Location-Pawn.Location)<1000 )
			GoTo'PickingFruits';
	}
	else if( PickDestination(TibCrystal.ClosestNode) )
	{
PickingFruits:
		CollectingCrystal = TibCrystal.PickOutTiberium();
		MoveToward(CollectingCrystal);
		CampingTime = Level.TimeSeconds+10;
		While( TibCrystal.HasResources() )
		{
			Sleep(0.25);
			MoveToward(TibCrystal.PickOutTiberium());
		}
	}
	else if(MoveTarget != None)
		MoveToward(MoveTarget);
	else MoveTo(PickMoveTowardSpot(TibCrystal.Location));
	GoTo'Begin';
UnGlitchMe:
	CampingTime = Level.TimeSeconds+15;
	MoveTo(Pawn.Location+VRand()*200);
	GoTo'Begin';
}
function vector PickMoveTowardSpot( vector Goal, optional bool bHasDirectTraced )
{
	local vector End,X,Y,Z;
	local rotator MoveR;
	local int Counter;

	GetAxes(Pawn.Rotation,X,Y,Z);
	End = Pawn.Location+Normal(Normal(Goal-Pawn.Location)*0.75 + X)*500;
	if( !WideFastTrace(Pawn.Location,End,Y*200) )
	{
		MoveR = rotator(Goal-Pawn.Location);
		MoveR.Yaw+=2000;
		End = Pawn.Location+vector(MoveR)*500;
		While( !FastTrace(Pawn.Location,End) )
		{
			MoveR.Yaw+=2000;
			End = Pawn.Location+vector(MoveR)*500;
			Counter++;
			if( Counter>20 )
				Return Pawn.Location+VRand()*200;
		}
		Return End;
	}
	Return End;
}
function bool WideFastTrace( vector Start, vector End, vector X )
{
	Return (FastTrace(Start,End) && FastTrace(Start+X,End+X) && FastTrace(Start-X,End-X));
}
state EndHarvesting
{
	function Timer()
	{
		if(Harvester(Pawn).Money <= 0)
			GoToState('StartHarvesting');
		if( CheckForCamping() )
			GoToState('EndHarvesting','UnGlitchMe');
	}
	function BeginState()
	{
		Vehicle(Pawn).ServerPlayHorn(0);
	}
Begin:
	if( BestTarRef==None )
		BestTarRef = FindClosestRefinery();
	if( BestTarRef==None )
		Sleep(1);
	else if( HasDirectSightTo(BestTarRef.Location,BestTarRef) )
		MoveTo(PickMoveTowardSpot(BestTarRef.Location,True));
	else if(PickDestination(BestTarRef.PickMoveGoal(Self)))
	{
		MoveToward(BestTarRef);
		CampingTime = Level.TimeSeconds+10;
		Sleep(0.5);
	}
	else if(MoveTarget != None)
		MoveToward(MoveTarget);
	else MoveTo(PickMoveTowardSpot(BestTarRef.Location));
	GoTo'Begin';
UnGlitchMe:
	CampingTime = Level.TimeSeconds+15;
	MoveTo(Pawn.Location+VRand()*200);
	GoTo'Begin';
}
function bool HasDirectSightTo( vector GoalPos, optional actor TracerActor )
{
	GoalPos.Z+=15;
	if( TracerActor!=None )
		TracerActor.bWorldGeometry = False;
	Return (FastTrace(GoalPos,Pawn.Location) && FastTrace(GoalPos,Pawn.Location+vect(45,0,0))
	 && FastTrace(GoalPos,Pawn.Location+vect(-45,0,0)));
	if( TracerActor!=None )
		TracerActor.bWorldGeometry = True;
}
function bool CheckForCamping()
{
	local int i;

	if( Vehicle(Pawn).Throttle==0 )
		bThrottelTrubbel = False;
	else if( VSize(Pawn.Velocity)<25 )
	{
		if( bThrottelTrubbel )
			Vehicle(Pawn).Throttle*=-1;
		bThrottelTrubbel = !bThrottelTrubbel;
	}
	if( CampingTime==-1 )
	{
		CampingPos = Pawn.Location;
		CampingTime = Level.TimeSeconds+15;
		ForceTime = Level.TimeSeconds+25;
		SuicideTime = Level.TimeSeconds+60;
		Return False;
	}
	if( VSize(CampingPos-Pawn.Location)<600 )
	{
		if( ForceTime<Level.TimeSeconds )
		{
			ForceTime = Level.TimeSeconds+5;
			Pawn.KAddImpulse(VRand()*10000,Pawn.Location);
		}
		if( SuicideTime<Level.TimeSeconds )
			Pawn.GibbedBy(None);
		if( CampingTime<Level.TimeSeconds )
		{
			For( i=0; i<5; i++ )
				AddRequiredPaths();
			CampingTime = Level.TimeSeconds+8;
			Return True;
		}
		Return False;
	}
	CampingPos = Pawn.Location;
	CampingTime = Level.TimeSeconds+15;
	ForceTime = Level.TimeSeconds+25;
	SuicideTime = Level.TimeSeconds+60;
	Return False;
}

function Restart()
{
	Super.Restart();
	SetTimer(0.5+FRand(),True);
	GoToState('StartHarvesting');
}
function AddRequiredPaths()
{
	local vector Start,End;
	local int C;

	Return;
	Start = Pawn.Location;
	Start.Z+=250;
	if( !FastTrace(Pawn.Location,Start) )
		Start.Z-=250;
	End = Start;
	End.X+=800*FRand()-400;
	End.Y+=800*FRand()-400;
	While( AlreadyAPath(End) )
	{
		End = Start;
		End.X+=2000*FRand()-1000;
		End.Y+=2000*FRand()-1000;
		C++;
		if( C>=5 )
			Return;
	}
	Start = End;
	End.Z-=1000;
	Start = FindGroundLoc(Start,End);
	if( Start!=vect(0,0,0) )
		Spawn(Class'AddedPathNode',,,Start);
}
function bool AlreadyAPath( vector Pos )
{
	local NavigationPoint N;
	local vector V;

	For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		V = Pos-N.Location;
		V.Z = 0;
		if( VSize(V)<500 )
			Return False;
	}
	Return True;
}
function vector FindGroundLoc( vector S, vector E )
{
	local vector HL,HN;

	if( Trace(HL,HN,E,S,False)!=None )
		Return HL+vect(0,0,40);
	Return vect(0,0,0);
}

defaultproperties
{
     CampingTime=-1.000000
}
