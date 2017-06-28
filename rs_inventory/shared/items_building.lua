local DEFAULT_BUILDING_STACK = 50
local ITEM_TYPE_BUILDING = "building"

local function createBuilding(player, item)
	triggerClientEvent(player, "showBuildingPartPreview", player, getItemById(item.id).name)
end

local function destroyBuilding(player)
	triggerClientEvent(player, "showBuildingPartPreview", player, false)
end

Items["foundation"] = {
    name        = "Foundation",
    description = "Basic foundataion.",
    type        = ITEM_TYPE_BUILDING,
    stack       = DEFAULT_BUILDING_STACK,

    create  = createBuilding,
    destroy = destroyBuilding,
}
