import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webinar/app/models/blog_model.dart';
import 'package:webinar/app/models/forum_answer_model.dart';
import 'package:webinar/app/models/forum_model.dart';
import 'package:webinar/app/models/profile_model.dart';
import 'package:webinar/app/models/user_model.dart';
import 'package:webinar/app/pages/main_page/home_page/cart_page/cart_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/forum_page/forum_answer_page.dart';
import 'package:webinar/app/pages/main_page/home_page/single_course_page/single_course_page.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/forum_service.dart';
import 'package:webinar/common/utils/constants.dart';
import 'package:webinar/common/utils/download_manager.dart';
import 'package:webinar/common/utils/utils.dart';
import '../app/pages/authentication_page/login_page.dart';
import '../app/pages/main_page/home_page/notification_page.dart';
import '../app/pages/main_page/providers_page/providers_filter.dart';
import '../app/providers/app_language_provider.dart';
import '../app/providers/drawer_provider.dart';
import '../app/widgets/main_widget/home_widget/single_course_widget/learning_widget.dart';
import '../app/widgets/main_widget/main_widget.dart';
import '../app/widgets/qr.dart';
import 'badges.dart';
import 'common.dart';
import 'data/app_data.dart';
import 'enums/course_enum.dart';
import 'enums/error_enum.dart';
import 'utils/app_text.dart';
import 'utils/course_utils.dart';
import 'utils/currency_utils.dart';
import 'utils/date_formater.dart';
import '../config/assets.dart';
import '../config/colors.dart';
import '../config/styles.dart';
import '../app/models/course_model.dart';

Widget courseSliderItem(CourseModel courseData, {int horizontalPadding = 20}) {
    return GestureDetector(
      onTap: () {
        nextRoute(SingleCoursePage.pageName,
            arguments: [courseData.id, courseData.type == 'bundle']);
      },
      child: Container(
        padding: padding(horizontal: horizontalPadding.toDouble()),
        width: getSize().width,
        height: 215,
        child: ClipRRect(
          borderRadius: borderRadius(),
          child: Stack(
            children: [
              // image
              fadeInImage(courseData.image ?? '', getSize().width, 215),

              // details
              Container(
                width: getSize().width,
                height: 215,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Colors.black.withOpacity(.8),
                  Colors.black.withOpacity(0),
                  Colors.black.withOpacity(0),
                ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                child: Column(
                  children: [
                    // price
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: Container(
                        margin: padding(horizontal: 12, vertical: 12),
                        padding: padding(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: borderRadius(radius: 10),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(.05),
                                  offset: const Offset(0, 3),
                                  blurRadius: 10)
                            ]),
                        child: Text(
                          (courseData.price == 0)
                              ? appText.free
                              : CurrencyUtils.calculator(courseData.price ?? 0),
                          style: style14Regular().copyWith(color: primaryColor),
                        ),
                      ),
                    ),

                    const Spacer(),

                    Padding(
                      padding: padding(horizontal: 9, vertical: 9),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: getSize().width,
                            child: Text(
                              courseData.title ?? '',
                              style:
                                  style16Bold().copyWith(color: Colors.white),
                            ),
                          ),

                          space(4),

                          ratingBar(double.parse(courseData.rate ?? '0')
                              .round()
                              .toString()),

                          space(10),

                          // info
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: borderRadius(radius: 50),
                                child: fadeInImage(
                                    courseData.teacher?.avatar ?? '', 20, 20),
                              ),
                              space(0, width: 4),
                              Text(
                                courseData.teacher?.fullName ?? '',
                                style: style10Regular()
                                    .copyWith(color: Colors.white),
                              ),
                              space(0, width: 12),
                              SvgPicture.asset(AppAssets.timeSvg),
                              space(0, width: 4),
                              Text(
                                '${durationToString(courseData.duration ?? 0)} ${appText.hours}',
                                style: style10Regular()
                                    .copyWith(color: Colors.white),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
}
Widget courseSliderItemShimmer() {
  return Shimmer.fromColors(
    baseColor: greyE7,
    highlightColor: greyF8,
    child: Container(
      padding: padding(),
      width: getSize().width,
      height: 215,
      child: ClipRRect(
          borderRadius: borderRadius(),
          child: Container(
            width: getSize().width,
            height: 215,
            color: Colors.white,
          )),
    ),
  );
}

Widget courseItem(CourseModel courseData,
    {bool isSmallSize = false,
      double width = 220.0,
      double height = 190.0,
      double endCardPadding = 15.0,
      bool isShowReward = false}) {
  if (!isSmallSize) {
    width = 240;
    height = 330;
  }
  return Container(
    clipBehavior: Clip.hardEdge,
    margin: EdgeInsetsDirectional.only(end: endCardPadding),
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: secondaryColor.withOpacity(0.2),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 5),
        ),
      ],
      // color: Colors.black,
      gradient: LinearGradient(
        colors: [
          Colors.black,
          Colors.black,
          Colors.black,
          secondaryColor.withOpacity(0.99),
          secondaryColor
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: GestureDetector(
      onTap: () {
        nextRoute(SingleCoursePage.pageName,
            arguments: [courseData.id, courseData.type == 'bundle']);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(15)),
                child: fadeInImage(
                  courseData.image ?? '',
                  width,
                  isSmallSize ? 100 : 140,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(AppAssets.starYellowSvg, width: 14),
                      const SizedBox(width: 4),
                      Text(
                        courseData.rate ?? '',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              if (CourseUtils.checkType(courseData) == CourseType.live)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _addToCalendar(courseData),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: SvgPicture.asset(AppAssets.notificationSvg,
                          width: 16, color: primaryColor2),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                height: isSmallSize ? 70 : 170, // Set the desired height
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      courseData.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.profileSvg,
                            width: 14, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(
                          courseData.teacher?.fullName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                        ),
                        // Expanded(
                        //   child:
                        // ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (!isSmallSize) const SizedBox(height: 10),
                    if (!isSmallSize)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${courseData.duration} ${appText.duration}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                '${courseData.studentsCount} ${appText.students}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ],
                      ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if ((courseData.discountPercent ?? 0) > 0)
                          Text(
                            CurrencyUtils.calculator(
                              (courseData.price ?? 0) -
                                  ((courseData.price ?? 0) *
                                      (courseData.discountPercent ?? 0) ~/
                                      100),
                            ),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                        Text(
                          courseData.price == 0
                              ? appText.free
                              : CurrencyUtils.calculator(courseData.price ?? 0),
                          style: TextStyle(
                            fontSize: ((courseData.discountPercent ?? 0) > 0 &&
                                isSmallSize)
                                ? 10
                                : 14,
                            // color in colors file 14,
                            fontWeight: FontWeight.w600,
                            color: (courseData.discountPercent ?? 0) > 0
                                ? Colors.red
                                : primaryColor,
                            // color in colors file
                            decoration: (courseData.discountPercent ?? 0) > 0
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: Colors
                                .white, // Apply white color to the line-through
                          ),
                        ),
                      ],
                    ),
                    if (!isSmallSize)
                      const SizedBox(
                        height: 10,
                      ),
                    if (!isSmallSize)
                      button(
                          onTap: () {
                            nextRoute(SingleCoursePage.pageName, arguments: [
                              courseData.id,
                              courseData.type == 'bundle'
                            ]);
                          },
                          width: getSize().width,
                          height: 35,
                          text: appText.enrollOnClass,
                          bgColor: primaryColor,
                          textColor: Colors.white,
                          borderColor: Colors.transparent,
                          textFontWeight: FontWeight.bold,
                          boxShadow: boxShadow(primaryColor.withOpacity(.3)),
                          raduis: 16)
                  ],
                ),
              )),
        ],
      ),
    ),
  );
}

void _addToCalendar(CourseModel courseData) {
  // Calendar event logic extracted to simplify widget
  try {
    DateTime start = DateTime.fromMillisecondsSinceEpoch(
        (courseData.startDate ?? 0) * 1000,
        isUtc: true);
    DateTime end = start.add(Duration(minutes: courseData.duration ?? 60));

    final Event event = Event(
      title: courseData.title ?? '',
      description: appText.webinar,
      startDate: start,
      endDate: end,
    );
    Add2Calendar.addEvent2Cal(event);
  } catch (e) {}
}

