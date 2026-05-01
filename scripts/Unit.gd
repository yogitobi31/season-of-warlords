extends Node2D
class_name Unit

const TEAM_PLAYER: int = 0
const TEAM_ENEMY: int = 1

@export var max_hp: float = 100.0
@export var attack_power: float = 12.0
@export var move_speed: float = 80.0
@export var attack_range: float = 26.0
@export var attack_cooldown: float = 0.8
@export var team: int = TEAM_PLAYER

var unit_name: String = ""
var is_companion: bool = false
var level: int = 1
var unit_class: String = "infantry"

var hp: float
var _cooldown_timer: float = 0.0
var _shape: ColorRect
var name_label: Label

func _ready() -> void:
	hp = max_hp
	_shape = ColorRect.new()
	var body_size: Vector2 = Vector2(16, 16)
	if is_companion:
		body_size = Vector2(24, 24)
	_shape.size = body_size
	_shape.position = -body_size * 0.5
	_shape.color = Color("7CFC00") if team == TEAM_PLAYER else Color("FF7043")
	add_child(_shape)

	if is_companion and unit_name != "":
		name_label = Label.new()
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.size = Vector2(160, 22)
		name_label.position = Vector2(-80, body_size.y * 0.5 + 4)
		name_label.text = "%s Lv.%d" % [unit_name, level]
		add_child(name_label)

func apply_class_stats(class_id: String) -> void:
	unit_class = class_id
	var class_data: Dictionary = GameState.UNIT_CLASSES.get(class_id, GameState.UNIT_CLASSES["infantry"])
	max_hp = float(class_data.get("max_hp", max_hp))
	attack_power = float(class_data.get("attack", attack_power))
	move_speed = float(class_data.get("move_speed", move_speed))
	attack_range = float(class_data.get("attack_range", attack_range))

func is_alive() -> bool:
	return hp > 0.0

func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0.0:
		queue_free()

func tick_ai(delta: float, enemies: Array[Unit]) -> void:
	if not is_alive():
		return

	_cooldown_timer = max(_cooldown_timer - delta, 0.0)

	var target: Unit = _find_nearest_enemy(enemies)
	if target == null:
		return

	var dist: float = global_position.distance_to(target.global_position)
	if dist <= attack_range:
		if _cooldown_timer <= 0.0:
			var multiplier: float = get_damage_multiplier(unit_class, target.unit_class)
			target.take_damage(attack_power * multiplier)
			_cooldown_timer = attack_cooldown
	else:
		var dir: Vector2 = (target.global_position - global_position).normalized()
		global_position += dir * move_speed * delta

func get_damage_multiplier(attacker_class: String, defender_class: String) -> float:
	if attacker_class == "spearman" and defender_class == "cavalry":
		return 1.35
	if attacker_class == "cavalry" and (defender_class == "archer" or defender_class == "sorcerer"):
		return 1.35
	if attacker_class == "sorcerer" and defender_class == "shieldbearer":
		return 1.35
	if attacker_class == "archer" and defender_class == "shieldbearer":
		return 0.75
	if attacker_class == "cavalry" and defender_class == "spearman":
		return 0.75
	return 1.0

func _find_nearest_enemy(enemies: Array[Unit]) -> Unit:
	var nearest: Unit = null
	var nearest_dist: float = INF
	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if not enemy.is_alive():
			continue
		var d: float = global_position.distance_to(enemy.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = enemy
	return nearest
