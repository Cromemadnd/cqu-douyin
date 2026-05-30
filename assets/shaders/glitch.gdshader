shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// --- 控制参数 ---
uniform float grain_amount : hint_range(0.0, 0.3) = 0.5;       // 噪点强度（微小噪点需要稍微调高一点才明显）
uniform float grain_size : hint_range(1.0, 100.0) = 45.0;       // 【关键】默认值调大，颗粒会变得非常细腻
uniform float flicker_intensity : hint_range(0.0, 0.2) = 0.03;   
uniform float scratch_intensity : hint_range(0.0, 0.5) = 0.12;   

// 改进的噪点生成：增加高频噪声，防止小噪点糊掉
float grain_noise(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec4 SCREEN_COLOR = texture(screen_texture, SCREEN_UV);
    
    // 胶片快门速度（24帧）
    float grain_time = floor(TIME * 24.0); 
    
    // 计算微小噪点坐标
    vec2 uv_grained = SCREEN_UV * grain_size;
    // 加上时间偏移
    float noise = grain_noise(uv_grained + vec2(grain_time * 0.13, grain_time * 0.71)) - 0.5;
    
    // 呼吸感（乘法混合）
    float flicker = 1.0 + (grain_noise(vec3(grain_time).xy) - 0.5) * flicker_intensity;
    vec3 base_color = SCREEN_COLOR.rgb * flicker;
    
    // Overlay 混合（保证黑白灰对比度）
    vec3 final_color;
    for (int i = 0; i < 3; i++) {
        if (base_color[i] < 0.5) {
            final_color[i] = base_color[i] + 2.0 * noise * grain_amount * base_color[i];
        } else {
            final_color[i] = base_color[i] + 2.0 * noise * grain_amount * (1.0 - base_color[i]);
        }
    }
    
    // 随机刮痕
    float scratch = 0.0;
    if (grain_noise(vec2(grain_time, 1.0)) > 0.90) { 
        float scratch_x = grain_noise(vec2(grain_time, 2.0)); 
        scratch = smoothstep(0.0012, 0.0, abs(SCREEN_UV.x - scratch_x)) * grain_noise(vec2(SCREEN_UV.y, grain_time));
    }
    if (grain_noise(vec2(grain_time, 3.0)) > 0.5) {
        final_color -= scratch * scratch_intensity;
    } else {
        final_color += scratch * scratch_intensity * 0.6;
    }

    COLOR = vec4(final_color, SCREEN_COLOR.a);
}