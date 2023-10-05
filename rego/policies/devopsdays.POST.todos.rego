package devopsdays.POST.todos

import future.keywords.in
import data.devopsdays.common.is_member_of

default allowed = false

allowed {
  allowedGroups := { "editor", "admin" }
  some group in allowedGroups
  is_member_of(input.user, group)
}
