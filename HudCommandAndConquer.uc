class HudCommandAndConquer extends HudCTeamDeathMatch;

#exec OBJ LOAD FILE="..\Textures\CommandAndConquerTEX.utx"
#exec OBJ LOAD FILE="..\Textures\2K4Menus.utx"
#exec OBJ LOAD FILE="..\Textures\X_CliffTest.utx"

struct HudLocation
{
    var int AHealth, ATeam;
    var class<Actor> AClass;
    var vector ALocation;
    var bool bNoDriver;
};
var array<HudLocation> ActorHudInfo;

var config float RadarScale, RadarTrans, IconScale, RadarPosX, RadarPosY;
var() config texture MouseCursor;
var float RadarMaxRange, RadarRange;
var vector MapCenter;
var int ClipY, ClipX, Page, DragStartX, DragStartY;
var bool bDisabledOne, bDisabledTwo, bDisabledThree;
var array<Actor> SelectedActor;
var() Material BorderMat;
var Font TextFont;

//0 = Normal
//1 = Sell
//2 = Buy
var byte Mode;

//var localized string CommanderResigned;

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//////////////COMMANDER VIEW HUD////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

simulated function DrawCommanderHUD(Canvas C)
{
    local vector ALocation;
	local float i, Num;
	local int S;

    ClipY = C.ClipY;
    ClipX = C.ClipX;

    EnableDisable();

    for(S=0;S<SelectedActor.Length;S++)
    {
        if(SelectedActor[S] != none && CCBuildings(SelectedActor[S]) != none)
            CCBuildings(SelectedActor[S]).DrawCommanderSelectionHud(C, self, S);
        else if(SelectedActor[S] != none && Pawn(SelectedActor[S]) != none)
        {
        	ALocation = PlayerOwner.Player.LocalInteractions[0].WorldToScreen(SelectedActor[S].Location);

        	if(Pawn(SelectedActor[S]).GetTeamNum() != PlayerOwner.GetTeamNum())
        		C.DrawColor = C.MakeColor(255,0,0);
        	else
                C.DrawColor = C.MakeColor(0,255,0);

        	C.SetPos(ALocation.X - (C.ClipX * 0.125), ALocation.Y - (C.ClipY * 0.125));
        	C.DrawTile(Material'CommandAndConquerTEX.Reticle', (C.ClipX * 0.25), (C.ClipY * 0.25), 0, 0, 256, 512);
        	C.DrawColor = C.MakeColor(255,255,0);
        	C.SetPos(ALocation.X - (C.ClipX * 0.1), ALocation.Y - (C.ClipY * 0.125));
        	if(xPawn(SelectedActor[S]) != none)
                i = (((((C.ClipX * 0.21) / xPawn(SelectedActor[S]).default.Health)*xPawn(SelectedActor[S]).Health) + ((128 / xPawn(SelectedActor[S]).ShieldStrengthMax)*xPawn(SelectedActor[S]).ShieldStrength)) / 2);
            else
                i = (((C.ClipX * 0.21) / Pawn(SelectedActor[S]).default.Health)*Pawn(SelectedActor[S]).Health);
        	C.DrawTileClipped(Material'CommandAndConquerTEX.HealthBar', i, 8, 0, 0, i, 8);
        }
    }

    if(DragStartX != 0)
    {
        C.DrawColor = C.MakeColor(255,255,255);

        C.SetPos(DragStartX, DragStartY);
        if(DragStartY - PlayerOwner.Player.WindowsMouseY > 0)
            Num = -(DragStartY - PlayerOwner.Player.WindowsMouseY);
        else
            Num = abs(DragStartY - PlayerOwner.Player.WindowsMouseY);
        C.DrawTile(Texture'engine.WhiteSquareTexture', 2, Num, 0, 0, 2, 2);
        C.SetPos(DragStartX, DragStartY);
        if(DragStartX - PlayerOwner.Player.WindowsMouseX > 0)
            Num = -(DragStartX - PlayerOwner.Player.WindowsMouseX);
        else
            Num = abs(DragStartX - PlayerOwner.Player.WindowsMouseX);
        C.DrawTile(Texture'engine.WhiteSquareTexture', Num, 2, 0, 0, 2, 2);

        C.SetPos(PlayerOwner.Player.WindowsMouseX, PlayerOwner.Player.WindowsMouseY);
        C.DrawTile(Texture'engine.WhiteSquareTexture', 2, DragStartY - PlayerOwner.Player.WindowsMouseY, 0, 0, 2, 2);
        C.SetPos(PlayerOwner.Player.WindowsMouseX, PlayerOwner.Player.WindowsMouseY);
        C.DrawTile(Texture'engine.WhiteSquareTexture', DragStartX - PlayerOwner.Player.WindowsMouseX, 2, 0, 0, 2, 2);
    }

    C.Reset();

    C.SetPos(C.ClipX * 0.75, 0);
    C.DrawRect(Material'CommandAndConquerTEX.MiddleSection', C.ClipX * 0.25, C.ClipY);
    C.SetPos(C.ClipX * 0.755, C.ClipY * 0.30);
    C.DrawRect(Material'CommandAndConquerTEX.POWER', C.ClipX * 0.02, C.ClipY * 0.70);
    C.SetPos(C.ClipX * 0.75, 0);
    C.DrawRect(Material'CommandAndConquerTEX.RADARBackground', C.ClipX * 0.25, C.ClipY * 0.25);

    C.SetPos(0, 0);
    C.DrawTile(Material'CommandAndConquerTEX.CLOSE', C.ClipX * 0.25 + 40, C.ClipY * 0.02, 70, 0, Material'CommandAndConquerTEX.CLOSE'.MaterialUSize() - 70, Material'CommandAndConquerTEX.CLOSE'.MaterialVSize());
    C.SetPos(C.ClipX * 0.5, 0);
    C.DrawTile(Material'CommandAndConquerTEX.TOPBlock', C.ClipX * 0.25 + 40, C.ClipY * 0.02, 70, 0, Material'CommandAndConquerTEX.TOPBlock'.MaterialUSize() - 70, Material'CommandAndConquerTEX.TOPBlock'.MaterialVSize());
    C.SetPos(C.ClipX * 0.25, 0);
    C.DrawTile(Material'CommandAndConquerTEX.RESIGN', C.ClipX * 0.25 + 40, C.ClipY * 0.02, 70, 0, Material'CommandAndConquerTEX.RESIGN'.MaterialUSize() - 70, Material'CommandAndConquerTEX.RESIGN'.MaterialVSize());
    C.SetPos(C.ClipX * 0.92, C.ClipY * 0.25);
    C.DrawRect(Material'CommandAndConquerTEX.MAP_Button', C.ClipX * 0.07, C.ClipY * 0.04);
    C.SetPos(C.ClipX * 0.84, C.ClipY * 0.25);
    C.DrawRect(Material'CommandAndConquerTEX.SELL_Button', C.ClipX * 0.07, C.ClipY * 0.04);
    C.SetPos(C.ClipX * 0.76, C.ClipY * 0.25);
    C.DrawRect(Material'CommandAndConquerTEX.REPAIR_Button', C.ClipX * 0.07, C.ClipY * 0.04);

    C.SetPos(C.ClipX * 0.79, C.ClipY * 0.94);
    C.DrawRect(Material'CommandAndConquerTEX.UPArrow', C.ClipX * 0.10, C.ClipY * 0.05);
    C.SetPos(C.ClipX * 0.89, C.ClipY * 0.94);
    C.DrawRect(Material'CommandAndConquerTEX.DOWNArrow', C.ClipX * 0.10, C.ClipY * 0.05);

    if(bDisabledOne)
        C.SetDrawColor(0, 0, 0);
    else
        C.DrawColor = C.default.DrawColor;
    C.SetPos(C.ClipX * 0.79, C.ClipY * 0.3);
    if(PlayerOwner.GetTeamNum() == 0)
        C.DrawRect(CCReplicationInfo(Level.GRI).MainController.Buildings[0+Page].RedBuilding.default.BuildingImage, C.ClipX * 0.20, C.ClipY * 0.20);
    else
        C.DrawRect(CCReplicationInfo(Level.GRI).MainController.Buildings[0+Page].BlueBuilding.default.BuildingImage, C.ClipX * 0.20, C.ClipY * 0.20);
    if(bDisabledTwo)
        C.SetDrawColor(0, 0, 0);
    else
        C.DrawColor = C.default.DrawColor;
    C.SetPos(C.ClipX * 0.79, C.ClipY * 0.51);
    if(PlayerOwner.GetTeamNum() == 0)
        C.DrawRect(CCReplicationInfo(Level.GRI).MainController.Buildings[1+Page].RedBuilding.default.BuildingImage, C.ClipX * 0.20, C.ClipY * 0.20);
    else
        C.DrawRect(CCReplicationInfo(Level.GRI).MainController.Buildings[1+Page].BlueBuilding.default.BuildingImage, C.ClipX * 0.20, C.ClipY * 0.20);
    if(bDisabledThree)
        C.SetDrawColor(0, 0, 0);
    else
        C.DrawColor = C.default.DrawColor;
    C.SetPos(C.ClipX * 0.79, C.ClipY * 0.72);
    if(PlayerOwner.GetTeamNum() == 0)
        C.DrawRect(CCReplicationInfo(Level.GRI).MainController.Buildings[2+Page].RedBuilding.default.BuildingImage, C.ClipX * 0.20, C.ClipY * 0.20);
    else
        C.DrawRect(CCReplicationInfo(Level.GRI).MainController.Buildings[2+Page].BlueBuilding.default.BuildingImage, C.ClipX * 0.20, C.ClipY * 0.20);
    DrawRadarMap(C, C.ClipX * 0.875, C.ClipY * 0.13, C.ClipY * 0.1);

    C.Reset();
    C.SetDrawColor(255,255,255,255);
    C.Font = TextFont;
    C.FontScaleX = C.ClipX / 1024.f;
	C.FontScaleY = C.ClipY / 768.f;

    C.SetPos(C.ClipX * 0.79, C.ClipY * 0.3);
    if(PlayerOwner.GetTeamNum() == 0)
    {
        C.DrawText(CCReplicationInfo(Level.GRI).MainController.Buildings[0+Page].RedBuilding.default.BuildingName);
        C.SetPos(C.ClipX * 0.79, C.ClipY * 0.32);
        C.DrawText("Cost:" @ CCReplicationInfo(Level.GRI).MainController.Buildings[0+Page].RedBuilding.default.BuildCost);
    }
    else
    {
        C.DrawText(CCReplicationInfo(Level.GRI).MainController.Buildings[0+Page].BlueBuilding.default.BuildingName);
        C.SetPos(C.ClipX * 0.79, C.ClipY * 0.32);
        C.DrawText("Cost:" @ CCReplicationInfo(Level.GRI).MainController.Buildings[0+Page].BlueBuilding.default.BuildCost);
    }

    C.SetPos(C.ClipX * 0.79, C.ClipY * 0.51);
    if(PlayerOwner.GetTeamNum() == 0)
    {
        C.DrawText(CCReplicationInfo(Level.GRI).MainController.Buildings[1+Page].RedBuilding.default.BuildingName);
        C.SetPos(C.ClipX * 0.79, C.ClipY * 0.53);
        C.DrawText("Cost:" @ CCReplicationInfo(Level.GRI).MainController.Buildings[1+Page].RedBuilding.default.BuildCost);
    }
    else
    {
        C.DrawText(CCReplicationInfo(Level.GRI).MainController.Buildings[1+Page].BlueBuilding.default.BuildingName);
        C.SetPos(C.ClipX * 0.79, C.ClipY * 0.53);
        C.DrawText("Cost:" @ CCReplicationInfo(Level.GRI).MainController.Buildings[1+Page].BlueBuilding.default.BuildCost);
    }

    C.SetPos(C.ClipX * 0.79, C.ClipY * 0.72);
    if(PlayerOwner.GetTeamNum() == 0)
    {
        C.DrawText(CCReplicationInfo(Level.GRI).MainController.Buildings[2+Page].RedBuilding.default.BuildingName);
        C.SetPos(C.ClipX * 0.79, C.ClipY * 0.74);
        C.DrawText("Cost:" @ CCReplicationInfo(Level.GRI).MainController.Buildings[2+Page].RedBuilding.default.BuildCost);
    }
    else
    {
        C.DrawText(CCReplicationInfo(Level.GRI).MainController.Buildings[2+Page].BlueBuilding.default.BuildingName);
        C.SetPos(C.ClipX * 0.79, C.ClipY * 0.74);
        C.DrawText("Cost:" @ CCReplicationInfo(Level.GRI).MainController.Buildings[2+Page].BlueBuilding.default.BuildCost);
    }

    C.SetDrawColor(0, 150, 0);
    C.SetPos(C.ClipX * 0.6, 0);
    if(PlayerOwner.GetTeamNum() == 0)
        C.DrawText(int(CCReplicationInfo(Level.GRI).NODCommanderMoney));
    else
        C.DrawText(int(CCReplicationInfo(Level.GRI).GDICommanderMoney));

    C.Reset();
    C.SetDrawColor(255, 255, 255);
    C.Style = 6;
    if(Mode >= 1)
        C.SetPos(PlayerOwner.Player.WindowsMouseX - MouseCursor.MaterialUSize(), PlayerOwner.Player.WindowsMouseY - MouseCursor.MaterialVSize());
    else
        C.SetPos(PlayerOwner.Player.WindowsMouseX, PlayerOwner.Player.WindowsMouseY);

    if(Mode == 1 && MouseCursor != Material'CommandAndConquerTEX.Misc.CCSell_NO'
    && (CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) == none
    || CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) != none
    && !CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).bBuilt))
        MouseCursor = Material'CommandAndConquerTEX.Misc.CCSell_NO';
    else if(Mode == 1 && MouseCursor != Material'CommandAndConquerTEX.Misc.CCSell'
    && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) != none
    && !CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).bSelling
    && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).Team == PlayerOwner.GetTeamNum()
    && CYard(CommandController(PlayerOwner).MouseTouchingActor) == none
    && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).bBuilt)
        MouseCursor = Material'CommandAndConquerTEX.Misc.CCSell';
    else if(Mode == 2 && MouseCursor != Material'CommandAndConquerTEX.Misc.CCSpanner_NO'
    && (CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) == none
    || CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) != none
    && !CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).bBuilt))
        MouseCursor = Material'CommandAndConquerTEX.Misc.CCSpanner_NO';
    else if(Mode == 2 && MouseCursor != Material'CommandAndConquerTEX.Misc.CCSpanner'
    && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) != none
    && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).Team == PlayerOwner.GetTeamNum()
    && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).bBuilt)
        MouseCursor = Material'CommandAndConquerTEX.Misc.CCSpanner';
    else if(Mode == 0 && MouseCursor != default.MouseCursor)
        MouseCursor = default.MouseCursor;

    C.DrawIcon(MouseCursor, 2);
    C.Reset();
}