// Widget courseItem(CourseModel courseData,{bool isSmallSize=true,double width = 200.0,height = 185.0,double endCardPadding=15.0, bool isShowReward=false}){
//
//
//   if(!isSmallSize){
//     width = 220;
//     height = 240;
//   }
//
//
//
//   return Container(
//     clipBehavior: Clip.hardEdge,
//     decoration: const BoxDecoration(),
//     margin: EdgeInsetsDirectional.only(end: endCardPadding),
//     width: width,
//     height: height,
//
//     child: GestureDetector(
//       onTap: (){
//         nextRoute(SingleCoursePage.pageName, arguments: [courseData.id, courseData.type == 'bundle']);
//       },
//       behavior: HitTestBehavior.opaque,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//
//           // image
//           ClipRRect(
//             borderRadius: borderRadius(radius: 15),
//             child: Stack(
//               children: [
//
//                 fadeInImage(
//                   courseData.image ?? '',
//                   width,
//                   isSmallSize ? 100 : 140
//                 ),
//
//                 // rate and notification and progress
//                 Container(
//                   width: width,
//                   height: isSmallSize ? 100 : 140,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [
//                         Colors.black.withOpacity(.4),
//                         Colors.black.withOpacity(0),
//                         Colors.black.withOpacity(0),
//                       ],
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter
//                     )
//                   ),
//
//                   child: Column(
//                     children: [
//
//                       // rate
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//
//                           // rate
//                           Container(
//                             margin: const EdgeInsetsDirectional.only(
//                               start: 8,
//                               end: 8,
//                               bottom: 2,
//                               top: 8
//                             ),
//                             // margin: padding(horizontal: 8,vertical: 8),
//                             padding: padding(horizontal: 8,vertical: 6),
//
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: borderRadius(radius: 10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(.05),
//                                   offset: const Offset(0, 3),
//                                   blurRadius: 10
//                                 )
//                               ]
//                             ),
//
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SvgPicture.asset(AppAssets.starYellowSvg,width: 13,),
//
//                                 space(0,width: 2),
//
//                                 Text(
//                                   courseData.rate ?? '',
//                                   style: style12Regular(),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//
//                           if(CourseUtils.checkType(courseData) == CourseType.live)...{
//                             GestureDetector(
//                               onTap: () async {
//                                 try{
//
//                                   DateTime start = DateTime(
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).year,
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).month,
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).day,
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).hour,
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).minute,
//                                   );
//                                   DateTime end = DateTime(
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).year,
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).month,
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).day,
//                                     DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).hour,
//                                     (DateTime.fromMillisecondsSinceEpoch((courseData.startDate ?? 0) * 1000, isUtc: true).minute + (courseData.duration ?? 0)),
//                                   );
//
//                                   final Event event = Event(
//                                     title: courseData.title ?? '',
//                                     description: appText.webinar,
//                                     startDate: start,
//                                     endDate: end,
//                                     iosParams: const IOSParams(),
//                                     androidParams: const AndroidParams(),
//                                   );
//
//                                   Add2Calendar.addEvent2Cal(event);
//
//                                 }catch(e){}
//                               },
//                               behavior: HitTestBehavior.opaque,
//                               child: Container(
//                                 margin: const EdgeInsetsDirectional.only(
//                                   start: 8,
//                                   end: 8,
//                                   bottom: 2,
//                                   top: 8
//                                 ),
//                                 width: 28,
//                                 height: 28,
//
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: borderRadius(radius: 8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(.05),
//                                       offset: const Offset(0, 3),
//                                       blurRadius: 20
//                                     )
//                                   ]
//                                 ),
//
//                                 alignment: Alignment.center,
//                                 child: SvgPicture.asset(AppAssets.notificationSvg,colorFilter: ColorFilter.mode(primaryColor2, BlendMode.srcIn),width: 12,),
//                               )
//                             ),
//                           }
//                         ],
//                       ),
//
//
//                       const Spacer(),
//
//
//
//                       if(courseData.badges?.isNotEmpty ?? false)...{
//
//                         Align(
//                           alignment: AlignmentDirectional.centerStart,
//                           child: Container(
//                             margin: padding(horizontal: 8),
//                             padding: padding(horizontal: 6,vertical: 4),
//
//                             decoration: BoxDecoration(
//                               color: getColorFromRGBString(courseData.badges!.first.badge?.background ?? ''),
//                               borderRadius: borderRadius(radius: 10),
//                             ),
//
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//
//                                 if(courseData.badges!.first.badge?.icon != null)...{
//                                   SvgPicture.network(
//                                     '${Constants.dommain}${courseData.badges!.first.badge?.icon ?? ''}',
//                                     width: 16,
//                                   ),
//
//                                   space(0,width: 2),
//
//                                 }else...{
//                                   space(0,width: 2),
//                                 },
//
//                                 Text(
//                                   courseData.badges!.first.badge?.title ?? '',
//                                   style: style12Regular().copyWith(
//                                     color: courseData.badges!.first.badge != null ? Color(int.parse(courseData.badges!.first.badge!.color!.substring(1, 7), radix: 16) + 0xFF000000) : null
//                                   ),
//                                 ),
//
//                                 space(0,width: 2),
//                               ],
//                             ),
//                           ),
//                         ),
//
//                         space(7),
//
//                       }else...{
//
//                         if (CourseUtils.checkType(courseData) == CourseType.live)...{
//
//                           // progress
//                           Padding(
//                             padding: padding(horizontal: 8,vertical: 8),
//                             child: LayoutBuilder(
//                               builder: (context, constraints) {
//                                 return Container(
//                                   width: constraints.maxWidth,
//                                   height: 4.5,
//                                   padding: padding(horizontal: 1.5),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: borderRadius()
//                                   ),
//                                   alignment: AlignmentDirectional.centerStart,
//
//                                   child: Container(
//                                     width: constraints.maxWidth * ( (courseData.studentsCount ?? 1) / (courseData.capacity ?? 1) ),
//                                     height: 2,
//                                     decoration: BoxDecoration(
//                                       color: yellow29,
//                                       borderRadius: borderRadius()
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           )
//
//                         },
//                       },
//
//                     ],
//                   ),
//                 )
//
//
//
//
//               ],
//             ),
//           ),
//
//           // details
//           Expanded(
//             child: Padding(
//               padding: padding(horizontal: 4),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//
//                   space(10),
//
//                   // title
//                   Text(
//                     courseData.title ?? '',
//                     style: style14Bold().copyWith(height: 1.3),
//                     maxLines: 2,
//                   ),
//
//                   const Spacer(),
//                   const Spacer(),
//
//                   // name and date and time
//                   SizedBox(
//                     width: width,
//                     child: Row(
//                       children: [
//
//                         SizedBox(
//                           width: (width / 2.3),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               SvgPicture.asset(AppAssets.profileSvg),
//
//                               space(0,width: 4),
//
//                               Expanded(
//                                 child: Text(
//                                   courseData.teacher?.fullName ?? '',
//                                   style: style10Regular().copyWith(color: greyB2),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//
//                               space(0,width: 8),
//                             ],
//                           ),
//                         ),
//
//                         if(CourseUtils.checkType(courseData) == CourseType.live)...{
//                           if(courseData.startDate != null)...{
//                             Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 SvgPicture.asset(AppAssets.calendarSvg),
//
//                                 space(0,width: 4),
//
//                                 Text(
//                                   DateTime.fromMillisecondsSinceEpoch(courseData.startDate! *  1000, isUtc: true).toDate(),
//                                   style: style10Regular().copyWith(color: greyB2),
//                                 ),
//
//                               ],
//                             ),
//                           }
//
//                         }else if(CourseUtils.checkType(courseData) == CourseType.video)...{
//
//                           Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               SvgPicture.asset(AppAssets.timeSvg,colorFilter: ColorFilter.mode(greyB2, BlendMode.srcIn)),
//
//                               space(0,width: 4),
//
//                               Text(
//                                 '${durationToString(courseData.duration ?? 0)} ${appText.hours}',
//                                 style: style10Regular().copyWith(color: greyB2),
//                               ),
//
//                             ],
//                           ),
//
//                         },
//
//                       ],
//                     ),
//                   ),
//
//                   const Spacer(),
//
//                   // price and type
//                   SizedBox(
//                     width: width,
//                     child: Row(
//                       children: [
//
//                         if(isShowReward)...{
//                           Text(
//                             courseData.points?.toString() ?? '-',
//                             style: style14Regular().copyWith(color: yellow29),
//                           )
//                         }else...{
//
//                           Text(
//                             (courseData.price == 0)
//                               ? appText.free
//                               : CurrencyUtils.calculator(courseData.price ?? 0),
//                             style: style12Regular().copyWith(
//                               color: (courseData.discountPercent ?? 0) > 0 ? greyCF : primaryColor,
//                               decoration: (courseData.discountPercent ?? 0) > 0 ? TextDecoration.lineThrough : TextDecoration.none,
//                               decorationColor: (courseData.discountPercent ?? 0) > 0 ? greyCF : primaryColor,
//                             ),
//                           ),
//                         },
//
//                         if((courseData.discountPercent ?? 0) > 0)...{
//                           space(0,width: 8),
//
//                           Text(
//                             CurrencyUtils.calculator(
//                               (courseData.price ?? 0) - ((courseData.price ?? 0) * (courseData.discountPercent ?? 0) ~/ 100)
//                             ),
//                             style: style14Regular().copyWith(
//                               color: primaryColor,
//                             ),
//                           ),
//                         },
//
//                         const Spacer(),
//
//                         if((courseData.discountPercent ?? 0) > 0)...{
//                           Badges.off((courseData.discountPercent ?? 0).toString())
//
//                         }else if(CourseUtils.checkType(courseData) == CourseType.live)...{
//                           Badges.liveClass(),
//
//                         }else if(courseData.label == 'Course')...{
//                           Badges.course(),
//
//                         }else if(courseData.label == 'Finished')...{
//                           Badges.finished(),
//
//                         }else if(courseData.label == 'In Progress')...{
//                           Badges.inProgress(),
//
//                         }else if(courseData.label == 'Text course')...{
//                           Badges.textClass(),
//
//                         }else if(courseData.label == 'Not conducted')...{
//                           Badges.notConducted(),
//                         }
//
//
//                       ],
//                     ),
//                   ),
//
//                   // const Spacer(),
//
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
//
// }

