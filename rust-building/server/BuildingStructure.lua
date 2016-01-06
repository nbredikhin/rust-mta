class "BuildingStructure"

local directions = {"right", "left", "forward", "backward"}

function BuildingStructure:BuildingStructure(position, rotation)
	self.position = position
	self.rotation = rotation

	self.floors = {}

	-- Создание первого фундамента
	self:AddFloor(0, 0, 0)
	setElementRotation(self:GetFloor(0, 0, 0), 0, 0, self.rotation)
end


local function getOppositeDirection(direction)
	if direction == "right" then
		return "left"
	elseif direction == "left" then
		return "right"
	elseif direction == "forward" then
		return "backward"
	elseif direction == "backward" then
		return "forward"
	end
end

local function convertDirectionNameToOffset(direction)
	if direction == "right" then
		return 1, 0
	elseif direction == "left" then
		return -1, 0
	elseif direction == "forward" then
		return 0, 1
	elseif direction == "backward" then
		return 0, -1
	end
end

local function getObjectDirection(object, direction)
	if direction == "right" then
		return object.matrix:getRight()
	elseif direction == "left" then
		return -object.matrix:getRight()
	elseif direction == "forward" then
		return object.matrix:getForward()
	elseif direction == "backward" then
		return -object.matrix:getForward()
	end
end

local function convertDirectionNameToRotation(direction)
	if direction == "right" then
		return -90
	elseif direction == "left" then
		return 90
	elseif direction == "forward" then
		return 0
	elseif direction == "backward" then
		return 180
	end
end

function BuildingStructure:GetFloor(x, y, h)
	if self.floors[x] and self.floors[x][y] and self.floors[x][y][h] then
		return self.floors[x][y][h]
	end
	return false
end

function BuildingStructure:SetFloor(x, y, h, floor)
	if not self.floors[x] then
		self.floors[x] = {}
	end
	if not self.floors[x][y] then
		self.floors[x][y] = {}
	end
	if not self.floors[x][y][h] then
		self.floors[x][y][h] = floor
	end
end

function BuildingStructure:GetBaseFoundation()
	return self:GetFloor(0, 0, 0)
end

function BuildingStructure:AddFloor(x, y, h)
	if h < 0 then
		return
	end
	-- Проверка на существование фундамента
	if self:GetFloor(x, y, h) then
		outputDebugString("Floor already exists")
		return false
	end

	-- Проверка существования соседних фундаментов
	if (x ~= 0 or y ~= 0) and (h == 0) then
		if not self:GetFloor(x - 1, y, h) and not self:GetFloor(x + 1, y, h) and not self:GetFloor(x, y - 1, h) and not self:GetFloor(x, y + 1, h) then
			outputDebugString("No neighboring foundations")
			return false
		end
	end
	
	if h > 0 then
		-- Проверка существования фундамента под полом
		if not self:GetFloor(x, y, 0) then
			outputDebugString("No foundations under floor")
			return false
		end
		if self:GetWallsCount(self:GetFloor(x, y, h - 1)) < 2 then
			outputDebugString("Not enough walls")
			return false
		end
	end

	-- Создание объекта
	local objectPosition = self.position
	if x ~= 0 or y ~= 0 or h ~= 0 then
		local baseFloor = self:GetFloor(0, 0, 0)
		objectPosition = Vector3(self.position.x, self.position.y, self.position.z + ModelsSizes.wall.height * h)
		objectPosition = objectPosition + ModelsSizes.foundation.width * x * baseFloor.matrix:getRight() + ModelsSizes.foundation.width * y * baseFloor.matrix:getForward()
	end
	if h > 1 then
		objectPosition = objectPosition + Vector3(0, 0, ModelsSizes.floor.height)
	end
	local modelName = "foundation"
	if h > 0 then
		modelName = "floor"
	end
	local object = createObject(ReplacedModelsIDs[modelName], objectPosition, 0, 0, self.rotation)
	object:setData("rust-floor-offset", {x, y, h})
	object:setData("rust-floor-foundation", object)

	-- Добавление в массив фундаментов
	self:SetFloor(x, y, h, object)

	return object
end

function BuildingStructure:GetWall(floor, direction)
	if not isElement(floor) or not direction then
		return false
	end
	return floor:getData("rust-floor-wall_" .. tostring(direction))
end

function BuildingStructure:GetWallsCount(floor)
	local floorOffset = floor:getData("rust-floor-offset")
	local floorX, floorY, floorH = unpack(floorOffset)

	local count = 0
	for i, direction in ipairs(directions) do
		local wallOffsetX, wallOffsetY = convertDirectionNameToOffset(direction)
		if isElement(self:GetWall(floor, direction)) then
			count = count + 1
		else
			local checkFloor = self:GetFloor(floorX + wallOffsetX, floorY + wallOffsetY, floorH)
			local checkWall = self:GetWall(checkFloor, getOppositeDirection(direction))
			if isElement(checkWall) then
				count = count + 1
			end
		end
	end
	return count
end

-- Установка стены
function BuildingStructure:AddWall(wallType, floor, direction)
	if not isElement(floor) or not direction then
		return false
	end

	local foundation = floor:getData("rust-floor-foundation")
	if not isElement(foundation) then
		return
	end
	local floorOffset = foundation:getData("rust-floor-offset")
	if not floorOffset then
		return false
	end
	local floorX, floorY, floorH = unpack(floorOffset)
	local wallOffsetX, wallOffsetY = convertDirectionNameToOffset(direction)

	-- Проверка наличия стены
	if self:GetWall(floor, direction) then
		outputDebugString("Wall already exists")
		return false
	end
	-- Проверка наличия стены на соседнем полу
	local checkFloor = self:GetFloor(floorX + wallOffsetX, floorY + wallOffsetY, floorH)
	if isElement(checkFloor) then
		local checkWall = self:GetWall(checkFloor, getOppositeDirection(direction))
		if isElement(checkWall) then
			outputDebugString("Wall already exists")
			return false
		end
	end

	-- Установка стены
	local wallName = "wall"
	if wallType == "door" then
		wallName = wallName .. "_door"
	elseif wallType == "window" then
		wallName = wallName .. "_window"
	end

	local objectPosition = foundation.position + getObjectDirection(foundation, direction) * ModelsSizes.foundation.width / 2
	if floorH > 0 then
		objectPosition = objectPosition + Vector3(0, 0, ModelsSizes.floor.height)
	end
	local object = createObject(ReplacedModelsIDs[wallName], objectPosition, Vector3(0, 0, foundation.rotation.z + convertDirectionNameToRotation(direction) + 90))
	object:setData("rust-wall-floor", floor)
	floor:setData("rust-floor-wall_" .. tostring(direction), object)

	return object
end