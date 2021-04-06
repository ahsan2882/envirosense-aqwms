import 'package:flutter/material.dart';
import 'package:envirosense_aqwms/ValueNotifiers.dart';
import 'package:envirosense_aqwms/Maps.dart';
import 'package:envirosense_aqwms/DataScreen.dart';
import 'package:envirosense_aqwms/StatisticsScreen.dart';

final ValueNotifier<String> locationName = ValueNotifier<String>("Loading");

class Node extends StatefulWidget {
  final String deviceId;
  final int index;
  Node({@required this.index, @required this.deviceId, Key key}) : super(key: key);
  @override
  _NodeState createState() => _NodeState(this.deviceId, this.index);
}

class _NodeState extends State<Node> {
  _NodeState(String devId, int _index){
    this._deviceId = devId;
    this._index = _index;
  }
  String _deviceId = "";
  int _index = 0;
  @override
  void initState() {
    super.initState();
    locationName.value = location.value[_index];
  }
  @override
  void dispose() {
    super.dispose();
  }
  int selectedIndex = 0;
  List<Widget> screens = <Widget>[
    DataPage(devId: "h", devIndex: 0),
    MapPage(latValue: double.parse(latitude.value[1]), longValue: double.parse(longitude.value[0]), zoom: 16.0),
    StatisticsPage(devId: "h")
  ];
  @override
  Widget build(BuildContext context) {
    screens[0] = DataPage(devId: _deviceId, devIndex: _index);
    screens[1] = MapPage(latValue: double.parse(latitude.value[_index]), longValue: double.parse(longitude.value[_index]), zoom: 16.0);
    screens[2] = StatisticsPage(devId: _deviceId);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.square(60.0 * MediaQuery.of(context).size.width / screenWidth),
        child: AppBar(
          elevation: 10 * MediaQuery.of(context).size.width / screenWidth,
          title: Text(locationName.value),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_location_alt_sharp,
            ),
            label: 'MyAir',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map,
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_sharp),
            label: 'Statistics',
          ),
        ],
        onTap: (index){
          setState(() {
            selectedIndex = index;
          });
        },
        selectedFontSize: 15 * MediaQuery.of(context).size.width / screenWidth,
        unselectedFontSize: 15 * MediaQuery.of(context).size.width / screenWidth,
        iconSize: 27 * MediaQuery.of(context).size.width / screenWidth,
      ),
      body: screens.elementAt(selectedIndex),
    );
  }
}
