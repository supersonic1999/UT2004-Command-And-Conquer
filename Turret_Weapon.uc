class Turret_Weapon extends ASTurret_BallTurret;

var CCBuildings Holder;

/*replication - No need for replication
{
	reliable if(Role<ROLE_Authority)
		Holder;
}*/

static function StaticPrecache(LevelInfo L);

simulated function UpdatePrecacheStaticMeshes();

simulated function UpdatePrecacheMaterials();

function TakeDamage(int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	//if(Holder != none) To stop turret from getting double damage from splash damage
	//	Holder.TakeDamage(NDamage, instigatedBy, hitlocation, momentum, damageType);
}

defaultproperties
{
     TurretBaseClass=None
     DefaultWeaponClassName="CommandAndConquer.NOD_Turret_Turret"
     bNonHumanControl=True
     AutoTurretControllerClass=Class'commandandconquer.NODTurretController'
     MaxViewPitch=0
     VehicleNameString="Turret"
     SightRadius=18000.000000
     HealthMax=1000.000000
     Health=1000
     Mesh=SkeletalMesh'commandandconquer.Turret'
     DrawScale=0.750000
     CollisionRadius=100.000000
     CollisionHeight=50.000000
     bCollideActors=False
     bBlockActors=False
     bProjTarget=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     RotationRate=(Pitch=0,Yaw=6000,Roll=0)
}
