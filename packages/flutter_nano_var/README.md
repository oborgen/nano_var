# Flutter NanoVar

[![Pub](https://img.shields.io/pub/v/nano_var.svg)](https://pub.dev/packages/nano_var)
![Build](https://github.com/oborgen/nano_var/actions/workflows/build.yaml/badge.svg)
[![codecov](https://codecov.io/gh/oborgen/nano_var/branch/master/graph/badge.svg?token=M8RFX21Y49)](https://codecov.io/gh/oborgen/nano_var)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A lightweight state management library independent from any dependency
injection methods.

# Usage

Create a NanoVar instance with a given initial value:

```
final counter = NanoVar(0);
```

A reference to the instance need to somehow be stored in a State so the value
will not be lost if the widget tree rebuilds.
However, the method to how this is done is up to you.

Create a NanoObs widget, which can be used to read values of NanoVar instances
and make sure the widget is rebuilt when any change occurs:

```
final widget = NanoObs(
  builder: (context, watch) => Text(watch(counter).toString()),
);
```

Assign a new value to the NanoVar:

```
counter.value = 1;
```

The widget declared above is now rebuilt.

Notice that as assigning new values trigger rebuilds, it is not possible to
assign values when building widgets.
However, it is possible to assign values from anywhere else, such as in button
callbacks.

Alternatively, you can use NanoObsWidget instead of StatelessWidget to watch
NanoVar instances:

```
class NanoReadText extends NanoObsWidget {
  final NanoRead<String> label;

  const NanoReadText({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(context, watch) {
    return Text(watch(label));
  }
}
```
