package permit.utils.rebac

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
