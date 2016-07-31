local directionNames = {
	"forward", "right", "backward", "left"
}

local directions = {
	["forward"] 	= 0,
	["right"] 		= 1,
	["backward"] 	= 2,
	["left"] 		= 3,
}

function getOppositeDirection(direction)
	check("getOppositeDirection", {direction, "number"})
	return (direction + 2) % 4
end

function rotateDirectionRight(direction)
	check("rotateDirectionRight", {direction, "number"})
	return (direction + 1) % 4
end

function rotateDirectionLeft(direction)
	check("rotateDirectionLeft", {direction, "number"})
	return (direction - 1) % 4
end

function getDirectionName(direction)
	check("getDirectionName", {direction, "number"})
	return directionNames[direction]
end

function getDirectionFromName(name)
	return directions[name]
end

-- В градусах
function getDirectionFromRotation(rotation)
	local direction = math.floor(rotation / 90)
	return direction % 4
end

function getDirectionOffset(direction)
	check("getDirectionOffset", {direction, "number"})
	if direction == 0 then
		return 0, 1
	elseif direction == 1 then
		return 1, 0
	elseif direction == 2 then
		return 0, -1
	elseif direction == 3 then
		return -1, 0
	end
	return false
end

function getMatrixDirection(matrix, direction)
	check("getMatrixDirection", {
		{matrix, "userdata"},
		{direction, "number"}
	})
	direction = direction % 4
	if direction == 0 then
		return matrix.forward
	elseif direction == 1 then
		return matrix.right
	elseif direction == 2 then
		return -matrix.forward
	elseif direction == 3 then
		return -matrix.right
	end
end