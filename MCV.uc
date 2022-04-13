class MCV extends ConstructionVehicle;

var VariableTexPanner LeftTreadPanner, RightTreadPanner;
var float TreadVelocityScale;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
		SetupTreads();
}

simulated function SetupTreads()
{
	LeftTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( LeftTreadPanner != None )
	{
		LeftTreadPanner.Material = Skins[1];
		LeftTreadPanner.PanDirection = rot(0, 16384, 0);
		LeftTreadPanner.PanRate = 0.0;
		Skins[1] = LeftTreadPanner;
	}
	RightTreadPanner = VariableTexPanner(Level.ObjectPool.AllocateObject(class'VariableTexPanner'));
	if ( RightTreadPanner != None )
	{
		RightTreadPanner.Material = Skins[2];
		RightTreadPanner.PanDirection = rot(0, 16384, 0);
		RightTreadPanner.PanRate = 0.0;
		Skins[2] = RightTreadPanner;
	}
}

simulated function Destroyed()
{
	if ( LeftTreadPanner != None )
	{
		Level.ObjectPool.FreeObject(LeftTreadPanner);
		LeftTreadPanner = None;
	}
	if ( RightTreadPanner != None )
	{
		Level.ObjectPool.FreeObject(RightTreadPanner);
		RightTreadPanner = None;
	}

	super.Destroyed();
}

simulated event DrivingStatusChanged()
{
    Super.DrivingStatusChanged();

    if (!bDriving)
    {
        if ( LeftTreadPanner != None )
            LeftTreadPanner.PanRate = 0.0;

        if ( RightTreadPanner != None )
            RightTreadPanner.PanRate = 0.0;
    }
}

simulated function Tick(float DeltaTime)
{
    local float LinTurnSpeed;

    if ( Level.NetMode != NM_DedicatedServer )
	{
		if ( LeftTreadPanner != None )
		{
			LeftTreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
			if (Velocity dot Vector(Rotation) > 0)
				LeftTreadPanner.PanRate = -1 * LeftTreadPanner.PanRate;
			LeftTreadPanner.PanRate += LinTurnSpeed;
		}

		if ( RightTreadPanner != None )
		{
			RightTreadPanner.PanRate = VSize(Velocity) / TreadVelocityScale;
			if (Velocity dot Vector(Rotation) > 0)
				RightTreadPanner.PanRate = -1 * RightTreadPanner.PanRate;
			RightTreadPanner.PanRate -= LinTurnSpeed;
		}
	}

    Super.Tick( DeltaTime );
}

defaultproperties
{
     TreadVelocityScale=450.000000
     VehicleClass=Class'commandandconquer.CYard'
     Begin Object Class=SVehicleWheel Name=Wheel1
         bPoweredWheel=True
         BoneName="FTire4"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(0)=SVehicleWheel'commandandconquer.MCV.Wheel1'

     Begin Object Class=SVehicleWheel Name=Wheel2
         bPoweredWheel=True
         BoneName="FTire1"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(1)=SVehicleWheel'commandandconquer.MCV.Wheel2'

     Begin Object Class=SVehicleWheel Name=Wheel3
         bPoweredWheel=True
         BoneName="FTire3"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(2)=SVehicleWheel'commandandconquer.MCV.Wheel3'

     Begin Object Class=SVehicleWheel Name=Wheel4
         bPoweredWheel=True
         BoneName="FTire2"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(3)=SVehicleWheel'commandandconquer.MCV.Wheel4'

     Begin Object Class=SVehicleWheel Name=Wheel5
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="BTire2"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(4)=SVehicleWheel'commandandconquer.MCV.Wheel5'

     Begin Object Class=SVehicleWheel Name=Wheel6
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="BTire3"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(5)=SVehicleWheel'commandandconquer.MCV.Wheel6'

     Begin Object Class=SVehicleWheel Name=Wheel7
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="BTire1"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(6)=SVehicleWheel'commandandconquer.MCV.Wheel7'

     Begin Object Class=SVehicleWheel Name=Wheel8
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="BTire4"
         BoneRollAxis=AXIS_Z
         BoneSteerAxis=AXIS_Y
         WheelRadius=80.000000
     End Object
     Wheels(7)=SVehicleWheel'commandandconquer.MCV.Wheel8'

     VehicleMass=10.000000
     EntryRadius=1000.000000
     FPCamPos=(Z=0.000000)
     TPCamDistance=300.000000
     TPCamWorldOffset=(X=0.000000,Z=400.000000)
     Skins(1)=Texture'VMVehicles-TX.HoverTankGroup.tankTreads'
     Skins(2)=Texture'VMVehicles-TX.HoverTankGroup.tankTreads'
     CollisionRadius=1000.000000
     CollisionHeight=350.000000
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
     KParams=KarmaParamsRBFull'commandandconquer.MCV.KParams0'

}
