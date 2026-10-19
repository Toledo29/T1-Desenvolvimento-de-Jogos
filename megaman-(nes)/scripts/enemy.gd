extends CharacterBody2D

@export var speed: float = 45.0
@export var patrol_distance: float = 36.0
@export var contact_damage: int = 4
@export var shoot_interval: float = 1.8

@onready var health: Node = $Health
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var hitbox: Area2D = $Hitbox
@onready var enemy_bullet_pool: Node = get_node_or_null("../BossBulletPool")

var _start_x: float = 0.0
var _dir: int = -1
var _flash_timer: float = 0.0
var _shoot_timer: float = 1.2
var _player: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	_start_x = global_position.x
	sprite.play("default")
	sprite.flip_h = (_dir > 0)
	muzzle.position.x = abs(muzzle.position.x) * _dir
	health.died.connect(_on_died)
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

	if not is_on_floor():
		velocity += get_gravity() * delta

	velocity.x = _dir * speed
	move_and_slide()

	if is_on_wall() or abs(global_position.x - _start_x) >= patrol_distance:
		_dir *= -1
		sprite.flip_h = (_dir > 0)
		muzzle.position.x = abs(muzzle.position.x) * _dir

	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	_shoot_timer -= delta
	if _shoot_timer <= 0.0:
		if _player != null and abs(_player.global_position.x - global_position.x) <= 220.0:
			if enemy_bullet_pool != null:
				enemy_bullet_pool.shoot(muzzle.global_position, _dir)
		_shoot_timer = shoot_interval

	# Verifica contato contínuo com o jogador
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(contact_damage)

func take_damage(amount: int) -> void:
	sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
	_flash_timer = 0.1
	health.take_damage(amount)

func _on_died() -> void:
	queue_free()
