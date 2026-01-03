import 'dart:ui';
import 'package:flutter/material.dart';

/// =======================================================
/// CONFIG
/// =======================================================
const double kSidebarWidth = 280.0;
const Duration kSidebarDuration = Duration(milliseconds: 260);

/// =======================================================
/// NAV MODEL
/// =======================================================
class NavigationItem {
  final String title;
  final IconData icon;
  final int? badgeCount;

  const NavigationItem({
    required this.title,
    required this.icon,
    this.badgeCount,
  });
}

/// =======================================================
/// MAIN SIDEBAR SCAFFOLD (USE THIS)
/// =======================================================
class SidebarScaffold extends StatefulWidget {
  final Widget child;
  final String title;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final Color? primaryColor;
  final Widget? sidebarFooter;
  final List<Widget>? actions;

  const SidebarScaffold({
    super.key,
    required this.child,
    required this.title,
    required this.navigationItems,
    required this.currentIndex,
    required this.onNavigationChanged,
    this.primaryColor,
    this.sidebarFooter,
    this.actions,
  });

  @override
  State<SidebarScaffold> createState() => _SidebarScaffoldState();
}

class _SidebarScaffoldState extends State<SidebarScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _open = false;
  double _dragStartX = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: kSidebarDuration);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  void _openSidebar() {
    setState(() => _open = true);
    _controller.forward();
  }

  void _closeSidebar() {
    _controller.reverse().then((_) {
      if (mounted) setState(() => _open = false);
    });
  }

  void _toggle() => _open ? _closeSidebar() : _openSidebar();

  /// ------------------- SWIPE HANDLING -------------------
  void _onDragStart(DragStartDetails d) {
    _dragStartX = d.globalPosition.dx;
  }

  void _onDragUpdate(DragUpdateDetails d) {
    final delta = d.globalPosition.dx - _dragStartX;

    // open from edge
    if (!_open && _dragStartX < 24 && delta > 0) {
      _controller.value = (delta / kSidebarWidth).clamp(0.0, 1.0);
    }

    // close
    if (_open && delta < 0) {
      _controller.value = 1.0 - (delta.abs() / kSidebarWidth).clamp(0.0, 1.0);
    }
  }

  void _onDragEnd(DragEndDetails d) {
    final velocity = d.velocity.pixelsPerSecond.dx;

    if (velocity > 600 || _controller.value > 0.5) {
      _openSidebar();
    } else {
      _closeSidebar();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// =====================================================
  /// BUILD
  /// =====================================================
  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          /// MAIN CONTENT + GESTURES
          GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Column(
              children: [
                _Header(
                  title: widget.title,
                  primary: primary,
                  isDark: isDark,
                  animation: _animation,
                  onMenu: _toggle,
                  actions: widget.actions,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),

          /// BACKDROP
          if (_animation.value > 0)
            AnimatedBuilder(
              animation: _animation,
              builder:
                  (_, __) => GestureDetector(
                    onTap: _closeSidebar,
                    child: Container(
                      color: Colors.black.withOpacity(0.45 * _animation.value),
                    ),
                  ),
            ),

          /// SIDEBAR (RENDER ONLY WHEN NEEDED)
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              if (_animation.value == 0) {
                return const SizedBox.shrink();
              }

              return Transform.translate(
                offset: Offset(
                  -kSidebarWidth + (kSidebarWidth * _animation.value),
                  0,
                ),
                child: SidebarDrawer(
                  width: kSidebarWidth,
                  navigationItems: widget.navigationItems,
                  currentIndex: widget.currentIndex,
                  onNavigationChanged: (i) {
                    widget.onNavigationChanged(i);
                    _closeSidebar();
                  },
                  primaryColor: primary,
                  footer: widget.sidebarFooter,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// HEADER (ATTRACTIVE STATUS BAR INTEGRATED WITH SYSTEM THEME)
/// =======================================================
class _Header extends StatelessWidget {
  final String title;
  final Color primary;
  final bool isDark;
  final Animation<double> animation;
  final VoidCallback onMenu;
  final List<Widget>? actions;

  const _Header({
    required this.title,
    required this.primary,
    required this.isDark,
    required this.animation,
    required this.onMenu,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final statusBarHeight =
        topInset > 0 ? topInset : 24.0; // Default to 24 if no inset

    // Get system theme colors
    final systemTheme = Theme.of(context);
    final systemBackgroundColor =
        systemTheme.appBarTheme.backgroundColor ??
        (isDark ? const Color(0xFF121212) : Colors.white);
    final systemSurfaceColor = systemTheme.colorScheme.surface;

    // Blend with our custom colors for a more integrated look
    final backgroundColor =
        isDark
            ? systemBackgroundColor?.withOpacity(0.85) ??
                const Color(0xFF0F172A).withOpacity(0.85)
            : systemBackgroundColor?.withOpacity(0.85) ??
                Colors.white.withOpacity(0.85);

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status bar area (transparent to show device status bar)
          Container(
            height: statusBarHeight,
            color: Colors.transparent, // Transparent to show device status bar
          ),
          // Main header content
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 40,
                sigmaY: 40,
              ), // Enhanced blur for premium glassmorphism
              child: Container(
                height: 76, // Slightly taller for more premium feel
                decoration: BoxDecoration(
                  color: backgroundColor, // Use system-aware background color
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                      (isDark ? Colors.white : Colors.black).withOpacity(0.02),
                      Colors.transparent,
                    ],
                  ),
                  // Enhanced shadow for depth
                  boxShadow: [
                    BoxShadow(
                      color:
                          isDark
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ), // More generous spacing
                  child: Row(
                    children: [
                      _HeaderButton(
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.menu_close,
                          progress: animation,
                        ),
                        color: primary,
                        onTap: onMenu,
                      ),
                      const SizedBox(width: 16), // More spacing
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 20, // Larger for more impact
                            fontWeight:
                                FontWeight.w700, // Bolder for more presence
                            color: isDark ? Colors.white : Colors.black87,
                            letterSpacing: 0.3, // Better readability
                            shadows: [
                              Shadow(
                                color: isDark ? Colors.black54 : Colors.white12,
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (actions != null) ...actions!,
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
}

/// =======================================================
/// SIDEBAR DRAWER
/// =======================================================
class SidebarDrawer extends StatelessWidget {
  final double width;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final Color primaryColor;
  final Widget? footer;

  const SidebarDrawer({
    super.key,
    required this.width,
    required this.navigationItems,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.primaryColor,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDark
                    ? const [Color(0xFF0B1224), Color(0xFF0F172A)]
                    : [Colors.white, Colors.grey.shade50],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 30,
              offset: Offset(12, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 28,
                backgroundColor: primaryColor.withOpacity(0.15),
                child: Icon(Icons.person, color: primaryColor),
              ),
              const SizedBox(height: 12),
              const Text(
                'Administrator',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 24),

              /// NAV ITEMS
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: navigationItems.length,
                  itemBuilder: (_, i) {
                    final item = navigationItems[i];
                    final selected = i == currentIndex;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onNavigationChanged(i),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? primaryColor.withOpacity(0.15)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color:
                                    selected
                                        ? primaryColor
                                        : isDark
                                        ? Colors.white70
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight:
                                        selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                    color:
                                        selected
                                            ? primaryColor
                                            : isDark
                                            ? Colors.white
                                            : Colors.black,
                                  ),
                                ),
                              ),
                              if (item.badgeCount != null &&
                                  item.badgeCount! > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    item.badgeCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (footer != null)
                Padding(padding: const EdgeInsets.all(16), child: footer!),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// HEADER ICON BUTTON
/// =======================================================
class _HeaderButton extends StatelessWidget {
  final Widget icon;
  final Color color;
  final VoidCallback onTap;

  const _HeaderButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.transparent, // No background
          ),
          child: IconTheme(
            data: IconThemeData(
              color: isDark ? Colors.white : Colors.black87,
              size: 22,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
