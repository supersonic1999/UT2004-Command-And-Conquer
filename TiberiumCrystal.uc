class TiberiumCrystal extends StaticMeshActor
    Placeable;

var() int Tiberium;
var bool bInitialCrystal;
var TiberiumTreeSpawn TreeSpawner;
var TiberiumCrystal CrystalList,NextCrystal;

function PostBeginPlay()
{
	if(Level.NetMode == NM_Client)
	    Return;

    bInitialCrystal = Level.bStartUp;

    if(bInitialCrystal)
        RemoteRole = ROLE_SimulatedProxy;
    else
        RemoteRole = ROLE_None;

	Class'TiberiumCrystal'.Static.ListCrystal(Self);
	SetTimer(0.5, True);
}

function Timer()
{
    local TiberiumHurtINV HurtINV;
    local Controller C;
    local TiberiumCrystal V;

	CheckCrystalStatus();

	if(bDeleteMe)
        Return;

    if(bInitialCrystal && TreeSpawner == none)
    {
        bInitialCrystal = False;
        TreeSpawner = Spawn(Class'FAKETiberiumTreeSpawn',,,Location+vect(0,0,32));
        FAKETiberiumTreeSpawn(TreeSpawner).AddCrystal(Self);
        for(V=Class'TiberiumCrystal'.Static.PickFirstCrystal(Level); V!=None; V=V.NextCrystal)
        {
            if(V.TreeSpawner == none && V.bInitialCrystal && VSize(V.Location-Location) < 1024 && FastTrace(Location+vect(0,0,34),V.Location+vect(0,0,34)))
            {
                V.TreeSpawner = TreeSpawner;
                FAKETiberiumTreeSpawn(TreeSpawner).AddCrystal(V);
                V.bInitialCrystal = False;
            }
        }
    }

    for(C=Level.ControllerList; C!=None; C=C.NextController)
    {
        if(C.Pawn != none && VSize(C.Pawn.Location-Location) < 512 && !C.Pawn.IsA('Vehicle') && C.Pawn.Health > 0)
        {
            HurtINV = TiberiumHurtINV(C.Pawn.FindInventoryType(class'TiberiumHurtINV'));
            if(HurtINV == none)
            {
                HurtINV = Spawn(class'TiberiumHurtINV', C.Pawn);
                HurtINV.GiveTo(C.Pawn);
            }
            else
                HurtINV.TimeIn = Level.TimeSeconds;
        }
    }

    super.Timer();
}

function CheckCrystalStatus()
{
	if(Tiberium <= 0)
		Destroy();
}

function Destroyed()
{
	if(Level.NetMode == NM_Client)
		Return;

	Class'TiberiumCrystal'.Static.FlushFromList(Self);
	if(TreeSpawner != none)
		TreeSpawner.RemoveCrystal(self);
	super.Destroyed();
}

static function ListCrystal( TiberiumCrystal Other )
{
	if(Default.CrystalList != none && Default.CrystalList.Level != Other.Level)
		Default.CrystalList = Other;
	else
	{
		Other.NextCrystal = Default.CrystalList;
		Default.CrystalList = Other;
	}
}

// Remove from buildings list
static function FlushFromList( TiberiumCrystal Other )
{
	local TiberiumCrystal C;

	if( Default.CrystalList==None )
		Return; // Already cleared
	else if( Default.CrystalList==Other )
		Default.CrystalList = Other.NextCrystal;
	else
	{
		For( C=Default.CrystalList; C!=None; C=C.NextCrystal )
		{
			if( C.NextCrystal==Other )
			{
				C.NextCrystal = Other.NextCrystal;
				Return;
			}
		}
	}
}

static function TiberiumCrystal PickFirstCrystal( LevelInfo Other )
{
	if( Other==None )
		Return Default.CrystalList;
	if( Default.CrystalList!=None && Default.CrystalList.Level==Other )
		Return Default.CrystalList;
	Default.CrystalList = None;
	Return None;
}

defaultproperties
{
     Tiberium=50
     StaticMesh=StaticMesh'CommandAndConquerSM.Tiberium.Crystal1'
     bStatic=False
     bWorldGeometry=False
     RemoteRole=ROLE_None
     CollisionRadius=512.000000
     CollisionHeight=32.000000
     bCollideActors=False
     bBlockActors=False
}
