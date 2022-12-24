import 'package:qr_users/Core/constants.dart';

class User {
  int companyID;
  DateTime createdOn, apkDate, iosBundleDate;
  bool isAllowedToAttend;
  String userToken,
      fcmToken,
      userID,
      email,
      phoneNum,
      userJob,
      password,
      userImage,
      id,
      name;

  int userSiteId, osType;
  double salary;
  int userShiftId;
  int userType;
  User(
      {this.userToken,
      this.fcmToken,
      this.id,
      this.userImage,
      this.salary,
      this.isAllowedToAttend,
      this.userShiftId,
      this.userSiteId,
      this.userID,
      this.name,
      this.createdOn,
      this.userJob,
      this.companyID,
      this.email,
      this.userType,
      this.phoneNum,
      this.password,
      this.osType,
      this.apkDate,
      this.iosBundleDate});

  factory User.fromJson(dynamic json) {
    return User(
      userToken: json["token"],
      id: json["userData"]["id"],
      userID: json["userData"]["userName"],
      name: json["userData"]["userName1"],
      userJob: json["userData"]["userJob"],
      email: json["userData"]["email"],
      phoneNum: json["userData"]["phoneNumber"],
      userType: json["userData"]["userType"],
      // fcmToken: json["userData"]["fcmToken"],
      // osType: json["userData"]["mobileOS"],
      companyID: json['companyData']['id'],
      salary: json["userData"]["salary"],
      createdOn: DateTime.tryParse(json["userData"]["createdOn"]),
      // apkDate: DateTime.tryParse(json["apkDate"]["apkDate"]),
      // iosBundleDate: DateTime.tryParse(json["apkDate"]["ios"]),
      userSiteId: json["userData"]["siteId"] as int,
      userShiftId: json["userData"]["shiftId"],
      // isAllowedToAttend: json["userData"]["isAllowtoAttend"],
      userImage: "$imageUrl${json["userData"]["userImage"]}",
      // userImage: "$imageUrl${json["userData"]["userName"]}.png",
    );
  }
}
