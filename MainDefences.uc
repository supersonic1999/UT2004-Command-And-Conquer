class MainDefences extends CCBuildings;

var Obelisk_Weapon NOD;
var Obelisk_Weapon GDI[5];
var bool BuiltWeapon;

function BuildWeapon()
{
    if(Team != 0 && GDI[0] == none)
    {
       GDI[0] = Spawn(class'AGT_Weapon', self,, SpawnOffsets[0]);
       GDI[1] = Spawn(class'AGT_SmallWeapon', self,, SpawnOffsets[1]);
       GDI[2] = Spawn(class'AGT_SmallWeapon', self,, SpawnOffsets[2]);
       GDI[3] = Spawn(class'AGT_SmallWeapon', self,, SpawnOffsets[3]);
       GDI[4] = Spawn(class'AGT_SmallWeapon', self,, SpawnOffsets[4]);
       GDI[0].SetTeamNum(Team);
       GDI[1].SetTeamNum(Team);
       GDI[2].SetTeamNum(Team);
       GDI[3].SetTeamNum(Team);
       GDI[4].SetTeamNum(Team);
    }
    else if(Team == 0 && NOD == none)
    {
       NOD = Spawn(class'Obelisk_Weapon', self,, SpawnOffsets[0]);
       NOD.SetTeamNum(Team);
    }
    BuiltWeapon=True;
}

function bool BePowered()
{
   local PowerPlant PowerName;

   foreach DynamicActors(class'PowerPlant', PowerName)
       if(PowerName.Team == Team && PowerName.bBuilt == true)
           return true;
   return false;
}

function Timer()
{
    local bool Power;

    Power = BePowered();

    if(Power == false && NOD != none || NOD != none && NOD.Health <= 0)
    {
        NOD.Destroy();
        NOD = none;
        BuiltWeapon = false;
    }

    if(Power == false && GDI[0] != none || GDI[0] != none && GDI[0].Health <= 0)
    {
        GDI[0].Destroy();
        GDI[1].Destroy();
        GDI[2].Destroy();
        GDI[3].Destroy();
        GDI[4].Destroy();
        GDI[0] = none;
        GDI[1] = none;
        GDI[2] = none;
        GDI[3] = none;
        GDI[4] = none;
        BuiltWeapon = false;
    }

    if(bBuilt == true && Power == true && BuiltWeapon == false)
       BuildWeapon();

    super.Timer();
}

simulated event Destroyed()
{
    if(NOD != none && NOD.Health > 0)
       NOD.Destroy();

    if(GDI[0] != none && GDI[0].Health > 0)
    {
        GDI[0].Destroy();
        GDI[1].Destroy();
        GDI[2].Destroy();
        GDI[3].Destroy();
        GDI[4].Destroy();
    }

	Super.Destroyed();
}

defaultproperties
{
     RequestedTimerRate=1.000000
     StartPositionNum=300
     EndPositionNum=2200
     BuildDuration=20
     BuildCost=1500
     Health=2000
     StaticMesh=StaticMesh'CommandAndConquerSM.Buildings.Obelisk'
}
