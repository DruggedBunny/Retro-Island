
Class AerialCamera

	Public
	
		Property CameraDistance:Float ()
			Return camera_distance
			Setter (distance:Float)
				camera_distance = distance
		End
		
		Property RenderCam:Camera ()
			Return real_camera
			Setter (new_cam:Camera)
				real_camera = new_cam
		End
		
		Field central:Vec3f
		Field look_back:Vec3f
		Field last_pos:Vec3f
		
		Field cam_dist:Float
		Field mode:Int = 0
		Field last_fov:Float
		
		Method New (viewport:Recti, current_camera:AerialCamera, range_far:Float)
			
			If current_camera Then current_camera.Destroy ()
			
			camera_pivot					= New Pivot
			
			RenderCam						= New Camera (camera_pivot)
			RenderCam.Near					= 0.01
			RenderCam.Far					= range_far * Sqrt (3.0) ' Terrain cube diagonal
			RenderCam.FOV					= 90.0 ' Mojo3d default
			last_fov = RenderCam.FOV
			
			RenderCam.Viewport				= viewport
	
			' Chase target -- position camera tries to move towards...
			
			chase_target 					= Model.CreateSphere (1, 32, 32, New PbrMaterial (Color.Red))
			chase_target.Alpha				= 0.5
			chase_target.Material.CullMode	= CullMode.None
			chase_target.Visible			= False
			
			up = New Vec3f (0.0, up_y_default, 0.0)
			
			central = New Vec3f (0, 50, 0)
			
			look_back = New Vec3f (0, 0, 0)
			
			Reset ()
			
		End
		
		Method Destroy ()
		
			camera_pivot?.Destroy ()
			real_camera?.Destroy ()
			chase_target?.Destroy ()
			
		End
		
		Method Update (target:PlaneBehaviour)
	
			prevvel = lastvel
			
			Local plane_model:Model = Cast <Model> (target.Entity)
			
			lastvel = lastvel.Blend (plane_model.RigidBody.LinearVelocity, 0.045)

			chase_target.Position = (plane_model.Position + up) - (lastvel * CameraDistance)

			If Keyboard.KeyDown (Key.Tab)

				If mode = 0
					look_back.Z = cam_dist
					camera_pivot.Position = plane_model.Position + (plane_model.Basis * look_back)
				Endif

				camera_pivot.PointAt (plane_model)

			Else
			
				camera_pivot.Position = last_pos
				
				If Keyboard.KeyHit (Key.F1)
					mode = 0
				Else
					If Keyboard.KeyHit (Key.F2)
						mode = 1
					Endif
				Endif
				
				Select mode
					Case 0
						camera_pivot.Move ((chase_target.Position - camera_pivot.Position) * 0.95, True)
						RenderCam.FOV = last_fov
					Case 1
						camera_pivot.Position = central
						last_fov = RenderCam.FOV
						RenderCam.FOV = 60.0
					Default
						RuntimeError ("AerialCamera.Update: Invalid camera mode " + mode)
				End

				camera_pivot.PointAt (plane_model)

				cam_dist = plane_model.Position.Distance (RenderCam.Position)
				
				Local closeup:Float = 10.5
				Local closer:Float = 0.1
				
				If cam_dist < closeup
					RenderCam.FOV = Blend (RenderCam.FOV, TransformRange (cam_dist, 1.0, closeup, 130.0, 90.0), closer)
					up.Y = Blend (up.Y, 3.0, 0.01)
				Else
					RenderCam.FOV = Blend (RenderCam.FOV, 90.0, 0.075)
					up.Y = Blend (up.Y, up_y_default, 0.01)
				Endif

				last_pos = camera_pivot.Position
				
			Endif


		End

		Method Render (canvas:Canvas)
			RenderCam.Render (canvas)
		End
		
		Method Move (tv:Vec3f, localSpace:Bool = False)
			camera_pivot.Move (tv, localSpace)
		End
		
		Method Move (tx:Float, ty:Float, tz:Float)
			camera_pivot.Move (tx, ty, tz)
		End
		
		Method PointAt (target:Entity)
			camera_pivot.PointAt (target)
		End
		
		Method Position (v3:Vec3f)
			camera_pivot.Position = v3
		End

		Method Reset ()
	
			RenderCam.FOV	= 90.0
	
			lastvel			= New Vec3f (0, 0, 15)
			prevvel			= lastvel
	
		End
		
	Private
	
		Field camera_pivot:Pivot
		Field real_camera:Camera
		
		Field chase_target:Model
	
		Field lastvel:Vec3f
		Field prevvel:Vec3f
	
		Field up:Vec3f
		Field up_y_default:Float = 5.0
		
		Field camera_distance:Float = 0.4
		
End

' Support functions...

Const RAD_DIVIDER:Float = 180.0 / Pi
Const DEG_DIVIDER:Float = Pi / 180.0

Function Degrees:Float (radians:Float)
	Return radians * RAD_DIVIDER
End

Function Radians:Float (degrees:Float)
	Return degrees * DEG_DIVIDER
End

Function TransformRange:Float (input_value:Float, from_min:Float, from_max:Float, to_min:Float, to_max:Float)

	' Algorithm via jerryjvl at https://stackoverflow.com/questions/929103/convert-a-number-range-to-another-range-maintaining-ratio
	
	Local from_delta:Float	= from_max	- from_min	' Input range,	eg. 0.0 - 1.0
	Local to_delta:Float	= to_max	- to_min	' Output range,	eg. 5.0 - 10.0
	
	Assert (from_delta <> 0.0, "TransformRange: Invalid input range!")
	
	Return (((input_value - from_min) * to_delta) / from_delta) + to_min
	
End

Function Blend:Float (in:Float, target:Float, delta:Float = 0.1)
	If Abs (target - in) < Abs (delta) Then Return target
	Return in + ((target - in) * delta)
End
