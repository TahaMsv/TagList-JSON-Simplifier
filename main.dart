import 'dart:convert';
import 'dart:io';
import 'classes.dart';

String findStem(List<String> arr) {
  int size = arr.length;

  arr.sort();
  int length = arr[0].length;
  String res = "";
  // Comapre the first and the last strings character
  // by character.
  for (int i = 0; i < length; i++) {
    // If the characters match, append the character to the result.
    if (arr[0][i] == arr[size - 1][i]) {
      res += arr[0][i];
    }
    // Else, stop the comparison.
    else {
      break;
    }
  }
  return res;
}

String removeCommonWithLastNumber(String lastNumber, String range) {
  String result = "";
  if (range.contains("_")) {
    String start = range.split("_")[0];
    String end = range.split("_")[1];
    start = start.replaceFirst(findStem([lastNumber, start]), "");
    end = end.replaceFirst(findStem([start, end]), "");
    result = start + "_" + end;
  } else {
    result = range.replaceFirst(findStem([lastNumber, range]), "");
  }
  return result;
}

String oddFunction(String tagNumbersRange) {
  String result = "";
  List<String> ranges = tagNumbersRange.split(",");
  if (ranges.length < 2) {
    return tagNumbersRange;
  }
  List<String> oddTagNumbers = [];
  for (var i = 0; i < ranges.length - 1; ++i) {
    String tn = ranges[i];
    if (tn.contains("_")) {
      String s = tn.split("_")[0];
      String e = tn.split("_")[1];
      String splitCharacter = "";
      switch (e.length) {
        case 0:
          splitCharacter = 'a'; // 0 character back
          break;
        case 1:
          splitCharacter = 'b'; // 1 character back
          break;
        case 2:
          splitCharacter = 'c'; // 2 character back
          break;
        case 3:
          splitCharacter = 'd'; // ...
          break;
        case 4:
          splitCharacter = 'e';
          break;
        case 5:
          splitCharacter = 'f';
          break;
        case 6:
          splitCharacter = 'g';
          break;
        case 7:
          splitCharacter = 'h';
          break;
        case 8:
          splitCharacter = 'i';
          break;
        case 9:
          splitCharacter = 'j';
          break;
        case 10:
          splitCharacter = 'k';
          break;
        case 11:
          splitCharacter = 'l';
          break;
        case 12:
          splitCharacter = 'm';
          break;
      }
      oddTagNumbers.add(s + e + splitCharacter);
    } else {
      oddTagNumbers.add(tn + "a"); //   ,14,  ==> 14a
    }
  }
  result = oddTagNumbers.join("") + ranges[ranges.length - 1];
  return result;
}

