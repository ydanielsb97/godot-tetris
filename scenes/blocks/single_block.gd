class_name SingleBlock
extends Sprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
const DESTROY_FX = preload("res://scenes/blocks/destroy_fx.tscn")

var grid_coords: Vector2i
var animation_length: float
const DESTROY_ANIMATION_NAME = "destroy"

func _ready() -> void:
	var animation = animation_player.get_animation("destroy")
	animation_length = animation.length
	
func setup(_texture: CompressedTexture2D) -> void:
	texture = _texture

func destroy() -> void:
	animation_player.play(DESTROY_ANIMATION_NAME)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == DESTROY_ANIMATION_NAME:
		queue_free()


func get_fire_if_exists() -> DestroyFX:
	for i in get_children():
		if i is DestroyFX: return i
	return null

func toggle_fire(activate: bool = true) -> void:
	var fire_exists = get_fire_if_exists()
	if activate:
		if fire_exists:
			fire_exists.emitting = true
		else:
			var new_fire_fx = DESTROY_FX.instantiate()
			add_child(new_fire_fx, false, Node.INTERNAL_MODE_BACK)
	elif !activate and fire_exists:
		fire_exists.emitting = false
