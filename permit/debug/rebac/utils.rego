package permit.debug.rebac

import data.permit.debug.utils as debug_utils
import data.permit.rebac

activated := rebac.activated

# The purpose of those values is to forward rbac policy package values to the debug package
allow = rebac.allow

allowing_roles = [rebac.rebac_roles_debugger[role_key] | rebac.allowing_roles[role_key]]
