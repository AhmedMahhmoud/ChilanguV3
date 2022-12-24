import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/ShiftsScreen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/ShiftsScreen/addShift.dart';
import 'package:qr_users/services/Reports/Widgets/circular_icon_button.dart';
import 'package:qr_users/services/Shift.dart';
import 'package:qr_users/services/ShiftSchedule/ShiftScheduleModel.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import '../../Core/constants.dart';
import '../../main.dart';
import 'normal_user_first_internal_mission.dart';

class UserCurrentShifts extends StatefulWidget {
  @override
  _UserCurrentShiftsState createState() => _UserCurrentShiftsState();
}

String amPmChanger(int intTime) {
  int hours = (intTime ~/ 100);
  final int min = intTime - (hours * 100);

  final ampm = hours >= 12 ? 'PM' : 'AM';
  hours = hours % 12;
  hours = hours != 0 ? hours : 12; //

  final String hoursStr =
      hours < 10 ? '0$hours' : hours.toString(); // the hour '0' should be '12'
  final String minStr = min < 10 ? '0$min' : min.toString();

  final strTime = '$hoursStr:$minStr$ampm';

  return strTime;
}

TextEditingController _timeInController = TextEditingController(); //sat
TextEditingController _timeOutController = TextEditingController();

TextEditingController _sunTimeInController = TextEditingController(); //sun
TextEditingController _sunTimeOutController = TextEditingController();

TextEditingController _monTimeInController = TextEditingController();
TextEditingController _monTimeOutController = TextEditingController();

TextEditingController _tuesTimeInController = TextEditingController();
TextEditingController _tuesTimeOutController = TextEditingController();

TextEditingController _wedTimeInController = TextEditingController();
TextEditingController _wedTimeOutController = TextEditingController();

TextEditingController _thuTimeInController = TextEditingController();
TextEditingController _thuTimeOutController = TextEditingController();

TextEditingController _friTimeInController = TextEditingController();
TextEditingController _friTimeOutController = TextEditingController();
int shifttime = 1300;
Shift _userShift;

class _UserCurrentShiftsState extends State<UserCurrentShifts> {
  bool isScheduleAvailable = false;
  bool retryScheduleRequest = true;
  final List<GlobalKey<ExpansionTileCardState>> cardKeyList = [];
  @override
  void initState() {
    cardKeyList
      ..add(GlobalKey(debugLabel: "0"))
      ..add(GlobalKey(debugLabel: "1"))
      ..add(GlobalKey(debugLabel: "2"));
    final missionData = Provider.of<MissionsData>(context, listen: false);
    _userShift = null;
    // ignore: cascade_invocations
    missionData.myInternalMissions = null;
    Provider.of<ShiftsData>(context, listen: false).firstAvailableSchedule =
        null;
    Provider.of<ShiftApi>(context, listen: false).userShift = null;
    // ignore: cascade_invocations
    missionData.errorMsg = "";

    super.initState();
  }

  String getShiftNameById(
    int id,
  ) {
    debugPrint("current id");
    final list = Provider.of<ShiftsData>(context, listen: false).shiftsList;
    final List<Shift> currentShift =
        list.where((element) => element.shiftId == id).toList();
    return currentShift[0].shiftName;
  }

  String getSiteNameById(
    int id,
  ) {
    final list = Provider.of<SiteData>(context, listen: false).sitesList;

    final List<Site> currentSite =
        list.where((element) => element.id == id).toList();
    return currentSite[0].name;
  }

