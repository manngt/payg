import 'package:gpay/models/transfer/inv_ach_bank.dart';

class InvAchBankList {
  List<InvAchBank>? invAchBanks;

  InvAchBankList({this.invAchBanks});

  InvAchBankList.fromJson(Map<String, dynamic> json) {
    this.invAchBanks = json["Banks"] == null
        ? null
        : (json["Banks"] as List).map((e) => InvAchBank.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.invAchBanks != null) {
      data['Banks'] = this.invAchBanks!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
