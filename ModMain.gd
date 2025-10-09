extends Node

func _init(mod_loader):
	mod_loader.installScriptExtension("res://ShipTransponder/hud/ShipList.gd")
	mod_loader.installScriptExtension("res://ShipTransponder/hud/components/ShipOnOMSNameTransponder.gd")