String convertJsonToFormattedString(TagInformation tagInformation) {
  Map<int, Map<String, List<String>>> compressedInformation = new Map();
  Map<int, Map<String, String>> stems = new Map();
  for (var i = 0; i < tagInformation.tagList.length; ++i) {
    String tagNumber = tagInformation.tagList[i].tagNumber;
    int currentPosition = tagInformation.tagList[i].currentPosition;
    String containerCode = tagInformation.tagList[i].tagPositions[0].containerCode;

    if (containerCode == "") containerCode = "!";

    if (compressedInformation.containsKey(currentPosition)) {
      if (compressedInformation[currentPosition].containsKey(containerCode)) {
        compressedInformation[currentPosition][containerCode].add(tagNumber);
      } else {
        compressedInformation[currentPosition][containerCode] = List<String>.from([tagNumber]);
      }
    } else {
      Map<String, List<String>> temp = new Map();
      temp[containerCode] = List<String>.from([tagNumber]);
      compressedInformation[currentPosition] = temp;

      Map<String, String> tempForStem = new Map();
      stems[currentPosition] = tempForStem;
    }
  }

  String compressedString = "";
  // print("////////////////////////////////////////////");
  compressedInformation.forEach((k, v) {
    String containerCodesString = "";
    compressedInformation[k].forEach((k2, v2) {
      List<String> tagNumbers = [];

      for (var i = 0; i < v2.length; ++i) {
        tagNumbers.add(v2[i]);
      }
      String stem = findStem(tagNumbers);
      stems[k][k2] = stem;
      for (var i = 0; i < v2.length; ++i) {
        if (v2[i].startsWith(stem)) {
          v2[i] = v2[i].replaceFirst(stem, "");
        } else {
          v2[i] = "-" + v2[i];
        }
      }

      v2.sort();

      String tagNumbersString = "";
      if (v2.length > 1) {
        List<String> numbersInRow = [];
        List<int> numbers = v2.map(int.parse).toList();
        int startNumberIndex = 0, endNumberIndex = 0;
        for (var i = 1; i < numbers.length; ++i) {
          if (numbers[i] - 1 == numbers[endNumberIndex]) {
            endNumberIndex = i;
          } else {
            String combinedNumbers = "";
            if (numbers[startNumberIndex] == numbers[endNumberIndex]) {
              combinedNumbers = v2[startNumberIndex];
            } else {
              String stem = findStem([v2[startNumberIndex], v2[endNumberIndex]]);
              String endNumberString = v2[endNumberIndex].toString().replaceFirst(stem, "");
              combinedNumbers = v2[startNumberIndex] + "_" + endNumberString;
            }
            numbersInRow.add(combinedNumbers);

            startNumberIndex = endNumberIndex = i;
          }
          if (i == numbers.length - 1) {
            String combinedNumbers = "";
            if (numbers[startNumberIndex] == numbers[endNumberIndex]) {
              combinedNumbers = v2[startNumberIndex];
            } else {
              String stem = findStem([v2[startNumberIndex], v2[endNumberIndex]]);
              String endNumberString = v2[endNumberIndex].toString().replaceFirst(stem, "");
              combinedNumbers = v2[startNumberIndex] + "_" + endNumberString;
            }
            numbersInRow.add(combinedNumbers);
          }
        }
        tagNumbersString = numbersInRow.join(',');
      } else {
        tagNumbersString = v2.join(',');
      }
      containerCodesString += "{" + (k2 + "=" + stem + ":" + tagNumbersString);
    });
    compressedString += ("}" + (k.toString() + "=" + containerCodesString));
  });

  compressedString = tagInformation.tagList.length.toString() + compressedString;

  return compressedString;
}

