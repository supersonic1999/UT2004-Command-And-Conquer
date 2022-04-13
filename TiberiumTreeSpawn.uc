class TiberiumTreeSpawn extends StaticMeshActor
    Placeable;

var array<TiberiumCrystal> SpawnedTiberium;
var() int SpawnRadius, RespawnTime;
var() int MaxTibSpawnable;
var() bool bFullySpawned, bRespawnTib;
var NavigationPoint ClosestNode;
var byte ClientNumCrystals,OlClientCrystals;

replication
{
	reliable if( bNetDirty && Role==ROLE_Authority )
		ClientNumCrystals;
}

function PostBeginPlay()
{
	local NavigationPoint N,BN;
	local float D,BD;

	SetTimer(RespawnTime/2+FRand()*RespawnTime,False);
	if(MaxTibSpawnable == Default.MaxTibSpawnable)
		MaxTibSpawnable = 20+Rand(8);
	super.PostBeginPlay();

	if(bFullySpawned)
		while(SpawnedTiberium.length < MaxTibSpawnable)
			SpawnTiberiumCrystal();

	For(N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint)
	{
		if( N.PathList.Length>0 && N.Region.Zone==Region.Zone )
		{
            D = VSize(N.Location-Location);
    		if( BN==None || D<BD )
    		{
    			BD = D;
    			BN = N;
    		}
		}
	}
	ClosestNode = BN;
}

function Timer()
{
	SpawnTiberiumCrystal();
	SetTimer(RespawnTime/2+FRand()*RespawnTime,False);
}

function RemoveCrystal(TiberiumCrystal Crystal)
{
	local int i;

	if(Crystal != none)
		for(i=0;i<SpawnedTiberium.length;i++)
			if(SpawnedTiberium[i] == Crystal)
				SpawnedTiberium.Remove(i, 1);
}

function SpawnTiberiumCrystal()
{
	if(bRespawnTib && SpawnedTiberium.Length < MaxTibSpawnable)
		GenerateACrystal();
	ClientNumCrystals = SpawnedTiberium.Length;
}

simulated function TiberiumCrystal GenerateACrystal()
{
	local vector SpawnRadLoc, HitLocation, HitNormal, EndTrace;
	local TiberiumCrystal Crystal;
	local Actor Other;

	SpawnRadLoc.X = Location.X + FRand()*SpawnRadius-SpawnRadius/2;
	SpawnRadLoc.Y = Location.Y + FRand()*SpawnRadius-SpawnRadius/2;
	SpawnRadLoc.Z = Location.Z + 500;
	EndTrace = SpawnRadLoc - vect(0,0,2000);
	Other = Trace(HitLocation, HitNormal, EndTrace, SpawnRadLoc, False);
	if( Other==None )
		Return None;
	Crystal = Spawn(class'TiberiumCrystal', self,, HitLocation);
	if( Crystal==None )
		Return None;
	Crystal.TreeSpawner = self;
	SpawnedTiberium.Length = SpawnedTiberium.Length+1;
	SpawnedTiberium[SpawnedTiberium.Length-1] = Crystal;
	Return Crystal;
}

simulated function Destroyed()
{
	while(SpawnedTiberium.length > 0)
	{
		SpawnedTiberium[0].Destroy();
		SpawnedTiberium.remove(0, 1);
	}
	super.Destroyed();
}

function TiberiumCrystal PickOutTiberium()
{
	Return SpawnedTiberium[Rand(SpawnedTiberium.Length)];
}

function float GetFieldPriority( vector SeekingPosition )
{
	local float F;
	local int i;

	i = GetFieldNetWorth();
	F = (float(i)+10000)/VSize(Location-SeekingPosition);
	if( i<1500 )
		F/=3;
	Return F;
}

function bool HasResources()
{
	return (SpawnedTiberium.Length>0);
}

function int GetFieldNetWorth()
{
	local int i,c;

	c = 0;
	For( i=ClientNumCrystals; i<SpawnedTiberium.Length; i++ )
	{
		if( SpawnedTiberium[i]!=None )
			c+=(SpawnedTiberium[i].Tiberium+1);
	}
	Return c;
}

simulated function PostNetReceive()
{
	local int i;

	if( OlClientCrystals==ClientNumCrystals )
		Return;
	OlClientCrystals = ClientNumCrystals;
	if( ClientNumCrystals<SpawnedTiberium.Length )
	{
		For( i=ClientNumCrystals; i<SpawnedTiberium.Length; i++ )
		{
			if( SpawnedTiberium[i]!=None )
				SpawnedTiberium[i].Destroy();
		}
		SpawnedTiberium.Length = ClientNumCrystals;
	}
	else
	{
		While( SpawnedTiberium.Length<ClientNumCrystals )
		{
			GenerateACrystal();
			i++;
			if( i>=30 )
				Return;
		}
	}
}

defaultproperties
{
     SpawnRadius=2000
     RespawnTime=30
     MaxTibSpawnable=25
     bFullySpawned=True
     bRespawnTib=True
     StaticMesh=StaticMesh'CommandAndConquerSM.Tiberium.TibTree'
     bStatic=False
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     Skins(0)=Texture'Albatross_architecture.trim.advwood'
     bNetNotify=True
}
