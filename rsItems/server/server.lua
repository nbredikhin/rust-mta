for key, item in pairs(items) do
	item.key = key
end

local itemsImgData = {}
for key, item in pairs(items) do
	if item.imgName then
		itemsImgData[key] = {}
		itemsImgData[key].imgName = item.imgName
	end
end

root:setData("itemsImgData", itemsImgData)

function getItems()
	return items
end