float random (vec2 st) {
    return fract(sin(dot(st.xy,
                         m_RandomModifier))*
        43758.5453123);
}


// http://aggregate.org/MAGIC/#Same%20Within%20Tolerance
// abs(a - b) < c

