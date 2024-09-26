extern float sunset_intensity;

// apply effect
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    return mix(pixel, vec4(1.0, 0.3, 0.1, pixel.a), sunset_intensity * 0.25);
}