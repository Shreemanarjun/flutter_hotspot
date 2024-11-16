import 'package:flutter/widgets.dart';

class CalloutLayoutDelegate {
  /// Comprehensive layout delegate for callout positioning
  CalloutLayoutDelegate({
    required this.context,
    required this.paintBounds,
    required this.targetBounds,
    this.hotspotPadding = EdgeInsets.zero,
    this.tailInsets = EdgeInsets.zero,
    this.tailSize = const Size(20, 10),
    this.bodyMargin = const EdgeInsets.all(16),
    this.bodyWidth = 250.0,
    this.hotspotSize,
    this.hotspotOffset = Offset.zero,
    this.boxDecoration,
  }) {
    // Create positioning context
    _positioningContext = CalloutPositioningContext(
      context: context,
      paintBounds: paintBounds,
      targetBounds: targetBounds,
    );
  }

  /// Build context for additional layout calculations
  final BuildContext context;

  /// The boundary of the viewport where targets will be found
  final Rect paintBounds;

  /// The global boundary of the target to hotspot
  final Rect targetBounds;

  /// Positioning context for advanced calculations
  late final CalloutPositioningContext _positioningContext;

  /// The hotspot padding
  final EdgeInsets hotspotPadding;

  /// The margin between the hotspot and the tail
  final EdgeInsets tailInsets;

  /// The size of the callout tail
  final Size tailSize;

  /// The margin between the callout body and the viewport
  final EdgeInsets bodyMargin;

  /// The width of the callout body
  final double bodyWidth;

  /// Optional custom size for the hotspot
  final Size? hotspotSize;

  /// Custom offset for the hotspot center
  final Offset hotspotOffset;

  /// BoxDecoration for border of callout body
  final BoxDecoration? boxDecoration;
// Determines if the target is above the center of the paint bounds
  bool get targetIsAboveCenter {
    final positioningResult = _positioningContext.calculatePositioning();
    return positioningResult.isAboveCenter;
  }

  /// Advanced hotspot bounds calculation
  Rect get hotspotBounds {
    final positioningResult = _positioningContext.calculatePositioning();
    final adjustmentFactor = positioningResult.adjustmentFactor;

    if (hotspotSize != null) {
      return hotspotPadding.inflateRect(
        Rect.fromCenter(
          center: targetBounds.center.translate(
            hotspotOffset.dx * adjustmentFactor,
            hotspotOffset.dy * adjustmentFactor,
          ),
          width: hotspotSize!.width * adjustmentFactor,
          height: hotspotSize!.height * adjustmentFactor,
        ),
      );
    } else {
      return hotspotPadding.inflateRect(targetBounds
          .shift(hotspotOffset.scale(adjustmentFactor, adjustmentFactor)));
    }
  }

  /// Enhanced tail bounds calculation
  Rect get tailBounds {
    final positioningResult = _positioningContext.calculatePositioning();

    // Calculate the tail point inset
    final inset = (hotspotPadding - tailInsets).inflateRect(targetBounds);

    // Determine tail position based on positioning result
    final tailCenter = positioningResult.isAboveCenter
        ? inset.bottomCenter.translate(0, tailSize.height)
        : inset.topCenter.translate(0, -tailSize.height);

    // Apply device-specific adjustment
    final adjustmentFactor = positioningResult.adjustmentFactor;

    return Rect.fromCenter(
      center: tailCenter,
      width: tailSize.width * adjustmentFactor,
      height: tailSize.height * adjustmentFactor * 2,
    );
  }

  /// Advanced body container bounds calculation
  Rect get bodyContainerBounds {
    final positioningResult = _positioningContext.calculatePositioning();
    final adjustmentFactor = positioningResult.adjustmentFactor;

    // Calculate deflated paint bounds
    final deflatedPaintBounds = bodyMargin.deflateRect(paintBounds);

    // Calculate body container dimensions
    final bodyContainerHeight = paintBounds.height * adjustmentFactor;
    final adjustedBodyWidth = bodyWidth * adjustmentFactor;

    // Create unpositioned body rect
    final unpositionedBodyRect = Rect.fromCenter(
      center: tailBounds.center,
      width: adjustedBodyWidth,
      height: bodyContainerHeight,
    ).translateToFitX(deflatedPaintBounds);

    // Vertical positioning based on target position
    if (positioningResult.isAboveCenter) {
      return unpositionedBodyRect.translate(0, bodyContainerHeight / 2);
    } else {
      return unpositionedBodyRect.translate(0, -bodyContainerHeight / 2);
    }
  }

