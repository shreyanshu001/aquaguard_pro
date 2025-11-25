import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/connectivity_status_bar.dart';
import './widgets/critical_alerts_card.dart';
import './widgets/current_readings_card.dart';
import './widgets/emergency_alert_button.dart';
import './widgets/recent_activity_timeline.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  bool _isRefreshing = false;
  bool _isConnected = true;
  int _connectedSensors = 8;
  int _totalSensors = 10;
  DateTime _lastUpdated = DateTime.now();

  // Mock data for critical alerts
  final List<Map<String, dynamic>> _criticalAlerts = [
    {
      "id": 1,
      "title": "High Temperature Alert",
      "location": "Main Treatment Plant - Tank A",
      "severity": "high",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "description": "Water temperature exceeded safe threshold of 25°C",
    },
    {
      "id": 2,
      "title": "Low Pressure Warning",
      "location": "Distribution Point B",
      "severity": "medium",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
      "description": "Water pressure dropped below optimal range",
    },
    {
      "id": 3,
      "title": "pH Level Critical",
      "location": "Reservoir C - Sector 3",
      "severity": "critical",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "description": "pH level detected at 8.9, immediate attention required",
    },
  ];

  // Mock data for current readings
  final List<Map<String, dynamic>> _currentReadings = [
    {
      "id": 1,
      "parameter": "Water Temperature",
      "value": 23.5,
      "unit": "°C",
      "status": "normal",
      "location": "Main Treatment Plant",
      "sensorId": "TEMP_001",
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 2)),
      "threshold": 25.0,
      "accuracy": 0.1,
    },
    {
      "id": 2,
      "parameter": "Water Pressure",
      "value": 45.2,
      "unit": "PSI",
      "status": "warning",
      "location": "Distribution Point A",
      "sensorId": "PRES_002",
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 1)),
      "threshold": 50.0,
      "accuracy": 0.5,
    },
    {
      "id": 3,
      "parameter": "pH Level",
      "value": 7.2,
      "unit": "pH",
      "status": "safe",
      "location": "Reservoir B",
      "sensorId": "PH_003",
      "lastUpdated": DateTime.now().subtract(Duration(seconds: 30)),
      "threshold": 8.5,
      "accuracy": 0.05,
    },
    {
      "id": 4,
      "parameter": "Flow Rate",
      "value": 125.8,
      "unit": "L/min",
      "status": "normal",
      "location": "Main Pipeline",
      "sensorId": "FLOW_004",
      "lastUpdated": DateTime.now().subtract(Duration(minutes: 3)),
      "threshold": 150.0,
      "accuracy": 1.0,
    },
  ];

  // Mock data for recent activity
  final List<Map<String, dynamic>> _recentActivity = [
    {
      "id": 1,
      "type": "alert",
      "title": "Temperature threshold exceeded",
      "description": "Automatic cooling system activated",
      "location": "Main Treatment Plant",
      "timestamp": DateTime.now().subtract(Duration(minutes: 15)),
      "value": 26.2,
      "unit": "°C",
    },
    {
      "id": 2,
      "type": "maintenance",
      "title": "Sensor calibration completed",
      "description": "pH sensor recalibrated successfully",
      "location": "Reservoir C",
      "timestamp": DateTime.now().subtract(Duration(hours: 1)),
    },
    {
      "id": 3,
      "type": "reading",
      "title": "Routine water quality check",
      "description": "All parameters within normal range",
      "location": "Distribution Point B",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      "id": 4,
      "type": "system",
      "title": "Backup system activated",
      "description": "Primary pump maintenance mode",
      "location": "Pumping Station 1",
      "timestamp": DateTime.now().subtract(Duration(hours: 3)),
    },
    {
      "id": 5,
      "type": "success",
      "title": "Water quality test passed",
      "description": "Monthly compliance check completed",
      "location": "Quality Control Lab",
      "timestamp": DateTime.now().subtract(Duration(hours: 4)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildStickyHeader(context),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: colorScheme.primary,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          SizedBox(height: 1.h),
                          ConnectivityStatusBar(
                            isConnected: _isConnected,
                            connectedSensors: _connectedSensors,
                            totalSensors: _totalSensors,
                            onTap: () => _navigateToMonitoring(),
                          ),
                          CriticalAlertsCard(
                            alerts: _criticalAlerts,
                            onViewAll: () => _navigateToAlerts(),
                          ),
                          CurrentReadingsCard(
                            readings: _currentReadings,
                            onRefresh: _handleRefresh,
                          ),
                          RecentActivityTimeline(
                            activities: _recentActivity,
                            onViewAll: () => _navigateToReports(),
                          ),
                          SizedBox(height: 10.h), // Space for FAB
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStickyHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AquaGuard Pro',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                _formatCurrentDateTime(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/profile'),
                icon: CustomIconWidget(
                  iconName: 'person',
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 24,
                ),
                tooltip: 'Profile',
              ),
              IconButton(
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                icon: CustomIconWidget(
                  iconName: 'settings',
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  size: 24,
                ),
                tooltip: 'Settings',
              ),
              SizedBox(width: 2.w),
              EmergencyAlertButton(
                isActive: _criticalAlerts.any((alert) =>
                    (alert['severity'] as String).toLowerCase() == 'critical'),
                onPressed: _handleEmergencyAlert,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FloatingActionButton.extended(
      onPressed: _showQuickActions,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      icon: CustomIconWidget(
        iconName: 'add',
        color: colorScheme.onPrimary,
        size: 6.w,
      ),
      label: Text(
        'Quick Action',
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Simulate network delay
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
      _lastUpdated = DateTime.now();
      // Simulate connection status changes
      _connectedSensors = (_connectedSensors == _totalSensors)
          ? _totalSensors - 1
          : _totalSensors;
    });

    // Show success feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'refresh',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Data refreshed successfully',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 3.h),
            _buildQuickActionItem(
              'Add Location',
              'Connect a new monitoring location',
              Icons.add_location,
              () => _handleAddLocation(),
            ),
            _buildQuickActionItem(
              'Manual Reading',
              'Record a manual sensor reading',
              Icons.edit,
              () => _handleManualReading(),
            ),
            _buildQuickActionItem(
              'System Check',
              'Run comprehensive system diagnostics',
              Icons.health_and_safety,
              () => _handleSystemCheck(),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionItem(
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: _getIconName(icon),
                color: colorScheme.primary,
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
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 4.w,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.add_location) return 'add_location';
    if (icon == Icons.edit) return 'edit';
    if (icon == Icons.health_and_safety) return 'health_and_safety';
    return 'help';
  }

  String _formatCurrentDateTime() {
    final now = DateTime.now();
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    final month = months[now.month - 1];
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$month $day, ${now.year} • $hour:$minute';
  }

  void _navigateToMonitoring() {
    Navigator.pushNamed(context, '/real-time-monitoring');
  }

  void _navigateToAlerts() {
    Navigator.pushNamed(context, '/alerts-notifications');
  }

  void _navigateToReports() {
    Navigator.pushNamed(context, '/reports-analytics');
  }

  void _handleEmergencyAlert() {
    // Emergency alert logic is handled in the EmergencyAlertButton widget
  }

  void _handleAddLocation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Add Location feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleManualReading() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Manual Reading feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleSystemCheck() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('System Check initiated'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
