class HeliPad extends CCBuildings;

defaultproperties
{
     RedSkin=Texture'CommandAndConquerTEX.HeliPadTEX_NOD'
     BlueSkin=Texture'CommandAndConquerTEX.HeliPadTEX_GDI'
     BuildingImage=Texture'CommandAndConquerTEX.BuildingPICS.HeliPadPIC'
     BuildingName="Heli Pad"
     StartPositionNum=200
     EndPositionNum=101
     BuildDuration=20
     MaxAmount=-1
     BuildCost=1500
     Health=1500
     bNeedsToBeDestroyed=False
     SpawnOffsets(0)=(Z=300.000000)
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.HeliPad'
     PrePivot=(Z=100.000000)
     CollisionRadius=1250.000000
}
