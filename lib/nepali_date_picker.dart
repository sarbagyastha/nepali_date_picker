// Copyright 2018 Sarbagya Dhaubanjar. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// Nepali Date Picker Package
/// Author: Sarbagya Dhaubanjar
///
///                               ,,
///    .M"""bgd                  *MM
///   ,MI    "Y                   MM
///   `MMb.      ,6"Yb.  `7Mb,od8 MM,dMMb.   ,6"Yb.  .P"Ybmmm `7M'   `MF',6"Yb.
///     `YMMNq. 8)   MM    MM' "' MM    `Mb 8)   MM :MI  I8     VA   ,V 8)   MM
///   .     `MM  ,pm9MM    MM     MM     M8  ,pm9MM  WmmmP"      VA ,V   ,pm9MM
///   Mb     dM 8M   MM    MM     MM.   ,M9 8M   MM 8M            VVV   8M   MM
///   P"Ybmmd"  `Moo9^Yo..JMML.   P^YbmdP'  `Moo9^Yo.YMMMMMb      ,V    `Moo9^Yo.
///                                              6'     dP    ,V
///                                              Ybmmmd'   OOb"
///
///
///                ,,                           ,,                             ,,
///   `7MM"""Yb. `7MM                          *MM                             db
///     MM    `Yb. MM                           MM
///     MM     `Mb MMpMMMb.   ,6"Yb.`7MM  `7MM  MM,dMMb.   ,6"Yb.  `7MMpMMMb.`7MM  ,6"Yb.  `7Mb,od8
///     MM      MM MM    MM  8)   MM  MM    MM  MM    `Mb 8)   MM    MM    MM  MM 8)   MM    MM' "'
///     MM     ,MP MM    MM   ,pm9MM  MM    MM  MM     M8  ,pm9MM    MM    MM  MM  ,pm9MM    MM
///     MM    ,dP' MM    MM  8M   MM  MM    MM  MM.   ,M9 8M   MM    MM    MM  MM 8M   MM    MM
///   .JMMmmmdP' .JMML  JMML.`Moo9^Yo.`Mbod"YML.P^YbmdP'  `Moo9^Yo..JMML  JMML.MM `Moo9^Yo..JMML.
///                                                                         QO MP
///                                                                         `bmP

/// Website: https://sarbagyastha.com.np
/// Github: https://github.com/sarbagyastha/

import 'dart:async';
import 'package:flutter/material.dart';

Map daysInMonths = {};
Map startDayInMonths = {};

typedef NepaliDatePickerCallBack(DateTime date);

enum Language { NEPALI, ENGLISH }

class NepaliDatePicker {
  static Future<String> showPicker({
    @required BuildContext context,
    @required int startYear,
    @required int endYear,
    @required NepaliDatePickerCallBack onPicked,
    Language language = Language.ENGLISH,
    bool barrierDismissible,
    Color color = Colors.blue,
  }) async {
    assert(startYear < endYear, 'startYear must be before endYear');

    Widget child = DatePickerDialog(
      startYear: startYear,
      endYear: endYear,
      color: color,
      onPicked: onPicked,
      language: language,
      barrierDismissible: barrierDismissible,
    );

    return await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) => child,
    );
  }
}

class DatePickerDialog extends StatefulWidget {
  final int startYear;
  final int endYear;
  final Color color;
  final Language language;
  final bool barrierDismissible;
  final NepaliDatePickerCallBack onPicked;

  DatePickerDialog(
      {this.startYear,
        this.endYear,
        this.color,
        this.language,
        this.barrierDismissible,
        this.onPicked});
  @override
  _DatePickerDialogState createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  String _selectedYear;
  String _selectedMonth;
  String _selectedDay;
  int duration;
  PageController pageController;
  bool pickDayFirst = true;

