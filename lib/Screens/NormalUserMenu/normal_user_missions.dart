import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/MLmodule/widgets/MissionsDisplay/missions_summary_table_end.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/CompanyMissions/DataTableMissionRow.dart';
import 'package:qr_users/widgets/Holidays/DataTableHolidayHeader.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyMissions extends StatefulWidget {
  @override
  State<MyMissions> createState() => _MyMissionsState();
}

class _MyMissionsState extends State<MyMissions> {
  DateTime initialTime = DateTime(DateTime.now().year, 1, 1);
  Future getUserMissions;

  @override
  void initState() {
    super.initState();
    getMissions();
  }

  getMissions() async {
    final DateTime startPeriod = DateTime.now();
    final DateTime endPeriod = startPeriod.add(const Duration(days: 30));

    final userData = Provider.of<UserData>(context, listen: false).user;
    getUserMissions = await Provider.of<MissionsData>(context, listen: false)
        .getSingleUserMissions(
            userData.id, userData.userToken, startPeriod, endPeriod);
  }

  @override
  Widget build(BuildContext context) {
    final missionProvider = Provider.of<MissionsData>(context);
    return Scaffold(
      endDrawer: NotificationItem(),
      body: Column(
        children: [
          Header(
            goUserHomeFromMenu: false,
            nav: false,
            goUserMenu: false,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              Row(
                children: [
                  AutoSizeText(
                    getTranslated(context, "مأمورياتى"),
                    style: boldStyle.copyWith(color: ColorManager.primary),
                  ),
                  SizedBox(
                    width: 90.w,
                    height: 60.h,
                    child: Lottie.asset("resources/missions.json"),
                  ),
                ],
              ),
              const Divider()
            ]),
          ),
          if (missionProvider.missionsLoading) ...[
            const Expanded(
              child: LoadingIndicator(),
            )
          ] else ...[
            missionProvider.singleUserMissionsList.isEmpty
                ? const Expanded(
                    child: const CenterMessageText(message: "لا يوجد مأموريات"),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        Divider(
                          thickness: 1,
                          color: ColorManager.primary,
                        ),
                        DataTableMissionHeaderForUser(),
                        Divider(
                          thickness: 1,
                          color: ColorManager.primary,
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount:
                                  missionProvider.singleUserMissionsList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    DataTableMissionRowForUser(missionProvider
                                        .singleUserMissionsList[index]),
                                    const Divider(
                                      thickness: 1,
                                    )
                                  ],
                                );
                              }),
                        ),
                        Divider(
                          thickness: 1,
                          color: ColorManager.primary,
                        ),
                        SlideInUp(child: MissionsSummaryTableEnd())
                      ],
                    ),
                  ),
          ],
          const Divider(),
        ],
      ),
    );
  }
}

// Column(
//                                 children: [
//                                   SizedBox(
//                                     height: 25.h,
//                                   ),
//                                   Divider(
//                                     thickness: 1,
//                                     color: ColorManager.primary,
//                                   ),
//                                   DataTableMissionHeader(),
//                                   Divider(
//                                     thickness: 1,
//                                     color: ColorManager.primary,
//                                   ),
//                                   Expanded(
//                                     child: ListView.builder(
//                                         itemCount: missionProvider
//                                             .singleUserMissionsList.length,
//                                         itemBuilder:
//                                             (BuildContext context, int index) {
//                                           return Column(
//                                             children: [
//                                               DataTableMissionRow(missionProvider
//                                                       .singleUserMissionsList[
//                                                   index]),
//                                               const Divider(
//                                                 thickness: 1,
//                                               )
//                                             ],
//                                           );
//                                         }),
//                                   ),
//                                   Divider(
//                                     thickness: 1,
//                                     color: ColorManager.primary,
//                                   ),
//                                   SlideInUp(child: MissionsSummaryTableEnd())
//                                 ],
//                               ),
