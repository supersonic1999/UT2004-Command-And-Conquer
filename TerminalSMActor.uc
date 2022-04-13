class TerminalSMActor extends StaticMeshActor;

var vector RotX, RotY, RotZ;
var() byte Team;
var() Material RedSkin, BlueSkin;
var CCBuildings myInstigator;
var Light myLight;
var UseTrigger mySwitch;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
		myInstigator,Team;
}

function PostBeginPlay()
{
	if(Level.NetMode == NM_DedicatedServer)
		Disable('Tick');
}

simulated function Tick(float DeltaTime)
{
    if(ROLE == ROLE_Authority)
    {
        if(myInstigator != none && Team != myInstigator.Team)
            Team = myInstigator.Team;
        if(mySwitch == none)
        {
            mySwitch = spawn(class'MainSwitch', self);
            mySwitch.SetBase(self);

        }
        if(myLight == none)
        {
            myLight = spawn(class'TerminalLight', self);
    	    myLight.SetBase(self);
   	    }
    }

    if(Team == 0 && RedSkin != none && Skins[0] != RedSkin)
        Skins[0] = RedSkin;
    else if(Team != 0 && BlueSkin != none && Skins[0] != BlueSkin)
        Skins[0] = BlueSkin;
}

simulated function DrawReticleHud(Canvas C, HudCommandAndConquer Hud)
{
    local float Num;

    if(Hud != none && C != none)
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
        {
            C.DrawColor = C.MakeColor(0,255,0);
            C.SetPos((C.ClipX * 0.5) - C.ClipX * 0.04, (C.ClipY * 0.5)-(C.ClipY * (Num/2)) - (C.ClipY * 0.08)* 4);
            C.DrawTile(Material'CommandAndConquerTEX.ArrowMover', C.ClipX * 0.08, (C.ClipY * 0.08)* 4, 0, 0, Material'CommandAndConquerTEX.ArrowMover'.MaterialUSize(), Material'CommandAndConquerTEX.ArrowMover'.MaterialVSize());
        }

        C.SetPos((C.ClipX * 0.5)-(C.ClipX * (Num/2)), (C.ClipY * 0.5)-(C.ClipY * (Num/2)));
        C.DrawTile(Material'CommandAndConquerTEX.Reticle', (C.ClipX * Num), (C.ClipY * Num), 0, 0, 256, 512);
        C.Font = Hud.TextFont;
        C.FontScaleX = C.ClipX / 1024.f;
    	C.FontScaleY = C.ClipY / 768.f;
        C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.62);
        C.DrawText("Purchase Terminal");
    }
}

simulated function Destroyed()
{
    if(mySwitch != none)
        mySwitch.Destroy();

    if(myLight != none)
        myLight.Destroy();

	super.Destroyed();
}

simulated function UpdatePrecacheMaterials()
{
    Super.UpdatePrecacheMaterials();
    if(RedSkin != none)
        Level.AddPrecacheMaterial(RedSkin);
    if(BlueSkin != none)
        Level.AddPrecacheMaterial(BlueSkin);
}

defaultproperties
{
     RedSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalRED'
     BlueSkin=Shader'VMVehicles-TX.HoverTankGroup.HoverTankChassisFinalBLUE'
     StaticMesh=StaticMesh'CommandAndConquerSM.Misc.Terminal'
     bStatic=False
     bIgnoreEncroachers=True
     bNetInitialRotation=True
     RemoteRole=ROLE_None
     bProjTarget=True
     bPathColliding=True
}
