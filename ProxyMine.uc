class ProxyMine extends Weapon
    config(user)
    HideDropDown;

#EXEC OBJ LOAD FILE=InterfaceContent.utx

defaultproperties
{
     FireModeClass(0)=Class'commandandconquer.ProxyFire'
     FireModeClass(1)=Class'commandandconquer.ProxyFire'
     PutDownAnim="PutDown"
     SelectAnimRate=3.100000
     PutDownAnimRate=2.800000
     SelectSound=Sound'WeaponSounds.FlakCannon.SwitchToFlakCannon'
     SelectForce="SwitchToFlakCannon"
     AIRating=0.550000
     CurrentRating=0.550000
     Description="The MGG Grenade Launcher fires magnetic sticky grenades, which will attach to enemy players and vehicles."
     EffectOffset=(X=100.000000,Y=32.000000,Z=-20.000000)
     DisplayFOV=45.000000
     Priority=10
     HudColor=(B=255,G=0,R=0)
     SmallViewOffset=(X=166.000000,Y=48.000000,Z=-54.000000)
     CustomCrosshair=15
     CustomCrossHairTextureName="ONSInterface-TX.grenadeLauncherReticle"
     InventoryGroup=9
     GroupOffset=1
     PickupClass=Class'Onslaught.ONSGrenadePickup'
     PlayerViewOffset=(X=150.000000,Y=40.000000,Z=-46.000000)
     BobDamping=2.200000
     AttachmentClass=Class'Onslaught.ONSGrenadeAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
     ItemName="Proximity C4"
     Mesh=SkeletalMesh'ONSWeapons-A.GrenadeLauncher_1st'
     AmbientGlow=64
}
