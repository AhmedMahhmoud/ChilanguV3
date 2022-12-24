import 'dart:async';
import 'dart:developer';
import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/widgets/Reports/ProgressBar.dart';
import 'package:qr_users/widgets/Reports/displayReportButton.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets//XlsxExportButton.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/Reports/LateAbsence/dataTableEnd.dart';
import 'package:qr_users/widgets/Reports/LateAbsence/dataTableHeader.dart';
import 'package:qr_users/widgets/Reports/LateAbsence/dataTableRow.dart';
import 'package:qr_users/widgets/Shared/Charts/PieChart.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../Core/constants.dart';

class LateAbsenceScreen extends StatefulWidget {
  @override
  _LateAbsenceScreenState createState() => _LateAbsenceScreenState();
}

class _LateAbsenceScreenState extends State<LateAbsenceScreen> {
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
  String dateFromString = "", currentSiteName = "", dateToString = "";
  TextEditingController _dateController = TextEditingController();
  int selectedDuration;
  DateTime toDate;
  DateTime fromDate;
  bool showTable, showViewTableButton = true;
  DateTime yesterday;
  DateTime intitialDate;
  Site siteData;
  ScrollController _scrollController = ScrollController();
  var percent = 0;
  Timer timer;
  String diff;

  var isLoading = false;
  @override
  void didChangeDependencies() {
    final String fromText =
        " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
    final String toText =
        " ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.dispose();

    if (percent != 0) timer.cancel();
    super.dispose();
  }