Widget courseItemVertically(CourseModel courseData,
    {bool isSmallSize = true,
      double height = 240,
      double bottomMargin = 16,
      bool ignoreTap = false,
      bool isShowReward = false,
      double imageHeight = 140}) {
  final isLive = CourseUtils.checkType(courseData) == CourseType.live;
  final hasDiscount = (courseData.discountPercent ?? 0) > 0;
  final isFree = courseData.price == 0;
   return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => !ignoreTap
            ? nextRoute(SingleCoursePage.pageName,
            arguments: [courseData.id, courseData.type == 'bundle'])
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    height: imageHeight,
                    child: fadeInImage(courseData.image ?? '', 135, imageHeight),
                    foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Badges and Actions
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (hasDiscount)
                              _buildDiscountBadge(courseData.discountPercent!),
                            if (isLive) _buildCalendarButton(courseData),
                          ],
                        ),
                        const Spacer(),
                        if (courseData.badges?.isNotEmpty ?? false)
                          _buildCourseBadge(courseData.badges!.first),
                        if (isLive) _buildCapacityProgress(courseData),
                      ],
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
                    courseData.title ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Instructor Row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: isSmallSize ? 12 : 14,
                        backgroundImage: courseData.teacher?.avatar != null
                            ? NetworkImage(courseData.teacher!.avatar!)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          courseData.teacher?.fullName ?? 'Instructor Name',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isSmallSize ? 12 : 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 8),

                      // Rating and Students
                      Row(
                        children: [
                          Icon(IconlyLight.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            courseData.rate ?? '4.5',
                          ),
                          const SizedBox(width: 16),
                          Icon(IconlyLight.user2, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${courseData.studentsCount}',
                          ),
                        ],
                      ),
                    ],
                  ),


                  const SizedBox(height: 16),

                  // Price and Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPriceSection(courseData, isFree, hasDiscount),
                      _buildDateSection(courseData, isLive),
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
Widget _buildCourseBadge(CustomBadges badge) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: getColorFromRGBString(badge.badge?.background ?? ''),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badge.badge?.icon != null)
          SvgPicture.network(
            '${Constants.dommain}${badge.badge?.icon}',
            width: 16,
            color: getColorFromRGBString(badge.badge?.color ?? ''),
          ),
        const SizedBox(width: 6),
        Text(
          badge.badge?.title ?? '',
          style: TextStyle(
            color: getColorFromRGBString(badge.badge?.color ?? ''),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildCapacityProgress(CourseModel courseData) {
  final progress = (courseData.studentsCount ?? 0) / (courseData.capacity ?? 1);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${(progress * 100).toStringAsFixed(0)}% Filled',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 4),
      Container(
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(2),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: yellow29,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildPriceSection(CourseModel courseData, bool isFree, bool hasDiscount) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (hasDiscount)
        Text(
          CurrencyUtils.calculator(courseData.price ?? 0),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            decoration: TextDecoration.lineThrough,
          ),
        ),
      Text(
        isFree ? 'Free' : CurrencyUtils.calculator(
            hasDiscount
                ? (courseData.price ?? 0) - ((courseData.price ?? 0) * (courseData.discountPercent! / 100))
                : courseData.price ?? 0
        ),
        style: TextStyle(
          color: hasDiscount ? primaryColor : Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}

Widget _buildDateSection(CourseModel courseData, bool isLive) {
  final timestamp = isLive ? courseData.startDate : courseData.createdAt;
  return Row(
    children: [
      Icon(IconlyLight.calendar, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 6),
      Text(
        timestamp != null
            ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toDate()
            : 'N/A',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    ],
  );
}



Widget _buildDiscountBadge(int discountPercent) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.redAccent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      '$discountPercent% OFF',
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _buildCalendarButton(CourseModel courseData) {
  return GestureDetector(
    onTap: () => _addToCalendar(courseData),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(Icons.calendar_today_rounded, size: 18, color: primaryColor2),
    ),
  );
}


Widget input(
  TextEditingController controller,
  FocusNode node,
  String hint, {
  String? iconPathLeft,
  bool isNumber = false,
  bool isCenter = false,
  int letterSpacing = 1,
  bool isReadOnly = false,
  Function? onTap,
  int height = 50,
  bool isPassword = false,
  Function? onTapLeftIcon,
  Function? obscureText,
  int leftIconSize = 8, // Adjusted icon size
  String? Function(String?)? validator,
  bool isError = false,
  Function(String)? onChange,
  int fontSize = 18,
  Color leftIconColor = const Color(0xff6E6E6E),
  double radius = 15,
  int? maxLength,
  bool isBorder = false,
  Color fillColor = Colors.white,
  int? maxLine,
  String? title,
  String? rightIconPath,
  int rightIconSize = 8, // Adjusted icon size
  Function? onTapRightIcon,
  bool? isPasswordVisible,
  Function()? togglePasswordVisibility,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (title != null) ...{
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 6.0).copyWith(top: 10),
          child: Text(
            title,
            style: style12Regular().copyWith(
                color: greyA5, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
      },
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          focusNode: node,
          cursorColor: primaryColor,
          readOnly: isReadOnly,
          onTap: () => onTap?.call(),
          onChanged: (text) => onChange?.call(text),
          validator: validator,
          obscureText: isPassword ? !(isPasswordVisible ?? false) : false,
          style: style14Regular().copyWith(
            letterSpacing: letterSpacing.toDouble(),
            fontSize: fontSize.toDouble(),
            color: Colors.black,
          ),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          textAlign: isCenter ? TextAlign.center : TextAlign.start,
          inputFormatters: [
            LengthLimitingTextInputFormatter(maxLength),
            if (isNumber) FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              vertical:
                  15.0, // Increased vertical padding to move text down more
              horizontal: 15.0, // Horizontal padding remains the same
            ),

            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14, // Change the font size of hint text
              height: 1.5, // This moves the label down by adjusting line height
              color: Colors.grey.shade600, // Change hint text color
              fontFamily: 'Roboto',
            ),

            prefixIcon: iconPathLeft != null
                ? GestureDetector(
                    onTap: () => onTapLeftIcon?.call(),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 7.0),
                      child: SvgPicture.asset(
                        iconPathLeft,
                        width: leftIconSize.toDouble(),
                        height: leftIconSize.toDouble(),
                        color: leftIconColor,
                      ),
                    ),
                  )
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible ?? false
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: togglePasswordVisibility,
                  )
                : rightIconPath != null
                    ? GestureDetector(
                        onTap: () => onTapRightIcon?.call(),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: SvgPicture.asset(
                            rightIconPath,
                            width: rightIconSize.toDouble(),
                            height: rightIconSize.toDouble(),
                          ),
                        ),
                      )
                    : null,

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(radius),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            border: InputBorder.none, // This removes the underline
            focusedBorder:
                InputBorder.none, // This removes the underline when focused
          ),
        ),
      ),
    ],
  );
}

Widget descriptionInput(
    TextEditingController controller, FocusNode node, String hint,
    {String? iconPathLeft,
    bool isNumber = false,
    bool isCenter = false,
    int letterSpacing = 1,
    bool isReadOnly = false,
    Function? onTap,
    int height = 52,
    bool isPassword = false,
    Function? onTapLeftIcon,
    Function? obscureText,
    int leftIconSize = 14,
    String? Function(String?)? validator,
    bool isError = false,
    Function(String)? onChange,
    int fontSize = 14,
    Color leftIconColor = const Color(0xff6E6E6E),
    double radius = 20,
    int? maxLength,
    bool isBorder = false,
    Color fillColor = Colors.white,
    int maxLine = 8}) {
  return Theme(
    data: Theme.of(navigatorKey.currentContext!)
        .copyWith(colorScheme: ColorScheme.light(error: red49)),
    child: TextFormField(
      controller: controller,
      focusNode: node,
      cursorColor: green50,

      maxLines: maxLine,

      readOnly: isReadOnly,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },

      onChanged: (text) {
        if (onChange != null) {
          onChange(text);
        }
      },

      validator: validator,
      obscureText: isPassword,

      style: style14Regular().copyWith(
          letterSpacing: letterSpacing.toDouble(),
          fontSize: fontSize.toDouble(),
          height: 1,
          color: greyB2),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      textAlign: isCenter
          ? TextAlign.center
          : isNumber
              ? TextAlign.end
              : TextAlign.start,

      // autofillHints: const [ AutofillHints.oneTimeCode ],
      inputFormatters: [LengthLimitingTextInputFormatter(maxLength)],
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style14Regular().copyWith(
            letterSpacing: 0, fontSize: 14, color: greyA5, height: 1.3),

        contentPadding: padding(horizontal: 12, vertical: 12),

        // prefixIconConstraints: BoxConstraints.expand(
        //   width: iconPathLeft == null ? 22 : 50
        // ),
        // prefixIcon: iconPathLeft != null
        //   ? GestureDetector(
        //     onTap: () {
        //       if(onTapLeftIcon!=null){
        //         onTapLeftIcon();
        //       }
        //     },
        //     child: Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         space(0,width: 22),

        //         SvgPicture.asset(
        //           iconPathLeft,
        //           width: leftIconSize.toDouble(),
        //         ),

        //       ],
        //     ),
        //   )
        //   : const SizedBox(),

        fillColor: fillColor,
        filled: true,

        border: OutlineInputBorder(
          borderRadius: borderRadius(radius: radius),
          borderSide: BorderSide(
              color: isBorder ? primaryColor.withOpacity(0.3) : Colors.transparent, width: 1),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius(radius: radius),
          borderSide: BorderSide(color: red49, width: 0),
        ),

        focusedErrorBorder: OutlineInputBorder(
            borderRadius: borderRadius(radius: radius),
            borderSide: BorderSide(color: red49, width: 0)),

        enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius(radius: radius),
            borderSide: BorderSide(
                color: isBorder ? primaryColor.withOpacity(0.3) : Colors.transparent, width: 1)),

        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius(radius: radius),
          borderSide: BorderSide(
              color: isBorder ? primaryColor : Colors.transparent, width: 1),
        ),
      ),
    ),
  );
}