simulated function EnableDisable()
{
    local int i, x;

    if(PlayerOwner != none && PlayerOwner.GetTeamNum() == 0  && CCReplicationInfo(Level.GRI).MainController != none)
    {
        for(i=0;i<CCReplicationInfo(Level.GRI).MainController.Buildings.Length;i++)
        {
            if(CCReplicationInfo(Level.GRI).MainController.Buildings[i].RedBuilding != none
            && CCReplicationInfo(Level.GRI).MainController.Buildings[i].RedBuilding.default.MaxAmount > 0)
            {
                X = CommandController(PlayerOwner).CheckBuildingAmount(i);
                if(X >= CCReplicationInfo(Level.GRI).MainController.Buildings[i].RedBuilding.default.MaxAmount)
                {
                    ChangeButton(i, true);
                    continue;
                }
            }

            if(CCReplicationInfo(Level.GRI).NODCommanderMoney < CCReplicationInfo(Level.GRI).MainController.Buildings[i].RedBuilding.default.BuildCost)
                ChangeButton(i, True);
            else
                ChangeButton(i, False);
        }
    }
    else if(CCReplicationInfo(Level.GRI).MainController != none)
    {
        for(i=0;i<CCReplicationInfo(Level.GRI).MainController.Buildings.Length;i++)
        {
            if(CCReplicationInfo(Level.GRI).MainController.Buildings[i].BlueBuilding != none
            && CCReplicationInfo(Level.GRI).MainController.Buildings[i].BlueBuilding.default.MaxAmount >= 0)
            {
                X = CommandController(PlayerOwner).CheckBuildingAmount(i);
                if(X >= CCReplicationInfo(Level.GRI).MainController.Buildings[i].BlueBuilding.default.MaxAmount)
                {
                    ChangeButton(i, true);
                    continue;
                }
            }

            if(CCReplicationInfo(Level.GRI).GDICommanderMoney < CCReplicationInfo(Level.GRI).MainController.Buildings[i].BlueBuilding.default.BuildCost)
                ChangeButton(i, True);
            else
                ChangeButton(i, False);
        }
    }
}

