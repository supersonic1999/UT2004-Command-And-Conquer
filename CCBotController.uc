class CCBotController extends xBot;

state CommandControl
{
	function bool DoWaitForLanding();
	function bool TryToDuck(vector duckDir, bool bReversed);
    function DoTacticalMove();
	function Startle(Actor Feared);
	function SetAttractionState();
	function VehicleFightEnemy(bool bCanCharge, float EnemyStrength);
	function FightEnemy(bool bCanCharge, float EnemyStrength);
	function DoRangedAttackOn(Actor A);
	function ChooseAttackMode();
	function ClearPathFor(Controller C);
	function DirectedWander(vector WanderDir);
	function ReceiveWarning(Pawn shooter, float projSpeed, vector FireDir);
	function WanderOrCamp(bool bMayCrouch);
	function DoStakeOut();
	function DoCharge();
	function DoRetreat();

    function SeePlayer(Pawn SeenPlayer)
	{
		if(SeenPlayer == Enemy)
		{
			FireWeaponAt(SeenPlayer);
            VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			BlockedPath = None;
			Focus = Enemy;
			WhatToDoNext(22);
		}
		else
			Global.SeePlayer(SeenPlayer);
	}

	function Timer()
	{
		SetCombatTimer();
		StopFiring();
	}

	function CheckNearVehicle()
	{
        local Vehicle V;

        for(V=Level.Game.VehicleList;V!=none;V=V.NextVehicle)
            if(VSize(Pawn.Location-V.Location) <= V.CollisionRadius && V.Driver == none && V.TryToDrive(Pawn))
                break;
	}

	function BeginState()
	{
		if(Pawn != none)
            Pawn.bWantsToCrouch = false;
	}
Begin:
    CheckNearVehicle();
	if(VSize(Pawn.Location-Destination) >= 100 && Destination != Vect(0,0,0))
        MoveTo(Destination);
	if(CanSee(Enemy))
		SeePlayer(Enemy);
	Sleep(0.1);
	goto('Begin');
}

simulated function MouseOverMe(HudCommandAndConquer myHud);

simulated function ClickMouseOverMe(HudCommandAndConquer myHud);

defaultproperties
{
     PlayerReplicationInfoClass=Class'commandandconquer.CCPlayerReplicationInfo'
     InitialState="CommandControl"
}
