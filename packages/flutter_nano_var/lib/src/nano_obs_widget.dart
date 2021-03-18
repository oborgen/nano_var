import 'package:flutter/widgets.dart';
import 'package:flutter_nano_var/flutter_nano_var.dart';
import 'package:nano_var/nano_var.dart';

/// A widget that can be used to listen to changes to [NanoRead] instances and
/// will rebuild itself when any change occurs.
///
/// Users have to override the method `build` to use the widget.
abstract class NanoObsWidget extends StatefulWidget {
  /// Creates a [NanoObsWidget] with an optional key.
  const NanoObsWidget({
    Key? key,
  }) : super(key: key);

  /// Builds the widget and provides the function `watch`, which can be used to
  /// read the values of [NanoRead] instances and subscribe to changes to those
  /// values.
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

  /// Creates a [_NanoObsWidgetState] without any subscriptions.
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

    // Declare a boolean to keep track of whether or not build has returned.
    bool buildReturned = false;

    // Call build to build the widget.
    final builtWidget = widget.build(context, <T>(NanoRead<T> nanoRead) {
      // Check if build already has returned.
      if (buildReturned) {
        // Throw an exception if that's the case.
        throw const InvalidWatchCallException();
      }

      // Call _watchReadable.
      return _watchReadable(nanoRead, reads, newSubscriptions);
    });

    // Set buildReturned to true, since build has returned.
    buildReturned = true;

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
