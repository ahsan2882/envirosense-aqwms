import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:envirosense_aqwms/ValueNotifiers.dart';
import 'package:envirosense_aqwms/functions.dart' as functions;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:envirosense_aqwms/AQI.dart';
import 'package:envirosense_aqwms/PM25.dart';

int aqiLength;
int no2Length;
int coLength;
int pm25Length;

Timer _timer;

final ValueNotifier<int> dataLength = ValueNotifier<int>(0);
final ValueNotifier<int> selectedButton = ValueNotifier<int>(0);

class StatisticsPage extends StatefulWidget {
  final String devId;
  StatisticsPage({@required this.devId, Key key}) : super(key: key);
  @override
  _StatisticsPageState createState() => _StatisticsPageState(this.devId);
}

class _StatisticsPageState extends State<StatisticsPage> {
  _StatisticsPageState(String deviceId){
    this._devId = deviceId;
  }
  String _devId;
  @override
  void initState() {
    super.initState();
    dataLength.value = 0;
    aqiLength = 0;
    pm25Length = 0;
    aqiValueList.value = List.filled(36, 0);
    aqiTsList.value = List.filled(36, 11111111111);
    pm25ValueList.value = List.filled(36, 0);
    pm25TsList.value = List.filled(36, 11111111111);
    _getPastValues();
    startTimer();
  }
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  startTimer() async{
    final duration = Duration(seconds: 20);
    _timer = Timer.periodic(duration, (timer){
      _getPastValues();
    });
  }
  List<Widget> screens = <Widget>[
    AQIStat(),
    PM25Stat(),
  ];
  Future<Map<String, dynamic>> _getPastValues() async{
    var startTs = DateTime.now().millisecondsSinceEpoch - 43200000;
    var endTs = DateTime.now().millisecondsSinceEpoch;
    String bearerToken = await functions.read('bearerToken.txt');
    var url = Uri.parse("https://demo.thingsboard.io/api/plugins/telemetry/DEVICE/$_devId/values/timeseries?limit=36&keys=AQI,pm25Con&startTs=$startTs&endTs=$endTs");
    var response = await http.get(
        url,
        headers: {
          'Accept':'application/json',
          'X-Authorization': bearerToken,
        }
    );
    var data = await json.decode(response.body);
    dataLength.value = data.length;
    var aqiData = await data['AQI'];
    var pm25Data = await data['pm25Con'];
    aqiLength = 0;
    pm25Length = 0;
    for(int i = 0, j = 0, k = 0, l = 0; i < aqiLength && j < coLength && k < no2Length && l < pm25Length; i++, j++, k++, l++){
      aqiValueList.value[aqiLength - i - 1] = int.parse(await aqiData[i]['value']);
      aqiTsList.value[aqiLength - i - 1] = await aqiData[i]['ts'];
      pm25ValueList.value[pm25Length - l - 1] = double.parse(await pm25Data[l]['value']);
      pm25TsList.value[pm25Length - l - 1] = await pm25Data[l]['ts'];
    }
    return json.decode(response.body);
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: dataLength,
      builder: (context, int _dataVal, _){
        return Container(
          child: Center(
              child: _dataVal != 0
                  ? Padding(
                padding: EdgeInsets.all(80 * MediaQuery.of(context).size.width / screenWidth),
                child: LinearProgressIndicator(
                  minHeight: 6 * MediaQuery.of(context).size.width / screenWidth,
                ),
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Spacer(flex: 10),
                  ValueListenableBuilder(
                    valueListenable: selectedButton,
                    builder: (context, int _selectedButton, _){
                      return screens[_selectedButton];
                    },
                  ),
                  Spacer(flex: 18,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      ElevatedButton(
                        child: Center(
                          child: Text(
                            "AQI",
                            style: TextStyle(
                                fontSize: 20 * MediaQuery.of(context).size.width / screenWidth
                            ),
                          ),
                        ),
                        onPressed: (){
                          selectedButton.value = 0;
                        },
                      ),
                      Spacer(),
                      ElevatedButton(
                        child: Center(
                          child: Text(
                            "PM2.5",
                            style: TextStyle(
                                fontSize: 20 * MediaQuery.of(context).size.width / screenWidth
                            ),
                          ),
                        ),
                        onPressed: (){
                          selectedButton.value = 1;
                        },
                      ),
                      Spacer(),
                    ],
                  ),
                  Spacer(flex: 3),
                ],
              )
          ),
        );
      },
    );
  }
}
