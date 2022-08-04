package permit.rbac

import future.keywords

# Santizied query
q := {
	"action": {
    	"id": input.actionId
    },
    "user": {
      "id": input.user.id,
      "authenticated": input.user.authenticated
    },
    "resource": {
#      "id": input.resource.id,
      "type": input.resource.type,
      "tenant": input.resource.tenant
    }
}

# # By default, deny requests.
default allow := false

 # Allow the action if the user is granted permission to perform the action.
allow  {
  # Find grants for the user.
  some grant in grants


  # Check if the grant permits the action.
  q.action.id == grant
}

tenant := tenant_id {
	q.resource.tenant != null
	tenant_id := q.resource.tenant
}

#tenant := tenant_id {
#	q.resource.tenant == null
#	q.resource.id != null
#	q.resource.type != null
#	data.resources[q.resource.type]
#	tenant_id := data.resources[q.resource.type][q.resource.id].tenant
#}

grants[grant] {
  some roleKey in data.users[q.user.id].roleAssignments[tenant]
  some grant in data.roles[roleKey].grants[q.resource.type]
}
