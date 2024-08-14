local Types = require("../Types")

local Serializer = require("../Serializer")

local DEFAULT_INDENTATION = (" "):rep(4)
local DEFAULT_CREATE_METHOD = "scope:New"
local DEFAULT_CHILDREN_KEY = "Children"

return function(config: {
	indentation: string?,
	createMethod: string?,
	childrenKey: string?,
	names: ("all" | "changed" | "none")?,
}?)
	local createMethod = config and config.createMethod or DEFAULT_CREATE_METHOD
	local childrenKey = config and config.childrenKey or DEFAULT_CHILDREN_KEY

	local function tab(n: number)
		local indent = config and config.indentation or DEFAULT_INDENTATION
		return indent:rep(n)
	end

	local function generate(package: Types.SerializedPackage)
		local document = {}
		local depth = 1

		local function renderNode(
			node: Types.SerializedTreeNode,
			prevNode: Types.SerializedTreeNode?
		)
			local nameKey = Serializer.formatString(node.ClassName, "luau")
			table.insert(document, `{tab(prevNode and depth or 0)}{createMethod} {nameKey} \{`)

			if prevNode then
				depth += 1
			end

			local applyNameProperty = true

			if config and config.names == "none" then
				applyNameProperty = false
			elseif config and config.names == "changed" then
				applyNameProperty = node.Name ~= node.ClassName
			end

			if applyNameProperty then
				local nameString = Serializer.formatString(node.Name, "luau")
				table.insert(document, `{tab(depth)}Name = {nameString},`)
			end

			for propertyName, property in node.Properties do
				if property.Type ~= "serialized" then
					continue
				end

				local propertyValue = property.Value:gsub("\t", tab(1))
				table.insert(document, `{tab(depth)}{propertyName} = {propertyValue},`)
			end

			if node.Children then
				table.insert(document, "")
				table.insert(document, `{tab(depth)}[{childrenKey}] = \{`)

				depth += 1

				for _, child: any in node.Children do
					renderNode(child, node)
					table.insert(document, "")
				end

				table.remove(document)
				depth -= 1

				table.insert(document, `{tab(depth)}}`)
			end

			if prevNode then
				depth -= 1
			end

			table.insert(document, `{tab(prevNode and depth or 0)}\}{prevNode and "," or ""}`)
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
