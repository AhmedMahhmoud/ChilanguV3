import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:date_range_picker/date_range_picker.dart' as DateRagePicker;

import 'package:flutter/cupertino.dart';

import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/colorManager.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';

import 'package:qr_users/Screens/Notifications/Screen/Notifications.dart';
import 'package:qr_users/main.dart';
import 'package:qr_users/services/company.dart';
import 'package:qr_users/services/permissions_data.dart';
import 'package:qr_users/widgets/OfficialVacations/DataTableVacationHeader.dart';

import 'package:qr_users/widgets/OfficialVacations/DataTableVacationRow.dart';
import 'package:qr_users/widgets/Shared/Picker/range_picker.dart';
import 'package:qr_users/widgets/multiple_floating_buttons.dart';

import 'package:qr_users/widgets/roundedAlert.dart';

import 'package:qr_users/Screens/SystemScreens/ReportScreens/UserAttendanceReport.dart';

import 'package:qr_users/Core/constants.dart';

import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/VacationData.dart';

import 'package:qr_users/services/Reports/Services/report_data.dart';
import 'package:qr_users/services/user_data.dart';

import 'package:qr_users/widgets/DirectoriesHeader.dart';

import 'package:qr_users/widgets/headers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import 'AddVacationScreen.dart';

class OfficialVacation extends StatefulWidget {
  @override
  _OfficialVacationState createState() => _OfficialVacationState();
}

