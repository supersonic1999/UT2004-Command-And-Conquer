Class XScout extends Scout
	NotPlaceable;

var XScout OtherSide;
var bool bImReady,bPositive,bFlyingPoint,bDidLand;
var NavigationPoint MyPoint;

function PreBeginPlay()
{
	Controller = Spawn(class'AIController');
	Controller.Pawn = Self;
}
function PostBeginPlay();
function ScanPoints( NavigationPoint Start, NavigationPoint End )
{
	SetPhysics(PHYS_Falling);
	OtherSide = Spawn(class'XScout',,,End.Location);
	if( OtherSide==None )
	{
		Destroy();
		Return;
	}
	OtherSide.OtherSide = Self;
	OtherSide.MyPoint = End;
	MyPoint = Start;
	SetTimer(0.35,False);
	OtherSide.SetPhysics(PHYS_Falling);
	OtherSide.SetTimer(0.35,False);
}
Auto state NothingAtAll
{
Ignores Bump,TakeDamage,Died;

}
event Landed(vector HitNormal)
{
	local byte MyFlag,OtherFlag;

	if( !bDidLand )
	{
		bDidLand = True;
		SetTimer(0.1,False);
		SetPhysics(PHYS_Walking);
		Return;
	}
	bImReady = True;
	bPositive = Controller.PointReachable(OtherSide.MyPoint.Location);
	if( OtherSide.bImReady )
	{
		if( bPositive && !bFlyingPoint )
		{
			if( MyPoint.PhysicsVolume.bWaterVolume )
				MyFlag = 4;
			else MyFlag = 1;
		}
		else MyFlag = 2;
		if( OtherSide.bPositive && !OtherSide.bFlyingPoint )
		{
			if( OtherSide.MyPoint.PhysicsVolume.bWaterVolume )
				OtherFlag = 4;
			else OtherFlag = 1;
		}
		else OtherFlag = 2;
		if( bPositive || OtherSide.bPositive )
			Class'AdvExecute'.Static.DefinePaths(MyPoint,OtherSide.MyPoint,MyFlag,OtherFlag,120,120);
		OtherSide.Destroy();
		Destroy();
	}
}
function Timer()
{
	if( bDidLand )
	{
		Landed(vect(0,0,0));
		Return;
	}
	if( PhysicsVolume.bWaterVolume )
	{
		SetPhysics(PHYS_Swimming);
		Velocity = vect(0,0,0);
		SetLocation(MyPoint.Location);
		bDidLand = True;
		SetTimer(0.1,False);
	}
	SetPhysics(PHYS_Flying);
	Velocity = vect(0,0,0);
	SetLocation(MyPoint.Location);
	bFlyingPoint = True;
	bDidLand = True;
	SetTimer(0.1,False);
}

defaultproperties
{
     Health=0
     bCollideWhenPlacing=True
     CollisionRadius=15.000000
     CollisionHeight=30.000000
     bCollideWorld=True
     bUseCylinderCollision=True
}
