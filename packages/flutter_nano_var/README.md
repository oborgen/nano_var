# Flutter NanoVar

[![Pub](https://img.shields.io/pub/v/flutter_nano_var.svg?label=flutter_nano_var)](https://pub.dev/packages/flutter_nano_var)
[![Build](https://github.com/oborgen/nano_var/actions/workflows/build.yaml/badge.svg)](https://github.com/oborgen/nano_var/actions)
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

## Motivation

The developers behind NanoVar needed a state management library that fulfilled
the following points:

* The library requires a minimal amount of boilerplate to be usable.
* Creation and destruction of state is controlled by the widget tree, so if a
user for instance leaves a page, the state associated with that page is
destroyed.

No existing state management library could be found that fulfilled these points
to a satisfying degree.
Therefore, NanoVar was created. 
The library is independent of any dependency injection method on purpose so
the method best suited for any individual case can be used to provide
dependency injection.
This property is used to fulfill the second point.
