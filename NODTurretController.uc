class NODTurretController extends TurretController;

//auto state Searching
//{
//Begin:
//	ScanRotation();
//	FocalPoint = Pawn.Location + 1000 * vector(DesiredRotation);
//	FocalPoint.Z = Pawn.Location.Z;
//	Sleep(2 + 3*FRand());
//	Goto('Begin');
//}
//
//state Engaged
//{
//	function EnemyNotVisible()
//	{
//		if ( IsTargetRelevant( Enemy ) )
//		{
//			Focus = None;
//			FocalPoint = LastSeenPos;
//			FocalPoint.Z = Location.Z;
//			GotoState('WaitForTarget');
//			return;
//		}
//		GotoState('Searching');
//	}
//
//	function BeginState()
//	{
//		Focus = None;
//		Target = Enemy;
//		bFire = 1;
//		if ( Pawn.Weapon != None )
//			Pawn.Weapon.BotFire(false);
//	}
//
//Begin:
//	FocalPoint = Enemy.GetAimTarget().Location;
//	FocalPoint.Z = Pawn.Location.Z;
//	Sleep(0.2);
//	if ( !IsTargetRelevant( Enemy ) || !IsTurretFiring() )
//		GotoState('Searching');
//	Goto('Begin');
//}
//
//defaultproperties
//{
//	RotationRate=(Pitch=0,Yaw=1000,Roll=0)
//}

defaultproperties
{
}