Widget horizontalCategoryItem(Color color, String icon, String title,
    String courseCount, Function onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Container(
      width: 150,
      margin: const EdgeInsetsDirectional.only(end: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius(radius: 16),
        gradient: LinearGradient(
          colors: [
            Colors.black,
            Colors.black,
            Colors.black,
            secondaryColor.withOpacity(0.99),
            secondaryColor
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 68,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            alignment: Alignment.center,
            child: Image.network(
              icon,
              fit: BoxFit.contain,
            ),
          ),
          Container(
              padding: padding(
                horizontal: 16,
              ),
              child: Column(
                children: [
                  space(8), // Add some space between the image and text
                  Text(
                    title,
                    style: style14Bold().copyWith(color: Colors.white),
                  ),
                  space(4),
                  Text(
                    '$courseCount ${appText.courses}',
                    style: style12Regular().copyWith(color: Colors.white),
                  ),
                ],
              ))
        ],
      ),
    ),
  );
}

// Widget horizontalCategoryItem(Color color, String icon, String title,
//     String courseCount, Function onTap) {
//
//   return GestureDetector(
//     onTap: () {
//       onTap();
//     },
//     child: Container(
//       width: getSize().width * .7,
//       margin: const EdgeInsetsDirectional.only(end: 16),
//       padding: padding(horizontal: 16, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: borderRadius(radius: 15),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 68,
//             height: 68,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: borderRadius(radius: 8),
//             ),
//             alignment: Alignment.center,
//             child: Image.network(icon, width: 24),
//           ),
//           space(0, width: 16),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 title,
//                 style: style14Bold(),
//               ),
//               space(4),
//               Text(
//                 '$courseCount ${appText.courses}',
//                 style: style12Regular().copyWith(color: greyA5),
//               ),
//             ],
//           )
//         ],
//       ),
//     ),
//   );
// }

Widget horizontalNoticesItem(Color color, String icon, String title,
    String name, String date, Function onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Container(
      width: getSize().width,
      padding: padding(horizontal: 16, vertical: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: borderRadius(radius: 15),
      ),
      child: Row(
        children: [
          // icom
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: color,
              borderRadius: borderRadius(radius: 8),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(icon,
                width: 24,
                colorFilter:
                    const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
          ),

          space(0, width: 16),

          // details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // title
                Text(
                  title,
                  style: style14Bold(),
                ),

                space(12),

                // username and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // user name
                    Row(
                      children: [
                        SvgPicture.asset(AppAssets.profileSvg, width: 11),
                        space(0, width: 4),
                        Text(
                          name,
                          style: style12Regular().copyWith(color: greyA5),
                        ),
                      ],
                    ),

                    // date
                    Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.calendarSvg,
                          width: 8,
                        ),
                        space(0, width: 4),
                        Text(
                          date,
                          style: style12Regular().copyWith(color: greyA5),
                        ),
                      ],
                    ),

                    const SizedBox()
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}

Widget horizontalChapterItem(
    Color color, String icon, String title, String subTitle, Function onTap,
    {double width = 24,
    double height = 24,
    bool isFixWidth = false,
    bool transparentColor = false,
    Color? iconColor}) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Container(
        height: 80,
        width: isFixWidth ? getSize().width : 300,
        margin: EdgeInsetsDirectional.only(end: isFixWidth ? 0 : 16),
        padding: padding(horizontal: 12),
        decoration: BoxDecoration(
          color: transparentColor ? Colors.transparent : Colors.white,
          borderRadius: borderRadius(radius: 15),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color,
                borderRadius: borderRadius(radius: 20),
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                icon,
                width: width,
                height: height,
                colorFilter: iconColor != null
                    ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                    : null,
              ),
            ),
            space(0, width: 16),
            Builder(
              builder: (context) {
                return Expanded(
                  // Wrap this container in an Expanded widget
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: isFixWidth ? getSize().width * .5 : 180,
                        ),
                        child: Text(
                          title,
                          style: style14Bold(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      space(4),
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: getSize().width * .5,
                        ),
                        child: Text(
                          subTitle,
                          style: style12Regular().copyWith(color: greyA5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        )),
  );
}

Widget switchButton(
    String title, bool state, Function(bool value) onChangeState) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: style14Regular().copyWith(color: primaryColor2),
      ),
      GestureDetector(
        onTap: () {
          onChangeState(!state);
        },
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx < 0) {
            onChangeState(true);
          } else {
            onChangeState(false);
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          // for touch
          alignment: Alignment.center,
          height: 25,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 32,
            height: 6,
            clipBehavior: Clip.none,
            decoration: BoxDecoration(
              color: state ? primaryColor : greyE7,
              borderRadius: borderRadius(radius: 30),
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                AnimatedPositionedDirectional(
                  top: -4,
                  end: state ? -2 : 18,
                  bottom: -4,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        color: state ? primaryColor : greyE7,
                        boxShadow: [
                          boxShadow(greyD0.withOpacity(.4), blur: 10, y: 3)
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget radioButton(
    String title, bool state, Function(bool value) onChangeState) {
  return GestureDetector(
    onTap: () {
      onChangeState(!state);
    },
    behavior: HitTestBehavior.opaque,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 6),
              color: state ? primaryColor : greyE7,
              boxShadow: [boxShadow(greyD0.withOpacity(.38), blur: 10, y: 3)]),
        ),
        space(0, width: 8),
        Text(
          title,
          style: style14Regular().copyWith(color: primaryColor2),
        ),
      ],
    ),
  );
}

Widget checkButton(
    String title, bool state, Function(bool value) onChangeState) {
  return GestureDetector(
    onTap: () {
      onChangeState(!state);
    },
    behavior: HitTestBehavior.opaque,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: style14Regular().copyWith(color: primaryColor2),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            borderRadius: borderRadius(radius: 5),
            border: Border.all(
              color: state ? primaryColor : greyCF,
            ),
            color: state ? primaryColor : Colors.white,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(AppAssets.checkSvg),
        ),
      ],
    ),
  );
}
class OutwardNavClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double height = size.height;
    double width = size.width;

    Path path = Path();

// Start from the bottom-left corner
    path.moveTo(0, height);
// Draw up to the top-left, then to the top-right, then down to the bottom-right
    path.lineTo(0, 0);
    path.lineTo(width, 0);
    path.lineTo(width, height);

// Add quadratic bezier curve to create the bottom-riyussufjoght curve
    path.quadraticBezierTo(
      width,
      height - 45, // Control point: 45 units above the bottom
      width - 45,
      height - 45, // End point: 45 units left and 45 units above bottom
    );

// Draw a line to the left side's curve start point
    path.lineTo(45, height - 45);

