package permit.debug.rbac

import data.permit.debug.utils as debug_utils
import data.permit.rbac
import data.permit.utils
import data.permit.utils.rbac as rbac_utils
import future.keywords.in

default details := null

details = details {
	# in case of rbac allow, return the allowing roles
	allow
	details := codes("allow")
} else = details {
	# if the resource type is not in the data
	not utils.has_key(data.resource_types, input.resource.type)
	details := codes("no_such_resource")
} else = details {
	# if the resource type does not have the specified action, return an error
	not input.action in data.resource_types[input.resource.type].actions
	details := codes("no_such_action")
} else = details {
	# if the tenant is not in the data
	not utils.has_key(data.tenants, input.resource.tenant)
	details := codes("no_such_tenant")
} else = details {
	# if the user is not in the data
	not utils.has_key(data.users, input.user.key)
	details := codes("user_not_synced")
} else = details {
	# if the user is not associated with the tenant
	count(tenants_with_roles) == 0
	details := codes("no_user_roles")
} else = details {
	# if the user has no roles
	count(rbac_utils.user_roles) == 0
	details := codes("no_role_in_tenant")
} else = details {
	# if the user does not have the required permissions ( grants )
	details := codes("no_permission")
}
