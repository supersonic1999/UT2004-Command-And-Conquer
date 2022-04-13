class CCPlayerReplicationInfo extends PlayerReplicationInfo;

var BaseCharacterModifier BCM;

replication
{
	reliable if(bNetDirty && Role==ROLE_Authority)
		BCM;
}

defaultproperties
{
}
