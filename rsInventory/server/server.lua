local itemsData



-- getting itemCounter



-- refreshing itemsData on every rsItems resource start
addEventHandler("onResourceStart", root,
	function(resourceStarted)
		local itemsResource = getResourceFromName("rsItems")

		if resourceStarted == resource then
			if itemsResource and itemsResource.state == "running" then
				itemsData = exports["rsItems"]:getItems()
			end

			Data.itemCounter = Data.itemCounter or 1

			--outputChatBox("itemCounter = " .. tostring(Data.itemCounter))
		elseif resourceStarted == itemsResource then
			itemsData = exports["rsItems"]:getItems()
		end
	end
)


function createItem(itemKey)
	if not itemsData then
		outputDebugString("rsItems resource is not running", 2)
		return
	end

	if not itemsData[itemKey] then
		outputDebugString("There is no item with key \"" .. tostring(itemKey) .. "\"", 2)
		return
	end

	local item = deepcopy(itemsData[itemKey])

	item.id = Data.itemCounter

	Data.itemCounter = Data.itemCounter + 1

	return item
end

function giveItemToPlayer(item, player)
	if not item or not player then
		return false
	end

	local playerItems = player:getData("items") or {}

	playerItems[item.id] = item

	player:setData("items", playerItems)

	return true
end

function createItemByKeyForPlayer(key, player)
	if not key or not player then
		return
	end

	local item = createItem(key)

	if not item then
		outputDebugString("no item", 2)
		return
	end
	
	giveItemToPlayer(item, player)
end

addCommandHandler("items", 
	function(player)
		createItemByKeyForPlayer("resource_wood", player)
		--createItemByKeyForPlayer("weapon_stone", player)
		--createItemByKeyForPlayer("resource_wood", player)
	end
)

addEventHandler("onElementDataChange", root,
	function(dataName, oldValue)

		if client and dataName == "items" then
			reportAndRevertDataChange(dataName, oldValue, source, client)
		end
	end
)

function reportAndRevertDataChange(dataName, oldValue, source, client)
	local newValue = getElementData(source,dataName)

	local oldItemsString = ""
	local newItemsString = ""
	if dataName == "items" then 
		if type(oldValue) == "table" then
			oldItemsString = oldItemsString .. "{"

			for key, value in pairs(oldValue) do
				oldItemsString = oldItemsString .. "[" .. tostring(key) .. "] = " .. tostring(value and value.name or "nil") .. ", "
			end

			oldItemsString = oldItemsString .. "}"
		end

		if type(newValue) == "table" then
			newItemsString = newItemsString .. "{"

			for key, value in pairs(newValue) do
				newItemsString = newItemsString .. "[" .. tostring(key) .. "] = " .. tostring(value and value.name or "nil") .. ", "
			end

			newItemsString = newItemsString .. "}"
		end
	end

	local reportString = "Possible data spoofing!"
		.. " source: " .. tostring(source)
		.. ", sourceName: " .. tostring(source and source.name or "nil")
		.. ", sourceAccountName: " .. tostring(source and source.account and source.account.name or "nil")
		.. ", client: " .. tostring(client)
		.. ", clientName: " .. tostring(client and client.name or "nil")
		.. ", clientAccountName: " .. tostring(client and client.account and client.account.name or "nil")
		.. ", dataName: " .. tostring(dataName)
		.. ", oldValue: " .. tostring(oldValue)
		.. ", newValue: " .. tostring(getElementData(source,dataName))
		.. ", oldItems: " .. oldItemsString
		.. ", newItems: " .. newItemsString
	
    for _, player in ipairs(getElementsByType("player")) do
    	if doesAccountHaveAdminRights(player.account) then
    		outputChatBox("[Anticheat] Possible data spoofing! (watch console/serverlogs)", player, 222, 0, 0)
    		outputConsole(reportString, player)
    	end
    end

    outputServerLog(reportString)

    -- Revert (Note this will cause an onElementDataChange event, but 'client' will be nil)
    setElementData(source, dataName, oldValue)               
end