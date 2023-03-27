package permit.abac

import future.keywords.in

import data.permit.generated.conditionset
import data.permit.utils.abac as utils

default allow := false

allow {
	count(allowing_rules) > 0
}

allowing_rules[rule] {
	some rule, value in conditionset.rules
	value == true
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

userset_permissions[userset] := resourceset_permissions {
	some userset in matching_usersets
	resourceset_permissions := {resourceset: permissions |
		some resourceset in matching_resourcesets
		permissions := utils.condition_set_permissions[userset][resourceset]
	}
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
