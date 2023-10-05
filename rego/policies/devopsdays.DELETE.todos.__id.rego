package devopsdays.DELETE.todos.__id

import future.keywords.in
import data.devopsdays.common.is_member_of
import data.devopsdays.common.has_permission

default allowed = false

allowed {
  has_permission(input.user, "delete", input.resource.id)
}

allowed {
  is_member_of(input.user, "admin")
}
