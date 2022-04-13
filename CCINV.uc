class CCINV extends Inventory;

var CYard CYard;
var PowerPlant PowerPlant;
var VehicleBuilding VB;
var SuperWBuilding SWB;
var TiberiumRef TiberiumRef;
var HeliPad HeliPad;
var CharacterBuilding CB;
var CCBuildings CurPlacement;
var class<CCBuildings> CommanderBuilding;
var class<Actor> CreateEffects[2];
var int i, BuildTime;
var byte VMax;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		BuildTime,VMax,CYard,PowerPlant,VB,CB,TiberiumRef,HeliPad,SWB;
    reliable if(Role<ROLE_Authority)
		CheckBuildings,ServerSpawnVehicle,ServerGiveSuperWeapon,Refill,ChangeCharacter;
}

simulated function int Adren()
{
    if(Pawn(Owner) != none && Pawn(Owner).Controller != none)
        return CommandController(Pawn(Owner).Controller).Money;
    return 0;
}

simulated function int CheckVehicleAmount()
{
    local int Num;
    local Vehicle V;

    for(V=Level.Game.VehicleList;V!=none;V=V.NextVehicle)
    {
        if(V.IsA('ConstructionVehicle') || V.IsA('Harvester') || V.IsA('ONSWeaponPawn') || V.IsA('ASTurret') || V.Health <= 0)
            continue;

        if(V.Team == Pawn(Owner).GetTeamNum())
            Num++;
    }
    return Num;
}

simulated function int GetTeamNum()
{
    if(Owner != none && Pawn(Owner) != none)
        return Pawn(Owner).GetTeamNum();
}

simulated function bool bBuildingVehicle()
{
    if(Level.TimeSeconds <= BuildTime + 10)
        return true;
    else
        return false;
}

simulated function Timer()
{
    local int x;

    CheckBuildings();

    if(CB != none && GetTeamNum() != 0)
    {
        x = Rand(CCReplicationInfo(Level.GRI).MainController.GDIWeapon.Length);
        ChangeCharacter(CCReplicationInfo(Level.GRI).MainController.GDIWeapon[x]);
    }
    else if(CB != none && GetTeamNum() == 0)
    {
        x = Rand(CCReplicationInfo(Level.GRI).MainController.NODWeapon.Length);
        ChangeCharacter(CCReplicationInfo(Level.GRI).MainController.NODWeapon[x]);
    }
    else if(GetTeamNum() != 0)
    {
        x = Rand(4);
        ChangeCharacter(CCReplicationInfo(Level.GRI).MainController.GDIBasic[x]);
    }
    else
    {
        x = Rand(4);
        ChangeCharacter(CCReplicationInfo(Level.GRI).MainController.NODBasic[x]);
    }

    super.Timer();
}

function CheckBuildings()
{
	local CCBuildings C;
	local byte T;

	VB = None;
	PowerPlant = None;
	TiberiumRef = None;
	CYard = None;
	HeliPad = None;
	SWB = None;
	CB = None;
	T = Pawn(Owner).GetTeamNum();
	For(C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding)
	{
		if(C.Team == T && C.bBuilt)
		{
			if(VB == none)
				VB = VehicleBuilding(C);
			if(CB == None)
				CB = CharacterBuilding(C);
			if(PowerPlant == None)
				PowerPlant = PowerPlant(C);
			if(TiberiumRef == None)
				TiberiumRef = TiberiumRef(C);
			if(CYard == None)
				CYard = CYard(C);
			if(HeliPad == None)
				HeliPad = HeliPad(C);
			if(SWB == None)
				SWB = SuperWBuilding(C);
		}
	}
}

simulated function SpawnVehicle(int Cost, class<Vehicle> VClass, int Sender)
{
    if(Cost < 0 || CheckVehicleAmount() >= VMax)
        return;

    CheckBuildings();

    if(PowerPlant == none)
        Cost *= 2;

    if(Pawn(Owner) != none && Pawn(Owner).Controller != none && CommandController(Pawn(Owner).Controller) != none)
        CommandController(Pawn(Owner).Controller).GiveMoney(-Cost);

    ServerSpawnVehicle(Cost,VClass);
}

function CCBuildings FindClosestBuilding( name BClass )
{
	local CCBuildings C,BC;
	local float D,BD;
	local byte T;

	T = Pawn(Owner).GetTeamNum();
	For(C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding)
	{
		if(C.Team == T && C.bBuilt && C.IsA(BClass))
		{
			D = VSize(C.Location-Owner.Location);
			if(BC == none || D < BD)
			{
				BC = C;
				BD = D;
			}
		}
	}
	Return BC;
}

