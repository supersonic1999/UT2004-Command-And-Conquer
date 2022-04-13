class NOD_Turret_Turret extends Weapon_Turret
    config(user)
    HideDropDown
	CacheExempt;

defaultproperties
{
     FireModeClass(0)=Class'commandandconquer.Turret_Weapon_Fire'
     AttachmentClass=Class'commandandconquer.Turret_Attachment'
}
