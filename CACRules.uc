class CACRules extends GameRules;

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
    Momentum = Vect(0,0,0);

    if(injured == none || instigatedBy == none || injured.Controller == none || instigatedBy.Controller == none || instigatedBy == injured)
        return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

    if(DamageType == class'DamTypeRepairGun')
        Damage /= 2;

    Damage = FMin(Damage, injured.Health);

    if((HarvesterController(injured.Controller) != none && injured.Controller.GetTeamNum() == instigatedBy.GetTeamNum()) ||
	 (HarvesterController(instigatedBy.Controller) != none && injured.Controller.GetTeamNum() == instigatedBy.GetTeamNum()))
		Damage = 0;
    if(instigatedBy.PlayerReplicationInfo != none)
    {
        instigatedBy.PlayerReplicationInfo.Team.Score += Damage/4.f;
        instigatedBy.PlayerReplicationInfo.Score += Damage/4.f;
    }

    if(CommandController(instigatedBy.Controller) != none)
	    CommandController(instigatedBy.Controller).GiveMoney(Damage/10.f);
    return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
}

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	if(Killed == none || Killed.Weapon == none || Vehicle(Killed) != None)
		return super.PreventDeath(Killed, Killer, damageType, HitLocation);

	if(Killed.Controller != None)
		Killed.Controller.LastPawnWeapon = Killed.Weapon.Class;
    Killed.Weapon.DetachFromPawn(Killed);
    Killed.Weapon = None;
    return super.PreventDeath(Killed, Killer, damageType, HitLocation);
}

function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
    local NavigationPoint BestStart;
    local float BestRating, NewRating;
    local CCPlayerStart PS;
    local byte Team;

    if(Rand(10) <= 7 || super.FindPlayerStart(Player, InTeam, incomingName) == none)
    {
        if ( (Player != None) && (Player.PlayerReplicationInfo != None) )
        {
            if ( Player.PlayerReplicationInfo.Team != None )
                Team = Player.PlayerReplicationInfo.Team.TeamIndex;
            else
                Team = InTeam;
        }
        else
            Team = InTeam;

        foreach DynamicActors(class'CCPlayerStart', PS)
        {
            NewRating = Level.Game.RatePlayerStart(PS,Team,Player);
            if ( NewRating > BestRating )
            {
                BestRating = NewRating;
                BestStart = PS;
            }
        }

        if(BestStart != none)
            return BestStart;
    }
    else
        return super.FindPlayerStart(Player, InTeam, incomingName);
}

defaultproperties
{
}
