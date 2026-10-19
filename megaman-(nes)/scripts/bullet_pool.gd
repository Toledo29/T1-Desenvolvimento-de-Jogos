extends Node2D

@export var bullet_scene: PackedScene
@export var pool_size: int = 3

var _pool: Array[Node] = []

func _ready() -> void:
	if bullet_scene == null:
		bullet_scene = load("res://scenes/bullet.tscn")
	for i in pool_size:
		var b = bullet_scene.instantiate()
		add_child(b)
		b.deactivate()
		b.returned.connect(_on_bullet_returned)
		_pool.append(b)

# Devolve true se conseguiu disparar, false se o pool está vazio
func shoot(from_pos: Vector2, direction: int) -> bool:
	if _pool.is_empty():
		return false
	var b = _pool.pop_back()
	b.activate(from_pos, direction)
	return true

func _on_bullet_returned(b: Node) -> void:
	if not _pool.has(b):
		_pool.append(b)
