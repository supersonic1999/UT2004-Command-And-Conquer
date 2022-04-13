class TransportHeli extends ONSDualAttackCraft;

defaultproperties
{
     DriverWeapons(0)=(WeaponClass=None)
     DriverWeapons(1)=(WeaponClass=None)
     PassengerWeapons(0)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat')
     PassengerWeapons(1)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="GatlingGunAttach")
     PassengerWeapons(2)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="GatlingGunAttach")
     PassengerWeapons(3)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="GatlingGunAttach")
     PassengerWeapons(4)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="GatlingGunAttach")
     VehiclePositionString="in a Transport Helicopter"
     VehicleNameString="Transport Helicopter"
     HealthMax=400.000000
     Health=400
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.250000)
         KLinearDamping=0.000000
         KAngularDamping=0.000000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KActorGravScale=0.000000
         KMaxSpeed=1100.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bKStayUpright=True
         bKAllowRotate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=300.000000
     End Object
     KParams=KarmaParamsRBFull'commandandconquer.TransportHeli.KParams0'

}
