local DEFAULT_WEAPON_STACK = 1
local ITEM_TYPE_WEAPON = "weapon"

Items["ak47"] = {
    name        = "AK-47",
    description = "Famous russian machine gun.",
    type        = ITEM_TYPE_WEAPON,
    stack       = DEFAULT_WEAPON_STACK,
    max_ammo    = 30,

    instance_props = {
        ammo = 0
    }
}