simulated function ChangeButton(int x, bool Disable)
{
    if(Disable)
    {
        if(x == 0 + Page)
            bDisabledOne = True;
        else if(x == 1 + Page)
            bDisabledTwo = True;
        else if(x == 2 + Page)
            bDisabledThree = True;
    }
    else
    {
        if(x == 0 + Page)
            bDisabledOne = False;
        else if(x == 1 + Page)
            bDisabledTwo = False;
        else if(x == 2 + Page)
            bDisabledThree = False;
    }
}

simulated function DoButtonClick(bool bLeftClick)
{
    local int i;

    if(PlayerOwner != none && CommandController(PlayerOwner) != none && CommandController(PlayerOwner).bCommandView)
    {
        if(bLeftClick)
        {
            if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.76 && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.83
            && PlayerOwner.Player.WindowsMouseY >= ClipY * 0.25 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.28
            && CommandController(PlayerOwner).CurPlacement == none) //Repair Button.
                Mode = 2;
            else if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.84 && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.91
            && PlayerOwner.Player.WindowsMouseY >= ClipY * 0.25 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.28
            && CommandController(PlayerOwner).CurPlacement == none) //Sell Button.
                Mode = 1;
            else if(Mode == 1 && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) != none
            && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).Team == PlayerOwner.GetTeamNum()
            && !CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).bSelling
            && CYard(CommandController(PlayerOwner).MouseTouchingActor) == none
            && CCBuildings(CommandController(PlayerOwner).MouseTouchingActor).bBuilt) //Sell building your mouse is over.
                CommandController(PlayerOwner).DoSellBuilding();
            else if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.25 && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.5
            && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.02) //Commander resigned.
            {
                CommandController(PlayerOwner).RemoveCommander(PlayerOwner.GetTeamNum(), false, CCReplicationInfo(Level.GRI).CommanderResigned);
                Mode = 0;
            }
            else if(PlayerOwner.Player.WindowsMouseX <= ClipX * 0.25 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.02) //Close Commander Mode.
            {
                CommandController(PlayerOwner).RepossesOldBody();
                if(CommandController(PlayerOwner).CurPlacement != none)
                {
                    CommandController(PlayerOwner).CurPlacement.Destroy();
                    CommandController(PlayerOwner).CurPlacement = none;
                }
            }
            else if(CommandController(PlayerOwner).CurPlacement != none) //Place current building.
            {
                if(CommandController(PlayerOwner).CheckPlacability())
                {
                    CommandController(PlayerOwner).TakeCmdMoney(-CommandController(PlayerOwner).CurPlacement.BuildCost);
                    CommandController(PlayerOwner).SpawnNewBuilding(CommandController(PlayerOwner).CurPlacement.class, CommandController(PlayerOwner).CurPlacement.Location, CommandController(PlayerOwner).CurPlacement.Rotation);
                    CommandController(PlayerOwner).CurPlacement.Destroy();
                    CommandController(PlayerOwner).CurPlacement = none;
                }
                else
                    PlayerOwner.ClientPlaySound(sound'MenuSounds.Denied1');
            }
            else if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.78 && PlayerOwner.Player.WindowsMouseY >= ClipY * 0.93
            && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.88 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.98 && Page - 1 >= 0) //Change building page (-).
                Page -= 1;
            else if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.88 && PlayerOwner.Player.WindowsMouseY >= ClipY * 0.93
            && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.98 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.98 && Page + 1 < (CCReplicationInfo(Level.GRI).MainController.Buildings.length - 2)) //Change building page (+).
                Page += 1;
            else if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.78 && PlayerOwner.Player.WindowsMouseY >= ClipY * 0.3
            && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.98 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.5 && !bDisabledOne && Mode == 0) //Spawn Building when clicked on (1).
                CommandController(PlayerOwner).SpawnPlacementBuilding(0+Page);
            else if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.78 && PlayerOwner.Player.WindowsMouseY >= ClipY * 0.5
            && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.98 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.7 && !bDisabledTwo && Mode == 0) //Spawn Building when clicked on (2).
                CommandController(PlayerOwner).SpawnPlacementBuilding(1+Page);
            else if(PlayerOwner.Player.WindowsMouseX >= ClipX * 0.78 && PlayerOwner.Player.WindowsMouseY >= ClipY * 0.7
            && PlayerOwner.Player.WindowsMouseX <= ClipX * 0.98 && PlayerOwner.Player.WindowsMouseY <= ClipY * 0.9 && !bDisabledThree && Mode == 0) //Spawn Building when clicked on (3).
                CommandController(PlayerOwner).SpawnPlacementBuilding(2+Page);
            else if(CCBuildings(CommandController(PlayerOwner).MouseTouchingActor) != none || Pawn(CommandController(PlayerOwner).MouseTouchingActor) != none) //Make reference to clicked on building.
            {
                SelectedActor.Remove(0, SelectedActor.Length);
                SelectedActor[0] = CommandController(PlayerOwner).MouseTouchingActor;
            }
            else if(SelectedActor[0] != none && CommandController(PlayerOwner).MouseTouchingActor == none) //Remove reference to selected building.
                SelectedActor.Remove(0, SelectedActor.Length);
        }
        else
        {
            if(Mode != 0) //Cancel other mode.
                Mode = 0;
            else if(CommandController(PlayerOwner).CurPlacement != none) //Cancel current building.
            {
                CommandController(PlayerOwner).CurPlacement.Destroy();
                CommandController(PlayerOwner).CurPlacement = none;
                PlayerOwner.ClientPlaySound(sound'MenuSounds.Denied1');
            }
            else if(SelectedActor[0] != none)
                for(i=0;i<SelectedActor.Length;i++)
                    if(Pawn(SelectedActor[i]) != none && Pawn(SelectedActor[i]).GetTeamNum() == PlayerOwner.GetTeamNum())
                        CommandController(PlayerOwner).SetNewOrders(Pawn(SelectedActor[i]), CommandController(PlayerOwner).RealMouseLocation);
        }
        CommandController(PlayerOwner).SaveMouseMoveTime();
    }
}

simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    if(PlayerOwner != none && CommandController(PlayerOwner) != none && CommandController(PlayerOwner).bCommandView)
    {
        if(PlayerOwner.Player.WindowsMouseY >= ClipY - 1) //Down
        {
            CommandController(PlayerOwner).CamLocation.Y += CommandController(PlayerOwner).MoveSpeed*DeltaTime/0.1;
            CommandController(PlayerOwner).SaveMouseMoveTime();
        }
        else if(PlayerOwner.Player.WindowsMouseY < 1) //Up
        {
            CommandController(PlayerOwner).CamLocation.Y -= CommandController(PlayerOwner).MoveSpeed*DeltaTime/0.1;
            CommandController(PlayerOwner).SaveMouseMoveTime();
        }

        if(PlayerOwner.Player.WindowsMouseX >= ClipX - 1) //Right
        {
            CommandController(PlayerOwner).CamLocation.X += CommandController(PlayerOwner).MoveSpeed*DeltaTime/0.1;
            CommandController(PlayerOwner).SaveMouseMoveTime();
        }
        else if(PlayerOwner.Player.WindowsMouseX < 1) //Left
        {
            CommandController(PlayerOwner).CamLocation.X -= CommandController(PlayerOwner).MoveSpeed*DeltaTime/0.1;
            CommandController(PlayerOwner).SaveMouseMoveTime();
        }
    }
}

simulated function DrawSpectatingHud(Canvas C)
{
    if(PlayerOwner != none && CommandController(PlayerOwner).bCommandView)
        DrawCommanderHUD(C);
    else
        super.DrawSpectatingHud(C);
}

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//////////////MAIN PAWNS HUD////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

simulated event PostBeginPlay()
{
	local TerrainInfo T, PrimaryTerrain;

	Super.PostBeginPlay();

    TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));

    foreach AllActors(class'TerrainInfo', T)
    {
        PrimaryTerrain = T;
        if (T.Tag == 'PrimaryTerrain')
            Break;
    }

    if (Level.bUseTerrainForRadarRange && PrimaryTerrain != None)
        RadarRange = abs(PrimaryTerrain.TerrainScale.X * PrimaryTerrain.TerrainMap.USize) / 2.0;
    else if (Level.CustomRadarRange > 0)
        RadarRange = Clamp(Level.CustomRadarRange, 500.0, default.RadarMaxRange);
}

simulated function UpdateTeamHud()
{
    local GameReplicationInfo GRI;
    local int i;

	GRI = PlayerOwner.GameReplicationInfo;

	if (GRI == None)
        return;

    for (i = 0; i < 2; i++)
    {
        if (GRI.Teams[i] == None)
            continue;

		TeamSymbols[i].Tints[i] = HudColorTeam[i];
        ScoreTeam[i].Value = GRI.Teams[i].Score;  // max space in hud

        if (GRI.TeamSymbols[i] != None)
			TeamSymbols[i].WidgetTexture = GRI.TeamSymbols [i];
    }
}

