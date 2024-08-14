package permit.abac

import future.keywords.in

import data.permit.generated.conditionset
import data.permit.utils.abac as utils

default allow := false

allow {
	some userset in matching_usersets
	some resourceset in matching_resourcesets
	is_allowing_pair(userset, resourceset)
}

allowing_rules[pair] {
	some userset in matching_usersets
	some resourceset in matching_resourcesets
	is_allowing_pair(userset, resourceset)
	pair := {
		"userset": userset,
		"resourceset": resourceset,
	}
}

is_allowing_pair(userset, resourceset) {
	# get the permissions in this couple of userset <> resourceset
	permissions := utils.condition_set_permissions[userset][resourceset][input.resource.type]

	# check if the specified action is allowed in this couple of userset <> resourceset
	input.action in permissions
}

decode_condition_set_key(key) = value {
	value := data.condition_sets[key].key
} else = key {
	true
}

matching_usersets[userset] {
	some set, value in conditionset
	startswith(set, "userset_")
	value == true
	userset := decode_condition_set_key(set)
}

matching_resourcesets[resourceset] {
	some set, value in conditionset
	startswith(set, "resourceset_")
	value == true
	resourceset := decode_condition_set_key(set)
}

usersets[set] {
	some _set, _ in conditionset
	startswith(_set, "userset_")
	not startswith(_set, "userset__5f_5fautogen")
	set := decode_condition_set_key(_set)
}

resourcesets[set] {
	some _set, _ in conditionset
	startswith(_set, "resourceset_")
	not startswith(_set, "resourceset__5f_5fautogen")
	set := decode_condition_set_key(_set)
}

default activated := false

# If there are any usersets or resourcesets, then abac is activated
activated {
	count(usersets) > 0
}

activated {
	count(resourcesets) > 0
}
