
#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Function NastyFormatFloatString:String (num:String, decimal_places:Int)

	Local pos:Int = num.Find (".")
	
	If pos > -1 And decimal_places
		num = num.Slice (0, pos + 1 + decimal_places)
	Endif
	
	Return num
	
End

Function Main ()

	color [0] = New Vec3f (0.0, 0.0, 0.0)
	color [1] = New Vec3f (0.384, 0.384, 0.384)
	color [2] = New Vec3f (0.537, 0.537, 0.537)
	color [3] = New Vec3f (0.678, 0.678, 0.678)
	color [4] = New Vec3f (1.0, 1.0, 1.0)
	color [5] = New Vec3f (0.624, 0.306, 0.267)
	color [6] = New Vec3f (0.796, 0.494, 0.459)
	color [7] = New Vec3f (0.427, 0.329, 0.71)
	color [8] = New Vec3f (0.631, 0.408, 0.235)
	color [9] = New Vec3f (0.788, 0.831, 0.529)
	color [10] = New Vec3f (0.604, 0.886, 0.608)
	color [11] = New Vec3f (0.361, 0.671, 0.369)
	color [12] = New Vec3f (0.416, 0.749, 0.776)
	color [13] = New Vec3f (0.0533, 0.494, 0.796)
	color [14] = New Vec3f (0.314, 0.271, 0.608)
	color [15] = New Vec3f (0.627, 0.341, 0.639)

	Local rgb:Vec3f = New Vec3f (51/255.0, 153/255.0, 255/255.0)
	
	Print ""
	Print rgb.x * 255
	Print rgb.y * 255
	Print rgb.z * 255
	
	rgb = rgbtohsl (rgb)
	
	Print ""
	Print rgb.x * 255
	Print rgb.y * 255
	Print rgb.z * 255
	
	rgb = hsltorgb (rgb)
	
	Print ""
	Print rgb.x
	Print rgb.y
	Print rgb.z
	
	rgb = dither(rgb)
	
	Print rgb.x
	Print rgb.y
	Print rgb.z


	Print "IMAGE"
	Local image:Image = Image.Load ("D:\Documents\Development\Sources\Monkey2 Sources\speccy island\amstrad-cpc-1x.png", Null, TextureFlags.None)
	
	For Local x:Int = 0 Until image.Width
		
		Local rgb:Color = image.GetPixel (x, 0)
		
		Print ""
		
		Print "TRY_COLOR (vec3 (  " + (rgb.R * 255) + ".0,   " + (rgb.G * 255) + ".0,   " + (rgb.B * 255) + ".0));"

	Next
	
	For Local loop:Int = 0 Until 20
		Print loop Mod 8
	Next
	
End

Const lightnessSteps:Float = 4.0
Const COLORS:Int = 16

Global color:Vec3f [] = New Vec3f [COLORS]

Const indexMatrix4x4:Int [] = New Int [16]	(0,  8,  2,  10,
											12, 4,  14, 6,
											3,  11, 1,  9,
											15, 7,  13, 5)

Function indexValue:Float ()

    Local x:Int = 0
    Local y:Int = 0
	
    Return indexMatrix4x4[(x + y * 4)] / 16.0

End

'TODO: define color[COLORS] with c64 palette

Function lightnessStep:Float (l:Float)
    Return Floor((0.5 + l * lightnessSteps)) / lightnessSteps
End

Function rgbtohsl:Vec3f (rgb:Vec3f)
	
	Local r:Float=rgb.x
	Local g:Float=rgb.y
	Local b:Float=rgb.z
	Local hsl:Vec3f
	Local ax:Float=Max(Max(r,g),b)
	Local _in:Float=Min(Min(r,g),b)
	hsl.z=(ax+_in)/2.0
	If ax=_in
		Return hsl
	Endif
	Local d:Float=ax-_in

	If hsl.z>.5
		hsl.y=d/(2.0-ax-_in)
	Else
		hsl.y=d/(ax+_in)
	Endif
	
	If ax=r
		Local gv:Int=0
		If g<b
			gv=6
		Endif
		hsl.x=(g-b)/d+gv
	Else
		If ax=g
			hsl.x=(b-r)/d+2
		Else
			If ax=b
				hsl.x=(r-g)/d+4
			Endif
		Endif
	Endif
	
	hsl.x=hsl.x/6.0
	
	Return hsl

End

Function huetorgb:Float (p:Float, q:Float, t:Float)

	If t<0
		t=t+1
	Endif
	If t>1
		t=t-1
	Endif
	If t<0.166666667
		Return p+(q-p)*6*t
	Endif
	If t<0.5
		Return q
	Endif
	If t<0.666666667
		Return p+(q-p)*(0.666666667-t)*6
	Endif
	Return p

End

Function hsltorgb:Vec3f (hsl:Vec3f)
	Local h:Float=hsl.x
	Local s:Float=hsl.y
	Local l:Float=hsl.z
	If s=0.0
		Return New Vec3f (1.0, 1.0, 1.0)
	Endif
	Local q:Float
	
	If l<.5
		q=l*(1+s)
	Else
		q=(l+s-l*s)
	Endif

	Local p:Float=2*l-q
	
	Return New Vec3f (huetorgb(p,q,h+0.333333333), huetorgb(p,q,h), huetorgb(p,q,h-0.333333333))
	
End

Function closestColors:Vec3f[](hue:Float)
    Local ret:Vec3f [] = New Vec3f [2]
    Local closest:Vec3f = New Vec3f(-2.0, 0.0, 0.0)
    Local secondClosest:Vec3f = New Vec3f(-2.0, 0.0, 0.0)
    Local temp:Vec3f
    For Local i:Int = 0 Until COLORS
        temp = color[i]
        Local tempDistance:Float = hueDistance(temp.x, hue)
        If tempDistance < hueDistance(closest.x, hue)
            secondClosest = closest
            closest = temp
        Else
            If tempDistance < hueDistance(secondClosest.x, hue)
                secondClosest = temp
            Endif
        Endif
    Next
    ret[0] = closest
    ret[1] = secondClosest
    Return ret
End

Function hueDistance:Float (h1:Float, h2:Float)
    Local diff:Float = Abs((h1 - h2))
    Return Min(Abs((1.0 - diff)), diff)
End

Function dither:Vec3f (color:Vec3f)

    Local hsl:Vec3f = rgbtohsl(color)

    Local cs:Vec3f[] = closestColors(hsl.x)
    Local c1:Vec3f = cs[0]
    Local c2:Vec3f = cs[1]
    Local d:Float = indexValue()
    Local hueDiff:Float = hueDistance(hsl.x, c1.x) / hueDistance(c2.x, c1.x)

    Local l1:Float = lightnessStep(Max((hsl.z - 0.125), 0.0))
    Local l2:Float = lightnessStep(Min((hsl.z + 0.124), 1.0))
    Local lightnessDiff:Float = (hsl.z - l1) / (l2 - l1)

    Local resultColor:Vec3f
    
    If hueDiff < d
    	resultColor = c1
    Else
    	resultColor = c2
    Endif
    
    If lightnessDiff < d
    	resultColor.z = l1
    Else
    	resultColor.z = l1
    Endif

    If lightnessDiff < d
    	resultColor.z = l1
    Else
    	resultColor.z = l2
    Endif

    Return hsltorgb(resultColor)

End
