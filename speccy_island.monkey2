
' Next up: Can I apply a shader to model materials and
' then use stippling like Spectrum "Fighter Bomber"??
' https://youtu.be/KJhPmDWtPhY?t=219


' Model credits at end of source.

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"

#Import "aerialcamera"
#Import "plane"
#Import "bullet"
#Import "marker"

#Import "retrofx"
#Import "retrofx/spectrumfx/spectrumfx"

#Import "assets/"

Using std..
Using mojo..
Using mojo3d..

Class IslandDemo Extends Window

	' Set this to True for ground self-shadowing on decent desktop PCs:
	
	Const GROUND_SHADOWS:Bool		= False
	
'	Const WINDOW_WIDTH:Int			= 960
'	Const WINDOW_HEIGHT:Int			= 540
'	Const WINDOW_FLAGS:WindowFlags	= WindowFlags.Resizable

	Const WINDOW_WIDTH:Int			= 1920
	Const WINDOW_HEIGHT:Int			= 1080
	Const WINDOW_FLAGS:WindowFlags	= WindowFlags.Fullscreen

	Field scene:Scene
	Field camera:AerialCamera
	Field plane:PlaneBehaviour

	Field retro_effect:RetroFX

	Field toggle_retro_mode:Bool
	Field retro_mode:Bool' = True

	Field store_fps:Float ' Used for un-pausing
	
	Method New (title:String = "Island Demo", width:Int = WINDOW_WIDTH, height:Int = WINDOW_HEIGHT, flags:WindowFlags = WINDOW_FLAGS)
		Super.New (title, width, height, flags)
'		SetConfig( "MOJO3D_RENDERER","forward" )
	End
	
	Method OnCreateWindow () Override

		scene									= Scene.GetCurrent ()

			scene.ClearColor					= New Color (0.2, 0.6, 1.0)
			scene.AmbientLight					= scene.ClearColor * 0.25
			scene.FogColor						= scene.ClearColor
			scene.FogNear						= 2048'128
			scene.FogFar						= 2048

		Local light:Light						= New Light

			light.CastsShadow					= True
			light.Rotate (45, 45, 0)
		
		Local ground_size:Float					= 4096 * 0.5
		Local ground_box:Boxf					= New Boxf (-ground_size, -ground_size * 0.5, -ground_size, ground_size, 0, ground_size)
		Local ground_model:Model				= Model.Load ("asset::model_gltf_6G3x4Sgg6iX_7QCCWe9sgpb\model.gltf")'CreateBox( groundBox,1,1,1,groundMaterial )

			ground_model.CastsShadow			= GROUND_SHADOWS
			ground_model.Mesh.FitVertices (ground_box, False)
			
			For Local mat:Material = Eachin ground_model.Materials
				mat.CullMode = CullMode.Back	
			Next

		Local ground_collider:MeshCollider		= ground_model.AddComponent <MeshCollider> ()

			ground_collider.Mesh				= ground_model.Mesh
		
		Local ground_body:RigidBody				= ground_model.AddComponent <RigidBody> ()

			ground_body.Mass					= 0

		Local mass:Float						= 10954.0
	
		Local pitch_rate:Float					= 155000.0 ' TODO: Maybe cancel auto roll-pitch when manually pitching?
		Local roll_rate:Float					= 550000.0
		Local yaw_rate:Float					= 100000.0

		Local plane_model:Model					= Model.Load ("asset::1397 Jet_gltf_3B3Pa6BHXn1_fKZwaiJPXpf\1397 Jet.gltf")

			plane = New PlaneBehaviour (plane_model, mass, pitch_rate, roll_rate, yaw_rate)

		camera									= New AerialCamera (App.ActiveWindow.Rect, Null, 4096)
		
			camera.RenderCam.View				= Null
			camera.RenderCam.Viewport			= New Recti (0, 0, Frame.Width, Frame.Height)

		Mouse.PointerVisible					= False
		
		' ---------------------------------------------------------------------
		' RETROFX init...
		' ---------------------------------------------------------------------

		' Params per New method; note that 12.5 used below is constrast tweak *for this specific scene*, which is pale and low-contrast.

		' Method New (width:Int = 256, height:Int = 192, centered:Bool = True, palette_enabled:Bool = True, brightness:Float = 0.0, contrast:Float = 0.0, attribute_clash:Bool = False, grid_size:Float = 8.0)
		
