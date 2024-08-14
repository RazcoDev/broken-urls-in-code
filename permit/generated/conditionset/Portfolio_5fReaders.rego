package permit.generated.conditionset

import future.keywords.in

import data.permit.generated.abac.utils.attributes

default userset_Portfolio_5fReaders = false

userset_Portfolio_5fReaders {
	userset_Portfolio_5fReaders_any_of_0
}

default userset_Portfolio_5fReaders_any_of_0 = false

userset_Portfolio_5fReaders_any_of_0 {
	attributes.resource.uid in attributes.user.readablePortfolios
}

userset_Portfolio_5fReaders_any_of_0 {
	attributes.resource.uid in attributes.user.writablePortfolios
}
