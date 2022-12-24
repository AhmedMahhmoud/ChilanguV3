import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/RadioButtonWidget.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/MemberData/MemberData.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserMissions/user_missions.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/services/user_data.dart';
import 'package:qr_users/widgets/CompanySettings/OutsideVac/header.dart';
import 'package:qr_users/widgets/CompanySettings/OutsideVac/outside_vac_display.dart';
import 'package:qr_users/widgets/CompanySettings/OutsideVac/outside_vac_dropdown.dart';
import 'package:qr_users/widgets/CompanySettings/OutsideVac/outside_vacation_radio_buttons.dart';
import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/CompanyMissions/sites_missions.dart';
import 'package:qr_users/widgets/Shared/Picker/range_picker.dart';
import 'package:qr_users/widgets/UserFullData/user_floating_button_permVacations.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../Core/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ignore: must_be_immutable
class OutsideVacation extends StatefulWidget {
  final Member member;
  int radioValue;
  final List<String> permessionTitles;
  final List<String> holidayTitles;
  OutsideVacation(
      this.member, this.radioValue, this.permessionTitles, this.holidayTitles);
  @override
  _OutsideVacationState createState() => _OutsideVacationState();
}

var selectedAction = "عارضة";
var selectedMission;
var sleectedMember;
String selectedReason;
String selectedPermession;
DateTime toDate;
String toText;
String fromText;
String missionFromText;
String missionToText;
DateTime fromDate;

DateTime missionFromDate;
DateTime missionToDate;
DateTime yesterday, tomorrow, _today;
TextEditingController timeOutController = TextEditingController();
String dateToString = "";
String dateFromString = "";
String newString = "";
String missionString = "";
List<String> missions;
TimeOfDay toPicked;
String dateDifference;
String formattedTime;
String _selectedDateString;
Future userHoliday;
Future userPermession;
Future userMission;
TextEditingController externalMissionController = TextEditingController();

class _OutsideVacationState extends State<OutsideVacation> {
  bool isPicked = false;

  TextEditingController _dateController = TextEditingController();
  TextEditingController _missionDateController = TextEditingController();
  List<DateTime> picked = [];

  TextEditingController _nameController = TextEditingController();
  @override
  void didChangeDependencies() {
    missions = [
      getTranslated(context, "داخلية"),
      getTranslated(context, "خارجية")
    ];
    super.didChangeDependencies();
  }

  void _updateMissionRadio(v) => setState(() {
        widget.radioValue = v;
      });
  void _updatePermRadio(v) => setState(() {
        _today = DateTime.now();
        widget.radioValue = v;
      });
  void _vacDropdownFun(v) {
    setState(() {
      selectedReason = v;

      if (v != getTranslated(context, "عارضة")) {
        fromDate = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
        _dateController.text = "";
        tomorrow = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
        _today = DateTime.now();
        toDate = tomorrow;
      }
    });
  }

  void _updateVacRadio(v) => setState(() {
        fromDate = widget.radioValue == 3 ? DateTime.now() : tomorrow;
        widget.radioValue = v;
      });
  void _saveVacationFun() {
    if (_dateController.text.isNotEmpty) {
      final DateTime now = DateTime.now();
      final DateFormat format = DateFormat('dd-M-yyyy'); //4-2-2021
      final String formatted = format.format(now);
      Provider.of<UserHolidaysData>(context, listen: false)
          .addHoliday(
              UserHolidays(
                  holidayDescription: commentController.text,
                  fromDate: fromDate,
                  toDate: toDate ?? fromDate,
                  holidayType: selectedReason == getTranslated(context, "عارضة")
                      ? 1
                      : selectedReason == getTranslated(context, "مرضى")
                          ? 2
                          : 3,
                  holidayStatus: 3),
              Provider.of<UserData>(context, listen: false).user.userToken,
              widget.member.id)
          .then((value) async {
        log(value.toString());
        if (value == Holiday.Success) {
          Fluttertoast.showToast(
                  msg: getTranslated(context, "تم الإضافة بنجاح"),
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.green)
              .whenComplete(() => Navigator.pop(context));
        } else if (value == Holiday.USER_ALREADY_ATTENDED) {
          displayErrorToast(context, "لا يمكن وضع الأجازة : تم الحضور");
        } else if (value == Holiday.External_Mission_InThis_Period) {
          displayErrorToast(
              context, "لا يمكن وضع الأجازة : يوجد مأمورية خارجية");
        } else if (value == Holiday.Holiday_Approved_InThis_Period) {
          displayErrorToast(
              context, "يوجد اجازة تم الموافقة عليها فى هذه الفترة");
        } else if (value == Holiday.Internal_Mission_InThis_Period) {
          displayErrorToast(
              context, "لا يمكن وضع الاجازة : يوجد مأمورية داخلية");
        } else if (value == Holiday.Permession_InThis_Period) {
          displayToast(context, "لا يمكن طلب الاجازة : يوجد طلب اذن");
        } else if (value == Holiday.Another_Holiday_NOT_APPROVED) {
          displayErrorToast(
              context, "يوجد اجازة لم يتم الموافقة عليها فى هذه الفترة");
        } else if (value == Holiday.Daily_limit_Reached) {
          displayErrorToast(context, "requests daily exceed");
        } else {
          errorToast(context);
        }
      });
    } else {
      displayErrorToast(context, "قم بأدخال مدة الأجازة");
    }
  }

