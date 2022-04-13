class BuildingCV extends ConstructionVehicle;

defaultproperties
{
     DamagedEffectScale=1.000000
     DamagedEffectOffset=(Z=100.000000)
     Begin Object Class=SVehicleWheel Name=FLWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="FrontLeftTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=10.000000)
         WheelRadius=22.000000
         SupportBoneName="FrontSuspensionLeft"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'commandandconquer.BuildingCV.FLWheel'

     Begin Object Class=SVehicleWheel Name=FRWheel
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="FrontRightTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-10.000000)
         WheelRadius=22.000000
         SupportBoneName="FrontSuspensionRight"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'commandandconquer.BuildingCV.FRWheel'

     Begin Object Class=SVehicleWheel Name=BRWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="BackRightTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=-10.000000)
         WheelRadius=22.000000
         SupportBoneName="BackSuspensionRight"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'commandandconquer.BuildingCV.BRWheel'

     Begin Object Class=SVehicleWheel Name=BLWheel
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="BackLeftTire"
         BoneRollAxis=AXIS_Y
         BoneOffset=(Y=10.000000)
         WheelRadius=22.000000
         SupportBoneName="BackSuspensionLeft"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'commandandconquer.BuildingCV.BLWheel'

     VehicleMass=3.500000
     ExitPositions(0)=(Z=0.000000)
     EntryRadius=250.000000
     FPCamPos=(X=300.000000,Z=100.000000)
     TPCamDistance=300.000000
     TPCamWorldOffset=(X=0.000000,Z=300.000000)
     VehiclePositionString="in a Construction Vehicle"
     VehicleNameString="Construction Vehicle"
     HealthMax=2000.000000
     Health=2000
     Mesh=SkeletalMesh'commandandconquer.Truck'
     CollisionRadius=200.000000
     CollisionHeight=100.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=-0.300000,Z=-0.500000)
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'commandandconquer.BuildingCV.KParams0'

}
