import 'dart:math';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

import 'nano_read_test.mocks.dart';
import 'fakes/fake_subscriber.dart';

class _NanoRead extends NanoRead<int> {
  _NanoRead(int initialValue) : super(initialValue);

  void _change(int newValue) {
    change(newValue);
  }

  void Function() _subscribe(void Function(int, int) callback) {
    return subscribe((oldValue, newValue) => callback(oldValue, newValue));
  }
}

@GenerateMocks([
  FakeSubscriber,
])
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
        final fakeSubscriber = MockFakeSubscriber();

        // Set up the mock to accept the generated random values.
        when(fakeSubscriber.onChange(oldValue, newValue)).thenAnswer((_) {});

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber.onChange);

        // Validate that the number of subscribers is one.
        expect(
          nanoRead.subscribersCount,
          equals(1),
        );

        // Verify onChange has not been called.
        verifyNever(fakeSubscriber.onChange(oldValue, newValue));

        // Call _change to trigger a change.
        nanoRead._change(newValue);

        // Verify onChange has been called.
        verify(fakeSubscriber.onChange(oldValue, newValue)).called(1);
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
        final fakeSubscriber = MockFakeSubscriber();

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber.onChange);

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
        final fakeSubscriber = MockFakeSubscriber();

        // Set up the mock to accept the two first generated random values.
        when(fakeSubscriber.onChange(oldValue, newValue1)).thenAnswer((_) {});

        // Subscribe to the nanoRead.
        final unsubscribe = nanoRead._subscribe(fakeSubscriber.onChange);

        // Validate that the number of subscribers is one.
        expect(
          nanoRead.subscribersCount,
          equals(1),
        );

        // Call _change to trigger a change.
        nanoRead._change(newValue1);

        // Call unsubscribe.
        unsubscribe();

        // Validate that the number of subscribers is zero.
        expect(
          nanoRead.subscribersCount,
          equals(0),
        );

        // Call _change to trigger another change.
        nanoRead._change(newValue2);
      });

      test("can have two subscriptions", () {
        // Generate random values.
        final random = Random();
        final oldValue = random.nextInt(100);
        final newValue = random.nextInt(100);

        // Create a _NanoRead.
        final nanoRead = _NanoRead(oldValue);

        // Create two mocks.
        final fakeSubscriber1 = MockFakeSubscriber();
        final fakeSubscriber2 = MockFakeSubscriber();

        // Set up the mocks to accept the generated random values.
        when(fakeSubscriber1.onChange(oldValue, newValue)).thenAnswer((_) {});
        when(fakeSubscriber2.onChange(oldValue, newValue)).thenAnswer((_) {});

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber1.onChange);
        nanoRead._subscribe(fakeSubscriber2.onChange);

        // Validate that the number of subscribers is two.
        expect(
          nanoRead.subscribersCount,
          equals(2),
        );

        // Verify onChange has not been called on both mocks.
        verifyNever(fakeSubscriber1.onChange(oldValue, newValue));
        verifyNever(fakeSubscriber2.onChange(oldValue, newValue));

        // Call _change to trigger a change.
        nanoRead._change(newValue);

        // Verify onChange has been called on both mocks.
        verify(fakeSubscriber1.onChange(oldValue, newValue)).called(1);
        verify(fakeSubscriber2.onChange(oldValue, newValue)).called(1);
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
        final fakeSubscriber1 = MockFakeSubscriber();
        final fakeSubscriber2 = MockFakeSubscriber();

        // Set up the mocks to accept the generated random values.
        when(fakeSubscriber1.onChange(oldValue, newValue1)).thenAnswer((_) {});
        when(fakeSubscriber2.onChange(oldValue, newValue1)).thenAnswer((_) {});
        when(fakeSubscriber1.onChange(newValue1, newValue2)).thenAnswer((_) {});

        // Subscribe to the nanoRead.
        nanoRead._subscribe(fakeSubscriber1.onChange);
        final unsubscribe = nanoRead._subscribe(fakeSubscriber2.onChange);

        // Validate that the number of subscribers is two.
        expect(
          nanoRead.subscribersCount,
          equals(2),
        );

        // Verify onChange has not been called on both mocks.
        verifyNever(fakeSubscriber1.onChange(oldValue, newValue1));
        verifyNever(fakeSubscriber2.onChange(oldValue, newValue1));
        verifyNever(fakeSubscriber1.onChange(newValue1, newValue2));

        // Call _change to trigger a change.
        nanoRead._change(newValue1);

        // Verify onChange has been called on both mocks.
        verify(fakeSubscriber1.onChange(oldValue, newValue1)).called(1);
        verify(fakeSubscriber2.onChange(oldValue, newValue1)).called(1);
        verifyNever(fakeSubscriber1.onChange(newValue1, newValue2));

        // Call unsubscribe to unsubscribe the second mock.
        unsubscribe();

        // Validate that the number of subscribers is one.
        expect(
          nanoRead.subscribersCount,
          equals(1),
        );

        // Call _change to trigger another change.
        nanoRead._change(newValue2);

        // Verify onChange has been called on the first mock.
        verify(fakeSubscriber1.onChange(newValue1, newValue2)).called(1);
      });
    });
  });
}
