# something interesting to note
#
# sometimes you'll run this and get wildly different results, this is because
# of variations in how long each frame takes to render or process. and this
# affects the physics as it's deltatimed, so each operation
# is multiplied by delta.
#
# it's a very small amount, but it adds up i guess.

extends Node2D

var font     = ThemeDB.fallback_font
var fontSize = 10

var selectedIcon = [
	[0, 0],
	[-7, -7],
	[7, -7]
]

var is_ready  = false
var fps       = 60
var timescale = 1

var gravity = 10

var debug   = false
var current = 0

var objects = []

func polygonThing(coords, offset):
	var packed = PackedVector2Array()

	for coord in coords:
		packed.append(Vector2(coord[0], coord[1]) + offset)

	return packed

func object_create(anchored, mass, density, position, velocity):
	var object = {
		"alive":    true,
		"active":   true,
		"index":    len(objects),
		"color":    Color(randf(), randf(), randf()),
		"anchored": anchored,
		"mass":     mass,
		"density":  density,
		"position": position,
		"velocity": velocity
	}

	objects.push_back(object)

	return object

func object_destroy(object):
	object.active = false
	object.alive  = false

func object_radius(object):
	return sqrt(object.mass / (object.density * PI))

func object_speed(object):
	return object.velocity.length()

func object_vectorTo(a, b):
	return b.position - a.position

func object_distance(a, b):
	return object_vectorTo(a, b).length()

func object_touching(a, b):
	return object_radius(a) + object_radius(b) >= object_distance(a, b)

func object_merge(a, b):
	var massFactor

	if a.mass > b.mass:
		massFactor = (b.mass / a.mass)

		a.velocity += b.velocity * massFactor
		a.mass     += b.mass
		a.density  += b.density * massFactor

		if current == b.index:
			current = a.index

		object_destroy(b)
	else:
		massFactor = (a.mass / b.mass)

		b.velocity += a.velocity * massFactor
		b.mass     += a.mass
		b.density  += a.density * massFactor

		if current == a.index:
			current = b.index

		object_destroy(a)

func object_satellite(object, mass, density, distance):
	var position  = Vector2(object.position.x + distance, object.position.y)
	var speed     = sqrt(gravity * object.mass)
	var direction = (position - object.position).normalized()
	var velocity  = Vector2(direction.y * speed, -direction.x * speed)

	if (!object.anchored):
		velocity += object.velocity

	var satellite = object_create(false, mass, density, position, velocity)

	return satellite

func object_debug(object):
	var x    = object.position.x
	var y    = object.position.y + object_radius(object) + fontSize
	var info = [
		"Object " + str(object.index),
		"Active: " + str(object.active),
		"Anchored: " + str(object.anchored),
		"Mass: " + str(round(object.mass)),
		"Density: " + str(round(object.density)),
		"Radius: " + str(round(object_radius(object)))
	]

	var offset = 0

	for line in info:
		draw_string(
			font,
			Vector2(x, y + offset),
			line,
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			fontSize,
			object.color
		)

		offset += fontSize

	draw_line(object.position, object.position + object.velocity / (fps / 10), object.color)

func physics_gravity(delta):
	for object in objects:
		if not object.active:
			continue

		for affector in objects:
			if object.index == affector.index or not affector.active:
				continue

			var pull     = object_vectorTo(object, affector)
			var distance = pull.length()

			if (distance == 0):
				continue

			var force = gravity * ((object.mass * affector.mass) / distance)

			pull = pull.normalized()

			object.velocity += (pull * force) / object.mass * delta;

func physics_velocity(delta):
	for object in objects:
		if not object.anchored:
			object.position += object.velocity * delta

func physics_collisions():
	for a in objects:
		if not a.active:
			continue

		for b in objects:
			if a.index == b.index or not b.active:
				continue

			if object_touching(a, b):
				object_merge(a, b)

func physics_sweep():
	objects = objects.filter(func(object): return object.alive)

	var index = 0

	for object in objects:
		object.index = index
		index       += 1

func physics_boundary():
	for object in objects:
		if object.position.x < 0:
			object.position.x = 0
			object.velocity.x = 0

		if object.position.x > 799:
			object.position.x = 799
			object.velocity.x = 0

		if object.position.y < 0:
			object.position.y = 0
			object.velocity.y = 0

		if object.position.y > 599:
			object.position.y = 599
			object.velocity.y = 0

func physics_step(delta):
	physics_gravity(delta)
	physics_velocity(delta)
	physics_collisions()
	physics_sweep()
	physics_boundary()

func input(delta):
	if Input.is_action_just_pressed("create"):
		object_create(
			false,
			randi_range(50, 5000),
			randi_range(1, 20),
			Vector2(randi_range(0, 799), randi_range(0, 599)),
			Vector2.ZERO
		)

	if len(objects) == 0:
		return

	var count = len(objects)

	if current > count - 1:
		current = count - 1

	var object = objects[current]

	if Input.is_action_just_pressed("anchor"):
		object.anchored = not object.anchored

	if Input.is_action_just_pressed("active"):
		object.active = not object.active

	if Input.is_action_just_pressed("previous") and current > 0:
		current -= 1

	if Input.is_action_just_pressed("next") and current < count - 1:
		current += 1

	if Input.is_action_just_pressed("destroy"):
		object_destroy(object)

	if Input.is_action_just_pressed("debug"):
		debug = not debug

	if Input.is_action_just_pressed("satellite"):
		object_satellite(
			object,
			object.mass / randi_range(1.5, 4),
			object.density,
			object_radius(object) + randi_range(10, 200)
		)

	if Input.is_action_pressed("up"):
		object.velocity.y -= 200 * delta

	if Input.is_action_pressed("down"):
		object.velocity.y += 200 * delta

	if Input.is_action_pressed("left"):
		object.velocity.x -= 200 * delta

	if Input.is_action_pressed("right"):
		object.velocity.x += 200 * delta

func _process(delta):
	delta *= timescale

	input(delta)
	physics_step(delta)
	queue_redraw()

	pass

func _draw():
	for object in objects:
		draw_circle(object.position, object_radius(object), object.color)

		if object.index == current:
			var offset = object.position - Vector2(0, 5 + object_radius(object))

			draw_polygon(polygonThing(selectedIcon, offset), [ object.color ])

		if debug:
			object_debug(object)

func _ready():
	Engine.max_fps = fps
	is_ready       = true

	var object = object_create(true, 5000, 5, Vector2(400, 300), Vector2.ZERO)
	object_satellite(object, 500, 5, 100)
