// To parse this JSON data, do
//
//     final showerSection = showerSectionFromJson(jsonString);

import 'dart:convert';

ShowerSection showerSectionFromJson(String str) =>
    ShowerSection.fromJson(json.decode(str));

String showerSectionToJson(ShowerSection data) => json.encode(data.toJson());

class ShowerSection {
  String? id;
  String? sectionName;
  int? orderIndex;
  int? seconds;
  int? minutes;
  int? hours;

  ShowerSection({
    this.id,
    this.sectionName,
    this.orderIndex,
    this.seconds,
    this.minutes,
  }) {
    hours = _getHours();
  }

  factory ShowerSection.fromJson(Map<String, dynamic> json) => ShowerSection(
        id: json["id"],
        sectionName: json["sectionName"],
        orderIndex: json["orderIndex"],
        seconds: json["seconds"],
        minutes: json["minutes"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sectionName": sectionName,
        "orderIndex": orderIndex,
        "seconds": seconds,
        "minutes": minutes,
      };

  int _getHours() {
    return minutes! ~/ 60;
  }

  @override
  String toString() {
    return '{id: $id, sectionName: $sectionName, orderIndex: $orderIndex, hours: $hours, minutes: $minutes, seconds: $seconds}';
  }
}