  @override
  void initState() {
    var currentDateStringList = DateTime.now().toIso8601String().split("-");
    initializeDaysInMonths();
    initializeStartDayInMonths();
    _convertEnglishDateToNepali(
        int.parse(currentDateStringList[0]),
        int.parse(currentDateStringList[1]),
        int.parse(currentDateStringList[2].split("T").first));
    pageController = PageController(
        initialPage: dateToIndex(
            year: int.parse(_selectedYear), month: int.parse(_selectedMonth)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    duration = widget.endYear - widget.startYear + 1;

    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        if (orientation == Orientation.portrait) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            content: Container(
              height: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildPortraitHeader(indexToMonth(int.parse(_selectedMonth)),
                      _selectedDay, _selectedYear),
                  _buildBody(orientation),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(color: widget.color),
                  )),
              FlatButton(
                  onPressed: () {
                    widget.onPicked(DateTime(int.parse(_selectedYear),
                        int.parse(_selectedMonth), int.parse(_selectedDay)));
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: widget.color),
                  )),
            ],
          );
        } else {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0.0),
            content: Container(
              width: 440,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _buildLandScapeHeader(indexToMonth(int.parse(_selectedMonth)),
                      _selectedDay, _selectedYear),
                  _buildBody(orientation),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "CANCEL",
                    style: TextStyle(color: widget.color),
                  )),
              FlatButton(
                  onPressed: () {
                    widget.onPicked(DateTime(int.parse(_selectedYear),
                        int.parse(_selectedMonth), int.parse(_selectedDay)));
                    Navigator.pop(context);
                  },
                  child: Text(
                    "OK",
                    style: TextStyle(color: widget.color),
                  )),
            ],
          );
        }
      },
    );
  }

  Widget _buildPortraitHeader(String month, String day, String year) {
    return Container(
      padding: EdgeInsets.all(5.0),
      color: widget.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                pickDayFirst = true;
              });
            },
            child: Column(
              children: <Widget>[
                Text(
                  month,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontFamily: "helvetica_neue_light"),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.language == Language.ENGLISH ? day : dayInNepali(day),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 54.0,
                      fontFamily: "helvetica_neue_light"),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                pickDayFirst = false;
              });
            },
            child: Text(
              widget.language == Language.ENGLISH ? year : yearInNepali(year),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontFamily: "helvetica_neue_light"),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLandScapeHeader(String month, String day, String year) {
    return Container(
      padding: EdgeInsets.all(5.0),
      color: widget.color,
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              setState(() {
                pickDayFirst = true;
              });
            },
            child: Column(
              children: <Widget>[
                Text(
                  month,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                      fontFamily: "helvetica_neue_light"),
                  textAlign: TextAlign.center,
                ),
                Text(
                  widget.language == Language.ENGLISH ? day : dayInNepali(day),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 80.0,
                      fontFamily: "helvetica_neue_light"),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              setState(() {
                pickDayFirst = false;
              });
            },
            child: Text(
              widget.language == Language.ENGLISH ? year : yearInNepali(year),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25.0,
                  fontFamily: "helvetica_neue_light"),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Orientation orientation) {
    return Container(
      child: Expanded(
        child: pickDayFirst
            ? PageView.builder(
            itemCount: duration * 12,
            scrollDirection: Axis.vertical,
            controller: pageController,
            onPageChanged: (pageNo) {
              setState(() {
                _selectedMonth = (pageNo % 12 + 1).toString();
                _selectedYear =
                    (widget.startYear + pageNo ~/ 12).toString();
              });
            },
            itemBuilder: (BuildContext context, int index) {
              Timer(Duration(milliseconds: 500), () {
                pageController.jumpToPage(dateToIndex(
                    year: int.parse(_selectedYear),
                    month: int.parse(_selectedMonth)));
              });
              return Container(
                color: Colors.white,
                child: _buildCalender(
                    indexToYear(index),
                    (index % 12 + 1),
                    daysInMonths[indexToYear(index)][index % 12 + 1],
                    startDayInMonths[indexToYear(index)][index % 12 + 1],
                    orientation),
              );
            })
            : yearPicker(),
      ),
    );
  }

  String indexToMonth(int index) {
    switch (index) {
      case 1:
        return widget.language == Language.ENGLISH ? "Baishak" : "बैशाख";
      case 2:
        return widget.language == Language.ENGLISH ? "Jestha" : "जेष्ठ";
      case 3:
        return widget.language == Language.ENGLISH ? "Ashadh" : "आषाढ";
      case 4:
        return widget.language == Language.ENGLISH ? "Shrawan" : "श्रावण";
      case 5:
        return widget.language == Language.ENGLISH ? "Bhadra" : "भाद्र";
      case 6:
        return widget.language == Language.ENGLISH ? "Ashwin" : "आश्विन";
      case 7:
        return widget.language == Language.ENGLISH ? "Kartik" : "कार्तिक";
      case 8:
        return widget.language == Language.ENGLISH ? "Mangsir" : "मंसिर";
      case 9:
        return widget.language == Language.ENGLISH ? "Poush" : "पौष";
      case 10:
        return widget.language == Language.ENGLISH ? "Magh" : "माघ";
      case 11:
        return widget.language == Language.ENGLISH ? "Falgun" : "फाल्गुण";
      case 12:
        return widget.language == Language.ENGLISH ? "Chaitra" : "चैत्र";
      default:
        return "Invalid";
    }
  }

  int indexToYear(int index) {
    int count = 0;
    if (index > 11) {
      while (index > 11) {
        index = index - 12;
        count++;
      }
      return widget.startYear + count;
    } else {
      return widget.startYear;
    }
  }

  int dateToIndex({int year, int month}) {
    int differenceYear = year - widget.startYear;
    int differenceMonth = month - 1;
    int totalDifference = differenceYear * 12 + differenceMonth;
    return totalDifference;
  }

  Widget yearPicker() {
    return ListView.builder(
      itemCount: widget.endYear - widget.startYear + 1,
      controller: ScrollController(
          initialScrollOffset:
          (60 * (double.parse(_selectedYear) - widget.startYear)),
          keepScrollOffset: true),
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () {
            setState(() {
              _selectedYear = (widget.startYear + index).toString();
              pickDayFirst = true;
            });
            Timer(Duration(milliseconds: 500), () {
              pageController.jumpToPage(dateToIndex(
                  year: int.parse(_selectedYear),
                  month: int.parse(_selectedMonth)));
            });
          },
          child: Container(
            decoration: _selectedYear == (widget.startYear + index).toString()
                ? BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            )
                : BoxDecoration(),
            alignment: Alignment(0, 0),
            padding: EdgeInsets.all(20.0),
            child: Text(
              widget.language == Language.ENGLISH
                  ? (widget.startYear + index).toString()
                  : yearInNepali((widget.startYear + index).toString()),
              style: TextStyle(
                  fontSize: 22.0,
                  color: _selectedYear == (widget.startYear + index).toString()
                      ? Colors.white
                      : Colors.black),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalender(int year, int month, int daysInMonth,
      int startDayInMonth, Orientation orientation) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0,right: 10.0,top: 5.0),
      child: Column(
        children: <Widget>[
          Text(
            "${indexToMonth(month)} $year",
            style: TextStyle(
                color: Colors.grey[900],
                fontWeight: FontWeight.bold,
                fontSize: 14),
          ),
          Expanded(
            child: GridView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
              children: _buildCalenderRows(
                  year, month, daysInMonth, startDayInMonth, orientation),
            ),
          ),
        ],
      ),
    );
  }

  Widget dayBuilder(String englishDay, String nepaliDay) {
    return Container(
        alignment: Alignment(0, 0),
        child: Text(
          widget.language == Language.ENGLISH ? englishDay : nepaliDay,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ));
  }

  List<Widget> _buildCalenderRows(int year, int month, int daysInMonth,
      int startDayInMonth, Orientation orientation) {
    var gridList = <Widget>[];
    gridList.add(dayBuilder("S", "आ"));
    gridList.add(dayBuilder("M", "सो"));
    gridList.add(dayBuilder("T", "मं"));
    gridList.add(dayBuilder("W", "बु"));
    gridList.add(dayBuilder("T", "वि"));
    gridList.add(dayBuilder("F", "शु"));
    gridList.add(dayBuilder("S", "श"));

    int dayCount = 1;
    Map day = {};
    for (int i = 0; i < 6; i++) {
      gridList.add(
        Container(
          child: InkWell(
            onTap: () {
              if (day[i * 7 + 1] != null) {
                setState(() {
                  _selectedDay = day[i * 7 + 1].toString();
                  _selectedMonth = month.toString();
                  _selectedYear = year.toString();
                });
              }
            },
            child: CircleAvatar(
              backgroundColor: dayCount.toString() == _selectedDay &&
                  startDayInMonth <= 1 &&
                  dayCount <= daysInMonth
                  ? widget.color
                  : Colors.white,
              foregroundColor: dayCount.toString() == _selectedDay &&
                  startDayInMonth <= 1 &&
                  dayCount <= daysInMonth
                  ? Colors.white
                  : Colors.black,
              maxRadius: orientation == Orientation.portrait ? 14.0 : 13.0,
              child: Text(
                startDayInMonth <= 1 && dayCount <= daysInMonth
                    ? (widget.language == Language.ENGLISH
                    ? (day[i * 7 + 1] = dayCount++).toString()
                    : dayInNepali((day[i * 7 + 1] = dayCount++).toString()))
                    : "",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      );
      gridList.add(
        InkWell(
          onTap: () {
            if (day[i * 7 + 2] != null) {
              setState(() {
                _selectedDay = day[i * 7 + 2].toString();
                _selectedMonth = month.toString();
                _selectedYear = year.toString();
              });
            }
          },
          child: CircleAvatar(
            backgroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 2 &&
                dayCount <= daysInMonth
                ? widget.color
                : Colors.white,
            foregroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 2 &&
                dayCount <= daysInMonth
                ? Colors.white
                : Colors.black,
            maxRadius: orientation == Orientation.portrait ? 14.0 : 13.0,
            child: Text(
              startDayInMonth <= 2 && dayCount <= daysInMonth
                  ? (widget.language == Language.ENGLISH
                  ? (day[i * 7 + 2] = dayCount++).toString()
                  : dayInNepali((day[i * 7 + 2] = dayCount++).toString()))
                  : "",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      gridList.add(
        InkWell(
          onTap: () {
            if (day[i * 7 + 3] != null) {
              setState(() {
                _selectedDay = day[i * 7 + 3].toString();
                _selectedMonth = month.toString();
                _selectedYear = year.toString();
              });
            }
          },
          child: CircleAvatar(
            backgroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 3 &&
                dayCount <= daysInMonth
                ? widget.color
                : Colors.white,
            foregroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 3 &&
                dayCount <= daysInMonth
                ? Colors.white
                : Colors.black,
            maxRadius: orientation == Orientation.portrait ? 14.0 : 13.0,
            child: Text(
              startDayInMonth <= 3 && dayCount <= daysInMonth
                  ? (widget.language == Language.ENGLISH
                  ? (day[i * 7 + 3] = dayCount++).toString()
                  : dayInNepali((day[i * 7 + 3] = dayCount++).toString()))
                  : "",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      gridList.add(
        InkWell(
          onTap: () {
            if (day[i * 7 + 4] != null) {
              setState(() {
                _selectedDay = day[i * 7 + 4].toString();
                _selectedMonth = month.toString();
                _selectedYear = year.toString();
              });
            }
          },
          child: CircleAvatar(
            backgroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 4 &&
                dayCount <= daysInMonth
                ? widget.color
                : Colors.white,
            foregroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 4 &&
                dayCount <= daysInMonth
                ? Colors.white
                : Colors.black,
            maxRadius: orientation == Orientation.portrait ? 14.0 : 13.0,
            child: Text(
              startDayInMonth <= 4 && dayCount <= daysInMonth
                  ? (widget.language == Language.ENGLISH
                  ? (day[i * 7 + 4] = dayCount++).toString()
                  : dayInNepali((day[i * 7 + 4] = dayCount++).toString()))
                  : "",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      gridList.add(
        InkWell(
          onTap: () {
            if (day[i * 7 + 5] != null) {
              setState(() {
                _selectedDay = day[i * 7 + 5].toString();
                _selectedMonth = month.toString();
                _selectedYear = year.toString();
              });
            }
          },
          child: CircleAvatar(
            backgroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 5 &&
                dayCount <= daysInMonth
                ? widget.color
                : Colors.white,
            foregroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 5 &&
                dayCount <= daysInMonth
                ? Colors.white
                : Colors.black,
            maxRadius: orientation == Orientation.portrait ? 14.0 : 13.0,
            child: Text(
              startDayInMonth <= 5 && dayCount <= daysInMonth
                  ? (widget.language == Language.ENGLISH
                  ? (day[i * 7 + 5] = dayCount++).toString()
                  : dayInNepali((day[i * 7 + 5] = dayCount++).toString()))
                  : "",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      gridList.add(
        InkWell(
          onTap: () {
            if (day[i * 7 + 6] != null) {
              setState(() {
                _selectedDay = day[i * 7 + 6].toString();
                _selectedMonth = month.toString();
                _selectedYear = year.toString();
              });
            }
          },
          child: CircleAvatar(
            backgroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 6 &&
                dayCount <= daysInMonth
                ? widget.color
                : Colors.white,
            foregroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 6 &&
                dayCount <= daysInMonth
                ? Colors.white
                : Colors.black,
            maxRadius: orientation == Orientation.portrait ? 14.0 : 4.0,
            child: Text(
              startDayInMonth <= 6 && dayCount <= daysInMonth
                  ? (widget.language == Language.ENGLISH
                  ? (day[i * 7 + 6] = dayCount++).toString()
                  : dayInNepali((day[i * 7 + 6] = dayCount++).toString()))
                  : "",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      gridList.add(
        InkWell(
          onTap: () {
            if (day[i * 7 + 7] != null) {
              setState(() {
                _selectedDay = day[i * 7 + 7].toString();
                _selectedMonth = month.toString();
                _selectedYear = year.toString();
              });
            }
          },
          child: CircleAvatar(
            backgroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 7 &&
                dayCount <= daysInMonth
                ? widget.color
                : Colors.white,
            foregroundColor: dayCount.toString() == _selectedDay &&
                startDayInMonth <= 7 &&
                dayCount <= daysInMonth
                ? Colors.white
                : Colors.black,
            maxRadius: orientation == Orientation.portrait ? 14.0 : 13.0,
            child: Text(
              startDayInMonth <= 7 && dayCount <= daysInMonth
                  ? (widget.language == Language.ENGLISH
                  ? (day[i * 7 + 7] = dayCount++).toString()
                  : dayInNepali((day[i * 7 + 7] = dayCount++).toString()))
                  : "",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
      );
      if (i == 0) {
        startDayInMonth = 1;
      }
    }

    return gridList;
  }

  void _convertEnglishDateToNepali(
      int currentEngYear, int currentEngMonth, int currentEngDay) {
    int startingEngYear = 1943;
    int startingEngMonth = 4;
    int startingEngDay = 14;
    int startingNepYear = 2000;
    int startingNepMonth = 1;
    int startingNepDay = 1;

    var currentDate =
    DateTime.utc(currentEngYear, currentEngMonth, currentEngDay);
    var startingDate =
    DateTime.utc(startingEngYear, startingEngMonth, startingEngDay);

    int totalEngDaysCount = currentDate.difference(startingDate).inDays;

    int currentNepYear = startingNepYear;
    int currentNepMonth = startingNepMonth;
    int currentNepDay = startingNepDay;

    while (totalEngDaysCount != 0) {
      int daysInIthMonth = daysInMonths[currentNepYear][currentNepMonth];
      currentNepDay++;

      if (currentNepDay > daysInIthMonth) {
        currentNepMonth++;
        currentNepDay = 1;
      }
      if (currentNepMonth > 12) {
        currentNepYear++;
        currentNepMonth = 1;
      }

      totalEngDaysCount--;
    }

    setState(() {
      _selectedYear = currentNepYear.toString();
      _selectedMonth = currentNepMonth.toString();
      _selectedDay = currentNepDay.toString();
    });
  }
}

String yearInNepali(String year) {
  switch (year) {
    case "2000":
      return "२०००";
    case "2001":
      return "२००१";
    case "2002":
      return "२००२";
    case "2003":
      return "२००३";
    case "2004":
      return "२००४";
    case "2005":
      return "२००५";
    case "2006":
      return "२००६";
    case "2007":
      return "२००७";
    case "2008":
      return "२००८";
    case "2009":
      return "२००९";
    case "2010":
      return "२०१०";
    case "2011":
      return "२०११";
    case "2012":
      return "२०१२";
    case "2013":
      return "२०१३";
    case "2014":
      return "२०१४";
    case "2015":
      return "२०१५";
    case "2016":
      return "२०१६";
    case "2017":
      return "२०१७";
    case "2018":
      return "२०१८";
    case "2019":
      return "२०१९";
    case "2020":
      return "२०२०";
    case "2021":
      return "२०२१";
    case "2022":
      return "२०२२";
    case "2023":
      return "२०२३";
    case "2024":
      return "२०२४";
    case "2025":
      return "२०२५";
    case "2026":
      return "२०२६";
    case "2027":
      return "२०२७";
    case "2028":
      return "२०२८";
    case "2029":
      return "२०२९";
    case "2030":
      return "२०३०";
    case "2031":
      return "२०३१";
    case "2032":
      return "२०३२";
    case "2033":
      return "२०३३";
    case "2034":
      return "२०३४";
    case "2035":
      return "२०३५";
    case "2036":
      return "२०३६";
    case "2037":
      return "२०३७";
    case "2038":
      return "२०३८";
    case "2039":
      return "२०३९";
    case "2040":
      return "२०४०";
    case "2041":
      return "२०४१";
    case "2042":
      return "२०४२";
    case "2043":
      return "२०४३";
    case "2044":
      return "२०४४";
    case "2045":
      return "२०४५";
    case "2046":
      return "२०४६";
    case "2047":
      return "२०४७";
    case "2048":
      return "२०४८";
    case "2049":
      return "२०४९";
    case "2050":
      return "२०५०";
    case "2051":
      return "२०५१";
    case "2052":
      return "२०५२";
    case "2053":
      return "२०५३";
    case "2054":
      return "२०५४";
    case "2055":
      return "२०५५";
    case "2056":
      return "२०५६";
    case "2057":
      return "२०५७";
    case "2058":
      return "२०५८";
    case "2059":
      return "२०५९";
    case "2060":
      return "२०६०";
    case "2061":
      return "२०६१";
    case "2062":
      return "२०६२";
    case "2063":
      return "२०६३";
    case "2064":
      return "२०६४";
    case "2065":
      return "२०६५";
    case "2066":
      return "२०६६";
    case "2067":
      return "२०६७";
    case "2068":
      return "२०६८";
    case "2069":
      return "२०६९";
    case "2070":
      return "२०७०";
    case "2071":
      return "२०७१";
    case "2072":
      return "२०७२";
    case "2073":
      return "२०७३";
    case "2074":
      return "२०७४";
    case "2075":
      return "२०७५";
    case "2076":
      return "२०७६";
    case "2077":
      return "२०७७";
    case "2078":
      return "२०७८";
    case "2079":
      return "२०७९";
    case "2080":
      return "२०८०";
    case "2081":
      return "२०८१";
    case "2082":
      return "२०८२";
    case "2083":
      return "२०८३";
    case "2084":
      return "२०८४";
    case "2085":
      return "२०८५";
    case "2086":
      return "२०८६";
    case "2087":
      return "२०८७";
    case "2088":
      return "२०८८";
    case "2089":
      return "२०८९";
    case "2090":
      return "२०९०";
    default:
      return "Invalid";
  }
}

String dayInNepali(String day) {
  switch (day) {
    case "1":
      return "१";
    case "2":
      return "२";
    case "3":
      return "३";
    case "4":
      return "४";
    case "5":
      return "५";
    case "6":
      return "६";
    case "7":
      return "७";
    case "8":
      return "८";
    case "9":
      return "९";
    case "10":
      return "१०";
    case "11":
      return "११";
    case "12":
      return "१२";
    case "13":
      return "१३";
    case "14":
      return "१४";
    case "15":
      return "१५";
    case "16":
      return "१६";
    case "17":
      return "१७";
    case "18":
      return "१८";
    case "19":
      return "१९";
    case "20":
      return "२०";
    case "21":
      return "२१";
    case "22":
      return "२२";
    case "23":
      return "२३";
    case "24":
      return "२४";
    case "25":
      return "२५";
    case "26":
      return "२६";
    case "27":
      return "२७";
    case "28":
      return "२८";
    case "29":
      return "२९";
    case "30":
      return "३०";
    case "31":
      return "३१";
    case "32":
      return "३२";
    case "33":
      return "३३";
    default:
      return "Invalid";
  }
}

void initializeDaysInMonths() {
  daysInMonths[2000] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2001] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2002] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2003] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2004] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2005] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2006] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2007] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2008] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31];
  daysInMonths[2009] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2010] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2011] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2012] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2013] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2014] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2015] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2016] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2017] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2018] = [0, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2019] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2020] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2021] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2022] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2023] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2024] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2025] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2026] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2027] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2028] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2029] = [0, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2030] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2031] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2032] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2033] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2034] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2035] = [0, 30, 32, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31];
  daysInMonths[2036] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2037] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2038] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2039] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2040] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2041] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2042] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2043] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2044] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2045] = [0, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2046] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2047] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2048] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2049] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2050] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2051] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2052] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2053] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2054] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2055] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2056] = [0, 31, 31, 32, 31, 32, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2057] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2058] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2059] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2060] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2061] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2062] = [0, 30, 32, 31, 32, 31, 31, 29, 30, 29, 30, 29, 31];
  daysInMonths[2063] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2064] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2065] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2066] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 29, 31];
  daysInMonths[2067] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2068] = [0, 31, 31, 32, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2069] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2070] = [0, 31, 31, 31, 32, 31, 31, 29, 30, 30, 29, 30, 30];
  daysInMonths[2071] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2072] = [0, 31, 32, 31, 32, 31, 30, 30, 29, 30, 29, 30, 30];
  daysInMonths[2073] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 31];
  daysInMonths[2074] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2075] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2076] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2077] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 30, 29, 31];
  daysInMonths[2078] = [0, 31, 31, 31, 32, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2079] = [0, 31, 31, 32, 31, 31, 31, 30, 29, 30, 29, 30, 30];
  daysInMonths[2080] = [0, 31, 32, 31, 32, 31, 30, 30, 30, 29, 29, 30, 30];
  daysInMonths[2081] = [0, 31, 31, 32, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2082] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2083] = [0, 31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2084] = [0, 31, 31, 32, 31, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2085] = [0, 31, 32, 31, 32, 30, 31, 30, 30, 29, 30, 30, 30];
  daysInMonths[2086] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2087] = [0, 31, 31, 32, 31, 31, 31, 30, 30, 29, 30, 30, 30];
  daysInMonths[2088] = [0, 30, 31, 32, 32, 30, 31, 30, 30, 29, 30, 30, 30];
  daysInMonths[2089] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
  daysInMonths[2090] = [0, 30, 32, 31, 32, 31, 30, 30, 30, 29, 30, 30, 30];
}

