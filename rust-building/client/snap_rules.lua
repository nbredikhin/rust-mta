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

snapRules["foundation"] = {}
snapRules["foundation"]["world"] = true
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
	local fnd = object:getData("rust-foundation_" .. direction)
	if isElement(fnd) then
		--return false
	end

	position = object.position + minPoint * ModelsSizes.foundation.width-- - modelsOffsets.foundation
	rotation = object.rotation.z
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

	local wall = object:getData("rust-wall_" .. direction)
	if isElement(wall) then
		return false
	end
	local fnd = object:getData("rust-foundation_" .. direction)
	if isElement(fnd) then
		wall = fnd:getData("rust-wall_" .. getOppositeDirection(direction))
		if isElement(wall) then
			return false
		end
	end

	position = object.position + minPoint * (ModelsSizes.foundation.width / 2)-- - modelsSizes.wallDepth / 2)
	rotation = -math.atan2(minPoint.x, minPoint.y) / math.pi * 180 + 90
	return position, rotation, direction
end
snapRules["wall"]["floor"] = snapRules["wall"]["foundation"]
snapRules["wall"]["stairs"] = snapRules["wall"]["foundation"]--[[function(object, position, rotation)
	position, rotation, direction = snapRules["wall"]["foundation"](object, position, rotation)
	if not position then
		return false
	end
	position = position + Vector3(0, 0, ModelsSizes.stairs.height / 2)
	return position, rotation, direction
end]]
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
	rotation = math.floor(rotation / 90) * 90 + 180
	return position, object.rotation.z
end 
snapRules["stairs"]["floor"] = snapRules["stairs"]["foundation"]