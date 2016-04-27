Floor = Part:subclass "Floor"

function Floor:checkPart(part)
	-- Can't place floor alongside another floor
	if part:class():inherits(Floor) then
		return false
	end
end