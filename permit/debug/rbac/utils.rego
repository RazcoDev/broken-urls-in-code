package permit.debug.rbac

import data.permit.debug.utils as debug_utils
import data.permit.rbac

# The purpose of those values is to forward rbac policy package values to the debug package
allow = rbac.allow

allowing_roles = debug_utils.to_array(rbac.allowing_roles)

tenants_with_roles = [tenant |
	count(data.users[input.user.key].roleAssignments[tenant]) > 0
	role_assignments := data.users[input.user.key].roleAssignments[tenant]
]
