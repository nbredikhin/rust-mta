function showPartPreview(name)
	return PartPreview.showPart(name)
end

function hidePartPreview()
	return PartPreview.hidePart()
end

addCommandHandler("part", function (_, name)
	outputChatBox("Show part '%s': %s" % {
		tostring(name), 
		tostring(showPartPreview(name))
	})
end)