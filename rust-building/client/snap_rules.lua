snapRules = {}

function getOppositeDirection(direction)
	if direction == "r" then
		return "l"
	elseif direction == "l" then
		return "r"
	elseif direction == "f" then
		return "b"
	elseif direction == "b" then
		return "f"
	end
end

function getDirectionName(index)
	local direction
	if index == 1 then
		direction = "f"
	elseif index == 2 then
		direction = "b"
	elseif index == 3 then
		direction = "r"
	elseif index == 4 then
		direction = "l"
	end
	return direction
end

function getDirectionOffset(direction)
	if direction == "r" then
		return 1, 0
	elseif direction == "l" then
		return -1, 0
	elseif direction == "f" then
		return 0, 1
	elseif direction == "b" then
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
		return false
	end

	position = object.position + minPoint * modelsSizes.foundationWidth - modelsOffsets.foundation
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

	position = object.position + minPoint * (modelsSizes.foundationWidth / 2)-- - modelsSizes.wallDepth / 2)
	rotation = -math.atan2(minPoint.x, minPoint.y) / math.pi * 180 + 90
	return position, rotation, direction
end
snapRules["wall"]["floor"] = snapRules["wall"]["foundation"]
snapRules["wall_door"] = snapRules["wall"]
snapRules["wall_window"] = snapRules["wall"]

snapRules["floor"] = {}
snapRules["floor"]["foundation"] = function(object, position, rotation)
	local wallsCount = object:getData("rust-walls-count") or 0
	if wallsCount < 1 then
		--return false
	end
	position = object.position + object.matrix:getUp() * (modelsSizes.wallHeight)
	return position, object.rotation.z
end
snapRules["floor"]["floor"] = function(object, position, rotation)
	position = object.position + object.matrix:getUp() * (modelsSizes.wallHeight)
	return position, object.rotation.z
end