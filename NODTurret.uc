class NODTurret extends CCBuildings;

var Turret_Weapon Turret;
var Material GDITurretSkin, NODTurretSkin;

replication
{
	reliable if(Role==ROLE_Authority)
		Turret;
}

function Timer()
{
    super.Timer();

    if(Turret != none)
    {
        Turret.Health = Health;
        Turret.default.Health = default.Health;

        if(Turret.Team == 0)
            Turret.Skins[0] = NODTurretSkin;
        else if(Turret.Team == 0)
            Turret.Skins[0] = GDITurretSkin;
    }
}

function FullyBuilt()
{
    super.FullyBuilt();
    if(Turret == none)
    {
        Turret = spawn(class'Turret_Weapon', self,, SpawnOffsets[0]);
        Turret.SetBase(self);
        Turret.SetTeamNum(Team);
        Turret.Holder = self;
        LinkedActors[LinkedActors.Length] = Turret;
    }
}

simulated function Destroyed()
{
    super.Destroyed();
    if(Turret != none)
        Turret.Destroy();
}

defaultproperties
{
     GDITurretSkin=Combiner'VMVehicles-TX.HoverTankGroup.TankCBred'
     NODTurretSkin=Combiner'VMVehicles-TX.HoverTankGroup.TankCBred'
     BuildingImage=Texture'CommandAndConquerTEX.BuildingPICS.TurretPIC'
     BuildingName="Turret"
     StartPositionNum=200
     EndPositionNum=0
     BuildDuration=10
     MaxAmount=10
     ScoreKill=100
     BuildCost=500
     Health=1100
     bNeedsToBeDestroyed=False
     SpawnOffsets(0)=(Z=96.000000)
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.TurretBase'
     DrawScale=0.600000
     CollisionRadius=150.000000
}