String convertJsonToFormattedString2(TagInformation tagInformation) {
  Map<int, Map<String, List<String>>> compressedInformation = new Map();
  for (var i = 0; i < tagInformation.tagList.length; ++i) {
    String tagNumber = tagInformation.tagList[i].tagNumber;
    int currentPosition = tagInformation.tagList[i].currentPosition;
    String containerCode = tagInformation.tagList[i].tagPositions[0].containerCode;

    if (containerCode == "") containerCode = "!";

    if (compressedInformation.containsKey(currentPosition)) {
      if (compressedInformation[currentPosition].containsKey(containerCode)) {
        compressedInformation[currentPosition][containerCode].add(tagNumber);
      } else {
        compressedInformation[currentPosition][containerCode] = List<String>.from([tagNumber]);
      }
    } else {
      Map<String, List<String>> temp = new Map();
      temp[containerCode] = List<String>.from([tagNumber]);
      compressedInformation[currentPosition] = temp;
    }
  }

  String compressedString = "";
  // print("////////////////////////////////////////////");
  List<String> listOfStems = [];
  compressedInformation.forEach((k, v) {
    String containerCodesString = "";

    compressedInformation[k].forEach((k2, v2) {
      List<String> tagNumbers = [];

      for (var i = 0; i < v2.length; ++i) {
        tagNumbers.add(v2[i]);
      }
      String stem = findStem(tagNumbers);
      listOfStems.add(stem);
      for (var i = 0; i < v2.length; ++i) {
        if (v2[i].startsWith(stem)) {
          v2[i] = v2[i].replaceFirst(stem, "");
        } else {
          v2[i] = "-" + v2[i];
        }
      }

      v2.sort();

      String tagNumbersString = "";
      if (v2.length > 1) {
        List<String> numbersInRow = [];
        List<int> numbers = v2.map(int.parse).toList();
        int startNumberIndex = 0, endNumberIndex = 0;
        String lastNumber = v2[startNumberIndex];
        bool addingFirstRange = true;
        for (var i = 1; i < numbers.length; ++i) {
          if (numbers[i] - 1 == numbers[endNumberIndex]) {
            endNumberIndex = i;
          } else {
            String combinedNumbers = "";
            if (numbers[startNumberIndex] == numbers[endNumberIndex]) {
              combinedNumbers = v2[startNumberIndex];
            } else {
              String stem = findStem([v2[startNumberIndex], v2[endNumberIndex]]);
              String endNumberString = v2[endNumberIndex].toString().replaceFirst(stem, "");
              combinedNumbers = v2[startNumberIndex] + "_" + endNumberString;
            }
            if (addingFirstRange) {
              numbersInRow.add(combinedNumbers);
              addingFirstRange = false;
            } else {
              numbersInRow.add(removeCommonWithLastNumber(lastNumber, combinedNumbers));
            }
            lastNumber = v2[endNumberIndex];
            startNumberIndex = endNumberIndex = i;
          }
          if (i == numbers.length - 1) {
            String combinedNumbers = "";
            if (numbers[startNumberIndex] == numbers[endNumberIndex]) {
              combinedNumbers = v2[startNumberIndex];
            } else {
              String stem = findStem([v2[startNumberIndex], v2[endNumberIndex]]);
              String endNumberString = v2[endNumberIndex].toString().replaceFirst(stem, "");
              combinedNumbers = v2[startNumberIndex] + "_" + endNumberString;
            }
            if (addingFirstRange) {
              numbersInRow.add(combinedNumbers);
              addingFirstRange = false;
            } else {
              numbersInRow.add(removeCommonWithLastNumber(lastNumber, combinedNumbers));
            }
            lastNumber = v2[endNumberIndex];
          }
        }
        tagNumbersString = numbersInRow.join(',');
      } else {
        tagNumbersString = v2.join(',');
      }
      containerCodesString += "{" + (k2 + "=" + stem + ":" + tagNumbersString);
    });

    compressedString += ("}" + (k.toString() + "=" + containerCodesString));
  });
  String stemOfStems = findStem(listOfStems);
  compressedString = compressedString.replaceAll("=" + stemOfStems, "=");
  compressedString = tagInformation.tagList.length.toString() + "," + stemOfStems + compressedString;

  return compressedString;
}

