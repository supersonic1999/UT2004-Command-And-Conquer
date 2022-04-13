class NodAPC extends ONSPRV;

function VehicleFire(bool bWasAltFire)
{
	if(bWasAltFire)
        ServerPlayHorn(0);
    else
        super(Vehicle).VehicleFire(bWasAltFire);
}

defaultproperties
{
     DriverWeapons(0)=(WeaponClass=Class'commandandconquer.NodBuggyCannon',WeaponBone="Dummy01")
     PassengerWeapons(0)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat')
     PassengerWeapons(1)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="Dummy01")
     PassengerWeapons(2)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="Dummy01")
     PassengerWeapons(3)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="Dummy01")
     bDrawDriverInTP=False
     VehiclePositionString="in a Armoured Personnel Carrier"
     VehicleNameString="Armoured Personnel Carrier"
}
