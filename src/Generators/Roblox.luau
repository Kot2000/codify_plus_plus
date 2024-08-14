local Types = require("../Types")

local Serializer = require("../Serializer")

local createUniqueKey = require("../Lib/createUniqueKey")

local DEFAULT_INDENTATION = (" "):rep(4)

return function(config: {
	indentation: string?,
	names: ("all" | "changed" | "none")?,
}?)
	local function tab(n: number)
		local indent = config and config.indentation or DEFAULT_INDENTATION
		return indent:rep(n)
	end

	local function generate(package: Types.SerializedPackage)
		local uniqueKey = createUniqueKey()
		local document = {}

		local function renderNode(
			node: Types.SerializedTreeNode,
			prevNode: Types.SerializedTreeNode?
		)
			local variableName = uniqueKey(node.VariableName)
			node.VariableName = variableName

			if prevNode then
				table.insert(document, "")
			end

			table.insert(document, `local {variableName} = Instance.new("{node.ClassName}")`)

			local applyNameProperty = true

			if config and config.names == "changed" then
				applyNameProperty = node.Name ~= node.ClassName
			elseif config and config.names == "none" then
				applyNameProperty = false
			end

			if applyNameProperty then
				local nameString = Serializer.formatString(node.Name, "luau")
				table.insert(document, `{variableName}.Name = {nameString}`)
			end

			for propertyName, property in node.Properties do
				if property.Type ~= "serialized" then
					continue
				end

				local propertyValue = property.Value:gsub("\t", tab(1))
				table.insert(document, `{variableName}.{propertyName} = {propertyValue}`)
			end

			if prevNode then
				table.insert(document, `{variableName}.Parent = {prevNode.VariableName}`)
			end

			if node.Children then
				for _, childNode: any in node.Children do
					renderNode(childNode, node)
				end
			end
		end

		renderNode(package.Tree)

		local renderedDocument = table.concat(document, "\n")
		return renderedDocument
	end

	return {
		language = "luau",
		generate = generate,
	}
end
