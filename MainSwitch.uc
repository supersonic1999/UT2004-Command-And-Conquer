class MainSwitch extends UseTrigger;

function UsedBy( Pawn user )
{
    local CCINV Inv;

    if(User != none && User.Instigator != none && User.Instigator.Controller != none && PlayerController(User.Instigator.Controller) != none)
    {
        if(User.Instigator.GetTeamNum() == TerminalSMActor(Owner).Team)
        {
            Inv = CCINV(user.FindInventoryType(class'CCINV'));
            if(Inv == None)
            {
            	Inv = user.spawn(class'CCINV', user,,, rot(0,0,0));
            	if(Inv != None)
            	{
            		Inv.giveTo(user);
            		if(CCGameType(Level.Game) != none)
            		    Inv.VMax = CCGameType(Level.Game).MaxVehicles;
            	}
            }
            PlayerController(User.Instigator.Controller).ClientOpenMenu("CommandAndConquer.Terminals");
        }
        else
        {
           PlayerController(User.Instigator.Controller).ClientPlaySound(sound'MenuSounds.Denied1');
           PlayerController(User.Instigator.Controller).ClientMessage("Insufficient Access");
        }
    }
}

defaultproperties
{
     CollisionRadius=128.000000
     CollisionHeight=256.000000
}
