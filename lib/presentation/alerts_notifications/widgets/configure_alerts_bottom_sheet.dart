import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ConfigureAlertsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentSettings;
  final Function(Map<String, dynamic>) onSaveSettings;

  const ConfigureAlertsBottomSheet({
    Key? key,
    required this.currentSettings,
    required this.onSaveSettings,
  }) : super(key: key);

  @override
  State<ConfigureAlertsBottomSheet> createState() =>
      _ConfigureAlertsBottomSheetState();
}

class _ConfigureAlertsBottomSheetState
    extends State<ConfigureAlertsBottomSheet> {
  late Map<String, dynamic> _settings;

  @override
  void initState() {
    super.initState();
    _settings = Map<String, dynamic>.from(widget.currentSettings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context, colorScheme),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Water Quality Parameters'),
                  SizedBox(height: 2.h),
                  _buildParameterCard('pH Level', 'ph', 'pH', 6.5, 8.5),
                  _buildParameterCard(
                      'Temperature', 'temperature', '°C', 15.0, 25.0),
                  _buildParameterCard(
                      'Turbidity', 'turbidity', 'NTU', 0.0, 4.0),
                  _buildParameterCard('Chlorine', 'chlorine', 'mg/L', 0.2, 4.0),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('System Parameters'),
                  SizedBox(height: 2.h),
                  _buildParameterCard(
                      'Pressure', 'pressure', 'PSI', 30.0, 80.0),
                  _buildParameterCard(
                      'Flow Rate', 'flowRate', 'L/min', 10.0, 100.0),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Notification Settings'),
                  SizedBox(height: 2.h),
                  _buildNotificationSettings(colorScheme),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          _buildActionButtons(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'tune',
            color: colorScheme.primary,
            size: 24,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Configure Alert Thresholds',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'close',
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildParameterCard(String name, String key, String unit,
      double defaultMin, double defaultMax) {
    final colorScheme = Theme.of(context).colorScheme;
    final parameterSettings = _settings[key] as Map<String, dynamic>? ?? {};
    final bool isEnabled = parameterSettings['enabled'] as bool? ?? true;
    final double minValue =
        (parameterSettings['minValue'] as num?)?.toDouble() ?? defaultMin;
    final double maxValue =
        (parameterSettings['maxValue'] as num?)?.toDouble() ?? defaultMax;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) {
                  setState(() {
                    _settings[key] = {
                      ...parameterSettings,
                      'enabled': value,
                    };
                  });
                },
              ),
            ],
          ),
          if (isEnabled) ...[
            SizedBox(height: 2.h),
            Text(
              'Safe Range',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                Expanded(
                  child: _buildThresholdInput('Min', minValue, unit, (value) {
                    setState(() {
                      _settings[key] = {
                        ...parameterSettings,
                        'minValue': value,
                      };
                    });
                  }),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _buildThresholdInput('Max', maxValue, unit, (value) {
                    setState(() {
                      _settings[key] = {
                        ...parameterSettings,
                        'maxValue': value,
                      };
                    });
                  }),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThresholdInput(
      String label, double value, String unit, Function(double) onChanged) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 0.5.h),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: unit,
            suffixStyle: GoogleFonts.inter(
              fontSize: 12.sp,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 12.sp),
          onChanged: (text) {
            final parsedValue = double.tryParse(text);
            if (parsedValue != null) {
              onChanged(parsedValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(ColorScheme colorScheme) {
    final notificationSettings =
        _settings['notifications'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          _buildNotificationToggle(
            'Push Notifications',
            'pushEnabled',
            notificationSettings['pushEnabled'] as bool? ?? true,
            'notifications',
          ),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          _buildNotificationToggle(
            'Email Alerts',
            'emailEnabled',
            notificationSettings['emailEnabled'] as bool? ?? false,
            'email',
          ),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          _buildNotificationToggle(
            'SMS Alerts',
            'smsEnabled',
            notificationSettings['smsEnabled'] as bool? ?? false,
            'sms',
          ),
          Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
          _buildNotificationToggle(
            'Critical Only',
            'criticalOnly',
            notificationSettings['criticalOnly'] as bool? ?? false,
            'priority_high',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(
      String title, String key, bool value, String iconName) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                final notifications =
                    _settings['notifications'] as Map<String, dynamic>? ?? {};
                _settings['notifications'] = {
                  ...notifications,
                  key: newValue,
                };
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                widget.onSaveSettings(_settings);
                Navigator.pop(context);
              },
              child: Text('Save Settings'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}