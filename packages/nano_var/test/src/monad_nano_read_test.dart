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

        // Create an outer NanoVar instance.
        final outerNanoVar = NanoVar(initialValue1);

        // Create an inner NanoVar instance.
        final innerNanoVar = NanoVar(initialValue2);

        // Create a binder.
        final binder = NanoMock<NanoRead<int>>();

        // Set up binder to accept the initial values.
        final verify = binder.when(
          innerNanoVar,
          [initialValue1],
        );

        // Call bind on the outer NanoVar instance.
        final monadNanoVar = outerNanoVar.bind(
          (value) => binder([value]),
        );

        // Verify the value getter returns the second initial value.
        expect(
          monadNanoVar.value,
          equals(initialValue2),
        );

        // Verify binder has been called once.
        verify.called(1);
      });

      test("is changed when a change is triggered on the appropriate instance",
          () {
        // Generate a random value.
        final random = UniqueRandom();
        final initialValue1 = random.next();
        final initialValue2 = random.next();
        final oldValue1 = random.next();
        final oldValue2 = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();

        // Create an inner NanoVar.
        final innerNanoVar1 = NanoVar(initialValue1);

        // Create another inner NanoVar.
        final innerNanoVar2 = NanoVar(initialValue2);

        // Create a binder.
        final binder = NanoMock<NanoRead<int>>();

        // Set up binder to return the inner NanoVar instances.
        final verifyInnerNanoVar1 = binder.when(
          innerNanoVar1,
          [false],
        );
        final verifyInnerNanoVar2 = binder.when(
          innerNanoVar2,
          [true],
        );

        // Create an outer NanoVar.
        final outerNanoVar = NanoVar(false);

        // Call bind on the outer NanoVar instance.
        final monadNanoVar = outerNanoVar.bind(
          (value) => binder([value]),
        );

        // Verify binder has been called once.
        verifyInnerNanoVar1.called(1);
        verifyInnerNanoVar2.neverCalled();

        // Assign values to the inner NanoVar instances.
        innerNanoVar1.value = oldValue1;
        innerNanoVar2.value = oldValue2;

        // Verify the value getter returns the first old value.
        expect(
          monadNanoVar.value,
          equals(oldValue1),
        );

        // Change the outer NanoVar's value to true.
        outerNanoVar.value = true;

        // Verify the value getter returns the second old value.
        expect(
          monadNanoVar.value,
          equals(oldValue2),
        );

        // Verify binder has been called twice.
        verifyInnerNanoVar1.called(1);
        verifyInnerNanoVar2.called(1);

        // Assign values to the inner NanoVar instances.
        innerNanoVar1.value = newValue1;
        innerNanoVar2.value = newValue2;

        // Verify the value getter returns the second new value.
        expect(
          monadNanoVar.value,
          equals(newValue2),
        );
      });
    });

    group("subscribe", () {
      test(
          "can subscribe and unsubscribe and get values while subscribing " +
              " when a change is triggered on the appropriate instance", () {
        // Generate a random value.
        final random = UniqueRandom();
        final initialValue1 = random.next();
        final initialValue2 = random.next();
        final oldValue1 = random.next();
        final oldValue2 = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();
        final newValue3 = random.next();
        final newValue4 = random.next();

        // Create an inner NanoVar.
        final innerNanoVar1 = NanoVar(initialValue1);

        // Create another inner NanoVar.
        final innerNanoVar2 = NanoVar(initialValue2);

        // Create a binder.
        final binder = NanoMock<NanoRead<int>>();

        // Set up binder to return the inner NanoVar instances.
        binder.when(
          innerNanoVar1,
          [false],
        );
        binder.when(
          innerNanoVar2,
          [true],
        );

        // Create an outer NanoVar.
        final outerNanoVar = NanoVar(true);

        // Call bind on the outer NanoVar instance.
        final monadNanoVar = outerNanoVar.bind(
          (value) => binder([value]),
        );

        // Change the outer NanoVar's value to false.
        outerNanoVar.value = false;

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the first old value.
        final verifySubscriber1 = fakeSubscriber.whenVoid([
          initialValue1,
          oldValue1,
        ]);

        // Set up the mock to accept the second old value.
        final verifySubscriber2 = fakeSubscriber.whenVoid([
          oldValue1,
          oldValue2,
        ]);

        // Set up the mock to accept the second new value.
        final verifySubscriber3 = fakeSubscriber.whenVoid([
          oldValue2,
          newValue2,
        ]);

        // Subscribe to the MonadNanoVar twice.
        final unsubscribe1 = monadNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );
        final unsubscribe2 = monadNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one on the outer NanoVar
        // instance.
        expect(
          outerNanoVar.subscribersCount,
          equals(1),
        );

        // Validate that the number of subscribers is one on the first inner
        // NanoVar instance.
        expect(
          innerNanoVar1.subscribersCount,
          equals(1),
        );

        // Validate that the number of subscribers is zero on the second inner
        // NanoVar instance.
        expect(
          innerNanoVar2.subscribersCount,
          equals(0),
        );

        // Assign values to the inner NanoVar instances.
        innerNanoVar1.value = oldValue1;
        innerNanoVar2.value = oldValue2;

        // Verify an initial emission has been made.
        verifySubscriber1.called(2);

        // Change the outer NanoVar's value to true.
        outerNanoVar.value = true;

        // Validate that the number of subscribers is zero on the first inner
        // NanoVar instance.
        expect(
          innerNanoVar1.subscribersCount,
          equals(0),
        );

        // Validate that the number of subscribers is one on the second inner
        // NanoVar instance.
        expect(
          innerNanoVar2.subscribersCount,
          equals(1),
        );

        // Verify a second emission has been made.
        verifySubscriber2.called(2);

        // Assign values to the inner NanoVar instances.
        innerNanoVar1.value = newValue1;
        innerNanoVar2.value = newValue2;

        // Verify a third emission has been made.
        verifySubscriber3.called(2);

        // Call unsubscribe1 and unsubscribe2.
        unsubscribe1();
        unsubscribe2();

        // Validate that the number of subscribers is zero on the outer NanoVar
        // instance.
        expect(
          outerNanoVar.subscribersCount,
          equals(0),
        );

        // Validate that the number of subscribers is zero on the first inner
        // NanoVar instance.
        expect(
          innerNanoVar1.subscribersCount,
          equals(0),
        );

        // Validate that the number of subscribers is zero on the second inner
        // NanoVar instance.
        expect(
          innerNanoVar2.subscribersCount,
          equals(0),
        );

        // Assign to the first NanoVar's value.
        innerNanoVar1.value = newValue3;

        // Assign to the second NanoVar's value.
        innerNanoVar2.value = newValue4;
      });
    });
  });
}
