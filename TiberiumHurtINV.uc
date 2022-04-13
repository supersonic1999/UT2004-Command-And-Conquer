class TiberiumHurtINV extends Inventory;

var int TimeIn;

function PostBeginPlay()
{
    SetTimer(0.25,True);
    super.PostBeginPlay();
}

function Timer()
{
    if(TimeIn > Level.TimeSeconds - 3)
        Owner.TakeDamage(1, none, Location, vect(0,0,0), class'TiberiumDT');
    else
        Destroy();
    super.Timer();
}

defaultproperties
{
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
