class ComCenter extends CCBuildings;

var RadarActor RActor;

function Timer()
{
    local PowerPlant PPlant;

    if(bBuilt && RActor != none)
    {
        foreach DynamicActors(class'PowerPlant', PPlant)
        {
            if(PPlant.Team == Team && PPlant.bBuilt)
                break;
            PPlant = none;
        }

        if(PPlant == none && RActor.bActive)
            RActor.bActive = false;
        else if(PPlant != none && !RActor.bActive)
            RActor.bActive = True;
    }
    super.Timer();
}

function FullyBuilt()
{
    super.FullyBuilt();

    foreach DynamicActors(class'RadarActor', RActor)
    {
        if(RActor.Team == Team)
            break;

        RActor = none;
    }

    if(RActor == none)
    {
        RActor = Spawn(class'RadarActor', self);
        RActor.Team = Team;
    }
}

simulated function Destroyed()
{
    local ComCenter CCenter;

    foreach DynamicActors(class'ComCenter', CCenter)
    {
        if(CCenter.Team == Team && CCenter != self)
            break;

        CCenter = none;
    }

    if(CCenter == none && RActor != none)
        RActor.Destroy();

	super.Destroyed();
}

defaultproperties
{
     Door(0)=(DoorOffset=(X=-581.000000,Y=-71.000000,Z=118.000000))
     Door(1)=(DoorOffset=(X=412.000000,Y=-851.000000,Z=118.000000),DoorRotation=(Yaw=-16384))
     PlayerStartLoc(0)=(PLocation=(X=-199.000000,Y=490.000000,Z=81.000000))
     PlayerStartLoc(1)=(PLocation=(X=-199.000000,Y=291.000000,Z=81.000000))
     PlayerStartLoc(2)=(PLocation=(X=70.000000,Y=491.000000,Z=81.000000),PRotation=(Yaw=-22984))
     PlayerStartLoc(3)=(PLocation=(X=-306.000000,Y=-57.000000,Z=81.000000))
     PlayerStartLoc(4)=(PLocation=(X=427.000000,Y=28.000000,Z=81.000000),PRotation=(Yaw=-29808))
     PlayerStartLoc(5)=(PLocation=(X=428.000000,Y=-219.000000,Z=81.000000),PRotation=(Yaw=-31268))
     PlayerStartLoc(6)=(PLocation=(X=417.000000,Y=-654.000000,Z=81.000000),PRotation=(Yaw=17156))
     BuildingImage=Texture'CommandAndConquerTEX.BuildingPICS.ComCenterPIC'
     BuildingName="Communication Center"
     RequestedTimerRate=1.000000
     StartPositionNum=1347
     EndPositionNum=0
     BuildDuration=15
     MaxAmount=-1
     Health=2000
     MCTOffset=(X=439.000000,Y=394.000000,Z=79.000000)
     MCTRotation=(Yaw=32768)
     SwitchOffsets(0)=(X=-304.000000,Y=386.000000,Z=95.000000)
     SwitchOffsets(1)=(X=581.000000,Y=-607.000000,Z=127.000000)
     TerminalRot(1)=(Yaw=32768)
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.ComCenter'
     CollisionRadius=1500.000000
}
