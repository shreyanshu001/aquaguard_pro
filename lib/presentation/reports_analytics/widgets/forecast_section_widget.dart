import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ForecastSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> forecastData;

  const ForecastSectionWidget({Key? key, required this.forecastData})
    : super(key: key);

  @override
  State<ForecastSectionWidget> createState() => _ForecastSectionWidgetState();
}

class _ForecastSectionWidgetState extends State<ForecastSectionWidget>
    with SingleTickerProviderStateMixin {
  String _selectedForecastType = 'usage';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> _forecastTypes = [
    {'key': 'usage', 'label': 'Usage Prediction', 'icon': 'trending_up'},
    {'key': 'maintenance', 'label': 'Maintenance Schedule', 'icon': 'build'},
    {'key': 'efficiency', 'label': 'Efficiency Trends', 'icon': 'eco'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
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
            _buildHeader(context),
            SizedBox(height: 2.h),
            _buildForecastTypeSelector(context),
            SizedBox(height: 3.h),
            _buildForecastContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.accentLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'insights',
            color: AppTheme.accentLight,
            size: 6.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Predictive Analytics',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'AI-powered forecasting and insights',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.successLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: AppTheme.successLight,
                size: 4.w,
              ),
              SizedBox(width: 1.w),
              Text(
                'AI Enabled',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.successLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastTypeSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 6.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _forecastTypes.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final type = _forecastTypes[index];
          final isSelected = _selectedForecastType == type['key'];

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedForecastType = type['key']!;
              });
              _animationController.reset();
              _animationController.forward();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: type['icon']!,
                    color:
                        isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    type['label']!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildForecastContent(BuildContext context) {
    switch (_selectedForecastType) {
      case 'usage':
        return _buildUsageForecast(context);
      case 'maintenance':
        return _buildMaintenanceForecast(context);
      case 'efficiency':
        return _buildEfficiencyForecast(context);
      default:
        return _buildUsageForecast(context);
    }
  }

  Widget _buildUsageForecast(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Water Usage Predictions',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          height: 25.h,
          child: LineChart(_createUsageLineChartData(context)),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildForecastMetric(
                context,
                'Next Week',
                '${widget.forecastData.isNotEmpty ? widget.forecastData.first['predicted_usage']?.toStringAsFixed(0) ?? "1280" : "1280"}L',
                'trending_up',
                AppTheme.primaryLight,
                '+12.5%',
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildForecastMetric(
                context,
                'Next Month',
                '${widget.forecastData.length > 3 ? widget.forecastData.last['predicted_usage']?.toStringAsFixed(0) ?? "1480" : "1480"}L',
                'timeline',
                AppTheme.warningLight,
                '+24.8%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMaintenanceForecast(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final upcomingMaintenance = [
      {
        'component': 'Water Filter System',
        'daysUntil': 7,
        'priority': 'high',
        'description': 'Filter replacement due to reduced efficiency',
      },
      {
        'component': 'pH Monitoring Sensor',
        'daysUntil': 14,
        'priority': 'medium',
        'description': 'Calibration required for accurate readings',
      },
      {
        'component': 'Pressure Valve Unit',
        'daysUntil': 21,
        'priority': 'low',
        'description': 'Routine inspection and cleaning',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Maintenance Schedule',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              upcomingMaintenance.map((item) {
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: _getMaintenancePriorityColor(
                      item['priority'] as String,
                    ).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getMaintenancePriorityColor(
                        item['priority'] as String,
                      ).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: _getMaintenancePriorityColor(
                            item['priority'] as String,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'build',
                          color: _getMaintenancePriorityColor(
                            item['priority'] as String,
                          ),
                          size: 5.w,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['component'] as String,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              item['description'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${item['daysUntil']}',
                            style: AppTheme.dataDisplaySmall(context).copyWith(
                              color: _getMaintenancePriorityColor(
                                item['priority'] as String,
                              ),
                            ),
                          ),
                          Text(
                            'days',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildEfficiencyForecast(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Efficiency Trends',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildForecastMetric(
                context,
                'Current Efficiency',
                '92.8%',
                'eco',
                AppTheme.successLight,
                '+2.1%',
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _buildForecastMetric(
                context,
                'Predicted (30d)',
                '89.5%',
                'trending_down',
                AppTheme.warningLight,
                '-3.3%',
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.accentLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.accentLight.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'psychology',
                    color: AppTheme.accentLight,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'AI Recommendation',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentLight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'System efficiency is predicted to decline over the next 30 days. Consider scheduling preventive maintenance to maintain optimal performance.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 2.h),
              InkWell(
                onTap: () {
                  // Handle schedule maintenance action
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        color: Colors.white,
                        size: 4.w,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Schedule Maintenance',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForecastMetric(
    BuildContext context,
    String label,
    String value,
    String iconName,
    Color color,
    String change,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomIconWidget(iconName: iconName, color: color, size: 5.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: AppTheme.dataDisplayMedium(
              context,
            ).copyWith(color: colorScheme.onSurface),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _createUsageLineChartData(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final spots =
        widget.forecastData.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          return FlSpot(
            index.toDouble(),
            data['predicted_usage']?.toDouble() ?? 0.0,
          );
        }).toList();

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [AppTheme.primaryLight, AppTheme.accentLight],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryLight.withValues(alpha: 0.3),
                AppTheme.primaryLight.withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Color _getMaintenancePriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.errorLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.successLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
