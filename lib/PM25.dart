import 'package:flutter/material.dart';
import 'package:envirosense_aqwms/barChartContainer.dart';
import 'package:envirosense_aqwms/ValueNotifiers.dart';
import 'package:intl/intl.dart';
import 'dart:async';

var dataMin;

double maxBarHeight = 250;
double yAxisHeight = 270;

Timer _timer;
Timer _timer2;

class PM25Stat extends StatefulWidget {
  @override
  _PM25StatState createState() => _PM25StatState();
}

class _PM25StatState extends State<PM25Stat> {
  int selectedIndex = -1;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedIndex = -1;
    aqiDataValue.value = "__";
    dataValue.value = "__";
    timeDiff.value = 0;
    dataMin = int.parse(DateFormat.m().format(
        DateTime.fromMillisecondsSinceEpoch(aqiTsList.value[35])));
    if (dataMin >= 0 && dataMin < 20) {
      timeDiff.value = 1;
    }
    else if (dataMin >= 20 && dataMin < 40) {
      timeDiff.value = 2;
    }
    else if (dataMin >= 40 && dataMin < 60) {
      timeDiff.value = 0;
    }
    dateTimeValue.value = "${DateFormat.jm().format(DateTime.now())}";
    currentTime.value = "${DateFormat.m().format(DateTime.now())}";
    startTimer();
  }

  startTimer() {
    print("PM25 TIMER STARTED");
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      dateTimeValue.value = "${DateFormat.jm().format(DateTime.now())}";
      currentTime.value = "${DateFormat.m().format(DateTime.now())}";
    });
    _timer2 = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        dataMin = int.tryParse(DateFormat.m().format(
            DateTime.fromMillisecondsSinceEpoch(pm25TsList.value[35])));
      });
      if (dataMin >= 0 && dataMin < 20) {
        timeDiff.value = 1;
      }
      else if (dataMin >= 20 && dataMin < 40) {
        timeDiff.value = 2;
      }
      else if (dataMin >= 40 && dataMin < 60) {
        timeDiff.value = 0;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    print("PM25 DISPOSED");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
            left: 60,
            right: 60,
          ),
          child: Container(
            color: Colors.grey,
            child: ValueListenableBuilder(
              valueListenable: aqiDataValue,
              builder: (context, String aqiData, _) {
                return ValueListenableBuilder(
                  valueListenable: dataValue,
                  builder: (context, String data, _) {
                    return ValueListenableBuilder(
                      valueListenable: dateTimeValue,
                      builder: (context, String dateTime, _) {
                        return Table(
                          children: <TableRow>[
                            TableRow(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(3)),
                                  Padding(padding: EdgeInsets.all(3)),
                                  Padding(padding: EdgeInsets.all(3)),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "AQI",
                                            style: TextStyle(
                                                fontSize: 24
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20 * MediaQuery
                                          .of(context)
                                          .size
                                          .width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20 * MediaQuery
                                          .of(context)
                                          .size
                                          .width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "$aqiData",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "PM2.5",
                                            style: TextStyle(
                                                fontSize: 24
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20 * MediaQuery
                                          .of(context)
                                          .size
                                          .width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20 * MediaQuery
                                          .of(context)
                                          .size
                                          .width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "$data \u03BCg/m\u00B3",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "Time",
                                            style: TextStyle(
                                                fontSize: 24
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20 * MediaQuery
                                          .of(context)
                                          .size
                                          .width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment
                                        .middle,
                                    child: Container(
                                      height: 20 * MediaQuery
                                          .of(context)
                                          .size
                                          .width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "$dateTime",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery
                                      .of(context)
                                      .size
                                      .width / screenWidth)),
                                ]
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
        SizedBox(
          height: 80,
          width: 100,
        ),
        Padding(
          padding: EdgeInsets.only(
              left: 48,
              right: 25.5
          ),
          child: Stack(
            alignment: AlignmentDirectional.bottomStart,
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                height: 330,
                width: 350,
                clipBehavior: Clip.none,
                child: Card(
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 2,
                          color: Colors.black38
                      )
                  ),
                  clipBehavior: Clip.none,
                  child: Scrollbar(
                    isAlwaysShown: true,
                    controller: _scrollController,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = -1;
                        });
                        aqiDataValue.value = "__";
                        dataValue.value = "__";
                        startTimer();
                      },
                      child: SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        controller: _scrollController,
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: 50,
                              left: 20
                          ),
                          child: ValueListenableBuilder(
                            valueListenable: pm25TsList,
                            builder: (context, List items, _) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    right: 40
                                ),
                                child: ValueListenableBuilder(
                                  valueListenable: timeDiff,
                                  builder: (context, int _timeDiff, _) {
                                    return Stack(
                                      alignment: AlignmentDirectional
                                          .bottomStart,
                                      clipBehavior: Clip.none,
                                      children: <Widget>[
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .end,
                                            crossAxisAlignment: CrossAxisAlignment
                                                .end,
                                            children: items.map<Widget>(
                                                    (item) =>
                                                    BarChartContainer(
                                                        key: GlobalKey(),
                                                        height: (pm25ValueList
                                                            .value[items
                                                            .indexOf(item)] *
                                                            3.0),
                                                        width: 15,
                                                        color: pm25ValueList
                                                            .value[items
                                                            .indexOf(item)] <=
                                                            10
                                                            ? (selectedIndex ==
                                                            items.indexOf(item)
                                                            ? Color(0xff31592e)
                                                            : Color(0xff2cf61a))
                                                            : (pm25ValueList
                                                            .value[items
                                                            .indexOf(item)] <=
                                                            30
                                                            ? (selectedIndex ==
                                                            items.indexOf(item)
                                                            ? Color(0xff92992f)
                                                            : Color(0xffedf93c))
                                                            : (selectedIndex ==
                                                            items.indexOf(item)
                                                            ? Color(0xff631515)
                                                            : Color(
                                                            0xffff3030))),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _timer.cancel();
                                                            setState(() {
                                                              selectedIndex =
                                                                  items.indexOf(
                                                                      item);
                                                            });
                                                            aqiDataValue.value =
                                                                aqiValueList
                                                                    .value[items
                                                                    .indexOf(
                                                                    item)]
                                                                    .toString();
                                                            dataValue.value =
                                                                pm25ValueList
                                                                    .value[items
                                                                    .indexOf(
                                                                    item)]
                                                                    .toString();
                                                            dateTimeValue
                                                                .value =
                                                            "${DateFormat.jm()
                                                                .format(DateTime
                                                                .fromMillisecondsSinceEpoch(
                                                                pm25TsList
                                                                    .value[items
                                                                    .indexOf(
                                                                    item)]))}";
                                                          },
                                                        )
                                                    )
                                            ).toList()
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}