import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../main.dart';
import 'NormalUserShifts.dart';

class DisplayInternalUserMissions extends StatelessWidget {
  final List<GlobalKey<ExpansionTileCardState>> gKey;
  const DisplayInternalUserMissions(this.gKey);
  @override
  Widget build(BuildContext context) {
    final missionDataProv = locator.locator<MissionsData>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Card(
        elevation: 5,
        child: ExpansionTileCard(
          key: gKey[2],
          onExpansionChanged: (value) async {
            if (value) {
              gKey[1].currentState.collapse();
              gKey[0].currentState.collapse();
            }

            if (missionDataProv.myInternalMissions == null &&
                missionDataProv.errorMsg != "empty") {
              if (value) {
                showDialog(
                  context: context,
                  builder: (context) => RoundedLoadingIndicator(),
                );

                await locator.locator<MissionsData>().getMyInternalMission();
                Navigator.pop(context);
              }
            }
          },
          title: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.briefcase,
                color: ColorManager.primary,
              ),
              const SizedBox(
                width: 5,
              ),
              AutoSizeText(
                getTranslated(context, "مأمورياتى الداخلية"),
                style: boldStyle,
              ),
            ],
          ),
          children: [
            missionDataProv.myInternalMissions == null
                ? Provider.of<MissionsData>(context).isLoading
                    ? Container()
                    : SizedBox(
                        height: 100.h,
                        child: Center(
                          child: AutoSizeText(
                            getTranslated(
                              context,
                              "لا يوجد مأموريات لهذا المستخدم",
                            ),
                          ),
                        ),
                      )
                : SlideInUp(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  child: AutoSizeText(
                                      getTranslated(context, "من"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.primary),
                                      textAlign: TextAlign.start),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: AutoSizeText(missionDataProv
                                    .myInternalMissions.fromDate
                                    .toString()
                                    .substring(0, 11)),
                              ),
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  getTranslated(context, "إلى"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorManager.primary),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: AutoSizeText(missionDataProv
                                      .myInternalMissions.toDate
                                      .toString()
                                      .substring(0, 11))),
                            ],
                          ),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SizedBox(
                                  child: AutoSizeText(
                                      getTranslated(context, "الموقع"),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: ColorManager.primary)),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: AutoSizeText(missionDataProv
                                      .myInternalMissions.siteName)),
                              Expanded(
                                flex: 1,
                                child: AutoSizeText(
                                  getTranslated(context, "المناوبة"),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: ColorManager.primary),
                                ),
                              ),
                              Expanded(
                                  flex: 2,
                                  child: AutoSizeText(missionDataProv
                                      .myInternalMissions.shiftName)),
                            ],
                          ),
                        ),
                        const Divider(),
                        MyInternalMissionsCard(
                          currentIndex: 0,
                          startTime:
                              missionDataProv.myInternalMissions.shiftSttime,
                          endTime:
                              missionDataProv.myInternalMissions.shiftEntime,
                        ),
                        MyInternalMissionsCard(
                          startTime:
                              missionDataProv.myInternalMissions.sunShiftSttime,
                          endTime:
                              missionDataProv.myInternalMissions.sunShiftEntime,
                          currentIndex: 1,
                        ),
                        MyInternalMissionsCard(
                          startTime:
                              missionDataProv.myInternalMissions.monShiftSttime,
                          endTime: missionDataProv
                              .myInternalMissions.mondayShiftEntime,
                          currentIndex: 2,
                        ),
                        MyInternalMissionsCard(
                          startTime: missionDataProv
                              .myInternalMissions.tuesdayShiftSttime,
                          endTime: missionDataProv
                              .myInternalMissions.tuesdayShiftEntime,
                          currentIndex: 3,
                        ),
                        MyInternalMissionsCard(
                          startTime: missionDataProv
                              .myInternalMissions.wednesdayShiftSttime,
                          endTime: missionDataProv
                              .myInternalMissions.wednesdayShiftEntime,
                          currentIndex: 4,
                        ),
                        MyInternalMissionsCard(
                          startTime: missionDataProv
                              .myInternalMissions.thursdayShiftSttime,
                          endTime: missionDataProv
                              .myInternalMissions.thursdayShiftEntime,
                          currentIndex: 5,
                        ),
                        MyInternalMissionsCard(
                          startTime: missionDataProv
                              .myInternalMissions.fridayShiftSttime,
                          endTime: missionDataProv
                              .myInternalMissions.fridayShiftEntime,
                          currentIndex: 6,
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
