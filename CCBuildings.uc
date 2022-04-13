///////////////////////////////////////////////////////////////////////////////////
////Many of the textures used in this gametype are (C)Command And Conquer Renegade.
////Harvester AI & some code improvements made by .:...:
////This mod was coded by -[UI]-Super_Sonic. UnrealInsanity.com
///////////////////////////////////////////////////////////////////////////////////
class CCBuildings extends Actor
    config(CommandAndConquer)
	placeable;

#exec OBJ LOAD FILE="..\Textures\CommandAndConquerTEX.utx"

struct DoorStruct
{
	var vector DoorOffset;
	var rotator DoorRotation;
};
struct PStarts
{
	var vector PLocation;
	var rotator PRotation;
};
var array<DoorStruct> Door;
var array<PStarts> PlayerStartLoc;

var() Material RedSkin, BlueSkin, TerminalSkin, ShieldOverlay;
var() texture BuildingImage;
var() class<Actor> EffectWhenDestroyed;
var() int Team;
var() bool bDontBuild, bCanBuildFrom;
var() string BuildingName;
var() sound NODDamagedSound, GDIDamagedSound;
var() float PathScanZDifference;
var float RequestedTimerRate,ConstructTime;
var int StartPositionNum, EndPositionNum, BuildDuration, MaxAmount, ScoreKill, BuildCost, Health, PowerUsage, DamageShotPlayTime;
var vector SellLocation, EndPosition, AddLocation, CurrentPosition, RotX, RotY, RotZ, MCTOffset;
var bool bBuilt, ScaleOffsetLocation, bNeedsToBeDestroyed, bGetBonusForDamage, bSelling, bRepairing, bShieldIsOn, bIsInitialActor;
var rotator MCTRotation;
var	array<vector> SwitchOffsets, SpawnOffsets;
var array<rotator> TerminalRot; // 0, 16384, 32768, 49152.
var array<Actor> SummonedActors, SummonedDoors, SummonedPlayerStarts, LinkedActors;
var array<class<CCBuildings> > UnlockedBuildings;
var MasterControlTerminal MCT;
var Controller DelayedDamageInstigatorController;
var Pawn FakePawn;

// Tell client what building is doing now:
// 0 - Normally standing there (Building finished)
// 1 - Building
// 2 - Selling
var byte ClientBuildingState,OldClientState;
var bool bClientInitilized,bBuildModeActor;

var CCBuildings BuildingsList,NextBuilding;
var TiberiumActor TActor;
var Combiner UpdatingCombiner;

replication
{
	reliable if( Role<ROLE_Authority )
		SellBuilding;
	reliable if( bNetDirty && Role==ROLE_Authority )
		bBuilt,Health,Team,BuildingName,bRepairing,ClientBuildingState;
}

simulated function PreBeginPlay()
{
	Class'CCBuildings'.Static.ListBuilding(Self);
	Disable('Tick');
	bIsInitialActor = Level.bStartUp;
	Super.PreBeginPlay();
}

function PostBeginPlay()
{
	super.PostBeginPlay();

	bMovable = False;

	if(CommandController(Owner) != None)
	{
		bBuildModeActor = True;
		bMovable = True;
		bWorldGeometry = false;
		bBuilt = True;
		Return;
	}

	if(Level.NetMode != NM_DedicatedServer && CCReplicationInfo(Level.GRI) != None)
		SetShieldSkin(CCReplicationInfo(Level.GRI).bShieldUp);

	if(!bDontBuild)
	{
		if(Level.NetMode == NM_DedicatedServer)
			SetTimer(BuildDuration,False);
		else
            Enable('Tick');
		ConstructTime = Level.TimeSeconds+BuildDuration;
		ClientBuildingState = 1;
	}
	else
        FullyBuilt();
}

function Timer()
{
	if(ClientBuildingState == 1)
	{
		ClientBuildingState = 0;
		FullyBuilt();
	}
	else if(ClientBuildingState == 2)
	{
		CCReplicationInfo(Level.GRI).GiveCmdMoney((BuildCost/2)*((1.f/default.Health)*Health), Team);
		Destroy();
	}
}

