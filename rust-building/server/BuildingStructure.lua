class "BuildingStructure"

local directions = {"right", "left", "forward", "backward"}
local wallTypes = {"wall", "wall_door", "wall_window"}
local floorMinWallsCount = 2

function BuildingStructure:BuildingStructure(position, rotation)
	self.position = position
	self.rotation = rotation

	self.floors = {}
	self.id = -1
end

-- После того, как был присвоен ID
function BuildingStructure:Setup()
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

function BuildingStructure:AddFoundation(foundation, direction)
	if not isElement(foundation) or not direction then
		return
	end
	local floorOffset = foundation:getData("rust-floor-offset")
	if not floorOffset then
		return false
	end
	local floorX, floorY, floorH = unpack(floorOffset)
	local offsetX, offsetY = convertDirectionNameToOffset(direction)
	return self:AddFloor(floorX + offsetX, floorY + offsetY, floorH)
end

function BuildingStructure:AddFloorAboveFloor(floor)
	if not isElement(floor) then
		return 
	end
	local floorOffset = floor:getData("rust-floor-offset")
	if not floorOffset then
		return false
	end
	local floorX, floorY, floorH = unpack(floorOffset)
	return self:AddFloor(floorX, floorY, floorH + 1)
end

function BuildingStructure:AddFloorToWall(wall)
	if not isElement(wall) then
		return 
	end
	local floor = wall:getData("rust-wall-floor")
	return self:AddFloorAboveFloor(floor)
end

function BuildingStructure:GetNeighboringFloorsCount(x, y, h)
	local count = 0
	if self:GetFloor(x - 1, y, h) then
		count = count + 1
	end
	if self:GetFloor(x + 1, y, h) then
		count = count + 1 
	end
	if self:GetFloor(x, y - 1, h) then
		count = count + 1
	end
	if self:GetFloor(x, y + 1, h) then
		count = count + 1
	end
	return count
end

function BuildingStructure:AddFloor(x, y, h, isStairs)
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
		if self:GetNeighboringFloorsCount(x, y, h) == 0 then
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
		-- Достаточно ли стен под фундаментом
		local wallsCount = self:GetWallsCount(self:GetFloor(x, y, h - 1))
		local floorsCount = self:GetNeighboringFloorsCount(x, y, h)
		if wallsCount == 1 and floorsCount == 0 then
			return false
		elseif wallsCount < 1 then
			if floorsCount < 3 then
				return false
			end
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
		--objectPosition = objectPosition + Vector3(0, 0, ModelsSizes.floor.height)
	end
	local modelName = "foundation"
	if h > 0 then
		modelName = "floor"
		if isStairs then
			modelName = "stairs"
		end 
	end
	local object = createObject(ReplacedModelsIDs[modelName], objectPosition, 0, 0, self.rotation)
	object:setData("rust-floor-offset", {x, y, h})
	object:setData("rust-floor-foundation", object)
	object:setData("rust-structure-type", "floor")
	object:setData("rust-structure-id", self.id)
	if h > 0 then
		if isStairs then
			object:setData("rust-object-type", "stairs")
		else
			object:setData("rust-object-type", "floor")
		end
	else
		object:setData("rust-object-type", "foundation")
	end

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

function BuildingStructure:CheckWall(floor, direction)
	local floorOffset = floor:getData("rust-floor-offset")
	if not floorOffset then
		return false
	end
	local floorX, floorY, floorH = unpack(floorOffset)
	local wallOffsetX, wallOffsetY = convertDirectionNameToOffset(direction)

	-- Проверка наличия стены
	if self:GetWall(floor, direction) then
		return true
	end
	-- Проверка наличия стены на соседнем полу
	local checkFloor = self:GetFloor(floorX + wallOffsetX, floorY + wallOffsetY, floorH)
	if isElement(checkFloor) then
		local checkWall = self:GetWall(checkFloor, getOppositeDirection(direction))
		if isElement(checkWall) then
			return true
		end
	end

	return false
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
	local floorOffset = floor:getData("rust-floor-offset")
	if not floorOffset then
		return false
	end
	local floorX, floorY, floorH = unpack(floorOffset)

	-- Проверка наличия стены под стеной, если ставим на лестницу
	if floorH > 0 and floor:getData("rust-object-type") == "stairs" then
		if not self:CheckWall(self:GetFloor(floorX, floorY, floorH - 1), direction) then
			outputDebugString("No wall under wall")
			return false
		end
	end
	-- Проверка наличия стены
	if self:CheckWall(floor, direction) then
		outputDebugString("Wall already exists")
		return false
	end

	local objectPosition = foundation.position + getObjectDirection(foundation, direction) * ModelsSizes.foundation.width / 2
	if floorH > 0 then
		--objectPosition = objectPosition + Vector3(0, 0, ModelsSizes.floor.height)
	end
	local object = createObject(ReplacedModelsIDs[wallType], objectPosition, Vector3(0, 0, foundation.rotation.z + convertDirectionNameToRotation(direction) + 90))
	object:setData("rust-wall-floor", floor)
	object:setData("rust-structure-type", "wall")
	object:setData("rust-wall-type", wallType)
	object:setData("rust-structure-id", self.id)
	object:setData("rust-object-type", wallType)
	floor:setData("rust-floor-wall_" .. tostring(direction), object)

	return object
end

-- Установка лестницы
function BuildingStructure:AddStairs(floor, rotation)
	if not isElement(floor) then
		return false
	end
	if not rotation then
		rotation = floor.rotation.z
	end
	local x, y, h = unpack(floor:getData("rust-floor-offset"))
	local object = self:AddFloor(x, y, h + 1, true)
	if not object then
		return false
	end
	rotation = math.floor(rotation / 90) * 90
	--object.rotation = floor.rotation + Vector3(0, 0, rotation)
	return object
end

-- Установка двери
function BuildingStructure:AddDoor(wall)
	if not isElement(wall) then
		return
	end
	if wall:getData("rust-wall-door") then
		outputDebugString("Door already exists")
		return false
	end
	local objectPosition = wall.position + wall.matrix:getForward() * ModelsSizes.door.width / 2
	local object = createObject(ReplacedModelsIDs["door"], objectPosition, wall.rotation)
	wall:setData("rust-wall-door", object)
	object:setData("rust-door-closed-angle", object.rotation.z)
	object:setData("rust-door-wall", wall)
	object:setData("rust-structure-type", "door")
	object:setData("rust-structure-id", self.id)
	object:setData("rust-object-type", "door")

	return object
end