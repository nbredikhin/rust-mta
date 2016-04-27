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