import 'package:flutter/material.dart';

import '../design_system/am5_colors.dart';
import '../design_system/am5_spacing.dart';
import 'voice_search_service.dart';

typedef VoiceSearchResultHandler = void Function(String query);

/// Shows a bottom sheet, listens for speech, and returns the final transcript.
Future<String?> showVoiceSearchSheet(
  BuildContext context, {
  VoiceSearchResultHandler? onSubmit,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _VoiceSearchSheet(onSubmit: onSubmit),
  );
}

class _VoiceSearchSheet extends StatefulWidget {
  const _VoiceSearchSheet({this.onSubmit});

  final VoiceSearchResultHandler? onSubmit;

  @override
  State<_VoiceSearchSheet> createState() => _VoiceSearchSheetState();
}

class _VoiceSearchSheetState extends State<_VoiceSearchSheet>
    with SingleTickerProviderStateMixin {
  final _service = VoiceSearchService();
  late final AnimationController _pulse;
  String _transcript = '';
  String? _error;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    _pulse.dispose();
    _service.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() {
      _listening = true;
      _error = null;
      _transcript = '';
    });
    await _service.startListening(
      onResult: (text, isFinal) {
        if (!mounted) return;
        setState(() => _transcript = text.trim());
        if (isFinal && text.trim().isNotEmpty) {
          _finish(text.trim());
        }
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _error = message;
          _listening = false;
        });
      },
    );
  }

  Future<void> _finish(String query) async {
    await _service.stopListening();
    if (!mounted) return;
    widget.onSubmit?.call(query);
    Navigator.of(context).pop(query);
  }

  Future<void> _cancel() async {
    await _service.stopListening();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(Am5Spacing.lg),
      padding: const EdgeInsets.fromLTRB(
        Am5Spacing.lg,
        Am5Spacing.lg,
        Am5Spacing.lg,
        Am5Spacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Am5Colors.outline,
              borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
            ),
          ),
          const SizedBox(height: Am5Spacing.lg),
          Text(
            _listening ? 'Listening…' : 'Voice search',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: Am5Spacing.sm),
          Text(
            'Say a service, vendor, or category',
            style: theme.textTheme.bodySmall?.copyWith(color: Am5Colors.textSecondary),
          ),
          const SizedBox(height: Am5Spacing.xl),
          ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.08).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Am5Colors.brandRed, Am5Colors.deepRed],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Am5Colors.brandRed.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: Am5Spacing.lg),
          if (_error != null)
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            )
          else
            Text(
              _transcript.isEmpty ? 'Try: "pest control in Hyderabad"' : _transcript,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: _transcript.isEmpty ? FontWeight.w400 : FontWeight.w600,
                color: _transcript.isEmpty
                    ? Am5Colors.textSecondary
                    : Am5Colors.textPrimary,
              ),
            ),
          const SizedBox(height: Am5Spacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _cancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: Am5Spacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _transcript.trim().isEmpty
                      ? null
                      : () => _finish(_transcript.trim()),
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
