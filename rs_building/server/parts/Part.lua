Part = class("Part")

function Part:initialize(building)
    self.building = building
    self.name = self.class.name
    self.model = exports["rs_models"]:getModel(self.name)
end

-- Проверяет, возможна ли установка данной детали на сетке
function Part:isPlacementAllowed(x, y, z, direction)
    return true
end

-- Рассчитывает положение объекта относительно центра постройки
-- Получает координаты на сетке и направление
-- Возвращает локальные координаты и угол поворота по оси Z
function Part:calculatePosition(x, y, z, direction)
    return Vector3(), 0
end

-- Возвращает список точек, к которым можно добавлять детали
function Part:getAnchors()
    -- { name = "Wall", position = {0, 0, 0}, [direction = 2] }
    return false
end