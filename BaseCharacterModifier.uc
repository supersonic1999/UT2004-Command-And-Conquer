class BaseCharacterModifier extends Inventory;

var array<string> GivenWeapons;
var int DefaultHealth, DefaultShield, ClassCost;
var string ClassName;

simulated function PostBeginPlay()
{
    local array<class<Weapon> > WeaponClass;
    local int i;
    local Inventory Inv;

    super.PostBeginPlay();

    if(Instigator != none)
    {
        Instigator.Health = DefaultHealth;
        Instigator.HealthMax = DefaultHealth;
        Instigator.SuperHealthMax = DefaultHealth;
        Instigator.ShieldStrength = DefaultShield;
        xPawn(Instigator).ShieldStrengthMax = DefaultShield;

        if(Role == ROLE_Authority)
        {
            if(CCPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none)
            {
                if(CCPlayerReplicationInfo(Instigator.PlayerReplicationInfo).BCM != none)
                    CCPlayerReplicationInfo(Instigator.PlayerReplicationInfo).BCM.Destroy();
                CCPlayerReplicationInfo(Instigator.PlayerReplicationInfo).BCM = self;
            }
            else
                for(Inv=Instigator.Inventory; Inv!=None; Inv=Inv.Inventory)
                    if(Inv != none && BaseCharacterModifier(Inv) != none && BaseCharacterModifier(Inv) != self)
                        Inv.Destroy();

            for(i=0;i<GivenWeapons.Length;i++)
            {
                WeaponClass[WeaponClass.Length] = class<Weapon>(DynamicLoadObject(GivenWeapons[i], class'Class'));
                Instigator.GiveWeapon(GivenWeapons[i]);
            }

            for(Inv=Instigator.Inventory; Inv!=None; Inv=Inv.Inventory)
                if(Inv != none && Weapon(Inv) != none)
                    for(i=0;i<WeaponClass.Length;i++)
                        if(Weapon(Inv).class == WeaponClass[i])
                            Weapon(Inv).MaxOutAmmo();
        }
    }
}

function Destroyed()
{
    local array<class<Weapon> > WeaponClass;
    local array<Inventory> DestroyInvs;
    local int i;
    local Inventory Inv;

    for(i=0;i<GivenWeapons.Length;i++)
        WeaponClass[WeaponClass.Length] = class<Weapon>(DynamicLoadObject(GivenWeapons[i], class'Class'));

    for(Inv=Instigator.Inventory; Inv!=None; Inv=Inv.Inventory)
        if(Inv != none && Weapon(Inv) != none)
            for(i=0;i<WeaponClass.Length;i++)
                if(Weapon(Inv).class == WeaponClass[i])
                    DestroyInvs[DestroyInvs.Length] = Inv;

	for(i=0;i<DestroyInvs.Length;i++)
	    DestroyInvs[i].Destroy();

    super.Destroyed();
}

defaultproperties
{
     GivenWeapons(0)="CommandAndConquer.Pistol"
     GivenWeapons(1)="CommandAndConquer.C4Timed"
     DefaultHealth=100
     DefaultShield=100
     ClassCost=100
     ClassName="Base Character"
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
