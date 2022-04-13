class ChaingunFire extends InstantFire;

var() float MaxRollSpeed;
var() float RollSpeed;
var() float BarrelRotationsPerSec;
var() int   RoundsPerRotation;
var() float FireTime;
var() sound WindingSound;
var() sound FiringSound;
var() byte	MinigunSoundVolume;
var ChainGun Gun;
var() float WindUpTime;

var() String FiringForce;
var() string WindingForce;

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

function StartBerserk()
{
	if ( (Level.GRI != None) && (Level.GRI.WeaponBerserk > 1.0) )
		return;
    DamageMin = default.DamageMin * 1.33;
    DamageMax = default.DamageMax * 1.33;
}

function StopBerserk()
{
	if ( (Level.GRI != None) && (Level.GRI.WeaponBerserk > 1.0) )
		return;
    DamageMin = default.DamageMin;
    DamageMax = default.DamageMax;
}

function StartSuperBerserk()
{
    DamageMin = default.DamageMin * 1.5;
    DamageMax = default.DamageMax * 1.5;
    BarrelRotationsPerSec = Default.BarrelRotationsPerSec * 0.667 * Level.GRI.WeaponBerserk;
    FireRate = 1.f / (RoundsPerRotation * BarrelRotationsPerSec);
    MaxRollSpeed = 65536.f*BarrelRotationsPerSec;
}

function PostBeginPlay()
{
    Super.PostBeginPlay();
    FireRate = 1.f / (RoundsPerRotation * BarrelRotationsPerSec);
    MaxRollSpeed = 65536.f*BarrelRotationsPerSec;
    Gun = Chaingun(Weapon);
}

function FlashMuzzleFlash()
{
    local rotator r;
    r.Roll = Rand(65536);
    Weapon.SetBoneRotation('Bone_Flash', r, 0, 1.f);
    Super.FlashMuzzleFlash();
}

function InitEffects()
{
    Super.InitEffects();
    if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'flash');
}

function PlayAmbientSound(Sound aSound)
{
    if ( (Chaingun(Weapon) == None) || (Instigator == None) || (aSound == None && ThisModeNum != Gun.CurrentMode) )
        return;

	if(aSound == None)
		Instigator.SoundVolume = Instigator.default.SoundVolume;
	else
		Instigator.SoundVolume = MinigunSoundVolume;

    Instigator.AmbientSound = aSound;
    Gun.CurrentMode = ThisModeNum;
}

function StopRolling()
{
    if (Gun == None || ThisModeNum != Gun.CurrentMode)
        return;

    RollSpeed = 0.f;
    Gun.RollSpeed = 0.f;
}

function PlayPreFire() {}
function PlayStartHold() {}
function PlayFiring() {}
function PlayFireEnd() {}
function StartFiring();
function StopFiring();
function bool IsIdle()
{
	return false;
}

auto state Idle
{
	function bool IsIdle()
	{
		return true;
	}

    function BeginState()
    {
        PlayAmbientSound(None);
        StopRolling();
    }

    function EndState()
    {
        PlayAmbientSound(WindingSound);
    }

    function StartFiring()
    {
        RollSpeed = 0;
		FireTime = (RollSpeed/MaxRollSpeed) * WindUpTime;
        GotoState('WindUp');
    }
}

state WindUp
{
    function BeginState()
    {
        ClientPlayForceFeedback(WindingForce);  // jdf
    }

    function EndState()
    {
        if (ThisModeNum == 0)
        {
            if ( (Weapon == None) || !Weapon.GetFireMode(1).bIsFiring )
                StopForceFeedback(WindingForce);
        }
        else
        {
            if ( (Weapon == None) || !Weapon.GetFireMode(0).bIsFiring )
                StopForceFeedback(WindingForce);
        }
    }

    function ModeTick(float dt)
    {
        FireTime += dt;
        RollSpeed = (FireTime/WindUpTime) * MaxRollSpeed;

        if ( !bIsFiring )
        {
			GotoState('WindDown');
			return;
		}

        if (RollSpeed >= MaxRollSpeed)
        {
            RollSpeed = MaxRollSpeed;
            FireTime = WindUpTime;
            Gun.UpdateRoll(dt, RollSpeed, ThisModeNum);
			GotoState('FireLoop');
            return;
        }

        Gun.UpdateRoll(dt, RollSpeed, ThisModeNum);
    }

    function StopFiring()
    {
        GotoState('WindDown');
    }
}

state FireLoop
{
    function BeginState()
    {
        NextFireTime = Level.TimeSeconds - 0.1; //fire now!
        PlayAmbientSound(FiringSound);
        ClientPlayForceFeedback(FiringForce);  // jdf
        Gun.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
        Gun.SpawnShells(RoundsPerRotation*BarrelRotationsPerSec);
    }

    function StopFiring()
    {
        GotoState('WindDown');
    }

    function EndState()
    {
        PlayAmbientSound(WindingSound);
        StopForceFeedback(FiringForce);  // jdf
        Gun.LoopAnim(Gun.IdleAnim, Gun.IdleAnimRate, TweenTime);
        Gun.SpawnShells(0.f);
     }

    function ModeTick(float dt)
    {
        Super.ModeTick(dt);
        Gun.UpdateRoll(dt, RollSpeed, ThisModeNum);
        if ( !bIsFiring )
        {
			GotoState('WindDown');
			return;
		}
    }
}

state WindDown
{
    function BeginState()
    {
        ClientPlayForceFeedback(WindingForce);  // jdf
    }

    function EndState()
    {
        if (ThisModeNum == 0)
        {
            if ( (Weapon == None) || !Weapon.GetFireMode(1).bIsFiring )
                StopForceFeedback(WindingForce);
        }
        else
        {
            if ( (Weapon == None) || !Weapon.GetFireMode(0).bIsFiring )
                StopForceFeedback(WindingForce);
        }
    }

    function ModeTick(float dt)
    {
        FireTime -= dt;
        RollSpeed = (FireTime/WindUpTime) * MaxRollSpeed;

        if (RollSpeed <= 0.f)
        {
            RollSpeed = 0.f;
            FireTime = 0.f;
            Gun.UpdateRoll(dt, RollSpeed, ThisModeNum);
            GotoState('Idle');
            return;
        }

        Gun.UpdateRoll(dt, RollSpeed, ThisModeNum);
    }

    function StartFiring()
    {
        GotoState('WindUp');
    }
}

defaultproperties
{
     BarrelRotationsPerSec=10.000000
     RoundsPerRotation=1
     WindingSound=Sound'WeaponSounds.Minigun.miniempty'
     FiringSound=Sound'NewWeaponSounds.NewMinigunFire'
     MinigunSoundVolume=220
     WindUpTime=0.270000
     FiringForce="minifireb"
     WindingForce="miniempty"
     DamageType=Class'commandandconquer.DamTypeChaingunBullet'
     DamageMin=7
     DamageMax=7
     Momentum=0.000000
     bPawnRapidFireAnim=True
     PreFireTime=0.270000
     FireLoopAnimRate=9.000000
     AmmoClass=Class'commandandconquer.ChaingunAmmo'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=10000.000000,Y=10000.000000,Z=10000.000000)
     ShakeRotTime=2.000000
     ShakeOffsetMag=(X=1.000000,Y=1.000000,Z=1.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=2.000000
     BotRefireRate=0.990000
     FlashEmitterClass=Class'XEffects.MinigunMuzFlash1st'
     SmokeEmitterClass=Class'XEffects.MinigunMuzzleSmoke'
     aimerror=900.000000
     Spread=0.040000
     SpreadStyle=SS_Random
}
