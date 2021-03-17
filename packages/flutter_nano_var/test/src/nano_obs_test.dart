import 'package:flutter_nano_var/flutter_nano_var.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nano_var/nano_var.dart';
import 'package:uuid/uuid.dart';

import 'utils/test_text.dart';

final _uuid = Uuid();
String _randomString() {
  // Call v4 to generate a new UUID.
  return _uuid.v4();
}

void main() {
  group("NanoObs", () {
    testWidgets("can build a Text with the initial value", (tester) async {
      // Generate an initial value.
      final initialValue = "initialValue-" + _randomString();

      // Create a Variable with the initial value.
      final nanoVar = NanoVar(initialValue);

      addTearDown(() {
        // Validate the subscribers count.
        expect(nanoVar.subscribersCount, 0);
      });

      // Build a NanoObs with the Variable.
      await tester.pumpWidget(
        NanoObs(
          builder: (context, watch) => TestText(watch(nanoVar)),
        ),
      );

      // Validate the subscribers count.
      expect(nanoVar.subscribersCount, 1);

      // Validate that the initial value is displayed.
      expect(
        find.text(initialValue),
        findsOneWidget,
      );
    });
  });
}