  datePickerFun(PickerDateRange dateRange, bool isMission) async {
    setState(() {
      if (!isMission) {
        _today = dateRange.startDate;
        tomorrow = dateRange.startDate;
        fromDate = dateRange.startDate;
        toDate = dateRange.endDate ?? dateRange.startDate;
        dateDifference = (toDate.difference(fromDate).inDays + 1).toString();

        fromText =
            " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
        toText =
            "  ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";
        newString = "$fromText $toText";

        if (_dateController.text != newString) {
          _dateController.text = newString;

          dateFromString = apiFormatter.format(fromDate);
          dateToString = apiFormatter.format(toDate);
        }
      } else {
        missionFromDate = dateRange.startDate;
        missionToDate = dateRange.endDate ?? dateRange.startDate;
        missionFromText =
            " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(missionFromDate).toString()}";
        missionToText =
            "  ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(missionToDate).toString()}";
        missionString = "$missionFromText $missionToText";
        if (_missionDateController.text != missionString) {
          _missionDateController.text = missionString;

          dateFromString = apiFormatter.format(missionFromDate);
          dateToString = apiFormatter.format(missionToDate);
        }
      }
    });

    Navigator.pop(context);
  }

  @override
  void initState() {
    final UserHolidaysData _userHolidayData =
        Provider.of<UserHolidaysData>(context, listen: false);
    final UserPermessionsData _userPermessionData =
        Provider.of<UserPermessionsData>(context, listen: false);
    Provider.of<SiteData>(context, listen: false).setSiteValue("كل المواقع");
    _userPermessionData.isLoading = false;
    _userHolidayData.loadingHolidaysDetails = false;
    Provider.of<PermissionHan>(context, listen: false).initializeUserScroll();
    _userHolidayData.isLoading = false;
    _userPermessionData.permessionDetailLoading = false;
    isPicked = false;
    Provider.of<MissionsData>(context, listen: false).isLoading = false;
    // userMission = getSingleUserMission();
    _userHolidayData.singleUserHoliday.clear();
    Provider.of<UserPermessionsData>(context, listen: false)
        .singleUserPermessions
        .clear();
    Provider.of<MissionsData>(context, listen: false)
        .singleUserMissionsList
        .clear();
    selectedMission =
        Provider.of<PermissionHan>(context, listen: false).isEnglishLocale()
            ? "Internal"
            : "داخلية";
    selectedReason = widget.holidayTitles.first;
    selectedPermession = widget.permessionTitles.first;
    final now = DateTime.now();
    fromText = "";
    toText = "";
    _missionDateController.clear();
    _dateController.clear();
    commentController.text = "";
    timeOutController.text = "";
    externalMissionController.text = "";
    toPicked = (intToTimeOfDay(0));

    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    tomorrow = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    missionFromDate = tomorrow;
    missionToDate = tomorrow;
    fromDate = now;
    _selectedDateString = now.toString();
    yesterday = DateTime(now.year + 2, DateTime.december, 31);
    _today = now;

    super.initState();
  }

