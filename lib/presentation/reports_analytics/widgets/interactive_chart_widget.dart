import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class InteractiveChartWidget extends StatefulWidget {
  final String reportType;
  final List<Map<String, dynamic>> data;
  final Function(Map<String, dynamic>) onDataPointTapped;

  const InteractiveChartWidget({
    Key? key,
    required this.reportType,
    required this.data,
    required this.onDataPointTapped,
  }) : super(key: key);

  @override
  State<InteractiveChartWidget> createState() => _InteractiveChartWidgetState();
}

class _InteractiveChartWidgetState extends State<InteractiveChartWidget>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  bool _showTooltip = false;
  bool _isZoomed = false;
  String _selectedParameter = '';
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeSelectedParameter();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeSelectedParameter() {
    switch (widget.reportType) {
      case 'Quality':
        _selectedParameter = 'pH';
        break;
      case 'Consumption':
        _selectedParameter = 'daily_usage';
        break;
      case 'Compliance':
        _selectedParameter = 'compliance_score';
        break;
      case 'Forecasting':
        _selectedParameter = 'predicted_usage';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          _buildChartHeader(context),
          SizedBox(height: 2.h),
          _buildParameterSelector(context),
          SizedBox(height: 3.h),
          _buildChart(context),
          if (_isZoomed) ...[
            SizedBox(height: 2.h),
            _buildZoomControls(context),
          ],
        ],
      ),
    );
  }

  Widget _buildChartHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.reportType} Trends',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Tap data points for details',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        Row(
          children: [
            _buildChartTypeButton(context, 'line', 'multiline_chart'),
            SizedBox(width: 2.w),
            _buildChartTypeButton(context, 'bar', 'bar_chart'),
            SizedBox(width: 2.w),
            _buildZoomButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildChartTypeButton(
    BuildContext context,
    String type,
    String iconName,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = type == 'line'; // Default to line chart

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        // Switch chart type logic would go here
      },
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                isSelected
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color:
              isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
          size: 4.w,
        ),
      ),
    );
  }

  Widget _buildZoomButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _isZoomed = !_isZoomed;
        });
        if (_isZoomed) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      },
      child: Container(
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color:
              _isZoomed
                  ? colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                _isZoomed
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: CustomIconWidget(
          iconName: _isZoomed ? 'zoom_out' : 'zoom_in',
          color:
              _isZoomed
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
          size: 4.w,
        ),
      ),
    );
  }

  Widget _buildParameterSelector(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final parameters = _getParametersForReportType(widget.reportType);

    return Container(
      height: 5.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: parameters.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final parameter = parameters[index];
          final isSelected = _selectedParameter == parameter['key'];

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedParameter = parameter['key'] ?? '';
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? colorScheme.primary
                        : colorScheme.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  parameter['label'] ?? '',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color:
                        isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Map<String, String>> _getParametersForReportType(String reportType) {
    switch (reportType) {
      case 'Quality':
        return [
          {'key': 'pH', 'label': 'pH Level'},
          {'key': 'chlorine', 'label': 'Chlorine'},
          {'key': 'turbidity', 'label': 'Turbidity'},
          {'key': 'temperature', 'label': 'Temperature'},
        ];
      case 'Consumption':
        return [
          {'key': 'daily_usage', 'label': 'Daily Usage'},
          {'key': 'peak_hour', 'label': 'Peak Hour'},
          {'key': 'efficiency', 'label': 'Efficiency'},
        ];
      case 'Compliance':
        return [
          {'key': 'compliance_score', 'label': 'Score'},
          {'key': 'violations', 'label': 'Violations'},
          {'key': 'passed_tests', 'label': 'Passed Tests'},
          {'key': 'failed_tests', 'label': 'Failed Tests'},
        ];
      case 'Forecasting':
        return [
          {'key': 'predicted_usage', 'label': 'Predicted Usage'},
          {'key': 'maintenance_score', 'label': 'Maintenance'},
        ];
      default:
        return [];
    }
  }

  Widget _buildChart(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isZoomed ? _scaleAnimation.value : 1.0,
          child: Container(
            height: _isZoomed ? 40.h : 30.h,
            child: LineChart(
              _createLineChartData(context),
              duration: Duration(milliseconds: 300),
            ),
          ),
        );
      },
    );
  }

  LineChartData _createLineChartData(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final spots = _createSpotsFromData();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: _getHorizontalInterval(),
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colorScheme.outline.withValues(alpha: 0.1),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: colorScheme.outline.withValues(alpha: 0.1),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) => _buildBottomTitle(value, meta),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _getLeftInterval(),
            reservedSize: 50,
            getTitlesWidget: (value, meta) => _buildLeftTitle(value, meta),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      minX: 0,
      maxX: (widget.data.length - 1).toDouble(),
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.primary.withValues(alpha: 0.7),
            ],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: _touchedIndex == index ? 6 : 4,
                color: colorScheme.primary,
                strokeWidth: 2,
                strokeColor: colorScheme.surface,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                colorScheme.primary.withValues(alpha: 0.2),
                colorScheme.primary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (touchResponse != null && touchResponse.lineBarSpots != null) {
              _touchedIndex = touchResponse.lineBarSpots!.first.spotIndex;
              _showTooltip = true;

              // Provide haptic feedback for data point interaction
              HapticFeedback.lightImpact();

              // Trigger callback with data point details
              if (_touchedIndex < widget.data.length) {
                widget.onDataPointTapped(widget.data[_touchedIndex]);
              }
            } else {
              _showTooltip = false;
              _touchedIndex = -1;
            }
          });
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: colorScheme.inverseSurface,
          tooltipRoundedRadius: 8,
          tooltipPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final index = barSpot.spotIndex;
              if (index >= 0 && index < widget.data.length) {
                final data = widget.data[index];
                final value = data[_selectedParameter];
                final timestamp = data['timestamp'] as DateTime;

                return LineTooltipItem(
                  '${_formatValue(value)}\n${_formatDate(timestamp)}',
                  TextStyle(
                    color: colorScheme.onInverseSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }

  List<FlSpot> _createSpotsFromData() {
    final spots = <FlSpot>[];

    for (int i = 0; i < widget.data.length; i++) {
      final value = widget.data[i][_selectedParameter];
      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value.toDouble()));
      }
    }

    return spots;
  }

  double _getMinY() {
    final values =
        widget.data
            .map((d) => d[_selectedParameter])
            .where((v) => v != null)
            .map((v) => v.toDouble())
            .toList();

    if (values.isEmpty) return 0;

    final min = values.reduce((a, b) => a < b ? a : b);
    return (min * 0.9); // Add 10% padding
  }

  double _getMaxY() {
    final values =
        widget.data
            .map((d) => d[_selectedParameter])
            .where((v) => v != null)
            .map((v) => v.toDouble())
            .toList();

    if (values.isEmpty) return 100;

    final max = values.reduce((a, b) => a > b ? a : b);
    return (max * 1.1); // Add 10% padding
  }

  double _getHorizontalInterval() {
    final range = _getMaxY() - _getMinY();
    return range / 5; // Show 5 horizontal grid lines
  }

  double _getLeftInterval() {
    final range = _getMaxY() - _getMinY();
    return range / 4; // Show 4 intervals on left axis
  }

  Widget _buildBottomTitle(double value, TitleMeta meta) {
    final theme = Theme.of(context);
    final index = value.toInt();

    if (index >= 0 && index < widget.data.length) {
      final timestamp = widget.data[index]['timestamp'] as DateTime;
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(
          _formatDateShort(timestamp),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );
    }
    return Container();
  }

  Widget _buildLeftTitle(double value, TitleMeta meta) {
    final theme = Theme.of(context);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        _formatValue(value),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildZoomControls(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pinch to zoom • Pan to navigate',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '—';

    switch (_selectedParameter) {
      case 'pH':
        return value.toStringAsFixed(1);
      case 'chlorine':
        return '${value.toStringAsFixed(1)}mg/L';
      case 'turbidity':
        return '${value.toStringAsFixed(1)}NTU';
      case 'temperature':
        return '${value.toStringAsFixed(1)}°C';
      case 'daily_usage':
      case 'peak_hour':
      case 'predicted_usage':
        return '${value.toStringAsFixed(0)}L';
      case 'efficiency':
      case 'compliance_score':
      case 'maintenance_score':
        return '${value.toStringAsFixed(1)}%';
      case 'violations':
      case 'passed_tests':
      case 'failed_tests':
        return value.toStringAsFixed(0);
      default:
        return value.toString();
    }
  }

  String _formatDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDateShort(DateTime date) {
    return '${date.day}/${date.month}';
  }
}