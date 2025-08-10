import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webinar/app/models/register_config_model.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/error_handler.dart';
import 'package:webinar/common/utils/http_handler.dart';
import 'package:http/http.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:webinar/config/assets.dart';
import '../../../common/utils/app_text.dart';

class AuthenticationService {
  static Future<bool> login(
      BuildContext context, String username, String password) async {
    // Validate password
    if (password.length < 6) {
      _showErrorDialog(context, {
        'title': 'Weak Password',
        'message': 'Password must be at least 6 characters long.',
      });
      return false;
    }
    try {
      String url = '${Constants.baseUrl}login';
      String deviceId = await getDeviceId();

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent accidental dismiss
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
                  // Stack to overlay spinner around the logo
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated Spinner around the logo
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                          strokeWidth: 5.0,
                        ),
                      ),
                      // Circular App Logo Avatar
                      CircleAvatar(
                        radius: 35, // Adjust size inside spinner
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

                  // Loading Text
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



      // Make the API call with a timeout
      Response res = await httpPost(url, {
        'username': username,
        'password': password,
        'device_id': deviceId,
      });

      // Close the loading dialog
      if (Navigator.canPop(context)) Navigator.pop(context);

      // print('Response Status: ${res.statusCode}');
      // print('Response Body: ${res.body}');

      var jsonResponse = jsonDecode(res.body);

      if (jsonResponse['success']) {
        // Save user details and return success
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        int userId = jsonResponse['data']['user_id'];
        await AppData.saveUserId(userId);
        return true;
      } else if (jsonResponse['status'] == 'invalid_credentials') {
        // Handle invalid username or password
        _showErrorDialog(context, {
          'title': 'Login Failed',
          'message': 'Invalid email or password. Please try again.',
        });
      } else if (jsonResponse['status'] == 'device_mismatch') {
        // Handle device mismatch error
        _showErrorDialog(context, {
          'title': 'Device Mismatch',
          'message':
              'This device is not allowed to login, Please Use Your First Device Used Or Contact Support.',
        });
      } else {
        // Handle other errors
        _showErrorDialog(context, {
          'title': 'Login Failed',
          'message': jsonResponse['message'] ?? 'Unable to login.',
        });
      }
      return false;
    } on SocketException catch (_) {
      // Close the loading dialog and show network error
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showErrorDialog(context, {
        'title': 'No Network',
        'message': 'Please check your internet connection and try again.',
      });
      return false;
    } on TimeoutException catch (_) {
      // Close the loading dialog and show timeout error
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showErrorDialog(context, {
        'title': 'Timeout',
        'message': 'The request timed out. Please try again later.',
      });
      return false;
    } catch (e) {
      // Close the loading dialog and show unexpected error
      if (Navigator.canPop(context)) Navigator.pop(context);
      // print('Unexpected error: $e');
      _showErrorDialog(context, {
        'title': 'Error',
        'message': 'Unexpected error: $e',
      });
      return false;
    }
  }

  static void _showErrorDialog(BuildContext context, Map jsonResponse) {
    // If a dialog is already open, dismiss it before showing a new one
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    String title = "Error"; // Default title
    String content =
        "An unexpected error occurred. Please try again later."; // Default content

    // Check for specific error scenarios in the response
    if (jsonResponse['message'] == 'auth.incorrect') {
      title = "Authentication Failed";
      content = "Invalid username or password. Please try again.";
    } else if (jsonResponse['status'] == 'device_mismatch') {
      title = "Device Mismatch";
      content =
      "This device is not allowed to log in. Please use your first registered device or contact support.";
    } else if (jsonResponse['message'] != null) {
      content = jsonResponse['message'];
    }

    // Show enhanced error dialog
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental dismissal
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Smooth rounded corners
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Error Icon
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(18),
                  child: Icon(Icons.error_outline, color: Colors.red, size: 55),
                ),
                SizedBox(height: 15),

                // Error Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                // Error Message
                Text(
                  content,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
                SizedBox(height: 20),

                // Button Row
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

  static Future<bool> google(
      BuildContext context, String email, String token, String name) async {
    try {
      String url = '${Constants.baseUrl}google/callback';
      String deviceId = await getDeviceId();
      String deviceType = Platform.isAndroid
          ? 'Android'
          : Platform.isIOS
              ? 'iOS'
              : 'Web';

      // Prepare the request body
      Map<String, String> body = {
        'email': email,
        'name': name,
        'id': token,
        'device_id': deviceId,
        'device_type': deviceType,
      };

      print("Sending request to: $url");
      print("Request body: $body");

      // Make the HTTP POST request
      Response res = await httpPost(url, body);

      print("Response Status: ${res.statusCode}");
      print("Response Body: ${res.body}");

      var responseData = jsonDecode(res.body);

      if (responseData['success'] == false &&
          responseData['status'] == 'device_mismatch') {
        print("Device mismatch error: $responseData");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showErrorDialog(context, responseData);
          }
        });

        return false;
      }

      if (res.statusCode == 200) {
        print("Login successful!");
        await AppData.saveAccessToken(responseData['data']['token']);
        int userId = responseData['data']['user_id'];
        print("User ID: $userId");

        await AppData.saveUserId(userId);
        return true;
      } else {
        print("Authentication failed with status code: ${res.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error in google authentication: $e");
      return false;
    }
  }

  static Future<Map?> registerWithEmail(
      String registerMethod,
      String email,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields) async {
    try {
      String url = '${Constants.baseUrl}register/step/1';

      Map body = {
        "register_method": registerMethod,
        "country_code": null,
        'email': email,
        'password': password,
        'password_confirmation': repeatPassword,
      };

      if (fields != null) {
        Map bodyFields = {};
        for (var i = 0; i < fields.length; i++) {
          if (fields[i].type != 'upload') {
            bodyFields.addEntries({
              fields[i].id: (fields[i].type == 'toggle')
                  ? fields[i].userSelectedData == null
                      ? 0
                      : 1
                  : fields[i].userSelectedData
            }.entries);
          }
        }

        body.addEntries({'fields': bodyFields.toString()}.entries);
      }

      Response res = await httpPost(url, body);

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success'] ||
          jsonResponse['status'] == 'go_step_2' ||
          jsonResponse['status'] == 'go_step_3') {
        return {
          'user_id': jsonResponse['data']['user_id'],
          'step': jsonResponse['status']
        };
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map?> registerWithPhone(
      String registerMethod,
      String countryCode,
      String mobile,
      String password,
      String repeatPassword,
      String? accountType,
      List<Fields>? fields) async {
    // try{
    String url = '${Constants.baseUrl}register/step/1';

    Map body = {
      "register_method": registerMethod,
      "country_code": countryCode,
      'mobile': mobile,
      'password': password,
      'password_confirmation': repeatPassword,
    };

    if (fields != null) {
      Map bodyFields = {};
      for (var i = 0; i < fields.length; i++) {
        if (fields[i].type != 'upload') {
          bodyFields.addEntries({
            fields[i].id: (fields[i].type == 'toggle')
                ? fields[i].userSelectedData == null
                    ? 0
                    : 1
                : fields[i].userSelectedData
          }.entries);
        }
      }

      body.addEntries({'fields': bodyFields.toString()}.entries);
    }

    Response res = await httpPost(url, body);

    ////printres.body);

    var jsonResponse = jsonDecode(res.body);
    if (jsonResponse['success'] ||
        jsonResponse['status'] == 'go_step_2' ||
        jsonResponse['status'] == 'go_step_3') {
      // || stored

      return {
        'user_id': jsonResponse['data']['user_id'],
        'step': jsonResponse['status']
      };
    } else {
      ErrorHandler().showError(ErrorEnum.error, jsonResponse);
      return null;
    }

    // }catch(e){
    //   return null;
    // }
  }

  static Future<bool> forgetPassword(String email) async {
    try {
      String url = '${Constants.baseUrl}forget-password';

      Response res = await httpPost(url, {"email": email});

      // log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        ErrorHandler()
            .showError(ErrorEnum.success, jsonResponse, readMessage: true);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> verifyCode(int userId, String code) async {
    try {
      String url = '${Constants.baseUrl}register/step/2';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "code": code,
      });

      // log(res.body.toString());

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> registerStep3(
      int userId, String name, String referralCode) async {
    try {
      String url = '${Constants.baseUrl}register/step/3';

      Response res = await httpPost(url, {
        "user_id": userId.toString(),
        "full_name": name,
        "referral_code": referralCode
      });

      var jsonResponse = jsonDecode(res.body);
      if (jsonResponse['success']) {
        await AppData.saveAccessToken(jsonResponse['data']['token']);
        await AppData.saveName(name);
        return true;
      } else {
        ErrorHandler().showError(ErrorEnum.error, jsonResponse);
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id; // Unique Android ID
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ??
          'Unknown Device ID'; // Unique iOS ID
    } else {
      return 'Unknown Device ID'; // Fallback for other platforms
    }
  }
}
