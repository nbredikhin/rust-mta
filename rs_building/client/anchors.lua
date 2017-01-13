buildingAnchors = {}
local size = 0.2

addEvent("updateBuildingAnchors", true)
addEventHandler("updateBuildingAnchors", resourceRoot, function (anchors)
    if not isElementStreamedIn(source) then
        return
    end
    buildingAnchors[source] = anchors
end)

addEvent("notifyBuildingUpdate", true)
addEventHandler("notifyBuildingUpdate", resourceRoot, function ()
    triggerServerEvent("requireBuildingAnchors", source)
end)

addEventHandler("onClientElementStreamOut", resourceRoot, function ()
    buildingAnchors[source] = nil
end)

addEventHandler("onClientElementStreamIn", resourceRoot, function ()
    if source:getData("isBuilding") then
        triggerServerEvent("requireBuildingAnchors", source)
    end
end)

addEventHandler("onClientRender", root, function ()
    for building, anchors in pairs(buildingAnchors) do
        for i, anchor in ipairs(anchors) do
            local x, y, z = unpack(anchor.position)
            --dxDrawLine3D(x, y, z - size / 2, x, y, z + size / 2, tocolor(0, 255, 0), size * 80)
            local sx, sy = getScreenFromWorldPosition(x, y, z, 0, false)
            if sx then
                --dxDrawText(anchor.name, sx - 30, sy - 20)
            end
        end
    end
end)