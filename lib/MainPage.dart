import 'package:flutter/material.dart';
import 'package:envirosense_aqwms/ValueNotifiers.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:envirosense_aqwms/functions.dart' as functions;
import 'package:envirosense_aqwms/Locations.dart';

class LoadingScreen extends StatefulWidget {
  final String title;
  LoadingScreen({@required this.title, Key key}) : super(key: key);
  @override
  _LoadingScreenState createState() => _LoadingScreenState(this.title);
}

class _LoadingScreenState extends State<LoadingScreen> {
  _LoadingScreenState(String title){
    this._title = title;
  }
  String _title;
  @override
  void initState() {
    super.initState();
    _checkConnection();
  }
  @override
  void dispose() {
    title.dispose();
    subtitle.dispose();
    super.dispose();
  }
  String username = "fypaqwms@gmail.com";
  String password = "fypcloud2020";
  String bearerToken;
  var response;
  var data;
  Future<Map<String, dynamic>> _login(String user, String pass) async{
    subtitle.value = "Connecting to server";
    var url = Uri.parse('https://demo.thingsboard.io/api/auth/login');
    var body = json.encode({
      "username" : user,
      "password" : pass
    });
    try {
      response = await http.post(
        url,
        headers: {
          'Content-Type' : 'application/json',
          'Accept' : 'application/json'
        },
        body: body,
      );
    } catch(e){
      subtitle.value = "Error Connecting to Server";
      _showPopup();
    }
    String token = json.decode(response.body)['token'].toString();
    bearerToken = 'Bearer\$' + token;
    await functions.save('bearerToken.txt', bearerToken);
    if(response.body != null){
      subtitle.value = "Connected to server";
    }
    return json.decode(response.body);
  }
  Future<Map<String,dynamic>> _getDeviceIds() async{
    var url = Uri.parse('https://demo.thingsboard.io/api/tenant/devices?pageSize=100&page=0');
    var response = await http.get(
        url,
        headers: {
          'Content-Type':'application/json',
          'Accept':'application/json',
          'X-Authorization':'$bearerToken',
        }
    );
    data = await json.decode(response.body)['data'];
    for(int i = 0; i < data.length; i++){
      String devId = data[i]['id']['id'].toString();
      await functions.save('devId${i+1}.txt', devId);
    }
    return json.decode(response.body);
  }
  _checkConnection() async{
    bool status = await DataConnectionChecker().hasConnection;
    if (!status){
      subtitle.value = "NO INTERNET CONNECTION";
      await Future.delayed(Duration(seconds: 2));
      await _showPopup();
    }
    else{
      await Future.delayed(Duration(seconds: 2));
      subtitle.value = "CONNECTED";
      await Future.delayed(Duration(seconds: 1));
      title.value = _title;
      await _login(username, password);
      await _getDeviceIds();
      await _route();
    }
  }
  _route() async{
    await Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => LocationPage(devCount: data.length)),
    );
  }
  _showPopup() async{
    String title = "You are disconnected from the internet. ";
    String subtitle = "Please check your internet connection";
    await _showDialog(title, subtitle, context);
  }
  _showDialog(String title, String subtitle, BuildContext context) async{
    showDialog(
        context: context,
        builder: (BuildContext context){
          return WillPopScope(
            onWillPop: () async => false,
            child: AlertDialog(
              title: Text(title),
              content: Text(subtitle),
              actions: <Widget>[
                ElevatedButton(
                  onPressed: (){
                    SystemNavigator.pop(animated: true);
                  },
                  child: Text("Close Application"),
                ),
                ElevatedButton(
                  onPressed: () async{
                    Navigator.pop(context);
                    await _checkConnection();
                  },
                  child: Text("Retry"),
                )
              ],
            ),
          );
        }
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 2,),
              Text(
                "ENVIROSENSE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32 * MediaQuery.of(context).size.width / screenWidth,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(flex: 6),
              ValueListenableBuilder(
                valueListenable: title,
                builder: (context, String title, _){
                  return Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28 * MediaQuery.of(context).size.width / screenWidth,
                    ),
                  );
                },
              ),
              Spacer(),
              Padding(
                padding: EdgeInsets.only(
                    right: 100 * MediaQuery.of(context).size.width / screenWidth,
                    left: 100 * MediaQuery.of(context).size.width / screenWidth
                ),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.blue,
                  minHeight: 8 * MediaQuery.of(context).size.width / screenWidth,
                ),
              ),
              Spacer(),
              ValueListenableBuilder(
                valueListenable: subtitle,
                builder: (context, String subtitle, _){
                  return Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 28 * MediaQuery.of(context).size.width / screenWidth
                    ),
                  );
                },
              ),
              Spacer(flex: 6),
            ],
          ),
        ),
      ),
    );
  }
}
