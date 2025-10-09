extends "res://hud/components/ShipOnOMSNameTransponder.gd"

var ship_class_name_label
var ship

# Load the HevLib ConfigDriver
var ConfigDriver = load("res://HevLib/pointers/ConfigDriver.gd")


const HYBRID_SHIP_NAMES = ["SHIP_TRTL", "SHIP_PROSPECTOR", "SHIP_COTHON", "SHIP_EIME", "SHIP_TRTL"]
const HYBRID_SHIP_MODELS = ["TRTL", "PROSPECTOR", "COTHON", "EIME", "TRTL"]


func _ready():
	ship_class_name_label = get_node("ShipClassName")

func setData(shipName, transponder):
	.setData(shipName, transponder)
	var shipObject = null

	if ship:
		for key in ship.identifiedShips:
			var identified_ship_data = ship.identifiedShips[key]
			if identified_ship_data[0] == transponder:
				shipObject = identified_ship_data[2]
				break

	if ship_class_name_label and shipObject:
		var ship_display_name = "UNKNOWN"
		var is_hailable = false

		var is_hybrid_ship = false
		if shipObject.filename.ends_with("HYB-based.tscn"):
			is_hybrid_ship = true

		if shipObject.has_method("get_hailable"):
			is_hailable = shipObject.get_hailable()
		elif shipObject.has_method("get") and shipObject.get("hailable") != null:
			is_hailable = shipObject.get("hailable")

		if transponder == "UIO":
			ship_display_name = "UNKNOWN"
		elif is_hailable or is_hybrid_ship:
			var potential_name = ""

			var display_preference = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "display_preference")

			# HYBRID LOGIC
			if is_hybrid_ship:
				var random_name_key = HYBRID_SHIP_NAMES[randi() % HYBRID_SHIP_NAMES.size()]
				var random_model = HYBRID_SHIP_MODELS[randi() % HYBRID_SHIP_MODELS.size()]

				potential_name = random_name_key if display_preference == "Ship_Name" else random_model

			# ALL OTHERS
			else:
				var primary_name = ""
				var fallback_name = ""

				if display_preference == "Ship_Name":
					primary_name = get_ship_name_property(shipObject)
					fallback_name = get_model_property(shipObject)
				else: # Ship_Model
					primary_name = get_model_property(shipObject)
					fallback_name = get_ship_name_property(shipObject)

				potential_name = primary_name if primary_name != "" else fallback_name

			# DISPLAY
			var show_all_names = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "show_all_names")
			if potential_name != "":
				if potential_name.begins_with("SHIP_"):
					var translated_name = tr(potential_name)
					if translated_name == potential_name and not show_all_names:
						ship_display_name = "UNKNOWN"
					else:
						ship_display_name = translated_name
				else:
					ship_display_name = potential_name

		ship_class_name_label.set_text(ship_display_name)
	elif ship_class_name_label:
		ship_class_name_label.set_text("UNKNOWN")

# Helper function to get ship name
func get_ship_name_property(obj):
	if obj.has_method("get_ship_name"):
		return obj.get_ship_name()
	elif obj.has_method("get") and obj.get("shipName") != null:
		return obj.get("shipName")
	return ""

# Helper function to get ship model
func get_model_property(obj):
	if obj.has_method("get_model"):
		return obj.get_model()
	elif obj.has_method("get") and obj.get("model") != null:
		return obj.get("model")
	return ""
