local Types = require("../Types")

local Serializer = require("../Serializer")

local createUniqueKey = require("../Lib/createUniqueKey")

local DEFAULT_INDENTATION = (" "):rep(4)
local DEFAULT_CREATE_METHOD = "React.createElement"

return function(config: {
	indentation: string?,
	createMethod: string?,
	names: ("all" | "changed" | "none")?,
}?)
	local createMethod = config and config.createMethod or DEFAULT_CREATE_METHOD

	local function tab(n: number, condition: boolean?)
		if condition then
			return ""
		end

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
			local initPrefix = ""

			if prevNode then
				local childKey = tostring(table.find((prevNode :: any).Children, node))

				if config then
					if
						config.names == "all"
						or (config.names == "changed" and node.Name ~= node.ClassName)
					then
						childKey = node.VariableName
					end
				end

				if not config or (config and config.names ~= "none") then
					initPrefix = `{childKey} = `
				end
			end

			table.insert(document, `{tab(depth, not prevNode)}{initPrefix}{createMethod}({nameKey}`)
			local initLineIndex = #document

			if prevNode then
				depth += 1
			end

			local hasProps = false

			for propertyName, property in node.Properties do
				if property.Type ~= "serialized" then
					continue
				end

				local propertyValue = property.Value:gsub("\t", tab(1))
				table.insert(document, `{tab(depth)}{propertyName} = {propertyValue},`)

				hasProps = true
			end

			if node.Children then
				depth -= 1

				if hasProps then
					table.insert(document, `{tab(depth)}}, \{`)
				end

				depth += 1

				local uniqueKey = createUniqueKey()

				for _, child: any in node.Children do
					child.VariableName = uniqueKey(child.VariableName)

					renderNode(child, node)
					table.insert(document, "")
				end

				table.remove(document)
			end

			if prevNode then
				depth -= 1
			end

			if hasProps or node.Children then
				table.insert(document, `{tab(depth, not prevNode)}}){prevNode and "," or ""}`)
			end

			if hasProps then
				document[initLineIndex] ..= ", {"
			elseif node.Children then
				document[initLineIndex] ..= ", nil, {"
			else
				document[initLineIndex] ..= prevNode and ")," or ")"
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
