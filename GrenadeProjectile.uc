#exec OBJ LOAD FILE=..\Sounds\MenuSounds.uax

class GrenadeProjectile extends Projectile;

var Emitter SmokeTrailEffect;
var bool bHitWater;
var vector Dir;

simulated function Destroyed()
{
	if ( SmokeTrailEffect != None )
		SmokeTrailEffect.Kill();
	Super.Destroyed();
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

simulated function PostBeginPlay()
{
	if ( Level.NetMode != NM_DedicatedServer)
        SmokeTrailEffect = Spawn(class'ONSTankFireTrailEffect',self);

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
    if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	Super.PostBeginPlay();
}

simulated function Landed( vector HitNormal )
{
	Explode(Location,HitNormal);
}

simulated function ProcessTouch (Actor Other, Vector HitLocation)
{
	if ( (Other != instigator) && (!Other.IsA('Projectile') || Other.bProjTarget) )
		Explode(HitLocation,Vect(0,0,1));
}

function BlowUp(vector HitLocation)
{
	HurtRadius(Damage, DamageRadius, MyDamageType, MomentumTransfer, HitLocation );
	MakeNoise(1.0);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	PlaySound(sound'WeaponSounds.BExplosion3',,5.5*TransientSoundVolume);
    if ( EffectIsRelevant(Location,false) )
    {
    	Spawn(class'ONSTankHitRockEffect',,,HitLocation + HitNormal*16, rotator(HitNormal) + rot(-16384,0,0));
		if ( (ExplosionDecal != None) && (Level.NetMode != NM_DedicatedServer) )
			Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
    }

	BlowUp(HitLocation);
	Destroy();
}

defaultproperties
{
     Speed=1200.000000
     MaxSpeed=1200.000000
     TossZ=0.000000
     bSwitchToZeroCollision=True
     Damage=130.000000
     DamageRadius=250.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'commandandconquer.DamTypeGLauncher'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.VMGrenade'
     CullDistance=5000.000000
     bNetTemporary=False
     bOnlyDirtyReplication=True
     Physics=PHYS_Falling
     LifeSpan=0.000000
     DrawScale=0.075000
     AmbientGlow=100
     bHardAttach=True
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bProjTarget=True
     bUseCollisionStaticMesh=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
