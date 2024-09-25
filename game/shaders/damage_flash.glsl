extern float flash_intensity;

// apply effect
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);
    return mix(pixel, vec4(1.0, 1.0, 1.0, pixel.a), flash_intensity * 0.8) * color;
}