void initializeStartDayInMonths() {
  startDayInMonths[2000] = [0, 4, 6, 3, 6, 3, 6, 1, 3, 5, 6, 1, 2];
  startDayInMonths[2001] = [0, 5, 1, 4, 1, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2002] = [0, 6, 2, 5, 2, 6, 2, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2003] = [0, 7, 3, 7, 3, 7, 3, 5, 7, 2, 3, 4, 6];
  startDayInMonths[2004] = [0, 2, 4, 1, 4, 1, 4, 6, 1, 3, 4, 6, 7];
  startDayInMonths[2005] = [0, 3, 6, 2, 6, 2, 5, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2006] = [0, 4, 7, 3, 7, 4, 7, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2007] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 7, 1, 2, 4];
  startDayInMonths[2008] = [0, 7, 3, 6, 2, 6, 2, 5, 6, 1, 3, 4, 5];
  startDayInMonths[2009] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2010] = [0, 2, 5, 1, 5, 2, 5, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2011] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 7, 2];
  startDayInMonths[2012] = [0, 5, 1, 4, 7, 4, 7, 3, 4, 6, 1, 2, 4];
  startDayInMonths[2013] = [0, 6, 2, 5, 2, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2014] = [0, 7, 3, 6, 3, 7, 3, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2015] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2016] = [0, 3, 6, 2, 5, 2, 5, 1, 2, 4, 6, 7, 2];
  startDayInMonths[2017] = [0, 4, 7, 3, 7, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2018] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2019] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 4, 5];
  startDayInMonths[2020] = [0, 1, 4, 7, 3, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2021] = [0, 2, 5, 1, 5, 1, 4, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2022] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 7, 2];
  startDayInMonths[2023] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 6, 7, 2, 3];
  startDayInMonths[2024] = [0, 6, 2, 5, 1, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2025] = [0, 7, 3, 6, 3, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2026] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2027] = [0, 3, 5, 2, 5, 2, 5, 7, 2, 4, 5, 7, 1];
  startDayInMonths[2028] = [0, 4, 7, 3, 7, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2029] = [0, 5, 1, 4, 1, 4, 1, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2030] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 3, 5];
  startDayInMonths[2031] = [0, 1, 3, 7, 3, 7, 3, 5, 7, 2, 3, 5, 6];
  startDayInMonths[2032] = [0, 2, 5, 1, 5, 1, 4, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2033] = [0, 3, 6, 2, 6, 3, 6, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2034] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 6, 7, 1, 3];
  startDayInMonths[2035] = [0, 6, 1, 5, 1, 5, 1, 4, 5, 7, 2, 3, 4];
  startDayInMonths[2036] = [0, 7, 3, 6, 3, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2037] = [0, 1, 4, 7, 4, 1, 4, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2038] = [0, 2, 5, 2, 5, 2, 5, 7, 2, 4, 5, 6, 1];
  startDayInMonths[2039] = [0, 4, 7, 3, 6, 3, 6, 2, 3, 5, 7, 1, 3];
  startDayInMonths[2040] = [0, 5, 1, 4, 1, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2041] = [0, 6, 2, 5, 2, 6, 2, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2042] = [0, 7, 3, 7, 3, 7, 3, 5, 7, 2, 3, 4, 6];
  startDayInMonths[2043] = [0, 2, 5, 1, 4, 1, 4, 7, 1, 3, 5, 6, 1];
  startDayInMonths[2044] = [0, 3, 6, 2, 6, 2, 5, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2045] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2046] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 7, 1, 2, 4];
  startDayInMonths[2047] = [0, 7, 3, 6, 2, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2048] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2049] = [0, 2, 5, 2, 5, 2, 5, 7, 2, 4, 5, 6, 1];
  startDayInMonths[2050] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 1, 2];
  startDayInMonths[2051] = [0, 5, 1, 4, 7, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2052] = [0, 6, 2, 5, 2, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2053] = [0, 7, 3, 7, 3, 7, 3, 5, 7, 2, 3, 4, 6];
  startDayInMonths[2054] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 6, 7];
  startDayInMonths[2055] = [0, 3, 6, 2, 6, 2, 5, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2056] = [0, 4, 7, 3, 7, 3, 7, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2057] = [0, 5, 1, 5, 1, 5, 1, 3, 5, 7, 1, 2, 4];
  startDayInMonths[2058] = [0, 7, 2, 6, 2, 6, 2, 4, 6, 1, 2, 4, 5];
  startDayInMonths[2059] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 2, 4, 5, 7];
  startDayInMonths[2060] = [0, 2, 5, 1, 5, 2, 5, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2061] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 5, 6, 7, 2];
  startDayInMonths[2062] = [0, 5, 7, 4, 7, 4, 7, 3, 4, 6, 7, 2, 3];
  startDayInMonths[2063] = [0, 6, 2, 5, 2, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2064] = [0, 7, 3, 6, 3, 7, 3, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2065] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2066] = [0, 3, 6, 2, 5, 2, 5, 1, 2, 4, 6, 7, 1];
  startDayInMonths[2067] = [0, 4, 7, 3, 7, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2068] = [0, 5, 1, 4, 1, 5, 1, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2069] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 3, 5];
  startDayInMonths[2070] = [0, 1, 4, 7, 3, 7, 3, 6, 7, 2, 4, 5, 7];
  startDayInMonths[2071] = [0, 2, 5, 1, 5, 1, 4, 7, 2, 3, 5, 6, 1];
  startDayInMonths[2072] = [0, 3, 6, 3, 6, 3, 6, 1, 3, 4, 6, 7, 2];
  startDayInMonths[2073] = [0, 4, 7, 4, 7, 4, 7, 2, 4, 6, 7, 1, 3];
  startDayInMonths[2074] = [0, 6, 2, 5, 1, 5, 1, 4, 6, 7, 2, 3, 5];
  startDayInMonths[2075] = [0, 7, 3, 6, 3, 6, 2, 5, 7, 1, 3, 4, 6];
  startDayInMonths[2076] = [0, 1, 4, 1, 4, 1, 4, 6, 1, 3, 4, 5, 7];
  startDayInMonths[2077] = [0, 2, 5, 2, 5, 2, 5, 7, 2, 4, 5, 7, 1];
  startDayInMonths[2078] = [0, 4, 7, 3, 6, 3, 6, 2, 4, 5, 7, 1, 3];
  startDayInMonths[2079] = [0, 5, 1, 4, 1, 4, 7, 3, 5, 6, 1, 2, 4];
  startDayInMonths[2080] = [0, 6, 2, 6, 2, 6, 2, 4, 6, 1, 2, 3, 5];
  startDayInMonths[2081] = [0, 7, 3, 6, 3, 7, 3, 5, 7, 2, 3, 5, 7];
  startDayInMonths[2082] = [0, 2, 4, 1, 4, 1, 4, 6, 1, 3, 4, 6, 1];
  startDayInMonths[2083] = [0, 3, 6, 2, 6, 2, 5, 7, 2, 4, 5, 7, 2];
  startDayInMonths[2084] = [0, 4, 7, 3, 7, 3, 6, 1, 3, 5, 6, 1, 3];
  startDayInMonths[2085] = [0, 5, 1, 5, 1, 5, 7, 3, 5, 7, 1, 3, 5];
  startDayInMonths[2086] = [0, 7, 2, 6, 2, 6, 2, 4, 6, 1, 2, 4, 6];
  startDayInMonths[2087] = [0, 1, 4, 7, 4, 7, 3, 6, 1, 3, 4, 6, 1];
  startDayInMonths[2088] = [0, 3, 5, 1, 5, 2, 4, 7, 2, 4, 5, 7, 2];
  startDayInMonths[2089] = [0, 4, 6, 3, 6, 3, 6, 1, 3, 5, 6, 1, 3];
  startDayInMonths[2090] = [0, 5, 7, 4, 7, 4, 7, 2, 4, 6, 7, 2, 4];
}
