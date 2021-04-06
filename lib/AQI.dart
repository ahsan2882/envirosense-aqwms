import 'package:flutter/material.dart';
import 'dart:async';
import 'package:envirosense_aqwms/ValueNotifiers.dart';
import 'package:intl/intl.dart';
import 'package:envirosense_aqwms/barChartContainer.dart';

double maxBarHeight = 250;
double yAxisHeight = 270;

Timer _timer;
Timer _timer2;

var dataMin;

class AQIStat extends StatefulWidget {
  @override
  _AQIStatState createState() => _AQIStatState();
}

class _AQIStatState extends State<AQIStat> {
  int selectedIndex = -1;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    selectedIndex = -1;
    aqiDataValue.value = "__";
    timeDiff.value = 0;
    dataMin = int.parse(DateFormat.m().format(DateTime.fromMillisecondsSinceEpoch(aqiTsList.value[35])));
    if(dataMin >= 0 && dataMin < 20){
      timeDiff.value = 1;
    }
    else if(dataMin >= 20 && dataMin < 40){
      timeDiff.value = 2;
    }
    else if(dataMin >= 40 && dataMin < 60){
      timeDiff.value = 0;
    }
    dateTimeValue.value = "${DateFormat.jm().format(DateTime.now())}";
    currentTime.value = "${DateFormat.m().format(DateTime.now())}";
    startTimer();
  }
  startTimer(){
    print("TIMER STARTED");
    final duration = Duration(milliseconds: 30);
    _timer = Timer.periodic(duration, (timer){
      dateTimeValue.value = "${DateFormat.jm().format(DateTime.now())}";
      currentTime.value = "${DateFormat.m().format(DateTime.now())}";
    });
    _timer2 = Timer.periodic((Duration(seconds: 1)), (timer) {
      setState(() {
        dataMin = int.tryParse(DateFormat.m().format(DateTime.fromMillisecondsSinceEpoch(aqiTsList.value[35])));
      });
      if(dataMin >= 0 && dataMin < 20){
        timeDiff.value = 1;
      }
      else if(dataMin >= 20 && dataMin < 40){
        timeDiff.value = 2;
      }
      else if(dataMin >= 40 && dataMin < 60){
        timeDiff.value = 0;
      }
    });
  }
  @override
  void dispose() {
    _timer.cancel();
    _timer2.cancel();
    print("AQI DISPOSED");
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
              right: 60 * MediaQuery.of(context).size.width / screenWidth,
              left: 60 * MediaQuery.of(context).size.width / screenWidth,
            ),
            child: Container(
              color: Colors.grey,
              child: ValueListenableBuilder(
                valueListenable: aqiDataValue,
                builder: (context, String aqiData, _){
                  return ValueListenableBuilder(
                    valueListenable: dateTimeValue,
                    builder: (context, String dateTime, _){
                      return Table(
                          border: TableBorder.all(color: Colors.black, width: 2 * MediaQuery.of(context).size.width / screenWidth, style: BorderStyle.none),
                          children: <TableRow>[
                            TableRow(
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                      child: Center(
                                          child: FittedBox(
                                            child: Text(
                                              "AQI",
                                              style: TextStyle(
                                                  fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                              ),
                                              textScaleFactor: 0.9,
                                            ),
                                          )
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "$aqiData",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
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
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth)),
                                ]
                            ),
                            TableRow(
                                children: <Widget>[
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "Time",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            ":",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  TableCell(
                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                    child: Container(
                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            "$dateTime",
                                            style: TextStyle(
                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
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
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth)),
                                  Padding(padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth)),
                                ]
                            ),
                          ]
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 80 * MediaQuery.of(context).size.width / screenWidth,
            width: 100 * MediaQuery.of(context).size.width / screenWidth,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: 48 * MediaQuery.of(context).size.width / screenWidth,
              right: 25.5 * MediaQuery.of(context).size.width / screenWidth,
            ),
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  height: 330 * MediaQuery.of(context).size.width / screenWidth,
                  width: 350 * MediaQuery.of(context).size.width / screenWidth,
                  clipBehavior: Clip.none,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 2 * MediaQuery.of(context).size.width / screenWidth,
                            color: Colors.black38
                        )
                    ),
                    clipBehavior: Clip.none,
                    child: Scrollbar(
                      isAlwaysShown: true,
                      controller: _scrollController,
                      child: GestureDetector(
                        onTap: (){
                          print("AREA TAPPED");
                          setState(() {
                            selectedIndex = -1;
                          });
                          aqiDataValue.value = "__";
                          startTimer();
                        },
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          controller: _scrollController,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 50 * MediaQuery.of(context).size.width / screenWidth,
                              left: 20 * MediaQuery.of(context).size.width / screenWidth,
                            ),
                            child: ValueListenableBuilder(
                              valueListenable: aqiTsList,
                              builder: (context, List items, _){
                                return Padding(
                                  padding: EdgeInsets.only(
                                      right: 40 * MediaQuery.of(context).size.width / screenWidth
                                  ),
                                  child: ValueListenableBuilder(
                                    valueListenable: timeDiff,
                                    builder: (context, int _timeDiff, _){
                                      return Stack(
                                        alignment: AlignmentDirectional.bottomStart,
                                        clipBehavior: Clip.none,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: items.map<Widget>(
                                                    (item) => BarChartContainer(
                                                      key: GlobalKey(),
                                                      height: (aqiValueList.value[items.indexOf(item)] / 2) * (MediaQuery.of(context).size.width / screenWidth),
                                                      color: aqiValueList.value[items.indexOf(item)] <= 50 ? (selectedIndex == items.indexOf(item) ? Color(0xff31592e) : Color(0xff2cf61a)) : (aqiValueList.value[items.indexOf(item)] <= 100 ? (selectedIndex == items.indexOf(item) ? Color(0xff92992f) : Color(0xffedf93c)) : (aqiValueList.value[items.indexOf(item)] <= 150 ? (selectedIndex == items.indexOf(item) ? Color(0xff631515) : Color(0xffff3030)) : (aqiValueList.value[items.indexOf(item)] <= 200 ? (selectedIndex == items.indexOf(item) ? Color(0xff856025) : Color(0xffff9d00)) : (aqiValueList.value[items.indexOf(item)] <= 300 ? (selectedIndex == items.indexOf(item) ? Color(0xff752666) : Color(0xffff00ce)) : (selectedIndex == items.indexOf(item) ? Color(0xff631f34) : Color(0xffab0f3e)))))),
                                                      child: GestureDetector(
                                                        onTap: () async{
                                                          _timer.cancel();
                                                          setState(() {
                                                            selectedIndex = items.indexOf(item);
                                                          });
                                                          aqiDataValue.value = aqiValueList.value[items.indexOf(item)].toString();
                                                          dateTimeValue.value = "${DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(aqiTsList.value[items.indexOf(item)]))}";
                                                        },
                                                      ),
                                                      width: 15 * MediaQuery.of(context).size.width / screenWidth,
                                                    )
                                            ).toList(),
                                          ),
                                          Positioned(
                                            bottom: -1 * MediaQuery.of(context).size.width / screenWidth,
                                            left: -20 * MediaQuery.of(context).size.width / screenWidth,
                                            child: Container(
                                              height: 2 * MediaQuery.of(context).size.width / screenWidth,
                                              width: ((15 * 36) + 45) * MediaQuery.of(context).size.width / screenWidth,
                                              color: Colors.black,
                                            ),
                                          ),
                                          if(_timeDiff == 0)
                                            Positioned(
                                              top: 273 * MediaQuery.of(context).size.width / screenWidth,
                                              left: (-12) * MediaQuery.of(context).size.width / screenWidth,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                    height: 7 * MediaQuery.of(context).size.width / screenWidth,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    height: 5 * MediaQuery.of(context).size.width / screenWidth,
                                                    width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                  ),
                                                  Container(
                                                    width: 25 * MediaQuery.of(context).size.width / screenWidth,
                                                    height: 14 * MediaQuery.of(context).size.width / screenWidth,
                                                    child: Center(
                                                      child: FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Text(
                                                            "${DateFormat.j().format(DateTime.fromMillisecondsSinceEpoch(aqiTsList.value[0]))}"
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          for(int i = 1; i < 12; i++)
                                            Positioned(
                                              top: 273 * MediaQuery.of(context).size.width / screenWidth,
                                              left: (-12 + 15 * ((3 * i) - _timeDiff)) * MediaQuery.of(context).size.width / screenWidth,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                    height: 7 * MediaQuery.of(context).size.width / screenWidth,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    height: 5 * MediaQuery.of(context).size.width / screenWidth,
                                                    width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                  ),
                                                  Container(
                                                    width: 25 * MediaQuery.of(context).size.width / screenWidth,
                                                    height: 14 * MediaQuery.of(context).size.width / screenWidth,
                                                    child: Center(
                                                      child: FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Text(
                                                            "${DateFormat.j().format(DateTime.fromMillisecondsSinceEpoch(aqiTsList.value[3 * i]))}"
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          Positioned(
                                            top: 273 * MediaQuery.of(context).size.width / screenWidth,
                                            left: (-12 + 15 * (36 - _timeDiff)) * MediaQuery.of(context).size.width / screenWidth,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Container(
                                                  width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                  height: 7 * MediaQuery.of(context).size.width / screenWidth,
                                                  color: Colors.black,
                                                ),
                                                SizedBox(
                                                  height: 5 * MediaQuery.of(context).size.width / screenWidth,
                                                  width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                ),
                                                Container(
                                                  width: 25 * MediaQuery.of(context).size.width / screenWidth,
                                                  height: 14 * MediaQuery.of(context).size.width / screenWidth,
                                                  child: Center(
                                                    child: FittedBox(
                                                      fit: BoxFit.fitHeight,
                                                      child: dataMin > 40 && int.tryParse(currentTime.value) > 40
                                                          ? Text(
                                                        "${DateFormat.j().format(DateTime.now().add(Duration(hours: 1)))}",
                                                        style: TextStyle(
                                                          fontSize: 15 * MediaQuery.of(context).size.width / screenWidth,
                                                        ),
                                                        textScaleFactor: 0.9,
                                                      )
                                                          : Text(
                                                        "${DateFormat.j().format(DateTime.now())}",
                                                        style: TextStyle(
                                                          fontSize: 15 * MediaQuery.of(context).size.width / screenWidth,
                                                        ),
                                                        textScaleFactor: 0.9,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          if(_timeDiff == 2)
                                            Positioned(
                                              top: 273 * MediaQuery.of(context).size.width / screenWidth,
                                              left: (-12 + 15 * 37) * MediaQuery.of(context).size.width / screenWidth,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Container(
                                                    width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                    height: 7 * MediaQuery.of(context).size.width / screenWidth,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(
                                                    height: 5 * MediaQuery.of(context).size.width / screenWidth,
                                                    width: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                  ),
                                                  Container(
                                                    width: 25 * MediaQuery.of(context).size.width / screenWidth,
                                                    height: 14 * MediaQuery.of(context).size.width / screenWidth,
                                                    child: Center(
                                                      child: FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Text(
                                                          "${DateFormat.j().format(DateTime.now().add(Duration(hours: 1)))}",
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
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
                ),
                Positioned(
                  left: 4 * MediaQuery.of(context).size.width / screenWidth,
                  bottom: 53 * MediaQuery.of(context).size.width / screenWidth,
                  child: Container(
                    width: 2 * MediaQuery.of(context).size.width / screenWidth,
                    height: yAxisHeight * MediaQuery.of(context).size.width / screenWidth,
                    color: Colors.black,
                  ),
                ),
                Positioned(
                  bottom: 43.5 * MediaQuery.of(context).size.width / screenWidth,
                  right: 346 * MediaQuery.of(context).size.width / screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 21 * MediaQuery.of(context).size.width / screenWidth,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "0",
                              style: TextStyle(
                                fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                      ),
                      Container(
                        width: 8 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: (43.5 + maxBarHeight / 2) * MediaQuery.of(context).size.width / screenWidth,
                  right: 346 * MediaQuery.of(context).size.width / screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 21 * MediaQuery.of(context).size.width / screenWidth,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "250",
                              style: TextStyle(
                                fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                      ),
                      Container(
                        width: 8 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: (43.5 + maxBarHeight / 4) * MediaQuery.of(context).size.width / screenWidth,
                  right: 346 * MediaQuery.of(context).size.width / screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 21 * MediaQuery.of(context).size.width / screenWidth,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "125",
                              style: TextStyle(
                                fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                      ),
                      Container(
                        width: 8 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: (43.5 + (3 * maxBarHeight / 4)) * MediaQuery.of(context).size.width / screenWidth,
                  right: 346 * MediaQuery.of(context).size.width / screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 21 * MediaQuery.of(context).size.width / screenWidth,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "375",
                              style: TextStyle(
                                fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                      ),
                      Container(
                        width: 8 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: (43.5 + maxBarHeight) * MediaQuery.of(context).size.width / screenWidth,
                  right: 346 * MediaQuery.of(context).size.width / screenWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 21 * MediaQuery.of(context).size.width / screenWidth,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.fitHeight,
                            child: Text(
                              "500",
                              style: TextStyle(
                                fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                      ),
                      Container(
                        width: 8 * MediaQuery.of(context).size.width / screenWidth,
                        height: 2 * MediaQuery.of(context).size.width / screenWidth,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]
    );
  }
}
