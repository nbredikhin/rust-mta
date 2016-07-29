Floor = Part:subclass "Floor"

function Floor:checkPlacement(building, x, y, z, direction)
	if z <= 0 then
		return false
	end
	if not building:containsPartOfType(Floor, x, y, 0) then
		return false
	end

	-- Counting walls under floor
	local wallsCount = 0
	local parts = building:getPartsAt(x, y, z - 1)
	if not parts then
		return false
	end
	for part in pairs(parts) do
		if isPartOfType(part, Wall) then
			wallsCount = wallsCount + 1
		end
	end
	-- Walls under neighboring floors
	for i = 0, 3 do
		local ox, oy = getDirectionOffset(i)
		if building:findPart(Wall, x + ox, y + oy, z - 1, getOppositeDirection(i)) then
			wallsCount = wallsCount + 1
		end
	end
	if wallsCount < 2 then
		outputChatBox(wallsCount)
		return false
	end
	return true
end

function Floor:checkPart(part, x, y, z, direction)
	-- Can't place floor alongside another floor
	if isPartOfType(part, Floor) then
		return false
	end
	return true
end

function Floor:spawn(building, x, y, z, direction)
	self.super:spawn(building, x, y, z, direction)

	local position = self.building:getLocalPosition(self.x, self.y, self.z)
	position = position + Vector3(0, 0, -BUILDING_NODE_HEIGHT / 2 - partSize.floor.z)
	local rotation = Vector3(0, 0, 90 * self.direction)
	self.element = createObject(
		exports.rsModels:getModelFromName("floor"), 
		self.building:getWorldPosition(position),
		self.building:getWorldRotation(rotation)
	)
	self.element:setData("rsBuilding.type", self:class():name())
end