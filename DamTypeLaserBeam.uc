class DamTypeLaserBeam extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     WeaponClass=Class'commandandconquer.LaserRifle'
     DeathString="%o was fatally enlightened by %k's laser beam."
     FemaleSuicide="%o somehow managed to shoot herself with the laser rifle."
     MaleSuicide="%o somehow managed to shoot himself with the laser rifle."
     bDetonatesGoop=True
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=0.800000
     GibPerterbation=0.750000
     VehicleDamageScaling=0.250000
     VehicleMomentumScaling=0.500000
}
