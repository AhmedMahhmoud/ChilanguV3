class MyInternalMissions {
  MyInternalMissions(
      {this.fromDate,
      this.toDate,
      this.siteName,
      this.shiftName,
      this.fridayShiftEntime,
      this.shiftSttime,
      this.shiftEntime,
      this.sunShiftSttime,
      this.fridayShiftSttime,
      this.sunShiftEntime,
      this.monShiftSttime,
      this.mondayShiftEntime,
      this.tuesdayShiftEntime,
      this.thursdayShiftEntime,
      this.thursdayShiftSttime,
      this.wednesdayShiftSttime,
      this.tuesdayShiftSttime,
      this.wednesdayShiftEntime});

  factory MyInternalMissions.fromJson(dynamic json) {
    return MyInternalMissions(
        fromDate: DateTime.tryParse(json["fromDate"]),
        toDate: DateTime.tryParse(json["toDate"]),
        shiftName: json["shiftData"]["shiftName"],
        shiftSttime: json["shiftData"]["shiftSttime"],
        shiftEntime: json["shiftData"]["shiftEntime"],
        tuesdayShiftEntime: json["shiftData"]["tuesdayShiftSttime"],
        tuesdayShiftSttime: json["shiftData"]["tuesdayShiftSttime"],
        sunShiftSttime: json["shiftData"]["sunShiftSttime"],
        sunShiftEntime: json["shiftData"]["sunShiftEntime"],
        monShiftSttime: json["shiftData"]["monShiftSttime"],
        mondayShiftEntime: json["shiftData"]["mondayShiftEntime"],
        wednesdayShiftSttime: json["shiftData"]["wednesdayShiftSttime"],
        wednesdayShiftEntime: json["shiftData"]["wednesdayShiftEntime"],
        thursdayShiftSttime: json["shiftData"]["thursdayShiftSttime"],
        thursdayShiftEntime: json["shiftData"]["thursdayShiftEntime"],
        fridayShiftSttime: json["shiftData"]["fridayShiftSttime"],
        fridayShiftEntime: json["shiftData"]["fridayShiftEntime"],
        siteName: json["siteName"]);
  }

  String sunShiftSttime,
      sunShiftEntime,
      monShiftSttime,
      mondayShiftEntime,
      tuesdayShiftSttime,
      tuesdayShiftEntime,
      wednesdayShiftSttime,
      wednesdayShiftEntime,
      thursdayShiftSttime,
      thursdayShiftEntime,
      fridayShiftSttime,
      fridayShiftEntime,
      shiftSttime,
      shiftEntime;

  String shiftName;
  String siteName;
  DateTime fromDate, toDate;
}
