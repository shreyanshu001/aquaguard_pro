import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class AlertCardWidget extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onAcknowledge;
  final VoidCallback? onViewLocation;
  final VoidCallback? onArchive;
  final VoidCallback? onShare;
  final VoidCallback? onExport;
  final VoidCallback? onContactSupport;

  const AlertCardWidget({
    Key? key,
    required this.alert,
    this.onTap,
    this.onMarkAsRead,
    this.onAcknowledge,
    this.onViewLocation,
    this.onArchive,
    this.onShare,
    this.onExport,
    this.onContactSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    
    final String severity = (alert['severity'] as String? ?? 'info').toLowerCase();
    final bool isRead = alert['isRead'] as bool? ?? false;
    final bool isActive = (alert['status'] as String?) == 'active';

    return Dismissible(
      key: Key('alert_${alert['id']}'),
      background: _buildSwipeBackground(context, isLeft: false),
      secondaryBackground: _buildSwipeBackground(context, isLeft: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Quick actions
          _showQuickActions(context);
        } else {
          // Swipe left - Archive
          onArchive?.call();
        }
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isRead 
                ? colorScheme.surface 
                : colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getSeverityColor(severity, isLight).withValues(alpha: 0.3),
              width: isActive ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isLight 
                    ? Colors.black.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAlertHeader(context, severity, isLight, isRead, isActive),
              _buildAlertContent(context, isLight),
              if (alert['expanded'] == true) _buildExpandedDetails(context, isLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeft ? colorScheme.error : colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isLeft ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isLeft ? 'archive' : 'check_circle',
            color: Colors.white,
            size: 24,
          ),
          SizedBox(height: 0.5.h),
          Text(
            isLeft ? 'Archive' : 'Actions',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertHeader(BuildContext context, String severity, bool isLight, bool isRead, bool isActive) {
    final colorScheme = Theme.of(context).colorScheme;
    final severityColor = _getSeverityColor(severity, isLight);
    
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: severityColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getSeverityIcon(severity),
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert['type'] as String? ?? 'System Alert',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Expanded(
                      child: Text(
                        alert['location'] as String? ?? 'Unknown Location',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isActive ? severityColor : colorScheme.outline,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'ACTIVE' : 'RESOLVED',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
    );
  }

  Widget _buildAlertContent(BuildContext context, bool isLight) {
    final colorScheme = Theme.of(context).colorScheme;
    final DateTime timestamp = DateTime.parse(alert['timestamp'] as String? ?? DateTime.now().toIso8601String());
    final String timeAgo = _getTimeAgo(timestamp);
    
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert['message'] as String? ?? 'No message available',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'access_time',
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 14,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    timeAgo,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              if (alert['parameterValue'] != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${alert['parameterValue']} ${alert['unit'] ?? ''}',
                    style: AppTheme.dataDisplaySmall(context),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails(BuildContext context, bool isLight) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(color: colorScheme.outline.withValues(alpha: 0.3)),
          SizedBox(height: 2.h),
          Text(
            'Alert Details',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          if (alert['thresholdValue'] != null) ...[
            _buildDetailRow(context, 'Threshold', '${alert['thresholdValue']} ${alert['unit'] ?? ''}'),
            SizedBox(height: 1.h),
          ],
          if (alert['currentValue'] != null) ...[
            _buildDetailRow(context, 'Current Value', '${alert['currentValue']} ${alert['unit'] ?? ''}'),
            SizedBox(height: 1.h),
          ],
          _buildDetailRow(context, 'Alert ID', '#${alert['id']}'),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onViewLocation,
                  icon: CustomIconWidget(
                    iconName: 'location_on',
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  label: Text('View Location'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onAcknowledge,
                  icon: CustomIconWidget(
                    iconName: 'check',
                    color: colorScheme.onPrimary,
                    size: 16,
                  ),
                  label: Text('Acknowledge'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'mark_email_read',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Mark as Read'),
              onTap: () {
                Navigator.pop(context);
                onMarkAsRead?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'check_circle',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Acknowledge'),
              onTap: () {
                Navigator.pop(context);
                onAcknowledge?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'location_on',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('View Location'),
              onTap: () {
                Navigator.pop(context);
                onViewLocation?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Share Alert'),
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Export Data'),
              onTap: () {
                Navigator.pop(context);
                onExport?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'support_agent',
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              title: Text('Contact Support'),
              onTap: () {
                Navigator.pop(context);
                onContactSupport?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity, bool isLight) {
    switch (severity) {
      case 'critical':
        return isLight ? AppTheme.errorLight : AppTheme.errorDark;
      case 'warning':
        return isLight ? AppTheme.warningLight : AppTheme.warningDark;
      case 'info':
        return isLight ? AppTheme.accentLight : AppTheme.accentDark;
      default:
        return isLight ? AppTheme.primaryLight : AppTheme.primaryDark;
    }
  }

  String _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return 'error';
      case 'warning':
        return 'warning';
      case 'info':
        return 'info';
      default:
        return 'notifications';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
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
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}