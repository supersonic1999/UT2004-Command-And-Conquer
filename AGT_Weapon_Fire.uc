class AGT_Weapon_Fire extends FM_BallTurret_Fire;

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
    local Projectile p;

	P = Weapon.Spawn(TeamProjectileClasses[Instigator.GetTeamNum()],,, Start, Dir);
    if(P == None)
        return None;

    SeekingRocketProj(P).Seeking = Instigator.Controller.Target;
    P.Damage *= DamageAtten;
    return P;
}

defaultproperties
{
     TeamProjectileClasses(0)=Class'commandandconquer.AGTRocket'
     TeamProjectileClasses(1)=Class'commandandconquer.AGTRocket'
     ProjSpawnOffset=(X=0.000000,Y=0.000000,Z=0.000000)
     FireRate=3.000000
}
