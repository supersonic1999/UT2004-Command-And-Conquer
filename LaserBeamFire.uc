class LaserBeamFire extends InstantFire;

var() class<ShockBeamEffect> BeamEffectClass;

#exec OBJ LOAD FILE=..\Sounds\WeaponSounds.uax

function DoTrace(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum;

	MaxRange();

    ReflectNum = 0;
    while (true)
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        Other = Weapon.Trace(HitLocation, HitNormal, End, Start, true);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = true;
                HitNormal = Vect(0,0,0);
            }
            else if (Other.bCanBeDamaged)
            {
				Damage = DamageMin;
				if ( (DamageMin != DamageMax) && (FRand() > 0.5) )
					Damage += Rand(1 + DamageMax - DamageMin);
                Damage = Damage * DamageAtten;

				// Update hit effect except for pawns (blood) other than vehicles.
               	if ( Other.IsA('Vehicle') || (!Other.IsA('Pawn') && !Other.IsA('HitScanBlockingVolume')) )
					WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other, HitLocation, HitNormal);

               	Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
                HitNormal = Vect(0,0,0);
            }
            else if ( WeaponAttachment(Weapon.ThirdPersonActor) != None )
				WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
			WeaponAttachment(Weapon.ThirdPersonActor).UpdateHit(Other,HitLocation,HitNormal);
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if (bDoReflect && ++ReflectNum < 4)
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start = HitLocation;
            Dir = Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }
}

function DoFireEffect()
{
    local Vector StartTrace,X,Y,Z;
    local Rotator R, Aim;

    Instigator.MakeNoise(1.0);

    StartTrace = Instigator.Location + Instigator.EyePosition();
    if ( PlayerController(Instigator.Controller) != None )
    {
		// for combos
	   Weapon.GetViewAxes(X,Y,Z);
		StartTrace = StartTrace + X*class'ShockProjFire'.Default.ProjSpawnOffset.X;
		if ( !Weapon.WeaponCentered() )
			StartTrace = StartTrace + Weapon.Hand * Y*class'ShockProjFire'.Default.ProjSpawnOffset.Y + Z*class'ShockProjFire'.Default.ProjSpawnOffset.Z;
	}

    Aim = AdjustAim(StartTrace, AimError);
	R = rotator(vector(Aim) + VRand()*FRand()*Spread);
    DoTrace(StartTrace, R);
}

function InitEffects()
{
	if ( Level.DetailMode == DM_Low )
		FlashEmitterClass = None;
    Super.InitEffects();
    if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'tip');
}

// for bot combos
function Rotator AdjustAim(Vector Start, float InAimError)
{
	if ( (ShockRifle(Weapon) != None) && (ShockRifle(Weapon).ComboTarget != None) )
		return Rotator(ShockRifle(Weapon).ComboTarget.Location - Start);

	return Super.AdjustAim(Start, InAimError);
}

function SpawnBeamEffect(Vector Start, Rotator Dir, Vector HitLocation, Vector HitNormal, int ReflectNum)
{
    local ShockBeamEffect Beam;

    if (Weapon != None)
    {
        Beam = Weapon.Spawn(BeamEffectClass,,, Start, Dir);
        if (ReflectNum != 0) Beam.Instigator = None; // prevents client side repositioning of beam start
            Beam.AimAt(HitLocation, HitNormal);
    }
}

defaultproperties
{
     BeamEffectClass=Class'XWeapons.ShockBeamEffect'
     DamageType=Class'commandandconquer.DamTypeLaserBeam'
     DamageMin=10
     DamageMax=10
     TraceRange=17000.000000
     Momentum=0.000000
     bReflective=True
     FireSound=SoundGroup'WeaponSounds.ShockRifle.ShockRifleFire'
     FireForce="ShockRifleFire"
     FireRate=0.200000
     AmmoClass=Class'commandandconquer.LaserAmmo'
     AmmoPerFire=1
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=-8.000000)
     ShakeOffsetRate=(X=-600.000000)
     ShakeOffsetTime=3.200000
     BotRefireRate=0.700000
     FlashEmitterClass=Class'XEffects.ShockBeamMuzFlash'
     aimerror=700.000000
}
