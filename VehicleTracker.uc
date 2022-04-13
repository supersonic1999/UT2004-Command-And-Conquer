class VehicleTracker extends Actor;

var Vehicle TrackedVehicle;
var float SpawnTime;
var int WaitTime;

function SetTrackedVehicle(Vehicle VT)
{
    TrackedVehicle = VT;
}

function PostBeginPlay()
{
    SpawnTime = Level.TimeSeconds;
    super.PostBeginPlay();
}

function Tick(float DeltaTime)
{
    if(Level.TimeSeconds > (SpawnTime + WaitTime))
    {
        if(TrackedVehicle != none)
            TrackedVehicle.bSpawnProtected = false;
        Destroy();
    }
    else if(TrackedVehicle != none && TrackedVehicle.bSpawnProtected == false)
        Destroy();
    super.Tick(DeltaTime);
}

defaultproperties
{
     WaitTime=90
     bHidden=True
}
