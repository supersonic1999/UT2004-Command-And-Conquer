class NODArtillery extends ONSWheeledCraft;

#exec OBJ LOAD FILE=ONSBPTextures.utx

function bool IsArtillery()
{
	return true;
}

function bool RecommendLongRangedAttack()
{
	return true;
}

function ShouldTargetMissile(Projectile P)
{
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	L.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
    L.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
    L.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
    L.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
    L.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.LargeShell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Target');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.Mini_Shell');
	Level.AddPrecacheStaticMesh(StaticMesh'ONS-BPJW1.Meshes.TargetNo');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMAGreen');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.MuzzleSpray');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.SPMATan');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Missile');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Smoke');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.ExploTrans');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Flair1Alpha');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.seexpt');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.Skins.ArtilleryCamTexture');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlpha_test2');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.Fire');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'BenTex01.textures.SmokePuff01');
    Level.AddPrecacheMaterial(Material'ArboreaTerrain.ground.flr02ar');
    Level.AddPrecacheMaterial(Material'ONSBPTextures.fX.TargetAlphaNo');
    Level.AddPrecacheMaterial(Material'AbaddonArchitecture.Base.bas28go');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     WheelSoftness=0.060000
     WheelPenScale=1.500000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=1.100000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.150000
     WheelSuspensionTravel=25.000000
     WheelSuspensionOffset=-10.000000
     WheelSuspensionMaxRenderTravel=25.000000
     FTScale=0.030000
     ChassisTorqueScale=1.250000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=35.000000),(InVal=700.000000,OutVal=35.000000),(InVal=800.000000,OutVal=10.000000),(InVal=1000000000.000000,OutVal=10.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2500.000000)))
     GearRatios(0)=-0.500000
     GearRatios(1)=0.400000
     GearRatios(2)=0.650000
     GearRatios(3)=0.850000
     GearRatios(4)=1.100000
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=110.000000
     TurnDamping=35.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.200000
     IdleRPM=500.000000
     EngineRPMSoundRange=10000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     bMakeBrakeLights=True
     BrakeLightOffset(0)=(X=46.000000,Y=47.000000,Z=45.000000)
     BrakeLightOffset(1)=(X=46.000000,Y=-47.000000,Z=45.000000)
     BrakeLightMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     DaredevilThreshInAirSpin=90.000000
     DaredevilThreshInAirTime=1.200000
     bDoStuntInfo=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     DriverWeapons(0)=(WeaponClass=Class'commandandconquer.NODArtilleryCannon',WeaponBone="CannonAttach")
     PassengerWeapons(0)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="CannonAttach")
     CustomAim=(Pitch=12000)
     RedSkin=Texture'ONSBPTextures.Skins.SPMATan'
     BlueSkin=Texture'ONSBPTextures.Skins.SPMAGreen'
     IdleSound=Sound'ONSVehicleSounds-S.PRV.PRVEng01'
     StartUpSound=Sound'ONSBPSounds.Artillery.EngineRampUp'
     ShutDownSound=Sound'ONSBPSounds.Artillery.EngineRampDown'
     StartUpForce="PRVStartUp"
     ShutDownForce="PRVShutDown"
     DestroyedVehicleMesh=StaticMesh'ONSBP_DestroyedVehicles.SPMA.DestroyedSPMA'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'OnslaughtBP.ONSArtilleryDeathExp'
     DisintegrationHealth=-100.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=150.000000)
     DamagedEffectScale=1.200000
     DamagedEffectOffset=(X=250.000000,Y=20.000000,Z=50.000000)
     ImpactDamageMult=0.001000
     HeadlightCoronaOffset(0)=(X=290.000000,Y=50.000000,Z=40.000000)
     HeadlightCoronaOffset(1)=(X=290.000000,Y=-50.000000,Z=40.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=70.000000
     HeadlightProjectorMaterial=Texture'VMVehicles-TX.NEWprvGroup.PRVprojector'
     HeadlightProjectorOffset=(X=290.000000,Z=40.000000)
     HeadlightProjectorRotation=(Pitch=-1500)
     HeadlightProjectorScale=0.650000
     Begin Object Class=SVehicleWheel Name=RWheel1
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Steered
         BoneName="Wheel_Right01"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionRight01"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(0)=SVehicleWheel'commandandconquer.NODArtillery.RWheel1'

     Begin Object Class=SVehicleWheel Name=LWheel1
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Steered
         BoneName="Wheel_Left01"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionLeft01"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(1)=SVehicleWheel'commandandconquer.NODArtillery.LWheel1'

     Begin Object Class=SVehicleWheel Name=RWheel2
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="Wheel_Right02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionRight02"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(2)=SVehicleWheel'commandandconquer.NODArtillery.RWheel2'

     Begin Object Class=SVehicleWheel Name=LWheel2
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="Wheel_Left02"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionLeft02"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(3)=SVehicleWheel'commandandconquer.NODArtillery.LWheel2'

     Begin Object Class=SVehicleWheel Name=RWheel3
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="Wheel_Right03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=-15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionRight03"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(4)=SVehicleWheel'commandandconquer.NODArtillery.RWheel3'

     Begin Object Class=SVehicleWheel Name=LWheel3
         bPoweredWheel=True
         bHandbrakeWheel=True
         SteerType=VST_Inverted
         BoneName="Wheel_Left03"
         BoneRollAxis=AXIS_Y
         BoneOffset=(X=15.000000)
         WheelRadius=43.000000
         SupportBoneName="SuspensionLeft03"
         SupportBoneAxis=AXIS_X
     End Object
     Wheels(5)=SVehicleWheel'commandandconquer.NODArtillery.LWheel3'

     VehicleMass=4.000000
     bDrawMeshInFP=True
     bHasHandbrake=True
     bDriverHoldsFlag=False
     DrivePos=(X=145.000000,Y=-30.000000,Z=75.000000)
     ExitPositions(0)=(Y=-165.000000,Z=100.000000)
     ExitPositions(1)=(Y=165.000000,Z=100.000000)
     ExitPositions(2)=(Y=-165.000000,Z=-100.000000)
     ExitPositions(3)=(Y=165.000000,Z=-100.000000)
     EntryPosition=(X=40.000000,Y=-60.000000,Z=10.000000)
     EntryRadius=320.000000
     FPCamPos=(X=160.000000,Y=-30.000000,Z=75.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=100.000000,Y=-30.000000,Z=-100.000000)
     TPCamWorldOffset=(Z=350.000000)
     TPCamDistRange=(Min=200.000000)
     MomentumMult=2.000000
     DriverDamageMult=0.100000
     VehiclePositionString="in a Mobile Artillery"
     VehicleNameString="Mobile Artillery"
     RanOverDamageType=Class'Onslaught.DamTypePRVRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypePRVPancake'
     MaxDesireability=0.600000
     ObjectiveGetOutDist=1500.000000
     FlagBone="Body"
     FlagOffset=(X=200.000000,Z=150.000000)
     FlagRotation=(Yaw=32768)
     HornSounds(0)=Sound'ONSBPSounds.Artillery.SPMAHorn'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.Horn04'
     VehicleIcon=(Material=Texture'AS_FX_TX.Icons.OBJ_HellBender',bIsGreyScale=True)
     GroundSpeed=500.000000
     HealthMax=400.000000
     Health=400
     Mesh=SkeletalMesh'ONSBPAnimations.ArtilleryMesh'
     SoundVolume=200
     SoundRadius=220.000000
     CollisionRadius=260.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.000000
         KInertiaTensor(3)=3.000000
         KInertiaTensor(5)=3.500000
         KCOMOffset=(X=1.500000,Z=-0.500000)
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
     KParams=KarmaParamsRBFull'commandandconquer.NODArtillery.KParams0'

}
