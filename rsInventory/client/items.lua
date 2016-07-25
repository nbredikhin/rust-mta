local items = {}
local itemsData

addEventHandler("onClientResourceStart", root,
	function(resourceStartred)
		if not resourceStarted == resource then
			return
		end

		local resource = getResourceFromName("rsItems")
		if not resource or not resource.state == "running" then
			outputDebugString("rsItems resource is not running", 2)
		else
			itemsResourceStart()
		end
	end
)

function itemsResourceStart()
	itemsData = exports["rsItems"]:getItems()

	if #items > 1 then
		return
	end

	items[1] = itemsData["resource_wood"]
	items[2] = itemsData["weapon_stone"]
	items[3] = itemsData["resource_wood"]

	inventory[1].item = items[1]
	inventory[2].item = items[2]
	inventory[27].item = items[3]
end

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

-- selecting or moving items
addEventHandler("onClientKey", root,
	function(keyPressed, keyDown)
		if keyPressed == "mouse1" then
			local cursorX, cursorY = getCursorPosition()

			if keyDown then -- start moving item
				if not slotUnderCursor then
					return
				end

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

					movingItem = nil

					outputChatBox("select")
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

		dxDrawImage(cursorX - movingOffsetX, cursorY - movingOffsetY, settings.width, settings.heigth, movingItem.img)
	end
)

addEventHandler("onClientResourceStart", root,
	function(resourceStarted)
		if resourceStarted.name == "rsItems" then
			itemsResourceStart()

			for _, itemData in pairs(itemsData) do
				for _, item in ipairs(items) do
					if item.name == itemData.name then
						for key, value in pairs(itemData) do
							item[key] = value
						end
					end
				end
			end
		end
	end
)

addEventHandler("onClientResourceStop", root,
	function(resourceStopped)
		if resourceStopped.name == "rsItems" then
			for _, item in ipairs(items) do
				item.img = nil
			end
		end
	end
)