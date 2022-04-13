class Obelisk_Weapon_Fire extends FM_BallTurret_Fire;

var class<Obelisk_Fire_Effect> BeamEffectClass;
var int DamageRadius, Damage;
var() sound HitSound;
var class<DamageType> DamageType;

function DoFireEffect()
{
    local vector HitLocation, HitNormal;

    if(Instigator != none)
    {
        Trace(HitLocation, HitNormal, ASTurret(Instigator).Controller.Enemy.Location, Instigator.Location, true);
    	SpawnBeamEffect(Instigator.Location, Instigator.Rotation, HitLocation, HitNormal);
    	Instigator.MakeNoise(1.0);
	}
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal)
{
	local Obelisk_Fire_Effect Beam;

	Beam = Weapon.spawn(BeamEffectClass,,, Start, Dir);
	Beam.SetDrawScale(8);
	Beam.HitLocation = HitLocation;

    Instigator.HurtRadius(Damage, DamageRadius, DamageType, 0.f, HitLocation);
    Owner.PlaySound(HitSound, SLOT_None, 255,, float(DamageRadius));

	if (Level.NetMode != NM_DedicatedServer)
		Beam.SetupBeam();
}

defaultproperties
{
     BeamEffectClass=Class'commandandconquer.Obelisk_Fire_Effect'
     DamageRadius=200
     Damage=300
     HitSound=Sound'ONSVehicleSounds-S.Explosions.VehicleExplosion05'
     DamageType=Class'commandandconquer.ObeliskDT'
     ProjSpawnOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     bLeadTarget=False
     FireRate=6.000000
}
