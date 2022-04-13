class SBHModifier extends BaseCharacterModifier;

var int SavedShootTime, ReCloakTime;

function Tick(float DeltaTime)
{
    if(Owner != none && Pawn(Owner) != none && Level.TimeSeconds >= (SavedShootTime + ReCloakTime))
        xPawn(Owner).SetInvisibility(2000000.0);
    if(Owner != none && Pawn(Owner) != none && Pawn(Owner).Weapon != none && Pawn(Owner).Weapon.IsFiring())
    {
        SavedShootTime = Level.TimeSeconds;
        xPawn(Owner).SetInvisibility(0);
    }
    super.Tick(DeltaTime);
}

simulated function Destroyed()
{
    if(Owner != none && Pawn(Owner) != none)
        xPawn(Owner).SetInvisibility(0);
	super.Destroyed();
}

defaultproperties
{
     ReCloakTime=5
     GivenWeapons(2)="CommandAndConquer.LaserRifle"
     DefaultHealth=200
     ClassCost=400
     ClassName="Stealth Black Hand"
}
