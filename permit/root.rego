package permit.policies

import data.permit.abac
import data.permit.rbac
import data.permit.rebac

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

allow {
	rebac.allow
}

__allow_sources["rebac"] {
	rebac.allow
}
