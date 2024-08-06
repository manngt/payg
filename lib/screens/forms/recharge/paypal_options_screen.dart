import 'package:flutter/material.dart';
import 'package:gpay/generated/l10n.dart';
import 'package:gpay/screens/forms/recharge/paypal_form.dart';
import 'package:gpay/widgets/paypal_disclosureTransfer_widget.dart';
import 'package:url_launcher/url_launcher.dart';

_openURL() async {
  Uri url = Uri.parse('https://www.paypal.com/paypalme/NEOTEL/');
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw 'Could not launch $url';
  }
}

class PayPalOptionsScreen extends StatefulWidget {
  const PayPalOptionsScreen({Key? key}) : super(key: key);

  @override
  _PayPalOptionsScreenState createState() => _PayPalOptionsScreenState();
}

class _PayPalOptionsScreenState extends State<PayPalOptionsScreen> {
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          flexibleSpace: Image.asset(
            'images/backgrounds/app_bar_header.png',
            fit: BoxFit.fill,
            height: 150.0,
          ),
          title: const Text(
            'PayPal Options',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'VarealRoundRegular',
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SizedBox(
          child: SafeArea(
            child: Stack(
              children: [
                Image.asset(
                  'images/backgrounds/app_background.jpg',
                  height: screenHeight,
                  width: screenWidth,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  child: SizedBox(
                    child: ListView(
                      children: [
                        PaypalDisclosureTWidget(
                          text: S.of(context).paypalDisclosureTransfer,
                        ),
                            Container(
                              child: TextButton(
                                child: Text(
                                  S.of(context).payPalTransfer,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'VarelaRoundRegular',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                  ),
                                ),
                                onPressed: _openURL, // Call _openURL function when the button is pressed
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFF00CAB2),
                                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                              ),
                              width: 300.0,
                              margin: const EdgeInsets.only(
                                bottom: 10.0,
                              ),
                            ),
                        Container(
                          child: TextButton(
                            child: Text(
                              S.of(context).payPalLoad,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'VarelaRoundRegular',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PayPalForm(),
                                ),
                              );
                            },
                          ),
                          decoration: const BoxDecoration(
                              color: Color(0xFF00CAB2),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                          width: 300.0,
                        ),
                      ],
                    ),
                    height: screenHeight,
                    width: 300,
                  ),
                  top: 50,
                  left: (screenWidth - 300) / 2,
                ),
              ],
            ),
          ),
          height: screenHeight,
          width: screenWidth,
        ));
  }
}
