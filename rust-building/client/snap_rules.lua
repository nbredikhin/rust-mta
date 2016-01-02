snapRules = {}

snapRules["foundation"] = {}
snapRules["foundation"]["world"] = true
snapRules["foundation"]["foundation"] = function(object, position, rotation)
	local offset = position - object.position
	local directions = {object.matrix:getForward(), -object.matrix:getForward(), object.matrix:getRight(), -object.matrix:getRight()}
	local min = 100000
	local minPoint = nil
	for i, v in ipairs(directions) do
		local dist = getDistanceBetweenPoints2D(v.x, v.y, offset.x, offset.y)
		if dist < min then
			min = dist
			minPoint = v
		end
	end
	position = object.position + minPoint * modelsSizes.foundationWidth - modelsOffsets.foundation
	rotation = -math.atan2(minPoint.x, minPoint.y) / math.pi * 180
	return position, rotation
end

snapRules["wall"] = {}
snapRules["wall"]["foundation"] = function(object, position, rotation)
	local offset = position - object.position
	local directions = {object.matrix:getForward(), -object.matrix:getForward(), object.matrix:getRight(), -object.matrix:getRight()}
	local min = 100000
	local minPoint = nil
	for i, v in ipairs(directions) do
		local dist = getDistanceBetweenPoints2D(v.x, v.y, offset.x, offset.y)
		if dist < min then
			min = dist
			minPoint = v
		end
	end
	position = object.position + minPoint * (modelsSizes.foundationWidth / 2)-- - modelsSizes.wallDepth / 2)
	rotation = -math.atan2(minPoint.x, minPoint.y) / math.pi * 180
	return position, rotation
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