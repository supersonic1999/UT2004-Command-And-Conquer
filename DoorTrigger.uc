class DoorTrigger extends Trigger;

#exec OBJ LOAD FILE="..\StaticMeshes\CommandAndConquerSM.usx"

var CCMover DoorOne, DoorTwo;
var() sound OpeningSound, ClosingSound;

simulated function Touch( actor Other )
{
	if(xPawn(Other) != none)
	{
        if(DoorOne != none)
            DoorOne.Trigger(self, Other.Instigator);
        if(DoorTwo != none)
            DoorTwo.Trigger(self, Other.Instigator);
        PlaySound(OpeningSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
    }
}

simulated function UnTouch( actor Other )
{
    local xPawn P;
    local bool bKeepClosed;

    if(xPawn(Other) != none)
	{
        foreach RadiusActors(class'xPawn', P, CollisionRadius)
        {
            if(P != none && P != xPawn(Other))
            {
                bKeepClosed = True;
                break;
            }
        }

        if(bKeepClosed == False)
        {
            if(DoorOne != none)
                DoorOne.UnTrigger(self, Other.Instigator);
            if(DoorTwo != none)
                DoorTwo.UnTrigger(self, Other.Instigator);
            PlaySound(ClosingSound, SLOT_None, SoundVolume / 255.0, false, SoundRadius, SoundPitch / 64.0);
        }
    }
}

simulated function Destroyed()
{
    if(DoorOne != none)
        DoorOne.Destroy();
    if(DoorTwo != none)
        DoorTwo.Destroy();

	super.Destroyed();
}

simulated function PostBeginPlay()
{
    local vector RotX, RotY, RotZ;

    super.PostBeginPlay();
    GetAxes(Rotation,RotX,RotY,RotZ);

    DoorOne = Spawn(class'CCMover', self,, Location, Rotation);
    DoorOne.SetMoveLocation(DoorOne.Location, Location + 60 * RotY);
    DoorOne.SetStaticMesh(StaticMesh'CommandAndConquerSM.Misc.Door2');
    DoorOne.SetBase(self);
    DoorTwo = Spawn(class'CCMover', self,, Location, Rotation);
    DoorTwo.SetMoveLocation(DoorTwo.Location, Location - 60 * RotY);
    DoorTwo.SetBase(self);
}

defaultproperties
{
     OpeningSound=Sound'IndoorAmbience.door1'
     ClosingSound=Sound'IndoorAmbience.door11'
     SoundVolume=255
     SoundRadius=256.000000
     CollisionRadius=128.000000
     CollisionHeight=256.000000
}
