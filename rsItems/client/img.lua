for _, item in pairs(items) do
	if item.img then
		item.img = dxCreateTexture("img/" .. item.img, "argb", true, "clamp")
	end
end