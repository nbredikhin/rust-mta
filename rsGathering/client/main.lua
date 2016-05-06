local tree = createObject(657, Vector3{ x = -1221.317, y = -154.494, z = 13 })
local treeHealth = 1

addEventHandler("onClientObjectDamage", root, function ()
	treeHealth = treeHealth - 1
	if treeHealth <= 0 then
		tree:move(1000, tree.position + Vector3(0, 0, 0.3), Vector3(0, 90, 0), "InQuad")
		tree:setCollisionsEnabled(false)
	end
end)