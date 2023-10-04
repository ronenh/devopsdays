package devopsdays.common

is_member_of(user, group) := x {
  x := ds.check_relation({
    "object": {
      "key": group,
      "type": "group"
    },
    "relation": {
      "name": "member",
      "object_type": "group"
    },
    "subject": {
      "key": user.key,
      "type": "user"
    }
  })
}

has_permission(user, permission, todo) := x {
  x := ds.check_permission({
	"subject": {"type": "user", "key": user.key},
	"permission": {"name": permission},
	"object": {"type": "todo", "key": todo}
  })
}
