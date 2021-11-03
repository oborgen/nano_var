# Flutter NanoVar

[![Pub](https://img.shields.io/pub/v/flutter_nano_var.svg?label=flutter_nano_var)](https://pub.dev/packages/flutter_nano_var)
[![Build](https://github.com/oborgen/nano_var/actions/workflows/build.yaml/badge.svg)](https://github.com/oborgen/nano_var/actions)
[![codecov](https://codecov.io/gh/oborgen/nano_var/branch/master/graph/badge.svg?token=M8RFX21Y49)](https://codecov.io/gh/oborgen/nano_var)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A lightweight state management library independent from any dependency
injection methods.

# Usage

### Basic usage

Create a NanoVar instance with a given initial value:

```dart
final counter = NanoVar(0);
```

A reference to the instance need to somehow be stored in a State so the value
will not be lost if the widget tree rebuilds.
However, the method to how this is done is up to you.

Create a NanoObs widget, which can be used to read values of NanoVar instances
and make sure the widget is rebuilt when any change occurs:

```dart
final widget = NanoObs(
  builder: (context, watch) => Text(watch(counter).toString()),
);
```

Assign a new value to the NanoVar:

```dart
counter.value = 1;
```

The widget declared above is now rebuilt.

Notice that as assigning new values trigger rebuilds, it is not possible to
assign values when building widgets.
However, it is possible to assign values from anywhere else, such as in button
callbacks.

Alternatively, you can use NanoObsWidget instead of StatelessWidget to watch
NanoVar instances:

```dart
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

### Limit to read-only

NanoVar instances can be casted to the type NanoRead, which contains the same
functionality for accessing values as NanoVar yet cannot be altered:

```dart
final NanoRead<int> readOnlyCounter = counter;

// This line will cause a compilation error.
readOnlyCounter.value = 1;
```

### Functional features

It is possible to modify the behavior of NanoVar instances as they can behave
like functors, applicative functors and monads.

#### Functor

Call `map` on an existing NanoVar instance with a function that can transform
any value held by the NanoVar instance to another value:

```dart
final stringCounter = counter.map((int value) {
    return value.toString();
});
```

The returned NanoRead instance `stringCounter` is updated whenever a change is
made to `counter` and `stringCounter` can be used in the same way as `counter`
for the purpose of retrieving values.
For instance, `stringCounter` can be used in a Widget:

```dart
final widget = NanoObs(
  builder: (context, watch) => Text(watch(stringCounter)),
);
```

#### Applicative functor

Call `liftA2` on an existing NanoVar instance with another NanoVar instance and
a function that can transform any value pair held by the NanoVar instances to a
third value:

```dart
final doubleCounter = NanoVar(0.0);

final stringCounter = counter.liftA2((int firstValue, double secondValue) {
    return (firstValue + secondValue).toString();
}, doubleCounter);
```

The returned NanoRead instance `stringCounter` is updated whenever a change is
made to `counter` or `doubleCounter`.

#### Monad

Call `bind` on an existing NanoVar instance with a function that can transform
any value held by the NanoVar instance to another NanoVar instance:

```dart
final stringCounter = counter.bind((int value) {
    return NanoVar(value.toString());
});
```

The returned NanoRead instance `stringCounter` is updated whenever a change is
made to `counter` or the NanoVar instance most recently returned by the
callback provided to `bind`.

### Future observing

Suppose this asynchronous function exists:

```dart
Future<DetailsModel> loadDetails(int id) async {
    return await callEndpoint("/details/$id");
}
```

Call `loadDetails` and then call `nanoRead` on the returned Future instance to
get a NanoRead instance that updates whenever the Future instance is completed:

```dart
final futureNanoRead = loadDetails(1).nanoRead;

void getStatus(status) {
    return status.status(
        uncompleted: () {
            return "futureNanoRead has not yet completed";
        },
        success: (value) {
            return "futureNanoRead has completed with the value $value";
        },
        fail: (error, stackTrace) {
            return "futureNanoRead has completed with the error $error " +
                "and the stack trace $stackTrace";
        },
    );
}

// Displays "futureNanoRead has not yet completed" and eventually displays
// "futureNanoRead has completed with the value..." if loadCount() succeeds or
// "futureNanoRead has completed with the error..." if loadCount() fails.
final widget = NanoObs(
  builder: (context, watch) => Text(getStatus(watch(futureNanoRead))),
);
```

A possible use case is to combine this feature with `bind` so that
`loadDetails` can be called each time `counter` is changed and the current
loading status for the most recent value of `counter` can be managed using a
NanoRead instance:

```dart
final detailsStatus = counter.bind((int value) {
    return loadDetails(value).nanoRead;
});
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
