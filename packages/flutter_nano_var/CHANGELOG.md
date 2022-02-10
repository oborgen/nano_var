# 1.1.1

* Added a check to _NanoObsWidgetState._onChange ensuring that State.mounted is
true before calling setState, which avoids an exception that would be thrown
otherwise.

# 1.1.0

* Added functional methods so NanoRead instances can behave as functors,
applicative functors and monads.
* Added future observing.
* Made certain documentation adjustments.

# 1.0.1

* Made the nano_var package description longer.

# 1.0.0

* Initial release.
