snapRules = {}

function getOppositeDirection(direction)
	if direction == "right" then
		return "left"
	elseif direction == "left" then
		return "right"
	elseif direction == "forward" then
		return "backward"
	elseif direction == "backward" then
		return "forward"
	end
end

function getDirectionName(index)
	local direction
	if index == 1 then
		direction = "forward"
	elseif index == 2 then
		direction = "backward"
	elseif index == 3 then
		direction = "right"
	elseif index == 4 then
		direction = "left"
	end
	return direction
end

function getDirectionOffset(direction)
	if direction == "right" then
		return 1, 0
	elseif direction == "left" then
		return -1, 0
	elseif direction == "forward" then
		return 0, 1
	elseif direction == "backward" then
		return 0, -1
	end
end

local function getPreviousDirection(direction)
	if direction == "forward" then
		return "right"
	elseif direction == "right" then
		return "backward"
	elseif direction == "backward" then
		return "left"
	elseif direction == "left" then
		return "forward"
	end
end

local function getNextDirection(direction)
	if direction == "forward" then
		return "left"
	elseif direction == "left" then
		return "backward"
	elseif direction == "backward" then
		return "right"
	elseif direction == "right" then
		return "forward"
	end
end

local function rotateDirection(direction, angle)
	local isNext = angle > 0
	local stepsCount = math.ceil(math.abs(angle / 90))
	for i = 1, stepsCount % 4 do
		if isNext then
			direction = getNextDirection(direction)
		else
			direction = getPreviousDirection(direction)
		end
	end
	return direction
end

local foundationRaysCount = 8
snapRules["foundation"] = {}
snapRules["foundation"]["world"] = function(position, rotation)
	for i = 1, foundationRaysCount do
		local x = ModelsSizes.foundation.width / 2 * math.cos(rotation / 180 * math.pi + math.pi / foundationRaysCount * 2 * i)
		local y = ModelsSizes.foundation.width / 2 * math.sin(rotation / 180 * math.pi + math.pi / foundationRaysCount * 2 * i)

		local x1, y1, z1 = position.x, position.y, position.z - 0.1
		local x2, y2, z2 = position.x + x, position.y + y, position.z - 0.1
		
		if not isLineOfSightClear(x1, y1, z1, x2, y2, z2) then
			return false
		end
	end
	return true
end
snapRules["foundation"]["foundation"] = function(object, position, rotation)
	local offset = position - object.position
	local directions = {object.matrix:getForward(), -object.matrix:getForward(), object.matrix:getRight(), -object.matrix:getRight()}
	local min = 100000
	local minPoint = nil
	local minIndex = 0
	for i, v in ipairs(directions) do
		local dist = getDistanceBetweenPoints2D(v.x, v.y, offset.x, offset.y)
		if dist < min then
			min = dist
			minPoint = v
			minIndex = i
		end
	end
	local direction = getDirectionName(minIndex)

	position = object.position + minPoint * ModelsSizes.foundation.width-- - modelsOffsets.foundation
	rotation = object.rotation.z
	for i = 1, foundationRaysCount do
		local x = ModelsSizes.foundation.width / 2.1 * math.cos(rotation / 180 * math.pi + math.pi / foundationRaysCount * 2 * i)
		local y = ModelsSizes.foundation.width / 2.1 * math.sin(rotation / 180 * math.pi + math.pi / foundationRaysCount * 2 * i)

		local x1, y1, z1 = position.x, position.y, position.z - 0.03
		local x2, y2, z2 = position.x + x, position.y + y, position.z - 0.03
		
		if not isLineOfSightClear(x1, y1, z1, x2, y2, z2) then
			return false
		end
		if isLineOfSightClear(x2, y2, position.z, x2, y2, position.z - ModelsSizes.foundation.height) then
			return false
		end
	end
	return position, rotation, direction
end

snapRules["wall"] = {}
snapRules["wall"]["foundation"] = function(object, position, rotation)
	local offset = position - object.position
	local directions = {object.matrix:getForward(), -object.matrix:getForward(), object.matrix:getRight(), -object.matrix:getRight()}
	local min = 100000
	local minPoint = nil
	local minIndex = 0
	for i, v in ipairs(directions) do
		local dist = getDistanceBetweenPoints2D(v.x, v.y, offset.x, offset.y)
		if dist < min then
			min = dist
			minPoint = v
			minIndex = i
		end
	end

	local direction = getDirectionName(minIndex)

	position = object.position + minPoint * (ModelsSizes.foundation.width / 2)-- - modelsSizes.wallDepth / 2)
	rotation = -math.atan2(minPoint.x, minPoint.y) / math.pi * 180
	return position, rotation, direction
end
snapRules["wall"]["floor"] = snapRules["wall"]["foundation"]
snapRules["wall"]["wall"] = function(object, position, rotation)
	position = object.position + Vector3(0, 0, ModelsSizes.wall.height)-- - modelsSizes.wallDepth / 2)
	rotation = object.rotation.z + 90
	return position, rotation, direction
end


snapRules["wall_door"] = snapRules["wall"]
snapRules["wall_window"] = snapRules["wall"]

snapRules["floor"] = {}
snapRules["floor"]["foundation"] = function(object, position, rotation)
	local wallsCount = object:getData("rust-walls-count") or 0
	if wallsCount < 1 then
		--return false
	end
	position = object.position + object.matrix:getUp() * (ModelsSizes.wall.height)
	return position, object.rotation.z
end
snapRules["floor"]["floor"] = function(object, position, rotation)
	position = object.position + object.matrix:getUp() * (ModelsSizes.wall.height)
	return position, object.rotation.z
end
snapRules["floor"]["wall"] = function(object, position, rotation)
	object = object:getData("rust-wall-floor")
	if not object then
		return false
	end
	position = object.position + object.matrix:getUp() * (ModelsSizes.wall.height)
	return position, object.rotation.z
end
snapRules["floor"]["wall_door"] = snapRules["floor"]["wall"]
snapRules["floor"]["wall_window"] = snapRules["floor"]["wall"]

snapRules["stairs"] = {}
snapRules["stairs"]["foundation"] = function(object, position, rotation)
	position = object.position + object.matrix:getUp() * (ModelsSizes.foundation.height / 2)
	rotation = math.floor(rotation / 90) * 90
	return position, object.rotation.z + rotation
end 
snapRules["stairs"]["floor"] = snapRules["stairs"]["foundation"]

snapRules["door"] = {}
snapRules["door"]["wall_door"] = function(object, position, rotation) 
	return object.position, object.rotation.z - 90 
end