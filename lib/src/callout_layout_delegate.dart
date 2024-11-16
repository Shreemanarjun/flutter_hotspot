import 'package:flutter/widgets.dart';

class CalloutLayoutDelegate {
  CalloutLayoutDelegate({
    required this.paintBounds,
    required this.targetBounds,
    required this.hotspotPadding,
    required this.tailSize,
    required this.tailInsets,
    required this.bodyMargin,
    required this.bodyWidth,
    required this.hotspotSize,
    required this.hotspotOffset,
    required this.boxDecoration,
  });

  final Rect paintBounds;
  final Rect targetBounds;
  final EdgeInsets hotspotPadding;
  final EdgeInsets tailInsets;
  final Size tailSize;
  final EdgeInsets bodyMargin;
  final double bodyWidth;
  final Size? hotspotSize;
  final Offset hotspotOffset;
  final BoxDecoration? boxDecoration;

  // Cached values for performance
  late final bool targetIsAboveCenter =
      targetBounds.center.dy < paintBounds.height / 2;
  late final Rect _deflatedPaintBounds = bodyMargin.deflateRect(paintBounds);

  Rect get hotspotBounds {
    if (hotspotSize != null) {
      return hotspotPadding.inflateRect(
        Rect.fromCenter(
          center: targetBounds.center.translate(
            hotspotOffset.dx,
            hotspotOffset.dy,
          ),
          width: hotspotSize!.width,
          height: hotspotSize!.height,
        ),
      );
    } else {
      return hotspotPadding.inflateRect(targetBounds.shift(hotspotOffset));
    }
  }

  Rect get tailBounds {
    final inset = (hotspotPadding - tailInsets).inflateRect(targetBounds);
    Offset tailCenter;

    if (targetIsAboveCenter) {
      tailCenter = inset.bottomCenter.translate(
        hotspotOffset.dx,
        tailSize.height,
      );
    } else {
      tailCenter = inset.topCenter.translate(
        hotspotOffset.dx,
        -tailSize.height,
      );
    }

    return Rect.fromCenter(
      center: tailCenter,
      width: tailSize.width,
      height: tailSize.height * 2,
    );
  }

  Rect get bodyContainerBounds {
    final unpositionedBodyRect = Rect.fromCenter(
      center: tailBounds.center,
      width: bodyWidth,
      height: bodyContainerHeight,
    ).translateToFitX(_deflatedPaintBounds);

    return targetIsAboveCenter
        ? unpositionedBodyRect.translate(0, bodyContainerHeight / 2)
        : unpositionedBodyRect.translate(0, -bodyContainerHeight / 2);
  }

  double get bodyContainerHeight => paintBounds.height;
}

extension on Rect {
  Rect translateToFitX(Rect e) {
    assert(width <= e.width,
        'The parent Rect(width: ${e.width}) must be wider than this Rect(width:$width)');

    if (e.right < right) {
      return translate(-(e.right - right).abs(), 0);
    } else if (e.left > left) {
      return translate((e.left - left).abs(), 0);
    } else {
      return this;
    }
  }
}
