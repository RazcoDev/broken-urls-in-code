package permit.rebac

import data.permit.rbac
import data.permit.utils
import future.keywords.in

allow {
	rebac_data := {
		"role_assignments": data.role_assignments,
		"relationships": data.relationships,
		"resource_types": data.resource_types,
	}
	rebac_roles := permit_rebac_roles(rebac_data, input)
	tenant_association := object.get(data.users, [input.user.key, "roleAssignments", input.resource.tenant], null)
	not is_null(tenant_association)
	roles_path = sprintf("/%s/roleAssignments/%s", [input.user.key, input.resource.tenant])
	scoped_users_obj := json.patch(data.users, [{"op": "replace", "path": roles_path, "value": rebac_roles}])
	rbac.allow with data.users as scoped_users_obj
}
