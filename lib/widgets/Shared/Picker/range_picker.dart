import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RangeDatePicker extends StatelessWidget {
  final Function pickerFun;
  final DateTime fromDate, toDate, maxDate, minDate;
  final Function onSelectionChangeFun;
  const RangeDatePicker(
      {@required this.pickerFun,
      @required this.fromDate,
      @required this.toDate,
      this.maxDate,
      this.onSelectionChangeFun,
      this.minDate})
      : super();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400.h,
      child: Center(
        child: SfDateRangePicker(
          confirmText: "حفظ",
          cancelText: "الغاء",
          onSubmit: (date) {
            pickerFun(date);
          },
          onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
            if (onSelectionChangeFun != null)
              onSelectionChangeFun(dateRangePickerSelectionChangedArgs);
          },
          onCancel: () => Navigator.pop(context),
          selectionColor: Colors.orange,
          startRangeSelectionColor: Colors.orange,
          endRangeSelectionColor: Colors.orange,
          showNavigationArrow: true,
          initialSelectedRange: PickerDateRange(
            fromDate,
            toDate,
          ),
          headerHeight: 100,
          initialSelectedDate: fromDate,
          initialDisplayDate: toDate,
          showActionButtons: true,
          maxDate: maxDate ?? DateTime(DateTime.now().year, 12, 31),
          minDate: minDate ??
              DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day + 1),
          selectionMode: DateRangePickerSelectionMode.range,
        ),
      ),
    );
  }
}
