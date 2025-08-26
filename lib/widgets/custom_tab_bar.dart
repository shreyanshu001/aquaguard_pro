import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


/// Tab item data class for custom tab configuration
class CustomTabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? tooltip;

  const CustomTabItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.tooltip,
  });
}

/// Custom Tab Bar widget for water quality management application
/// Provides flexible tabbed navigation with consistent styling
class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final List<CustomTabItem> tabs;
  final TabController? controller;
  final Function(int)? onTap;
  final bool isScrollable;
  final TabAlignment tabAlignment;
  final EdgeInsetsGeometry? labelPadding;
  final Color? indicatorColor;
  final double indicatorWeight;
  final TabBarIndicatorSize indicatorSize;
  final bool showIcons;
  final double? elevation;

  const CustomTabBar({
    Key? key,
    required this.tabs,
    this.controller,
    this.onTap,
    this.isScrollable = false,
    this.tabAlignment = TabAlignment.center,
    this.labelPadding,
    this.indicatorColor,
    this.indicatorWeight = 2.0,
    this.indicatorSize = TabBarIndicatorSize.label,
    this.showIcons = true,
    this.elevation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return Container(
      decoration: elevation != null
          ? BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: isLight
                      ? Colors.black.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.05),
                  blurRadius: elevation!,
                  offset: Offset(0, 2),
                ),
              ],
            )
          : null,
      child: TabBar(
        controller: controller,
        tabs: _buildTabs(context),
        onTap: onTap,
        isScrollable: isScrollable,
        tabAlignment: tabAlignment,
        labelPadding:
            labelPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.1,
        ),
        indicatorColor: indicatorColor ?? colorScheme.primary,
        indicatorWeight: indicatorWeight,
        indicatorSize: indicatorSize,
        dividerColor: Colors.transparent,
        splashFactory: InkRipple.splashFactory,
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.primary.withValues(alpha: 0.04);
            }
            if (states.contains(WidgetState.focused)) {
              return colorScheme.primary.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.primary.withValues(alpha: 0.16);
            }
            return null;
          },
        ),
      ),
    );
  }

  List<Widget> _buildTabs(BuildContext context) {
    return tabs.map((tabItem) {
      return Tab(
        text: tabItem.label,
        icon: showIcons ? _buildTabIcon(tabItem) : null,
        iconMargin: showIcons ? EdgeInsets.only(bottom: 4) : EdgeInsets.zero,
      );
    }).toList();
  }

  Widget? _buildTabIcon(CustomTabItem tabItem) {
    if (tabItem.customIcon != null) {
      return tabItem.customIcon;
    }

    if (tabItem.icon != null) {
      return Icon(
        tabItem.icon,
        size: 20,
      );
    }

    return null;
  }

  @override
  Size get preferredSize {
    double height = kTextTabBarHeight;
    if (showIcons &&
        tabs.any((tab) => tab.icon != null || tab.customIcon != null)) {
      height = 72.0; // Height for tabs with icons
    }
    return Size.fromHeight(height);
  }
}

/// Predefined tab configurations for common water quality management screens

/// Dashboard tabs for different overview sections
class DashboardTabs {
  static const List<CustomTabItem> items = [
    CustomTabItem(
      label: 'Overview',
      icon: Icons.dashboard_outlined,
      tooltip: 'System overview',
    ),
    CustomTabItem(
      label: 'Locations',
      icon: Icons.location_on_outlined,
      tooltip: 'Monitoring locations',
    ),
    CustomTabItem(
      label: 'Status',
      icon: Icons.health_and_safety_outlined,
      tooltip: 'System status',
    ),
  ];
}

/// Real-time monitoring tabs for different parameter categories
class MonitoringTabs {
  static const List<CustomTabItem> items = [
    CustomTabItem(
      label: 'Water Quality',
      icon: Icons.water_drop_outlined,
      tooltip: 'Water quality parameters',
    ),
    CustomTabItem(
      label: 'Flow Rate',
      icon: Icons.speed_outlined,
      tooltip: 'Flow measurements',
    ),
    CustomTabItem(
      label: 'Pressure',
      icon: Icons.compress_outlined,
      tooltip: 'Pressure readings',
    ),
    CustomTabItem(
      label: 'Temperature',
      icon: Icons.thermostat_outlined,
      tooltip: 'Temperature monitoring',
    ),
  ];
}

/// Reports tabs for different analytics views
class ReportsTabs {
  static const List<CustomTabItem> items = [
    CustomTabItem(
      label: 'Daily',
      icon: Icons.today_outlined,
      tooltip: 'Daily reports',
    ),
    CustomTabItem(
      label: 'Weekly',
      icon: Icons.view_week_outlined,
      tooltip: 'Weekly analysis',
    ),
    CustomTabItem(
      label: 'Monthly',
      icon: Icons.calendar_month_outlined,
      tooltip: 'Monthly trends',
    ),
    CustomTabItem(
      label: 'Custom',
      icon: Icons.date_range_outlined,
      tooltip: 'Custom date range',
    ),
  ];
}

/// Alerts tabs for different notification categories
class AlertsTabs {
  static const List<CustomTabItem> items = [
    CustomTabItem(
      label: 'Active',
      icon: Icons.warning_outlined,
      tooltip: 'Active alerts',
    ),
    CustomTabItem(
      label: 'History',
      icon: Icons.history_outlined,
      tooltip: 'Alert history',
    ),
    CustomTabItem(
      label: 'Settings',
      icon: Icons.settings_outlined,
      tooltip: 'Alert settings',
    ),
  ];
}
