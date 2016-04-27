Part = newclass "Part"

function Part:init()
	self.spawned = false
end

function Part:checkPlacement(building, x, y, z, direction)
	return true
end

function Part:checkPart(part)
	return true
end

function Part:spawn()
	self.spawned = true
end

function Part:destroy()
	if isElement(self.element) then
		self.element:destroy()
	end
	self.spawned = false
end