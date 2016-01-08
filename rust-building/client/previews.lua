previews = {}
previews.material = dxCreateTexture("images/preview.png")
previews.material_door = dxCreateTexture("images/preview_door.png")
previews.material_window = dxCreateTexture("images/preview_window.png")

-- Рассчет точки, на которую должна смотреть стена
local function calculatePlaneLookAt(rotationX, rotationY)
	local xzLen = math.cos(rotationY)
	return xzLen * math.cos(rotationX), math.sin(-rotationY), xzLen * math.sin(-rotationX)
end

local function drawPlaneHorizontal(material, x, y, z, width, height, rotation, color)
	local radians = rotation / 180 * math.pi
	-- Look at
	local dx, dy, dz = calculatePlaneLookAt(math.pi / 2, 0)

	local halfWidth = width / 2
	local widthX = math.cos(radians) * halfWidth
	local widthY = math.sin(radians) * halfWidth
	dxDrawMaterialLine3D(x - widthX, y - widthY, z, x + widthX, y + widthY, z, material, height, color, x + dx, y + dy, z + dz)
end

local function drawPlaneVertical(material, x, y, z, width, height, rotation, color)
	local radians = rotation / 180 * math.pi
	-- Look at
	local dx, dy, dz = calculatePlaneLookAt(0, -radians)

	dxDrawMaterialLine3D(x, y, z + height / 2, x, y, z - height / 2, material, width, color, x + dx, y + dy, z + dz)
end

local function drawBox(materialTop, materialSide, x, y, z, size_width, size_depth, size_height, rotation, color)
	if not color then 
		color = tocolor(255, 255, 255)
	end
	rotation = rotation + 90
	local radians = rotation / 180 * math.pi
	local offsetX = math.cos(radians) * size_width / 2
	local offsetY = math.sin(radians) * size_width / 2

	drawPlaneHorizontal(materialTop, x, y, z + size_height / 2, size_width, size_depth, rotation, color)
	drawPlaneHorizontal(materialTop, x, y, z - size_height / 2, size_width, size_depth, rotation, color)

	drawPlaneVertical(materialSide, x + offsetX, y + offsetY, z, size_depth, size_height, rotation, color)
	drawPlaneVertical(materialSide, x - offsetX, y - offsetY, z, size_depth, size_height, rotation, color)

	radians = radians + math.pi / 2
	offsetX = math.cos(radians) * size_depth / 2
	offsetY = math.sin(radians) * size_depth / 2

	drawPlaneVertical(materialSide, x + offsetX, y + offsetY, z, size_width, size_height, rotation + 90, color)
	drawPlaneVertical(materialSide, x - offsetX, y - offsetY, z, size_width, size_height, rotation + 90, color)
end

local drawFunctions = {}

drawFunctions["foundation"] = function(x, y, z, rotation, color)
	drawBox(previews.material, previews.material, x, y, z - ModelsSizes.foundation.height / 2 - 0.02, ModelsSizes.foundation.width, ModelsSizes.foundation.width, ModelsSizes.foundation.height, rotation, color)
end

drawFunctions["wall"] = function(x, y, z, rotation, color)
	drawBox(previews.material, previews.material, x, y, z + ModelsSizes.wall.height / 2, ModelsSizes.wall.width, ModelsSizes.wall.depth, ModelsSizes.wall.height, rotation, color)
end

drawFunctions["wall_door"] = function(x, y, z, rotation, color)
	drawBox(previews.material, previews.material_door, x, y, z + ModelsSizes.wall.height / 2, ModelsSizes.wall.width, ModelsSizes.wall.depth, ModelsSizes.wall.height, rotation, color)
end

drawFunctions["wall_window"] = function(x, y, z, rotation,color)
	drawBox(previews.material, previews.material_window, x, y, z + ModelsSizes.wall.height / 2, ModelsSizes.wall.width, ModelsSizes.wall.depth, ModelsSizes.wall.height, rotation, color)
end

drawFunctions["floor"] = function(x, y, z, rotation, color)
	drawBox(previews.material, previews.material, x, y, z, ModelsSizes.floor.width, ModelsSizes.floor.width, ModelsSizes.floor.height, rotation, color)
end

drawFunctions["stairs"] = function(x, y, z, rotation, color)
	drawBox(previews.material, previews.material, x, y, z, ModelsSizes.foundation.width, ModelsSizes.foundation.width, ModelsSizes.foundation.height, rotation, color)
end

function previews:drawObject(name, ...)
	if drawFunctions[name] then
		drawFunctions[name](...)
	end
end