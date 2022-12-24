import 'dart:developer';

// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_users/Core/lang/Localization/localizationConstant.dart';
import 'package:qr_users/Core/constants.dart';
import 'package:qr_users/Network/Network.dart';
import 'package:qr_users/Network/NetworkFaliure.dart';
import 'package:qr_users/enums/request_type.dart';
import 'package:qr_users/services/AllSiteShiftsData/sites_shifts_dataService.dart';
import 'package:qr_users/services/Sites_data.dart';
import 'package:qr_users/services/UserMissions/Models/CompanyMissions.dart';
import 'package:qr_users/services/user_data.dart';

import '../../main.dart';
import 'Models/my_internal_missions.dart';

class UserMissions {
  UserMissions(
      {this.description,
      this.fromDate,
      this.shiftId,
      this.toDate,
      this.userId});

  factory UserMissions.fromJson(dynamic json) {
    return UserMissions(
        description: json["desc"],
        fromDate: DateTime.tryParse(json["fromdate"]),
        toDate: DateTime.tryParse(json["toDate"]),
        shiftId: json["shiftId"],
        userId: json["userId"]);
  }

  int shiftId;
  DateTime fromDate, toDate;
  String description, userId;
}

class MissionsData with ChangeNotifier {
  List<CompanyMissions> companyMissionsList = [];
  List<CompanyMissions> copyMissionsList = [];
  String errorMsg = "";
  int internalMissionsCount = 0, externalMissionsCount = 0;
  bool isLoading = false;

  List<UserMissions> missionsList = [];
  bool missionsLoading = false;
  MyInternalMissions myInternalMissions;
  List<CompanyMissions> singleUserMissionsList = [];
  List<String> userNames = [];

  getAllUserNamesInMission() {
    userNames = [];
    companyMissionsList.forEach((element) {
      userNames.add(element.userName);
    });
    // notifyListeners();
  }

  setCopyByIndex(List<int> index) {
    copyMissionsList = [];

    for (int i = 0; i < index.length; i++) {
      copyMissionsList.add(companyMissionsList[index[i]]);
    }

    notifyListeners();
  }

  getSingleUserMissions(String userId, String userToken,
      [DateTime startDate, DateTime endDate]) async {
    String startTime;
    String endingTime;
    errorMsg = "";
    externalMissionsCount = 0;
    internalMissionsCount = 0;
    if (startDate != null && endDate != null) {
      startTime = startDate.toString().substring(0, 11);
      endingTime = endDate.toString().substring(0, 11);
    } else {
      startTime = DateTime(
        DateTime.now().year,
        1,
        1,
      ).toString().substring(0, 11);
      endingTime =
          DateTime(DateTime.now().year, 12, 30).toString().substring(0, 11);
    }

    missionsLoading = true;
    final response = await http.get(
        Uri.parse(
            "$baseURL/api/InternalMission/GetInExternalMissionPeriodbyUser/$userId/$startTime/$endingTime"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        });
    log(response.request.toString());
    log(response.body);
    print(response.statusCode);
    missionsLoading = false;
    final decodedResp = json.decode(response.body);
    if (decodedResp["message"] == "Success") {
      final missionsObj =
          jsonDecode(response.body)['data']["ExternalMissions"] as List;
      final internalObj =
          jsonDecode(response.body)['data']["InternalMissions"] as List;

      final List<CompanyMissions> externalMissions = missionsObj
          .map((json) => CompanyMissions.fromJsonExternal(json))
          .toList();
      final List<CompanyMissions> internalMissions = internalObj
          .map((json) => CompanyMissions.fromJsonInternal(json))
          .toList();
      singleUserMissionsList =
          [...externalMissions, ...internalMissions].toSet().toList();
      if (singleUserMissionsList.length > 0) {
        externalMissionsCount =
            jsonDecode(response.body)['data']["TotalExternalMission"];
        internalMissionsCount =
            jsonDecode(response.body)['data']["TotalInternal"];
      }
    } else if (decodedResp["message"] ==
        "Success: older than user creation date") {
      errorMsg = "older than user creation date";
    }

    notifyListeners();
  }

