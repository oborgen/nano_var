import 'package:flutter/widgets.dart';
import 'package:nano_var/nano_var.dart';

import 'nano_obs_widget.dart';

/// A widget that can be used to listen to changes to [NanoRead] instances and
/// will rebuild itself when any change occurs.
///
/// The parameter [builder] is used to build the widget.
class NanoObs extends NanoObsWidget {
  /// A builder that builds the widget and provides the function [watch],
  /// which can be used to read the values of [NanoRead] instances and
  /// subscribe to changes to those values.
  final Widget Function(
    BuildContext context,
    T Function<T>(NanoRead<T> readable) watch,
  ) builder;

  /// Creates a [NanoObsWidget] with a mandatory [builder] and an optional key.
  ///
  /// [builder] builds the widget and provides the function [watch], which can
  /// be used to read the values of [NanoRead] instances and subscribe to
  /// changes to those values.
  const NanoObs({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(
    BuildContext context,
    T Function<T>(NanoRead<T> readable) watch,
  ) {
    // Call builder with the BuildContext and watch function and return the
    // resulting Widget.
    return builder(context, watch);
  }
}
