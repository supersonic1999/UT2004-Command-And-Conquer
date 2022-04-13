class RepairFire extends LinkFire;

simulated function ModeTick(float dt)
{
	local Vector StartTrace, EndTrace, X, Y, Z;
	local Vector HitLocation, HitNormal, EndEffect, Momentum;
	local Actor Other;
	local Rotator Aim;
	local LinkGun LinkGun;
	local float Step, ls;
	local bot B;
	local bool bShouldStop;
	local LinkBeamEffect LB;

    if ( !bIsFiring )
    {
		bInitAimError = true;
        return;
    }

    LinkGun = LinkGun(Weapon);

    ls = LinkScale[Min(LinkGun.Links,5)];

    if ( myHasAmmo(LinkGun) && ((UpTime > 0.0) || (Instigator.Role < ROLE_Authority)) )
    {
        UpTime -= dt;

		LinkGun.GetViewAxes(X, Y, Z);
		StartTrace = GetFireStart( X, Y, Z);
        TraceRange = default.TraceRange + LinkGun.Links*250;

        if ( Instigator.Role < ROLE_Authority )
        {
			if ( Beam == None )
				foreach Weapon.DynamicActors(class'LinkBeamEffect', LB )
					if ( !LB.bDeleteMe && (LB.Instigator != None) && (LB.Instigator == Instigator) )
					{
						Beam = LB;
						break;
					}

			if ( Beam != None )
				LockedPawn = Beam.LinkedPawn;
		}

        if ( LockedPawn != None )
			TraceRange *= 1.5;

        if ( Instigator.Role == ROLE_Authority )
		{
		    if ( bDoHit )
			    LinkGun.ConsumeAmmo(ThisModeNum, AmmoPerFire);

			B = Bot(Instigator.Controller);
			if ( (B != None) && (PlayerController(B.Squad.SquadLeader) != None) && (B.Squad.SquadLeader.Pawn != None) )
			{
				if ( IsLinkable(B.Squad.SquadLeader.Pawn)
					&& (B.Squad.SquadLeader.Pawn.Weapon != none && B.Squad.SquadLeader.Pawn.Weapon.GetFireMode(1).bIsFiring)
					&& (VSize(B.Squad.SquadLeader.Pawn.Location - StartTrace) < TraceRange) )
				{
					Other = Weapon.Trace(HitLocation, HitNormal, B.Squad.SquadLeader.Pawn.Location, StartTrace, true);
					if ( Other == B.Squad.SquadLeader.Pawn )
					{
						B.Focus = B.Squad.SquadLeader.Pawn;
						if ( B.Focus != LockedPawn )
							SetLinkTo(B.Squad.SquadLeader.Pawn);
						B.SetRotation(Rotator(B.Focus.Location - StartTrace));
 						X = Normal(B.Focus.Location - StartTrace);
 					}
 					else if ( B.Focus == B.Squad.SquadLeader.Pawn )
						bShouldStop = true;
				}
 				else if ( B.Focus == B.Squad.SquadLeader.Pawn )
					bShouldStop = true;
			}
		}

        if ( Bot(Instigator.Controller) != None )
        {
			if ( bInitAimError )
			{
				CurrentAimError = AdjustAim(StartTrace, AimError);
				bInitAimError = false;
			}
			else
			{
				BoundError();
				CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;
			}

			Step = 7500.0 * dt;
			if ( DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw )
			{
				CurrentAimError.Yaw += Step;
				if ( !(DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw) )
				{
					CurrentAimError.Yaw = DesiredAimError.Yaw;
					DesiredAimError = AdjustAim(StartTrace, AimError);
				}
			}
			else
			{
				CurrentAimError.Yaw -= Step;
				if ( DesiredAimError.Yaw ClockWiseFrom CurrentAimError.Yaw )
				{
					CurrentAimError.Yaw = DesiredAimError.Yaw;
					DesiredAimError = AdjustAim(StartTrace, AimError);
				}
			}
			CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
			if ( BoundError() )
				DesiredAimError = AdjustAim(StartTrace, AimError);
			CurrentAimError.Yaw = CurrentAimError.Yaw + Instigator.Rotation.Yaw;

			if ( Instigator.Controller.Target == None )
				Aim = Rotator(Instigator.Controller.FocalPoint - StartTrace);
			else
				Aim = Rotator(Instigator.Controller.Target.Location - StartTrace);

			Aim.Yaw = CurrentAimError.Yaw;

			CurrentAimError.Yaw = CurrentAimError.Yaw - Instigator.Rotation.Yaw;
		}
		else
            Aim = GetPlayerAim(StartTrace, AimError);

        X = Vector(Aim);
        EndTrace = StartTrace + TraceRange * X;

        Other = Weapon.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true);
        if ( Other != None && Other != Instigator )
			EndEffect = HitLocation;
		else
			EndEffect = EndTrace;

		if ( Beam != None )
			Beam.EndEffect = EndEffect;

        if(Instigator.Role < ROLE_Authority)
		    return;

        if(bDoHit)
        {
            Instigator.MakeNoise(1.0);
            if(CCBuildings(Other) != none && CCBuildings(Other).Team == Instigator.GetTeamNum())
    		    Other.TakeDamage(Damage, Instigator, HitLocation, Momentum, DamageType);
  		    else if(TimedC4Proj(Other) != none && Instigator.GetTeamNum() != TimedC4Proj(Other).Team)
  		        TimedC4Proj(Other).DisarmBomb(Damage, Instigator, HitLocation, Momentum, DamageType);
            else if(RemoteC4Proj(Other) != none && Instigator.GetTeamNum() != RemoteC4Proj(Other).Team)
  		        RemoteC4Proj(Other).DisarmBomb(Damage, Instigator, HitLocation, Momentum, DamageType);
		    else if(Pawn(Other) != none && Pawn(Other).GetTeamNum() == Instigator.GetTeamNum()
            && (Pawn(Other).GiveHealth(Damage, Pawn(Other).HealthMax) || xPawn(Other) != none && xPawn(Other).AddShieldStrength(Damage)))
		        Level.Game.GameRulesModifiers.NetDamage(Damage, Damage, Pawn(Other), Instigator, hitlocation, Momentum, damageType);
            else if(MasterControlTerminal(Other) != none && MasterControlTerminal(Other).BuildingOwner.Team == Instigator.GetTeamNum())
    		    Other.TakeDamage(Damage, Instigator, HitLocation, Momentum, DamageType);
        }

		if(bShouldStop)
			B.StopFiring();
		else
		{
			if((Beam == None) && bIsFiring)
			{
				Beam = Weapon.Spawn( BeamEffectClass, Instigator );
				if ( SentLinkVolume == Default.LinkVolume )
					SentLinkVolume = Default.LinkVolume + 1;
				else
					SentLinkVolume = Default.LinkVolume;
			}

			if(Beam != none)
			{
				Instigator.AmbientSound = BeamSounds[3];
				Instigator.SoundVolume = SentLinkVolume;
				Beam.bHitSomething = (Other != None);
				Beam.EndEffect = EndEffect;
			}
		}
    }
    else
        StopFiring();

    bStartFire = false;
    bDoHit = false;
}

function SetLinkTo(Pawn Other)
{
}

function bool AddLink(int Size, Pawn Starter)
{
    return false;
}

defaultproperties
{
     DamageType=Class'commandandconquer.DamTypeRepairGun'
     Damage=2
     AmmoPerFire=0
}
