class MasterControlTerminal extends StaticMeshActor;

var CCBuildings BuildingOwner;
var Controller DelayedDamageInstigatorController;
var() Material NODSkin, GDISkin;
var byte Team;

replication
{
	reliable if(Role<ROLE_Authority)
		SetTeamNum;
	reliable if(bNetDirty && Role==ROLE_Authority)
		BuildingOwner,Team;
}

function SetTeamNum(byte myTeam)
{
    Team = myTeam;
    Skins.Length = 1;

    if(Team == 0 && NODSkin != none && Skins[0] != NODSkin)
        Skins[0] = NODSkin;
    else if(Team != 0 && GDISkin != none && Skins[0] != GDISkin)
        Skins[0] = GDISkin;
}

function SetDelayedDamageInstigatorController(Controller C)
{
	DelayedDamageInstigatorController = C;
}

function TakeDamage(int NDamage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
    Instigator = InstigatedBy;

    if((instigatedBy == none || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != none && DelayedDamageInstigatorController.Pawn != none)
		Instigator = DelayedDamageInstigatorController.Pawn;

    if(BuildingOwner != none && Instigator != none && xPawn(Instigator) != none)
    {
        NDamage *= 3;
        BuildingOwner.TakeDamage(NDamage, Instigator, hitlocation, momentum, damageType);
    }
}

simulated function DrawReticleHud(Canvas C, HudCommandAndConquer Hud)
{
    local float Num, i;

    if(BuildingOwner != none && BuildingOwner.Health > 0 && Hud != none && C != none)
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
        C.DrawText("Master Control Terminal");
        C.DrawColor = C.MakeColor(255,255,0);
        C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.64);
        i = ((128 / BuildingOwner.default.Health)*BuildingOwner.Health);
        C.DrawTileClipped(Material'CommandAndConquerTEX.HealthBar', i, 16, 0, 0, i, 16);
    }
}

defaultproperties
{
     NODSkin=Texture'CommandAndConquerTEX.BuildingTEX.mct_nod'
     GDISkin=Texture'CommandAndConquerTEX.BuildingTEX.mct_gdi'
     StaticMesh=StaticMesh'CommandAndConquerSM.Misc.MasterControlTerminal'
     bStatic=False
     bIgnoreEncroachers=True
     bNetInitialRotation=True
     RemoteRole=ROLE_None
     bCanBeDamaged=True
     bProjTarget=True
     bPathColliding=True
}
