import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:g2g/constants.dart';
import 'package:g2g/models/clientBasicModel.dart';
import 'package:g2g/models/clientModel.dart';
import 'package:g2g/utility/hashSha256.dart';
import 'package:g2g/utility/pref_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml2json/xml2json.dart';

class ClientController with ChangeNotifier {
  Client client;
  String clientName = '';
  String clientId = '';
  ClientBasicModel clientBasicModel;
  var forcePassword;

  Future<String> authenticateUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userID = 'WEBSERVICES';
    var password = 'G2GW3bs3rv1c35';
    Map hashAndSalt = hashSHA256();
    var postbodyMap = {
      "subscriberId": subscriberID,
      "userId": userID,
      "password": password,
      "hash": hashAndSalt['hash'],
      "hashSalt": hashAndSalt['salt']
    };
    http.Response response =
        await http.post('$apiBaseURL/Authentication/AuthenticateUser',
            headers: <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(postbodyMap));
    print(response.body);
    var webUserResponse = jsonDecode(response.body);
    if (webUserResponse['SessionToken'] != null) {
      prefs.setString(
          PrefHelper.PREF_AUTH_TOKEN, webUserResponse['SessionToken']);

      // prefs.setString('user', response.body);
      return webUserResponse['SessionToken'];
    } else if (webUserResponse["Code"] == "Subscriber.InvalidHash") {
      return await authenticateUser();
    }
    return null;
  }

  Future<dynamic> authenticateClient(
      String clientID, String password, bool isWebAuthenticated) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final storage = new FlutterSecureStorage();
    String ePass = isWebAuthenticated ? password : getEncryptPassword(password);
    String envelope =
        '<ClientAuthentication>\r\n<UserID>$clientID<\/UserID>\r\n<Password>$ePass<\/Password>\r\n<\/ClientAuthentication>';
    print('clientLogin_envelope' + envelope);
    print('clientLogin_url' + '$apiBaseURL/custom/ClientLogin');

    http.Response response = await http.post(
      '$apiBaseURL/custom/ClientLogin',
      headers: <String, String>{
        'Content-Type': 'text/xml',
        'Authorization':
            'AuthFinWs token="${prefs.getString(PrefHelper.PREF_AUTH_TOKEN)}"'
      },
      body: envelope,
    );
    print(response.body);
    final myTransformer = Xml2Json();
    myTransformer.parse(response.body);
    var json = myTransformer.toParker();
    print(json);
    var decodedJson = jsonDecode(json);
    forcePassword = decodedJson['ClientAuthentication']['ForcePasswordChange'];
    print('Force' +
        forcePassword.toString() +
        forcePassword.runtimeType.toString());
    var innerJson = jsonDecode(json)['ClientAuthentication']['SessionDetails'];
    print(innerJson);
    // print(response.body);
    // var _document = xml.parse(response.body);
    // var innerJson = "";
    // Iterable<xml.XmlElement> items =
    //     _document.findAllElements('ClientAuthentication');
    // items.map((xml.XmlElement item) {
    //   innerJson = _getValue(item.findElements("SessionDetails"));
    // }).toList();
    if (jsonDecode(json)['ClientAuthentication']['SessionError'] != null) {
      return jsonDecode(json)['ClientAuthentication']['SessionError'];
      // return await authenticateClient(clientID, password, isWebAuthenticated);
      //  CustomDialog.showMyDialog(context, 'ClientLogin', jsonDecode(json)['ClientAuthentication']['SessionError'], 'Retry', authenticateClient(context,clientID, password, isWebAuthenticated));
    } else if (innerJson['SessionToken'] != null) {
      prefs.setBool('isLoggedIn', true);
      prefs.setString(PrefHelper.PREF_USER_ID, clientID);
      prefs.setString(PrefHelper.Pref_CLIENT_ID, innerJson['ClientId']);
      prefs.setString(PrefHelper.PREF_SESSION_TOKEN, innerJson['SessionToken']);
      //prefs.setString(PrefHelper.PREF_PASSWORD, ePass);
      prefs.setString(PrefHelper.PREF_FULLNAME, innerJson['FullName']);
      await storage.write(key: PrefHelper.PREF_PASSWORD, value: ePass);
      if (forcePassword == 'true') {
        prefs.setString(
            PrefHelper.PREF_FORCE_PASSWORD, forcePassword.toString());

        print('$forcePassword true');
        prefs.getString(PrefHelper.PREF_FORCE_PASSWORD);
        print('key ' +
            prefs.getString(PrefHelper.PREF_FORCE_PASSWORD).toString());
      }
      // prefs.setString('user', response.body);
      client = Client.fromJson(jsonDecode(json)['ClientAuthentication']);

      notifyListeners();
      return client;
    } else if (jsonDecode(response.body)["Code"] == "Subscriber.InvalidHash") {
      // return await authenticateClient(clientID, ePass, isWebAuthenticated);
      return null;
    } else {
      return null;
    }
  }

  Future<ClientBasicModel> getClientBasic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(
        '$apiBaseURL/Client/GetClientBasic?clientId=${prefs.getString(PrefHelper.Pref_CLIENT_ID)}');
    print(
        'AuthFinWs token="${prefs.getString(PrefHelper.PREF_SESSION_TOKEN)}"');
    http.Response response = await http.get(
        '$apiBaseURL/Client/GetClientBasic?clientId=${prefs.getString(PrefHelper.Pref_CLIENT_ID)}',
        headers: {
          'Content-Type': 'application/json',
          HttpHeaders.authorizationHeader:
              'AuthFinWs token="${prefs.getString(PrefHelper.PREF_SESSION_TOKEN)}"'
        });
    print(response.body);
    prefs.setString(PrefHelper.PREF_EMAIL_ID,
        jsonDecode(response.body)['ContactMethodEmail']);
    print('link' +
        '$apiBaseURL/Client/GetClientBasic?clientId=${prefs.getString('clientID')}');
    try {
      clientBasicModel = ClientBasicModel.fromJson(jsonDecode(response.body));
    } catch (error) {
      print(error.toString());
    }
    notifyListeners();
    return clientBasicModel;
  }

  String splitName(String name, flag) {
    List<String> listName = name?.split(', ');
    //print("Listname :${listName[0]}");
    //print("Listname :${listName[1]}");
    //print("Listname :${listName}");
    //List<String> list1Name = listName[1]?.split(' ');
    //print("List1Name :${list1Name}");

    if (listName != null) {
      switch (flag) {
        case '1':
          //print("Case1");
          //print(listName[listName?.length - 2].replaceAll(',', ''));
          return listName[0];
          break;
        case '2':
          //print("Case2");
          //print(listName[0].replaceAll(',', ''));
          return listName[1];
          break;
      }
    }
  }

  Future<Map> postClientBasic(
      ClientBasicModel oldData, Map<String, dynamic> data) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // print('inputFormBody' +
    //     json.encode(
    //       {
    //         "old_fName": splitName(oldData?.name, '1'),
    //         "old_lName": splitName(oldData?.name, '2'),
    //         "old_ContactMethodEmail": oldData.contactMethodEmail,
    //         "old_ContactMethodMobile": oldData.contactMethodMobile,
    //         "old_ContactMethodPhoneHome": oldData.contactMethodPhoneHome,
    //         "old_ContactMethodPhoneWork": oldData.contactMethodPhoneWork,
    //         "old_StreetAddressFull":
    //             oldData?.addressPhysical?.streetAddressFull,
    //         "old_Suburb": oldData?.addressPhysical?.suburb,
    //         "old_Postcode": oldData?.addressPhysical?.postcode,
    //         "fName": data["first_name"],
    //         "lName": data["last_name"],
    //         "ContactMethodEmail": data["email"],
    //         "ContactMethodMobile": data["mobile_no"],
    //         "ContactMethodPhoneHome": data["home_phone_no"],
    //         "ContactMethodPhoneWork": data["work_phone_no"],
    //         "StreetAddressFull": data["street_address"],
    //         "Suburb": data["suburb"],
    //         "Postcode": data["post_code"]
    //       },
    //     ));
    String fName = splitName(oldData?.name, '2');
    String lName = splitName(oldData?.name, '1');
    print("Fname: $fName");
    print("Lname: $lName");
    print("Lname: ${data['last_name']}");
    Map<String, dynamic> bodyMap = {
      "old_fName": fName,
      "old_lName": lName,
      "old_ContactMethodEmail": oldData.contactMethodEmail ?? '',
      "old_ContactMethodMobile": oldData.contactMethodMobile ?? '',
      "old_ContactMethodPhoneHome": oldData.contactMethodPhoneHome ?? '',
      "old_ContactMethodPhoneWork": oldData.contactMethodPhoneWork ?? '',
      "old_StreetAddressFull":
          oldData?.addressPhysical?.streetAddressFull ?? '',
      "old_Suburb": oldData?.addressPhysical?.suburb ?? '',
      "old_Postcode": oldData?.addressPhysical?.postcode ?? '',
      "fName": data["first_name"] ?? '',
      "lName": data["last_name"] ?? '',
      "ContactMethodEmail": data["email"] ?? '',
      "ContactMethodMobile": data["mobile_no"] ?? '',
      "ContactMethodPhoneHome": data["home_phone_no"] ?? '',
      "ContactMethodPhoneWork": data["work_phone_no"] ?? '',
      "StreetAddressFull": data["street_address"] ?? '',
      "Suburb": data["suburb"] ?? '',
      "Postcode": data["post_code"] ?? ''
    };

    //print(jsonEncode(bodyMap));
    print('https://www.goodtogoloans.com.au/crons/mobile_app_email.php');
    try {
      /*var request = http.Request('POST', Uri.parse('https://www.goodtogoloans.com.au/crons/mobile_app_email.php'));
      request.bodyFields = bodyMap;

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        return jsonDecode(await response.stream.bytesToString());
      }
      else {
        print(response.reasonPhrase);
      }*/
      http.Response response = await http.post(
          'https://www.goodtogoloans.com.au/crons/mobile_app_email.php',
          headers: {
            'Accept': '*/*',
          },
          encoding: Encoding.getByName("utf-8"),
          body: bodyMap);

      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchClientDetailsSP() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    clientName = prefs.getString(PrefHelper.PREF_FULLNAME);
    clientId = prefs.getString(PrefHelper.Pref_CLIENT_ID);
  }

  Client getClient() {
    return client;
  }

  String get getClientName {
    return clientName;
  }

  String get getClientId {
    return clientId;
  }
}
