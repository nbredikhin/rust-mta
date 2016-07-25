items = {}

items["resource_wood"] = {
	img = "wood.png",
	name = "Древесина",
	stack = 1
}

items["weapon_stone"] = {
--	img = "stone.png",
	name = "Камень",
	damage = {
		-- body
		head = 22,
		chest = 12,
		arms = 2,
		-- buildings
		twig = 2,
		wood = 0.2,
		stone = 0.2,
		metal = 0.1,
		armored = 0.1
	},
	range = 1.25,
	speed = 1.25,
	gatheringEfficiency = 
	{
		wood = 0.3, 
		stone = 0.01,
		metal = 0.001
	}
}

items["weapon_stonehatchet"] = {
--	img = "stonehatchet.png",
	name = "Каменный топор",
	damage = {
		-- body
		head = 15,
		chest = 27,
		arms = 8,
		-- buildings
		twig = 3,
		wood = 2.1,
		stone = 0.3,
		metal = 0.15,
		armored = 0.15
	},
	range = 1.5,
	speed = 0.5,
	gatheringEfficiency = 
	{
		wood = 0.8, 
		stone = 0.01,
		metal = 0.001
	},
	crafting =
	{
		duration = 30,
		materials = {
			["wood"] = 200,
			["stone"] = 200
		}
	}
}