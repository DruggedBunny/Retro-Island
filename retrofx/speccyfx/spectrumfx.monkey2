
#Import "../retrofx"
#Import "spectrum.glsl"

Class SpectrumFX Extends RetroFX

	' Add attr clash and brightness/contrast controls...
	
	' Params:
	
	' width/height:		Simulated display size; defaults to 256 x 192 (!) per legit Spectrum
	' centered:			Use MidHandle = True for drawing
	' shader_enabled:	Shader enabled
	' brightness:		Brightness increase/decrease on input image
	' contrast:			Contrast increase/decrease on input image
	' attribute_clash:	Simulate ZX Spectrum's attribute/colour clash (disabled by default as it looks bad; use True for legit Spectrum rendering)
	' grid_size:		Grid size for attribute clash; defaults to 8 x 8 pixels per legit Spectrum
	
	Method New (width:Int = 256, height:Int = 192, centered:Bool = True, shader_enabled:Bool = True, brightness:Float = 0.0, contrast:Float = 0.0, attribute_clash:Bool = False, grid_size:Float = 8.0)

		Super.New ("speccy", width, height, centered, shader_enabled)

		TargetImage.Material.SetInt		("Toggle",		shader_enabled)
		TargetImage.Material.SetInt		("Attr",		attribute_clash)
		TargetImage.Material.SetFloat	("Brightness",	brightness)
		TargetImage.Material.SetFloat	("Contrast",	contrast)
		TargetImage.Material.SetFloat	("GridSize",	grid_size)

	End
	
End
