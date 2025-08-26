import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyInsightsState extends StatelessWidget {
  final String reportType;
  final VoidCallback onSetupPressed;

  const EmptyInsightsState({
    Key? key,
    required this.reportType,
    required this.onSetupPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 10.h),
          _buildIllustration(context),
          SizedBox(height: 4.h),
          _buildContent(context),
          SizedBox(height: 4.h),
          _buildActionButtons(context),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconName = _getIconForReportType(reportType);
    final color = _getColorForReportType(reportType);

    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: color.withValues(alpha: 0.3),
            size: 15.w,
          ),
          Positioned(
            bottom: 2.w,
            right: 2.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: CustomIconWidget(iconName: 'add', color: color, size: 6.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          _getTitle(reportType),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2.h),
        Text(
          _getDescription(reportType),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 3.h),
        _buildRequirementsCard(context),
      ],
    );
  }

  Widget _buildRequirementsCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final requirements = _getRequirementsForReportType(reportType);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.accentLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.accentLight,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'What you need:',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Column(
            children:
                requirements.map((requirement) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 1.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 0.5.h, right: 2.w),
                          width: 1.w,
                          height: 1.w,
                          decoration: BoxDecoration(
                            color: AppTheme.accentLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            requirement,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSetupPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: CustomIconWidget(
              iconName: 'sensors',
              color: colorScheme.onPrimary,
              size: 5.w,
            ),
            label: Text(
              'Setup Data Collection',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showMoreInfo(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              side: BorderSide(color: colorScheme.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: CustomIconWidget(
              iconName: 'help_outline',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 5.w,
            ),
            label: Text(
              'Learn More',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getIconForReportType(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'quality':
        return 'water_drop';
      case 'consumption':
        return 'waterfall_chart';
      case 'compliance':
        return 'verified';
      case 'forecasting':
        return 'insights';
      default:
        return 'analytics';
    }
  }

  Color _getColorForReportType(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'quality':
        return AppTheme.primaryLight;
      case 'consumption':
        return AppTheme.successLight;
      case 'compliance':
        return AppTheme.accentLight;
      case 'forecasting':
        return AppTheme.warningLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  String _getTitle(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'quality':
        return 'No Quality Data Available';
      case 'consumption':
        return 'No Consumption Data Available';
      case 'compliance':
        return 'No Compliance Data Available';
      case 'forecasting':
        return 'No Forecast Data Available';
      default:
        return 'No Data Available';
    }
  }

  String _getDescription(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'quality':
        return 'Start collecting water quality measurements to generate comprehensive reports and track water safety parameters over time.';
      case 'consumption':
        return 'Connect usage monitoring sensors to track water consumption patterns, efficiency metrics, and optimize resource utilization.';
      case 'compliance':
        return 'Set up regular testing and monitoring to ensure regulatory compliance and maintain detailed audit records.';
      case 'forecasting':
        return 'Enable predictive analytics by collecting sufficient historical data to forecast future trends and maintenance needs.';
      default:
        return 'Connect sensors and start collecting data to generate insightful reports and analytics.';
    }
  }

  List<String> _getRequirementsForReportType(String reportType) {
    switch (reportType.toLowerCase()) {
      case 'quality':
        return [
          'Water quality sensors (pH, chlorine, turbidity)',
          'Temperature monitoring devices',
          'Real-time data collection system',
          'Calibrated measurement equipment',
        ];
      case 'consumption':
        return [
          'Flow rate monitoring sensors',
          'Usage tracking devices',
          'Pressure monitoring equipment',
          'Data logging infrastructure',
        ];
      case 'compliance':
        return [
          'Regular testing schedule',
          'Laboratory analysis results',
          'Regulatory parameter monitoring',
          'Documentation and record keeping',
        ];
      case 'forecasting':
        return [
          'Minimum 30 days of historical data',
          'Multiple sensor data points',
          'Consistent data collection frequency',
          'AI/ML processing capabilities',
        ];
      default:
        return [
          'Sensor installation and configuration',
          'Data collection infrastructure',
          'Network connectivity',
          'Regular maintenance schedule',
        ];
    }
  }

  void _showMoreInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Getting Started'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'To begin generating ${reportType.toLowerCase()} reports, you\'ll need to:',
                ),
                SizedBox(height: 2.h),
                Text('1. Connect appropriate sensors'),
                Text('2. Configure data collection parameters'),
                Text('3. Allow time for data accumulation'),
                Text('4. Set up automated monitoring'),
                SizedBox(height: 2.h),
                Text(
                  'Once set up, reports will be automatically generated with real-time insights and analytics.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Got it'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onSetupPressed();
                },
                child: Text('Start Setup'),
              ),
            ],
          ),
    );
  }
}
