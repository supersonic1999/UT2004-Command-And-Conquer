class Smoke extends Emitter;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitter0
         UseColorScale=True
         FadeOut=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         UseRandomSubdivision=True
         Acceleration=(Z=200.000000)
         FadeOutStartTime=4.000000
         MaxParticles=25
         StartLocationShape=PTLS_Sphere
         SphereRadiusRange=(Min=12.000000,Max=12.000000)
         RotationOffset=(Yaw=-16384)
         SpinsPerSecondRange=(X=(Max=0.100000))
         StartSpinRange=(X=(Max=1.000000))
         StartSizeRange=(X=(Min=200.000000,Max=200.000000))
         InitialParticlesPerSecond=500.000000
         DrawStyle=PTDS_AlphaBlend
         Texture=Texture'ExplosionTex.Framed.SmokeReOrdered'
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         LifetimeRange=(Min=4.500000,Max=5.000000)
     End Object
     Emitters(0)=SpriteEmitter'commandandconquer.Smoke.SpriteEmitter0'

     bNoDelete=False
}
