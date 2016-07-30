-- Привязка объектов при предпросмотре
PartSnap = {}

local rules = {}
-- rules[что ставим][на что ставим]
rules["foundation"] = {}
rules["foundation"]["world"] = {
	offset = {x = 0, y = 0, z = 0.5},
}
rules["foundation"]["foundation"] = {
	snap = {
		type = "direction",
		distance = partSize.foundation.x
	}
}
--------------------------------------------------------------------------------
rules["wall"] = {}
rules["wall"]["foundation"] = {
	snap = {
		type = "direction",
		distance = partSize.foundation.x / 2
	}
}
rules["wall"]["floor"] = rules["wall"]["foundation"]
rules["wall"]["wall"] = {
	snap = {
		type = "offset",
		offset = {x = 0, y = 0, z = partSize.wall.z / 2 - partSize.floor.z}
	}
}
--------------------------------------------------------------------------------
rules["wall_window"] = rules["wall"]
rules["wall_door"] = rules["wall"]
--------------------------------------------------------------------------------
rules["floor"] = {}
rules["floor"]["foundation"] = {
	snap = {
		type = "offset",
		offset = {x = 0, y = 0, z = partSize.wall.z / 2 - partSize.floor.z}
	}
}
rules["floor"]["floor"] = rules["floor"]["foundation"]
--------------------------------------------------------------------------------
rules["stairway"] = {}
rules["stairway"]["foundation"] = {	
	snap = {
		type = "offset",
		offset = {x = 0, y = 0, z = partSize.stairway.z / 2},
		directionFromRotation = true,
		rotation = 90,
	}	
}
rules["stairway"]["floor"] = rules["stairway"]["foundation"] 

local function directionSnap(snap, object2, x, y, z, rotation)
	-- Позиция, куда смотрит игрок, относительно объекта
	local relativePosition = {
		x = x - object2.position.x,
		y = y - object2.position.y
	}

	-- Массив векторов направлений
	local directionVectors = {}
	directionVectors[1] = getMatrixDirection(object2.matrix, 0)
	directionVectors[2] = getMatrixDirection(object2.matrix, 1)
	directionVectors[3] = getMatrixDirection(object2.matrix, 2)
	directionVectors[4] = getMatrixDirection(object2.matrix, 3)

	-- Поиск ближайшего направления
	local minDistance, minPoint, minIndex = 9999, nil, -1
	for i, point in ipairs(directionVectors) do
		local distance = getDistanceBetweenPoints2D(point.x, point.y, relativePosition.x, relativePosition.y)
		if distance < minDistance then
			minDistance = distance
			minPoint = point
			minIndex = i
		end
	end

	local direction = minIndex - 1
	x = object2.position.x + minPoint.x * snap.distance
	y = object2.position.y + minPoint.y * snap.distance
	z = object2.position.z
	rotation = 90 * direction + object2.rotation.z + 90
	return x, y, z, rotation, direction
end

local function offsetSnap(snap, object2, x, y, z, rotation)
	x = object2.position.x
	y = object2.position.y 
	z = object2.position.z
	if snap.offset then
		x = x + snap.offset.x
		y = y + snap.offset.y
		z = z + snap.offset.z
	end	
	local direction = 0
	if snap.directionFromRotation then
		direction = getDirectionFromRotation(rotation)
		rotation = object2.rotation.z + 90 * direction
	else
		rotation = object2.rotation.z
	end
	if snap.rotaiton then
		rotation = rotation + snap.rotation
	end
	return x, y, z, rotation, direction
end

function PartSnap.getSnap(object1, partName1, object2, partName2, x, y, z, rotation)
	local rule = rules[partName1][partName2]
	if not rule then
		return false
	end
	local direction = 0
	if rule.offset then
		x = x + rule.offset.x
		y = y + rule.offset.y
		z = z + rule.offset.z
	end
	if rule.rotation then
		rotation = rotation + rule.rotation
	end
	if rule.snap then
		local snap = rule.snap
		if snap.type == "direction" then
			x, y, z, rotation, direction = directionSnap(snap, object2, x, y, z, rotation)
		elseif snap.type == "offset" then
			x, y, z, rotation, direction = offsetSnap(snap, object2, x, y, z, rotation)
		end
	end
	return x, y, z, rotation, direction
end

function PartSnap.hasRule(partName1, partName2)
	if not rules[partName1] then
		return false
	end
	return not not rules[partName1][partName2]
end