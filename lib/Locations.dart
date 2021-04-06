import 'package:flutter/material.dart';
import 'package:envirosense_aqwms/ValueNotifiers.dart';
import 'package:envirosense_aqwms/functions.dart' as functions;
import 'package:envirosense_aqwms/app_icon_icons.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:envirosense_aqwms/Maps.dart';
import 'package:envirosense_aqwms/NodeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:math';

final ValueNotifier<int> _devCount = ValueNotifier<int>(0);

class LocationPage extends StatefulWidget {
  final int devCount;
  LocationPage({this.devCount, Key key}) : super(key: key);
  @override
  _LocationPageState createState() => _LocationPageState(this.devCount);
}

class _LocationPageState extends State<LocationPage> {
  _LocationPageState(int devCount){
    _devCount.value = devCount;
  }
  @override
  void initState() {
    super.initState();
    _getVal();
  }
  @override
  void dispose() {
    super.dispose();
  }
  var data;
  _getVal() async{
    location.value = [];
    longitude.value = [];
    latitude.value = [];
    for(int i = 0; i < _devCount.value; i++){
      await _getLocValues(i);
    }
  }
  Future<Map<String, dynamic>> _getLocValues(int index) async{
    String bearerToken = await functions.read('bearerToken.txt');
    String deviceId = await functions.read('devId${index+1}.txt');
    var url = Uri.parse('https://demo.thingsboard.io/api/plugins/telemetry/DEVICE/$deviceId/values/timeseries?keys=latitude,longitude,location');
    var response = await http.get(
        url,
        headers: {
          'Content-Type':'application/json',
          'Accept':'application/json',
          'X-Authorization': bearerToken,
        }
    );
    var data = await json.decode(response.body);
    location.value = List.from(location.value)..add((data['location'][0]['value']).toString());
    longitude.value = List.from(longitude.value)..add((data['longitude'][0]['value']).toString());
    latitude.value = List.from(latitude.value)..add((data['latitude'][0]['value']).toString());
    return json.decode(response.body);
  }
  Future<Map<String,dynamic>> _getDeviceId () async{
    String bearerToken = await functions.read('bearerToken.txt');
    var url = Uri.parse('https://demo.thingsboard.io/api/tenant/devices?pageSize=100&page=0');
    var responseDev = await http.get(
        url,
        headers: {
          'Content-Type':'application/json',
          'Accept':'application/json',
          'X-Authorization':'$bearerToken',
        }
    );
    data = await json.decode(responseDev.body)['data'];
    if(_devCount.value < data.length){
      for(int i = _devCount.value; i < data.length; i++){
        String devId = data[i]['id']['id'].toString();
        await functions.save('devId${i+1}.txt', devId);
      }
    }
    _devCount.value = data.length;
    await _getVal();
    return json.decode(responseDev.body);
  }
  _refresh() async{
    await _getDeviceId();
  }
  _goToNode(int index) async{
    String deviceId = await functions.read('devId${index+1}.txt');
    await Navigator.push(context, MaterialPageRoute(
        builder: (context) => LoadingState(devId: deviceId, index: index)
    ));
  }
  _goToMap() async{
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MapPage(latValue: 24.919, longValue: 67.065, zoom: 12.0 * MediaQuery.of(context).size.width / screenWidth)
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Available Locations',
          style: TextStyle(
            fontSize: 20 * MediaQuery.of(context).size.width / screenWidth,
          ),
          textScaleFactor: 0.9,
        ),
        leading: Icon(AppIcon.globe_2,
          color: Colors.blue,
          size: 35 * MediaQuery.of(context).size.width / screenWidth,
        ),
      ),
      backgroundColor: Colors.grey[400],
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints){
            return Center(
              child: RefreshIndicator(
                onRefresh: () async{
                  await _refresh();
                },
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Container(
                    constraints: constraints,
                    child: Padding(
                      padding: EdgeInsets.all(8 * MediaQuery.of(context).size.width / screenWidth),
                      child: Center(
                        child: ValueListenableBuilder(
                          valueListenable: location,
                          builder: (context, List items, _){
                            return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  if(items.length != _devCount.value)
                                    Padding(
                                      padding: EdgeInsets.only(left: 80 * MediaQuery.of(context).size.width / screenWidth, right: 80 * MediaQuery.of(context).size.width / screenWidth),
                                      child: LinearProgressIndicator(
                                        minHeight: 6 * MediaQuery.of(context).size.width / screenWidth,
                                        value: items.length / _devCount.value,
                                      ),
                                    )
                                  else
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: items.map<Widget>(
                                              (item) => Container(
                                            child: Card(
                                              child: Center(
                                                child: ListTile(
                                                  leading: Icon(Icons.location_on),
                                                  title: Text(
                                                    item,
                                                    style: TextStyle(
                                                        fontSize: 14 * MediaQuery.of(context).size.width / screenWidth
                                                    ),
                                                  ),
                                                  onTap: () async{
                                                    await _goToNode(items.indexOf(item));
                                                  },
                                                ),
                                              ),
                                            ),
                                          )
                                      ).toList(),
                                    ),
                                  ElevatedButton(
                                      onPressed: () async{
                                        await _goToMap();
                                      },
                                      child: Text(
                                        "Maps",
                                        style: TextStyle(
                                            fontSize: 14 * MediaQuery.of(context).size.width / screenWidth
                                        ),
                                      )
                                  )
                                ]
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoadingState extends StatefulWidget {
  final String devId;
  final int index;
  LoadingState({@required this.devId, @required this.index, Key key}) : super(key: key);
  @override
  _LoadingStateState createState() => _LoadingStateState(this.devId, this.index);
}

class _LoadingStateState extends State<LoadingState> {
  _LoadingStateState(String devId, int index){
    this._devId = devId;
    this._index = index;
  }
  String _devId;
  int _index;
  @override
  void initState() {
    super.initState();
    _getVal();
  }
  @override
  void dispose() {
    super.dispose();
  }
  _getVal() async{
    await _getAllValues();
    await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => Node(deviceId: _devId, index: _index)
        )
    );
  }
  Future<Map<String, dynamic>> _getAllValues() async{

    String bearerToken = await functions.read('bearerToken.txt');
    var response = await http.get(
      Uri.parse('https://demo.thingsboard.io/api/device/$_devId/credentials'),
      headers: {
        'Content-Type':'application/json',
        'Accept':'application/json',
        'X-Authorization': bearerToken,
      },
    );
    var data = await json.decode(response.body);
    String accessToken = data['credentialsId'];
    final prefs = await SharedPreferences.getInstance();
    int aqiVal = prefs.getInt('aqiData$_index') ?? -1;
    int lastUpdate = prefs.getInt('lastUpdateDev$_index') ?? -1;
    String lastUpdateTimeStamp = prefs.getString('lastUpdatedTimeStampDev$_index') ?? "2019-01-05";
    int lastMin = prefs.getInt("lastUpdatedMin") ?? -1;
    int currentMin = int.parse(DateFormat.m().format(DateTime.now()));
    int currentHour = int.parse(DateFormat.H().format(DateTime.now()));
    print(lastUpdate);
    DateTime currentTimeStamp = DateTime(int.parse(DateFormat.y().format(DateTime.now())), int.parse(DateFormat.M().format(DateTime.now())), int.parse(DateFormat.d().format(DateTime.now())));
    print(currentTimeStamp);
    if(aqiVal == -1 || (currentMin - lastMin >= 10) || (currentHour > lastUpdate) || currentTimeStamp.isAfter(DateTime.parse(lastUpdateTimeStamp))){
      var response2 = await http.get(
        Uri.parse('https://api.airvisual.com/v2/nearest_city?lat=24.960874&lon=67.072938&key=d3a020c6-72a6-432a-843f-daeefeff141c')
      );
      var data2 = await json.decode(response2.body);
      aqiVal = data2['data']['current']['pollution']['aqius'];
      int randomNumber = 0;
      print(aqiVal);
      if(aqiVal < 80){
        Random random = new Random();
        randomNumber = random.nextInt(20) - 5;
        aqiVal = aqiVal + randomNumber;
      } else if(aqiVal > 80 && aqiVal < 100){
        Random random = new Random();
        randomNumber = random.nextInt(30) - 10;
        aqiVal = aqiVal + randomNumber;
      } else if(aqiVal > 100 && aqiVal < 150){
        Random random = new Random();
        randomNumber = random.nextInt(25) -15;
        aqiVal = aqiVal + randomNumber;
      } else{
        Random random = new Random();
        randomNumber = random.nextInt(25) - 30;
        aqiVal = aqiVal + randomNumber;
      }
      print(randomNumber);
      print(aqiVal);
      await prefs.setInt('aqiData$_index', aqiVal);
      var body = json.encode({
        'AQI' : '$aqiVal'
      });
      print(body);
      await http.post(
        Uri.parse('https://demo.thingsboard.io/api/v1/$accessToken/telemetry'),
        body: body
      );
      lastUpdate = currentHour;
      await prefs.setInt('lastUpdateDev$_index', lastUpdate);
      lastUpdateTimeStamp = currentTimeStamp.toString();
      await prefs.setString('lastUpdatedTimeStampDev$_index', lastUpdateTimeStamp);
      await prefs.setInt('lastUpdatedMin', currentMin);
      print("AQI UPDATED");
      await Future.delayed(Duration(seconds: 3));
    }

    var response4 = await http.get(
        Uri.parse('https://demo.thingsboard.io/api/plugins/telemetry/DEVICE/$_devId/values/timeseries?keys=humidity,temperature,pressure,windDirection,windSpeed,coCon,no2Con,pm25Con,AQI'),
        headers: {
          'Content-Type':'application/json',
          'Accept':'application/json',
          'X-Authorization': bearerToken,
        }
    );
    var data4 = await json.decode(response4.body);
    airQuality.value = int.parse(await data4['AQI'][0]['value']);
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
    humidity.value = int.parse(await data4['humidity'][0]['value']);
    temperature.value = int.parse(await data4['temperature'][0]['value']);
    pressure.value = (double.parse(await data4['pressure'][0]['value']) ~/ 1);
    if(pressure.value > 2000){
      pressure.value = (double.parse(await data4['pressure'][0]['value']) ~/ 100);
    } else{
      pressure.value = (double.parse(await data4['pressure'][0]['value']) ~/ 1);
    }
    windDirection.value = int.parse(await data4['windDirection'][0]['value']);
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
    windSpeed.value = double.parse(await data4['windSpeed'][0]['value']);
    no2Con.value = double.parse(await data4['no2Con'][0]['value']);
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
    pm25Con.value = double.parse(await data4['pm25Con'][0]['value']);
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
    coCon.value = double.parse(await data4['coCon'][0]['value']);
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
    return json.decode(response4.body);
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          body: Container(
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 5 * MediaQuery.of(context).size.width / screenWidth,
                backgroundColor: Colors.grey[300],
              ),
            ),
          )
      ),
    );
  }
}
