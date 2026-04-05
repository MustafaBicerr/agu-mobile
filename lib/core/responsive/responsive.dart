import 'package:flutter/widgets.dart';

class Responsive {
  const Responsive._();

  static double w(BuildContext context, double ratio) =>
      MediaQuery.sizeOf(context).width * ratio;

  static double h(BuildContext context, double ratio) =>
      MediaQuery.sizeOf(context).height * ratio;

  static double text(
    BuildContext context,
    double size, {
    double min = 11,
    double max = 24,
  }) {
    final scale = MediaQuery.textScalerOf(context).textScaleFactor;
    final value = size * scale;
    return value.clamp(min, max);
  }
}
