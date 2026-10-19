extends Node2D

@onready var player: CharacterBody2D = $player
@onready var boss: CharacterBody2D = $Boss
@onready var player_hp_bar: Sprite2D = $HUD/PlayerHealthBar
@onready var boss_hp_bar: Sprite2D = $HUD/BossHealthBar
@onready var boss_label: Label = $HUD/BossLabel
@onready var status_panel: Panel = $HUD/StatusPanel
@onready var status_label: Label = $HUD/StatusPanel/StatusLabel

var _game_over: bool = false

func _ready() -> void:
	status_panel.visible = false
	var player_health: Node = player.get_node("Health")
	_update_energy_bar(player_hp_bar, player_health.current, player_health.max_health)
	player_health.changed.connect(_on_player_health_changed)
	player_health.died.connect(_on_player_died)

	var boss_health: Node = boss.get_node("Health")
	_update_energy_bar(boss_hp_bar, boss_health.current, boss_health.max_health)
	boss_health.changed.connect(_on_boss_health_changed)
	boss_health.died.connect(_on_boss_died)

func _process(_delta: float) -> void:
	if is_instance_valid(player) and player.global_position.x >= 460.0:
		boss_hp_bar.visible = true
		boss_label.visible = true

	if _game_over and (Input.is_action_just_pressed("jump") or Input.is_physical_key_pressed(KEY_R) or Input.is_action_just_pressed("ui_accept")):
		get_tree().reload_current_scene()

func _update_energy_bar(bar: Sprite2D, current: int, maximum: int) -> void:
	var units := roundi((float(current) / float(max(maximum, 1))) * 28.0)
	var index := 28 - clampi(units, 0, 28)
	bar.region_rect = Rect2(index * 9, 0, 8, 55)

func _on_player_health_changed(current: int, maximum: int) -> void:
	_update_energy_bar(player_hp_bar, current, maximum)

func _on_boss_health_changed(current: int, maximum: int) -> void:
	_update_energy_bar(boss_hp_bar, current, maximum)

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	status_panel.visible = true
	status_label.text = "DERROTA!\nEnergia esgotada.\n\n[Espaço / R] Reiniciar"

func _on_boss_died() -> void:
	if _game_over:
		return
	_game_over = true
	status_panel.visible = true
	status_label.text = "VITÓRIA!\nChefe derrotado!\n\n[Espaço / R] Jogar novamente"
