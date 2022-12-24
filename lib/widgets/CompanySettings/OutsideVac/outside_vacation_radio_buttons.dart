import 'package:flutter/cupertino.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Screens/SystemScreens/ReportScreens/RadioButtonWidget.dart';

class OutSideVacRadioButtons extends StatelessWidget {
  final int radioValue;
  final Function permFun;
  final Function vacFun;
  final Function missionFun;
  const OutSideVacRadioButtons(
      {this.radioValue, this.missionFun, this.permFun, this.vacFun})
      : super();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RadioButtonWidg(
            radioVal2: radioValue,
            radioVal: 3,
            title: getTranslated(context, "أذن"),
            onchannge: (value) {
              permFun(value);
            },
          ),
          RadioButtonWidg(
            radioVal2: radioValue,
            radioVal: 1,
            title: getTranslated(context, "اجازة"),
            onchannge: (value) {
              vacFun(value);
            },
          ),
          RadioButtonWidg(
            radioVal: 2,
            radioVal2: radioValue,
            title: getTranslated(
              context,
              "مأمورية",
            ),
            onchannge: (value) {
              missionFun(value);
            },
          ),
        ],
      ),
    );
  }
}
