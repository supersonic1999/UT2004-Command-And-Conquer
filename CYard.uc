class CYard extends CCBuildings;

var() config int HealAmount;

function Timer()
{
    local CCBuildings Buildings;

    if(bBuilt)
        for(Buildings=Class'CCBuildings'.Static.PickFirstBuilding(Level); Buildings!=None; Buildings=Buildings.NextBuilding)
            if(Buildings != none && Buildings.Team == Team && Buildings.Health < Buildings.default.Health)
                Buildings.ChangeHealth(HealAmount);
    super.Timer();
}

defaultproperties
{
     HealAmount=5
     Door(0)=(DoorOffset=(X=722.000000,Y=802.999878,Z=93.000000))
     Door(1)=(DoorOffset=(X=-534.999878,Y=-1708.000122,Z=93.000000),DoorRotation=(Yaw=-16384))
     Door(2)=(DoorOffset=(X=-480.000000,Y=-31.000000,Z=109.000000),DoorRotation=(Yaw=16384))
     Door(3)=(DoorOffset=(X=-608.000000,Y=693.000000,Z=109.000000))
     Door(4)=(DoorOffset=(X=-1256.000122,Y=-978.000000,Z=93.000000),DoorRotation=(Yaw=-16384))
     Door(5)=(DoorOffset=(X=-788.000122,Y=-1126.000000,Z=93.000000))
     Door(6)=(DoorOffset=(X=-1523.000122,Y=-1126.000000,Z=93.000000))
     Door(7)=(DoorOffset=(X=454.000000,Y=-34.000000,Z=97.000000),DoorRotation=(Yaw=16384))
     PlayerStartLoc(0)=(PLocation=(X=192.000000,Y=-575.000000,Z=71.000000))
     PlayerStartLoc(1)=(PLocation=(X=-284.000000,Y=-575.000000,Z=71.000000))
     PlayerStartLoc(2)=(PLocation=(X=-684.000000,Y=-575.000000,Z=71.000000))
     PlayerStartLoc(3)=(PLocation=(X=-900.000000,Y=733.000000,Z=71.000000))
     PlayerStartLoc(4)=(PLocation=(X=-1260.000000,Y=-1139.000000,Z=71.000000))
     PlayerStartLoc(5)=(PLocation=(X=-332.000000,Y=-1283.000000,Z=71.000000))
     RedSkin=Texture'CommandAndConquerTEX.BuildingTEX.NODConTEX'
     BlueSkin=Texture'CommandAndConquerTEX.BuildingTEX.GDIConTEX'
     BuildingImage=Texture'CommandAndConquerTEX.BuildingPICS.CYardPIC'
     BuildingName="Construction Yard"
     RequestedTimerRate=1.000000
     StartPositionNum=1850
     EndPositionNum=650
     ScoreKill=3000
     BuildCost=5000
     Health=7000
     MCTOffset=(X=137.000000,Y=-184.000000,Z=73.000000)
     MCTRotation=(Yaw=32768)
     SwitchOffsets(0)=(X=326.000000,Y=473.000000,Z=98.000000)
     SwitchOffsets(1)=(X=-307.000000,Y=473.000000,Z=98.000000)
     SwitchOffsets(2)=(X=-768.000000,Y=-1367.000000,Z=98.000000)
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.CYard'
     CollisionRadius=3000.000000
}
