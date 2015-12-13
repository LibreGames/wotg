return {
	default = "idle",

	states = {
		["idle"] = { image = "player_idle.png", fw = 16, fh = 32, oy = 20, delay = 1 },
		["run"] = { image = "player_run.png", fw = 18, fh = 32, oy = 20, delay = 0.1 },
		["charge"] = { image = "player_charge.png", fw = 36, fh = 32, ox = 11, oy = 20, delay = 0.02, loop = false },
		["attack"] = { image = "player_attack.png", fw = 36, fh = 32, ox = 11, oy = 20, delay = 0.05 },
		["hurt"] = { image = "player_hurt.png", fw = 18, fh = 32, oy = 20, delay = 0.25 },
		["jump"] = { image = "player_jump.png", fw = 18, fh = 32, oy = 20, delay = 0.15, loop = false },
		["fall"] = { image = "player_fall.png", fw = 18, fh = 32, oy = 20, delay = 0.1 }
	},

	properties = {
		["state"] = { value = 1 },
		["attack"] = { value = false, isTrigger = true },
		["jump"] = { value = false, isTrigger = true }
	},

	transitions = {
		{ from = "run", to = "idle", property = "state", value = 1 },
		{ from = "idle", to = "run", property = "state", value = 2 },

		{ from = "idle", to = "charge", property = "state", value = 3 },
		{ from = "run", to = "charge", property = "state", value = 3 },
		{ from = "jump", to = "charge", property = "state", value = 3 },
		{ from = "fall", to = "charge", property = "state", value = 3 },
		{ from = "charge", to = "attack", property = "attack", value = true },
		{ from = "attack", to = "idle", property = "_finished", value = true },

		{ from = "any", to = "hurt", property = "state", value = 4 },
		{ from = "hurt", to = "idle", property = "_finished", value = true },

		{ from = "idle", to = "jump", property = "jump", value = true },
		{ from = "run", to = "jump", property = "jump", value = true },
		{ from = "jump", to = "fall", property = "state", value = 5 },

		{ from = "idle", to = "fall", property = "state", value = 5 },
		{ from = "run", to = "fall", property = "state", value = 5 },
		{ from = "fall", to = "idle", property = "state", value = 1 },
		{ from = "fall", to = "run", property = "state", value = 2 }
	}
}
