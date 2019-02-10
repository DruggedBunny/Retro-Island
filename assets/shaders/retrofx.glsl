
// Uses palette-matching portions of MAME-PSGS,
// by Marco Gomez (mgzme): https://github.com/mgzme/MAME-PSGS
// License supplied separately as "mame-psgs license.txt".
// Thanks, Marco!

// --------------------
// BOILERPLATE BEGINS!
// --------------------

//@renderpasses 0

varying vec2 v_TexCoord0;
varying vec4 v_Color;

//@vertex

attribute vec4 a_Position;
attribute vec2 a_TexCoord0;
attribute vec4 a_Color;

uniform mat4 r_ModelViewProjectionMatrix;

uniform vec4 m_ImageColor;

void main(){

	v_TexCoord0=a_TexCoord0;
	v_Color=m_ImageColor * a_Color;
	
	gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

//@fragment

// --------------------
// BOILERPLATE ENDS!
// --------------------

uniform sampler2D	m_ImageTexture0;

uniform bool		m_Toggle;
uniform bool		m_Dither;

uniform float		m_Brightness;
uniform float		m_Contrast;

uniform int			m_TextureWidth;
uniform int			m_TextureHeight;

uniform int			m_PaletteMode;

vec3 find_closest (vec3 ref)
{
	vec3 old = vec3 (100.0 * 255.0);
	
	#define TRY_COLOR(new) old = mix (new, old, step (length (old-ref), length (new-ref)));

	// Part one - YPbPr 16-colorish composite video based systems =====================================================

	// AppleII series 16-color composite video palette representation, based on YIQ color space used by NTSC
	// practical 15 color palette as it count's  with 2 similar grey instances.
	if (m_PaletteMode == 1) {
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));		//  0 - black			(YPbPr = 0.0  ,  0.0 ,  0.0 )
		TRY_COLOR (vec3 (133.0,  59.0,  81.0));		//  1 - magenta			(YPbPr = 0.25 ,  0.0 ,  0.5 )
		TRY_COLOR (vec3 ( 80.0,  71.0, 137.0));		//  2 - dark blue		(YPbPr = 0.25 ,  0.5 ,  0.0 )
		TRY_COLOR (vec3 (233.0,  93.0, 240.0));		//  3 - purple			(YPbPr = 0.5  ,  1.0 ,  1.0 )
		TRY_COLOR (vec3 (  0.0, 104.0,  82.0));		//  4 - dark green		(YPbPr = 0.25 ,  0.0 , -0.5 )
		TRY_COLOR (vec3 (146.0, 146.0, 146.0));		//  5 - gray #1			(YPbPr = 0.5  ,  0.0 ,  0.0 )
		TRY_COLOR (vec3 (  0.0, 168.0, 241.0));		//  6 - medium blue		(YPbPr = 0.5  ,  1.0 , -1.0 )
		TRY_COLOR (vec3 (202.0, 195.0, 248.0));		//  7 - light blue		(YPbPr = 0.75 ,  0.5 ,  0.0 )
		TRY_COLOR (vec3 ( 81.0,  92.0,  15.0));		//  8 - brown			(YPbPr = 0.25 , -0.5 ,  0.0 )
		TRY_COLOR (vec3 (235.0, 127.0,  35.0));		//  9 - orange			(YPbPr = 0.5  , -1.0 ,  1.0 )
		//TRY_COLOR(vec3(146.0, 146.0, 146.0));		// 10 - gray #2			(YPbPr = 0.5  ,  0.0 ,  0.0 )
		TRY_COLOR (vec3 (241.0, 166.0, 191.0));		// 11 - pink			(YPbPr = 0.75 ,  0.0 ,  0.5 )
		TRY_COLOR (vec3 (  0.0, 201.0,  41.0));		// 12 - green			(YPbPr = 0.5  , -1.0 , -1.0 )
		TRY_COLOR (vec3 (203.0, 211.0, 155.0));		// 13 - yellow			(YPbPr = 0.75 , -0.5 ,  0.0 )
		TRY_COLOR (vec3 (154.0, 220.0, 203.0));		// 14 - aqua			(YPbPr = 0.75 ,  0.0 , -0.5 )
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));		// 15 - white			(YPbPr = 1.0  ,  0.0 ,  0.0 )
	}

	// Commodore VIC-20 based on MOS Technology VIC chip (also a 16-color YpbPr composite video palette)
	// this one lacks any intermediate grey shade and counts with 5 levels of luminance.
	if (m_PaletteMode == 2) {
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));		//  0 - black			(YPbPr = 0.0  ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));		//  1 - white			(YPbPr = 1.0  ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (120.0,  41.0,  34.0));		//  2 - red				(YPbPr = 0.25 , -0.383 ,  0.924 )
		TRY_COLOR (vec3 (135.0, 214.0, 221.0));		//  3 - cyan			(YPbPr = 0.75 ,  0.383 , -0.924 )
		TRY_COLOR (vec3 (170.0,  95.0, 182.0));		//  4 - purple			(YPbPr = 0.5  ,  0.707 ,  0.707 )
		TRY_COLOR (vec3 ( 85.0, 160.0,  73.0));		//  5 - green			(YPbPr = 0.5  , -0.707 , -0.707 )
		TRY_COLOR (vec3 ( 64.0,  49.0, 141.0));		//  6 - blue			(YPbPr = 0.25 ,  1.0   ,  0.0   )
		TRY_COLOR (vec3 (191.0, 206.0, 114.0));		//  7 - yellow			(YPbPr = 0.75 , -1.0   ,  0.0   )
		TRY_COLOR (vec3 (170.0, 116.0,  73.0));		//  8 - orange			(YPbPr = 0.5  , -0.707 ,  0.707 )
		TRY_COLOR (vec3 (234.0, 180.0, 137.0));		//  9 - light orange	(YPbPr = 0.75 , -0.707 ,  0.707 )
		TRY_COLOR (vec3 (184.0, 105.0,  98.0));		// 10 - light red		(YPbPr = 0.5  , -0.383 ,  0.924 )
		TRY_COLOR (vec3 (199.0, 255.0, 255.0));		// 11 - light cyan		(YPbPr = 1.0  ,  0.383 , -0.924 )
		TRY_COLOR (vec3 (234.0, 159.0, 246.0));		// 12 - light purple	(YPbPr = 0.75 ,  0.707 ,  0.707 )
		TRY_COLOR (vec3 (148.0, 224.0, 137.0));		// 13 - light green		(YPbPr = 0.75 , -0.707 , -0.707 )
		TRY_COLOR (vec3 (128.0, 113.0, 204.0));		// 14 - light blue		(YPbPr = 0.5  ,  1.0   ,  0.0   )
		TRY_COLOR (vec3 (255.0, 255.0, 178.0));		// 15 - light yellow	(YPbPr = 1.0  , -1.0   ,  0.0   )
	}

	// Commodore 64 based on MOS Technology VIC-II chip (also a 16-color YpbPr composite video palette)
	// this one evolved from VIC-20 and now counts with 3 shades of grey
	if (m_PaletteMode == 3) {
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));		//  0 - black			(YPbPr = 0.0   ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));		//  1 - white			(YPbPr = 1.0   ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (161.0,  77.0,  67.0));		//  2 - red				(YPbPr = 0.313 , -0.383 ,  0.924 )
		TRY_COLOR (vec3 (106.0, 193.0, 200.0));		//  3 - cyan			(YPbPr = 0.625 ,  0.383 , -0.924 )
		TRY_COLOR (vec3 (162.0,  86.0, 165.0));		//  4 - purple			(YPbPr = 0.375 ,  0.707 ,  0.707 )
		TRY_COLOR (vec3 ( 92.0, 173.0,  95.0));		//  5 - green			(YPbPr = 0.5   , -0.707 , -0.707 )
		TRY_COLOR (vec3 ( 79.0,  68.0, 156.0));		//  6 - blue			(YPbPr = 0.25  ,  1.0   ,  0.0   )
		TRY_COLOR (vec3 (203.0, 214.0, 137.0));		//  7 - yellow			(YPbPr = 0.75  , -1.0   ,  0.0   )
		TRY_COLOR (vec3 (163.0, 104.0,  58.0));		//  8 - orange			(YPbPr = 0.375 , -0.707 ,  0.707 )
		TRY_COLOR (vec3 (110.0,  83.0,  11.0));		//  9 - brown			(YPbPr = 0.25  , -0.924 ,  0.383 )
		TRY_COLOR (vec3 (204.0, 127.0, 118.0));		// 10 - light red		(YPbPr = 0.5   , -0.383 ,  0.924 )
		TRY_COLOR (vec3 ( 99.0,  99.0,  99.0));		// 11 - dark grey		(YPbPr = 0.313 ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (139.0, 139.0, 139.0));		// 12 - grey			(YPbPr = 0.469 ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (155.0, 227.0, 157.0));		// 13 - light green		(YPbPr = 0.75  , -0.707 , -0.707 )
		TRY_COLOR (vec3 (138.0, 127.0, 205.0));		// 14 - light blue		(YPbPr = 0.469 ,  1.0   ,  0.0   )
		TRY_COLOR (vec3 (175.0, 175.0, 175.0));		// 15 - light grey		(YPbPr = 0.625  , 0.0   ,  0.0   )
	}

	// MSX compatible computers using a Texas Instruments TMS9918 chip providing a proprietary 15-color YPbPr
	// ... encoded palette with a plus transparent color intended to be used by hardware sprites overlay.
	// ... curiously, TI TMS9918 focuses on 3 shades of green, 3 shades of red, and just 1 shade of grey
	if (m_PaletteMode == 4) {
		//TRY_COLOR(vec3(  0.0,   0.0,   0.0));		//  0 - transparent		(YPbPr = 0.0  ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));		//  1 - black			(YPbPr = 0.0  ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 ( 62.0, 184.0,  73.0));		//  2 - medium green	(YPbPr = 0.53 , -0.509 , -0.755 )
		TRY_COLOR (vec3 (116.0, 208.0, 125.0));		//  3 - light green		(YPbPr = 0.67 , -0.377 , -0.566 )
		TRY_COLOR (vec3 ( 89.0,  85.0, 224.0));		//  4 - dark blue		(YPbPr = 0.40 ,  1.0   , -0.132 )
		TRY_COLOR (vec3 (128.0, 128.0, 241.0));		//  5 - light blue		(YPbPr = 0.53 ,  0.868 , -0.075 )
		TRY_COLOR (vec3 (185.0,  94.0,  81.0));		//  6 - dark red		(YPbPr = 0.47 , -0.321 ,  0.679 )
		TRY_COLOR (vec3 (101.0, 219.0, 239.0));		//  7 - cyan			(YPbPr = 0.73 ,  0.434 , -0.887 )
		TRY_COLOR (vec3 (219.0, 101.0,  89.0));		//  8 - medium red		(YPbPr = 0.53 , -0.377 ,  0.868 )
		TRY_COLOR (vec3 (255.0, 137.0, 125.0));		//  9 - light red		(YPbPr = 0.67 , -0.377 ,  0.868 )
		TRY_COLOR (vec3 (204.0, 195.0,  94.0));		// 10 - dark yellow		(YPbPr = 0.73 , -0.755 ,  0.189 )
		TRY_COLOR (vec3 (222.0, 208.0, 135.0));		// 11 - light yellow	(YPbPr = 0.80 , -0.566 ,  0.189 )
		TRY_COLOR (vec3 ( 58.0, 162.0,  65.0));		// 12 - dark green		(YPbPr = 0.47 , -0.453 , -0.642 )
		TRY_COLOR (vec3 (183.0, 102.0, 181.0));		// 13 - magenta			(YPbPr = 0.53 ,  0.377 ,  0.491 )
		TRY_COLOR (vec3 (204.0, 204.0, 204.0));		// 14 - grey			(YPbPr = 0.80 ,  0.0   ,  0.0   )
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));		// 15 - white			(YPbPr = 1.0  ,  0.0   ,  0.0   )
	}

	// Part Two - IBM RGBi based palettes =============================================================================

	// CGA Mode 4 palette #1 with both intensities (low and high). The good old cyan-magenta "7-color" palette
	if (m_PaletteMode == 5) {
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));		//  0 - black
		TRY_COLOR (vec3 (  0.0, 170.0, 170.0));		//  1 - low intensity cyan
		TRY_COLOR (vec3 (170.0,   0.0, 170.0));		//  2 - low intensity magenta
		TRY_COLOR (vec3 (170.0, 170.0, 170.0));		//  3 - low intensity white / light grey
		TRY_COLOR (vec3 ( 85.0, 255.0, 255.0));		//  4 - high intensity cyan
		TRY_COLOR (vec3 (255.0,  85.0, 255.0));		//  5 - high intensity magenta
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));		//  6 - high intensity grey / bright white
	}


	// 16-color RGBi IBM CGA as seen on registers from compatible monitors back then
	if (m_PaletteMode == 6) {
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));		//  0 - black
		TRY_COLOR (vec3 (  0.0,  25.0, 182.0));		//  1 - low blue
		TRY_COLOR (vec3 (  0.0, 180.0,  29.0));		//  2 - low green
		TRY_COLOR (vec3 (  0.0, 182.0, 184.0));		//  3 - low cyan
		TRY_COLOR (vec3 (196.0,  31.0,  12.0));		//  4 - low red
		TRY_COLOR (vec3 (193.0,  43.0, 182.0));		//  5 - low magenta
		TRY_COLOR (vec3 (193.0, 106.0,  21.0));		//  6 - brown
		TRY_COLOR (vec3 (184.0, 184.0, 184.0));		//  7 - light grey
		TRY_COLOR (vec3 (104.0, 104.0, 104.0));		//  8 - dark grey
		TRY_COLOR (vec3 ( 95.0, 110.0, 252.0));		//  9 - high blue
		TRY_COLOR (vec3 ( 57.0, 250.0, 111.0));		// 10 - high green
		TRY_COLOR (vec3 ( 36.0, 252.0, 254.0));		// 11 - high cyan
		TRY_COLOR (vec3 (255.0, 112.0, 106.0));		// 12 - high red
		TRY_COLOR (vec3 (255.0, 118.0, 253.0));		// 13 - high magenta
		TRY_COLOR (vec3 (255.0, 253.0, 113.0));		// 14 - yellow
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));		// 15 - white
	}

	// Part three - my hand crafted palettes ==========================================================================

	if (m_PaletteMode == 7) {							// 54 COLORS NESish palette
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0)); //vec3 (  0.0,   88.0,   0.0)
		TRY_COLOR (vec3 ( 80.0,  48.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 104.0,   0.0));
		TRY_COLOR (vec3 (  0.0,  64.0,  88.0));
		TRY_COLOR (vec3 (  0.0, 120.0,   0.0));
		TRY_COLOR (vec3 (136.0,  20.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 168.0,   0.0));
		TRY_COLOR (vec3 (168.0,  16.0,   0.0));
		TRY_COLOR (vec3 (168.0,   0.0,  32.0));
		TRY_COLOR (vec3 (  0.0, 168.0,  68.0));
		TRY_COLOR (vec3 (  0.0, 184.0,   0.0));
		TRY_COLOR (vec3 (  0.0,   0.0, 188.0));
		TRY_COLOR (vec3 (  0.0, 136.0, 136.0));
		TRY_COLOR (vec3 (148.0,   0.0, 132.0));
		TRY_COLOR (vec3 ( 68.0,  40.0, 188.0));
		TRY_COLOR (vec3 (120.0, 120.0, 120.0));
		TRY_COLOR (vec3 (172.0, 124.0,   0.0));
		TRY_COLOR (vec3 (124.0, 124.0, 124.0));
		TRY_COLOR (vec3 (228.0,   0.0,  88.0));
		TRY_COLOR (vec3 (228.0,  92.0,  16.0));
		TRY_COLOR (vec3 ( 88.0, 216.0,  84.0));
		TRY_COLOR (vec3 (  0.0,   0.0, 252.0));
		TRY_COLOR (vec3 (248.0,  56.0,   0.0));
		TRY_COLOR (vec3 (  0.0,  88.0, 248.0));
		TRY_COLOR (vec3 (  0.0, 120.0, 248.0));
		TRY_COLOR (vec3 (104.0,  68.0, 252.0));
		TRY_COLOR (vec3 (248.0, 120.0,  88.0));
		TRY_COLOR (vec3 (216.0,   0.0, 204.0));
		TRY_COLOR (vec3 ( 88.0, 248.0, 152.0));
		TRY_COLOR (vec3 (248.0,  88.0, 152.0));
		TRY_COLOR (vec3 (104.0, 136.0, 252.0));
		TRY_COLOR (vec3 (252.0, 160.0,  68.0));
		TRY_COLOR (vec3 (248.0, 184.0,   0.0));
		TRY_COLOR (vec3 (184.0, 248.0,  24.0));
		TRY_COLOR (vec3 (152.0, 120.0, 248.0));
		TRY_COLOR (vec3 (  0.0, 232.0, 216.0));
		TRY_COLOR (vec3 ( 60.0, 188.0, 252.0));
		TRY_COLOR (vec3 (188.0, 188.0, 188.0));
		TRY_COLOR (vec3 (216.0, 248.0, 120.0));
		TRY_COLOR (vec3 (248.0, 216.0, 120.0));
		TRY_COLOR (vec3 (248.0, 164.0, 192.0));
		TRY_COLOR (vec3 (  0.0, 252.0, 252.0));
		TRY_COLOR (vec3 (184.0, 184.0, 248.0));
		TRY_COLOR (vec3 (184.0, 248.0, 184.0));
		TRY_COLOR (vec3 (240.0, 208.0, 176.0));
		TRY_COLOR (vec3 (248.0, 120.0, 248.0));
		TRY_COLOR (vec3 (252.0, 224.0, 168.0));
		TRY_COLOR (vec3 (184.0, 248.0, 216.0));
		TRY_COLOR (vec3 (216.0, 184.0, 248.0));
		TRY_COLOR (vec3 (164.0, 228.0, 252.0));
		TRY_COLOR (vec3 (248.0, 184.0, 248.0));
		TRY_COLOR (vec3 (248.0, 216.0, 248.0));
		TRY_COLOR (vec3 (248.0, 248.0, 248.0));
		TRY_COLOR (vec3 (252.0, 252.0, 252.0));
	}

	else if (m_PaletteMode == 8) {						// 38 COLORS
		TRY_COLOR (vec3 (255.0, 153.0, 153.0)); // L80
		TRY_COLOR (vec3 (255.0, 181.0, 153.0)); // L80
		TRY_COLOR (vec3 (254.0, 255.0, 153.0)); // L80
		TRY_COLOR (vec3 (181.0, 255.0, 153.0)); // L80
		TRY_COLOR (vec3 (153.0, 214.0, 255.0)); // L80
		TRY_COLOR (vec3 (153.0, 163.0, 255.0)); // L80
		TRY_COLOR (vec3 (255.0,  50.0,  50.0)); // L60
		TRY_COLOR (vec3 (255.0, 108.0,  50.0)); // L60
		TRY_COLOR (vec3 (254.0, 255.0,  50.0)); // L60
		TRY_COLOR (vec3 (108.0, 255.0,  50.0)); // L60
		TRY_COLOR (vec3 ( 50.0, 173.0, 255.0)); // L60
		TRY_COLOR (vec3 ( 50.0,  71.0, 255.0)); // L60
		TRY_COLOR (vec3 (204.0,   0.0,   0.0)); // L40
		TRY_COLOR (vec3 (204.0,  57.0,   0.0)); // L40
		TRY_COLOR (vec3 (203.0, 204.0,   0.0)); // L40
		TRY_COLOR (vec3 ( 57.0, 204.0,   0.0)); // L40
		TRY_COLOR (vec3 (  0.0, 122.0, 204.0)); // L40
		TRY_COLOR (vec3 (  0.0,  20.0, 204.0)); // L40
		TRY_COLOR (vec3 (102.0,   0.0,   0.0)); // L20
		TRY_COLOR (vec3 (102.0,  28.0,   0.0)); // L20
		TRY_COLOR (vec3 (101.0, 102.0,   0.0)); // L20
		TRY_COLOR (vec3 ( 28.0, 102.0,   0.0)); // L20
		TRY_COLOR (vec3 (  0.0,  61.0, 102.0)); // L20
		TRY_COLOR (vec3 (  0.0,  10.0, 102.0)); // L20
		TRY_COLOR (vec3 (255.0, 255.0, 255.0)); // L100
		TRY_COLOR (vec3 (226.0, 226.0, 226.0)); // L90
		TRY_COLOR (vec3 (198.0, 198.0, 198.0)); // L80
		TRY_COLOR (vec3 (171.0, 171.0, 171.0)); // L70
		TRY_COLOR (vec3 (145.0, 145.0, 145.0)); // L60
		TRY_COLOR (vec3 (119.0, 119.0, 119.0)); // L50
		TRY_COLOR (vec3 ( 94.0,  94.0,  94.0)); // L40
		TRY_COLOR (vec3 ( 71.0,  71.0,  71.0)); // L30
		TRY_COLOR (vec3 ( 48.0,  48.0,  48.0)); // L20
		TRY_COLOR (vec3 ( 27.0,  27.0,  27.0)); // L10
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0)); // L0
		TRY_COLOR (vec3 (  0.0,   0.0, 255.0)); // L30
		TRY_COLOR (vec3 (255.0,   0.0,   0.0)); // L54
		TRY_COLOR (vec3 (  0.0, 255.0,   0.0)); // L88
	}

	else if (m_PaletteMode == 9) {						// 16 COLORS
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));
		TRY_COLOR (vec3 (255.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 255.0,   0.0));
		TRY_COLOR (vec3 (  0.0,   0.0, 255.0));
		TRY_COLOR (vec3 (255.0, 255.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 255.0, 255.0));
		TRY_COLOR (vec3 (255.0,   0.0, 255.0));
		TRY_COLOR (vec3 (128.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 128.0,   0.0));
		TRY_COLOR (vec3 (  0.0,   0.0, 128.0));
		TRY_COLOR (vec3 (128.0, 128.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 128.0, 128.0));
		TRY_COLOR (vec3 (128.0,   0.0, 128.0));
		TRY_COLOR (vec3 (128.0, 128.0, 128.0));
		TRY_COLOR (vec3 (255.0, 128.0, 128.0));
	}

	else if (m_PaletteMode == 10) {					// 16 COLORS
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));
	    TRY_COLOR (vec3 (255.0, 255.0, 255.0));
	    TRY_COLOR (vec3 (116.0,  67.0,  53.0));
	    TRY_COLOR (vec3 (124.0, 172.0, 186.0));
	    TRY_COLOR (vec3 (123.0,  72.0, 144.0));
	    TRY_COLOR (vec3 (100.0, 151.0,  79.0));
	    TRY_COLOR (vec3 ( 64.0,  50.0, 133.0));
	    TRY_COLOR (vec3 (191.0, 205.0, 122.0));
	    TRY_COLOR (vec3 (123.0,  91.0,  47.0));
	    TRY_COLOR (vec3 ( 79.0,  69.0,   0.0));
	    TRY_COLOR (vec3 (163.0, 114.0, 101.0));
	    TRY_COLOR (vec3 ( 80.0,  80.0,  80.0));
	    TRY_COLOR (vec3 (120.0, 120.0, 120.0));
	    TRY_COLOR (vec3 (164.0, 215.0, 142.0));
	    TRY_COLOR (vec3 (120.0, 106.0, 189.0));
	    TRY_COLOR (vec3 (159.0, 159.0, 150.0));
	}

	else if (m_PaletteMode == 11) {					// 16 COLORS					
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));
		TRY_COLOR (vec3 (152.0,  75.0,  67.0));
		TRY_COLOR (vec3 (121.0, 193.0, 200.0));
		TRY_COLOR (vec3 (155.0,  81.0, 165.0));
		TRY_COLOR (vec3 (202.0, 160.0, 218.0));
		TRY_COLOR (vec3 (202.0, 160.0, 218.0));
		TRY_COLOR (vec3 (202.0, 160.0, 218.0));
		TRY_COLOR (vec3 (202.0, 160.0, 218.0));
		TRY_COLOR (vec3 (191.0, 148.0, 208.0));
		TRY_COLOR (vec3 (179.0, 119.0, 201.0));
		TRY_COLOR (vec3 (167.0, 106.0, 198.0));
		TRY_COLOR (vec3 (138.0, 138.0, 138.0));
		TRY_COLOR (vec3 (163.0, 229.0, 153.0));
		TRY_COLOR (vec3 (138.0, 123.0, 206.0));
		TRY_COLOR (vec3 (173.0, 173.0, 173.0));
	}

	else if (m_PaletteMode == 12) {					// 16 COLORS
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));
		TRY_COLOR (vec3 (255.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 255.0,   0.0));
		TRY_COLOR (vec3 (  0.0,   0.0, 255.0));
		TRY_COLOR (vec3 (255.0,   0.0, 255.0));
		TRY_COLOR (vec3 (255.0, 255.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 255.0, 255.0));
		TRY_COLOR (vec3 (215.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 215.0,   0.0));
		TRY_COLOR (vec3 (  0.0,   0.0, 215.0));
		TRY_COLOR (vec3 (215.0,   0.0, 215.0));
		TRY_COLOR (vec3 (215.0, 215.0,   0.0));
		TRY_COLOR (vec3 (  0.0, 215.0, 215.0));
		TRY_COLOR (vec3 (215.0, 215.0, 215.0));
		TRY_COLOR (vec3 ( 40.0,  40.0,  40.0));
	}

	else if (m_PaletteMode == 13) {					// 13 COLORS
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  1.0,   3.0,  31.0));
		TRY_COLOR (vec3 (  1.0,   3.0,  53.0));
		TRY_COLOR (vec3 ( 28.0,   2.0,  78.0));
		TRY_COLOR (vec3 ( 80.0,   2.0, 110.0));
		TRY_COLOR (vec3 (143.0,   3.0, 133.0));
		TRY_COLOR (vec3 (181.0,   3.0, 103.0));
		TRY_COLOR (vec3 (229.0,   3.0,  46.0));
		TRY_COLOR (vec3 (252.0,  73.0,  31.0));
		TRY_COLOR (vec3 (253.0, 173.0,  81.0));
		TRY_COLOR (vec3 (254.0, 244.0, 139.0));
		TRY_COLOR (vec3 (239.0, 254.0, 203.0));
		TRY_COLOR (vec3 (242.0, 255.0, 236.0));
	}

	else if (m_PaletteMode == 14) {					// 5 COLORS (GREENISH - GAMEBOY)
		TRY_COLOR (vec3 ( 41.0,  57.0,  65.0));
		TRY_COLOR (vec3 ( 72.0,  93.0,  72.0));
		TRY_COLOR (vec3 (133.0, 149.0,  80.0));
		TRY_COLOR (vec3 (186.0, 195.0, 117.0));
		TRY_COLOR (vec3 (242.0, 239.0, 231.0));
	}
	
	else if (m_PaletteMode == 15) {					// 5 COLORS (PURPLEISH)
		TRY_COLOR (vec3 ( 65.0,  49.0,  41.0));
		TRY_COLOR (vec3 ( 93.0,  72.0,  93.0));
		TRY_COLOR (vec3 ( 96.0,  80.0, 149.0));
		TRY_COLOR (vec3 (126.0, 117.0, 195.0));
		TRY_COLOR (vec3 (231.0, 234.0, 242.0));
	}

	else if (m_PaletteMode == 16) {					// 4 COLORS (GREENISH)
		TRY_COLOR (vec3 (156.0, 189.0,  15.0));
		TRY_COLOR (vec3 (140.0, 173.0,  15.0));
		TRY_COLOR (vec3 ( 48.0,  98.0,  48.0));
		TRY_COLOR (vec3 ( 15.0,  56.0,  15.0));
	}
	
	else if (m_PaletteMode == 17) {					// 11 COLORS (GRAYSCALE)
		TRY_COLOR (vec3 (255.0, 255.0, 255.0)); // L100
		TRY_COLOR (vec3 (226.0, 226.0, 226.0)); // L90
		TRY_COLOR (vec3 (198.0, 198.0, 198.0)); // L80
		TRY_COLOR (vec3 (171.0, 171.0, 171.0)); // L70
		TRY_COLOR (vec3 (145.0, 145.0, 145.0)); // L60
		TRY_COLOR (vec3 (119.0, 119.0, 119.0)); // L50
		TRY_COLOR (vec3 ( 94.0,  94.0,  94.0)); // L40
		TRY_COLOR (vec3 ( 71.0,  71.0,  71.0)); // L30
		TRY_COLOR (vec3 ( 48.0,  48.0,  48.0)); // L20
		TRY_COLOR (vec3 ( 27.0,  27.0,  27.0)); // L10
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0)); // L0
	}
	
	else if (m_PaletteMode == 18) {					// 6 COLORS (GRAYSCALE)
		TRY_COLOR (vec3 (255.0, 255.0, 255.0)); // L100
		TRY_COLOR (vec3 (198.0, 198.0, 198.0)); // L80
		TRY_COLOR (vec3 (145.0, 145.0, 145.0)); // L60
		TRY_COLOR (vec3 ( 94.0,  94.0,  94.0)); // L40
		TRY_COLOR (vec3 ( 48.0,  48.0,  48.0)); // L20
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0)); // L0
	}
	
	else if (m_PaletteMode == 19) {					// 3 COLORS (GRAYSCALE)
		TRY_COLOR (vec3 (255.0, 255.0, 255.0)); // L100
		TRY_COLOR (vec3 (145.0, 145.0, 145.0)); // L60
		TRY_COLOR (vec3 ( 48.0,  48.0,  48.0)); // L20
	}
	
	// User modes!
	
	else if (m_PaletteMode == 1000) {					// ZX Spectrum
		// Lights
		TRY_COLOR (vec3 (0.0, 0.0, 0.0));
		TRY_COLOR (vec3 (0.0, 0.0, 255.0));
		TRY_COLOR (vec3 (255.0, 0.0, 0.0));
		TRY_COLOR (vec3 (255.0, 0.0, 255.0));
		TRY_COLOR (vec3 (0.0, 255.0, 0.0));
		TRY_COLOR (vec3 (0.0, 255.0, 255.0));
		TRY_COLOR (vec3 (255.0, 255.0, 0.0));
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));
		// Darks
		TRY_COLOR (vec3 (0.0, 0.0, 0.0));
		TRY_COLOR (vec3 (0.0, 0.0, 216.75));
		TRY_COLOR (vec3 (216.75, 0.0, 0.0));
		TRY_COLOR (vec3 (216.75, 0.0, 216.75));
		TRY_COLOR (vec3 (0.0, 216.75, 0.0));
		TRY_COLOR (vec3 (0.0, 216.75, 216.75));
		TRY_COLOR (vec3 (216.75, 216.75, 0.0));
		TRY_COLOR (vec3 (216.75, 216.75, 216.75));
	}	

	else if (m_PaletteMode == 1001) {					// B & W mono
		TRY_COLOR (vec3 (0.0, 0.0, 0.0));
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));
	}
	
	else if (m_PaletteMode == 1002) {					// Apple II Hi-Res
		// Hi-Res palette from https://en.wikipedia.org/wiki/Apple_II_graphics
		TRY_COLOR (vec3 (0.0, 0.0, 0.0));
		TRY_COLOR (vec3 (255.0, 0.0, 255.0));
		TRY_COLOR (vec3 (0.0, 255.0, 0.0));
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));
		TRY_COLOR (vec3 (0.0, 0.0, 0.0));
		TRY_COLOR (vec3 (0.0, 175.0, 255.0));
		TRY_COLOR (vec3 (255.0, 80.0, 0.0));
		TRY_COLOR (vec3 (255.0, 255.0, 255.0));
	}

	else if (m_PaletteMode == 1003) {					// Aurora 256-colour by DawnBringer: https://lospec.com/palette-list/aurora
		TRY_COLOR (vec3 (  0.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  17.0,   17.0,   17.0));
		TRY_COLOR (vec3 (  34.0,   34.0,   34.0));
		TRY_COLOR (vec3 (  51.0,   51.0,   51.0));
		TRY_COLOR (vec3 (  68.0,   68.0,   68.0));
		TRY_COLOR (vec3 (  85.0,   85.0,   85.0));
		TRY_COLOR (vec3 (  102.0,   102.0,   102.0));
		TRY_COLOR (vec3 (  119.0,   119.0,   119.0));
		TRY_COLOR (vec3 (  136.0,   136.0,   136.0));
		TRY_COLOR (vec3 (  153.0,   153.0,   153.0));
		TRY_COLOR (vec3 (  170.0,   170.0,   170.0));
		TRY_COLOR (vec3 (  187.0,   187.0,   187.0));
		TRY_COLOR (vec3 (  204.0,   204.0,   204.0));
		TRY_COLOR (vec3 (  221.0,   221.0,   221.0));
		TRY_COLOR (vec3 (  238.0,   238.0,   238.0));
		TRY_COLOR (vec3 (  255.0,   255.0,   255.0));
		TRY_COLOR (vec3 (  0.0,   127.0,   127.0));
		TRY_COLOR (vec3 (  63.0,   191.0,   191.0));
		TRY_COLOR (vec3 (  0.0,   255.0,   255.0));
		TRY_COLOR (vec3 (  191.0,   255.0,   255.0));
		TRY_COLOR (vec3 (  129.0,   129.0,   255.0));
		TRY_COLOR (vec3 (  0.0,   0.0,   255.0));
		TRY_COLOR (vec3 (  63.0,   63.0,   191.0));
		TRY_COLOR (vec3 (  0.0,   0.0,   127.0));
		TRY_COLOR (vec3 (  15.0,   15.0,   80.0));
		TRY_COLOR (vec3 (  127.0,   0.0,   127.0));
		TRY_COLOR (vec3 (  191.0,   63.0,   191.0));
		TRY_COLOR (vec3 (  245.0,   0.0,   245.0));
		TRY_COLOR (vec3 (  253.0,   129.0,   255.0));
		TRY_COLOR (vec3 (  255.0,   192.0,   203.0));
		TRY_COLOR (vec3 (  255.0,   129.0,   129.0));
		TRY_COLOR (vec3 (  255.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  191.0,   63.0,   63.0));
		TRY_COLOR (vec3 (  127.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  85.0,   20.0,   20.0));
		TRY_COLOR (vec3 (  127.0,   63.0,   0.0));
		TRY_COLOR (vec3 (  191.0,   127.0,   63.0));
		TRY_COLOR (vec3 (  255.0,   127.0,   0.0));
		TRY_COLOR (vec3 (  255.0,   191.0,   129.0));
		TRY_COLOR (vec3 (  255.0,   255.0,   191.0));
		TRY_COLOR (vec3 (  255.0,   255.0,   0.0));
		TRY_COLOR (vec3 (  191.0,   191.0,   63.0));
		TRY_COLOR (vec3 (  127.0,   127.0,   0.0));
		TRY_COLOR (vec3 (  0.0,   127.0,   0.0));
		TRY_COLOR (vec3 (  63.0,   191.0,   63.0));
		TRY_COLOR (vec3 (  0.0,   255.0,   0.0));
		TRY_COLOR (vec3 (  175.0,   255.0,   175.0));
		TRY_COLOR (vec3 (  0.0,   191.0,   255.0));
		TRY_COLOR (vec3 (  0.0,   127.0,   255.0));
		TRY_COLOR (vec3 (  75.0,   125.0,   200.0));
		TRY_COLOR (vec3 (  188.0,   175.0,   192.0));
		TRY_COLOR (vec3 (  203.0,   170.0,   137.0));
		TRY_COLOR (vec3 (  166.0,   160.0,   144.0));
		TRY_COLOR (vec3 (  126.0,   148.0,   148.0));
		TRY_COLOR (vec3 (  110.0,   130.0,   135.0));
		TRY_COLOR (vec3 (  126.0,   110.0,   96.0));
		TRY_COLOR (vec3 (  160.0,   105.0,   95.0));
		TRY_COLOR (vec3 (  192.0,   120.0,   114.0));
		TRY_COLOR (vec3 (  208.0,   138.0,   116.0));
		TRY_COLOR (vec3 (  225.0,   155.0,   125.0));
		TRY_COLOR (vec3 (  235.0,   170.0,   140.0));
		TRY_COLOR (vec3 (  245.0,   185.0,   155.0));
		TRY_COLOR (vec3 (  246.0,   200.0,   175.0));
		TRY_COLOR (vec3 (  245.0,   225.0,   210.0));
		TRY_COLOR (vec3 (  127.0,   0.0,   255.0));
		TRY_COLOR (vec3 (  87.0,   59.0,   59.0));
		TRY_COLOR (vec3 (  115.0,   65.0,   60.0));
		TRY_COLOR (vec3 (  142.0,   85.0,   85.0));
		TRY_COLOR (vec3 (  171.0,   115.0,   115.0));
		TRY_COLOR (vec3 (  199.0,   143.0,   143.0));
		TRY_COLOR (vec3 (  227.0,   171.0,   171.0));
		TRY_COLOR (vec3 (  248.0,   210.0,   218.0));
		TRY_COLOR (vec3 (  227.0,   199.0,   171.0));
		TRY_COLOR (vec3 (  196.0,   158.0,   115.0));
		TRY_COLOR (vec3 (  143.0,   115.0,   87.0));
		TRY_COLOR (vec3 (  115.0,   87.0,   59.0));
		TRY_COLOR (vec3 (  59.0,   45.0,   31.0));
		TRY_COLOR (vec3 (  65.0,   65.0,   35.0));
		TRY_COLOR (vec3 (  115.0,   115.0,   59.0));
		TRY_COLOR (vec3 (  143.0,   143.0,   87.0));
		TRY_COLOR (vec3 (  162.0,   162.0,   85.0));
		TRY_COLOR (vec3 (  181.0,   181.0,   114.0));
		TRY_COLOR (vec3 (  199.0,   199.0,   143.0));
		TRY_COLOR (vec3 (  218.0,   218.0,   171.0));
		TRY_COLOR (vec3 (  237.0,   237.0,   199.0));
		TRY_COLOR (vec3 (  199.0,   227.0,   171.0));
		TRY_COLOR (vec3 (  171.0,   199.0,   143.0));
		TRY_COLOR (vec3 (  142.0,   190.0,   85.0));
		TRY_COLOR (vec3 (  115.0,   143.0,   87.0));
		TRY_COLOR (vec3 (  88.0,   125.0,   62.0));
		TRY_COLOR (vec3 (  70.0,   80.0,   50.0));
		TRY_COLOR (vec3 (  25.0,   30.0,   15.0));
		TRY_COLOR (vec3 (  35.0,   80.0,   55.0));
		TRY_COLOR (vec3 (  59.0,   87.0,   59.0));
		TRY_COLOR (vec3 (  80.0,   100.0,   80.0));
		TRY_COLOR (vec3 (  59.0,   115.0,   73.0));
		TRY_COLOR (vec3 (  87.0,   143.0,   87.0));
		TRY_COLOR (vec3 (  115.0,   171.0,   115.0));
		TRY_COLOR (vec3 (  100.0,   192.0,   130.0));
		TRY_COLOR (vec3 (  143.0,   199.0,   143.0));
		TRY_COLOR (vec3 (  162.0,   216.0,   162.0));
		TRY_COLOR (vec3 (  225.0,   248.0,   250.0));
		TRY_COLOR (vec3 (  180.0,   238.0,   202.0));
		TRY_COLOR (vec3 (  171.0,   227.0,   197.0));
		TRY_COLOR (vec3 (  135.0,   180.0,   142.0));
		TRY_COLOR (vec3 (  80.0,   125.0,   95.0));
		TRY_COLOR (vec3 (  15.0,   105.0,   70.0));
		TRY_COLOR (vec3 (  30.0,   45.0,   35.0));
		TRY_COLOR (vec3 (  35.0,   65.0,   70.0));
		TRY_COLOR (vec3 (  59.0,   115.0,   115.0));
		TRY_COLOR (vec3 (  100.0,   171.0,   171.0));
		TRY_COLOR (vec3 (  143.0,   199.0,   199.0));
		TRY_COLOR (vec3 (  171.0,   227.0,   227.0));
		TRY_COLOR (vec3 (  199.0,   241.0,   241.0));
		TRY_COLOR (vec3 (  190.0,   210.0,   240.0));
		TRY_COLOR (vec3 (  171.0,   199.0,   227.0));
		TRY_COLOR (vec3 (  168.0,   185.0,   220.0));
		TRY_COLOR (vec3 (  143.0,   171.0,   199.0));
		TRY_COLOR (vec3 (  87.0,   143.0,   199.0));
		TRY_COLOR (vec3 (  87.0,   115.0,   143.0));
		TRY_COLOR (vec3 (  59.0,   87.0,   115.0));
		TRY_COLOR (vec3 (  15.0,   25.0,   45.0));
		TRY_COLOR (vec3 (  31.0,   31.0,   59.0));
		TRY_COLOR (vec3 (  59.0,   59.0,   87.0));
		TRY_COLOR (vec3 (  73.0,   73.0,   115.0));
		TRY_COLOR (vec3 (  87.0,   87.0,   143.0));
		TRY_COLOR (vec3 (  115.0,   110.0,   170.0));
		TRY_COLOR (vec3 (  118.0,   118.0,   202.0));
		TRY_COLOR (vec3 (  143.0,   143.0,   199.0));
		TRY_COLOR (vec3 (  171.0,   171.0,   227.0));
		TRY_COLOR (vec3 (  208.0,   218.0,   248.0));
		TRY_COLOR (vec3 (  227.0,   227.0,   255.0));
		TRY_COLOR (vec3 (  171.0,   143.0,   199.0));
		TRY_COLOR (vec3 (  143.0,   87.0,   199.0));
		TRY_COLOR (vec3 (  115.0,   87.0,   143.0));
		TRY_COLOR (vec3 (  87.0,   59.0,   115.0));
		TRY_COLOR (vec3 (  60.0,   35.0,   60.0));
		TRY_COLOR (vec3 (  70.0,   50.0,   70.0));
		TRY_COLOR (vec3 (  114.0,   64.0,   114.0));
		TRY_COLOR (vec3 (  143.0,   87.0,   143.0));
		TRY_COLOR (vec3 (  171.0,   87.0,   171.0));
		TRY_COLOR (vec3 (  171.0,   115.0,   171.0));
		TRY_COLOR (vec3 (  235.0,   172.0,   225.0));
		TRY_COLOR (vec3 (  255.0,   220.0,   245.0));
		TRY_COLOR (vec3 (  227.0,   199.0,   227.0));
		TRY_COLOR (vec3 (  225.0,   185.0,   210.0));
		TRY_COLOR (vec3 (  215.0,   160.0,   190.0));
		TRY_COLOR (vec3 (  199.0,   143.0,   185.0));
		TRY_COLOR (vec3 (  200.0,   125.0,   160.0));
		TRY_COLOR (vec3 (  195.0,   90.0,   145.0));
		TRY_COLOR (vec3 (  75.0,   40.0,   55.0));
		TRY_COLOR (vec3 (  50.0,   22.0,   35.0));
		TRY_COLOR (vec3 (  40.0,   10.0,   30.0));
		TRY_COLOR (vec3 (  64.0,   24.0,   17.0));
		TRY_COLOR (vec3 (  98.0,   24.0,   0.0));
		TRY_COLOR (vec3 (  165.0,   20.0,   10.0));
		TRY_COLOR (vec3 (  218.0,   32.0,   16.0));
		TRY_COLOR (vec3 (  213.0,   82.0,   74.0));
		TRY_COLOR (vec3 (  255.0,   60.0,   10.0));
		TRY_COLOR (vec3 (  245.0,   90.0,   50.0));
		TRY_COLOR (vec3 (  255.0,   98.0,   98.0));
		TRY_COLOR (vec3 (  246.0,   189.0,   49.0));
		TRY_COLOR (vec3 (  255.0,   165.0,   60.0));
		TRY_COLOR (vec3 (  215.0,   155.0,   15.0));
		TRY_COLOR (vec3 (  218.0,   110.0,   10.0));
		TRY_COLOR (vec3 (  180.0,   90.0,   0.0));
		TRY_COLOR (vec3 (  160.0,   75.0,   5.0));
		TRY_COLOR (vec3 (  95.0,   50.0,   20.0));
		TRY_COLOR (vec3 (  83.0,   80.0,   10.0));
		TRY_COLOR (vec3 (  98.0,   98.0,   0.0));
		TRY_COLOR (vec3 (  140.0,   128.0,   90.0));
		TRY_COLOR (vec3 (  172.0,   148.0,   0.0));
		TRY_COLOR (vec3 (  177.0,   177.0,   10.0));
		TRY_COLOR (vec3 (  230.0,   213.0,   90.0));
		TRY_COLOR (vec3 (  255.0,   213.0,   16.0));
		TRY_COLOR (vec3 (  255.0,   234.0,   74.0));
		TRY_COLOR (vec3 (  200.0,   255.0,   65.0));
		TRY_COLOR (vec3 (  155.0,   240.0,   70.0));
		TRY_COLOR (vec3 (  150.0,   220.0,   25.0));
		TRY_COLOR (vec3 (  115.0,   200.0,   5.0));
		TRY_COLOR (vec3 (  106.0,   168.0,   5.0));
		TRY_COLOR (vec3 (  60.0,   110.0,   20.0));
		TRY_COLOR (vec3 (  40.0,   52.0,   5.0));
		TRY_COLOR (vec3 (  32.0,   70.0,   8.0));
		TRY_COLOR (vec3 (  12.0,   92.0,   12.0));
		TRY_COLOR (vec3 (  20.0,   150.0,   5.0));
		TRY_COLOR (vec3 (  10.0,   215.0,   10.0));
		TRY_COLOR (vec3 (  20.0,   230.0,   10.0));
		TRY_COLOR (vec3 (  125.0,   255.0,   115.0));
		TRY_COLOR (vec3 (  75.0,   240.0,   90.0));
		TRY_COLOR (vec3 (  0.0,   197.0,   20.0));
		TRY_COLOR (vec3 (  5.0,   180.0,   80.0));
		TRY_COLOR (vec3 (  28.0,   140.0,   78.0));
		TRY_COLOR (vec3 (  18.0,   56.0,   50.0));
		TRY_COLOR (vec3 (  18.0,   152.0,   128.0));
		TRY_COLOR (vec3 (  6.0,   196.0,   145.0));
		TRY_COLOR (vec3 (  0.0,   222.0,   106.0));
		TRY_COLOR (vec3 (  45.0,   235.0,   168.0));
		TRY_COLOR (vec3 (  60.0,   254.0,   165.0));
		TRY_COLOR (vec3 (  106.0,   255.0,   205.0));
		TRY_COLOR (vec3 (  145.0,   235.0,   255.0));
		TRY_COLOR (vec3 (  85.0,   230.0,   255.0));
		TRY_COLOR (vec3 (  125.0,   215.0,   240.0));
		TRY_COLOR (vec3 (  8.0,   222.0,   213.0));
		TRY_COLOR (vec3 (  16.0,   156.0,   222.0));
		TRY_COLOR (vec3 (  5.0,   90.0,   92.0));
		TRY_COLOR (vec3 (  22.0,   44.0,   82.0));
		TRY_COLOR (vec3 (  15.0,   55.0,   125.0));
		TRY_COLOR (vec3 (  0.0,   74.0,   156.0));
		TRY_COLOR (vec3 (  50.0,   100.0,   150.0));
		TRY_COLOR (vec3 (  0.0,   82.0,   246.0));
		TRY_COLOR (vec3 (  24.0,   106.0,   189.0));
		TRY_COLOR (vec3 (  35.0,   120.0,   220.0));
		TRY_COLOR (vec3 (  105.0,   157.0,   195.0));
		TRY_COLOR (vec3 (  74.0,   164.0,   255.0));
		TRY_COLOR (vec3 (  144.0,   176.0,   255.0));
		TRY_COLOR (vec3 (  90.0,   197.0,   255.0));
		TRY_COLOR (vec3 (  190.0,   185.0,   250.0));
		TRY_COLOR (vec3 (  120.0,   110.0,   240.0));
		TRY_COLOR (vec3 (  74.0,   90.0,   255.0));
		TRY_COLOR (vec3 (  98.0,   65.0,   246.0));
		TRY_COLOR (vec3 (  60.0,   60.0,   245.0));
		TRY_COLOR (vec3 (  16.0,   28.0,   218.0));
		TRY_COLOR (vec3 (  0.0,   16.0,   189.0));
		TRY_COLOR (vec3 (  35.0,   16.0,   148.0));
		TRY_COLOR (vec3 (  12.0,   33.0,   72.0));
		TRY_COLOR (vec3 (  80.0,   16.0,   176.0));
		TRY_COLOR (vec3 (  96.0,   16.0,   208.0));
		TRY_COLOR (vec3 (  135.0,   50.0,   210.0));
		TRY_COLOR (vec3 (  156.0,   65.0,   255.0));
		TRY_COLOR (vec3 (  189.0,   98.0,   255.0));
		TRY_COLOR (vec3 (  185.0,   145.0,   255.0));
		TRY_COLOR (vec3 (  215.0,   165.0,   255.0));
		TRY_COLOR (vec3 (  215.0,   195.0,   250.0));
		TRY_COLOR (vec3 (  248.0,   198.0,   252.0));
		TRY_COLOR (vec3 (  230.0,   115.0,   255.0));
		TRY_COLOR (vec3 (  255.0,   82.0,   255.0));
		TRY_COLOR (vec3 (  218.0,   32.0,   224.0));
		TRY_COLOR (vec3 (  189.0,   41.0,   255.0));
		TRY_COLOR (vec3 (  189.0,   16.0,   197.0));
		TRY_COLOR (vec3 (  140.0,   20.0,   190.0));
		TRY_COLOR (vec3 (  90.0,   24.0,   123.0));
		TRY_COLOR (vec3 (  100.0,   20.0,   100.0));
		TRY_COLOR (vec3 (  65.0,   0.0,   98.0));
		TRY_COLOR (vec3 (  50.0,   10.0,   70.0));
		TRY_COLOR (vec3 (  85.0,   25.0,   55.0));
		TRY_COLOR (vec3 (  160.0,   25.0,   130.0));
		TRY_COLOR (vec3 (  200.0,   0.0,   120.0));
		TRY_COLOR (vec3 (  255.0,   80.0,   191.0));
		TRY_COLOR (vec3 (  255.0,   106.0,   197.0));
		TRY_COLOR (vec3 (  250.0,   160.0,   185.0));
		TRY_COLOR (vec3 (  252.0,   58.0,   140.0));
		TRY_COLOR (vec3 (  230.0,   30.0,   120.0));
		TRY_COLOR (vec3 (  189.0,   16.0,   57.0));
		TRY_COLOR (vec3 (  152.0,   52.0,   77.0));
		TRY_COLOR (vec3 (  145.0,   20.0,   55.0));
	}

	else if (m_PaletteMode == 1004) {					// Amstrad CPC
		TRY_COLOR (vec3 (  4.0,   4.0,   4.0));
		TRY_COLOR (vec3 (  128.0,   128.0,   128.0));
		TRY_COLOR (vec3 (  255.0,   255.0,   255.0));
		TRY_COLOR (vec3 (  128.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  255.0,   0.0,   0.0));
		TRY_COLOR (vec3 (  255.0,   128.0,   128.0));
		TRY_COLOR (vec3 (  255.0,   127.0,   0.0));
		TRY_COLOR (vec3 (  255.0,   255.0,   128.0));
		TRY_COLOR (vec3 (  255.0,   255.0,   0.0));
		TRY_COLOR (vec3 (  128.0,   128.0,   0.0));
		TRY_COLOR (vec3 (  0.0,   128.0,   0.0));
		TRY_COLOR (vec3 (  1.0,   255.0,   0.0));
		TRY_COLOR (vec3 (  128.0,   255.0,   0.0));
		TRY_COLOR (vec3 (  128.0,   255.0,   128.0));
		TRY_COLOR (vec3 (  1.0,   255.0,   128.0));
		TRY_COLOR (vec3 (  0.0,   128.0,   128.0));
		TRY_COLOR (vec3 (  1.0,   255.0,   255.0));
		TRY_COLOR (vec3 (  128.0,   255.0,   255.0));
		TRY_COLOR (vec3 (  0.0,   128.0,   255.0));
		TRY_COLOR (vec3 (  0.0,   0.0,   255.0));
		TRY_COLOR (vec3 (  0.0,   0.0,   127.0));
		TRY_COLOR (vec3 (  127.0,   0.0,   255.0));
		TRY_COLOR (vec3 (  128.0,   128.0,   255.0));
		TRY_COLOR (vec3 (  255.0,   128.0,   255.0));
		TRY_COLOR (vec3 (  255.0,   0.0,   255.0));
		TRY_COLOR (vec3 (  255.0,   0.0,   128.0));
		TRY_COLOR (vec3 (  128.0,   0.0,   128.0));
	}

