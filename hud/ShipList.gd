extends "res://hud/ShipList.gd"

export (PackedScene) var shipOnOmsDataMod = preload("res://ShipTransponder/hud/components/ShipOnOMSNameTransponder.tscn")

func _ready():
	# Replaces the name panel with out modified one
	shipOnOmsData = shipOnOmsDataMod
