local DEFAULT_WEAPON_STACK = 1
local ITEM_TYPE_WEAPON = "weapon"

local function createWeapon(player, item)
    local itemDescription = Items[item.id]
    giveWeapon(player, itemDescription.mta_weapon_id, 2, true)
end

local function destroyWeapon(player)
    takeAllWeapons(player)
end

Items["ak47"] = {
    name          = "AK-47",
    description   = "Famous russian machine gun.",
    type          = ITEM_TYPE_WEAPON,
    stack         = DEFAULT_WEAPON_STACK,
    max_ammo      = 30,

    mta_weapon_id = 30,

    instance_props = {
        ammo = 0
    },

    create  = createWeapon,
    destroy = destroyWeapon,
}
