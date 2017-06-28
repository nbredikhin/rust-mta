-- Предпросмотр установки строительного объекта
PartPreview = {}
PartPreview.partName = nil

-- Максимальное расстояние от камеры, на котором можно строить
local PLACEMENT_RANGE = 15

local screenWidth, screenHeight = guiGetScreenSize()
local placementScreenPosition = {x = screenWidth / 2, y = screenHeight / 2}

local object
local targetObject

local previewGridPosition
local previewDirection = 0

local previewAngle
local previewPosition

-- Шейдер для подсвечивания устанавливаемых частей
local highlightShader

local function update(deltaTime)
    if not object then
        return
    end
    -- Скрыть объект по умолчанию
    object:setPosition(0, 0, -1000)

    previewGridPosition = nil
    previewDirection = nil
    previewAngle = nil
    previewPosition = nil

    -- Точка, в которую смотрит камера
    local lx, ly, lz = getWorldFromScreenPosition(
        placementScreenPosition.x,
        placementScreenPosition.y,
        PLACEMENT_RANGE)
    -- Позиция камеры
    local cx, cy, cz = getCameraMatrix()
    -- Точка в мире, в которую смотрит камера
    local hit, wx, wy, wz, hitObject = processLineOfSight(
        cx, cy, cz,
        lx, ly, lz,
        -- Проверка столкновений
        true,   -- Мир
        false,  -- Машины
        false,  -- Игроки
        true,   -- Объекты
        false   -- Дамми
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
        targetPartName = BuildingClient.getPartName(targetObject) or "world"
    else
        targetObject = nil
    end
    if SnapRules.hasRule(PartPreview.partName, targetPartName) then
        local x, y, z, rotation, gx, gy, gz, direction =
            SnapRules.getSnap(
                object,
                PartPreview.partName,
                targetObject,
                targetPartName,
                wx,
                wy,
                wz,
                rotation)

        if x then
            -- Обновление позиции объекта для предпросмотра
            object:setPosition(x, y, z)
            object:setRotation(0, 0, rotation)

            -- Позиция на сетке
            previewGridPosition = {gx, gy, gz}
            previewDirection = direction
            -- Позиция в мире
            previewPosition = {x, y, z}
            previewAngle = rotation
        end
    end
end

local function buildPart()
    if not PartPreview.partName then
        return false
    end

    local building = BuildingClient.getPartBuilding(targetObject)
    local x, y, z
    local direction
    if building and previewGridPosition then
        x, y, z = unpack(previewGridPosition)
        direction = previewDirection
    elseif previewPosition then
        building = resourceRoot
        x, y, z = unpack(previewPosition)
        direction = previewAngle
    else
        return
    end

    -- outputDebugString("Build part " .. tostring(PartPreview.partName) .. " " ..  tostring(x) .. " " .. tostring(y) .. " " .. tostring(z))
    triggerServerEvent("buildPart", building, PartPreview.partName, x, y, z, previewDirection)
end

function PartPreview.showPart(name)
    if type(name) ~= "string" or PartPreview.partName == name then
        return false
    end
    local model = exports["rs_models"]:getModel(name)
    if not model then
        return false
    end
    -- Если предпросмотр не отображается
    if not PartPreview.partName or not object then
        -- Создать объект
        object = createObject(model, 0, 0, -10)
        object.alpha = 150
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
    highlightShader = DxShader("assets/highlight.fx")
    highlightShader:setValue("gColor", {0, 255, 0, 255})

    PartPreview.showPart("Floor")
    bindKey("mouse2", "down", buildPart)
end)

addCommandHandler("part", function(cmd, name)
    PartPreview.showPart(name)
end)

-- export
function showBuildingPart(name)
    if name then
        PartPreview.showPart(name)
    else
        PartPreview.hidePart()
    end
end

addEvent("showBuildingPartPreview", true)
addEventHandler("showBuildingPartPreview", localPlayer, showBuildingPart)
