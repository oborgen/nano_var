import 'dart:math';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

import 'fakes/fake_subscriber.dart';
import 'nano_var_test.mocks.dart';

@GenerateMocks([
  FakeSubscriber,
])
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
        final fakeSubscriber = MockFakeSubscriber();

        // Set up the mock to accept the generated random values.
        when(fakeSubscriber.onChange(oldValue, newValue)).thenAnswer((_) {});

        // Subscribe to the readable.
        nanoVar.subscribe(fakeSubscriber.onChange);

        // Verify onChange has not been called.
        verifyNever(fakeSubscriber.onChange(oldValue, newValue));

        // Call _change to trigger a change.
        nanoVar.value = newValue;

        // Verify the value getter returns the new value.
        expect(
          nanoVar.value,
          equals(newValue),
        );

        // Verify onChange has been called.
        verify(fakeSubscriber.onChange(oldValue, newValue)).called(1);
      });
    });
  });
}
