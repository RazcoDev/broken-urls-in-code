package permit.generated.conditionset

import future.keywords.in

import data.permit.generated.abac.utils.attributes

default userset__5f_5fautogen_5fowner = false

userset__5f_5fautogen_5fowner {
	"owner" in attributes.user.roles
}
