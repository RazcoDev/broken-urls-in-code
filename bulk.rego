package permit.bulk

import data.permit.root

default allow := []

allow := results {
	checks = input.checks
	results := [result |
		check := checks[_]
		result := root with input as check
	]
}
