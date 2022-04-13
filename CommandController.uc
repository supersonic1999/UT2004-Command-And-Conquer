class CommandController extends XPlayer;

var vector CamLocation, BuildingLocation, OrderLocation, RealMouseLocation;
var rotator CamRotation, PlayerPlacingRotation;
var int MoneyMax, MoveSpeedMax;
var float Money;
var config int MoveSpeed;
var bool bCommandView, bValidPlacementZ;
var CCBuildings CurPlacement;
var Pawn Other;
var Actor MouseTouchingActor;

var localized string ApplyMessage, AlreadyApplied, AlreadyCommander, VoteRemoveCommander;

replication
{
	reliable if(Role==ROLE_Authority)
		RemoveCommander,SetHudLocProperties;
    reliable if(Role<ROLE_Authority)
		ServerDonate,ApplyCommander,GiveMoney,SpawnNewBuilding,TakeCmdMoney,ResetMoney,CheckIfProtected,SetNewOrders
        ,ServerRemoveCommander,DoSellBuilding,SetMouseTouchingActor,FindHudActorLocations,SaveMouseMoveTime;
	reliable if(bNetDirty && Role==ROLE_Authority)
		CamLocation,Money,OrderLocation;
}

state Spectating
{
    ignores SwitchWeapon, RestartLevel, ClientRestart, Suicide,
     ThrowWeapon, NotifyPhysicsVolumeChange, NotifyHeadVolumeChange;

    exec function Fire( optional float F )
    {
    	if(!bCommandView)
            super.Fire(F);
    }

    exec function AltFire( optional float F )
    {
        if(!bCommandView)
            super.AltFire(F);
    }

    function Timer()
    {
    	bFrozen = false;
    }

    function BeginState()
    {
        if ( Pawn != None )
        {
            SetLocation(Pawn.Location);
            UnPossess();
        }
        bCollideWorld = true;
		CameraDist = Default.CameraDist;
    }

    function EndState()
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bCollideWorld = false;
    }
}

function bool ApplyCommander()
{
    local int i;
    local bool bIsMutiny;

    if(GetTeamNum() == 0 && CCReplicationInfo(Level.GRI).MutinyVotesNOD > 0
    && PlayerReplicationInfo != CCReplicationInfo(Level.GRI).CommanderRED)
    {
        for(i=0;i<CCReplicationInfo(Level.GRI).NODMutinyVoters.Length;i++)
        {
            if(CCReplicationInfo(Level.GRI).NODMutinyVoters[i] == PlayerReplicationInfo)
            {
                bIsMutiny = True;
                break;
            }
        }
    }
    else if(GetTeamNum() != 0 && CCReplicationInfo(Level.GRI).MutinyVotesGDI > 0
    && PlayerReplicationInfo != CCReplicationInfo(Level.GRI).CommanderBLUE)
    {
        for(i=0;i<CCReplicationInfo(Level.GRI).GDIMutinyVoters.Length;i++)
        {
            if(CCReplicationInfo(Level.GRI).GDIMutinyVoters[i] == PlayerReplicationInfo)
            {
                bIsMutiny = True;
                break;
            }
        }
    }

    if(GetTeamNum() == 0 && bIsMutiny)
    {
        CCReplicationInfo(Level.GRI).NODMutinyVoters[CCReplicationInfo(Level.GRI).NODMutinyVoters.Length] = PlayerReplicationInfo;
        CCReplicationInfo(Level.GRI).MutinyVotesNOD += 1;
        ClientMessage(VoteRemoveCommander);
        return true;
    }
    else if(GetTeamNum() != 0 && bIsMutiny)
    {
        CCReplicationInfo(Level.GRI).GDIMutinyVoters[CCReplicationInfo(Level.GRI).GDIMutinyVoters.Length] = PlayerReplicationInfo;
        CCReplicationInfo(Level.GRI).MutinyVotesGDI += 1;
        ClientMessage(VoteRemoveCommander);
        return true;
    }

    if(CCReplicationInfo(Level.GRI).OldCommanders.Length > 0)
        for(i=0;i<CCReplicationInfo(Level.GRI).OldCommanders.Length;i++)
            if(CCReplicationInfo(Level.GRI).OldCommanders[i] == self)
                return false;

    if(CCReplicationInfo(Level.GRI).CommanderBLUE != none && GetTeamNum() != 0)
	{
		ClientMessage(AlreadyCommander @ CCReplicationInfo(Level.GRI).CommanderBLUE.PlayerName);
        return false;
	}
	else if(CCReplicationInfo(Level.GRI).CommanderRED != none && GetTeamNum() == 0)
	{
		ClientMessage(AlreadyCommander @ CCReplicationInfo(Level.GRI).CommanderRED.PlayerName);
        return false;
	}
    else if(GetTeamNum() != 0)
    {
        for(i=0;i<CCReplicationInfo(Level.GRI).CommanderAppliersBLUE.Length;i++)
        {
            if(CCReplicationInfo(Level.GRI).CommanderAppliersBLUE[i] == PlayerReplicationInfo)
            {
                ClientMessage(AlreadyApplied);
                return false;
            }
        }
    }
    else
    {
        for(i=0;i<CCReplicationInfo(Level.GRI).CommanderAppliersRED.Length;i++)
        {
            if(CCReplicationInfo(Level.GRI).CommanderAppliersRED[i] == PlayerReplicationInfo)
            {
                ClientMessage(AlreadyApplied);
                return false;
            }
        }
    }

    if(GetTeamNum() == 0)
    {
	    if(CCReplicationInfo(Level.GRI).CommanderAppliersRED.Length == 0)
	        CCReplicationInfo(Level.GRI).NODFirstApply = Level.TimeSeconds;
        CCReplicationInfo(Level.GRI).CommanderAppliersRED[CCReplicationInfo(Level.GRI).CommanderAppliersRED.Length] = PlayerReplicationInfo;
    }
    else
    {
        if(CCReplicationInfo(Level.GRI).CommanderAppliersBLUE.Length == 0)
	        CCReplicationInfo(Level.GRI).GDIFirstApply = Level.TimeSeconds;
        CCReplicationInfo(Level.GRI).CommanderAppliersBLUE[CCReplicationInfo(Level.GRI).CommanderAppliersBLUE.Length] = PlayerReplicationInfo;
    }
    ClientMessage(ApplyMessage);
    return true;
}

