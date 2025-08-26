import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmergencyAlertButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isActive;

  const EmergencyAlertButton({
    Key? key,
    this.onPressed,
    this.isActive = false,
  }) : super(key: key);

  @override
  State<EmergencyAlertButton> createState() => _EmergencyAlertButtonState();
}

class _EmergencyAlertButtonState extends State<EmergencyAlertButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.1, curve: Curves.easeInOut),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));

    if (widget.isActive) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(EmergencyAlertButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handlePress() {
    HapticFeedback.heavyImpact();
    _showEmergencyDialog();
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.errorLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'warning',
              color: Colors.white,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Emergency Alert',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to trigger an emergency alert? This will notify all administrators and emergency contacts.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _triggerEmergencyAlert();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.errorLight,
            ),
            child: Text(
              'Trigger Alert',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _triggerEmergencyAlert() {
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.errorLight,
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Emergency alert sent successfully',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
      ),
    );

    // Call the callback if provided
    if (widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale:
              widget.isActive ? _pulseAnimation.value : _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.errorLight.withValues(alpha: 0.3),
                  blurRadius: widget.isActive ? 12 : 8,
                  spreadRadius: widget.isActive ? 2 : 0,
                ),
              ],
            ),
            child: Material(
              color: AppTheme.errorLight,
              shape: CircleBorder(),
              elevation: 4,
              child: InkWell(
                onTap: _handlePress,
                customBorder: CircleBorder(),
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'emergency',
                      color: Colors.white,
                      size: 7.w,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
