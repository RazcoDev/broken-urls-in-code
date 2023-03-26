package permit.utils

import future.keywords.in

# not undefined if object 'x' has a key 'k'
has_key(x, k) {
	_ := x[k]
}

# If a field 'k' relies in both 'a' and 'b' objects, pick its value from 'a'.
pick_first(k, a, b) = a[k] {
	has_key(a, k)
}

else = b[k] {
	true
}

# Merging objects a & b. If a field relies in both of them, pick it's value from a.
merge_objects(a, b) = c {
	ks := {k | some k; _ = a[k]} | {k | some k; _ = b[k]}
	c := {k: v | some k; ks[k]; v := pick_first(k, b, a)}
}

object_keys(obj) := result {
	result := [key | some key, value in obj]
}