  @override
  Widget build(BuildContext context) {
    final shiftDate =
        Provider.of<ShiftsData>(context, listen: true).firstAvailableSchedule;
    return Scaffold(
        endDrawer: NotificationItem(),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Header(
                  goUserHomeFromMenu: false,
                  nav: false,
                  goUserMenu: false,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SmallDirectoriesHeader(
                        Lottie.asset("resources/shifts.json", repeat: false),
                        getTranslated(context, "مناوباتى")),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                ExpansionUserShiftTile(
                  title: getTranslated(context, "مناوباتى الأساسية"),
                  isShedcule: false,
                  gkey: cardKeyList,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    elevation: 5,
                    child: ExpansionTileCard(
                      key: cardKeyList[1],
                      onExpansionChanged: (value) async {
                        if (value) {
                          cardKeyList[0].currentState.collapse();
                          cardKeyList[2].currentState.collapse();
                        }
                        if (shiftDate == null && retryScheduleRequest == true) {
                          if (value) {
                            showDialog(
                              context: context,
                              builder: (context) => RoundedLoadingIndicator(),
                            );

                            isScheduleAvailable = await Provider.of<ShiftsData>(
                                    context,
                                    listen: false)
                                .getFirstAvailableSchedule(
                                    locator.locator<UserData>().user.id);
                            if (!isScheduleAvailable) {
                              retryScheduleRequest = false;
                            }
                            Navigator.pop(context);
                          }
                        }
                      },
                      title: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.clock,
                            color: ColorManager.primary,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          AutoSizeText(
                            getTranslated(context, "مناوباتى المجدولة"),
                            style: boldStyle,
                          ),
                        ],
                      ),
                      children: [
                        Provider.of<ShiftsData>(context).isLoading
                            ? Container()
                            : shiftDate == null
                                ? SizedBox(
                                    height: 100.h,
                                    child: Center(
                                      child: AutoSizeText(getTranslated(context,
                                          "لا يوجد جدولة لهذا المستخدم")),
                                    ),
                                  )
                                : SlideInUp(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            AutoSizeText(
                                                getTranslated(context, "من"),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        ColorManager.primary)),
                                            AutoSizeText(shiftDate
                                                .scheduleFromTime
                                                .toString()
                                                .substring(0, 11)),
                                            AutoSizeText(
                                              getTranslated(context, "إلى"),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorManager.primary),
                                            ),
                                            AutoSizeText(shiftDate
                                                .scheduleToTime
                                                .toString()
                                                .substring(0, 11)),
                                          ],
                                        ),
                                        const Divider(),
                                        FeatureScheduleShiftCard(
                                            currentIndex: 0,
                                            startTime:
                                                shiftDate.satShift.startTime,
                                            endTime: shiftDate.satShift.endTime,
                                            shiftname:
                                                shiftDate.satShift.shiftName,
                                            sitename:
                                                shiftDate.satShift.siteName,
                                            shiftDate: shiftDate),
                                        FeatureScheduleShiftCard(
                                            startTime:
                                                shiftDate.sunShift.startTime,
                                            endTime: shiftDate.sunShift.endTime,
                                            currentIndex: 1,
                                            shiftname:
                                                shiftDate.sunShift.shiftName,
                                            sitename:
                                                shiftDate.sunShift.siteName,
                                            shiftDate: shiftDate),
                                        FeatureScheduleShiftCard(
                                            startTime:
                                                shiftDate.monShift.startTime,
                                            endTime: shiftDate.monShift.endTime,
                                            currentIndex: 2,
                                            shiftname:
                                                shiftDate.monShift.shiftName,
                                            sitename:
                                                shiftDate.monShift.siteName,
                                            shiftDate: shiftDate),
                                        FeatureScheduleShiftCard(
                                            startTime:
                                                shiftDate.tuesShift.startTime,
                                            endTime:
                                                shiftDate.tuesShift.endTime,
                                            currentIndex: 3,
                                            shiftname:
                                                shiftDate.tuesShift.shiftName,
                                            sitename:
                                                shiftDate.tuesShift.siteName,
                                            shiftDate: shiftDate),
                                        FeatureScheduleShiftCard(
                                            startTime:
                                                shiftDate.wednShift.startTime,
                                            endTime:
                                                shiftDate.wednShift.endTime,
                                            currentIndex: 4,
                                            shiftname:
                                                shiftDate.wednShift.shiftName,
                                            sitename:
                                                shiftDate.wednShift.siteName,
                                            shiftDate: shiftDate),
                                        FeatureScheduleShiftCard(
                                            startTime:
                                                shiftDate.thurShift.startTime,
                                            endTime:
                                                shiftDate.thurShift.endTime,
                                            shiftname:
                                                shiftDate.thurShift.shiftName,
                                            sitename:
                                                shiftDate.thurShift.siteName,
                                            currentIndex: 5,
                                            shiftDate: shiftDate),
                                        FeatureScheduleShiftCard(
                                            startTime:
                                                shiftDate.friShift.startTime,
                                            endTime: shiftDate.friShift.endTime,
                                            currentIndex: 6,
                                            shiftname:
                                                shiftDate.friShift.shiftName,
                                            sitename:
                                                shiftDate.friShift.siteName,
                                            shiftDate: shiftDate),
                                      ],
                                    ),
                                  )
                      ],
                    ),
                  ),
                ),
                DisplayInternalUserMissions(cardKeyList)
              ],
            ),
          ),
        ));
  }
}

