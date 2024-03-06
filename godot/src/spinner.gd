extends Control

@export var spin_duration: float = -20

func _ready():
	pivot_offset = size / 2

func _process(delta):
	rotation += TAU * delta / spin_duration
