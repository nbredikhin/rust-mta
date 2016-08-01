function createTextures()
	local itemsImgData = root:getData("itemsImgData")

	for _, imgData in pairs(itemsImgData) do
		imgData.img = dxCreateTexture("img\\" .. imgData.imgName, "argb", true, "clamp")
	end

	root:setData("itemsImgData", itemsImgData, false)
end


addEventHandler("onClientResourceStart", root,
	function(resourceStarted)
		if resourceStarted == resource then
			local itemsImgData = root:getData("itemsImgData")

			if itemsImgData and type(itemsImgData) == "table" then
				createTextures()
			else
				setTimer(createTextures, 500, 1)
			end
		end
	end
)


addEventHandler("onClientResourceStop", root,
	function(resourceStopped)
		if resourceStopped == resource then
			root:setData("itemsImgData", false, false)
		end
	end
)