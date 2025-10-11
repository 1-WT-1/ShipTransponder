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

		if shipObject.has_method("get_hailable"):
			is_hailable = shipObject.get_hailable()
		elif shipObject.has_method("get") and shipObject.get("hailable") != null:
			is_hailable = shipObject.get("hailable")

		var show_non_hailable = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "show_non_hailable")

		# CONDITION
		if transponder != "UIO" and (is_hailable or show_non_hailable or shipObject.name in ["HYB-base", "Tsukuyomi"]):
			var potential_name = ""
			var display_preference = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "display_preference")

			match shipObject.name:
				"HYB-base":
					var hybrid_name_key = ""
					var hybrid_model = ""
					var dynamic_hybrid_naming = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "dynamic_hybrid_naming")

					if not dynamic_hybrid_naming:
						if shipObject.has_meta("hybrid_name_key"):
							hybrid_name_key = shipObject.get_meta("hybrid_name_key")
							hybrid_model = shipObject.get_meta("hybrid_model")
						else:
							hybrid_name_key = HYBRID_SHIP_NAMES[randi() % HYBRID_SHIP_NAMES.size()]
							hybrid_model = HYBRID_SHIP_MODELS[randi() % HYBRID_SHIP_MODELS.size()]
							shipObject.set_meta("hybrid_name_key", hybrid_name_key)
							shipObject.set_meta("hybrid_model", hybrid_model)
					else:
						hybrid_name_key = HYBRID_SHIP_NAMES[randi() % HYBRID_SHIP_NAMES.size()]
						hybrid_model = HYBRID_SHIP_MODELS[randi() % HYBRID_SHIP_MODELS.size()]

					potential_name = hybrid_name_key if display_preference == "Name" else hybrid_model

				"Tsukuyomi":
					potential_name = "SHIP_TSUKUYOMI_NAME" if display_preference == "Name" else "TSUKUYOMI"

				_: # Default case for all other ships
					var primary_name = ""
					var fallback_name = ""
					if display_preference == "Name":
						primary_name = get_ship_name_property(shipObject)
						fallback_name = get_model_property(shipObject)
					else: # Model
						primary_name = get_model_property(shipObject)
						fallback_name = get_ship_name_property(shipObject)
					potential_name = primary_name if primary_name != "" else fallback_name

			# DISPLAY
			var show_all_names = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "show_all_names")
			if potential_name != "":
				var is_translation_key = (potential_name == potential_name.to_upper() and "_" in potential_name)

				if is_translation_key:
					var translated_name = tr(potential_name)
					if translated_name != potential_name:
						ship_display_name = translated_name
					elif show_all_names:
						ship_display_name = potential_name
					else:
						ship_display_name = "UNKNOWN"
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
