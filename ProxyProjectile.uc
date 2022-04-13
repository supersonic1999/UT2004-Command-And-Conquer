#exec OBJ LOAD FILE=..\Sounds\MenuSounds.uax

class ProxyProjectile extends Projectile;

var byte Team;
var int Health, MaxMines;
var ProxyProjectile GDIList, GDINext, NODList, NODNext;

replication
{
	reliable if (bNetDirty && Role == ROLE_Authority)
		Team, Health;
    reliable if(Role<ROLE_Authority)
		DisarmBomb;
}

simulated function PostBeginPlay()
{
    local int i;
    local rotator myRot;
    local ProxyProjectile M, MM;

    super.PostBeginPlay();

   	myRot.Yaw = Rotation.Yaw;
    myRot.Roll = Rotation.Roll;
    myRot.Pitch = 0;

    SetRotation(myRot);
    Velocity = Speed * Vector(Rotation);

    if(Role == ROLE_Authority && Instigator != None)
    	Team = Instigator.GetTeamNum();

   	if(PhysicsVolume.bWaterVolume)
   	    Explode(Location, vect(0,0,1));

    Class'ProxyProjectile'.Static.ListMine(Self, Team);

    if(Team == 0)
    {
        for(M=Class'ProxyProjectile'.Static.PickFirstMine(Level, Team); M!=None; M=M.NODNext)
        {
            i++;
            MM = M;
        }
    }
    else
    {
        for(M=Class'ProxyProjectile'.Static.PickFirstMine(Level, Team); M!=None; M=M.GDINext)
        {
            i++;
            MM = M;
        }
    }

    if(Team == 0 && i > MaxMines)
    {
        Class'ProxyProjectile'.Static.FlushFromList(MM, Team);
        MM.Explode(Location, vect(0,0,1));
    }
    else if(Team != 0 && i > MaxMines)
    {
        Class'ProxyProjectile'.Static.FlushFromList(MM, Team);
        MM.Explode(Location, vect(0,0,1));
    }
}

simulated function ProcessTouch( actor Other, vector HitLocation )
{
    if (!bPendingDelete && Base == None && xPawn(Other) == none
    && (!Other.bWorldGeometry && Other.Class != class && Other != Instigator))
	    Stick(Other, HitLocation);
}

function DisarmBomb(int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    Instigator = InstigatedBy;

    if(Instigator != None)
    {
        Health -= NDamage;
        if(Health <= 0)
            Destroy();
    }
}

simulated function Destroyed()
{
    Class'ProxyProjectile'.Static.FlushFromList(Self, Team);

    if(!bNoFX)
    {
		if(EffectIsRelevant(Location, false))
		{
			Spawn(class'ONSGrenadeExplosionEffect',,, Location, rotator(vect(0,0,1)));
			Spawn(ExplosionDecal,self,, Location, rotator(vect(0,0,-1)));
		}
		PlaySound(sound'WeaponSounds.BExplosion3',,2.5*TransientSoundVolume);
	}

    Super.Destroyed();
}

simulated function Stick(actor HitActor, vector HitLocation)
{
    bBounce = False;
    LastTouched = HitActor;
    SetPhysics(PHYS_None);
    SetBase(HitActor);
    bCollideWorld = False;
    bProjTarget = true;

	PlaySound(Sound'MenuSounds.Select3',,2.5*TransientSoundVolume);
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, None );
}

simulated function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType);

simulated function HitWall( vector HitNormal, actor Wall )
{
    Stick(Wall, Location);
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if ( bHurtEntry )
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Hurtwall != Victims) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') )
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1;
			if ( Instigator == None || Instigator.Controller == None )
				Victims.SetDelayedDamageInstigatorController( InstigatorController );
			if ( Victims == LastTouched )
				LastTouched = None;
			Victims.TakeDamage
			(
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
			if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
				Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);

		}
	}
	if ( (LastTouched != None) && (LastTouched != self) && (LastTouched.Role == ROLE_Authority) && !LastTouched.IsA('FluidSurfaceInfo') )
	{
		Victims = LastTouched;
		LastTouched = None;
		dir = Victims.Location - HitLocation;
		dist = FMax(1,VSize(dir));
		dir = dir/dist;
		damageScale = 1;
		if ( Instigator == None || Instigator.Controller == None )
			Victims.SetDelayedDamageInstigatorController(InstigatorController);
		Victims.TakeDamage
		(
			damageScale * DamageAmount,
			Instigator,
			Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
			(damageScale * Momentum * dir),
			DamageType
		);
		if (Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
			Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, InstigatorController, DamageType, Momentum, HitLocation);
	}

	bHurtEntry = false;
}

simulated function PawnBaseDied()
{
	Explode(Location, vect(0,0,1));
}

