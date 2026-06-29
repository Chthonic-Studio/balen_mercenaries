class_name NPC
extends Character

@export var raycast_radius: float = 100.0
@export var raycast_count: int = 12
@export var node_resolution: float = 20.0 # Spacing between AStar nodes
@export var goal_vector: Vector2 = Vector2(400, 300)

var local_nodes: Array = []
var active_raycasts: Array = []

func _physics_process(delta: float) -> void:
	update_movement_state()
	
	# 1. Cast local raycasts to detect nearby obstacles
	var obstacles_detected = cast_virtual_raycasts()
	
	# 2. Rebuild local AStar grid nodes from radius
	rebuild_local_grid(obstacles_detected)
	
	# 3. Find optimal local path node towards the goal_vector
	var target_local_pos = find_best_local_node()
	
	# 4. Drive CharacterBody2D movement
	var move_direction = (target_local_pos - global_position).normalized()
	handle_velocity(move_direction)
	
	# 5. Play Animation
	var anim = "Walk"
	if velocity.length() < 5:
		anim = "Idle"
	
	var facing_dir = get_facing_direction(move_direction)
	var current_frame = Engine.get_physics_frames() / 6 % 15
	visuals.play_animation(anim, facing_dir, current_frame)

func cast_virtual_raycasts() -> Array:
	var hits = []
	var space_state = get_world_2d().direct_space_state
	
	for i in range(raycast_count):
		var angle = (i * 2 * PI) / raycast_count
		var dir = Vector2(cos(angle), sin(angle))
		var query = PhysicsRayQueryParameters2D.create(global_position, global_position + dir * raycast_radius)
		query.exclude = [get_rid()] # Exclude self
		
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			hits.append(result.position)
	return hits

func rebuild_local_grid(hits: Array) -> void:
	local_nodes.clear()
	var grid_range = int(raycast_radius / node_resolution)
	
	for x_offset in range(-grid_range, grid_range + 1):
		for y_offset in range(-grid_range, grid_range + 1):
			var node_pos = global_position + Vector2(x_offset, y_offset) * node_resolution
			
			# Check if this node overlaps any obstacle hits or is too close to a hit position
			var is_obstacle = false
			for hit in hits:
				if node_pos.distance_to(hit) < node_resolution * 0.8:
					is_obstacle = true
					break
			
			if not is_obstacle:
				local_nodes.append(node_pos)

func find_best_local_node() -> Vector2:
	if local_nodes.is_empty():
		return global_position # Stand still
		
	var best_node = global_position
	var min_cost = INF
	
	for node in local_nodes:
		var dist_to_self = global_position.distance_to(node)
		# Node must be in adjacent perimeter
		if dist_to_self <= node_resolution * 1.5 and dist_to_self > 5:
			# F_Cost = G_Cost (distance from self) + H_Cost (distance to final goal)
			var g_cost = dist_to_self
			var h_cost = node.distance_to(goal_vector)
			var f_cost = g_cost + h_cost
			
			if f_cost < min_cost:
				min_cost = f_cost
				best_node = node
				
	return best_node

func get_facing_direction(input_vec: Vector2) -> CharacterVisuals.Direction:
	var angle = input_vec.angle()
	var degrees = rad_to_deg(angle)
	if degrees < 0:
		degrees += 360
	var slice = round(degrees / 45.0)
	return (int(slice) % 8) as CharacterVisuals.Direction
