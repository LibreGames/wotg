return {
	default = "walk",

	states = {
		["walk"] = { image = "boar_walk.png", fw = 32, fh = 32, oy = 24, delay = 0.2 },
		["charge"] = { image = "boar_charge.png", fw = 32, fh = 32, oy = 24, delay = 0.1, loop = false },
		["dash"] = { image = "boar_dash.png", fw = 32, fh = 32, oy = 24, delay = 0.12 },
		["eat"] = { image = "boar_eat.png", fw = 24, fh = 32, oy = 24, delay = 0.15 },
		["stunned"] = { image = "boar_stunned.png", fw = 32, fh = 32, oy = 24, delay = 0.2 }
	},

	properties = {
		["state"] = { value = 1 }
	},

	transitions = {
		{ from = "any", to = "walk", property = "state", value = 1 },
		{ from = "any", to = "charge", property = "state", value = 2 },
		{ from = "any", to = "dash", property = "state", value = 3 },
		{ from = "any", to = "eat", property = "state", value = 4 },
		{ from = "any", to = "stunned", property = "state", value = 5 }
	}
}
