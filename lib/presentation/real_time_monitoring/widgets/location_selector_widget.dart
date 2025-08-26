import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationSelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final int selectedLocationIndex;
  final PageController pageController;
  final Function(int) onLocationChanged;

  const LocationSelectorWidget({
    Key? key,
    required this.locations,
    required this.selectedLocationIndex,
    required this.pageController,
    required this.onLocationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return Container(
      height: 12.h,
      child: PageView.builder(
        controller: pageController,
        onPageChanged: onLocationChanged,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          final isSelected = index == selectedLocationIndex;

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.primary : colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.2),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.2)
                      : isLight
                          ? Colors.black.withValues(alpha: 0.05)
                          : Colors.white.withValues(alpha: 0.05),
                  blurRadius: isSelected ? 12 : 4,
                  offset: Offset(0, isSelected ? 4 : 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.onPrimary.withValues(alpha: 0.2)
                        : colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'location_on',
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        location["name"] as String,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        location["address"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary.withValues(alpha: 0.8)
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor(location["status"] as String)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        location["status"] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : _getStatusColor(location["status"] as String),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'sensors',
                          color: isSelected
                              ? colorScheme.onPrimary.withValues(alpha: 0.7)
                              : colorScheme.onSurface.withValues(alpha: 0.5),
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${location["sensorCount"]} sensors',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? colorScheme.onPrimary.withValues(alpha: 0.7)
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
      case 'normal':
        return AppTheme.successLight;
      case 'warning':
      case 'maintenance':
        return AppTheme.warningLight;
      case 'offline':
      case 'error':
      case 'critical':
        return AppTheme.errorLight;
      default:
        return AppTheme.primaryLight;
    }
  }
}
