extends Label

export var placeholder = "????"

func _ready():
	if not text:
		text = placeholder

func set_text(to):
	if not to:
		text = placeholder
	else:
		text = to
