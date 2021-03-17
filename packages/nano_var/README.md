# NanoVar

[![Pub](https://img.shields.io/pub/v/nano_var.svg)](https://pub.dev/packages/nano_var)
![Build](https://github.com/oborgen/nano_var/actions/workflows/build.yaml/badge.svg)
[![codecov](https://codecov.io/gh/oborgen/nano_var/branch/master/graph/badge.svg?token=M8RFX21Y49)](https://codecov.io/gh/oborgen/nano_var)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

A variable that can notify subscribers when changes occur.

## Usage

Create a NanoVar instance with a given initial value:

```
final counter = NanoVar(0);
```

Subscribe to changes made to the value of the NanoVar instance:

```
final unsubscribe = counter.subscribe((oldValue, newValue) {
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
