import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget for water quality management application
/// Provides consistent navigation and branding across all screens
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool showNotificationBadge;
  final int notificationCount;
  final VoidCallback? onNotificationTap;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 2.0,
    this.showNotificationBadge = false,
    this.notificationCount = 0,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? colorScheme.onPrimary,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      elevation: elevation,
      shadowColor: isLight
          ? Colors.black.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.1),
      leading: leading ?? (showBackButton ? _buildLeading(context) : null),
      actions: _buildActions(context),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isLight ? Brightness.light : Brightness.dark,
        statusBarBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: foregroundColor ?? colorScheme.onPrimary,
          size: 20,
        ),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }
    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> actionWidgets = [];

    // Add notification icon if enabled
    if (showNotificationBadge) {
      actionWidgets.add(
        Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: foregroundColor ?? colorScheme.onPrimary,
                size: 24,
              ),
              onPressed: onNotificationTap ??
                  () => Navigator.pushNamed(context, '/alerts-notifications'),
              tooltip: 'Notifications',
            ),
            if (notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    notificationCount > 99
                        ? '99+'
                        : notificationCount.toString(),
                    style: GoogleFonts.inter(
                      color: colorScheme.onError,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // Add menu icon for main screens
    if (_isMainScreen(context)) {
      actionWidgets.add(
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: foregroundColor ?? colorScheme.onPrimary,
            size: 24,
          ),
          onSelected: (value) => _handleMenuSelection(context, value),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'dashboard',
              child: Row(
                children: [
                  Icon(Icons.dashboard_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Dashboard', style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'monitoring',
              child: Row(
                children: [
                  Icon(Icons.sensors, size: 20),
                  SizedBox(width: 12),
                  Text('Real-time Monitoring',
                      style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'reports',
              child: Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Reports & Analytics',
                      style: GoogleFonts.inter(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, size: 20, color: colorScheme.error),
                  SizedBox(width: 12),
                  Text(
                    'Logout',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
          tooltip: 'More options',
        ),
      );
    }

    // Add custom actions if provided
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets.isNotEmpty ? actionWidgets : null;
  }

  bool _isMainScreen(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return currentRoute == '/dashboard' ||
        currentRoute == '/real-time-monitoring' ||
        currentRoute == '/alerts-notifications' ||
        currentRoute == '/reports-analytics';
  }

  void _handleMenuSelection(BuildContext context, String value) {
    switch (value) {
      case 'dashboard':
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 'monitoring':
        Navigator.pushNamed(context, '/real-time-monitoring');
        break;
      case 'reports':
        Navigator.pushNamed(context, '/reports-analytics');
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
