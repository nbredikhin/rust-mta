Building = newclass "Building"

function Building:init(position, foundation)
	check("Building:new", {
		{position, "userdata"},
		{foundation, "table"}
	})	
	self.grid = {}
	self.position = position
	self:addPart(foundation, 0, 0, 0, 0)
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
		if not part:checkPart(p) then
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