import 'dart:math';

import 'package:nano_mock/nano_mock.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

void main() {
  group("NanoVar", () {
    group("set value", () {
      test("can subscribe and get new values when called", () {
        // Generate random values.
        final random = Random();
        final oldValue = random.nextInt(100);
        final newValue = random.nextInt(100);

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the generated random values.
        final verify = fakeSubscriber.whenVoid([oldValue, newValue]);

        // Subscribe to the readable.
        nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Verify onChange has not been called.
        verify.neverCalled();

        // Call _change to trigger a change.
        nanoVar.value = newValue;

        // Verify the value getter returns the new value.
        expect(
          nanoVar.value,
          equals(newValue),
        );

        // Verify onChange has been called.
        verify.called(1);
      });
    });
  });
}
