class TiberiumActor extends ReplicationInfo
    placeable;

var() byte Team;
var() float GiveMoneyTime;
var bool bActive;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
        Team,bActive;
}

function PostBeginPlay()
{
    if(Level.NetMode != NM_Client && GiveMoneyTime > 0)
        SetTimer(GiveMoneyTime, True);
    super.PostBeginPlay();
}

function Timer()
{
    local Controller C;

    if(ROLE == ROLE_Authority)
    {
    	for(C=Level.ControllerList; C!=None; C=C.NextController)
    	{
    		if(CommandController(C) != none && C.GetTeamNum() == Team)
    			CommandController(C).GiveMoney(2);
    	}
	}
    super.Timer();
}

defaultproperties
{
     GiveMoneyTime=1.000000
     bActive=True
}
