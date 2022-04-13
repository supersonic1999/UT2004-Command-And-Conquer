class CCPassangerGun extends ONSWeapon;

state InstantFireMode
{
  function Fire(controller C){}
  function AltFire(Controller C) {}
}

defaultproperties
{
     GunnerAttachmentBone="PlasmaGunAttachment"
     bInstantFire=True
     Mesh=SkeletalMesh'ONSWeapons-A.PlasmaGun'
}
