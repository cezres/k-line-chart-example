import 'package:flutter/material.dart';

final class CustomChartAnimationController {
  CustomChartAnimationController();

  AnimationController? _controller;
  CurvedAnimation? _animation;
  void Function(double progress)? _listener;

  void stop() {
    _animation?.removeListener(_listen);
    _animation?.dispose();
    _controller?.stop();
    // ignore: invalid_use_of_protected_member
    _controller?.clearListeners();
  }

  void run(
      AnimationController controller, void Function(double progress) listener) {
    _listener = listener;

    // ignore: invalid_use_of_protected_member
    controller.clearListeners();
    controller.addListener(_listen);

    _controller = controller;
    _controller?.reset();
    _controller?.animateTo(
      1,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
    );
  }

  void _listen() {
    _listener?.call(_controller?.value ?? 0);
  }
}
