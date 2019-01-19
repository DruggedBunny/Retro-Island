
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


uniform sampler2D m_ImageTexture0;

uniform bool m_Toggle;
uniform bool m_Attr;

uniform float m_Brightness;
uniform float m_Contrast;
uniform float m_GridSize;

uniform int m_TextureWidth;
uniform int m_TextureHeight;

// ------------------------------------------------------------------------
// Standard colour index...
// ------------------------------------------------------------------------

const int COLORS		= 16;

const int BLACK			= 0;
const int BLUE			= 1;
const int RED			= 2;
const int MAGENTA		= 3;
const int GREEN			= 4;
const int CYAN			= 5;
const int YELLOW		= 6;
const int WHITE			= 7;

const int DARKBLACK		= 8;
const int DARKBLUE		= 9;
const int DARKRED		= 10;
const int DARKMAGENTA	= 11;
const int DARKGREEN		= 12;
const int DARKCYAN		= 13;
const int DARKYELLOW	= 14;
const int DARKWHITE		= 15;

// brightnessContrast: Thanks to Alain Galvan, http://alaingalvan.tumblr.com/post/79864187609/glsl-color-correction-shaders

vec3 brightnessContrast(vec3 value, float frag_brightness, float frag_contrast)
{
    return (value - 0.5) * frag_contrast + 0.5 + frag_brightness;
}

// luma: Thanks to hughsk, https://github.com/hughsk/glsl-luma

// License applicable to luma() function:

// This software is released under the MIT license:
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

float luma (vec3 color)
{
  return dot (color, vec3 (0.299, 0.587, 0.114));
}

vec3 SpeccyRGB (vec4 color, float frag_brightness, float frag_contrast)
{
	// Hard-coded brightness/contrast tweaks for Island Demo (very pale colours, not Speccy-friendly)...
	
//	vec3 new_rgb				= vec3 (brightnessContrast (color.rgb, -1.25, 12.5));
	vec3 new_rgb				= vec3 (brightnessContrast (color.rgb, frag_brightness, frag_contrast));
	
	// Convert result to Speccy colours (rgb = 1 or 0, 1 or 0, 1 or 0!)...
	
	new_rgb						= vec3 (step (0.333, new_rgb));

	// Tweak Speccy colour so < 0.5 brightness is treated as dark -- 85% voltage applied, apparently. More hard-coding...
	
	float speccy_brightness		= luma (color.rgb) < 0.5 ? 0.85 : 1.0;
	
	// Resulting RGB...
	
	return vec3 (new_rgb * speccy_brightness);
}

void main ()
{
	vec4 pixels						= texture2D (m_ImageTexture0, v_TexCoord0);
	
	vec2 texel_pos					= v_TexCoord0 * vec2 (m_TextureWidth, m_TextureHeight);
	ivec2 int_texel_pos				= ivec2 (texel_pos);
	
	vec3 new_rgb					= SpeccyRGB (pixels, m_Brightness, m_Contrast);
	
	int color_count [COLORS];

	for (int zero_out = 0; zero_out < COLORS; zero_out++)
	{
		color_count[zero_out] = 0;
	}
	
	vec3 color [COLORS];

	color [BLACK]		= vec3 (0.0, 0.0, 0.0);
	color [BLUE]		= vec3 (0.0, 0.0, 1.0);
	color [RED]			= vec3 (1.0, 0.0, 0.0);
	color [MAGENTA]		= vec3 (1.0, 0.0, 1.0);
	color [GREEN]		= vec3 (0.0, 1.0, 0.0);
	color [CYAN]		= vec3 (0.0, 1.0, 1.0);
	color [YELLOW]		= vec3 (1.0, 1.0, 0.0);
	color [WHITE]		= vec3 (1.0, 1.0, 1.0);

	color [DARKBLACK]	= vec3 (0.0, 0.0, 0.0);
	color [DARKBLUE]	= vec3 (0.0, 0.0, 0.85);
	color [DARKRED]		= vec3 (0.85, 0.0, 0.0);
	color [DARKMAGENTA]	= vec3 (0.85, 0.0, 0.85);
	color [DARKGREEN]	= vec3 (0.0, 0.85, 0.0);
	color [DARKCYAN]	= vec3 (0.0, 0.85, 0.85);
	color [DARKYELLOW]	= vec3 (0.85, 0.85, 0.0);
	color [DARKWHITE]	= vec3 (0.85, 0.85, 0.85);

	if (m_Attr)
	{
		vec2 texture_size			= vec2 (m_TextureWidth, m_TextureHeight);
		vec2 grid8x8_offset			= vec2 (floor (mod (float (int_texel_pos.x), m_GridSize)), floor (mod (float (int_texel_pos.y), m_GridSize)));
		
		int color_index	= 0;
		
		vec3 bgcolor;
		vec3 fgcolor;
		vec3 altcolor;
		
		vec2 grid_offset;
		vec2 grid_pos;
	
		int grid_x					= int (max (texel_pos.x - grid8x8_offset.x, 0.0));
		int grid_y					= int (max (texel_pos.y - grid8x8_offset.y, 0.0));
		
		grid_offset = vec2 (grid_x, grid_y);
		grid_pos	= (v_TexCoord0 + grid_offset) / texture_size;
		bgcolor		= SpeccyRGB (texture2D (m_ImageTexture0, grid_pos), m_Brightness, m_Contrast);
		
		int grid_center_x			= grid_x + 4;
		int grid_center_y			= grid_y + 4;
		
		grid_offset = vec2 (grid_center_x, grid_center_y);
		grid_pos	= (v_TexCoord0 + grid_offset) / texture_size;
		fgcolor		= SpeccyRGB (texture2D (m_ImageTexture0, grid_pos), m_Brightness, m_Contrast);
	

		if ((fgcolor == bgcolor) && (bgcolor != color [BLACK]))
		{
			fgcolor = color [BLACK];
		}
	
		// REVIEW LOGIC!! Lost track...
		
		if (new_rgb != bgcolor)
		{
			new_rgb = fgcolor;
		}
		else
		{
			new_rgb = bgcolor;
		}

	}
	
	
	if (m_Toggle)
	{

		// Dot grid...
		
//		if ((int_texel_pos.x == int (max (texel_pos.x - grid8x8.x, 0.0))) && (int_texel_pos.y == int (max (texel_pos.y - grid8x8.y, 0.0))))
//		{
//			new_rgb = vec3 (1.0, 1.0, 1.0);
//		}

		gl_FragColor = vec4 (new_rgb, 1.0);
	}
	else
	{
		gl_FragColor = pixels;
	}
		
}
