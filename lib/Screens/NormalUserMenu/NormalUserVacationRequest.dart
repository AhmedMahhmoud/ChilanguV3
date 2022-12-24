import 'package:auto_size_text/auto_size_text.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/screen_util.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/FirebaseCloudMessaging/FirebaseFunction.dart';
import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/RadioButtonWidget.dart';

import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/MembersScreens/UserFullData.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';

import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';

import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';
import 'package:qr_users/widgets/Shared/Picker/range_picker.dart';
import 'package:qr_users/widgets/StackedNotificationAlert.dart';
import 'package:qr_users/widgets/headers.dart';
import 'package:qr_users/widgets/roundedAlert.dart';
import 'package:qr_users/widgets/roundedButton.dart';

import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../Core/constants.dart';

class UserVacationRequest extends StatefulWidget {
  UserVacationRequest(this.radioVal, this.permesionTitles, this.holidayTitles);

  final List<String> holidayTitles;
  final List<String> permesionTitles;
  int radioVal;

  @override
  _UserVacationRequestState createState() => _UserVacationRequestState();
}

TextEditingController commentController = TextEditingController();
String selectedReason;
String selectedPermession;
TextEditingController timeOutController = TextEditingController();
var sleectedMember;
var toDate;
var fromDate;
String toText;
String fromText;
DateTime yesterday;
TextEditingController _dateController = TextEditingController();
String dateToString = "";
String dateFromString = "";
int radioVal;
TimeOfDay toPicked;
String dateDifference;
DateTime _today, _tomorow;

class _UserVacationRequestState extends State<UserVacationRequest> {
  String formattedTime;
  var newString = "";
  var selectedVal = "كل المواقع";

