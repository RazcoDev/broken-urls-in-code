package permit.user_permissions

import future.keywords.in

default permissions := []

__user := sprintf("user:%s", [input.user.key])

user_assignments := data.role_assignments[__user]

permissions := result {
	result := object.union_n([rbac_permissions])
}

is_filtered_tenant(tenant) {
	is_array(input.tenants)
	tenant in input.tenants
} else {
	input_tenants = object.get(input, "tenants", null)
	not is_array(input_tenants)
}

default rbac_permissions := set()

__rbac_permissions[tenant_permissions] {
	# iterate user assignments
	some assigned_object, role_assignments in user_assignments

	# filter for tenant roles
	startswith(assigned_object, "__tenant:")
	tenant_key := split(assigned_object, ":")[1]
	is_filtered_tenant(tenant_key)
	tenant_obj := data.tenants[tenant_key]

	# iterate role assignments
	permissions := {sprintf("%s:%s", [resource, permission]) |
		# iterate role assignments
		role := role_assignments[_]

		# extract role permission grants
		role_permissions_map := data.role_permissions.__tenant[role].grants

		# iterate role permissions grants on each resource
		resource_permissions := role_permissions_map[resource]

		# extract permission grants
		permission := resource_permissions[_]
	}

	tenant_permissions := {tenant_key: object.union(
		{"tenant": {
			"key": tenant_key,
			"attributes": tenant_obj.attributes,
		}},
		{"permissions": permissions},
	)}
}

rbac_permissions := object.union_n([v | v := __rbac_permissions[_]])
