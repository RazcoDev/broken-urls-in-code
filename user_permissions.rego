package permit.user_permissions


import future.keywords.in

user := sprintf("user:%s", [input.user.key])

user_assignments := data.role_assignments[user]

__input_tenants := object.get(input, "tenants", null)

__input_resources := object.get(input, "resources", null)

_input_resources := results {
	is_null(__input_resources)
	is_null(__input_tenants)
	results := null
} else {
	not is_null(__input_resources)
	is_null(__input_tenants)
	results := __input_resources
} else {
	is_null(__input_resources)
	not is_null(__input_tenants)
	results := __input_tenants
} else {
	results := __input_resources
}

_input_resource_types := object.get(input, "resource_types", null)

split_resource_role_to_parts(resource_role) := parts_details {
	parts := split(resource_role, "#")
	count(parts) == 2
	resource := parts[0]
	role := parts[1]
	parts_details := {
		"resource": split_resource_to_parts(resource),
		"role": role,
	}
}

split_resource_to_parts(resource) := parts_details {
	parts := split(resource, ":")
	count(parts) == 2
	resource_type := parts[0]
	resource_instance := parts[1]
	fully_qualified_key := resource
	parts_details := {
		"fully_qualified_key": fully_qualified_key,
		"resource_type": resource_type,
		"resource_instance": resource_instance,
	}
} else {
	resource_type := "__tenant"
	resource_instance := resource
	fully_qualified_key := sprintf("%s:%s", [resource_type, resource_instance])
	parts_details := {
		"fully_qualified_key": fully_qualified_key,
		"resource_type": resource_type,
		"resource_instance": resource_instance,
	}
}

is_filtered_resource_type(resource) {
	is_array(_input_resource_types)
	resource.resource_type in _input_resource_types
} else {
	not is_array(_input_resource_types)
}

is_filtered_resource(resource) {
	is_array(_input_resources)
	is_filtered_resource_type(resource)
	resource.fully_qualified_key in _input_resources
} else {
	not is_array(_input_resources)
	is_filtered_resource_type(resource)
}

build_permissions_object(resource_object_key, resource_type, resource_key, resource_attributes, resource_permissions) := {
    sprintf("%s:%s",[resource_type,resource_key]): {
        resource_object_key: {
            "key": resource_key,
            "type": resource_type,
            "attributes": resource_attributes,
        },
        "permissions": resource_permissions,
    }
}

roles_permissions(role_assignments, resource_details) := {sprintf("%s:%s", [resource, permission]) |
	# iterate role assignments
	role := role_assignments[_]

	# extract role permission grants
	role_permissions_map := data.role_permissions[resource_details.resource_type][role].grants

	# iterate role permissions grants on each resource
	resource_permissions := role_permissions_map[resource]

	# extract permission grants
	permission := resource_permissions[_]
}

default __rebac_roles := {}



default permissions := {}

permissions := result {
	result := object.union_n([
		rbac_permissions,
		rebac_permissions,
	])
}

default rbac_permissions := {}

rbac_permissions := object.union_n([v | v := _rbac_permissions[_]])

default rebac_permissions := {}

rebac_permissions := object.union_n([v | v := _rebac_permissions[_]])

_rbac_permissions[object_permissions] {
	some assigned_object, _ in user_assignments
	startswith(assigned_object, "__tenant:")
	object_permissions := __rbac_permissions[assigned_object]
}

__rbac_permissions[assigned_object] := build_permissions_object(
	"tenant",
	"__tenant",
	tenant_key,
	object.get(tenant_obj, "attributes", {}),
	permissions,
) {
	tenant_details := split_resource_to_parts(assigned_object)
	tenant_key := tenant_details.resource_instance
	is_filtered_resource(tenant_details)
	tenant_obj := data.tenants[tenant_key]
	role_assignments := user_assignments[assigned_object]

	# iterate role assignments
	permissions := roles_permissions(role_assignments, tenant_details)
}

_rebac_permissions[resource] := build_permissions_object(
	"resource",
	resource_details.resource_type,
	resource_details.resource_instance,
	object.get(resource_obj, "attributes", {}),
	permissions,
) {
	rebac_all_roles := __rebac_roles
	some resource, roles in rebac_all_roles
	resource_obj := object.get(data.resource_instances, resource, {})
	resource_details := split_resource_to_parts(resource)
	is_filtered_resource(resource_details)
	stripped_roles := [stripped_role |
		role := roles[_]
		stripped_role := split_resource_role_to_parts(role).role
	]

	permissions := roles_permissions(stripped_roles, resource_details)
}
