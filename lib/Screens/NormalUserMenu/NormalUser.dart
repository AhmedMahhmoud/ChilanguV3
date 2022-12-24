import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/NormalUserMenu/NormalUserShifts.dart';
import 'package:qr_users/Screens/NormalUserMenu/normal_user_missions.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/api.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Settings/LanguageSettings.dart';
import 'package:qr_users/widgets/UserReport/TodayUserReport.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart ';
import '../HomePage.dart';
import 'NormalUserReport.dart';
import 'NormalUserVacationRequest.dart';
import 'NormalUsersOrders.dart';
import 'ReportTile.dart';

class NormalUserMenu extends StatefulWidget {
  @override
  _NormalUserMenuState createState() => _NormalUserMenuState();
}

class _NormalUserMenuState extends State<NormalUserMenu> {
  @override
  Widget build(BuildContext context) {
    List<ReportTile> reports = [
      ReportTile(
          title: getTranslated(context, "تقرير اليوم"),
          subTitle: getTranslated(context, "تقرير الحضور / الأنصراف عن اليوم"),
          icon: Icons.calendar_today_rounded,
          onTap: () async {
            final reportData = Provider.of<ReportsData>(context, listen: false);

            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RoundedLoadingIndicator();
                });
            final String msg = await reportData.getTodayUserReport();
            Navigator.pop(context);

            return showDialog(
              context: context,
              builder: (context) {
                return TodayUserReport(
                  apiStatus: msg,
                );
              },
            );
          }),
      ReportTile(
          title: getTranslated(context, "تقرير عن فترة"),
          subTitle: getTranslated(context, "تقرير الحضور / الأنصراف عن فترة"),
          icon: Icons.calendar_today_rounded,
          onTap: () {
            goPage(context, NormalUserReport());
          }),
      ReportTile(
          title: getTranslated(context, "الطلبات"),
          subTitle: getTranslated(context, "طلب اذن / اجازة"),
          icon: Icons.person,
          onTap: () {
            goPage(
              context,
              UserVacationRequest(3, [
                getTranslated(context, "تأخير عن الحضور"),
                getTranslated(context, "انصراف مبكر")
              ], [
                getTranslated(context, "عارضة"),
                getTranslated(context, "مرضى"),
                getTranslated(context, "رصيد اجازات")
              ]),
            );
          }),
      ReportTile(
          title: getTranslated(context, "طلباتى"),
          subTitle: getTranslated(context, "متابعة حالة الطلبات"),
          icon: FontAwesomeIcons.clipboardList,
          onTap: () {
            if (Provider.of<UserHolidaysData>(context, listen: false)
                    .singleUserHoliday ==
                null) {
              Provider.of<UserHolidaysData>(context, listen: false)
                  .singleUserHoliday = [];
            } else {
              if (Provider.of<UserHolidaysData>(context, listen: false)
                  .singleUserHoliday
                  .isNotEmpty) {
                Provider.of<UserHolidaysData>(context, listen: false)
                    .singleUserHoliday
                    .clear();
              }
            }

            Provider.of<UserPermessionsData>(context, listen: false)
                .singleUserPermessions
                .clear();
            goPage(
              context,
              UserOrdersView(
                selectedOrder: getTranslated(context, "الأجازات"),
                ordersList: [
                  getTranslated(context, "الأجازات"),
                  getTranslated(context, "الأذونات")
                ],
              ),
            );
          }),
      ReportTile(
          title: getTranslated(context, "مناوباتى"),
          subTitle: getTranslated(context, "عرض مناوبات الأسبوع"),
          icon: FontAwesomeIcons.clock,
          onTap: () async {
            goPage(context, UserCurrentShifts());
          }),
      ReportTile(
          title: getTranslated(context, "مأمورياتى"),
          subTitle: getTranslated(context, "عرض المأموريات عن فترة"),
          icon: FontAwesomeIcons.briefcase,
          onTap: () async {
            goPage(context, MyMissions());
          }),
      ReportTile(
          title: getTranslated(context, "اعدادات اللغة"),
          subTitle: getTranslated(context, "ضبط اعدادات اللغة"),
          icon: FontAwesomeIcons.globe,
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) {
                return ChangeLanguage(
                    callBackFun: () {},
                    locale: Provider.of<PermissionHan>(context, listen: false)
                            .isEnglishLocale()
                        ? "En"
                        : "Ar");
              },
            );
          }),
    ];
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: Column(
            children: [
              ///Title
              Header(
                nav: false,
                goUserMenu: false,
                goUserHomeFromMenu:
                    Provider.of<UserData>(context, listen: false)
                                .user
                                .userType ==
                            0
                        ? false
                        : true,
              ),
              DirectoriesHeader(
                  ClipRRect(
                    child: Lottie.asset("resources/user.json", repeat: false),
                  ),
                  getTranslated(context, "حسابى")),
              SizedBox(
                height: 10.h,
              ),

              ///List OF SITES
              Expanded(
                  child: ListView.builder(
                      itemCount: reports.length,
                      itemBuilder: (BuildContext context, int index) {
                        return reports[index];
                      }))
            ],
          ),
        ),
      );
    });
  }

  Future<bool> onWillPop() {
    if (Provider.of<UserData>(context, listen: false).user.userType != 0) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const NavScreenTwo(0)),
          (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false);
    }
    return Future.value(false);
  }
}
