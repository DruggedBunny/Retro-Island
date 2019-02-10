
Class AmstradCPCFX Extends RetroFX

	' Params:
	
	' width/height:		Simulated display size; defaults to 256 x 192 (!) per legit Spectrum
	' centered:			Use MidHandle = True for drawing
	' palette_enabled:	Palette shader enabled
	' dither_enabled:	Dithering enabled
	' brightness:		Brightness increase/decrease on input image
	' contrast:			Contrast increase/decrease on input image
	
	Method New (width:Int = 160, height:Int = 200, centered:Bool = True, palette_enabled:Bool = True, dither_enabled:Bool = True, brightness:Float = 0.0, contrast:Float = 0.0)

		' Amstrad low-res mode is double-wide pixels (rectangular, not square!),
		' so we double the width here and use a custom overridden Render further down...
		
		Super.New ("Amstrad CPC", width * 2.0, height, palette_enabled, dither_enabled, centered)

		InitShader (palette_enabled, dither_enabled, brightness, contrast)

	End
	
	Method InitShader (palette_enabled:Bool, dither_enabled:Bool, brightness:Float, contrast:Float)
	
		TargetImage.Material.SetInt		("Toggle",			palette_enabled)
		TargetImage.Material.SetInt		("Dither",			dither_enabled)
		TargetImage.Material.SetFloat	("Brightness",		brightness)
		TargetImage.Material.SetFloat	("Contrast",		contrast)
		TargetImage.Material.SetInt		("PaletteMode",		RetroFXPalette.AmstradCPCFX)

	End

	' Although Amstrad low resolution is higher than it is wider, it is stretched
	' to fill a 4:3 screen... this does that (scaling 1.6, 1.0)...
	
	Method Render (camera:Camera, main_canvas:Canvas) Override
		camera.Render (TargetCanvas)
		TargetCanvas.Flush ()
		main_canvas.DrawImage (TargetImage, TargetCanvas.Viewport.Width * 0.5, TargetCanvas.Viewport.Height * 0.5, 0.0, 1.6, 1.0)
	End
	
End
