Wall = Part:subclass "Wall"

function Wall:checkPlacement(building, x, y, z, direction)
	-- Check floor at the neighboring node
	local ox, oy = getDirectionOffset(direction)
	local hasNeighboringFloor = building:containsPartOfType(Floor, x + ox, y + oy, z)
	
	-- Wall must be placed on floor or on wall
	if 	not (building:containsPartOfType(Floor, x, y, z) or hasNeighboringFloor) and -- floor under
		not building:findPart(Wall, x, y, z - 1, direction) -- wall under
	then
		return false
	end

	-- Check wall at the neighboring node
	if building:findPart(Wall, x + ox, y + oy, z, getOppositeDirection(direction)) then
		return false
	end
	return true
end

function Wall:checkPart(part, x, y, z, direction)
	-- Check walls at the same position
	if isPartOfType(part, Wall) and part.direction == direction then
		return false
	end
	return true
end

function Wall:spawn()
	self.super:spawn()

	local position = self.building:getLocalPosition(self.x, self.y, self.z)
	position = position + Vector3(0, 0, -BUILDING_NODE_HEIGHT / 2)
	position = position + getMatrixDirection(self.building.matrix, self.direction) * BUILDING_NODE_WIDTH / 2
	
	local rotation = Vector3(0, 0, -90 * self.direction + 90)
	self.element = createObject(
		exports.rsModels:getModelFromName("wall"), 
		self.building:getWorldPosition(position),
		self.building:getWorldRotation(rotation)
	)
end