local anchors = {}
local size = 0.2

addEvent("updateBuilding", true)
addEventHandler("updateBuilding", resourceRoot, function (a)
    anchors = a
end)

addEventHandler("onClientRender", root, function ()
    dxDrawText("Anchors count: " .. tostring(#anchors), 10, 750)
    for i, anchor in ipairs(anchors) do
        local x, y, z = unpack(anchor.position)
        dxDrawLine3D(x, y, z - size / 2, x, y, z + size / 2, tocolor(0, 255, 0), size * 80)
        local sx, sy = getScreenFromWorldPosition(x, y, z, 0, false)
        if sx then
            dxDrawText(anchor.name, sx - 30, sy - 20)
        end
    end
end)