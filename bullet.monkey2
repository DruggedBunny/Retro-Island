
Const BULLET_LENGTH:Float	= 15.0
Const REMOVE_DISTANCE:Float	= 750.0

Class BulletBehaviour Extends Behaviour

	Global BulletModel:Model
	Global LastBullet:Entity
	
	Global BulletAudio:Sound
	Global ImpactAudio:Sound
	
	Field start_pos:Vec3f
	
	Function CreateBullet (parent:Entity)
	
		If Not LastBullet

			' Shouldn't really do this here!
			
			If Not BulletAudio
				
				BulletAudio = Sound.Load ("asset::audio/bullet_pink.ogg")
				
				' Or this here! Rock and roll!

				ImpactAudio = Sound.Load ("asset::audio/bullet_impact.ogg")
				
			Endif
			
			BulletModel			= Model.CreateCylinder (0.33, BULLET_LENGTH, Axis.Z, 8, New PbrMaterial (Color.White))
			BulletModel.Visible	= False

			New BulletBehaviour (BulletModel.Copy (parent))

		Else
			If LastBullet.Position.Distance (parent.Position) > BULLET_LENGTH * 2.5
				New BulletBehaviour (BulletModel.Copy (parent))
			Endif
		Endif
		
	End
	
	Method New (entity:Entity)

		Super.New (entity)
		AddInstance ()
		
	End
	
	Method OnStart () Override
	
		Local channel:Channel = BulletAudio.Play ()

			channel.Rate = channel.Rate * 1.0'0.5
		
		Entity.Visible					= True

		Entity.Rotate (2.5, 0, 0, True)
		Entity.Move (0, -2, 15)
		
		Local bullet_velocity:Vec3f		= Entity.Parent.RigidBody.LinearVelocity + (Entity.Basis * New Vec3f (0, 0, 300))
		
		Entity.Parent					= Null
		
		Local collider:CylinderCollider	= Entity.AddComponent <CylinderCollider> ()
		
			collider.Radius				= 1.0
			collider.Axis				= Axis.Z
		
		Local body:RigidBody			= Entity.AddComponent <RigidBody> ()
			
			body.Collided				=	Lambda (other_body:RigidBody)
												
												Local channel:Channel = ImpactAudio.Play ()
												
												channel.Rate = channel.Rate * Rnd (0.8, 1.2)
												
												MarkerBehaviour.Create (Entity)
												
												Entity.Destroy ()
												
											End

' Additional function test: note += syntax to add to functions called... uncomment to try!

'			body.Collided				+=	Lambda (other_body:RigidBody)
'												Print "Hi"
'											End
		
		start_pos						= Entity.Position
		
		LastBullet						= Entity
		
		Select Int (Rnd (4))
		
			Case 0
				Entity.Color			= Color.White
			Case 1
				Entity.Color			= Color.Yellow
			Case 2
				Entity.Color			= Color.Orange
			Case 3
				Entity.Color			= Color.Red
			
		End
		
		Local model:Model				= Cast <Model> (Entity)
		Local pbrm:PbrMaterial			= Cast <PbrMaterial> (model.Material)

			pbrm.EmissiveFactor			= Entity.Color

		Entity.RigidBody.ApplyImpulse (bullet_velocity)

	End
	
	Method OnUpdate (elapsed:Float) Override
		
		Entity.RigidBody.ApplyForce (New Vec3f (0.0, -40.0, 0.0))
		
		If Entity.Position.Distance (start_pos) > REMOVE_DISTANCE

			Entity.Destroy ()

'			Entity.RigidBody.Kinematic = True


'				' --------------------------------------------------------------------------------------------------------------------
'				' Re-position rigidbody:
'				' --------------------------------------------------------------------------------------------------------------------
'				

				' Last comment at https://stackoverflow.com/questions/12251199/re-positioning-a-rigid-body-in-bullet-physics

				' 	"Change its worldtransform and then clear forces and linear and angular velocities is sufficient. – Ben Sep 6 '16 at 12:21"
				
'				Local t:bullet.btTransform = New bullet.btTransform
'				Local v:bullet.btVector3 = New bullet.btVector3 (Rnd (100), Rnd (100), Rnd (100))
'				t.setOrigin (v)
''				
'				Entity.RigidBody.btBody.proceedToTransform (t)
'
'				'Entity.RigidBody.btBody.clearForces ()
'				Entity.RigidBody.btBody.setLinearVelocity (New bullet.btVector3 (0, 0, 0))
'				Entity.RigidBody.btBody.setAngularVelocity (New bullet.btVector3 (1, 2, 4))
''				

' alternative to try, from same thread:

' There are three things you'll need to do in order to solve this:

'    Convert your rigid bodies to kinematic ones
 '   Adjust the World Transform of the bodies motion state and NOT the rigid body
  '  Convert the kinematic body back to a rigid body

' also https://stackoverflow.com/questions/12251199/re-positioning-a-rigid-body-in-bullet-physics

'Here is my reposition method that does exactly this.
'
'void LimbBt::reposition(btVector3 position,btVector3 orientation) {
'    btTransform initialTransform;
'
'    initialTransform.setOrigin(position);
'    initialTransform.setRotation(orientation);
'
'    mBody->setWorldTransform(initialTransform);
'    mMotionState->setWorldTransform(initialTransform);
'}
'
'The motion state mMotionState is the motion state you created for the btRigidBody in the beginning. Just add your clearForces() and velocities to it to stop the body from moving on from the new position as if it went through a portal. That should do it. It works nicely with me here.


'				' --------------------------------------------------------------------------------------------------------------------
'			
			'Entity.RigidBody.Mass = 0'btBody.setGravity (New bullet.btVector3 (0, 0, 0))
'			Entity.RigidBody.Kinematic = False

		Endif
		
	End
	
End
