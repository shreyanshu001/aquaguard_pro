import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Navigation item data class
class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom Bottom Navigation Bar for water quality management application
/// Provides quick access to main application sections with visual feedback
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final bool showLabels;
  final double elevation;

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
    this.showLabels = true,
    this.elevation = 8.0,
  }) : super(key: key);

  // Hardcoded navigation items for water quality management
  static const List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    BottomNavItem(
      icon: Icons.sensors_outlined,
      activeIcon: Icons.sensors,
      label: 'Monitoring',
      route: '/real-time-monitoring',
    ),
    BottomNavItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      label: 'Alerts',
      route: '/alerts-notifications',
    ),
    BottomNavItem(
      icon: Icons.analytics_outlined,
      activeIcon: Icons.analytics,
      label: 'Reports',
      route: '/reports-analytics',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: isLight
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.05),
            blurRadius: elevation,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = currentIndex == index;

              return Expanded(
                child: _buildNavItem(
                  context,
                  item,
                  index,
                  isSelected,
                  colorScheme,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    BottomNavItem item,
    int index,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    final Color itemColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withValues(alpha: 0.6);

    return InkWell(
      onTap: () => _handleNavTap(context, index, item.route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with selection indicator
            Container(
              padding: EdgeInsets.all(4),
              decoration: isSelected
                  ? BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    )
                  : null,
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                size: 24,
                color: itemColor,
              ),
            ),

            // Label
            if (showLabels) ...[
              SizedBox(height: 2),
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: itemColor,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleNavTap(BuildContext context, int index, String route) {
    // Provide haptic feedback for better user experience
    HapticFeedback.lightImpact();

    // Call the onTap callback if provided
    if (onTap != null) {
      onTap!(index);
    }

    // Navigate to the selected route if it's different from current
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  /// Helper method to get current index based on route
  static int getCurrentIndex(String? routeName) {
    for (int i = 0; i < _navItems.length; i++) {
      if (_navItems[i].route == routeName) {
        return i;
      }
    }
    return 0; // Default to dashboard
  }

  /// Helper method to check if route should show bottom navigation
  static bool shouldShowBottomNav(String? routeName) {
    return _navItems.any((item) => item.route == routeName);
  }
}