  getMyInternalMission() async {
    final String userToken = locator.locator<UserData>().user.userToken;
    errorMsg = "";
    isLoading = true;
    notifyListeners();
    final response = await NetworkApi().request(
      "$baseURL/api/InternalMission/mine",
      RequestType.GET,
      {
        'Content-type': 'application/json',
        'Authorization': "Bearer $userToken"
      },
    );
    isLoading = false;
    if (response is Faliure) {
      print(response.errorResponse);
    } else {
      if (response == "There is no internal missions for this user!" ||
          response.toString() == "") {
        myInternalMissions = null;
        errorMsg = 'empty';
      } else {
        final decodedResponse = json.decode(response);
        myInternalMissions = MyInternalMissions.fromJson(decodedResponse);
      }
    }
    notifyListeners();
  }

  addUserExternalMission(UserMissions userMissions, String userToken) async {
    isLoading = true;
    notifyListeners();

    final response = await http.post(
        Uri.parse("$baseURL/api/externalMissions/Add"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode({
          "fromdate": userMissions.fromDate.toIso8601String(),
          "shiftId": userMissions.shiftId,
          "toDate": userMissions.toDate.toIso8601String(),
          "userId": userMissions.userId,
          "desc": userMissions.description,
          "adminResponse": ""
        }));
    isLoading = false;
    notifyListeners();
    return json.decode(response.body)["message"];
  }

  addUserInternalMission(
    UserMissions userMissions,
    String userToken,
  ) async {
    isLoading = true;
    notifyListeners();
    log(userMissions.fromDate.toString().substring(0, 11).toString());
    final response = await http.post(
        Uri.parse("$baseURL/api/InternalMission/AddInternalMission"),
        headers: {
          'Content-type': 'application/json',
          'Authorization': "Bearer $userToken"
        },
        body: json.encode({
          "fromdate": userMissions.fromDate.toString().substring(0, 11).trim(),
          "shiftId": userMissions.shiftId,
          "toDate": userMissions.toDate.toString().substring(0, 11).trim(),
          "userId": userMissions.userId,
          "desc": userMissions.description,
        }));
    print(response.body);
    isLoading = false;
    notifyListeners();
    return json.decode(response.body)["message"];
  }

  addInternalMission(
      BuildContext context,
      TextEditingController picked,
      String description,
      DateTime fromDate,
      DateTime toDate,
      String userId,
      String fcmToken,
      int osType,
      String sitename,
      String shiftName) async {
    final prov = Provider.of<SiteData>(context, listen: false);
    log(shiftName);
    if (prov.siteValue == "كل المواقع" || picked.text.isEmpty) {
      Fluttertoast.showToast(
          msg: getTranslated(context, "برجاء ادخال البيانات المطلوبة"),
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER);
    } else if (shiftName == "لا يوجد مناوبات بهذا الموقع") {
      displayErrorToast(context, "برجاء اختيار مناوبة");
    } else {
      final String msg = await addUserInternalMission(
        UserMissions(
            description: description ?? "لا يوجد تفاصيل",
            fromDate: fromDate,
            toDate: toDate,
            shiftId: Provider.of<SiteShiftsData>(context, listen: false)
                .shifts[prov.dropDownShiftIndex]
                .shiftId,
            userId: userId),
        Provider.of<UserData>(context, listen: false).user.userToken,
      );
      if (msg == "Success : InternalMission Created!") {
        Fluttertoast.showToast(
            msg: getTranslated(
              context,
              "تم الإضافة بنجاح",
            ),
            backgroundColor: Colors.green,
            gravity: ToastGravity.CENTER);

        Navigator.pop(context);
      } else if (msg ==
          "Failed : Another InternalMission not approved for this user!") {
        displayErrorToast(context, "تم وضع مأمورية لهذا المستخدم من قبل");
      } else if (msg ==
          "Failed : There is an external mission for this user in this period!") {
        displayErrorToast(context, 'يوجد مأمورية خارجية فى هذا اليوم');
      } else if (msg ==
          'Failed : There are an internal mission in this period!') {
        displayErrorToast(context, 'يوجد مأمورية داخلية فى هذا التاريخ');
      } else if (msg == "Failed : User has a schedule shift in this period!") {
        displayErrorToast(
            context, "خطأ : هذا المسخدم لديه جدولة فى نفس الفترة");
      } else {
        displayErrorToast(context, "خطأ فى اضافة المأمورية");
      }
    }
  }
}
