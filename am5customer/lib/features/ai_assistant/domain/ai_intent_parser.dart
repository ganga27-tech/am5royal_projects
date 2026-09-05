import 'package:am5_core/am5_core.dart';

import 'ai_booking_context.dart';

enum AiUserIntent {
  greeting,
  search,
  selectService,
  selectVendor,
  selectCheapest,
  selectFirst,
  selectByIndex,
  setDate,
  setTime,
  confirm,
  cancel,
  showBookings,
  reset,
  help,
  unknown,
}

class ParsedUserMessage {
  const ParsedUserMessage({
    required this.intent,
    this.searchQuery,
    this.serviceIndex,
    this.vendorIndex,
    this.date,
    this.timeWindow,
    this.slotHour,
    this.isCheapest = false,
  });

  final AiUserIntent intent;
  final String? searchQuery;
  final int? serviceIndex;
  final int? vendorIndex;
  final DateTime? date;
  final AiTimeWindow? timeWindow;
  final int? slotHour;
  final bool isCheapest;
}

abstract final class AiIntentParser {
  static ParsedUserMessage parse(String raw, {AiBookingContext? context}) {
    final text = raw.trim();
    final lower = _normalize(text);

    if (_isGreeting(lower)) {
      return const ParsedUserMessage(intent: AiUserIntent.greeting);
    }
    if (_isConfirm(lower)) {
      return const ParsedUserMessage(intent: AiUserIntent.confirm);
    }
    if (_isCancel(lower)) {
      return const ParsedUserMessage(intent: AiUserIntent.cancel);
    }
    if (_isShowBookings(lower)) {
      return const ParsedUserMessage(intent: AiUserIntent.showBookings);
    }
    if (_isReset(lower)) {
      return const ParsedUserMessage(intent: AiUserIntent.reset);
    }

    final serviceIndex = _parseIndex(lower, context?.serviceCandidates.length ?? 0);
    if (serviceIndex != null && (context?.serviceCandidates.isNotEmpty ?? false)) {
      return ParsedUserMessage(intent: AiUserIntent.selectService, serviceIndex: serviceIndex);
    }

    final vendorIndex = _parseIndex(lower, context?.vendorOptions.length ?? 0);
    if (vendorIndex != null && (context?.vendorOptions.isNotEmpty ?? false)) {
      return ParsedUserMessage(
        intent: _isCheapest(lower) ? AiUserIntent.selectCheapest : AiUserIntent.selectVendor,
        vendorIndex: vendorIndex,
        isCheapest: _isCheapest(lower),
      );
    }

    if (_isCheapest(lower) && (context?.vendorOptions.isNotEmpty ?? false)) {
      return const ParsedUserMessage(intent: AiUserIntent.selectCheapest, isCheapest: true);
    }
    if (_isFirst(lower) && (context?.vendorOptions.isNotEmpty ?? false)) {
      return const ParsedUserMessage(intent: AiUserIntent.selectFirst);
    }
    if (_isFirst(lower) && (context?.serviceCandidates.isNotEmpty ?? false)) {
      return ParsedUserMessage(intent: AiUserIntent.selectService, serviceIndex: 0);
    }

    final date = _parseDate(lower);
    final timeWindow = _parseTimeWindow(lower);
    final slotHour = _parseHour(lower);

    if (date != null && timeWindow == null && slotHour == null && !_hasServiceKeywords(lower)) {
      return ParsedUserMessage(intent: AiUserIntent.setDate, date: date);
    }
    if ((timeWindow != null || slotHour != null) && !_hasServiceKeywords(lower)) {
      return ParsedUserMessage(
        intent: AiUserIntent.setTime,
        timeWindow: timeWindow,
        slotHour: slotHour,
        date: date,
      );
    }

    final query = _buildSearchQuery(lower, text);
    return ParsedUserMessage(
      intent: AiUserIntent.search,
      searchQuery: query,
      date: date,
      timeWindow: timeWindow,
      slotHour: slotHour,
      isCheapest: _isCheapest(lower),
    );
  }

  static String _normalize(String text) => text.toLowerCase().trim();

  static bool _isGreeting(String lower) =>
      RegExp(r'^(hi|hello|hey|namaste|namaskaram)\b').hasMatch(lower);

  static bool _isConfirm(String lower) =>
      RegExp(r'^(yes|yeah|yep|ok|okay|confirm|book it|book that|proceed|cheppu|avunu|sare)\b')
          .hasMatch(lower) ||
      lower == 'ha' ||
      lower.contains('confirm booking');

