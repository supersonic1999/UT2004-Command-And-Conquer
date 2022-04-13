class OrcaTurret extends ONSTankSecondaryTurret;

state InstantFireMode
{
    function AltFire(Controller C)
    {
        if(AltFireProjectileClass == None)
            Fire(C);
        else
            SpawnProjectile(AltFireProjectileClass, True);
    }
}

simulated function FlashMuzzleFlash()
{
	if(!bIsAltFire)
        Super.FlashMuzzleFlash();
}

simulated function SimulateTraceFire( out vector Start, out Rotator Dir, out vector HitLocation, out vector HitNormal )
{
    local Vector		X, End;
    local Actor			Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle		VehicleInstigator;

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

	X = Vector(Dir);
    End = Start + TraceRange * X;

    // skip past vehicle driver
    VehicleInstigator = Vehicle(Instigator);
    if ( VehicleInstigator != None && VehicleInstigator.Driver != None )
    {
        VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        Other = Trace(HitLocation, HitNormal, End, Start, true);
        VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
    }
    else
        Other = Trace(HitLocation, HitNormal, End, Start, True);

    if ( Other != None && Other != Instigator )
    {
		if ( Other.bCanBeDamaged )
        {
 			if ( Vehicle(Other) != None || Pawn(Other) == None )
 			{
 				LastHitLocation = HitLocation;
			}
			HitNormal = vect(0,0,0);
        }
        else
        {
            LastHitLocation = HitLocation;
		}
    }
    else
    {
        HitLocation = End;
        HitNormal = Vect(0,0,0);
    }
}

function TraceFire(Vector Start, Rotator Dir)
{
    local Vector X, End, HitLocation, HitNormal, RefNormal;
    local Actor Other;
    local ONSWeaponPawn WeaponPawn;
    local Vehicle VehicleInstigator;
    local int Damage;
    local bool bDoReflect;
    local int ReflectNum;

    MaxRange();

    if ( bDoOffsetTrace )
    {
    	WeaponPawn = ONSWeaponPawn(Owner);
	    if ( WeaponPawn != None && WeaponPawn.VehicleBase != None )
    	{
    		if ( !WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5)))
				Start = HitLocation;
		}
		else
			if ( !Owner.TraceThisActor(HitLocation, HitNormal, Start, Start + vector(Dir) * (Owner.CollisionRadius * 1.5)))
				Start = HitLocation;
    }

    ReflectNum = 0;
    while ( true )
    {
        bDoReflect = false;
        X = Vector(Dir);
        End = Start + TraceRange * X;

        //skip past vehicle driver
        VehicleInstigator = Vehicle(Instigator);
        if ( ReflectNum == 0 && VehicleInstigator != None && VehicleInstigator.Driver != None )
        {
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = false;
        	Other = Trace(HitLocation, HitNormal, End, Start, true);
        	VehicleInstigator.Driver.bBlockZeroExtentTraces = true;
        }
        else
        	Other = Trace(HitLocation, HitNormal, End, Start, True);

        if ( Other != None && (Other != Instigator || ReflectNum > 0) )
        {
            if (bReflective && Other.IsA('xPawn') && xPawn(Other).CheckReflect(HitLocation, RefNormal, DamageMin*0.25))
            {
                bDoReflect = True;
                HitNormal = vect(0,0,0);
            }
            else if (Other.bCanBeDamaged)
            {
                Damage = (DamageMin + Rand(DamageMax - DamageMin));
 				if ( Vehicle(Other) != None || Pawn(Other) == None )
 				{
 					HitCount++;
 					LastHitLocation = HitLocation;
					SpawnHitEffects(Other, HitLocation, HitNormal);
				}
               	Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
				HitNormal = vect(0,0,0);
            }
            else
            {
                HitCount++;
                LastHitLocation = HitLocation;
                SpawnHitEffects(Other, HitLocation, HitNormal);
	    }
        }
        else
        {
            HitLocation = End;
            HitNormal = Vect(0,0,0);
            HitCount++;
            LastHitLocation = HitLocation;
        }

        SpawnBeamEffect(Start, Dir, HitLocation, HitNormal, ReflectNum);

        if ( bDoReflect && ++ReflectNum < 4 )
        {
            //Log("reflecting off"@Other@Start@HitLocation);
            Start	= HitLocation;
            Dir		= Rotator(RefNormal); //Rotator( X - 2.0*RefNormal*(X dot RefNormal) );
        }
        else
        {
            break;
        }
    }

    NetUpdateTime = Level.TimeSeconds - 1;
}

defaultproperties
{
     PitchUpLimit=15000
     PitchDownLimit=-15000
     AltFireInterval=1.000000
     AltFireSoundClass=Sound'ONSVehicleSounds-S.Tank.TankFire01'
     AltFireForce="minifireb"
     DamageType=Class'commandandconquer.DamTypeCCChainGun'
     DamageMin=3
     DamageMax=3
     AltFireProjectileClass=Class'commandandconquer.OrcaRocketProjectile'
}
