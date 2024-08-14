local function trimString(str: string)
	local trimmed = str:gsub("^%s*(.-)%s*$", "%1")
	return trimmed
end

return trimString
