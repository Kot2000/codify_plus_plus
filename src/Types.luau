local Packager = require("@pkg/Packager")

export type SerializedProperty = {
	Type: "serialized",
	Value: string,
	OriginalType: string,
	OriginalValue: any,
}

type SerializedNodeAdditions = {
	VariableName: string,
}

export type SeralizedFlatTreeNode = Packager.FlatTreeNode & SerializedNodeAdditions
export type SerializedTreeNode = Packager.TreeNode & SerializedNodeAdditions

export type SerializedPackage = Packager.Package & {
	Tree: SerializedTreeNode,
}

return {}
