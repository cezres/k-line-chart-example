import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_controller.dart';
import 'package:k_line_chart_example/modules/trade/spot/kline/kline_configs.dart';

class KlineGestureDetector extends StatefulWidget {
  const KlineGestureDetector({
    super.key,
    required this.controller,
    required this.child,
  });

  final KlineController controller;
  final Widget child;

  @override
  State<KlineGestureDetector> createState() => _KlineGestureDetectorState();
}

class _KlineGestureDetectorState extends State<KlineGestureDetector> with TickerProviderStateMixin {
  late final AnimationController _controller;

  double? _velocity;
  Offset _startOffset = const Offset(0, 0);
  double _tempScrollOffset = 0;

  double _tempSegmentWidth = 0;
  Offset? _tempTapDownPosition;

  double get segmentWidth => widget.controller.data.segmentWidth;
  set segmentWidth(double width) {
    widget.controller.setSegmentWidth(width);
  }

  double get scrollOffset => widget.controller.data.scrollOffset;
  set scrollOffset(double offset) {
    widget.controller.scroll(offset);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _controller.addListener(() {
      if (_velocity == null) {
        return;
      }
      final scrollOffset = _tempScrollOffset + _velocity! * _controller.value;
      if (!setNewScrollOffset(scrollOffset)) {
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;
    if (kIsWeb) {
      child = _listenPointerSignal(child);
    } else {
      child = _listenGestureDetector(child);
    }
    if (kIsWeb || Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      child = _listenMouseRegion(child);
    }
    return child;
  }

  PointerScrollMode _pointerScrollMode = PointerScrollMode.none;
  int _pointerScrollEventTimestamp = 0;
  int _pointerScrollModeChangeCount = 0;

  void _handleDesktopScrolll(double dx, double dy, int timeStamp) {
    /// 当前数据模式
    final mode = dx.abs() >= dy.abs() ? PointerScrollMode.scroll : PointerScrollMode.scale;

    /// 重置
    final timestamp = timeStamp;
    if (timestamp - _pointerScrollEventTimestamp > 100) {
      _pointerScrollMode = mode;
    }
    _pointerScrollEventTimestamp = timestamp;

    if (_pointerScrollMode != mode) {
      _pointerScrollModeChangeCount++;
      if (_pointerScrollModeChangeCount > 3) {
        _pointerScrollMode = mode;
        _pointerScrollModeChangeCount = 0;
      }
    }

    if (_pointerScrollMode == PointerScrollMode.scroll) {
      setNewScrollOffset(scrollOffset - dx);
    } else if (_pointerScrollMode == PointerScrollMode.scale) {
      final width = segmentWidth * (1 - dy / 200);
      setNewSegmentWidth(width);
    }
  }

  Widget _listenPointerSignal(Widget child) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _handleDesktopScrolll(
            event.scrollDelta.dx,
            event.scrollDelta.dy,
            event.timeStamp.inMilliseconds,
          );
        }
      },
      child: child,
    );
  }

  Widget _listenMouseRegion(Widget child) {
    return MouseRegion(
      onEnter: (event) {
        widget.controller.mouse(event.localPosition);
      },
      onHover: (event) {
        widget.controller.mouse(event.localPosition);
      },
      onExit: (event) {
        widget.controller.mouse(const Offset(-1, -1));
      },
      child: child,
    );
  }

  Widget _listenGestureDetector(Widget child) {
    void Function(TapDownDetails)? onTapDown;
    void Function()? onTapUp;

    if (kIsWeb) {
      //
    } else if (Platform.isIOS || Platform.isAndroid) {
      onTapDown = (details) {
        _tempTapDownPosition = details.localPosition;
      };
      onTapUp = () {
        if (_tempTapDownPosition != null) {
          widget.controller.mouse(_tempTapDownPosition!);
        }
        _controller.stop();
      };
    }

    return GestureDetector(
      onTap: onTapUp,
      onTapDown: onTapDown,
      onScaleStart: (details) {
        _pointerScrollMode = PointerScrollMode.none;
        _velocity = null;
        _startOffset = details.localFocalPoint;
        _tempScrollOffset = scrollOffset;
        _tempSegmentWidth = segmentWidth;
        _controller.stop();
        if (kIsWeb) {
          //
        } else if (Platform.isIOS || Platform.isAndroid) {
          widget.controller.mouse(const Offset(-1, -1));
        }
      },
      onScaleUpdate: (details) {
        final dx = details.localFocalPoint.dx - _startOffset.dx;
        final dy = details.localFocalPoint.dy - _startOffset.dy;

        if (_pointerScrollMode == PointerScrollMode.none) {
          /// 当前数据模式
          if (Platform.isIOS || Platform.isAndroid) {
            _pointerScrollMode = details.verticalScale == 1 ? PointerScrollMode.scroll : PointerScrollMode.scale;
          } else {
            final mode = dx.abs() >= dy.abs() ? PointerScrollMode.scroll : PointerScrollMode.scale;
            _pointerScrollMode = mode;
          }
        }

        if (Platform.isIOS || Platform.isAndroid) {
          if (_pointerScrollMode == PointerScrollMode.scale) {
            setNewSegmentWidth(_tempSegmentWidth * details.verticalScale);
          } else {
            setNewScrollOffset(_tempScrollOffset + dx);
          }
        } else {
          if (_pointerScrollMode == PointerScrollMode.scroll) {
            setNewScrollOffset(_tempScrollOffset + dx);
          } else {
            final width = 10 * (dy / 400);
            setNewSegmentWidth(_tempSegmentWidth + width);
          }
        }
      },
      onScaleEnd: (details) {
        _velocity = details.velocity.pixelsPerSecond.dx * 0.8;
        if (_velocity != 0) {
          _tempScrollOffset = scrollOffset;
          _controller.reset();
          _controller.animateTo(1, curve: Curves.easeOut);
        }
      },
      child: widget.child,
    );
  }

  bool setNewScrollOffset(double offset) {
    if (offset > -KlineConfigs.rightScrollOffset) {
      scrollOffset = offset;
      return true;
    } else if (offset != -KlineConfigs.rightScrollOffset) {
      scrollOffset = -KlineConfigs.rightScrollOffset;
      return false;
    } else {
      return false;
    }
  }

  bool setNewSegmentWidth(double width) {
    // debugPrint("setNewSegmentWidth: $width");
    if (width > KlineConfigs.maxScaleSegmentWidth) {
      if (segmentWidth != KlineConfigs.maxScaleSegmentWidth) {
        segmentWidth = KlineConfigs.maxScaleSegmentWidth;
      }
      return false;
    } else if (width < KlineConfigs.minScaleSegmentWidth) {
      if (segmentWidth != KlineConfigs.minScaleSegmentWidth) {
        segmentWidth = KlineConfigs.minScaleSegmentWidth;
      }
      return false;
    } else {
      segmentWidth = width;
      return true;
    }
  }
}

enum PointerScrollMode {
  none,
  scroll,
  scale,
}