  final _radioButtonNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    radioVal = widget.radioVal;
    selectedPermession = widget.permesionTitles.first;
    selectedReason = widget.holidayTitles.first;
    _today = DateTime.now();
    _tomorow = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    Provider.of<UserPermessionsData>(context, listen: false).isLoading = false;
    Provider.of<UserHolidaysData>(context, listen: false).isLoading = false;
    timeOutController.text = "";
    toPicked = (intToTimeOfDay(0));
    selectedDateString = null;
    dateDifference = null;
    _dateController = TextEditingController();
    final now = DateTime.now();
    commentController.text = "";
    fromDate = DateTime(now.year, now.month, now.day);
    toDate = DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day + 1);
    yesterday = DateTime(now.year + 2, DateTime.december, 31);

    super.initState();
  }

  void setRadioButtonState(int newState) {
    _radioButtonNotifier.value = newState;
  }

  datePickerFun(PickerDateRange picked) {
    setState(() {
      _today = picked.startDate;
      _tomorow = picked.startDate;
      fromDate = picked.startDate;
      toDate = picked.endDate ?? picked.startDate;
      dateDifference = (toDate.difference(fromDate).inDays + 1).toString();
      fromText =
          " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
      toText =
          " ${getTranslated(context, "إلى")}  ${DateFormat('yMMMd').format(toDate).toString()}";
      newString = "$fromText $toText";
    });

    if (_dateController.text != newString) {
      _dateController.text = newString;

      dateFromString = apiFormatter.format(fromDate);
      dateToString = apiFormatter.format(toDate);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final DateTime initialTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        selectedReason == getTranslated(context, "عارضة")
            ? DateTime.now().day
            : DateTime.now().day + 1);
    final userdata = Provider.of<UserData>(context, listen: false).user;
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          endDrawer: NotificationItem(),
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Header(
                  goUserHomeFromMenu: false,
                  nav: false,
                  goUserMenu: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SmallDirectoriesHeader(
                                Lottie.asset("resources/calender.json",
                                    repeat: false),
                                getTranslated(context, "طلب اذن / اجازة"),
                              ),
                            ],
                          ),
                          VacationCardHeader(
                            header: getTranslated(context, "نوع الطلب"),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                RadioButtonWidg(
                                  radioVal2: radioVal,
                                  radioVal: 3,
                                  title: getTranslated(context, "أذن"),
                                  onchannge: (value) {
                                    setState(() {
                                      radioVal = value;
                                    });
                                  },
                                ),
                                RadioButtonWidg(
                                  radioVal2: radioVal,
                                  radioVal: 1,
                                  title: getTranslated(context, "اجازة"),
                                  onchannge: (value) {
                                    setState(() {
                                      radioVal = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          radioVal == 1
                              ? Column(
                                  children: [
                                    VacationCardHeader(
                                      header:
                                          getTranslated(context, "نوع الأجازة"),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(right: 5.w),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(width: 1)),
                                          width: 600.w,
                                          height: 40.h,
                                          child: DropdownButtonHideUnderline(
                                              child: DropdownButton(
                                            elevation: 2,
                                            isExpanded: true,
                                            items: widget.holidayTitles
                                                .map((String x) {
                                              return DropdownMenuItem<String>(
                                                  value: x,
                                                  child: AutoSizeText(
                                                    x,
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                        color: ColorManager
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ));
                                            }).toList(),
                                            onChanged: (String value) {
                                              setState(() {
                                                selectedReason = value;

                                                if (value !=
                                                    getTranslated(
                                                        context, "عارضة")) {
                                                  dateDifference = null;
                                                  _dateController.text = "";
                                                  newString = "";
                                                  _tomorow = DateTime(
                                                      DateTime.now().year,
                                                      DateTime.now().month,
                                                      DateTime.now().day + 1);
                                                  fromDate = _tomorow;
                                                  _today = DateTime.now();
                                                  toDate = _tomorow;
                                                }
                                              });
                                            },
                                            value: selectedReason,
                                          )),
                                        ),
                                      ),
                                    ),
                                    VacationCardHeader(
                                      header:
                                          getTranslated(context, "مدة الأجازة"),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Container(
                                        child: Theme(
                                            data: clockTheme1,
                                            child: Builder(builder: (context) {
                                              return InkWell(
                                                  child: Container(
                                                    // width: 330,
                                                    width: 365.w,
                                                    child: IgnorePointer(
                                                      child: TextFormField(
                                                        style: TextStyle(
                                                            color: ColorManager
                                                                .accentColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        controller:
                                                            _dateController,
                                                        decoration: kTextFieldDecorationFromTO
                                                            .copyWith(
                                                                hintStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w300,
                                                                    fontSize:
                                                                        setResponsiveFontSize(
                                                                            14),
                                                                    color: Colors
                                                                        .black),
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
                                                  onTap: () async {
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
                                                          child: Container(
                                                            height: 400.h,
                                                            child: Center(
                                                              child: Container(
                                                                child:
                                                                    SfDateRangePicker(
                                                                  confirmText:
                                                                      "حفظ",
                                                                  cancelText:
                                                                      "الغاء",
                                                                  onSubmit:
                                                                      (date) {
                                                                    datePickerFun(
                                                                      date,
                                                                    );
                                                                  },
                                                                  onCancel: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  selectionColor:
                                                                      Colors
                                                                          .orange,
                                                                  startRangeSelectionColor:
                                                                      Colors
                                                                          .orange,
                                                                  endRangeSelectionColor:
                                                                      Colors
                                                                          .orange,
                                                                  showNavigationArrow:
                                                                      true,
                                                                  initialSelectedRange:
                                                                      PickerDateRange(
                                                                          fromDate,
                                                                          toDate),
                                                                  headerHeight:
                                                                      100,
                                                                  initialSelectedDate:
                                                                      initialTime,
                                                                  initialDisplayDate:
                                                                      fromDate,
                                                                  showActionButtons:
                                                                      true,
                                                                  maxDate: DateTime(
                                                                      DateTime.now()
                                                                          .year,
                                                                      12,
                                                                      31),
                                                                  minDate:
                                                                      initialTime,
                                                                  selectionMode:
                                                                      DateRangePickerSelectionMode
                                                                          .range,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  });
                                            }))),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    dateDifference != null
                                        ? Container(
                                            padding: const EdgeInsets.all(5),
                                            alignment: Alignment.centerRight,
                                            child: AutoSizeText(
                                              "${getTranslated(context, "تم اختيار")} $dateDifference ${getTranslated(context, "يوم")} ",
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w300),
                                            ))
                                        : Container(),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    DetialsTextField(
                                      commentController,
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
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
                                                  fontWeight: FontWeight.w600,
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
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            alignment:
                                                Provider.of<PermissionHan>(
                                                            context,
                                                            listen: false)
                                                        .isEnglishLocale()
                                                    ? Alignment.centerLeft
                                                    : Alignment.centerRight,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    border:
                                                        Border.all(width: 1)),
                                                width: 600.w,
                                                height: 40.h,
                                                child:
                                                    DropdownButtonHideUnderline(
                                                        child: DropdownButton(
                                                  elevation: 2,
                                                  isExpanded: true,
                                                  items: widget.permesionTitles
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
                                                            textAlign:
                                                                TextAlign.start,
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
                                          ),
                                          const Divider(),
                                          Card(
                                            elevation: 5,
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                    getTranslated(
                                                        context, "تاريخ الأذن"),
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
                                            padding: const EdgeInsets.all(5),
                                            child: Container(
                                              child: Theme(
                                                data: clockTheme,
                                                child: DateTimePicker(
                                                  initialValue:
                                                      selectedDateString,

                                                  onChanged: (value) {
                                                    date = value;

                                                    setState(() {
                                                      selectedDateString = date;
                                                      selectedDate =
                                                          DateTime.parse(
                                                              selectedDateString);
                                                    });
                                                  },
                                                  initialDate: radioVal == 3
                                                      ? _today
                                                      : _tomorow,
                                                  type: DateTimePickerType.date,
                                                  firstDate: radioVal == 3
                                                      ? _today
                                                      : _tomorow,
                                                  lastDate: DateTime(
                                                      DateTime.now().year + 2,
                                                      DateTime.december,
                                                      31),
                                                  //controller: _endTimeController,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil().setSp(
                                                          14,
                                                          allowFontScalingSelf:
                                                              true),
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w400),

                                                  decoration:
                                                      kTextFieldDecorationTime
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
                                                                      "اليوم"),
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
                                              padding: const EdgeInsets.all(10),
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                    selectedPermession ==
                                                            getTranslated(
                                                                context,
                                                                "تأخير عن الحضور")
                                                        ? getTranslated(context,
                                                            "اذن حتى الساعة")
                                                        : getTranslated(context,
                                                            "اذن من الساعة"),
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
                                                          initialTime: toPicked,
                                                          builder: (BuildContext
                                                                  context,
                                                              Widget child) {
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
                                                          final dt = DateTime(
                                                              now.year,
                                                              now.month,
                                                              now.day,
                                                              to.hour,
                                                              to.minute);

                                                          formattedTime =
                                                              DateFormat.Hm()
                                                                  .format(dt);

                                                          toPicked = to;
                                                          setState(() {
                                                            timeOutController
                                                                    .text =
                                                                "${toPicked.format(context).replaceAll(" ", " ")}";
                                                          });
                                                        }
                                                      },
                                                      child: Container(
                                                        child: IgnorePointer(
                                                          child: TextFormField(
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
                                                                        "الوقت"),
                                                                    prefixIcon:
                                                                        const Icon(
                                                                      Icons
                                                                          .alarm,
                                                                      color: Colors
                                                                          .orange,
                                                                    )),
                                                          ),
                                                        ),
                                                      ));
                                                },
                                              ),
                                            )),
                                          ),
                                          DetialsTextField(
                                            commentController,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                          Provider.of<UserPermessionsData>(context).isLoading ||
                                  Provider.of<UserHolidaysData>(context)
                                      .isLoading
                              ? const CircularProgressIndicator(
                                  backgroundColor: Colors.orange)
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RoundedButton(
                                      title:
                                          getTranslated(context, "حفظ الطلب"),
                                      onPressed: () async {
                                        if (radioVal == 1) //اجازة
                                        {
                                          if (_dateController.text != "") {
//4-2-2021
                                            Provider.of<UserHolidaysData>(
                                                    context,
                                                    listen: false)
                                                .addHoliday(
                                                    UserHolidays(
                                                        holidayDescription:
                                                            commentController
                                                                .text,
                                                        fromDate: fromDate,
                                                        toDate:
                                                            toDate ?? fromDate,
                                                        holidayType: selectedReason ==
                                                                getTranslated(
                                                                    context,
                                                                    "عارضة")
                                                            ? 1
                                                            : selectedReason ==
                                                                    getTranslated(
                                                                        context,
                                                                        "مرضى")
                                                                ? 2
                                                                : 3,
                                                        holidayStatus: 3),
                                                    userdata.userToken,
                                                    userdata.id)
                                                .then((value) async {
                                              if (value == Holiday.Success) {
                                                return showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return StackedNotificaitonAlert(
                                                      repeatAnimation: false,
                                                      popWidget: true,
                                                      isAdmin: false,
                                                      isFromBackground: false,
                                                      notificationTitle:
                                                          getTranslated(context,
                                                              "تم تقديم طلب الأجازة بنجاح"),
                                                      notificationContent:
                                                          getTranslated(context,
                                                              "برجاء متابعة الطلب"),
                                                      roundedButtonTitle:
                                                          getTranslated(context,
                                                              "متابعة"),
                                                      lottieAsset:
                                                          "resources/success.json",
                                                      showToast: false,
                                                    );
                                                  },
                                                );
                                              } else if (value ==
                                                  Holiday
                                                      .Internal_Mission_InThis_Period) {
                                                {
                                                  displayErrorToast(context,
                                                      "لا يمكن طلب الاجازة : يوجد مأمورية خارجية");
                                                }
                                              } else if (value ==
                                                  Holiday
                                                      .USER_ALREADY_ATTENDED) {
                                                displayErrorToast(context,
                                                    "لا يمكن وضع الأجازة : تم الحضور");
                                              } else if (value ==
                                                  Holiday
                                                      .External_Mission_InThis_Period) {
                                                displayErrorToast(context,
                                                    "خطأ : يوجد مأمورية خارجية");
                                              } else if (value ==
                                                  Holiday
                                                      .Another_Holiday_NOT_APPROVED) {
                                                displayErrorToast(context,
                                                    "يوجد اجازة لم يتم الموافقة عليها فى هذه الفترة");
                                              } else if (value ==
                                                  Holiday
                                                      .Holiday_Approved_InThis_Period) {
                                                displayErrorToast(context,
                                                    "يوجد اجازة تم الموافقة عليها فى هذه الفترة");
                                              } else if (value ==
                                                  Holiday
                                                      .Internal_Mission_InThis_Period) {
                                                displayErrorToast(context,
                                                    "لا يمكن طلب الاجازة : يوجد مأمورية داخلية");
                                              } else if (value ==
                                                  Holiday
                                                      .Permession_InThis_Period) {
                                                displayErrorToast(context,
                                                    "لا يمكن طلب الاجازة : يوجد طلب اذن");
                                              } else if (value ==
                                                  Holiday
                                                      .Holiday_Limit_Exceed) {
                                                displayErrorToast(context,
                                                    "لقد تجاوزت العدد المسموح بة من الطلبات لهذا اليوم");
                                              } else if (value ==
                                                  Holiday.Daily_limit_Reached) {
                                                displayErrorToast(context,
                                                    "requests daily exceed");
                                              } else if (value ==
                                                  Holiday
                                                      .Pending_limit_reached) {
                                                displayErrorToast(context,
                                                    "لقد تجاوزت الحد المسموح من الطلبات التى لم يتم الرد عليها");
                                              } else {
                                                errorToast(context);
                                              }
                                            });
                                          } else {
                                            Fluttertoast.showToast(
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.red,
                                                msg: getTranslated(context,
                                                    "قم بأدخال مدة الأجازة"));
                                          }
                                        } else //اذن
                                        {
                                          if (selectedDateString != null &&
                                              timeOutController.text != "") {
                                            showDialog(
                                              context: context,
                                              builder: (ct) {
                                                return RoundedAlert(
                                                    onCancel: () {},
                                                    onPressed: () async {
                                                      Navigator.pop(ct);
                                                      {
                                                        final String msg = await Provider.of<UserPermessionsData>(context, listen: false).addUserPermession(
                                                            UserPermessions(
                                                                date:
                                                                    selectedDate,
                                                                duration: formattedTime
                                                                    .replaceAll(
                                                                        ":", ""),
                                                                permessionType:
                                                                    selectedPermession == getTranslated(context, "تأخير عن الحضور")
                                                                        ? 1
                                                                        : 2,
                                                                permessionDescription: commentController.text == ""
                                                                    ? getTranslated(
                                                                        context,
                                                                        "لا يوجد تعليق")
                                                                    : commentController
                                                                        .text,
                                                                user: userdata
                                                                    .name),
                                                            Provider.of<UserData>(context,
                                                                    listen: false)
                                                                .user
                                                                .userToken,
                                                            userdata.id);

                                                        if (msg == "success") {
                                                          return showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return StackedNotificaitonAlert(
                                                                repeatAnimation:
                                                                    false,
                                                                isFromBackground:
                                                                    false,
                                                                popWidget: true,
                                                                isAdmin: false,
                                                                notificationTitle:
                                                                    getTranslated(
                                                                        context,
                                                                        "تم تقديم طلب الأذن بنجاح"),
                                                                notificationContent:
                                                                    getTranslated(
                                                                        context,
                                                                        "برجاء متابعة الطلب"),
                                                                roundedButtonTitle:
                                                                    getTranslated(
                                                                        context,
                                                                        "متابعة"),
                                                                lottieAsset:
                                                                    "resources/success.json",
                                                                showToast:
                                                                    false,
                                                              );
                                                            },
                                                          );
                                                        } else if (msg ==
                                                            'already exist') {
                                                          displayErrorToast(
                                                              context,
                                                              "لقد تم تقديم طلب من قبل");
                                                        } else if (msg ==
                                                                "dublicate permession" ||
                                                            msg ==
                                                                "latePermExist") {
                                                          displayErrorToast(
                                                              context,
                                                              "يوجد اذن اخر فى هذا اليوم");
                                                        } else if (msg ==
                                                            "external mission") {
                                                          displayErrorToast(
                                                              context,
                                                              "يوجد مأمورية خارجية فى هذا اليوم");
                                                        } else if (msg ==
                                                            "holiday") {
                                                          displayErrorToast(
                                                              context,
                                                              "يوجد اجازة فى هذا اليوم");
                                                        } else if (msg ==
                                                            "holiday was not approved") {
                                                          displayErrorToast(
                                                              context,
                                                              "يوجد اجازة لم يتم الموافقة عليها");
                                                        } else if (msg ==
                                                            "Failed : User already Attend!") {
                                                          displayErrorToast(
                                                              context,
                                                              "لا يمكن تنفيذ طلبك المسخدم سجل حضور بالفعل");
                                                        } else if (msg ==
                                                            "User already Leave") {
                                                          displayErrorToast(
                                                              context,
                                                              "لا يمكن تنفيذ طلبك المسخدم سجل انصراف بالفعل");
                                                        } else if (msg ==
                                                            "pending limit exceed") {
                                                          displayErrorToast(
                                                              context,
                                                              "لقد تجاوزت الحد المسموح من الطلبات التى لم يتم الرد عليها");
                                                        } else if (msg ==
                                                            "daily limit exceed") {
                                                          displayErrorToast(
                                                              context,
                                                              "requests daily exceed");
                                                        } else if (msg ==
                                                            "daily limit exceed") {
                                                          displayErrorToast(
                                                              context,
                                                              "requests daily exceed");
                                                        } else if (msg ==
                                                            "shiftTimeOut") {
                                                          displayErrorToast(
                                                              context,
                                                              "خطأ : لا يمكن تسجيل إذن فى هذا التوقيت");
                                                        } else if (msg ==
                                                            "incorrect attend permision time") {
                                                          displayErrorToast(
                                                              context,
                                                              "يجب ان يكون إذن التأخير عن الحضور قبل موعد الأنصراف بساعة");
                                                        } else if (msg ==
                                                            "incorrect leave permision time") {
                                                          displayErrorToast(
                                                              context,
                                                              "يجب أن يكون إذن الإنصراف المبكر بعد بدء المناوبة بساعة واحدة");
                                                        } else if (msg ==
                                                            "failed") {
                                                          errorToast(context);
                                                        } else if (msg ==
                                                            "intersection permissions") {
                                                          displayErrorToast(
                                                              context,
                                                              "يوجد تقاطع مع إذن اخر فى نفس التوقيت");
                                                        }
                                                      }
                                                    },
                                                    title: getTranslated(
                                                        context,
                                                        'هل تريد حفظ الطلب ؟'),
                                                    content:
                                                        "${getTranslated(context, "الوقت")} : ${timeOutController.text} \n ${getTranslated(context, "التاريخ")} : ${selectedDate.toString().substring(0, 11)}");
                                              },
                                            );
                                          } else {
                                            Fluttertoast.showToast(
                                                gravity: ToastGravity.CENTER,
                                                backgroundColor: Colors.red,
                                                msg: getTranslated(context,
                                                    "قم بأدخال البيانات المطلوبة"));
                                          }
                                        }
                                      }))
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
