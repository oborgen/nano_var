import 'package:nano_mock/nano_mock.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

import 'utils/unique_random.dart';

void main() {
  group("NanoVar", () {
    group("get value", () {
      test("can get the initial value", () {
        // Generate a random value.
        final random = UniqueRandom();
        final initialValue = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(initialValue);

        // Verify the value getter returns the initial value.
        expect(
          nanoVar.value,
          equals(initialValue),
        );
      });

      test("is changed when a change is triggered", () {
        // Generate a random value.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Assign to value to trigger a change.
        nanoVar.value = newValue;

        // Verify the value getter returns the new value.
        expect(
          nanoVar.value,
          equals(newValue),
        );
      });
    });

    group("subscribe", () {
      test("can subscribe and get new values when it's changed", () {
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

        // Subscribe to the NanoVar.
        nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one.
        expect(
          nanoVar.subscribersCount,
          equals(1),
        );

        // Verify fakeSubscriber has not been called.
        verify.neverCalled();

        // Assign to value to trigger a change.
        nanoVar.value = newValue;

        // Verify fakeSubscriber has been called once.
        verify.called(1);
      });

      test(
          "doesn't call subscribers when it's changed but the new value is " +
              "equal to the old value", () {
        // Generate a random value.
        final random = UniqueRandom();
        final value = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(value);

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Subscribe to the NanoVar.
        nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one.
        expect(
          nanoVar.subscribersCount,
          equals(1),
        );

        // Assign to value to trigger a change.
        nanoVar.value = value;
      });

      test("can unsubscribe", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the two first generated random values.
        final verify = fakeSubscriber.whenVoid([oldValue, newValue1]);

        // Subscribe to the NanoVar.
        final unsubscribe = nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one.
        expect(
          nanoVar.subscribersCount,
          equals(1),
        );

        // Assign to value to trigger a change.
        nanoVar.value = newValue1;

        // Verify fakeSubscriber has been called once.
        verify.called(1);

        // Call unsubscribe.
        unsubscribe();

        // Validate that the number of subscribers is zero.
        expect(
          nanoVar.subscribersCount,
          equals(0),
        );

        // Assign to value to trigger another change.
        nanoVar.value = newValue2;

        // Verify fakeSubscriber still has been called once.
        verify.called(1);
      });

      test("can have two subscriptions", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create two mocks.
        final fakeSubscriber1 = NanoMock<void>();
        final fakeSubscriber2 = NanoMock<void>();

        // Set up the mocks to accept the generated random values.
        final verify1 = fakeSubscriber1.whenVoid([oldValue, newValue]);
        final verify2 = fakeSubscriber2.whenVoid([oldValue, newValue]);

        // Subscribe to the NanoVar.
        nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber1([oldValue, newValue]),
        );
        nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber2([oldValue, newValue]),
        );

        // Validate that the number of subscribers is two.
        expect(
          nanoVar.subscribersCount,
          equals(2),
        );

        // Verify both mocks have not been called.
        verify1.neverCalled();
        verify2.neverCalled();

        // Assign to value to trigger another change.
        nanoVar.value = newValue;

        // Verify both mocks have been called once.
        verify1.called(1);
        verify2.called(1);
      });

      test("can unsubscribe on one of them", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create two mocks.
        final fakeSubscriber1 = NanoMock<void>();
        final fakeSubscriber2 = NanoMock<void>();

        // Set up the mocks to accept the generated random values.
        final verify1 = fakeSubscriber1.whenVoid([oldValue, newValue1]);
        final verify2 = fakeSubscriber2.whenVoid([oldValue, newValue1]);
        final verify3 = fakeSubscriber1.whenVoid([newValue1, newValue2]);

        // Subscribe to the nanoRead.
        nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber1([oldValue, newValue]),
        );
        final unsubscribe = nanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber2([oldValue, newValue]),
        );

        // Validate that the number of subscribers is two.
        expect(
          nanoVar.subscribersCount,
          equals(2),
        );

        // Verify both mocks have not been called.
        verify1.neverCalled();
        verify2.neverCalled();
        verify3.neverCalled();

        // Assign to value to trigger a change.
        nanoVar.value = newValue1;

        // Verify both mocks has been called.
        verify1.called(1);
        verify2.called(1);
        verify3.neverCalled();

        // Call unsubscribe to unsubscribe the second mock.
        unsubscribe();

        // Validate that the number of subscribers is one.
        expect(
          nanoVar.subscribersCount,
          equals(1),
        );

        // Assign to value to trigger another change.
        nanoVar.value = newValue2;

        // Verify the first mock has been called.
        verify3.called(1);
      });
    });
  });
}