// Add quadratic bezier curve to create the bottom-left curve
    path.quadraticBezierTo(
      0,
      height - 45, // Control point: 45 units above the bottom on the left
      0,
      height, // End point: back to the bottom-left corner
    );

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
AppBar appbar({
  required String title,
  Function onTapLeftIcon = backRoute,
  String? leftIcon = AppAssets.backSvg,
  bool isBack = true,
  bool isBasket = true,
  bool isNotification = true,
  bool isQr = false,
  bool isFilter = false,
  double? rightWidth,
  Color? background,
  Color? Color,
  GlobalKey<ScaffoldState>? scaffoldKey,
  UserProvider? userProvider,

}) {
  return AppBar(

    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    ),
    titleSpacing: 0,
    backgroundColor:                Colors.white,

    elevation: 0,
    shadowColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    automaticallyImplyLeading: false,
    centerTitle: true,
    toolbarHeight: 140,
    flexibleSpace: ClipPath(
      clipper: OutwardNavClipper(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Container(
          color: primaryColor,
        ),
      ),
    ),

    title: Directionality(
      textDirection: TextDirection.ltr,
      child: Consumer3<DrawerProvider, AppLanguageProvider, UserProvider>(
        builder: (context, drawerProvider, languageProvider, userProvider, _) {
          return FutureBuilder<String>(
            future: AppData.getAccessToken(),
            builder: (context, snapshot) {
              String? token = snapshot.data;

              return Container(
                width: getSize().width,
                margin: EdgeInsets.only(
                  top: (!kIsWeb && Platform.isIOS)
                      ? MediaQuery.of(context).viewPadding.top + 5
                      : MediaQuery.of(context).viewPadding.top + 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left Icon/Profile Avatar
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        bottom: 70.0, // Adjusted to move icon up more
                      ),
                      child: isBack
                          ? MainWidget.menuButton(
                        AppAssets.backSvg,
                        false, // Pass a boolean for enabling/disabling the button
                        Colors.white, // Icon color
                        Colors.black.withOpacity(
                            0.2), // Background color (if needed)
                            () {
                          Navigator.pop(context); // Go to previous page
                        },
                      )
                          : GestureDetector(
                        onTap: () {
                          scaffoldKey?.currentState
                              ?.openDrawer(); // Open drawer
                        },
                        child: ClipRRect(
                          borderRadius: borderRadius(radius: 65),
                          child: MainWidget.menuButton(
                            AppAssets.menuSvg,
                            userProvider.cartData?.items?.isNotEmpty ??
                                false,
                            Colors.white,
                            Colors.black.withOpacity(.2),
                                () {
                              scaffoldKey?.currentState?.openDrawer();
                            },
                          ),
                        ),
                      ),
                    ),
                    // Title (Centered)
                    Flexible(
                      child: Align(
                        alignment: Alignment.center, // Keep title centered
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 70.0, // Adjusted to move icon up more
                          ),
                          child: Text(
                            title,
                            style: style14Regular()
                                .copyWith(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width:15),
                    // Basket & Notification Icons
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 5.0,
                        bottom: 70.0, // Adjusted to move icon up more
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isBasket)
                            MainWidget.menuButton(
                              AppAssets.basketSvg,
                               userProvider.cartData?.items?.isNotEmpty ?? false, // Named parameter if applicable
                               Colors.white, // Ensure menuButton supports this
                               Colors.black.withOpacity(0.2), // Ensure this is correct
                               () {
                                if (token?.isEmpty ?? true) {
                                  nextRoute(LoginPage.pageName);
                                  showSnackBar(ErrorEnum.alert, appText.loginDesc);
                                } else {
                                  nextRoute(CartPage.pageName);
                                }
                              },
                            ),

                          SizedBox(width: 8), // Replace space(0, width: 8) if not a widget

                          if (isNotification)
                            MainWidget.menuButton(
                              AppAssets.notificationSvg,
                               userProvider.notification
                                  .where((element) => element.status == 'unread')
                                  .isNotEmpty,
                               Colors.white,
                               Colors.black.withOpacity(0.2),
                               () {
                                if (token?.isEmpty ?? true) {
                                  nextRoute(LoginPage.pageName);
                                  showSnackBar(ErrorEnum.alert, appText.loginDesc);
                                } else {
                                  nextRoute(NotificationPage.pageName);
                                }
                              },
                            ),

                          SizedBox(width: 8),

                          if (isQr)
                            MainWidget.menuButton(
                              AppAssets.qrSvg,
                               false, // Ensure this matches the expected parameter
                               Colors.white,
                               Colors.black.withOpacity(0.2),
                               () {
                                if (token?.isEmpty ?? true) {
                                  nextRoute(LoginPage.pageName);
                                  showSnackBar(ErrorEnum.alert, appText.loginDesc);
                                } else {
                                  nextRoute(ScannerPage.pageName);
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
        },
      ),
    ),
  );
}


Widget button(
    {required Function onTap,
    required double? width,
    required double height,
    required String text,
    required Color bgColor,
    required Color textColor,
    Color? iconColor,
    Color? borderColor,
    int raduis = 20,
    BoxShadow? boxShadow,
    String? iconPath,
    int fontSize = 14,
    textFontWeight = FontWeight.normal,
    bool isLoading = false,
    Color? loadingColor,
    int horizontalPadding = 0,
    int? icWidth}) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isLoading ? height.toDouble() : width?.toDouble(),
        height: height.toDouble(),
        alignment: Alignment.center,
        padding:
            padding(horizontal: isLoading ? 0 : horizontalPadding.toDouble()),
        decoration: BoxDecoration(
            color: bgColor,
            border:
                Border.all(color: borderColor ?? Colors.transparent, width: 1),
            borderRadius:
                borderRadius(radius: isLoading ? 100 : raduis.toDouble()),
            boxShadow: [
              if (boxShadow != null) ...{boxShadow}
            ]),
        child: AnimatedCrossFade(
          firstChild: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconPath != null) ...{
                if (text.isNotEmpty) ...{
                  space(0, width: 2.5),
                },
                SvgPicture.asset(
                  iconPath,
                  colorFilter: iconColor != null
                      ? ColorFilter.mode(iconColor, BlendMode.srcIn)
                      : null,
                  width: icWidth?.toDouble(),
                ),
                if (text.isNotEmpty) ...{
                  space(0, width: 5.5),
                }
              },
              if (text.isNotEmpty) ...{
                Text(
                  text,
                  style: style14Regular().copyWith(
                      fontSize: fontSize.toDouble(),
                      color: textColor,
                      fontWeight: textFontWeight // Set fontWeight to bold

                      ),
                ),
              }
            ],
          ),
          secondChild: loading(color: loadingColor ?? Colors.white),
          crossFadeState:
              isLoading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        )),
  );
}

Widget emptyState(String icon, String title, String desc,
    {bool isBottomPadding = true}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SvgPicture.asset(icon),
      space(20),
      Text(
        title,
        style: style20Bold(),
      ),
      space(4),
      Padding(
        padding: padding(horizontal: 50),
        child: Text(
          desc,
          style: style14Regular().copyWith(color: grey5E),
          textAlign: TextAlign.center,
        ),
      ),
      space(isBottomPadding ? getSize().height * .1 : 0)
    ],
  );
}

showSnackBar(ErrorEnum type, String? title,
    {String? desc, int time = 3, int fontSize = 14, BuildContext? context}) {
  ScaffoldMessenger.of(context ?? navigatorKey.currentContext!)
      .showSnackBar(SnackBar(
    content: directionality(
        child: Container(
      width: getSize().width,
      padding: padding(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius(),
          border: Border.all(color: primaryColor.withOpacity(0.2), width: 1)),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
                color: type == ErrorEnum.success
                    ? primaryColor
                    : type == ErrorEnum.error
                        ? red49
                        : yellow29,
                shape: BoxShape.circle),
            alignment: Alignment.center,
            child: SvgPicture.asset(type == ErrorEnum.success
                ? AppAssets.checkSvg
                : type == ErrorEnum.error
                    ? AppAssets.clearSvg
                    : AppAssets.alertSvg),
          ),
          space(0, width: 9),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...{
                Text(
                  title,
                  style: style14Bold(),
                )
              },
              if (desc != null) ...{
                Text(
                  desc,
                  style: style12Regular().copyWith(color: greyB2),
                )
              },
            ],
          ))
        ],
      ),
    )),
    duration: Duration(seconds: time),
    backgroundColor: Colors.transparent,
    elevation: 0,
  ));
}

closeSnackBar() {
  ScaffoldMessenger.of(navigatorKey.currentContext!).hideCurrentSnackBar();
}

Widget userProfileCard(UserModel user, Function onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    child: Column(
      children: [
        // Profile image with SVG on top-right corner
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(55),
              child: fadeInImage(user.avatar ?? '', 100, 100),
            ),
            // SVG icon positioned on the top-right of the image
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: user.meetingStatus == 'no'
                      ? red49.withOpacity(.3)
                      : user.meetingStatus == 'available'
                          ? primaryColor.withOpacity(.3)
                          : primaryColor.withOpacity(.3),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  AppAssets.meetingsSvg,
                  width: 18,
                  colorFilter: ColorFilter.mode(
                      user.meetingStatus == 'no'
                          ? red49
                                                : user.meetingStatus == 'available'
                          ? primaryColor
                          : primaryColor,
                      BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),

        const Spacer(flex: 1),

        // Name and Bio
        Text(
          user.fullName ?? '',
          style: style14Regular(),
        ),
        Text(
          user.bio ?? '',
          style: style10Regular().copyWith(color: Colors.black87),
          maxLines: 1,
        ),

        // Rating bar below the name and bio
        ratingBar(user.rate ?? '0'),

        const Spacer(flex: 2),
      ],
    ),
  );
}

