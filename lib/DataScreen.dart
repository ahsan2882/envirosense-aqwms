import 'package:flutter/material.dart';
import 'package:envirosense_aqwms/app_icon_icons.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:envirosense_aqwms/ValueNotifiers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:envirosense_aqwms/functions.dart' as functions;

int lastDirection = 0;
double start = 0.0;
double end = 2 * math.pi;

double safeHeightAQI = (60 / 500) * 320;
double safeHeightNO = (2 / 10) * 320;
double safeHeightPM25 = (10 / 100) * 320;
double safeHeightCO = (9 / 100) * 320;

Timer _timer;

class DataPage extends StatefulWidget {
  final String devId;
  final int devIndex;
  DataPage({@required this.devId, @required this.devIndex, Key key}) : super(key: key);
  @override
  _DataPageState createState() => _DataPageState(this.devId, this.devIndex);
}

class _DataPageState extends State<DataPage> with TickerProviderStateMixin {
  _DataPageState(String devId, int devIndex){
    this._deviceId = devId;
    this._devIndex = devIndex;
  }
  String _deviceId = "";
  int _devIndex = 0;
  Animation _arrowAnimation;
  AnimationController _arrowAnimationController;
  @override
  void initState() {
    lastDirection = windDirection.value;
    _getValues();
    startTimer();
    _arrowAnimationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    if(lastDirection == 45){
      start = math.pi / 4;
    }
    else if(lastDirection == 0){
      start = 0;
    }
    else if(lastDirection == 90){
      start = math.pi / 2;
    }
    else if(lastDirection == 135){
      start = 3 * math.pi / 4;
    }
    else if(lastDirection == 180){
      start = math.pi;
    }
    else if(lastDirection == 225){
      start = 5 * math.pi / 4;
    }
    else if(lastDirection == 270){
      start = 3 * math.pi / 2;
    }
    else if(lastDirection == 315){
      start = 7 * math.pi / 4;
    }
    _arrowAnimation = Tween(begin: start, end: end).animate(_arrowAnimationController);
    super.initState();
  }
  @override
  void dispose() {
    _timer.cancel();
    _arrowAnimationController.dispose();
    super.dispose();
  }
  startTimer(){
    _timer = Timer.periodic(Duration(seconds: 60), (timer) {
      _getValues();
      print("Timer Restart");
    });
  }
  Future<void> _getValues() async{
    await _getAllValues();
  }
  Future<Map<String, dynamic>> _getAllValues() async{
    int currentMin = int.parse(DateFormat.m().format(DateTime.now()));
    if(currentMin == 0 || currentMin == 30){
      var url2 = Uri.parse('https://api.airvisual.com/v2/nearest_city?lat=24.960874&lon=67.072938&key=d3a020c6-72a6-432a-843f-daeefeff141c');
      var response2 = await http.get(url2);
      var aqiData = await json.decode(response2.body);
      int aqiVal = aqiData['data']['current']['pollution']['aqius'];
      airQuality.value = aqiVal;
    }
    String bearerToken = await functions.read('bearerToken.txt');
    var url = Uri.parse('https://demo.thingsboard.io/api/plugins/telemetry/DEVICE/$_deviceId/values/timeseries?keys=humidity,temperature,pressure,windDirection,windSpeed,coCon,no2Con,pm25Con');
    var response = await http.get(
        url,
        headers: {
          'Content-Type':'application/json',
          'Accept':'application/json',
          'X-Authorization': bearerToken,
        }
    );
    var data = await json.decode(response.body);
    lastDirection = windDirection.value;
    heightAQI.value = ((airQuality.value) / 500) * 320;
    if(airQuality.value <= 50 && airQuality.value > 0){
      healthColor.value = 0xff2cf61a;
      healthStatus.value = "Good";
    }
    else if(airQuality.value <= 100 && airQuality.value > 50){
      healthColor.value = 0xffedf93c;
      healthStatus.value = "Moderate";
    }
    else if(airQuality.value > 100 && airQuality.value <= 150){
      healthColor.value = 0xffff0303;
      healthStatus.value = "Unhealthy";
    }
    else if(airQuality.value > 150 && airQuality.value <= 200){
      healthColor.value = 0xffff9d00;
      healthStatus.value = "Moderately Unhealthy";
    }
    else if(airQuality.value > 200 && airQuality.value <= 300){
      healthColor.value = 0xffe730c4;
      healthStatus.value = "Very Unhealthy";
    }
    else if(airQuality.value > 300 && airQuality.value <= 500){
      healthColor.value = 0xffab0f3e;
      healthStatus.value = "Hazardous";
    }
    humidity.value = int.parse(await data['humidity'][0]['value']);
    temperature.value = int.parse(await data['temperature'][0]['value']);
    pressure.value = (double.parse(await data['pressure'][0]['value']) ~/ 1);
    if(pressure.value > 2000){
      pressure.value = (double.parse(await data['pressure'][0]['value']) ~/ 100);
    } else{
      pressure.value = (double.parse(await data['pressure'][0]['value']) ~/ 1);
    }
    windDirection.value = int.parse(await data['windDirection'][0]['value']);
    if(lastDirection < windDirection.value){
      start = (lastDirection) * math.pi / 180;
      end = windDirection.value * math.pi / 180;
    }
    else if(lastDirection > windDirection.value){
      start = windDirection.value * math.pi / 180;
      end = lastDirection * math.pi / 180;
    }
    if(windDirection.value == 0){
      windDirectionString.value = "S";
    }
    else if(windDirection.value == 45){
      windDirectionString.value = "SW";
    }
    else if(windDirection.value == 90){
      windDirectionString.value = "W";
    }
    else if(windDirection.value == 135){
      windDirectionString.value = "NW";
    }
    else if(windDirection.value == 180){
      windDirectionString.value = "N";
    }
    else if(windDirection.value == 225){
      windDirectionString.value = "NE";
    }
    else if(windDirection.value == 270){
      windDirectionString.value = "E";
    }
    else if(windDirection.value == 315){
      windDirectionString.value = "SE";
    }
    windSpeed.value = double.parse(await data['windSpeed'][0]['value']);
    no2Con.value = double.parse(await data['no2Con'][0]['value']);
    heightNO.value = ((no2Con.value) / maxNO) * 320;
    if(no2Con.value <= safeNO){
      colorNO2.value = 0xff64e35f;
    }
    else if(no2Con.value > safeNO && no2Con.value <= (maxNO * 0.6)){
      colorNO2.value = 0xffdfe35f;
    }
    else if(no2Con.value > (maxNO * 0.6) && no2Con.value <= maxNO){
      colorNO2.value = 0xfff76060;
    }
    pm25Con.value = double.parse(await data['pm25Con'][0]['value']);
    heightPM25.value = ((pm25Con.value) / maxPM25) *320;
    if(pm25Con.value <= safePM25){
      colorPM25.value = 0xff64e35f;
    }
    else if(pm25Con.value > safePM25 && pm25Con.value <= (maxPM25 * 0.3)){
      colorPM25.value = 0xffdfe35f;
    }
    else if(pm25Con.value > (maxPM25 * 0.3) && pm25Con.value <= maxPM25){
      colorPM25.value = 0xfff76060;
    }
    coCon.value = double.parse(await data['coCon'][0]['value']);
    heightCO.value = ((coCon.value) / maxCO) * 320;
    if(coCon.value <= safeCO){
      colorCO.value = 0xff64e35f;
    }
    else if(coCon.value > safeCO && coCon.value <= (maxCO * 0.4)){
      colorCO.value = 0xffdfe35f;
    }
    else if(coCon.value > (maxCO * 0.4) && coCon.value <= maxCO){
      colorCO.value = 0xfff76060;
    }
    _arrowAnimation = Tween(begin: start, end: end).animate(_arrowAnimationController);
    if(lastDirection < windDirection.value){
      _arrowAnimationController.forward();
    }
    else if(lastDirection > windDirection.value){
      _arrowAnimationController.reverse();
    }
    // await Future.delayed(Duration(milliseconds: 700));
    return json.decode(response.body);
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // physics: AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 80 * MediaQuery.of(context).size.width / screenWidth,
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth)),
                    side: BorderSide(
                      color: Colors.grey[500],
                      width: 3 * MediaQuery.of(context).size.width / screenWidth,
                    )
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ValueListenableBuilder(
                      valueListenable: healthColor,
                      builder: (BuildContext context, int color, Widget child){
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth),
                              topLeft: Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth),
                            ),
                            color: Color(color),
                          ),
                          child: child,
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 90 * MediaQuery.of(context).size.width / screenWidth,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 90 * MediaQuery.of(context).size.width / screenWidth,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth),
                                  child: ValueListenableBuilder(
                                    valueListenable: airQuality,
                                    builder: (BuildContext context, int value, Widget child){
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            height: 25 * MediaQuery.of(context).size.width / screenWidth,
                                            child: Center(
                                              child: FittedBox(
                                                fit: BoxFit.fitHeight,
                                                child: Text(
                                                  "$value",
                                                  style: TextStyle(
                                                    fontSize: 36  * MediaQuery.of(context).size.width / screenWidth,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textScaleFactor: 0.9,
                                                ),
                                              ),
                                            ),
                                          ),
                                          child,
                                        ],
                                      );
                                    },
                                    child: Container(
                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                      child: Center(
                                        child: FittedBox(
                                          fit: BoxFit.fitHeight,
                                          child: Text(
                                            "US AQI",
                                            style: TextStyle(
                                              fontSize: 24  * MediaQuery.of(context).size.width / screenWidth,
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 90 * MediaQuery.of(context).size.width / screenWidth,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8 * MediaQuery.of(context).size.width / screenWidth),
                                  child: ValueListenableBuilder(
                                    valueListenable: healthStatus,
                                    builder: (BuildContext context, String message, _){
                                      return Container(
                                        height: 25 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Center(
                                          child: FittedBox(
                                            fit: BoxFit.fitHeight,
                                            child: Text(
                                              message,
                                              style: TextStyle(
                                                fontSize: 28 * MediaQuery.of(context).size.width / screenWidth,
                                              ),
                                              textScaleFactor: 0.9,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 65 * MediaQuery.of(context).size.width / screenWidth,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(8 * MediaQuery.of(context).size.width / screenWidth),
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: ValueListenableBuilder(
                                    valueListenable: temperature,
                                    builder: (BuildContext context, int value, Widget child){
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          child,
                                          Padding(padding: EdgeInsets.all(7 * MediaQuery.of(context).size.width / screenWidth)),
                                          Text(
                                            "$value \u00B0 C",
                                            style: TextStyle(
                                              fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ],
                                      );
                                    },
                                    child: Icon(
                                      AppIcon.temperature_high,
                                      color: Colors.red,
                                      size: 20 * MediaQuery.of(context).size.width / screenWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                        // Container(
                        //   width: 2 * MediaQuery.of(context).size.width / screenWidth,
                        //   height: 35 * MediaQuery.of(context).size.width / screenWidth,
                        //   color: Colors.grey[300],
                        // ),
                        // Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                        // Expanded(
                        //   child: Container(
                        //     height: 65 * MediaQuery.of(context).size.width / screenWidth,
                        //     child: Center(
                        //       child: Padding(
                        //         padding: EdgeInsets.all(1 * MediaQuery.of(context).size.width / screenWidth),
                        //         child: FittedBox(
                        //           fit: BoxFit.fitHeight,
                        //           child: ValueListenableBuilder(
                        //             valueListenable: windSpeed,
                        //             builder: (BuildContext context, double value, Widget child){
                        //               return Row(
                        //                 mainAxisAlignment: MainAxisAlignment.center,
                        //                 crossAxisAlignment: CrossAxisAlignment.center,
                        //                 children: <Widget>[
                        //                   Column(
                        //                     mainAxisAlignment: MainAxisAlignment.center,
                        //                     crossAxisAlignment: CrossAxisAlignment.center,
                        //                     children: <Widget>[
                        //                       Icon(
                        //                         AppIcon.wind_1,
                        //                         color: Colors.blue[300],
                        //                         size: 34 * MediaQuery.of(context).size.width / screenWidth,
                        //                       ),
                        //                       AnimatedBuilder(
                        //                         animation: _arrowAnimationController,
                        //                         builder: (context, child){
                        //                           return Transform.rotate(
                        //                             angle: _arrowAnimation.value,
                        //                             child: Icon(Icons.arrow_upward,size: 40 * MediaQuery.of(context).size.width / screenWidth),
                        //                           );
                        //                         },
                        //                       )
                        //                     ],
                        //                   ),
                        //                   Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                        //                   Column(
                        //                     mainAxisAlignment: MainAxisAlignment.center,
                        //                     crossAxisAlignment: CrossAxisAlignment.center,
                        //                     children: <Widget>[
                        //                       Text(
                        //                         "$value km/hr",
                        //                         style: TextStyle(
                        //                           fontSize: 30 * MediaQuery.of(context).size.width / screenWidth,
                        //                         ),
                        //                         textScaleFactor: 0.9,
                        //                       ),
                        //                       child,
                        //                     ],
                        //                   ),
                        //                 ],
                        //               );
                        //             },
                        //             child: ValueListenableBuilder(
                        //               valueListenable: windDirectionString,
                        //               builder: (BuildContext context, String value, Widget child){
                        //                 return Text(
                        //                   "$value",
                        //                   style: TextStyle(
                        //                     fontSize: 30 * MediaQuery.of(context).size.width / screenWidth,
                        //                   ),
                        //                   textScaleFactor: 0.9,
                        //                 );
                        //               },
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                        Container(
                          width: 2 * MediaQuery.of(context).size.width / screenWidth,
                          height: 35 * MediaQuery.of(context).size.width / screenWidth,
                          color: Colors.grey[300],
                        ),
                        Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                        Expanded(
                          child: Container(
                            height: 65 * MediaQuery.of(context).size.width / screenWidth,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(5 * MediaQuery.of(context).size.width / screenWidth),
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: ValueListenableBuilder(
                                    valueListenable: humidity,
                                    builder: (BuildContext context, int value, Widget child){
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          child,
                                          Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                                          Text(
                                            "$value %",
                                            style: TextStyle(
                                              fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                                            ),
                                            textScaleFactor: 0.9,
                                          ),
                                        ],
                                      );
                                    },
                                    child: Icon(
                                      AppIcon.water_drop,
                                      color: Colors.blue,
                                      size: 20 * MediaQuery.of(context).size.width / screenWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                        Container(
                          width: 2 * MediaQuery.of(context).size.width / screenWidth,
                          height: 35 * MediaQuery.of(context).size.width / screenWidth,
                          color: Colors.grey[300],
                        ),
                        Padding(padding: EdgeInsets.all(3 * MediaQuery.of(context).size.width / screenWidth)),
                        Expanded(
                          child: Container(
                            height: 65 * MediaQuery.of(context).size.width / screenWidth,
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(12 * MediaQuery.of(context).size.width / screenWidth),
                                child: FittedBox(
                                  fit: BoxFit.fitHeight,
                                  child: ValueListenableBuilder(
                                    valueListenable: pressure,
                                    builder: (BuildContext context, int value, _){
                                      return Text(
                                        "$value hPa",
                                        style: TextStyle(
                                          fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        ),
                                        textScaleFactor: 0.9,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(30 * MediaQuery.of(context).size.width / screenWidth)),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth)),
                  side: BorderSide(
                    color: Colors.black38,
                    width: 3 * MediaQuery.of(context).size.width / screenWidth,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 280 * MediaQuery.of(context).size.width / screenWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Spacer(),
                        Container(
                          height: 40 * MediaQuery.of(context).size.width / screenWidth,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.fitHeight,
                              child: Text(
                                "Concentrations",
                                style: TextStyle(
                                    fontSize: 25 * MediaQuery.of(context).size.width / screenWidth,
                                    fontWeight: FontWeight.bold
                                ),
                                textScaleFactor: 0.9,
                              ),
                            ),
                          ),
                        ),
                        Spacer(flex: 2),
                        ValueListenableBuilder(
                          valueListenable: colorNO2,
                          builder: (context, int colorVal, _){
                            return ValueListenableBuilder(
                              valueListenable: colorPM25,
                              builder: (context, int _colorVal, _){
                                return ValueListenableBuilder(
                                  valueListenable: colorCO,
                                  builder: (context, int colorValue, _){
                                    return Padding(
                                      padding: EdgeInsets.only(left: 25 * MediaQuery.of(context).size.width / screenWidth, right: 25 * MediaQuery.of(context).size.width / screenWidth),
                                      child: Table(
                                        border: TableBorder.all(color: Colors.black, width: 2 * MediaQuery.of(context).size.width / screenWidth, style: BorderStyle.none),
                                        children: <TableRow>[
                                          TableRow(
                                              decoration: BoxDecoration(
                                                color: Color(_colorVal),
                                                borderRadius: BorderRadius.all(Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth)),
                                              ),
                                              children: <Widget>[
                                                TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Container(
                                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                                      child: Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Text(
                                                            "PM2.5",
                                                            style: TextStyle(
                                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                                            ),
                                                            textScaleFactor: 0.9,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                                  child: Container(
                                                    height: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                    child: Center(
                                                      child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Icon(Icons.arrow_forward_outlined, size: 24 * MediaQuery.of(context).size.width / screenWidth)
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: ValueListenableBuilder(
                                                      valueListenable: pm25Con,
                                                      builder: (context, double _val, _){
                                                        return Container(
                                                          height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                                          child: Center(
                                                            child: FittedBox(
                                                              fit: BoxFit.fitHeight,
                                                              child: Text(
                                                                "$_val \u03BCg/m\u00B3",
                                                                style: TextStyle(
                                                                    fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                                                ),
                                                                textScaleFactor: 0.9,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                ),
                                              ]
                                          ),
                                          TableRow(
                                              children: <Widget>[
                                                Padding(padding: EdgeInsets.all(4 * MediaQuery.of(context).size.width / screenWidth)),
                                                Padding(padding: EdgeInsets.all(4 * MediaQuery.of(context).size.width / screenWidth)),
                                                Padding(padding: EdgeInsets.all(4 * MediaQuery.of(context).size.width / screenWidth)),
                                              ]
                                          ),
                                          TableRow(
                                              decoration: BoxDecoration(
                                                color: Color(colorVal),
                                                borderRadius: BorderRadius.all(Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth)),
                                              ),
                                              children: <Widget>[
                                                TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Container(
                                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                                      child: Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Text(
                                                            "NO2",
                                                            style: TextStyle(
                                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                                            ),
                                                            textScaleFactor: 0.9,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                                  child: Container(
                                                    height: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                    child: Center(
                                                      child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Icon(Icons.arrow_forward_outlined, size: 24 * MediaQuery.of(context).size.width / screenWidth)
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: ValueListenableBuilder(
                                                      valueListenable: no2Con,
                                                      builder: (context, double _val, _){
                                                        return Container(
                                                          height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                                          child: Center(
                                                            child: FittedBox(
                                                              fit: BoxFit.fitHeight,
                                                              child: Text(
                                                                "$_val ppm",
                                                                style: TextStyle(
                                                                    fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                                                ),
                                                                textScaleFactor: 0.9,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                ),
                                              ]
                                          ),
                                          TableRow(
                                              children: <Widget>[
                                                Padding(padding: EdgeInsets.all(4 * MediaQuery.of(context).size.width / screenWidth)),
                                                Padding(padding: EdgeInsets.all(4 * MediaQuery.of(context).size.width / screenWidth)),
                                                Padding(padding: EdgeInsets.all(4 * MediaQuery.of(context).size.width / screenWidth)),
                                              ]
                                          ),
                                          TableRow(
                                              decoration: BoxDecoration(
                                                color: Color(colorValue),
                                                borderRadius: BorderRadius.all(Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth)),
                                              ),
                                              children: <Widget>[
                                                TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: Container(
                                                      height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                                      child: Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Text(
                                                            "CO",
                                                            style: TextStyle(
                                                                fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                                            ),
                                                            textScaleFactor: 0.9,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                ),
                                                TableCell(
                                                  verticalAlignment: TableCellVerticalAlignment.middle,
                                                  child: Container(
                                                    height: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                    child: Center(
                                                      child: FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Icon(Icons.arrow_forward_outlined, size: 24 * MediaQuery.of(context).size.width / screenWidth)
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                TableCell(
                                                    verticalAlignment: TableCellVerticalAlignment.middle,
                                                    child: ValueListenableBuilder(
                                                      valueListenable: coCon,
                                                      builder: (context, double _val, _){
                                                        return Container(
                                                          height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                                          child: Center(
                                                            child: FittedBox(
                                                              fit: BoxFit.fitHeight,
                                                              child: Text(
                                                                "$_val ppm",
                                                                style: TextStyle(
                                                                    fontSize: 24 * MediaQuery.of(context).size.width / screenWidth
                                                                ),
                                                                textScaleFactor: 0.9,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                ),
                                              ]
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(30 * MediaQuery.of(context).size.width / screenWidth)),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20 * MediaQuery.of(context).size.width / screenWidth)),
                  side: BorderSide(
                    color: Colors.black38,
                    width: 3 * MediaQuery.of(context).size.width / screenWidth,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 530 * MediaQuery.of(context).size.width / screenWidth,
                    child: Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 30 * MediaQuery.of(context).size.width / screenWidth, top:20 * MediaQuery.of(context).size.width / screenWidth),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 40 * MediaQuery.of(context).size.width / screenWidth,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.fitHeight,
                                    child: Text(
                                      "Exposures",
                                      style: TextStyle(
                                          fontSize: 30 * MediaQuery.of(context).size.width / screenWidth
                                      ),
                                      textScaleFactor: 0.9,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Spacer(),
                                  Stack(
                                    alignment: AlignmentDirectional.centerStart,
                                    children: <Widget>[
                                      Container(
                                        width: 80 * MediaQuery.of(context).size.width / screenWidth,
                                        height: 420 * MediaQuery.of(context).size.width / screenWidth,
                                      ),
                                      Positioned(
                                        left: 25 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: AlignmentDirectional.bottomCenter,
                                          children: <Widget>[
                                            Container(
                                              width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                              height: 320 * MediaQuery.of(context).size.width / screenWidth,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable: heightAQI,
                                              builder: (context, double value, _){
                                                return ValueListenableBuilder(
                                                  valueListenable: healthColor,
                                                  builder: (context, int colorVal, _){
                                                    return AnimatedContainer(
                                                      width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                      height: value * MediaQuery.of(context).size.width / screenWidth,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                                        color: Color(colorVal),
                                                      ),
                                                      duration: Duration(milliseconds: 800),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            Positioned(
                                              bottom: safeHeightAQI * MediaQuery.of(context).size.width / screenWidth,
                                              child: Container(
                                                width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                height: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        left: 10 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (41 + safeHeightAQI) * MediaQuery.of(context).size.width / screenWidth,
                                        child: Icon(
                                          Icons.arrow_right_sharp,
                                          // color: ,
                                          size: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        ),
                                      ),
                                      Positioned(
                                        left: -2 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (44 + safeHeightAQI) * MediaQuery.of(context).size.width / screenWidth,
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Container(
                                            height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "60",
                                                style: TextStyle(
                                                    fontSize: 14 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 33 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Container(
                                          height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "AQI",
                                                style: TextStyle(
                                                    fontSize: 20 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    clipBehavior: Clip.none,
                                  ),
                                  Spacer(),
                                  Stack(
                                    clipBehavior: Clip.none,
                                    alignment: AlignmentDirectional.centerStart,
                                    children: <Widget>[
                                      Container(
                                        width: 80 * MediaQuery.of(context).size.width / screenWidth,
                                        height: 420 * MediaQuery.of(context).size.width / screenWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                        ),
                                      ),
                                      Positioned(
                                        left: 25 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: AlignmentDirectional.bottomCenter,
                                          children: <Widget>[
                                            Container(
                                              width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                              height: 320 * MediaQuery.of(context).size.width / screenWidth,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable: heightNO,
                                              builder: (context, double value, _){
                                                return ValueListenableBuilder(
                                                  valueListenable: colorNO2,
                                                  builder: (context, int colorVal, _){
                                                    return AnimatedContainer(
                                                      width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                      height: value * MediaQuery.of(context).size.width / screenWidth,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(8)),
                                                        color: Color(colorVal),
                                                      ),
                                                      duration: Duration(milliseconds: 800),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            Positioned(
                                              bottom: safeHeightNO * MediaQuery.of(context).size.width / screenWidth,
                                              child: Container(
                                                width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                height: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        left: 10 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (41 + safeHeightNO) * MediaQuery.of(context).size.width / screenWidth,
                                        child: Icon(
                                          Icons.arrow_right_sharp,
                                          // color: ,
                                          size: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        ),
                                      ),
                                      Positioned(
                                        left: -3 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (34 + safeHeightNO) * MediaQuery.of(context).size.width / screenWidth,
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Container(
                                            height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "$safeNO ppm",
                                                style: TextStyle(
                                                    fontSize: 14 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 35 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Container(
                                          height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "NO2",
                                                style: TextStyle(
                                                    fontSize: 20 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Stack(
                                    alignment: AlignmentDirectional.centerStart,
                                    children: <Widget>[
                                      Container(
                                        width: 80 * MediaQuery.of(context).size.width / screenWidth,
                                        height: 420 * MediaQuery.of(context).size.width / screenWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                        ),
                                      ),
                                      Positioned(
                                        left: 25 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: AlignmentDirectional.bottomCenter,
                                          children: <Widget>[
                                            Container(
                                              width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                              height: 320 * MediaQuery.of(context).size.width / screenWidth,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable: heightPM25,
                                              builder: (context, double value, _){
                                                return ValueListenableBuilder(
                                                  valueListenable: colorPM25,
                                                  builder: (context, int colorVal, _){
                                                    return AnimatedContainer(
                                                      width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                      height: value * MediaQuery.of(context).size.width / screenWidth,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                                        color: Color(colorVal),
                                                      ),
                                                      duration: Duration(milliseconds: 800),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            Positioned(
                                              bottom: safeHeightPM25 * MediaQuery.of(context).size.width / screenWidth,
                                              child: Container(
                                                width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                height: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        left: 10 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (41 + safeHeightPM25) * MediaQuery.of(context).size.width / screenWidth,
                                        child: Icon(
                                          Icons.arrow_right_sharp,
                                          // color: ,
                                          size: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        ),
                                      ),
                                      Positioned(
                                        left: -5 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (32 + safeHeightPM25) * MediaQuery.of(context).size.width / screenWidth,
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Container(
                                            height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "$safePM25 \u03BCg/m\u00B3",
                                                style: TextStyle(
                                                    fontSize: 14 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 28 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Container(
                                          height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "PM2.5",
                                                style: TextStyle(
                                                    fontSize: 20 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    clipBehavior: Clip.none,
                                  ),
                                  Spacer(),
                                  Stack(
                                    alignment: AlignmentDirectional.centerStart,
                                    children: <Widget>[
                                      Container(
                                        width: 80 * MediaQuery.of(context).size.width / screenWidth,
                                        height: 420 * MediaQuery.of(context).size.width / screenWidth,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                        ),
                                      ),
                                      Positioned(
                                        left: 25 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Stack(
                                          clipBehavior: Clip.none,
                                          alignment: AlignmentDirectional.bottomCenter,
                                          children: <Widget>[
                                            Container(
                                              width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                              height: 320 * MediaQuery.of(context).size.width / screenWidth,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                                color: Colors.blueGrey,
                                              ),
                                            ),
                                            ValueListenableBuilder(
                                              valueListenable: heightCO,
                                              builder: (context, double value, _){
                                                return ValueListenableBuilder(
                                                  valueListenable: colorCO,
                                                  builder: (context, int colorVal, _){
                                                    return AnimatedContainer(
                                                      width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                      height: value * MediaQuery.of(context).size.width / screenWidth,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.all(Radius.circular(8 * MediaQuery.of(context).size.width / screenWidth)),
                                                        color: Color(colorVal),
                                                      ),
                                                      duration: Duration(milliseconds: 800),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                            Positioned(
                                              bottom: safeHeightCO * MediaQuery.of(context).size.width / screenWidth,
                                              child: Container(
                                                width: 50 * MediaQuery.of(context).size.width / screenWidth,
                                                height: 2 * MediaQuery.of(context).size.width / screenWidth,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        left: 10 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (41 + safeHeightCO) * MediaQuery.of(context).size.width / screenWidth,
                                        child: Icon(
                                          Icons.arrow_right_sharp,
                                          // color: ,
                                          size: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        ),
                                      ),
                                      Positioned(
                                        left: -3 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: (33 + safeHeightCO) * MediaQuery.of(context).size.width / screenWidth,
                                        child: RotatedBox(
                                          quarterTurns: 3,
                                          child: Container(
                                            height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "$safeCO ppm",
                                                style: TextStyle(
                                                    fontSize: 14 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        left: 40 * MediaQuery.of(context).size.width / screenWidth,
                                        bottom: 20 * MediaQuery.of(context).size.width / screenWidth,
                                        child: Container(
                                          height: 20 * MediaQuery.of(context).size.width / screenWidth,
                                          child: Center(
                                            child: FittedBox(
                                              fit: BoxFit.fitHeight,
                                              child: Text(
                                                "CO",
                                                style: TextStyle(
                                                    fontSize: 20 * MediaQuery.of(context).size.width / screenWidth
                                                ),
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                    clipBehavior: Clip.none,
                                  ),
                                  Spacer(flex: 3,),
                                ],
                              ),
                              // Spacer(),
                              // Container(
                              //   child: Center(
                              //     child: Row(
                              //       mainAxisAlignment: MainAxisAlignment.center,
                              //       // crossAxisAlignment: CrossAxisAlignment.center,
                              //       children: <Widget>[
                              //         Spacer(),
                              //         Container(
                              //           color: Colors.grey,
                              //           child: FittedBox(
                              //             fit: BoxFit.fitWidth,
                              //             child: Text(
                              //               "Key : "
                              //             ),
                              //           ),
                              //         ),
                              //         RotatedBox(
                              //           quarterTurns: 3,
                              //           child: Container(
                              //             color: Colors.grey,
                              //             child: FittedBox(
                              //               fit: BoxFit.fitWidth,
                              //               child: Text("value",style: TextStyle(fontSize: 14),textScaleFactor: 0.9),
                              //             ),
                              //           ),
                              //         ),
                              //         Container(
                              //           color: Colors.grey,
                              //           child: Icon(Icons.arrow_right_sharp),
                              //         ),
                              //         Container(
                              //           width: 50,
                              //           height: 2,
                              //           color: Colors.black,
                              //         ),
                              //         Spacer(),
                              //         Container(
                              //           width: 75,
                              //           color: Colors.grey,
                              //           child: FittedBox(
                              //             fit: BoxFit.fitWidth,
                              //             child: Text("Safe Values"),
                              //           ),
                              //         ),
                              //         Spacer()
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // Spacer(),
                            ],
                          ),
                        )
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50 * MediaQuery.of(context).size.width / screenWidth,
              ),
            ],
          ),
        ),
      ),
    );

  }
}
