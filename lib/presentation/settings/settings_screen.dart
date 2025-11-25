import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _autoRefreshEnabled = true;
  bool _darkModeEnabled = false;
  bool _analyticsEnabled = true;
  String _selectedLanguage = 'English';
  String _selectedUnitSystem = 'Metric';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<String> _unitSystems = ['Metric', 'Imperial'];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _autoRefreshEnabled = prefs.getBool('auto_refresh_enabled') ?? true;
      _darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
      _selectedUnitSystem = prefs.getString('selected_unit_system') ?? 'Metric';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Settings',
        showNotificationBadge: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account & Security'),
            _buildSettingItem(
              'Biometric Authentication',
              'fingerprint',
              subtitle: 'Use fingerprint or face unlock',
              trailing: Switch(
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() => _biometricEnabled = value);
                  _saveSetting('biometric_enabled', value);
                  HapticFeedback.lightImpact();
                },
              ),
            ),
            _buildDivider(),

            _buildSectionHeader('Notifications'),
            _buildSettingItem(
              'Push Notifications',
              'notifications',
              subtitle: 'Receive alerts and updates',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  _saveSetting('notifications_enabled', value);
                  HapticFeedback.lightImpact();
                },
              ),
            ),
            _buildDivider(),

            _buildSectionHeader('Data & Sync'),
            _buildSettingItem(
              'Auto Refresh',
              'refresh',
              subtitle: 'Automatically refresh sensor data',
              trailing: Switch(
                value: _autoRefreshEnabled,
                onChanged: (value) {
                  setState(() => _autoRefreshEnabled = value);
                  _saveSetting('auto_refresh_enabled', value);
                  HapticFeedback.lightImpact();
                },
              ),
            ),
            _buildSettingItem(
              'Unit System',
              'straighten',
              subtitle: 'Choose measurement units',
              subtitleText: _selectedUnitSystem,
              onTap: () => _showUnitSystemDialog(),
            ),
            _buildDivider(),

            _buildSectionHeader('Appearance'),
            _buildSettingItem(
              'Dark Mode',
              'dark_mode',
              subtitle: 'Switch between light and dark themes',
              trailing: Switch(
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() => _darkModeEnabled = value);
                  _saveSetting('dark_mode_enabled', value);
                  HapticFeedback.lightImpact();
                  _showThemeChangeDialog();
                },
              ),
            ),
            _buildSettingItem(
              'Language',
              'language',
              subtitle: 'Select your preferred language',
              subtitleText: _selectedLanguage,
              onTap: () => _showLanguageDialog(),
            ),
            _buildDivider(),

            _buildSectionHeader('Privacy & Analytics'),
            _buildSettingItem(
              'Analytics',
              'analytics',
              subtitle: 'Help improve the app with usage data',
              trailing: Switch(
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() => _analyticsEnabled = value);
                  _saveSetting('analytics_enabled', value);
                  HapticFeedback.lightImpact();
                },
              ),
            ),
            _buildDivider(),

            _buildSectionHeader('Support & About'),
            _buildSettingItem(
              'Help & Support',
              'help',
              subtitle: 'Get help and contact support',
              onTap: () => _showHelpDialog(),
            ),
            _buildSettingItem(
              'About AquaGuard Pro',
              'info',
              subtitle: 'Version 1.0.0',
              onTap: () => _showAboutDialog(),
            ),
            _buildSettingItem(
              'Privacy Policy',
              'privacy_tip',
              subtitle: 'Read our privacy policy',
              onTap: () => _showPrivacyPolicy(),
            ),
            _buildSettingItem(
              'Terms of Service',
              'description',
              subtitle: 'Read our terms and conditions',
              onTap: () => _showTermsOfService(),
            ),
            _buildDivider(),

            _buildSectionHeader('Account Actions'),
            _buildSettingItem(
              'Export Data',
              'download',
              subtitle: 'Download your data',
              onTap: () => _exportData(),
            ),
            _buildSettingItem(
              'Clear Cache',
              'cleaning_services',
              subtitle: 'Free up storage space',
              onTap: () => _clearCache(),
            ),
            _buildSettingItem(
              'Sign Out',
              'logout',
              subtitle: 'Sign out of your account',
              textColor: AppTheme.errorLight,
              onTap: () => _showSignOutDialog(),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4, // Settings index (we'll need to update the bottom bar)
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String iconName, {
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    String? subtitleText,
    Color? textColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: textColor ?? colorScheme.primary,
                size: 6.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitleText ?? subtitle ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
            if (onTap != null && trailing == null)
              CustomIconWidget(
                iconName: 'chevron_right',
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: 5.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
    );
  }

  void _showUnitSystemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Unit System'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _unitSystems.map((unit) {
            return RadioListTile<String>(
              title: Text(unit),
              value: unit,
              groupValue: _selectedUnitSystem,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedUnitSystem = value);
                  _saveSetting('selected_unit_system', value);
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  _saveSetting('selected_language', value);
                  Navigator.of(context).pop();
                  HapticFeedback.lightImpact();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showThemeChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Theme Changed'),
        content: Text('The app will restart to apply the new theme.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you would restart the app or apply theme change
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Theme change applied')),
              );
            },
            child: Text('Apply Now'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Help & Support'),
        content: Text(
          'For help and support:\n\n'
          '• Check our FAQ section\n'
          '• Contact support@aquaguard.com\n'
          '• Visit our website\n\n'
          'Support hours: 24/7',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About AquaGuard Pro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 1.h),
            Text('Build: 2024.11.26'),
            SizedBox(height: 2.h),
            Text(
              'AquaGuard Pro is a comprehensive water quality management system designed for utilities, municipalities, and water treatment facilities.',
              style: TextStyle(fontSize: 12.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    // In a real app, this would open a web view or navigate to a privacy policy screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Privacy Policy would open here')),
    );
  }

  void _showTermsOfService() {
    // In a real app, this would open a web view or navigate to terms screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Terms of Service would open here')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data export started')),
    );
  }

  void _clearCache() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cache cleared successfully')),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, this would sign out and navigate to login
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Signed out successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}