String convertJsonToFormattedString3(TagInformation tagInformation) {
  Map<int, Map<String, List<String>>> compressedInformation = new Map();
  for (var i = 0; i < tagInformation.tagList.length; ++i) {
    String tagNumber = tagInformation.tagList[i].tagNumber;
    int currentPosition = tagInformation.tagList[i].currentPosition;
    String containerCode = tagInformation.tagList[i].tagPositions[0].containerCode;

    if (containerCode == "") containerCode = "!";

    if (compressedInformation.containsKey(currentPosition)) {
      if (compressedInformation[currentPosition].containsKey(containerCode)) {
        compressedInformation[currentPosition][containerCode].add(tagNumber);
      } else {
        compressedInformation[currentPosition][containerCode] = List<String>.from([tagNumber]);
      }
    } else {
      Map<String, List<String>> temp = new Map();
      temp[containerCode] = List<String>.from([tagNumber]);
      compressedInformation[currentPosition] = temp;
    }
  }

  String compressedString = "";
  // print("////////////////////////////////////////////");
  List<String> listOfStems = [];
  compressedInformation.forEach((k, v) {
    String containerCodesString = "";

    compressedInformation[k].forEach((k2, v2) {
      List<String> tagNumbers = [];

      for (var i = 0; i < v2.length; ++i) {
        tagNumbers.add(v2[i]);
      }
      String stem = findStem(tagNumbers);
      listOfStems.add(stem);
      for (var i = 0; i < v2.length; ++i) {
        if (v2[i].startsWith(stem)) {
          v2[i] = v2[i].replaceFirst(stem, "");
        } else {
          v2[i] = "-" + v2[i];
        }
      }

      v2.sort();

      String tagNumbersString = "";
      if (v2.length > 1) {
        List<String> numbersInRow = [];
        List<int> numbers = v2.map(int.parse).toList();
        int startNumberIndex = 0, endNumberIndex = 0;
        String lastNumber = v2[startNumberIndex];
        bool addingFirstRange = true;
        for (var i = 1; i < numbers.length; ++i) {
          if (numbers[i] - 1 == numbers[endNumberIndex]) {
            endNumberIndex = i;
          } else {
            String combinedNumbers = "";
            if (numbers[startNumberIndex] == numbers[endNumberIndex]) {
              combinedNumbers = v2[startNumberIndex];
            } else {
              String stem = findStem([v2[startNumberIndex], v2[endNumberIndex]]);
              String endNumberString = v2[endNumberIndex].toString().replaceFirst(stem, "");
              combinedNumbers = v2[startNumberIndex] + "_" + endNumberString;
            }
            if (addingFirstRange) {
              numbersInRow.add(combinedNumbers);
              addingFirstRange = false;
            } else {
              numbersInRow.add(removeCommonWithLastNumber(lastNumber, combinedNumbers));
            }
            lastNumber = v2[endNumberIndex];
            startNumberIndex = endNumberIndex = i;
          }
          if (i == numbers.length - 1) {
            String combinedNumbers = "";
            if (numbers[startNumberIndex] == numbers[endNumberIndex]) {
              combinedNumbers = v2[startNumberIndex];
            } else {
              String stem = findStem([v2[startNumberIndex], v2[endNumberIndex]]);
              String endNumberString = v2[endNumberIndex].toString().replaceFirst(stem, "");
              combinedNumbers = v2[startNumberIndex] + "_" + endNumberString;
            }
            if (addingFirstRange) {
              numbersInRow.add(combinedNumbers);
              addingFirstRange = false;
            } else {
              numbersInRow.add(removeCommonWithLastNumber(lastNumber, combinedNumbers));
            }
            lastNumber = v2[endNumberIndex];
          }
        }
        tagNumbersString = numbersInRow.join(',');
      } else {
        tagNumbersString = v2.join(',');
      }
      tagNumbersString = oddFunction(tagNumbersString);
      containerCodesString += "{" + (k2 + "=" + stem + ":" + tagNumbersString);
    });

    compressedString += ("}" + (k.toString() + "=" + containerCodesString));
  });
  String stemOfStems = findStem(listOfStems);
  compressedString = compressedString.replaceAll("=" + stemOfStems, "=");
  compressedString = tagInformation.tagList.length.toString() + "," + stemOfStems + compressedString;

  return compressedString;
}

