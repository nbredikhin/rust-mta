Building = class("Building")
local buildings = {}

-- Создание новой постройки
function Building:initialize(worldPosition, worldAngle)
    self.position = worldPosition
    self.angle = worldAngle
    -- Строительные точки
    self.anchors = {}
    -- Создание трёхмерной сетки для хранения деталей
    self.grid = self:createGrid(3)
    self.parts = {}
    -- Элемент для синхронизации
    self.element = createObject(1337, worldPosition, Vector3(0, 0, worldAngle))
    self.element.alpha = 0
    self.element:setCollisionsEnabled(false)
    self.element:setData("isBuilding", true)
    -- Добавление в таблицу построек
    buildings[self.element] = self    
    -- Добавление первой детали
    self:addPart("Foundation", 0, 0, 0, 0, true)
end

-- Добавление детали name в постройку с указанными координатами и направлением
-- Флаг force заставляет пропустить проверку isPlacementAllowed 
function Building:addPart(name, x, y, z, direction, force)
    -- Проверка существования детали с названием name
    if not _G[name] then
        return false
    end
    -- Если деталь уже установлена
    if self:getPart(x, y, z) then
        return false
    end
    local part = _G[name]:new(self)
    part.direction = direction
    part.x = x
    part.y = y
    part.z = z
    -- Проверить возможность установки детали
    if not force and not part:isPlacementAllowed(x, y, z, direction) then
        return false
    end
    -- Рассчёт локальных координат детали
    local position, angle = part:calculatePosition(x, y, z, direction)
    if not position or not angle then
        return false
    end
    -- Добавление детали к постройке
    self.grid[x][y][z] = part
    self.parts[part] = true
    -- Строительные точки
    self:updateAnchors()
    -- Спавн объекта
    position = rotateVector(position, self.angle)
    part.object = createObject(part.model, self.position + position, Vector3(0, 0, self.angle + angle))

    triggerClientEvent("notifyBuildingUpdate", self.element)
    return true
end

function Building:getPart(x, y, z)
    return self.grid[x][y][z]
end

-- Проверяет существование детали в координатах x, y, z
-- Если указан direction, проверяет направление
-- Если указан name, проверяет название детали
function Building:checkPart(x, y, z, direction, name)
    local part = self.grid[x][y][z]
    if not part then
        return false
    end
    if direction and part.direction ~= direction then
        return false
    end
    if name and part.name ~= name then
        return false
    end
    return true
end

function Building:addAnchor(anchor)
    if not anchor then
        return false
    end
    local partClass = _G[anchor.name]
    if not partClass then
        return false
    end    
    local x, y, z = anchor.x, anchor.y, anchor.z
    for i, a in ipairs(self.anchors) do
        if a.x == x and a.y == y and a.z == z then
            return false
        end
    end
    if not partClass.isPlacementAllowed({building=self}, x, y, z, anchor.direction or 0) then
        return false
    end
    anchor.position, anchor.angle = partClass.calculatePosition(nil, x, y, z, anchor.direction or 0)
    anchor.position = anchor.position + Vector3(0, 0, anchor.oz)
    anchor.position = self.position + rotateVector(anchor.position, self.angle)
    anchor.angle = self.angle + anchor.angle

    anchor.position = {anchor.position.x, anchor.position.y, anchor.position.z}
    table.insert(self.anchors, anchor)
    return true
end

function Building:updateAnchors()
    self.anchors = {}
    for part in pairs(self.parts) do
        local anchors = part:getAnchors()
        if anchors then
            for i, anchor in ipairs(anchors) do
                self:addAnchor(anchor)
            end
        end
    end

    local anchors = {}
    for i, anchor in ipairs(self.anchors) do
        if not self:checkPart(anchor.x, anchor.y, anchor.z) then
            table.insert(anchors, anchor)
        end
    end
    self.anchors = anchors
end

-- Создаёт сетку с заданной размерностью
function Building:createGrid(dim)
    local mt = {}

    for i = 1, dim do
        mt[i] = { 
            __index = function(t, k)
                if i < dim then
                    t[k] = setmetatable({}, mt[i+1])
                    return t[k]
                end
            end                
        }
    end

    return setmetatable({}, mt[1])
end

addEvent("requireBuildingAnchors", true)
addEventHandler("requireBuildingAnchors", resourceRoot, function ()
    if buildings[source] then
        triggerClientEvent(client, "updateBuildingAnchors", source, buildings[source].anchors)
    end
end)

addEvent("placePart", true)
addEventHandler("placePart", resourceRoot, function (name, position, direction)
    local building = buildings[source]
    if not building then
        return
    end
    local x, y, z = unpack(position)
    building:addPart(name, x, y, z, direction)
end)