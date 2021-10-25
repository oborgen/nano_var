import 'package:nano_mock/nano_mock.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

import 'utils/unique_random.dart';

void main() {
  group("ApplicativeNanoVar", () {
    group("get value", () {
      test("can get the initial value", () {
        // Generate a random value.
        final random = UniqueRandom();
        final initialValue1 = random.next();
        final initialValue2 = random.next();

        // Create a NanoVar.
        final nanoVar1 = NanoVar(initialValue1);

        // Create another NanoVar.
        final nanoVar2 = NanoVar(initialValue2);

        // Create a lifter.
        final lifter = NanoMock<int>();

        // Set up lifter to accept the initial values.
        final verify = lifter.when(
          initialValue1 + initialValue2,
          [initialValue1, initialValue2],
        );

        // Call liftA2 on the NanoVar instances.
        final applicativeNanoVar = nanoVar1.liftA2(
          (value1, value2) => lifter([value1, value2]),
          nanoVar2,
        );

        // Verify the value getter returns the mapped initial values.
        expect(
          applicativeNanoVar.value,
          equals(initialValue1 + initialValue2),
        );

        // Verify lifter has been called once.
        verify.called(1);
      });

      test("is changed when a change is triggered on either instance", () {
        // Generate a random value.
        final random = UniqueRandom();
        final oldValue1 = random.next();
        final oldValue2 = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();

        // Create a NanoVar.
        final nanoVar1 = NanoVar(oldValue1);

        // Create another NanoVar.
        final nanoVar2 = NanoVar(oldValue2);

        // Create a lifter.
        final lifter = NanoMock<int>();

        // Set up lifter to accept the old values.
        lifter.when(
          oldValue1 + oldValue2,
          [oldValue1, oldValue2],
        );

        // Set up lifter to accept the first new value and the second old value.
        final verify1 = lifter.when(
          newValue1 + oldValue2,
          [newValue1, oldValue2],
        );

        // Set up lifter to accept the new values.
        final verify2 = lifter.when(
          newValue1 + newValue2,
          [newValue1, newValue2],
        );

        // Call liftA2 on the NanoVar instances.
        final applicativeNanoVar = nanoVar1.liftA2(
          (value1, value2) => lifter([value1, value2]),
          nanoVar2,
        );

        // Assign to the first NanoVar's value to trigger a change.
        nanoVar1.value = newValue1;

        // Verify the value getter returns a new value.
        expect(
          applicativeNanoVar.value,
          equals(newValue1 + oldValue2),
        );

        // Verify lifter has been called once.
        verify1.called(1);

        // Assign to the second NanoVar's value to trigger a change.
        nanoVar2.value = newValue2;

        // Verify the value getter returns a new value.
        expect(
          applicativeNanoVar.value,
          equals(newValue1 + newValue2),
        );

        // Verify lifter has been called once.
        verify2.called(1);
      });
    });

    group("subscribe", () {
      test("can subscribe and get new values when either instance is changed",
          () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue1 = random.next();
        final oldValue2 = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();

        // Create a NanoVar.
        final nanoVar1 = NanoVar(oldValue1);

        // Create another NanoVar.
        final nanoVar2 = NanoVar(oldValue2);

        // Create a lifter.
        final lifter = NanoMock<int>();

        // Set up lifter to accept the old value.
        lifter.when(
          oldValue1 + oldValue2,
          [oldValue1, oldValue2],
        );

        // Set up lifter to accept the first new value and the second old value.
        final verifyLifter1 = lifter.when(
          newValue1 + oldValue2,
          [newValue1, oldValue2],
        );

        // Set up lifter to accept the new values.
        final verifyLifter2 = lifter.when(
          newValue1 + newValue2,
          [newValue1, newValue2],
        );

        // Call liftA2 on the NanoVar instances.
        final applicativeNanoVar = nanoVar1.liftA2(
          (value1, value2) => lifter([value1, value2]),
          nanoVar2,
        );

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the first value.
        final verifySubscriber1 = fakeSubscriber.whenVoid([
          oldValue1 + oldValue2,
          newValue1 + oldValue2,
        ]);

        // Set up the mock to accept the second value.
        final verifySubscriber2 = fakeSubscriber.whenVoid([
          newValue1 + oldValue2,
          newValue1 + newValue2,
        ]);

        // Subscribe to the ApplicativeNanoVar.
        applicativeNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one on the first NanoVar
        // instance.
        expect(
          nanoVar1.subscribersCount,
          equals(1),
        );

        // Validate that the number of subscribers is one on the second NanoVar
        // instance.
        expect(
          nanoVar2.subscribersCount,
          equals(1),
        );

        // Verify fakeSubscriber has not been called.
        verifySubscriber1.neverCalled();

        // Verify lifter has not been called.
        verifyLifter1.neverCalled();

        // Assign to the first NanoVar's value to trigger a change.
        nanoVar1.value = newValue1;

        // Verify fakeSubscriber has been called once.
        verifySubscriber1.called(1);

        // Verify lifter has been called once.
        verifyLifter1.called(1);

        // Verify fakeSubscriber has not been called.
        verifySubscriber2.neverCalled();

        // Verify lifter has not been called.
        verifyLifter2.neverCalled();

        // Assign to the second NanoVar's value to trigger a change.
        nanoVar2.value = newValue2;

        // Verify fakeSubscriber has been called twice.
        verifySubscriber2.called(1);

        // Verify lifter has been called twice.
        verifyLifter2.called(1);
      });

      test("can unsubscribe", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue1 = random.next();
        final oldValue2 = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();
        final newValue3 = random.next();
        final newValue4 = random.next();

        // Create a NanoVar.
        final nanoVar1 = NanoVar(oldValue1);

        // Create another NanoVar.
        final nanoVar2 = NanoVar(oldValue2);

        // Create a lifter.
        final lifter = NanoMock<int>();

        // Set up lifter to accept the old value.
        lifter.when(
          oldValue1 + oldValue2,
          [oldValue1, oldValue2],
        );

        // Set up lifter to accept the first new value and the second old value.
        final verifyLifter1 = lifter.when(
          newValue1 + oldValue2,
          [newValue1, oldValue2],
        );

        // Set up lifter to accept the new values.
        final verifyLifter2 = lifter.when(
          newValue1 + newValue2,
          [newValue1, newValue2],
        );

        // Call liftA2 on the NanoVar instances.
        final applicativeNanoVar = nanoVar1.liftA2(
          (value1, value2) => lifter([value1, value2]),
          nanoVar2,
        );

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the first value.
        final verifySubscriber1 = fakeSubscriber.whenVoid([
          oldValue1 + oldValue2,
          newValue1 + oldValue2,
        ]);

        // Set up the mock to accept the second value.
        final verifySubscriber2 = fakeSubscriber.whenVoid([
          newValue1 + oldValue2,
          newValue1 + newValue2,
        ]);

        // Subscribe to the ApplicativeNanoVar.
        final unsubscribe = applicativeNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one on the first NanoVar
        // instance.
        expect(
          nanoVar1.subscribersCount,
          equals(1),
        );

        // Validate that the number of subscribers is one on the second NanoVar
        // instance.
        expect(
          nanoVar2.subscribersCount,
          equals(1),
        );

        // Verify fakeSubscriber has not been called.
        verifySubscriber1.neverCalled();

        // Verify lifter has not been called.
        verifyLifter1.neverCalled();

        // Assign to the first NanoVar's value to trigger a change.
        nanoVar1.value = newValue1;

        // Verify fakeSubscriber has been called once.
        verifySubscriber1.called(1);

        // Verify lifter has been called once.
        verifyLifter1.called(1);

        // Verify fakeSubscriber has not been called.
        verifySubscriber2.neverCalled();

        // Verify lifter has not been called.
        verifyLifter2.neverCalled();

        // Assign to the second NanoVar's value to trigger a change.
        nanoVar2.value = newValue2;

        // Verify fakeSubscriber has been called twice.
        verifySubscriber2.called(1);

        // Verify lifter has been called twice.
        verifyLifter2.called(1);

        // Call unsubscribe.
        unsubscribe();

        // Validate that the number of subscribers is zero on the first NanoVar
        // instance.
        expect(
          nanoVar1.subscribersCount,
          equals(0),
        );

        // Validate that the number of subscribers is zero on the second NanoVar
        // instance.
        expect(
          nanoVar2.subscribersCount,
          equals(0),
        );

        // Assign to the first NanoVar's value to trigger another change.
        nanoVar1.value = newValue3;

        // Assign to the second NanoVar's value to trigger another change.
        nanoVar2.value = newValue4;

        // Verify fakeSubscriber still has been called twice.
        verifySubscriber1.called(1);
        verifySubscriber2.called(1);
      });

      test("can have two subscriptions", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue1 = random.next();
        final oldValue2 = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();

        // Create a NanoVar.
        final nanoVar1 = NanoVar(oldValue1);

        // Create another NanoVar.
        final nanoVar2 = NanoVar(oldValue2);

        // Create a lifter.
        final lifter = NanoMock<int>();

        // Set up lifter to accept the old value.
        lifter.when(
          oldValue1 + oldValue2,
          [oldValue1, oldValue2],
        );

        // Set up lifter to accept the first new value and the second old value.
        final verifyLifter1 = lifter.when(
          newValue1 + oldValue2,
          [newValue1, oldValue2],
        );

        // Set up lifter to accept the new values.
        final verifyLifter2 = lifter.when(
          newValue1 + newValue2,
          [newValue1, newValue2],
        );

        // Call liftA2 on the NanoVar instances.
        final applicativeNanoVar = nanoVar1.liftA2(
          (value1, value2) => lifter([value1, value2]),
          nanoVar2,
        );

        // Create two mocks.
        final fakeSubscriber1 = NanoMock<void>();
        final fakeSubscriber2 = NanoMock<void>();

        // Set up the mocks to accept the first value.
        final verifySubscriber1 = fakeSubscriber1.whenVoid([
          oldValue1 + oldValue2,
          newValue1 + oldValue2,
        ]);
        final verifySubscriber2 = fakeSubscriber2.whenVoid([
          oldValue1 + oldValue2,
          newValue1 + oldValue2,
        ]);

        // Set up the mocks to accept the second value.
        final verifySubscriber3 = fakeSubscriber1.whenVoid([
          newValue1 + oldValue2,
          newValue1 + newValue2,
        ]);
        final verifySubscriber4 = fakeSubscriber2.whenVoid([
          newValue1 + oldValue2,
          newValue1 + newValue2,
        ]);

        // Subscribe to the ApplicativeNanoVar.
        applicativeNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber1([oldValue, newValue]),
        );
        applicativeNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber2([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one on the first NanoVar
        // instance.
        // ApplicativeNanoVar should optimize so only one subscription is
        // necessary.
        expect(
          nanoVar1.subscribersCount,
          equals(1),
        );

        // Validate that the number of subscribers is one on the second NanoVar
        // instance.
        // ApplicativeNanoVar should optimize so only one subscription is
        // necessary.
        expect(
          nanoVar2.subscribersCount,
          equals(1),
        );

        // Verify fakeSubscriber has not been called.
        verifySubscriber1.neverCalled();
        verifySubscriber2.neverCalled();

        // Verify lifter has not been called.
        verifyLifter1.neverCalled();

        // Assign to the first NanoVar's value to trigger a change.
        nanoVar1.value = newValue1;

        // Verify fakeSubscriber has been called once.
        verifySubscriber1.called(1);
        verifySubscriber2.called(1);

        // Verify lifter has been called once.
        // ApplicativeNanoVar should optimize so both subscribers get the same
        // value.
        verifyLifter1.called(1);

        // Verify fakeSubscriber has not been called.
        verifySubscriber3.neverCalled();
        verifySubscriber4.neverCalled();

        // Verify lifter has not been called.
        verifyLifter2.neverCalled();

        // Assign to the second NanoVar's value to trigger a change.
        nanoVar2.value = newValue2;

        // Verify fakeSubscriber has been called twice.
        verifySubscriber3.called(1);
        verifySubscriber4.called(1);

        // Verify lifter has been called twice.
        // ApplicativeNanoVar should optimize so both subscribers get the same
        // value.
        verifyLifter2.called(1);
      });

      test("oldValue is correct when subscribing after the value has changed",
          () {
        // Generate random values.
        final random = UniqueRandom(1);
        final initialValue1 = random.next();
        final initialValue2 = random.next();
        final oldValue1 = random.next();
        final oldValue2 = random.next();
        final newValue = random.next();

        // Create a NanoVar.
        final nanoVar1 = NanoVar(oldValue1);

        // Create another NanoVar.
        final nanoVar2 = NanoVar(oldValue2);

        // Create a lifter.
        final lifter = NanoMock<int>();

        // Set up lifter to accept the initial values.
        lifter.when(
          initialValue1 + initialValue2,
          [initialValue1, initialValue2],
        );

        // Set up lifter to accept the old values.
        lifter.when(
          oldValue1 + oldValue2,
          [oldValue1, oldValue2],
        );

        // Set up lifter to accept the new value.
        lifter.when(
          newValue + oldValue2,
          [newValue, oldValue2],
        );

        // Call liftA2 on the NanoVar instances.
        final applicativeNanoVar = nanoVar1.liftA2(
          (value1, value2) => lifter([value1, value2]),
          nanoVar2,
        );

        // Assign to the first NanoVar's value to trigger a change.
        nanoVar1.value = oldValue1;

        // Assign to the second NanoVar's value to trigger a change.
        nanoVar2.value = oldValue2;

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the generated random values.
        final verifySubscriber = fakeSubscriber.whenVoid([
          oldValue1 + oldValue2,
          newValue + oldValue2,
        ]);

        // Subscribe to the FunctorNanoVar.
        applicativeNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Assign to first NanoVar's value to trigger another change.
        nanoVar1.value = newValue;

        // Verify fakeSubscriber has been called once.
        verifySubscriber.called(1);
      });
    });
  });
}
