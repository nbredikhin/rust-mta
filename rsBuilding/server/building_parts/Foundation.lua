Foundation = Floor:subclass "Foundation"

function Foundation:checkPlacement(building, x, y, z, direction)
	-- Foundation can only be placed at 1st floor
	if z > 0 then
		return false
	end
	return true
end