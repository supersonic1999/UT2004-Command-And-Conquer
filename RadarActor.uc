class RadarActor extends ReplicationInfo
    placeable;

var() byte Team;
var bool bActive;

replication
{
    reliable if(bNetDirty && Role==ROLE_Authority)
        Team,bActive;
}

defaultproperties
{
}
