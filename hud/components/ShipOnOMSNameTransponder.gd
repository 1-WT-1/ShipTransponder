extends "res://hud/components/ShipOnOMSNameTransponder.gd"

var ship_class_name_label
var ship

# Load the HevLib ConfigDriver
var ConfigDriver:HevLibPointers._ConfigDriver = ModLoader._savedObjects[0].ConfigDriver


const HYBRID_SHIP_NAMES = ["SHIP_TRTL", "SHIP_PROSPECTOR", "SHIP_COTHON", "SHIP_EIME", "SHIP_TRTL"]
const HYBRID_SHIP_MODELS = ["TRTL", "PROSPECTOR", "COTHON", "EIME", "TRTL"]

const SHIP_OVERRIDES = [
	["MAD-CERF", "SHIP_TRANSPONDER_CERF_NAME", "CERF"],
	["Tsukuyomi", "SHIP_TRANSPONDER_TSUKUYOMI_NAME", "TSUKUYOMI"],
	["ATLAS", "SHIP_TRANSPONDER_ATLAS_NAME", "ATLAS"],
	["STATION_HABITAT", "SHIP_TRANSPONDER_HABITAT_NAME", "HABITAT"],
	["STATION_PHAGE", "SHIP_TRANSPONDER_PHAGE_NAME", "PHAGE"],
]


func _ready():
	# The ship will always be the player vessel, so we can just set it
	# here instead of passing it via the overriden ShipList.redraw() method
	ship = CurrentGame.getPlayerShip()
	ship_class_name_label = get_node("ShipClassName")

func setData(shipName, transponder):
	.setData(shipName, transponder)
	if not transponder: #UIO
		if ship_class_name_label:
			ship_class_name_label.set_text("UNKNOWN")
		return

	var shipObject = null
	if ship:
		for key in ship.identifiedShips:
			var identified_ship_data = ship.identifiedShips[key]
			if identified_ship_data[0] == transponder:
				shipObject = identified_ship_data[2]
				break

	if Tool.claim(shipObject):
		if ship_class_name_label and shipObject:
			var ship_display_name = "UNKNOWN"
			var is_hailable = false

			if shipObject.has_method("get_hailable"):
				is_hailable = shipObject.get_hailable()
			elif shipObject.has_method("get") and shipObject.get("hailable") != null:
				is_hailable = shipObject.get("hailable")

			var show_non_hailable = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "show_non_hailable")
			var ship_name_prop = get_ship_name_property(shipObject)
			var ship_model_prop = get_model_property(shipObject)
			var is_hybrid = "HYB-base" in shipObject.name
			var ship_override = get_ship_type_override(shipObject, ship_name_prop)

			# CONDITION
			if is_hailable or show_non_hailable or is_hybrid or ship_override != null:
				var potential_name = ""
				var display_preference = ConfigDriver.__get_value("ShipTransponder", "SHIPTRANSPONDER_CONFIG_OPTIONS", "display_preference")

				if is_hybrid:
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

				elif ship_override != null:
					potential_name = ship_override[1] if display_preference == "Name" else ship_override[2]

				else: # Default case for all other ships
					var primary_name = ""
					var fallback_name = ""
					if display_preference == "Name":
						primary_name = ship_name_prop
						fallback_name = ship_model_prop
					else: # Model
						primary_name = ship_model_prop
						fallback_name = ship_name_prop
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
						elif ship_model_prop != "":
							ship_display_name = ship_model_prop
						else:
							ship_display_name = "UNKNOWN"
					else:
						ship_display_name = potential_name

			ship_class_name_label.set_text(ship_display_name)
		elif ship_class_name_label:
			ship_class_name_label.set_text("UNKNOWN")
	Tool.release(shipObject)

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

# Helper function to get ship type override
func get_ship_type_override(obj, ship_name_prop):
	for override in SHIP_OVERRIDES:
		var key = override[0]
		if key in obj.name or key == ship_name_prop:
			return override
	return null
