class RemoteC4Fire extends BioFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local RemoteC4Proj G;

	G = RemoteC4Proj(Super.SpawnProjectile(Start, Dir));
	if (G != None && Weapon != none && C4Remote(Weapon) != None)
	{
		G.SetOwner(Weapon);
		C4Remote(Weapon).Grenades[C4Remote(Weapon).Grenades.length] = G;
		C4Remote(Weapon).CurrentGrenades++;
	}

	return G;
}

defaultproperties
{
     bSplashDamage=False
     bRecommendSplashDamage=False
     FireRate=1.000000
     AmmoClass=Class'commandandconquer.RemoteC4Ammo'
     ProjectileClass=Class'commandandconquer.RemoteC4Proj'
}
