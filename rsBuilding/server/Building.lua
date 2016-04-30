Building = newclass "Building"

function Building:init(position, rotationZ, foundation)
	check("Building:new", {
		{position, "userdata"},
		{rotationZ, "number"},
		{foundation, "table"}
	})	
	self.grid = {}
	self.position = position
	self.rotationZ = rotationZ
	self.matrix = Matrix(position)
	self:addPart(foundation, 0, 0, 0, 0)
end

function Building:getWorldPosition(position)
	check("Building:getWorldPosition", {position, "userdata"})
	position = rotateVector(position, self.rotationZ)
	return self.position + position
end

function Building:getWorldRotation(rotation)
	check("Building:getWorldRotation", {rotation, "userdata"})
	rotation = rotation + Vector3(0, 0, self.rotationZ)
	return self.matrix:transformDirection(rotation)
end

function Building:getLocalPosition(x, y, z)
	check("Building:getLocalPosition", {
		{x, "number"},
		{y, "number"},
		{z, "number"}
	})			
	return 	Vector3(x * BUILDING_NODE_WIDTH,
			y * BUILDING_NODE_WIDTH,
			z * BUILDING_NODE_HEIGHT + BUILDING_NODE_HEIGHT / 2)
end

function Building:containsPartOfType(partClass, x, y, z)
	check("Building:containsPartOfType", {
		{partClass, "table"},
		{x, "number"},
		{y, "number"},
		{z, "number"}
	})		
	local parts = self:getPartsAt(x, y, z)
	if not parts then
		return false
	end
	for part in pairs(parts) do
		if isPartOfType(part, partClass) then
			return true
		end
	end
	return false
end

function Building:findPart(partClass, x, y, z, direction)
	check("Building:findPart", {
		{partClass, "table"},
		{x, "number"},
		{y, "number"},
		{z, "number"}
	})	
	local parts = self:getPartsAt(x, y, z)
	if not parts then
		return false
	end
	for part in pairs(parts) do
		if isPartOfType(part, partClass) and (part.direction == direction) then
			return part
		end
	end
	return false
end

function Building:addPart(part, x, y, z, direction)
	check("Building:addPart", {
		{part, "table"},
		{x, "number"},
		{y, "number"},
		{z, "number"}
	})
	if part.spawned then
		return false
	end
	-- Default direction
	if type(direction) ~= "number" then direction = 0 end
	direction = direction % 4

	if not part:checkPlacement(self, x, y, z, direction) then
		return false
	end

	-- Check and setup grid
	if not self.grid[x] then self.grid[x] = {} end
	if not self.grid[x][y] then self.grid[x][y] = {} end
	if not self.grid[x][y][z] then self.grid[x][y][z] = {} end

	-- Check is placement allowed by other parts in this node
	for p in pairs(self:getPartsAt(x, y, z)) do
		if not part:checkPart(p, x, y, z, direction) then
			return false
		end
	end

	-- Setup part
	self.grid[x][y][z][part] = true
	part.building = self
	part.x = x
	part.y = y
	part.z = z
	part.direction = direction
	part:spawn()
	return true
end

function Building:getPartsAt(x, y, z)
	check("Building:getPartAt", {
		{x, "number"},
		{y, "number"},
		{z, "number"}
	})
	if not self.grid[x] then return false end
	if not self.grid[x][y] then return false end
	return self.grid[x][y][z]	
end

function Building:removePart(part)
	check("Building:removePartAt", {
		{part, "table"}
	})
	if not part.spawned then
		return false
	end
	local parts = self:getPartsAt(part.x, part.y, part.z)
	if not parts then
		return false
	end
	part:destroy()
	parts[part] = nil
	return true
end