import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/report_header_widget.dart';
import './widgets/interactive_chart_widget.dart';
import './widgets/summary_statistics_card.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/export_options_bottom_sheet.dart';
import './widgets/quick_insights_card.dart';
import './widgets/forecast_section_widget.dart';
import './widgets/empty_insights_state.dart';

class ReportsAnalytics extends StatefulWidget {
  const ReportsAnalytics({Key? key}) : super(key: key);

  @override
  State<ReportsAnalytics> createState() => _ReportsAnalyticsState();
}

class _ReportsAnalyticsState extends State<ReportsAnalytics>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String _selectedDateRange = '30D';
  String _selectedLocation = 'All Locations';
  String _selectedParameter = 'All Parameters';
  bool _hasOfflineData = true;

  // Mock data for different report types
  final Map<String, List<Map<String, dynamic>>> _reportData = {
    'Quality': [
      {
        'timestamp': DateTime.now().subtract(Duration(days: 29)),
        'pH': 7.2,
        'chlorine': 2.1,
        'turbidity': 0.8,
        'temperature': 22.5,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 20)),
        'pH': 7.4,
        'chlorine': 1.9,
        'turbidity': 1.2,
        'temperature': 23.8,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 15)),
        'pH': 7.1,
        'chlorine': 2.3,
        'turbidity': 0.6,
        'temperature': 21.2,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 10)),
        'pH': 7.6,
        'chlorine': 1.7,
        'turbidity': 1.1,
        'temperature': 24.1,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 5)),
        'pH': 7.3,
        'chlorine': 2.0,
        'turbidity': 0.9,
        'temperature': 22.8,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 1)),
        'pH': 7.5,
        'chlorine': 1.8,
        'turbidity': 0.7,
        'temperature': 23.5,
      },
    ],
    'Consumption': [
      {
        'timestamp': DateTime.now().subtract(Duration(days: 29)),
        'daily_usage': 1250.5,
        'peak_hour': 850.2,
        'efficiency': 92.3,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 25)),
        'daily_usage': 1180.3,
        'peak_hour': 780.5,
        'efficiency': 94.1,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 20)),
        'daily_usage': 1320.8,
        'peak_hour': 920.7,
        'efficiency': 89.8,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 15)),
        'daily_usage': 1100.2,
        'peak_hour': 720.1,
        'efficiency': 96.5,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 10)),
        'daily_usage': 1290.6,
        'peak_hour': 880.3,
        'efficiency': 91.2,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 5)),
        'daily_usage': 1220.4,
        'peak_hour': 810.6,
        'efficiency': 93.7,
      },
    ],
    'Compliance': [
      {
        'timestamp': DateTime.now().subtract(Duration(days: 30)),
        'compliance_score': 98.2,
        'violations': 0,
        'passed_tests': 45,
        'failed_tests': 1,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 20)),
        'compliance_score': 96.8,
        'violations': 1,
        'passed_tests': 42,
        'failed_tests': 2,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 15)),
        'compliance_score': 99.1,
        'violations': 0,
        'passed_tests': 48,
        'failed_tests': 0,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 10)),
        'compliance_score': 97.5,
        'violations': 0,
        'passed_tests': 44,
        'failed_tests': 1,
      },
      {
        'timestamp': DateTime.now().subtract(Duration(days: 5)),
        'compliance_score': 98.9,
        'violations': 0,
        'passed_tests': 47,
        'failed_tests': 0,
      },
    ],
    'Forecasting': [
      {
        'timestamp': DateTime.now().add(Duration(days: 7)),
        'predicted_usage': 1280.5,
        'maintenance_score': 85.2,
        'efficiency_trend': 'stable',
      },
      {
        'timestamp': DateTime.now().add(Duration(days: 14)),
        'predicted_usage': 1350.8,
        'maintenance_score': 82.1,
        'efficiency_trend': 'declining',
      },
      {
        'timestamp': DateTime.now().add(Duration(days: 21)),
        'predicted_usage': 1420.3,
        'maintenance_score': 78.9,
        'efficiency_trend': 'declining',
      },
      {
        'timestamp': DateTime.now().add(Duration(days: 30)),
        'predicted_usage': 1480.7,
        'maintenance_score': 75.5,
        'efficiency_trend': 'needs_attention',
      },
    ],
  };

  final List<Map<String, dynamic>> _quickInsights = [
    {
      'type': 'anomaly',
      'title': 'pH Spike Detected',
      'description':
          'Unusual pH levels recorded at Treatment Plant A between 2:00-4:00 PM',
      'severity': 'medium',
      'timestamp': DateTime.now().subtract(Duration(hours: 6)),
      'action': 'investigate',
    },
    {
      'type': 'efficiency',
      'title': 'Efficiency Improvement',
      'description': 'Water treatment efficiency increased by 3.2% this week',
      'severity': 'positive',
      'timestamp': DateTime.now().subtract(Duration(days: 1)),
      'action': 'monitor',
    },
    {
      'type': 'maintenance',
      'title': 'Maintenance Scheduled',
      'description': 'Filter replacement recommended for optimal performance',
      'severity': 'low',
      'timestamp': DateTime.now().subtract(Duration(days: 2)),
      'action': 'schedule',
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadReportData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _isLoading = true;
      });
      _loadReportData();

      // Provide haptic feedback
      HapticFeedback.selectionClick();
    }
  }

  Future<void> _loadReportData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(Duration(milliseconds: 800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            ReportHeaderWidget(
              selectedDateRange: _selectedDateRange,
              onDateRangeChanged: (range) {
                setState(() {
                  _selectedDateRange = range;
                });
                _loadReportData();
              },
              onExportPressed: _showExportOptions,
            ),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReportContent('Quality'),
                  _buildReportContent('Consumption'),
                  _buildReportContent('Compliance'),
                  _buildReportContent('Forecasting'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFilterFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
      child: TabBar(
        controller: _tabController,
        labelColor: colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
        indicatorColor: colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 3,
        labelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        tabs: [
          Tab(text: 'Quality'),
          Tab(text: 'Consumption'),
          Tab(text: 'Compliance'),
          Tab(text: 'Forecasting'),
        ],
      ),
    );
  }

  Widget _buildReportContent(String reportType) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 2.h),
            Text(
              'Loading ${reportType} Report...',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    final data = _reportData[reportType] ?? [];

    if (data.isEmpty) {
      return EmptyInsightsState(
        reportType: reportType,
        onSetupPressed: _handleSetupAssistance,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReportData,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                SizedBox(height: 2.h),
                SummaryStatisticsCard(
                  reportType: reportType,
                  data: data,
                  dateRange: _selectedDateRange,
                ),
                InteractiveChartWidget(
                  reportType: reportType,
                  data: data,
                  onDataPointTapped: _showDataPointDetails,
                ),
                if (_quickInsights.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  QuickInsightsCard(
                    insights: _quickInsights,
                    onInsightTapped: _investigateInsight,
                  ),
                ],
                if (reportType == 'Forecasting') ...[
                  SizedBox(height: 2.h),
                  ForecastSectionWidget(
                    forecastData: _reportData['Forecasting'] ?? [],
                  ),
                ],
                SizedBox(height: 10.h), // Space for FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFAB() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FloatingActionButton.extended(
      onPressed: _showFilterOptions,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      icon: CustomIconWidget(
        iconName: 'filter_list',
        color: colorScheme.onPrimary,
        size: 5.w,
      ),
      label: Text(
        'Filter',
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ExportOptionsBottomSheet(
            reportType:
                [
                  'Quality',
                  'Consumption',
                  'Compliance',
                  'Forecasting',
                ][_tabController.index],
            onExport: _handleExport,
          ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FilterBottomSheet(
            selectedLocation: _selectedLocation,
            selectedParameter: _selectedParameter,
            selectedDateRange: _selectedDateRange,
            onFiltersApplied: (location, parameter, dateRange) {
              setState(() {
                _selectedLocation = location;
                _selectedParameter = parameter;
                _selectedDateRange = dateRange;
              });
              _loadReportData();
            },
          ),
    );
  }

  void _showDataPointDetails(Map<String, dynamic> dataPoint) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Data Point Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  dataPoint.entries
                      .where((entry) => entry.key != 'timestamp')
                      .map(
                        (entry) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.5.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatParameterName(entry.key),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                '${entry.value}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
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

  String _formatParameterName(String key) {
    switch (key) {
      case 'pH':
        return 'pH Level';
      case 'chlorine':
        return 'Chlorine (mg/L)';
      case 'turbidity':
        return 'Turbidity (NTU)';
      case 'temperature':
        return 'Temperature (°C)';
      case 'daily_usage':
        return 'Daily Usage (L)';
      case 'peak_hour':
        return 'Peak Hour (L)';
      case 'efficiency':
        return 'Efficiency (%)';
      case 'compliance_score':
        return 'Compliance Score (%)';
      case 'violations':
        return 'Violations';
      case 'passed_tests':
        return 'Passed Tests';
      case 'failed_tests':
        return 'Failed Tests';
      case 'predicted_usage':
        return 'Predicted Usage (L)';
      case 'maintenance_score':
        return 'Maintenance Score (%)';
      case 'efficiency_trend':
        return 'Efficiency Trend';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }

  void _investigateInsight(Map<String, dynamic> insight) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(insight['title']),
            content: Text(insight['description']),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Dismiss'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleInsightAction(insight);
                },
                child: Text('Investigate'),
              ),
            ],
          ),
    );
  }

  void _handleInsightAction(Map<String, dynamic> insight) {
    final message = 'Investigating: ${insight["title"]}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'View Details',
          onPressed: () {
            // Navigate to detailed investigation screen
          },
        ),
      ),
    );
  }

  Future<void> _handleExport(String format, List<String> sections) async {
    final theme = Theme.of(context);
    final reportType =
        ['Quality', 'Consumption', 'Compliance', 'Forecasting'][_tabController
            .index];

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 2.h),
                    Text('Generating ${format.toUpperCase()} report...'),
                  ],
                ),
              ),
            ),
          ),
    );

    // Simulate export process
    await Future.delayed(Duration(seconds: 2));

    Navigator.of(context).pop(); // Close loading dialog

    if (kIsWeb) {
      // Web-specific download logic
      _downloadFileWeb(format, reportType, sections);
    } else {
      // Mobile file saving logic
      _saveFileMobile(format, reportType, sections);
    }
  }

  void _downloadFileWeb(
    String format,
    String reportType,
    List<String> sections,
  ) {
    final content = _generateReportContent(format, reportType, sections);
    final filename =
        '${reportType}_Report_${DateTime.now().millisecondsSinceEpoch}.$format';

    // Create download trigger for web
    // This would integrate with universal_html package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format report download started'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Open in new tab
          },
        ),
      ),
    );
  }

  void _saveFileMobile(
    String format,
    String reportType,
    List<String> sections,
  ) {
    final content = _generateReportContent(format, reportType, sections);
    final filename =
        '${reportType}_Report_${DateTime.now().millisecondsSinceEpoch}.$format';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$format report saved to Downloads'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () {
            _shareReport(filename, content);
          },
        ),
      ),
    );
  }

  String _generateReportContent(
    String format,
    String reportType,
    List<String> sections,
  ) {
    final data = _reportData[reportType] ?? [];
    final timestamp = DateTime.now();

    if (format == 'csv') {
      return _generateCSVContent(data, reportType);
    } else {
      return _generateJSONContent(data, reportType, sections, timestamp);
    }
  }

  String _generateCSVContent(
    List<Map<String, dynamic>> data,
    String reportType,
  ) {
    if (data.isEmpty) return 'No data available';

    final headers = data.first.keys.toList();
    final csvContent = StringBuffer();

    // Add headers
    csvContent.writeln(headers.join(','));

    // Add data rows
    for (final row in data) {
      final values = headers.map((key) => row[key]?.toString() ?? '').toList();
      csvContent.writeln(values.join(','));
    }

    return csvContent.toString();
  }

  String _generateJSONContent(
    List<Map<String, dynamic>> data,
    String reportType,
    List<String> sections,
    DateTime timestamp,
  ) {
    final reportData = {
      'report_type': reportType,
      'generated_at': timestamp.toIso8601String(),
      'date_range': _selectedDateRange,
      'location_filter': _selectedLocation,
      'parameter_filter': _selectedParameter,
      'sections': sections,
      'data': data,
      'summary': _generateSummaryData(data, reportType),
    };

    return reportData
        .toString(); // Would use json.encode in real implementation
  }

  Map<String, dynamic> _generateSummaryData(
    List<Map<String, dynamic>> data,
    String reportType,
  ) {
    if (data.isEmpty) return {};

    switch (reportType) {
      case 'Quality':
        return {
          'avg_pH': _calculateAverage(data, 'pH'),
          'avg_chlorine': _calculateAverage(data, 'chlorine'),
          'avg_turbidity': _calculateAverage(data, 'turbidity'),
          'avg_temperature': _calculateAverage(data, 'temperature'),
        };
      case 'Consumption':
        return {
          'total_usage': _calculateSum(data, 'daily_usage'),
          'avg_efficiency': _calculateAverage(data, 'efficiency'),
          'peak_usage': _calculateMax(data, 'peak_hour'),
        };
      case 'Compliance':
        return {
          'avg_score': _calculateAverage(data, 'compliance_score'),
          'total_violations': _calculateSum(data, 'violations'),
          'test_success_rate': _calculateTestSuccessRate(data),
        };
      default:
        return {};
    }
  }

  double _calculateAverage(List<Map<String, dynamic>> data, String key) {
    if (data.isEmpty) return 0.0;
    final sum = data.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0));
    return sum / data.length;
  }

  double _calculateSum(List<Map<String, dynamic>> data, String key) {
    return data.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0));
  }

  double _calculateMax(List<Map<String, dynamic>> data, String key) {
    if (data.isEmpty) return 0.0;
    return data.fold<double>(0.0, (max, item) {
      final value = item[key] ?? 0.0;
      return value > max ? value : max;
    });
  }

  double _calculateTestSuccessRate(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return 0.0;
    final totalPassed = _calculateSum(data, 'passed_tests');
    final totalFailed = _calculateSum(data, 'failed_tests');
    final totalTests = totalPassed + totalFailed;
    return totalTests > 0 ? (totalPassed / totalTests) * 100 : 0.0;
  }

  void _shareReport(String filename, String content) {
    // Implement system share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality would open system share dialog'),
      ),
    );
  }

  void _handleSetupAssistance() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: 'sensors',
                  color: Theme.of(context).colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 2.w),
                Text('Sensor Setup'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To start generating reports, you need to:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 2.h),
                _buildSetupStep(1, 'Connect water quality sensors'),
                _buildSetupStep(2, 'Configure monitoring parameters'),
                _buildSetupStep(3, 'Set up data collection schedule'),
                _buildSetupStep(4, 'Enable automatic reporting'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Later'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _startSetupProcess();
                },
                child: Text('Start Setup'),
              ),
            ],
          ),
    );
  }

  Widget _buildSetupStep(int step, String description) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$step',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(child: Text(description, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  void _startSetupProcess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Setup wizard would launch here'),
        action: SnackBarAction(
          label: 'Continue',
          onPressed: () {
            // Navigate to setup wizard
          },
        ),
      ),
    );
  }
}
