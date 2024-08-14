local Types = require("../Types")

local Serializer = require("../Serializer")

local createUniqueKey = require("../Lib/createUniqueKey")

local DEFAULT_INDENTATION = (" "):rep(4)

return function(config: {
	indentation: string?,
	names: ("all" | "changed" | "none")?,
	lowercaseKeyProp: boolean?,
}?)
	local keyProp = config and config.lowercaseKeyProp and "key" or "Key"

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
			local className = node.ClassName:lower()

			table.insert(document, `{tab(depth, not prevNode)}<{className}`)
			local initLineIndex = #document

			local nodeNameProp = Serializer.formatString(node.Name, "jsx")
			local applyNameProperty = true

			if config and config.names == "changed" then
				applyNameProperty = node.Name ~= node.ClassName
			elseif config and config.names == "none" then
				applyNameProperty = false
			end

			if prevNode then
				depth += 1
			end

			local hasProps = false
			local keyPropInsertPosition = #document + 1

			for propertyName, property: any in node.Properties do
				if property.Type ~= "serialized" then
					continue
				end

				local propertyValue = property.Value:gsub("\t", tab(1))

				if property.OriginalType ~= "string" then
					propertyValue = `\{{propertyValue}}`
				end

				table.insert(document, `{tab(depth)}{propertyName}={propertyValue}`)

				hasProps = true
			end

			if applyNameProperty then
				if not hasProps then
					document[initLineIndex] ..= ` {keyProp}={nodeNameProp}`
				else
					table.insert(
						document,
						keyPropInsertPosition,
						`{tab(depth)}{keyProp}={nodeNameProp}`
					)
				end
			end

			if node.Children then
				local uniqueKey = createUniqueKey()

				if hasProps then
					table.insert(document, ">")
				else
					document[initLineIndex] ..= ">"
				end

				for _, child: any in node.Children do
					child.Name = uniqueKey(child.Name)

					renderNode(child, node)
					table.insert(document, "")
				end

				table.remove(document)
			end

			if prevNode then
				depth -= 1
			end

			if hasProps or node.Children then
				table.insert(document, `{tab(depth, not prevNode)}/>`)
			else
				document[initLineIndex] ..= `{applyNameProperty and " " or ""}/>`
			end
		end

		renderNode(package.Tree)

		local renderedDocument = table.concat(document, "\n")
		return renderedDocument
	end

	return {
		language = "jsx",
		generate = generate,
	}
end
