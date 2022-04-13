class StealthTank extends ONSShockTank;

var int SavedShootTime, ReCloakTime;
var bool bInvis;
var Material InvisMaterial;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
		bInvis;
    reliable if(bNetDirty && Role<ROLE_Authority)
		SavedShootTime;
    reliable if(Role==ROLE_Authority)
		ClientSetInvis;
    reliable if(Role<ROLE_Authority)
		SetInvis;
}

function KDriverEnter(Pawn P)
{
   super.KDriverEnter(P);
   SavedShootTime = Level.TimeSeconds;
}

function DriverLeft()
{
    super.DriverLeft();

    if(bInvis)
        SetInvis(false);
}

simulated function Fire( optional float F )
{
    if(bInvis)
        SetInvis(false);
    super.Fire(F);
}

simulated function AltFire( optional float F )
{
    if(bInvis)
        SetInvis(false);
    super.AltFire(F);
}

function SetInvis(bool Invis)
{
    if(Invis)
    {
        bInvis = True;
        ClientSetInvis(Invis);
        SetInvisibility(60);
        //Visibility = 1;
        Projectors.Remove(0, Projectors.Length);
	    bAcceptsProjectors = false;
        if(VehicleShadow != None)
			VehicleShadow.bShadowActive = false;
    }
    else
    {
        bInvis = False;
        SavedShootTime = Level.TimeSeconds;
        ClientSetInvis(Invis);
        SetInvisibility(0);
        //Visibility = default.Visibility;
        bAcceptsProjectors = default.bAcceptsProjectors;
        if(VehicleShadow != None)
			VehicleShadow.bShadowActive = True;
    }
}

simulated function ClientSetInvis(bool Invis)
{
    if(Invis)
    {
	    Projectors.Remove(0, Projectors.Length);
	    bAcceptsProjectors = false;
	    //Visibility = 1;
        if(VehicleShadow != None)
			VehicleShadow.bShadowActive = false;
    }
    else
    {
	    bAcceptsProjectors = default.bAcceptsProjectors;
	    //Visibility = default.Visibility;
        if(VehicleShadow != None)
			VehicleShadow.bShadowActive = True;
    }
}

function Tick(float DeltaTime)
{
    if(ROLE==ROLE_Authority && Level.TimeSeconds >= (SavedShootTime + ReCloakTime))
	    SetInvis(true);
    super.Tick(DeltaTime);
}

simulated function SetInvisibility(int InvisTime)
{
    local int i;

    for(i=0;i<Weapons.length;i++)
        Weapons[i].SetOverlayMaterial(InvisMaterial, InvisTime, true);

    for(i=0;i<WeaponPawns.length;i++)
        WeaponPawns[i].SetOverlayMaterial(InvisMaterial, InvisTime, true);

    SetOverlayMaterial(InvisMaterial, InvisTime, true);
}

defaultproperties
{
     ReCloakTime=5
     InvisMaterial=FinalBlend'XEffectMat.Combos.InvisOverlayFB'
     DriverWeapons(0)=(WeaponClass=Class'commandandconquer.StealthTankCannon')
     PassengerWeapons(0)=(WeaponPawnClass=Class'commandandconquer.CCPassangerSeat',WeaponBone="CannonAttach")
     VehiclePositionString="in a Stealth Tank"
     VehicleNameString="Stealth Tank"
     HealthMax=400.000000
     Health=400
}