function CheckIfProtected(Vehicle cVehicle, out byte bProtected)
{
    if(cVehicle != none && cVehicle.bSpawnProtected)
        bProtected = 1; //true
    else
        bProtected = 0; //false
}

function SetNewOrders(Pawn P, vector myVec)
{
    if(CommandController(P.Controller) != none)
    {
        CommandController(P.Controller).OrderLocation = myVec;
        CommandController(P.Controller).ClientMessage("You have new orders.");
    }
    else if(CCBotController(P.Controller) != none)
    {
        P.Controller.GoToState('CommandControl');
        CCBotController(P.Controller).Destination = myVec;
    }
}

function SaveMouseMoveTime()
{
    LastActiveTime = Level.TimeSeconds;
}

function TakeCmdMoney(int Cost)
{
    if(Level != none && Level.GRI != none)
        CCReplicationInfo(Level.GRI).GiveCmdMoney(Cost, GetTeamNum());
}

function ServerRemoveCommander(byte Team, bool bCanReApply)
{
    if(Team == 0 && CCReplicationInfo(Level.GRI).CommanderRED != none)
        CCReplicationInfo(Level.GRI).CommanderRED = none;
    else if(CCReplicationInfo(Level.GRI).CommanderBLUE != none)
        CCReplicationInfo(Level.GRI).CommanderBLUE = none;

    if(bCanReApply)
        CCReplicationInfo(Level.GRI).OldCommanders[CCReplicationInfo(Level.GRI).OldCommanders.Length] = self;
}

simulated function RemoveCommander(byte Team, bool bCanReApply, string Message)
{
    ServerRemoveCommander(GetTeamNum(), bCanReApply);
    RepossesOldBody();
    bCommandView = false;
    if(CurPlacement != none)
    {
        CurPlacement.Destroy();
        CurPlacement = none;
    }
    ClientMessage(Message);
}

simulated function UpdatePlaceRot( bool bMoveRight )
{
	if(bMoveRight)
		PlayerPlacingRotation.Yaw+=1024;
	else
        PlayerPlacingRotation.Yaw-=1024;
}

simulated function rotator MergeRotWithNormal( rotator TurnedRot, vector FloorN )
{
	local quat CarQuat, LookQuat, ResultQuat;

    if(FloorN.Z > 0.98)
		return TurnedRot;

	CarQuat = QuatFromRotator(rotator(FloorN)-rot(16384,0,0));
	LookQuat = QuatFromRotator(Normalize(TurnedRot));
	ResultQuat = QuatProduct(LookQuat, CarQuat);
	Return QuatToRotator(ResultQuat);
}

