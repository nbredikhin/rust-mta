-- Правила установки строительных объектов друг на друга

local function sign(val)
	if val > 0 then
		return 1
	elseif val < 0 then
		return -1
	else
		return 0
	end
end

local function getDirectionVector(v)
	local rv = Vector3(0, 0, 0)
	if math.abs(v.x) > math.abs(v.y) then
		rv.x = sign(v.x)
	else
		rv.y = sign(v.y)
	end
	return rv
end

placementRules = {}
-- Фундамент можно установить только на землю
placementRules["Foundation"] = {
	["World"] = function (targetObject, targetPosition, targetAngle)
		return targetPosition + Vector3(0, 0, 0.5), targetAngle
	end,

	["Foundation"] = function (targetObject, targetPosition, targetAngle)
		local offset = getDirectionVector(targetPosition - targetObject.position) * BUILDING_NODE_WIDTH
		return targetObject.matrix:transformPosition(offset), targetObject.rotation.z
	end
}

placementRules["Floor"] = {
	-- Пол можно установить на фундамент
	["Foundation"] = function (targetObject, targetPosition, targetAngle)
		return targetObject.matrix:transformPosition(0, 0, BUILDING_NODE_HEIGHT), targetObject.rotation.z
	end,
	-- Пол можно установить на стену (?)
	-- ["Wall"] = function(targetObject, targetPosition)
	-- 	if not targetObject:getData("Foundation") then
	-- 		return false
	-- 	end
	-- end
}

placementRules["Wall"] = {
	["Foundation"] = function(targetObject, targetPosition, targetAngle)
		return targetPosition, targetAngle
	end,

	["Floor"] = placementRules["Foundation"]
}

placementRules["WallWindow"] = placementRules["Wall"]
placementRules["WallDoor"] = placementRules["Wall"]

function getPlacementRule(partType, targetType, ...)
	if not placementRules[partType] then
		return false
	end
	if not placementRules[partType][targetType] then
		return false
	end
	return placementRules[partType][targetType](...)
end