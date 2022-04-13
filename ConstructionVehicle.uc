class ConstructionVehicle extends ONSWheeledCraft;

var float MaxGroundSpeed, MaxAirSpeed, MaxPitchSpeed;
var() class<CCBuildings> VehicleClass;
var CCBuildings V;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
		VehicleClass;
}

function VehicleFire(bool bWasAltFire)
{
   local CCBuildings Building;
   local bool bCloseEnough, bColliding;
   local int BuildAmount;

    if(bWasAltFire)
    {
        foreach RadiusActors(class'CCBuildings', Building, 5000 + VehicleClass.default.CollisionRadius)
        {
            if(Building != none && Building.Team == Team)
            {
                bCloseEnough = true;
                break;
            }
        }

        for(Building=Class'CCBuildings'.Static.PickFirstBuilding(Level); Building!=None; Building=Building.NextBuilding)
        {
            if(Building != none && Building.Team == Team)
            {
                BuildAmount++;
                break;
            }
        }

        foreach RadiusActors(class'CCBuildings', Building, VehicleClass.default.CollisionRadius)
        {
            bColliding = true;
            break;
        }

        if(Rotation.Pitch > 500 || Rotation.Roll > 500 || Rotation.Pitch < -500 || Rotation.Roll < -500 || VehicleClass == none || BuildAmount > 0 && !bCloseEnough || bColliding)
            if(PlayerController(Controller) != none)
                PlayerController(Controller).ClientPlaySound(sound'MenuSounds.Denied1');
        else
        {
            V = Spawn(VehicleClass, self,,, GetViewRotation());
            KDriverLeave(True);
            Destroy();
        }
    }
    else
    	ServerPlayHorn(0);
}

function bool ImportantVehicle()
{
	return true;
}

simulated function Destroyed()
{
	Super.Destroyed();

	if(Level != none && CCGameType(Level.Game) != None)
        CCGameType(Level.Game).CheckEndGame(none, "BuildingsDestroyed");
}

simulated function Tick(float DeltaTime)
{
    local float EnginePitch, LinTurnSpeed;
    local KRigidBodyState BodyState;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		LinTurnSpeed = 0.5 * BodyState.AngVel.Z;
		EnginePitch = 64.0 + VSize(Velocity)/MaxPitchSpeed * 64.0;
		SoundPitch = FClamp(EnginePitch, 64, 128);
	}

    Super.Tick(DeltaTime);
}

function ClientVehicleCeaseFire(bool bWasAltFire)
{
	local PlayerController PC;

	if(!bWasAltFire)
	{
		Super.ClientVehicleCeaseFire(bWasAltFire);
		return;
	}

	PC = PlayerController(Controller);
	if (PC == None)
		return;

	bWeaponIsAltFiring = false;
	PC.StopZoom();
}

static function StaticPrecache(LevelInfo L)
{
    Super.StaticPrecache(L);

	L.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.TANKexploded.TankTurret');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	L.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	L.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    L.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    L.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    L.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.TankColorRED');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.TankColorBLUE');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.TankNoColor');
    L.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.tankTreads');
    L.AddPrecacheMaterial(Material'VMParticleTextures.EJECTA.Tex');
	L.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlur');
    L.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    L.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Fireball3');
    L.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'ONSDeadVehicles-SM.TANKexploded.TankTurret');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris2');
	Level.AddPrecacheStaticMesh(StaticMesh'AW-2004Particles.Debris.Veh_Debris1');
	Level.AddPrecacheStaticMesh(StaticMesh'WeaponStaticMesh.RocketProj');

    Super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Energy.SparkHead');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp2_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.exp1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.we1_frames');
    Level.AddPrecacheMaterial(Material'ExplosionTex.Framed.SmokeReOrdered');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.MuchSmoke1');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.NapalmSpot');
    Level.AddPrecacheMaterial(Material'EpicParticles.Fire.SprayFire1');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.TankColorRED');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.TankColorBLUE');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.TankNoColor');
    Level.AddPrecacheMaterial(Material'VMVehicles-TX.HoverTankGroup.tankTreads');
    Level.AddPrecacheMaterial(Material'VMParticleTextures.EJECTA.Tex');
	Level.AddPrecacheMaterial(Material'AW-2004Particles.Weapons.TrailBlur');
    Level.AddPrecacheMaterial(Material'Engine.GRADIENT_Fade');
    Level.AddPrecacheMaterial(Material'AW-2004Explosions.Fire.Fireball3');
    Level.AddPrecacheMaterial(Material'AW-2004Particles.Fire.SmokeFragment');

	Super.UpdatePrecacheMaterials();
}

