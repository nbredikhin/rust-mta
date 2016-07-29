-- Предпросмотр установки строительного объекта
PartPreview = {}
PartPreview.partName = nil
local object
local highlightShader

local function update(deltaTime)
	if not object then
		return
	end

	object.position = localPlayer.position
end

function PartPreview.showPart(name)
	if type(name) ~= "string" or PartPreview.partName == name then
		return false
	end
	if PartPreview.partName then
		PartPreview.hidePart()
	end
	local model = exports.rsModels:getModelFromName(name)
	if not model then
		return false
	end	
	PartPreview.partName = name

	object = createObject(model, 0, 0, -10)
	object:setCollisionsEnabled(false)
	highlightShader:applyToWorldTexture("*", object)

	addEventHandler("onClientPreRender", root, update)
	return true
end

function PartPreview.hidePart()
	if not PartPreview.partName then
		return false
	end
	PartPreview.partName = nil
	-- Удалить объект
	if isElement(object) then
		destroyElement(object)
	end
	object = nil
	removeEventHandler("onClientPreRender", root, update)
	return true
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
	highlightShader = DxShader("assets/shaders/highlight.fx")
	highlightShader:setValue("gColor", {0, 255, 0, 150})
end)