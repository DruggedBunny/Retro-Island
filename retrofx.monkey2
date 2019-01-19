
Class RetroFX

	Property PaletteToggle:Bool ()
		Return palette_toggle
		Setter (state:Bool)
			palette_toggle = state
			TogglePalette ()
	End
	
	Property TargetImage:Image ()
		Return image
	End
	
	Property TargetCanvas:Canvas ()
		Return canvas
	End
	
	Private
	
		Field image:Image
		Field canvas:Canvas
		
		Field palette_toggle:Bool
		
		Method TogglePalette ()
			image.Material.SetInt ("Toggle", PaletteToggle)
		End
		
	Public

		Method New (shader_file:String, width:Int, height:Int, enabled:Bool = True, centered:Bool = True, filter:Bool = False)
	
			' Adapted from DoctorWhoof's Plane Demo -- thanks, DoctorWhoof!
			
			Local shader:Shader = Shader.Open (shader_file)
			
			If Not shader Then Notify ("RetroFX setup error!", "You need to copy ~q" + shader_file + ".glsl~q from ~qretrofx/" + shader_file + "/~q into ~qassets/shaders/~q!", True)
			
			image = New Image (width, height, TextureFlags.Dynamic, shader)
	
			If centered
				image.Handle = New Vec2f (0.5, 0.5)
			Endif
			
			canvas = New Canvas (image)
			
				canvas.TextureFilteringEnabled = filter
			
			image.Material.SetInt ("TextureWidth",	width)
			image.Material.SetInt ("TextureHeight",	height)

			PaletteToggle = enabled
			TogglePalette ()
			
		End

		Method Render (camera:Camera, main_canvas:Canvas)
			camera.Render (TargetCanvas)
			TargetCanvas.Flush ()
			main_canvas.DrawImage (TargetImage, TargetCanvas.Viewport.Width * 0.5, TargetCanvas.Viewport.Height * 0.5)
		End
		
End
