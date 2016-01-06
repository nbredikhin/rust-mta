class "BuildingStructure"

function BuildingStructure:BuildingStructure(position, rotation)
	self.position = position
	self.rotation = rotation

	self.foundations = {}

	-- Создание первого фундамента
	self:AddFoundation(0, 0)
	setElementRotation(self:GetFoundation(0, 0), 0, 0, self.rotation)
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

function BuildingStructure:GetFoundation(x, y)
	if self.foundations[x] and self.foundations[x][y] then
		return self.foundations[x][y]
	end
	return false
end

function BuildingStructure:AddFoundation(x, y)
	-- Проверка на существование фундамента
	if self:GetFoundation(x, y) then
		outputDebugString("Foundation already exists")
		return false
	end

	-- Проверка существования соседних фундаментов
	if x ~= 0 or y ~= 0 then
		if not self:GetFoundation(x - 1, y) and not self:GetFoundation(x + 1, y) and not self:GetFoundation(x, y - 1) and not self:GetFoundation(x, y + 1) then
			outputDebugString("No neighboring foundations")
			return false
		end
	end

	-- Создание объекта
	local objectPosition = self.position
	local objectRotation = self.rotation
	if x ~= 0 or y ~= 0 then
		local baseFoundation = self:GetFoundation(0, 0)
		objectPosition = Vector3(self.position.x, self.position.y, self.position.z)
		objectPosition = objectPosition + ModelsSizes.foundation.width * x * baseFoundation.matrix:getRight()
		objectPosition = objectPosition + ModelsSizes.foundation.width * y * baseFoundation.matrix:getForward()
	end

	local object = createObject(ReplacedModelsIDs["foundation"], objectPosition, 0, 0, objectRotation)
	object:setData("rust-foundation-offset", {x, y})

	-- Добавление в массив фундаментов
	if not self.foundations[x] then
		self.foundations[x] = {}
	end
	self.foundations[x][y] = object

	return object
end

function BuildingStructure:GetFoundationWall(foundation, direction)
	if not isElement(foundation) or not direction then
		return false
	end
	return foundation:getData("rust-foundation-wall_" .. tostring(direction))
end

function BuildingStructure:AddWall(wallType, foundation, direction)
	if not isElement(foundation) or not direction then
		return false
	end

	local foundationOffset = foundation:getData("rust-foundation-offset")
	if not foundationOffset then
		return false
	end
	local foundationX, foundationY = unpack(foundationOffset)
	local wallOffsetX, wallOffsetY = convertDirectionNameToOffset(direction)

	-- Проверка наличия стены
	if self:GetFoundationWall(foundation, direction) then
		outputDebugString("Wall already exists")
		return false
	end
	-- Проверка наличия стены на соседнем фундаменте
	local checkFoundation = self:GetFoundation(foundationX + wallOffsetX, foundationY + wallOffsetY)
	if isElement(checkFoundation) then
		local checkWall = self:GetFoundationWall(checkFoundation, getOppositeDirection(direction))
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
	local object = createObject(ReplacedModelsIDs[wallName], objectPosition, Vector3(0, 0, foundation.rotation.z + convertDirectionNameToRotation(direction) + 90))
	
	object:setData("rust-wall-foundation", foundation)
	foundation:setData("rust-foundation-wall_" .. tostring(direction), object)
end