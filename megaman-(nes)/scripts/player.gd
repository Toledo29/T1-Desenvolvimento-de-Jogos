# player.gd
extends CharacterBody2D

const SPEED: float = 100.0
const JUMP_VELOCITY: float = -270.0
const INVULN_DURATION: float = 0.8

@onready var bullet_pool: Node = get_node_or_null("../BulletPool")
@onready var muzzle: Marker2D = $Muzzle
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var health: Node = $Health

var facing: int = 1   # 1 = direita, -1 = esquerda
var _invuln_timer: float = 0.0
var _muzzle_offset_x: float = 12.0
var _dead: bool = false

func _ready() -> void:
	add_to_group("player")
	_muzzle_offset_x = abs(muzzle.position.x)
	# Os sprites originais olham para a esquerda, então flip_h = true quando olha para a direita
	sprite.flip_h = (facing > 0)
	sprite.play("idle")
	health.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	if _dead:
		return

	# Tempo de invulnerabilidade após sofrer dano (pisca o sprite)
	if _invuln_timer > 0.0:
		_invuln_timer -= delta
		sprite.visible = int(_invuln_timer * 15.0) % 2 == 0
		if _invuln_timer <= 0.0:
			sprite.visible = true

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo (Mega Man permite soltar o botão para pulo mais curto)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_released("jump") and velocity.y < -80.0:
		velocity.y = -80.0

	# Movimentação horizontal
	var direction := Input.get_axis("move_left", "move_right")
	if direction != 0.0:
		velocity.x = direction * SPEED
		facing = 1 if direction > 0.0 else -1
		sprite.flip_h = (facing > 0)
		muzzle.position.x = _muzzle_offset_x * facing
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Atualiza animação conforme estado (no ar, correndo ou parado)
	if not is_on_floor():
		if sprite.animation != &"jump":
			sprite.play("jump")
	elif direction != 0.0:
		if sprite.animation != &"walk":
			sprite.play("walk")
	else:
		if sprite.animation != &"idle":
			sprite.play("idle")

	move_and_slide()

	# Disparo usando Object Pool
	if Input.is_action_just_pressed("shoot") and bullet_pool != null:
		bullet_pool.shoot(muzzle.global_position, facing)

	# Queda em buraco / abismo resulta em perda total de energia
	if global_position.y > 260.0:
		health.take_damage(health.current)

func take_damage(amount: int) -> void:
	if _dead or _invuln_timer > 0.0:
		return
	_invuln_timer = INVULN_DURATION
	# Pequeno recuo ao tomar dano (knockback clássico)
	velocity.y = -120.0
	velocity.x = -facing * 60.0
	health.take_damage(amount)

func _on_died() -> void:
	_dead = true
	visible = false
	set_physics_process(false)
