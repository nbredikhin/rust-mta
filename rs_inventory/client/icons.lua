local textures = {}
local placeholderIcon

function getItemIcon(name)
    if not name then
        return
    end
    if not Items[name] then
        return
    end
    if textures[name] then
        return textures[name]
    end
    local path = "assets/icons/" .. tostring(name) .. ".png"
    if not fileExists(path) then
        return placeholderIcon
    end
    textures[name] = dxCreateTexture(path)
    return textures[name]
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
    placeholderIcon = dxCreateTexture("assets/placeholder.png")
end)
