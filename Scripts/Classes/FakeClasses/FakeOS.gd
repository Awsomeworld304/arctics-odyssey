extends Object
class_name FakeOS

func _unhandled_method(_name, _args):
	push_error("Access to OS is forbidden.");
	return null;
