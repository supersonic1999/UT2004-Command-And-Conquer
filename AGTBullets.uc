class AGTBullets extends PROJ_TurretSkaarjPlasma;

var xEmitter Trail;

simulated function Destroyed()
{
    if(Trail != None)
		Trail.mRegen=False;
	Super.Destroyed();
}

simulated function SetupProjectile()
{
    if(Level.NetMode != NM_DedicatedServer )
    {
        if(!PhysicsVolume.bWaterVolume)
        {
            Trail = Spawn(class'FlakTrail', self);
            Trail.Lifespan = Lifespan;
            Trail.SetBase( self );
        }
    }
}

simulated function SpawnExplodeFX(vector HitLocation, vector HitNormal);

defaultproperties
{
     Speed=20000.000000
     MaxSpeed=20000.000000
     Damage=2.000000
     MomentumTransfer=0.000000
     MyDamageType=Class'commandandconquer.AGTDT'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'WeaponStaticMesh.FlakChunk'
     LifeSpan=1.250000
     DrawScale=5.000000
}
