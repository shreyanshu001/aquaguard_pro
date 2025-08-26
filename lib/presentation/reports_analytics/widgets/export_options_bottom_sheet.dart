import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class ExportOptionsBottomSheet extends StatefulWidget {
  final String reportType;
  final Function(String, List<String>) onExport;

  const ExportOptionsBottomSheet({
    Key? key,
    required this.reportType,
    required this.onExport,
  }) : super(key: key);

  @override
  State<ExportOptionsBottomSheet> createState() =>
      _ExportOptionsBottomSheetState();
}

class _ExportOptionsBottomSheetState extends State<ExportOptionsBottomSheet>
    with SingleTickerProviderStateMixin {
  String _selectedFormat = 'PDF';
  Set<String> _selectedSections = {};
  bool _scheduleReports = false;
  String _scheduleFrequency = 'Weekly';
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  final List<Map<String, dynamic>> _exportFormats = [
    {
      'format': 'PDF',
      'description': 'Formatted report with charts and analysis',
      'icon': 'picture_as_pdf',
      'color': AppTheme.errorLight,
    },
    {
      'format': 'CSV',
      'description': 'Raw data for spreadsheet analysis',
      'icon': 'table_chart',
      'color': AppTheme.successLight,
    },
    {
      'format': 'Email',
      'description': 'Send report directly via email',
      'icon': 'email',
      'color': AppTheme.accentLight,
    },
  ];

  final List<String> _scheduleFrequencies = [
    'Daily',
    'Weekly',
    'Monthly',
    'Quarterly',
  ];

  @override
  void initState() {
    super.initState();
    _initializeSections();

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

  void _initializeSections() {
    switch (widget.reportType) {
      case 'Quality':
        _selectedSections = {
          'Summary Statistics',
          'Water Quality Trends',
          'Parameter Analysis',
        };
        break;
      case 'Consumption':
        _selectedSections = {
          'Usage Summary',
          'Consumption Trends',
          'Efficiency Analysis',
        };
        break;
      case 'Compliance':
        _selectedSections = {
          'Compliance Score',
          'Violation History',
          'Test Results',
        };
        break;
      case 'Forecasting':
        _selectedSections = {
          'Predictions',
          'Maintenance Schedule',
          'Trend Analysis',
        };
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SlideTransition(
      position: _slideAnimation.drive(Tween<Offset>(begin: Offset(0, 1), end: Offset.zero)),
      child: Container(
        height: 90.h,
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
                    _buildFormatSelection(context),
                    SizedBox(height: 3.h),
                    _buildSectionSelection(context),
                    SizedBox(height: 3.h),
                    _buildScheduleOptions(context),
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
            children: [
              CustomIconWidget(
                iconName: 'file_download',
                color: colorScheme.primary,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Report',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '${widget.reportType} Report • Export Options',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Column(
          children:
              _exportFormats.map((format) {
                final isSelected = _selectedFormat == format['format'];
                return Container(
                  margin: EdgeInsets.only(bottom: 2.h),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedFormat = format['format'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? colorScheme.primary.withValues(alpha: 0.1)
                                : colorScheme.surface.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.2),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: format['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: format['icon'],
                              color: format['color'],
                              size: 6.w,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  format['format'],
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  format['description'],
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'check',
                                color: colorScheme.onPrimary,
                                size: 4.w,
                              ),
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

  Widget _buildSectionSelection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final sections = _getSectionsForReportType(widget.reportType);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Include Sections',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed:
                  _selectedSections.length == sections.length
                      ? _deselectAllSections
                      : _selectAllSections,
              child: Text(
                _selectedSections.length == sections.length
                    ? 'Deselect All'
                    : 'Select All',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Column(
          children:
              sections.map((section) {
                final isSelected = _selectedSections.contains(section['name']);
                return Container(
                  margin: EdgeInsets.only(bottom: 1.h),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedSections.add(section['name']!);
                        } else {
                          _selectedSections.remove(section['name']!);
                        }
                      });
                    },
                    title: Text(
                      section['name']!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      section['description']!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    secondary: CustomIconWidget(
                      iconName: section['icon']!,
                      color: colorScheme.primary.withValues(alpha: 0.7),
                      size: 5.w,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildScheduleOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Schedule Automatic Reports',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch(
              value: _scheduleReports,
              onChanged: (bool value) {
                setState(() {
                  _scheduleReports = value;
                });
              },
            ),
          ],
        ),
        if (_scheduleReports) ...[
          SizedBox(height: 2.h),
          Text(
            'Frequency',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: DropdownButton<String>(
              value: _scheduleFrequency,
              isExpanded: true,
              underline: Container(),
              icon: CustomIconWidget(
                iconName: 'arrow_drop_down',
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                size: 6.w,
              ),
              items:
                  _scheduleFrequencies.map((frequency) {
                    return DropdownMenuItem<String>(
                      value: frequency,
                      child: Text(frequency, style: theme.textTheme.bodyMedium),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _scheduleFrequency = newValue;
                  });
                }
              },
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.accentLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.accentLight.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'info',
                  color: AppTheme.accentLight,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Scheduled reports will be automatically generated and sent to your email.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.accentLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
              onPressed: _selectedSections.isEmpty ? null : _exportReport,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName:
                        _selectedFormat == 'Email' ? 'send' : 'file_download',
                    color: colorScheme.onPrimary,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _selectedFormat == 'Email'
                        ? 'Send Report'
                        : 'Export Report',
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

  List<Map<String, String>> _getSectionsForReportType(String reportType) {
    switch (reportType) {
      case 'Quality':
        return [
          {
            'name': 'Summary Statistics',
            'description': 'Key metrics and averages',
            'icon': 'analytics',
          },
          {
            'name': 'Water Quality Trends',
            'description': 'Charts showing parameter changes over time',
            'icon': 'multiline_chart',
          },
          {
            'name': 'Parameter Analysis',
            'description': 'Detailed analysis of pH, chlorine, turbidity, etc.',
            'icon': 'science',
          },
          {
            'name': 'Compliance Status',
            'description': 'Regulatory compliance information',
            'icon': 'verified',
          },
          {
            'name': 'Anomaly Detection',
            'description': 'Unusual readings and alerts',
            'icon': 'warning',
          },
        ];
      case 'Consumption':
        return [
          {
            'name': 'Usage Summary',
            'description': 'Total consumption and key metrics',
            'icon': 'water',
          },
          {
            'name': 'Consumption Trends',
            'description': 'Usage patterns over time',
            'icon': 'trending_up',
          },
          {
            'name': 'Efficiency Analysis',
            'description': 'System efficiency and waste reduction',
            'icon': 'eco',
          },
          {
            'name': 'Peak Usage',
            'description': 'High demand periods and patterns',
            'icon': 'show_chart',
          },
          {
            'name': 'Cost Analysis',
            'description': 'Water treatment and distribution costs',
            'icon': 'attach_money',
          },
        ];
      case 'Compliance':
        return [
          {
            'name': 'Compliance Score',
            'description': 'Overall regulatory compliance rating',
            'icon': 'grade',
          },
          {
            'name': 'Violation History',
            'description': 'Past violations and corrective actions',
            'icon': 'report_problem',
          },
          {
            'name': 'Test Results',
            'description': 'Laboratory test outcomes',
            'icon': 'assignment_turned_in',
          },
          {
            'name': 'Audit Trail',
            'description': 'Documentation and record keeping',
            'icon': 'history',
          },
          {
            'name': 'Regulatory Updates',
            'description': 'Changes in regulations and requirements',
            'icon': 'new_releases',
          },
        ];
      case 'Forecasting':
        return [
          {
            'name': 'Predictions',
            'description': 'Future consumption and quality forecasts',
            'icon': 'insights',
          },
          {
            'name': 'Maintenance Schedule',
            'description': 'Predicted maintenance requirements',
            'icon': 'schedule',
          },
          {
            'name': 'Trend Analysis',
            'description': 'Long-term patterns and projections',
            'icon': 'timeline',
          },
          {
            'name': 'Risk Assessment',
            'description': 'Potential issues and mitigation strategies',
            'icon': 'security',
          },
          {
            'name': 'Resource Planning',
            'description': 'Future resource and capacity needs',
            'icon': 'inventory',
          },
        ];
      default:
        return [];
    }
  }

  void _selectAllSections() {
    setState(() {
      _selectedSections =
          _getSectionsForReportType(
            widget.reportType,
          ).map((section) => section['name']!).toSet();
    });
  }

  void _deselectAllSections() {
    setState(() {
      _selectedSections.clear();
    });
  }

  void _exportReport() {
    widget.onExport(_selectedFormat, _selectedSections.toList());
    Navigator.of(context).pop();
  }
}