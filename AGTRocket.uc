class AGTRocket extends SeekingRocketProj;

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

simulated function Timer()
{
    local vector ForceDir;
    local float VelMag;

    if(InitialDir == vect(0,0,0))
        InitialDir = Normal(Velocity);

	Acceleration = vect(0,0,0);
    Super.Timer();

    if((Seeking != None) && (Seeking != Instigator))
    {
	    ForceDir = Normal(Seeking.Location - Location);
        VelMag = VSize(Velocity);
		Velocity =  VelMag * ForceDir;
		Acceleration += 5 * ForceDir;
		SetRotation(rotator(Velocity));
    }
}

defaultproperties
{
     Speed=5000.000000
     MaxSpeed=5000.000000
     Damage=100.000000
     DamageRadius=200.000000
     MyDamageType=Class'commandandconquer.AGTDT'
     LifeSpan=5.000000
     DrawScale=2.000000
}
