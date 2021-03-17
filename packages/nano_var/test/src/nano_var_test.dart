import 'package:nano_mock/nano_mock.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

import 'utils/unique_random.dart';

void main() {
  group("NanoVar", () {
    group("set value", () {
      test("can subscribe and get new values when called", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue = random.next();

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
