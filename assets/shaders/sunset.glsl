extern float sunset_intensity;

// ease in expo function
float easeInExpo(float x){
    return x == 0 ? 0.0 : pow(2, 10 * x - 10); 
}

// apply effect
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec4 pixel = Texel(texture, texture_coords);

    float gradient = 1 - easeInExpo(screen_coords.y / love_ScreenSize.y) * 0.5;
    float new_sunset_intensity = sunset_intensity * gradient;
    
    return mix(pixel, vec4(1.0, 0.3, 0.1, pixel.a), new_sunset_intensity * 0.3);
}