import 'dart:io';
import 'dart:math';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:qr_users/widgets/roundedAlert.dart';

import 'Widgets/display_pending_vacations.dart';

class PendingCompanyVacations extends StatefulWidget {
  const PendingCompanyVacations();

  @override
  _PendingCompanyVacationsState createState() =>
      _PendingCompanyVacationsState();
}

class _PendingCompanyVacationsState extends State<PendingCompanyVacations> {
  String comment = "";
  Future pendingHolidays;
  Future getPendingHolidays() async {
    final int comId = Provider.of<CompanyData>(context, listen: false).com.id;
    final String token =
        Provider.of<UserData>(context, listen: false).user.userToken;
    pendingHolidays = Provider.of<UserHolidaysData>(context, listen: false)
        .getPendingCompanyHolidays(comId, token);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  RefreshController refreshController =
      RefreshController(initialRefresh: false);
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    final userHolidaysData =
        Provider.of<UserHolidaysData>(context, listen: false);
    // ignore: cascade_invocations
    userHolidaysData.pageIndex = 0;
    // ignore: cascade_invocations
    userHolidaysData.isLoading = false;
    // ignore: cascade_invocations
    userHolidaysData.keepRetriving = true;
    getPendingHolidays();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          userHolidaysData.holidaysList.length >= 10) {
        // log("reached end of list");
        if (Provider.of<UserHolidaysData>(context, listen: false)
            .keepRetriving) {
          await getPendingHolidays();
        }
      }
    });
  }

  final List<GlobalKey<ExpansionTileCardState>> cardKeyList = [];
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onRefresh() async {
    final userHoliday = Provider.of<UserHolidaysData>(context, listen: false);
    // ignore: cascade_invocations
    userHoliday.pendingCompanyHolidays = [];
    // ignore: cascade_invocations
    userHoliday.pageIndex = 0;
    // ignore: cascade_invocations
    userHoliday.keepRetriving = true;

    setState(() {
      getPendingHolidays();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pendingList = Provider.of<UserHolidaysData>(context);
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        key: _scaffoldKey,
        floatingActionButton: MultipleFloatingButtonsNoADD(),
        endDrawer: NotificationItem(),
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Header(
                nav: false,
                goUserMenu: false,
                goUserHomeFromMenu: false,
              ),
              SmallDirectoriesHeader(
                Lottie.asset("resources/calender.json", repeat: false),
                getTranslated(context, "طلبات الأجازات"),
              ),
              Divider(
                endIndent: 50.w,
                color: ColorManager.primary,
              ),
              FutureBuilder(
                  future: pendingHolidays,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        pendingList.pendingCompanyHolidays.length == 0 &&
                        pendingList.keepRetriving) {
                      return Expanded(
                        child: Container(
                          color: Colors.white,
                          child: Center(
                            child: Platform.isIOS
                                ? const CupertinoActivityIndicator(
                                    radius: 20,
                                  )
                                : const CircularProgressIndicator(
                                    backgroundColor: Colors.white,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.orange),
                                  ),
                          ),
                        ),
                      );
                    } else {
                      return (Expanded(
                          child: pendingList.pendingCompanyHolidays.length == 0
                              ? SmartRefresher(
                                  onRefresh: _onRefresh,
                                  controller: refreshController,
                                  header: const WaterDropMaterialHeader(
                                    color: Colors.white,
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: Center(
                                      child: AutoSizeText(
                                    getTranslated(context,
                                        "لا يوجد اجازات لم يتم الرد عليها"),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: setResponsiveFontSize(16)),
                                    textAlign: TextAlign.center,
                                  )),
                                )
                              : SmartRefresher(
                                  onRefresh: _onRefresh,
                                  controller: refreshController,
                                  header: const WaterDropMaterialHeader(
                                    color: Colors.white,
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    itemBuilder: (context, index) {
                                      cardKeyList.add(GlobalKey(
                                          debugLabel: "index :$index"));
                                      final pending = pendingList
                                          .pendingCompanyHolidays[index];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        child: Card(
                                          child: ExpandedPendingVacation(
                                            userHolidays: pending,
                                            cardList: cardKeyList,
                                            index: index,
                                            isAdmin: true,
                                            vacationDaysCount: [
                                              pending.fromDate,
                                              pending.toDate
                                            ],
                                            onAccept: () {
                                              return showDialog(
                                                  context: context,
                                                  builder: (BuildContext ctx) {
                                                    return RoundedAlertWithComment(
                                                      onTapped: (comm) {
                                                        comment = comm;
                                                      },
                                                      hint: getTranslated(
                                                        context,
                                                        "التفاصيل",
                                                      ),
                                                      onPressed: () async {
                                                        Navigator.pop(ctx);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              RoundedLoadingIndicator(),
                                                        );
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    0), () {
                                                          cardKeyList[index]
                                                              .currentState
                                                              ?.collapse();
                                                        });
                                                        final String msg = await pendingList
                                                            .acceptOrRefusePendingVacation(
                                                                1,
                                                                pending
                                                                    .holidayNumber,
                                                                pending
                                                                    .holidayDescription,
                                                                Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .user
                                                                    .userToken,
                                                                comment,
                                                                pending
                                                                    .fromDate,
                                                                pending.toDate);
                                                        Navigator.pop(context);

                                                        if (msg ==
                                                            "Success : Updated!") {
                                                          Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "تم الموافقة بنجاح"),
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER,
                                                              backgroundColor:
                                                                  Colors.green);
                                                        } else if (msg ==
                                                            "Fail : User not found") {
                                                          displayErrorToast(
                                                              context,
                                                              "خطأ فى بيانات المستخدم");
                                                        } else if (msg ==
                                                            "Fail: holiday time out!") {
                                                          displayErrorToast(
                                                              context,
                                                              "خطأ فى الموافقة : انتهى وقت الرد");
                                                        } else if (msg ==
                                                            "Failed: there is a Permisson in this period!") {
                                                          displayErrorToast(
                                                              context,
                                                              "يوجد اذن فى هذا اليوم");
                                                        } else {
                                                          Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "خطأ في الموافقة"),
                                                              backgroundColor:
                                                                  Colors.red);
                                                        }
                                                      },
                                                      content: getTranslated(
                                                          context,
                                                          "تأكيد الموافقة على الاجازة"),
                                                      onCancel: () {},
                                                      title:
                                                          "${getTranslated(context, "الموافقة على طلب")} ${pendingList.pendingCompanyHolidays[index].userName} ",
                                                    );
                                                  });
                                            },
                                            onRefused: () {
                                              return showDialog(
                                                  context: context,
                                                  builder: (BuildContext ctx) {
                                                    return RoundedAlertWithComment(
                                                      hint: getTranslated(
                                                          context, "سبب الرفض"),
                                                      onTapped: (comm) {
                                                        comment = comm;
                                                      },
                                                      onPressed: () async {
                                                        Navigator.pop(ctx);
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) =>
                                                              RoundedLoadingIndicator(),
                                                        );
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    0), () {
                                                          cardKeyList[index]
                                                              .currentState
                                                              ?.collapse();
                                                        });
                                                        final String msg = await pendingList
                                                            .acceptOrRefusePendingVacation(
                                                                2,
                                                                pending
                                                                    .holidayNumber,
                                                                pending
                                                                    .holidayDescription,
                                                                Provider.of<UserData>(
                                                                        context,
                                                                        listen:
                                                                            false)
                                                                    .user
                                                                    .userToken,
                                                                comment,
                                                                pending
                                                                    .fromDate,
                                                                pending.toDate);
                                                        Navigator.pop(context);

                                                        if (msg ==
                                                            "Success : Updated!") {
                                                          Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "تم الرفض بنجاح"),
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER,
                                                              backgroundColor:
                                                                  Colors.green);
                                                        } else if (msg ==
                                                            "Fail : User not found") {
                                                          displayErrorToast(
                                                              context,
                                                              "خطأ فى بيانات المستخدم");
                                                        } else if (msg ==
                                                            "Fail: holiday time out!") {
                                                          displayErrorToast(
                                                              context,
                                                              "خطأ فى الرفض : انتهى وقت الرد");
                                                        } else {
                                                          displayErrorToast(
                                                              context,
                                                              "خطأ في الرفض");
                                                        }
                                                      },
                                                      content: getTranslated(
                                                        context,
                                                        "تأكيد رفض الأجازة",
                                                      ),
                                                      onCancel: () {},
                                                      title:
                                                          "${getTranslated(context, "رفض  طلب ")}${pendingList.pendingCompanyHolidays[index].userName} ",
                                                    );
                                                  });
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    itemCount: pendingList
                                        .pendingCompanyHolidays.length,
                                  ),
                                )));
                    }
                  }),
              Provider.of<UserHolidaysData>(context)
                          .pendingCompanyHolidays
                          .length !=
                      0
                  ? Provider.of<UserHolidaysData>(context).paginatedIsLoading
                      ? Column(
                          children: [
                            const Center(
                                child: CupertinoActivityIndicator(
                              radius: 15,
                            )),
                            Container(
                              height: 30,
                            )
                          ],
                        )
                      : Container()
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
