import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/location_selector_widget.dart';
import './widgets/parameter_detail_sheet.dart';
import './widgets/pressure_gauge_widget.dart';
import './widgets/temperature_chart_widget.dart';
import './widgets/water_quality_grid_widget.dart';
import 'widgets/location_selector_widget.dart';
import 'widgets/parameter_detail_sheet.dart';
import 'widgets/pressure_gauge_widget.dart';
import 'widgets/temperature_chart_widget.dart';
import 'widgets/water_quality_grid_widget.dart';

class RealTimeMonitoring extends StatefulWidget {
  @override
  State<RealTimeMonitoring> createState() => _RealTimeMonitoringState();
}

class _RealTimeMonitoringState extends State<RealTimeMonitoring>
    with TickerProviderStateMixin {
  late PageController _locationPageController;
  late AnimationController _refreshAnimationController;

  int _selectedLocationIndex = 0;
  String _selectedTimeRange = '24H';
  bool _isRefreshing = false;

  // Mock data for locations
  final List<Map<String, dynamic>> _locations = [
    {
      "id": 1,
      "name": "Main Treatment Plant",
      "address": "1234 Water St, Downtown",
      "status": "Online",
      "sensorCount": 12,
      "coordinates": {"lat": 40.7128, "lng": -74.0060},
    },
    {
      "id": 2,
      "name": "North Distribution Center",
      "address": "5678 Pipeline Ave, North District",
      "status": "Warning",
      "sensorCount": 8,
      "coordinates": {"lat": 40.7589, "lng": -73.9851},
    },
    {
      "id": 3,
      "name": "East Reservoir Station",
      "address": "9012 Reservoir Rd, East Side",
      "status": "Online",
      "sensorCount": 15,
      "coordinates": {"lat": 40.7282, "lng": -73.7949},
    },
    {
      "id": 4,
      "name": "South Pumping Station",
      "address": "3456 Pump House Ln, South End",
      "status": "Maintenance",
      "sensorCount": 6,
      "coordinates": {"lat": 40.6892, "lng": -74.0445},
    },
  ];

  // Mock temperature data
  final List<Map<String, dynamic>> _temperatureData = [
    {"time": "00:00", "temperature": 22.5},
    {"time": "02:00", "temperature": 21.8},
    {"time": "04:00", "temperature": 21.2},
    {"time": "06:00", "temperature": 20.9},
    {"time": "08:00", "temperature": 22.1},
    {"time": "10:00", "temperature": 23.4},
    {"time": "12:00", "temperature": 24.8},
    {"time": "14:00", "temperature": 25.2},
    {"time": "16:00", "temperature": 24.9},
    {"time": "18:00", "temperature": 23.7},
    {"time": "20:00", "temperature": 23.1},
    {"time": "22:00", "temperature": 22.8},
  ];

  // Mock water quality parameters
  final List<Map<String, dynamic>> _waterQualityParameters = [
    {
      "name": "pH Level",
      "value": 7.2,
      "unit": "pH",
      "status": "Safe",
      "trend": "stable",
      "icon": "science",
      "description": "Acidity/alkalinity measurement",
      "minThreshold": 6.5,
      "maxThreshold": 8.5,
      "warningThreshold": 8.0,
      "criticalThreshold": 9.0,
    },
    {
      "name": "Chlorine",
      "value": 1.8,
      "unit": "mg/L",
      "status": "Safe",
      "trend": "down",
      "icon": "water_drop",
      "description": "Disinfectant concentration",
      "minThreshold": 0.5,
      "maxThreshold": 4.0,
      "warningThreshold": 3.5,
      "criticalThreshold": 5.0,
    },
    {
      "name": "Turbidity",
      "value": 0.3,
      "unit": "NTU",
      "status": "Safe",
      "trend": "stable",
      "icon": "visibility",
      "description": "Water clarity measurement",
      "minThreshold": 0.0,
      "maxThreshold": 1.0,
      "warningThreshold": 0.8,
      "criticalThreshold": 1.5,
    },
    {
      "name": "Dissolved O2",
      "value": 8.5,
      "unit": "mg/L",
      "status": "Good",
      "trend": "up",
      "icon": "air",
      "description": "Oxygen content in water",
      "minThreshold": 5.0,
      "maxThreshold": 14.0,
      "warningThreshold": 12.0,
      "criticalThreshold": 15.0,
    },
    {
      "name": "Conductivity",
      "value": 450.2,
      "unit": "μS/cm",
      "status": "Warning",
      "trend": "up",
      "icon": "electrical_services",
      "description": "Electrical conductivity",
      "minThreshold": 50.0,
      "maxThreshold": 500.0,
      "warningThreshold": 450.0,
      "criticalThreshold": 600.0,
    },
    {
      "name": "Temperature",
      "value": 23.4,
      "unit": "°C",
      "status": "Safe",
      "trend": "stable",
      "icon": "thermostat",
      "description": "Water temperature",
      "minThreshold": 4.0,
      "maxThreshold": 30.0,
      "warningThreshold": 28.0,
      "criticalThreshold": 35.0,
    },
  ];

  // Mock historical data for parameter details
  final List<Map<String, dynamic>> _historicalData = [
    {"time": "00:00", "value": 7.1},
    {"time": "02:00", "value": 7.0},
    {"time": "04:00", "value": 7.2},
    {"time": "06:00", "value": 7.3},
    {"time": "08:00", "value": 7.2},
    {"time": "10:00", "value": 7.1},
    {"time": "12:00", "value": 7.4},
    {"time": "14:00", "value": 7.3},
    {"time": "16:00", "value": 7.2},
    {"time": "18:00", "value": 7.1},
    {"time": "20:00", "value": 7.2},
    {"time": "22:00", "value": 7.2},
  ];

  @override
  void initState() {
    super.initState();
    _locationPageController = PageController();
    _refreshAnimationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _locationPageController.dispose();
    _refreshAnimationController.dispose();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Simulate auto-refresh every 30 seconds
    Future.delayed(Duration(seconds: 30), () {
      if (mounted) {
        _refreshData();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    _refreshAnimationController.repeat();

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Simulate data refresh
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      setState(() => _isRefreshing = false);
      _refreshAnimationController.stop();
      _refreshAnimationController.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data refreshed successfully'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onLocationChanged(int index) {
    setState(() => _selectedLocationIndex = index);
    HapticFeedback.selectionClick();
  }

  void _onTimeRangeChanged(String range) {
    setState(() => _selectedTimeRange = range);
    HapticFeedback.selectionClick();
  }

  void _onParameterTap(Map<String, dynamic> parameter) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ParameterDetailSheet(
        parameter: parameter,
        historicalData: _historicalData,
        onExport: _exportParameterData,
        onSetThreshold: _setThreshold,
      ),
    );
  }

  void _exportParameterData() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Parameter data exported successfully'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _setThreshold() {
    Navigator.of(context).pop();
    _showThresholdDialog();
  }

  void _showThresholdDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Set Threshold',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Threshold configuration will be available in the next update.',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monitoring Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  SizedBox(height: 3.h),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'refresh',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Auto Refresh'),
                    subtitle: Text('Refresh data every 30 seconds'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'notifications',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Push Notifications'),
                    subtitle: Text('Alert for threshold breaches'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'vibration',
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    title: Text('Haptic Feedback'),
                    subtitle: Text('Vibration for interactions'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentLocation = _locations[_selectedLocationIndex];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Real-time Monitoring',
        showNotificationBadge: true,
        notificationCount: 3,
        actions: [
          AnimatedBuilder(
            animation: _refreshAnimationController,
            builder: (context, child) {
              return IconButton(
                onPressed: _isRefreshing ? null : _refreshData,
                icon: Transform.rotate(
                  angle: _refreshAnimationController.value * 2 * 3.14159,
                  child: CustomIconWidget(
                    iconName: 'refresh',
                    color: _isRefreshing
                        ? colorScheme.primary.withValues(alpha: 0.5)
                        : colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
                tooltip: 'Refresh Data',
              );
            },
          ),
          IconButton(
            onPressed: _showSettingsBottomSheet,
            icon: CustomIconWidget(
              iconName: 'settings',
              color: colorScheme.onPrimary,
              size: 24,
            ),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Selector
              LocationSelectorWidget(
                locations: _locations,
                selectedLocationIndex: _selectedLocationIndex,
                pageController: _locationPageController,
                onLocationChanged: _onLocationChanged,
              ),

              SizedBox(height: 2.h),

              // Current Location Info
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Monitoring Location',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            currentLocation["name"] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: _getLocationStatusColor(
                                currentLocation["status"] as String)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentLocation["status"] as String,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: _getLocationStatusColor(
                              currentLocation["status"] as String),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Temperature Chart
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: TemperatureChartWidget(
                  temperatureData: _temperatureData,
                  selectedTimeRange: _selectedTimeRange,
                  onTimeRangeChanged: _onTimeRangeChanged,
                ),
              ),

              SizedBox(height: 3.h),

              // Pressure Gauge
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: PressureGaugeWidget(
                  currentPressure: 65.8,
                  minPressure: 0,
                  maxPressure: 100,
                  unit: 'PSI',
                  status: 'Normal',
                ),
              ),

              SizedBox(height: 3.h),

              // Water Quality Parameters Grid
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: WaterQualityGridWidget(
                  qualityParameters: _waterQualityParameters,
                  onParameterTap: _onParameterTap,
                ),
              ),

              SizedBox(height: 10.h), // Bottom padding for navigation
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: CustomBottomBar.getCurrentIndex('/real-time-monitoring'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Quick alert configuration coming soon'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: CustomIconWidget(
          iconName: 'tune',
          color:
              theme.floatingActionButtonTheme.foregroundColor ?? Colors.white,
          size: 24,
        ),
        tooltip: 'Quick Settings',
      ),
    );
  }

  Color _getLocationStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
      case 'normal':
        return AppTheme.successLight;
      case 'warning':
      case 'maintenance':
        return AppTheme.warningLight;
      case 'offline':
      case 'error':
      case 'critical':
        return AppTheme.errorLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}