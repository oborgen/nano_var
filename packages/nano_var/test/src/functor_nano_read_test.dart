import 'package:nano_mock/nano_mock.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

import 'utils/unique_random.dart';

void main() {
  group("FunctorNanoVar", () {
    group("get value", () {
      test("can get the initial value", () {
        // Generate a random value.
        final random = UniqueRandom();
        final initialValue = random.next();
        final incrementBy = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(initialValue);

        // Create a mapper.
        final mapper = NanoMock<int>();

        // Set up mapper to accept the initial value.
        final verify = mapper.when(initialValue + incrementBy, [initialValue]);

        // Call map on the NanoVar.
        final functorNanoVar = nanoVar.map((value) => mapper([value]));

        // Verify the value getter returns the mapped initial value.
        expect(
          functorNanoVar.value,
          equals(initialValue + incrementBy),
        );

        // Verify mapper has been called once.
        verify.called(1);
      });

      test("is changed when a change is triggered", () {
        // Generate a random value.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue = random.next();
        final incrementBy = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create a mapper.
        final mapper = NanoMock<int>();

        // Set up mapper to accept the old value.
        mapper.when(oldValue + incrementBy, [oldValue]);

        // Set up mapper to accept the new value.
        final verify = mapper.when(newValue + incrementBy, [newValue]);

        // Call map on the NanoVar.
        final functorNanoVar = nanoVar.map((value) => mapper([value]));

        // Assign to value to trigger a change.
        nanoVar.value = newValue;

        // Verify the value getter returns the new value.
        expect(
          functorNanoVar.value,
          equals(newValue + incrementBy),
        );

        // Verify mapper has been called once.
        verify.called(1);
      });
    });

    group("subscribe", () {
      test("can subscribe and get new values when it's changed", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue = random.next();
        final incrementBy = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create a mapper.
        final mapper = NanoMock<int>();

        // Set up mapper to accept the old value.
        mapper.when(oldValue + incrementBy, [oldValue]);

        // Set up mapper to accept the new value.
        final verifyMapper = mapper.when(newValue + incrementBy, [newValue]);

        // Call map on the NanoVar.
        final functorNanoVar = nanoVar.map((value) => mapper([value]));

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the generated random values.
        final verifySubscriber = fakeSubscriber.whenVoid([
          oldValue + incrementBy,
          newValue + incrementBy,
        ]);

        // Subscribe to the FunctorNanoVar.
        functorNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one.
        expect(
          nanoVar.subscribersCount,
          equals(1),
        );

        // Verify fakeSubscriber has not been called.
        verifySubscriber.neverCalled();

        // Verify mapper has not been called.
        verifyMapper.neverCalled();

        // Assign to value to trigger a change.
        nanoVar.value = newValue;

        // Verify fakeSubscriber has been called once.
        verifySubscriber.called(1);

        // Verify mapper has been called once.
        verifyMapper.called(1);
      });

      test("can unsubscribe", () {
        // Generate random values.
        final random = UniqueRandom();
        final oldValue = random.next();
        final newValue1 = random.next();
        final newValue2 = random.next();
        final incrementBy = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create a mapper.
        final mapper = NanoMock<int>();

        // Set up mapper to accept the old value.
        mapper.when(oldValue + incrementBy, [oldValue]);

        // Set up mapper to accept the first new value.
        final verifyMapper = mapper.when(newValue1 + incrementBy, [newValue1]);

        // Call map on the NanoVar.
        final functorNanoVar = nanoVar.map((value) => mapper([value]));

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the two first generated random values.
        final verify = fakeSubscriber.whenVoid([
          oldValue + incrementBy,
          newValue1 + incrementBy,
        ]);

        // Subscribe to the NanoVar.
        final unsubscribe = functorNanoVar.subscribe(
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

        // Verify mapper has been called once.
        verifyMapper.called(1);

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
        final incrementBy = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(oldValue);

        // Create a mapper.
        final mapper = NanoMock<int>();

        // Set up mapper to accept the old value.
        mapper.when(oldValue + incrementBy, [oldValue]);

        // Set up mapper to accept the new value.
        final verifyMapper = mapper.when(newValue + incrementBy, [newValue]);

        // Call map on the NanoVar.
        final functorNanoVar = nanoVar.map((value) => mapper([value]));

        // Create two mocks.
        final fakeSubscriber1 = NanoMock<void>();
        final fakeSubscriber2 = NanoMock<void>();

        // Set up the mocks to accept the generated random values.
        final verify1 = fakeSubscriber1.whenVoid([
          oldValue + incrementBy,
          newValue + incrementBy,
        ]);
        final verify2 = fakeSubscriber2.whenVoid([
          oldValue + incrementBy,
          newValue + incrementBy,
        ]);

        // Subscribe to the FunctorNanoVar.
        functorNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber1([oldValue, newValue]),
        );
        functorNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber2([oldValue, newValue]),
        );

        // Validate that the number of subscribers is one.
        // FunctorNanoVar should optimize so only one subscription is necessary.
        expect(
          nanoVar.subscribersCount,
          equals(1),
        );

        // Verify both mocks have not been called.
        verify1.neverCalled();
        verify2.neverCalled();

        // Verify mapper has not been called.
        verifyMapper.neverCalled();

        // Assign to value to trigger a change.
        nanoVar.value = newValue;

        // Verify both mocks have been called once.
        verify1.called(1);
        verify2.called(1);

        // Verify mapper has been called once.
        // FunctorNanoVar should optimize so both subscribers get the same
        // value.
        verifyMapper.called(1);
      });

      test("oldValue is correct when subscribing after the value has changed",
          () {
        // Generate random values.
        final random = UniqueRandom();
        final initialValue = random.next();
        final oldValue = random.next();
        final newValue = random.next();
        final incrementBy = random.next();

        // Create a NanoVar.
        final nanoVar = NanoVar(initialValue);

        // Create a mapper.
        final mapper = NanoMock<int>();

        // Set up mapper to accept the initial value.
        mapper.when(initialValue + incrementBy, [initialValue]);

        // Set up mapper to accept the old value.
        mapper.when(oldValue + incrementBy, [oldValue]);

        // Set up mapper to accept the new value.
        mapper.when(newValue + incrementBy, [newValue]);

        // Call map on the NanoVar.
        final functorNanoVar = nanoVar.map((value) => mapper([value]));

        // Assign to value to trigger a change.
        nanoVar.value = oldValue;

        // Create a mock.
        final fakeSubscriber = NanoMock<void>();

        // Set up the mock to accept the generated random values.
        final verifySubscriber = fakeSubscriber.whenVoid([
          oldValue + incrementBy,
          newValue + incrementBy,
        ]);

        // Subscribe to the FunctorNanoVar.
        functorNanoVar.subscribe(
          (oldValue, newValue) => fakeSubscriber([oldValue, newValue]),
        );

        // Assign to value to trigger another change.
        nanoVar.value = newValue;

        // Verify fakeSubscriber has been called once.
        verifySubscriber.called(1);
      });
    });
  });
}
