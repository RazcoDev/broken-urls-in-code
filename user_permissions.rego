package permit.user_permissions

import data.permit.utils.rebac as rebac_utils
import future.keywords.in

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
	some assigned_object, _ in rebac_utils.user_assignments
	startswith(assigned_object, "__tenant:")
	object_permissions := __rbac_permissions[assigned_object]
}

__rbac_permissions[assigned_object] := rebac_utils.build_permissions_object(
	"tenant",
	"__tenant",
	tenant_key,
	object.get(tenant_obj, "attributes", {}),
	permissions,
) {
	tenant_details := rebac_utils.split_resource_to_parts(assigned_object)
	tenant_key := tenant_details.resource_instance
	rebac_utils.is_filtered_resource(tenant_details)
	tenant_obj := data.tenants[tenant_key]
	role_assignments := rebac_utils.user_assignments[assigned_object]

	# iterate role assignments
	permissions := rebac_utils.roles_permissions(role_assignments, tenant_details)
}

_rebac_permissions[resource] := rebac_utils.build_permissions_object(
	"resource",
	resource_details.resource_type,
	resource_details.resource_instance,
	object.get(resource_obj, "attributes", {}),
	permissions,
) {
	rebac_all_roles := __rebac_roles
	some resource, roles in rebac_all_roles
	resource_obj := object.get(data.resource_instances, resource, {})
	resource_details := rebac_utils.split_resource_to_parts(resource)
	rebac_utils.is_filtered_resource(resource_details)
	stripped_roles := [stripped_role |
		role := roles[_]
		stripped_role := rebac_utils.split_resource_role_to_parts(role).role
	]

	permissions := rebac_utils.roles_permissions(stripped_roles, resource_details)
}
