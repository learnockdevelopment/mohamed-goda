import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:webinar/app/pages/main_page/categories_page/filter_category_page/filter_category_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'package:webinar/app/pages/main_page/home_page/subscription_page/subscription_page.dart';
import 'package:webinar/app/providers/drawer_provider.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/app/services/user_service/user_service.dart';
import 'package:webinar/app/widgets/main_widget/home_widget/home_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_data.dart';
import 'package:webinar/common/shimmer_component.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import '../../../../common/enums/error_enum.dart';
import '../../../../common/utils/currency_utils.dart';
import '../../../../locator.dart';
import '../../../models/course_model.dart';
import '../../../models/subscription_model.dart';
import '../../../providers/app_language_provider.dart';
import '../../../../common/components.dart';
import '../../../providers/filter_course_provider.dart';
import '../../../providers/CategoryDataManagerProvider.dart';
import '../../../services/user_service/subscription_service.dart';
import '../../../widgets/main_widget/main_drawer.dart';
import '../../authentication_page/login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String token = '';
  String name = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController searchController = TextEditingController();
  FocusNode searchNode = FocusNode();

  late AnimationController appBarController;
  late Animation<double> appBarAnimation;

  double appBarHeight = 230;

  ScrollController scrollController = ScrollController();

  PageController sliderPageController = PageController();
  int currentSliderIndex = 0;

  PageController adSliderPageController = PageController();
  int currentAdSliderIndex = 0;

  bool isLoadingFeaturedListData = false;
  List<CourseModel> featuredListData = [];

  bool isLoadingNewsetListData = false;
  List<CourseModel> newsetListData = [];

  bool isLoadingBestRatedListData = false;
  List<CourseModel> bestRatedListData = [];

  bool isLoadingBestSellingListData = false;
  List<CourseModel> bestSellingListData = [];

  bool isLoadingDiscountListData = false;
  List<CourseModel> discountListData = [];

  bool isLoadingFreeListData = false;
  List<CourseModel> freeListData = [];

  bool isLoadingBundleData = false;
  List<CourseModel> bundleData = [];

  bool isLoadingSubscriptionData = false;
  SubscriptionModel? subscriptionData;

  @override
  void initState() {
    super.initState();

    getToken();

    appBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    appBarAnimation = Tween<double>(
      begin: 70 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
      end: 70 + MediaQuery.of(navigatorKey.currentContext!).viewPadding.top,
    ).animate(appBarController);

    scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ModalRoute.of(context)!.settings.arguments != null) {
        if (AppData.canShowFinalizeSheet) {
          AppData.canShowFinalizeSheet = false;

          // finalize signup
          HomeWidget.showFinalizeRegister(
              (ModalRoute.of(context)!.settings.arguments as int))
              .then((value) {
            if (value) {
              getToken();
            }
          });
        }
      }

      // Initialize category data
      Provider.of<CategoryDataManagerProvider>(context, listen: false).fetchData();
    });

    getData();
  }

  @override
  void deactivate() {
    // Stop animations when widget is deactivated (e.g., during navigation)
    appBarController.stop();
    super.deactivate();
  }

  void _scrollListener() {
    if (!mounted) return;

    if (scrollController.position.pixels > 100) {
      if (!appBarController.isAnimating) {
        if (appBarController.status == AnimationStatus.dismissed) {
          appBarController.forward();
        }
      }
    } else if (scrollController.position.pixels < 50) {
      if (!appBarController.isAnimating) {
        if (appBarController.status == AnimationStatus.completed) {
          appBarController.reverse();
        }
      }
    }
  }

  void getData() async {
    if (!mounted) return;

    setState(() {
      isLoadingFeaturedListData = true;
      isLoadingNewsetListData = true;
      isLoadingBundleData = true;
      isLoadingBestRatedListData = true;
      isLoadingBestSellingListData = true;
      isLoadingDiscountListData = true;
      isLoadingFreeListData = true;
      isLoadingSubscriptionData = true;
    });

    try {
      // Load all course data in parallel
      final results = await Future.wait([
        CourseService.featuredCourse(),
        CourseService.getAll(offset: 0, bundle: true),
        CourseService.getAll(offset: 0, sort: 'newest'),
        CourseService.getAll(offset: 0, sort: 'best_rates'),
        CourseService.getAll(offset: 0, sort: 'bestsellers'),
        CourseService.getAll(offset: 0, discount: true),
        CourseService.getAll(offset: 0, free: true),
        SubscriptionService.getSubscription(),
      ], eagerError: false);

      if (!mounted) return;

      setState(() {
        featuredListData = results[0] as List<CourseModel>;
        bundleData = results[1] as List<CourseModel>;
        newsetListData = results[2] as List<CourseModel>;
        bestRatedListData = results[3] as List<CourseModel>;
        bestSellingListData = results[4] as List<CourseModel>;
        discountListData = results[5] as List<CourseModel>;
        freeListData = results[6] as List<CourseModel>;
        subscriptionData = results[7] as SubscriptionModel?;

        // Update loading states
        isLoadingFeaturedListData = false;
        isLoadingBundleData = false;
        isLoadingNewsetListData = false;
        isLoadingBestRatedListData = false;
        isLoadingBestSellingListData = false;
        isLoadingDiscountListData = false;
        isLoadingFreeListData = false;
        isLoadingSubscriptionData = false;
      });
    } catch (error) {
      if (!mounted) return;
      
      // Handle errors gracefully
      setState(() {
        isLoadingFeaturedListData = false;
        isLoadingBundleData = false;
        isLoadingNewsetListData = false;
        isLoadingBestRatedListData = false;
        isLoadingBestSellingListData = false;
        isLoadingDiscountListData = false;
        isLoadingFreeListData = false;
        isLoadingSubscriptionData = false;
      });

      // Show error message to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load data. Please try again.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      
      print('Error loading data: $error');
    }
  }

  void getToken() async {
    if (!mounted) return;

    AppData.getAccessToken().then((value) {
      if (!mounted) return;
      setState(() {
        token = value;
      });

      if (token.isNotEmpty) {
        UserService.getProfile().then((value) async {
          if (!mounted) return;
          if (value != null) {
            await AppData.saveName(value.fullName ?? '');
            getUserName();
          }
        });
      }
    });

    getUserName();
  }

  void getUserName() {
    if (!mounted) return;

    AppData.getName().then((value) {
      if (!mounted) return;
      setState(() {
        name = value;
      });
    });
  }

  @override
  void dispose() {
    // Ensure all controllers are disposed
    if (mounted) {
      scrollController.removeListener(_scrollListener);
      scrollController.dispose();
      sliderPageController.dispose();
      adSliderPageController.dispose();
      searchController.dispose();
      searchNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLanguageProvider>(builder: (context, provider, _) {
      return directionality(child:
      Consumer<DrawerProvider>(builder: (context, drawerProvider, _) {
        return ClipRRect(
          borderRadius:
          borderRadius(radius: drawerProvider.isOpenDrawer ? 20 : 0),
          child: Scaffold(
            key: _scaffoldKey,
            drawer: MainDrawer(
              scaffoldKey: _scaffoldKey,
            ),
            appBar: appbar( 
              title: appText.home,
              isBack: false,
              scaffoldKey: _scaffoldKey,

            ),
            body: Container(
              color: Colors.white,
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: space(30)),
                  // Featured Courses Slider
                  if (featuredListData.isNotEmpty || isLoadingFeaturedListData)
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 32, bottom: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Featured Courses',
                                      style: style24Bold().copyWith(
                                        color: grey33,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    space(4),
                                    Text(
                                      'Handpicked courses for you',
                                      style: style14Regular().copyWith(
                                        color: greyA5,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '${featuredListData.length} Courses',
                                    style: style12Bold().copyWith(
                                      color: primaryColor,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 320,
                            child: PageView.builder(
                              controller: sliderPageController,
                              onPageChanged: (index) {
                                setState(() {
                                  currentSliderIndex = index;
                                });
                              },
                              itemCount: isLoadingFeaturedListData ? 1 : featuredListData.length,
                              itemBuilder: (context, index) {
                                if (isLoadingFeaturedListData) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    child: courseItemVerticallyShimmer(),
                                  );
                                }

                                final course = featuredListData[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(32),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      // Course Image
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.network(
                                              course.image ?? '',
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: greyE7,
                                                  child: Icon(Icons.image_not_supported, color: greyA5, size: 40),
                                                );
                                              },
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.transparent,
                                                    Colors.black.withOpacity(0.7),
                                                    Colors.black.withOpacity(0.9),
                                                  ],
                                                  stops: const [0.0, 0.5, 1.0],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Content
                                      Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: primaryColor.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: primaryColor.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.star_rounded, color: primaryColor, size: 16),
                                                    space(0, width: 8),
                                                    Text(
                                                      'Featured',
                                                      style: style12Bold().copyWith(
                                                        color: primaryColor,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              space(16),
                                              Text(
                                                course.title ?? '',
                                                style: style24Bold().copyWith(
                                                  color: Colors.white,
                                                  height: 1.3,
                                                  letterSpacing: -0.5,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              space(12),
                                              Text(
                                                course.description ?? '',
                                                style: style14Regular().copyWith(
                                                  color: Colors.white.withOpacity(0.9),
                                                  height: 1.5,
                                                  letterSpacing: 0.2,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              space(20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius.circular(30),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.1),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      CurrencyUtils.calculator(course.price),
                                                      style: style16Bold().copyWith(
                                                        color: primaryColor,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: [primaryColor, primaryColor.withOpacity(0.8)],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                      borderRadius: BorderRadius.circular(30),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: primaryColor.withOpacity(0.3),
                                                          blurRadius: 10,
                                                          offset: const Offset(0, 5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons.star_rounded, color: Colors.white, size: 16),
                                                        space(0, width: 8),
                                                        Text(
                                                          course.rate?.toString() ?? '0.0',
                                                          style: style14Bold().copyWith(
                                                            color: Colors.white,
                                                            letterSpacing: 0.2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          space(24),
                          // Page Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              isLoadingFeaturedListData ? 1 : featuredListData.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: currentSliderIndex == index ? 32 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: currentSliderIndex == index ? primaryColor : greyE7,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: currentSliderIndex == index ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ] : null,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Newest Classes Section
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (newsetListData.isNotEmpty || isLoadingNewsetListData) ...{
                          if (newsetListData.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 32, bottom: 20),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        appText.newestClasses,
                                        style: style24Bold().copyWith(color: grey33),
                                      ),
                                      space(4),
                                      Text(
                                        'Discover our latest courses',
                                        style: style14Regular().copyWith(color: greyA5),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${newsetListData.length} Courses',
                                      style: style12Bold().copyWith(color: primaryColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: List.generate(
                                isLoadingNewsetListData ? 3 : newsetListData.length,
                                    (index) {
                                  if (isLoadingNewsetListData) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: courseItemShimmer(),
                                    );
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: _buildVerticalCourseItem(newsetListData[index]),
                                  );
                                },
                              ),
                            ),
                          )
                        }
                      ],
                    ),
                  ),

                  // Bottom padding
                  SliverToBoxAdapter(
                    child: space(150),
                  ),
                ],
              ),
            ),
          ),
        );
      }));
    });
  }

  Widget _buildVerticalCourseItem(CourseModel course) {
    return InkWell(
      onTap: () {
        nextRoute(SingleCoursePage.pageName, arguments: [course.id, course.type == 'bundle']);
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: greyE7, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      course.image ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: greyE7,
                          child: Icon(Icons.image_not_supported, color: greyA5, size: 40),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: greyE7,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: primaryColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ),
                // Price Tag
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Text(
                      course.price == 0
                          ? 'Free'
                          : CurrencyUtils.calculator(course.price ?? 0),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Course Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    course.title ?? '',
                    style: style16Bold().copyWith(
                      color: grey33,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Instructor Row
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: greyE7,
                        ),
                        child: course.teacher?.avatar != null
                            ? ClipOval(
                          child: Image.network(
                            course.teacher!.avatar!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.person, color: greyA5, size: 16);
                            },
                          ),
                        )
                            : Icon(Icons.person, color: greyA5, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          course.teacher?.fullName ?? 'Instructor Name',
                          style: style14Regular().copyWith(color: greyA5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Course Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              course.rate ?? '0.0',
                              style: style14Regular().copyWith(color: greyA5),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.people_alt_rounded, color: greyA5, size: 16),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${course.studentsCount}',
                                style: style14Regular().copyWith(color: greyA5),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, color: greyA5, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${course.duration} Hours',
                            style: style14Regular().copyWith(color: greyA5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
