extends Node

const MOD_PRIORITY = 0
const MOD_NAME = "ShipTransponder"
const MOD_VERSION_MAJOR = 0
const MOD_VERSION_MINOR = 2
const MOD_VERSION_BUGFIX = 3
const MOD_VERSION_METADATA = ""
var modPath:String = get_script().resource_path.get_base_dir() + "/"
var _savedObjects := []

func _init(modLoader = ModLoader):
	l("Initializing")
	loadDLC()
	installScriptExtension("hud/ShipList.gd")
	installScriptExtension("hud/components/ShipOnOMSNameTransponder.gd")
	updateTL("i18n/en.txt", "|")
	#updateTL("i18n/ua.txt", "|")
	l("Initialized")

#func _ready():
#	updateTL("i18n/en.txt", "|")

func updateTL(path:String, delim:String = ","):
	path = str(modPath + path)
	l("Adding translations from: %s" % path)
	var tlFile:File = File.new()
	tlFile.open(path, File.READ)

	var translations := []

	var csvLine := tlFile.get_line().split(delim)
	l("Adding translations as: %s" % csvLine)
	for i in range(1, csvLine.size()):
		var translationObject := Translation.new()
		translationObject.locale = csvLine[i]
		translations.append(translationObject)

	while not tlFile.eof_reached():
		csvLine = tlFile.get_csv_line(delim)

		if csvLine.size() > 1:
			var translationID := csvLine[0]
			for i in range(1, csvLine.size()):
				translations[i - 1].add_message(translationID, csvLine[i].c_unescape())
			l("Added translation: %s" % csvLine)

	tlFile.close()

	for translationObject in translations:
		TranslationServer.add_translation(translationObject)

	l("Translations Updated")


# Helper function to extend scripts
# Loads the script you pass, checks what script is extended, and overrides it
func installScriptExtension(path:String):
	var childPath:String = str(modPath + path)
	var childScript:Script = ResourceLoader.load(childPath)

	childScript.new()

	var parentScript:Script = childScript.get_base_script()
	var parentPath:String = parentScript.resource_path

	l("Installing script extension: %s <- %s" % [parentPath, childPath])

	childScript.take_over_path(parentPath)


# Helper function to replace scenes
# Can either be passed a single path, or two paths
# With a single path, it will replace the vanilla scene in the same relative position
func replaceScene(newPath:String, oldPath:String = ""):
	l("Updating scene: %s" % newPath)

	if oldPath.empty():
		oldPath = str("res://" + newPath)

	newPath = str(modPath + newPath)

	var scene := load(newPath)
	scene.take_over_path(oldPath)
	_savedObjects.append(scene)
	l("Finished updating: %s" % oldPath)


# Instances Settings.gd, loads DLC, then frees the script.
func loadDLC():
	l("Preloading DLC as workaround")
	var DLCLoader:Settings = preload("res://Settings.gd").new()
	DLCLoader.loadDLC()
	DLCLoader.queue_free()
	l("Finished loading DLC")


# Func to print messages to the logs
func l(msg:String, title:String = MOD_NAME, version:String = str(MOD_VERSION_MAJOR) + "." + str(MOD_VERSION_MINOR) + "." + str(MOD_VERSION_BUGFIX)):
	if not MOD_VERSION_METADATA == "":
		version = version + "-" + MOD_VERSION_METADATA
		Debug.l("[%s V%s]: %s" % [title, version, msg])
