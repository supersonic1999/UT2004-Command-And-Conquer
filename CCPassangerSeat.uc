class CCPassangerSeat extends ONSWeaponPawn;

replication
{
    reliable if(Role==ROLE_Authority)
		ChangeLookPosition;
}

function PostBeginPlay()
{
    super.PostBeginPlay();
    if(Vehicle(Owner) != none)
    {
        FPCamPos = Vehicle(Owner).FPCamPos;
        TPCamLookat = Vehicle(Owner).TPCamLookat;
        TPCamWorldOffset = Vehicle(Owner).TPCamWorldOffset;
        TPCamDistance = Vehicle(Owner).TPCamDistance;
        ChangeLookPosition(FPCamPos, TPCamLookat, TPCamWorldOffset, TPCamDistance);
    }
}

simulated function ChangeLookPosition(vector FPPos, vector TPLook, vector TPWorld, int TPDistance)
{
    FPCamPos = FPPos;
    TPCamLookat = TPLook;
    TPCamWorldOffset = TPWorld;
    TPCamDistance = TPDistance;
}

defaultproperties
{
     GunClass=Class'commandandconquer.CCPassangerGun'
     bDrawDriverInTP=False
     ExitPositions(0)=(Y=100.000000)
     EntryRadius=200.000000
     FPCamPos=(X=15.000000,Z=25.000000)
     TPCamDistance=375.000000
     TPCamLookat=(X=0.000000,Z=0.000000)
     TPCamWorldOffset=(Z=100.000000)
     VehicleNameString="Passanger Seat"
}
