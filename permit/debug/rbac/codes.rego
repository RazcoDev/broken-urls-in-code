package permit.debug.rbac

import future.keywords.in

import data.permit.abac
import data.permit.debug.utils as debug_utils
import data.permit.policies
import data.permit.root
import data.permit.utils

# please note !
# this file uses parameters from different files with the same package name,
# for example, the 'allow','allowing_roles' are coming from the utils.rego file

__codes("allow") = {
	"allowing_roles": allowing_roles,
	"reason": sprintf(
		"user '%s' has the role '%s' in tenant '%s', role '%s' has the '%s' permission on resources of type '%s'",
		[input.user.key, allowing_roles[0], input.resource.tenant, allowing_roles[0], input.action, input.resource.type],
	),
}

__codes("user_not_synced") = {"reason": sprintf(
	"user '%s' is not synced and therefore has no known role assignments",
	[input.user.key],
)}

__codes("no_such_tenant") = {"reason": sprintf(
	"tenant '%s' does not exist. existing tenants: %s",
	[input.resource.tenant, debug_utils.format_array(utils.object_keys(data.tenants))],
)}

__codes("no_user_roles") = {"reason": sprintf(
	"no roles assigned to user '%s'",
	[input.user.key],
)}

__codes("no_such_resource") = {"reason": sprintf(
	"resource type '%s' is not defined. known resource types: %s",
	[input.resource.type, debug_utils.format_array(utils.object_keys(data.resource_types))],
)}

__codes("no_such_action") = {"reason": sprintf(
	"action '%s' is not defined on resource type '%s'. known actions on '%s': %s",
	[input.action, input.resource.type, input.resource.type, debug_utils.format_array(data.resource_types[input.resource.type].actions)],
)}

__codes("no_role_in_tenant") = {"reason": sprintf(
	"user '%s' has no assigned roles in tenant '%s'. user has roles in these tenants: %s",
	[
		input.user.key, input.resource.tenant,
		debug_utils.format_array(tenants_with_roles),
	],
)}

__codes("no_permission") = {"reason": sprintf(
	"user '%s' does not have any role that grants him the '%s' permission on resources of type '%s'",
	[input.user.key, input.action, input.resource.type],
)}

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
