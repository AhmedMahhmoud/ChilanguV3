import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/DailyReportScreen.dart';

import 'package:qr_users/Screens/SystemScreens/SystemGateScreens/NavScreenPartTwo.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';

import 'package:qr_users/services/VacationData.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets//XlsxExportButton.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/DropDown.dart';
import 'package:qr_users/widgets/Shared/Charts/PieChart.dart';
import 'package:qr_users/widgets/Shared/Charts/UserReportPieChart.dart';
import 'package:qr_users/widgets/Shared/LoadingIndicator.dart';
import 'package:qr_users/widgets/Shared/centerMessageText.dart';

import 'package:qr_users/widgets/UserReport/UserReportDataTable.dart';
import 'package:qr_users/widgets/UserReport/UserReportDataTableEnd.dart';
import 'package:qr_users/widgets/UserReport/UserReportTableHeader.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../services/Reports/Services/report_data.dart';
import 'package:intl/intl.dart';

import 'LateCommersScreen.dart';

class UserAttendanceReportScreen extends StatefulWidget {
  final String name, id;
  final String reportName;
  final int siteId;
  final DateTime userFromDate, userToDate;
  // getUserReportUnits
  const UserAttendanceReportScreen(
      {this.name,
      this.siteId,
      this.id,
      this.userFromDate,
      this.userToDate,
      this.reportName});

  @override
  _UserAttendanceReportScreenState createState() =>
      _UserAttendanceReportScreenState();
}

