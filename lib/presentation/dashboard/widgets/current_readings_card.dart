import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CurrentReadingsCard extends StatefulWidget {
  final List<Map<String, dynamic>> readings;
  final VoidCallback? onRefresh;

  const CurrentReadingsCard({
    Key? key,
    required this.readings,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<CurrentReadingsCard> createState() => _CurrentReadingsCardState();
}

class _CurrentReadingsCardState extends State<CurrentReadingsCard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.readings.isEmpty) {
      return _buildEmptyState(context);
    }

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
                  'Current Readings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Live',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.successLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Container(
                      width: 2.w,
                      height: 2.w,
                      decoration: BoxDecoration(
                        color: AppTheme.successLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    InkWell(
                      onTap: widget.onRefresh,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: CustomIconWidget(
                          iconName: 'refresh',
                          color: colorScheme.primary,
                          size: 5.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Container(
              height: 25.h,
              child: PageView.builder(
                itemCount: widget.readings.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildReadingCard(widget.readings[index]);
                },
              ),
            ),
            if (widget.readings.length > 1) ...[
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.readings.length,
                  (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    width: _selectedIndex == index ? 6.w : 2.w,
                    height: 1.h,
                    decoration: BoxDecoration(
                      color: _selectedIndex == index
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadingCard(Map<String, dynamic> reading) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String parameter = reading['parameter'] as String? ?? 'Unknown';
    final double value = (reading['value'] as num?)?.toDouble() ?? 0.0;
    final String unit = reading['unit'] as String? ?? '';
    final String status =
        (reading['status'] as String? ?? 'normal').toLowerCase();
    final String location =
        reading['location'] as String? ?? 'Unknown Location';

    Color statusColor =
        _getStatusColor(status, theme.brightness == Brightness.light);
    IconData statusIcon = _getStatusIcon(status);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parameter,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getIconName(statusIcon),
                  color: statusColor,
                  size: 6.w,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Center(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: value.toStringAsFixed(1),
                        style: AppTheme.dataDisplayLarge(context).copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: ' $unit',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 1.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last updated: ${_formatLastUpdated(reading['lastUpdated'])}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              InkWell(
                onTap: () => _showDetailedView(reading),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Details',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward_ios',
                        color: colorScheme.primary,
                        size: 3.w,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: AppTheme.elevationLevel1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'sensors_off',
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No Sensor Data',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Connect your sensors to start monitoring',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status, bool isLight) {
    switch (status) {
      case 'safe':
      case 'normal':
      case 'good':
        return isLight ? AppTheme.successLight : AppTheme.successDark;
      case 'warning':
      case 'caution':
      case 'moderate':
        return isLight ? AppTheme.warningLight : AppTheme.warningDark;
      case 'critical':
      case 'danger':
      case 'emergency':
        return isLight ? AppTheme.errorLight : AppTheme.errorDark;
      default:
        return isLight ? AppTheme.primaryLight : AppTheme.primaryDark;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'safe':
      case 'normal':
      case 'good':
        return Icons.check_circle;
      case 'warning':
      case 'caution':
      case 'moderate':
        return Icons.warning;
      case 'critical':
      case 'danger':
      case 'emergency':
        return Icons.error;
      default:
        return Icons.sensors;
    }
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.check_circle) return 'check_circle';
    if (icon == Icons.warning) return 'warning';
    if (icon == Icons.error) return 'error';
    return 'sensors';
  }

  String _formatLastUpdated(dynamic timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      DateTime dateTime;
      if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Unknown';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 30) {
        return 'Just now';
      } else if (difference.inMinutes < 1) {
        return '${difference.inSeconds}s ago';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else {
        return '${difference.inHours}h ago';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  void _showDetailedView(Map<String, dynamic> reading) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detailed Reading',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        _buildDetailRow(
                            'Parameter', reading['parameter'] ?? 'Unknown'),
                        _buildDetailRow('Current Value',
                            '${reading['value'] ?? 0} ${reading['unit'] ?? ''}'),
                        _buildDetailRow(
                            'Status', reading['status'] ?? 'Unknown'),
                        _buildDetailRow(
                            'Location', reading['location'] ?? 'Unknown'),
                        _buildDetailRow(
                            'Sensor ID', reading['sensorId'] ?? 'Unknown'),
                        _buildDetailRow('Last Updated',
                            _formatLastUpdated(reading['lastUpdated'])),
                        if (reading['threshold'] != null)
                          _buildDetailRow('Threshold',
                              '${reading['threshold']} ${reading['unit'] ?? ''}'),
                        if (reading['accuracy'] != null)
                          _buildDetailRow(
                              'Accuracy', '±${reading['accuracy']}%'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
