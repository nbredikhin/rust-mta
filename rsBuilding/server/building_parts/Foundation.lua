Foundation = Floor:subclass "Foundation"

function Foundation:checkPlacement(building, x, y, z, direction)
	-- Foundation can only be placed at 1st floor
	if z > 0 then
		return false
	end
	return true
end

function Foundation:spawn(building, x, y, z, direction)
	self.super.super:spawn(building, x, y, z, direction)

	local position = self.building:getLocalPosition(self.x, self.y, self.z)
	position = position + Vector3(0, 0, -BUILDING_NODE_HEIGHT / 2)
	local rotation = Vector3(0, 0, 90 * self.direction)
	self.element = createObject(
		exports.rsModels:getModelFromName("foundation"), 
		self.building:getWorldPosition(position),
		self.building:getWorldRotation(rotation)
	)
	self.element:setData("rsBuilding.type", self:class():name())
end