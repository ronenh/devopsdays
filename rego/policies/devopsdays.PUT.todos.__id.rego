package devopsdays.PUT.todos.__id

import input.user
import input.resource
import future.keywords.in
import data.devopsdays.common.is_member_of
import data.devopsdays.common.has_permission

default allowed = false

allowed {
  has_permission(user, "edit", resource.id)
}

allowed {
  is_member_of(user, "evil_genius")
}
