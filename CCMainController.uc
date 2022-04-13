class CCMainController extends Actor
    placeable;

const Version = 1;

struct BaseBuildings
{
    var class<CCBuildings> RedBuilding;
    var class<CCBuildings> BlueBuilding;
};
struct VehicleStruct
{
    var int Cost;
    var string VName;
    var class<Vehicle> Summon;
};
var() config array<VehicleStruct> GDIVehicles, NODVehicles;
var() config array<BaseBuildings> Buildings;
var() config array<class<BaseCharacterModifier> > GDIWeapon, NODWeapon, GDIBasic, NODBasic;

defaultproperties
{
     GDIVehicles(0)=(cost=350,VName="Humm-Vee",Summon=Class'commandandconquer.Hummer')
     GDIVehicles(1)=(cost=500,VName="Armoured Personnel Carrier",Summon=Class'commandandconquer.NodAPC')
     GDIVehicles(2)=(cost=450,VName="Mobile Rocket Launcher System",Summon=Class'commandandconquer.MRLS')
     GDIVehicles(3)=(cost=800,VName="Medium Tank",Summon=Class'commandandconquer.MediumTank')
     GDIVehicles(4)=(cost=1500,VName="Mammoth Tank",Summon=Class'commandandconquer.MammothTank')
     GDIVehicles(5)=(cost=700,VName="Transport Helicopter",Summon=Class'commandandconquer.TransportHeli')
     GDIVehicles(6)=(cost=900,VName="Orca VTOL Assault Craft",Summon=Class'commandandconquer.Orca')
     NODVehicles(0)=(cost=300,VName="Nod Buggy",Summon=Class'commandandconquer.NodBuggy')
     NODVehicles(1)=(cost=500,VName="Armoured Personnel Carrier",Summon=Class'commandandconquer.NodAPC')
     NODVehicles(2)=(cost=450,VName="Mobile Artillery",Summon=Class'commandandconquer.NODArtillery')
     NODVehicles(3)=(cost=800,VName="Flame Tank",Summon=Class'commandandconquer.FlameTank')
     NODVehicles(4)=(cost=600,VName="Light Tank",Summon=Class'commandandconquer.LightTank')
     NODVehicles(5)=(cost=900,VName="Stealth Tank",Summon=Class'commandandconquer.StealthTank')
     NODVehicles(6)=(cost=700,VName="Transport Helicopter",Summon=Class'commandandconquer.TransportHeli')
     NODVehicles(7)=(cost=900,VName="Apache Attack Helicopter",Summon=Class'commandandconquer.Apache')
     Buildings(0)=(RedBuilding=Class'commandandconquer.PowerPlant',BlueBuilding=Class'commandandconquer.PowerPlant')
     Buildings(1)=(RedBuilding=Class'commandandconquer.Air_Strip',BlueBuilding=Class'commandandconquer.WarFactory')
     Buildings(2)=(RedBuilding=Class'commandandconquer.HandOfNod',BlueBuilding=Class'commandandconquer.Barracks')
     Buildings(3)=(RedBuilding=Class'commandandconquer.TiberiumRef',BlueBuilding=Class'commandandconquer.TiberiumRef')
     Buildings(4)=(RedBuilding=Class'commandandconquer.Obelisk',BlueBuilding=Class'commandandconquer.AdvancedGT')
     Buildings(5)=(RedBuilding=Class'commandandconquer.NODTurret',BlueBuilding=Class'commandandconquer.NODTurret')
     Buildings(6)=(RedBuilding=Class'commandandconquer.ComCenter',BlueBuilding=Class'commandandconquer.ComCenter')
     Buildings(7)=(RedBuilding=Class'commandandconquer.RepairFacility',BlueBuilding=Class'commandandconquer.RepairFacility')
     Buildings(8)=(RedBuilding=Class'commandandconquer.HeliPad',BlueBuilding=Class'commandandconquer.HeliPad')
     Buildings(9)=(RedBuilding=Class'commandandconquer.ConcreteWall',BlueBuilding=Class'commandandconquer.ConcreteWall')
     Buildings(10)=(RedBuilding=Class'commandandconquer.TempleOfNod',BlueBuilding=Class'commandandconquer.AdvComCenter')
     GDIWeapon(0)=Class'commandandconquer.GDIOfficerModifier'
     GDIWeapon(1)=Class'commandandconquer.RocketOfficerModifier'
     GDIWeapon(2)=Class'commandandconquer.SydneyModifier'
     GDIWeapon(3)=Class'commandandconquer.DeadeyeModifier'
     GDIWeapon(4)=Class'commandandconquer.GunnerModifier'
     GDIWeapon(5)=Class'commandandconquer.PatchModifier'
     GDIWeapon(6)=Class'commandandconquer.HavocModifier'
     GDIWeapon(7)=Class'commandandconquer.SydneyTwoModifier'
     GDIWeapon(8)=Class'commandandconquer.MobiusModifier'
     GDIWeapon(9)=Class'commandandconquer.AdvEngiModifier'
     NODWeapon(0)=Class'commandandconquer.NodOfficerModifier'
     NODWeapon(1)=Class'commandandconquer.RocketOfficerNodModifier'
     NODWeapon(2)=Class'commandandconquer.ChemWarriorModifier'
     NODWeapon(3)=Class'commandandconquer.BlackHandModifier'
     NODWeapon(4)=Class'commandandconquer.BlackHand2Modifier'
     NODWeapon(5)=Class'commandandconquer.SBHModifier'
     NODWeapon(6)=Class'commandandconquer.SakuraModifier'
     NODWeapon(7)=Class'commandandconquer.RaveshawModifier'
     NODWeapon(8)=Class'commandandconquer.MendozaModifier'
     NODWeapon(9)=Class'commandandconquer.TechnicianModifier'
     GDIBasic(0)=Class'commandandconquer.SoldierModifier'
     GDIBasic(1)=Class'commandandconquer.ShotgunTrooperModifier'
     GDIBasic(2)=Class'commandandconquer.GrenadierModifier'
     GDIBasic(3)=Class'commandandconquer.EngineerModifier'
     NODBasic(0)=Class'commandandconquer.SoldierNodModifier'
     NODBasic(1)=Class'commandandconquer.ShotgunTrooperModifier'
     NODBasic(2)=Class'commandandconquer.FlamethrowerModifier'
     NODBasic(3)=Class'commandandconquer.EngineerModifier'
     bHidden=True
     bAlwaysRelevant=True
}