simulated function ShowTeamScorePassC(Canvas C)
{
    local float RadarWidth, CenterRadarPosX, CenterRadarPosY;

    RadarWidth = 0.5 * RadarScale * HUDScale * C.ClipX;
    CenterRadarPosX = (RadarPosX * C.ClipX) - RadarWidth;
    CenterRadarPosY = (RadarPosY * C.ClipY) + RadarWidth;
    if(bShowPersonalInfo)
    {
        DrawRadarMap(C, CenterRadarPosX, CenterRadarPosY, RadarWidth);
        DrawMoneyCount(C);
        DrawEnemyName(C);
        DrawTeamCommander(C);
        DrawCompass(C);
        DrawMutinyText(C);
    }
    super.ShowTeamScorePassC(C);
}

simulated function DrawMutinyText(Canvas C)
{
    C.DrawColor = C.MakeColor(0,200,0);
    C.SetPos(0, C.ClipY * 0.8);
    if(CCReplicationInfo(Level.GRI).MutinyVotesNOD >= 1 && PlayerOwner.GetTeamNum() == 0)
	    C.DrawText((CCReplicationInfo(Level.GRI).NODMutinyVoters[0].PlayerName @ "started a mutiny against" @ CCReplicationInfo(Level.GRI).CommanderRED.PlayerName @ "press 'Page Up' to vote for the mutiny."), true);
    else if(CCReplicationInfo(Level.GRI).MutinyVotesGDI >= 1 && PlayerOwner.GetTeamNum() != 0)
        C.DrawText((CCReplicationInfo(Level.GRI).NODMutinyVoters[0].PlayerName @ "started a mutiny against" @ CCReplicationInfo(Level.GRI).CommanderRED.PlayerName @ "press 'Page Up' to vote for the mutiny."), true);
}

function DrawCustomBeacon(Canvas C, Pawn P, float ScreenLocX, float ScreenLocY)
{
	local texture BeaconTex;
	local float XL,YL;

	BeaconTex = PlayerOwner.TeamBeaconTexture;
	if ( (BeaconTex == None) || (P.PlayerReplicationInfo == None) )
		return;

	if ( P.PlayerReplicationInfo.Team != None )
		C.DrawColor = class'CommandController'.Default.TeamBeaconTeamColors[P.PlayerReplicationInfo.Team.TeamIndex];
	else
		C.DrawColor = class'CommandController'.Default.TeamBeaconTeamColors[0];

	C.StrLen(P.PlayerReplicationInfo.PlayerName, XL, YL);
	C.SetPos(ScreenLocX - 0.5*XL , ScreenLocY - 0.125 * BeaconTex.VSize - YL);
	C.DrawText(P.PlayerReplicationInfo.PlayerName,true);

	C.SetPos(ScreenLocX - 0.125 * BeaconTex.USize, ScreenLocY - 0.125 * BeaconTex.VSize);
	C.DrawTile(BeaconTex,
		0.25 * BeaconTex.USize,
		0.25 * BeaconTex.VSize,
		0.0,
		0.0,
		BeaconTex.USize,
		BeaconTex.VSize);
}

simulated static function DrawMapImage( Canvas C, Material Image, float MapX, float MapY, float PlayerX, float PlayerY, vector Dimensions )
{
	local float MapScale, MapSize;
	local byte  SavedAlpha;

	if(Image == none || C == None)
		return;

	MapSize = Image.MaterialUSize();
	MapScale = MapSize / (Dimensions.Y * 2);

	SavedAlpha = C.DrawColor.A;

	C.DrawColor = default.WhiteColor;
	C.DrawColor.A = Dimensions.Z;

	C.SetPos( MapX - Dimensions.X, MapY - Dimensions.X );
	C.DrawTile( Image, Dimensions.X * 2.0, Dimensions.X * 2.0,
	           (PlayerX - Dimensions.Y) * MapScale + MapSize / 2.0,
			   (PlayerY - Dimensions.Y) * MapScale + MapSize / 2.0,
			   Dimensions.Y * 2 * MapScale, Dimensions.Y * 2 * MapScale );

	C.DrawColor.A = SavedAlpha;
}

simulated function DrawMoneyCount(Canvas C)
{
	local string MoneyAmount, CmdAmount;
	local float XL, YL;

    if(PawnOwner != none && PawnOwner.Controller != none && CommandController(PawnOwner.Controller) != none)
	    MoneyAmount = ("Money:" @ string(int(CommandController(PawnOwner.Controller).Money)));
    if(Level != none && Level.GRI != none && PawnOwner != none && PawnOwner.GetTeamNum() == 0)
	    CmdAmount = ("Commander Money:" @ string(int(CCReplicationInfo(Level.GRI).NODCommanderMoney)));
    else if(Level != none && Level.GRI != none && PawnOwner != none && PawnOwner.GetTeamNum() != 0)
	    CmdAmount = ("Commander Money:" @ string(int(CCReplicationInfo(Level.GRI).GDICommanderMoney)));

    C.Font = TextFont;
    C.FontScaleX = C.ClipX / 1024.f;
	C.FontScaleY = C.ClipY / 768.f;
    XL = FMax(XL + 9.f * C.FontScaleX, 135.f * C.FontScaleX);
    C.DrawColor = default.WhiteColor;

    C.TextSize(MoneyAmount, XL, YL);
    C.SetPos((C.ClipX * 0.5), C.ClipY * 0.9);
    C.DrawText(MoneyAmount);

    C.TextSize(CmdAmount, XL, YL);
    C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.85);
    C.DrawText(CmdAmount);
}

simulated function DrawCompass(Canvas C)
{
    local TexRotator PlayerIcon;
	local Actor A;
	local vector ViewLoc;
	local rotator ViewRot;

    PlayerIcon = TexRotator'CommandAndConquerTEX.RotCompass';
    if(PawnOwner != none && Vehicle(PawnOwner) != none)
    {
        Vehicle(PawnOwner).SpecialCalcView(A, ViewLoc, ViewRot);
        PlayerIcon.Rotation.Yaw = ViewRot.Yaw;
    }
    else if(PawnOwner != none)
	    PlayerIcon.Rotation.Yaw = PawnOwner.Rotation.Yaw;

    C.DrawColor = C.MakeColor(0,200,0);
    C.SetPos(0, (C.ClipY * 0.05));
    C.DrawTile(PlayerIcon, C.ClipX * 0.2, C.ClipX * 0.2, 128, 128, 384, 384);
}