simulated function rotator GetViewRotation()
{
	return Rotation;
}

function SetTeamNum(byte Num)
{
    Team = Num;

    if(Level.NetMode != NM_DedicatedServer && CCReplicationInfo(Level.GRI) != None)
	    SetShieldSkin(CCReplicationInfo(Level.GRI).bShieldUp);
}

function SetDelayedDamageInstigatorController(Controller C)
{
	DelayedDamageInstigatorController = C;
}

simulated function PostNetReceive()
{
	if(OldClientState != ClientBuildingState)
	{
		OldClientState = ClientBuildingState;
		if(ClientBuildingState == 1)
		{
			ConstructTime = Level.TimeSeconds+BuildDuration;
			PrePivot.Z = 800+Default.PrePivot.Z;
			Enable('Tick');
		}
		else if(ClientBuildingState == 0)
		{
			PrePivot.Z = Default.PrePivot.Z;
			SetDrawScale(DrawScale);
			ClientBuildingDone();
			Disable('Tick');
		}
		else if(ClientBuildingState == 2)
		{
			ConstructTime = Level.TimeSeconds+(BuildDuration/2);
			SetDrawScale3D(vect(1,1,1));
			Enable('Tick');
		}
	}
}

simulated function PostNetBeginPlay()
{
	if(Level.NetMode != NM_Client || bBuildModeActor)
		Return;

	bNetNotify = True;
	PostNetReceive();
	bMovable = False;
	if(ClientBuildingState == 0)
		ClientBuildingDone();
	if(CCReplicationInfo(Level.GRI) != None)
		SetShieldSkin(CCReplicationInfo(Level.GRI).bShieldUp);
}

simulated function Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if(ClientBuildingState == 1)
	{
		if(ConstructTime < Level.TimeSeconds)
		{
			Disable('Tick');
			PrePivot.Z = Default.PrePivot.Z;
			if(Level.NetMode != NM_Client)
				FullyBuilt();
			else
                ClientBuildingDone();
		}
		else
            PrePivot.Z = 800*(ConstructTime-Level.TimeSeconds)/BuildDuration+Default.PrePivot.Z;
		SetDrawScale(DrawScale);
	}
	else if(ClientBuildingState == 2)
	{
		bMovable = True;
		if(ConstructTime < Level.TimeSeconds)
		{
			if(Level.NetMode == NM_Client)
			{
				bHidden = True;
				Return;
			}
			CCReplicationInfo(Level.GRI).GiveCmdMoney((BuildCost/2)*((1.f/default.Health)*Health), Team);
			Destroy();
		}
		else
            PrePivot.Z = 800*(1-(ConstructTime-Level.TimeSeconds)/BuildDuration)+Default.PrePivot.Z;
		SetDrawScale(DrawScale);
	}
}

simulated function SetShieldSkin(bool bShieldEnabled)
{
	if(Skins.Length == 0)
		Skins.Insert(0,1);

	bShieldIsOn = bShieldEnabled;

	if(bShieldEnabled)
		AmbientGlow = 255;

	if(!bShieldEnabled)
	{
		AmbientGlow = Default.AmbientGlow;
		if(Team == 0)
		    Skins[0] = RedSkin;
	    else
            Skins[0] = BlueSkin;
	}
	else if(ShieldOverlay != none)
	{
		UpdatingCombiner = New(None)Class'Combiner';
		if(Team == 0)
			UpdatingCombiner.Material1 = RedSkin;
		else
            UpdatingCombiner.Material1 = BlueSkin;
		if(Combiner(ShieldOverlay) != none)
		{
			UpdatingCombiner.Material2 = Combiner(ShieldOverlay).Material2;
			UpdatingCombiner.CombineOperation = Combiner(ShieldOverlay).CombineOperation;
		}
		Skins[0] = UpdatingCombiner;
	}
	else if(Team == 0)
		Skins[0] = RedSkin;
	else
        Skins[0] = BlueSkin;
}

