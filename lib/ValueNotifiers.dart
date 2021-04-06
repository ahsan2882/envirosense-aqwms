import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

double screenWidth = 423.5293998850261;

int maxNO = 10;
int maxCO = 100;
int maxPM25 = 100;
int safeNO = 2;
int safePM25 = 10;
int safeCO = 9;

final ValueNotifier<String> title = ValueNotifier<String>("Checking Network Connection");
final ValueNotifier<String> subtitle = ValueNotifier<String>("");
final ValueNotifier<List> location = ValueNotifier<List>([]);
final ValueNotifier<List> longitude = ValueNotifier<List>([]);
final ValueNotifier<List> latitude = ValueNotifier<List>([]);
final ValueNotifier<int> airQuality = ValueNotifier<int>(0);
final ValueNotifier<int> humidity = ValueNotifier<int>(0);
final ValueNotifier<int> pressure = ValueNotifier<int>(0);
final ValueNotifier<int> temperature = ValueNotifier<int>(0);
final ValueNotifier<double> no2Con = ValueNotifier<double>(0.0);
final ValueNotifier<double> coCon = ValueNotifier<double>(0.0);
final ValueNotifier<double> windSpeed = ValueNotifier<double>(0.0);
final ValueNotifier<int> windDirection = ValueNotifier<int>(0);
final ValueNotifier<String> windDirectionString = ValueNotifier<String>("Loading");
final ValueNotifier<double> pm25Con = ValueNotifier<double>(0.0);
final ValueNotifier<String> healthStatus = ValueNotifier<String>("");
final ValueNotifier<int> healthColor = ValueNotifier<int>(0xff9c9c9c);
final ValueNotifier<double> heightAQI = ValueNotifier<double>(0.0);
final ValueNotifier<double> heightNO = ValueNotifier<double>(0.0);
final ValueNotifier<double> heightPM25 = ValueNotifier<double>(0.0);
final ValueNotifier<double> heightCO = ValueNotifier<double>(0.0);
final ValueNotifier<int> colorNO2 = ValueNotifier<int>(0xff9c9c9c);
final ValueNotifier<int> colorPM25 = ValueNotifier<int>(0xff9c9c9c);
final ValueNotifier<int> colorCO = ValueNotifier<int>(0xff9c9c9c);
final ValueNotifier<List> aqiValueList = ValueNotifier<List>([]);
final ValueNotifier<List> aqiTsList = ValueNotifier<List>([]);
final ValueNotifier<List> coValueList = ValueNotifier<List>([]);
final ValueNotifier<List> coTsList = ValueNotifier<List>([]);
final ValueNotifier<List> no2ValueList = ValueNotifier<List>([]);
final ValueNotifier<List> no2TsList = ValueNotifier<List>([]);
final ValueNotifier<List> pm25ValueList = ValueNotifier<List>([]);
final ValueNotifier<List> pm25TsList = ValueNotifier<List>([]);
final ValueNotifier<String> dataValue = ValueNotifier<String>("0");
final ValueNotifier<String> aqiDataValue = ValueNotifier<String>("0");
final ValueNotifier<String> currentTime = ValueNotifier<String>("${DateFormat.jm().format(DateTime.now())}");
final ValueNotifier<String> dateTimeValue = ValueNotifier<String>("${DateFormat.jm().format(DateTime.now())}");
final ValueNotifier<int> timeDiff = ValueNotifier<int>(0);