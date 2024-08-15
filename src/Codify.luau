local Packager = require("@pkg/Packager")

local Serializer = require("./Serializer")
local Types = require("./Types")

local formatCase = require("./Lib/formatCase")
local sanitizeName = require("./Lib/sanitizeName")
local trimString = require("./Lib/trimString")

local IGNORED_PROPERTIES = require("./IgnoredProperties")

local SanitizeNameReservedWords = {
	luau = require("./Lib/sanitizeName/ReservedWords/Luau"),
}

local _packagerHandle
local function getPackagerHandle()
	if _packagerHandle then
		return _packagerHandle
	end

	local packager = Packager.fetchFromServer()
	_packagerHandle = packager

	return packager
end

local function isIgnoredProperty(className: string, propertyName: string)
	if table.find(IGNORED_PROPERTIES.global, propertyName) then
		return true
	end

	if IGNORED_PROPERTIES.classes[className] then
		if table.find(IGNORED_PROPERTIES[className], propertyName) then
			return true
		end
	end

	local packager = getPackagerHandle()
	local ancestry = packager.Dump:GetAncestry(className)

	for _, ancestor in ancestry do
		if IGNORED_PROPERTIES.classes[ancestor] then
			if table.find(IGNORED_PROPERTIES.classes[ancestor], propertyName) then
				return true
			end
		end
	end

	return false
end

local function codify(
	root: Instance,
	config: {
		generator: {
    language: Serializer.Language,
    generate: (package: Types.SerializedPackage) -> string,
  },
		userFormats: Serializer.UserFormats?,
		caseFormat: formatCase.CaseFormat?,
	}
)
	local packager = getPackagerHandle()
	local flatpack = packager:CreatePackageFlat(root)

	for _, node in flatpack.Tree do
		local newNode: Types.SeralizedFlatTreeNode = node :: never
		local name = trimString(node.Name)

		newNode.VariableName = formatCase(
			sanitizeName(name, {
				reservedWords = SanitizeNameReservedWords[config.generator.language],
			}),
			config.caseFormat
		)

		for propertyName, property in node.Properties do
			if property.Type == "REF" then
				continue
			end

			if isIgnoredProperty(node.ClassName, propertyName) then
				continue
			end

			local newProperty: Types.SerializedProperty = property :: never
			local value = property.Value

			if property.Type == "Enum" then
				value = (Enum :: any)[value.Type][value.Value]
			end

			local serializedValue = Serializer.format(value, {
				language = config.generator.language,
				userFormats = config.userFormats,
			})

			if serializedValue == nil then
				continue
			end

			newProperty.OriginalType = property.Type
			newProperty.OriginalValue = value

			newProperty.Type = "serialized"
			newProperty.Value = serializedValue
		end
	end

	local package = Packager:ConvertToPackage(flatpack)
	return config.generator.generate(package)
end

return codify
