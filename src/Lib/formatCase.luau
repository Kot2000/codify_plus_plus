export type CaseFormat = "camel" | "lower" | "pascal" | "upper"

local function formatCase(str: string, caseFormat: CaseFormat?)
	if caseFormat == "pascal" then
		local formatted = str:gsub("^%l", string.upper)
		return formatted
	elseif caseFormat == "lower" then
		return str:lower()
	elseif caseFormat == "camel" then
		local formatted = str:gsub("^%l", string.upper):gsub("^%u", string.lower)
		return formatted
	elseif caseFormat == "upper" then
		return str:upper()
	end

	return str
end

return formatCase
