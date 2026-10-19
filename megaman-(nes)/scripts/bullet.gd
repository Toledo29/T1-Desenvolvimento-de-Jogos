extends Area2D

signal returned(bullet)

@export var speed: float = 300.0
@export var damage: int = 1
@export var target_group: String = "enemy"

var _dir: int = 1
var _active: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	$Notifier.screen_exited.connect(deactivate)

func activate(pos: Vector2, direction: int) -> void:
	global_position = pos
	_dir = direction
	_active = true
	visible = true
	set_deferred("monitoring", true)
	set_physics_process(true)

func deactivate() -> void:
	if not _active and not visible:
		return
	_active = false
	visible = false
	set_deferred("monitoring", false)
	set_physics_process(false)
	returned.emit(self)

func _physics_process(delta: float) -> void:
	global_position.x += _dir * speed * delta

func _on_body_entered(body: Node) -> void:
	if not _active:
		return
	# Ignora colisão com quem disparou (ex.: tiro do player não acerta o próprio player)
	if target_group == "enemy" and body.is_in_group("player"):
		return
	if target_group == "player" and body.is_in_group("enemy"):
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	deactivate()

func _on_area_entered(area: Area2D) -> void:
	if not _active:
		return
	var target = area.get_parent()
	if target == null:
		return
	if target_group == "enemy" and target.is_in_group("player"):
		return
	if target_group == "player" and target.is_in_group("enemy"):
		return
	if target.has_method("take_damage"):
		target.take_damage(damage)
		deactivate()
