# health.gd
# Componente reutilizável: adicione como Node filho do jogador, inimigos e chefe.
class_name Health
extends Node

signal changed(current, maximum)
signal died

@export var max_health: int = 28   # Megaman tem 28 unidades de energia
var current: int

func _ready() -> void:
	current = max_health
	changed.emit(current, max_health)

func take_damage(amount: int) -> void:
	if current <= 0:
		return
	current = max(current - amount, 0)
	changed.emit(current, max_health)
	if current == 0:
		died.emit()
