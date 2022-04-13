class TimedC4Fire extends BioFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local TimedC4Proj G;

	G = TimedC4Proj(Super.SpawnProjectile(Start, Dir));
	if (G != None && Weapon != none && C4Timed(Weapon) != None)
	{
		G.SetOwner(Weapon);
		C4Timed(Weapon).Grenades[C4Timed(Weapon).Grenades.length] = G;
		C4Timed(Weapon).CurrentGrenades++;
	}

	return G;
}

defaultproperties
{
     bSplashDamage=False
     bRecommendSplashDamage=False
     FireRate=1.000000
     AmmoClass=Class'commandandconquer.TimedC4Ammo'
     ProjectileClass=Class'commandandconquer.TimedC4Proj'
}
