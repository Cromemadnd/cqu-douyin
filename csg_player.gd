extends CharacterBody3D # 或者 Node3D，取决于你的 Player 类型

# 使用 % 唯一节点功能，或者直接拖拽引用你的 CSG 节点
@onready var csg_player: CSGBox3D = $"../CSGCombiner3D/CSGBox3D_Player" 

func _process(_delta: float) -> void:
	if csg_player:
		# 核心：直接同步全局变换（包含位置、旋转和缩放）
		csg_player.global_transform = self.global_transform
