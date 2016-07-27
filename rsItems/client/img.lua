function createTextures()
	local itemsImgData = root:getData("itemsImgData")

	for _, imgData in pairs(itemsImgData) do
		imgData.img = dxCreateTexture("img\\" .. imgData.imgName, "argb", true, "clamp")
	end

	root:setData("itemsImgData", itemsImgData)
end


addEventHandler("onClientResourceStart", root,
	function(resourceStarted)
		if resourceStarted == resource then
			local itemsImgData = root:getData("itemsImgData")

			if itemsImgData then
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
			root:setData("itemsImgData", false)
		end
	end
)