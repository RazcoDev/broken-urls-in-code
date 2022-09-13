package permit.abac

import data.permit.generated.conditionset.rules

default allow := false

allow {
    any_allowed := rules[_]
    any_allowed
}
