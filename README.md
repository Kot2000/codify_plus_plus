<!-- markdownlint-disable MD041 -->

<!-- Links -->
[codify-devforum]: https://devforum.roblox.com/t/473076
[codify-itch]: https://cxmeel.itch.io/codify

<!-- Content -->
# CodifyLib

An open source implementation of the [Codify plugin][codify-devforum]'s internal "Instance-to-snippet" conversion module.

-----

**Looking for the [Codify plugin][codify-devforum]?**

[![Purchase on Roblox](assets/roblox_dev-animated.svg)](https://create.roblox.com/store/asset/4749111907) [![Purchase on Itch.io](assets/itch.svg)][codify-itch]

[Codify][codify-devforum] converts Roblox Instances into code snippets in a flash. Whether you use vanilla Roblox Luau, [TypeScript JSX](https://roblox-ts.com/docs/guides/roact-jsx), or a framework like [React](https://github.com/jsdotlua/react-lua#readme)/[Roact](https://github.com/roblox/roact), [Fusion](https://github.com/dphfox/Fusion#readme), [Vide](https://github.com/centau/vide#readme) or [Rojo](https://rojo.space/docs/v7/sync-details/#json-models), Codify’s got you covered!

- [Learn more &rarr;][codify-devforum]

-----

## Contributors

The following individuals have contributed to the development of CodifyLib:

- [@boatbomber](https://github.com/boatbomber) - Implemented original generators for Fusion and vanilla Roblox.
- [@PepeElToro41](https://github.com/PepeElToro41) - Implemented original JSX generator.

## Example Usage

```luau
local CodifyLib = require("path/to/CodifyLib")
local Generators = CodifyLib.Generators

-- Setup the React generator with a custom config
local react = Generators.React({
    indentation = "  ",
    createMethod = "e",
    names = "all",
})

-- Generate the snippet, targeting the Baseplate
-- with a custom config
local snippet = CodifyLib.codify(workspace.Baseplate, {
    generator = react,
    caseFormat = "camel", -- Render keys/variables in camelCase
    userFormats = {
        color3 = "hex", -- Render Color3 values as hex
    },
})

print("Snippet:", snippet)
```

## Generators

CodifyLib comes with a variety of generators to suit your needs:

### Roblox

> Generates vanilla Roblox Lua code (i.e. `Instance.new`).

```luau
type Config = {
    indentation: string?, -- default: "    "
    names: ("all" | "none" | "changed")?, -- default: "all"
}?
```

### Fusion

> Fusion is a reactive framework for Roblox Luau, created by [@dphfox](https://github.com/dphfox).\
> [Learn more &rarr;](https://github.com/dphfox/Fusion#readme)

```luau
type Config = {
    indentation: string?, -- default: "    "
    createMethod: string?, -- default: "scope:New"
    childrenKey: string?, -- default: "Children"
    names: ("all" | "none" | "changed")?, -- default: "all"
}
```

### React

> React for Roblox is a translation of React17 from JavaScript to Lua by [@roblox](https://github.com/roblox) and [@jsdotlua](https://github.com/jsdotlua).\
> [Learn more &rarr;](https://github.com/jsdotlua/react-lua)

```luau
type Config = {
    indentation: string?, -- default: "    "
    createMethod: string?, -- default: "React.createElement"
    names: ("all" | "none" | "changed")?,
}
```

### Jsx

> JSX allows HTML-like syntax to be used in TypeScript for Roblox. It is part of the roblox-ts project.\
> [Learn more &rarr;](https://roblox-ts.com/docs/guides/roact-jsx)

```luau
type Config = {
    indentation: string?, -- default: "    "
    names: ("all" | "none" | "changed")?, -- default: "all"
    lowercaseKeyProp: boolean?, -- default: false
}
```

## UserFormats

CodifyLib allows you to define the way datatypes are formatted in the resulting snippets. This can be useful for customizing the output to match your coding style.

The default for all values is `"full"`.

```luau
type UserFormats = {
    color3: "full" | "hex" | "hsv" | "rgb",
    udim2: "full",
    numberRange: "full",
    enum: "full" | "number" | "string",
    normalId: "full",
    brickColor: "full" | "number" | "rgb",
    physicalProperties: "full",
    udim: "full",
    cframe: "full",
    vector2: "full",
    vector3: "full",
    font: "full",
    colorSequence: "full",
    numberSequence: "full",
}
```

-----

<!-- markdownlint-disable-next-line MD033 -->
<div align="center">

**Codify for Roblox Studio**\
[Purchase on Roblox](https://create.roblox.com/store/asset/4749111907) | [Purchase on Itch.io][codify-itch] | [Learn more][codify-devforum]

</div>
