import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/service_asset_mapper.dart';

/// Renders a service icon from network URL (SVG/PNG), local asset, or fallback.
class ServiceImage extends StatefulWidget {
  const ServiceImage({
    super.key,
    this.imageUrl,
    this.name,
    this.assetPath,
    this.fit = BoxFit.contain,
    this.iconSize = 36,
  });

  final String? imageUrl;
  final String? name;
  final String? assetPath;
  final BoxFit fit;
  final double iconSize;

  @override
  State<ServiceImage> createState() => _ServiceImageState();
}

class _ServiceImageState extends State<ServiceImage> {
  bool _networkFailed = false;

  @override
  Widget build(BuildContext context) {
    final String? localAsset = widget.assetPath ??
        (widget.name != null ? ServiceAssetMapper.forName(widget.name!) : null);

    if (!_networkFailed &&
        widget.imageUrl != null &&
        widget.imageUrl!.isNotEmpty) {
      final String url = widget.imageUrl!;
      if (_isSvg(url)) {
        return SvgPicture.network(
          url,
          fit: widget.fit,
          placeholderBuilder: (_) => _placeholder(localAsset),
          headers: const {'Accept': 'image/svg+xml,*/*'},
        );
      }

      return Image.network(
        url,
        fit: widget.fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _loading();
        },
        errorBuilder: (_, __, ___) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_networkFailed) {
              setState(() => _networkFailed = true);
            }
          });
          return _buildAssetOrIcon(localAsset);
        },
      );
    }

    return _buildAssetOrIcon(localAsset);
  }

  bool _isSvg(String url) {
    final String path =
        Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.svg');
  }

  Widget _buildAssetOrIcon(String? localAsset) {
    if (localAsset != null) {
      return Image.asset(
        localAsset,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => _fallbackIcon(),
      );
    }
    return _fallbackIcon();
  }

  Widget _placeholder(String? localAsset) {
    if (localAsset != null) {
      return Image.asset(localAsset, fit: widget.fit);
    }
    return _loading();
  }

  Widget _loading() {
    return Center(
      child: SizedBox(
        width: widget.iconSize * 0.6,
        height: widget.iconSize * 0.6,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.royalBlue,
        ),
      ),
    );
  }

  Widget _fallbackIcon() {
    return Icon(
      Icons.home_repair_service_rounded,
      color: AppColors.royalBlue,
      size: widget.iconSize,
    );
  }
}