class _OfficialVacationState extends State<OfficialVacation> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<Vacation>> key = new GlobalKey();
  final SlidableController slidableController = SlidableController();
  DateTime toDate;
  DateTime fromDate;
  // bool isVacationselected = false;
  final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');

  String dateToString = "";
  String dateFromString = "";
  String fromText;
  String selectedId = "";
  Site siteData;
  String toText;
  DateTime yesterday;
  @override
  void didChangeDependencies() {
    fromText =
        " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
    toText =
        " ${getTranslated(context, "إلى")}  ${DateFormat('yMMMd').format(toDate).toString()}";
    _dateController.text = "$fromText $toText";
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    Provider.of<VacationData>(context, listen: false).isLoading = false;
    toDate = DateTime(now.year, DateTime.december, 31);
    fromDate = DateTime(toDate.year, DateTime.january, 1);
    Provider.of<PermissionHan>(context, listen: false).initializeUserScroll();
    yesterday = DateTime(now.year, now.month, now.day - 1);

    dateFromString = apiFormatter.format(fromDate);
    dateToString = apiFormatter.format(toDate);

    _dateController.text = "$fromText $toText";
  }

  ScrollController _scrollController = ScrollController();
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vactionProv = Provider.of<VacationData>(context, listen: true);
    List<DateTime> pickedRange = [fromDate, toDate];
    return GestureDetector(
        onTap: () {
          _nameController.text == ""
              ? FocusScope.of(context).unfocus()
              : SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: NotificationListener(
          onNotification: (notificationInfo) {
            if (_scrollController.hasClients) {
              if (_scrollController.position.userScrollDirection ==
                  ScrollDirection.reverse) {
                Provider.of<PermissionHan>(context, listen: false)
                    .setUserScrolling();
              } else if (_scrollController.position.userScrollDirection ==
                  ScrollDirection.forward) {
                Provider.of<PermissionHan>(context, listen: false)
                    .resetUserscrolling();
              }
            }

            return true;
          },
          child: Scaffold(
              endDrawer: NotificationItem(),
              floatingActionButton:
                  Provider.of<UserData>(context).user.userType == 4 ||
                          Provider.of<UserData>(context).user.userType == 3
                      ? MultipleFloatingButtons(
                          shiftIndex:
                              Provider.of<SiteData>(context, listen: false)
                                  .currentShiftIndex,
                          comingFromShifts: false,
                          shiftName: "",
                          mainTitle: getTranslated(context, 'إضافة عطلة'),
                          mainIconData: Icons.person_add,
                        )
                      : Container(),
              body: Container(
                child: Column(children: [
                  Header(
                    nav: false,
                    goUserMenu: false,
                    goUserHomeFromMenu: false,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SmallDirectoriesHeader(
                        Lottie.asset("resources/calender.json", repeat: false),
                        getTranslated(context, "العطلات الرسمية"),
                      ),
                    ],
                  ),
                  Container(
                    child: Theme(
                      data: clockTheme1,
                      child: Builder(
                        builder: (context) {
                          return InkWell(
                            child: Container(
                              // width: 330,
                              width: getkDeviceWidthFactor(context, 370),
                              child: IgnorePointer(
                                child: TextFormField(
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: setResponsiveFontSize(15)),
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
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return StatefulBuilder(
                                      builder: (context, setstatee) {
                                    return Dialog(
                                        insetPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 20),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0)),
                                        child: RangeDatePicker(
                                          pickerFun: (date) => _dateFun(
                                            date,
                                          ),
                                          fromDate: fromDate,
                                          toDate: toDate,
                                          maxDate: yesterday,
                                          minDate:
                                              DateTime(DateTime.now().year),
                                        ));
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    width: 370.w,
                    child: searchTextField = AutoCompleteTextField<Vacation>(
                      key: key,
                      clearOnSubmit: false,
                      controller: _nameController,
                      suggestions: vactionProv.vactionList
                          .where((element) => isDateBetweenTheRange(
                              element, pickedRange.first, pickedRange.last))
                          .toList(),
                      style: TextStyle(
                          fontSize: ScreenUtil()
                              .setSp(16, allowFontScalingSelf: true),
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                      decoration: kTextFieldDecorationFromTO.copyWith(
                          hintStyle: TextStyle(
                              fontSize: ScreenUtil()
                                  .setSp(16, allowFontScalingSelf: true),
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500),
                          hintText: getTranslated(context, "أسم العطلة"),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.orange,
                          )),
                      itemFilter: (item, query) {
                        return item.vacationName
                            .toLowerCase()
                            .contains(query.toLowerCase());
                      },
                      itemSorter: (a, b) {
                        return a.vacationName.compareTo(b.vacationName);
                      },
                      itemSubmitted: (item) async {
                        final index = vactionProv.vactionList.indexOf(item);
                        if (_nameController.text != item.vacationName) {
                          setState(() {
                            searchTextField.textField.controller.text =
                                item.vacationName;

                            vactionProv.setCopyByIndex(index);
                            // isVacationselected = true;
                          });
                        }
                      },
                      itemBuilder: (context, item) {
                        // ui for the autocompelete row
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 10,
                            bottom: 5,
                          ),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 10.w,
                              ),
                              Container(
                                height: 20,
                                child: AutoSizeText(
                                  item.vacationName,
                                  maxLines: 1,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(16,
                                          allowFontScalingSelf: true),
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Expanded(
                      child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Divider(thickness: 1, color: ColorManager.primary),
                        DataTableVacationHeader(),
                        Divider(thickness: 1, color: ColorManager.primary),
                        vactionProv.isLoading
                            ? const Expanded(
                                child: Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.orange,
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Container(
                                child: vactionProv.vactionList.length == 0
                                    ? Center(
                                        child: AutoSizeText(
                                          getTranslated(
                                              context, "لا يوجد عطلات رسمية"),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                    : ListView.builder(
                                        controller: _scrollController,
                                        itemCount: _nameController.text == ""
                                            ? vactionProv.vactionList.length
                                            : vactionProv
                                                .copyVacationList.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return Column(
                                            children: [
                                              Slidable(
                                                enabled: vactionProv
                                                    .vactionList[index]
                                                    .vacationDate
                                                    .isAfter(DateTime.now()),
                                                actionExtentRatio: 0.10,
                                                closeOnScroll: true,
                                                controller: slidableController,
                                                actionPane:
                                                    const SlidableDrawerActionPane(),
                                                secondaryActions: [
                                                  ZoomIn(
                                                      child: InkWell(
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              7),
                                                      decoration:
                                                          const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.green,
                                                      ),
                                                      child: const Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddVacationScreen(
                                                              edit: true,
                                                            ),
                                                          ));
                                                    },
                                                  )),
                                                  vactionProv.vactionList[index]
                                                              .vacationDate
                                                              .difference(
                                                                  DateTime
                                                                      .now())
                                                              .inDays !=
                                                          0
                                                      ? Container()
                                                      : ZoomIn(
                                                          child: InkWell(
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(7),
                                                            decoration:
                                                                const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Colors.red,
                                                            ),
                                                            child: const Icon(
                                                              Icons.delete,
                                                              size: 18,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            return showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                        ctx) {
                                                                  return vactionProv
                                                                          .isLoading
                                                                      ? const Center(
                                                                          child:
                                                                              CircularProgressIndicator(
                                                                            backgroundColor:
                                                                                Colors.orange,
                                                                          ),
                                                                        )
                                                                      : RoundedAlert(
                                                                          onPressed:
                                                                              () async {
                                                                            Navigator.pop(ctx);
                                                                            final String
                                                                                msg =
                                                                                await vactionProv.deleteVacationById(Provider.of<UserData>(context, listen: false).user.userToken, vactionProv.vactionList[index].vacationId, index);
                                                                            if (msg ==
                                                                                "Success") {
                                                                              Fluttertoast.showToast(msg: getTranslated(navigatorKey.currentState.overlay.context, "تم الحذف بنجاح"), backgroundColor: Colors.green);
                                                                            } else {
                                                                              Fluttertoast.showToast(msg: getTranslated(navigatorKey.currentState.overlay.context, "خطأ في حذف العطلة"), backgroundColor: Colors.red);
                                                                            }
                                                                          },
                                                                          content:
                                                                              "${getTranslated(context, "هل تريد حذف")}  : ${vactionProv.vactionList[index].vacationName}؟",
                                                                          onCancel:
                                                                              () {},
                                                                          title: getTranslated(
                                                                              context,
                                                                              "حذف العطلة"),
                                                                        );
                                                                });
                                                          },
                                                        )),
                                                ],
                                                child: DataTableVacationRow(
                                                  clearTextFieldCallback: () {
                                                    setState(() {
                                                      _nameController.clear();
                                                    });
                                                  },
                                                  vacation: _nameController
                                                              .text ==
                                                          ""
                                                      ? vactionProv
                                                          .vactionList[index]
                                                      : vactionProv
                                                          .copyVacationList
                                                          .first,
                                                  filterFromDate:
                                                      pickedRange.first,
                                                  filterToDate:
                                                      pickedRange.last,
                                                ),
                                              ),
                                              isDateBetweenTheRange(
                                                      vactionProv
                                                          .vactionList[index],
                                                      pickedRange.first,
                                                      pickedRange.last)
                                                  ? const Divider(
                                                      thickness: 1,
                                                    )
                                                  : Container()
                                            ],
                                          );
                                        }),
                              )),
                      ],
                    ),
                  ))
                ]),
              )),
        ));
  }

  _dateFun(PickerDateRange picked) async {
    var newString = "";
    setState(() {
      fromDate = picked.startDate;
      toDate = picked.endDate ?? picked.startDate;

      final String fromText =
          " ${getTranslated(context, "من")} ${DateFormat('yMMMd').format(fromDate).toString()}";
      final String toText =
          " ${getTranslated(context, "إلى")} ${DateFormat('yMMMd').format(toDate).toString()}";
      newString = "$fromText $toText";
    });
    Navigator.pop(context);
    if (_dateController.text != newString) {
      _dateController.text = newString;

      dateFromString = apiFormatter.format(fromDate);
      dateToString = apiFormatter.format(toDate);

      if (_nameController.text != "" ||
          Provider.of<UserData>(context, listen: false).user.userType == 2) {
        final userToken =
            Provider.of<UserData>(context, listen: false).user.userToken;

        await Provider.of<ReportsData>(context, listen: false)
            .getUserReportUnits(
                userToken, selectedId, dateFromString, dateToString, context);
      }
    }
  }
}
