package permit.root

import data.permit.rbac
import data.permit.abac

default allow := false

allow {
	rbac.allow
}

allow {
	abac.allow
}
