package permit.debug.abac

import data.permit.abac
import data.permit.utils
import data.permit.utils.abac as abac_utils
import future.keywords.in

# The purpose of those values is to forward abac policy package values to the debug package
allow = abac.allow

activated = abac.activated

usersets = abac.usersets

matching_usersets = abac.matching_usersets

resourcesets = abac.resourcesets

matching_resourcesets = abac.matching_resourcesets

__convert_userset_name_to_response(userset) = decoded_name {
	# check if the userset name starts with __autogen_
	startswith(userset, "__autogen_")

	# if so, it is a role, so we return it as a role name
	decoded_name := {"role": trim_prefix(userset, "__autogen_")}
} else = decoded_name {
	# otherwise, it is a userset, so we return it as a userset name
	decoded_name := {"userset": userset}
}

__convert_resourceset_name_to_response(resourceset) = decoded_name {
	# check if the resourceset name starts with __autogen_
	startswith(resourceset, "__autogen_")

	# if so, it is a resource type, so we return it as a resource type name
	decoded_name := {"resource_type": trim_prefix(resourceset, "__autogen_")}
} else = decoded_name {
	# otherwise, it is a resourceset, so we return it as a resourceset name
	decoded_name := {"resourceset": resourceset}
}

default allowing_rules := []

allowing_rules = [
# merge the userset and resourceset details
object.union(
	__convert_userset_name_to_response(pair.userset),
	__convert_resourceset_name_to_response(pair.resourceset),
) |
	abac.allowing_rules[pair]
]

format_reason_msg(allowing_rule) = msg {
	userset := allowing_rule.userset
	resourceset := allowing_rule.resourceset
	msg := sprintf(
		"user '%s' matched '%s' userset conditions, the given resource matched the '%s' resourceset conditions, users matching '%s' userset conditions has the '%s' permission on resources of type '%s' matching '%s' resourceset conditions",
		[input.user.key, userset, resourceset, userset, input.action, input.resource.type, resourceset],
	)
}

format_reason_msg(allowing_rule) = msg {
	role := allowing_rule.role
	resourceset := allowing_rule.resourceset
	msg := sprintf(
		"user '%s' has the role '%s' in tenant '%s', the given resource matched the '%s' resourceset conditions, role '%s' has the '%s' permission on resources of type '%s' matching '%s' resourceset conditions",
		[input.user.key, role, input.resource.tenant, resourceset, role, input.action, input.resource.type, resourceset],
	)
}

format_reason_msg(allowing_rule) = msg {
	userset := allowing_rule.userset
	resource_type := allowing_rule.resource_type
	msg := sprintf(
		"user '%s' matched '%s' userset conditions, users matching '%s' userset conditions has the '%s' permission on resources of type '%s'",
		[input.user.key, userset, userset, input.action, input.resource.type],
	)
}
