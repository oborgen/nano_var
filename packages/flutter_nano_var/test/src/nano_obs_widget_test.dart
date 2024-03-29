import 'package:flutter/material.dart';
import 'package:flutter_nano_var/flutter_nano_var.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_mock/nano_mock.dart';
import 'package:nano_var/nano_var.dart';
import 'package:uuid/uuid.dart';

import 'utils/test_text.dart';

class _TextObserverWidget extends NanoObsWidget {
  final NanoRead<String> nanoRead;
  final void Function(T Function<T>(NanoRead<T> nanoRead))? stealWatch;

  const _TextObserverWidget({
    required this.nanoRead,
    this.stealWatch,
  });

  @override
  Widget build(
    BuildContext context,
    T Function<T>(NanoRead<T> nanoRead) watch,
  ) {
    // Call stealWatch with the watch function if a stealWatch is set.
    final stealWatch = this.stealWatch;
    if (stealWatch != null) {
      stealWatch(watch);
    }

    // Build a TestText widget.
    return TestText(watch(nanoRead));
  }
}

class _MultiTextObserverWidget extends NanoObsWidget {
  final NanoRead<bool> selection;
  final NanoRead<String> nanoRead1;
  final NanoRead<String> nanoRead2;

  const _MultiTextObserverWidget({
    required this.selection,
    required this.nanoRead1,
    required this.nanoRead2,
  });

  @override
  Widget build(
    BuildContext context,
    T Function<T>(NanoRead<T> nanoRead) watch,
  ) {
    return TestText(watch(selection)
        // Readable 1
        ? watch(nanoRead1)
        // Readable 2
        : watch(nanoRead2));
  }
}

final _uuid = Uuid();
String randomString() {
  // Call v4 to generate a new UUID.
  return _uuid.v4();
}

class _PostDisposeEmitNanoRead extends NanoRead<String> {
  final String initialValue;
  final void Function() unsubscribe;

  NanoReadSubscribeCallback<String>? callback;

  _PostDisposeEmitNanoRead(
    this.initialValue,
    this.unsubscribe,
  );

  @override
  void Function() subscribe(NanoReadSubscribeCallback<String> callback) {
    // Store the given callback.
    this.callback = callback;

    // Return the given unsubscribe function.
    return unsubscribe;
  }

  @override
  String get value => initialValue;
}

