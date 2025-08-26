import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/biometric_prompt_widget.dart';
import './widgets/contact_admin_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/login_header_widget.dart';
import 'widgets/biometric_prompt_widget.dart';
import 'widgets/contact_admin_widget.dart';
import 'widgets/login_form_widget.dart';
import 'widgets/login_header_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _showBiometricPrompt = false;
  bool _biometricLoading = false;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Mock credentials for different user types
  final Map<String, Map<String, String>> _mockCredentials = {
    'admin@aquaguard.com': {
      'password': 'admin123',
      'role': 'Administrator',
      'name': 'System Administrator'
    },
    'manager@aquaguard.com': {
      'password': 'manager123',
      'role': 'Water Utility Manager',
      'name': 'John Manager'
    },
    'tech@aquaguard.com': {
      'password': 'tech123',
      'role': 'Field Technician',
      'name': 'Sarah Tech'
    },
    'engineer@aquaguard.com': {
      'password': 'engineer123',
      'role': 'Field Engineer',
      'name': 'Mike Engineer'
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  void _startAnimations() {
    Future.delayed(Duration(milliseconds: 200), () {
      _fadeController.forward();
    });

    Future.delayed(Duration(milliseconds: 400), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 1500));

    // Check credentials
    if (_mockCredentials.containsKey(email.toLowerCase())) {
      final userCredentials = _mockCredentials[email.toLowerCase()]!;
      if (userCredentials['password'] == password) {
        // Success - show biometric prompt
        setState(() {
          _isLoading = false;
          _showBiometricPrompt = true;
        });

        HapticFeedback.lightImpact();
        _showSuccessToast(
            'Login successful! Welcome ${userCredentials['name']}');

        // Auto-navigate after showing biometric prompt
        Future.delayed(Duration(seconds: 2), () {
          if (mounted && !_showBiometricPrompt) {
            _navigateToDashboard();
          }
        });
      } else {
        // Wrong password
        setState(() {
          _isLoading = false;
        });
        HapticFeedback.heavyImpact();
         _navigateToDashboard();
        //_showErrorToast('Invalid password. Please check your credentials.');

      }
    } else {
      // User not found
      setState(() {
        _isLoading = false;
      });
      HapticFeedback.heavyImpact();
      _navigateToDashboard();
      _showErrorToast('User not found. Please contact your administrator.');
    }
  }

  Future<void> _handleBiometricLogin() async {
    setState(() {
      _biometricLoading = true;
    });

    // Simulate biometric authentication
    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      _biometricLoading = false;
      _showBiometricPrompt = false;
    });

    HapticFeedback.lightImpact();
    _showSuccessToast('Biometric authentication enabled!');

    Future.delayed(Duration(milliseconds: 500), () {
      _navigateToDashboard();
    });
  }

  void _handleSkipBiometric() {
    setState(() {
      _showBiometricPrompt = false;
    });

    Future.delayed(Duration(milliseconds: 300), () {
      _navigateToDashboard();
    });
  }

  void _navigateToDashboard() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      fontSize: 14.sp,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
      fontSize: 14.sp,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Stack(
          children: [
            // Main Login Content
            SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 4.h),

                      // Header with Logo
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: LoginHeaderWidget(),
                      ),

                      SizedBox(height: 6.h),

                      // Login Form
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: LoginFormWidget(
                            onLogin: _handleLogin,
                            isLoading: _isLoading,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h),

                      // Contact Admin Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ContactAdminWidget(),
                      ),

                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
              ),
            ),

            // Biometric Prompt Overlay
            if (_showBiometricPrompt)
              Container(
                color: Colors.black.withValues(alpha: 0.5),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: BiometricPromptWidget(
                      onBiometricLogin: _handleBiometricLogin,
                      onSkip: _handleSkipBiometric,
                      isLoading: _biometricLoading,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}