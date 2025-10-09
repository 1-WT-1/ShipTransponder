extends "res://hud/ShipList.gd"

export (PackedScene) var shipOnOmsDataMod = preload("res://ShipTransponder/hud/components/ShipOnOMSNameTransponder.tscn")

func redraw():
	if not is_visible_in_tree():
		return
	var first = true
	var remove = shown.duplicate()
	var ships = ship.identifiedShips
	Debug.l("Identified ships: %s" % ships)
	focusTarget = null
	for k in ships:
			
		var transponder = ships[k][0]
		var shipName = ships[k][1]
		var shipObject = ships[k][2]
		var marked = ships[k][3]
		if ship.temporaryCargo.has(shipObject):
			continue
		if Tool.claim(shipObject):
			remove.erase(k)
			if not (k in shown):
				var h = hailShip.instance()
				h.ship = ship
				h.target = shipObject
				var iff = iffBlueprint.instance()
				iff.ship = ship
				iff.target = shipObject
				var sl = shipOnOmsDataMod.instance() # Use the modded scene here
				sl.ship = ship # Pass the main ship object
				sl.setData(shipName, transponder)
				var bd = shipOnOmsBearingDistance.instance()
				if marked:
					bd.setData(ship, shipObject)
				
				add_child(h)
				add_child(sl)
				add_child(bd)
				add_child(iff)
				shown[k] = [h, sl, bd, iff]
				if first:
					first = false
					focusTarget = h
			else:
				shown[k][1].ship = ship # Pass the main ship object
				shown[k][1].setData(shipName, transponder)
				if marked:
					shown[k][2].setData(ship, shipObject)
				if first:
					first = false
					focusTarget = shown[k][0]
			Tool.release(shipObject)
	for k in remove:
		shown.erase(k)
		for r in remove[k]:
			r.queue_free()
	


