local textures = {}
local placeholderIcon

function getItemIcon(id)
    if not id then
        return
    end
    if not Items[id] then
        return
    end
    if textures[id] then
        return textures[id]
    end
    local path = "assets/icons/" .. tostring(id) .. ".png"
    if not fileExists(path) then
        return placeholderIcon
    end
    textures[id] = dxCreateTexture(path)
    return textures[id]
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
    placeholderIcon = dxCreateTexture("assets/placeholder.png")
end)
