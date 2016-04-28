Wall = Part:subclass "Wall"

function Wall:checkPlacement(building, x, y, z, direction)
	-- Wall must be placed on floor
	if not building:containsPartOfType(Floor, x, y, z) then
		return false
	end

	-- Check wall at the neighboring node
	local ox, oy = getDirectionOffset(direction)
	if building:findPart(Wall, x + ox, y + oy, z, getOppositeDirection(direction)) then
		return false
	end
	return true
end

function Wall:checkPart(part)
	-- Check walls at the same position
	if part:class() == Wall and part.direction == direction then
		return false
	end
	return true
end

function Wall:spawn()
	self.super:spawn()

	local position = self.building:getLocalPosition(self.x, self.y, self.z)
	position = position + Vector3(0, 0, -BUILDING_NODE_HEIGHT / 2)
	position = position + getMatrixDirection(self.building.matrix, self.direction) * BUILDING_NODE_WIDTH / 2
	
	local rotation = Vector3(0, 0, 90 * self.direction - 90)
	self.element = createObject(
		exports.rsModels:getModelFromName("wall"), 
		self.building:getWorldPosition(position),
		self.building:getWorldRotation(rotation)
	)
end