package permit.rbac

import future.keywords

# Santizied query
q := {
	"action": input.action,
    "user": {
      "key": input.user.key,
    },
    "resource": {
#      "key": input.resource.key,
      "type": input.resource.type,
      "tenant": input.resource.tenant
    }
}

# By default, deny requests.
default allow := false

# Allow the action if the user is granted permission to perform the action.
allow {
  # Find grants for the user.
  some grant in grants

  # Check if the grant permits the action.
  q.action == grant
}

tenant := tenant_key {
	q.resource.tenant != null
	tenant_key := q.resource.tenant
}

#tenant := tenant_key {
#	q.resource.tenant == null
#	q.resource.key != null
#	q.resource.type != null
#	data.resources[q.resource.type]
#	tenant_key := data.resources[q.resource.type][q.resource.key].tenant
#}

grants[grant] {
  some roleKey in data.users[q.user.key].roleAssignments[tenant]
  some grant in data.roles[roleKey].grants[q.resource.type]
}