function GiveMoney(float Amount)
{
    if(Amount < 0 && Money + Amount < 0)
        Amount = -Money;
    else if(Amount > 0 && Money + Amount > MoneyMax)
        Amount = (MoneyMax - Money);

    if(Money < MoneyMax || Money > 0 && Amount < 0)
        Money += Amount;
}

function ResetMoney()
{
    Money = 0.000000;
}

simulated function int CheckBuildingAmount(int P)
{
   local CCBuildings CurBuilding;
   //local ConstructionVehicle CurVehicle;
   local int BuildingNum;

   for(CurBuilding=Class'CCBuildings'.Static.PickFirstBuilding(Level); CurBuilding!=None; CurBuilding=CurBuilding.NextBuilding)
   {
       if(CurBuilding != none && CurBuilding != CurPlacement && CCReplicationInfo(Level.GRI).MainController.Buildings[p].RedBuilding != none && CurBuilding.IsA(CCReplicationInfo(Level.GRI).MainController.Buildings[p].RedBuilding.name) && CurBuilding.Team == GetTeamNum())
           BuildingNum++;
       else if(CurBuilding != none && CurBuilding != CurPlacement && CCReplicationInfo(Level.GRI).MainController.Buildings[p].BlueBuilding != none && CurBuilding.IsA(CCReplicationInfo(Level.GRI).MainController.Buildings[p].BlueBuilding.name) && CurBuilding.Team == GetTeamNum())
           BuildingNum++;
   }

//   foreach DynamicActors(class'ConstructionVehicle', CurVehicle)
//   {
//       if(CurVehicle != none && CCReplicationInfo(Level.GRI).MainController.Buildings[P].RedBuilding != none && CurVehicle.VehicleClass == CCReplicationInfo(Level.GRI).MainController.Buildings[P].RedBuilding && CurVehicle.Team == GetTeamNum())
//           BuildingNum++;
//       else if(CurVehicle != none && CCReplicationInfo(Level.GRI).MainController.Buildings[P].BlueBuilding != none && CurVehicle.VehicleClass == CCReplicationInfo(Level.GRI).MainController.Buildings[P].BlueBuilding && CurVehicle.Team == GetTeamNum())
//           BuildingNum++;
//   }
   return BuildingNum;
}

exec function Donate(string PlayerName, int Amount)
{
    ServerDonate(PlayerName, Amount);
}

function ServerDonate(string PlayerName, int Amount)
{
    local CommandController C, DonatedPlayer;
    local int namematch;

    foreach DynamicActors(class'CommandController', C)
    {
    	if(Len(C.PlayerReplicationInfo.PlayerName) >= 3 && Len(PlayerName) < 3)
        	Continue;
        else
        {
       		namematch = InStr(Caps(C.PlayerReplicationInfo.PlayerName), Caps(PlayerName));
          	if(namematch >= 0)
          	{
            	DonatedPlayer = C;
            	break;
          	}
    	}
    }

    if(DonatedPlayer != none && Amount > 0 && Money > 0 && DonatedPlayer != self && DonatedPlayer.GetTeamNum() == GetTeamNum())
    {
        if(Money - Amount < 0)
            Amount = Money;
        if(DonatedPlayer.Money + Amount > DonatedPlayer.MoneyMax)
            Amount = (DonatedPlayer.MoneyMax - DonatedPlayer.Money);

        if(Amount > 0)
        {
            GiveMoney(-Amount);
            DonatedPlayer.GiveMoney(Amount);
            DonatedPlayer.ClientMessage(PlayerReplicationInfo.PlayerName @ "donated" @ Amount @ "money to you.");
            ClientMessage("You donated" @ Amount @ "money to:" @ DonatedPlayer.PlayerReplicationInfo.PlayerName $ ".");
        }
        else
            ClientMessage("You do not have enough money or the player you want to donate to is already at max.");
        return;
    }
    ClientMessage("Cant find player:" @ PlayerName);
}

exec function SetScrollSpeed(int Speed)
{
    Speed = Min(Speed, MoveSpeedMax);
    MoveSpeed = Speed;
    SaveConfig();
}

function CalcBehindView(out vector CameraLocation, out rotator CameraRotation, float Dist)
{
    if(Pawn != none)
        Other = Pawn;

    if(bCommandView)
	{
       bBehindView = false;
       return;
    }
    super.CalcBehindView(CameraLocation,CameraRotation,Dist);
}

