import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickInsightsCard extends StatelessWidget {
  final List<Map<String, dynamic>> insights;
  final Function(Map<String, dynamic>) onInsightTapped;

  const QuickInsightsCard({
    Key? key,
    required this.insights,
    required this.onInsightTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

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
          _buildHeader(context),
          SizedBox(height: 2.h),
          if (insights.isEmpty)
            _buildEmptyState(context)
          else
            Column(
              children:
                  insights
                      .map((insight) => _buildInsightItem(context, insight))
                      .toList(),
            ),
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
        Row(
          children: [
            CustomIconWidget(
              iconName: 'lightbulb',
              color: colorScheme.primary,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Quick Insights',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${insights.length}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'lightbulb_outline',
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 15.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No insights available',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Insights will appear here as data is analyzed',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(BuildContext context, Map<String, dynamic> insight) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: () => onInsightTapped(insight),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: _getInsightBackgroundColor(insight['severity'], colorScheme),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getInsightBorderColor(insight['severity'], colorScheme),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getInsightIconColor(
                        insight['severity'],
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getInsightIcon(insight['type']),
                      color: _getInsightIconColor(insight['severity']),
                      size: 5.w,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight['title'],
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _formatTimestamp(insight['timestamp']),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSeverityBadge(context, insight['severity']),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                insight['description'],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: _getActionIcon(insight['action']),
                          color: colorScheme.primary,
                          size: 4.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          _getActionText(insight['action']),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(BuildContext context, String severity) {
    final theme = Theme.of(context);
    final color = _getInsightIconColor(severity);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 1.w),
          Text(
            severity.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getInsightBackgroundColor(String severity, ColorScheme colorScheme) {
    final color = _getInsightIconColor(severity);
    return color.withValues(alpha: 0.03);
  }

  Color _getInsightBorderColor(String severity, ColorScheme colorScheme) {
    final color = _getInsightIconColor(severity);
    return color.withValues(alpha: 0.1);
  }

  Color _getInsightIconColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return AppTheme.errorLight;
      case 'high':
        return AppTheme.errorLight;
      case 'medium':
        return AppTheme.warningLight;
      case 'low':
        return AppTheme.accentLight;
      case 'positive':
        return AppTheme.successLight;
      default:
        return AppTheme.primaryLight;
    }
  }

  String _getInsightIcon(String type) {
    switch (type.toLowerCase()) {
      case 'anomaly':
        return 'warning';
      case 'efficiency':
        return 'trending_up';
      case 'maintenance':
        return 'build';
      case 'quality':
        return 'water_drop';
      case 'compliance':
        return 'verified';
      case 'forecast':
        return 'insights';
      default:
        return 'info';
    }
  }

  String _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'investigate':
        return 'search';
      case 'monitor':
        return 'visibility';
      case 'schedule':
        return 'event';
      case 'fix':
        return 'build';
      case 'review':
        return 'rate_review';
      default:
        return 'arrow_forward';
    }
  }

  String _getActionText(String action) {
    switch (action.toLowerCase()) {
      case 'investigate':
        return 'Investigate';
      case 'monitor':
        return 'Monitor';
      case 'schedule':
        return 'Schedule';
      case 'fix':
        return 'Fix Issue';
      case 'review':
        return 'Review';
      default:
        return 'View Details';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
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
        'Dec',
      ];
      return '${months[timestamp.month - 1]} ${timestamp.day}';
    }
  }
}
