import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterBottomSheet extends StatefulWidget {
  final String selectedLocation;
  final String selectedParameter;
  final String selectedDateRange;
  final Function(String, String, String) onFiltersApplied;

  const FilterBottomSheet({
    Key? key,
    required this.selectedLocation,
    required this.selectedParameter,
    required this.selectedDateRange,
    required this.onFiltersApplied,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  late String _selectedLocation;
  late String _selectedParameter;
  late String _selectedDateRange;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<String> _locations = [
    'All Locations',
    'Main Treatment Plant',
    'Distribution Point A',
    'Distribution Point B',
    'Reservoir C',
    'Pumping Station 1',
    'Quality Control Lab',
  ];

  final List<String> _parameters = [
    'All Parameters',
    'pH Level',
    'Chlorine',
    'Turbidity',
    'Temperature',
    'Pressure',
    'Flow Rate',
  ];

  final List<Map<String, String>> _dateRanges = [
    {'key': '7D', 'label': 'Last 7 Days'},
    {'key': '30D', 'label': 'Last 30 Days'},
    {'key': '90D', 'label': 'Last 90 Days'},
    {'key': '6M', 'label': 'Last 6 Months'},
    {'key': '1Y', 'label': 'Last Year'},
    {'key': 'custom', 'label': 'Custom Range'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selectedLocation;
    _selectedParameter = widget.selectedParameter;
    _selectedDateRange = widget.selectedDateRange;

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
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

    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset(0, 0),
      ).animate(_animationController),
      child: Container(
        height: 85.h,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationFilter(context),
                    SizedBox(height: 3.h),
                    _buildParameterFilter(context),
                    SizedBox(height: 3.h),
                    _buildDateRangeFilter(context),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'filter_list',
                    color: colorScheme.primary,
                    size: 6.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Filter Reports',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _resetFilters,
                child: Text(
                  'Reset All',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'place',
              color: colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Location',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children:
              _locations.map((location) {
                final isSelected = _selectedLocation == location;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLocation = location;
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? colorScheme.primary.withValues(alpha: 0.1)
                              : colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      location,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color:
                            isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.7),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildParameterFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'science',
              color: colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Parameter Type',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              _parameters.map((parameter) {
                final isSelected = _selectedParameter == parameter;
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedParameter = parameter;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? colorScheme.primary.withValues(alpha: 0.1)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5.w,
                            height: 5.w,
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withValues(
                                          alpha: 0.5,
                                        ),
                                width: 2,
                              ),
                            ),
                            child:
                                isSelected
                                    ? Center(
                                      child: CustomIconWidget(
                                        iconName: 'check',
                                        color: colorScheme.onPrimary,
                                        size: 3.w,
                                      ),
                                    )
                                    : null,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              parameter,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    isSelected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (parameter != 'All Parameters')
                            CustomIconWidget(
                              iconName: _getParameterIcon(parameter),
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                              size: 4.w,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'date_range',
              color: colorScheme.primary,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Time Period',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 1.h,
            childAspectRatio: 3,
          ),
          itemCount: _dateRanges.length,
          itemBuilder: (context, index) {
            final range = _dateRanges[index];
            final isSelected = _selectedDateRange == range['key'];

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDateRange = range['key']!;
                });
                if (range['key'] == 'custom') {
                  _showCustomDatePicker();
                }
              },
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Center(
                  child: Text(
                    range['label']!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.7),
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                side: BorderSide(color: colorScheme.outline),
              ),
              child: Text('Cancel'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'check',
                    color: colorScheme.onPrimary,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Apply Filters',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getParameterIcon(String parameter) {
    switch (parameter) {
      case 'pH Level':
        return 'science';
      case 'Chlorine':
        return 'water_drop';
      case 'Turbidity':
        return 'visibility_off';
      case 'Temperature':
        return 'thermostat';
      case 'Pressure':
        return 'speed';
      case 'Flow Rate':
        return 'waterfall_chart';
      default:
        return 'help';
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedLocation = 'All Locations';
      _selectedParameter = 'All Parameters';
      _selectedDateRange = '30D';
    });
  }

  void _showCustomDatePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    ).then((DateTimeRange? range) {
      if (range != null) {
        setState(() {
          _selectedDateRange = 'custom';
        });
      }
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(
      _selectedLocation,
      _selectedParameter,
      _selectedDateRange,
    );
    Navigator.of(context).pop();
  }
}