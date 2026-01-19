import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'dart:ui';
import '../services/update_service.dart';
import '../widgets/animated_press_button.dart';
import '../ui/components/particle_background.dart';
import '../ui/design_system.dart';

class UpdateScreen extends StatefulWidget {
  final UpdateCheckResult updateResult;
  final VoidCallback? onSkip;

  const UpdateScreen({super.key, required this.updateResult, this.onSkip});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen>
    with SingleTickerProviderStateMixin {
  bool _isDownloading = false;
  double _downloadProgress = 0;
  String? _error;
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryController, curve: Curves.easeOut));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _startUpdate() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _error = null;
    });

    try {
      final dio = Dio();
      final tempDir = await getTemporaryDirectory();
      final savePath =
          '${tempDir.path}/update_${widget.updateResult.version}.apk';

      await dio.download(
        widget.updateResult.apkUrl!,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

      setState(() {
        _downloadProgress = 1.0;
      });

      // Install APK
      final result = await OpenFilex.open(savePath);
      if (result.type != ResultType.done) {
        throw Exception('Could not launch installer: ${result.message}');
      }
    } catch (e) {
      setState(() {
        _error = 'Download failed: $e';
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMandatory = widget.updateResult.isMandatory;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Premium Animated Background
          Positioned.fill(
            child: ParticleBackground(
              color: colorScheme.primary,
              numberOfParticles: 25,
            ),
          ),

          // 2. Glassmorphism Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 3. Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Icon & Title
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            FluentIcons.rocket_24_filled,
                            size: 32,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'New Version Available',
                        textAlign: TextAlign.center,
                        style: AppTypography.headlineMedium.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upgrade to experience the latest features',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Version Comparison (Glass Card)
                      _buildGlassCard(
                        context,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildVersionBlock(
                              context,
                              'Current',
                              'v1.6.0',
                              false,
                            ), // Placeholder logic for current
                            Icon(
                              FluentIcons.arrow_right_24_filled,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            _buildVersionBlock(
                              context,
                              'New',
                              'v${widget.updateResult.version}',
                              true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Release Notes Header
                      Text(
                        "WHAT'S NEW",
                        style: AppTypography.labelSmall.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Release Notes (Glass Card Scrollable)
                      Expanded(
                        child: _buildGlassCard(
                          context,
                          padding: EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Markdown(
                              data:
                                  widget.updateResult.releaseNotes ??
                                  "• General improvements",
                              padding: const EdgeInsets.all(20),
                              styleSheet: MarkdownStyleSheet(
                                p: AppTypography.bodyMedium.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                listBullet: TextStyle(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Area
                      if (_isDownloading)
                        _buildDownloadProgress(context)
                      else
                        _buildActionButtons(context, isMandatory),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildVersionBlock(
    BuildContext context,
    String label,
    String version,
    bool isHighlight,
  ) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.labelSmall.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          version,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: isHighlight
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadProgress(BuildContext context) {
    final theme = Theme.of(context);
    return _buildGlassCard(
      context,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Downloading...', style: AppTypography.labelLarge),
              Text(
                '${(_downloadProgress * 100).toInt()}%',
                style: AppTypography.labelLarge.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _downloadProgress,
            backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
            ),
            TextButton(onPressed: _startUpdate, child: const Text("Retry")),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isMandatory) {
    final theme = Theme.of(context);
    return Column(
      children: [
        AnimatedPressButton(
          onPressed: _startUpdate,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'UPDATE NOW',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        if (!isMandatory) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: widget.onSkip,
            child: Text(
              'Skip for now',
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );
  }
}