function ServerSpawnVehicle(int Cost, class<Vehicle> VClass)
{
	local CCBuildings C;
	local Vehicle V;
	local VehicleTracker VT;

	if(ClassIsChildOf(VClass, class'ONSChopperCraft') || ClassIsChildOf(VClass, class'ONSHoverCraft'))
	{
		C = FindClosestBuilding('HeliPad');
		if(C != none)
		{
			Spawn(CreateEffects[C.Team], C,, C.SpawnOffsets[0], C.GetViewRotation());
			V = Spawn(VClass, Instigator.Controller,, C.SpawnOffsets[0], C.GetViewRotation());
		}
	}
	else
	{
		C = FindClosestBuilding('VehicleBuilding');
		if(C != none)
		{
			Spawn(CreateEffects[C.Team], C,, C.SpawnOffsets[0], C.GetViewRotation());
			V = Spawn(VClass, Instigator.Controller,, C.SpawnOffsets[0], C.GetViewRotation());
		}
	}
	if(V != none)
	{
		BuildTime = Level.TimeSeconds;
		V.SetTeamNum(C.Team);
		V.bEnterringUnlocks = true;
		V.bSpawnProtected = true;
		V.bEjectDriver = true;
		VT = V.Spawn(class'VehicleTracker', Instigator);
		VT.TrackedVehicle = V;
		VT.SetBase(V);
	}
}

function ChangeCharacter(class<BaseCharacterModifier> CClass)
{
    local BaseCharacterModifier BCM;

    if(CClass != none && Pawn(Owner) != none)
    {
        if(Pawn(Owner).Controller != none && CommandController(Pawn(Owner).Controller) != none)
            CommandController(Pawn(Owner).Controller).GiveMoney(-CClass.default.ClassCost);
        BCM = Spawn(CClass, Pawn(Owner));
        BCM.Instigator = Pawn(Owner);
        BCM.SetBase(Pawn(Owner));
        BCM.GiveTo(Pawn(Owner));
    }
}

simulated function GiveSuperWeapon(int Cost)
{
    if(CommandController(Pawn(Owner).Controller).Money >= Cost)
    {
        if(Cost > 0)
            CommandController(Pawn(Owner).Controller).GiveMoney(-Cost);
        ServerGiveSuperWeapon(Cost);
    }
}

function ServerGiveSuperWeapon(int Cost)
{
    local Inventory Inv;

    for(Inv=Pawn(Owner).Inventory; Inv!=None; Inv=Inv.Inventory)
	{
        if(Inv != none && Redeemer(Inv) != none || Inv != none && ONSPainter(Inv) != none || Inv != none && Painter(Inv) != none)
        {
            Weapon(Inv).MaxOutAmmo();
            return;
        }
	}

    if(Pawn(Owner).GetTeamNum() == 0)
        Pawn(Owner).giveWeapon("XWeapons.Redeemer");
    else
        Pawn(Owner).giveWeapon("XWeapons.Redeemer");
}

simulated function DoTopView()
{
    if(Owner != none && Pawn(Owner) != none && CCPawn(Pawn(Owner)) != none)
    {
        if(CYard != none && CYard.Team == CommandController(Pawn(Owner).Controller).GetTeamNum())
        {
            CommandController(Pawn(Owner).Controller).CamLocation.X = CYard.Location.X;
            CommandController(Pawn(Owner).Controller).CamLocation.Y = CYard.Location.Y;
        }
        CommandController(Pawn(Owner).Controller).bCommandView = true;
    }
}

simulated function UnDoTopView()
{
    if(Owner != none && Pawn(Owner) != none && CCPawn(Pawn(Owner)) != none)
        CommandController(Pawn(Owner).Controller).bCommandView = true;
}

function Refill()
{
    local Inventory Inv;

    if(Pawn(Owner) != none)
    {
    	for(Inv=Pawn(Owner).Inventory; Inv!=None; Inv=Inv.Inventory)
    	    if(Weapon(Inv) != none && Redeemer(Inv) == none && ONSPainter(Inv) == none && Painter(Inv) == none)
    		    Weapon(Inv).MaxOutAmmo();
    	Pawn(Owner).Health = Pawn(Owner).HealthMax;
        Pawn(Owner).ShieldStrength = xPawn(Owner).ShieldStrengthMax;
	}
}

defaultproperties
{
     CreateEffects(0)=Class'XEffects.TransEffectRed'
     CreateEffects(1)=Class'XEffects.TransEffectBlue'
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
