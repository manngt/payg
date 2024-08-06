import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:network_info_plus/network_info_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Device Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DeviceInforPage(),
    );
  }
}

class DeviceInforPage extends StatefulWidget {
  @override
  _DeviceInforPageState createState() => _DeviceInforPageState();
}

class _DeviceInforPageState extends State<DeviceInforPage> {
  String deviceModel = 'Unknown';
  String osVersion = 'Unknown';
  String ipAddress = 'Unknown';
  String androidId = 'Unknown';
  String iOSIdentifier = 'Unknown';

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
    getIpAddress();
  }

  Future<void> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      setState(() {
        deviceModel = androidInfo.model;
        osVersion = androidInfo.version.release;
        androidId = androidInfo.androidId;
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      setState(() {
        deviceModel = iosInfo.model;
        osVersion = iosInfo.systemVersion;
        iOSIdentifier = iosInfo.identifierForVendor;
      });
    }
  }

  Future<void> getIpAddress() async {
    NetworkInfo networkInfo = NetworkInfo();
    String? ipAddress;
    try {
      ipAddress = await networkInfo.getWifiIP();
    } catch (e) {
      ipAddress = 'Not available';
    }
    setState(() {
      this.ipAddress = ipAddress ?? 'Unknown'; // Use ?? operator to provide a default value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Info'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Device Model: $deviceModel'),
            Text('OS Version: $osVersion'),
            Text('IP Address: $ipAddress'),
            if (androidId != null && androidId != 'Unknown')
              Text('Android ID: $androidId'),
            if (iOSIdentifier != null && iOSIdentifier != 'Unknown')
              Text('iOS Identifier: $iOSIdentifier'),
          ],
        ),
      ),
    );
  }
}
