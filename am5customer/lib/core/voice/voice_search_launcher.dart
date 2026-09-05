import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'voice_search_sheet.dart';

/// Starts voice capture and routes to search (or returns text to caller).
abstract final class VoiceSearchLauncher {
  static Future<void> openSearch(BuildContext context) async {
    final query = await showVoiceSearchSheet(context);
    if (!context.mounted || query == null || query.trim().isEmpty) return;
    final encoded = Uri.encodeComponent(query.trim());
    context.go('/search?q=$encoded');
  }

  static Future<String?> capture(BuildContext context) {
    return showVoiceSearchSheet(context);
  }
}
