local itemsData



-- getting itemCounter and itemsData
addEventHandler("onResourceStart", root,
	function(resourceStarted)
		local itemsResource = getResourceFromName("rsItems")

		if resourceStarted == resource then
			if itemsResource and itemsResource.state == "running" then
				itemsData = exports["rsItems"]:getItems()
			end

			Data.itemCounter = Data.itemCounter or 1

		elseif resourceStarted == itemsResource then
			itemsData = exports["rsItems"]:getItems()
		end
	end
)


function createItem(itemKey, amount)
	if not itemsData then
		outputDebugString("rsItems resource is not running", 2)
		return
	end

	if not itemsData[itemKey] then
		outputDebugString("There is no item with key \"" .. tostring(itemKey) .. "\"", 2)
		return
	end

	local amount = amount or 1

	local item = deepcopy(itemsData[itemKey])

	item.id = Data.itemCounter
	item.amount = amount

	Data.itemCounter = Data.itemCounter + 1

	return item
end

function dropPlayerItem(player, item)
	-- watch out right usage in giveItemToPlayer function (dropping item which isn't actually inside inventary)
	outputChatBox("drop item")
end

function giveItemToPlayer(item, player)
	if not item or not player then
		outputDebugString("", 2)
		return
	end

	if not playerItems[player] then
		outputDebugString("", 2)
		return
	end

	local items = fixItemStacking(item)

	for _, item in ipairs(items) do
		local slot = getEmptySlot(player)
		if slot then
			item.slot = slot
			table.insert(playerItems[player], item)
			refreshClientData(player)
		else
			dropPlayerItem(player, item)
		end
	end
end

function createItemByKeyForPlayer(key, player, amount)
	local item = createItem(key, amount)
	if item then
		giveItemToPlayer(item, player)
	end
end


function refreshClientData(client)
	if not client then
		return
	end

	if not playerItems[client] then
		return
	end

	triggerClientEvent(client, "inventory.refresh", resourceRoot, playerItems[client])
end

function fixItemStacking(item) -- e.g. one wood item with 2400 amount will return 3 items with 1000, 1000, 400 amount
	if not item then
		return
	end

	if not item.stack or not item.amount then
		return
	end

	if item.amount <= item.stack then
		return {item}
	end

	-- amount: 2400
	-- 2 new items with 1000
	local newItems = {}
	for i = 1, math.floor(item.amount / item.stack) do
		local newItem = createItem(item.key, item.stack)
		if not newItem then
			return item
		end

		table.insert(newItems, newItem)
	end

	-- 1 new item with 400
	local remainder = item.amount % item.stack
	if remainder > 0 then
		local newItem = createItem(item.key, remainder)

		table.insert(newItems, newItem)
	end

	return newItems
end

function getEmptySlot(player)
	local items = playerItems[player]
	if not items then
		return
	end

	local occupied = {}
	for _, item in ipairs(items) do
		if item.slot then
			occupied[item.slot] = true
		end
	end

	for i = 1, settings.inventorySize do
		if not occupied[i] then
			return i
		end
	end
end

addCommandHandler("items", 
	function(player, _, itemKey, amount)
		createItemByKeyForPlayer(itemKey, player, tonumber(amount))
	end
)
