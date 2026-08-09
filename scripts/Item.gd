extends Node3D
class_name Item

@export var item_id: String = "item_default"
@export var item_name: String = "Item"
@export var item_type: String = "consumable"  # consumable, weapon, ammo, etc.

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var area_3d: Area3D = $Area3D
@onready var collision_shape: CollisionShape3D = $Area3D/CollisionShape3D

var is_picked_up: bool = false
var original_position: Vector3

func _ready() -> void:
	original_position = global_position
	
	# Only the authority (server) handles item logic
	if not is_multiplayer_authority():
		return

func pick_up(player_id: int) -> bool:
	if is_picked_up:
		return false
	
	is_picked_up = true
	
	# Sync pickup across network
	rpc("_on_item_picked_up", player_id)
	return true

@rpc("call_local")
func _on_item_picked_up(player_id: int) -> void:
	mesh_instance.visible = false
	collision_shape.disabled = true
	area_3d.monitoring = false
	# Keep the item in the scene but invisible and non-interactable
	# This way it stays synced across the network

func reset() -> void:
	if is_multiplayer_authority():
		rpc("_reset_item")

@rpc("call_local")
func _reset_item() -> void:
	is_picked_up = false
	mesh_instance.visible = true
	collision_shape.disabled = false
	area_3d.monitoring = true
