package permit.policies

import data.permit.abac
import data.permit.rbac

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
