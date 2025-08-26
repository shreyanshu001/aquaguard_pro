import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onConfigureThresholds;

  const EmptyStateWidget({
    Key? key,
    this.onConfigureThresholds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.successLight.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  color: AppTheme.successLight,
                  size: 20.w,
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              'All Clear!',
              style: GoogleFonts.inter(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Text(
              'No active alerts at the moment.\nYour water quality systems are operating within safe parameters.',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 4.h),

            // Status indicators
            _buildStatusIndicators(context, colorScheme, isLight),

            SizedBox(height: 4.h),

            // Action button
            ElevatedButton.icon(
              onPressed: onConfigureThresholds,
              icon: CustomIconWidget(
                iconName: 'tune',
                color: colorScheme.onPrimary,
                size: 20,
              ),
              label: Text('Configure Alert Thresholds'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            SizedBox(height: 2.h),

            // Secondary action
            TextButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, '/real-time-monitoring'),
              icon: CustomIconWidget(
                iconName: 'sensors',
                color: colorScheme.primary,
                size: 18,
              ),
              label: Text('View Real-time Monitoring'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicators(
      BuildContext context, ColorScheme colorScheme, bool isLight) {
    final List<Map<String, dynamic>> statusItems = [
      {
        'label': 'Water Quality',
        'status': 'Normal',
        'icon': 'water_drop',
        'color': AppTheme.successLight,
      },
      {
        'label': 'System Pressure',
        'status': 'Optimal',
        'icon': 'compress',
        'color': AppTheme.successLight,
      },
      {
        'label': 'Flow Rate',
        'status': 'Stable',
        'icon': 'speed',
        'color': AppTheme.successLight,
      },
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            'System Status Overview',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          ...statusItems
              .map((item) => _buildStatusItem(
                    context,
                    item['label'] as String,
                    item['status'] as String,
                    item['icon'] as String,
                    item['color'] as Color,
                    colorScheme,
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context,
    String label,
    String status,
    String iconName,
    Color statusColor,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: statusColor,
              size: 16,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}