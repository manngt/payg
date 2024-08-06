import 'package:flutter/material.dart';
import 'package:gpay/generated/l10n.dart';
import 'package:gpay/models/transfer/inv_ach_bank.dart';
import 'package:gpay/models/transfer/inv_ach_bank_list.dart';
import 'package:gpay/models/transfer/inv_ach_response.dart';
import 'package:gpay/services/system_errors.dart';
import 'package:gpay/services/transfer_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class InvAchTransferForm extends StatefulWidget {
  const InvAchTransferForm({Key? key}) : super(key: key);

  @override
  _InvAchTransferFormState createState() => _InvAchTransferFormState();
}

class _InvAchTransferFormState extends State<InvAchTransferForm>
    with WidgetsBindingObserver {
  //Variables
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> scaffoldStateKey = GlobalKey<ScaffoldState>();
  final _amountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _recipientController = TextEditingController();
  final _messageController = TextEditingController();
  bool isProcessing = false;
  String? _accountType;
  bool banksLoaded = false;
  InvAchResponse invAchResponse = InvAchResponse();
  InvAchBank? invAchBankSelected;
  InvAchBankList? invAchBanks;

  _getInvAchBanks() async {
    await TransferServices.getInvAchBanks().then((list) => {
          setState(() {
            invAchBanks = InvAchBankList.fromJson(list);
            banksLoaded = true;
          })
        });
  }

  //functions for dialogs
  _showSuccessResponse(
      BuildContext context, InvAchResponse invAchResponse) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.greenAccent,
          child: Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              child: Text(
                              'No Autorizacion',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              width: 150,
                            ),
                            SizedBox(
                              child: Text(invAchResponse.transID.toString()),
                              width: 150,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: Text(
                                'Transferido a',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              width: 150,
                            ),
                            SizedBox(
                              child: Text(invAchResponse.transferTo.toString()),
                              width: 150,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: Text(
                                'Debitado',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              width: 150,
                            ),
                            SizedBox(
                              child:
                                  Text(invAchResponse.totalDebit.toString()),
                              width: 150,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: Text(
                                'Cargo',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              width: 150,
                            ),
                            SizedBox(
                              child:
                                  Text(invAchResponse.fee.toString()),
                              width: 150,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: Text(
                                'Rate',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              width: 150,
                            ),
                            SizedBox(
                              child:
                              Text(invAchResponse.rate.toString()),
                              width: 150,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              child: Text(
                                'Transferido en GTQ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              width: 150,
                            ),
                            SizedBox(
                              child:
                              Text(invAchResponse.transferAmount.toString()),
                              width: 150,
                            ),
                          ],
                        ),
                      ],
                    ),
                    margin: const EdgeInsets.only(left: 40),
                  ),
                  ElevatedButton(
                    child: const Text('Cerrar'),
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0XFF0E325F),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _showErrorResponse(BuildContext context, String errorMessage) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          color: Colors.red,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                  margin: const EdgeInsets.only(left: 40.0),
                ),
                ElevatedButton(
                  child: const Text('Cerrar'),
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF0E325F),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //Check response
  _checkResponse(BuildContext context, dynamic json) async {
    if (json['ErrorCode'] == 0) {
      InvAchResponse invAchResponse = InvAchResponse.fromJson(json);
      _showSuccessResponse(context, invAchResponse);
    } else {
      String errorMessage =
          await SystemErrors.getSystemError(json['ErrorCode']);
      _showErrorResponse(context, errorMessage);
    }
  }

  //Reset from
  _resetForm() {
    setState(() {
      isProcessing = false;
      _amountController.text = '';
      _messageController.text = '';
      _passwordController.text = '';
      _recipientController.text = '';
    });
  }

  //Execute registration
  _executeTransaction(BuildContext context) async {
    setState(() {
      isProcessing = true;
    });
    await TransferServices.getInvAch(
            _passwordController.text,
            _amountController.text,
            _recipientController.text,
        _accountType!,
        invAchBankSelected!.bankCode.toString())
        .then((response) => {
              if (response['ErrorCode'] != null)
                {
                  _checkResponse(context, response),
                }
            })
        .catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString(),
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
      _resetForm();
    });
    _resetForm();
  }

  _offScanning() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isScanning', false);
  }

  @override
  void initState() {
    _getInvAchBanks();
    _offScanning();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transferencia a \n Banco de GTM', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0XFF0E325F),
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      backgroundColor: const Color(0XFFAFBECC),
      body: Builder(
        builder: (context) => Form(
          child: SizedBox(
            child: SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    child: SizedBox(
                      child: ListView(
                        children: [
                          Container(
                            child: const Text(
                                'Se utiliza el Rate de Cambio del dia \n de Banco Central de Guatemala'),
                                decoration: BoxDecoration(
                                color: const Color(0XFFEFEFEF),
                                border: Border.all(
                                  color: const Color(0XFF01ACCA),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0))),
                            margin: const EdgeInsets.only(bottom: 15.0),
                            padding: const EdgeInsets.only(left: 35.0),
                            width: 300,
                          ),
                          banksLoaded
                              ? Container(
                                  child: DropdownButton<InvAchBank>(
                                    hint: const Text(
                                      'Seleccionar Banco',
                                      style: TextStyle(
                                        color: Colors.black26,
                                        fontFamily: 'VarelaRoundRegular',
                                      ),
                                    ),
                                    value: invAchBankSelected,
                                    onChanged: (InvAchBank? value) {
                                      setState(() {
                                        invAchBankSelected = value;
                                      });
                                    },
                                    items: invAchBanks!.invAchBanks!
                                        .map((InvAchBank invAchBank) {
                                      return DropdownMenuItem<InvAchBank>(
                                        value: invAchBank,
                                        child: Container(
                                          padding:
                                          const EdgeInsets.only(left: 5.0),
                                          width: 250,
                                          child: Text(
                                            '${invAchBank.bankName}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'VarelaRoundRegular',
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0))),
                            margin: const EdgeInsets.only(bottom: 15.0),
                            padding: const EdgeInsets.only(left: 10.0),
                            width: 300,
                          )
                              : Container(
                                  child: TextField(
                                    decoration: InputDecoration(
                                        label: Text(
                                          'Seleccionar Banco',
                                          style: const TextStyle(
                                            color: Colors.black26,
                                            fontFamily: 'VarelaRoundRegular',
                                          ),
                                        ),
                                        border: InputBorder.none),
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(30.0))),
                                  margin: const EdgeInsets.only(bottom: 15.0),
                                  padding: const EdgeInsets.only(left: 10.0),
                                  width: 300,
                                ),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  label: Text(
                                    'Monto (Maximo Q1,500.00)',
                                    style: const TextStyle(
                                      color: Colors.black26,
                                      fontFamily: 'VarelaRoundRegular',
                                    ),
                                  ),
                                  border: InputBorder.none),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obligatorio';
                                }
                              },
                              controller: _amountController,
                            ),
                            decoration: BoxDecoration(
                                color: const Color(0XFFEFEFEF),
                                border: Border.all(
                                  color: const Color(0XFF01ACCA),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0))),
                            margin: const EdgeInsets.only(bottom: 15.0),
                            padding: const EdgeInsets.only(left: 10.0),
                            width: 300,
                          ),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  label: Text(
                                    'Nro de Cuenta Destino',
                                    style: const TextStyle(
                                      color: Colors.black26,
                                      fontFamily: 'VarelaRoundRegular',
                                    ),
                                  ),
                                  border: InputBorder.none),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obligatorio';
                                }
                              },
                              controller: _recipientController,
                            ),
                            decoration: BoxDecoration(
                                color: const Color(0XFFEFEFEF),
                                border: Border.all(
                                  color: const Color(0XFF01ACCA),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0))),
                            margin: const EdgeInsets.only(bottom: 15.0),
                            padding: const EdgeInsets.only(left: 10.0),
                            width: 300,
                          ),
                          Container(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                label: Text(
                                  'Tipo de Cuenta',
                                  style: const TextStyle(
                                    color: Colors.black26,
                                    fontFamily: 'VarelaRoundRegular',
                                  ),
                                ),
                                border: InputBorder.none,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: '1',
                                  child: Text('Monetarios'),
                                ),
                                DropdownMenuItem(
                                  value: '2',
                                  child: Text('Ahorros'),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  _accountType = newValue!;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obligatorio';
                                }
                                return null;
                              },
                              value: _accountType,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0XFFEFEFEF),
                              border: Border.all(
                                color: const Color(0XFF01ACCA),
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(30.0),
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 15.0),
                            padding: const EdgeInsets.only(left: 10.0),
                            width: 300,
                          ),
                          Container(
                            child: TextFormField(
                              decoration: InputDecoration(
                                  label: Text(
                                    'PIN Web',
                                    style: const TextStyle(
                                      color: Colors.black26,
                                      fontFamily: 'VarelaRoundRegular',
                                    ),
                                  ),
                                  border: InputBorder.none),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [LengthLimitingTextInputFormatter(4)],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Campo obligatorio';
                                }
                              },
                              controller: _passwordController,
                              obscureText: true,
                            ),
                            decoration: BoxDecoration(
                                color: const Color(0XFFEFEFEF),
                                border: Border.all(
                                  color: const Color(0XFF01ACCA),
                                ),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0))),
                            margin: const EdgeInsets.only(bottom: 15.0),
                            padding: const EdgeInsets.only(left: 10.0),
                            width: 300,
                          ),
                          Visibility(
                            child: Container(
                              child: TextButton(
                                child: Text(
                                  'Enviar',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'VarelaRoundRegular',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.0),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _executeTransaction(context);
                                  }
                                },
                              ),
                              decoration: const BoxDecoration(
                                  color: Color(0xFF00CAB2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(25.0))),
                              width: 300.0,
                            ),
                            visible: !isProcessing,
                          ),
                        ],
                      ),
                      height: screenHeight,
                      width: 300,
                    ),
                    top: 50,
                    left: (screenWidth - 300) / 2,
                  ),
                  Positioned(
                    child: Visibility(
                      child: Container(
                        child: Text(
                          'Procesando',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'VarelaRoundRegular',
                          ),
                        ),
                        decoration: const BoxDecoration(color: Colors.grey),
                        height: 50.0,
                        width: screenWidth,
                        padding: const EdgeInsets.all(10.0),
                      ),
                      visible: isProcessing,
                    ),
                    top: screenHeight - 130.0,
                  ),
                ],
              ),
            ),
            height: screenHeight,
            width: screenWidth,
          ),
          key: _formKey,
        ),
      ),
    );
  }
}
