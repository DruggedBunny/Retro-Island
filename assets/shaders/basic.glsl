
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

// m_Toggle is filled-in by image.Material.SetInt ("Toggle", toggle)
// m_ prefix is automatically added by mojo...

uniform bool m_Toggle;

void main(){



	// Store "this" pixel's original colour:
	
	vec4 color = texture2D(m_ImageTexture0, v_TexCoord0);
	
	
	
	// Average out the RGB values:
	
	float average_rgb = ((color.r + color.g + color.b) * 0.333);

	
	
	// Build a new vec4 value with RGB each set to average_rgb, and alpha of 1.0:
	
	vec4 bw = vec4(average_rgb, average_rgb, average_rgb, 1.0);
	
	
	
	// If Toggle = True, set to B & W version of pixel, else draw default.
	// (gl_FragColor is the resulting pixel colour.)
	
	if (m_Toggle)
	{
		gl_FragColor = bw;
	}
	else
	{
		gl_FragColor = color;
	}
	
	
}
