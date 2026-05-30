extends Node3D
## 把 map 下所有 MeshInstance3D 替换成“切面”材质。
## 配合正交相机：相机的近裁剪面 = 切刀，相机沿 Z 移动即移动切面。
## 原理见 slice_cap.gdshader 顶部注释（用深度缓冲当蒙版，无需 stencil）。

## 在检查器里拖入 slice_cap.gdshader
@export var slice_shader : Shader

## 截面填充色（被切开的内部显示成这个色）
@export var fill_color : Color = Color(0.8, 0.8, 0.8, 1.0)

## “空”的颜色，必须等于相机 Environment 的背景色，否则没被切到的外表面会露出来
@export var empty_color : Color = Color(0.0, 0.0, 0.0, 1.0)

func _ready() -> void:
	if not slice_shader:
		push_error("请在 map 节点上关联 slice_cap.gdshader！")
		return
	var count := _apply_slice_effect_recursive(self)
	print("地图切面材质批量改造完成，共处理 ", count, " 个 MeshInstance3D")

## 返回处理过的网格数量
func _apply_slice_effect_recursive(current_node: Node) -> int:
	var count := 0
	if current_node is MeshInstance3D:
		_apply_to_mesh(current_node as MeshInstance3D)
		count += 1
	for child in current_node.get_children():
		count += _apply_slice_effect_recursive(child)
	return count

func _apply_to_mesh(mesh_inst: MeshInstance3D) -> void:
	var shader_mat := ShaderMaterial.new()
	shader_mat.shader = slice_shader
	shader_mat.set_shader_parameter("fill_color", fill_color)
	shader_mat.set_shader_parameter("empty_color", empty_color)

	# material_override 会无视模型自带的所有 surface 材质，
	# 用同一个切面材质统一渲染整个网格，正是我们想要的效果。
	mesh_inst.material_override = shader_mat
