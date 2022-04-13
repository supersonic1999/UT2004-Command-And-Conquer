class Harvester extends ONSWheeledCraft;

var int Money,  MoneyMax, MoneyPerSec, SpawnTeam;
var Font TextFont;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
		Money,SpawnTeam;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
}

simulated function KDriverEnter(Pawn P)
{
	super.KDriverEnter(P);
	SetTimer((20 / MoneyMax), true);
}

//function DriverDied()
//{
//	Super.DriverDied();
//	GibbedBy(None);
//}

function Timer()
{
	local TiberiumCrystal V;
	local CCBuildings T;
	local Controller C;
	local int i;

	super.Timer();

	if(ROLE == ROLE_Authority)
	{
		if(Money < MoneyMax)
		{
			for(V=Class'TiberiumCrystal'.Static.PickFirstCrystal(Level); V!=None; V=V.NextCrystal)
			{
				if(VSize(V.Location-Location) < 250)
				{
					Money++;
					V.Tiberium--;
					V.CheckCrystalStatus();
					Break;
				}
			}
		}

		if(Money <= 0)
            Return;

		for(T=Class'CCBuildings'.Static.PickFirstBuilding(Level); T!=None; T=T.NextBuilding)
		{
			if(T.Team == Team && TiberiumRef(T) != none && VSize(T.Location-Location) < 2500)
			{
				if(Money < MoneyPerSec)
					i = Money;
				else
                    i = MoneyPerSec;

				Money -= i;
				for(C=Level.ControllerList; C!=None; C=C.NextController)
                    if(CommandController(C) != none && C.GetTeamNum() == Team)
						CommandController(C).GiveMoney(i*2);

				if(CCReplicationInfo(Level.GRI) != none)
					CCReplicationInfo(Level.GRI).GiveCmdMoney(i*4, Team);
				Break;
			}
		}
	}
}

simulated function DriverLeft()
{
	super.DriverLeft();
	SetTimer(0, false);
}

simulated function DrawHUD(Canvas Canvas)
{
	local PlayerController PC;

	super.DrawHUD(Canvas);
	PC = PlayerController(Controller);

	if(Health > 0 && PC != none && PC.myHUD != none && PC.MyHUD.bShowScoreboard == false)
	{
		Canvas.Font = TextFont;
		Canvas.FontScaleX = Canvas.ClipX / 1024.f;
		Canvas.FontScaleY = Canvas.ClipY / 768.f;
		Canvas.SetPos(Canvas.FontScaleX, Canvas.ClipY * 0.2);
		Canvas.SetDrawColor(255,255,255,255);
		if(Money < MoneyMax)
			Canvas.DrawText("Tiberium:" @ Money);
		else Canvas.DrawText("Tiberium:" @ "***FULL***");
		Canvas.Reset();
	}
}

function VehicleFire(bool bWasAltFire)
{
    ServerPlayHorn(0);
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ParticleMeshes.Complex.ExplosionRing');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.MainGun');
	L.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorRED');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVnoColor');
    L.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorBlue');
    L.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    L.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ParticleMeshes.Complex.ExplosionRing');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.BayDoor');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.MainGun');
	Level.AddPrecacheStaticMesh(StaticMesh'ONSFullStaticMeshes.LEVexploded.SideFlap');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorRED');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVnoColor');
    Level.AddPrecacheMaterial(Material'ONSFullTextures.MASGroup.LEVcolorBlue');
    Level.AddPrecacheMaterial(Material'VehicleFX.Particles.DustyCloud2');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.DirtKICKGROUP.dirtKICKTEX');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');

	Super.UpdatePrecacheMaterials();
}

function ShouldTargetMissile(Projectile P);

simulated function int GetTeamNum()
{
	Return Team;
}