simulated function DrawTeamCommander(Canvas C)
{
//	local string Commander;
//	local float XL, YL;
//
//    if(PawnOwner == none)
//        return;
//
//	if(PawnOwner.GetTeamNum() == 0 && CCReplicationInfo(Level.GRI).CommanderRED != none)
//        Commander = CCReplicationInfo(Level.GRI).CommanderREDName;
//    else if(CCReplicationInfo(Level.GRI).CommanderBLUE != none)
//        Commander = CCReplicationInfo(Level.GRI).CommanderBLUEName;
//    else
//        Commander = "**Position Empty**";
//
//    C.Font = TextFont;
//    C.FontScaleX = C.ClipX / 1024.f;
//	C.FontScaleY = C.ClipY / 768.f;
//    C.DrawColor = default.WhiteColor;
//    C.TextSize(Commander, XL, YL);
//    C.SetPos(C.FontScaleX, C.ClipY * 0.25);
//    C.DrawText("Team Commander:" @ Commander);
}

simulated function DrawEnemyName(Canvas C)
{
	local Actor HitActor, A;
	local BaseCharacterModifier BCM;
	local float Num, i;
	local vector HitLocation, HitNormal, ViewPos, ViewLoc;
    local rotator ViewRot;
    local byte bProtected;

	if(PlayerOwner == none || PawnOwner == none)
		return;

    if(Vehicle(PawnOwner) != none)
    {
        Vehicle(PawnOwner).SpecialCalcView(A, ViewLoc, ViewRot);
	    HitActor = PawnOwner.trace(HitLocation, HitNormal, ViewLoc+10000*vector(ViewRot), ViewLoc, true);
    }
    else
    {
	    ViewPos = PawnOwner.Location + PawnOwner.BaseEyeHeight * vect(0,0,1);
	    HitActor = PawnOwner.trace(HitLocation, HitNormal, ViewPos+10000*vector(PlayerOwner.Rotation), ViewPos, true);
	}

    if(HitActor != none && HitActor != PawnOwner)
    {
        if(CCBuildings(HitActor) != none)
            CCBuildings(HitActor).DrawReticleHud(C, self);
    	else if(MasterControlTerminal(HitActor) != none)
            MasterControlTerminal(HitActor).DrawReticleHud(C, self);
    	else if(TerminalSMActor(HitActor) != None)
            TerminalSMActor(HitActor).DrawReticleHud(C, self);
        else if(RemoteC4Proj(HitActor) != None)
            RemoteC4Proj(HitActor).DrawReticleHud(C, self);
        else if(TimedC4Proj(HitActor) != None)
            TimedC4Proj(HitActor).DrawReticleHud(C, self);
        else if(ProxyProjectile(HitActor) != None)
            ProxyProjectile(HitActor).DrawReticleHud(C, self);
    	else if(Vehicle(HitActor) != None && Vehicle(HitActor).Health > 0
        && (StealthTank(HitActor) != none && !StealthTank(HitActor).bInvis || StealthTank(HitActor) == none))
    	{
            Num = 0.25;
            CommandController(PlayerOwner).CheckIfProtected(Vehicle(HitActor), bProtected);
            if(!Vehicle(HitActor).bNonHumanControl && bProtected == 0 && Vehicle(HitActor).NumPassengers() == 0)
            {
                C.DrawColor = C.MakeColor(255,255,255);
                C.SetPos((C.ClipX * 0.44) - 32, (C.ClipY * 0.62));
                //C.DrawTileScaled(Material'CommandAndConquerTEX.NOD_LOGO', Num, Num);
            }
            else if(Vehicle(HitActor).Team == 0)
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

            if((bProtected == 1 && Vehicle(HitActor).Owner == PlayerOwner || bProtected == 0)
            && (PawnOwner.GetTeamNum() == Vehicle(HitActor).Team || !Vehicle(HitActor).bTeamLocked)
            && !PawnOwner.bIsCrouched && !Vehicle(HitActor).bNonHumanControl && (PawnOwner.Controller != None)
            && (Vehicle(HitActor).Driver == None) && (PawnOwner.DrivenVehicle == None) && PawnOwner.Controller.bIsPlayer)
            {
                C.DrawColor = C.MakeColor(0,255,0);
                C.SetPos((C.ClipX * 0.5) - C.ClipX * 0.04, (C.ClipY * 0.5)-(C.ClipY * (Num/2)) - (C.ClipY * 0.08)* 4);
                C.DrawTile(Material'CommandAndConquerTEX.ArrowMover', C.ClipX * 0.08, (C.ClipY * 0.08)* 4, 0, 0, Material'CommandAndConquerTEX.ArrowMover'.MaterialUSize(), Material'CommandAndConquerTEX.ArrowMover'.MaterialVSize());
            }

            if(!Vehicle(HitActor).bNonHumanControl && bProtected == 0 && Vehicle(HitActor).NumPassengers() == 0)
                C.DrawColor = C.MakeColor(255,255,255);
            else if(Vehicle(HitActor).Team != PawnOwner.GetTeamNum())
                C.DrawColor = C.MakeColor(255,0,0);
            else
                C.DrawColor = C.MakeColor(0,255,0);

            C.SetPos((C.ClipX * 0.5)-(C.ClipX * (Num/2)), (C.ClipY * 0.5)-(C.ClipY * (Num/2)));
            C.DrawTile(Material'CommandAndConquerTEX.Reticle', (C.ClipX * Num), (C.ClipY * Num), 0, 0, 256, 512);
            C.Font = TextFont;
            C.FontScaleX = C.ClipX / 1024.f;
        	C.FontScaleY = C.ClipY / 768.f;
            C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.62);
            C.DrawText(Vehicle(HitActor).VehicleNameString);
            C.DrawColor = C.MakeColor(255,255,0);
            C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.64);
            i = ((128 / Vehicle(HitActor).default.Health)*Vehicle(HitActor).Health);
            C.DrawTileClipped(Material'CommandAndConquerTEX.HealthBar', i, 16, 0, 0, i, 16);
    	}
   	    else if(xPawn(HitActor) != none && xPawn(HitActor).bInvis == false && xPawn(HitActor).Health > 0)
    	{
            Num = 0.25;
            if(xPawn(HitActor).GetTeamNum() == 0)
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

            if(xPawn(HitActor).GetTeamNum() != PawnOwner.GetTeamNum())
                C.DrawColor = C.MakeColor(255,0,0);
            else
                C.DrawColor = C.MakeColor(0,255,0);
            C.SetPos((C.ClipX * 0.5)-(C.ClipX * (Num/2)), (C.ClipY * 0.5)-(C.ClipY * (Num/2)));
            C.DrawTile(Material'CommandAndConquerTEX.Reticle', (C.ClipX * Num), (C.ClipY * Num), 0, 0, 256, 512);
            C.Font = TextFont;
            C.FontScaleX = C.ClipX / 1024.f;
        	C.FontScaleY = C.ClipY / 768.f;
            C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.62);

            BCM = BaseCharacterModifier(Pawn(HitActor).FindInventoryType(class'BaseCharacterModifier'));
            if(BCM == none)
            {
                foreach DynamicActors(class'BaseCharacterModifier', BCM)
                {
                    if(BCM.Instigator == HitActor || BCM.Owner == HitActor)
                        break;
                }
            }
            if(BCM != none)
                C.DrawText(BCM.ClassName);

            C.DrawColor = C.MakeColor(255,255,0);
            C.SetPos((C.ClipX * 0.45) - C.FontScaleX, C.ClipY * 0.64);
            i = (((128 / xPawn(HitActor).HealthMax)*xPawn(HitActor).Health) + ((128 / xPawn(HitActor).ShieldStrengthMax)*xPawn(HitActor).ShieldStrength)) / 2;
            C.DrawTileClipped(Material'CommandAndConquerTEX.HealthBar', i, 16, 0, 0, i, 16);
    	}
	}
}

