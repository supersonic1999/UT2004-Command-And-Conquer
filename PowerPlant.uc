class PowerPlant extends CCBuildings;

var Smoke Smoke;
var vector SmokeLoc;
var int PowerAmount;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
		SmokeLoc;
}

simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if(ROLE < ROLE_Authority && Smoke == none && bBuilt == True)
    {
        Smoke = spawn(class'Smoke', self);
        Smoke.SetBase(self);
    }

    if(ROLE == ROLE_Authority && bBuilt == True)
    {
        if(SmokeLoc.X != SpawnOffsets[0].X)
            SmokeLoc.X = SpawnOffsets[0].X;
        if(SmokeLoc.Y != SpawnOffsets[0].Y)
            SmokeLoc.Y = SpawnOffsets[0].Y;
        if(SmokeLoc.Z != SpawnOffsets[0].Z)
            SmokeLoc.Z = SpawnOffsets[0].Z;
    }

    if(ROLE < ROLE_Authority && Smoke != none && Smoke.Location != SmokeLoc)
        Smoke.SetLocation(SmokeLoc);
}

simulated function Destroyed()
{
    if(Smoke != none)
        Smoke.Destroy();
    super.Destroyed();
}

defaultproperties
{
     PowerAmount=5
     Door(0)=(DoorOffset=(X=204.000000,Y=-421.000000,Z=-264.000000))
     Door(1)=(DoorOffset=(X=487.000000,Y=419.000000,Z=-264.000000))
     PlayerStartLoc(0)=(PLocation=(X=10.000000,Y=-352.000000,Z=-309.000000))
     PlayerStartLoc(1)=(PLocation=(X=10.000000,Y=111.000000,Z=-309.000000))
     PlayerStartLoc(2)=(PLocation=(X=229.000000,Y=414.000000,Z=-309.000000))
     BuildingName="Power Plant"
     StartPositionNum=1090
     EndPositionNum=340
     BuildDuration=5
     BuildCost=300
     MCTOffset=(X=-297.000000,Z=-282.000000)
     MCTRotation=(Yaw=-65536)
     SwitchOffsets(0)=(X=165.000000,Y=150.000000,Z=-250.000000)
     SwitchOffsets(1)=(X=165.000000,Y=-160.000000,Z=-250.000000)
     SpawnOffsets(0)=(X=240.000000)
     TerminalRot(0)=(Yaw=32768)
     TerminalRot(1)=(Yaw=32768)
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.PowerPlant'
     CollisionRadius=1000.000000
}
