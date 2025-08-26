import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterChipsWidget extends StatelessWidget {
  final List<String> selectedFilters;
  final Function(String) onFilterToggle;
  final Map<String, int> filterCounts;

  const FilterChipsWidget({
    Key? key,
    required this.selectedFilters,
    required this.onFilterToggle,
    required this.filterCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, dynamic>> filters = [
      {
        'key': 'critical',
        'label': 'Critical',
        'icon': 'error',
        'color': AppTheme.errorLight,
      },
      {
        'key': 'warning',
        'label': 'Warning',
        'icon': 'warning',
        'color': AppTheme.warningLight,
      },
      {
        'key': 'info',
        'label': 'Info',
        'icon': 'info',
        'color': AppTheme.accentLight,
      },
      {
        'key': 'active',
        'label': 'Active',
        'icon': 'radio_button_checked',
        'color': colorScheme.primary,
      },
      {
        'key': 'resolved',
        'label': 'Resolved',
        'icon': 'check_circle',
        'color': AppTheme.successLight,
      },
      {
        'key': 'today',
        'label': 'Today',
        'icon': 'today',
        'color': colorScheme.secondary,
      },
      {
        'key': 'week',
        'label': 'This Week',
        'icon': 'date_range',
        'color': colorScheme.secondary,
      },
    ];

    return Container(
      height: 6.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: filters.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final filterKey = filter['key'] as String;
          final isSelected = selectedFilters.contains(filterKey);
          final count = filterCounts[filterKey] ?? 0;

          return _buildFilterChip(
            context,
            filter,
            isSelected,
            count,
            colorScheme,
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    Map<String, dynamic> filter,
    bool isSelected,
    int count,
    ColorScheme colorScheme,
  ) {
    final filterKey = filter['key'] as String;
    final label = filter['label'] as String;
    final iconName = filter['icon'] as String;
    final filterColor = filter['color'] as Color;

    return GestureDetector(
      onTap: () => onFilterToggle(filterKey),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? filterColor.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? filterColor
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: filterColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isSelected
                  ? filterColor
                  : colorScheme.onSurface.withValues(alpha: 0.7),
              size: 16,
            ),
            SizedBox(width: 1.5.w),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? filterColor
                    : colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            if (count > 0) ...[
              SizedBox(width: 1.w),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: isSelected ? filterColor : colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}