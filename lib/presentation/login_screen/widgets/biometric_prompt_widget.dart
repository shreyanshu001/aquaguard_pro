import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BiometricPromptWidget extends StatelessWidget {
  final VoidCallback onBiometricLogin;
  final VoidCallback onSkip;
  final bool isLoading;

  const BiometricPromptWidget({
    Key? key,
    required this.onBiometricLogin,
    required this.onSkip,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(4.w),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Biometric Icon
          Container(
            width: 16.w,
            height: 16.w,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'fingerprint',
                color: colorScheme.primary,
                size: 8.w,
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Title
          Text(
            'Enable Biometric Login',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Description
          Text(
            'Use your fingerprint or face recognition for quick and secure access to AquaGuard Pro.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 3.h),

          // Action Buttons
          Row(
            children: [
              // Skip Button
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          onSkip();
                        },
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.7),
                    side: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 3.w),

              // Enable Button
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          HapticFeedback.lightImpact();
                          onBiometricLogin();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 4.w,
                          width: 4.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'security',
                              color: colorScheme.onPrimary,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Enable',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
