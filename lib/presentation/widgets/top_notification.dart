import 'dart:async';
import 'package:flutter/material.dart';

/// 顶部通知组件
/// 从屏幕顶部弹出的横幅通知，3秒后自动消失
class TopNotification {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  /// 显示顶部通知
  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    hide();

    final overlay = Overlay.of(context);
    
    _currentEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -1.0, end: 0.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, value * 100),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_currentEntry!);

    _timer?.cancel();
    _timer = Timer(duration, () {
      hide();
    });
  }

  static void success(BuildContext context, String message) {
    show(context, message, isSuccess: true);
  }

  static void error(BuildContext context, String message) {
    show(context, message, isSuccess: false);
  }

  static void hide() {
    _timer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;
  }
}
