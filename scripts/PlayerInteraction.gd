extends Area3D
class_name PlayerInteraction

@export var pickup_range: float = 3.0

var player_id: int
var nearby_items: Array[Item] = []
var inventory: PlayerInventory

func _ready() -> void:
	# Get the parent player node
	var player = get_parent()
	player_id = player.name.to_int()
	
	# Get or create inventory
	inventory = player.get_node_or_null("PlayerInventory")
	if not inventory:
		print("Warning: PlayerInventory not found on player!")
	
	# Set up area signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	if not is_multiplayer_authority():
		return

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if Input.is_action_just_pressed("interact"):
		attempt_pickup()

func attempt_pickup() -> void:
	# Find closest item within range
	var closest_item: Item = null
	var closest_distance: float = pickup_range
	
	for item in nearby_items:
		if not item.is_picked_up:
			var distance = global_position.distance_to(item.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_item = item
	
	if closest_item:
		if closest_item.pick_up(player_id):
			# Add item to inventory
			if inventory:
				inventory.add_item(closest_item)
			print("Picked up: ", closest_item.item_name)

func _on_area_entered(area: Area3D) -> void:
	# Check if the area belongs to an Item node
	var item = area.get_parent()
	if item is Item:
		if item not in nearby_items:
			nearby_items.append(item)
			print("Item nearby: ", item.item_name)

func _on_area_exited(area: Area3D) -> void:
	# Check if the area belongs to an Item node
	var item = area.get_parent()
	if item is Item:
		nearby_items.erase(item)
		print("Item out of range: ", item.item_name)

func get_nearby_items() -> Array[Item]:
	return nearby_items
