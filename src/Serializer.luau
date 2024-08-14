export type UserFormats = {
	color3: Color3Format,
	udim2: UDim2Format,
	numberRange: NumberRangeFormat,
	enum: EnumFormat,
	normalId: NormalIdFormat,
	brickColor: BrickColorFormat,
	physicalProperties: PhysicalPropertiesFormat,
	udim: UDimFormat,
	cframe: CFrameFormat,
	vector2: Vector2Format,
	vector3: Vector3Format,
	font: FontFormat,
	colorSequence: ColorSequenceFormat,
	numberSequence: NumberSequenceFormat,
}

export type Language = "luau" | "jsx"

local DEFAULT_LANGUAGE: Language = "luau"
local DEFAULT_USER_FORMATS: UserFormats = {
	color3 = "full",
	udim2 = "full",
	numberRange = "full",
	enum = "full",
	normalId = "full",
	brickColor = "full",
	physicalProperties = "full",
	udim = "full",
	cframe = "full",
	vector2 = "full",
	vector3 = "full",
	font = "full",
	colorSequence = "full",
	numberSequence = "full",
}

local function formatNumber(value: number, precision: number?)
	if value == math.huge then
		return "math.huge"
	elseif value == -math.huge then
		return "-math.huge"
	end

	return string.format(`%.{precision or 3}g`, value)
end

local function formatString(value: string, lang: Language?)
	local isMultiLine = value:find("\n")

	if isMultiLine then
		if lang == "jsx" then
			return `\`{value:gsub("`", "\\`")}\``
		end

		return `[[{value:gsub("]]", "]\\]")}]`
	end

	return `"{value:gsub('"', '\\"')}"`
end

export type Color3Format = "full" | "hex" | "hsv" | "rgb"
local function formatColor3(format: Color3Format, _userFormats: UserFormats)
	return function(value: Color3, lang: Language?)
		if format == "hex" then
			return `Color3.fromHex("#{value:ToHex()}")`
		elseif format == "hsv" then
			local h, s, v = value:ToHSV()

			local hue = formatNumber(math.clamp(h, 0, 1))
			local sat = formatNumber(math.clamp(s, 0, 1))
			local val = formatNumber(math.clamp(v, 0, 1))

			return `Color3.fromHSV({hue}, {sat}, {val})`
		elseif format == "rgb" then
			local r = formatNumber(math.clamp(value.R, 0, 1))
			local g = formatNumber(math.clamp(value.G, 0, 1))
			local b = formatNumber(math.clamp(value.B, 0, 1))

			return `Color3.fromRGB({r}, {g}, {b})`
		end

		if value.R == 0 and value.G == 0 and value.B == 0 then
			if lang == "jsx" then
				return "new Color()"
			end

			return "Color3.new()"
		end

		local r = formatNumber(math.clamp(value.R, 0, 1))
		local g = formatNumber(math.clamp(value.G, 0, 1))
		local b = formatNumber(math.clamp(value.B, 0, 1))

		if lang == "jsx" then
			return `new Color({r}, {g}, {b})`
		end

		return `Color3.new({r}, {g}, {b})`
	end
end

export type UDim2Format = "full"
local function formatUDim2(_format: UDim2Format, _userFormats: UserFormats)
	return function(value: UDim2, lang: Language?)
		local xs = value.X.Scale
		local xo = value.X.Offset
		local ys = value.Y.Scale
		local yo = value.Y.Offset

		if xs == 0 and xo == 0 and ys == 0 and yo == 0 then
			if lang == "jsx" then
				return "new UDim2()"
			end

			return "UDim2.new()"
		end

		local xss = formatNumber(xs)
		local xos = formatNumber(xo)
		local yss = formatNumber(ys)
		local yos = formatNumber(yo)

		if lang == "jsx" then
			return `new UDim2({xss}, {xos}, {yss}, {yos})`
		end

		return `UDim2.new({xss}, {xos}, {yss}, {yos})`
	end
end

export type NumberRangeFormat = "full"
local function formatNumberRange(_format: NumberRangeFormat, _userFormats: UserFormats)
	return function(value: NumberRange, lang: Language?)
		local min = formatNumber(value.Min)
		local max = formatNumber(value.Max)

		if lang == "jsx" then
			return `new NumberRange({min}, {max})`
		end

		return `NumberRange.new({min}, {max})`
	end
