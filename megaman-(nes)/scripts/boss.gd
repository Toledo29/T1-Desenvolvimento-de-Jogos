# boss.gd
# Chefe no final da fase (3ª tela - Pickelman Gigante): salta, persegue o jogador e arremessa picaretas.
extends CharacterBody2D

@export var move_speed: float = 70.0
@export var jump_velocity: float = -255.0
@export var contact_damage: int = 6

@onready var health: Node = $Health
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var muzzle: Marker2D = $Muzzle
@onready var hitbox: Area2D = $Hitbox
@onready var boss_bullet_pool: Node = get_node_or_null("../BossBulletPool")

var _player: Node2D = null
var _active: bool = false
var _action_timer: float = 1.0
var _shoot_timer: float = 1.4
var _facing: int = -1
var _flash_timer: float = 0.0

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	sprite.play("idle")
	health.died.connect(_on_died)
	_player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)

	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player")

	# Ativa o chefe quando o jogador entra na última tela (arena do chefe)
	if not _active and _player != null:
		if _player.global_position.x >= 470.0:
			_active = true

	if not is_on_floor():
		velocity += get_gravity() * delta

	if _active and _player != null:
		# Os sprites do Pickelman olham para a esquerda por padrão
		_facing = 1 if _player.global_position.x > global_position.x else -1
		sprite.flip_h = (_facing > 0)
		muzzle.position.x = abs(muzzle.position.x) * _facing

		# Saltos periódicos
		_action_timer -= delta
		if _action_timer <= 0.0 and is_on_floor():
			velocity.y = jump_velocity
			velocity.x = _facing * move_speed
			_action_timer = 1.35

		if is_on_floor() and _action_timer < 1.1:
			velocity.x = move_toward(velocity.x, _facing * (move_speed * 0.55), 300.0 * delta)

		# Alterna animação entre pulo e ataque
		if not is_on_floor():
			if sprite.animation != &"jump":
				sprite.play("jump")
		else:
			if sprite.animation != &"attack":
				sprite.play("attack")

		# Disparos periódicos usando pool de projéteis do chefe
		_shoot_timer -= delta
		if _shoot_timer <= 0.0:
			if boss_bullet_pool != null:
				boss_bullet_pool.shoot(muzzle.global_position, _facing)
			_shoot_timer = 1.25
	else:
		if sprite.animation != &"idle":
			sprite.play("idle")

	move_and_slide()

	# Dano de contato com o jogador
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(contact_damage)

func take_damage(amount: int) -> void:
	_active = true
	sprite.modulate = Color(2.5, 2.5, 2.5, 1.0)
	_flash_timer = 0.1
	health.take_damage(amount)

func _on_died() -> void:
	queue_free()
