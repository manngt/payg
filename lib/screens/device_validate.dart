import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:gpay/screens/login_screen.dart';
import 'package:gpay/screens/login_validator.dart';

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
      home: DeviceInfoPage(),
    );
  }
}

class DeviceInfoPage extends StatefulWidget {
  @override
  _DeviceInfoPageState createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  String deviceModel = 'Unknown';
  String osVersion = 'Unknown';
  String androidId = 'Unknown';
  String iOSIdentifier = 'Unknown';

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
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
    // After getting device info, send it to backend for validation
    await sendDeviceInfo();
  }

  Future<void> sendDeviceInfo() async {
    // Prepare the URL with query parameters
    final Uri uri = Uri.parse('https://gpspay.io/APIMobile/customer/devVerify?ReqMerchantID=154&ReqToken=i0mQHBMqDxa0UNgx' +
        '&deviceModel=$deviceModel' +
        '&osVersion=$osVersion' +
        '&androidId=$androidId' +
        '&iOSIdentifier=$iOSIdentifier');

    // Send HTTP GET request to your backend API
    try {
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      ).timeout(Duration(seconds: 10), onTimeout: () {
        // Handle timeout
        throw TimeoutException('Request to backend timed out.');
      });

      // Handle response
      if (response.statusCode == 200) {
        // Parse response body for errorCode
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final int? errorCode = jsonResponse['ErrorCode'];

        if (errorCode == 0) {
          // Error code 0 indicates success, redirect to LoginScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } else {
          // Handle errorCode (if needed)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      } else {
        // If statusCode is not 200, redirect to LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    } on TimeoutException catch (e) {
      // Handle timeout
      print('Timeout: ${e.message}');
      // Navigate to an error screen or handle it accordingly
    } catch (e) {
      // Handle other errors here
      print('Error sending device info: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while sending device info
    return Scaffold(
      appBar: AppBar(
        title: Text('Sending Device Info...'),
      ),
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

