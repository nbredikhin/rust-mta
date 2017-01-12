replacedModelsIds = {
	["Foundation"] = 3865,
	["Wall"] = 1618,
	["WallDoor"] = 1623,
	["WallWindow"] = 1624,
	["Floor"] = 3397,
	["Stairway"] = 1660,
	["Door"] = 3391,
	["Hatchet"] = 339,
}

function getModel(name)
	if type(name) ~= "string" then
		return false
	end
	return replacedModelsIds[name]
end