class Pistol extends Weapon
    config(user);

var AssaultAttachment OffhandActor;
var bool bFireLeft;

#EXEC OBJ LOAD FILE=InterfaceContent.utx
#EXEC OBJ LOAD FILE=UT2004Weapons.utx

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if ( (Role < ROLE_Authority) && (Instigator != None) && (Instigator.Controller != None) && (Instigator.Weapon != self) && (Instigator.PendingWeapon != self) )
		Instigator.Controller.ClientSwitchToBestWeapon();
}

simulated function DetachFromPawn(Pawn P)
{
	bFireLeft = false;
	Super.DetachFromPawn(P);
	if ( OffhandActor != None )
	{
		OffhandActor.Destroy();
		OffhandActor = None;
	}
}

function AttachToPawn(Pawn P)
{
	local name BoneName;

	if ( ThirdPersonActor == None )
	{
		ThirdPersonActor = Spawn(AttachmentClass,Owner);
		InventoryAttachment(ThirdPersonActor).InitFor(self);
	}
	BoneName = P.GetWeaponBoneFor(self);
	if ( BoneName == '' )
	{
		ThirdPersonActor.SetLocation(P.Location);
		ThirdPersonActor.SetBase(P);
	}
	else
		P.AttachToBone(ThirdPersonActor,BoneName);
}

function byte BestMode()
{
	local Bot B;

	B = Bot(Instigator.Controller);
    if ( AmmoAmount(0) >= FireMode[0].AmmoPerFire )
		return 0;
	return 1;
}

function bool HandlePickupQuery( pickup Item )
{
	if ( class == Item.InventoryType )
    {
		if ( Instigator.Weapon == self )
		{
			PlayOwnedSound(SelectSound, SLOT_Interact,,,,, false);
			AttachToPawn(Instigator);
		}
		if (Level.GRI.WeaponBerserk > 1.0)
			CheckSuperBerserk();
		else
			FireMode[0].FireRate = FireMode[0].Default.FireRate *  0.55;

		FireMode[0].Spread = FireMode[0].Default.Spread * 1.5;
		if (xPawn(Instigator) != None && xPawn(Instigator).bBerserk)
			StartBerserk();

		return false;
    }
	if ( item.inventorytype == AmmoClass[1] )
	{
		if ( (AmmoCharge[1] >= MaxAmmo(1)) && (AmmoCharge[0] >= MaxAmmo(0)) )
			return true;
		item.AnnouncePickup(Pawn(Owner));
		AddAmmo(50, 0);
		AddAmmo(Ammo(item).AmmoAmount, 1);
		item.SetRespawn();
		return true;
	}

    if ( Inventory == None )
		return false;

	return Inventory.HandlePickupQuery(Item);
}

simulated function int MaxAmmo(int mode)
{
	return FireMode[mode].AmmoClass.Default.MaxAmmo;
}

function float GetAIRating()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( B == None )
		return AIRating;

	if ( B.Enemy == None )
	{
		if ( (B.Target != None) && VSize(B.Target.Location - B.Pawn.Location) > 8000 )
			return 0.78;
		return AIRating;
	}

	return (AIRating + 0.0003 * FClamp(1500 - VSize(B.Enemy.Location - Instigator.Location),0,1000));
}

defaultproperties
{
     FireModeClass(0)=Class'commandandconquer.PistolFire'
     FireModeClass(1)=Class'commandandconquer.PistolFire'
     PutDownAnim="PutDown"
     SelectSound=Sound'WeaponSounds.AssaultRifle.SwitchToAssaultRifle'
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.100000
     CurrentRating=0.400000
     bCanThrow=False
     OldMesh=SkeletalMesh'Weapons.AssaultRifle_1st'
     OldPickup="WeaponStaticMesh.AssaultRiflePickup"
     OldCenteredOffsetY=0.000000
     OldPlayerViewOffset=(X=-8.000000,Y=5.000000,Z=-6.000000)
     OldSmallViewOffset=(X=4.000000,Y=11.000000,Z=-12.000000)
     OldPlayerViewPivot=(Pitch=400)
     OldCenteredRoll=3000
     Description="Inexpensive and easily produced, the AR770 provides a lightweight 5.56mm combat solution that is most effective against unarmored foes. With low-to-moderate armor penetration capabilities, this rifle is best suited to a role as a light support weapon.|The optional M355 Grenade Launcher provides the punch that makes this weapon effective against heavily armored enemies.  Pick up a second assault rifle to double your fire power."
     EffectOffset=(X=100.000000,Y=25.000000,Z=-10.000000)
     DisplayFOV=70.000000
     Priority=3
     HudColor=(B=192,G=128)
     SmallViewOffset=(X=13.000000,Y=12.000000,Z=-10.000000)
     CenteredOffsetY=-5.000000
     CenteredRoll=3000
     CenteredYaw=-1500
     CustomCrosshair=4
     CustomCrossHairScale=0.666700
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Cross5"
     PickupClass=Class'XWeapons.AssaultRiflePickup'
     PlayerViewOffset=(X=4.000000,Y=5.500000,Z=-6.000000)
     PlayerViewPivot=(Pitch=400)
     BobDamping=1.700000
     AttachmentClass=Class'commandandconquer.PistolAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X1=245,Y1=39,X2=329,Y2=79)
     ItemName="Automatic Pistol"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=255.000000
     LightRadius=4.000000
     LightPeriod=3
     Mesh=SkeletalMesh'NewWeapons2004.AssaultRifle'
     DrawScale=0.800000
     HighDetailOverlay=Combiner'UT2004Weapons.WeaponSpecMap2'
}
