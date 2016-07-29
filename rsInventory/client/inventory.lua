inventory = {
	alpha = settings.alpha,
	visible = false
}


function getImgForItem(item)
	if not item then
		return unknownImg
	end

	local itemsImgData = root:getData("itemsImgData") or {}
	return itemsImgData[item.key] and itemsImgData[item.key].img or unknownImg
end

function drawItem(item, x, y, w, h)
	if not item then
		return
	end

	-- img
	dxDrawImage(x, y, w, h, getImgForItem(item))

	-- amount
	local spacing = settings.slotAmountSpacing
	local amount = item.amount > 1 and "x" .. item.amount or ""
	local x1, y1 = x + spacing, y + spacing
	local x2, y2 = x + w - spacing, y + h - spacing + 2

	dxDrawText(amount, x1+1, y1+1, x2+1, y2+1, 0x44000000, 1, "default-bold", "right", "bottom")
	dxDrawText(amount, x1, y1, x2, y2, 0xFFFFFFFF, 1, "default-bold", "right", "bottom")
end

function drawSlot(slot)
	-- border
	dxDrawRectangle(slot.x - 1, slot.y - 1, slot.w + 2, slot.h + 2, 0x11000000)

	-- color
	local color = slot.color
	if not color then
		color = tocolor(settings.colorNormal[1], settings.colorNormal[2], settings.colorNormal[3], inventory.alpha)

		-- hovered
		if slot == slotUnderCursor then
			color = tocolor(settings.colorHover[1], settings.colorHover[2], settings.colorHover[3], inventory.alpha)
		end

		-- selected
		if selectedItem and (slot.item == selectedItem) then
			color = tocolor(settings.colorSelected[1], settings.colorSelected[2], settings.colorSelected[3], inventory.alpha)
		end
	end
	
	-- slot
	dxDrawRectangle(slot.x, slot.y, slot.w, slot.h, color)

	-- item
	if slot.item then
		if movingItem then
			if movingItem.id == slot.item.id then
				return
			end
		end

		drawItem(slot.item, slot.x, slot.y, slot.w, slot.h)
	end
end

function createSlotsRow(yPos, isHotbar)
	local row = {}
	for i = 1, settings.row do
		local slot = {}

		slot.w = settings.width
		slot.h = settings.heigth
		slot.x = (screenW / 2) - (slot.w / 2) + (slot.w + settings.spacing) * (i - 1) - ((settings.row - 1) * (slot.w + settings.spacing)/2)
		slot.y = yPos
		slot.isHotbar = isHotbar
		slot.draw = drawSlot
		slot.index = #inventory + 1

		table.insert(inventory, slot)
		table.insert(row, slot)
	end

	return row
end

function toggleInventory(state)
	inventory.visible = state or (not inventory.visible)
	showCursor(inventory.visible)

	if inventory.visible then
		inventory.alpha = 100
	else
		inventory.alpha = settings.alpha
	end

	triggerEvent("onClientInventoryToggle", root, inventory.visible)
end


-- background
function drawBG()
	dxDrawRectangle(0, 0, screenW, screenH, settings.inventoryBGColor)
end
--

-- inventory block
inventory.pos = {}
for i = 1, settings.inventoryRows do
	local yPos = settings.inventoryY + (settings.heigth + settings.spacing) * i
	local row = createSlotsRow(yPos)

	if i == 1 then
		inventory.x1, inventory.y1 = row[1].x, row[1].y
	end

	if i == settings.inventoryRows then
		inventory.x2, inventory.y2 = row[#row].x + settings.width, row[#row].y + settings.heigth
	end
end
function drawInventoryBlock()
	local textX, textY = inventory.x1, inventory.y1 - settings.titleSpacing

	dxDrawText(text.inventory, textX, textY, textX, textY, 0xFFFFFFFF, 2 * scaleFactor, "default-bold")

	for _, slot in ipairs(inventory) do
		if not slot.isHotbar then
			slot:draw()
		end
	end
end
--

function getSlotUnderCursor()
	local x, y = getCursorPosition()

	-- get slot under point
	for _, slot in ipairs(inventory) do
		if x > slot.x and x < slot.x + slot.w then
			if y > slot.y and y < slot.y + slot.h then
				return slot
			end
		end
	end

	-- exclude spacing between inventory slots
	if (x > inventory.x1 and x < inventory.x2) and (y > inventory.y1 and y < inventory.y2) then
		return getClosiestSlotToCursor(x, y)
	end

	-- exclude spacing between hotbar slots
	if (x > hotbar.x1 and y < hotbar.x2) and (y > hotbar.y1 and y < hotbar.y2) then
		return getClosiestSlotToCursor(x, y)
	end
end

function getClosiestSlotToCursor(cursorX, cursorY)
	local x1, y1 = cursorX, cursorY

	local minDistance = 32767
	local closiestSlot

	for _, slot in ipairs(inventory) do
		local x2, y2 = slot.x + slot.w/2, slot.y + slot.h/2

		local distance = math.sqrt((x2 - x1)^2 + (y2 - y1)^2)

		if distance < minDistance then 
			minDistance = distance
			closiestSlot = slot
		end
	end

	return closiestSlot
end


addEventHandler("onClientPreRender", root,
	function()
		if not settings.visible or not inventory.visible then
			return
		end
		-- slot under cursor
		slotUnderCursor = getSlotUnderCursor()

		-- drawing all the shit
		drawBG()
		drawInventoryBlock()
	end
)

-- toggle visibility
addEventHandler("onClientKey", root,
	function(key, state)
		if not state then
			return
		end

		if key == settings.key then
			toggleInventory()
		end
	end
)
