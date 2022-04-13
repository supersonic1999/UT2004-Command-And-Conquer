class MRLSRocketCannon extends ONSWeapon;

var vector OldDir;
var rotator OldRot;
var int AmmoLeft, ReloadTime;

#exec OBJ LOAD FILE=..\Animations\ONSWeapons-A.ukx
#exec OBJ LOAD FILE=..\Textures\BenTex01.utx

static function StaticPrecache(LevelInfo L)
{
    L.AddPrecacheMaterial(Material'WeaponSkins.RocketShellTex');
    L.AddPrecacheMaterial(Material'XEffects.RocketFlare');
    L.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TankTrail');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    L.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    L.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick1');
    L.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    L.AddPrecacheMaterial(Material'EpicParticles.Smoke.SparkCloud_01aw');
    L.AddPrecacheMaterial(Material'BenTex01.Textures.SmokePuff01');
    L.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Part_explode2');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.HardSpot');
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'WeaponSkins.RocketShellTex');
    Level.AddPrecacheMaterial(Material'XEffects.RocketFlare');
    Level.AddPrecacheMaterial(Material'XEffects.SmokeAlphab_t');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TankTrail');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.SmokePanels2');
    Level.AddPrecacheMaterial(Material'ONSInterface-TX.tankBarrelAligned');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.TankFiringP.TankDustKick1');
    Level.AddPrecacheMaterial(Material'EmitterTextures.MultiFrame.rockchunks02');
    Level.AddPrecacheMaterial(Material'EpicParticles.Smoke.SparkCloud_01aw');
    Level.AddPrecacheMaterial(Material'BenTex01.Textures.SmokePuff01');
    Level.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Part_explode2');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.HardSpot');

    Super.UpdatePrecacheMaterials();
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');
	Super.UpdatePrecacheStaticMeshes();
}

simulated function ClientStartFire(Controller C, bool bAltFire)
{
    bIsAltFire = bAltFire;

	if(FireCountdown <= 0 && AmmoLeft > 0)
	{
		if(bIsRepeatingFF)
		{
			if(bIsAltFire)
				ClientPlayForceFeedback( AltFireForce );
			else
				ClientPlayForceFeedback( FireForce );
		}
		OwnerEffects();
	}
}

state ProjectileFireMode
{
    function Fire(Controller C)
    {
    	local Projectile p;
    	local Actor A;
    	local vector HitLocation, HitNormal, ViewLoc;
    	local rotator ViewRot;

    	Vehicle(Owner).SpecialCalcView(A, ViewLoc, ViewRot);
    	Owner.trace(HitLocation, HitNormal, ViewLoc+100000*vector(ViewRot), ViewLoc, true);

        if(AmmoLeft > 0)
    	{
            P = SpawnProjectile(ProjectileClass, False);
            MRLSRocketProjectile(P).DirectionLocation = HitLocation;
            AmmoLeft--;
            if(AmmoLeft <= 0)
                GoToState('Reload');
        }
        else
            GoToState('Reload');
    }

    function AltFire(Controller C)
    {
        local Projectile p;
        local Actor A;
        local vector HitLocation, HitNormal, ViewLoc;
        local rotator ViewRot;

    	Vehicle(Owner).SpecialCalcView(A, ViewLoc, ViewRot);
    	Owner.trace(HitLocation, HitNormal, ViewLoc+100000*vector(ViewRot), ViewLoc, true);

        if(AltFireProjectileClass == None)
            Fire(C);
        else if(AmmoLeft > 0)
        {
            P = SpawnProjectile(AltFireProjectileClass, True);
            MRLSRocketProjectile(P).DirectionLocation = HitLocation;
            AmmoLeft--;
            if(AmmoLeft <= 0)
                GoToState('Reload');
        }
        else
            GoToState('Reload');
    }
}

state Reload
{
    function Fire(Controller C);
    function AltFire(Controller C);

Begin:
    Sleep(ReloadTime);
    AmmoLeft = default.AmmoLeft;
    GoToState('ProjectileFireMode');
}

function byte BestMode()
{
	return 0;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	OldDir = Vector(CurrentAim);
}

function Tick(float Delta)
{
	local int i;
	local xPawn P;
	local vector NewDir, PawnDir;
    local coords WeaponBoneCoords;


    Super.Tick(Delta);

	if ( (Role == ROLE_Authority) && (Base != None) )
	{
	    WeaponBoneCoords = GetBoneCoords(YawBone);
		NewDir = WeaponBoneCoords.XAxis;
		if ( (Vehicle(Base).Controller != None) && (NewDir.Z < 0.9) )
		{
			for ( i=0; i<Base.Attached.Length; i++ )
			{
				P = XPawn(Base.Attached[i]);
				if ( (P != None) && (P.Physics != PHYS_None) && (P != Vehicle(Base).Driver) )
				{
					PawnDir = P.Location - WeaponBoneCoords.Origin;
					PawnDir.Z = 0;
					PawnDir = Normal(PawnDir);
					if ( ((PawnDir.X <= NewDir.X) && (PawnDir.X > OldDir.X))
						|| ((PawnDir.X >= NewDir.X) && (PawnDir.X < OldDir.X)) )
					{
						if ( ((PawnDir.Y <= NewDir.Y) && (PawnDir.Y > OldDir.Y))
							|| ((PawnDir.Y >= NewDir.Y) && (PawnDir.X < OldDir.Y)) )
						{
							P.SetPhysics(PHYS_Falling);
							P.Velocity = WeaponBoneCoords.YAxis;
							if ( ((NewDir - OldDir) dot WeaponBoneCoords.YAxis) < 0 )
								P.Velocity *= -1;
							P.Velocity = 500 * (P.Velocity + 0.3*NewDir);
							P.Velocity.Z = 200;
						}
					}
				}
			}
		}
		OldDir = NewDir;
	}
}

defaultproperties
{
     AmmoLeft=6
     ReloadTime=5
     YawBone="TankTurret"
     YawEndConstraint=0.000000
     PitchBone="TankBarrel"
     PitchUpLimit=9000
     PitchDownLimit=61500
     WeaponFireAttachmentBone="TankBarrel"
     WeaponFireOffset=200.000000
     RotationsPerSecond=0.150000
     Spread=0.015000
     RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     EffectEmitterClass=Class'Onslaught.ONSTankFireEffect'
     FireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     FireSoundVolume=512.000000
     AltFireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     FireForce="Explosion05"
     ProjectileClass=Class'commandandconquer.MRLSRocketProjectile'
     ShakeRotMag=(Z=250.000000)
     ShakeRotRate=(Z=2500.000000)
     ShakeRotTime=6.000000
     ShakeOffsetMag=(Z=10.000000)
     ShakeOffsetRate=(Z=200.000000)
     ShakeOffsetTime=10.000000
     AIInfo(0)=(bTrySplash=True,bLeadTarget=True,WarnTargetPct=0.750000,RefireRate=0.800000)
     Mesh=SkeletalMesh'ONSWeapons-A.HoverTankCannon'
}
