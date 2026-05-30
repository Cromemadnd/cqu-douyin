shader_type spatial;
// cull_disabled: 正面和反面都渲染（我们要同时拿到外表面和内表面）
// unshaded: 不参与光照，保证外表面输出的颜色精确等于背景色（否则光照会让它“露馅”）
// depth_draw_opaque + depth_test_default: 正常写深度、做深度测试，这是“蒙版”的核心
render_mode cull_disabled, unshaded, depth_draw_opaque, depth_test_default;

// 截面填充色：被相机近裁剪面切开的内部，显示成这个颜色
uniform vec4 fill_color : source_color = vec4(0.8, 0.8, 0.8, 1.0);

// “空”的颜色：外表面（正面）会被画成这个颜色，从而在画面上“隐身”。
// 必须和相机环境(Environment)的背景色完全一致，否则没被切到的外表面会露出来。
// 你的场景背景是纯色且默认黑色，所以这里默认黑色即可。
uniform vec4 empty_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

void fragment() {
	if (FRONT_FACING) {
		// 外表面（朝向相机的正面）：画成背景色 => 看不见。
		// 但它照常写入深度缓冲，于是充当“蒙版”——
		// 凡是被它挡住的内表面都会因深度测试失败而被隐藏。
		ALBEDO = empty_color.rgb;
	} else {
		// 内表面（背面）：只有当它前面没有外表面遮挡时
		//（也就是被近裁剪面切开、外表面被裁掉的缺口处）
		// 才能通过深度测试显示出来 —— 这就是你要的截面。
		ALBEDO = fill_color.rgb;
	}
}