TagInformation convertFormattedStringToJson(String formattedString) {
  Map<int, Map<String, List<String>>> mapOfAllTags = new Map();
  Map<int, int> numberOfTagsByPositionNumber = new Map();
  Map<String, int> numberOfTagsByContainerCode = new Map();

  List<String> separatedByCurrentPosition = formattedString.split("}");
  int numberOfTags = int.parse(separatedByCurrentPosition[0].split(",")[0]);
  String stemOfStems = separatedByCurrentPosition[0].split(",")[1];

  separatedByCurrentPosition.removeWhere((element) => element == "");

  TagInformation tagInformation = TagInformation();
  tagInformation.tagList = [];
  for (var i = 1; i < separatedByCurrentPosition.length; ++i) {
    // print("*************************${i}*****************************");
    int currentPosition = int.parse(separatedByCurrentPosition[i].substring(0, separatedByCurrentPosition[i].indexOf("=")));
    mapOfAllTags[currentPosition] = new Map();
    numberOfTagsByPositionNumber[currentPosition] = 0;
    // print("currentPosition: " + currentPosition.toString());
    List<String> containerCodesAndTagNumbers = separatedByCurrentPosition[i].substring(separatedByCurrentPosition[i].indexOf("=") + 1).split("{");
    containerCodesAndTagNumbers.removeWhere((element) => element == "");

    for (var j = 0; j < containerCodesAndTagNumbers.length; ++j) {
      // print("/////////////////////////////${j}////////////////////////");

      String containerCode = containerCodesAndTagNumbers[j].substring(0, containerCodesAndTagNumbers[j].indexOf("="));
      mapOfAllTags[currentPosition][containerCode] = [];
      numberOfTagsByContainerCode[containerCode] = 0;
      List<String> stemAndTagNumbers = containerCodesAndTagNumbers[j].substring(containerCodesAndTagNumbers[j].indexOf("=") + 1).split(":");
      String stem = stemOfStems + stemAndTagNumbers[0];
      String oddTagNumbers = stemAndTagNumbers[1];
      String tagNumbersRange = convertToNormalRange(oddTagNumbers);

      List<String> compressedTagNumbers = tagNumbersRange.split(",");
      List<String> tagNumbers = [];
      for (var k = 0; k < compressedTagNumbers.length; ++k) {
        if (compressedTagNumbers[k].contains("_")) {
          String startNumber = compressedTagNumbers[k].split("_")[0];
          String endNumber = compressedTagNumbers[k].split("_")[1];

          int l = compressedTagNumbers[k].split("_")[1].length;

          int s = int.parse(startNumber);
          int e = int.parse(endNumber);

          for (var m = s; m <= e; ++m) {
            String mString = m.toString().padLeft(l, "0");
            tagNumbers.add(mString);
            // stdout.write(mString+",");
          }
        } else {
          tagNumbers.add(compressedTagNumbers[k]);
          // stdout.write(compressedTagNumbers[k]+",");
        }
      }
      // print(tagNumbers);
      for (var k = 0; k < tagNumbers.length; ++k) {
        if (!tagNumbers[k].startsWith("-")) {
          tagNumbers[k] = stem + tagNumbers[k];
        }
        // print("currentPosition: " + currentPosition.toString());
        // print("tagNumbers: " + tagNumbers[k]);
        // print("containerCode: " + containerCode);
        // print("//////////");
        mapOfAllTags[currentPosition][containerCode].add(tagNumbers[k]);
        numberOfTagsByPositionNumber[currentPosition]++;
        numberOfTagsByContainerCode[containerCode]++;

        TagList tagList = TagList(
          currentPosition: currentPosition,
          tagNumber: tagNumbers[k],
          tagPositions: [
            containerCode == "!" ? TagPosition(containerCode: null) : TagPosition(containerCode: containerCode),
          ],
        );
        tagInformation.tagList.add(tagList);
      }

      // print("tagNumbers after adding stem: " + tagNumbers.toString());
    }
  }

  print("Total  number of tags: ${numberOfTags}");
  print("////////////////////////////////////////");
  numberOfTagsByPositionNumber.forEach((k, v) => print("Position number : $k    ==>    Number of tags : $v"));
  print("////////////////////////////////////////");
  numberOfTagsByContainerCode.forEach((k, v) => print("Container Code : $k    ==>    Number of tags : $v"));

  return tagInformation;
}