end

export type EnumFormat = "full" | "number" | "string"
local function formatEnum(format: EnumFormat, _userFormats: UserFormats)
	return function(value: EnumItem, _lang: Language?)
		if format == "number" then
			return tostring(value.Value)
		elseif format == "string" then
			return `"{value.Name}"`
		end

		return tostring(value)
	end
end

export type NormalIdFormat = "full"
local function formatNormalIdDataType<T>(className: string, __datatype: T)
	return function(_format: NormalIdFormat, userFormats: UserFormats)
		return function(value: T, lang: Language?)
			local axes = {}

			for _, normalId in Enum.NormalId:GetEnumItems() do
				if (value :: any)[normalId.Name] then
					table.insert(axes, formatEnum("full", userFormats)(normalId, lang))
				end
			end

			local values = table.concat(axes, ", ")

			if lang == "jsx" then
				return `new {className}({values})`
			end

			return `{className}.new({values})`
		end
	end
end

local FORMAT_AXES_TYPE_INSTANCE = (nil :: never) :: Axes
local formatAxes = formatNormalIdDataType("Axes", FORMAT_AXES_TYPE_INSTANCE)

local FORMAT_FACES_TYPE_INSTANCE = (nil :: never) :: Faces
local formatFaces = formatNormalIdDataType("Faces", FORMAT_FACES_TYPE_INSTANCE)

export type BrickColorFormat = "full" | "rgb" | "number"
local function formatBrickColor(format: BrickColorFormat, _userFormats: UserFormats)
	return function(value: BrickColor, lang: Language?)
		if format == "rgb" then
			local r = formatNumber(math.clamp(value.r, 0, 1))
			local g = formatNumber(math.clamp(value.g, 0, 1))
			local b = formatNumber(math.clamp(value.b, 0, 1))

			if lang == "jsx" then
				return `new BrickColor({r}, {g}, {b})`
			end

			return `BrickColor.new({r}, {g}, {b})`
		elseif format == "number" then
			if lang == "jsx" then
				return `new BrickColor({value.Number})`
			end

			return `BrickColor.new({value.Number})`
		end

		if lang == "jsx" then
			return `new BrickColor("{value.Name}")`
		end

		return `BrickColor.new("{value.Name}")`
	end
end

export type PhysicalPropertiesFormat = "full"
local function formatPhysicalProperties(
	_format: PhysicalPropertiesFormat,
	_userFormats: UserFormats
)
	return function(value: PhysicalProperties, lang: Language?)
		local values = {
			formatNumber(value.Density),
			formatNumber(value.Friction),
			formatNumber(value.Elasticity),
			formatNumber(value.FrictionWeight),
			formatNumber(value.ElasticityWeight),
		}

		if lang == "jsx" then
			return `new PhysicalProperties({table.concat(values, ", ")})`
		end

		return `PhysicalProperties.new({table.concat(values, ", ")})`
	end
end

export type UDimFormat = "full"
local function formatUDim(_format: UDimFormat, _userFormats: UserFormats)
	return function(value: UDim, lang: Language?)
		local scale = formatNumber(value.Scale)
		local offset = formatNumber(value.Offset)

		if lang == "jsx" then
			return `new UDim({scale}, {offset})`
		end

		return `UDim.new({scale}, {offset})`
	end
end

export type CFrameFormat = "full"
local function formatCFrame(_format: CFrameFormat, _userFormats: UserFormats)
	return function(value: CFrame, lang: Language?)
		local components = {}

		for _, component in { value:GetComponents() } do
			table.insert(components, formatNumber(component))
		end

		if lang == "jsx" then
			return `new CFrame({table.concat(components, ", ")})`
		end

		return `CFrame.new({table.concat(components, ", ")})`
	end
end

export type Vector2Format = "full"
local function formatVector2(_format: Vector2Format, _userFormats: UserFormats)
	return function(value: Vector2 | Vector2int16, lang: Language?)
		local dataType = typeof(value)

		local x = formatNumber(value.X)
		local y = formatNumber(value.Y)

		if lang == "jsx" then
			return `new {dataType}({x}, {y})`
		end

		return `{dataType}.new({x}, {y})`
	end
end

