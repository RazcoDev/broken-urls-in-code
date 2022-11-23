package permit.policies

import data.permit.rbac
import data.permit.abac

default allow := false

allow {
	rbac.allow
}

__allow_sources["rbac"] {
	rbac.allow
}

allow {
	abac.allow
}

__allow_sources["abac"] {
	abac.allow
}

default __debug_input := null
__debug_input = {
	"action": input.action,
	"user": input.user,
	"resource": input.resource,
}

debug := {
	"allow_source": __allow_sources,
	"rbac": rbac.debug,
	"abac": abac.debug,
	"input": __debug_input,
}
