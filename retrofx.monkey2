
#Import "retrofx/spectrumfx/spectrumfx"
#Import "retrofx/c64fx/c64fx"
#Import "retrofx/appleiifx/appleiifx"
#Import "retrofx/aurora256fx/aurora256fx"
#Import "retrofx\amstradcpcfx\amstradcpcfx"
#Import "retrofx\gbfx\gbfx"

Enum RetroFXPalette

	AppleII					= 1,
	CommodoreVIC20,
	Commodore64,
	MSX,
	CGA4,
	CGA16,
	MARCO_NES54,
	MARCO_CUSTOM38,
	MARCO_CUSTOM16,
	MARCO_CUSTOM16_2,
	MARCO_CUSTOM16_3,
	MARCO_CUSTOM16_4,
	MARCO_CUSTOM13,
	MARCO_GAMEBOY5,
	MARCO_CUSTOM5PURPLE,
	MARCO_CUSTOM4GREEN,
	MARCO_CUSTOM11GRAYSCALE,
	MARCO_CUSTOM6GRAYSCALE,
	MARCO_CUSTOM3GRAYSCALE,
	Spectrum				= 1000,
	Monochrome,
	AppleIIHiRes,
	Aurora256FX,
	AmstradCPCFX
	
End

Class RetroFX

	Property Name:String ()
		Return fx_name
	End
	
	Property PaletteToggle:Bool ()
		Return palette_toggle
		Setter (state:Bool)
			palette_toggle = state
			TogglePalette ()
	End
	
	Property DitherToggle:Bool ()
		Return dither_toggle
		Setter (state:Bool)
			dither_toggle = state
			ToggleDither ()
	End
	
	Property TargetImage:Image ()
		Return image
	End
	
	Property TargetCanvas:Canvas ()
		Return canvas
	End
	
	Private
	
		Field fx_name:String
	
		Field image:Image
		Field canvas:Canvas
		
		Field palette_toggle:Bool
		
		Method TogglePalette ()
			image.Material.SetInt ("Toggle", PaletteToggle)
		End
		
		Field dither_toggle:Bool
		
		Method ToggleDither ()
			image.Material.SetInt ("Dither", DitherToggle)
		End
		
	Public

		Method New (name:String, width:Int, height:Int, palette_enabled:Bool = True, dither_enabled:Bool = True, centered:Bool = True, filter:Bool = False)
	
			fx_name = name
			
			' Adapted from DoctorWhoof's Plane Demo -- thanks, DoctorWhoof!
			
			Local shader:Shader = Shader.Open ("retrofx")
			
			#If Not __WEB_TARGET__ ' https://github.com/blitz-research/monkey2/issues/460
				If Not shader Then Notify ("RetroFX setup error!", "You need to copy ~qretrofx.glsl~q from ~qretrofx/~q into ~qassets/shaders/~q!", True)
			#Endif
			
			image = New Image (width, height, TextureFlags.Dynamic, shader)
	
			If centered
				image.Handle = New Vec2f (0.5, 0.5)
			Endif
			
			canvas = New Canvas (image)
			
				canvas.TextureFilteringEnabled = filter
			
			image.Material.SetInt ("TextureWidth",	width)
			image.Material.SetInt ("TextureHeight",	height)

			PaletteToggle = palette_enabled
			TogglePalette ()
			
			DitherToggle = dither_enabled
			ToggleDither ()
			
		End
		
		Method Render (camera:Camera, main_canvas:Canvas) Virtual
			camera.Render (TargetCanvas)
			TargetCanvas.Flush ()
			main_canvas.DrawImage (TargetImage, TargetCanvas.Viewport.Width * 0.5, TargetCanvas.Viewport.Height * 0.5)
		End

End
