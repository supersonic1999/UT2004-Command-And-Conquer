class AddedPathNode extends PathNode
	NotPlaceable;

#exec obj load file="Inc\AdvExecute.u" package="CommandAndConquer"

var NavigationPoint NN;

Auto State BuildPath
{
Begin:
	Class'AdvExecute'.Static.AddToNavigationList(Self);
	Sleep(0.1);
	For(NN=Level.NavigationPointList; NN!=None; NN=NN.NextNavigationPoint)
	{
		if(NN !=Self && VSize(NN.Location-Location) < 1000)
		{
			ScanPathBetween(Self,NN);
			Sleep(0.1);
		}
	}
	MaxPathSize = vect(120,120,120);
}

function Destroyed()
{
	Class'AdvExecute'.Static.UnbindNavigationPoint(Self);
	Class'AdvExecute'.Static.RemoveFromNavigationList(Self);
}

function ScanPathBetween(NavigationPoint A, NavigationPoint B)
{
	local XScout XX;

	XX = Spawn(class'XScout',,,A.Location);
	if(XX == None)
        Return;
	XX.ScanPoints(A,B);
}

defaultproperties
{
     bStatic=False
     bNoDelete=False
     RemoteRole=ROLE_None
     bMovable=False
     CollisionRadius=80.000000
}
