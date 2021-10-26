import 'package:nano_var/nano_var.dart';
import 'package:test/test.dart';

void main() {
  group("FutureNanoReadStatus", () {
    // These tests are necessary to get 100 percent test coverage.
    group("hashCode", () {
      test("can call hashCode on UncompletedNanoReadStatus", () {
        UncompletedNanoReadStatus().hashCode;
      });

      test("can call hashCode on SucceessNanoReadStatus", () {
        SucceessNanoReadStatus("").hashCode;
      });

      test("can call hashCode on FailNanoReadStatus", () {
        FailNanoReadStatus("", StackTrace.current).hashCode;
      });
    });
  });
}