class FeatureScheduleShiftCard extends StatelessWidget {
  const FeatureScheduleShiftCard({
    Key key,
    @required this.shiftDate,
    this.shiftname,
    this.sitename,
    this.startTime,
    this.endTime,
    this.currentIndex,
  }) : super(key: key);

  final int currentIndex;
  final String startTime, endTime;
  final ShiftSheduleModel shiftDate;
  final String shiftname, sitename;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Card(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AutoSizeText(
                          getTranslated(context, weekDays[currentIndex]),
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: setResponsiveFontSize(15),
                              color: ColorManager.primary)),
                      Container(
                        child: AutoSizeText(
                          sitename,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: setResponsiveFontSize(13),
                          ),
                        ),
                      ),
                      AutoSizeText(
                        shiftname,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: setResponsiveFontSize(13),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: dateDataField(
                          controller: TextEditingController(
                              text: amPmChanger(int.parse(startTime))),
                          icon: Icons.alarm,
                          labelText: getTranslated(context, "من")),
                    ),
                    SizedBox(
                      width: 5.0.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: dateDataField(
                          controller: TextEditingController(
                              text: amPmChanger(int.parse(endTime))),
                          icon: Icons.alarm,
                          labelText: getTranslated(context, "إلى")),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                )
              ],
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
}

class MyInternalMissionsCard extends StatelessWidget {
  const MyInternalMissionsCard({
    Key key,
    this.startTime,
    this.endTime,
    this.currentIndex,
  }) : super(key: key);

  final int currentIndex;
  final String startTime, endTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Card(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: AutoSizeText(
                      getTranslated(context, weekDays[currentIndex]),
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: setResponsiveFontSize(15),
                          color: ColorManager.primary)),
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: dateDataField(
                          controller: TextEditingController(
                              text: amPmChanger(int.parse(startTime))),
                          icon: Icons.alarm,
                          labelText: getTranslated(context, "من")),
                    ),
                    SizedBox(
                      width: 5.0.w,
                    ),
                    Expanded(
                      flex: 1,
                      child: dateDataField(
                          controller: TextEditingController(
                              text: amPmChanger(int.parse(endTime))),
                          icon: Icons.alarm,
                          labelText: getTranslated(context, "إلى")),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5.h,
                )
              ],
            ),
          ),
          const Divider()
        ],
      ),
    );
  }
}

