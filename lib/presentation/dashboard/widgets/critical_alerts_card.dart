import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CriticalAlertsCard extends StatefulWidget {
  final List<Map<String, dynamic>> alerts;
  final VoidCallback? onViewAll;

  const CriticalAlertsCard({
    Key? key,
    required this.alerts,
    this.onViewAll,
  }) : super(key: key);

  @override
  State<CriticalAlertsCard> createState() => _CriticalAlertsCardState();
}

class _CriticalAlertsCardState extends State<CriticalAlertsCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasAlerts = widget.alerts.isNotEmpty;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: AppTheme.elevationLevel2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasAlerts ? colorScheme.error : Colors.transparent,
          width: hasAlerts ? 1.5 : 0,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: hasAlerts
              ? LinearGradient(
                  colors: [
                    colorScheme.error.withValues(alpha: 0.05),
                    colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Column(
          children: [
            InkWell(
              onTap: hasAlerts ? _toggleExpanded : null,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: hasAlerts
                            ? colorScheme.error.withValues(alpha: 0.1)
                            : colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: hasAlerts ? 'warning' : 'check_circle',
                        color:
                            hasAlerts ? colorScheme.error : colorScheme.primary,
                        size: 6.w,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Critical Alerts',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: hasAlerts ? colorScheme.error : null,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            hasAlerts
                                ? '${widget.alerts.length} active alert${widget.alerts.length > 1 ? 's' : ''}'
                                : 'All systems normal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: hasAlerts
                                  ? colorScheme.error
                                  : colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasAlerts)
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: Duration(milliseconds: 300),
                        child: CustomIconWidget(
                          iconName: 'keyboard_arrow_down',
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 6.w,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (hasAlerts)
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: Container(
                  padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                  child: Column(
                    children: [
                      Divider(height: 1),
                      SizedBox(height: 2.h),
                      ...widget.alerts
                          .take(3)
                          .map((alert) => _buildAlertItem(alert)),
                      if (widget.alerts.length > 3) ...[
                        SizedBox(height: 2.h),
                        TextButton(
                          onPressed: widget.onViewAll,
                          child: Text(
                            'View All ${widget.alerts.length} Alerts',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.primary,
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
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final String severity =
        (alert['severity'] as String? ?? 'medium').toLowerCase();

    Color severityColor;
    switch (severity) {
      case 'high':
      case 'critical':
        severityColor = colorScheme.error;
        break;
      case 'medium':
      case 'warning':
        severityColor = AppTheme.warningLight;
        break;
      default:
        severityColor = colorScheme.primary;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: severityColor,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'] as String? ?? 'Unknown Alert',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: severityColor,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  alert['location'] as String? ?? 'Unknown Location',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatTimestamp(alert['timestamp']),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              severity.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: severityColor,
                fontWeight: FontWeight.w600,
                fontSize: 8.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Unknown time';

    try {
      DateTime dateTime;
      if (timestamp is DateTime) {
        dateTime = timestamp;
      } else if (timestamp is String) {
        dateTime = DateTime.parse(timestamp);
      } else {
        return 'Unknown time';
      }

      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
}