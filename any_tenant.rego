package permit.any_tenant

import data.permit.root

default allowed_tenants := []

allowed_tenants := results {
	results := [wrapped_result |
		tenant := data.tenants[tenant_key]
		result := root with input.resource.tenant as tenant_key
		result.allow == true
		allowed_tenant = object.union(
			tenant,
			{"key": tenant_key},
		)

		wrapped_result := object.union(result, {"tenant": allowed_tenant})
	]
}
