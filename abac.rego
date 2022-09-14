package permit.abac

import future.keywords.in

import data.permit.generated.conditionset
import data.permit.generated.abac.utils

default allow := false

allow {
	count(allowing_rules) > 0
}

allowing_rules[rule] {
	some rule, value in conditionset.rules
	value == true
}

matching_usersets[userset] {
	some set, value in conditionset
	startswith(set, "userset_")
	value == true
	userset := trim_prefix(set, "userset_")
}

matching_resourcesets[resourceset] {
	some set, value in conditionset
	startswith(set, "resourceset_")
	value == true
	resourceset := trim_prefix(set, "resourceset_")
}

userset_permissions[userset] := resourceset_permissions {
	some userset in matching_usersets
	resourceset_permissions := {
		resourceset: permissions |
			some resourceset in matching_resourcesets
			permissions := utils.condition_set_permissions[userset][resourceset]
	}
}

default debug = null
debug = {
	"allowing_rules": allowing_rules,
	"matching_usersets": matching_usersets,
	"matching_resourcesets": matching_resourcesets,
	"userset_permissions": userset_permissions,
	"attributes": {
		"context": {
			"generated": {},
			"input": utils.__input_context_attributes,
			"result": utils.attributes.context,
		},
		"user": {
			"generated": utils.__generated_user_attributes,
			"input": utils.__input_user_attributes,
			"result": utils.attributes.user,
		},
		"resource": {
			"generated": utils.__generated_resource_attributes,
			"input": utils.__input_resource_attributes,
			"result": utils.attributes.resource,
		},
	}
}
