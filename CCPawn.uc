class CCPawn extends xPawn;

function bool PerformDodge(eDoubleClickDir DoubleClickMove, vector Dir, vector Cross)
{
    return false;
}

function SetInvisibility(float time)
{
    bInvis = (time > 0.0);
    if(Role == ROLE_Authority)
    {
        if(bInvis)
		{
			if ( (time == 2000000.0) )
				Visibility = Default.Visibility;
			else
				Visibility = 1;
            SetWeaponOverlay(InvisMaterial, time, true);
        }
        else
        {
			Visibility = Default.Visibility;
            if(HasUDamage())
                SetWeaponOverlay(UDamageWeaponMaterial, UDamageTime - Level.TimeSeconds, true);
            else
                SetWeaponOverlay(None, 0.0, true);
        }
    }
}

function TakeFallingDamage()
{
	local float Shake, EffectiveSpeed;

	if(Velocity.Z < -0.5 * MaxFallSpeed)
	{
		if(Role == ROLE_Authority)
		{
		    MakeNoise(1.0);
		    if(Velocity.Z < -1 * MaxFallSpeed)
		    {
				EffectiveSpeed = Velocity.Z;
				if ( TouchingWaterVolume() )
					EffectiveSpeed = FMin(0, EffectiveSpeed + 100);
				if ( EffectiveSpeed < -1 * MaxFallSpeed )
					TakeDamage(-100 * (EffectiveSpeed + MaxFallSpeed)/MaxFallSpeed, None, Location, vect(0,0,0), class'CCFell');
		    }
		}
		if(Controller != none)
		{
			Shake = FMin(1, -1 * Velocity.Z/MaxFallSpeed);
            Controller.DamageShake(Shake);
		}
	}
	else if(Velocity.Z < -1.4 * JumpZ)
		MakeNoise(0.5);
}

defaultproperties
{
     MaxFallSpeed=900.000000
}
