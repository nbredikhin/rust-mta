local PLACEMENT_RANGE = 20
local screenWidth, screenHeight = guiGetScreenSize()
local placementX, placementY = screenWidth / 2, screenHeight / 2
local anchorRadius = 70

local object
local activePartName
local activePosition = {}
local activeDirection = 0
local activeBuilding

local allowWorldPlacement = {
    Foundation = true
}

local function update(deltaTime)
    --deltaTime = deltaTime / 1000

    if not object then
        return
    end
    
    -- Скрыть объект по умолчанию
    object:setPosition(0, 0, -1000)

    -- 1. Сначала пытаемся привязать к anchor'ам
    --dxDrawRectangle(placementX - anchorRadius, placementY - anchorRadius, anchorRadius * 2 , anchorRadius * 2, tocolor(0, 0, 0, 50))
    activePosition = nil
    for building, anchors in pairs(buildingAnchors) do
        for i, anchor in ipairs(anchors) do
            if anchor.name == activePartName then
                local x, y, z = unpack(anchor.position)
                local sx, sy = getScreenFromWorldPosition(x, y, z, 0, false)
                if sx and 
                   placementX > sx - anchorRadius and 
                   placementX < sx + anchorRadius and 
                   placementY > sy - anchorRadius and
                   placementY < sy + anchorRadius
                then
                    if anchor.oz then
                        z = z - anchor.oz
                    end
                    object:setPosition(x, y, z)
                    activePosition = {anchor.x, anchor.y, anchor.z}
                    local angle = building.rotation.z
                    activeDirection = 0
                    activeBuilding = building
                    if anchor.direction then 
                        angle = angle + getDirectionAngle(anchor.direction) + 90
                        activeDirection = anchor.direction
                    end
                    object:setRotation(0, 0, angle)
                    return
                end
            end
        end
    end

    if not allowWorldPlacement[activePartName] then
        return
    end
    -- Позиция, куда смотрит камера
    local lx, ly, lz = getWorldFromScreenPosition(placementX, placementY, PLACEMENT_RANGE)
    -- Позиция камеры
    local cx, cy, cz = getCameraMatrix()
    -- Точка в мире, куда смотрит камера
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
    if hit then 
        return
    end

    -- Угол поворота объекта в градусах
    local rotation = -math.atan2(cx - wx, cy - wy) / math.pi * 180

    object:setPosition(wx, wy, wz + 1)
    object:setRotation(0, 0, rotation)
    -- if PartSnap.hasRule(
    --     PartPreview.partName, targetPartName) then
    --     local x, y, z, rotation, direction = PartSnap.getSnap(object, PartPreview.partName, targetObject, targetPartName, wx, wy, wz, rotation)
    --     if x then
    --         previewPositionX, previewPositionY, previewPositionZ = x, y, z
    --         previewRotation = rotation
    --         previewDirection = direction
            
    --         object:setPosition(x, y, z)
    --         object:setRotation(0, 0, rotation)
    --     end
    -- end    
end

function showPreview(partName)
    if not isElement(object) then
        object = createObject(1337, 0, 0, 0)
        addEventHandler("onClientPreRender", root, update)
    end

    object.model = exports["rs_models"]:getModel(partName)
    object:setCollisionsEnabled(false)
    object.alpha = 200

    activePartName = partName
end

function hidePreview(partName)
    if not isElement(object) then
        return 
    end
    destroyElement(object)
    object = nil
    removeEventHandler("onClientPreRender", root, update)
    activePartName = nil
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    showPreview("Floor")
end)

addEventHandler("onClientKey", root, function (key, down)
    if not down then
        return
    end
    if key ~= "mouse2" then
        return
    end
    if not activePartName then
        return
    end

    if not activePosition then
        return
    end
    triggerServerEvent("placePart", activeBuilding, activePartName, activePosition, activeDirection)
end)

addCommandHandler("build", function (cmd, name)
    showPreview(name)
end)