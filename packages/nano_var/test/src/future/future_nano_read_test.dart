import 'dart:async';

import 'package:test/test.dart';
import 'package:nano_var/nano_var.dart';

import '../utils/unique_random.dart';

void main() {
  group("FutureNanoRead", () {
    test("reports uncompleted and then success with a succeeding Future",
        () async {
      // Generate a random value.
      final random = UniqueRandom();
      final value = random.next();

      // Create a Completer.
      final completer = Completer<int>();

      // Call nanoRead on the Completer's future.
      final futureNanoRead = completer.future.nanoRead;

      // Verify the current status is uncompleted.
      expect(
        futureNanoRead.value,
        equals(const UncompletedNanoReadStatus<int>()),
      );

      // Complete the completer using value.
      completer.complete(value);

      // Yield so the status is updated properly.
      await Future.delayed(Duration.zero);

      // Verify the current status is success.
      expect(
        futureNanoRead.value,
        equals(SucceessNanoReadStatus(
          value,
        )),
      );
    });

    test("reports uncompleted and then fail with a failing Future", () async {
      // Create a Completer.
      final completer = Completer<int>();

      // Call nanoRead on the Completer's future.
      final futureNanoRead = completer.future.nanoRead;

      // Verify the current status is uncompleted.
      expect(
        futureNanoRead.value,
        equals(const UncompletedNanoReadStatus<int>()),
      );

      // Create a test error.
      final error = Exception();

      // Create a test stack trace.
      final stackTrace = StackTrace.current;

      // Complete the completer with the error and the stack trace.
      completer.completeError(error, stackTrace);

      // Yield so the status is updated properly.
      await Future.delayed(Duration.zero);

      // Verify the current status is failed.
      expect(
        futureNanoRead.value,
        equals(FailNanoReadStatus<int>(
          error,
          stackTrace,
        )),
      );
    });

    test("can handle a use case where a status text is based on an input field",
        () async {
      // Declare three test statuses.
      const String loadingStatus = "Loading";
      const String successStatus = "Success";
      const String failedStatus = "Failed";

      // Create a Completer to test success.
      final successCompleter = Completer<String>();

      // Create a Completer to test failure.
      final failCompleter = Completer<String>();

      // Create NanoVar instance simulating an input field.
      final inputField = NanoVar(true);

      // Set up a NanoRead instance simulating a status field.
      final statusField = inputField
          // Simulate loading with two possible outcomes.
          .bind((value) => value
              ? successCompleter.future.nanoRead
              : failCompleter.future.nanoRead)

          // Map each FutureNanoReadStatus to an appropriate status string.
          .map(
            (status) => status.status(
              uncompleted: () => loadingStatus,
              success: (value) => value,
              fail: (error, stackTrace) => error.toString(),
            ),
          );

      // Declare and initialize status with the status field's current value.
      String status = statusField.value;

      // Subscribe to the status field.
      statusField.subscribe((oldStatus, newStatus) {
        // Assign to status each time the status field is changed.
        status = newStatus;
      });

      // Expect the current status to be loading.
      expect(
        status,
        equals(loadingStatus),
      );

      // Complete successCompleter using successStatus.
      successCompleter.complete(successStatus);

      // Yield so the status is updated properly.
      await Future.delayed(Duration.zero);

      // Expect the current status to be success.
      expect(
        status,
        equals(successStatus),
      );

      // Change the input field.
      inputField.value = false;

      // Expect the current status to be loading.
      expect(
        status,
        equals(loadingStatus),
      );

      // Complete failCompleter using failedStatus.
      failCompleter.completeError(failedStatus);

      // Yield so the status is updated properly.
      await Future.delayed(Duration.zero);

      // Expect the current status to be failure.
      expect(
        status,
        equals(failedStatus),
      );
    });
  });
}