simulated function DrawRadarMap(Canvas C, float CenterPosX, float CenterPosY, float RadarWidth)
{
	local float PawnIconSize, PlayerIconSize, CoreIconSize, MapScale, MapRadarWidth, Percent;
	local vector HUDLocation, CameraLoc;
	local plane SavedModulation;
	local rotator CameraRot;
	//local int i;
	local FinalBlend PlayerIcon;
	local Actor A, ViewActor;
	local Pawn P;
	local CCBuildings B;
	local RadarActor RActor;

    if(C == none || Level.RadarMapImage == none)
        return;

    foreach DynamicActors(class'RadarActor', RActor)
    {
        if(PlayerOwner != none && RActor.Team == PlayerOwner.GetTeamNum())
            break;
        RActor = none;
    }

    if(RActor == none || RActor != none && RActor.bActive == false)
        return;

//    ActorHudInfo.Remove(0, ActorHudInfo.Length);
//    CommandController(PlayerOwner).FindHudActorLocations();

	SavedModulation = C.ColorModulate;

	C.ColorModulate.X = 1;
	C.ColorModulate.Y = 1;
	C.ColorModulate.Z = 1;
	C.ColorModulate.W = 1;

	C.Style = ERenderStyle.STY_Alpha;

	MapRadarWidth = RadarWidth;
    if(PawnOwner != None)
    {
        MapCenter.X = 0.0;
        MapCenter.Y = 0.0;
    }
    else
        MapCenter = vect(0,0,0);

	HUDLocation.X = RadarWidth;
	HUDLocation.Y = RadarRange;
	HUDLocation.Z = RadarTrans;

	DrawMapImage(C, Level.RadarMapImage, CenterPosX, CenterPosY, MapCenter.X, MapCenter.Y, HUDLocation);

    CoreIconSize = IconScale * 16 * C.ClipX * HUDScale/1600;
	PawnIconSize = CoreIconSize * 0.5;
	PlayerIconSize = CoreIconSize * 1.5;
	MapScale = MapRadarWidth/RadarRange;

//    for(i=0;i<ActorHudInfo.Length;i++)
//    {
//        HUDLocation = ActorHudInfo[i].ALocation - MapCenter;
//        HUDLocation.Z = 0;
//        C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.25, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.25);
//
//        if(class<Pawn>(ActorHudInfo[i].AClass) != none)
//        {
//            if(ActorHudInfo[i].ATeam == 0)
//                C.DrawColor = C.MakeColor(255,0,0);
//            else
//                C.DrawColor = C.MakeColor(255,255,0);
//
//            if(ActorHudInfo[i].bNoDriver == True)
//                C.DrawColor = C.MakeColor(255,255,255);
//
//            if(class<Vehicle>(ActorHudInfo[i].AClass) != none)
//                C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.50, PlayerIconSize * 0.50, 0, 0, 32, 32);
//            else
//                C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.25, PlayerIconSize * 0.25, 0, 0, 32, 32);
//        }
//        else
//        {
//            Percent = (255 / class<CCBuildings>(ActorHudInfo[i].AClass).default.Health) * ActorHudInfo[i].AHealth;
//            if(ActorHudInfo[i].ATeam == 0)
//                C.DrawColor = C.MakeColor(Percent,0,0);
//            else
//                C.DrawColor = C.MakeColor(Percent,Percent,0);
//
//            C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.75, PlayerIconSize * 0.75, 0, 0, 32, 32);
//        }
//    }

//    foreach DynamicActors(class'CCBuildings', B)
//    {
//        if(PlayerOwner != none && B.Team == PlayerOwner.PlayerReplicationInfo.Team.TeamIndex)
//        {
//            HUDLocation = B.Location - MapCenter;
//            HUDLocation.Z = 0;
//            C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.25, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.25);
//
//            Percent = (255 / B.default.Health) * B.Health;
//            if(B.Team == 0)
//                C.DrawColor = C.MakeColor(Percent,0,0);
//            else
//                C.DrawColor = C.MakeColor(Percent,Percent,0);
//            C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.75, PlayerIconSize * 0.75, 0, 0, 32, 32);
//        }
//    }

    for(B=Class'CCBuildings'.Static.PickFirstBuilding(Level); B!=None; B=B.NextBuilding)
    {
        if(B != none && B.Health > 0)
        {
            HUDLocation = B.Location - MapCenter;
            HUDLocation.Z = 0;
            C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.25, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.25);

            Percent = (255 / B.default.Health) * B.Health;
            if(B.Team == 0)
                C.DrawColor = C.MakeColor(Percent,0,0);
            else
                C.DrawColor = C.MakeColor(Percent,Percent,0);
            C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.75, PlayerIconSize * 0.75, 0, 0, 32, 32);
        }
    }

    if(PlayerOwner != none)
    {
        PlayerOwner.PlayerCalcView(ViewActor, CameraLoc, CameraRot);
        foreach PlayerOwner.VisibleCollidingActors(class'Pawn', P, 25000, CameraLoc)
        {
            if(P.IsA('ASTurret_BallTurret') || P.IsA('ONSWeaponPawn') || P == PawnOwner || P == PlayerOwner.Pawn || P == PlayerOwner || P == none)
                 continue;
            else if(P.Health > 0)
            {
                HUDLocation = P.Location - MapCenter;
                HUDLocation.Z = 0;

                if(P != none && P.IsA('Vehicle')
                && (P.GetTeamNum() == PlayerOwner.GetTeamNum() || StealthTank(P) != none
                && !StealthTank(P).bInvis || StealthTank(P) == none))
                {
                    if(Vehicle(P).bDriving == false)
                        C.DrawColor = C.MakeColor(255,255,255);
                    else if(Vehicle(P).Team == 0)
                        C.DrawColor = C.MakeColor(255,0,0);
                    else
                        C.DrawColor = C.MakeColor(255,255,0);
                    C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.5, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.5);
                    C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.5, PlayerIconSize * 0.5, 0, 0, 32, 32);
                }
                else if(xPawn(P) != none && !xPawn(P).bInvis)
                {
                    if(P.GetTeamNum() == 0)
                        C.DrawColor = C.MakeColor(255,0,0);
                    else
                        C.DrawColor = C.MakeColor(255,255,0);
                    C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5 * 0.25, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5 * 0.25);
                    C.DrawTile(Material'NewHUDIcons', PlayerIconSize * 0.25, PlayerIconSize * 0.25, 0, 0, 32, 32);
                }
            }
        }
    }

    if (PawnOwner != None)
    	A = PawnOwner;
    else if (PlayerOwner.IsInState('Spectating'))
        A = PlayerOwner;
    else if (PlayerOwner.Pawn != None)
    	A = PlayerOwner.Pawn;

    if(A != none)
    {
        CoreIconSize = IconScale * 16 * C.ClipX * HUDScale/1600;
    	PawnIconSize = CoreIconSize * 0.5;
    	PlayerIconSize = CoreIconSize * 1.5;
    	MapScale = MapRadarWidth/RadarRange;
        PlayerIcon = FinalBlend'CurrentPlayerIconFinal';
    	TexRotator(PlayerIcon.Material).Rotation.Yaw = -A.Rotation.Yaw - 16384;
        HUDLocation = A.Location - MapCenter;
        HUDLocation.Z = 0;
    	if(HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
    	{
        	C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5);
            C.DrawColor = C.MakeColor(40,255,40);
            C.DrawTile(PlayerIcon, PlayerIconSize, PlayerIconSize, 0, 0, 64, 64);
        }
    }

    if(PlayerOwner != none && CommandController(PlayerOwner).OrderLocation != vect(0,0,0))
    {
        CoreIconSize = IconScale * 16 * C.ClipX * HUDScale/1600;
    	PawnIconSize = CoreIconSize * 0.5;
    	PlayerIconSize = CoreIconSize * 1.5;
    	MapScale = MapRadarWidth/RadarRange;
        HUDLocation = CommandController(PlayerOwner).OrderLocation - MapCenter;
        HUDLocation.Z = 0;
    	if(HUDLocation.X < (RadarRange * 0.95) && HUDLocation.Y < (RadarRange * 0.95))
    	{
        	C.SetPos(CenterPosX + HUDLocation.X * MapScale - PlayerIconSize * 0.5, CenterPosY + HUDLocation.Y * MapScale - PlayerIconSize * 0.5);
            C.DrawColor = C.MakeColor(255,0,0);
            C.DrawTile(Texture'X_CliffTest.CB-EvilAMMO', PlayerIconSize, PlayerIconSize, 0, 0, 128, 128);
        }
    }

