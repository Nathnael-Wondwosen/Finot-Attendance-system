import 'package:flutter/material.dart';

/// Legacy copy of the modern header/sidebar for reference (renamed)
class LegacyModernHeader extends StatefulWidget {
  final Widget child;
  final String title;
  final List<dynamic> navigationItems;
  final int currentIndex;
  final ValueChanged<int> onNavigationChanged;
  final Color? primaryColor;

  const LegacyModernHeader({
    super.key,
    required this.child,
    required this.title,
    required this.navigationItems,
    required this.currentIndex,
    required this.onNavigationChanged,
    this.primaryColor,
  });

  @override
  State<LegacyModernHeader> createState() => _LegacyModernHeaderState();
}

class _LegacyModernHeaderState extends State<LegacyModernHeader>
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            transform: Matrix4.translationValues(
              _sidebarOpen ? _sidebarWidth : 0,
              0,
              0,
            ),
            child: Column(
              children: [
                _LegacyAndroidHeader(
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

          if (_sidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: AnimatedOpacity(
                opacity: _animation.value,
                duration: const Duration(milliseconds: 200),
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),
            ),

          AnimatedBuilder(
            animation: _animation,
            builder: (_, __) {
              return Positioned(
                left: -_sidebarWidth + (_animation.value * _sidebarWidth),
                top: 0,
                bottom: 0,
                width: _sidebarWidth,
                child: Container(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegacyAndroidHeader extends StatelessWidget {
  final String title;
  final Color primary;
  final bool isDark;
  final Animation<double> animation;
  final VoidCallback onMenu;

  const _LegacyAndroidHeader({
    required this.title,
    required this.primary,
    required this.isDark,
    required this.animation,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final statusBarHeight = topInset > 0 ? topInset : 24.0;

    final systemTheme = Theme.of(context);
    final systemBackgroundColor =
        systemTheme.appBarTheme.backgroundColor ??
        (isDark ? const Color(0xFF121212) : Colors.white);

    final backgroundColor = systemBackgroundColor.withOpacity(0.85);

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72 + statusBarHeight,
            padding: EdgeInsets.fromLTRB(16, statusBarHeight, 16, 0),
            decoration: BoxDecoration(
              color: backgroundColor,
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
