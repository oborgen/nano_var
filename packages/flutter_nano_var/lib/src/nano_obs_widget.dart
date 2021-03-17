import 'package:flutter/widgets.dart';
import 'package:nano_var/nano_var.dart';

/// A widget that can be used to listen to changes to [NanoRead]s and will
/// rebuild itself when any change occurs.
///
/// Users have to override the method `build` to use the widget.
abstract class NanoObsWidget extends StatefulWidget {
  const NanoObsWidget({
    Key? key,
  }) : super(key: key);

  /// Builds the widget and provides the function `watch`, which can be used to
  /// read the values of [NanoRead]s and subscribe to changes to those values.
  Widget build(
    BuildContext context,
    T Function<T>(NanoRead<T> nanoRead) watch,
  );

  @override
  State<StatefulWidget> createState() {
    return _NanoObsWidgetState();
  }
}

/// The state for [NanoObsWidget].
class _NanoObsWidgetState extends State<NanoObsWidget> {
  /// A map containing all subscriptions of the widget including their
  /// unsubscribe functions.
  final Map<NanoRead, void Function()> subscriptions;

  _NanoObsWidgetState() : subscriptions = {};

  @override
  void dispose() {
    // Process each subscription.
    subscriptions.forEach((nanoRead, unsubscribe) {
      // Unsubscribe the current subscription.
      unsubscribe();
    });

    // Call dispose on the superclass.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Declare a Set of reads.
    final Set<NanoRead> reads = {};

    // Declare a Map of new subscriptions.
    final Map<NanoRead, void Function()> newSubscriptions = {};

    // Call build to build the widget.
    final builtWidget = widget.build(context, <T>(NanoRead<T> nanoRead) {
      // Call _watchReadable.
      return _watchReadable(nanoRead, reads, newSubscriptions);
    });

    // Call _cleanSubscriptions.
    _cleanSubscriptions(reads);

    // Add all new subscriptions to subscriptions.
    subscriptions.addAll(newSubscriptions);

    // Return the built Widget.
    return builtWidget;
  }

  /// Handles a given [NanoRead] by subscribing to it if necessary, marking it
  /// as read and returning its current value.
  T _watchReadable<T>(
    NanoRead<T> nanoRead,
    Set<NanoRead> reads,
    Map<NanoRead, void Function()> newSubscriptions,
  ) {
    // Check if the widget already subscribes to the given nanoRead.
    if (!subscriptions.containsKey(nanoRead)) {
      // If not, a new subscription is created and _onChange is called when a
      // change occurs.
      newSubscriptions[nanoRead] = nanoRead.subscribe(_onChange);
    }

    // Mark nanoRead as read by adding it to reads.
    reads.add(nanoRead);

    // Return the current value of nanoRead.
    return nanoRead.value;
  }

  /// Unsubscribes and remove all subscriptions that are not in `reads`.
  void _cleanSubscriptions(Set<NanoRead> reads) {
    // Process each subscription and remove certain subscriptions if necessary.
    subscriptions.removeWhere((nanoRead, unsubscribe) {
      // Check if the current nanoRead has been marked as read.
      if (reads.contains(nanoRead)) {
        // If so, return false to keep the subscription.
        return false;
      } else {
        // If not, call unsubscribe.
        unsubscribe();

        // Return true to remove the subscription.
        return true;
      }
    });
  }

  /// Callback for when a change has occured.
  void _onChange<T>(T oldValue, T newValue) {
    setState(() {
      // Do nothing.
      // build handles all the bookkeeping.
    });
  }
}
