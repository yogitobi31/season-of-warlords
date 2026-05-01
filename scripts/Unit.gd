extends Node2D
class_name Unit

# 팀 구분 상수
const TEAM_PLAYER := 0
const TEAM_ENEMY := 1

# 유닛 기본 능력치
@export var max_hp: float = 100.0
@export var attack_power: float = 12.0
@export var move_speed: float = 80.0
@export var attack_range: float = 26.0
@export var attack_cooldown: float = 0.8
@export var team: int = TEAM_PLAYER

var unit_name: String = ""
var is_companion: bool = false
var level: int = 1

var hp: float
var _cooldown_timer: float = 0.0
var _shape: ColorRect
var name_label: Label

func _ready() -> void:
	hp = max_hp
	_shape = ColorRect.new()
	var body_size := Vector2(16, 16)
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

	var target := _find_nearest_enemy(enemies)
	if target == null:
		return

	var dist := global_position.distance_to(target.global_position)
	if dist <= attack_range:
		if _cooldown_timer <= 0.0:
			target.take_damage(attack_power)
			_cooldown_timer = attack_cooldown
	else:
		var dir := (target.global_position - global_position).normalized()
		global_position += dir * move_speed * delta

func _find_nearest_enemy(enemies: Array[Unit]) -> Unit:
	var nearest: Unit = null
	var nearest_dist := INF
	for enemy in enemies:
		if enemy == null or not is_instance_valid(enemy):
			continue
		if not enemy.is_alive():
			continue
		var d := global_position.distance_to(enemy.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = enemy
	return nearest
