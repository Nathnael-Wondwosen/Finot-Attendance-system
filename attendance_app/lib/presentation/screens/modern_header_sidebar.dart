import 'package:flutter/material.dart';

/// =======================================================
/// NAV ITEM MODEL
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
/// MAIN SCAFFOLD (ANDROID-FIRST HEADER + SIDEBAR + CONTENT)
/// =======================================================
class ModernHeaderSidebar extends StatefulWidget {
  final Widget child;
  final String title;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final Color? primaryColor;

  const ModernHeaderSidebar({
    super.key,
    required this.child,
    required this.title,
    required this.navigationItems,
    required this.currentIndex,
    required this.onNavigationChanged,
    this.primaryColor,
  });

  @override
  State<ModernHeaderSidebar> createState() => _ModernHeaderSidebarState();
}

class _ModernHeaderSidebarState extends State<ModernHeaderSidebar>
    with SingleTickerProviderStateMixin {
  static const double _sidebarWidth = 280;

  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _sidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarOpen = !_sidebarOpen;
      _sidebarOpen ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          /// ===================== MAIN CONTENT =====================
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            transform: Matrix4.translationValues(
              _sidebarOpen ? _sidebarWidth : 0,
              0,
              0,
            ),
            child: Column(
              children: [
                _ModernAndroidHeader(
                  title: widget.title,
                  primary: primary,
                  isDark: isDark,
                  animation: _controller,
                  onMenu: _toggleSidebar,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),

          /// ===================== OVERLAY =====================
          if (_sidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: AnimatedOpacity(
                opacity: _animation.value,
                duration: const Duration(milliseconds: 200),
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            ),

          /// ===================== SIDEBAR =====================
          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Positioned(
                left: -_sidebarWidth + (_animation.value * _sidebarWidth),
                top: 0,
                bottom: 0,
                width: _sidebarWidth,
                child: _Sidebar(
                  items: widget.navigationItems,
                  currentIndex: widget.currentIndex,
                  primary: primary,
                  isDark: isDark,
                  onSelect: (index) {
                    widget.onNavigationChanged(index);
                    _toggleSidebar();
                  },
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
/// ANDROID MODERN HEADER (ATTRACTIVE SYSTEM THEME INTEGRATED)
/// =======================================================
class _ModernAndroidHeader extends StatelessWidget {
  final String title;
  final Color primary;
  final bool isDark;
  final Animation<double> animation;
  final VoidCallback onMenu;

  const _ModernAndroidHeader({
    required this.title,
    required this.primary,
    required this.isDark,
    required this.animation,
    required this.onMenu,
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

    // Blend with our custom colors for a more integrated look
    final backgroundColor =
        isDark
            ? systemBackgroundColor?.withOpacity(0.85) ??
                const Color(0xFF0F172A).withOpacity(0.85)
            : systemBackgroundColor?.withOpacity(0.85) ??
                Colors.white.withOpacity(0.85);

    return Container(
      // No Material wrapper to allow transparency where status bar overlaps
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status bar area (transparent to show device status bar)
          Container(
            height: statusBarHeight,
            color: Colors.transparent, // Transparent to show device status bar
          ),
          // Main header content
          Container(
            height: 72, // Increased height for more premium feel
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: backgroundColor, // Use system-aware background color
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                _HeaderIconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: animation,
                  ),
                  onTap: onMenu,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: isDark ? Colors.white : Colors.black87,
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
              ],
            ),
          ),
          // Accent line (professional signal)
          Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  primary.withOpacity(0.8),
                  primary.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// SIDEBAR
/// =======================================================
class _Sidebar extends StatelessWidget {
  final List<NavigationItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final Color primary;
  final bool isDark;

  const _Sidebar({
    required this.items,
    required this.currentIndex,
    required this.onSelect,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0B1224) : Colors.white,
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
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 30,
              backgroundColor: primary.withOpacity(0.15),
              child: Icon(Icons.person, color: primary),
            ),
            const SizedBox(height: 12),
            Text(
              'Administrator',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final selected = i == currentIndex;
                  final item = items[i];

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onSelect(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color:
                            selected
                                ? primary.withOpacity(0.15)
                                : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item.icon,
                            color:
                                selected
                                    ? primary
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
                                        ? primary
                                        : isDark
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                            ),
                          ),
                          if (item.badgeCount != null && item.badgeCount! > 0)
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// HEADER ICON BUTTON
/// =======================================================
class _HeaderIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color:
                isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.05),
          ),
          child: IconTheme(
            data: IconThemeData(
              size: 22,
              color: isDark ? Colors.white : Colors.black87,
            ),
            child: icon,
          ),
        ),
      ),
    );
  }
}
