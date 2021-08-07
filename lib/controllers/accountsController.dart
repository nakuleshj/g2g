import 'dart:convert';

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import 'package:g2g/constants.dart';
import 'package:g2g/models/accountModel.dart';
import 'package:g2g/utility/pref_helper.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountsController with ChangeNotifier {
  List<Account> _accounts = [];

  Future<List<Account>> getAccounts(
      String clientID, String sessionToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    http.Response response = await http.get(
        '$apiBaseURL/Client/GetAccounts?clientId=$clientID&includeQuote=true&includeOpen=true&includeClosed=true',
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'AuthFinWs token="${prefs.getString(PrefHelper.PREF_AUTH_TOKEN)}"'
        });
    //print(clientID);
    //print('$apiBaseURL/Client/GetAccounts?clientId=$clientID&includeQuote=true&includeOpen=true&includeClosed=true');
    //print(response.body);

    /* for (Map m in jsonDecode(response.body)) {
      prefs.setDouble(PrefHelper.PREF_ACCOUNT_BALANCE, m['Balance']);
      prefs.setString(PrefHelper.PREF_ACCOUNT_ID, m['AccountId'].toString());
    }*/
    List<dynamic> m = jsonDecode(response.body);
    _accounts.clear();
    m.forEach((account) {
      _accounts.add(Account.fromJson(account));
    });
    _accounts.where((account) => account.status == 'Open').toList();
    _accounts.where((account) => account.status == 'Quote').toList();
    _accounts.where((account) => account.status == 'Closed').toList();

    /*for (Map m in jsonDecode(response.body))
      if (m['Status'] == 'Open')
        _accounts.add(Account.fromJson(m));
      else if (m['Status'] == 'Quote')
        _accounts.add(Account.fromJson(m));
      else if (m['Status'] == 'Closed') _accounts.add(Account.fromJson(m));*/
    notifyListeners();
    return _accounts;
  }

  List<Account> getAccountsList() {
    print(_accounts.length);
    _accounts.sort((a, b) => -a.dateOpened.compareTo(b.dateOpened));
    // _accounts.forEach((element) {
    //   // print('Dates sorted new to last : '+element.openedDate.toString());
    //   // print('Account Status : '+element.status.toString());
    //   // print('Balance OverDue : '+element.balanceOverdue.toString());

    //   print('Check ' +
    //       //element.dateOpened.toString() +
    //       //' ' +
    //       element.status.toString() +
    //       ' ' +
    //       element.balanceOverdue.toString());
    //   // print('Balance OverDue : '+element.balanceOverdue.runtimeType.toString());
    // });

    return _accounts;
  }

  String formatCurrency(double price) {
    var dollarsInUSFormat =
        new NumberFormat.currency(locale: "en_US", symbol: "\$");

    var resultPrice = '0';
    if (price != null) {
      resultPrice = dollarsInUSFormat.format(double.tryParse(price.toString()));
    }
    return resultPrice;
  }
}