//	COPY TO ADD NEW SHADER!

//	else if (m_PaletteMode == 10xx) {					// NAME HERE
//	}

	return old;
}

// Ho-lee... !

float dither_matrix (float x, float y) {
	return mix(mix(mix(mix(mix(mix(0.0,32.0,step(1.0,y)),mix(8.0,40.0,step(3.0,y)),step(2.0,y)),mix(mix(2.0,34.0,step(5.0,y)),mix(10.0,42.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(48.0,16.0,step(1.0,y)),mix(56.0,24.0,step(3.0,y)),step(2.0,y)),mix(mix(50.0,18.0,step(5.0,y)),mix(58.0,26.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(1.0,x)),mix(mix(mix(mix(12.0,44.0,step(1.0,y)),mix(4.0,36.0,step(3.0,y)),step(2.0,y)),mix(mix(14.0,46.0,step(5.0,y)),mix(6.0,38.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(60.0,28.0,step(1.0,y)),mix(52.0,20.0,step(3.0,y)),step(2.0,y)),mix(mix(62.0,30.0,step(5.0,y)),mix(54.0,22.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(3.0,x)),step(2.0,x)),mix(mix(mix(mix(mix(3.0,35.0,step(1.0,y)),mix(11.0,43.0,step(3.0,y)),step(2.0,y)),mix(mix(1.0,33.0,step(5.0,y)),mix(9.0,41.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(51.0,19.0,step(1.0,y)),mix(59.0,27.0,step(3.0,y)),step(2.0,y)),mix(mix(49.0,17.0,step(5.0,y)),mix(57.0,25.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(5.0,x)),mix(mix(mix(mix(15.0,47.0,step(1.0,y)),mix(7.0,39.0,step(3.0,y)),step(2.0,y)),mix(mix(13.0,45.0,step(5.0,y)),mix(5.0,37.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(63.0,31.0,step(1.0,y)),mix(55.0,23.0,step(3.0,y)),step(2.0,y)),mix(mix(61.0,29.0,step(5.0,y)),mix(53.0,21.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(7.0,x)),step(6.0,x)),step(4.0,x));
}

vec3 dither (vec3 col, vec2 uv) {	
	col *= 255.0;// * BRIGHTNESS;
	col += dither_matrix (mod (float (m_TextureWidth) * uv.x, 8.0), mod (float (m_TextureHeight) * uv.y, 8.0));
	col = find_closest (clamp (col, 0.0, 255.0));
	return col / 255.0;
}

vec3 brightnessContrast(vec3 value, float frag_brightness, float frag_contrast)
{
	// brightnessContrast: Thanks to Alain Galvan,
	// http://alaingalvan.tumblr.com/post/79864187609/glsl-color-correction-shaders
    return (value - 0.5) * frag_contrast + 0.5 + frag_brightness;
}

vec3 RetroRGB (vec4 color, float frag_brightness, float frag_contrast, bool dithering)
{
	// Fix scene. (In demo's case, quite washed-out, so we boost the contrast in particular.)
	
	color.rgb = brightnessContrast (color.rgb, frag_brightness, frag_contrast);
	
	// Dither...
	
	if (dithering)
	{
		return dither (color.rgb, v_TexCoord0);
	}
	
	// Don't dither...
	
	return find_closest (color.rgb * 255.0);
}

void main ()
{
	vec4 pixels		= texture2D (m_ImageTexture0, v_TexCoord0);
	vec3 new_rgb	= RetroRGB (pixels, m_Brightness, m_Contrast, m_Dither);

	if (m_Toggle)
	{
		gl_FragColor = vec4 (new_rgb, 1.0);
	}
	else
	{
		gl_FragColor = pixels;
	}
}
