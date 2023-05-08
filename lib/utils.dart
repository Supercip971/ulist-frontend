import 'package:flutter/material.dart';

Widget pad(el, {factor = 1.0}) {
  return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: factor * 8.0, vertical: 16.0 * factor),
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
