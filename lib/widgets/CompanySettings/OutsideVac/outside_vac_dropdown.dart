import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OutsideVacDropDown extends StatelessWidget {
  final List<String> holidayTile;
  final String selectedReason;
  final Function dropdownFun;
  const OutsideVacDropDown(
      {@required this.holidayTile,
      @required this.selectedReason,
      @required this.dropdownFun})
      : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(right: 5.w),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1)),
                height: 40.h,
                child: DropdownButtonHideUnderline(
                    child: DropdownButton(
                  elevation: 2,
                  isExpanded: true,
                  items: holidayTile.map((String x) {
                    return DropdownMenuItem<String>(
                        value: x,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: AutoSizeText(
                            x,
                            style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500),
                          ),
                        ));
                  }).toList(),
                  onChanged: (value) {
                    dropdownFun(value);
                  },
                  value: selectedReason,
                )))));
  }
}
