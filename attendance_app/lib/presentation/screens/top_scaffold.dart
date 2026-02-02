import 'dart:ui';
import 'package:flutter/material.dart';
import 'sidebar_drawer.dart';

/// Modern Top Scaffold for mobile: header + content + modern bottom navigation
class TopScaffold extends StatelessWidget {
  final Widget child;
  final String title;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final Color? primaryColor;
  final bool showHeader;

  const TopScaffold({
    super.key,
    required this.child,
    required this.title,
    required this.navigationItems,
    required this.currentIndex,
    required this.onNavigationChanged,
    this.primaryColor,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = primaryColor ?? theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    final bottomInset = mediaQuery.padding.bottom;

    // Theme-driven sizes and styles for bottom navigation
    final iconThemeSize = IconTheme.of(context).size ?? 24.0;
    final containerSelectedSize = iconThemeSize * 2.0;
    final containerUnselectedSize = iconThemeSize * 1.5;
    final selectedIconSize = iconThemeSize * 0.95;
    final unselectedIconSize = iconThemeSize * 0.75;
    final labelSelectedStyle =
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: primary,
        ) ??
        TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary);
    final labelUnselectedStyle =
        theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black54,
        ) ??
        TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : Colors.black54,
        );
    final badgeTextStyle =
        theme.textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        );
    final navBackground = theme.colorScheme.surface.withOpacity(
      isDark ? 0.92 : 0.92,
    );
    final navTopBorder = theme.colorScheme.onSurface.withOpacity(0.06);
    // indicator alignment (-1..1) across horizontal space and width factor for one tab
    final indicatorAlignX =
        navigationItems.length > 1
            ? (currentIndex / (navigationItems.length - 1)) * 2 - 1
            : 0.0;
    final indicatorWidthFactor =
        0.6 / (navigationItems.length > 0 ? navigationItems.length : 1);

    return Scaffold(
      drawer: Drawer(
        child: SidebarDrawer(
          // reuse existing sidebar UI for the drawer
          width: kSidebarWidth,
          navigationItems: navigationItems,
          currentIndex: currentIndex,
          primaryColor: primary,
          onNavigationChanged: (i) {
            onNavigationChanged(i);
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Column(
        children: [
          // Header (optional)
          if (showHeader)
            Container(
              height: 64 + topInset,
              color: primary,
              child: Container(
                margin: EdgeInsets.only(top: topInset),
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.35 : 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Builder(
                      builder:
                          (ctx) => IconButton(
                            icon: Icon(
                              Icons.menu,
                              color: theme.colorScheme.onPrimary,
                            ),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.onPrimary.withOpacity(
                        0.15,
                      ),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(height: topInset),

          // Content
          Expanded(child: child),

          // Bottom navigation (flat full-width, theme-driven to match requested design)
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(0, 8, 0, bottomInset),
            height: 64 + bottomInset,
            decoration: BoxDecoration(
              color: navBackground,
              border: Border(top: BorderSide(color: navTopBorder)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  children: List.generate(navigationItems.length, (index) {
                    final item = navigationItems[index];
                    final selected = index == currentIndex;
                    return Expanded(
                      child: Semantics(
                        selected: selected,
                        label: '${item.title} tab',
                        child: InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          onTap: () => onNavigationChanged(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            color:
                                selected
                                    ? primary.withOpacity(0.04)
                                    : Colors.transparent,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                // Determine available inner height and adapt sizes to avoid overflow
                                final availableH = constraints.maxHeight;

                                // Scale factors (base design assumes ~64 total height)
                                final scale = (availableH / 64.0).clamp(
                                  0.6,
                                  1.0,
                                );

                                final maxIconH =
                                    availableH *
                                    0.55; // allow icon to take up to 55%
                                final rawIconH = (selected
                                        ? containerSelectedSize
                                        : containerUnselectedSize)
                                    .clamp(0.0, maxIconH);
                                final iconH = (rawIconH * scale).clamp(
                                  18.0,
                                  rawIconH,
                                );
                                final iconSizeAdjusted =
                                    ((selected
                                            ? selectedIconSize
                                            : unselectedIconSize)
                                        .clamp(0.0, iconH * 0.9)) *
                                    scale;

                                final spacing = (availableH * 0.06).clamp(
                                  2.0,
                                  8.0,
                                );

                                final baseLabelSize =
                                    (selected
                                        ? (labelSelectedStyle.fontSize ?? 12)
                                        : (labelUnselectedStyle.fontSize ??
                                            11));
                                final labelFontSize = (baseLabelSize * scale)
                                    .clamp(9.0, baseLabelSize);
                                final effectiveLabelStyle = (selected
                                        ? labelSelectedStyle
                                        : labelUnselectedStyle)
                                    .copyWith(fontSize: labelFontSize);

                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      width: iconH,
                                      height: iconH,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            selected
                                                ? primary
                                                : Colors.transparent,
                                        boxShadow:
                                            selected
                                                ? [
                                                  BoxShadow(
                                                    color: primary.withOpacity(
                                                      0.2,
                                                    ),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                                : null,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            item.icon,
                                            size: iconSizeAdjusted,
                                            color:
                                                selected
                                                    ? theme
                                                        .colorScheme
                                                        .onPrimary
                                                    : (isDark
                                                        ? Colors.white70
                                                        : Colors.black87),
                                          ),
                                          if (item.badgeCount != null &&
                                              item.badgeCount! > 0)
                                            Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      blurRadius: 4,
                                                      offset: const Offset(
                                                        0,
                                                        2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 16,
                                                      minHeight: 16,
                                                    ),
                                                child: Text(
                                                  item.badgeCount.toString(),
                                                  textAlign: TextAlign.center,
                                                  style: badgeTextStyle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: spacing),
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      style: effectiveLabelStyle,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 64 * scale,
                                        ),
                                        child: Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: spacing),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
