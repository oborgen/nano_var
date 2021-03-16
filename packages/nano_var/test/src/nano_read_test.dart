import 'dart:math';

import 'package:nano_mock/nano_mock.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

class _NanoRead extends NanoRead<int> {
  _NanoRead(int initialValue) : super(initialValue);

  void _change(int newValue) {
    change(newValue);
  }

  void Function() _subscribe(NanoMock<void> callback) {
    return subscribe((oldValue, newValue) => callback([oldValue, newValue]));
  }
}

void main() {
  group("NanoRead", () {
    group("get value", () {
      test("can get the initial value", () {
        // Generate a random value.
        final random = Random();
        final initialValue = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(initialValue);

        // Verify the value getter returns the initial value.
        expect(
          nanoRead.value,
          equals(initialValue),
        );
      });

      test("is changed when a change is triggered", () {
        // Generate a random value.
        final random = Random();
        final oldValue = random.nextInt(100);
        final newValue = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(oldValue);

        // Call _change to trigger a change.
        nanoRead._change(newValue);

        // Verify the value getter returns the new value.
        expect(
          nanoRead.value,
          equals(newValue),
        );
      });
    });

    group("subscribe", () {
      test("can subscribe and get new values when it's changed", () {
        // Generate random values.
        final random = Random();
        final oldValue = random.nextInt(100);
        final newValue = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(oldValue);

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the generated random values.
        final verify = fakeSubscriber.whenVoid([oldValue, newValue]);

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber);

        // Validate that the number of subscribers is one.
        expect(
          nanoRead.subscribersCount,
          equals(1),
        );

        // Verify fakeSubscriber has not been called.
        verify.neverCalled();

        // Call _change to trigger a change.
        nanoRead._change(newValue);

        // Verify fakeSubscriber has been called once.
        verify.called(1);
      });

      test(
          "doesn't call subscribers when it's changed but the new value is " +
              "equal to the old value", () {
        // Generate random values.
        final random = Random();
        final value = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(value);

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber);

        // Validate that the number of subscribers is one.
        expect(
          nanoRead.subscribersCount,
          equals(1),
        );

        // Call _change to trigger a change.
        nanoRead._change(value);
      });

      test("can unsubscribe", () {
        // Generate random values.
        final random = Random();
        final oldValue = random.nextInt(100);
        final newValue1 = random.nextInt(100);
        final newValue2 = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(oldValue);

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the two first generated random values.
        final verify = fakeSubscriber.whenVoid([oldValue, newValue1]);

        // Subscribe to the nanoRead.
        final unsubscribe = nanoRead._subscribe(fakeSubscriber);

        // Validate that the number of subscribers is one.
        expect(
          nanoRead.subscribersCount,
          equals(1),
        );

        // Call _change to trigger a change.
        nanoRead._change(newValue1);

        // Verify fakeSubscriber has been called once.
        verify.called(1);

        // Call unsubscribe.
        unsubscribe();

        // Validate that the number of subscribers is zero.
        expect(
          nanoRead.subscribersCount,
          equals(0),
        );

        // Call _change to trigger another change.
        nanoRead._change(newValue2);

        // Verify fakeSubscriber still has been called once.
        verify.called(1);
      });

      test("can have two subscriptions", () {
        // Generate random values.
        final random = Random();
        final oldValue = random.nextInt(100);
        final newValue = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(oldValue);

        // Create two mocks.
        final fakeSubscriber1 = NanoMock<void>();
        final fakeSubscriber2 = NanoMock<void>();

        // Set up the mocks to accept the generated random values.
        final verify1 = fakeSubscriber1.whenVoid([oldValue, newValue]);
        final verify2 = fakeSubscriber2.whenVoid([oldValue, newValue]);

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber1);
        nanoRead._subscribe(fakeSubscriber2);

        // Validate that the number of subscribers is two.
        expect(
          nanoRead.subscribersCount,
          equals(2),
        );

        // Verify both mocks have not been called.
        verify1.neverCalled();
        verify2.neverCalled();

        // Call _change to trigger a change.
        nanoRead._change(newValue);

        // Verify both mocks have been called once.
        verify1.called(1);
        verify2.called(1);
      });

      test("can unsubscribe on one of them", () {
        // Generate random values.
        final random = Random();
        final oldValue = random.nextInt(100);
        final newValue1 = random.nextInt(100);
        final newValue2 = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(oldValue);

        // Create two mocks.
        final fakeSubscriber1 = NanoMock<void>();
        final fakeSubscriber2 = NanoMock<void>();

        // Set up the mocks to accept the generated random values.
        final verify1 = fakeSubscriber1.whenVoid([oldValue, newValue1]);
        final verify2 = fakeSubscriber2.whenVoid([oldValue, newValue1]);
        final verify3 = fakeSubscriber1.whenVoid([newValue1, newValue2]);

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber1);
        final unsubscribe = nanoRead._subscribe(fakeSubscriber2);

        // Validate that the number of subscribers is two.
        expect(
          nanoRead.subscribersCount,
          equals(2),
        );

        // Verify both mocks have not been called.
        verify1.neverCalled();
        verify2.neverCalled();
        verify3.neverCalled();

        // Call _change to trigger a change.
        nanoRead._change(newValue1);

        // Verify both mocks has been called.
        verify1.called(1);
        verify2.called(1);
        verify3.neverCalled();

        // Call unsubscribe to unsubscribe the second mock.
        unsubscribe();

        // Validate that the number of subscribers is one.
        expect(
          nanoRead.subscribersCount,
          equals(1),
        );

        // Call _change to trigger another change.
        nanoRead._change(newValue2);

        // Verify the first mock has been called.
        verify3.called(1);
      });
    });
  });
}