//    if(Level.RadarMapImage != none)
//    {
//        C.DrawColor = C.MakeColor(200,200,200);
//    	C.SetPos(CenterPosX - RadarWidth, CenterPosY - RadarWidth);
//    	C.DrawTile(BorderMat,
//                   RadarWidth * 2.0,
//                   RadarWidth * 2.0,
//                   0,
//                   0,
//                   256,
//                   256);
//
//        C.ColorModulate = SavedModulation;
//    }
}

//simulated function DrawRoute()
//{
//	local HarvesterController C;
//	local int i;
//	local vector OldPos;
//	local NavigationPoint N;
//
//	For( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
//	{
//		For( i=0; i<N.PathList.Length; i++ )
//		{
//			if( N.PathList[i]!=None )
//			{
//				if( N.PathList[i].ReachFlags==1 )
//					Draw3DLine(N.PathList[i].Start.Location+vect(0,0,25), N.PathList[i].End.Location-vect(0,0,25), class'Canvas'.Static.MakeColor(0,100,0));
//				else if( N.PathList[i].ReachFlags==128 )
//					Draw3DLine(N.PathList[i].Start.Location+vect(0,0,25), N.PathList[i].End.Location-vect(0,0,25), class'Canvas'.Static.MakeColor(100,0,0));
//			}
//		}
//	}
//	C = HarvesterController(Pawn(PlayerOwner.ViewTarget).Controller);
//	if ( C == None )
//	{
//		Super.DrawRoute();
//		return;
//	}
//	if( C.MoveTarget!=None )
//	{
//		OldPos = C.MoveTarget.Location;
//		Draw3DLine(C.Pawn.Location, C.MoveTarget.Location, class'Canvas'.Static.MakeColor(255,0,255));
//	}
//	else if( C.Destination!=vect(0,0,0) )
//	{
//		OldPos = C.Destination;
//		Draw3DLine(C.Pawn.Location, C.Destination, class'Canvas'.Static.MakeColor(255,0,0));
//	}
//	For( i=0; i<16; i++ )
//	{
//		if( C.RouteCache[i]!=None && C.RouteCache[i]!=C.MoveTarget )
//		{
//			Draw3DLine(OldPos, C.RouteCache[i].Location, class'Canvas'.Static.MakeColor(0,255,0));
//			OldPos = C.RouteCache[i].Location;
//		}
//	}
//	if( C.TibCrystal!=None )
//		Draw3DLine(C.Pawn.Location, C.TibCrystal.Location, class'Canvas'.Static.MakeColor(0,0,220));
//	if( C.BestTarRef!=None )
//		Draw3DLine(C.Pawn.Location, C.BestTarRef.Location, class'Canvas'.Static.MakeColor(150,150,150));
//}

defaultproperties
{
     RadarScale=0.200000
     RadarTrans=255.000000
     IconScale=1.000000
     RadarPosX=1.000000
     RadarPosY=0.100000
     MouseCursor=Texture'InterfaceContent.Menu.MouseCursor'
     RadarMaxRange=500000.000000
     BorderMat=Texture'ONSInterface-TX.MapBorderTEX'
     TeamSymbols(1)=(Tints[0]=(B=0,G=200,R=200,A=255),Tints[1]=(B=0,R=200))
     HudColorBlue=(B=0,G=200,R=200)
     HudColorTeam(1)=(B=0,G=200,R=200)
}
