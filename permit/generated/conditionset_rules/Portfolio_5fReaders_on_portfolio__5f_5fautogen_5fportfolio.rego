package permit.generated.conditionset.rules

import future.keywords.in

import data.permit.generated.abac.utils.attributes
import data.permit.generated.abac.utils.condition_set_permissions
import data.permit.generated.conditionset

default Portfolio_5f5fReaders_5fon_5fportfolio_5f_5f5f_5f5fautogen_5f5fportfolio = false

Portfolio_5f5fReaders_5fon_5fportfolio_5f_5f5f_5f5fautogen_5f5fportfolio {
	conditionset.userset_Portfolio_5fReaders
	conditionset.resourceset__5f_5fautogen_5fportfolio
	input.action in condition_set_permissions.Portfolio_Readers.__autogen_portfolio[input.resource.type]
}
