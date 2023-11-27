package permit.any_tenant

import future.keywords.in
import data.permit.root

default is_synced_user := false

is_synced_user {
    data.users[input.user.key]
}

default _associated_tenants := {}

_associated_tenants[tenant_key] := tenant {
    is_synced_user
    user_assignments := data.role_assignments[sprintf("user:%s", [input.user.key])]
    some assigned_object,_ in user_assignments
    startswith(assigned_object, "__tenant:")
    tenant_key := trim_left(assigned_object, "__tenant:")
    tenant := data.tenants[tenant_key]
}

_associated_tenants[tenant_key] := tenant {
    not is_synced_user
    some tenant_key, tenant in data.tenants
}

default allowed_tenants := []

allowed_tenants := results {
	results := [wrapped_result |
		tenant := _associated_tenants[tenant_key]
		result := root with input.resource.tenant as tenant_key
		result.allow == true
		allowed_tenant = object.union(
			tenant,
			{"key": tenant_key},
		)

		wrapped_result := object.union(result, {"tenant": allowed_tenant})
	]
}
