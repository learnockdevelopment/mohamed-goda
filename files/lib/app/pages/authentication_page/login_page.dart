import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webinar/app/pages/authentication_page/register_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/authentication_service/authentication_service.dart';
import 'package:webinar/app/widgets/authentication_widget/register_widget/register_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/api_public_data.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/locator.dart';

import '../../../common/utils/app_text.dart';
import '../../../config/assets.dart';
import '../../../config/colors.dart';
import '../../widgets/authentication_widget/country_code_widget/code_country.dart';

class LoginPage extends StatefulWidget {
  static const String pageName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController mailController = TextEditingController();
  FocusNode mailNode = FocusNode();
  TextEditingController passwordController = TextEditingController();
  FocusNode passwordNode = FocusNode();
  bool isSendingData = false; // Track whether data is being sent
  String? errorMessage; // Hold the error message if any

  String? otherRegisterMethod;
  bool isEmptyInputs = true;
  bool isPhoneNumber = true;
  bool isLoading = true;
  bool isPasswordVisible = false;

  CountryCode countryCode = CountryCode(
      code: "EGY",
      dialCode: "+20",
      flagUri: "${AppAssets.flags}eg.png",
      name: "Egypt");

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Simulate fetching data or fetch actual data here
        await Future.delayed(Duration(seconds: 2));
        if (mounted) {
          setState(() {
            isLoading = false; // Update loading state when done
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    });

    if ((PublicData.apiConfigData?['register_method'] ?? '') == 'email') {
      isPhoneNumber = false; // Default to email
      otherRegisterMethod = 'email';
    } else {
      isPhoneNumber = true; // Default to phone
      otherRegisterMethod = 'phone'; // Set default method to phone
    }

    // Add listener to mailController
    mailController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty) {
          if (isEmptyInputs) {
            isEmptyInputs = false;
            setState(() {});
          }
        } else {
          if (!isEmptyInputs) {
            isEmptyInputs = true;
            setState(() {});
          }
        }
      }
    });
    // Add listener to passwordController
    passwordController.addListener(() {
      if (mounted) {
        if ((mailController.text.trim().isNotEmpty) &&
            passwordController.text.trim().isNotEmpty) {
          if (isEmptyInputs) {
            isEmptyInputs = false;
            setState(() {});
          }
        } else {
          if (!isEmptyInputs) {
            isEmptyInputs = true;
            setState(() {});
          }
        }
      }
    });
  }

  Widget _buildToggleButton(String text, String method) {
    bool isSelected = (otherRegisterMethod == method);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            otherRegisterMethod = method;
            isPhoneNumber = method == 'phone';
            mailController.clear();
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
              colors: [Colors.deepPurple, Colors.purple.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null, // No gradient for unselected state
            color: isSelected ? null : Colors.transparent, // Transparent when not selected
            borderRadius: BorderRadius.circular(25), // Softer round edges
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildAnimatedPhoneField() {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: isPhoneNumber ? _buildPhoneField() : _buildEmailField(),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      children: [
        // Country Code Selector
        GestureDetector(
          onTap: () async {
            CountryCode? newData = await RegisterWidget.showCountryDialog();
            if (newData != null) {
              setState(() {
                countryCode = newData;
              });
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15), // More rounded edges
              border: Border.all(color: Colors.grey.shade300),
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50), // Ensure round edges
              child: Image.asset(
                countryCode.flagUri ?? '',
                width: 24,
                height: 22,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12), // Improved spacing
        Expanded(
          child: input(
            mailController,
            mailNode,
            appText.phoneNumber,

            isNumber: true,
            iconPathLeft: AppAssets.phoneSvg,
            leftIconSize: 16, // Adjusted size
            leftIconColor: Color(0xff6E6E6E),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return input(
      mailController,
      mailNode,
      appText.email,
      iconPathLeft: AppAssets.mailSvg,
      leftIconSize: 16, // Adjusted size for better visibility
      leftIconColor: Color(0xff6E6E6E),
    );
  }

  Widget _buildPasswordField() {
    return input(
      passwordController,
      passwordNode,
      appText.password,
      iconPathLeft: AppAssets.passwordSvg,
      leftIconSize: 16, // Adjusted icon size
      leftIconColor: Color(0xff6E6E6E),
      isPassword: true,
      isPasswordVisible: isPasswordVisible,
      togglePasswordVisibility: () {
        setState(() {
          isPasswordVisible = !isPasswordVisible;
        });
      },
    );
  }

  Widget _buildGoogleSignInButton(
      BuildContext context, Function(GoogleSignInAccount?) onSignIn) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: green77(), // Custom color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22), // Rounded corners
          ),
          padding: EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: () async {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  width: 320,
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blueAccent),
                              strokeWidth: 5.0,
                            ),
                          ),
                          CircleAvatar(
                            radius: 35,
                            backgroundColor: Colors.white,
                            child: ClipOval(
                              child: Image.asset(
                                AppAssets.logoPng,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        appText.mayTakeSeconds,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          try {
            print("Google Sign-In started...");

            final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

            if (gUser == null) {
              print("Google sign-in canceled by user.");
              Navigator.pop(context);
              return;
            }

            print("Google user signed in: ${gUser.email}");

            final GoogleSignInAuthentication gAuth = await gUser.authentication;

            if (gAuth.accessToken == null) {
              print("Google Authentication failed.");
              Navigator.pop(context);
              return;
            }

            print("Access Token received: ${gAuth.accessToken}");

            bool res = await AuthenticationService.google(
              context,
              gUser.email,
              gAuth.accessToken ?? '',
              gUser.displayName ?? '',
            );

            if (!res) {
              print("Authentication failed.");
              Navigator.pop(context);
              return;
            }

            int? userId = await AppData.getUserId();

            if (userId == null) {
              print("User ID not found in shared preferences.");
              Navigator.pop(context);
              return;
            }

            print('Retrieved User ID: $userId');

            Navigator.pop(context);

            locator<PageProvider>().setPage(PageNames.home);
            nextRoute(MainPage.pageName, isClearBackRoutes: true);
          } catch (e) {
            print("Error during Google Sign-In: $e");
            Navigator.pop(context);
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              appText.googleSign,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 10), // Space between icon and text

            SvgPicture.asset(
              AppAssets.googleSvg, // SVG Icon
              width: 24,
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _signUp() {
    return SizedBox(
      width: double.infinity,
      child: button(
        onTap: () async {
          nextRoute(RegisterPage.pageName, isClearBackRoutes: true);
        },
        width:
            MediaQuery.of(context).size.width * 0.9, // 90% of the screen width
        height: 52,
        text: appText.signup,
        fontSize: 16,
        bgColor: green77(),
        textColor: Colors.white,
        borderColor: Colors.transparent,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: button(
        onTap: () async {
          FocusScope.of(context).unfocus();

          String emailOrPhone = mailController.text.trim();

          // Phone number validation (basic check)
          bool isPhoneNumberValid = isPhoneNumber
              ? RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(emailOrPhone)
              : true;

          // Email validation
          bool isEmailValid =
              RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(emailOrPhone);

          if (emailOrPhone.isNotEmpty &&
              passwordController.text.trim().isNotEmpty) {
            if (isPhoneNumber && !isPhoneNumberValid) {
              // Show error for invalid phone number format
              _showErrorDialog(context, 'Invalid mobile number format.');
              return;
            } else if (!isPhoneNumber && !isEmailValid) {
              // Show error for invalid email format
              _showErrorDialog(context, 'Invalid email format.');
              return;
            }

            setState(() {
              isSendingData = true;
            });

            bool res = await AuthenticationService.login(
              context,
              '${isPhoneNumber ? countryCode.dialCode!.replaceAll('+', '') : ''}$emailOrPhone',
              passwordController.text.trim(),
            );

            setState(() {
              isSendingData = false;
            });

            if (res) {
              // Retrieve the user ID from shared preferences
              int? userId =
                  await AppData.getUserId(); // Fetch the stored user ID

              if (userId != null) {
                // Proceed if the user ID exists
                // print('Retrieved User ID: $userId');
                locator<PageProvider>().setPage(PageNames.home);
                nextRoute(MainPage.pageName, isClearBackRoutes: true);
              } else {
                // print(
                //     'User ID not found in shared preferences.');
              }
            }
          } else {
            // Handle empty input error
            _showErrorDialog(context, 'Please fill in all fields.');
          }
        },
        width:
            MediaQuery.of(context).size.width * 0.9, // 90% of the screen width
        height: 52,
        text: appText.login,
        bgColor: isEmptyInputs ? greyCF : green77(),
        textColor: Colors.white,
        borderColor: Colors.transparent,
      ),
    );
  }

  Widget _buildDividerWithText(String text) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade400)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade400)),
      ],
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(15),
                  child: Icon(Icons.error_outline, color: Colors.red, size: 50),
                ),
                SizedBox(height: 15),

                // Title
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                SizedBox(height: 10),

                // Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 20),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        nextRoute(MainPage.pageName, isClearBackRoutes: true);
        return false;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.purple.shade900, Colors.purple.shade400],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ✅ Circular Avatar with SVG Logo
                  CircleAvatar(
                    radius: 50, // Circle size
                    backgroundColor:
                        Colors.white, // Background color for contrast
                    child: ClipOval(
                      child: SvgPicture.asset(
                        AppAssets.splashLogoSvg, // Ensure it's correctly linked
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain, // Ensures the image scales inside
                      ),
                    ),
                  ),

                  SizedBox(height: 15), // Space between logo and form

                  // ✅ White Form Container
                  Container(
                    width: 360, // Optimal width
                    padding: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),

                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Take Tour Link
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, MainPage.pageName);
                            },
                            child: Text(
                              appText.takeTour,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          SizedBox(height: 30),

                          // Toggle Buttons
                          AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade200], // Soft gradient effect
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300, width: 1.5),

                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildToggleButton(appText.email, 'email'),

                                _buildToggleButton(appText.phone, 'phone'),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Input Fields
                          isPhoneNumber
                              ? _buildAnimatedPhoneField()
                              : _buildEmailField(),

                          SizedBox(height: 18),

                          // Password Field
                          _buildPasswordField(),

                          SizedBox(height: 25),

                          // Login Button
                          _buildLoginButton(),

                          SizedBox(height: 20),

                          // OR Divider
                          _buildDividerWithText(appText.or),

                          SizedBox(height: 20),
                          _signUp(),
                          SizedBox(height: 20),

                          // Google Sign-In Button
                          _buildGoogleSignInButton(context,
                              (GoogleSignInAccount? account) {
                            if (account != null) {
                              print("User signed in: ${account.email}");
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Remove listeners in dispose() to prevent memory leaks
    mailController.removeListener(() {});
    passwordController.removeListener(() {});

    // Dispose controllers and focus nodes
    mailController.dispose();
    mailNode.dispose();
    passwordController.dispose();
    passwordNode.dispose();

    super.dispose();
  }

  socialWidget(String icon, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: 98,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius(radius: 16),
        ),
        child: SvgPicture.asset(
          icon,
          width: 30,
        ),
      ),
    );
  }
}
