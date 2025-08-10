import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/authentication_page/login_page.dart';
import 'package:webinar/app/pages/main_page/categories_page/categories_page.dart';
import 'package:webinar/app/pages/main_page/home_page/certificates_page/certificates_page.dart';
import 'package:webinar/app/pages/main_page/home_page/assignments_page/assignments_page.dart';
import 'package:webinar/app/pages/main_page/home_page/financial_page/financial_page.dart';
import 'package:webinar/app/pages/main_page/home_page/meetings_page/meetings_page.dart';
import 'package:webinar/app/pages/main_page/home_page/setting_page/setting_page.dart';
import 'package:webinar/app/pages/main_page/main_page.dart';
import 'package:webinar/app/providers/app_language_provider.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/storage_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/common/database/app_database.dart';
import 'package:webinar/common/enums/error_enum.dart';
import 'package:webinar/common/enums/page_name_enum.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

import '../../pages/main_page/home_page/comments_page/comments_page.dart';
import '../../pages/main_page/home_page/dashboard_page/dashboard_page.dart';
import '../../pages/main_page/home_page/favorites_page/favorites_page.dart';
import '../../pages/main_page/home_page/quizzes_page/quizzes_page.dart';
import '../../pages/main_page/home_page/subscription_page/subscription_page.dart';
import '../../pages/main_page/home_page/support_message_page/support_message_page.dart';
import '../../services/guest_service/guest_service.dart';

class MainDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const MainDrawer({super.key, required this.scaffoldKey});

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  String token = '';
  bool showCurrencySelector = false;
  Map<String, dynamic> systemSettings = {};
  double profileCardHeight = 280.0; // Reduce initial height
  File? localImage;

  @override
  void initState() {
    super.initState();
    getToken();
  }


  Future<void> getToken() async {
    final value = await AppData.getAccessToken();

    if (mounted) {
      setState(() {
        token = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppLanguageProvider, UserProvider>(
      builder: (context, provider, userProvider, _) {
        getToken();

        return Container(
          width: MediaQuery.of(context).size.width * 0.70,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Profile Section
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Background Pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: DrawerPatternPainter(),
                        ),
                      ),
                      // Profile Content
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 80,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (hasAccess()) {
                                            nextRoute(SettingPage.pageName);
                                          } else {
                                            nextRoute(LoginPage.pageName);
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: CircleAvatar(
                                                radius: 22,
                                                backgroundColor: Colors.white,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(22),
                                                  child: localImage == null
                                                      ? fadeInImage(
                                                          (locator<UserProvider>().profile?.avatar) ?? '',
                                                          44,
                                                          44)
                                                      : Image.file(localImage!,
                                                          width: 44,
                                                          height: 44,
                                                          fit: BoxFit.cover),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    locator<UserProvider>().profile?.fullName ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'View Profile',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    loginButton(),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 40),
                                child: _languageAndCurrencyMenu(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Menu Items
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    _buildMenuItem(
                      appText.home,
                      AppAssets.homeSvg,
                      Colors.blue,
                      () {
                        if (locator<PageProvider>().page != PageNames.home) {
                          locator<PageProvider>().setPage(PageNames.home);
                        }
                        widget.scaffoldKey.currentState?.closeDrawer();
                      },
                    ),
                    _buildMenuItem(
                      appText.dashboard,
                      AppAssets.dashboardSvg,
                      Colors.purple,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(DashboardPage.pageName);
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.classes,
                      AppAssets.classesSvg,
                      Colors.green,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          if (locator<PageProvider>().page != PageNames.myClasses) {
                            locator<PageProvider>().setPage(PageNames.myClasses);
                          }
                          widget.scaffoldKey.currentState?.closeDrawer();
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.meetings,
                      AppAssets.meetingsSvg,
                      Colors.pink,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(MeetingsPage.pageName);
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.assignments,
                      AppAssets.assignmentsSvg,
                      Colors.deepPurple,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(AssignmentsPage.pageName);
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.category,
                      AppAssets.categorySvg,
                      Colors.orange,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(CategoriesPage.pageName);
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.quizzes,
                      AppAssets.quizzesSvg,
                      Colors.red,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(QuizzesPage.pageName);
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.certificates,
                      AppAssets.certificatesSvg,
                      Colors.teal,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(CertificatesPage.pageName);
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.favorites,
                      AppAssets.favoritesSvg,
                      Colors.amber,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(FavoritesPage.pageName);
                        }
                      },
                    ),
                    _buildMenuItem(
                      appText.support,
                      AppAssets.supportSvg,
                      Colors.indigo,
                      () {
                        if (hasAccess(canRedirect: true)) {
                          nextRoute(SupportMessagePage.pageName);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String name, String iconPath, Color color, Function onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTap(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    color,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageAndCurrencyMenu(BuildContext context) {
    bool showCurrency = StorageService.getUserMultiCurrency();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!showCurrency)
          Expanded(child: _menuButton(context, true))
        else ...[
          Expanded(child: _menuButton(context, true)),
          const SizedBox(width: 12),
          Expanded(child: _menuButton(context, false)),
        ],
      ],
    );
  }

    Widget _menuButton(BuildContext context, bool isLanguage) {
    return GestureDetector(
      onTap: () async {
        if (isLanguage) {
          await MainWidget.showLanguageDialog();
        } else {
          MainWidget.showCurrencyDialog();
        }
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            isLanguage
                ? ClipOval(
                    child: Image.asset(
                      '${AppAssets.flags}${locator<AppLanguage>().currentLanguage}.png',
                      width: 14,
                      height: 14,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.attach_money_rounded, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                isLanguage
                    ? locator<AppLanguage>()
                            .appLanguagesData[locator<AppLanguage>()
                                .appLanguagesData
                                .indexWhere((element) =>
                                    element.code!.toLowerCase() ==
                                    locator<AppLanguage>()
                                        .currentLanguage
                                        .toLowerCase())]
                            .name ??
                        ''
                    : CurrencyUtils.getSymbol(CurrencyUtils.userCurrency),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey.shade500,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  bool hasAccess({bool canRedirect = false}) {
    if (token.isEmpty) {
      showSnackBar(ErrorEnum.alert, appText.youHaveNotAccess);
      if (canRedirect) {
        nextRoute(LoginPage.pageName, isClearBackRoutes: true);
      }
      return false;
    } else {
      return true;
    }
  }

  Widget loginButton() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

      child: GestureDetector(
        onTap: () async {
          if (token.isNotEmpty) {
            // Show loading dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return Dialog(
                  backgroundColor: Colors.transparent,
                  child: Container(
                    width: 300,
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
                        Image.asset(AppAssets.logoPng, width: 90, height: 90),
                        SizedBox(height: 20),
                        SpinKitThreeBounce(color: Colors.blueAccent, size: 15.0),
                        SizedBox(height: 20),
                        Text(
                          appText.mayTakeSeconds,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            // Perform logout operations
            UserService.logout();
            AppData.saveAccessToken('');
            AppDataBase.clearBox();
            locator<UserProvider>().clearAll();
            locator<AppLanguageProvider>().changeState();
            await Future.delayed(const Duration(seconds: 3));

            if (context.mounted) Navigator.of(context).pop();
            widget.scaffoldKey.currentState?.closeDrawer();

            nextRoute(LoginPage.pageName, isClearBackRoutes: true);
          } else {
            // Navigate to login directly
            AppData.saveAccessToken('');
            nextRoute(LoginPage.pageName, isClearBackRoutes: true);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              token.isEmpty
                  ? SvgPicture.asset(
                AppAssets.loginArrow,
                width: 24,
                height: 30,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              )
                  : Container(),
              const SizedBox(width: 8),
              Baseline(
                baseline: 20,
                baselineType: TextBaseline.alphabetic,
              ),
              const SizedBox(width: 8),
              token.isNotEmpty
                  ? SvgPicture.asset(
                AppAssets.loginArrow,
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height * 1.2,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
