import 'package:flutter/material.dart';
import 'package:webinar/app/models/single_course_model.dart';
import 'package:webinar/app/services/guest_service/course_service.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/common/utils/currency_utils.dart';
import 'package:webinar/common/utils/date_formater.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';

import '../../../../config/assets.dart';
import '../../../widgets/main_widget/home_widget/single_course_widget/single_course_widget.dart';
import '../home_page/single_course_page/single_course_page.dart';

class CourseOverviewPage extends StatefulWidget {
  static const String pageName = '/course-overview';
  const CourseOverviewPage({super.key});

  @override
  State<CourseOverviewPage> createState() => _CourseOverviewPageState();
}

class _CourseOverviewPageState extends State<CourseOverviewPage> {

  SingleCourseModel? course;
  bool isLoading = true;
  bool isPrivate = false;

  int? id;
  bool? isBundle;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      if (args is List && args.length >= 2) {
        id = args[0] as int?;
        isBundle = (args[1] as bool?) ?? false; // Ensure non-nullable bool

        if (args.length >= 3) {
          isPrivate = (args[2] as bool?) ?? false; // Ensure non-nullable bool
        }

        if (id != null) {
          getData(id!, isBundle!);
        } else {
          debugPrint("Invalid arguments received in route.");
        }
      } else {
        debugPrint("No or incorrect arguments received in route.");
      }
    });
  }




  getData(int id, bool isBundle) async {
    setState(() {
      isLoading  = true;
    });
    
    course = await CourseService.getOverviewCourseData(id, isBundle, isPrivate: isPrivate);
    
    setState(() {
      isLoading  = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return directionality(
      
      child: Scaffold(
        appBar: appbar(title: appText.courseOverview),

        body: isLoading
        ? loading()
        : course == null
      ? const SizedBox()
      : Stack(
          children: [
            
            // details
            Positioned.fill(
              child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: padding(),
            
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      space(20),
            
                      // title
                      Text(
                        course!.title ?? '',
                        style: style16Bold(),
                      ),
                      
                      space(4),
            
                      // rate
                      Row(
                        children: [
                          
                          ratingBar(course!.rate ?? '0'),
            
                          space(0,width: 8),
            
                          Container(
                            padding: padding(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(color: greyE7, borderRadius: borderRadius()),
                            child: Text(
                              course!.reviewsCount?.toString() ?? '0',
                              style: style10Regular().copyWith(color: greyB2),
                            ),
                          )
            
                        ],
                      ),
            
                      space(24),
            
                      // image
                      Padding(
                        padding: padding(),
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: ClipRRect(
                            borderRadius: borderRadius(),
                            child: fadeInImage(course?.image ?? '', getSize().width, getSize().width)
                          ),
                        ),
                      ),
            
                      space(24),
            
                      Center(
                        child: Text(
                          appText.courseOverview,
                          style: style20Bold(),
                        ),
                      ),
            
                      space(24),
            
            
                      // info
                      Container(
                        padding: padding(),
                        width: getSize().width,
                        child: Wrap(
                          runSpacing: 20,
                          children: [
                
                            SingleCourseWidget.courseStatus(
                              appText.classOptions, 
                              course!.id?.toString() ?? '-', 
                              AppAssets.moreCircleSvg,
                              width: (getSize().width * .5) - 42,
                            ),
                            
                            SingleCourseWidget.courseStatus(
                              appText.category, 
                              course!.category?.toString() ?? '-', 
                              AppAssets.categorySvg,
                              width: (getSize().width * .5) - 42,
                            ),
                            
                            SingleCourseWidget.courseStatus(
                              appText.sessions, 
                              course!.sessionsCount?.toString() ?? '-', 
                              AppAssets.videoSvg,
                              width: (getSize().width * .5) - 42,
                            ),
                            
                            SingleCourseWidget.courseStatus(
                              appText.sales, 
                              CurrencyUtils.calculator(course?.sales?.amount), 
                              AppAssets.walletSvg,
                              width: (getSize().width * .5) - 42,
                            ),
                            
                            SingleCourseWidget.courseStatus(
                              appText.students, 
                              course?.studentsCount?.toString() ?? '-', 
                              AppAssets.provideresSvg,
                              width: (getSize().width * .5) - 42,
                            ),
            
                            SingleCourseWidget.courseStatus(
                              appText.quizzes, 
                              course?.quizzesCount?.toString() ?? '-', 
                              AppAssets.tickSquareSvg,
                              width: (getSize().width * .5) - 42,
                            ),
            
                            SingleCourseWidget.courseStatus(
                              appText.duration, 
                              '${formatHHMMSS((course?.duration ?? 0))} ${appText.hours}', 
                              AppAssets.tickSquareSvg,
                              width: (getSize().width * .5) - 42,
                            ),
            
                            SingleCourseWidget.courseStatus(
                              appText.dateCreated, 
                              timeStampToDate((course?.createdAt ?? 0) * 1000), 
                              AppAssets.calendarSvg,
                              width: (getSize().width * .5) - 42,
                            ),
              
                
                      
                          ],
                        ),
                      ),
                
                      space(120),
            
            
                    ],
                  ),
                ),
            ),

            // button
            AnimatedPositioned(
              duration: const Duration(milliseconds: 500),
              bottom: 0,
              child: Container(
                width: getSize().width,
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 30
                ),

                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    boxShadow(Colors.black.withOpacity(.1),blur: 15,y: -3)
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30))
                ),
                child: button(
                  onTap: (){
                    
                    nextRoute(
                      SingleCoursePage.pageName, 
                      arguments: [
                        course!.id, 
                        course!.type == 'bundle', 
                        null, 
                        isPrivate
                      ]
                    );          
                  },
                  width: getSize().width, 
                  height: 52, 
                  text: appText.view, 
                  bgColor: primaryColor, 
                  textColor: Colors.white
                ),
              )
            ),
          ],
        ),
      )

    );
  }
}