defaultproperties
{
     MoneyMax=150
     MoneyPerSec=10
     SpawnTeam=999
     WheelSoftness=0.040000
     WheelPenScale=1.000000
     WheelPenOffset=0.010000
     WheelRestitution=0.100000
     WheelInertia=0.100000
     WheelLongFrictionFunc=(Points=(,(InVal=100.000000,OutVal=1.000000),(InVal=200.000000,OutVal=0.900000),(InVal=10000000000.000000,OutVal=0.900000)))
     WheelLongSlip=0.001000
     WheelLatSlipFunc=(Points=(,(InVal=30.000000,OutVal=0.009000),(InVal=45.000000),(InVal=10000000000.000000)))
     WheelLongFrictionScale=0.900000
     WheelLatFrictionScale=1.500000
     WheelHandbrakeSlip=0.010000
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=40.000000
     WheelSuspensionMaxRenderTravel=40.000000
     FTScale=0.010000
     ChassisTorqueScale=0.100000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=1000000000.000000,OutVal=11.000000)))
     TorqueCurve=(Points=((OutVal=9.000000),(InVal=200.000000,OutVal=10.000000),(InVal=1500.000000,OutVal=11.000000),(InVal=2800.000000)))
     GearRatios(0)=-0.200000
     GearRatios(1)=0.200000
     NumForwardGears=1
     TransRatio=0.110000
     ChangeUpPoint=2000.000000
     ChangeDownPoint=1000.000000
     LSDFactor=1.000000
     EngineBrakeFactor=0.000100
     EngineBrakeRPMScale=0.100000
     MaxBrakeTorque=20.000000
     SteerSpeed=160.000000
     StopThreshold=100.000000
     HandbrakeThresh=200.000000
     EngineInertia=0.100000
     IdleRPM=1000.000000
     EngineRPMSoundRange=8000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=60.000000
     RevMeterScale=4000.000000
     bAllowBigWheels=True
     AirPitchDamping=45.000000
     bHasAltFire=False
     RedSkin=Shader'ONSFullTextures.MASGroup.MASredSHAD'
     BlueSkin=Shader'ONSFullTextures.MASGroup.MASblueSHAD'
     IdleSound=Sound'ONSVehicleSounds-S.MAS.MASEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.MAS.MASStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.MAS.MASStop01'
     StartUpForce="MASStartUp"
     ShutDownForce="MASShutDown"
     ViewShakeRadius=1000.000000
     ViewShakeOffsetMag=(X=0.700000,Z=2.700000)
     ViewShakeOffsetFreq=7.000000
     DestroyedVehicleMesh=StaticMesh'ONSFullStaticMeshes.leviathanDEAD'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'OnslaughtFull.ONSVehDeathMAS'
     DisintegrationHealth=0.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     UpsideDownDamage=500.000000
     DamagedEffectScale=2.500000
     DamagedEffectOffset=(Z=185.000000)
     bEnableProximityViewShake=True
     bCannotBeBased=True
     HeadlightCoronaOffset(0)=(X=275.000000,Y=-80.000000)
     HeadlightCoronaOffset(1)=(X=275.000000,Y=80.000000)
     HeadlightCoronaMaterial=Texture'EpicParticles.Flares.FlashFlare1'
     HeadlightCoronaMaxSize=50.000000
     Begin Object Class=SVehicleWheel Name=BackTireLeft4
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="BTireLeft4"
         BoneRollAxis=AXIS_Y
         WheelRadius=60.000000
         SupportBoneName="MiddleSuspension1"
     End Object
     Wheels(0)=SVehicleWheel'commandandconquer.Harvester.BackTireLeft4'

     Begin Object Class=SVehicleWheel Name=BackTireLeft3
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="BTireLeft3"
         BoneRollAxis=AXIS_Y
         WheelRadius=60.000000
         SupportBoneName="MiddleSuspension2"
     End Object
     Wheels(1)=SVehicleWheel'commandandconquer.Harvester.BackTireLeft3'

     Begin Object Class=SVehicleWheel Name=BackTireRight3
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="BTireRight3"
         BoneRollAxis=AXIS_Y
         WheelRadius=60.000000
         SupportBoneName="MiddleSuspension1"
     End Object
     Wheels(2)=SVehicleWheel'commandandconquer.Harvester.BackTireRight3'

     Begin Object Class=SVehicleWheel Name=BackTireRight4
         bPoweredWheel=True
         bHandbrakeWheel=True
         BoneName="BTireRight4"
         BoneRollAxis=AXIS_Y
         WheelRadius=60.000000
         SupportBoneName="MiddleSuspension2"
     End Object
     Wheels(3)=SVehicleWheel'commandandconquer.Harvester.BackTireRight4'

     Begin Object Class=SVehicleWheel Name=FrontTireLeft1
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="FTireLeft1"
         BoneRollAxis=AXIS_Y
         WheelRadius=50.000000
         SupportBoneName="FSuspentionLeft"
     End Object
     Wheels(4)=SVehicleWheel'commandandconquer.Harvester.FrontTireLeft1'

     Begin Object Class=SVehicleWheel Name=FrontTireRight1
         bPoweredWheel=True
         SteerType=VST_Steered
         BoneName="FTireRight1"
         BoneRollAxis=AXIS_Y
         WheelRadius=50.000000
         SupportBoneName="FSuspentionRight"
     End Object
     Wheels(5)=SVehicleWheel'commandandconquer.Harvester.FrontTireRight1'

     VehicleMass=10.000000
     bEjectDriver=True
     bDrawMeshInFP=True
     bEnterringUnlocks=False
     bKeyVehicle=True
     bDriverHoldsFlag=False
     bSpawnProtected=True
     DrivePos=(X=16.921000,Y=-40.284000,Z=65.793999)
     ExitPositions(0)=(Y=-365.000000)
     EntryRadius=300.000000
     FPCamPos=(X=240.000000,Z=350.000000)
     TPCamDistance=400.000000
     TPCamLookat=(X=100.000000,Z=300.000000)
     TPCamDistRange=(Min=0.000000,Max=2500.000000)
     MaxViewPitch=30000
     ShadowCullDistance=2000.000000
     MomentumMult=0.100000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Harvester"
     VehicleNameString="Harvester"
     RanOverDamageType=Class'OnslaughtFull.DamTypeMASRoadkill'
     CrushedDamageType=Class'OnslaughtFull.DamTypeMASPancake'
     MaxDesireability=2.000000
     ObjectiveGetOutDist=2000.000000
     FlagBone="root"
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.LevHorn01'
     HornSounds(1)=Sound'ONSVehicleSounds-S.Horns.LevHorn02'
     NavigationPointRange=190.000000
     HealthMax=1500.000000
     Health=1500
     bAlwaysRelevant=True
     Mesh=SkeletalMesh'commandandconquer.Harvester'
     SoundRadius=255.000000
     CollisionRadius=100.000000
     CollisionHeight=60.000000
     Begin Object Class=KarmaParamsRBFull Name=KParams0
         KInertiaTensor(0)=1.260000
         KInertiaTensor(3)=3.099998
         KInertiaTensor(5)=4.499996
         KLinearDamping=0.050000
         KAngularDamping=0.050000
         KStartEnabled=True
         bKNonSphericalInertia=True
         KMaxSpeed=500.000000
         bHighDetailOnly=False
         bClientOnly=False
         bKDoubleTickRate=True
         bDestroyOnWorldPenetrate=True
         bDoSafetime=True
         KFriction=0.500000
         KImpactThreshold=500.000000
     End Object
     KParams=KarmaParamsRBFull'commandandconquer.Harvester.KParams0'

}
