package permit.abac_user_permissions

import data.permit.abac
import data.permit.generated.abac.utils

import future.keywords.in

permissions[ps] {
	user_key := input.user.key
	allowed_type := input.resource_types[_]

	some instance, instance_data in data.resource_instances
	parts := split(instance, ":")
	resource_type := parts[0]

	resource_type == allowed_type
	instance_key := parts[1]

	matching_us := abac.matching_usersets with input as {
		"user": {"key": user_key},
		"resource": {
			"type": resource_type,
			"key": instance_key,
			"tenant": instance_data.tenant,
		},
	}
	some userset in matching_us

	matching_rs := abac.matching_resourcesets with input as {
		"user": {"key": user_key},
		"resource": {
			"type": resource_type,
			"key": instance_key,
			"tenant": instance_data.tenant,
		},
	}
	some resourceset in matching_rs

	actions := data.condition_set_rules[userset][resourceset][resource_type]
	permissions := {p | action := actions[_]; p := sprintf("%s:%s", [resource_type, action])}

	ps := {instance: {"permissions": permissions, "userset": userset, "resourceset": resourceset}}
}