  void initState() {
    super.initState();
    siteIdIndex = getSiteIndexBySiteID(
        Provider.of<UserData>(context, listen: false).user.userSiteId);
    if (Provider.of<UserData>(context, listen: false).user.userType != 2) {
      currentSiteName = Provider.of<SiteShiftsData>(context, listen: false)
          .siteShiftList[siteIdIndex]
          .siteName;
    }
    Provider.of<PermissionHan>(context, listen: false).initializeUserScroll();
    showTable = false;
    final now = DateTime.now();
    fromDate = DateTime(now.year, now.month,
        Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day);
    final comProv = Provider.of<CompanyData>(context, listen: false);
    intitialDate = DateTime(comProv.com.createdOn.year - 1,
        comProv.com.createdOn.month, comProv.com.createdOn.day);
    if (toDate.isBefore(fromDate)) {
      fromDate = DateTime(now.year, now.month - 1,
          Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    }

    if (fromDate.isBefore(comProv.com.createdOn)) {
      fromDate = DateTime(comProv.com.createdOn.year,
          comProv.com.createdOn.month, comProv.com.createdOn.day - 1);
    }

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    final String fromText =
        " من ${DateFormat('yMMMd').format(fromDate).toString()}";
    final String toText =
        " إلى ${DateFormat('yMMMd').format(toDate).toString()}";

    _dateController.text = "$fromText $toText";
    // getData(siteIdIndex);
  }

  void setFBvisability() {
    Provider.of<PermissionHan>(context, listen: false).setUserScrolling();
  }

  void resettFBvisability() {
    Provider.of<PermissionHan>(context, listen: false).resetUserscrolling();
  }

  loadProgressIndicator() {
    percent = 0;
    if (mounted) {
      timer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
        if (Provider.of<ReportsData>(context, listen: false).isLoading ==
            false) {
          setState(() {
            percent = 300;
          });
        }
        setState(() {
          percent += 3;
          if (percent >= 295) {
            timer.cancel();
          }
        });
      });
    }
  }

  getData(int siteIndex) async {
    int siteID;
    final UserData userProvider = Provider.of<UserData>(context, listen: false);

    if (userProvider.user.userType != 2) {
      siteID = Provider.of<SiteShiftsData>(context, listen: false)
          .siteShiftList[siteIndex]
          .siteId;
    } else {
      siteID = userProvider.user.userSiteId;
    }
    await Provider.of<ReportsData>(context, listen: false).getLateAbsenceReport(
        userProvider.user.userToken,
        siteID,
        dateFromString,
        dateToString,
        context);
  }

  int getSiteIndexBySiteID(int siteId) {
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteId == list[i].siteId) {
        return i;
      }
    }
    return 0;
  }

  int getSiteIndexBySiteName(String siteName) {
    final list =
        Provider.of<SiteShiftsData>(context, listen: false).siteShiftList;
    final int index = list.length;
    for (int i = 0; i < index; i++) {
      if (siteName == list[i].siteName) {
        return i;
      }
    }
    return -1;
  }

  int siteIdIndex = 0;
  int siteId = 0;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final comProv = Provider.of<CompanyData>(context, listen: false);
    return Consumer<ReportsData>(builder: (context, reportsData, child) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: NotificationListener(
          onNotification: (notificationInfo) {
            if (showTable) {
              if (_scrollController.hasClients) {
                if (_scrollController.position.userScrollDirection ==
                    ScrollDirection.reverse) {
                  setFBvisability();
                } else if (_scrollController.position.userScrollDirection ==
                    ScrollDirection.forward) {
                  resettFBvisability();
                }
              }
            }

            return true;
          },
          child: Scaffold(
            floatingActionButton: MultipleFloatingButtonsNoADD(),
            endDrawer: NotificationItem(),
            backgroundColor: Colors.white,
            body: Container(
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                onPanDown: (_) {
                  FocusScope.of(context).unfocus();
                },
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Header(
                          nav: false,
                          goUserMenu: false,
                          goUserHomeFromMenu: false,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SmallDirectoriesHeader(
                              Lottie.asset("resources/report.json",
                                  repeat: false),
                              getTranslated(context, "تقرير التأخير و الغياب"),
                            ),
                            Container(
                                child: FutureBuilder(
                                    future: Provider.of<ReportsData>(context,
                                            listen: true)
                                        .futureListener,
                                    builder: (context, snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return Container();
                                        case ConnectionState.done:
                                          return !reportsData
                                                  .lateAbsenceReport.isDayOff
                                              ? reportsData
                                                          .lateAbsenceReport
                                                          .lateAbsenceReportUnitList
                                                          .length !=
                                                      0
                                                  ? isLoading
                                                      ? Container()
                                                      : Visibility(
                                                          visible: showTable,
                                                          child: Row(
                                                            children: [
                                                              InkWell(
                                                                onTap: () {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return Dialog(
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0)),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              300.h,
                                                                          width:
                                                                              double.infinity,
                                                                          child:
                                                                              FadeInRight(
                                                                            child:
                                                                                Padding(padding: const EdgeInsets.all(8.0), child: ZoomIn(child: LateReportPieChart())),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  );
                                                                },
                                                                child:
                                                                    const Icon(
                                                                  FontAwesomeIcons
                                                                      .chartBar,
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                              ),
                                                              XlsxExportButton(
                                                                reportType: 1,
                                                                title: getTranslated(
                                                                    context,
                                                                    "تقرير التأخير و الغياب"),
                                                                day:
                                                                    _dateController
                                                                        .text,
                                                                site: userDataProvider
                                                                            .user
                                                                            .userType ==
                                                                        2
                                                                    ? ""
                                                                    : Provider.of<SiteShiftsData>(
                                                                            context)
                                                                        .siteShiftList[
                                                                            siteIdIndex]
                                                                        .siteName,
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                  : Container()
                                              : Container();
                                        default:
                                          return Container();
                                      }
                                    }))
                          ],
                        ),
                        Container(
                            child: Theme(
                          data: clockTheme1,
                          child: Builder(
                            builder: (context) {
                              return InkWell(
                                  onTap:
                                      yesterday.isBefore(getMinDateTime()) ||
                                              DateTime.now()
                                                      .difference(
                                                          comProv.com.createdOn)
                                                      .inDays ==
                                                  0
                                          ? null
                                          : () async {
                                              var now = DateTime.now();
                                              yesterday = DateTime(now.year,
                                                  now.month, now.day - 1);

                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return Dialog(
                                                      insetPadding:
                                                          const EdgeInsets
                                                                  .symmetric(
                                                              horizontal: 20),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0)),
                                                      child: StatefulBuilder(
                                                        builder: (context,
                                                            changeState) {
                                                          return Container(
                                                            height: 400.h,
                                                            child: Center(
                                                              child: Container(
                                                                child:
                                                                    SfDateRangePicker(
                                                                        startRangeSelectionColor: Colors
                                                                            .orange,
                                                                        endRangeSelectionColor: Colors
                                                                            .orange,
                                                                        showNavigationArrow:
                                                                            true,
                                                                        headerHeight:
                                                                            100,
                                                                        initialSelectedDate:
                                                                            intitialDate,
                                                                        minDate: now.year - comProv.com.createdOn.year >= 1
                                                                            ? DateTime(
                                                                                now.year -
                                                                                    1,
                                                                                now
                                                                                    .month,
                                                                                now
                                                                                    .day)
                                                                            : DateTime(
                                                                                now
                                                                                    .year,
                                                                                comProv
                                                                                    .com.createdOn.month,
                                                                                comProv.com.createdOn.day -
                                                                                    1),
                                                                        maxDate:
                                                                            yesterday,
                                                                        initialDisplayDate:
                                                                            fromDate,
                                                                        selectionMode: DateRangePickerSelectionMode
                                                                            .range,
                                                                        onSelectionChanged:
                                                                            (dateRangePickerSelectionChangedArgs) {
                                                                          final PickerDateRange
                                                                              val =
                                                                              dateRangePickerSelectionChangedArgs.value;
                                                                          changeState(
                                                                              () {
                                                                            final DateTime
                                                                                now =
                                                                                DateTime.now();

                                                                            if (DateTime(now.year, now.month, now.day).difference(DateTime(val.startDate.year, val.startDate.month, val.startDate.day + 31)).inDays <=
                                                                                0) {
                                                                              yesterday = DateTime(now.year, now.month, now.day - 1);
                                                                            } else {
                                                                              yesterday = DateTime(val.startDate.year, val.startDate.month, val.startDate.day + 31);
                                                                            }
                                                                          });
                                                                        },
                                                                        confirmText:
                                                                            "حفظ",
                                                                        cancelText:
                                                                            "الغاء",
                                                                        allowViewNavigation:
                                                                            true,
                                                                        selectionColor: Colors
                                                                            .orange,
                                                                        onCancel: () =>
                                                                            Navigator.pop(
                                                                                context),
                                                                        showActionButtons:
                                                                            true,
                                                                        initialSelectedRange: PickerDateRange(
                                                                            fromDate,
                                                                            toDate),
                                                                        onSubmit:
                                                                            (date) {
                                                                          final PickerDateRange
                                                                              pickerRange =
                                                                              date;

                                                                          if (pickerRange.startDate == null &&
                                                                              pickerRange.endDate == null) {
                                                                            displayToast(context,
                                                                                "يرجى تحديد تاريخ");
                                                                          } else {
                                                                            var newString =
                                                                                "";
                                                                            setState(() {
                                                                              int differanceBetweenDays = 0;

                                                                              if (pickerRange.endDate != null) {
                                                                                differanceBetweenDays = pickerRange.endDate.difference(pickerRange.startDate).inDays;
                                                                              }

                                                                              if (differanceBetweenDays > 31) {
                                                                                fromDate = pickerRange.endDate.subtract(const Duration(days: 30));

                                                                                toDate = pickerRange.endDate;
                                                                              } else {
                                                                                fromDate = pickerRange.startDate;
                                                                                toDate = pickerRange.endDate ?? pickerRange.startDate;
                                                                              }

                                                                              showTable = false;
                                                                              showViewTableButton = true;
                                                                              final String fromText = " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
                                                                              final String toText = " ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";
                                                                              newString = "$fromText $toText";
                                                                            });

                                                                            if (_dateController.text !=
                                                                                newString) {
                                                                              _dateController.text = newString;

                                                                              dateFromString = apiFormatter.format(fromDate);
                                                                              dateToString = apiFormatter.format(toDate);
                                                                            }
                                                                          }
                                                                          setState(
                                                                              () {
                                                                            yesterday = DateTime(
                                                                                DateTime.now().year,
                                                                                DateTime.now().month,
                                                                                DateTime.now().day - 1);
                                                                          });
                                                                          Navigator.pop(
                                                                              context);
                                                                        }),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ));
                                                },
                                              );
                                            },
                                  child: Container(
                                    // width: 330,
                                    width: getkDeviceWidthFactor(context, 330),
                                    child: IgnorePointer(
                                      child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: setResponsiveFontSize(15),
                                            fontWeight: FontWeight.w500),
                                        textInputAction: TextInputAction.next,
                                        controller: _dateController,
                                        decoration:
                                            kTextFieldDecorationFromTO.copyWith(
                                                hintText: getTranslated(
                                                    context, 'المدة من / إلى'),
                                                prefixIcon: const Icon(
                                                  Icons.calendar_today_rounded,
                                                  color: Colors.orange,
                                                )),
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        )),
                        const SizedBox(
                          height: 10,
                        ),
                        Provider.of<UserData>(context, listen: false)
                                        .user
                                        .userType ==
                                    3 ||
                                Provider.of<UserData>(context, listen: false)
                                        .user
                                        .userType ==
                                    4
                            ? Container(
                                // width: 330,
                                width: getkDeviceWidthFactor(context, 345),
                                child: SiteDropdown(
                                  height: 40.h,
                                  edit: true,
                                  list: Provider.of<SiteShiftsData>(context)
                                      .siteShiftList,
                                  colour: Colors.white,
                                  icon: Icons.location_on,
                                  borderColor: Colors.black,
                                  hint: getTranslated(context, "الموقع"),
                                  hintColor: Colors.black,
                                  onChange: (value) async {
                                    // debugPrint()
                                    siteIdIndex = getSiteIndexBySiteName(value);
                                    if (siteId !=
                                        Provider.of<SiteShiftsData>(context,
                                                listen: false)
                                            .siteShiftList[siteIdIndex]
                                            .siteId) {
                                      siteId = Provider.of<SiteShiftsData>(
                                              context,
                                              listen: false)
                                          .siteShiftList[siteIdIndex]
                                          .siteId;

                                      setState(() {
                                        showTable = false;
                                        showViewTableButton = true;
                                      });
                                    }
                                    debugPrint(value);
                                  },
                                  selectedvalue:
                                      Provider.of<SiteShiftsData>(context)
                                          .siteShiftList[siteIdIndex]
                                          .siteName,
                                  textColor: Colors.orange,
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 5,
                        ),
                        Visibility(
                          visible: showViewTableButton,
                          child: Expanded(
                            flex: 9,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Container(
                                    width: 400.w,
                                    height: 300.h,
                                    child: Lottie.asset(
                                        "resources/displayReport.json",
                                        fit: BoxFit.fill),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(5),
                                    width: 150.w,
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            width: 2,
                                            color: ColorManager.primary),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: InkWell(
                                      onTap: () {
                                        if (!yesterday
                                                .isBefore(getMinDateTime()) &&
                                            DateTime.now()
                                                    .difference(
                                                        comProv.com.createdOn)
                                                    .inDays !=
                                                0) {
                                          loadProgressIndicator();
                                          setState(() {
                                            getData(siteIdIndex);
                                            showTable = true;
                                            showViewTableButton = false;
                                          });
                                        }
                                      },
                                      child: const DisplayReportButton(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: FutureBuilder(
                              future: Provider.of<ReportsData>(context,
                                      listen: true)
                                  .futureListener,
                              builder: (context, snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return ProgressBar(percent, 300, 290);
                                  case ConnectionState.done:
                                    if (percent != 0) {
                                      timer.cancel();
                                    }

                                    return showTable
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                height: 10.h,
                                              ),
                                              snapshot.data == "failed"
                                                  ? const Expanded(
                                                      child:
                                                          FailiureCenteredMessage())
                                                  : snapshot.data ==
                                                          "Date is older than company date"
                                                      ? Expanded(
                                                          child: CenterMessageText(
                                                              message:
                                                                  getTranslated(
                                                                      context,
                                                                      "التاريخ قبل إنشاء الشركة")),
                                                        )
                                                      : Expanded(
                                                          child: Container(
                                                              color:
                                                                  Colors.white,
                                                              child: reportsData
                                                                          .lateAbsenceReport
                                                                          .lateAbsenceReportUnitList
                                                                          .length !=
                                                                      0
                                                                  ? Column(
                                                                      children: [
                                                                        Divider(
                                                                          thickness:
                                                                              1,
                                                                          color:
                                                                              Colors.orange[600],
                                                                        ),
                                                                        DataTableHeader(),
                                                                        Divider(
                                                                          thickness:
                                                                              1,
                                                                          color:
                                                                              Colors.orange[600],
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                Container(
                                                                          child:
                                                                              Stack(
                                                                            children: [
                                                                              ListView.builder(
                                                                                  controller: _scrollController,
                                                                                  itemCount: reportsData.lateAbsenceReport.lateAbsenceReportUnitList.length,
                                                                                  itemBuilder: (BuildContext context, int index) {
                                                                                    return DataTableRow(reportsData.lateAbsenceReport.lateAbsenceReportUnitList[index], siteIdIndex, fromDate, toDate);
                                                                                  }),
                                                                            ],
                                                                          ),
                                                                        )),
                                                                        DataTableEnd(
                                                                          lateRatio: reportsData
                                                                              .lateAbsenceReport
                                                                              .lateRatio,
                                                                          absenceRatio: reportsData.lateAbsenceReport.absentRatio == "%NaN"
                                                                              ? "%0"
                                                                              : reportsData.lateAbsenceReport.absentRatio,
                                                                          totalDeduction: reportsData
                                                                              .lateAbsenceReport
                                                                              .totalDecutionForAllUsers,
                                                                        )
                                                                      ],
                                                                    )
                                                                  : Center(
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            20.h,
                                                                        child:
                                                                            AutoSizeText(
                                                                          getTranslated(
                                                                              context,
                                                                              "لا يوجد تسجيلات بهذا الموقع"),
                                                                          maxLines:
                                                                              1,
                                                                          style: TextStyle(
                                                                              fontSize: ScreenUtil().setSp(16, allowFontScalingSelf: true),
                                                                              fontWeight: FontWeight.w700),
                                                                        ),
                                                                      ),
                                                                    )),
                                                        ),
                                            ],
                                          )
                                        : Container();
                                  default:
                                    return Container();
                                }
                              }),
                        ),
                      ],
                    ),
                    Positioned(
                      left: 5.0.w,
                      top: 5.0.h,
                      child: Container(
                        width: 50.w,
                        height: 50.h,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => NavScreenTwo(2)),
                                (Route<dynamic> route) => false);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<bool> onWillPop() {
    debugPrint("back");
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const NavScreenTwo(2)),
        (Route<dynamic> route) => false);
    return Future.value(false);
  }
}