  static bool _isCancel(String lower) =>
      RegExp(r'^(no|cancel|stop|abort|vaddu|ledu)\b').hasMatch(lower);

  static bool _isShowBookings(String lower) =>
      lower.contains('my booking') ||
      lower.contains('show booking') ||
      lower.contains('booking status');

  static bool _isReset(String lower) =>
      lower.contains('start over') || lower.contains('new booking');

  static bool _isCheapest(String lower) =>
      lower.contains('cheap') || lower.contains('budget') || lower.contains('lowest');

  static bool _isFirst(String lower) =>
      lower.contains('first one') ||
      lower.contains('first option') ||
      lower == 'first' ||
      lower.contains('option 1');

  static int? _parseIndex(String lower, int max) {
    if (max == 0) return null;
    final digit = RegExp(r'\b([1-9])\b').firstMatch(lower);
    if (digit != null) {
      final idx = int.parse(digit.group(1)!) - 1;
      if (idx >= 0 && idx < max) return idx;
    }
    if (lower.contains('second') && max > 1) return 1;
    if (lower.contains('third') && max > 2) return 2;
    return null;
  }

  static bool _hasServiceKeywords(String lower) =>
      lower.contains('ac') ||
      lower.contains('clean') ||
      lower.contains('electric') ||
      lower.contains('plumb') ||
      lower.contains('pest') ||
      lower.contains('service') ||
      lower.contains('kavali') ||
      lower.contains('repair');

  static String _buildSearchQuery(String lower, String original) {
    if (lower.contains('ac') || lower.contains('cooling') || lower.contains('air conditioner')) {
      if (lower.contains('deep') || lower.contains('clean')) return 'AC deep cleaning';
      if (lower.contains('repair') || lower.contains('cooling') || lower.contains('cool')) {
        return 'AC repair cooling';
      }
      return 'AC service';
    }
    if (lower.contains('clean') || lower.contains('cleaning')) return 'home deep cleaning';
    if (lower.contains('electric')) return 'electrician';
    if (lower.contains('plumb')) return 'plumbing';
    if (lower.contains('pest')) return 'pest control';
    if (lower.contains('pet')) return 'pet care';
    if (lower.contains('beauty') || lower.contains('spa') || lower.contains('salon')) {
      return 'beauty salon';
    }
    return original;
  }

  static DateTime? _parseDate(String lower) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (lower.contains('day after tomorrow') || lower.contains('repu repu')) {
      return today.add(const Duration(days: 2));
    }
    if (lower.contains('tomorrow') || lower.contains('repu')) {
      return today.add(const Duration(days: 1));
    }
    if (lower.contains('today') || lower.contains('ee roju') || lower.contains('tonight')) {
      return today;
    }
    if (lower.contains('weekend')) {
      var daysUntilSat = DateTime.saturday - now.weekday;
      if (daysUntilSat <= 0) daysUntilSat += 7;
      return today.add(Duration(days: daysUntilSat));
    }
    return null;
  }

  static AiTimeWindow? _parseTimeWindow(String lower) {
    if (lower.contains('morning') || lower.contains('morning lo')) return AiTimeWindow.morning;
    if (lower.contains('afternoon')) return AiTimeWindow.afternoon;
    if (lower.contains('evening') || lower.contains('evening lo')) return AiTimeWindow.evening;
    if (lower.contains('night') || lower.contains('tonight')) return AiTimeWindow.night;
    return null;
  }

  static int? _parseHour(String lower) {
    final pm = lower.contains('pm') || lower.contains('evening');
    final am = lower.contains('am') || lower.contains('morning');
    final match = RegExp(r'\b(\d{1,2})\s*(pm|am|ki)?\b').firstMatch(lower);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    if (pm && hour < 12) hour += 12;
    if (am && hour == 12) hour = 0;
    if (!pm && !am && hour <= 8) hour += 12;
    return hour.clamp(0, 23);
  }

  static List<BookingSlot> filterSlotsByWindow(
    List<BookingSlot> slots,
    AiTimeWindow? window, {
    int? hour,
  }) {
    if (hour != null) {
      return slots.where((s) => s.start.hour == hour || (s.start.hour - hour).abs() <= 1).toList();
    }
    if (window == null) return slots;
    return slots.where((s) {
      final h = s.start.hour;
      return switch (window) {
        AiTimeWindow.morning => h >= 8 && h < 12,
        AiTimeWindow.afternoon => h >= 12 && h < 17,
        AiTimeWindow.evening => h >= 17 && h < 21,
        AiTimeWindow.night => h >= 21 || h < 8,
      };
    }).toList();
  }
}
