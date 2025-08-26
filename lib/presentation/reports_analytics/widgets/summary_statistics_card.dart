import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SummaryStatisticsCard extends StatelessWidget {
  final String reportType;
  final List<Map<String, dynamic>> data;
  final String dateRange;

  const SummaryStatisticsCard({
    Key? key,
    required this.reportType,
    required this.data,
    required this.dateRange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    final statistics = _calculateStatistics();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                isLight
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary Statistics',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Last $dateRange',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: _getOverallStatusColor(
                    colorScheme,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: _getOverallStatusIcon(),
                      color: _getOverallStatusColor(colorScheme),
                      size: 4.w,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _getOverallStatus(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getOverallStatusColor(colorScheme),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 1.2,
            ),
            itemCount: statistics.length,
            itemBuilder: (context, index) {
              final stat = statistics[index];
              return _buildStatisticItem(context, stat);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticItem(BuildContext context, Map<String, dynamic> stat) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconWidget(
                iconName: stat['icon'],
                color: stat['color'],
                size: 5.w,
              ),
              if (stat['trend'] != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: _getTrendColor(
                      stat['trend'],
                      colorScheme,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: _getTrendIcon(stat['trend']),
                        color: _getTrendColor(stat['trend'], colorScheme),
                        size: 3.w,
                      ),
                      SizedBox(width: 0.5.w),
                      Text(
                        '${(stat['change'] as double).abs().toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: _getTrendColor(stat['trend'], colorScheme),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Spacer(),
          Text(
            stat['value'],
            style: AppTheme.dataDisplayMedium(
              context,
            ).copyWith(color: colorScheme.onSurface),
          ),
          SizedBox(height: 0.5.h),
          Text(
            stat['label'],
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _calculateStatistics() {
    if (data.isEmpty) return [];

    switch (reportType) {
      case 'Quality':
        return _calculateQualityStatistics();
      case 'Consumption':
        return _calculateConsumptionStatistics();
      case 'Compliance':
        return _calculateComplianceStatistics();
      case 'Forecasting':
        return _calculateForecastingStatistics();
      default:
        return [];
    }
  }

  List<Map<String, dynamic>> _calculateQualityStatistics() {
    final avgPH = _calculateAverage('pH');
    final avgChlorine = _calculateAverage('chlorine');
    final avgTurbidity = _calculateAverage('turbidity');
    final avgTemperature = _calculateAverage('temperature');

    return [
      {
        'label': 'Average pH',
        'value': avgPH.toStringAsFixed(1),
        'icon': 'science',
        'color': _getParameterColor('pH'),
        'trend': _calculateTrend('pH'),
        'change': _calculatePercentageChange('pH'),
      },
      {
        'label': 'Chlorine Level',
        'value': '${avgChlorine.toStringAsFixed(1)}mg/L',
        'icon': 'water_drop',
        'color': _getParameterColor('chlorine'),
        'trend': _calculateTrend('chlorine'),
        'change': _calculatePercentageChange('chlorine'),
      },
      {
        'label': 'Turbidity',
        'value': '${avgTurbidity.toStringAsFixed(1)}NTU',
        'icon': 'visibility_off',
        'color': _getParameterColor('turbidity'),
        'trend': _calculateTrend('turbidity'),
        'change': _calculatePercentageChange('turbidity'),
      },
      {
        'label': 'Temperature',
        'value': '${avgTemperature.toStringAsFixed(1)}°C',
        'icon': 'thermostat',
        'color': _getParameterColor('temperature'),
        'trend': _calculateTrend('temperature'),
        'change': _calculatePercentageChange('temperature'),
      },
    ];
  }

  List<Map<String, dynamic>> _calculateConsumptionStatistics() {
    final totalUsage = _calculateSum('daily_usage');
    final avgEfficiency = _calculateAverage('efficiency');
    final peakUsage = _calculateMax('peak_hour');
    final usagePerDay = totalUsage / data.length;

    return [
      {
        'label': 'Total Usage',
        'value': '${totalUsage.toStringAsFixed(0)}L',
        'icon': 'water',
        'color': AppTheme.primaryLight,
        'trend': _calculateTrend('daily_usage'),
        'change': _calculatePercentageChange('daily_usage'),
      },
      {
        'label': 'Avg Efficiency',
        'value': '${avgEfficiency.toStringAsFixed(1)}%',
        'icon': 'eco',
        'color': AppTheme.successLight,
        'trend': _calculateTrend('efficiency'),
        'change': _calculatePercentageChange('efficiency'),
      },
      {
        'label': 'Peak Usage',
        'value': '${peakUsage.toStringAsFixed(0)}L/h',
        'icon': 'trending_up',
        'color': AppTheme.warningLight,
        'trend': _calculateTrend('peak_hour'),
        'change': _calculatePercentageChange('peak_hour'),
      },
      {
        'label': 'Daily Average',
        'value': '${usagePerDay.toStringAsFixed(0)}L',
        'icon': 'analytics',
        'color': AppTheme.accentLight,
        'trend': null,
        'change': 0.0,
      },
    ];
  }

  List<Map<String, dynamic>> _calculateComplianceStatistics() {
    final avgScore = _calculateAverage('compliance_score');
    final totalViolations = _calculateSum('violations').toInt();
    final totalTests =
        _calculateSum('passed_tests') + _calculateSum('failed_tests');
    final passRate =
        totalTests > 0 ? (_calculateSum('passed_tests') / totalTests) * 100 : 0;

    return [
      {
        'label': 'Compliance Score',
        'value': '${avgScore.toStringAsFixed(1)}%',
        'icon': 'verified',
        'color':
            avgScore >= 95
                ? AppTheme.successLight
                : avgScore >= 85
                ? AppTheme.warningLight
                : AppTheme.errorLight,
        'trend': _calculateTrend('compliance_score'),
        'change': _calculatePercentageChange('compliance_score'),
      },
      {
        'label': 'Total Violations',
        'value': totalViolations.toString(),
        'icon': 'warning',
        'color':
            totalViolations == 0 ? AppTheme.successLight : AppTheme.errorLight,
        'trend': _calculateTrend('violations'),
        'change': _calculatePercentageChange('violations'),
      },
      {
        'label': 'Test Pass Rate',
        'value': '${passRate.toStringAsFixed(1)}%',
        'icon': 'check_circle',
        'color':
            passRate >= 95
                ? AppTheme.successLight
                : passRate >= 85
                ? AppTheme.warningLight
                : AppTheme.errorLight,
        'trend':
            passRate >= 90
                ? 'up'
                : passRate >= 80
                ? 'stable'
                : 'down',
        'change': 0.0,
      },
      {
        'label': 'Total Tests',
        'value': totalTests.toStringAsFixed(0),
        'icon': 'assignment',
        'color': AppTheme.primaryLight,
        'trend': null,
        'change': 0.0,
      },
    ];
  }

  List<Map<String, dynamic>> _calculateForecastingStatistics() {
    final avgPredictedUsage = _calculateAverage('predicted_usage');
    final avgMaintenanceScore = _calculateAverage('maintenance_score');
    final trendingDown =
        data.where((d) => d['efficiency_trend'] == 'declining').length;
    final needsAttention =
        data.where((d) => d['efficiency_trend'] == 'needs_attention').length;

    return [
      {
        'label': 'Predicted Usage',
        'value': '${avgPredictedUsage.toStringAsFixed(0)}L',
        'icon': 'trending_up',
        'color': AppTheme.primaryLight,
        'trend': 'up',
        'change': 5.2,
      },
      {
        'label': 'Maintenance Score',
        'value': '${avgMaintenanceScore.toStringAsFixed(1)}%',
        'icon': 'build',
        'color':
            avgMaintenanceScore >= 85
                ? AppTheme.successLight
                : avgMaintenanceScore >= 70
                ? AppTheme.warningLight
                : AppTheme.errorLight,
        'trend': avgMaintenanceScore >= 85 ? 'stable' : 'down',
        'change': 2.1,
      },
      {
        'label': 'Declining Trends',
        'value': trendingDown.toString(),
        'icon': 'trending_down',
        'color':
            trendingDown == 0 ? AppTheme.successLight : AppTheme.warningLight,
        'trend': null,
        'change': 0.0,
      },
      {
        'label': 'Needs Attention',
        'value': needsAttention.toString(),
        'icon': 'priority_high',
        'color':
            needsAttention == 0 ? AppTheme.successLight : AppTheme.errorLight,
        'trend': null,
        'change': 0.0,
      },
    ];
  }

  double _calculateAverage(String key) {
    if (data.isEmpty) return 0.0;
    final sum = data.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0));
    return sum / data.length;
  }

  double _calculateSum(String key) {
    return data.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0));
  }

  double _calculateMax(String key) {
    if (data.isEmpty) return 0.0;
    return data.fold<double>(0.0, (max, item) {
      final value = item[key] ?? 0.0;
      return value > max ? value : max;
    });
  }

  String _calculateTrend(String key) {
    if (data.length < 2) return 'stable';

    final firstHalf = data.take(data.length ~/ 2);
    final secondHalf = data.skip(data.length ~/ 2);

    final firstAvg =
        firstHalf.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0)) /
        firstHalf.length;
    final secondAvg =
        secondHalf.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0)) /
        secondHalf.length;

    final change = ((secondAvg - firstAvg) / firstAvg) * 100;

    if (change > 5) return 'up';
    if (change < -5) return 'down';
    return 'stable';
  }

  double _calculatePercentageChange(String key) {
    if (data.length < 2) return 0.0;

    final firstHalf = data.take(data.length ~/ 2);
    final secondHalf = data.skip(data.length ~/ 2);

    final firstAvg =
        firstHalf.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0)) /
        firstHalf.length;
    final secondAvg =
        secondHalf.fold<double>(0.0, (sum, item) => sum + (item[key] ?? 0.0)) /
        secondHalf.length;

    if (firstAvg == 0) return 0.0;
    return ((secondAvg - firstAvg) / firstAvg) * 100;
  }

  Color _getParameterColor(String parameter) {
    switch (parameter) {
      case 'pH':
        return AppTheme.primaryLight;
      case 'chlorine':
        return AppTheme.accentLight;
      case 'turbidity':
        return AppTheme.warningLight;
      case 'temperature':
        return AppTheme.successLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  Color _getTrendColor(String? trend, ColorScheme colorScheme) {
    switch (trend) {
      case 'up':
        return AppTheme.successLight;
      case 'down':
        return AppTheme.errorLight;
      case 'stable':
        return colorScheme.primary;
      default:
        return colorScheme.onSurface.withValues(alpha: 0.6);
    }
  }

  String _getTrendIcon(String? trend) {
    switch (trend) {
      case 'up':
        return 'trending_up';
      case 'down':
        return 'trending_down';
      case 'stable':
        return 'trending_flat';
      default:
        return 'remove';
    }
  }

  Color _getOverallStatusColor(ColorScheme colorScheme) {
    final status = _getOverallStatus();
    switch (status.toLowerCase()) {
      case 'excellent':
        return AppTheme.successLight;
      case 'good':
        return AppTheme.successLight;
      case 'moderate':
        return AppTheme.warningLight;
      case 'needs attention':
        return AppTheme.errorLight;
      default:
        return colorScheme.primary;
    }
  }

  String _getOverallStatusIcon() {
    final status = _getOverallStatus();
    switch (status.toLowerCase()) {
      case 'excellent':
        return 'star';
      case 'good':
        return 'check_circle';
      case 'moderate':
        return 'warning';
      case 'needs attention':
        return 'priority_high';
      default:
        return 'info';
    }
  }

  String _getOverallStatus() {
    if (data.isEmpty) return 'No Data';

    switch (reportType) {
      case 'Quality':
        final avgPH = _calculateAverage('pH');
        if (avgPH >= 6.5 && avgPH <= 8.5) return 'Good';
        if (avgPH >= 6.0 && avgPH <= 9.0) return 'Moderate';
        return 'Needs Attention';
      case 'Consumption':
        final avgEfficiency = _calculateAverage('efficiency');
        if (avgEfficiency >= 95) return 'Excellent';
        if (avgEfficiency >= 85) return 'Good';
        if (avgEfficiency >= 75) return 'Moderate';
        return 'Needs Attention';
      case 'Compliance':
        final avgScore = _calculateAverage('compliance_score');
        if (avgScore >= 98) return 'Excellent';
        if (avgScore >= 90) return 'Good';
        if (avgScore >= 80) return 'Moderate';
        return 'Needs Attention';
      case 'Forecasting':
        final avgMaintenance = _calculateAverage('maintenance_score');
        if (avgMaintenance >= 85) return 'Good';
        if (avgMaintenance >= 70) return 'Moderate';
        return 'Needs Attention';
      default:
        return 'Unknown';
    }
  }
}
