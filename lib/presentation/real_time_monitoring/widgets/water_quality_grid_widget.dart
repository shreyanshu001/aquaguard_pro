import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaterQualityGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> qualityParameters;
  final Function(Map<String, dynamic>) onParameterTap;

  const WaterQualityGridWidget({
    Key? key,
    required this.qualityParameters,
    required this.onParameterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isLight
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
          SizedBox(height: 3.h),
          _buildParametersGrid(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Quality Parameters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Live sensor readings',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: _getOverallStatusColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: _getOverallStatusIcon(),
                color: _getOverallStatusColor(),
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(
                _getOverallStatus(),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _getOverallStatusColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildParametersGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.2,
      ),
      itemCount: qualityParameters.length,
      itemBuilder: (context, index) {
        final parameter = qualityParameters[index];
        return _buildParameterCard(context, parameter);
      },
    );
  }

  Widget _buildParameterCard(
      BuildContext context, Map<String, dynamic> parameter) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    final String name = parameter["name"] as String;
    final double value = parameter["value"] as double;
    final String unit = parameter["unit"] as String;
    final String status = parameter["status"] as String;
    final String trend = parameter["trend"] as String;
    final String icon = parameter["icon"] as String;

    final statusColor = _getStatusColor(status);
    final trendIcon = _getTrendIcon(trend);

    return GestureDetector(
      onTap: () => onParameterTap(parameter),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: isLight
                  ? Colors.black.withValues(alpha: 0.03)
                  : Colors.white.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: icon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                CustomIconWidget(
                  iconName: trendIcon,
                  color: _getTrendColor(trend),
                  size: 16,
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              value.toStringAsFixed(1),
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            unit,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'safe':
      case 'normal':
      case 'good':
        return AppTheme.successLight;
      case 'warning':
      case 'caution':
      case 'moderate':
        return AppTheme.warningLight;
      case 'critical':
      case 'danger':
      case 'high':
        return AppTheme.errorLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  String _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
      case 'increasing':
        return 'trending_up';
      case 'down':
      case 'decreasing':
        return 'trending_down';
      case 'stable':
      case 'steady':
        return 'trending_flat';
      default:
        return 'remove';
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'up':
      case 'increasing':
        return AppTheme.errorLight;
      case 'down':
      case 'decreasing':
        return AppTheme.successLight;
      case 'stable':
      case 'steady':
        return AppTheme.primaryLight;
      default:
        return Colors.grey;
    }
  }

  Color _getOverallStatusColor() {
    int criticalCount = 0;
    int warningCount = 0;

    for (final parameter in qualityParameters) {
      final status = (parameter["status"] as String).toLowerCase();
      if (status == 'critical' || status == 'danger' || status == 'high') {
        criticalCount++;
      } else if (status == 'warning' ||
          status == 'caution' ||
          status == 'moderate') {
        warningCount++;
      }
    }

    if (criticalCount > 0) {
      return AppTheme.errorLight;
    } else if (warningCount > 0) {
      return AppTheme.warningLight;
    } else {
      return AppTheme.successLight;
    }
  }

  String _getOverallStatusIcon() {
    int criticalCount = 0;
    int warningCount = 0;

    for (final parameter in qualityParameters) {
      final status = (parameter["status"] as String).toLowerCase();
      if (status == 'critical' || status == 'danger' || status == 'high') {
        criticalCount++;
      } else if (status == 'warning' ||
          status == 'caution' ||
          status == 'moderate') {
        warningCount++;
      }
    }

    if (criticalCount > 0) {
      return 'error_outline';
    } else if (warningCount > 0) {
      return 'warning_outlined';
    } else {
      return 'check_circle_outline';
    }
  }

  String _getOverallStatus() {
    int criticalCount = 0;
    int warningCount = 0;

    for (final parameter in qualityParameters) {
      final status = (parameter["status"] as String).toLowerCase();
      if (status == 'critical' || status == 'danger' || status == 'high') {
        criticalCount++;
      } else if (status == 'warning' ||
          status == 'caution' ||
          status == 'moderate') {
        warningCount++;
      }
    }

    if (criticalCount > 0) {
      return 'Critical';
    } else if (warningCount > 0) {
      return 'Warning';
    } else {
      return 'All Safe';
    }
  }
}
