
Class PlaneBehaviour Extends Behaviour

	Field plane_audio:Sound
	Field plane_audio_channel:Channel
	
	Field plane_mass:Float
	
	Field pitch_torque:Float
	Field roll_torque:Float
	Field yaw_torque:Float
	
	Field throttle:Float	= 1650000.0
	
	Method New (entity:Entity, mass:Float, pitch_rate:Float, roll_rate:Float, yaw_rate:Float)
		
		Super.New (entity)
		
		AddInstance ()

		plane_mass								= mass

		pitch_torque							= pitch_rate
		roll_torque								= roll_rate
		yaw_torque								= yaw_rate

		If Not plane_audio
			plane_audio = Sound.Load ("asset::audio/jet.ogg")
			plane_audio_channel = plane_audio.Play (True)
			plane_audio_channel.Volume = 0.5
			plane_audio_channel.Rate = plane_audio_channel.Rate * 0.05
		Endif
		
	End
	
	Method OnStart () Override

		Local plane_size:Float					= 16.83 * 0.5
		Local plane_box:Boxf					= New Boxf (-plane_size, -plane_size, -plane_size, plane_size, plane_size, plane_size)
	
		Local plane_model:Model					= Cast <Model> (Entity)
		
		plane_model.Mesh.FitVertices (plane_box)
		plane_model.Mesh.Rotate (0, 180, 0)
		
		plane_model.Move (0.0, 5.0, 0.0)

		For Local mat:Material = Eachin plane_model.Materials
			mat.CullMode = CullMode.Back	
		Next

		Local plane_collider:SphereCollider		= Entity.AddComponent <SphereCollider> ()

			plane_collider.Radius				= plane_size * 0.6
		
		Local plane_body:RigidBody				= Entity.AddComponent <RigidBody> ()

			plane_body.Mass						= plane_mass
			plane_body.Restitution				= 0.5
			plane_body.AngularDamping			= 0.9
			plane_body.LinearDamping			= 0.75
			plane_body.Friction					= 0.0

		Entity.RigidBody.ApplyImpulse (Entity.Basis * New Vec3f (0.0, 0.0, 500000.0))

	End
	
	Method OnUpdate (elapsed:Float) Override

		Entity.RigidBody.ApplyForce (Entity.Basis * New Vec3f (0.0, 0.0, throttle))
		Entity.RigidBody.ApplyTorque (Entity.Basis * New Vec3f (-Abs (Entity.RollFactor ()) * 85000.0, -Entity.RollFactor () * 25000.0, 0.0))
		
		If Keyboard.KeyDown (Key.A)
			throttle = throttle + 10000.0
			plane_audio_channel.Rate = plane_audio_channel.Rate + 0.000005
			plane_audio_channel.Volume = plane_audio_channel.Volume + 0.01
			If plane_audio_channel.Volume > 1 Then plane_audio_channel.Volume = 1
		Endif
		
		If Keyboard.KeyDown (Key.Z)
			throttle = throttle - 10000.0
			plane_audio_channel.Rate = plane_audio_channel.Rate - 0.000005
			plane_audio_channel.Volume = plane_audio_channel.Volume - 0.01
			If plane_audio_channel.Volume < 0.2 Then plane_audio_channel.Volume = 0.2
		Endif
		
		If Keyboard.KeyDown (Key.Left)
			Entity.RigidBody.ApplyTorque (Entity.Basis * New Vec3f (0.0, 0.0, roll_torque))
		Endif

		If Keyboard.KeyDown (Key.Right)
			Entity.RigidBody.ApplyTorque (Entity.Basis * New Vec3f (0.0, 0.0, -roll_torque))
		Endif

		If Keyboard.KeyDown (Key.Up)
			Entity.RigidBody.ApplyTorque (Entity.Basis * New Vec3f (pitch_torque, 0.0, 0.0))
		Endif

		If Keyboard.KeyDown (Key.Down)
			Entity.RigidBody.ApplyTorque (Entity.Basis * New Vec3f (-pitch_torque, 0.0, 0.0))
		Endif

		If Keyboard.KeyDown (Key.Q)
			Entity.RigidBody.ApplyTorque (Entity.Basis * New Vec3f (0.0, -yaw_torque, 0.0))
		Endif
		
		If Keyboard.KeyDown (Key.E)
			Entity.RigidBody.ApplyTorque (Entity.Basis * New Vec3f (0.0, yaw_torque, 0.0))
		Endif
		
	End
	
End
