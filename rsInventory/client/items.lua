function moveItem(item, slot)
	if not item or not slot then
		return
	end

	triggerServerEvent("inventory.onClientMoveItem", resourceRoot, item.id, slot.index)
end

function dropItem(item)
	if not item then
		return
	end

	if item == selectedItem then
		selectedItem = nil
	end

	local groundPos
	local startPoint, endPoint

	startPoint = localPlayer.matrix:transformPosition(Vector3(0, 1, 0))
	endPoint = localPlayer.matrix:transformPosition(Vector3(0, 1, 0))
	endPoint.z = 0

	local hit, x, y, z, element, nx, ny, nz = processLineOfSight(startPoint, endPoint, true, false, false, true)

	if hit then
		if element and element:getData("inventory.itemData") then

			local top = element.position + Vector3(0, 0, 10)

			local doBreak = false
			for length = 0.5, 10, 0.5 do
				for angle = 0, 360 do
					local x = top.x + math.cos(math.rad(angle)) * length
					local y = top.y + math.sin(math.rad(angle)) * length
					local z = top.z
					local startPoint = Vector3(x, y, z)
					local endPoint = Vector3(x, y, 0)

					local hit, x, y, z, element, nx, ny, nz = processLineOfSight(startPoint, endPoint, true, false, false, true)
					if hit and not element then
						groundPos = {}
						groundPos.x = x
						groundPos.y = y
						groundPos.z = z

						doBreak = true
						break
					end
				end

				if doBreak then
					break
				end
			end
		else
			groundPos = {}
			groundPos.x = x
			groundPos.y = y
			groundPos.z = z
		end
	end

	triggerServerEvent("inventory.onClientDropItem", resourceRoot, item.id, groundPos)
end

-- подсвечиваем название предметов при наведении
addEventHandler("onClientCursorMove", root,
	function(cursorX, cursorY, absoluteX, absoluteY, worldX, worldY, worldZ)
		local worldPos = Vector3(worldX, worldY, worldZ)
		local camera = Camera:getMatrix()
		local _, _, _, _, element = processLineOfSight(camera.position, worldPos, true, false, true, true)

		if element then
			local item = element:getData("inventory.itemData")
			if item then
				worldItemUnderCursor = {
					name = item.name,
					pos = element.position,
					object = element,
					item = item
				}
			else
				worldItemUnderCursor = nil
			end
		else
			worldItemUnderCursor = nil
		end
	end
)
addEventHandler("onClientRender", root,
	function()
		if worldItemUnderCursor then
			if inventory.visible then
				worldItemUnderCursor = nil
				return
			end

			if not isElement(worldItemUnderCursor.object) then
				return
			end

			if not worldItemUnderCursor.object.onScreen then
				return
			end

			local distance = getDistanceBetweenPoints3D(localPlayer.position, worldItemUnderCursor.pos)
			if distance > shared.maxDistanceToPickupItem then
				return
			end

			local f = (1 / distance)^0.5
			local scale = f * 1.5
			local alpha = f * 255 + 50
				  alpha = alpha > 255 and 255 or alpha

			local x, y = getScreenFromWorldPosition(worldItemUnderCursor.pos, 0, false)
			if not x or not y then
				return
			end

			local offset = (f * settings.worldItemNameOffset)
			
			dxDrawText(worldItemUnderCursor.name, x, y - offset, x, y - offset, tocolor(255, 255, 255, alpha), scale, "default-bold", "center", "center")
		end
	end
)
-- подбираем предметы
addEventHandler("onClientClick", root,
	function(button, state)
		if button ~= "left" or state ~= "down" then
			return
		end

		if not isThereAnEmptySlot() then
			return
		end

		if worldItemUnderCursor then
			triggerServerEvent("inventory.onClientAttemptToPickUpItem", resourceRoot, worldItemUnderCursor.item)
			worldItemUnderCursor = nil
		end
	end
)


-- убираем коллизию дропнутым итемам (так, потому что если убрать ее на сервее, lineOfSight не будет срабатывать)
addEvent("inventory.onItemDropped", true)
addEventHandler("inventory.onItemDropped", resourceRoot,
	function(item)
		localPlayer:setCollidableWith(item.object, false)
	end
)


addEvent("inventory.refresh", true)
addEventHandler("inventory.refresh", resourceRoot,
	function(items)
		for _, slot in ipairs(inventory) do
			slot.item = nil
		end

		for _, item in ipairs(items) do
			if not item.slot then
				dropItem(item)
				return
			end

			if inventory[item.slot] then
				inventory[item.slot].item = item
			else
				outputDebugString("no slot with index " .. tostring(item.slot), 2)
			end
		end

		inventory.items = items
	end
)


-- tracking to decide whether its selecting item or moving item case
function cursorMove()
	if slotUnderCursor and slotUnderCursor.item then
		movingItem = slotUnderCursor.item
	end	

	removeEventHandler("onClientCursorMove", root, cursorMove)
end

-- moving/selecting item
addEventHandler("onClientKey", root,
	function(keyPressed, keyDown)
		if keyPressed ~= "mouse1" then
			return
		end

		if keyDown then
			if not slotUnderCursor or not slotUnderCursor.item then
				return
			end

			addEventHandler("onClientCursorMove", root, cursorMove)
		else
			removeEventHandler("onClientCursorMove", root, cursorMove)

			if not movingItem then
				if slotUnderCursor then
					selectedItem = slotUnderCursor.item
				end
			else
				if slotUnderCursor then
					if slotUnderCursor.index ~= movingItem.slot then
						moveItem(movingItem, slotUnderCursor)
					end
				else
					dropItem(movingItem)
				end

				movingItem = nil
			end
		end
	end
)

-- drawing moving item
addEventHandler("onClientRender", root,
	function()
		if not movingItem then
			return
		end

		local x, y = getCursorPosition()
		local w, h = settings.width, settings.heigth
		local alpha = 200

		drawItem(movingItem, x - w/2, y - h/2, w, h, alpha)
	end
)

