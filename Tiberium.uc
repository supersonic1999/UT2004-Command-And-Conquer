class Tiberium extends PhysicsVolume;

function CausePainTo(Actor Other)
{
    if(Other.IsA('Vehicle') && bDamagesVehicles == False)
        return;

    super.CausePainTo(Other);
}

defaultproperties
{
     DamagePerSec=2.000000
     DamageType=Class'Engine.FellLava'
     bPainCausing=True
     bDestructive=True
     bNoInventory=True
     bDamagesVehicles=False
     LocationName="in tiberium"
     RemoteRole=ROLE_None
}
