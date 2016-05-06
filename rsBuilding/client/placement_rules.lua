-- Правила установки строительных объектов друг на друга
placementRules = {}

-- Фундамент можно установить только на землю
placementRules["Foundation"] = {
	["World"] = function (targetObject, targetPosition, targetAngle)
		targetPosition = targetPosition + Vector3(0, 0, 0.5)
		local raysCount = 8
		for i = 1, raysCount do
			local x = BUILDING_NODE_WIDTH / 2 * math.cos(targetAngle / 180 * math.pi + math.pi / raysCount * 2 * i)
			local y = BUILDING_NODE_WIDTH / 2 * math.sin(targetAngle / 180 * math.pi + math.pi / raysCount * 2 * i)

			local v1 = targetPosition + Vector3(0, 0, -0.1)
			local v2 = targetPosition + Vector3(x, y, -0.1)
			
			if not isLineOfSightClear(v1, v2) then
				return false
			end
		end	
		return targetPosition, targetAngle, false
	end,

	["Foundation"] = function (targetObject, targetPosition, targetAngle)
		local directions = {
			targetObject.matrix:getForward(), 
			targetObject.matrix:getRight(), 
			-targetObject.matrix:getForward(),
			-targetObject.matrix:getRight()
		}
		local offset = targetPosition - targetObject.position
		local min = 100000
		local minPoint = nil
		local minIndex = 0
		for i, v in ipairs(directions) do
			local dist = getDistanceBetweenPoints2D(v, offset)
			if dist < min then
				min = dist
				minPoint = v
				minIndex = i
			end
		end
		local raysCount = 8
		targetPosition = targetObject.position + minPoint * BUILDING_NODE_WIDTH
		for i = 1, raysCount do
			local x = BUILDING_NODE_WIDTH / 2.1 * math.cos(targetObject.rotation.z / 180 * math.pi + math.pi / raysCount * 2 * i)
			local y = BUILDING_NODE_WIDTH / 2.1 * math.sin(targetObject.rotation.z / 180 * math.pi + math.pi / raysCount * 2 * i)
			
			if not isLineOfSightClear(targetPosition + Vector3(0, 0, -0.03), targetPosition + Vector3(x, y, -0.03)) then
				return false
			end
			if isLineOfSightClear(targetPosition + Vector3(x, y, 0), targetPosition + Vector3(x, y, -partSize.foundation.z)) then
				return false
			end
		end
		return targetPosition, targetObject.rotation.z, true
	end
}

placementRules["Floor"] = {
	-- Пол можно установить на фундамент
	["Foundation"] = function (targetObject, targetPosition, targetAngle)
		return targetObject.matrix:transformPosition(0, 0, BUILDING_NODE_HEIGHT), targetObject.rotation.z, true
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
		return targetPosition, targetAngle, true
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