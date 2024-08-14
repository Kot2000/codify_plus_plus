local trimString = require("../trimString")

local function sanitizeName(
	name: string,
	config: {
		reservedWords: { string }?,
	}?
)
	local reservedWords = config and config.reservedWords

	-- Replace all non-alphanumeric characters with underscores
	name = trimString(name):gsub("[^%w_]+", "_")

	-- If the name is a reserved word, prefix it with `var_`
	if reservedWords and table.find(reservedWords, name) then
		return `var_{name}`
	end

	-- If the name starts with a number, prefix it with `var_`
	if name:match("^%d") then
		return `var_{name}`
	end

	-- If the name is empty, return `var_undefined`
	if name == "" then
		return "var_undefined"
	end

	return name
end

return sanitizeName