// Widget userProfileCard(UserModel user, Function onTap) {
//   return GestureDetector(
//     onTap: () {
//       onTap();
//     },
//     child: Container(
//       width: 155,
//       height: 195,
//       padding: padding(horizontal: 14, vertical: 14),
//       decoration:
//           BoxDecoration(color: Colors.white, borderRadius: borderRadius()),
//       child: Column(
//         children: [
//           // meet status
//           Align(
//             alignment: AlignmentDirectional.centerEnd,
//             child: Container(
//               width: 22,
//               height: 22,
//               decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: user.meetingStatus == 'no'
//                       ? red49.withOpacity(.3)
//                       : user.meetingStatus == 'available'
//                           ? primaryColor.withOpacity(.3)
//                           : greyCF.withOpacity(.3)),
//               alignment: Alignment.center,
//               child: SvgPicture.asset(
//                 AppAssets.calendarSvg,
//                 width: 11,
//                 colorFilter: ColorFilter.mode(
//                     user.meetingStatus == 'no'
//                         ? red49
//                         : user.meetingStatus == 'available'
//                             ? primaryColor
//                             : greyCF,
//                     BlendMode.srcIn),
//               ),
//             ),
//           ),
//
//           Expanded(
//             child: Column(
//               children: [
//                 ClipRRect(
//                   borderRadius: borderRadius(radius: 100),
//                   child: fadeInImage(user.avatar ?? '', 70, 70),
//                 ),
//                 const Spacer(flex: 1),
//                 Text(
//                   user.fullName ?? '',
//                   style: style14Regular(),
//                 ),
//                 space(2),
//                 Text(
//                   user.bio ?? '',
//                   style: style10Regular().copyWith(color: greyA5),
//                   maxLines: 1,
//                 ),
//                 space(8),
//                 ratingBar(user.rate ?? '0'),
//                 const Spacer(flex: 2),
//               ],
//             ),
//           )
//         ],
//       ),
//     ),
//   );
// }

Widget userCard(String image, String title, String desc, String date,
    String price, String type, Function onTap,
    {Time? time,
    String? userGrade,
    String? gradeStatus,
    int imageWidth = 70,
    int paddingValue = 14,
    int titleAndDescSpace = 2,
    Function? onTapSubtitle}) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: getSize().width,
        height: 100,
        padding: padding(
            horizontal: paddingValue.toDouble(),
            vertical: paddingValue.toDouble()),
        margin: const EdgeInsets.only(bottom: 15),
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: borderRadius()),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: borderRadius(radius: 10),
              child: fadeInImage(image, imageWidth.toDouble(), 100),
            ),
            space(0, width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  space(4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: style14Regular(),
                        ),
                      ),
                      if (type == 'webinar') ...{
                        Badges.course(),
                      } else if (type == 'pending') ...{
                        Badges.pending(),
                      } else if (type == 'open') ...{
                        Badges.open(),
                      } else if (type == 'waiting') ...{
                        Badges.waiting(),
                      }
                    ],
                  ),
                  space(titleAndDescSpace.toDouble()),
                  IgnorePointer(
                    ignoring: onTapSubtitle == null,
                    child: GestureDetector(
                      onTap: () {
                        if (onTapSubtitle != null) {
                          onTapSubtitle();
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        desc,
                        style: style10Regular().copyWith(color: greyA5),
                        maxLines: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // date
                      Row(
                        children: [
                          SvgPicture.asset(AppAssets.calendarSvg),
                          space(0, width: 4),
                          Text(
                            date,
                            style: style10Regular().copyWith(color: greyA5),
                          )
                        ],
                      ),

                      if (time != null) ...{
                        // time
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.timeSvg,
                              colorFilter:
                                  ColorFilter.mode(greyA5, BlendMode.srcIn),
                            ),
                            space(0, width: 4),
                            Text(
                              '${time.start}-${time.end}',
                              style: style10Regular().copyWith(color: greyA5),
                            ),
                          ],
                        ),

                        space(0)
                      },
                      if (price.isNotEmpty) ...{
                        Text(
                          price,
                          style: style16Regular().copyWith(color: primaryColor),
                        )
                      },

                      if (userGrade != null) ...{
                        // Grade
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.badgeSvg,
                              colorFilter: ColorFilter.mode(
                                  gradeStatus == 'passed'
                                      ? primaryColor
                                      : gradeStatus == 'waiting'
                                          ? yellow29
                                          : gradeStatus == 'failed'
                                              ? red49
                                              : yellow29,
                                  BlendMode.srcIn),
                              width: 9,
                            ),

                            space(0, width: 4),

                            Text(
                              userGrade,
                              style: style12Regular().copyWith(
                                color: gradeStatus == 'passed'
                                    ? primaryColor
                                    : gradeStatus == 'waiting'
                                        ? yellow29
                                        : gradeStatus == 'failed'
                                            ? red49
                                            : yellow29,
                              ),
                            ),

                            // space(0,width: 12),
                          ],
                        ),
                      },
                    ],
                  ),
                  space(4),
                ],
              ),
            )
          ],
        ),
      ),
    );
}

Widget tabBar(
    Function(int) onChangeTab, TabController tabController, List<Widget> tab,
    {double horizontalPadding = 14}) {
  return Align(
    alignment: AlignmentDirectional.centerStart,
    child: TabBar(
        onTap: onChangeTab,
        isScrollable: true,
        controller: tabController,
        physics: const BouncingScrollPhysics(),
        padding: padding(horizontal: horizontalPadding),
        indicator: RoundedTabIndicator(),
        labelStyle: style14Regular(),
        unselectedLabelStyle: style14Regular(),
        labelColor: primaryColor2,
        dividerColor: Colors.transparent,
        labelPadding: padding(horizontal: 10),
        overlayColor: const MaterialStatePropertyAll(Colors.transparent),
        tabs: tab),
  );
}

