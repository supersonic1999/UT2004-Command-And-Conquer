class CCBot extends CCPawn;

function PostBeginPlay()
{
    local CCINV Inv;

    super.PostBeginPlay();

    Inv = CCINV(FindInventoryType(class'CCINV'));
	if(Inv == None)
	{
		Inv = spawn(class'CCINV', self,,, rot(0,0,0));
		if(Inv != none && Level.Game != none && CCGameType(Level.Game) != none)
		{
    		Inv.giveTo(self);
    		Inv.VMax = CCGameType(Level.Game).MaxVehicles;
		}
	}

	if(Inv != none)
        Inv.SetTimer(5.0, False);
}

function DoDoubleJump( bool bUpdating );

defaultproperties
{
     ControllerClass=Class'commandandconquer.CCBotController'
}
