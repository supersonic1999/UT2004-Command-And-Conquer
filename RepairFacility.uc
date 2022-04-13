class RepairFacility extends CCBuildings;

var int HealthPlus;

simulated function Timer()
{
    local Vehicle V;
    local int i;

    if(bBuilt)
    {
        foreach RadiusActors(class'Vehicle', V, 300)
        {
            if(V != none && V.Team == Team && V.Health < V.default.HealthMax)
            {
                if(V.Health + HealthPlus > V.default.HealthMax)
                    i = (V.default.HealthMax - V.Health);
                else
                    i = HealthPlus;

                V.Health += i;
                break;
            }
        }
    }
    super.Timer();
}

simulated function FullyBuilt()
{
    super.FullyBuilt();
	SetTimer(1.0,True);
}

defaultproperties
{
     HealthPlus=20
     BuildingImage=Texture'CommandAndConquerTEX.BuildingPICS.RepairFacPIC'
     BuildingName="Repair Facility"
     StartPositionNum=500
     EndPositionNum=50
     BuildDuration=15
     MaxAmount=-1
     BuildCost=1200
     Health=2000
     bNeedsToBeDestroyed=False
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.RepairFacility'
     PrePivot=(Z=80.000000)
     CollisionRadius=350.000000
}