function Tick(float Deltatime)
{
    local Controller C;

    if(Role == ROLE_Authority)
        for(C=Level.ControllerList; C!=None; C=C.NextController)
            if(C.Pawn != none && C.Pawn.GetTeamNum() != Team && VSize(C.Pawn.Location-Location) < Max(0, DamageRadius - 10))
                Explode(Location, vect(0,0,1));

    super.Tick(Deltatime);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    LastTouched = Base;
    BlowUp(HitLocation);
    Destroy();
}

static function ListMine(ProxyProjectile Other, byte MineTeam)
{
	if(MineTeam == 0)
	{
        if(Default.NODList != none && Default.NODList.Level != Other.Level)
    		Default.NODList = Other;
    	else
    	{
    		Other.NODNext = Default.NODList;
    		Default.NODList = Other;
    	}
	}
	else
	{
        if(Default.GDIList != none && Default.GDIList.Level != Other.Level)
    		Default.GDIList = Other;
    	else
    	{
    		Other.GDINext = Default.GDIList;
    		Default.GDIList = Other;
    	}
	}
}

static function FlushFromList(ProxyProjectile Other, byte MineTeam)
{
	local ProxyProjectile C;

    if(MineTeam == 0)
    {
    	if(Default.NODList == none)
    		Return;
    	else if(Default.NODList == Other)
    		Default.NODList = Other.NODNext;
    	else
    	{
    		for(C=Default.NODList; C!=None; C=C.NODNext)
    		{
    			if(C.NODNext == Other)
    			{
    				C.NODNext = Other.NODNext;
    				Return;
    			}
    		}
    	}
	}
	else
	{
	    if(Default.GDIList == none)
    		Return;
    	else if(Default.GDIList == Other)
    		Default.GDIList = Other.GDINext;
    	else
    	{
    		for(C=Default.GDIList; C!=None; C=C.GDINext)
    		{
    			if(C.GDINext == Other)
    			{
    				C.GDINext = Other.GDINext;
    				Return;
    			}
    		}
    	}
	}
}

static function ProxyProjectile PickFirstMine(LevelInfo Other, byte MineTeam)
{
	if(MineTeam == 0)
	{
        if(Other == None)
    		return Default.NODList;
    	if(Default.NODList != none && Default.NODList.Level == Other)
    		return Default.NODList;
    	Default.NODList = None;
    	return None;
	}
	else
	{
        if(Other == None)
    		return Default.GDIList;
    	if(Default.GDIList != none && Default.GDIList.Level == Other)
    		return Default.GDIList;
    	Default.GDIList = None;
    	return None;
	}
}

simulated function DrawReticleHud(Canvas C, HudCommandAndConquer Hud)
{
    local float Num, i;

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

    if(Team != Hud.PawnOwner.GetTeamNum())
        C.DrawColor = C.MakeColor(255,0,0);
    else
        C.DrawColor = C.MakeColor(0,255,0);

    C.SetPos((C.ClipX * 0.5)-(C.ClipX * (Num/2)), (C.ClipY * 0.5)-(C.ClipY * (Num/2)));
    C.DrawTile(Material'CommandAndConquerTEX.Reticle', (C.ClipX * Num), (C.ClipY * Num), 0, 0, 256, 512);
    C.Font = Hud.TextFont;
    C.FontScaleX = C.ClipX / 1024.f;
    C.FontScaleY = C.ClipY / 768.f;
    C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.62);
    C.DrawText("C4 Explosive");
    C.DrawColor = C.MakeColor(255,255,0);
    C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.64);
    i = ((128 / default.Health)*Health);
    C.DrawTileClipped(Material'CommandAndConquerTEX.HealthBar', i, 16, 0, 0, i, 16);
}

defaultproperties
{
     Health=100
     MaxMines=40
     Speed=600.000000
     MaxSpeed=600.000000
     TossZ=0.000000
     bSwitchToZeroCollision=True
     Damage=100.000000
     DamageRadius=150.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'commandandconquer.DamTypeMine'
     ImpactSound=ProceduralSound'WeaponSounds.PGrenFloor1.P1GrenFloor1'
     ExplosionDecal=Class'Onslaught.ONSRocketScorch'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'VMWeaponsSM.PlayerWeaponsGroup.VMGrenade'
     CullDistance=5000.000000
     bNetTemporary=False
     bOnlyDirtyReplication=True
     Physics=PHYS_Falling
     LifeSpan=0.000000
     DrawScale3D=(X=0.300000,Y=0.300000,Z=0.020000)
     AmbientGlow=100
     bHardAttach=True
     CollisionRadius=25.000000
     CollisionHeight=2.000000
     bUseCollisionStaticMesh=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
}
