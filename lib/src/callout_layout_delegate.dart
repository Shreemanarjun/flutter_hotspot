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
    required this.context,
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
  final BuildContext context;

  // Cached values for performance
  late final bool targetIsAboveCenter =
      targetBounds.center.dy < paintBounds.height / 2;
  late final Rect _deflatedPaintBounds = bodyMargin.deflateRect(paintBounds);

  Rect get hotspotBounds {
    if (hotspotSize != null) {
      return _calculateHotspotBoundsWithSize();
    } else {
      return _calculateHotspotBoundsForDevice();
    }
  }

  Rect _calculateHotspotBoundsWithSize() {
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
  }

  Rect _calculateHotspotBoundsForDevice() {
    final double devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool isTablet = _isTablet(screenSize);
    final bool hasNotch = _hasNotch(context);

    // Adjust target bounds based on device characteristics
    Rect adjustedTargetBounds = targetBounds.shift(hotspotOffset);

    if (isTablet) {
      // Increase padding for tablets
      adjustedTargetBounds = adjustedTargetBounds.inflate(20.0);
    }

    if (hasNotch) {
      // Additional adjustment for notched devices
      adjustedTargetBounds = adjustedTargetBounds.inflate(15.0);
    }

    if (devicePixelRatio > 2.0) {
      // Extra padding for high-density screens
      adjustedTargetBounds = adjustedTargetBounds.inflate(10.0);
    }

    return hotspotPadding.inflateRect(adjustedTargetBounds);
  }

// Helper method to determine if the device is a tablet
  bool _isTablet(Size screenSize) {
    // This is a common approach, but you might want to fine-tune the logic
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final double width = screenSize.width / devicePixelRatio;
    final double height = screenSize.height / devicePixelRatio;

    // Typical tablet screen size threshold
    return width >= 600 || height >= 600;
  }

// Helper method to detect if the device has a notch
  bool _hasNotch(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Check for top padding (typically indicates a notch)
    return mediaQuery.padding.top > 20;
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
