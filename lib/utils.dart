import 'package:flutter/material.dart';

Widget pad(el, {factor = 1.0}) {
  return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: factor * 16.0, vertical: 16.0 * factor),
      child: el);
}

Widget padx(el, {factor = 1.0}) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: factor * 8.0, vertical: 0.0),
      child: el);
}

Widget pady(el, {factor = 1.0}) {
  return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 16.0 * factor),
      child: el);
}

class FadeInPageRoute<T> extends PageRoute<T> {
  FadeInPageRoute({
    required this.child,
    this.duration = const Duration(milliseconds: 200),
    this.color = Colors.black54,
  });

  Duration duration = Duration(milliseconds: 200);
  Color color = Colors.black54;
  @override
  // TODO: implement barrierColor
  Color get barrierColor => color;

  @override
  String get barrierLabel => "";

  final Widget child;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => duration;
}
