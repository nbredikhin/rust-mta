Stairway = Part:subclass "Stairway"

function Stairway:checkPlacement(building, x, y, z, direction)
	-- Must be placed on floor
	if not building:containsPartOfType(Floor, x, y, z) then
		return false
	end

	return true
end

function Stairway:checkPart(part, x, y, z, direction)
	if isPartOfType(part, Stairway) then
		return false
	end
	return true
end

function Stairway:spawn(building, x, y, z, direction)
	self.super:spawn(building, x, y, z, direction)

	local position = self.building:getLocalPosition(self.x, self.y, self.z)
	position = position + Vector3(0, 0, BUILDING_NODE_HEIGHT / 2)
	local rotation = Vector3(0, 0, 90 * self.direction)
	self.element = createObject(
		exports.rsModels:getModelFromName("stairs"), 
		self.building:getWorldPosition(position),
		self.building:getWorldRotation(rotation)
	)
	self.element:setData("rsBuilding.type", self:class():name())
end