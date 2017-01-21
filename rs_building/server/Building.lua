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
    -- Спавн объекта
    position = rotateVector(position, self.angle)
    part.object = createObject(part.model, self.position + position, Vector3(0, 0, self.angle + angle))
    part.object.parent = self.element

    -- TODO: Streamed data
    part.object:setData("gridPosition", {x, y, z})
    part.object:setData("direction", direction)
    part.object:setData("name", name)
    return true
end

function Building:getPart(x, y, z)
    return self.grid[x][y][z]
end

-- Проверяет существование детали в координатах x, y, z
-- Если указан direction, проверяет направление
-- Если указан name, проверяет название детали
function Building:checkPart(x, y, z, direction, name, instanceof)
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
    if instanceof and not part:isInstanceOf(instanceof) then
        return false
    end
    return true
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

addEvent("buildPart", true)
addEventHandler("buildPart", resourceRoot, function (name, x, y, z, direction)
    if source == resourceRoot then
        -- Создать новую постройку        
        Building:new(Vector3(x, y, z), direction)
    else
        -- Добавить к существующей постройке
        local building = buildings[source]
        if not building then
            return
        end
        outputDebugString(string.format("Add part '%s' at (%i, %i, %i) direction=%i",
            name,
            x, y, z,
            direction))        
        building:addPart(name, x, y, z, direction)
    end
end)