defaultproperties
{
     MaxGroundSpeed=500.000000
     MaxAirSpeed=5000.000000
     MaxPitchSpeed=700.000000
     WheelSoftness=0.040000
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
     WheelHandbrakeFriction=0.100000
     WheelSuspensionTravel=25.000000
     WheelSuspensionOffset=-10.000000
     WheelSuspensionMaxRenderTravel=25.000000
     FTScale=0.030000
     ChassisTorqueScale=0.700000
     MinBrakeFriction=4.000000
     MaxSteerAngleCurve=(Points=((OutVal=25.000000),(InVal=1500.000000,OutVal=8.000000),(InVal=1000000000.000000,OutVal=8.000000)))
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
     EngineInertia=0.100000
     IdleRPM=500.000000
     EngineRPMSoundRange=10000.000000
     SteerBoneAxis=AXIS_Z
     SteerBoneMaxAngle=90.000000
     RevMeterScale=4000.000000
     DaredevilThreshInAirSpin=90.000000
     DaredevilThreshInAirTime=1.200000
     bDoStuntInfo=True
     bAllowBigWheels=True
     AirTurnTorque=35.000000
     AirPitchTorque=55.000000
     AirPitchDamping=35.000000
     AirRollTorque=35.000000
     AirRollDamping=35.000000
     RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     IdleSound=Sound'ONSVehicleSounds-S.Tank.TankEng01'
     StartUpSound=Sound'ONSVehicleSounds-S.Tank.TankStart01'
     ShutDownSound=Sound'ONSVehicleSounds-S.Tank.TankStop01'
     StartUpForce="TankStartUp"
     ShutDownForce="TankShutDown"
     ViewShakeRadius=600.000000
     ViewShakeOffsetMag=(X=0.500000,Z=2.000000)
     ViewShakeOffsetFreq=7.000000
     DestroyedVehicleMesh=StaticMesh'ONSDeadVehicles-SM.TankDead'
     DestructionEffectClass=Class'Onslaught.ONSVehicleExplosionEffect'
     DisintegrationEffectClass=Class'Onslaught.ONSVehDeathHoverTank'
     DisintegrationHealth=-125.000000
     DestructionLinearMomentum=(Min=250000.000000,Max=400000.000000)
     DestructionAngularMomentum=(Min=100.000000,Max=300.000000)
     DamagedEffectScale=5.000000
     DamagedEffectOffset=(Z=400.000000)
     bEnableProximityViewShake=True
     bNeverReset=True
     VehicleMass=5.000000
     bDrawMeshInFP=True
     bEnterringUnlocks=False
     bHasHandbrake=True
     bKeyVehicle=True
     bDriverHoldsFlag=False
     bFPNoZFromCameraPitch=True
     ExitPositions(0)=(Y=-500.000000,Z=100.000000)
     EntryRadius=1500.000000
     FPCamPos=(X=700.000000,Z=130.000000)
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(X=200.000000,Z=600.000000)
     MomentumMult=0.100000
     DriverDamageMult=0.000000
     VehiclePositionString="in a Mobile Construction Vehicle"
     VehicleNameString="Mobile Construction Vehicle"
     RanOverDamageType=Class'Onslaught.DamTypeTankRoadkill'
     CrushedDamageType=Class'Onslaught.DamTypeTankPancake'
     MaxDesireability=0.800000
     HornSounds(0)=Sound'ONSVehicleSounds-S.Horns.Horn09'
     GroundSpeed=300.000000
     HealthMax=5000.000000
     Health=5000
     CollisionRadius=500.000000
     CollisionHeight=200.000000
}
