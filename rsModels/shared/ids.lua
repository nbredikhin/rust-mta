replacedModelsIds = {
	["foundation"] = 3865,
	["wall"] = 1618,
	["wall_door"] = 1623,
	["wall_window"] = 1624,
	["floor"] = 3397,
	["stairs"] = 1660,
	["door"] = 3391,
	["hatchet"] = 339,
}

function getModelFromName(name)
	if type(name) ~= "string" then
		return false
	end
	return replacedModelsIds[name]
end