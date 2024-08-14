package permit.api.role_assignments

import future.keywords.in

default page := 1

page := input.pagination.page {
	input.pagination.page > 0
}

default per_page := 30

per_page := input.pagination.per_page {
	input.pagination.per_page > 0
	input.pagination.per_page <= 100
}

is_filtered(value, filter) {
	is_null(filter)
} else {
	value == filter
}

resource_parts_tenant_filtered(resource_parts, filters) {
	# in case of tenant filter and a tenant resource, we need to check if the tenant matches
	not is_null(object.get(filters, "tenant", null))
	resource_parts.resource_type == "__tenant"
	resource_parts.resource_instance == filters.tenant
} else {
	# in case of a tenant filter and a resource instance, we need to check the tenant of the resource instance matches
	not is_null(object.get(filters, "tenant", null))
	resource_parts.resource_type != "__tenant"
	resources_tenants[resource_parts.fully_qualified_key] == filters.tenant
} else {
	# in case of no tenant filter, we don't need to check the tenant
	is_null(object.get(filters, "tenant", null))
}

tenant_filtered(tenant, filters) {
	is_filtered(tenant, object.get(filters, "tenant", null))
}

user_filtered(user, filters) {
	is_filtered(user, object.get(filters, "user", null))
}

role_filtered(role, filters) {
	is_filtered(role, object.get(filters, "role", null))
}

resource_filtered(resource, filters) {
	is_filtered(resource, object.get(filters, "resource", null))
}

format_resource(resource) := {
	"resource_type": _parts[0],
	"resource_instance": _parts[1],
	"fully_qualified_key": resource,
} {
	_parts = split(resource, ":")
	count(_parts) == 2
}

# a map between resource fully qualified key to a tenant
resources_tenants[resource] := data.resource_instances[resource].tenant

format_assignment(user, resource_parts, assignment) := result {
	resource_parts.resource_type == "__tenant"
	result := {
		"user": trim_prefix(user, "user:"),
		"role": assignment,
		"tenant": resource_parts.resource_instance,
	}
} else = result {
	not resource_parts.resource_type == "__tenant"
	result := {
		"user": trim_prefix(user, "user:"),
		"role": assignment,
		"resource_instance": resource_parts.fully_qualified_key,
		"tenant": resources_tenants[resource_parts.fully_qualified_key],
	}
}

resource_filtered_assignments[user] := assignments {
	# in case we have a resource instance filter, we can reduce iterations by filtering only
	# for the role assignments on the resource instance on the user given ( if given )
	not is_null(object.get(input.filters, "resource_instance", null))

	# verify the the tenant of the resource instance matches
	tenant_filtered(resources_tenants[input.filters.resource_instance], input.filters)

	# parse the resource instance
	resource_parts := format_resource(input.filters.resource_instance)

	# verify the resource type matches
	resource_filtered(resource_parts.resource_type, input.filters)
	some user, resources_assignments in data.role_assignments

	# extract only the relevant assignments for the resource instance given in the filter
	relevant_assignments := resources_assignments[input.filters.resource_instance]

	# format the assignments
	assignments := [
	format_assignment(user, resource_parts, assignment) |
		assignment := relevant_assignments[_]
		assignment != "tenant-association"
	]
}

resource_filtered_assignments[user] := assignments {
	# in case we don't have a resource instance filter we must iterate over all assignments of the user given ( if given )
	is_null(object.get(input.filters, "resource_instance", null))
	relevant_assignments := data.role_assignments[user]
	assignments := [
	# format the assignment
	format_assignment(user, resource_parts, assignment) |
		# iterate over all assignments of the user by resource instance
		resource_assignments := relevant_assignments[resource]

		# parse the resource
		resource_parts := format_resource(resource)

		# verify the tenant matches
		resource_parts_tenant_filtered(resource_parts, input.filters)

		# verify the resource type matches
		resource_filtered(resource_parts.resource_type, input.filters)

		# iterate over all the left assignments ( that passed all the above filter )
		assignment := resource_assignments[_]
		assignment != "tenant-association"
	]
}

default filtered_role_assignments := []

filtered_role_assignments := [
assignment |
	# iterate over all the role assignments of the user that matched the resource filters ( resource, tenant, resource instance )
	assignment := resource_filtered_assignments[user][_]

	# verify the role matches
	role_filtered(assignment.role, input.filters)
] {
	# in case we have a user filter, we can reduce iterations by filtering only for the filter given
	not is_null(object.get(input.filters, "user", null))

	# format it to have the user: prefix
	user := sprintf("user:%s", [input.filters.user])
}

filtered_role_assignments := [
assignment |
	# iterate over all users with role assignments
	_ := data.role_assignments[user]

	# iterate over all the role assignments of the user that matched the resource filters ( resource, tenant, resource instance )
	assignment := resource_filtered_assignments[user][_]

	# verify the role matches
	role_filtered(assignment.role, input.filters)
] {
	# in case we don't have a user filter, we must iterate over the role assignments of all users
	is_null(object.get(input.filters, "user", null))
}

start := (page - 1) * per_page

end := start + per_page

list_role_assignments := array.slice(sort(filtered_role_assignments), start, end)