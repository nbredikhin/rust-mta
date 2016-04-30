function rotateVector(v, angle)
	local theta = math.rad(angle)
	local cs = math.cos(theta)
	local sn = math.sin(theta)
	return Vector3(v.x * cs - v.y * sn, v.x * sn + v.y * cs, v.z)
end

function isPartOfType(part, partClass)
	return part:class():inherits(partClass) or part:class() == partClass
end