simulated function RepossesOldBody()
{
    if(Other != none && Other.Health > 0 && Pawn == none && bCommandView)
    {
        Possess(Other);
        CamLocation.X = 0;
        CamLocation.Y = 0;
        Other = none;
        bCommandView = false;
    }
}

function PlayerCalcView(out actor ViewActor, out vector CameraLocation, out rotator CameraRotation)
{
    super.PlayerCalcView(ViewActor, CameraLocation, CameraRotation);

    if(Pawn != None)
        Other = Pawn;

    if(Other != none && Other.Health <= 0 && Pawn == none && bCommandView == true)
        Level.Game.RestartPlayer(self);
    else if(Other != none && bCommandView)
    {
        UnPossess();
        CameraRotation.Pitch = CamRotation.Pitch;
        CameraRotation.Yaw = CamRotation.Yaw;
        CameraRotation.Roll = CamRotation.Roll;
        CameraLocation.Z = CamLocation.Z;
        CameraLocation.X = CamLocation.X;
        CameraLocation.Y = CamLocation.Y;
        ClientSetRotation(rot(0,0,0));
        bCollideWorld = false;
	}
}

function FindHudActorLocations()
{
    local CCBuildings B;
    local Controller C;
    local Pawn P;

    for(B=Class'CCBuildings'.Static.PickFirstBuilding(Level); B!=None; B=B.NextBuilding)
        if(B.Health > 0)
            SetHudLocProperties(B.Health, B.Team, B.Class, false, B.Location);

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        P = C.Pawn;
        if(P == none || P.IsA('ASTurret_BallTurret') || P.IsA('ONSWeaponPawn') || P == self || P == self.Pawn || P.Health <= 0)
             continue;
        else if(Vehicle(P) != none && !Vehicle(P).bDriving)
            SetHudLocProperties(P.Health, P.GetTeamNum(), P.Class, false, P.Location);
        else
            SetHudLocProperties(P.Health, P.GetTeamNum(), P.Class, True, P.Location);
    }
}

simulated function SetHudLocProperties(int Health, int Team, class<Actor> AClass, bool bDriver, vector Loc)
{
    HudCommandAndConquer(myHud).ActorHudInfo.Insert(HudCommandAndConquer(myHud).ActorHudInfo.Length, 1);

    HudCommandAndConquer(myHud).ActorHudInfo[HudCommandAndConquer(myHud).ActorHudInfo.Length-1].AHealth = Health;
    HudCommandAndConquer(myHud).ActorHudInfo[HudCommandAndConquer(myHud).ActorHudInfo.Length-1].AClass = AClass;
    HudCommandAndConquer(myHud).ActorHudInfo[HudCommandAndConquer(myHud).ActorHudInfo.Length-1].ATeam = Team;
    HudCommandAndConquer(myHud).ActorHudInfo[HudCommandAndConquer(myHud).ActorHudInfo.Length-1].bNoDriver = bDriver;
    HudCommandAndConquer(myHud).ActorHudInfo[HudCommandAndConquer(myHud).ActorHudInfo.Length-1].ALocation = Loc;
}

simulated function SpawnPlacementBuilding(int i)
{
    local vector MouseLoc;
    local class<CCBuildings> CommanderBuilding;

    if(CCReplicationInfo(Level.GRI).CommanderBLUE == PlayerReplicationInfo
    || CCReplicationInfo(Level.GRI).CommanderRED == PlayerReplicationInfo)
    {
        MouseLoc.X = CamLocation.X;
        MouseLoc.Y = CamLocation.Y;
        MouseLoc.Z = CamLocation.Z;

        if(CurPlacement == none)
        {
            if(GetTeamNum() == 0 && CCReplicationInfo(Level.GRI).MainController.Buildings.Length > i)
                CommanderBuilding = CCReplicationInfo(Level.GRI).MainController.Buildings[i].RedBuilding;
            else if(CCReplicationInfo(Level.GRI).MainController.Buildings.Length > i)
                CommanderBuilding = CCReplicationInfo(Level.GRI).MainController.Buildings[i].BlueBuilding;

            if(CommanderBuilding != none)
            {
                CurPlacement = Spawn(CommanderBuilding, self,, MouseLoc);
                //CurPlacement.bOnlyOwnerSee = true;
                CurPlacement.SetTeamNum(GetTeamNum());
            }
        }
    }
}

function SetMouseTouchingActor(Actor CCB)
{
    MouseTouchingActor = CCB;
}

