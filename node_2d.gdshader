shader_type spatial;
// 【关键】cull_disabled 必须开启！这样显卡才会去画被切开后的内壁（背面）
render_mode unshaded, cull_disabled; 

uniform vec4 fill_color : source_color = vec4(0.0, 1.0, 0.0, 1.0); // 填充纯色
uniform float slice_distance = 5.0; // 5米切面

void fragment() {
	float depth = -VERTEX.z;
	
	// 1. 任何比 5 米近的像素（包含物体的正面外壳），统统擦除
	if (depth < slice_distance) {
		discard;
	}
	
	// 2. 此时，只有距离大于 5 米的像素能活下来。
	// 我们用 FRONT_FACING 判断：如果它不是正面（即它是物体的内壁背面）
	if (!FRONT_FACING) {
		ALBEDO = fill_color.rgb; // 强制涂成纯色（比如绿色）
	} else {
		// 如果是大于 5 米的正面（比如切片后面的其他完整 3D 物体）
		// 如果你们不想看到它，直接 discard；如果想当成纯色背景，就保留
		discard; 
	}
}