class ExpansionUserShiftTile extends StatelessWidget {
  const ExpansionUserShiftTile({
    this.isShedcule,
    this.gkey,
    this.title,
    Key key,
  }) : super(key: key);
  final List<GlobalKey<ExpansionTileCardState>> gkey;
  final bool isShedcule;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SlideInUp(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Card(
          elevation: 5,
          child: ExpansionTileCard(
            key: gkey[0],
            onExpansionChanged: (value) async {
              if (value) {
                gkey[1].currentState.collapse();
                gkey[2].currentState.collapse();
              }
              if (_userShift == null) {
                if (value) {
                  showDialog(
                    context: context,
                    builder: (context) => RoundedLoadingIndicator(),
                  );

                  await Provider.of<ShiftApi>(context, listen: false)
                      .getShiftByShiftId(
                    locator.locator<UserData>().user.userShiftId,
                  );
                  _userShift =
                      Provider.of<ShiftApi>(context, listen: false).userShift;
                  _timeInController.text =
                      amPmChanger(_userShift.shiftStartTime);
                  _timeOutController.text =
                      amPmChanger(_userShift.shiftEndTime);
                  _sunTimeInController.text =
                      amPmChanger(_userShift.sunShiftstTime);
                  _sunTimeOutController.text =
                      amPmChanger(_userShift.sunShiftenTime);
                  _monTimeInController.text =
                      amPmChanger(_userShift.monShiftstTime);
                  _monTimeOutController.text =
                      amPmChanger(_userShift.mondayShiftenTime);
                  _tuesTimeInController.text =
                      amPmChanger(_userShift.tuesdayShiftstTime);
                  _tuesTimeOutController.text =
                      amPmChanger(_userShift.tuesdayShiftenTime);
                  _wedTimeInController.text =
                      amPmChanger(_userShift.wednesDayShiftstTime);
                  _wedTimeOutController.text =
                      amPmChanger(_userShift.wednesDayShiftenTime);
                  _thuTimeInController.text =
                      amPmChanger(_userShift.thursdayShiftstTime);
                  _thuTimeOutController.text =
                      amPmChanger(_userShift.thursdayShiftenTime);
                  _friTimeInController.text =
                      amPmChanger(_userShift.fridayShiftstTime);
                  _friTimeOutController.text =
                      amPmChanger(_userShift.fridayShiftenTime);
                  Navigator.pop(context);
                }
              }
            },
            title: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.clock,
                  color: ColorManager.primary,
                ),
                const SizedBox(
                  width: 5,
                ),
                AutoSizeText(
                  title,
                  style: boldStyle,
                ),
              ],
            ),
            children: [
              Provider.of<ShiftApi>(context, listen: true).isLoading
                  ? Container()
                  : Container(
                      width: 300.w,
                      child: Container(
                        child: Column(
                          children: [
                            AdvancedShiftPicker(
                              timeInController: _timeInController,
                              timeOutController: _timeOutController,
                              isShiftsScreen: false,
                              weekDay: getTranslated(context, "السبت"),
                            ),
                            AdvancedShiftPicker(
                              isShiftsScreen: false,
                              weekDay: getTranslated(context, "الأحد"),
                              timeInController: _sunTimeInController,
                              timeOutController: _sunTimeOutController,
                            ),
                            AdvancedShiftPicker(
                              isShiftsScreen: false,
                              weekDay: getTranslated(context, "الأثنين"),
                              timeInController: _monTimeInController,
                              timeOutController: _monTimeOutController,
                            ),
                            AdvancedShiftPicker(
                              isShiftsScreen: false,
                              weekDay: getTranslated(context, "الثلاثاء"),
                              timeInController: _tuesTimeInController,
                              timeOutController: _tuesTimeOutController,
                            ),
                            AdvancedShiftPicker(
                              isShiftsScreen: false,
                              weekDay: getTranslated(context, "الأربعاء"),
                              timeInController: _wedTimeInController,
                              timeOutController: _wedTimeOutController,
                            ),
                            AdvancedShiftPicker(
                              isShiftsScreen: false,
                              weekDay: getTranslated(context, "الخميس"),
                              timeInController: _thuTimeInController,
                              timeOutController: _thuTimeOutController,
                            ),
                            AdvancedShiftPicker(
                              isShiftsScreen: false,
                              weekDay: getTranslated(context, "الجمعة"),
                              timeInController: _friTimeInController,
                              timeOutController: _friTimeOutController,
                            ),
                          ],
                        ),
                      ))
            ],
          ),
        ),
      ),
    );
  }
}
