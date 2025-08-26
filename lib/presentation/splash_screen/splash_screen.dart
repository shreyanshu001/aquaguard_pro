import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  String _statusText = 'Initializing...';
  bool _showOfflineOption = false;
  bool _isConnecting = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialization();
  }

  void _initializeAnimations() {
    // Pulse animation for logo
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Fade animation for transition
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  Future<void> _startInitialization() async {
    try {
      // Check authentication status
      await _updateStatus('Checking authentication...');
      await Future.delayed(Duration(milliseconds: 800));

      // Establish IoT connections
      await _updateStatus('Connecting to sensors...');
      await Future.delayed(Duration(milliseconds: 1000));

      // Load user preferences
      await _updateStatus('Loading preferences...');
      await Future.delayed(Duration(milliseconds: 600));

      // Prepare cached data
      await _updateStatus('Preparing data...');
      await Future.delayed(Duration(milliseconds: 800));

      // Show offline option after 5 seconds if still connecting
      Future.delayed(Duration(seconds: 5), () {
        if (_isConnecting && mounted) {
          setState(() {
            _showOfflineOption = true;
          });
        }
      });

      // Simulate connection success after initialization
      await Future.delayed(Duration(milliseconds: 500));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusText = 'Connection failed';
          _showOfflineOption = true;
        });
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    if (mounted) {
      setState(() {
        _statusText = status;
      });
    }
  }

  void _navigateToNextScreen() {
    setState(() {
      _isConnecting = false;
    });

    // Start fade out animation
    _fadeController.forward().then((_) {
      if (mounted) {
        // Simulate authentication check - in real app, check actual auth status
        bool isAuthenticated = false; // Replace with actual auth check
        bool isFirstTime = true; // Replace with actual first-time check

        if (isAuthenticated) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else if (isFirstTime) {
          // Navigate to onboarding if available, otherwise login
          Navigator.pushReplacementNamed(context, '/login-screen');
        } else {
          Navigator.pushReplacementNamed(context, '/login-screen');
        }
      }
    });
  }

  void _continueOffline() {
    setState(() {
      _statusText = 'Continuing offline...';
      _showOfflineOption = false;
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      if (mounted) {
        _navigateToNextScreen();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 100.w,
              height: 100.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.lightTheme.colorScheme.primary,
                    AppTheme.lightTheme.colorScheme.primaryContainer,
                    AppTheme.lightTheme.colorScheme.secondary,
                  ],
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo section
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated logo
                          AnimatedBuilder(
                            animation: _pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 25.w,
                                  height: 25.w,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: CustomIconWidget(
                                      iconName: 'water_drop',
                                      size: 12.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 4.h),

                          // App name
                          Text(
                            'AquaGuard Pro',
                            style: AppTheme.lightTheme.textTheme.headlineLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 1.h),

                          // Tagline
                          Text(
                            'Smart Water Quality Management',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Loading section
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Loading indicator
                          SizedBox(
                            width: 8.w,
                            height: 8.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Status text
                          Text(
                            _statusText,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          SizedBox(height: 2.h),

                          // Offline option
                          if (_showOfflineOption)
                            TextButton(
                              onPressed: _continueOffline,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.2),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 1.5.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'wifi_off',
                                    size: 4.w,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Continue Offline',
                                    style: AppTheme
                                        .lightTheme.textTheme.labelLarge
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: EdgeInsets.only(bottom: 2.h),
                      child: Column(
                        children: [
                          // Version info
                          Text(
                            'Version 1.0.0',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10.sp,
                            ),
                          ),

                          SizedBox(height: 1.h),

                          // Security badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'security',
                                size: 3.w,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'SSL Secured',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 9.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
