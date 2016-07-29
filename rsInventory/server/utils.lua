addEvent("inventory.onClientMoveItem", true)
addEvent("inventory.onClientDropItem", true)

local dataPath = "server\\data.json"

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function getData()
    local file = fileOpen(dataPath)
    if not file then
        return {}
    end

    local data = fromJSON(file:read(file.size) or "[]")

    file:close()

    return data
end

function saveData(data)
    if not data then
        outputDebugString("No data to save", 2)
        return
    end

    local file = fileCreate(dataPath)
    if not file then
        outputDebugString("Cannot create file", 1)
        return
    end

    file:write(toJSON(data))
    file:close()
end

addEventHandler("onResourceStart", resource.rootElement,
    function()
        Data = getData()
    end
)

addEventHandler("onResourceStop", resource.rootElement,
    function()
        saveData(Data)
    end
)

function doesAccountHaveAdminRights(account)
    local group = aclGetGroup("Admin")

    if group and isObjectInACLGroup("user." .. account.name, group) then
        return true
    end

    return false
end