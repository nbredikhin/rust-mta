inventory = {
	alpha = settings.alpha,
	visible = false,
	key = "e"
}

function drawSlot(slot)
	-- border
	dxDrawRectangle(slot.x - 1, slot.y - 1, slot.w + 2, slot.h + 2, 0x11000000)

	-- color
	local color = slot.color
	if not color then
		color = tocolor(settings.colorNormal[1], settings.colorNormal[2], settings.colorNormal[3], inventory.alpha)
		if slot == slotUnderCursor then
			color = tocolor(settings.colorHover[1], settings.colorHover[2], settings.colorHover[3], inventory.alpha)
		end
	end
	
	-- slot
	dxDrawRectangle(slot.x, slot.y, slot.w, slot.h, color)

	-- item
	if slot.item then
		if not slot.item.img then
			slot.item.img = unknownImg
		end

		
		dxDrawImage(slot.x, slot.y, slot.w, slot.h, slot.item.img)
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
	local textX, textY = inventory.x1, inventory.y1 - 32 * scaleFactor

	dxDrawText(text.inventory, textX, textY, textX, textY, 0xFFFFFFFF, 2 * scaleFactor, "default-bold")

	for _, slot in ipairs(inventory) do
		if not slot.isHotbar then
			slot:draw()
		end
	end
end
--

-- drawing all the shit
addEventHandler("onClientPreRender", root,
	function()
		if not settings.visible or not inventory.visible then
			return
		end

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

		if key == inventory.key then
			toggleInventory()
		end
	end
)