'		retro_effect							= New SpectrumFX (1920, 1080, , , , 12.5, True, 8) ' Attribute clash in a 1080p Speccy!
		retro_effect							= New SpectrumFX (, , , , , 12.5) ' Contrast adjustment = 12.5 for this scene
		
		' ---------------------------------------------------------------------
	End
	
	Method OnMeasure:Vec2i () Override

		If toggle_retro_mode
			retro_mode	= Not retro_mode	
			toggle_retro_mode	= False
		Endif
		
		If retro_mode
			camera.RenderCam.View		= Null
			camera.RenderCam.Viewport	= New Recti (0, 0, retro_effect.TargetImage.Width, retro_effect.TargetImage.Height)
			Layout						= "letterbox"
			Return New Vec2i (retro_effect.TargetImage.Width, retro_effect.TargetImage.Height)
		Else
			camera.RenderCam.View		= Null
			camera.RenderCam.Viewport	= New Recti (0, 0, Frame.Width, Frame.Height)
			Layout						= "fill"
			Return Frame.Size
		Endif

	End
	
	Method OnRender (canvas:Canvas) Override
	
		canvas.TextureFilteringEnabled = False

		If Keyboard.KeyHit (Key.Escape) Then App.Terminate ()

		If Keyboard.KeyDown (Key.Space)
			If scene.UpdateRate
				BulletBehaviour.CreateBullet (plane.Entity) ' Can't spawn while scene is paused!
			Endif
		Endif

'		Changing target/shader works! Not tied in to the demo toggles...
'		If Keyboard.KeyHit (Key.CHANGEME)
'			retro_effect = New SpectrumFX (1920, 1080, , , , 12.5, True, 8)
'		Endif
		
		If Keyboard.KeyHit (Key.R)
			toggle_retro_mode = True ' Resolution is changed in OnMeasure
		Endif
		
		If Keyboard.KeyHit (Key.O)
			If retro_mode
				retro_effect.PaletteToggle = Not retro_effect.PaletteToggle
			Endif
		Endif
		
		If Keyboard.KeyHit (Key.P)
			If scene.UpdateRate
				store_fps			= scene.UpdateRate
				scene.UpdateRate	= 0
			Else
				scene.UpdateRate	= store_fps
			Endif
		Endif
		
		RequestRender ()

		scene.Update ()
		
		camera.Update (plane)
		
		' ---------------------------------------------------------------------
		' Camera rendering selection:
		' ---------------------------------------------------------------------
		
		If retro_mode
			
			' In retro_mode, use RetroFX.Render, passing current camera and canvas...
			
			retro_effect.Render (camera.RenderCam, canvas)
			
		Else
		
			' In non-retro_mode, use current camera.Render (canvas)...
			
			camera.RenderCam.Render (canvas)
			
			' (OK, slightly confusing here, as 'camera' is an AerialCamera: 'camera.RenderCam' is the actual Camera object.)
			
		Endif

		If Not retro_mode
			canvas.DrawText ("FPS: " + App.FPS, 20, 20)
			canvas.DrawText ("Flight controls: Cursors for roll & pitch, Q/E for yaw", 20, 60)
			canvas.DrawText ("Throttle: A/Z", 20, 80)
			canvas.DrawText ("Fire cannon: Space", 20, 100)
			canvas.DrawText ("Look back: Tab", 20, 140)
			canvas.DrawText ("Toggle retro mode: R", 20, 180)
			canvas.DrawText ("Pause: P", 20, 200)
		Else
			canvas.DrawText ("FPS: " + App.FPS, 20, 0)
			canvas.DrawText ("T[O]ggle palette: O", 20, 20)
		Endif

	End

End

Class Entity Extension

	Method RollFactor:Float ()
		Return Sin (Basis.GetRoll ())
	End

End

Class Mesh Extension

	' Thanks, DoctorWhoof!

	Method Rotate (pitch:Float, yaw:Float, roll:Float)
		TransformVertices (AffineMat4f.Rotation (Radians (pitch), Radians(yaw), Radians (roll)))
	End
	
End

Function Main ()

	New AppInstance
	New IslandDemo
	
	App.Run ()

End

' Model credits -- thanks to the authors!

' Unmodified GLTF models from sources below.

' Model: "A little Irish island"

' 		Author

'			John Huikku:	https://poly.google.com/user/1b9F61Bj5l9
'			Source:			https://poly.google.com/view/6G3x4Sgg6iX

'		License

'			Attribution 3.0 Unported (CC BY 3.0) aka. "CC-BY 3.0"
'			https://creativecommons.org/licenses/by/3.0/
'			https://support.google.com/poly/answer/7418679

' Model: "Jet"

'		Author

'			Poly by Google:	https://poly.google.com/user/1b9F61Bj5l9
'			Source:			https://poly.google.com/view/3B3Pa6BHXn1

'		License

'			Attribution 3.0 Unported (CC BY 3.0) aka. "CC-BY 3.0"
'			https://creativecommons.org/licenses/by/3.0/
'			https://support.google.com/poly/answer/7418679
