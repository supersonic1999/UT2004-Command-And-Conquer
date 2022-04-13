class RocketProj extends Projectile;

var bool bRing,bHitWater,bWaterStart;
var int NumExtraRockets;
var	xEmitter SmokeTrail;
var Effects Corona;
var byte FlockIndex;
var RocketProj Flock[2];

var() float	FlockRadius;
var() float	FlockStiffness;
var() float FlockMaxForce;
var() float	FlockCurlForce;
var bool bCurl;
var vector Dir;

replication
{
    reliable if ( bNetInitial && (Role == ROLE_Authority) )
        FlockIndex, bCurl;
}

simulated function Destroyed()
{
	if ( SmokeTrail != None )
		SmokeTrail.mRegen = False;
	if ( Corona != None )
		Corona.Destroy();
	Super.Destroyed();
}

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'RocketTrailSmoke',self);
		Corona = Spawn(class'RocketCorona',self);
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	local RocketProj R;
	local int i;
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if ( FlockIndex != 0 )
	{
	    SetTimer(0.1, true);

	    // look for other rockets
	    if ( Flock[1] == None )
	    {
			ForEach DynamicActors(class'RocketProj',R)
				if ( R.FlockIndex == FlockIndex )
				{
					Flock[i] = R;
					if ( R.Flock[0] == None )
						R.Flock[0] = self;
					else if ( R.Flock[0] != self )
						R.Flock[1] = self;
					i++;
					if ( i == 2 )
						break;
				}
		}
	}
    if ( Level.NetMode == NM_DedicatedServer )
		return;
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if ( (Instigator != None) && (PC == Instigator.Controller) )
			return;
		if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
		{
			bDynamicLight = false;
			LightType = LT_None;
		}
	}
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation, vector(rotation)*-1 );
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local PlayerController PC;

	PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'NewExplosionA',,,HitLocation + HitNormal*20,rotator(HitNormal));
    	PC = Level.GetLocalPlayerController();
		if ( (PC.ViewTarget != None) && VSize(PC.ViewTarget.Location - Location) < 5000 )
	        Spawn(class'ExplosionCrap',,, HitLocation + HitNormal*20, rotator(HitNormal));
//		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
//			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

simulated function Timer()
{
    local vector ForceDir, CurlDir;
    local float ForceMag;
    local int i;

	Velocity =  Default.Speed * Normal(Dir * 0.5 * Default.Speed + Velocity);

	// Work out force between flock to add madness
	for(i=0; i<2; i++)
	{
		if(Flock[i] == None)
			continue;

		// Attract if distance between rockets is over 2*FlockRadius, repulse if below.
		ForceDir = Flock[i].Location - Location;
		ForceMag = FlockStiffness * ( (2 * FlockRadius) - VSize(ForceDir) );
		Acceleration = Normal(ForceDir) * Min(ForceMag, FlockMaxForce);

		// Vector 'curl'
		CurlDir = Flock[i].Velocity cross ForceDir;
		if ( bCurl == Flock[i].bCurl )
			Acceleration += Normal(CurlDir) * FlockCurlForce;
		else
			Acceleration -= Normal(CurlDir) * FlockCurlForce;
	}
}

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	local PlayerController PC;

	if ( Role == ROLE_Authority )
	{
		if ( !Wall.bStatic && Wall.bCanBeDamaged)
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer)  )
	{
		if ( ExplosionDecal.Default.CullDistance != 0 )
		{
			PC = Level.GetLocalPlayerController();
			if ( !PC.BeyondViewDistance(Location, ExplosionDecal.Default.CullDistance) )
				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
			else if ( (Instigator != None) && (PC == Instigator.Controller) && !PC.BeyondViewDistance(Location, 2*ExplosionDecal.Default.CullDistance) )
				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
		}
		else
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
	}
	HurtWall = None;
}

defaultproperties
{
     FlockRadius=12.000000
     FlockStiffness=-40.000000
     FlockMaxForce=600.000000
     FlockCurlForce=450.000000
     Speed=1350.000000
     MaxSpeed=1350.000000
     Damage=60.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'commandandconquer.DamTypeRocket'
     ExplosionDecal=Class'XEffects.RocketMark'
     LightType=LT_Steady
     LightEffect=LE_QuadraticNonIncidence
     LightHue=28
     LightBrightness=255.000000
     LightRadius=5.000000
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.RocketProj'
     CullDistance=7500.000000
     bDynamicLight=True
     AmbientSound=Sound'WeaponSounds.RocketLauncher.RocketLauncherProjectile'
     LifeSpan=8.000000
     AmbientGlow=96
     FluidSurfaceShootStrengthMod=10.000000
     SoundVolume=255
     SoundRadius=100.000000
     bFixedRotationDir=True
     RotationRate=(Roll=50000)
     DesiredRotation=(Roll=30000)
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
}
