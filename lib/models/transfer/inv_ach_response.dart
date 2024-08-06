class InvAchResponse {
  int? errorCode;
  String? transferTo;
  String? totalDebit;
  String? fee;
  String? rate;
  String? transferAmount;
  String? transID;

  InvAchResponse(
      {this.errorCode,
      this.transferTo,
      this.totalDebit,
      this.fee,
      this.rate,
      this.transferAmount,
      this.transID});

  InvAchResponse.fromJson(Map<String, dynamic> json) {
    errorCode = json['ErrorCode'];
    transferTo = json['TransferTo'];
    totalDebit = json["DebitedAmount"];
    fee = json['Fee'];
    rate = json['Rate'];
    transferAmount = json["TransferAmount"];
    transID = json['TransID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ErrorCode'] = this.errorCode;
    data['TransferTo'] = this.transferTo;
    data['DebitedAmount'] = this.totalDebit;
    data['Fee'] = this.fee;
    data['Rate'] = this.rate;
    data['TransferAmount'] = this.transferAmount;
    data['TransID'] = this.transID;
    return data;
  }
}
