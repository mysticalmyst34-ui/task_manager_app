import 'package:flutter/material.dart';

class NotificationService {
  static void showPriorityNotification({
    required String title,
    required String body,
    required String priority,
  }) {
    // For now, we just log it (safe for web & debug)
    debugPrint('[NOTIFICATION][$priority] $title - $body');
  }
}
