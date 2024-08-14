package permit.debug.abac

import future.keywords.in

import data.permit.debug.utils as debug_utils
import data.permit.utils

# please note !
# this file uses parameters from different files with the same package name,
# for example, the 'allow','allowing_rules' are coming from the utils.rego file

__codes("allow") = {
	"allowing_rules": allowing_rules,
	"reason": format_reason_msg(allowing_rules[0]),
}

__codes("no_matching_usersets") = {"reason": sprintf(
	"user '%s' did not match any userset conditions. known usersets: %s",
	[input.user.key, debug_utils.format_array(usersets)],
)}

__codes("no_matching_resourcesets") = {
	"reason": sprintf(
		"the given resource did not match any resourceset conditions. known resourcesets: %s",
		[debug_utils.format_array(resourcesets)],
	),
	"matching_usersets": matching_usersets,
}

__codes("no_matching_rules") = {
	"reason": sprintf(
		"user '%s' does not match any rule that grants him the '%s' permission on the given resource of type '%s'",
		[input.user.key, input.action, input.resource.type],
	),
	"matching_usersets": matching_usersets,
	"matching_resourcesets": matching_resourcesets,
}

__codes("cloud_pdp_not_supporting_abac") = {"reason": "The Cloud PDP does not support ABAC policies at the moment, run the PDP container to enforce access with ABAC"}

codes(code) = result {
	allow
	result := object.union(
		{
			"allow": allow,
			"code": code,
		},
		__codes(code),
	)
}

codes(code) = result {
	not allow
	result := object.union(
		{
			"allow": allow,
			"code": code,
			"support_link": sprintf("https://docs.permit.io/errors/%s", [code]),
		},
		__codes(code),
	)
}