  // Calculates the dynamic body container height
  double get bodyContainerHeight {
    final positioningResult = _positioningContext.calculatePositioning();
    final adjustmentFactor = positioningResult.adjustmentFactor;

    // Base height calculation
    double baseHeight = paintBounds.height * adjustmentFactor;

    // Apply device-specific height adjustments
    switch (_positioningContext.deviceType) {
      case DeviceType.tablet:
        // Slightly taller for tablets
        baseHeight *= 1.1;
        break;
      case DeviceType.notchedDevice:
        // Adjust for devices with notches
        baseHeight -= _positioningContext.systemPadding.top;
        break;
      case DeviceType.phone:
      default:
        break;
    }

    // Orientation-based height adjustment
    if (_positioningContext.orientation == Orientation.landscape) {
      baseHeight *= 0.9; // Reduce height in landscape
    }

    // Ensure minimum and maximum height
    return baseHeight.clamp(
        paintBounds.height * 0.3, // Minimum 30% of paint bounds
        paintBounds.height * 0.8 // Maximum 80% of paint bounds
        );
  }

  /// Provides a proportional height calculation with custom scaling
  double calculateProportionalHeight({
    double minHeightFactor = 0.3,
    double maxHeightFactor = 0.8,
    double? customScaleFactor,
  }) {
    final positioningResult = _positioningContext.calculatePositioning();
    final adjustmentFactor = positioningResult.adjustmentFactor;

    // Base height calculation
    double baseHeight = paintBounds.height * adjustmentFactor;

    // Apply custom scaling if provided
    if (customScaleFactor != null) {
      baseHeight *= customScaleFactor;
    }

    // Device-specific adjustments
    switch (_positioningContext.deviceType) {
      case DeviceType.tablet:
        baseHeight *= 1.1;
        break;
      case DeviceType.notchedDevice:
        baseHeight -= _positioningContext.systemPadding.top;
        break;
      default:
        break;
    }

    // Orientation adjustment
    if (_positioningContext.orientation == Orientation.landscape) {
      baseHeight *= 0.9;
    }

    // Constrain height
    return baseHeight.clamp(paintBounds.height * minHeightFactor,
        paintBounds.height * maxHeightFactor);
  }

  /// Comprehensive layout information
  CalloutLayoutInfo getLayoutInfo() {
    final positioningResult = _positioningContext.calculatePositioning();

    return CalloutLayoutInfo(
      hotspotBounds: hotspotBounds,
      tailBounds: tailBounds,
      bodyContainerBounds: bodyContainerBounds,
      positioningResult: positioningResult,
      deviceType: _positioningContext.deviceType,
    );
  }
}

/// Comprehensive layout information container
class CalloutLayoutInfo {
  final Rect hotspotBounds;
  final Rect tailBounds;
  final Rect bodyContainerBounds;
  final PositioningResult positioningResult;
  final DeviceType deviceType;

  CalloutLayoutInfo({
    required this.hotspotBounds,
    required this.tailBounds,
    required this.bodyContainerBounds,
    required this.positioningResult,
    required this.deviceType,
  });

  /// Convenience method for debugging
  @override
  String toString() {
    return '''
    CalloutLayoutInfo:
    - Hotspot Bounds: $hotspotBounds
    - Tail Bounds: $tailBounds
    - Body Container Bounds: $bodyContainerBounds
    - Positioning: $positioningResult
    - Device Type: $deviceType
    ''';
  }
}

/// Utility extension for rect translation
extension RectTranslationExtension on Rect {
  /// Translate this Rect horizontally to fit inside another Rect
  /// Translate this Rect horizontally to fit inside another Rect with more flexible handling
  Rect translateToFitX(Rect container) {
    // If the current rect is wider than the container, adjust proportionally
    if (width > container.width) {
      // Calculate scale factor to fit width
      final scaleFactor = container.width / width;

      // Create new rect scaled to container width
      return Rect.fromCenter(
              center: center,
              width: container.width,
              height: height * scaleFactor)
          .translate(container.left - left, 0);
    }

    // Calculate horizontal translation
    double translationX = 0;
    if (left < container.left) {
      // Shift right if left edge is outside container
      translationX = container.left - left;
    } else if (right > container.right) {
      // Shift left if right edge is outside container
      translationX = container.right - right;
    }

    return translate(translationX, 0);
  }
}

enum DeviceType { phone, tablet, notchedDevice }

class CalloutPositioningContext {
  final BuildContext context;
  final Rect paintBounds;
  final Rect targetBounds;

