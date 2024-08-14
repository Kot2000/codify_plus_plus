local function createUniqueKey()
	local names = {}

	return function(name)
		if names[name] == nil then
			names[name] = 1
			return name
		end

		while true do
			names[name] += 1
			local finalName = `{name}_{names[name]}`

			if names[finalName] == nil then
				return finalName
			end
		end
	end
end

return createUniqueKey
