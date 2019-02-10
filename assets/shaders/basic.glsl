
// Scroll down to FRAGMENT_BEGINS!

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

// ----------------------------------
// FRAGMENT_BEGINS
// ----------------------------------

uniform sampler2D	m_ImageTexture0;
uniform bool		m_Toggle;

void main(){

	vec4 rgba = texture2D(m_ImageTexture0, v_TexCoord0);
	
	if (m_Toggle)
	{

		vec4 new_rgba;
		
		// Do stuff to new_rgba...
		
		rgba = new_rgba;

	}
	gl_FragColor = rgba;
}