String convertToNormalRange(String oddTagNumbers) {
  String tagNumbersRange = "";
  for (var k = 0; k < oddTagNumbers.length; ++k) {
    String ch = oddTagNumbers.substring(k, k + 1);
    if (ch.contains(new RegExp('^[a-z]+'))) {
      // print(oddTagNumbers.substring(k, k + 1));
      int lengthOfEnd;
      switch (ch) {
        case "a":
          lengthOfEnd = 0;
          break;
        case "b":
          lengthOfEnd = 1;
          break;
        case "c":
          lengthOfEnd = 2;
          break;
        case "d":
          lengthOfEnd = 3;
          break;
        case "e":
          lengthOfEnd = 4;
          break;
        case "f":
          lengthOfEnd = 5;
          break;
        case "g":
          lengthOfEnd = 6;
          break;
        case "h":
          lengthOfEnd = 7;
          break;
        case "i":
          lengthOfEnd = 8;
          break;
        case "j":
          lengthOfEnd = 9;
          break;
        case "k":
          lengthOfEnd = 10;
          break;
        case "l":
          lengthOfEnd = 11;
          break;
      }
      String end = tagNumbersRange.substring(tagNumbersRange.length - lengthOfEnd);
      tagNumbersRange = tagNumbersRange.substring(0, tagNumbersRange.length - lengthOfEnd) + (lengthOfEnd == 0 ? "" : "_") + end + ",";
    } else {
      tagNumbersRange += ch;
    }
  }
  if (tagNumbersRange == "") {
    return tagNumbersRange;
  } else {
    List<String> oddTagNumbersList = tagNumbersRange.split(",");
    List<String> tagNumbersList = [];
    if (oddTagNumbersList.length > 0) {
      bool firstRange = true;
      int maxLengthOfNumber = oddTagNumbersList[0].contains("_") ? oddTagNumbersList[0].split("_")[0].length : oddTagNumbersList[0].length;
      int lastNumber = int.parse((oddTagNumbersList[0].contains("_") ? oddTagNumbersList[0].split("_")[0] : oddTagNumbersList[0]));
      String lastNumberString = lastNumber.toString().padLeft(maxLengthOfNumber, "0");
      String start, end;

      for (var i = 0; i < oddTagNumbersList.length; ++i) {
        var tn = oddTagNumbersList[i];
        if (tn.contains("_")) {
          start = tn.split("_")[0];
          end = tn.split("_")[1];
          if (firstRange) {
            firstRange = false;
            end = start.substring(0, maxLengthOfNumber - end.length) + end;
          } else {
            start = lastNumberString.substring(0, maxLengthOfNumber - start.length) + start;
            lastNumber = int.parse(start);
            lastNumberString = lastNumber.toString().padLeft(maxLengthOfNumber, "0");
            end = lastNumberString.substring(0, maxLengthOfNumber - end.length) + end;
          }
          tagNumbersList.add(start + "_" + end);
        } else {
          start = end = tn;
          if (firstRange) {
            firstRange = false;
          } else {
            start = end = lastNumberString.substring(0, maxLengthOfNumber - end.length) + end;
          }
          tagNumbersList.add(end);
        }
        lastNumber = int.parse(end);
        lastNumberString = lastNumber.toString().padLeft(maxLengthOfNumber, "0");
        // print("start: " + start + " , " + "end: " + end + " , " + "lastNumberString: " + lastNumberString);
      }
    }
    return tagNumbersList.join(",");
  }

  return tagNumbersRange;
}

main() async {
  var jsonInput = await File("je5.json").readAsString();
  TagInformation tagInformation = tagInformationFromJson(jsonInput);
  // // print(jsonDecode(jsonInput));
  //
  // String formattedString = convertJsonToFormattedString(tagInformation);
  // print(formattedString);
  // //
  // print("****************************************");
  //
  // print(convertJsonToFormattedString2(tagInformation));
  // //
  // print("****************************************");
  // //
  print(convertJsonToFormattedString3(tagInformation));
  print("****************************************");
  TagInformation convertedTagInformation = convertFormattedStringToJson(convertJsonToFormattedString3(tagInformation));
  // // print(jsonEncode(convertedTagInformation.toJson()));
  // print("****************************************");
  validation(convertedTagInformation, tagInformation);
}

void validation(TagInformation convertedTagInformation, TagInformation tagInformation) {
  int numberOfEquals = 0;
  for (var i = 0; i < convertedTagInformation.tagList.length; ++i) {
    var tag1 = convertedTagInformation.tagList[i];
    for (var j = 0; j < tagInformation.tagList.length; ++j) {
      var tag2 = tagInformation.tagList[j];
      // print("here");
      if (tag1.tagNumber == tag2.tagNumber) {
        if (tag1.currentPosition == tag2.currentPosition) {
          if (tag1.tagPositions[0].containerCode == null) {
            numberOfEquals++;
            print("${numberOfEquals}- Equal");
          } else if (tag1.tagPositions[0].containerCode == tag2.tagPositions[0].containerCode) {
            numberOfEquals++;
            print("${numberOfEquals}- Equal");
          }

          // else {
          //   print("//////////////");
          //   print(tag1.tagNumber);
          //   tag1.currentPosition.toString();
          //   print("tag1.containerCode: " + tag1.tagPositions[0].containerCode + "  " + "tag2.containerCode: " + tag2.tagPositions[0].containerCode);
          //   print("//////////////");
          // }
        } else {
          print("//////////////");
          print(tag1.tagNumber);
          print("tag1.currentPosition: " + tag1.currentPosition.toString() + "  " + "tag2.currentPosition: " + tag2.currentPosition.toString());
          print("//////////////");
        }
      }
    }
  }
}
