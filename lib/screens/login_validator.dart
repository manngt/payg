import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:gpay/screens/login_screen.dart';
import 'package:gpay/screens/startup_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  runApp(TwilioSMSVerificationApp());
}

class TwilioSMSVerificationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twilio SMS Verification',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final List<TextEditingController> _verificationCodeControllers = List.generate(6, (index) => TextEditingController()); // Define here

  String _verificationSid = '';
  String _selectedCountryCode = '+1'; // Default country code

  String deviceModel = 'Unknown';
  String osVersion = 'Unknown';
  String androidId = 'Unknown';
  String iOSIdentifier = 'Unknown';
  String phoneNumberWithoutCountryCode = ''; // Declare as instance variable
  String phoneNumber = ''; // Declare as instance variable

  List<String> _countryCodes = [
    '+1', '+34', '+39', '+51', '+53', '+54', '+56', '+57', '+58', '+502', '+503', '+504', '+505', '+506', '+507', '+591', '+593', // Add more country codes as needed
  ];

  Future<void> _verifyPhoneNumber() async {
    final String fullPhoneNumber = _selectedCountryCode + _phoneNumberController.text;
    // Remove country code portion from the full phone number
    final int countryCodeLength = _selectedCountryCode.length;
      phoneNumberWithoutCountryCode = _phoneNumberController.text;
    if (fullPhoneNumber.length > countryCodeLength) {
      phoneNumberWithoutCountryCode = fullPhoneNumber.substring(countryCodeLength);
    }
    // Update the phoneNumber variable
    phoneNumber = _selectedCountryCode + _phoneNumberController.text;

    final Uri url = Uri.parse('https://gpspay.io/APIMobile/customer/verifyphone?ReqMerchantID=154&ReqToken=i0mQHBMqDxa0UNgx&ReqPhone=$phoneNumberWithoutCountryCode');

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        // Phone number verification successful, proceed to send verification code
        _getDeviceInfo();
        //_sendDeviceInfo();
       // _sendVerificationCode();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Phone number verification failed')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify phone number')),
      );
    }
  }

  Future<void> _getDeviceInfo() async {
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
    await _sendDeviceInfo();
  }

  Future<void> _sendDeviceInfo() async {
    // Prepare the URL with query parameters
    final Uri url = Uri.parse('https://gpspay.io/APIMobile/customer/devRegister?ReqMerchantID=154&ReqToken=i0mQHBMqDxa0UNgx' +
        '&ReqPhone=${this.phoneNumberWithoutCountryCode}' +
        '&deviceModel=$deviceModel' +
        '&osVersion=$osVersion' +
        '&androidId=$androidId' +
        '&iOSIdentifier=$iOSIdentifier');

    // Send HTTP POST request to your backend API
      try {
        final http.Response response = await http.get(
          url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
          },
        );

      // Handle response
      if (response.statusCode == 200) {
        // Parse response body for errorCode
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final int? errorCode = jsonResponse['ErrorCode'];

        if (errorCode == 0) {
          // Error code 0 indicates success
           _sendVerificationCode();
        } else {
          // Handle errorCode (if needed)
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Phone number verification failed')),
          );
        }
      } else {
        // If statusCode is not 200, redirect to LoginPage
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Phone number does not exist')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify phone number')),
      );
    }
  }

  Future<void> _sendVerificationCode() async {
    final String? accountSid = dotenv.env['ACCOUNT_SID'];
    final String? authToken =  dotenv.env['AUTH_TOKEN'];
    // final String twilioNumber
    final String userPhoneNumber = _selectedCountryCode + _phoneNumberController.text;

    //final Uri
    final Uri url = Uri.parse('https://verify.twilio.com/v2/Services/VA5473714b4a067df6bf72fb3fb1676f0c/Verifications');
    final http.Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
      },
      body: <String, String>{
        'To': userPhoneNumber,
        'Channel': 'sms'
      },
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _verificationSid = responseData['sid'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification code sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification code')),
      );
    }
  }

  Future<void> _verifyCode() async {
    final String? accountSid = dotenv.env['ACCOUNT_SID'];
    final String? authToken =  dotenv.env['AUTH_TOKEN'];
    final String userPhoneNumber = phoneNumber; //phoneNumber;
    final String userCodeNumber = _verificationCodeControllers.map((controller) => controller.text).join();

    final Uri uri = Uri.parse('https://verify.twilio.com/v2/Services/VA5473714b4a067df6bf72fb3fb1676f0c/VerificationCheck');
    final http.Response response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic ${base64Encode(utf8.encode('$accountSid:$authToken'))}',
      },
      body: <String, String>{
        'To': userPhoneNumber,
        'Code': userCodeNumber
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == 'approved') {
        setState(() {
          _verificationSid = responseData['sid'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification successful')),
        );
        // Proceed with login or desired action
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification code is incorrect')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify code')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPSPAY SMS Verification'),
      ),
      body: Stack(
        children: [
          Image.asset(
            'images/logos/logo-gpswallet-m.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            height: 100, // Adjust height as needed
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    DropdownButton<String>(
                      value: _selectedCountryCode,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCountryCode = newValue!;
                        });
                      },
                      items: _countryCodes.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _phoneNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _verifyPhoneNumber(); // Call _verifyPhoneNumber() here
                  },
                  child: Text('Send Verification Code'),
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      child: _buildVerificationCodeTextField(index),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: _verifyCode,
                  child: Text('Verify Code'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCodeTextField(int index) {
    return SizedBox(
      width: 40.0,
      child: TextField(
        controller: _verificationCodeControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 5) {
              FocusScope.of(context).nextFocus();
            } else {
              // Last text field, hide keyboard
              FocusScope.of(context).unfocus();
            }
          } else {
            // Backspace pressed, focus previous text field
            if (index > 0) {
              FocusScope.of(context).previousFocus();
            }
          }
        },
        decoration: InputDecoration(
          counter: Offstage(), // Hide character counter
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
