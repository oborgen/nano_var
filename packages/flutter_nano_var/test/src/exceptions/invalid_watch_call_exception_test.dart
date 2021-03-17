import 'package:flutter_nano_var/flutter_nano_var.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("InvalidWatchCallException", () {
    test("can call toString", () {
      expect(
        InvalidWatchCallException().toString(),
        equals("watch() cannot be called after build() has returned."),
      );
    });
  });
}
