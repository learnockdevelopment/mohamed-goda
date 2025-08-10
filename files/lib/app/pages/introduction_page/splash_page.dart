import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/pages/offline_page/internet_connection_page.dart';
import 'package:webinar/app/services/guest_service/guest_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/config/assets.dart';

import '../../services/storage_service.dart';

class SplashPage extends StatefulWidget {
  static const String pageName = '/splash';
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Color?> backgroundColorAnimation;
  late Animation<Offset> logoPositionAnimation;
  late Animation<double> logoSizeAnimation;
  bool showSpinner = false; // Control visibility of spinner

  @override
  void initState() {
    super.initState();
    fetchSign();
    fetchPurchase();
    fetchSystemSettings();

    // Initialize the animation controller
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    // Define the background color animation
    backgroundColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.deepPurple,
    ).animate(animationController);

    // Define the logo position animation (from bottom to center)
    logoPositionAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Start at the bottom
      end: Offset.zero, // Move to the center
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    // Define the logo size animation
    logoSizeAnimation = Tween<double>(begin: 120, end: 200).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      animationController.forward().whenComplete(() {
        setState(() {
          showSpinner = true; // Show spinner when animation completes
        });
      });

      Timer(const Duration(seconds: 7), () async {
        final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());
        if (connectivityResult.contains(ConnectivityResult.none)) {
          nextRoute(InternetConnectionPage.pageName, isClearBackRoutes: true);
        } else {
          if (mounted) {
            nextRoute(MainPage.pageName, isClearBackRoutes: true);
          }
        }
      });
    });

    GuestService.config();
  }
  Future<void> fetchSign() async {
    try {
      var apiResponse = await GuestService.systemsettings();
      if (apiResponse is Map && apiResponse.containsKey('data')) {
        var data = apiResponse['data'];

        if (data.containsKey('security_settings')) {
          var securitySettings = data['security_settings'];

          if (securitySettings.containsKey('enable_signup')) {
            bool enableSignup = (securitySettings['enable_signup'] == '1');
            await StorageService.setEnableSignup(enableSignup);
          }
        }
      }
    } catch (e) {
      print("Error fetching enable_signup: $e");
    }
  }

  Future<void> fetchPurchase() async {
    try {
      var apiResponse = await GuestService.systemsettings();
      if (apiResponse is Map && apiResponse.containsKey('data')) {
        var data = apiResponse['data'];

        if (data.containsKey('general_settings')) {
          var generalSettings = data['general_settings'];

          if (generalSettings.containsKey('can_buy')) {
            bool canPurchase = (generalSettings['can_buy'] == '1');
            await StorageService.setCanPurchase(canPurchase);
          }
        }
      }
    } catch (e) {
      print("Error fetching can_buy: $e");
    }
  }

  Future<void> fetchSystemSettings() async {
    print("Fetching system settings...");

    final response = await GuestService.systemsettings();
    print("System settings response: $response");

    await GuestService.config();
    print("GuestService.config() called");

    if (response != null && response['success'] == true) {
      var data = response['data'];
      print("Received data: $data");

      if (data.containsKey('general_settings')) {
        var generalSettings = data['general_settings'];
        print("General settings: $generalSettings");

        if (generalSettings.containsKey('user_multi_currency')) {
          var rawValue = generalSettings['user_multi_currency'];
          bool userMultiCurrency = (rawValue == 1 || rawValue == '1');

          print("User Multi Currency Raw Value: $rawValue");
          print("Parsed User Multi Currency: $userMultiCurrency");

          await StorageService.setUserMultiCurrency(userMultiCurrency);
          print("User multi-currency setting saved: $userMultiCurrency");
        } else {
          print("Key 'user_multi_currency' not found in general settings");
        }
        if (generalSettings.containsKey('whatsapp_floating_button')) {
          String whatsappNumber = generalSettings['whatsapp_floating_button'];

          print("WhatsApp Floating Button Number: $whatsappNumber");

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('whatsapp_floating_button', whatsappNumber);

          print("WhatsApp number saved to SharedPreferences: $whatsappNumber");
        } else {
          print("Key 'whatsapp_floating_button' not found in general settings");
        }
      } else {
        print("Key 'general_settings' not found in response data");
      }
    } else {
      print("Failed to fetch system settings or response is null/unsuccessful");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          return Container(
            color: backgroundColorAnimation.value, // Background color transition
            child: Center(
              child: Transform.translate(
                offset: logoPositionAnimation.value * MediaQuery.of(context).size.height,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Expanding Logo
                    Container(
                      width: logoSizeAnimation.value,
                      height: logoSizeAnimation.value,
                      decoration: BoxDecoration(
                        color: Colors.transparent, // Keep white background for contrast
                        shape: BoxShape.circle, // Circular shape
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          AppAssets.splashPng, // Your logo
                          width: 100,
                          height: 100,
                        ),
                      ),
                    ),

                    // Spinner (Appears when animation ends)
                    if (showSpinner)
                      SizedBox(
                        width: logoSizeAnimation.value + 40, // Slightly larger than logo
                        height: logoSizeAnimation.value + 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 4,
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

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
