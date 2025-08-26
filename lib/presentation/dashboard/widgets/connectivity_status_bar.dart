import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectivityStatusBar extends StatefulWidget {
  final bool isConnected;
  final int connectedSensors;
  final int totalSensors;
  final VoidCallback? onTap;

  const ConnectivityStatusBar({
    Key? key,
    required this.isConnected,
    required this.connectedSensors,
    required this.totalSensors,
    this.onTap,
  }) : super(key: key);

  @override
  State<ConnectivityStatusBar> createState() => _ConnectivityStatusBarState();
}

class _ConnectivityStatusBarState extends State<ConnectivityStatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isConnected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectivityStatusBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isConnected != oldWidget.isConnected) {
      if (widget.isConnected) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool hasPartialConnection = widget.connectedSensors > 0 &&
        widget.connectedSensors < widget.totalSensors;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (widget.isConnected && widget.connectedSensors == widget.totalSensors) {
      statusColor = AppTheme.successLight;
      statusText = 'All Systems Online';
      statusIcon = Icons.wifi;
    } else if (hasPartialConnection) {
      statusColor = AppTheme.warningLight;
      statusText = 'Partial Connection';
      statusIcon = Icons.wifi_off;
    } else {
      statusColor = AppTheme.errorLight;
      statusText = 'Offline';
      statusIcon = Icons.wifi_off;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isConnected ? _pulseAnimation.value : 1.0,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: _getIconName(statusIcon),
                      color: statusColor,
                      size: 5.w,
                    ),
                  ),
                );
              },
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    '${widget.connectedSensors}/${widget.totalSensors} sensors connected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.totalSensors > 0)
              Container(
                width: 15.w,
                height: 1.h,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: widget.connectedSensors / widget.totalSensors,
                  child: Container(
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: colorScheme.onSurface.withValues(alpha: 0.5),
              size: 5.w,
            ),
          ],
        ),
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.wifi) return 'wifi';
    if (icon == Icons.wifi_off) return 'wifi_off';
    return 'signal_wifi_off';
  }
}
