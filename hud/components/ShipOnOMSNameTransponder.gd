extends "res://hud/components/ShipOnOMSNameTransponder.gd"

var ship_class_name_label
var ship # Add this line

func _ready():
	ship_class_name_label = get_node("ShipClassName")

func setData(shipName, transponder):
	.setData(shipName, transponder)
	var shipObject = null

	Debug.l("ShipOnOMSNameTransponder: 'ship' variable = %s" % ship)
	if ship:
		Debug.l("ShipOnOMSNameTransponder: ship.identifiedShips = %s" % ship.identifiedShips)
		Debug.l("ShipOnOMSNameTransponder: searching for transponder = %s" % transponder)
		if ship.identifiedShips.empty():
			Debug.l("ShipOnOMSNameTransponder: ship.identifiedShips is empty!")
		for key in ship.identifiedShips:
			var identified_ship_data = ship.identifiedShips[key]
			Debug.l("ShipOnOMSNameTransponder: Comparing identified_ship_data[0] (%s) with transponder (%s)" % [identified_ship_data[0], transponder])
			if identified_ship_data[0] == transponder: # Check if the transponder matches
				shipObject = identified_ship_data[2]
				Debug.l("ShipOnOMSNameTransponder: Found shipObject: %s" % shipObject)
				break

	Debug.l("ShipOnOMSNameTransponder: final shipObject = %s" % shipObject)
	if ship_class_name_label and shipObject:
		var ship_display_name = "UNKNOWN"
		var is_hailable = false # Assume not hailable unless explicitly true
		if shipObject.has_method("get_hailable"):
			is_hailable = shipObject.get_hailable()
		elif shipObject.has_method("get") and shipObject.get("hailable") != null:
			is_hailable = shipObject.get("hailable")
		
		# If transponder is UIO, always treat as UNKNOWN
		if transponder == "UIO":
			ship_display_name = "UNKNOWN"
		elif is_hailable:
			var potential_name = ""
			var ship_name_property = null
			if shipObject.has_method("get_ship_name"):
				ship_name_property = shipObject.get_ship_name()
			elif shipObject.has_method("get") and shipObject.get("shipName") != null:
				ship_name_property = shipObject.get("shipName")
			
			if ship_name_property != null and ship_name_property != "":
				potential_name = ship_name_property
			else:
				var model_property = null
				if shipObject.has_method("get_model"):
					model_property = shipObject.get_model()
				elif shipObject.has_method("get") and shipObject.get("model") != null:
					model_property = shipObject.get("model")
				
				if model_property != null and model_property != "":
					potential_name = model_property
			
			# Check for translation and set display name
			if potential_name != "":
				if potential_name.begins_with("SHIP_"):
					var translated_name = tr(potential_name)
					if translated_name == potential_name:
						ship_display_name = "UNKNOWN"
					else:
						ship_display_name = translated_name
				else:
					ship_display_name = potential_name
			
		Debug.l("ShipOnOMSNameTransponder: Attempting to set class name to: %s" % ship_display_name)
		ship_class_name_label.set_text(ship_display_name)
	elif ship_class_name_label:
		Debug.l("ShipOnOMSNameTransponder: shipObject is null or not hailable, setting class name to UNKNOWN")
		ship_class_name_label.set_text("UNKNOWN")
