// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

TagInformation tagInformationFromJson(String str) => TagInformation.fromJson(json.decode(str));

String welcomeToJson(TagInformation data) => json.encode(data.toJson());

class TagInformation {
  TagInformation({
    this.tagList,
  });

  List<TagList> tagList;

  factory TagInformation.fromJson(Map<String, dynamic> json) => TagInformation(
        tagList: json["TagList"] == null ? null : List<TagList>.from(json["TagList"].map((x) => TagList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "TagList": tagList == null ? null : List<dynamic>.from(tagList.map((x) => x.toJson())),
      };
}

class TagList {
  TagList({
    this.tagNumber,
    this.currentPosition,
    this.tagPositions,
  });

  String tagNumber;
  int currentPosition;
  List<TagPosition> tagPositions;

  factory TagList.fromJson(Map<String, dynamic> json) => TagList(
        tagNumber: json["TagNumber"] == null ? null : json["TagNumber"],
        currentPosition: json["CurrentPosition"] == null ? null : json["CurrentPosition"],
        tagPositions: json["TagPositions"] == null ? null : List<TagPosition>.from([TagPosition.fromJson((json["TagPositions"] as List).first)]),
      );

  Map<String, dynamic> toJson() => {
        "TagNumber": tagNumber == null ? null : tagNumber,
        "CurrentPosition": currentPosition == null ? null : currentPosition,
        "TagPositions": tagPositions == null ? null : List<dynamic>.from(tagPositions.map((x) => x.toJson())),
      };
}

class TagPosition {
  TagPosition({
    this.containerCode,
  });

  String containerCode;

  factory TagPosition.fromJson(Map<String, dynamic> json) => TagPosition(
        containerCode: json["ContainerCode"] == null ? null : json["ContainerCode"],
      );

  Map<String, dynamic> toJson() => {
        "ContainerCode": containerCode == null ? null : containerCode,
      };
}