function CheckBlockPaths(vector Pos, float Radius, bool bSpawnCheck)
{
	local NavigationPoint N;
	local int i;

	if(Radius < 5580)
		Radius = 5580;

	if(bSpawnCheck)
	{
		For(N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint)
		{
			if(VSize(N.Location-Pos) < Radius)
			{
				for(i=0; i<N.PathList.Length; i++)
				{
					if(N.PathList[i] != none && N.PathList[i].reachFlags == 1 && !PathReachable(N.PathList[i],True))
						N.PathList[i].reachFlags = 128; // Prune path
				}
			}
		}
	}
	else
	{
		For(N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint)
		{
			if(VSize(N.Location-Pos) < Radius)
			{
				For(i=0; i<N.PathList.Length; i++)
				{
					if(N.PathList[i] != none && N.PathList[i].reachFlags == 128 && PathReachable(N.PathList[i],False))
						N.PathList[i].reachFlags = 1; // Enable path
				}
			}
		}
	}
}

function bool PathReachable( ReachSpec Other, bool bSpawnScan )
{
	local CCBuildings C;

	if(bSpawnScan)
		return PathVisible(Other.Start.Location,Other.End.Location,Self);
	else
	{
		for(C=Class'CCBuildings'.Static.PickFirstBuilding(Level); C!=None; C=C.NextBuilding)
			if(C != self && C.bIsInitialActor && !PathVisible(Other.Start.Location,Other.End.Location,C))
				Return False;
		return True;
	}
}

simulated function DrawCommanderSelectionHud(Canvas C, HudCommandAndConquer Hud, int SelectedActorNum)
{
	local vector ALocation;
	local float i;

	ALocation = Hud.PlayerOwner.Player.LocalInteractions[0].WorldToScreen(Hud.SelectedActor[SelectedActorNum].Location);

	if(Team != Hud.PlayerOwner.GetTeamNum())
		C.DrawColor = C.MakeColor(255,0,0);
	else
        C.DrawColor = C.MakeColor(0,255,0);

	C.SetPos(ALocation.X - (C.ClipX * 0.125), ALocation.Y - (C.ClipY * 0.125));
	C.DrawTile(Material'CommandAndConquerTEX.Reticle', (C.ClipX * 0.25), (C.ClipY * 0.25), 0, 0, 256, 512);
	C.DrawColor = C.MakeColor(255,255,0);
	C.SetPos(ALocation.X - (C.ClipX * 0.1), ALocation.Y - (C.ClipY * 0.125));
	i = (((C.ClipX * 0.21) / default.Health)*Health);
	C.DrawTileClipped(Material'CommandAndConquerTEX.HealthBar', i, 8, 0, 0, i, 8);
}

simulated function DrawReticleHud(Canvas C, HudCommandAndConquer Hud)
{
	local float Num, i;

	if(Health > 0 && Hud != none && C != none)
	{
		Num = 0.25;

		if(Team == 0)
		{
			C.DrawColor = C.MakeColor(255,0,0);
			C.SetPos((C.ClipX * 0.44) - 32, (C.ClipY * 0.62));
			C.DrawTileScaled(Material'CommandAndConquerTEX.NOD_LOGO', Num, Num);
		}
		else
		{
			C.DrawColor = C.MakeColor(255,255,0);
			C.SetPos((C.ClipX * 0.44) - 32, (C.ClipY * 0.62));
			C.DrawTileScaled(Material'CommandAndConquerTEX.GDI_LOGO', Num, Num);
		}

		if(Team != Hud.PlayerOwner.GetTeamNum())
			C.DrawColor = C.MakeColor(255,0,0);
		else
            C.DrawColor = C.MakeColor(0,255,0);

		C.SetPos((C.ClipX * 0.5)-(C.ClipX * (Num/2)), (C.ClipY * 0.5)-(C.ClipY * (Num/2)));
		C.DrawTile(Material'CommandAndConquerTEX.Reticle', (C.ClipX * Num), (C.ClipY * Num), 0, 0, 256, 512);
		C.Font = Hud.TextFont;
		C.FontScaleX = C.ClipX / 1024.f;
		C.FontScaleY = C.ClipY / 768.f;
		C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.62);
		C.DrawText(BuildingName);
		C.DrawColor = C.MakeColor(255,255,0);
		C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.64);
		i = ((128 / default.Health)*Health);
		C.DrawTileClipped(Material'CommandAndConquerTEX.HealthBar', i, 16, 0, 0, i, 16);
	}
}

