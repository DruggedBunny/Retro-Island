
Class C64FX Extends RetroFX

	' Params:
	
	' width/height:		Simulated display size; defaults to 256 x 192 (!) per legit Spectrum
	' centered:			Use MidHandle = True for drawing
	' palette_enabled:	Palette shader enabled
	' dither_enabled:	Dithering enabled
	' brightness:		Brightness increase/decrease on input image
	' contrast:			Contrast increase/decrease on input image
	
	Method New (width:Int = 320, height:Int = 200, centered:Bool = True, palette_enabled:Bool = True, dither_enabled:Bool = True, brightness:Float = 0.0, contrast:Float = 0.0)

		Super.New ("C64", width, height, palette_enabled, dither_enabled, centered)

		InitShader (palette_enabled, dither_enabled, brightness, contrast)

	End
	
	Method InitShader (palette_enabled:Bool, dither_enabled:Bool, brightness:Float, contrast:Float)
	
		TargetImage.Material.SetInt		("Toggle",			palette_enabled)
		TargetImage.Material.SetInt		("Dither",			dither_enabled)
		TargetImage.Material.SetFloat	("Brightness",		brightness)
		TargetImage.Material.SetFloat	("Contrast",		contrast)
		TargetImage.Material.SetInt		("PaletteMode",		RetroFXPalette.Commodore64)

	End
	
End