Widget blogItem(BlogModel blog, Function onTap) {
  return GestureDetector(
    onTap: () {
      onTap();
    },
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: getSize().width,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.black,
          Colors.black,
          Colors.black,
          secondaryColor.withOpacity(0.99),
          secondaryColor
        ], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: borderRadius(radius: 15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image
          Hero(
            tag: blog.id!,
            child: ClipRRect(
              borderRadius: borderRadius(radius: 10),
              child: Stack(
                children: [
                  fadeInImage(blog.image ?? '', getSize().width, 200),
                  Container(
                    padding: padding(horizontal: 12, vertical: 12),
                    width: getSize().width,
                    height: 200,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [
                          Colors.black.withOpacity(.7),
                          Colors.black.withOpacity(.1),
                          Colors.black.withOpacity(0),
                        ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter)),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: borderRadius(radius: 100),
                          child: fadeInImage(blog.author?.avatar ?? '', 32, 32),
                        ),
                        space(0, width: 8),
                        Text(
                          blog.author?.fullName ?? '',
                          style: style14Regular().copyWith(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  if (blog.badges?.isNotEmpty ?? false) ...{
                    space(3),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Container(
                        margin: padding(horizontal: 12, vertical: 12),
                        padding: padding(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: getColorFromRGBString(
                              blog.badges!.first.badge?.background ?? ''),
                          borderRadius: borderRadius(radius: 10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (blog.badges!.first.badge?.icon != null) ...{
                              SvgPicture.network(
                                '${Constants.dommain}${blog.badges!.first.badge?.icon ?? ''}',
                                width: 16,
                              ),
                              space(0, width: 2),
                            } else ...{
                              space(0, width: 2),
                            },
                            Text(
                              blog.badges!.first.badge?.title ?? '',
                              style: style12Regular().copyWith(
                                  color: Color(int.parse(
                                          blog.badges!.first.badge!.color!
                                              .substring(1, 7),
                                          radix: 16) +
                                      0xFF000000)),
                            ),
                            space(0, width: 2),
                          ],
                        ),
                      ),
                    )
                  },
                ],
              ),
            ),
          ),

          space(16),

          Padding(
            padding: const EdgeInsets.all(16.0), // Adjust padding as needed
            child: Column(
              children: [
                Text(
                  blog.title ?? '',
                  style: style20Bold().copyWith(
                      color: Colors.white), // Replace with any hex color code
                ),
                space(5),
                HtmlWidget(
                  blog.description ?? '',
                  textStyle: style14Regular()
                      .copyWith(color: Colors.white, height: 1.6),
                ),
                space(10),
                Row(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset(AppAssets.calendarSvg),
                        space(0, width: 5),
                        Baseline(
                          baseline: 10,
                          // Adjust this value to move the text up or down
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            timeStampToDate((blog.createdAt ?? 0) * 1000)
                                .toString(),
                            style:
                                style12Regular().copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    space(0, width: 20),
                    Row(
                      children: [
                        SvgPicture.asset(AppAssets.commentSvg),
                        space(0, width: 5),
                        Baseline(
                          baseline: 10,
                          // Adjust this value to move the text up or down
                          baselineType: TextBaseline.alphabetic,
                          child: Text(
                            '${blog.commentCount} ${appText.comments}',
                            style:
                                style12Regular().copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget userProfile(UserModel user,
    {bool showRate = false,
    String? customRate,
    String? customSubtitle,
    bool isBoldTitle = false,
    bool isBackground = false,
    bool isBoxLimited = false}) {
  return Container(
    padding: isBackground ? padding(horizontal: 12, vertical: 12) : null,
    decoration: isBackground
        ? BoxDecoration(
            color: Colors.white, borderRadius: borderRadius(radius: 10))
        : null,
    width: isBoxLimited ? 240 : null,
    child: Row(
      children: [
        ClipRRect(
            borderRadius: borderRadius(radius: 100),
            child: fadeInImage(user.avatar ?? '', 40, 40)),
        space(0, width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: isBoxLimited
                  ? const BoxConstraints(maxWidth: 150)
                  : const BoxConstraints(),
              child: Text(
                user.fullName ?? '',
                style: !isBoldTitle ? style14Regular() : style14Bold(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (showRate) ...{
              space(3),
              ratingBar(customRate ?? user.rate.toString()),
            } else if (customSubtitle != null) ...{
              space(6),
              Text(
                customSubtitle,
                style: style12Regular().copyWith(color: greyA5),
              ),
            } else ...{
              Text(
                user.roleName ?? '',
                style: style14Regular().copyWith(color: greyA5),
              ),
            }
          ],
        )
      ],
    ),
  );
}

Widget dropDown(
    String hint,
    String itemSelected,
    List<String> items,
    Function onTapOpenBox,
    Function(String newValue, int index) onTap,
    bool isOpen,
    {String? icon,
    int iconSize = 16,
    String? title,
    bool isBorder = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null) ...{
        Padding(
          padding: padding(horizontal: 6),
          child: Text(
            title,
            style: style12Regular().copyWith(color: greyA5),
          ),
        ),
        space(8),
      },
      Container(
        width: getSize().width,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius(),
            border: isBorder ? Border.all(color: primaryColor.withOpacity(0.2), width: 1) : null),
        child: Column(
          children: [
            GestureDetector(
                onTap: () {
                  onTapOpenBox();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: padding(horizontal: 20),
                  height: 52,
                  width: getSize().width,
                  child: Row(
                    children: [
                      if (icon != null) ...{
                        SvgPicture.asset(
                          icon,
                          width: iconSize.toDouble(),
                        ),
                        space(0, width: 11),
                      },
                      Text(
                        itemSelected.isEmpty ? hint : itemSelected,
                        style: style14Regular().copyWith(color: greyB2),
                      ),
                      const Spacer(),
                      Icon(
                        !isOpen
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: primaryColor.withOpacity(0.6),
                      )
                    ],
                  ),
                )),
            AnimatedCrossFade(
                firstChild: Container(
                  width: getSize().width,
                  constraints: BoxConstraints(
                    maxHeight: getSize().height * .5,
                    minHeight: 0,
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...List.generate(items.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              onTap(items[index], index);
                              onTapOpenBox();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: padding(horizontal: 16),
                              width: getSize().width,
                              height: 35,
                              child: Text(
                                items[index],
                                style: style14Regular(),
                              ),
                            ),
                          );
                        })
                      ],
                    ),
                  ),
                ),
                secondChild: SizedBox(width: getSize().width),
                crossFadeState: isOpen
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 300)),
          ],
        ),
      ),
    ],
  );
}

RatingBar ratingBar(String rate,
    {int itemSize = 12, Function(double)? onRatingUpdate}) {
  return RatingBar(
    ignoreGestures: onRatingUpdate == null,
    itemPadding: padding(horizontal: 0),
    itemSize: itemSize.toDouble(),
    initialRating: double.parse(rate).round().toDouble(),
    ratingWidget: RatingWidget(
        full: SvgPicture.asset(AppAssets.starYellowSvg),
        half: SvgPicture.asset(AppAssets.starYellowSvg),
        empty: SvgPicture.asset(AppAssets.starGreySvg)),
    onRatingUpdate: (value) {
      if (onRatingUpdate != null) {
        onRatingUpdate(value);
      }
    },
    glow: false,
  );
}

Widget faqDropDown(
    String title, String desc, bool isOpen, String icon, Function onTap) {
  return Container(
    width: getSize().width,
    padding: padding(horizontal: 12, vertical: 12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: borderRadius(radius: 15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            onTap();
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                    color: primaryColor, borderRadius: borderRadius(radius: 8)),
                alignment: Alignment.center,
                child: SvgPicture.asset(AppAssets.questionSvg),
              ),
              space(0, width: 8),
              Expanded(
                  child: Text(
                title,
                style: style14Bold(),
              )),
              space(0, width: 12),
              Icon(
                isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: greyA5,
              )
            ],
          ),
        ),
        AnimatedCrossFade(
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                desc,
                style: style14Regular().copyWith(color: greyA5),
              ),
            ),
            secondChild: SizedBox(width: getSize().width),
            crossFadeState:
                isOpen ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300)),
      ],
    ),
  );
}

Widget commentUi(Comments comment, Function onTapOption) {
  return Container(
    key: comment.globalKey,
    width: getSize().width,
    padding: padding(horizontal: 16, vertical: 16),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius()
        // border: Border.all()
        ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // user info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            userProfile(comment.user ?? UserModel()),
            GestureDetector(
              onTap: () {
                onTapOption();
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 45,
                height: 45,
                child: Icon(
                  Icons.more_horiz,
                  size: 30,
                  color: greyA5,
                ),
              ),
            )
          ],
        ),

        space(16),

        Text(
          comment.comment ?? '',
          style: style14Regular().copyWith(color: greyA5, height: 1.5),
        ),

        space(16),

        Text(
          timeStampToDate((comment.createAt ?? 0) * 1000),
          style: style14Regular().copyWith(color: greyA5, height: 1.5),
        ),

        // Replies
        if (comment.replies?.isNotEmpty ?? false) ...{
          space(16),
          ...List.generate(comment.replies?.length ?? 0, (i) {
            return Container(
              width: getSize().width,
              padding: padding(horizontal: 16, vertical: 16),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: borderRadius(),
                  border: Border.all(color: primaryColor.withOpacity(0.2))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // user info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      userProfile(comment.replies![i].user!),
                      GestureDetector(
                        onTap: () {
                          onTapOption();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: 45,
                          height: 45,
                          child: Icon(
                            Icons.more_horiz,
                            size: 30,
                            color: greyA5,
                          ),
                        ),
                      )
                    ],
                  ),

                  space(16),

                  Text(
                    comment.replies![i].comment ?? '',
                    style:
                        style14Regular().copyWith(color: greyA5, height: 1.5),
                  ),

                  space(14),

                  Text(
                    timeStampToDate((comment.replies![i].createAt ?? 0) * 1000),
                    style:
                        style12Regular().copyWith(color: greyA5, height: 1.5),
                  ),
                ],
              ),
            );
          }),
        },
      ],
    ),
  );
}

Widget dashboardInfoBox(
    Color color, String icon, String title, String subTitle, Function onTap,
    {double width = 140, double height = 170, int icWidth = 22}) {
  return GestureDetector(
    onTap: () {},
    behavior: HitTestBehavior.opaque,
    child: Container(
      width: width,
      height: height,
      padding: padding(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        // gradient: LinearGradient(
        //     begin: Alignment.topLeft,  // Start from the top-left
        //     end: Alignment.bottomRight, // End at the bottom-right
        //     colors: [
        //       Colors.black,
        //       Colors.black,
        //       Colors.black,
        //       secondaryColor.withOpacity(0.99),
        //       secondaryColor,
        //     ],
        //   ),
        borderRadius: borderRadius(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // circle icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(icon,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                width: icWidth.toDouble()),
          ),

          const Spacer(),
          const Spacer(),

          Text(
            title,
            style: style20Bold(),
          ),

          space(4),

          Text(
            subTitle,
            style: style12Regular().copyWith(color: greyB2),
          ),
        ],
      ),
    ),
  );
}