export type Vector3Format = "full"
local function formatVector3(_format: Vector3Format, _userFormats: UserFormats)
	return function(value: Vector3 | Vector3int16, lang: Language?)
		local dataType = typeof(value)

		local x = formatNumber(value.X)
		local y = formatNumber(value.Y)
		local z = formatNumber(value.Z)

		if lang == "jsx" then
			return `new {dataType}({x}, {y}, {z})`
		end

		return `{dataType}.new({x}, {y}, {z})`
	end
end

export type FontFormat = "full"
local function formatFont(_format: FontFormat, userFormats: UserFormats)
	return function(value: Font, lang: Language?)
		if value.Style == Enum.FontStyle.Normal and value.Weight == Enum.FontWeight.Regular then
			if lang == "jsx" then
				return `new Font("{value.Family}")`
			end

			return `Font.new("{value.Family}")`
		end

		local style = formatEnum("full", userFormats)(value.Style)
		local weight = formatEnum("full", userFormats)(value.Weight)

		if lang == "jsx" then
			return `new Font(\n\t"{value.Family}",\n\t{style},\n\t{weight}\n)`
		end

		return `Font.new(\n\t"{value.Family}",\n\t{style},\n\t{weight}\n)`
	end
end

export type ColorSequenceFormat = "full"
local function formatColorSequence(_format: ColorSequenceFormat, userFormats: UserFormats)
	return function(value: ColorSequence, lang: Language?)
		local keypoints = {}

		for _, keypoint in value.Keypoints do
			local keypointValue =
				formatColor3(userFormats.color3, userFormats)(keypoint.Value, lang)
			local timeValue = formatNumber(keypoint.Time)

			if lang == "jsx" then
				table.insert(keypoints, `\tnew ColorSequenceKeypoint({keypointValue}, {timeValue})`)
				continue
			end

			table.insert(keypoints, `\tColorSequenceKeypoint.new({keypointValue}, {timeValue})`)
		end

		local keypointsString = table.concat(keypoints, ",\n")

		if lang == "jsx" then
			return `new ColorSequence([\n{keypointsString}\n])`
		end

		return `ColorSequence.new(\{\n{keypointsString}\n})`
	end
end

export type NumberSequenceFormat = "full"
local function formatNumberSequence(_format: NumberSequenceFormat, _userFormats: UserFormats)
	return function(value: NumberSequence, lang: Language?)
		local keypoints = {}

		for _, keypoint in value.Keypoints do
			local keypointValue = formatNumber(keypoint.Value)
			local timeValue = formatNumber(keypoint.Time)
			local envelopeValue = formatNumber(keypoint.Envelope)

			if keypoint.Envelope == 0 then
				if lang == "jsx" then
					table.insert(
						keypoints,
						`\tnew NumberSequenceKeypoint({keypointValue}, {timeValue})`
					)
					continue
				end

				table.insert(
					keypoints,
					`\tNumberSequenceKeypoint.new({keypointValue}, {timeValue})`
				)
				continue
			end

			if lang == "jsx" then
				table.insert(
					keypoints,
					`\tnew NumberSequenceKeypoint({keypointValue}, {timeValue}, {envelopeValue})`
				)
				continue
			end

			table.insert(
				keypoints,
				`\tNumberSequenceKeypoint.new({keypointValue}, {timeValue}, {envelopeValue})`
			)
		end

		local keypointsString = table.concat(keypoints, ",\n")

		if lang == "jsx" then
			return `new NumberSequence([\n{keypointsString}\n])`
		end

		return `NumberSequence.new(\{\n{keypointsString}\n})`
	end
end

