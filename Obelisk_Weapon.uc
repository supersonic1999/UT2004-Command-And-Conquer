class Obelisk_Weapon extends ASTurret_BallTurret;

static function StaticPrecache(LevelInfo L)
{
    super.StaticPrecache( L );

	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Base' );		// Skins
	L.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Canon' );

	L.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	L.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );

	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	L.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	L.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	L.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	L.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	L.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	L.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );		// Fire Effect
	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );

	L.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASTurret_Base' );
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.ASTurret_Base' );
	Level.AddPrecacheStaticMesh( StaticMesh'AS_Weapons_SM.Projectiles.Skaarj_Energy' );

	super.UpdatePrecacheStaticMeshes();
}


simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Base' );		// Skins
	Level.AddPrecacheMaterial( Material'AS_Weapons_TX.Turret.ASTurret_Canon' );

	Level.AddPrecacheMaterial( Texture'AS_FX_TX.HUD.SpaceHUD_Weapon_Grey' );		// HUD
	Level.AddPrecacheMaterial( Texture'InterfaceContent.WhileSquare' );

	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp7_frames' );			// Explosion Effect
	Level.AddPrecacheMaterial( Material'EpicParticles.Flares.SoftFlare' );
	Level.AddPrecacheMaterial( Material'AW-2004Particles.Fire.MuchSmoke2t' );
	Level.AddPrecacheMaterial( Material'AS_FX_TX.Trails.Trail_red' );
	Level.AddPrecacheMaterial( Material'ExplosionTex.Framed.exp1_frames' );
	Level.AddPrecacheMaterial( Material'EmitterTextures.MultiFrame.rockchunks02' );

	Level.AddPrecacheMaterial( Texture'EpicParticles.Smoke.StellarFog1aw' );		// Fire Effect

	super.UpdatePrecacheMaterials();
}

defaultproperties
{
     TurretBaseClass=None
     DefaultWeaponClassName="CommandAndConquer.Obelisk_Turret"
     bRemoteControlled=False
     bNonHumanControl=True
     HealthMax=100000000.000000
     Health=99999999
     bHidden=True
     bCanBeDamaged=False
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bBlockActors=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bPathColliding=False
}
