class_name GenUtils
extends Reference
# A collection of static general utility functions which may be needed by many classes


static func connect_signal_assert_ok(origin: Object, sig: String, target: Object, meth: String) -> void:
	var err := origin.connect(sig, target, meth)
	assert(err == OK)