  // Device-specific parameters
  final DeviceType deviceType;
  final Orientation orientation;
  final double devicePixelRatio;
  final EdgeInsets systemPadding;

  CalloutPositioningContext({
    required this.context,
    required this.paintBounds,
    required this.targetBounds,
    DeviceType? deviceType,
    Orientation? orientation,
    double? devicePixelRatio,
    EdgeInsets? systemPadding,
  })  : deviceType = deviceType ?? _determineDeviceType(context),
        orientation = orientation ?? MediaQuery.of(context).orientation,
        devicePixelRatio =
            devicePixelRatio ?? MediaQuery.of(context).devicePixelRatio,
        systemPadding = systemPadding ?? MediaQuery.of(context).padding;

  // Comprehensive device type determination
  static DeviceType _determineDeviceType(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // Screen size calculation (accounting for pixel ratio)
    final width = screenSize.width / devicePixelRatio;
    final height = screenSize.height / devicePixelRatio;

    // Notch detection
    final topPadding = mediaQuery.padding.top;
    final hasNotch = topPadding > 20; // Typical notch indicator

    // Tablet detection (adjust thresholds as needed)
    final isTablet = (width >= 600 || height >= 600);

    if (hasNotch) return DeviceType.notchedDevice;
    if (isTablet) return DeviceType.tablet;
    return DeviceType.phone;
  }

  // Advanced positioning calculation
  PositioningResult calculatePositioning() {
    // Base midpoint calculation
    double baseMidPoint = paintBounds.height / 2;
    double adjustedMidPoint = _calculateAdjustedMidPoint(baseMidPoint);

    // Tolerance calculation
    final tolerance = adjustedMidPoint * 0.1;

    // Determine vertical position
    final isAboveCenter =
        targetBounds.center.dy < (adjustedMidPoint + tolerance);

    return PositioningResult(
      isAboveCenter: isAboveCenter,
      deviceType: deviceType,
      midPointOffset: adjustedMidPoint,
      adjustmentFactor: _calculateAdjustmentFactor(),
    );
  }

  // Midpoint adjustment logic
  double _calculateAdjustedMidPoint(double baseMidPoint) {
    double adjustedMidPoint = baseMidPoint;

    switch (deviceType) {
      case DeviceType.tablet:
        // Shift midpoint for tablets
        adjustedMidPoint *= 1.1; // 10% adjustment
        break;
      case DeviceType.notchedDevice:
        // Compensate for notch
        adjustedMidPoint += systemPadding.top / devicePixelRatio;
        break;
      case DeviceType.phone:
      default:
        break;
    }

    // Orientation-based adjustments
    if (orientation == Orientation.landscape) {
      adjustedMidPoint *= 0.95; // Slight landscape adjustment
    }

    return adjustedMidPoint;
  }

  // Adjustment factor calculation
  double _calculateAdjustmentFactor() {
    switch (deviceType) {
      case DeviceType.tablet:
        return 1.1;
      case DeviceType.notchedDevice:
        return 1.05;
      case DeviceType.phone:
      default:
        return 1.0;
    }
  }

  // Advanced positioning strategy
  Rect calculatePositionedRect({
    required double width,
    required double height,
    required Offset offset,
  }) {
    final positioning = calculatePositioning();
    final adjustmentFactor = positioning.adjustmentFactor;

    // Base rect calculation
    Rect baseRect = Rect.fromCenter(
      center: targetBounds.center.translate(offset.dx, offset.dy),
      width: width * adjustmentFactor,
      height: height * adjustmentFactor,
    );

    // Vertical positioning adjustment
    if (positioning.isAboveCenter) {
      baseRect = baseRect.translate(0, -height * 0.5);
    } else {
      baseRect = baseRect.translate(0, height * 0.5);
    }

    return baseRect;
  }
}

// Positioning result encapsulation
class PositioningResult {
  final bool isAboveCenter;
  final DeviceType deviceType;
  final double midPointOffset;
  final double adjustmentFactor;

  PositioningResult({
    required this.isAboveCenter,
    required this.deviceType,
    required this.midPointOffset,
    required this.adjustmentFactor,
  });

  // Convenience getters
  bool get needsSpecialHandling => deviceType != DeviceType.phone;

  // Debugging and logging
  @override
  String toString() {
    return 'PositioningResult('
        'isAboveCenter: $isAboveCenter, '
        'deviceType: $deviceType, '
        'midPointOffset: $midPointOffset, '
        'adjustmentFactor: $adjustmentFactor)';
  }
}
