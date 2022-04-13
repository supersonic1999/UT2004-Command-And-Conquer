class NodBuggy extends ONSRV;

function VehicleFire(bool bWasAltFire)
{
    super(ONSWheeledCraft).VehicleFire(bWasAltFire);
}

defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'commandandconquer.NodBuggyCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="ChainGunAttachment")
     VehiclePositionString="in a Nod Buggy"
     VehicleNameString="Nod Buggy"
     HealthMax=250.000000
     Health=250
}
