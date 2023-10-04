package devopsdays.check_permission

# default to a closed system (deny by default)
default allowed = false

# resource context is expected in the following form:
# {
#   "permission": "permission name",
#   "object_type": "object type that carries the permission",
#   "object_key": "key of object instance with type of object_type"
# }
allowed {
  ds.check_permission({
    "object": {
      "key": input.resource.key,
      "type": input.resource.type
    },
    "permission": {
      "name": input.resource.permission
    },
    "subject": {
      "key": input.user.key,
      "type": "user"
    }
  })
}
