
' https://github.com/mgzme/MAME-PSGS/blob/master/glsl/mame-psgs_rgb32_dir.fsh
' https://en.wikipedia.org/wiki/List_of_color_palettes
' https://en.wikipedia.org/wiki/List_of_8-bit_computer_hardware_palettes
' https://en.wikipedia.org/wiki/List_of_software_palettes
' https://en.wikipedia.org/wiki/List_of_videogame_consoles_palettes
' https://dithermark.com/resources/

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

#Import "assets/"

Using std..
Using mojo..
Using mojo3d..

Global FullScreen:Bool = False

Global WindowWidth:Int
Global WindowHeight:Int
Global Flags:WindowFlags

Class IslandDemo Extends Window

	' Set this to True for ground self-shadowing on decent desktop PCs:
	
	Const GROUND_SHADOWS:Bool		= False
	
	Field scene:Scene
	Field camera:AerialCamera
	Field plane:PlaneBehaviour

	Field retro_effect:RetroFX

	Field effects:RetroFX []
	Field selected_effect:Int
	
	Field toggle_retro_mode:Bool
	Field retro_mode:Bool
	Field hide_retro_text:Bool

	Field palette_index:Int ' TMP

	Field store_fps:Float ' Used for un-pausing
	
	Method New (title:String = "Retro Island", width:Int = WindowWidth, height:Int = WindowHeight, flags:WindowFlags = Flags)
		Super.New (title, width, height, flags)
		SetConfig( "MOJO3D_RENDERER","forward" )
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
'		Local ground_model:Model				= Model.Load ("asset::untitled.gltf")
		Local ground_model:Model				= Model.Load ("asset::model_gltf_6G3x4Sgg6iX_7QCCWe9sgpb\model.gltf")

			ground_model.CastsShadow			= GROUND_SHADOWS
			ground_model.Mesh.FitVertices (ground_box, False)
			
			For Local mat:Material = Eachin ground_model.Materials
				mat.CullMode = CullMode.Back
				Cast <PbrMaterial> (mat).MetalnessFactor = 0.0
			Next

		Local ground_collider:MeshCollider		= ground_model.AddComponent <MeshCollider> ()

			ground_collider.Mesh				= ground_model.Mesh
		
		Local ground_body:RigidBody				= ground_model.AddComponent <RigidBody> ()

			ground_body.Mass					= 0

		Local mass:Float						= 10954.0
	
		Local pitch_rate:Float					= 175000.0
		Local roll_rate:Float					= 600000.0
		Local yaw_rate:Float					= 100000.0

		Local plane_model:Model					= Model.Load ("asset::1397 Jet_gltf_3B3Pa6BHXn1_fKZwaiJPXpf\1397 Jet.gltf")

			plane = New PlaneBehaviour (plane_model, mass, pitch_rate, roll_rate, yaw_rate) ' False = tmp_nosound

		camera									= New AerialCamera (App.ActiveWindow.Rect, Null, 4096)
		
			camera.RenderCam.View				= Null
			camera.RenderCam.Viewport			= New Recti (0, 0, Frame.Width, Frame.Height)

		Mouse.PointerVisible					= False
		
		' ---------------------------------------------------------------------
		' RETROFX init...
		' ---------------------------------------------------------------------

		' Params:	width:Int				[Default: FX-specific, eg. 640]
		'			height:Int				[Default: FX-specific, eg. 480]
		'			centered:Bool			[Default: True]
		'			palette_enabled:Bool	[Default: True]
		'			dither_enabled:Bool		[Default: True]
		'			brightness:Float		[Default: 0.0]
		'			contrast:Float			[Default: 0.0]

		effects = New RetroFX [6]

		effects [0]								= New SpectrumFX	(, , , , , -0.5, 8.5)
		effects [1]								= New C64FX			(, , , , , -0.5, 8.5)
		effects [2]								= New AppleIIFX		(, , , , , -0.333, 10.5)
		effects [3]								= New Aurora256FX	(, , , , , -0.25, 8.5)
		effects [4]								= New AmstradCPCFX	(, , , , , -0.25, 5.5)
		effects [5]								= New GBFX			(, , , , , 0.0, 5.5)
		
		selected_effect							= 0
		retro_effect							= effects [selected_effect]
		
		' Dither testing on random colours...
		
