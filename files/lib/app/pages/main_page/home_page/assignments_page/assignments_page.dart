import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webinar/app/models/instructor_assignment_model.dart';
import 'package:webinar/app/providers/user_provider.dart';
import 'package:webinar/app/services/user_service/assignment_service.dart';
import 'package:webinar/app/widgets/main_widget/assignment_widget/assignment_widget.dart';
import 'package:webinar/common/common.dart';
import 'package:webinar/common/components.dart';
import 'package:webinar/common/utils/app_text.dart';
import 'package:webinar/config/assets.dart';
import 'package:webinar/config/colors.dart';
import 'package:webinar/config/styles.dart';
import 'package:webinar/locator.dart';

import '../../../../models/assignment_model.dart';

class AssignmentsPage extends StatefulWidget {
  static const String pageName = '/assignments';

  const AssignmentsPage({super.key});

  @override
  State<AssignmentsPage> createState() => _AssignmentsPageState();
}

class _AssignmentsPageState extends State<AssignmentsPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  List<AssignmentModel> myAssignments = [];
  InstructorAssignmentModel? studentAssignments;

  bool isLoadingMyAssignment = false;
  bool isLoadingStudentAssignment = false;

  @override
  void initState() {
    super.initState();

    final roleName = locator<UserProvider>().profile?.roleName ?? 'user';

    tabController = TabController(length: roleName == 'user' ? 1 : 2, vsync: this);

    getData();
  }


  getData() async {
    setState(() {
      isLoadingMyAssignment = true;
      isLoadingStudentAssignment = locator<UserProvider>().profile?.roleName != 'user';
    });

    try {
      myAssignments = await AssignmentService.getAssignments();
    } catch (error) {
      print("Error fetching my assignments: $error");
    } finally {
      setState(() {
        isLoadingMyAssignment = false;
      });
    }

    if (locator<UserProvider>().profile?.roleName != 'user') {
      try {
        studentAssignments = await AssignmentService.getAllAssignmentsInstructor();
      } catch (error) {
        print("Error fetching student assignments: $error");
      } finally {
        setState(() {
          isLoadingStudentAssignment = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Adjust based on localization
      child: Scaffold(
        appBar: appbar(title: appText.assignments, background: backgroundColor),
                body: Column(
          children: [
            tabBar((p0) {}, tabController, [
              Tab(
                text: appText.myAssignments,
                height: 32,
              ),
              if (locator<UserProvider>().profile?.roleName != 'user')
                Tab(
                  text: appText.studentAssignmetns,
                  height: 32,
                ),
            ]),
            Expanded(
              child: TabBarView(
                controller: tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  isLoadingMyAssignment
                      ? loading()
                      : myAssignments.isEmpty
                      ? emptyState(AppAssets.commentsEmptyStateSvg, appText.noAssignments, appText.noAssignmentsDesc)
                      : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: padding(vertical: 20),
                    child: Column(
                      children: List.generate(
                          myAssignments.length,
                              (index) => AssignmentWidget.assignmentItem(myAssignments[index])
                      ),
                    ),
                  ),
                  if (locator<UserProvider>().profile?.roleName != 'user')
                    isLoadingStudentAssignment
                        ? loading()
                        : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: padding(vertical: 20),
                      child: Column(
                        children: [
                          Container(
                            width: getSize().width,
                            padding: padding(horizontal: 4, vertical: 18),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: borderRadius(),
                                border: Border.all(color: greyE7)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Pending
                                _buildAssignmentStatus(
                                  color: yellow29,
                                  icon: AppAssets.more2Svg,
                                  count: studentAssignments?.pendingReviewsCount,
                                  label: appText.pending,
                                ),
                                // Passed
                                _buildAssignmentStatus(
                                  color: green50,
                                  icon: AppAssets.checkSvg,
                                  count: studentAssignments?.passedCount,
                                  label: appText.passed,
                                ),
                                // Failed
                                _buildAssignmentStatus(
                                  color: red49,
                                  icon: AppAssets.clearSvg,
                                  count: studentAssignments?.failedCount,
                                  label: appText.failed,
                                ),
                              ],
                            ),
                          ),
                          space(16),
                          ...List.generate(
                            studentAssignments?.assignments?.length ?? 0,
                                (index) => AssignmentWidget.assignmentItem(
                              studentAssignments!.assignments![index],
                              froUserRole: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper widget for assignment status
  Widget _buildAssignmentStatus({
    required Color color,
    required String icon,
    int? count,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: color.withOpacity(.3), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: SvgPicture.asset(icon, colorFilter: ColorFilter.mode(color, BlendMode.srcIn), width: 20),
        ),
        space(8),
        Text(count?.toString() ?? '-', style: style14Bold()),
        space(4),
        Text(label, style: style12Regular().copyWith(color: greyB2)),
      ],
    );
  }
}