class _UserAttendanceReportScreenState
    extends State<UserAttendanceReportScreen> {
  TextEditingController _dateController = TextEditingController();

  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<SearchMember>> key = new GlobalKey();

  DateTime toDate;
  DateTime fromDate;

  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  String dateToString = "";
  String dateFromString = "";
  String fromText;
  String selectedId = "";
  String toText;
  Site siteData;
  bool showSearchIcon = true;
  DateTime yesterday;
  bool datePickerPeriodAvailable(DateTime currentDate, DateTime val) {
    debugPrint("val $val");
    final DateTime maxDate = currentDate.add(const Duration(days: 31));
    final DateTime minDate = currentDate.subtract(const Duration(days: 31));

    if (val.isBefore(maxDate) && val.isAfter(minDate)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void didChangeDependencies() {
    fromText =
        " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
    toText =
        " ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";
    _dateController.text = "$fromText $toText";

    super.didChangeDependencies();
  }

  Future future;
  @override
  void initState() {
    Provider.of<ReportsData>(context, listen: false).futureListener = future;
    showSearchIcon = true;
    final userProv = Provider.of<UserData>(context, listen: false).user;
    final DateTime companyDate =
        Provider.of<CompanyData>(context, listen: false).com.createdOn;
    if (userProv.userType == 2) {
      siteId = userProv.userSiteId;
    } else {
      siteId = Provider.of<SiteShiftsData>(context, listen: false)
          .siteShiftList[0]
          .siteId;
    }

    super.initState();
    debugPrint("id $widget.id");
    final now = DateTime.now();
    selectedId = widget.id;
    toDate = DateTime(now.year, now.month, now.day - 1);
    fromDate = DateTime(now.year, now.month,
        Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    Provider.of<MemberData>(context, listen: false).loadingSearch = false;
    fromDate = DateTime(now.year, now.month,
        Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    toDate = DateTime(now.year, now.month, now.day - 1);
    yesterday = DateTime(now.year, now.month, now.day - 1);
    final comProv = Provider.of<CompanyData>(context, listen: false);

    if (toDate.isBefore(fromDate)) {
      fromDate = DateTime(now.year, now.month - 1,
          Provider.of<CompanyData>(context, listen: false).com.legalComDate);
    }

    if (fromDate.isBefore(comProv.com.createdOn)) {
      fromDate = DateTime(comProv.com.createdOn.year,
          comProv.com.createdOn.month, comProv.com.createdOn.day - 1);
    }
    if (widget.userFromDate != null && widget.userToDate != null) {
      fromDate = widget.userFromDate;
      toDate = widget.userToDate;
    }
    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    if (widget.name != "") {
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      _nameController.text = widget.name;
      debugPrint("widget.siteId${widget.siteId}");
      siteIdIndex = widget.siteId;
      Provider.of<ReportsData>(context, listen: false).getUserReportUnits(
          userProv.userToken,
          widget.id,
          formatter.format(fromDate),
          formatter.format(toDate),
          context);
    } else {
      Provider.of<ReportsData>(context, listen: false).userAttendanceReport =
          new UserAttendanceReport(
              userAttendListUnits: [],
              totalAbsentDay: 0,
              totalLateDay: 0,
              totalLateDuration: "",
              totalLateDeduction: -1,
              isDayOff: 0,
              totalDeduction: 0,
              totalDeductionAbsent: 0,
              totalOfficialVacation: 0);
    }
  }

  searchInList(String value, int siteId, int companyId) async {
    if (value.isNotEmpty) {
      await Provider.of<MemberData>(context, listen: false).searchUsersList(
          value,
          Provider.of<UserData>(context, listen: false).user.userToken,
          siteId,
          companyId,
          context);
      focusNode.requestFocus();
    } else {
      Provider.of<MemberData>(context, listen: false).resetUsers();
    }
  }

  int getSiteId(String siteName) {
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

  String msg = "";
  int siteId = 0;
  int siteIdIndex = 0;
  final focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final userToken = Provider.of<UserData>(context, listen: false);
    final comData = Provider.of<CompanyData>(context, listen: false).com;
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    final reportsData = Provider.of<ReportsData>(context, listen: false);
    final userDataProvider = Provider.of<UserData>(context, listen: false);
    final siteProv = Provider.of<SiteShiftsData>(context, listen: false);

    return WillPopScope(
      onWillPop: onWillPop,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          // _nameController.text == ""
          //     ? FocusScope.of(context).unfocus()
          //     : SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          backgroundColor: Colors.white,
          body: Container(
            child: Stack(
              alignment: Alignment.center,
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
                          Lottie.asset("resources/report.json", repeat: false),
                          getTranslated(context, "تقرير حضور مستخدم"),
                        ),
                        Container(
                            child: FutureBuilder(
                                future: Provider.of<ReportsData>(context,
                                        listen: false)
                                    .futureListener,
                                builder: (context, snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Container();
                                    case ConnectionState.done:
                                      msg = snapshot.data;
                                      return reportsData.userAttendanceReport
                                                      .isDayOff ==
                                                  0 ||
                                              reportsData
                                                      .userAttendanceReport
                                                      .userAttendListUnits
                                                      .length !=
                                                  0
                                          ? reportsData.userAttendanceReport
                                                  .userAttendListUnits.isEmpty
                                              ? Container()
                                              : Row(
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return Dialog(
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10.0)),
                                                              child: Container(
                                                                color: Colors
                                                                    .transparent,
                                                                height: 300.h,
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    FadeInRight(
                                                                  child: Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child: ZoomIn(
                                                                          child:
                                                                              UserReportPieChart())),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: const Icon(
                                                        FontAwesomeIcons
                                                            .chartBar,
                                                        color: Colors.orange,
                                                      ),
                                                    ),
                                                    XlsxExportButton(
                                                      reportType: 2,
                                                      title: getTranslated(
                                                          context,
                                                          "تقرير حضور مستخدم"),
                                                      day: _dateController.text,
                                                      userName:
                                                          _nameController.text,
                                                      site: userDataProvider
                                                                  .user
                                                                  .userType ==
                                                              2
                                                          ? ""
                                                          : Provider.of<
                                                                      SiteShiftsData>(
                                                                  context)
                                                              .siteShiftList[
                                                                  siteIdIndex]
                                                              .siteName,
                                                    ),
                                                  ],
                                                )
                                          : Container();

                                    default:
                                      return Container();
                                  }
                                }))
                      ],
                    ),
                    Expanded(
                        child: Column(
                      children: [
                        Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                child: Theme(
                              data: clockTheme1,
                              child: Builder(
                                builder: (context) {
                                  return InkWell(
                                      onTap:
                                          yesterday.isBefore(
                                                      getMinDateTime()) ||
                                                  DateTime.now()
                                                          .difference(
                                                              comData.createdOn)
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
                                                                  horizontal:
                                                                      20),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.0)),
                                                          child:
                                                              StatefulBuilder(
                                                            builder: (context,
                                                                changeState) {
                                                              return Container(
                                                                height: 400.h,
                                                                child: Center(
                                                                  child:
                                                                      Container(
                                                                    child: SfDateRangePicker(
                                                                        startRangeSelectionColor: Colors.orange,
                                                                        endRangeSelectionColor: Colors.orange,
                                                                        showNavigationArrow: true,
                                                                        headerHeight: 100,
                                                                        initialSelectedDate: fromDate,
                                                                        minDate: DateTime.now().year - Provider.of<CompanyData>(context, listen: false).com.createdOn.year >= 1 ? DateTime(DateTime.now().year - 1, DateTime.now().month, DateTime.now().day) : DateTime(DateTime.now().year, Provider.of<CompanyData>(context, listen: false).com.createdOn.month, Provider.of<CompanyData>(context, listen: false).com.createdOn.day - 1),
                                                                        maxDate: yesterday,
                                                                        initialDisplayDate: fromDate,
                                                                        selectionMode: DateRangePickerSelectionMode.range,
                                                                        onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                                                                          final PickerDateRange
                                                                              val =
                                                                              dateRangePickerSelectionChangedArgs.value;
                                                                          changeState(
                                                                              () {
                                                                            final DateTime
                                                                                now =
                                                                                DateTime.now();

                                                                            if (DateTime(now.year, now.month, now.day).difference(DateTime(val.startDate.year, val.startDate.month, val.startDate.day + 31)).inDays <
                                                                                0) {
                                                                              yesterday = DateTime(now.year, now.month, now.day - 1);
                                                                            } else {
                                                                              yesterday = DateTime(val.startDate.year, val.startDate.month, val.startDate.day + 31);
                                                                            }
                                                                          });
                                                                        },
                                                                        confirmText: "حفظ",
                                                                        cancelText: "الغاء",
                                                                        allowViewNavigation: true,
                                                                        selectionColor: Colors.orange,
                                                                        onCancel: () => Navigator.pop(context),
                                                                        showActionButtons: true,
                                                                        initialSelectedRange: PickerDateRange(fromDate, toDate),
                                                                        onSubmit: (date) async {
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
                                                                          if (selectedId !=
                                                                              null) {
                                                                            Provider.of<ReportsData>(context, listen: false).getUserReportUnits(
                                                                                userToken.user.userToken,
                                                                                selectedId,
                                                                                dateFromString,
                                                                                dateToString,
                                                                                context);
                                                                          }

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
                                        width:
                                            getkDeviceWidthFactor(context, 330),
                                        child: IgnorePointer(
                                          child: TextFormField(
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize:
                                                    setResponsiveFontSize(15),
                                                fontWeight: FontWeight.w500),
                                            textInputAction:
                                                TextInputAction.next,
                                            controller: _dateController,
                                            decoration:
                                                kTextFieldDecorationFromTO
                                                    .copyWith(
                                                        hintText: getTranslated(
                                                            context,
                                                            'المدة من / إلى'),
                                                        prefixIcon: const Icon(
                                                          Icons
                                                              .calendar_today_rounded,
                                                          color: Colors.orange,
                                                        )),
                                          ),
                                        ),
                                      ));
                                },
                              ),
                            )),
                          ],
                        )),
                        SizedBox(
                          height: 10.h,
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
                                width: 360.w,
                                child: SiteDropdown(
                                  height: 40,
                                  edit: true,
                                  list: Provider.of<SiteShiftsData>(context)
                                      .siteShiftList,
                                  colour: Colors.white,
                                  icon: Icons.location_on,
                                  borderColor: Colors.black,
                                  hint: getTranslated(context, "الموقع"),
                                  hintColor: Colors.black,
                                  onChange: (value) {
                                    // debugPrint()

                                    siteIdIndex = getSiteId(value);
                                    if (siteId !=
                                        siteProv.siteShiftList[siteIdIndex]
                                            .siteId) {
                                      _nameController.text = "";
                                      siteId = siteProv
                                          .siteShiftList[siteIdIndex].siteId;

                                      setState(() {});
                                    }
                                  },
                                  selectedvalue: siteProv
                                      .siteShiftList[siteIdIndex].siteName,
                                  textColor: Colors.orange,
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 10.h,
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 340.w,
                              child: Provider.of<MemberData>(context)
                                      .loadingSearch
                                  ? const LoadingIndicator()
                                  : searchTextField =
                                      AutoCompleteTextField<SearchMember>(
                                      key: key,
                                      clearOnSubmit: false,
                                      focusNode: focusNode,
                                      controller: _nameController,
                                      suggestionsAmount: 100,
                                      suggestions:
                                          Provider.of<MemberData>(context)
                                              .userSearchMember,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(16,
                                              allowFontScalingSelf: true),
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500),
                                      decoration:
                                          kTextFieldDecorationFromTO.copyWith(
                                              hintStyle: TextStyle(
                                                  fontSize: ScreenUtil().setSp(
                                                      16,
                                                      allowFontScalingSelf:
                                                          true),
                                                  color: Colors.grey.shade700,
                                                  fontWeight: FontWeight.w500),
                                              hintText: getTranslated(
                                                  context, 'الأسم'),
                                              prefixIcon: const Icon(
                                                Icons.person,
                                                color: Colors.orange,
                                              )),
                                      itemFilter: (item, query) {
                                        return item.username
                                            .toLowerCase()
                                            .contains(query.toLowerCase());
                                      },
                                      itemSorter: (a, b) {
                                        return a.username.compareTo(b.username);
                                      },
                                      textSubmitted: (data) {
                                        setState(() {
                                          showSearchIcon = false;
                                          searchInList(
                                              _nameController.text,
                                              userDataProvider.user.userType ==
                                                      2
                                                  ? userDataProvider
                                                      .user.userSiteId
                                                  : siteId,
                                              Provider.of<CompanyData>(context,
                                                      listen: false)
                                                  .com
                                                  .id);
                                        });
                                        debugPrint("print start");
                                      },
                                      textInputAction: TextInputAction.search,
                                      itemSubmitted: (item) async {
                                        if (_nameController.text !=
                                            item.username) {
                                          setState(() {
                                            searchTextField.textField.controller
                                                .text = item.username;
                                            showSearchIcon = false;
                                          });
                                          selectedId = item.id;

                                          await Provider.of<ReportsData>(
                                                  context,
                                                  listen: false)
                                              .getUserReportUnits(
                                                  userToken.user.userToken,
                                                  item.id,
                                                  dateFromString,
                                                  dateToString,
                                                  context);
                                        }
                                      },
                                      itemBuilder: (context, item) {
                                        // ui for the autocompelete row
                                        return Column(
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  width: 10.w,
                                                ),
                                                Container(
                                                  height: 20.h,
                                                  child: AutoSizeText(
                                                    item.username,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(16,
                                                                allowFontScalingSelf:
                                                                    true),
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              color: Colors.grey,
                                              thickness: 1,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                            ),
                            Provider.of<MemberData>(context).loadingSearch
                                ? Container()
                                : PositionedDirectional(
                                    end: 10.w,
                                    top: 12.h,
                                    child: showSearchIcon
                                        ? InkWell(
                                            onTap: () {
                                              if (_nameController.text.length <
                                                  3) {
                                                Fluttertoast.showToast(
                                                    msg: getTranslated(context,
                                                        "يجب ان لا يقل البحث عن 3 احرف"),
                                                    backgroundColor: Colors.red,
                                                    gravity:
                                                        ToastGravity.CENTER);
                                              } else {
                                                setState(() {
                                                  showSearchIcon = false;
                                                  searchInList(
                                                      _nameController.text,
                                                      userDataProvider.user
                                                                  .userType ==
                                                              2
                                                          ? userDataProvider
                                                              .user.userSiteId
                                                          : siteId,
                                                      Provider.of<CompanyData>(
                                                              context,
                                                              listen: false)
                                                          .com
                                                          .id);
                                                });
                                              }
                                            },
                                            child: Icon(
                                              Icons.search,
                                              color: ColorManager.primary,
                                            ),
                                          )
                                        : InkWell(
                                            onTap: () {
                                              setState(() {
                                                _nameController.clear();
                                                showSearchIcon = true;
                                              });
                                            },
                                            child: const Icon(
                                              FontAwesomeIcons.times,
                                              color: Colors.orange,
                                            ),
                                          ))
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        _nameController.text != ""
                            ? Expanded(
                                child: FutureBuilder(
                                    future: Provider.of<ReportsData>(context)
                                        .futureListener,
                                    builder: (context, snapshot) {
                                      switch (snapshot.connectionState) {
                                        case ConnectionState.waiting:
                                          return Container(
                                            color: Colors.white,
                                            child: Center(
                                              child: Platform.isIOS
                                                  ? const CupertinoActivityIndicator()
                                                  : const CircularProgressIndicator(
                                                      backgroundColor:
                                                          Colors.white,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.orange),
                                                    ),
                                            ),
                                          );
                                        case ConnectionState.done:
                                          log("response ${snapshot.data.toString()}");
                                          if (_nameController.text.isEmpty) {
                                            return Container();
                                          }
                                          return snapshot.data == "failed"
                                              ? const FailiureCenteredMessage()
                                              : snapshot.data == "dayOff"
                                                  ? CenterMessageText(
                                                      message: getTranslated(
                                                          context,
                                                          "لا يوجد تسجيلات : عطلة اسبوعية"))
                                                  : reportsData
                                                              .userAttendanceReport
                                                              .userAttendListUnits
                                                              .length !=
                                                          0
                                                      ? Container(
                                                          color: Colors.white,
                                                          child: Column(
                                                            children: [
                                                              Divider(
                                                                  thickness: 1,
                                                                  color: Colors
                                                                          .orange[
                                                                      600]),
                                                              UserReportTableHeader(),
                                                              Divider(
                                                                  thickness: 1,
                                                                  color: Colors
                                                                          .orange[
                                                                      600]),
                                                              Expanded(
                                                                  child: Container(
                                                                      child: snapshot.data == "user created after period"
                                                                          ? Container(
                                                                              child: Center(
                                                                                child: AutoSizeText(
                                                                                    getTranslated(
                                                                                      context,
                                                                                      "المستخدم لم يكن مقيدا فى هذة الفترة",
                                                                                    ),
                                                                                    style: boldStyle),
                                                                              ),
                                                                            )
                                                                          : ListView.builder(
                                                                              itemCount: reportsData.userAttendanceReport.userAttendListUnits.length,
                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                return UserReportDataTableRow(reportsData.userAttendanceReport.userAttendListUnits[index]);
                                                                              }))),
                                                              snapshot.data ==
                                                                      "user created after period"
                                                                  ? Container()
                                                                  : UserReprotDataTableEnd(
                                                                      reportsData
                                                                          .userAttendanceReport)
                                                            ],
                                                          ),
                                                        )
                                                      : Row(
                                                          children: [
                                                            Expanded(
                                                                child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  height: 20,
                                                                  child:
                                                                      AutoSizeText(
                                                                    getTranslated(
                                                                      context,
                                                                      "لا يوجد تسجيلات بهذا المستخدم",
                                                                    ),
                                                                    maxLines: 1,
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontSize: ScreenUtil().setSp(
                                                                            16,
                                                                            allowFontScalingSelf:
                                                                                true),
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                ),
                                                              ],
                                                            )),
                                                          ],
                                                        );

                                        default:
                                          return Container();
                                      }
                                    }),
                              )
                            : Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 20,
                                        child: AutoSizeText(
                                          getTranslated(context,
                                              "برجاء اختيار اسم المستخدم"),
                                          maxLines: 1,
                                          style: TextStyle(
                                              color: Colors.orange,
                                              fontSize: ScreenUtil().setSp(16,
                                                  allowFontScalingSelf: true),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                      ],
                    ))
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
                        widget.name != ""
                            ? Navigator.pop(context)
                            : Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const NavScreenTwo(2)),
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
    );
  }

  Future<bool> onWillPop() {
    log(widget.name);
    if (widget.name != "") {
      if (widget.reportName == "daily report") {
        Navigator.pop(context);
      } else {
        goPage(context, LateAbsenceScreen());
      }
    } else {
      goPageReplacment(context, const NavScreenTwo(2));
    }
    return Future.value(false);
  }
}

bool isDateBetweenTheRange(
    Vacation vacation, DateTime filterFromDate, DateTime filterToDate) {
  return ((filterFromDate.isBefore(vacation.vacationDate) ||
          (vacation.vacationDate.year == filterFromDate.year &&
              vacation.vacationDate.day == filterFromDate.day &&
              vacation.vacationDate.month == filterFromDate.month)) &&
      (filterToDate.isAfter(vacation.vacationDate) ||
          (vacation.vacationDate.year == filterToDate.year &&
              vacation.vacationDate.day == filterToDate.day &&
              vacation.vacationDate.month == filterToDate.month)));
}