'		Local cube:Model = Model.CreateBox (New Boxf (-2.5, -2.5, -2.5, 2.5, 2.5, 2.5), 1, 1, 1, New PbrMaterial (Color.White))
'		
'		For Local loop:Int = 1 To 1000
'			Local cube_copy:Model = cube.Copy ()
'			cube_copy.Color = Color.Rnd ()
'			cube_copy.Move (Rnd (-1000, 1000), Rnd (50, 200), Rnd (-1000, 1000))
'		Next

		scene.Update () ' Avoids crash in AerialCamera.Update if P hit before first update!

	End
	
	Method OnMeasure:Vec2i () Override

		If toggle_retro_mode
			retro_mode					= Not retro_mode
			toggle_retro_mode			= False
		Endif
		
		If retro_effect And retro_mode
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

		#If Not __WEB_TARGET__
			If Keyboard.KeyHit (Key.Escape) Then App.Terminate ()
		#Endif

		If Keyboard.KeyDown (Key.Space)
			If scene.UpdateRate
				BulletBehaviour.CreateBullet (plane.Entity) ' Can't spawn while scene is paused!
			Endif
		Endif

		If Keyboard.KeyHit (Key.R)
			toggle_retro_mode = True ' Resolution is changed in OnMeasure
		Endif
		
		
		If Keyboard.KeyHit (Key.H)
			If retro_mode
				hide_retro_text = Not hide_retro_text
			Endif
		Endif
		
		If Keyboard.KeyHit (Key.P)
			If scene
				If scene.UpdateRate
					store_fps			= scene.UpdateRate
					scene.UpdateRate	= 0
				Else
					scene.UpdateRate	= store_fps
				Endif
			Endif
		Endif
		
		If Keyboard.KeyHit (Key.LeftBracket)
		
			If retro_mode
				
				selected_effect = selected_effect - 1
				If selected_effect < 0 Then selected_effect = effects.Length - 1
				
				retro_effect = effects [selected_effect]
				
			Endif
		
		Endif
			
		If Keyboard.KeyHit (Key.RightBracket)
		
			If retro_mode
			
				selected_effect = selected_effect + 1
				If selected_effect > effects.Length - 1 Then selected_effect = 0
				
				retro_effect = effects [selected_effect]
				
			Endif
			
		Endif
	
		If Keyboard.KeyHit (Key.O)
			If retro_mode
				retro_effect.PaletteToggle = Not retro_effect.PaletteToggle
			Endif
		Endif
	
		RequestRender ()

		scene.Update ()
		
		camera.Update (plane)
		
		' ---------------------------------------------------------------------
		' Camera rendering selection:
		' ---------------------------------------------------------------------
		
		If retro_effect And retro_mode
			
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
			If Not hide_retro_text
				canvas.DrawText ("Mode: " + retro_effect.Name, 20, 0)
				canvas.DrawText ("Use [ + ] to change", 20, 14)
				canvas.DrawText ("T[O]ggle palette: O", 20, 28)
				canvas.DrawText ("Toggle retro mode: R", 20, 42)
				canvas.DrawText ("Toggle help: H", 20, 56)
				canvas.DrawText ("FPS: " + App.FPS, 20, 70)
			Endif
		Endif

		Title = "FPS: " + App.FPS
		
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

	If FullScreen
		WindowWidth = 1920
		WindowHeight = 1080
		Flags = WindowFlags.Fullscreen
	Else
		WindowWidth = 960
		WindowHeight = 540
		Flags = WindowFlags.Resizable
	Endif
	
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
