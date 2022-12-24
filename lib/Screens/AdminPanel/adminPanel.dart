import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_permessions.dart';
import 'package:qr_users/Screens/AdminPanel/pending_company_vacations.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SuperAdmin/Screen/super_company_pie_chart.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/AttendProovReport.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/SiteAdmin/site_admin_users_screen.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UsersScreen.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';

import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/ShiftsData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import '../../main.dart';

class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

RefreshController refreshController = RefreshController(initialRefresh: false);

class _AdminPanelState extends State<AdminPanel> {
  @override
  // void _onRefresh() async {
  //   final userDataProvider = Provider.of<UserData>(context, listen: false);
  //   await Provider.of<UserPermessionsData>(context, listen: false)
  //       .getPendingCompanyPermessions(
  //           Provider.of<CompanyData>(context, listen: false).com.id,
  //           userDataProvider.user.userToken);
  //   await Provider.of<UserHolidaysData>(context, listen: false)
  //       .getPendingCompanyHolidays(
  //           Provider.of<CompanyData>(context, listen: false).com.id,
  //           userDataProvider.user.userToken);

  //   refreshController.refreshCompleted();
  // }

  Widget build(BuildContext context) {
    // final userDataProvider = Provider.of<UserData>(context, listen: false);

    SystemChrome.setEnabledSystemUIOverlays([]);
    return Consumer<MemberData>(builder: (context, memberData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          floatingActionButton: MultipleFloatingButtonsNoADD(),
          endDrawer: NotificationItem(),
          body: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ///Title
                      Header(
                        nav: false,
                        goUserMenu: false,
                        goUserHomeFromMenu: true,
                      ),
                      DirectoriesHeader(
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60.0),
                              child: Lottie.asset("resources/adminPanel.json",
                                  repeat: false),
                            ),
                          ),
                          getTranslated(context, "لوحة التحكم")),
                      SizedBox(
                        height: 20.h,
                      ),

                      ///List OF SITES
                      Expanded(
                          child: ListView(children: [
                        AdminPanelTile(
                            title: getTranslated(context, "المستخدمين"),
                            subTitle:
                                getTranslated(context, "ادارة المستخدمين"),
                            icon: Icons.person,
                            onTap: () {
                              goPage(
                                context,
                                UsersScreen(-1, false, "", true),
                              );
                            }),
                        AdminPanelTile(
                          title: getTranslated(context, "طلبات الأذونات"),
                          subTitle: getTranslated(
                              context, "طلبات الأذونات للمستخدمين"),
                          icon: FontAwesomeIcons.solidCalendarCheck,
                          onTap: () {
                            goPage(
                              context,
                              const PendingCompanyPermessions(),
                            );
                          },
                        ),
                        AdminPanelTile(
                          title: getTranslated(context, "طلبات الأجازات"),
                          subTitle: getTranslated(
                              context, "طلبات الأجازات للمستخدمين"),
                          icon: FontAwesomeIcons.calendarDay,
                          onTap: () {
                            goPage(
                              context,
                              const PendingCompanyVacations(),
                            );
                          },
                        ),
                        InkWell(
                          onTap: () {
                            goPage(
                              context,
                              AttendProofReport(),
                            );
                          },
                          child: Card(
                            elevation: 3,
                            child: ListTile(
                              trailing: Image.asset(
                                "resources/attend_proof_icon.png",
                                width: 50.w,
                                height: 50.h,
                              ),
                              title: Container(
                                height: 20.h,
                                child: AutoSizeText(
                                  getTranslated(context, "إثبات الحضور"),
                                  maxLines: 1,
                                ),
                              ),
                              subtitle: Container(
                                height: 20.h,
                                child: AutoSizeText(
                                  getTranslated(context, "إدارة إثبات الحضور"),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<bool> onWillPop() {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => NavScreenTwo(0)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}

class ReportTile extends StatelessWidget {
  final String title;
  final String subTitle;
  final icon;
  final onTap;
  const ReportTile({this.title, this.subTitle, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        trailing: Icon(
          icon,
          size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
        onTap: onTap,
        title: Container(
          height: 20,
          child: AutoSizeText(
            title,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        subtitle: Container(
          height: 20,
          child: AutoSizeText(
            subTitle,
            maxLines: 1,
            textAlign: TextAlign.right,
          ),
        ),
        leading: Icon(
          locator.locator<PermissionHan>().isEnglishLocale()
              ? Icons.chevron_left
              : Icons.chevron_right,
          size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
      ),
    );
  }
}

class AdminPanelTile extends StatelessWidget {
  final String title;
  final String subTitle;
  // final String requestsCount;
  final icon;
  final onTap;
  const AdminPanelTile({
    this.title,
    this.subTitle,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: ListTile(
        trailing: Icon(
          icon,
          size: ScreenUtil().setSp(35, allowFontScalingSelf: true),
          color: Colors.orange,
        ),
        onTap: onTap,
        title: Container(
          height: 20.h,
          child: AutoSizeText(
            title,
            maxLines: 1,
          ),
        ),
        subtitle: Container(
          height: 20.h,
          child: AutoSizeText(
            subTitle,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}
