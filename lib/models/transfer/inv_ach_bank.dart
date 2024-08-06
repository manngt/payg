class InvAchBank {
  String? bankName;
  String? bankCode;

  InvAchBank({this.bankName, this.bankCode});

  InvAchBank.fromJson(Map<String, dynamic> json) {
    bankName = json['BankName'];
    bankCode = json['BankCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['BankName'] = this.bankName;
    data['BankCode'] = this.bankCode;
    return data;
  }
}
