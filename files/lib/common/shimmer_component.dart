import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/data/app_language.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/locator.dart';

// Enhanced shimmer with better colors and animation
Widget enhancedShimmer({
  required Widget child,
  Color? baseColor,
  Color? highlightColor,
  Duration duration = const Duration(milliseconds: 1500),
}) {
  return Shimmer.fromColors(
    baseColor: baseColor ?? Color(0xffeff1ee).withOpacity(0.4),
    highlightColor: highlightColor ?? Color(0xffeff1ee).withOpacity(0.8),
    period: duration,
    child: child,
  );
}

// Enhanced shimmer with gradient effect
Widget gradientShimmer({
  required Widget child,
  List<Color>? colors,
  Duration duration = const Duration(milliseconds: 2000),
}) {
  return Shimmer.fromColors(
    baseColor: colors?.first ?? Color(0xffeff1ee).withOpacity(0.3),
    highlightColor: colors?.last ?? Color(0xffeff1ee).withOpacity(0.7),
    period: duration,
    child: child,
  );
}

// Enhanced course item shimmer for vertical layout
Widget courseItemVerticallyShimmer() {
  return enhancedShimmer(
    child: Container(
      margin: const EdgeInsetsDirectional.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: padding(horizontal: 16, vertical: 16),
      width: getSize().width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Enhanced image placeholder
          Container(
            width: 135,
            height: 85,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Enhanced details
          Expanded(
            child: SizedBox(
              height: 85,
              child: Padding(
                padding: padding(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Enhanced title
                    Container(
                      height: 12,
                      width: getSize().width * 0.5,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),

                    // Enhanced subtitle
                    Container(
                      height: 10,
                      width: getSize().width * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),

                    // Enhanced price and date row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 10,
                          width: getSize().width * 0.35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        Container(
                          height: 10,
                          width: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// Enhanced course item shimmer for horizontal layout
Widget courseItemShimmer({
  bool isSmallSize = true,
  double width = 158.0,
  double height = 200.0,
  double endCardPadding = 16.0,
  bool isShowReward = false,
}) {
  return enhancedShimmer(
    child: Container(
      margin: EdgeInsetsDirectional.only(end: endCardPadding),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Enhanced image placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: width,
              height: 100,
              color: Colors.white,
            ),
          ),

          // Enhanced details
          Expanded(
            child: Padding(
              padding: padding(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  space(16),

                  // Enhanced title
                  Container(
                    width: width,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  space(12),

                  // Enhanced subtitle
                  Container(
                    width: width / 3,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),

                  const Spacer(),

                  // Enhanced price
                  Container(
                    width: width / 2,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),

                  space(12),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// New: Enhanced featured course shimmer
Widget featuredCourseShimmer() {
  return gradientShimmer(
    colors: [
      Color(0xffeff1ee).withOpacity(0.3),
      Color(0xffeff1ee).withOpacity(0.6),
      Color(0xffeff1ee).withOpacity(0.3),
    ],
    child: Container(
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
      height: 320,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced image placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
            ),
          ),
          
          // Enhanced content area
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced badge
                Container(
                  width: 80,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                
                space(16),
                
                // Enhanced title
                Container(
                  height: 20,
                  width: getSize().width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                
                space(12),
                
                // Enhanced description
                Container(
                  height: 16,
                  width: getSize().width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                
                space(20),
                
                // Enhanced bottom row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
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
  );
}

// New: Enhanced category shimmer
Widget categoryShimmer() {
  return enhancedShimmer(
    child: Container(
      width: 120,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          space(8),
          Container(
            width: 60,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ],
      ),
    ),
  );
}

// New: Enhanced search bar shimmer
Widget searchBarShimmer() {
  return enhancedShimmer(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
    ),
  );
}

// New: Enhanced section header shimmer
Widget sectionHeaderShimmer() {
  return enhancedShimmer(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              space(8),
              Container(
                width: 200,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          Container(
            width: 80,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Shimmer widget specifically for video or image placeholder.
Widget videoImageShimmer({
  Color? baseColor,
  Color? highlightColor,
  double borderRadius = 12.0,
}) {
  return Shimmer.fromColors(
    baseColor: baseColor ?? Colors.grey[300]!,
    highlightColor: highlightColor ?? Colors.grey[100]!,
    child: Container(
      width: double.infinity,
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
  );
}

Widget singleCourseShimmer({
  double borderRadius = 12.0,
}) {
  return Shimmer.fromColors(
    baseColor: primaryColor.withOpacity(0.1),
    highlightColor: primaryColor.withOpacity(0.05),
    child: Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for special offer
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          SizedBox(height: 14),

          // Title placeholder
          Container(
            width: double.infinity,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          SizedBox(height: 8),

          // Rating row
          Row(
            children: [
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              SizedBox(width: 4),
              Container(
                width: 30,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ],
          ),
          SizedBox(height: 18),

          // Video or image placeholder
          Container(
            width: double.infinity,
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          SizedBox(height: 24),

          // Teacher profile row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Cashback helper box placeholder
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),

          SizedBox(height: 24),

          // Tabs placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 70,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              Container(
                width: 70,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              Container(
                width: 70,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              Container(
                width: 70,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget classesCourseItemShimmer() {
  return Shimmer.fromColors(
      baseColor: primaryColor.withOpacity(0.1),
      highlightColor: primaryColor.withOpacity(0.05),
      child: Container(
        margin: const EdgeInsetsDirectional.only(bottom: 16),
        decoration: BoxDecoration(borderRadius: borderRadius()),
        padding: padding(horizontal: 10, vertical: 9),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // course details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                shimmerUi(height: 85, width: 130),

                // details
                Expanded(
                  child: SizedBox(
                    height: 85,
                    child: Padding(
                      padding: padding(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // title
                          shimmerUi(height: 8, width: getSize().width * .4),

                          // name and date and time
                          shimmerUi(height: 8, width: 60),

                          // price and date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // date
                              shimmerUi(height: 8, width: 70),

                              // price
                              Row(
                                children: [
                                  shimmerUi(height: 8, width: 20),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            space(24),

            // category and publish date
            Row(
              children: [
                // category
                Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerUi(height: 8, width: 70),
                        space(6),
                        shimmerUi(height: 8, width: 70),
                      ],
                    )),

                // Publish Date
                Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerUi(height: 8, width: 70),
                        space(6),
                        shimmerUi(height: 8, width: 70),
                      ],
                    )),
              ],
            ),

            space(24),

            // progress
            shimmerUi(height: 8, width: getSize().width),

            space(12),
          ],
        ),
      ));
}

Widget blogItemShimmer() {
  return Shimmer.fromColors(
    baseColor: primaryColor.withOpacity(0.1),
    highlightColor: primaryColor.withOpacity(0.05),
    child: Container(
      width: getSize().width,
      padding: padding(horizontal: 10, vertical: 10),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: borderRadius(radius: 15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          shimmerUi(height: 200, width: getSize().width, radius: 10),

          space(16),

          // title
          shimmerUi(height: 8, width: getSize().width * .6),

          space(20),

          // desc
          shimmerUi(height: 8, width: getSize().width),

          space(8),

          // desc
          shimmerUi(height: 8, width: getSize().width),

          space(8),

          // desc
          shimmerUi(height: 8, width: getSize().width * .3),

          space(24),

          Row(
            children: [
              shimmerUi(height: 8, width: 50),
              space(0, width: 20),
              shimmerUi(height: 8, width: 50),
            ],
          )
        ],
      ),
    ),
  );
}

Widget userProfileCardShimmer() {
  return Shimmer.fromColors(
    baseColor: primaryColor.withOpacity(0.1),
    highlightColor: primaryColor.withOpacity(0.05),
    child: Container(
      width: 155,
      height: 195,
      padding: padding(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(borderRadius: borderRadius()),
      child: Column(
        children: [
          // meet status
          Align(
              alignment: AlignmentDirectional.centerEnd,
              child: shimmerUi(height: 22, width: 22, radius: 50)),

          Expanded(
            child: Column(
              children: [
                shimmerUi(height: 70, width: 70, radius: 100),
                const Spacer(flex: 1),
                shimmerUi(height: 8, width: getSize().width * .2),
                space(6),
                shimmerUi(height: 8, width: getSize().width * .3),
                space(12),
                shimmerUi(height: 8, width: getSize().width * .2),
                const Spacer(flex: 2),
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget horizontalCategoryItemShimmer() {
  return Shimmer.fromColors(
    baseColor: primaryColor.withOpacity(0.1),
    highlightColor: primaryColor.withOpacity(0.05),
    child: Container(
      width: getSize().width * .7,
      margin: const EdgeInsetsDirectional.only(end: 16),
      padding: padding(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: borderRadius(radius: 15),
      ),
      child: Row(
        children: [
          shimmerUi(height: 65, width: 65, radius: 6),
          space(0, width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              shimmerUi(
                height: 8,
                width: 100,
              ),
              space(10),
              shimmerUi(
                height: 8,
                width: 50,
              ),
            ],
          )
        ],
      ),
    ),
  );
}

Widget categoryItemShimmer() {
  return Shimmer.fromColors(
    baseColor: primaryColor.withOpacity(0.1),
    highlightColor: primaryColor.withOpacity(0.05),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Row(
        children: [
          shimmerUi(height: 34, width: 34, radius: 30),
          space(0, width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              shimmerUi(height: 8, width: getSize().width * .3),
              space(8),
              shimmerUi(height: 8, width: getSize().width * .2),
            ],
          ),
          const Spacer(),
          AnimatedRotation(
            turns: locator<AppLanguage>().isRtl() ? 180 / 360 : 0,
            duration: const Duration(milliseconds: 200),
            child: SvgPicture.asset(AppAssets.arrowRightSvg),
          )
        ],
      ),
    ),
  );
}

Widget shimmerUi(
    {required double height, required double width, double radius = 15}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: primaryColor.withOpacity(0.1),
      borderRadius: borderRadius(radius: radius),
    ),
  );
}
