import 'package:flutter/material.dart';

import '../../../../core/design_system/am5_colors.dart';
import '../../../../core/design_system/am5_spacing.dart';
import '../models/vendor_catalog_groups.dart';

/// Floating category picker for vendors with multiple main categories.
class VendorCategoryFab extends StatefulWidget {
  const VendorCategoryFab({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<VendorMainCategoryGroup> categories;
  final String? selectedId;
  final ValueChanged<VendorMainCategoryGroup> onSelected;

  @override
  State<VendorCategoryFab> createState() => _VendorCategoryFabState();
}

class _VendorCategoryFabState extends State<VendorCategoryFab>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  VendorMainCategoryGroup? get _selected {
    for (final category in widget.categories) {
      if (category.id == widget.selectedId) return category;
    }
    return null;
  }

  void _toggle() {
    setState(() => _open = !_open);
    if (_open) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _close() {
    if (!_open) return;
    setState(() => _open = false);
    _controller.reverse();
  }

  void _pick(VendorMainCategoryGroup category) {
    widget.onSelected(category);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _selected;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withValues(alpha: 0.18)),
            ),
          ),
        Positioned(
          right: Am5Spacing.lg,
          bottom: Am5Spacing.lg,
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FadeTransition(
                  opacity: _fade,
                  child: ScaleTransition(
                    scale: _scale,
                    alignment: Alignment.bottomRight,
                    child: _CategoryPanel(
                      categories: widget.categories,
                      selectedId: widget.selectedId,
                      onPick: _pick,
                    ),
                  ),
                ),
                const SizedBox(height: Am5Spacing.md),
                Material(
                  elevation: 6,
                  shadowColor: Am5Colors.brandRed.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
                  child: InkWell(
                    onTap: _toggle,
                    borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Am5Colors.brandRed, Am5Colors.deepRed],
                        ),
                        borderRadius: BorderRadius.circular(Am5Spacing.radiusFull),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _open ? Icons.close_rounded : Icons.grid_view_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              selected?.name ?? 'Categories',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
    );
  }
}

class _CategoryPanel extends StatelessWidget {
  const _CategoryPanel({
    required this.categories,
    required this.selectedId,
    required this.onPick,
  });

  final List<VendorMainCategoryGroup> categories;
  final String? selectedId;
  final ValueChanged<VendorMainCategoryGroup> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 280,
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusXl),
        border: Border.all(color: Am5Colors.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Am5Spacing.lg, Am5Spacing.lg, Am5Spacing.lg, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Browse categories',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                Text(
                  '${categories.length}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(Am5Spacing.sm),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 6),
              itemBuilder: (context, i) {
                final cat = categories[i];
                final selected = cat.id == selectedId;
                return _CategoryTile(
                  category: cat,
                  selected: selected,
                  onTap: () => onPick(cat),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final VendorMainCategoryGroup category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? Am5Colors.lightRed : Colors.transparent,
      borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Am5Spacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              _CategoryIcon(iconUrl: category.iconUrl, name: category.name),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: selected ? theme.colorScheme.primary : Am5Colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${category.serviceCount} services · ${category.subcategories.length} subcategories',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Am5Colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconUrl, required this.name});

  final String? iconUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = iconUrl;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Am5Colors.lightRed,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Am5Colors.outline.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url != null && url.isNotEmpty
          ? Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => _fallback(theme))
          : _fallback(theme),
    );
  }

  Widget _fallback(ThemeData theme) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'C',
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
