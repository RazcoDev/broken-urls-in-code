package permit.rbac

import future.keywords

# Santizied query
input_query := {
	"action": input.action,
	"user": {"key": input.user.key},
	"resource": {
		#			"key": input.resource.key,
		"type": input.resource.type,
		"tenant": input.resource.tenant,
	},
}

# By default, deny requests.
default allow := false

# Allow the action if the user is granted permission to perform the action.
allow {
	count(matching_grants) > 0
}

matching_grants[grant] {
	# Find grants for the user.
	some grant in grants

	# Check if the grant permits the action.
	input_query.action == grant
}

tenant := tenant_key {
	input_query.resource.tenant != null
	tenant_key := input_query.resource.tenant
}

#tenant := tenant_key {
#	q.resource.tenant == null
#	q.resource.key != null
#	q.resource.type != null
#	data.resources[q.resource.type]
#	tenant_key := data.resources[q.resource.type][q.resource.key].tenant
#}

user_roles[role_key] {
	some role_key in data.users[input_query.user.key].roleAssignments[tenant]
}

default roles_resource := "__tenant"

roles_resource := data.roles_resource

grants[grant] {
	some role_key in user_roles
	some grant in data.role_permissions[roles_resource][role_key].grants[input_query.resource.type]
}

allowing_roles[role_key] {
	some role_key in user_roles
	input.action in data.role_permissions[roles_resource][role_key].grants[input_query.resource.type]
}
