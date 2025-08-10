import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/providers_page/providers_page.dart';
import 'package:webinar/app/providers/CategoryDataManagerProvider.dart';
import 'package:webinar/app/providers/page_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/cart_service.dart';
import 'package:webinar/app/services/user_service/rewards_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/main_widget.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/database/app_database.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

import '../../../common/data/app_language.dart';
import '../../../common/enums/page_name_enum.dart';
import '../../models/course_model.dart';
import '../../providers/CourseDataManagerProvider.dart';
import '../../providers/app_language_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/FloatingActionButtonMenu.dart';
import 'classes_page/classes_page.dart';
import 'home_page/home_page.dart';
import 'home_page/search_page/suggested_search_page.dart';
import 'home_page/setting_page/setting_page.dart';

class MainPage extends StatefulWidget {
  static const String pageName = '/main';

  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late Future<int> future;
  String? token;

  List<List<CourseModel>> allCourseLists = [];

  int _selectedIndex = 0; // Track the selected index

  final List<Widget> screens = const [
    HomePage(),
    SuggestedSearchPage(),
    ClassesPage(),
    ProvidersPage()
  ];

  @override
  void initState() {
    super.initState();

    future = Future<int>(() {
      return 0;
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      AppDataBase.getCoursesAndSaveInDB();
    });

    getData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CourseDataManagerProvider>(context, listen: false).getData();
      Provider.of<CategoryDataManagerProvider>(context, listen: false)
          .fetchData();
    });
  }

  getData() {
    CourseService.getReasons();

    AppData.getAccessToken().then((String value) {
      if (value.isNotEmpty) {
        RewardsService.getRewards();
        CartService.getCart();
        UserService.getAllNotification();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    }

    return Consumer<AppLanguageProvider>(
      builder: (context, appLanguageProvider, _) {
        bool isRTL = locator<AppLanguage>().currentLanguage == 'ar';

        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Consumer2<UserProvider, PageProvider>(
            builder: (context, userProvider, pageProvider, _) {
              return PopScope(
                canPop: false,
                onPopInvoked: (v) {
                  if (v) {
                    if (locator<PageProvider>().page == PageNames.home) {
                      MainWidget.showExitDialog();
                    } else {
                      locator<PageProvider>().setPage(PageNames.home);
                      _selectedIndex = 0;
                    }
                  }
                },
                child: Scaffold(
                  floatingActionButton: Padding(
                    padding: const EdgeInsets.only(bottom: 70),
                    child: FloatingActionButtonMenu(),
                  ),
                  floatingActionButtonLocation: isRTL
                      ? FloatingActionButtonLocation.startFloat
                      : FloatingActionButtonLocation.endFloat,
                  resizeToAvoidBottomInset: false,
                  backgroundColor: primaryColor,
                  body: Consumer<PageProvider>(
                    builder: (context, pageProvider, _) {
                      return SafeArea(
                        bottom: !kIsWeb && Platform.isAndroid,
                        top: false,
                        child: Scaffold(
                          backgroundColor: Colors.transparent,
                          resizeToAvoidBottomInset: false,
                          extendBody: true,
                          body: PageView(
                            controller: pageProvider.pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedIndex = index;
                                pageProvider.setPage(PageNames.values[index]);
                              });
                            },
                            children: screens,
                          ),
                          bottomNavigationBar: Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: GNav(
                                rippleColor: primaryColor.withOpacity(0.3),
                                hoverColor: Colors.grey.shade700,
                                haptic: true,
                                tabBorderRadius: 16,
                                curve: Curves.easeIn,
                                duration: const Duration(milliseconds: 300),
                                gap: 8,
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                color: Colors.grey,
                                activeColor: primaryColor,
                                iconSize: 24,
                                tabBackgroundColor: primaryColor.withOpacity(0.1),
                                backgroundColor: Colors.transparent,
                                tabs: [
                                  GButton(
                                    icon: Icons.add_circle_outline,
                                    leading: SvgPicture.asset(
                                      AppAssets.homeNavBarSvg,
                                      width: 30,
                                      height: 30,
                                    ),
                                    text: appText.home,
                                  ),
                                  GButton(
                                    icon: Icons.circle,
                                    leading: SvgPicture.asset(
                                      AppAssets.searchNavBarSvg,
                                      width: 30,
                                      height: 30,
                                    ),
                                    text: appText.search,
                                  ),
                                  GButton(
                                    icon: Icons.circle,
                                    leading: SvgPicture.asset(
                                      AppAssets.coursesSvg,
                                      width: 30,
                                      height: 30,
                                    ),
                                    text: appText.courses,
                                  ),
                                  GButton(
                                    icon: Icons.circle,
                                    leading: SvgPicture.asset(
                                      AppAssets.providersNavBarSvg,
                                      width: 30,
                                      height: 30,
                                    ),
                                    text: appText.providers,
                                  ),
                                ],
                                onTabChange: (index) {
                                  setState(() {
                                    _selectedIndex = index;
                                    pageProvider.pageController.jumpToPage(index);
                                    pageProvider.setPage(PageNames.values[index]);
                                  });
                                },
                                selectedIndex: _selectedIndex,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}