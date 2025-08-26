import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class RecentActivityTimeline extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final VoidCallback? onViewAll;

  const RecentActivityTimeline({
    Key? key,
    required this.activities,
    this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: AppTheme.elevationLevel2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (activities.length > 3)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text(
                      'View All',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            activities.isEmpty
                ? _buildEmptyState(context)
                : Column(
                    children: activities
                        .take(5)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) => _buildTimelineItem(
                              entry.value,
                              entry.key,
                              entry.key == activities.take(5).length - 1,
                              context,
                            ))
                        .toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    Map<String, dynamic> activity,
    int index,
    bool isLast,
    BuildContext context,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String type = (activity['type'] as String? ?? 'info').toLowerCase();
    final String title = activity['title'] as String? ?? 'Unknown Activity';
    final String description = activity['description'] as String? ?? '';
    final String location = activity['location'] as String? ?? '';

    Color typeColor =
        _getActivityColor(type, theme.brightness == Brightness.light);
    IconData typeIcon = _getActivityIcon(type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surface,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: _getIconName(typeIcon),
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 8.h,
                  color: colorScheme.outline.withValues(alpha: 0.2),
                ),
            ],
          ),
          SizedBox(width: 3.w),
          // Content
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 3.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(activity['timestamp']),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  if (location.isNotEmpty) ...[
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'location_on',
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 3.w,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          location,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (activity['value'] != null) ...[
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activity['value']} ${activity['unit'] ?? ''}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: typeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'timeline',
            color: colorScheme.onSurface.withValues(alpha: 0.3),
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Recent Activity',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Activity will appear here once sensors start reporting',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type, bool isLight) {
    switch (type) {
      case 'alert':
      case 'warning':
      case 'error':
        return isLight ? AppTheme.errorLight : AppTheme.errorDark;
      case 'maintenance':
      case 'update':
        return isLight ? AppTheme.warningLight : AppTheme.warningDark;
      case 'reading':
      case 'measurement':
        return isLight ? AppTheme.primaryLight : AppTheme.primaryDark;
      case 'success':
      case 'normal':
        return isLight ? AppTheme.successLight : AppTheme.successDark;
      case 'system':
      case 'connection':
        return isLight ? AppTheme.accentLight : AppTheme.accentDark;
      default:
        return isLight ? AppTheme.primaryLight : AppTheme.primaryDark;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'alert':
      case 'warning':
        return Icons.warning;
      case 'error':
        return Icons.error;
      case 'maintenance':
        return Icons.build;
      case 'update':
        return Icons.system_update;
      case 'reading':
      case 'measurement':
        return Icons.sensors;
      case 'success':
      case 'normal':
        return Icons.check_circle;
      case 'system':
        return Icons.settings;
      case 'connection':
        return Icons.wifi;
      default:
        return Icons.info;
    }
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.warning) return 'warning';
    if (icon == Icons.error) return 'error';
    if (icon == Icons.build) return 'build';
    if (icon == Icons.system_update) return 'system_update';
    if (icon == Icons.sensors) return 'sensors';
    if (icon == Icons.check_circle) return 'check_circle';
    if (icon == Icons.settings) return 'settings';
    if (icon == Icons.wifi) return 'wifi';
    return 'info';
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      DateTime dateTime;
      if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return '';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d';
      } else {
        final weeks = (difference.inDays / 7).floor();
        return '${weeks}w';
      }
    } catch (e) {
      return '';
    }
  }
}