package permit.rebac

import data.permit.rbac
import data.permit.utils
import future.keywords.in

__rebac_data := {
	"role_assignments": data.role_assignments,
	"relationships": data.relationships,
	"resource_types": data.resource_types,
}

default rebac_roles := []

rebac_roles_result := {
  "roles": [],
  "debugger": {
    "error": "Connected PDPs do not not support ReBAC, try to update your pdp version"
  }
}

rebac_roles := rebac_roles_result.roles

rebac_roles_debugger := rebac_roles_result.debugger

scoped_users_obj := result {
	roles_path = sprintf("/%s/roleAssignments/%s", [input.user.key, input.resource.tenant])
	result := json.patch(data.users, [{"op": "add", "path": roles_path, "value": rebac_roles}])
}

default allow := false

allow {
	rbac.allow with data.users as scoped_users_obj
		with data.roles_resource as input.resource.type
}

grants[grant] {
	rbac.grants[grant] with data.users as scoped_users_obj with data.roles_resource as input.resource.type
}

allowing_roles[role_key] {
	rbac.allowing_roles[role_key] with data.users as scoped_users_obj with data.roles_resource as input.resource.type
}

default activated := false

activated {
	count(utils.object_keys(data.relationships)) > 0
}
