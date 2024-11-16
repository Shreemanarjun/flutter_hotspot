import 'package:flutter/material.dart';
import 'package:hotspot/hotspot.dart';

extension HotspotExt on Widget {
  /// Wrap this widget with a branded [HotspotTarget]
  Widget withCustomHotspot({
    String flow = 'main',
    required num order,
    required Widget showCaseWidget,
    Size? hotspotSize,
    BoxDecoration? boxDecoration,
    Offset hotspotOffset = Offset.zero,
  }) {
    return Builder(
      builder: (context) {
        return HotspotTarget(
          flow: flow,
          hotspotSize: hotspotSize,
          hotspotOffset: hotspotOffset,
          order: order,
          calloutBody: showCaseWidget,
          boxDecoration: boxDecoration,
          child: this,
        );
      },
    );
  }
}
