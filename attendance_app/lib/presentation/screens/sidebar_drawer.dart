import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/typography.dart';

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
  final bool showHeader;

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
    this.showHeader = true,
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
    final topPadding = MediaQuery.of(context).padding.top;

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
                if (widget.showHeader)
                  _Header(
                    title: widget.title,
                    primary: primary,
                    isDark: isDark,
                    animation: _animation,
                    onMenu: _toggle,
                    actions: widget.actions,
                  )
                else
                  SizedBox(height: topPadding),
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
                  showHeader: widget.showHeader,
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
    final mediaQuery = MediaQuery.of(context);
    final topInset = mediaQuery.padding.top;
    final statusBarHeight =
        topInset > 0 ? topInset : 24.0; // Default to 24 if no inset

    // Get system theme colors
    final systemTheme = Theme.of(context);
    final systemBackgroundColor =
        systemTheme.appBarTheme.backgroundColor ??
        (isDark ? const Color(0xFF121212) : Colors.white);

    // Blend with our custom colors for a more integrated look
    final backgroundColor = systemBackgroundColor.withOpacity(0.85);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 20,
          sigmaY: 20,
        ), // Enhanced blur for premium glassmorphism
        child: Container(
          height: 76 + statusBarHeight, // include status bar height
          padding: EdgeInsets.fromLTRB(16, statusBarHeight, 16, 10),
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
                blurRadius: 30,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
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
                      fontSize: 22, // Larger for more impact
                      fontWeight: FontWeight.w800, // Bolder for more presence
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 0.3, // Better readability
                      shadows: [
                        Shadow(
                          color: isDark ? Colors.black54 : Colors.white12,
                          offset: const Offset(0, 2),
                          blurRadius: 4,
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
    );
  }
}

/// =======================================================
/// SIDEBAR DRAWER (UI REMODELED TO MATCH PROVIDED MOCKUP)
/// =======================================================
class SidebarDrawer extends StatelessWidget {
  final double width;
  final List<NavigationItem> navigationItems;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final Color primaryColor;
  final Widget? footer;
  final bool showHeader;

  const SidebarDrawer({
    super.key,
    required this.width,
    required this.navigationItems,
    required this.currentIndex,
    required this.onNavigationChanged,
    required this.primaryColor,
    this.footer,
    this.showHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const headerDeep = Color(0xFF0E5C66);
    const headerBright = Color(0xFF0B7A83);
    const faintDivider = Color(0xFFE6ECF2);
    const subtleText = Color(0xFF516173);
    final secondaryText = Colors.black.withOpacity(0.65);
    final accent = primaryColor;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(3, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (showHeader)
                _SidebarHeader(
                  deepColor: headerDeep,
                  brightColor: headerBright,
                  textColor: Colors.white,
                ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
                  children: [
                    if (navigationItems.isNotEmpty)
                      _PrimaryNavCard(
                        item: navigationItems.first,
                        selected: currentIndex == 0,
                        accent: accent,
                        secondaryText: secondaryText,
                        onTap: () => onNavigationChanged(0),
                        showOnlineDot: true,
                      ),
                    if (navigationItems.length > 1)
                      _PrimaryNavCard(
                        item: navigationItems[1],
                        selected: currentIndex == 1,
                        accent: accent,
                        secondaryText: secondaryText,
                        onTap: () => onNavigationChanged(1),
                        showDropdown: true,
                      ),

                    const SizedBox(height: 10),
                    const Divider(
                      height: 26,
                      color: faintDivider,
                      thickness: 1,
                    ),

                    ...navigationItems
                        .asMap()
                        .entries
                        .skip(2)
                        .map(
                          (entry) => _SlimNavTile(
                            item: entry.value,
                            selected: currentIndex == entry.key,
                            onTap: () => onNavigationChanged(entry.key),
                            accent: accent,
                            subtleText: subtleText,
                            secondaryText: secondaryText,
                          ),
                        )
                        .toList(),

                    if (footer != null) ...[const SizedBox(height: 8), footer!],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =======================================================
/// HEADER WITH GLOW + OVERLAY CIRCLES (MATCHES MOCKUP)
/// =======================================================
class _SidebarHeader extends StatelessWidget {
  final Color deepColor;
  final Color brightColor;
  final Color textColor;

  const _SidebarHeader({
    required this.deepColor,
    required this.brightColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [brightColor, deepColor],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      ),
      child: Stack(
        children: [
          // Floating circle glow
          Positioned(
            right: -36,
            top: -18,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            right: 12,
            top: 42,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.45)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.20),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.15), Colors.white24],
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/lg.png',
                    fit: BoxFit.cover,
                    errorBuilder:
                        (_, __, ___) => Icon(
                          Icons.school,
                          color: Colors.white.withOpacity(0.8),
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'የሞቅ ጎረም',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'የስነ ምግባር ት/ቤት መረጃ',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: textColor.withOpacity(0.82),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.home_rounded, color: textColor, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'መነጽር ገጽ',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.lightGreenAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// PRIMARY CARD STYLE (TOP TWO ROWS IN MOCKUP)
/// =======================================================
class _PrimaryNavCard extends StatelessWidget {
  final NavigationItem item;
  final bool selected;
  final bool showOnlineDot;
  final bool showDropdown;
  final Color accent;
  final Color secondaryText;
  final VoidCallback onTap;

  const _PrimaryNavCard({
    required this.item,
    required this.selected,
    required this.accent,
    required this.secondaryText,
    required this.onTap,
    this.showOnlineDot = false,
    this.showDropdown = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.10) : const Color(0xFFF7FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent : Colors.grey.withOpacity(0.18),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? accent.withOpacity(0.20) : Colors.white,
                border: Border.all(color: accent.withOpacity(0.30)),
              ),
              child: Icon(item.icon, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2A35),
                ),
              ),
            ),
            if (showOnlineDot)
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.tealAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.tealAccent.withOpacity(0.6),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            if (showDropdown)
              Icon(Icons.keyboard_arrow_down_rounded, color: secondaryText),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// SLIM LIST TILE STYLE (LOWER SECTION IN MOCKUP)
/// =======================================================
class _SlimNavTile extends StatelessWidget {
  final NavigationItem item;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final Color subtleText;
  final Color secondaryText;

  const _SlimNavTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.accent,
    required this.subtleText,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    selected
                        ? accent.withOpacity(0.18)
                        : Colors.grey.withOpacity(0.10),
              ),
              child: Icon(
                item.icon,
                size: 18,
                color: selected ? accent : subtleText,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: selected ? accent : secondaryText,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            if (item.badgeCount != null && item.badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.badgeCount.toString(),
                  style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
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
