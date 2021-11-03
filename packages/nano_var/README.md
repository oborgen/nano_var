# NanoVar

[![Pub](https://img.shields.io/pub/v/nano_var.svg?label=nano_var)](https://pub.dev/packages/nano_var)
[![Build](https://github.com/oborgen/nano_var/actions/workflows/build.yaml/badge.svg)](https://github.com/oborgen/nano_var/actions)
[![codecov](https://codecov.io/gh/oborgen/nano_var/branch/master/graph/badge.svg?token=M8RFX21Y49)](https://codecov.io/gh/oborgen/nano_var)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A variable that can be subscribed to so the subscribers get notified when
changes occur.

## Usage

### Basic usage

Create a NanoVar instance with a given initial value:

```
final counter = NanoVar(0);
```

Subscribe to changes made to the value of the NanoVar instance:

```
final unsubscribe = counter.subscribe((int oldValue, int newValue) {
    print("The counter changed from $oldValue to $newValue");
});
```

Assign a new value to the NanoVar instance:

```
counter.value = 1;
```

The callback declared above is now called with the assigned value and the
previous value.

Call `unsubscribe` to make the NanoVar instance stop calling the callback:

```
unsubscribe();
```

### Limit to read-only

NanoVar instances can be casted to the type NanoRead, which contains the same
functionality for accessing values as NanoVar yet cannot be altered:

```
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

```
final stringCounter = counter.map((int value) {
    return value.toString();
});
```

The returned NanoRead instance `stringCounter` is updated whenever a change is
made to `counter` and `stringCounter` can be used in the same way as `counter`
for the purpose of retrieving values.
For instance, `stringCounter` can be subscribed to:

```
final unsubscribe = counter.subscribe((String oldValue, String newValue) {
    print("The counter changed from $oldValue to $newValue");
});
```

#### Applicative functor

Call `liftA2` on an existing NanoVar instance with another NanoVar instance and
a function that can transform any value pair held by the NanoVar instances to a
third value:

```
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

```
final stringCounter = counter.bind((int value) {
    return NanoVar(value.toString());
});
```

The returned NanoRead instance `stringCounter` is updated whenever a change is
made to `counter` or the NanoVar instance most recently returned by the
callback provided to `bind`.

### Future observing

Suppose this asynchronous function exists:

```
Future<DetailsModel> loadDetails(int id) async {
    return await callEndpoint("/details/$id");
}
```

Call `loadDetails` and then call `nanoRead` on the returned Future instance to
get a NanoRead instance that updates whenever the Future instance is completed:

```
final futureNanoRead = loadDetails(1).nanoRead;

void printStatus(status) {
    return status.status(
        uncompleted: () {
            print("futureNanoRead has not yet completed");
        },
        success: (value) {
            print("futureNanoRead has completed with the value $value");
        },
        fail: (error, stackTrace) {
            print("futureNanoRead has completed with the error $error " +
                "and the stack trace $stackTrace");
        },
    );
}

// Prints "futureNanoRead has not yet completed".
printStatus(futureNanoRead.value);

// Eventually prints "futureNanoRead has completed with the value..."
// if loadCount() succeeds or "futureNanoRead has completed with the error..."
// if loadCount() fails.
final unsubscribe = futureNanoRead.subscribe((oldStatus, newStatus) {
    printStatus(newStatus);
});
```

A possible use case is to combine this feature with `bind` so that
`loadDetails` can be called each time `counter` is changed and the current
loading status for the most recent value of `counter` can be managed using a
NanoRead instance:

```
final detailsStatus = counter.bind((int value) {
    return loadDetails(value).nanoRead;
});
```

## Motivation

This library was created to be used in
[Flutter NanoVar](https://pub.dev/packages/flutter_nano_var), which provides a
lightweight method of state management in Flutter.
However, NanoVar can be used on its own as well.
