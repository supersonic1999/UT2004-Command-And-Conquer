class FAKETiberiumTreeSpawn extends TiberiumTreeSpawn
    NotPlaceable;

function PostBeginPlay()
{
	local NavigationPoint N,BN;
	local float D,BD;

	For(N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint)
	{
		if(N.PathList.Length>0 && N.Region.Zone == Region.Zone)
		{
			D = VSize(N.Location-Location);
			if(BN == None || D < BD )
			{
				BD = D;
				BN = N;
			}
		}
	}
	ClosestNode = BN;
}

function Timer();

function RemoveCrystal(TiberiumCrystal Crystal)
{
	Super.RemoveCrystal(Crystal);
	if( SpawnedTiberium.Length<=0 )
		Destroy();
}

function AddCrystal( TiberiumCrystal Crystal )
{
	local int i;

	i = SpawnedTiberium.Length;
	SpawnedTiberium.Length = i+1;
	SpawnedTiberium[i] = Crystal;
}

function SpawnTiberiumCrystal();

simulated function TiberiumCrystal GenerateACrystal();

simulated function PostNetReceive();

defaultproperties
{
     StaticMesh=None
     bHidden=True
     bAlwaysRelevant=False
     RemoteRole=ROLE_None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bCollideActors=False
     bBlockActors=False
     bBlockKarma=False
     bNetNotify=False
}
