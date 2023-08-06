import 'package:flutter/material.dart';

class OverlayManager {
  Map<String, OverlayEntry> overlays = {};

  void pushOverlay(BuildContext context, OverlayEntry overlay, String name) {
    if (overlays.containsKey(name)) {
      popOverlay(context, name);
    }
    Overlay.of(context)!.insert(overlay);

    overlays[name] = overlay;
  }

  void popOverlay(BuildContext context, String name) {
    if (overlays.containsKey(name)) {
      overlays[name]!.remove();
      overlays.remove(name);
    }
  }

  void popAllOverlays(BuildContext context) {
    overlays.forEach((key, value) {
      value.remove();
    });
    overlays = {};
  }
}
