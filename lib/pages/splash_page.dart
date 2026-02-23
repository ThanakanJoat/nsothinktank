import 'package:flutter/material.dart';
import 'package:nsothinktank/theme/app_theme.dart';
import 'dart:async';
import 'package:nsothinktank/utils/version_manager.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    
    // Check version and navigate
    _initSequence();
  }

  Future<void> _initSequence() async {
    // Wait minimum time (e.g. 2s) to show splash AND check version in parallel
    // If version check takes longer than 2s, splash will stay until check finishes.
    final minTimer = Future.delayed(const Duration(seconds: 3));
    final versionCheck = VersionManager.isUpdateAvailable();
    
    await Future.wait([minTimer]); // Wait at least 3s
    
    bool updateAvailable = false;
    try {
      updateAvailable = await versionCheck;
    } catch (e) {
      print("Version check failed: $e");
    }
    
    if (updateAvailable && mounted) {
       await VersionManager.showUpdateDialog(
         context, 
         allowSkip: true,
         onSkip: () => _navigateToHome(),
       );
       // If dialog closed by tapping outside or 'Update', we might still want to go home or just stay?
       // Usually 'Update' opens store. User comes back. 
       // If we want to allow user to use app after update click (or if they return), we should navigate home.
       // For now, onSkip handles the "Later" case.
       // What if they click Update? The dialog closes, opens store. The app is still on Splash?
       // Let's make sure we navigate to Home if they click Update as well (so when they return, they are in app)
       // OR we can rely on allowSkip logic.
       // Simpler: Just rely on callback in dialog.
       _navigateToHome();
    } else {
       _navigateToHome();
    }
  }

  void _navigateToHome() {
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.lightBlue.shade50,
              Colors.white,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Illustration at bottom (Background layer)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/thai_skyline.png',
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                height: size.height * 0.35, 
              ),
            ),

            // 2. Content with Safe Layout (Foreground layer)
            Positioned.fill(
               child: SafeArea(
                 child: Column(
                   children: [
                     const Spacer(flex: 3), // Middle-Top position
                     FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                               Container(
                                 padding: EdgeInsets.all(size.width * 0.04),
                                 decoration: BoxDecoration(
                                   shape: BoxShape.circle,
                                   color: Colors.white,
                                   boxShadow: [
                                     BoxShadow(
                                       color: theme.primaryColor.withOpacity(0.15),
                                       blurRadius: 20,
                                       offset: const Offset(0, 10),
                                     )
                                   ]
                                 ),
                                 child: Image.asset(
                                    'assets/images/nso.png',
                                    width: (size.width * 0.25).clamp(80.0, 120.0), 
                                    height: (size.width * 0.25).clamp(80.0, 120.0),
                                  ),
                               ),
                              SizedBox(height: size.height * 0.03), 
                              
                              Text(
                                'สำนักงานสถิติแห่งชาติ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (size.width * 0.06).clamp(20.0, 28.0),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2D3142),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(height: size.height * 0.005),
                              Text(
                                'National Statistical Office',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (size.width * 0.035).clamp(12.0, 16.0),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                  letterSpacing: 1.0,
                                ),
                              ),
                              
                              SizedBox(height: size.height * 0.04),
                              
                              Text(
                                'THAI STAT',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (size.width * 0.07).clamp(24.0, 32.0),
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              SizedBox(height: size.height * 0.01),

                              Text(
                                'NSO Mobile Application',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (size.width * 0.045).clamp(16.0, 22.0),
                                  fontWeight: FontWeight.w600,
                                  color: theme.primaryColor,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Text(
                                  'ขับเคลื่อนระบบสถิติประเทศไทย\nเพื่อการพัฒนาประเทศอย่างยั่งยืน',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: (size.width * 0.038).clamp(14.0, 18.0),
                                    height: 1.5,
                                    color: Colors.grey[700],
                                    fontStyle: FontStyle.italic
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                     ),
                     const Spacer(flex: 4), // Higher flex to push content up more
                   ],
                 ),
               ),
            ),
             
             // Loading indicator or hints
             Positioned(
               bottom: 50,
               child: CircularProgressIndicator(
                 color: theme.primaryColor.withOpacity(0.5),
               ),
             )
          ],
        ),
      ),
    );
  }
}
