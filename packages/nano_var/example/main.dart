import 'package:nano_var/nano_var.dart';

void main() {
  // Create a NanoVar.
  final nanoVar = NanoVar(0);

  void Function() _subscribe(int id) {
    // Subscribe to nanoVar.
    return nanoVar.subscribe((oldValue, newValue) {
      // Print a message when nanoVar's value is changed.
      print("Subscriber $id sees that the value changed " +
          "from $oldValue to $newValue. " +
          "A direct read says the value is ${nanoVar.value}.");
    });
  }

  // Subscribe to nanoVar.
  final unsubscribe1 = _subscribe(1);

  // Print an explanation about what should happen next.
  print("One line should be printed before the empty line.");

  // Set nanoVar's value to 1.
  nanoVar.value = 1;

  // Print an empty line.
  print("");

  // Subscribe to nanoVar.
  final unsubscribe2 = _subscribe(2);

  // Print an explanation about what should happen next.
  print("Two lines should be printed before the empty line.");

  // Set nanoVar's value to 2.
  nanoVar.value = 2;

  // Print an empty line.
  print("");

  // Print an explanation about what should happen next.
  print("Nothing should be printed after this line.");

  // Make both subscribers unsubscribe.
  unsubscribe1();
  unsubscribe2();

  // Set nanoVar's value to 3, which shouldn't result in any more lines being
  // printed as both subscribers have unsubscribed.
  nanoVar.value = 3;
}