local function formatValue(
	value: any,
	config: {
		userFormats: UserFormats?,
		language: Language?,
	}?
): string?
	local lang: Language = config and config.language or DEFAULT_LANGUAGE
	local userFormats = config and config.userFormats or DEFAULT_USER_FORMATS

	local dataType = typeof(value)

	if dataType == "Color3" then
		local format: Color3Format = (
			userFormats.color3 or DEFAULT_USER_FORMATS.color3
		) :: Color3Format

		return formatColor3(format, userFormats)(value, lang)
	elseif dataType == "UDim2" then
		local format: UDim2Format = (userFormats.udim2 or DEFAULT_USER_FORMATS.udim2) :: UDim2Format

		return formatUDim2(format, userFormats)(value, lang)
	elseif dataType == "NumberRange" then
		local format: NumberRangeFormat = (
			userFormats.numberRange or DEFAULT_USER_FORMATS.numberRange
		) :: NumberRangeFormat

		return formatNumberRange(format, userFormats)(value, lang)
	elseif dataType == "EnumItem" then
		local format: EnumFormat = (userFormats.enum or DEFAULT_USER_FORMATS.enum) :: EnumFormat

		return formatEnum(format, userFormats)(value, lang)
	elseif dataType == "Axes" then
		local format: NormalIdFormat = (
			userFormats.normalId or DEFAULT_USER_FORMATS.normalId
		) :: NormalIdFormat

		return formatAxes(format, userFormats)(value, lang)
	elseif dataType == "Faces" then
		local format: NormalIdFormat = (
			userFormats.normalId or DEFAULT_USER_FORMATS.normalId
		) :: NormalIdFormat

		return formatFaces(format, userFormats)(value, lang)
	elseif dataType == "BrickColor" then
		local format: BrickColorFormat = (
			userFormats.brickColor or DEFAULT_USER_FORMATS.brickColor
		) :: BrickColorFormat

		return formatBrickColor(format, userFormats)(value, lang)
	elseif dataType == "PhysicalProperties" then
		local format: PhysicalPropertiesFormat = (
			userFormats.physicalProperties or DEFAULT_USER_FORMATS.physicalProperties
		) :: PhysicalPropertiesFormat

		return formatPhysicalProperties(format, userFormats)(value, lang)
	elseif dataType == "UDim" then
		local format: UDimFormat = (userFormats.udim or DEFAULT_USER_FORMATS.udim) :: UDimFormat

		return formatUDim(format, userFormats)(value, lang)
	elseif dataType == "CFrame" then
		local format: CFrameFormat = (
			userFormats.cframe or DEFAULT_USER_FORMATS.cframe
		) :: CFrameFormat

		return formatCFrame(format, userFormats)(value, lang)
	elseif dataType == "Vector2" or dataType == "Vector2int16" then
		local format: Vector2Format = (
			userFormats.vector2 or DEFAULT_USER_FORMATS.vector2
		) :: Vector2Format

		return formatVector2(format, userFormats)(value, lang)
	elseif dataType == "Vector3" or dataType == "Vector3int16" then
		local format: Vector3Format = (
			userFormats.vector3 or DEFAULT_USER_FORMATS.vector3
		) :: Vector3Format

		return formatVector3(format, userFormats)(value, lang)
	elseif dataType == "Font" then
		local format: FontFormat = (userFormats.font or DEFAULT_USER_FORMATS.font) :: FontFormat

		return formatFont(format, userFormats)(value, lang)
	elseif dataType == "ColorSequence" then
		local format: ColorSequenceFormat = (
			userFormats.colorSequence or DEFAULT_USER_FORMATS.colorSequence
		) :: ColorSequenceFormat

		return formatColorSequence(format, userFormats)(value, lang)
	elseif dataType == "NumberSequence" then
		local format: NumberSequenceFormat = (
			userFormats.numberSequence or DEFAULT_USER_FORMATS.numberSequence
		) :: NumberSequenceFormat

		return formatNumberSequence(format, userFormats)(value, lang)
	end

	if dataType == "Instance" then
		return
	elseif dataType == "number" then
		return formatNumber(value)
	elseif dataType == "string" then
		return formatString(value, lang)
	end

	if type(value) == "userdata" then
		if lang == "jsx" then
			return `new {dataType}({value})`
		end

		return `{dataType}.new({value})`
	end

	return tostring(value)
end

return {
	DEFAULT_USER_FORMATS = DEFAULT_USER_FORMATS,
	DEFAULT_LANGUAGE = DEFAULT_LANGUAGE,

	formatAxes = formatAxes,
	formatBrickColor = formatBrickColor,
	formatColor3 = formatColor3,
	formatColorSequence = formatColorSequence,
	formatCFrame = formatCFrame,
	formatEnum = formatEnum,
	formatFont = formatFont,
	formatNumber = formatNumber,
	formatNumberRange = formatNumberRange,
	formatNumberSequence = formatNumberSequence,
	formatPhysicalProperties = formatPhysicalProperties,
	formatString = formatString,
	formatUDim = formatUDim,
	formatUDim2 = formatUDim2,
	formatVector2 = formatVector2,
	formatVector3 = formatVector3,

	format = formatValue,
}
