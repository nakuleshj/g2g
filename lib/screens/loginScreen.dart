import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:g2g/components/progressDialog.dart';
import 'package:g2g/constants.dart';
import 'package:g2g/controllers/accountsController.dart';
import 'package:g2g/controllers/clientController.dart';
import 'package:g2g/models/clientModel.dart';
import 'package:g2g/responsive_ui.dart';
import 'package:g2g/screens/applyNow_CalcScreen.dart';
import 'package:g2g/screens/homeScreen.dart';
import 'package:g2g/screens/resetPassword.dart';
import 'package:g2g/screens/updatePasswordScreen.dart';
import 'package:g2g/utility/hashSha256.dart';
import 'package:g2g/utility/pref_helper.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final clientID = TextEditingController();
  final password = TextEditingController();

  bool _autoValidate = false;
  AnimationController animationController;
  Animation animation;
  final userIDNode = FocusNode();
  final pwdNode = FocusNode();
  double _height;
  double _width;
  double _pixelRatio;
  bool _isLarge;
  bool _loading = false;
  bool _obscurePass = true;

  @override
  void initState() {
    super.initState();
    tripleDES();
    // animationController =
    //     AnimationController(vsync: this, duration: Duration(seconds: 1));
    // animation =
    //     CurvedAnimation(parent: animationController, curve: Curves.bounceIn);
    // animationController.forward();
    // animationController.addListener(() {
    //   setState(() {});
    //   // print(animationController.value);
    // });
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _width = MediaQuery.of(context).size.width;
    _isLarge = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    print('Pixel ' + _pixelRatio.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/bg.jpg'), fit: BoxFit.cover)),
            child: SafeArea(child: GestureDetector(
              onPanDown: (_) {
                FocusScope.of(context).requestFocus(FocusNode());
              },
            )),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      child: Container(
                        height: 100,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Image.asset(
                              _isLarge
                                  ? 'images/fulllogo.png'
                                  : 'images/logobig.png',
                              height: _isLarge ? 200 : 150,
                              width: _isLarge ? 500 : 150,
                              fit: BoxFit.fitWidth,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AutoSizeText(
                                    'Log in to your account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 28,
                                      color: Colors.black,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Form(
                                    autovalidate: _autoValidate,
                                    key: _loginFormKey,
                                    child: Card(
                                      elevation: 0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          buildEmailFormField(
                                              Icons.person_outline,
                                              clientID,
                                              'Email/Username',
                                              userIDNode,
                                              pwdNode),
                                          SizedBox(height: 15),
                                          buildPasswordFormField(
                                              Icons.lock,
                                              password,
                                              'Password',
                                              pwdNode,
                                              null,
                                              obscureText: true),
                                          SizedBox(height: 40),
                                          Container(
                                            child: RaisedButton(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 16),
                                              child: AutoSizeText(
                                                'Login'.toUpperCase(),
                                                style: TextStyle(
                                                    fontSize:
                                                        _isLarge ? 26 : 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'Montserrat',
                                                    color: Colors.white),
                                              ),
                                              color: kPrimaryColor,
                                              // padding: EdgeInsets.only(
                                              //     top: 15, bottom: 15, left: 15, right: 15),
                                              onPressed: () async {
                                                print('Pass ' +
                                                    getEncryptPassword(password
                                                        .text
                                                        .toString()));
                                                if (_loginFormKey.currentState
                                                    .validate()) {
                                                  final pr = ProgressDialog(
                                                      context,
                                                      isLogin: true);
                                                  setState(() {
                                                    pr.show();
                                                  });

                                                  Provider.of<ClientController>(
                                                          context,
                                                          listen: false)
                                                      .authenticateUser()
                                                      .then((value) async {
                                                    if (value == null) {
                                                      Scaffold.of(context)
                                                          .showSnackBar(
                                                              SnackBar(
                                                        content: AutoSizeText(
                                                            'Something went wrong please try again!'),
                                                      ));
                                                      return;
                                                    }
                                                    Provider.of<ClientController>(
                                                            context,
                                                            listen: false)
                                                        .authenticateClient(
                                                            clientID.text,
                                                            password.text,
                                                            false)
                                                        .then(
                                                      (user) async {
                                                        if (user.runtimeType !=
                                                            Client) {
                                                          var message =
                                                              'Invalid Password or Your account is temporarily locked!\n\nPlease try again.';
                                                          if (user
                                                              .toString()
                                                              .startsWith(
                                                                  'Client with web user Id of'))
                                                            message =
                                                                'Username not found!';
                                                          else if (user
                                                              .toString()
                                                              .startsWith(
                                                                  'Invalid Password'))
                                                            message =
                                                                'Invalid Password';

                                                          pr.hide();
                                                          Alert(
                                                              context: context,
                                                              title: '',
                                                              content:
                                                                  Container(
                                                                child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                      Image.asset(
                                                                          'images/alert_icon.png'),
                                                                      SizedBox(
                                                                          height:
                                                                              20),
                                                                      Container(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 8),
                                                                        child:
                                                                            Text(
                                                                          message,
                                                                          style: TextStyle(
                                                                              color: Colors.black45,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 20),
                                                                        ),
                                                                      ),
                                                                    ]),
                                                              ),
                                                              buttons: [
                                                                DialogButton(
                                                                  child: Text(
                                                                    "Close",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize: _isLarge
                                                                            ? 24
                                                                            : 18),
                                                                  ),
                                                                  onPressed: () =>
                                                                      Navigator.pop(
                                                                          context),
                                                                  color:
                                                                      kPrimaryColor,
                                                                  radius: BorderRadius
                                                                      .circular(
                                                                          0.0),
                                                                ),
                                                              ],
                                                              style: AlertStyle(
                                                                animationType:
                                                                    AnimationType
                                                                        .fromTop,
                                                                isCloseButton:
                                                                    false,
                                                                isOverlayTapDismiss:
                                                                    false,
                                                                titleStyle: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        _isLarge
                                                                            ? 24
                                                                            : 18),
                                                              )).show();
                                                        } else {
                                                          Client client =
                                                              user as Client;
                                                          SharedPreferences
                                                              prefs =
                                                              await SharedPreferences
                                                                  .getInstance();
                                                          //Return String

                                                          print('Check ' +
                                                              prefs
                                                                  .getString(
                                                                      PrefHelper
                                                                          .PREF_FORCE_PASSWORD)
                                                                  .toString());
                                                          bool fpscreen = prefs
                                                                      .getString(
                                                                          PrefHelper
                                                                              .PREF_FORCE_PASSWORD)
                                                                      .toString() ==
                                                                  'true'
                                                              ? true
                                                              : false;
                                                          print('Checl=k 2' +
                                                              fpscreen
                                                                  .toString());
                                                          Provider.of<AccountsController>(
                                                                  context,
                                                                  listen: false)
                                                              .getAccounts(
                                                                  client
                                                                      .clientId,
                                                                  client
                                                                      .sessionDetails
                                                                      .sessionToken)
                                                              .then((accounts) {
                                                            pr.hide();
                                                            !fpscreen
                                                                ? Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => HomeScreen(),
                                                                        settings: RouteSettings(
                                                                          arguments:
                                                                              1,
                                                                        )),
                                                                    (route) => false)
                                                                : Navigator.pushAndRemoveUntil(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder: (context) => UpdatePassword(),
                                                                        settings: RouteSettings(
                                                                          arguments:
                                                                              client?.forcePasswordChange,
                                                                        )),
                                                                    (route) => false);
                                                          });
                                                        }
                                                      },
                                                    );
                                                  });
                                                } else {
                                                  setState(() {
                                                    _autoValidate = true;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                //SizedBox(height: 4),
                                FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                ResetPassword()));
                                  },
                                  child: AutoSizeText(
                                    'Forgot Password?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.grey,
                                        decoration: TextDecoration.underline,
                                        fontSize: 20),
                                  ),
                                ),
                                SizedBox(height: 4),

                                Container(
                                  margin: EdgeInsets.all(_isLarge ? 10 : 5),
                                  padding: EdgeInsets.all(_isLarge ? 15 : 10),
                                  color: Colors.grey.shade300,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: AutoSizeText(
                                            'Are you a new Customer?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ApplyNowForLoan()));
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: _isLarge ? 4 : 0),
                                              decoration: BoxDecoration(
                                                // borderRadius: BorderRadius.all(Radius.circular(15)),
                                                color: Color(0xFF17477A),
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: _isLarge ? 10 : 5,
                                                  vertical: _isLarge ? 16 : 10),
                                              child: AutoSizeText(
                                                'Apply Now'.toUpperCase(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                  // letterSpacing: 1.0,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildEmailFormField(IconData icon, TextEditingController controller,
      String labelText, FocusNode fNode, FocusNode nextNode,
      {bool obscureText = false}) {
    return Container(
      child: TextFormField(
        cursorColor: kPrimaryColor,
        inputFormatters: [
          LowerCaseTextFormatter(),
        ],

        validator: (value) {
          if (value.isEmpty) return 'Email ID/Username Required';
          return null;
        },
        textInputAction:
            nextNode != null ? TextInputAction.next : TextInputAction.done,
        // textCapitalization: obscureText
        //     ? TextCapitalization.sentences
        //     : TextCapitalization.characters,
        obscureText: false,
        focusNode: fNode,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            prefixIcon:
                Icon(icon, color: kPrimaryColor, size: _isLarge ? 30 : 24),
            hintText: labelText,
            hintStyle:
                TextStyle(fontSize: _isLarge ? 24 : 18, color: Colors.black54)),
        style: TextStyle(
          fontSize: _isLarge ? 24 : 18,
          color: Colors.black,
        ),
        onFieldSubmitted: (value) {
          if (nextNode != null) nextNode.requestFocus();
        },
        controller: controller,
      ),
    );
  }

  Widget buildPasswordFormField(IconData icon, TextEditingController controller,
      String labelText, FocusNode fNode, FocusNode nextNode,
      {bool obscureText = false}) {
    return Container(
      child: TextFormField(
        cursorColor: kPrimaryColor,
        inputFormatters: null,

        validator: (value) {
          if (value.isEmpty) return 'Password Required';
          return null;
        },
        textInputAction:
            nextNode != null ? TextInputAction.next : TextInputAction.done,
        // textCapitalization: obscureText
        //     ? TextCapitalization.sentences
        //     : TextCapitalization.characters,
        obscureText: _obscurePass,
        focusNode: fNode,
        decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black54),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            prefixIcon:
                Icon(icon, color: kPrimaryColor, size: _isLarge ? 30 : 24),
            suffixIcon: IconButton(
              icon: Icon(
                // Based on passwordVisible state choose the icon
                _obscurePass ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscurePass = !_obscurePass;
                });
              },
            ),
            hintText: labelText,
            hintStyle:
                TextStyle(fontSize: _isLarge ? 24 : 18, color: Colors.black54)),
        style: TextStyle(
          fontSize: _isLarge ? 24 : 18,
          color: Colors.black,
        ),
        onFieldSubmitted: (value) {
          if (nextNode != null) nextNode.requestFocus();
        },
        controller: controller,
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
