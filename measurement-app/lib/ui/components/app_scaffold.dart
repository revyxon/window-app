import 'package:flutter/material.dart';

/// A standardized scaffold wrapper for consistent screen layouts.
///
/// Features:
/// - Consistent AppBar styling
/// - Optional floating action button
/// - Safe area handling
/// - Loading state overlay
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool isLoading;
  final PreferredSizeWidget? bottom;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showBackButton = true,
    this.onBackPressed,
    this.isLoading = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              )
            : null,
        automaticallyImplyLeading: showBackButton,
        actions: actions,
        bottom: bottom,
      ),
      body: Stack(
        children: [
          body,
          if (isLoading)
            Container(
              color: theme.colorScheme.surface.withValues(alpha: 0.7),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// A minimal scaffold for screens with custom scroll views.
class AppScrollScaffold extends StatelessWidget {
  final String title;
  final List<Widget> slivers;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showBackButton;

  const AppScrollScaffold({
    super.key,
    required this.title,
    required this.slivers,
    this.actions,
    this.floatingActionButton,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            automaticallyImplyLeading: showBackButton,
            title: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: actions,
          ),
          ...slivers,
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
