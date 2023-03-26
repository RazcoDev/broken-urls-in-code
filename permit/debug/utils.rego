package permit.debug.utils

__slice_arr(arr) = sliced_arr {
	is_array(arr)
	count(arr) > 10
	sliced_arr = array.slice(arr, 0, 10)
	sliced_arr = array.concat(sliced_arr, ["..."])
} else = sliced_arr {
	is_array(arr)
	sliced_arr = arr
} else = [] {
	true
}

__suffix_prefix(arr) = "'" {
	is_array(arr)
	count(arr) > 0
} else = "" {
	true
}

format_array(set_or_arr) = repr {
	arr := to_array(set_or_arr)
	sliced_arr := array.slice(arr, 0, 10)
	suffix_prefix = __suffix_prefix(arr)
	repr := sprintf("[%s%s%s]", [suffix_prefix, concat("', '", __slice_arr(arr)), suffix_prefix])
}

to_array(v) = arr {
	is_set(v)
	arr := [value | value := v[_]]
}

to_array(v) = v {
	is_array(v)
}