void main() {
  group("NanoObsWidget", () {
    testWidgets("can build a Text with the initial value", (tester) async {
      // Generate an initial value.
      final initialValue = "initialValue-" + randomString();

      // Create a Variable with the initial value.
      final nanoVar = NanoVar(initialValue);

      addTearDown(() {
        // Validate the subscribers count.
        expect(nanoVar.subscribersCount, 0);
      });

      // Build a _TextObserverWidget with the Variable.
      await tester.pumpWidget(_TextObserverWidget(
        nanoRead: nanoVar,
      ));

      // Validate the subscribers count.
      expect(nanoVar.subscribersCount, 1);

      // Validate that the initial value is displayed.
      expect(
        find.text(initialValue),
        findsOneWidget,
      );
    });

    testWidgets("updates the Text when the value changes", (tester) async {
      // Generate values.
      final oldValue = "oldValue-" + randomString();
      final newValue = "newValue-" + randomString();

      // Create a Variable with the old value.
      final nanoVar = NanoVar(oldValue);

      addTearDown(() {
        // Validate the subscribers count.
        expect(nanoVar.subscribersCount, 0);
      });

      // Build a _TextObserverWidget with the Variable.
      await tester.pumpWidget(_TextObserverWidget(
        nanoRead: nanoVar,
      ));

      // Validate the subscribers count.
      expect(nanoVar.subscribersCount, 1);

      // Assign newValue to the Variable.
      nanoVar.value = newValue;

      // Call pumpAndSettle to trigger a rebuild.
      await tester.pumpAndSettle();

      // Validate that the new value is displayed.
      expect(
        find.text(newValue),
        findsOneWidget,
      );
    });

    testWidgets("can subscribe and unsubscribe on demand", (tester) async {
      // Generate values.
      final initialValue1 = "initialValue1-" + randomString();
      final initialValue2 = "initialValue2-" + randomString();
      final oldValue1 = "oldValue1-" + randomString();
      final oldValue2 = "oldValue2-" + randomString();
      final newValue1 = "newValue1-" + randomString();
      final newValue2 = "newValue2-" + randomString();

      // Create a Variable with the old value.
      final selection = NanoVar(true);
      final nanoVar1 = NanoVar(initialValue1);
      final nanoVar2 = NanoVar(initialValue2);

      addTearDown(() {
        // Validate the subscribers count.
        expect(selection.subscribersCount, 0);
        expect(nanoVar1.subscribersCount, 0);
        expect(nanoVar2.subscribersCount, 0);
      });

      // Build a _TextObserverWidget with the Variable.
      await tester.pumpWidget(_MultiTextObserverWidget(
        selection: selection,
        nanoRead1: nanoVar1,
        nanoRead2: nanoVar2,
      ));

      // Validate the subscribers count.
      expect(selection.subscribersCount, 1);
      expect(nanoVar1.subscribersCount, 1);
      expect(nanoVar2.subscribersCount, 0);

      // Validate that initialValue1 is displayed.
      expect(
        find.text(initialValue1),
        findsOneWidget,
      );

      // Assign values to the variables.
      nanoVar1.value = oldValue1;
      nanoVar2.value = oldValue2;

      // Call pumpAndSettle to trigger a rebuild.
      await tester.pumpAndSettle();

      // Validate that oldValue1 is displayed.
      expect(
        find.text(oldValue1),
        findsOneWidget,
      );

      // Assign false to selection.
      selection.value = false;

      // Call pumpAndSettle to trigger a rebuild.
      await tester.pumpAndSettle();

      // Validate the subscribers count.
      expect(selection.subscribersCount, 1);
      expect(nanoVar1.subscribersCount, 0);
      expect(nanoVar2.subscribersCount, 1);

      // Validate that oldValue2 is displayed.
      expect(
        find.text(oldValue2),
        findsOneWidget,
      );

      // Assign values to the variables.
      nanoVar1.value = newValue1;
      nanoVar2.value = newValue2;

      // Call pumpAndSettle to trigger a rebuild.
      await tester.pumpAndSettle();

      // Validate that newValue2 is displayed.
      expect(
        find.text(newValue2),
        findsOneWidget,
      );
    });

    testWidgets("watch throws an exception if called outside build",
        (tester) async {
      // Generate an initial value.
      final initialValue = "initialValue-" + randomString();

      // Create a Variable with the initial value.
      final nanoVar = NanoVar(initialValue);

      // Declare a variable and a function used to steal the watch function.
      late T Function<T>(NanoRead<T> nanoRead) watch;
      void stealWatch(T Function<T>(NanoRead<T> nanoRead) _watch) {
        watch = _watch;
      }

      // Build a _TextObserverWidget with the Variable.
      await tester.pumpWidget(_TextObserverWidget(
        nanoRead: nanoVar,
        stealWatch: stealWatch,
      ));

      // Call watch an verify that an InvalidWatchCallException is thrown.
      expect(
        () => watch(nanoVar),
        throwsA(isA<InvalidWatchCallException>()),
      );
    });

    testWidgets(
        "does nothing if a NanoRead instance emits a new value after the " +
            "widget has been disposed", (tester) async {
      // Generate an initial value.
      final initialValue = "initialValue-" + randomString();

      // Generate a new value.
      final newValue = "newValue-" + randomString();

      // Create a mock.
      final fakeUnsubscribe = NanoMock<void>();

      // Set up the mock to accept no arguments.
      final verify = fakeUnsubscribe.whenVoid([]);

      // Create a _PostDisposeEmitNanoRead.
      final nanoRead = _PostDisposeEmitNanoRead(
        initialValue,
        () => fakeUnsubscribe([]),
      );

      // Build a _TextObserverWidget with the _PostDisposeEmitNanoRead
      // instance.
      await tester.pumpWidget(
        _TextObserverWidget(
          nanoRead: nanoRead,
        ),
      );

      // Build a Container, which disposes the NanoObsWidget.
      await tester.pumpWidget(
        Container(),
      );

      // Verify that unsubscribe has been called.
      verify.called(1);

      // Trigger the callback from the NanoObsWidget anyway.
      nanoRead.callback!(
        initialValue,
        newValue,
      );
    });
  });
}
