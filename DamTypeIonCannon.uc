class DamTypeIonCannon extends WeaponDamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth )
{
    HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     WeaponClass=Class'commandandconquer.PersonalIonCannon'
     DeathString="%o was fatally enlightened by %k's personal ion cannon."
     FemaleSuicide="%o somehow managed to shoot herself with the personal ion cannon."
     MaleSuicide="%o somehow managed to shoot himself with the personal ion cannon."
     bDetonatesGoop=True
     DamageOverlayMaterial=Shader'UT2004Weapons.Shaders.ShockHitShader'
     DamageOverlayTime=0.800000
     GibPerterbation=0.750000
     VehicleMomentumScaling=0.500000
}
