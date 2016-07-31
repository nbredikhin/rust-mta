-- Предпросмотр установки строительного объекта
PartPreview = {}
PartPreview.partName = nil

-- Максимальное расстояние от камеры, на котором можно строить
local PLACEMENT_RANGE = 30 -- 15

local screenWidth, screenHeight = guiGetScreenSize()
local placementScreenPosition = {x = screenWidth / 2, y = screenHeight / 2}

local object
local targetObject
local previewPositionX, previewPositionY, previewPositionZ = 0, 0, 0
local previewRotation = 0
local previewDirection = 0

local highlightShader

local function update(deltaTime)
	if not object then
		return
	end
	-- Скрыть объект по умолчанию
	object:setPosition(0, 0, -1000)
	-- Позиция, куда смотрит камера
	local lx, ly, lz = getWorldFromScreenPosition(placementScreenPosition.x, placementScreenPosition.y, PLACEMENT_RANGE)
	-- Позиция камеры
	local cx, cy, cz = getCameraMatrix()
	-- Точка в мире, куда смотрит камера
	local hit, wx, wy, wz, hitObject = processLineOfSight(
		cx, cy, cz,
		lx, ly, lz, 
		-- Проверка столкновений
		true, 	-- Мир
		false, 	-- Машины
		false, 	-- Игроки
		true, 	-- Объекты
		false 	-- Дамми
	)
	-- Если камера смотрит слишком далеко
	if not wx then
		return
	end

	-- Угол поворота объекта в градусах
	local rotation = -math.atan2(cx - wx, cy - wy) / math.pi * 180
	-- Привязка объектов
	local targetPartName = "world"
	if hitObject then
		targetObject = hitObject
		targetPartName = targetObject:getData("rsBuilding.type") or "world"
	else
		targetObject = nil
	end
	if PartSnap.hasRule(PartPreview.partName, targetPartName) then
		local x, y, z, rotation, direction = PartSnap.getSnap(object, PartPreview.partName, targetObject, targetPartName, wx, wy, wz, rotation)
		if x then
			previewPositionX, previewPositionY, previewPositionZ = x, y, z
			previewRotation = rotation
			previewDirection = direction
			
			object:setPosition(x, y, z)
			object:setRotation(0, 0, rotation)
		end
	end
end

local function placePart()
	if not PartPreview.partName then
		return false
	end

	triggerServerEvent("rsBuilding.build", resourceRoot, 
		targetObject, 
		PartPreview.partName, 
		previewPositionX,
		previewPositionY,
		previewPositionZ,
		previewRotation,
		previewDirection
	)
end

function PartPreview.showPart(name)
	if type(name) ~= "string" or PartPreview.partName == name then
		return false
	end
	local model = exports.rsModels:getModelFromName(name)
	if not model then
		return false
	end	
	-- Если предпросмотр не отображается
	if not PartPreview.partName or not object then
		-- Создать объект
		object = createObject(model, 0, 0, -10)
		object:setCollisionsEnabled(false)
		-- Применить шейдер
		highlightShader:applyToWorldTexture("*", object)

		addEventHandler("onClientPreRender", root, update)		
	else
		-- Если предпросмотр уже отображается, просто меняем модель
		object.model = model
	end
	PartPreview.partName = name
	return true
end

function PartPreview.hidePart()
	if not PartPreview.partName then
		return false
	end
	PartPreview.partName = nil
	-- Удалить объект
	if isElement(object) then
		destroyElement(object)
	end
	object = nil
	removeEventHandler("onClientPreRender", root, update)
	return true
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
	highlightShader = DxShader("assets/shaders/highlight.fx")
	highlightShader:setValue("gColor", {0, 255, 0, 150})

	PartPreview.showPart("foundation")
	bindKey("mouse1", "down", placePart)
end)