import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PressureGaugeWidget extends StatefulWidget {
  final double currentPressure;
  final double minPressure;
  final double maxPressure;
  final String unit;
  final String status;

  const PressureGaugeWidget({
    Key? key,
    required this.currentPressure,
    this.minPressure = 0,
    this.maxPressure = 100,
    this.unit = 'PSI',
    required this.status,
  }) : super(key: key);

  @override
  State<PressureGaugeWidget> createState() => _PressureGaugeWidgetState();
}

class _PressureGaugeWidgetState extends State<PressureGaugeWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.currentPressure,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didUpdateWidget(PressureGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPressure != widget.currentPressure) {
      _animation = Tween<double>(
        begin: oldWidget.currentPressure,
        end: widget.currentPressure,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));
      _animationController.reset();
      _animationController.forward();
    }
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
    final bool isLight = theme.brightness == Brightness.light;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isLight
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
          _buildHeader(context),
          SizedBox(height: 3.h),
          _buildGauge(context),
          SizedBox(height: 2.h),
          _buildStatusIndicator(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Pressure',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Real-time monitoring',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        CustomIconWidget(
          iconName: 'compress',
          color: colorScheme.primary,
          size: 24,
        ),
      ],
    );
  }

  Widget _buildGauge(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Container(
        width: 60.w,
        height: 60.w,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: GaugePainter(
                currentValue: _animation.value,
                minValue: widget.minPressure,
                maxValue: widget.maxPressure,
                primaryColor: colorScheme.primary,
                backgroundColor: colorScheme.outline.withValues(alpha: 0.2),
                needleColor: colorScheme.onSurface,
                textColor: colorScheme.onSurface,
                unit: widget.unit,
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color statusColor;
    IconData statusIcon;

    switch (widget.status.toLowerCase()) {
      case 'normal':
        statusColor = AppTheme.successLight;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'warning':
        statusColor = AppTheme.warningLight;
        statusIcon = Icons.warning_outlined;
        break;
      case 'critical':
        statusColor = AppTheme.errorLight;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusColor = colorScheme.onSurface.withValues(alpha: 0.6);
        statusIcon = Icons.info_outline;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: statusIcon == Icons.check_circle_outline
                ? 'check_circle_outline'
                : statusIcon == Icons.warning_outlined
                    ? 'warning_outlined'
                    : statusIcon == Icons.error_outline
                        ? 'error_outline'
                        : 'info_outline',
            color: statusColor,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: ${widget.status}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Range: ${widget.minPressure.toInt()}-${widget.maxPressure.toInt()} ${widget.unit}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double currentValue;
  final double minValue;
  final double maxValue;
  final Color primaryColor;
  final Color backgroundColor;
  final Color needleColor;
  final Color textColor;
  final String unit;

  GaugePainter({
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
    required this.primaryColor,
    required this.backgroundColor,
    required this.needleColor,
    required this.textColor,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      math.pi * 1.5,
      false,
      backgroundPaint,
    );

    // Draw progress arc
    final progressPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final progress = (currentValue - minValue) / (maxValue - minValue);
    final sweepAngle = math.pi * 1.5 * progress.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 0.75,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw needle
    final needleAngle = -math.pi * 0.75 + sweepAngle;
    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center circle
    final centerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);

    // Draw value text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${currentValue.toInt()}\n$unit',
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
