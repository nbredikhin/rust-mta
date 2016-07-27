function getSlotByPoint(x, y)
	-- get slot under point
	for _, slot in ipairs(inventory) do
		if x > slot.x and x < slot.x + slot.w then
			if y > slot.y and y < slot.y + slot.h then
				return slot
			end
		end
	end

	-- exclude spacing between inventory slots
	if (x > inventory.x1 and x < inventory.x2)
	and (y > inventory.y1 and y < inventory.y2) then
		return getClosiestSlotToCursor(x, y)
	end

	-- exclude spacing between hotbar slots
	if (x > hotbar.x1 and y < hotbar.x2)
	and (y > hotbar.y1 and y < hotbar.y2) then
		return getClosiestSlotToCursor(x, y)
	end
end

function getSlotUnderCursor(cursorX, cursorY)
	local slot

	-- by moving item center
	if movingItem then
		local w, h = settings.width, settings.heigth
		local x, y = cursorX - movingOffsetX + w/2, cursorY - movingOffsetY + h/2

		slot = getSlotByPoint(x, y)
	end

	-- by cursor
	slot = slot or getSlotByPoint(cursorX, cursorY)

	return slot
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

-- getting a slot under cursor
addEventHandler("onClientRender", root, 
	function()
		slotUnderCursor = nil

		if not isCursorShowing() then
			return
		end

		local cursorX, cursorY = getCursorPosition()

		slotUnderCursor = getSlotUnderCursor(cursorX, cursorY)
	end
)

-- selecting, moving, dropping items
addEventHandler("onClientKey", root,
	function(keyPressed, keyDown)
		if keyPressed == "mouse1" then
			local cursorX, cursorY = getCursorPosition()

			if keyDown then -- start moving item
				if not slotUnderCursor then
					return
				end

				outputChatBox(slotUnderCursor.index .. " " .. tostring(slotUnderCursor.item and slotUnderCursor.item.id or "no item"))

				-- if there is an item in the slot under cursor, move it, do nothing otherwise
				if slotUnderCursor.item then
					movingItem = slotUnderCursor.item
					movingItem.lastSlot = slotUnderCursor
					slotUnderCursor.item = nil

					movingOffsetX, movingOffsetY = cursorX - slotUnderCursor.x, cursorY - slotUnderCursor.y
					lastCursorX, lastCursorY = getCursorPosition()
				end
			else -- finish moving item
				-- happens when inventory is closed before mouse1 up
				if not movingItem then
					return
				end

				-- if position of cursor didn't change, it's a selecting case
				if lastCursorX == cursorX and lastCursorY == cursorY then
					-- technically the moving did start, so if the old place is occupied, drop the item
					if not movingItem.lastSlot.item then
						movingItem.lastSlot.item = movingItem
						movingItem.lastSlot = nil
					else
						outputChatBox("drop item")
					end

					selectedItem = movingItem

					movingItem = nil

					saveOccupiedSlots()
					return
				end

				-- if slot under cursor, move it there or swap items
				if slotUnderCursor then
					if slotUnderCursor.item then -- swap
						movingItem.lastSlot.item = slotUnderCursor.item
						slotUnderCursor.item = movingItem
						movingItem.lastSlot = nil
						movingItem = nil
					else -- just move
						slotUnderCursor.item = movingItem
						movingItem = nil
					end
				else -- if no slot under cursor, drop item
					outputChatBox("drop item")

					movingItem = nil
				end

				saveOccupiedSlots()
			end
		end
	end
)

-- attaching item img to cursor
addEventHandler("onClientPreRender", root,
	function()
		if not movingItem then
			return
		end

		-- happens when inventory was closed before finishing moving, move item back to its place if not occupied, drop otherwise
		if not isCursorShowing() then
			if not movingItem.lastSlot.item then
				movingItem.lastSlot.item = movingItem
				movingItem.lastSlot = nil
			else
				outputChatBox("drop item")
			end

			movingItem = nil
			return
		end		

		local cursorX, cursorY = getCursorPosition()

		dxDrawImage(cursorX - movingOffsetX, cursorY - movingOffsetY, settings.width, settings.heigth, getImgForItem(movingItem))
	end
)

function refreshItems()
	--outputChatBox("refresh")

	inventory.items = localPlayer:getData("items")

	-- удаляем итемы из слотов при их исчезновении из даты (вроде ссылки, а автоматически не работает, хуй знает короч)
	for _, slot in ipairs(inventory) do
		if slot.item then
			if not inventory.items[slot.item.id] then
				slot.item = nil
			end
		end
	end

	-- расставляем итемы по их слотам, если они не расставлены (при заходе на сервер, например)
	local occupiedSlots = localPlayer:getData("occupiedSlots") or {}

	for slotIndex, slotItemID in pairs(occupiedSlots) do
		local slot = inventory[tonumber(slotIndex)]
		if slot then
			local item = inventory.items[tostring(slotItemID)] or inventory.items[tonumber(slotItemID)]
			if item then
				if movingItem then
					if movingItem.id ~= item.id then
						slot.item = item
					end
				else
					slot.item = item
				end
			else
				--outputDebugString("no item with ID " .. tostring(slotItemID) .. " in inventory", 2)
			end
		end
	end

	
	-- проверяем, все ли итемы из даты лежат в инвентаре, если нет, то ищем им слоты, если нет слотов, выбрасываем итемы
	for _, item in pairs(inventory.items) do
		if not(movingItem and movingItem.id == item.id) then

			local itemIsInInventory
			for _, slot in ipairs(inventory) do

				if slot.item and tostring(slot.item.id) == tostring(item.id) then
					itemIsInInventory = true
					break
				end
			end

			if not itemIsInInventory then
				local slot = getEmptySlot()
				if slot then
					slot.item = item
				else
					outputChatBox("drop item")
				end
			end
		end
	end

	-- сохранение положения предметов в инвентаре
	saveOccupiedSlots()

	localPlayer:setData("occupiedSlots", occupiedSlots)
end

function saveOccupiedSlots()
	local occupiedSlots = {}

	for _, slot in ipairs(inventory) do
		if slot.item then
			occupiedSlots[slot.index] = slot.item.id
		end
	end

	localPlayer:setData("occupiedSlots", occupiedSlots)
end

--setTimer(refreshItems, 100, 0)

addEventHandler("onClientElementDataChange", localPlayer, 
	function(dataName)

		if dataName ~= "items" then
			return
		end

		refreshItems()
	end
)

addCommandHandler("t",
	function()
		local i = 0
		for _ in pairs(inventory.items) do
			i = i + 1
		end

		outputChatBox(i .. " items in inventory")
	end
)

addEventHandler("onClientResourceStart", resource.rootElement, 
	function()
		setTimer(refreshItems, 100, 1)
	end
)