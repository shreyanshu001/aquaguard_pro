import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/custom_tab_bar.dart';
import './widgets/alert_card_widget.dart';
import './widgets/configure_alerts_bottom_sheet.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/search_bar_widget.dart';
import 'widgets/alert_card_widget.dart';
import 'widgets/configure_alerts_bottom_sheet.dart';
import 'widgets/empty_state_widget.dart';
import 'widgets/filter_chips_widget.dart';
import 'widgets/search_bar_widget.dart';

class AlertsNotifications extends StatefulWidget {
  const AlertsNotifications({Key? key}) : super(key: key);

  @override
  State<AlertsNotifications> createState() => _AlertsNotificationsState();
}

class _AlertsNotificationsState extends State<AlertsNotifications>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  List<String> _selectedFilters = [];
  bool _isLoading = false;
  bool _isOffline = false;

  // Mock data for alerts
  final List<Map<String, dynamic>> _allAlerts = [
    {
      "id": 1,
      "type": "High pH Level",
      "severity": "critical",
      "location": "Main Treatment Plant - Tank A",
      "message":
          "pH level has exceeded safe threshold. Immediate attention required to prevent water quality degradation.",
      "timestamp": "2025-08-26T10:30:00.000Z",
      "status": "active",
      "isRead": false,
      "parameterValue": 9.2,
      "thresholdValue": 8.5,
      "currentValue": 9.2,
      "unit": "pH",
      "expanded": false,
    },
    {
      "id": 2,
      "type": "Low Water Pressure",
      "severity": "warning",
      "location": "Distribution Zone B",
      "message":
          "Water pressure has dropped below optimal levels. Check for potential leaks or pump issues.",
      "timestamp": "2025-08-26T09:15:00.000Z",
      "status": "active",
      "isRead": true,
      "parameterValue": 25.0,
      "thresholdValue": 30.0,
      "currentValue": 25.0,
      "unit": "PSI",
      "expanded": false,
    },
    {
      "id": 3,
      "type": "Temperature Alert",
      "severity": "info",
      "location": "Reservoir Station 1",
      "message":
          "Water temperature is approaching upper threshold. Monitor closely for potential issues.",
      "timestamp": "2025-08-26T08:45:00.000Z",
      "status": "resolved",
      "isRead": true,
      "parameterValue": 24.5,
      "thresholdValue": 25.0,
      "currentValue": 22.8,
      "unit": "°C",
      "expanded": false,
    },
    {
      "id": 4,
      "type": "Chlorine Level Low",
      "severity": "warning",
      "location": "Secondary Treatment - Unit C",
      "message":
          "Chlorine levels are below recommended range. Disinfection effectiveness may be compromised.",
      "timestamp": "2025-08-25T16:20:00.000Z",
      "status": "active",
      "isRead": false,
      "parameterValue": 0.15,
      "thresholdValue": 0.2,
      "currentValue": 0.15,
      "unit": "mg/L",
      "expanded": false,
    },
    {
      "id": 5,
      "type": "Flow Rate Anomaly",
      "severity": "critical",
      "location": "Main Distribution Line",
      "message":
          "Significant deviation in flow rate detected. Possible blockage or equipment malfunction.",
      "timestamp": "2025-08-25T14:10:00.000Z",
      "status": "resolved",
      "isRead": true,
      "parameterValue": 45.0,
      "thresholdValue": 75.0,
      "currentValue": 78.0,
      "unit": "L/min",
      "expanded": false,
    },
  ];

  List<Map<String, dynamic>> _filteredAlerts = [];
  Map<String, int> _filterCounts = {};

  // Mock alert configuration settings
  Map<String, dynamic> _alertSettings = {
    'ph': {
      'enabled': true,
      'minValue': 6.5,
      'maxValue': 8.5,
    },
    'temperature': {
      'enabled': true,
      'minValue': 15.0,
      'maxValue': 25.0,
    },
    'pressure': {
      'enabled': true,
      'minValue': 30.0,
      'maxValue': 80.0,
    },
    'chlorine': {
      'enabled': true,
      'minValue': 0.2,
      'maxValue': 4.0,
    },
    'notifications': {
      'pushEnabled': true,
      'emailEnabled': false,
      'smsEnabled': false,
      'criticalOnly': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredAlerts = List.from(_allAlerts);
    _updateFilterCounts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _updateFilterCounts() {
    _filterCounts = {
      'critical': _allAlerts
          .where((alert) => (alert['severity'] as String) == 'critical')
          .length,
      'warning': _allAlerts
          .where((alert) => (alert['severity'] as String) == 'warning')
          .length,
      'info': _allAlerts
          .where((alert) => (alert['severity'] as String) == 'info')
          .length,
      'active': _allAlerts
          .where((alert) => (alert['status'] as String) == 'active')
          .length,
      'resolved': _allAlerts
          .where((alert) => (alert['status'] as String) == 'resolved')
          .length,
      'today': _allAlerts
          .where(
              (alert) => _isToday(DateTime.parse(alert['timestamp'] as String)))
          .length,
      'week': _allAlerts
          .where((alert) =>
              _isThisWeek(DateTime.parse(alert['timestamp'] as String)))
          .length,
    };
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return date.isAfter(weekStart.subtract(Duration(days: 1)));
  }

  void _filterAlerts() {
    setState(() {
      _filteredAlerts = _allAlerts.where((alert) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          final location = (alert['location'] as String).toLowerCase();
          final type = (alert['type'] as String).toLowerCase();
          if (!location.contains(searchLower) && !type.contains(searchLower)) {
            return false;
          }
        }

        // Selected filters
        if (_selectedFilters.isNotEmpty) {
          for (String filter in _selectedFilters) {
            switch (filter) {
              case 'critical':
              case 'warning':
              case 'info':
                if ((alert['severity'] as String) != filter) continue;
                break;
              case 'active':
              case 'resolved':
                if ((alert['status'] as String) != filter) continue;
                break;
              case 'today':
                if (!_isToday(DateTime.parse(alert['timestamp'] as String)))
                  continue;
                break;
              case 'week':
                if (!_isThisWeek(DateTime.parse(alert['timestamp'] as String)))
                  continue;
                break;
            }
            return true;
          }
          return false;
        }

        return true;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterAlerts();
  }

  void _onFilterToggle(String filter) {
    setState(() {
      if (_selectedFilters.contains(filter)) {
        _selectedFilters.remove(filter);
      } else {
        _selectedFilters.add(filter);
      }
    });
    _filterAlerts();
  }

  void _onClearSearch() {
    setState(() {
      _searchQuery = '';
    });
    _filterAlerts();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network request
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      // In real app, this would fetch fresh data
    });
  }

  void _onAlertTap(int alertId) {
    setState(() {
      final alertIndex =
          _filteredAlerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _filteredAlerts[alertIndex]['expanded'] =
            !(_filteredAlerts[alertIndex]['expanded'] as bool);
      }
    });
  }

  void _onMarkAsRead(int alertId) {
    setState(() {
      final alertIndex =
          _allAlerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _allAlerts[alertIndex]['isRead'] = true;
      }
    });
    _filterAlerts();
  }

  void _onAcknowledge(int alertId) {
    setState(() {
      final alertIndex =
          _allAlerts.indexWhere((alert) => alert['id'] == alertId);
      if (alertIndex != -1) {
        _allAlerts[alertIndex]['status'] = 'resolved';
        _allAlerts[alertIndex]['isRead'] = true;
      }
    });
    _updateFilterCounts();
    _filterAlerts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert acknowledged and marked as resolved'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              final alertIndex =
                  _allAlerts.indexWhere((alert) => alert['id'] == alertId);
              if (alertIndex != -1) {
                _allAlerts[alertIndex]['status'] = 'active';
              }
            });
            _updateFilterCounts();
            _filterAlerts();
          },
        ),
      ),
    );
  }

  void _onViewLocation(int alertId) {
    final alert = _allAlerts.firstWhere((alert) => alert['id'] == alertId);
    Navigator.pushNamed(context, '/real-time-monitoring');
  }

  void _onArchive(int alertId) {
    setState(() {
      _allAlerts.removeWhere((alert) => alert['id'] == alertId);
    });
    _updateFilterCounts();
    _filterAlerts();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert archived')),
    );
  }

  void _onShare(int alertId) {
    final alert = _allAlerts.firstWhere((alert) => alert['id'] == alertId);
    // In real app, implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert shared: ${alert['type']}')),
    );
  }

  void _onExport(int alertId) {
    // In real app, implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Alert data exported')),
    );
  }

  void _onContactSupport(int alertId) {
    // In real app, implement support contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Contacting support...')),
    );
  }

  void _showConfigureAlerts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfigureAlertsBottomSheet(
        currentSettings: _alertSettings,
        onSaveSettings: (settings) {
          setState(() {
            _alertSettings = settings;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Alert settings saved successfully')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final int unreadCount =
        _allAlerts.where((alert) => !(alert['isRead'] as bool)).length;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Alerts & Notifications',
        showNotificationBadge: true,
        notificationCount: unreadCount,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: CustomIconWidget(
              iconName: 'person',
              color: colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Profile',
          ),
          IconButton(
            onPressed: _showConfigureAlerts,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Configure Alerts',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          CustomTabBar(
            tabs: AlertsTabs.items,
            controller: _tabController,
            showIcons: true,
            elevation: 2,
          ),

          // Search Bar
          SearchBarWidget(
            searchQuery: _searchQuery,
            onSearchChanged: _onSearchChanged,
            onClearSearch: _onClearSearch,
          ),

          // Filter Chips
          FilterChipsWidget(
            selectedFilters: _selectedFilters,
            onFilterToggle: _onFilterToggle,
            filterCounts: _filterCounts,
          ),

          // Offline indicator
          if (_isOffline)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              color: AppTheme.warningLight.withValues(alpha: 0.1),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_off',
                    color: AppTheme.warningLight,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Offline - Showing cached alerts',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: AppTheme.warningLight,
                    ),
                  ),
                ],
              ),
            ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActiveAlertsTab(),
                _buildHistoryTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: CustomBottomBar.getCurrentIndex('/alerts-notifications'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showConfigureAlerts,
        tooltip: 'Configure Alerts',
        child: CustomIconWidget(
          iconName: 'tune',
          color: colorScheme.onPrimary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildActiveAlertsTab() {
    final activeAlerts = _filteredAlerts
        .where((alert) => (alert['status'] as String) == 'active')
        .toList();

    if (activeAlerts.isEmpty &&
        _selectedFilters.isEmpty &&
        _searchQuery.isEmpty) {
      return EmptyStateWidget(
        onConfigureThresholds: _showConfigureAlerts,
      );
    }

    if (activeAlerts.isEmpty) {
      return _buildNoResultsWidget();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: activeAlerts.length,
        itemBuilder: (context, index) {
          final alert = activeAlerts[index];
          return AlertCardWidget(
            alert: alert,
            onTap: () => _onAlertTap(alert['id'] as int),
            onMarkAsRead: () => _onMarkAsRead(alert['id'] as int),
            onAcknowledge: () => _onAcknowledge(alert['id'] as int),
            onViewLocation: () => _onViewLocation(alert['id'] as int),
            onArchive: () => _onArchive(alert['id'] as int),
            onShare: () => _onShare(alert['id'] as int),
            onExport: () => _onExport(alert['id'] as int),
            onContactSupport: () => _onContactSupport(alert['id'] as int),
          );
        },
      ),
    );
  }

  Widget _buildHistoryTab() {
    final historyAlerts = _filteredAlerts
        .where((alert) => (alert['status'] as String) == 'resolved')
        .toList();

    if (historyAlerts.isEmpty) {
      return _buildNoResultsWidget();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        itemCount: historyAlerts.length,
        itemBuilder: (context, index) {
          final alert = historyAlerts[index];
          return AlertCardWidget(
            alert: alert,
            onTap: () => _onAlertTap(alert['id'] as int),
            onViewLocation: () => _onViewLocation(alert['id'] as int),
            onArchive: () => _onArchive(alert['id'] as int),
            onShare: () => _onShare(alert['id'] as int),
            onExport: () => _onExport(alert['id'] as int),
            onContactSupport: () => _onContactSupport(alert['id'] as int),
          );
        },
      ),
    );
  }

  Widget _buildSettingsTab() {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alert Configuration',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'tune',
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Threshold Settings',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Configure alert thresholds for water quality parameters and system monitoring.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  ElevatedButton.icon(
                    onPressed: _showConfigureAlerts,
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text('Configure Thresholds'),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'notifications',
                        color: colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Notification Preferences',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildNotificationSetting('Push Notifications',
                      _alertSettings['notifications']['pushEnabled'] as bool),
                  _buildNotificationSetting('Email Alerts',
                      _alertSettings['notifications']['emailEnabled'] as bool),
                  _buildNotificationSetting('SMS Alerts',
                      _alertSettings['notifications']['smsEnabled'] as bool),
                  _buildNotificationSetting('Critical Only',
                      _alertSettings['notifications']['criticalOnly'] as bool),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting(String title, bool value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                final notifications =
                    _alertSettings['notifications'] as Map<String, dynamic>;
                final key = title
                    .toLowerCase()
                    .replaceAll(' ', '')
                    .replaceAll('notifications', 'enabled')
                    .replaceAll('alerts', 'enabled')
                    .replaceAll('only', 'only');
                notifications[key] = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsWidget() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: colorScheme.onSurface.withValues(alpha: 0.4),
              size: 15.w,
            ),
            SizedBox(height: 3.h),
            Text(
              'No alerts found',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filters',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 3.h),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedFilters.clear();
                });
                _filterAlerts();
              },
              child: Text('Clear all filters'),
            ),
          ],
        ),
      ),
    );
  }
}
