//=============================================================================
// AdvExecute.
// Coded by .:..:
// *Note*: This is REALLY hard to compile, so dont even think about recompiling it. Just use the functions.
// Warning: Only advanced coders should attempt to try use these functions.
//=============================================================================
class AdvExecute extends Object;

// Add a desired navigationpoint to levelinfo's navigationpointlist
Static function AddToNavigationList( NavigationPoint Other )
{
	Other.NextNavigationPoint = Other.Level.NavigationPointList;
	Other.Level.NavigationPointList = Other;
}

// Remove a desired navigationpoint from level's navigationpointlist
Static function RemoveFromNavigationList( NavigationPoint Other )
{
	local NavigationPoint N;

	if( Other.Level.NavigationPointList==Other )
	{
		Other.Level.NavigationPointList = Other.NextNavigationPoint;
		Return;
	}
	For( N=Other.Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		if( N.NextNavigationPoint==Other )
		{
			N.NextNavigationPoint = Other.NextNavigationPoint;
			Return;
		}
	}
}

// Bind 2 navigationpoints with reachspecs for AI navigation
// Reach flags:
/*
	R_WALK = 1	walking required
	R_FLY = 2 flying required 
	R_SWIM = 4 swimming required
	R_JUMP = 8 jumping required
	R_DOOR = 16 door between paths
	R_SPECIAL = 32 something special required (elevator etc..)
	R_LADDER = 64 ladder path
	R_PROSCRIBED = 128 ?
	R_FORCED = 256 ?
	R_PLAYERONLY = 512 Only for players
*/
Static function DefinePaths( NavigationPoint A, NavigationPoint B, int FlagsA, int FlagsB, int ColH, int ColR )
{
	local ReachSpec RS;
	local int D,i;

	// Make Reachspec A -> B
	RS = New(None)Class'ReachSpec';
	RS.Start = A;
	RS.End = B;
	RS.ReachFlags = FlagsA;
	D = VSize(A.Location-B.Location);
	RS.Distance = D;
	RS.CollisionRadius = ColR;
	RS.CollisionHeight = ColH;
	i = A.PathList.Length;
	A.PathList.Length = i+1;
	A.PathList[i] = RS;

	// Make reachspec B -> A
	RS = New(None)Class'ReachSpec';
	RS.Start = B;
	RS.End = A;
	RS.ReachFlags = FlagsB;
	RS.Distance = D;
	RS.CollisionRadius = ColR;
	RS.CollisionHeight = ColH;
	i = B.PathList.Length;
	B.PathList.Length = i+1;
	B.PathList[i] = RS;
	// Done!
}

// Unbind a navigationpoint from AI path
Static function UnbindNavigationPoint( NavigationPoint Other )
{
	local NavigationPoint N;
	local int i,j;

	For( N=Other.Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		j = N.PathList.Length;
		if( N==Other )
		{
			For( i=0; i<j; i++ )
			{
				if( N.PathList[i]!=None )
				{
					N.PathList[i].Start = None;
					N.PathList[i].End = None;
					N.PathList[i] = None;
				}
			}
		}
		else
		{
			For( i=0; i<j; i++ )
			{
				if( N.PathList[i]!=None && N.PathList[i].End==Other )
				{
					if( i==(j-1) )
					{
						N.PathList[i] = None;
						N.PathList.Length = j-1;
					}
					else
					{
						j--;
						N.PathList[i] = N.PathList[j];
						N.PathList.Length = j;
						i--;
					}
				}
			}
		}
	}
}

// Unbind a path just between 2 points
Static function UnbindPath( NavigationPoint A, NavigationPoint B )
{
	local int i,j;

	j = A.PathList.Length;
	For( i=0; i<j; i++ )
	{
		if( A.PathList[i]!=None && A.PathList[i].End==B )
		{
			j--;
			A.PathList[i] = A.PathList[j];
			A.PathList.Length = j;
			i--;
		}
	}
	j = B.PathList.Length;
	For( i=0; i<j; i++ )
	{
		if( B.PathList[i]!=None && B.PathList[i].End==B )
		{
			j--;
			B.PathList[i] = B.PathList[j];
			B.PathList.Length = j;
			i--;
		}
	}
}

// Bind actor with a brush
Static function BindWithBrush( Actor Other, Model MyBrush )
{
	Other.Brush = MyBrush;
}

defaultproperties
{
}
