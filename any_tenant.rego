package permit.any_tenant

import data.permit.root
import future.keywords.in

default is_synced_user := false

is_synced_user {
	data.users[input.user.key]
}

_associated_tenants[tenant_key] := tenant {
	is_synced_user
	user_assignments := data.role_assignments[sprintf("user:%s", [input.user.key])]
	some assigned_object, _ in user_assignments
	startswith(assigned_object, "__tenant:")
	tenant_key := trim_left(assigned_object, "__tenant:")
	tenant := data.tenants[tenant_key]
}

_associated_tenants[tenant_key] := tenant {
	not is_synced_user
	some tenant_key, tenant in data.tenants
}

default using_optimized_policy := false

using_optimized_policy {
	input.context.optimized
}

allowed_tenants[allowed_tenant] {
	not using_optimized_policy
	some tenant_key
	tenant := _associated_tenants[tenant_key]
	result := root with input.resource.tenant as tenant_key
	result.allow == true
	tenant_info = object.union(
		tenant,
		{"key": tenant_key},
	)
	allowed_tenant := object.union(result, {"tenant": tenant_info})
}

# optimized version
allowed_tenants[allowed_tenant] {
	using_optimized_policy
	some tenant_key
	tenant := _associated_tenants[tenant_key]
	some role in data.users[input.user.key].roleAssignments[tenant_key]
	input.action in data.role_permissions.__tenant[role].grants[input.resource.type]

	result := {
		"__data_use_debugger": false,
		"__input_use_debugger": null,
		"allow": true,
		"allowing_sources": ["rbac"],
		"debugger_activated": false,
	}

	tenant_info = object.union(
		tenant,
		{"key": tenant_key},
	)

	allowed_tenant := object.union(result, {"tenant": tenant_info})
}
