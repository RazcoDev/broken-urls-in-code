package permit.authorized_users

import data.permit.root.debugger_activated
import future.keywords.in

format_rbac_assignment(user, role) := {
	"role": role,
	"resource": sprintf("__tenant:%s", [input.resource.tenant]),
	"tenant": input.resource.tenant,
	"user": user,
}

format_rebac_assignment(user, root_grant) := {
	"role": root_grant.role,
	"resource": root_grant.resource,
	"tenant": input.resource.tenant,
	"user": user,
}

default linked_users := {}

linked_users := permit_rebac.linked_users(input.resource)


allowing_action_roles_map[resource_type] := result {
	some resource_type, _ in data.role_permissions
	result := {role_key: {granted_resource_type:
	actions |
		actions := role.grants[granted_resource_type]
	} |
		role := data.role_permissions[resource_type][role_key]
	}
}

authorized_rbac_users[user] := roles {
	some _user, user_assignments in data.role_assignments
	tenant_assignments := user_assignments[sprintf("__tenant:%s", [input.resource.tenant])]
	user := trim_prefix(_user, "user:")
	roles := {
	formatted_assignment |
		role := tenant_assignments[_]
		input.action in allowing_action_roles_map.__tenant[role][input.resource.type]
		formatted_assignment := format_rbac_assignment(user, role)
	}
	count(roles) > 0
}

authorized_rebac_users[user] := roles {
	some _user, result in linked_users
	user := trim_prefix(_user, "user:")
	roles := {
	formatted_assignment |
		input.action in allowing_action_roles_map[input.resource.type][role][input.resource.type]
		root_grants := result.roles[role]
		root_grant := root_grants[_]
		formatted_assignment := format_rebac_assignment(user, root_grant)
	}
	count(roles) > 0
}

get_rebac_user_authorized_roles(user) := roles {
	roles := authorized_rebac_users[user]
} else = roles {
	roles := set()
}

get_rbac_user_authorized_roles(user) := roles {
	roles := authorized_rbac_users[user]
} else = roles {
	roles := set()
}


_authorized_users[user] := roles {
	
	authorized_users := object.keys(authorized_rebac_users) | object.keys(authorized_rbac_users)
	
	some user in authorized_users
	rebac_assignments := get_rebac_user_authorized_roles(user)
	rbac_assignments := get_rbac_user_authorized_roles(user)
	roles := rebac_assignments | rbac_assignments
}

debug.rbac[user] := debug_output {
	debugger_activated
	some user, roles in authorized_rbac_users
	debug_output := {"allowing_roles": {allowing_role: {"reason": reason} |
		allowing_role_formatted := roles[_]
		allowing_role := allowing_role_formatted.role
		reason := sprintf(
			"user '%s' has the role '%s' on tenant '%s', role '%s' has the permission to '%s' on resources of type '%s'",
			[user, allowing_role, input.resource.tenant, allowing_role, input.action, input.resource.type],
		)
	}}
}

debug.rebac[user] := debug_output {
	debugger_activated
	some user, result in linked_users
	debug_output := {role: role_debug |
		role_debug := result.debugger[role]
		input.action in allowing_action_roles_map[input.resource.type][role][input.resource.type]
	}
}

authorized_users_result := {
	"resource": sprintf("%s:*", [input.resource.type]),
	"tenant": input.resource.tenant,
	"users": authorized_rbac_users,
} {
	is_null(object.get(input.resource, "key", null))
}

authorized_users_result := {
	"resource": sprintf("%s:%s", [input.resource.type, input.resource.key]),
	"tenant": input.resource.tenant,
	"users": _authorized_users,
} {
	not is_null(object.get(input.resource, "key", null))
}

authorized_users.debug := debug {
	debugger_activated
}

authorized_users.result := authorized_users_result