function SellBuilding()
{
	SellLocation = Location;
	bSelling = true;
	bRepairing = false;
	ConstructTime = Level.TimeSeconds+(BuildDuration/2);
	ClientBuildingState = 2;
	ClearBuildingDecos();
	if(Level.NetMode == NM_DedicatedServer)
		SetTimer(BuildDuration,False);
	else
        Enable('Tick');
}

function ChangeHealth(int Amount, optional Pawn InstigatedBy )
{
	Health += Amount;
	if(Health > default.Health)
		Health = default.Health;
	if(Health <= 0)
	{
		if(InstigatedBy != none && InstigatedBy.PlayerReplicationInfo != none && InstigatedBy.PlayerReplicationInfo.Team != None)
		{
			InstigatedBy.PlayerReplicationInfo.Team.Score += ScoreKill;
			InstigatedBy.PlayerReplicationInfo.Score += ScoreKill;
		}
		Destroy();
	}
}

function bool GiveHealth(int HealAmount, int HealMax)
{
	if(Health < HealMax)
	{
		Health = Min(HealMax, Health + HealAmount);
		return true;
	}
	return false;
}

function TakeDamage(int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	local Controller C;

	super.TakeDamage(NDamage, instigatedBy, hitlocation, momentum, damageType);

	Instigator = InstigatedBy;

	if((instigatedBy == none || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != none && DelayedDamageInstigatorController.Pawn != none)
		Instigator = DelayedDamageInstigatorController.Pawn;

	if(instigatedBy != none)
	{
		if(CCReplicationInfo(Level.GRI).bShieldUp)
			return;
		else if(!bCanBeDamaged || Health <= 0)
			Return;
		else if(Level.TimeSeconds > DamageShotPlayTime + 60 && Instigator.GetTeamNum() != Team)
		{
			DamageShotPlayTime = Level.TimeSeconds;
			For(C=Level.ControllerList; C!=None; C=C.NextController)
			{
				if(PlayerController(C) != none && C.GetTeamNum() == Team)
				{
					if(Team == 0)
						PlayerController(C).ClientPlaySound(NODDamagedSound, False, 2.0);
					else
                        PlayerController(C).ClientPlaySound(GDIDamagedSound, False, 2.0);
				}
			}
		}

		MakeNoise(1.0);

		if(instigatedBy.GetTeamNum() == Team && damageType == class'DamTypeRepairGun' && (Health + abs(NDamage)) <= default.Health)
		{
			NDamage = ModifyDamageWithFP(NDamage,instigatedBy,hitlocation,momentum,damageType,1);
            ChangeHealth(abs(NDamage),InstigatedBy);
		}
		else if(xPawn(instigatedBy) != none && DamageType != class'DamTypeC4Placed' && instigatedBy.GetTeamNum() != Team)
		{
			NDamage = ModifyDamageWithFP(NDamage,instigatedBy,hitlocation,momentum,damageType,10);
            ChangeHealth(-(NDamage/10),InstigatedBy);
		}
		else if(instigatedBy.GetTeamNum() != Team)
		{
            NDamage = ModifyDamageWithFP(NDamage,instigatedBy,hitlocation,momentum,damageType,1);
            ChangeHealth(-NDamage,InstigatedBy);
        }
	}
}

function int ModifyDamageWithFP(int NDamage, Pawn Instig, vector HitLoc, vector Momentum, class<DamageType> DmgType, int DivideNum)
{
	if(FakePawn == none)
	{
		FakePawn = Spawn(class'FakePawn',Self,, Location + class'FakePawn'.default.CollisionHeight * vect(0,0,1));
		if(FakePawn != none)
		{
			if( FakePawn.Controller!=None )
			{
				FakePawn.Controller.Pawn = None;
				FakePawn.Controller.Destroy();
			}
			FakePawn.Controller = Spawn(class'FakeController');
		}
	}

	if(FakePawn != none && bGetBonusForDamage)
	{
		FakePawn.Health = Health;
		return Level.Game.GameRulesModifiers.NetDamage(NDamage/DivideNum, NDamage/DivideNum, FakePawn, Instig, HitLoc, Momentum, DmgType);
	}
	return NDamage;
}

simulated function UpdatePrecacheMaterials()
{
	Super.UpdatePrecacheMaterials();
	if(BuildingImage != none)
		Level.AddPrecacheMaterial(BuildingImage);
	if(RedSkin != none)
		Level.AddPrecacheMaterial(RedSkin);
	if(BlueSkin != none)
		Level.AddPrecacheMaterial(BlueSkin);
	if(TerminalSkin != none)
		Level.AddPrecacheMaterial(TerminalSkin);
	if(ShieldOverlay != none)
		Level.AddPrecacheMaterial(ShieldOverlay);
}

simulated function Destroyed()
{
	Class'CCBuildings'.Static.FlushFromList(Self);

	if(Level.NetMode != NM_Client)
	{
		bWorldGeometry = False;
		if(!bBuildModeActor)
			CheckBlockPaths(Location, CollisionRadius*3,False);
		if(Level != none && Level.Game != none && CCGameType(Level.Game) != none)
			CCGameType(Level.Game).CheckBuildingsDestroyed();
	}

	if(Level.NetMode != NM_DedicatedServer && EffectWhenDestroyed != none && EffectIsRelevant(location,false))
		Spawn(EffectWhenDestroyed, Owner,, Location);

    ClearBuildingDecos();

	super.Destroyed();
}

function FullyBuilt()
{
	local int i, x;
	local PlayerStart PS;

	ClientBuildingState = 0;
	if(bBuilt)
		return;

	GetAxes(Rotation,RotX,RotY,RotZ);

	for(i=0;i<SpawnOffsets.Length;i++)
		SpawnOffsets[i] = Location + SpawnOffsets[i].X * RotX + SpawnOffsets[i].Y * RotY + SpawnOffsets[i].Z * RotZ;

	for(i=0;i<SwitchOffsets.Length;i++)
	{
		if(i >= TerminalRot.Length)
			SummonedActors[SummonedActors.Length] = spawn(class'TerminalSMActor', self,, Location + SwitchOffsets[i].X * RotX + SwitchOffsets[i].Y * RotY + SwitchOffsets[i].Z * RotZ, GetViewRotation());
		else
            SummonedActors[SummonedActors.Length] = spawn(class'TerminalSMActor', self,, Location + SwitchOffsets[i].X * RotX + SwitchOffsets[i].Y * RotY + SwitchOffsets[i].Z * RotZ, MergeRotWithBuilding(TerminalRot[i]));
	}
	for(i=0;i<PlayerStartLoc.Length;i++)
	{
		PS = Spawn(class'CCPlayerStart', self,, Location + PlayerStartLoc[i].PLocation.X * RotX + PlayerStartLoc[i].PLocation.Y * RotY + PlayerStartLoc[i].PLocation.Z * RotZ, MergeRotWithBuilding(PlayerStartLoc[i].PRotation));
		if(PS != none)
		{
            PS.TeamNumber = Team;
		    SummonedPlayerStarts[SummonedPlayerStarts.length] = PS;
		}
	}
	for(i=0;i<Door.Length;i++)
		SummonedDoors[SummonedDoors.Length] = spawn(class'DoorTrigger', self,, Location + Door[i].DoorOffset.X * RotX + Door[i].DoorOffset.Y * RotY + Door[i].DoorOffset.Z * RotZ, MergeRotWithBuilding(Door[i].DoorRotation));

	if(MCTOffset != vect(0,0,0))
	{
		MCT = Spawn(class'MasterControlTerminal', self,, Location + MCTOffset.X * RotX + MCTOffset.Y * RotY + MCTOffset.Z * RotZ, MergeRotWithBuilding(MCTRotation));

		if(MCT != none)
		{
			MCT.BuildingOwner = self;
			MCT.SetTeamNum(Team);
			MCT.SetBase(self);
		}
	}

	for(x=0;x<SummonedActors.Length;x++)
	{
		SummonedActors[x].SetBase(self);
		if(TerminalSMActor(SummonedActors[x]) != none)
			TerminalSMActor(SummonedActors[x]).myInstigator = self;

		if(TerminalSkin != None)
			SummonedActors[x].Skins[1] = TerminalSkin;
	}

	for(x=0;x<SummonedDoors.Length;x++)
		SummonedDoors[x].SetBase(self);

	if(EndPosition != default.EndPosition)
		SetLocation(EndPosition);
	if(RequestedTimerRate != 0)
		SetTimer(RequestedTimerRate,True);
	bBuilt = True;
	bMovable = False;
	if(!bIsInitialActor)
		CheckBlockPaths(Location, CollisionRadius*3,True);
	if(!CanHoldTiberium())
        Return;
	foreach DynamicActors(class'TiberiumActor', TActor)
	{
		if(TActor.Team == Team)
			Return;
	}
	TActor = Spawn(class'TiberiumActor');
	TActor.Team = Team;
}

simulated function ClientBuildingDone()
{
	local int i;

	if(bClientInitilized || Level.NetMode != NM_Client)
		Return;

	bClientInitilized = True;
	GetAxes(Rotation,RotX,RotY,RotZ);
	for(i=0;i<SpawnOffsets.Length;i++)
		SpawnOffsets[i] = Location + SpawnOffsets[i].X * RotX + SpawnOffsets[i].Y * RotY + SpawnOffsets[i].Z * RotZ;
	for(i=0;i<SwitchOffsets.Length;i++)
	{
		if(i >= TerminalRot.Length)
			SummonedActors[SummonedActors.Length] = spawn(class'TerminalSMActor', self,, Location + SwitchOffsets[i].X * RotX + SwitchOffsets[i].Y * RotY + SwitchOffsets[i].Z * RotZ, GetViewRotation());
		else
            SummonedActors[SummonedActors.Length] = spawn(class'TerminalSMActor', self,, Location + SwitchOffsets[i].X * RotX + SwitchOffsets[i].Y * RotY + SwitchOffsets[i].Z * RotZ, MergeRotWithBuilding(TerminalRot[i]));
	}

	for(i=0;i<Door.Length;i++)
		SummonedDoors[SummonedDoors.Length] = spawn(class'DoorTrigger', self,, Location + Door[i].DoorOffset.X * RotX + Door[i].DoorOffset.Y * RotY + Door[i].DoorOffset.Z * RotZ, MergeRotWithBuilding(Door[i].DoorRotation));

    if(MCTOffset != vect(0,0,0))
	{
		MCT = Spawn(class'MasterControlTerminal', self,, Location + MCTOffset.X * RotX + MCTOffset.Y * RotY + MCTOffset.Z * RotZ, MergeRotWithBuilding(MCTRotation));

		if(MCT != none)
		{
			MCT.BuildingOwner = self;
			MCT.SetTeamNum(Team);
			MCT.SetBase(self);
		}
	}
}

simulated function rotator MergeRotWithBuilding( rotator DesRot )
{
	local quat CarQuat, LookQuat, ResultQuat;

	CarQuat = QuatFromRotator(Rotation);
	LookQuat = QuatFromRotator(Normalize(DesRot));
	ResultQuat = QuatProduct(LookQuat, CarQuat);
	return QuatToRotator(ResultQuat);
}

simulated function ClearBuildingDecos()
{
	if(MCT != none)
		MCT.Destroy();

	if(FakePawn != none)
		FakePawn.Destroy();

	while(SummonedActors.length > 0)
	{
		SummonedActors[0].Destroy();
		SummonedActors.remove(0, 1);
	}

	while(SummonedPlayerStarts.length > 0)
	{
		SummonedPlayerStarts[0].Destroy();
		SummonedPlayerStarts.remove(0, 1);
	}

	while(SummonedDoors.length > 0)
	{
		SummonedDoors[0].Destroy();
		SummonedDoors.remove(0, 1);
	}
}

// Add to buildings list (both client/serverside)
static function ListBuilding( CCBuildings Other )
{
	if(Default.BuildingsList != none && Default.BuildingsList.Level != Other.Level)
		Default.BuildingsList = Other;
	else
	{
		Other.NextBuilding = Default.BuildingsList;
		Default.BuildingsList = Other;
	}
}

// Remove from buildings list
static function FlushFromList( CCBuildings Other )
{
	local CCBuildings C;

	if(Default.BuildingsList == none)
		Return; // Already cleared
	else if(Default.BuildingsList == Other)
		Default.BuildingsList = Other.NextBuilding;
	else
	{
		for(C=Default.BuildingsList; C!=None; C=C.NextBuilding)
		{
			if(C.NextBuilding == Other)
			{
				C.NextBuilding = Other.NextBuilding;
				Return;
			}
		}
	}
}

static function CCBuildings PickFirstBuilding( LevelInfo Other )
{
	if(Other == None)
		Return Default.BuildingsList;
	if(Default.BuildingsList != none && Default.BuildingsList.Level == Other)
		Return Default.BuildingsList;
	Default.BuildingsList = None;
	Return None;
}

simulated function bool CanHoldTiberium()
{
	Return False;
}

function bool PathVisible(vector Start, vector End, CCBuildings CheckActor)
{
	local vector HL,HN;

	Start.Z += CheckActor.PathScanZDifference;
	End.Z += CheckActor.PathScanZDifference;
	return CheckActor.TraceThisActor(HL,HN,End,Start,vect(120,120,20));
}

defaultproperties
{
     RedSkin=Combiner'VMVehicles-TX.HoverTankGroup.TankCBred'
     BlueSkin=Combiner'VMVehicles-TX.HoverTankGroup.TankCBblue'
     TerminalSkin=Texture'CommandAndConquerTEX.TIberiumPT'
     ShieldOverlay=Combiner'CommandAndConquerTEX.ShieldCombiner'
     BuildingImage=Texture'CommandAndConquerTEX.BuildingPICS.PowerPlantPIC'
     bCanBuildFrom=True
     BuildingName="C&C Building"
     NODDamagedSound=Sound'GameSounds.CTFAlarm'
     GDIDamagedSound=Sound'GameSounds.CTFAlarm'
     StartPositionNum=750
     EndPositionNum=550
     BuildDuration=60
     MaxAmount=1
     ScoreKill=1000
     BuildCost=1000
     Health=3000
     PowerUsage=1
     bNeedsToBeDestroyed=True
     bGetBonusForDamage=True
     DrawType=DT_StaticMesh
     bActorShadows=True
     bUseDynamicLights=True
     bWorldGeometry=True
     bIgnoreEncroachers=True
     bAlwaysRelevant=True
     bReplicateInstigator=True
     bUpdateSimulatedPosition=True
     RemoteRole=ROLE_SimulatedProxy
     bStaticLighting=True
     bCanBeDamaged=True
     CollisionRadius=2000.000000
     CollisionHeight=0.000000
     bCollideActors=True
     bBlockActors=True
     bProjTarget=True
     bBlockKarma=True
     bEdShouldSnap=True
     bPathColliding=True
}
