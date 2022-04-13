class CCMover extends Actor;

var float MoveTime,CurMovePos;
var vector StartPosition, EndPosition;
var bool PositionOne,bOldPosOne,bAcceptReplication,bIsMoving;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		StartPosition,EndPosition,PositionOne;
}

simulated function PostBeginPlay()
{
	Disable('Tick');
}

function Trigger(Actor Other, Pawn EventInstigator)
{
	Instigator = EventInstigator;
	if(!PositionOne)
	{
		if(bIsMoving)
			CurMovePos = Level.TimeSeconds+MoveTime-(CurMovePos-Level.TimeSeconds);
		else CurMovePos = Level.TimeSeconds+MoveTime;
		Enable('Tick');
		PositionOne = True;
		bIsMoving = True;
	}
}

function UnTrigger(Actor Other, Pawn EventInstigator)
{
	if( PositionOne )
	{
		if( bIsMoving )
			CurMovePos = Level.TimeSeconds+MoveTime-(CurMovePos-Level.TimeSeconds);
		else CurMovePos = Level.TimeSeconds+MoveTime;
		Enable('Tick');
		PositionOne = False;
		bIsMoving = True;
	}
}

simulated function Tick(float DeltaTime)
{
	if(CurMovePos < Level.TimeSeconds)
	{
		if(PositionOne)
			SetLocation(EndPosition);
		else SetLocation(StartPosition);
		bIsMoving = False;
		Disable('Tick');
	}
	else if(!PositionOne)
		SetLocation(StartPosition+(EndPosition-StartPosition)*((CurMovePos-Level.TimeSeconds)/MoveTime));
	else SetLocation(EndPosition+(StartPosition-EndPosition)*((CurMovePos-Level.TimeSeconds)/MoveTime));
}

function SetMoveLocation(vector SLocation, vector ELocation)
{
	StartPosition = SLocation;
	EndPosition = ELocation;
	SetLocation(SLocation);
	PositionOne = False;
}
/*simulated function PostNetBeginPlay()
{
	if( Level.NetMode!=NM_Client ) Return;
	bAcceptReplication = True;
	bOldPosOne = PositionOne;
	if( PositionOne )
		SetLocation(EndPosition);
	else SetLocation(StartPosition);
}
simulated function PostNetReceive()
{
	if( !bAcceptReplication || bOldPosOne==PositionOne )
		Return;
	bOldPosOne = PositionOne;
	if( bIsMoving )
		CurMovePos = Level.TimeSeconds+MoveTime-(CurMovePos-Level.TimeSeconds);
	else CurMovePos = Level.TimeSeconds+MoveTime;
	Enable('Tick');
	bIsMoving = True;
}*/

defaultproperties
{
     MoveTime=0.500000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'CommandAndConquerSM.Misc.Door'
     bActorShadows=True
     bUseDynamicLights=True
     bWorldGeometry=True
     bIgnoreEncroachers=True
     bReplicateInstigator=True
     bNetInitialRotation=True
     RemoteRole=ROLE_None
     bShadowCast=True
     bCollideActors=True
     bBlockActors=True
     bProjTarget=True
     bBlockKarma=True
     bNetNotify=True
     bEdShouldSnap=True
     bPathColliding=True
}
