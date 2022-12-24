import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/SittingScreens/CompanySettings/OutsideVacation.dart';
import 'package:qr_users/services/UserHolidays/user_holidays.dart';
import 'package:qr_users/services/UserPermessions/user_permessions.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:qr_users/Screens/NormalUserMenu/NormalUserVacationRequest.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_users/widgets/roundedButton.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../Core/constants.dart';

class OutsideVacDisplay extends StatelessWidget {
  final Function datePickerFun;
  final TextEditingController dateController;
  final String dateDifference, fromText, selectedReason;
  final Function saveButtonFun;
  final Widget vacationDropdown;
  final DateTime fromDate, toDate, initialDate;
  const OutsideVacDisplay(
      {@required this.datePickerFun,
      @required this.dateController,
      @required this.saveButtonFun,
      @required this.vacationDropdown,
      this.fromDate,
      this.toDate,
      this.selectedReason,
      this.dateDifference,
      this.initialDate,
      this.fromText});

  @override
  Widget build(BuildContext context) {
    final DateTime initialTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        selectedReason == getTranslated(context, "عارضة")
            ? DateTime.now().day
            : DateTime.now().day + 1);
    return Column(
      children: [
        VacationCardHeader(
          header: getTranslated(context, "مدة الأجازة"),
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
                    width: getkDeviceWidthFactor(context, 370),
                    child: IgnorePointer(
                      child: TextFormField(
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                            fontSize: setResponsiveFontSize(15)),
                        textInputAction: TextInputAction.next,
                        controller: dateController,
                        decoration: kTextFieldDecorationFromTO.copyWith(
                            hintText: getTranslated(context, 'المدة من / إلى'),
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
                        return Dialog(
                          insetPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: Container(
                            height: 400.h,
                            child: Center(
                              child: Container(
                                child: SfDateRangePicker(
                                  confirmText: "حفظ",
                                  cancelText: "الغاء",
                                  onSubmit: (date) {
                                    datePickerFun(date, false);
                                  },
                                  onCancel: () => Navigator.pop(context),
                                  selectionColor: Colors.orange,
                                  startRangeSelectionColor: Colors.orange,
                                  endRangeSelectionColor: Colors.orange,
                                  showNavigationArrow: true,
                                  initialSelectedRange:
                                      PickerDateRange(fromDate, toDate),
                                  headerHeight: 100,
                                  initialSelectedDate: initialTime,
                                  initialDisplayDate: fromDate,
                                  showActionButtons: true,
                                  maxDate:
                                      DateTime(DateTime.now().year, 12, 31),
                                  minDate: initialTime,
                                  selectionMode:
                                      DateRangePickerSelectionMode.range,
                                ),
                              ),
                            ),
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
        const SizedBox(
          height: 3,
        ),
        dateDifference != null
            ? fromText == ""
                ? Container()
                : Container(
                    padding: const EdgeInsets.all(5),
                    alignment: Alignment.centerRight,
                    child: AutoSizeText(
                      "${getTranslated(context, "تم اختيار")} $dateDifference ${getTranslated(context, "يوم")} ",
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.w300),
                    ))
            : Container(),
        const SizedBox(
          height: 5,
        ),
        VacationCardHeader(
          header: getTranslated(context, "نوع الأجازة"),
        ),
        vacationDropdown,
        DetialsTextField(commentController),
        SizedBox(
          height: 50.h,
        ),
        Provider.of<UserPermessionsData>(context).isLoading ||
                Provider.of<UserHolidaysData>(context).isLoading
            ? const CircularProgressIndicator(backgroundColor: Colors.orange)
            : RoundedButton(
                onPressed: () async {
                  saveButtonFun();
                },
                title: getTranslated(context, "حفظ"),
              )
      ],
    );
  }
}