  var selectedVal = "كل المواقع";
  @override
  Widget build(BuildContext context) {
    final SiteData prov = Provider.of<SiteData>(context, listen: false);
    final List<Site> list =
        Provider.of<SiteShiftsData>(context, listen: true).sites;
    final SiteShiftsData shiftsData =
        Provider.of<SiteShiftsData>(context, listen: false);
    final sitesData = Provider.of<SiteData>(context, listen: false);
    SystemChrome.setEnabledSystemUIOverlays([]);
    return GestureDetector(
        onTap: () {
          _nameController.text == ""
              ? FocusScope.of(context).unfocus()
              : SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
          floatingActionButton: widget.radioValue != 2
              ? FadeInVacPermFloatingButton(
                  radioVal2: widget.radioValue,
                  comingFromAdminPanel: false,
                  memberId: widget.member.id,
                )
              : Container(),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          OutsideVacHeader(
                            memberName: widget.member.name,
                          ),
                          OutSideVacRadioButtons(
                            missionFun: (v) {
                              _updateMissionRadio(v);
                            },
                            permFun: (v) {
                              _updatePermRadio(v);
                            },
                            radioValue: widget.radioValue,
                            vacFun: (v) {
                              _updateVacRadio(v);
                            },
                          ),
                          widget.radioValue == 1
                              ? OutsideVacDisplay(
                                  saveButtonFun: _saveVacationFun,
                                  dateController: _dateController,
                                  fromText: fromText,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  selectedReason: selectedReason,
                                  vacationDropdown: OutsideVacDropDown(
                                    holidayTile: widget.holidayTitles,
                                    dropdownFun: (v) {
                                      _vacDropdownFun(v);
                                    },
                                    selectedReason: selectedReason,
                                  ),
                                  datePickerFun: datePickerFun,
                                  dateDifference: dateDifference,
                                )
                              : widget.radioValue == 2
                                  ? Column(
                                      children: [
                                        VacationCardHeader(
                                          header: getTranslated(
                                              context, "نوع المأمورية"),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(width: 1)),
                                            height: 40.h,
                                            child: DropdownButtonHideUnderline(
                                                child: DropdownButton(
                                              elevation: 2,
                                              isExpanded: true,
                                              items: missions.map((String x) {
                                                return DropdownMenuItem<String>(
                                                    value: x,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 10),
                                                      child: AutoSizeText(
                                                        x,
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.orange,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ));
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  if (selectedMission !=
                                                      value) {
                                                    _missionDateController
                                                        .clear();
                                                    if (value == "خارجية") {
                                                      missionFromDate =
                                                          DateTime(
                                                              DateTime.now()
                                                                  .year,
                                                              DateTime.now()
                                                                  .month,
                                                              DateTime.now()
                                                                      .day +
                                                                  1);
                                                    } else {
                                                      missionFromDate =
                                                          DateTime.now();
                                                    }
                                                    fromDate = missionFromDate;
                                                    toDate = fromDate;
                                                    missionToDate = toDate;
                                                  }

                                                  selectedMission = value;
                                                });
                                              },
                                              value: selectedMission,
                                            )),
                                          ),
                                        ),
                                        selectedMission ==
                                                getTranslated(context, "داخلية")
                                            ? SitesAndMissionsWidg(
                                                prov: prov,
                                                selectedVal: selectedVal,
                                                list: list,
                                                onchannge: (value) {
                                                  setState(() {
                                                    selectedVal = value;
                                                  });
                                                },
                                              )
                                            : Container(),
                                        VacationCardHeader(
                                          header: getTranslated(
                                              context, "مدة المأمورية"),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          child: Theme(
                                            data: clockTheme1,
                                            child: Builder(
                                              builder: (context) {
                                                return InkWell(
                                                  child: Container(
                                                    // width: 330,
                                                    width:
                                                        getkDeviceWidthFactor(
                                                            context, 370),
                                                    child: IgnorePointer(
                                                      child: TextFormField(
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                setResponsiveFontSize(
                                                                    15)),
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        controller:
                                                            _missionDateController,
                                                        decoration: kTextFieldDecorationFromTO
                                                            .copyWith(
                                                                hintText:
                                                                    getTranslated(
                                                                        context,
                                                                        'المدة من / إلى'),
                                                                prefixIcon:
                                                                    const Icon(
                                                                  Icons
                                                                      .calendar_today_rounded,
                                                                  color: Colors
                                                                      .orange,
                                                                )),
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
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
                                                              RangeDatePicker(
                                                            pickerFun: (date) =>
                                                                datePickerFun(
                                                                    date, true),
                                                            fromDate:
                                                                missionFromDate,
                                                            toDate:
                                                                missionToDate,
                                                            maxDate: DateTime(
                                                                DateTime.now()
                                                                    .year,
                                                                12,
                                                                31),
                                                            minDate: DateTime(
                                                                DateTime.now()
                                                                    .year,
                                                                DateTime.now()
                                                                    .month,
                                                                selectedMission ==
                                                                        getTranslated(
                                                                            context,
                                                                            "داخلية")
                                                                    ? DateTime
                                                                            .now()
                                                                        .day
                                                                    : DateTime.now()
                                                                            .day +
                                                                        1),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        DetialsTextField(
                                            externalMissionController),
                                        Provider.of<UserHolidaysData>(context)
                                                    .isLoading ||
                                                Provider.of<MissionsData>(
                                                        context)
                                                    .isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              )
                                            : RoundedButton(
                                                onPressed: () async {
                                                  if (selectedMission ==
                                                      getTranslated(
                                                          context, "خارجية")) {
                                                    if (_missionDateController
                                                        .text.isEmpty) {
                                                      Fluttertoast.showToast(
                                                          msg: getTranslated(
                                                              context,
                                                              "برجاء ادخال المدة"),
                                                          backgroundColor:
                                                              Colors.red);
                                                    } else {
                                                      Provider.of<UserHolidaysData>(
                                                              context,
                                                              listen: false)
                                                          .addExternalMission(
                                                              missionFromDate,
                                                              missionToDate,
                                                              context,
                                                              widget.member.id,
                                                              externalMissionController
                                                                  .text,
                                                              widget.member
                                                                  .fcmToken);
                                                    }
                                                  } //داخلية
                                                  else {
                                                    Provider.of<MissionsData>(
                                                            context,
                                                            listen: false)
                                                        .addInternalMission(
                                                            context,
                                                            _missionDateController,
                                                            externalMissionController
                                                                .text,
                                                            missionFromDate,
                                                            missionToDate,
                                                            widget.member.id,
                                                            widget.member
                                                                .fcmToken,
                                                            widget
                                                                .member.osType,
                                                            shiftsData
                                                                .siteShiftList[
                                                                    sitesData
                                                                        .dropDownSitesIndex]
                                                                .siteName,
                                                            shiftsData
                                                                .shifts[sitesData
                                                                    .dropDownShiftIndex]
                                                                .shiftName);
                                                  }
                                                },
                                                title: getTranslated(
                                                    context, "حفظ"),
                                              )
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Card(
                                          elevation: 5,
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                AutoSizeText(
                                                  getTranslated(
                                                      context, "نوع الأذن"),
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize:
                                                          setResponsiveFontSize(
                                                              11)),
                                                  maxLines: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border:
                                                          Border.all(width: 1)),
                                                  height: 40.h,
                                                  child:
                                                      DropdownButtonHideUnderline(
                                                          child: DropdownButton(
                                                    elevation: 2,
                                                    isExpanded: true,
                                                    items: widget
                                                        .permessionTitles
                                                        .map((String x) {
                                                      return DropdownMenuItem<
                                                              String>(
                                                          value: x,
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: AutoSizeText(
                                                              x,
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .orange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ));
                                                    }).toList(),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedPermession =
                                                            value;
                                                      });
                                                    },
                                                    value: selectedPermession,
                                                  )),
                                                ),
                                              ),
                                              const Divider(),
                                              Card(
                                                elevation: 5,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      AutoSizeText(
                                                        getTranslated(context,
                                                            "تاريخ الأذن"),
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize:
                                                                setResponsiveFontSize(
                                                                    13)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: Container(
                                                  child: Theme(
                                                    data: clockTheme,
                                                    child: DateTimePicker(
                                                      initialValue:
                                                          _selectedDateString,

                                                      onChanged: (value) {
                                                        date = value;

                                                        setState(() {
                                                          _selectedDateString =
                                                              date;
                                                          selectedDate =
                                                              DateTime.parse(
                                                                  _selectedDateString);
                                                        });
                                                      },
                                                      type: DateTimePickerType
                                                          .date,
                                                      initialDate: _today,
                                                      firstDate: _today,
                                                      lastDate: DateTime(
                                                          DateTime.now().year +
                                                              2,
                                                          DateTime.december,
                                                          31),
                                                      //controller: _endTimeController,
                                                      style: TextStyle(
                                                          fontSize: ScreenUtil()
                                                              .setSp(14,
                                                                  allowFontScalingSelf:
                                                                      true),
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w400),

                                                      decoration: kTextFieldDecorationTime
                                                          .copyWith(
                                                              hintStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              hintText:
                                                                  getTranslated(
                                                                      context,
                                                                      'اليوم'),
                                                              prefixIcon:
                                                                  const Icon(
                                                                Icons
                                                                    .access_time,
                                                                color: Colors
                                                                    .orange,
                                                              )),
                                                      validator: (val) {
                                                        if (val.length == 0) {
                                                          return getTranslated(
                                                              context, "مطلوب");
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Card(
                                                elevation: 5,
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Row(
                                                    children: [
                                                      AutoSizeText(
                                                        selectedPermession ==
                                                                getTranslated(
                                                                    context,
                                                                    "تأخير عن الحضور")
                                                            ? getTranslated(
                                                                context,
                                                                "اذن حتى الساعة")
                                                            : getTranslated(
                                                                context,
                                                                "اذن من الساعة",
                                                              ),
                                                        style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: double.infinity,
                                                height: 50.h,
                                                child: Container(
                                                    child: Theme(
                                                  data: clockTheme,
                                                  child: Builder(
                                                    builder: (context) {
                                                      return InkWell(
                                                          onTap: () async {
                                                            final to =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialTime:
                                                                  toPicked,
                                                              builder: (BuildContext
                                                                      context,
                                                                  Widget
                                                                      child) {
                                                                return MediaQuery(
                                                                  data: MediaQuery.of(
                                                                          context)
                                                                      .copyWith(
                                                                    alwaysUse24HourFormat:
                                                                        false,
                                                                  ),
                                                                  child: child,
                                                                );
                                                              },
                                                            );

                                                            if (to != null) {
                                                              final now =
                                                                  new DateTime
                                                                      .now();
                                                              final dt =
                                                                  DateTime(
                                                                      now.year,
                                                                      now.month,
                                                                      now.day,
                                                                      to.hour,
                                                                      to.minute);

                                                              formattedTime =
                                                                  DateFormat
                                                                          .Hm()
                                                                      .format(
                                                                          dt);

                                                              toPicked = to;
                                                              setState(() {
                                                                timeOutController
                                                                        .text =
                                                                    "${toPicked.format(context).replaceAll(" ", " ")}";
                                                              });
                                                            }
                                                          },
                                                          child: Container(
                                                            child:
                                                                IgnorePointer(
                                                              child:
                                                                  TextFormField(
                                                                enabled: false,
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                textInputAction:
                                                                    TextInputAction
                                                                        .next,
                                                                controller:
                                                                    timeOutController,
                                                                decoration: kTextFieldDecorationFromTO
                                                                    .copyWith(
                                                                        hintText: getTranslated(
                                                                            context,
                                                                            'الوقت'),
                                                                        prefixIcon:
                                                                            const Icon(
                                                                          Icons
                                                                              .alarm,
                                                                          color:
                                                                              Colors.orange,
                                                                        )),
                                                              ),
                                                            ),
                                                          ));
                                                    },
                                                  ),
                                                )),
                                              ),
                                              DetialsTextField(
                                                  commentController)
                                            ],
                                          ),
                                        ),
                                        Provider.of<UserPermessionsData>(
                                                        context)
                                                    .isLoading ||
                                                Provider.of<UserHolidaysData>(
                                                        context)
                                                    .isLoading
                                            ? const CircularProgressIndicator(
                                                backgroundColor: Colors.orange)
                                            : RoundedButton(
                                                onPressed: () async {
                                                  if (_selectedDateString !=
                                                          null &&
                                                      timeOutController.text !=
                                                          "") {
                                                    final String msg = await Provider.of<UserPermessionsData>(context, listen: false)
                                                        .addUserPermession(
                                                            UserPermessions(
                                                                // createdOn:
                                                                //     DateTime.now(),
                                                                date: DateTime.parse(
                                                                    _selectedDateString),
                                                                duration: formattedTime
                                                                    .replaceAll(
                                                                        ":", ""),
                                                                permessionType:
                                                                    selectedPermession == getTranslated(context, "تأخير عن الحضور")
                                                                        ? 1
                                                                        : 2,
                                                                permessionDescription: commentController.text == ""
                                                                    ? getTranslated(
                                                                        context, "لا يوجد تعليق")
                                                                    : commentController
                                                                        .text,
                                                                user: widget
                                                                    .member
                                                                    .name),
                                                            Provider.of<UserData>(
                                                                    context,
                                                                    listen: false)
                                                                .user
                                                                .userToken,
                                                            widget.member.id);
                                                    print("msgggggggg $msg");
                                                    if (msg == "success") {
                                                      Fluttertoast.showToast(
                                                              msg: getTranslated(
                                                                  context,
                                                                  "تم الإضافة بنجاح"),
                                                              backgroundColor:
                                                                  Colors.green,
                                                              gravity:
                                                                  ToastGravity
                                                                      .CENTER)
                                                          .whenComplete(() =>
                                                              Navigator.pop(
                                                                  context));
                                                    } else if (msg ==
                                                        "holiday") {
                                                      displayErrorToast(context,
                                                          'يوجد اجازة فى هذا اليوم');
                                                    } else if (msg ==
                                                        "external mission") {
                                                      displayErrorToast(context,
                                                          "يوجد مأمورية خارجية فى هذا اليوم");
                                                    } else if (msg ==
                                                        'already exist') {
                                                      displayErrorToast(context,
                                                          "لقد تم تقديم طلب من قبل");
                                                    } else if (msg ==
                                                        "failed") {
                                                      errorToast(context);
                                                    } else if (msg ==
                                                            "dublicate permession" ||
                                                        msg ==
                                                            "latePermExist") {
                                                      displayErrorToast(context,
                                                          "يوجد اذن فى هذا اليوم");
                                                    } else if (msg ==
                                                        "Failed : User already Attend!") {
                                                      displayErrorToast(context,
                                                          "لا يمكن تنفيذ طلبك المسخدم سجل حضور بالفعل");
                                                    } else if (msg ==
                                                        "User already Leave") {
                                                      displayErrorToast(context,
                                                          "لا يمكن تنفيذ طلبك المسخدم سجل انصراف بالفعل");
                                                    } else if (msg ==
                                                        "pending limit exceed") {
                                                      displayErrorToast(context,
                                                          "لقد تجاوزت الحد المسموح من الطلبات التى لم يتم الرد عليها");
                                                    } else if (msg ==
                                                        "daily limit exceed") {
                                                      displayErrorToast(context,
                                                          "requests daily exceed");
                                                    } else if (msg ==
                                                        "shiftTimeOut") {
                                                      displayErrorToast(context,
                                                          "خطأ : لا يمكن تسجيل إذن فى هذا التوقيت");
                                                    } else if (msg ==
                                                        "intersection permissions") {
                                                      displayErrorToast(context,
                                                          "يوجد تقاطع مع إذن اخر فى نفس التوقيت");
                                                    } else if (msg ==
                                                        "incorrect attend permision time") {
                                                      displayErrorToast(context,
                                                          "يجب ان يكون إذن التأخير عن الحضور قبل موعد الأنصراف بساعة");
                                                    } else if (msg ==
                                                        "incorrect leave permision time") {
                                                      displayErrorToast(context,
                                                          "يجب أن يكون إذن الإنصراف المبكر بعد بدء المناوبة بساعة واحدة");
                                                    }
                                                  } else {
                                                    displayErrorToast(context,
                                                        "قم بأدخال البيانات المطلوبة");
                                                  }
                                                },
                                                title: getTranslated(
                                                    context, "حفظ"),
                                              )
                                      ],
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

class VacationCardHeader extends StatelessWidget {
  final String header;
  const VacationCardHeader({
    this.header,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            AutoSizeText(
              header,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: setResponsiveFontSize(13)),
            ),
          ],
        ),
      ),
    );
  }
}
