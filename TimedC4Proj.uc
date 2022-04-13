class TimedC4Proj extends ONSGrenadeProjectile;

var int Health;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
		Health;
    reliable if(Role<ROLE_Authority)
		DisarmBomb;
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

simulated function Stick(actor HitActor, vector HitLocation)
{
    if ( Trail != None )
        Trail.mRegen = false; // stop the emitter from regenerating

    bBounce = False;
    LastTouched = HitActor;
    SetPhysics(PHYS_None);
    SetBase(HitActor);
    bCollideWorld = False;
    bProjTarget = true;

	PlaySound(Sound'MenuSounds.Select3',,2.5*TransientSoundVolume);
}

simulated function PostBeginPlay()
{
    super.PostBeginPlay();
    SetTimer(30.0, False);
}

simulated function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType);

simulated function HitWall( vector HitNormal, actor Wall )
{
    if(xPawn(Wall) == none)
        Stick(Wall, Location);
}

simulated function Timer()
{
	Explode(Location, vect(0,0,1));
	//ONSGrenadeLauncher(Owner).Grenades.length--;
	//ONSGrenadeLauncher(Owner).CurrentGrenades--;
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
     Speed=500.000000
     MaxSpeed=500.000000
     Damage=330.000000
     DamageRadius=150.000000
     MyDamageType=Class'commandandconquer.DamTypeC4Placed'
     CollisionRadius=8.000000
     CollisionHeight=8.000000
     bBounce=False
}
