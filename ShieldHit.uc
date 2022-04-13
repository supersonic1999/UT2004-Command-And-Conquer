class ShieldHit extends ONSRocketScorch;

//#exec OBJ LOAD FILE=EpicParticles.utx
//
//defaultproperties
//{
//    Begin Object Class=MeshEmitter Name=MeshEmitter0
//        StaticMesh=StaticMesh'CommandAndConquerSM.Misc.Hit'
//        UseParticleColor=True
//        UseColorScale=True
//        ColorScale(1)=(RelativeTime=0.300000,Color=(B=56,G=137,R=197))
//        ColorScale(2)=(RelativeTime=0.600000,Color=(B=7,G=177,R=186))
//        ColorScale(3)=(RelativeTime=1.000000)
//        FadeOutStartTime=1.000000
//        FadeOut=True
//        FadeInEndTime=0.100000
//        FadeIn=True
//        MaxParticles=1
//        CoordinateSystem=PTCS_Relative
//        RespawnDeadParticles=False
//        StartSpinRange=(Y=(Max=1.000000),Z=(Max=1.000000))
//        UseSizeScale=True
//        UseRegularSizeScale=False
//        SizeScale(0)=(RelativeSize=0.200000)
//        SizeScale(1)=(RelativeTime=1.000000,RelativeSize=25.000000)
//        StartSizeRange=(X=(Min=0.025000,Max=0.025000),Y=(Min=0.025000,Max=0.025000),Z=(Min=0.010000,Max=0.010000))
//        InitialParticlesPerSecond=50000.000000
//        AutomaticInitialSpawning=False
//        Texture=Texture'CommandAndConquerTEX.Shield'
//        LifetimeRange=(Min=1.000000,Max=1.000000)
//        InitialDelayRange=(Min=1.000000,Max=1.000000)
//        SecondsBeforeInactive=0
//        Name="MeshEmitter0"
//    End Object
//    Emitters(0)=MeshEmitter'MeshEmitter0'
//
////    Begin Object Class=SpriteEmitter Name=SpriteEmitter4
////        UseColorScale=True
////        ColorScale(0)=(Color=(B=16,G=30,R=158))
////        ColorScale(1)=(RelativeTime=0.600000,Color=(B=64,G=174,R=255))
////        ColorScale(2)=(RelativeTime=0.800000,Color=(B=23,G=121,R=187))
////        ColorScale(3)=(RelativeTime=1.000000)
////        MaxParticles=2
////        RespawnDeadParticles=False
////        UseSizeScale=True
////        UseRegularSizeScale=False
////        SizeScale(0)=(RelativeSize=0.200000)
////        SizeScale(1)=(RelativeTime=0.800000,RelativeSize=10.000000)
////        SizeScale(2)=(RelativeTime=1.000000,RelativeSize=1.000000)
////        StartSizeRange=(X=(Min=100.000000,Max=100.000000))
////        UniformSize=True
////        InitialParticlesPerSecond=50000.000000
////        AutomaticInitialSpawning=False
////        Texture=Texture'EpicParticles.Flares.SoftFlare'
////        LifetimeRange=(Min=1.250000,Max=1.250000)
////        InitialDelayRange=(Min=0.800000,Max=0.800000)
////        SecondsBeforeInactive=0
////        Name="SpriteEmitter4"
////    End Object
////    Emitters(1)=SpriteEmitter'SpriteEmitter4'
//
//    AutoDestroy=True
//    Style=STY_Masked
//    bUnlit=true
//    bDirectional=True
//    bNoDelete=false
//    RemoteRole=ROLE_DumbProxy
//    bNetTemporary=true
//}

defaultproperties
{
     ProjTexture=Texture'CommandAndConquerTEX.Shield'
}