Widget forumQuestionItem(Forums question, Function changeState,
    {bool ignoreOnTap = false,
    bool isShowDownload = false,
    bool isShowAnswerCount = true,
    bool isShowMoreIcon = true,
    Function? getData}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      // details box
      GestureDetector(
        onTap: () {
          if (!ignoreOnTap) {
            nextRoute(ForumAnswerPage.pageName, arguments: question);
          }
        },
        child: Container(
          width: getSize().width,
          margin: const EdgeInsets.only(bottom: 16),
          padding: padding(horizontal: 16, vertical: 16),
          decoration:
              BoxDecoration(color: Colors.white, borderRadius: borderRadius()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // userInfo and answers count
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // userInfo
                  Row(
                    children: [
                      ClipRRect(
                          borderRadius: borderRadius(radius: 100),
                          child:
                              fadeInImage(question.user?.avatar ?? '', 40, 40)),
                      space(0, width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.user?.fullName ?? '',
                            style: style14Regular(),
                          ),
                          space(4),
                          Text(
                            timeStampToDateHour(
                                (question.createdAt ?? 0) * 1000),
                            style: style12Regular().copyWith(color: greyA5),
                          ),
                        ],
                      )
                    ],
                  ),

                  // answer count or more buttom
                  if ((question.can?.pin ?? false) && isShowMoreIcon) ...{
                    GestureDetector(
                      onTap: () async {
                        LearningWidget.forumOptionSheet(
                            question.can!, question.pin!, () {
                          question.pin = !(question.pin ?? true);

                          changeState();
                        }, () async {
                          // bool? res = await LearningWidget.forumReplaySheet(question);

                          // if(res != null && res){
                          //   getData!();
                          // }
                        }, () {});
                      },
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 40,
                        child: Icon(
                          Icons.more_horiz,
                          color: greyB2,
                          size: 30,
                        ),
                      ),
                    )
                  } else ...{
                    Container(
                      padding: padding(horizontal: 5, vertical: 4),
                      decoration: BoxDecoration(
                          color: greyF8, borderRadius: borderRadius()),
                      child: Text(
                        '${question.answersCount ?? 0} ${appText.answers}',
                        style: style10Regular().copyWith(color: greyB2),
                      ),
                    )
                  }
                ],
              ),

              space(16),

              if (question.resolved ?? false) ...{
                // Resolved
                Center(
                  child: Container(
                    padding: padding(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: borderRadius(radius: 50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.checkCircleSvg,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                          width: 20,
                        ),
                        space(0, width: 4),
                        Text(
                          appText.resolved,
                          style: style14Regular().copyWith(color: Colors.white),
                        ),
                        space(0, width: 4),
                      ],
                    ),
                  ),
                ),

                space(12),
              },

              Text(
                question.title ?? '',
                style: style16Bold(),
              ),

              space(12),

              Text(
                question.description ?? '',
                style: style14Regular().copyWith(color: greyA5),
              ),

              if (isShowAnswerCount) ...{
                if (question.activeUsers?.isNotEmpty ?? false) ...{
                  space(12),
                  Container(
                    padding: padding(horizontal: 8, vertical: 8),
                    width: getSize().width,
                    decoration: BoxDecoration(
                        color: greyF8, borderRadius: borderRadius(radius: 15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // users image
                        Row(
                          children: [
                            SizedBox(
                              width: (((((question.activeUsers?.length ?? 0) >
                                                  3)
                                              ? 3
                                              : (question.activeUsers?.length ??
                                                  0)) -
                                          1) *
                                      17) +
                                  34,
                              height: 35,
                              child: Stack(
                                children: List.generate(
                                    ((question.activeUsers?.length ?? 0) > 3)
                                        ? 3
                                        : (question.activeUsers?.length ?? 0),
                                    (i) {
                                  return PositionedDirectional(
                                      start: i == 0 ? 0 : i * 17,
                                      child: ClipRRect(
                                          borderRadius:
                                              borderRadius(radius: 50),
                                          child: fadeInImage(
                                              question.activeUsers?[i] ?? '',
                                              34,
                                              34)));
                                }),
                              ),
                            ),
                            space(0, width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question.activeUsers?.length.toString() ?? '',
                                  style: style12Bold(),
                                ),
                                Text(
                                  appText.activeUsers,
                                  style:
                                      style10Regular().copyWith(color: greyA5),
                                ),
                              ],
                            )
                          ],
                        ),

                        // line
                        Container(
                          width: 1,
                          height: 35,
                          color: primaryColor.withOpacity(0.3),
                        ),

                        // last activity
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeStampToDateHour(
                                  (question.lastActivity ?? 0) * 1000),
                              style: style12Bold(),
                            ),
                            Text(
                              appText.lastActivity,
                              style: style10Regular().copyWith(color: greyA5),
                            ),
                          ],
                        ),

                        space(0, width: 5)
                      ],
                    ),
                  )
                }
              },

              if (isShowDownload && question.attachment != null) ...{
                space(16),
                GestureDetector(
                  onTap: () {
                    if (!question.isDownload) {
                      DownloadManager.download(question.attachment!,
                          (progress) {
                        if (progress <= 90) {
                          if (!question.isDownload) {
                            question.isDownload = true;
                            changeState();
                          }
                        } else {
                          question.isDownload = false;
                          changeState();
                        }
                      });
                    }
                  },
                  child: Container(
                    width: getSize().width,
                    padding: padding(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                        color: greyF8, borderRadius: borderRadius(radius: 15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // details
                        Row(
                          children: [
                            SvgPicture.asset(AppAssets.downloadSvg),
                            space(0, width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appText.download,
                                  style: style12Bold(),
                                ),
                                space(2),
                                Text(
                                  question.attachment?.split('/').last ?? '',
                                  style:
                                      style12Regular().copyWith(color: greyA5),
                                )
                              ],
                            ),
                          ],
                        ),

                        question.isDownload ? loading() : const SizedBox()
                      ],
                    ),
                  ),
                )
              }
            ],
          ),
        ),
      ),

      if (question.pin ?? false) ...{
        PositionedDirectional(
            top: -12,
            end: 18,
            child: Container(
              width: 28,
              height: 28,
              decoration:
                  BoxDecoration(color: yellow29, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: SvgPicture.asset(AppAssets.bookmarkSvg),
            ))
      }
    ],
  );
}

Widget forumAnswerItem(ForumAnswerModel answer, Function changeState,
    {Function? getNewData}) {
  return Stack(
    clipBehavior: Clip.none,
    children: [
      // details box
      Container(
        width: getSize().width,
        margin: const EdgeInsets.only(bottom: 16),
        padding: padding(horizontal: 16, vertical: 16),
        decoration:
            BoxDecoration(color: Colors.white, borderRadius: borderRadius()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // userInfo and answers count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // userInfo
                userProfile(answer.user!),

                // answer count or more buttom
                GestureDetector(
                  onTap: () async {
                    LearningWidget.forumOptionSheet(answer.can!, answer.pin!,
                        () {
                      answer.pin = !(answer.pin ?? true);
                      ForumService.answerPin(answer.id!);

                      changeState();
                    }, () {
                      answer.resolved = !(answer.resolved ?? true);
                      ForumService.answerResolve(answer.id!);

                      changeState();
                    }, () async {
                      bool? res = await LearningWidget.forumReplaySheet(null,
                          isEdit: true, answer: answer);

                      if (res != null && res) {
                        getNewData!();
                      }
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    height: 40,
                    child: Icon(
                      Icons.more_horiz,
                      color: greyB2,
                      size: 30,
                    ),
                  ),
                )
              ],
            ),

            space(16),

            Text(
              answer.description ?? '',
              style: style14Regular().copyWith(color: greyA5),
            ),

            space(12),

            Divider(color: grey3A.withOpacity(.15), thickness: .3),

            space(4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // date
                Row(
                  children: [
                    SvgPicture.asset(
                      AppAssets.calendarSvg,
                      width: 8,
                    ),
                    space(0, width: 5),
                    Text(
                      timeStampToDateHour((answer.createdAt ?? 0) * 1000),
                      style: style12Regular().copyWith(color: greyA5),
                    ),
                  ],
                ),

                if (answer.resolved ?? false) ...{
                  // Resolved
                  Container(
                    padding: padding(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: borderRadius(radius: 50),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          AppAssets.checkCircleSvg,
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                          width: 20,
                        ),
                        space(0, width: 4),
                        Text(
                          appText.resolved,
                          style: style14Regular().copyWith(color: Colors.white),
                        ),
                        space(0, width: 4),
                      ],
                    ),
                  ),
                },
              ],
            )
          ],
        ),
      ),

      if (answer.pin ?? false) ...{
        PositionedDirectional(
            top: -12,
            end: 18,
            child: Container(
              width: 28,
              height: 28,
              decoration:
                  BoxDecoration(color: yellow29, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: SvgPicture.asset(AppAssets.bookmarkSvg),
            ))
      }
    ],
  );
}

Widget helperBox(String icon, String title, String subTitle,
    {int iconSize = 20, int horizontalPadding = 21}) {
  return Container(
    width: getSize().width,
    padding: padding(vertical: 9, horizontal: 9),
    margin: padding(horizontal: horizontalPadding.toDouble()),
    decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withOpacity(0.2)), borderRadius: borderRadius()),
    child: Row(
      children: [
        // icon
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: SvgPicture.asset(
            icon,
            width: iconSize.toDouble(),
          ),
        ),

        space(0, width: 10),

        // title
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: style14Bold(),
            ),
            Text(
              subTitle,
              style: style12Regular().copyWith(color: greyB2),
            ),
          ],
        )),
      ],
    ),
  );
}

Future downloadSheet(String downloadUrl, String name,
    {bool isOpen = true}) async {
  double progress = 0;
  CancelToken cancelToken = CancelToken();

  bool isStartDownload = false;

  return await baseBottomSheet(
      child: StatefulBuilder(builder: (context, state) {
    if (!isStartDownload) {
      isStartDownload = true;

      DownloadManager.download(
          downloadUrl,
          (va) {
            progress = va / 100;
            state(() {});
          },
          name: name,
          cancelToken: cancelToken,
          onLoadAtLocal: () {
            if (context.mounted) {
              backRoute();
            }
          },
          isOpen: isOpen);
    }

    return Padding(
      padding: padding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          space(20),
          Text(
            appText.download,
            style: style16Bold(),
          ),
          space(25),
          Text(
            '${(progress * 100).toInt()} %',
            style: style14Regular(),
          ),
          space(6),
          LinearProgressIndicator(
            backgroundColor: primaryColor.withOpacity(.2),
            value: progress,
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          space(40),
          button(
              onTap: () async {
                cancelToken.cancel();

                await Future.delayed(const Duration(milliseconds: 600));

                if (context.mounted) {
                  backRoute();
                }
              },
              width: getSize().width,
              height: 52,
              text: appText.cancel,
              bgColor: primaryColor,
              textColor: Colors.white),
          space(30),
        ],
      ),
    );
  }));
}
