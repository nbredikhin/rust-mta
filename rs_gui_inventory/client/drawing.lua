local screenSize = Vector2(guiGetScreenSize())
local isVisible = false

local SLOT_SIZE = 65
local SLOT_SPACING = 10
local ICON_SPACING = 5

local HOTBAR_SLOTS_COUNT = 6
local HOTBAR_OFFSET = 10

local INVENTORY_WIDTH = 6
local INVENTORY_HEIGHT = 5

local inventoryWidth
local inventoryHeight
local inventoryX
local inventoryY

local INVENTORY_HEADER = 40

local slots = {}

-- Слот из которого происходит перетаскивание
local draggingSlot = nil
local dragOffsetX = 0
local dragOffsetY = 0

local function createSlot(x, y, hotbarIndex)
    local slot = {}

    slot.x = x
    slot.y = y
    slot.hotbarIndex = hotbarIndex

    table.insert(slots, slot)
    slot.id = #slots
end

local function drawSlots()
    if isVisible then
        dxDrawRectangle(0, 0, screenSize.x, screenSize.y, tocolor(0, 0, 0, 200))
        dxDrawRectangle(inventoryX - SLOT_SPACING, inventoryY - INVENTORY_HEADER, inventoryWidth + SLOT_SPACING * 2,
            inventoryHeight + INVENTORY_HEADER + SLOT_SPACING, tocolor(50, 50, 50))
        dxDrawText("INVENTORY", inventoryX, inventoryY - INVENTORY_HEADER + 5)
    end
    local mx, my = getCursorPosition()
    if not mx then
        mx, my = 0, 0
    else
        mx, my = mx * screenSize.x, my * screenSize.y
    end

    local isMouseDown = getKeyState("mouse1")
    for i, slot in ipairs(slots) do
        if isVisible or slot.hotbarIndex then
            local color = tocolor(30, 30, 30, 230)

            local hs = SLOT_SPACING / 2 -- Половина расстояния между слотами
            local isMouseOver =  mx > slot.x - hs and mx < slot.x + SLOT_SIZE + hs
                             and my > slot.y - hs and my < slot.y + SLOT_SIZE + hs

            if isMouseOver then
                color = tocolor(40, 40, 40, 230)
            end
            if exports.rs_inventory:getActiveHotbarSlot() == slot.id then
                color = tocolor(60, 60, 60, 230)
            end
            dxDrawRectangle(slot.x, slot.y, SLOT_SIZE, SLOT_SIZE, color)
            -- Иконка
            local item = exports.rs_inventory:getItem(slot.id)
            if item and slot ~= draggingSlot then
                dxDrawImage(slot.x + ICON_SPACING, slot.y + ICON_SPACING, SLOT_SIZE - ICON_SPACING * 2,
                    SLOT_SIZE - ICON_SPACING * 2, exports.rs_inventory:getItemIcon(item.id))

                if item.count > 1 then
                    dxDrawText("x" .. item.count, slot.x + SLOT_SIZE - 2, slot.y + SLOT_SIZE,
                        slot.x + SLOT_SIZE - 2, slot.y + SLOT_SIZE, tocolor(255, 255, 255),
                        1, "default", "right", "bottom")
                end
            end
            -- Номер на хотбаре
            if slot.hotbarIndex then
                dxDrawText(slot.hotbarIndex, slot.x + 2, slot.y)
            end

            -- Клик
            if isMouseDown and isMouseOver and not draggingSlot and item then
                draggingSlot = slot
                dragOffsetX = slot.x - mx
                dragOffsetY = slot.y - my
            elseif not isMouseDown and draggingSlot and isMouseOver then
                if draggingSlot.id ~= slot.id then
                    exports.rs_inventory:moveItems(draggingSlot.id, slot.id)
                end
            end
        else
            return
        end
    end

    if not isMouseDown then
        draggingSlot = nil
    end
    if draggingSlot then
        local imageX = mx + dragOffsetX
        local imageY = my + dragOffsetY

        local item = exports.rs_inventory:getItem(draggingSlot.id)

        dxDrawImage(imageX + ICON_SPACING, imageY + ICON_SPACING, SLOT_SIZE - ICON_SPACING * 2,
            SLOT_SIZE - ICON_SPACING * 2, exports.rs_inventory:getItemIcon(item.id))

        if item.count > 1 then
            dxDrawText("x" .. item.count, imageX + SLOT_SIZE - 2, imageY + SLOT_SIZE,
                imageX + SLOT_SIZE - 2, imageY + SLOT_SIZE, tocolor(255, 255, 255),
                1, "default", "right", "bottom")
        end
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
    inventoryWidth = (SLOT_SIZE + SLOT_SPACING) * HOTBAR_SLOTS_COUNT - SLOT_SPACING
    inventoryX = screenSize.x / 2 - inventoryWidth / 2
    local hotbarY = screenSize.y - SLOT_SIZE - HOTBAR_OFFSET
    for i = 1, HOTBAR_SLOTS_COUNT do
        createSlot(inventoryX + (i - 1) * (SLOT_SIZE + SLOT_SPACING), hotbarY, i)
    end

    -- Основные слоты
    local sx = inventoryX
    inventoryHeight = (SLOT_SIZE + SLOT_SPACING) * INVENTORY_HEIGHT - SLOT_SPACING
    inventoryY = screenSize.y / 2 - inventoryHeight / 2
    local sy = inventoryY
    for i = 1, INVENTORY_SIZE - HOTBAR_SLOTS_COUNT do
        createSlot(sx, sy)
        sx = sx + SLOT_SIZE + SLOT_SPACING
        if i % INVENTORY_WIDTH == 0 then
            sx = inventoryX
            sy = sy + SLOT_SIZE + SLOT_SPACING
        end
    end

    addEventHandler("onClientRender", root, drawSlots)
end)

function setInventoryVisible(visible)
    if not not visible == isVisible then
        return
    end
    isVisible = not not visible

    showCursor(visible)
end

local function toggleInventory()
    setInventoryVisible(not isVisible)
end

bindKey("i", "down", toggleInventory)
bindKey("tab", "down", toggleInventory)
