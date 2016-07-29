-- Привязка объектов при предпросмотре
PartSnap = {}

local rules = {}
-- rules[что ставим][на что ставим]

rules["foundation"] = {}
rules["foundation"]["world"] = {
	offset = {x = 0, y = 0, z = 0.5}
}

function PartSnap.getSnap(object1, partName1, object2, partName2, x, y, z, rotation)
	local rule = rules[partName1][partName2]
	if not rule then
		return false
	end
	local direction = 0
	if rule.offset then
		x = x + rule.offset.x
		y = y + rule.offset.y
		z = z + rule.offset.z
	end

	return x, y, z, rotation, direction
end

function PartSnap.hasRule(partName1, partName2)
	return not not rules[partName1][partName2]
end