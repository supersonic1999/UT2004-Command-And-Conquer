class MRLSRocketProjectile extends SeekingRocketProj;

var vector DirectionLocation;

replication
{
    reliable if(bNetDirty && (Role==ROLE_Authority))
        DirectionLocation;
}

simulated function PostBeginPlay()
{
	if(Level.NetMode != NM_DedicatedServer)
	{
		SmokeTrail = Spawn(class'AGTTrailSmoke',self);
		Corona = Spawn(class'RocketCorona',self);
	}

	Dir = vector(Rotation);
	Velocity = speed * Dir;
	if(PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}

	super(Projectile).PostBeginPlay();
	SetTimer(0.1, true);
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

simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;

    if ( InitialDir == vect(0,0,0) )
        InitialDir = Normal(Velocity);

	Acceleration = vect(0,0,0);
    Super.Timer();
    if((DirectionLocation != vect(0,0,0)))
    {
		// Do normal guidance to target.
		ForceDir = Normal(DirectionLocation - Location);

		if( (ForceDir Dot InitialDir) > 0 )
		{
			VelMag = VSize(Velocity);

			ForceDir = Normal(ForceDir * 0.5 * VelMag + Velocity);
			Velocity =  VelMag * ForceDir;
			Acceleration += 5 * ForceDir;
		}
		// Update rocket so it faces in the direction its going.
		SetRotation(rotator(Velocity));
    }
}

defaultproperties
{
     Speed=2000.000000
     MaxSpeed=2000.000000
     Damage=40.000000
     DamageRadius=800.000000
     LifeSpan=15.000000
}