simulated function PlayerTick(float DeltaTime)
{
    local vector HitLocation, HitNormal, PlacementLoc, MouseLoc;
	local rotator R;
	local Actor A;
	local CCBuildings B;
	local CYard C;

    if(bCommandView)
    {
        for(B=Class'CCBuildings'.Static.PickFirstBuilding(Level); B!=None; B=B.NextBuilding)
    	{
            C = CYard(B);
            if(C != none && C.Team == GetTeamNum())
                break;

            C = none;
    	}

    	if(C == none)
    	{
    	    RepossesOldBody();
            HudCommandAndConquer(myHud).Mode = 0;
            if(CurPlacement != none)
            {
                CurPlacement.Destroy();
                CurPlacement = none;
            }
    	    return;
	    }

        if(MouseLoc.X != Player.WindowsMouseX)
            MouseLoc.X = Player.WindowsMouseX;
        if(MouseLoc.Y != Player.WindowsMouseY)
            MouseLoc.Y = Player.WindowsMouseY;

        BuildingLocation = Player.LocalInteractions[0].ScreenToWorld(MouseLoc);

        if(CurPlacement != none)
            A = Trace(HitLocation, HitNormal, (CamLocation + (BuildingLocation * 50000)), CamLocation, False);
        else
            A = Trace(HitLocation, HitNormal, (CamLocation + (BuildingLocation * 50000)), CamLocation, True);

        RealMouseLocation = HitLocation;

        if(!A.bStatic)
            MouseTouchingActor = A;
        else
            MouseTouchingActor = none;

        SetMouseTouchingActor(MouseTouchingActor);

        if(CurPlacement != none)
        {
            PlacementLoc = HitLocation + HitNormal*CurPlacement.EndPositionNum;
			CurPlacement.SetLocation(PlacementLoc);
			R = MergeRotWithNormal(PlayerPlacingRotation,HitNormal);
			R = R/8;
			R = R*8;
			CurPlacement.SetRotation(R);
			bValidPlacementZ = (HitNormal.Z>0.8);
        }
    }
    super.PlayerTick(DeltaTime);
}

function DoSellBuilding()
{
    if(MouseTouchingActor != none)
        CCBuildings(MouseTouchingActor).SellBuilding();
}

function SpawnNewBuilding(class<CCBuildings> BClass, vector Loc, rotator BRot)
{
    local CCBuildings B;

    if(BClass == none)
        return;

    if(CCReplicationInfo(Level.GRI).CommanderBLUE == PlayerReplicationInfo
    || CCReplicationInfo(Level.GRI).CommanderRED == PlayerReplicationInfo)
    {
        B = Spawn(BClass,,, Loc, BRot);
        B.SetTeamNum(GetTeamNum());
    }
}

simulated function bool CheckPlacability()
{
	local CCBuildings C;
	local Volume V;
	local byte T;
	local float D;
	local bool bGoodPlacement;

	if(!bValidPlacementZ)
		return False;

	T = GetTeamNum();
	for(C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding)
	{
		if(C.Team == T && C != CurPlacement)
		{
			D = VSize(C.Location-CurPlacement.Location);
			if(D < (3000+CurPlacement.CollisionRadius+C.CollisionRadius) && C.bCanBuildFrom && C.bBuilt)
				bGoodPlacement = True;
			if(D < (CurPlacement.CollisionRadius+C.CollisionRadius))
				return False;
		}
	}

	foreach CurPlacement.TouchingActors(class'Volume',V)
		if(BlockingVolume(V) != none || (PhysicsVolume(V)!=none && (PhysicsVolume(V).bWaterVolume || PhysicsVolume(V).bPainCausing)) )
			Return False;

	if(bGoodPlacement && MouseTouchingActor != class'CCBuildings')
		return true;
	return false;
}

defaultproperties
{
     CamLocation=(Z=10000.000000)
     CamRotation=(Pitch=49152,Yaw=-16384)
     MoneyMax=9999
     MoveSpeedMax=3000
     MoveSpeed=1000
     ApplyMessage="You have applied to be the commander of your team!"
     AlreadyApplied="You have already applied to be the commander of your team."
     AlreadyCommander="There is already a commander! The commander is:"
     VoteRemoveCommander="You successfully voted to remove your teams commander from command."
     TeamBeaconTeamColors(1)=(B=0,G=200,R=200)
     PlayerReplicationInfoClass=Class'commandandconquer.CCPlayerReplicationInfo'
}
