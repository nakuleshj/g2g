import 'package:after_layout/after_layout.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:g2g/components/navigationDrawer.dart';
import 'package:g2g/components/progressDialog.dart';
import 'package:g2g/constants.dart';
import 'package:g2g/controllers/accountsController.dart';
import 'package:g2g/controllers/clientController.dart';
import 'package:g2g/controllers/transactionsController.dart';
import 'package:g2g/models/accountModel.dart';
import 'package:g2g/models/clientModel.dart';
import 'package:g2g/responsive_ui.dart';
import 'package:g2g/utility/pref_helper.dart';

import 'package:g2g/screens/apply_now.dart';
import 'package:g2g/screens/loanDocumentsScreen.dart';
import 'package:g2g/screens/transactionScreen.dart';
import 'package:g2g/screens/twakToScreen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin<HomeScreen> {
  final _homeScreenScaffold = GlobalKey<ScaffoldState>();
  double _height;
  double _width;
  double _pixelRatio;
  bool _isLarge;
  final transactionsController = TransactionsController();
  List<Account> accounts;

  int bottomNavIndex = 0;
  Client client;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  PageController pageViewController = PageController();
  var accProvider;

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    accounts = accProvider.getAccountsList();

    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    int flag = ModalRoute.of(context).settings.arguments;
    //print('navFlag' + flag.toString());
    if (flag == 1) {
      bool qoute = isQoute();

      if (qoute) {
        _showDialog();
      }
    }
  }

  List<String> overdueaccount = [];
  bool isOverdue() {
    overdueaccount.clear();
    try {
      for (int i = 0; i < accounts.length; i++) {
        if (accounts[i].status == "Open" &&
            (accounts[i].balanceOverdue) > 0.0) {
          overdueaccount.add('true');
        } else {
          overdueaccount.add('false');
        }
      }
      return overdueaccount.contains('true') ? true : false;
    } catch (error) {
      print(error.toString());
      return false;
    }
  }

  List<String> closedaccount = [];
  bool isElligible() {
    closedaccount.clear();
    //print("LegthL:::${accounts.length}");
    //print(closedaccount);
    for (int i = 0; i < accounts.length; i++) {
      if (accounts[i].status == "Closed") {
        closedaccount.add('true');
      } else {
        closedaccount.add('false');
      }
    }
    print(closedaccount);

    return closedaccount.contains('false') ? false : true;
  }

  List<String> qouteaccount = [];
  bool isQoute() {
    qouteaccount.clear();
    //print("LegthL:::${accounts.length}");
    //print(closedaccount);
    for (int i = 0; i < accounts.length; i++) {
      if (accounts[i].status == "Quote" || accounts[i].status == "Closed") {
        qouteaccount.add('true');
      } else {
        print(accounts[i].status);
        qouteaccount.add('false');
      }
    }
    print(qouteaccount);

    return qouteaccount.contains('false') ? true : false;
  }

  payURL(Account account) async {
    await ClientController().getClientBasic();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var name = account.name;
    List fname = name.split(',');
    //print('fname' + fname[1]);

    try {
      String url =
          'https://www.goodtogoloans.com.au/payments/?fname=${fname[1].toString().trim()}&lname=${fname[0]}&email=${prefs.getString(PrefHelper.PREF_EMAIL_ID)}&account_id=${account.accountId}&client_id=${prefs.getString(PrefHelper.Pref_CLIENT_ID)}'
              .replaceAll(' ', '%20');
      //print(url);
      //   await launch(url);
      await _launchInWebViewWithJavaScript(url);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future<void> _launchInWebViewWithJavaScript(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        enableJavaScript: true,
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showDialog() {
    bool elligible = isElligible();
    print("Elligible:" + elligible.toString());
    bool overdue = isOverdue();
    print("Overdue:" + overdue.toString());
    Alert(
            context: context,
            title: '',
            buttons: [
              DialogButton(
                color: overdue
                    ? Colors.red[600]
                    : elligible
                        ? Colors.green
                        : Colors.amberAccent,
                child: Text(
                  "CLOSE",
                  style: TextStyle(
                      color: Colors.white, fontSize: _isLarge ? 24 : 18),
                ),
                onPressed: () => Navigator.pop(context),
              )
            ],
            content: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                      '${overdue ? 'Hi' : (elligible) ? 'Welcome' : 'Well Done'}' +
                          ', ${client.sessionDetails.fullName.split(' ')[0]}',
                      style: TextStyle(
                          fontSize: _isLarge ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  Text(
                      overdue
                          ? 'Your Account is Overdue'
                          : elligible
                              ? 'You\'re eligible to reapply'
                              : 'You\'re on Track',
                      style: TextStyle(
                          fontSize: _isLarge ? 24 : 18,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  SizedBox(
                    height: _isLarge ? 12 : 8,
                  ),
                  Image.asset(
                    overdue
                        ? 'images/overdue.png'
                        : elligible
                            ? 'images/reapply.png'
                            : 'images/ontrack.png',
                  ),
                ],
              ),
            ),
            style: AlertStyle(
                isCloseButton: false,
                isOverlayTapDismiss: false,
                titleStyle: TextStyle(fontSize: 1)))
        .show();
  }

  void _showMakePaymentDialog() {
    Alert(
            context: context,
            onWillPopActive: true,
            closeIcon: Icon(
              Icons.close,
              color: Colors.black,
            ),
            closeFunction: () {
              Navigator.pop(context);
            },
            title: '',
            buttons: [
              /* DialogButton(
                color: Colors.green,
                child: Text(
                  "Apply Now",
                  style: TextStyle(
                      color: Colors.white, fontSize: _isLarge ? 24 : 18),
                ),
                onPressed: () async {

                },
              )*/
            ],
            content: Padding(
              padding: EdgeInsets.all(8.0),
              child: Container(
                width: _width * 0.7,
                height: _height * 0.6,
                child: WebView(
                  gestureNavigationEnabled: true,
                  initialUrl:
                      'https://www.goodtogoloans.com.au/payment-details.php',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController c) {},
                  onPageStarted: (String url) {
                    if (url.startsWith('tel:')) launch("tel://1300197727");
                  },
                ),
              ),
            ),
            style: AlertStyle(
                isCloseButton: true,
                isOverlayTapDismiss: true,
                titleStyle: TextStyle(fontSize: 1)))
        .show();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _width = MediaQuery.of(context).size.width;
    _isLarge = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);

    accProvider = Provider.of<AccountsController>(context, listen: false);
    var clientProvider = Provider.of<ClientController>(context, listen: false);

    client = clientProvider.getClient();
    accounts = accProvider.getAccountsList();
    for (int i = 0; i < accounts.length; i++) {
      print("Status $i :::${accounts[i].status}");
    }

    return Scaffold(
      key: _homeScreenScaffold,
      drawer: NavigationDrawer(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0, // this will be set when a new tab is tapped
        onTap: (value) => setState(() {
          switch (value) {
            case 0:
              break; // Create this function, it should return your first page as a widget
            case 1:
              // Navigator.pushAndRemoveUntil(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => ApplyNowScreen()),
              //         (r) => r.isFirst);
              _launchInWebViewWithJavaScript(
                  'https://www.goodtogoloans.com.au/');
              break; // Create this function, it should return your second page as a widget
            case 2:
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => TawkToScreen()),
                  (r) => r.isFirst);
              break; // Create this function, it should return your third page as a widget
            // Create this function, it should return your fourth page as a widget
          }
        }),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Container(
              alignment: Alignment.center,
              child: ImageIcon(AssetImage('images/loan.png'),
                  size: _isLarge ? 35 : 24, color: kSecondaryColor),
            ),
            title: Padding(
              padding: const EdgeInsets.all(3.0),
              child: AutoSizeText(
                'My Loans',
                style: TextStyle(
                    fontSize: _isLarge ? 22 : 18,
                    fontFamily: 'Montserrat',
                    color: kSecondaryColor,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Container(
              alignment: Alignment.center,
              child: ImageIcon(AssetImage('images/apply_now.png'),
                  size: _isLarge ? 35 : 24, color: kSecondaryColor),
            ),
            title: Padding(
              padding: const EdgeInsets.all(3.0),
              child: AutoSizeText(
                'Apply Now',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: _isLarge ? 22 : 18,
                  fontWeight: FontWeight.normal,
                  color: kSecondaryColor,
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Container(
              alignment: Alignment.center,
              child: ImageIcon(AssetImage('images/connect.png'),
                  size: _isLarge ? 35 : 24, color: kSecondaryColor),
            ),
            title: Padding(
              padding: const EdgeInsets.all(3.0),
              child: AutoSizeText(
                'Connect',
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: _isLarge ? 22 : 18,
                    color: kSecondaryColor,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: false,
        header: WaterDropHeader(),
        footer: CustomFooter(
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;
            if (mode == LoadStatus.idle) {
              body = AutoSizeText("pull up load");
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();
            } else if (mode == LoadStatus.failed) {
              body = AutoSizeText("Load Failed!Click retry!");
            } else if (mode == LoadStatus.canLoading) {
              body = AutoSizeText("release to load more");
            } else {
              body = AutoSizeText("No more Data");
            }
            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: new Stack(
          children: <Widget>[
            new Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: const AssetImage('images/bg.jpg'),
                      fit: BoxFit.cover)),
            ),
            Padding(
                padding: _isLarge
                    ? const EdgeInsets.all(20)
                    : const EdgeInsets.only(top: 10.0, left: 10, right: 10),
                child: AppBar(
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xffccebf2),
                    child: IconButton(
                      onPressed: () {
                        _homeScreenScaffold.currentState.openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: kSecondaryColor,
                        size: _isLarge ? 35 : 30,
                      ),
                    ),
                  ),
                  title: AutoSizeText(
                      'Hi ${(client.sessionDetails.fullName.split(' ')[0])}',
                      //widget.client.fullName.split(' ')[0]
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  centerTitle: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  actions: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Color(0xffccebf2),
                      child: IconButton(
                        onPressed: () {
                          launch("tel://1300197727");
                        },
                        icon: Icon(
                          Icons.call,
                          color: kSecondaryColor,
                          size: _isLarge ? 35 : 30,
                        ),
                      ),
                    ),
                  ],
                )
                // AppBar(
                //   title: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       CircleAvatar(
                //         radius: 25,
                //         backgroundColor: Color(0xffccebf2),
                //         child: IconButton(
                //           onPressed: () {
                //             _homeScreenScaffold.currentState.openDrawer();
                //           },
                //           icon: Icon(
                //             Icons.menu,
                //             color: kSecondaryColor,
                //             size: 30,
                //           ),
                //         ),
                //       ),
                //       AutoSizeText('Hi ${widget.client.fullName.split(' ')[0]}',
                //           //widget.client.fullName.split(' ')[0]
                //           style: TextStyle(
                //               fontSize: _isLarge ? 28 : 22,
                //               fontWeight: FontWeight.bold,
                //               color: Colors.black)),
                //       CircleAvatar(
                //         radius: 25,
                //         backgroundColor: Color(0xffccebf2),
                //         child: IconButton(
                //           onPressed: () {
                //             launch("tel://1300197727");
                //           },
                //           icon: Icon(
                //             Icons.call,
                //             color: kSecondaryColor,
                //             size: _isLarge ? 35 : 30,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                //   backgroundColor: Colors.transparent,
                //   elevation: 0.0,
                // ),
                ),
            new Positioned(
              top: MediaQuery.of(context).size.height * 0.12,
              left: 0.0,
              bottom: 0.0,
              right: 0.0,
              //here the body
              child: accounts.length > 0
                  ? PageView.builder(
                      controller: pageViewController,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  index > 0
                                      ? FlatButton.icon(
                                          onPressed: () {
                                            pageViewController.jumpToPage(
                                                pageViewController.page
                                                        .toInt() -
                                                    1);
                                          },
                                          icon: Icon(
                                            Icons.keyboard_arrow_left,
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                          label: AutoSizeText(
                                            'Previous Loan',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                        )
                                      : Container(),
                                  index < accounts.length - 1
                                      ? FlatButton.icon(
                                          onPressed: () {
                                            pageViewController.jumpToPage(
                                                pageViewController.page
                                                        .toInt() +
                                                    1);
                                          },
                                          icon: AutoSizeText('Next Loan',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          label: Icon(
                                            Icons.keyboard_arrow_right,
                                            size: 40,
                                            color: Colors.black,
                                          ))
                                      : Container()
                                ],
                              ),
                            ),
                            Expanded(
                                child: buildPage(context, accounts[index])),
                          ],
                        );
                      },
                      itemCount: accounts.length,
                    )
                  : Center(
                      child: Container(
                          margin: const EdgeInsets.all(15.0),
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Theme.of(context).accentColor,
                                  width: 2)),
                          child: Text('No Loan Accounts or\n Quotes found',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).accentColor)))),
            ),
          ],
        ),
      ),
    );
  }

  Widget setUserForm() {
    return new Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex:
            bottomNavIndex, // this will be set when a new tab is tapped
        onTap: (value) => setState(() => bottomNavIndex = value),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Container(
              alignment: Alignment.center,
              child: ImageIcon(AssetImage('images/loan.png'),
                  size: _isLarge ? 28 : 24, color: kSecondaryColor),
            ),
            title: Padding(
              padding: const EdgeInsets.all(3.0),
              child: AutoSizeText(
                'My Loans',
                style: TextStyle(
                  fontSize: _isLarge ? 22 : 18,
                  color: kSecondaryColor,
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Container(
              alignment: Alignment.center,
              child: ImageIcon(AssetImage('images/apply_now.png'),
                  size: _isLarge ? 28 : 24, color: kSecondaryColor),
            ),
            title: Padding(
              padding: const EdgeInsets.all(3.0),
              child: AutoSizeText(
                'Apply Now',
                style: TextStyle(
                  fontSize: _isLarge ? 22 : 18,
                  color: kSecondaryColor,
                ),
              ),
            ),
          ),
          BottomNavigationBarItem(
            icon: Container(
              alignment: Alignment.center,
              child: ImageIcon(AssetImage('images/connect.png'),
                  size: _isLarge ? 28 : 24, color: kSecondaryColor),
            ),
            title: Padding(
              padding: const EdgeInsets.all(3.0),
              child: AutoSizeText(
                'Connect',
                style: TextStyle(
                  fontSize: _isLarge ? 22 : 18,
                  color: kSecondaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: new Stack(
        children: <Widget>[
          // new Container(
          //   decoration: BoxDecoration(
          //       image: DecorationImage(
          //           image: const AssetImage('images/bg.jpg'),
          //           fit: BoxFit.cover)),
          // ),
          Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
            ),
            child: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xffccebf2),
                    child: IconButton(
                      onPressed: () {
                        _homeScreenScaffold.currentState.openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: kSecondaryColor,
                        size: 30,
                      ),
                    ),
                  ),
                  AutoSizeText(
                      'Hi ${client.sessionDetails.fullName.split(' ')[0]}',
                      //widget.client.fullName.split(' ')[0]
                      style: TextStyle(
                          fontSize: _isLarge ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xffccebf2),
                    child: IconButton(
                      onPressed: () {
                        launch("tel://1300197727");
                      },
                      icon: Icon(
                        Icons.call,
                        color: kSecondaryColor,
                        size: _isLarge ? 35 : 30,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
          ),
          new Positioned(
            top: 110.0,
            left: 0.0,
            bottom: 0.0,
            right: 0.0,
            //here the body
            child: PageView.builder(
              physics: BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return buildPage(context, accounts[index]);
              },
              itemCount: accounts.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(BuildContext context, Account account) {
    _height = MediaQuery.of(context).size.height;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _width = MediaQuery.of(context).size.width;
    _isLarge = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);

    return SingleChildScrollView(
      padding: _isLarge ? EdgeInsets.all(20) : EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(children: [
                  Row(children: [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionsScreen(account)));
                                  },
                                  child: AutoSizeText(
                                    account.accountId,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                        color: Colors.green),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TransactionsScreen(account)));
                                  },
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20.0)),
                                      color:
                                          account.status.toUpperCase() == 'OPEN'
                                              ? isOverdue()
                                                  ? Colors.red
                                                  : kPrimaryColor
                                              : (account.status.toUpperCase() ==
                                                      'QUOTE'
                                                  ? Colors.amber[300]
                                                  : Colors.grey),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 8.0, horizontal: 15),
                                        child: AutoSizeText(
                                            account.status.toUpperCase(),
                                            style: TextStyle(
                                                fontSize: _isLarge ? 16 : 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                      )),
                                )
                              ],
                            ),
                            SizedBox(height: 10),
                            AutoSizeText(
                              account.accountTypeDescription,
                              softWrap: true,
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                  color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  !_isLarge
                      ? Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      AutoSizeText(
                                        'Overdue',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black45),
                                        textAlign: TextAlign.start,
                                      ),
                                      Row(
                                        children: [
                                          AutoSizeText(
                                            '${accProvider.formatCurrency(account.balanceOverdue ??= 0.00)}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: account.balanceOverdue !=
                                                        null
                                                    ? (account.balanceOverdue >
                                                            0
                                                        ? Colors.red
                                                        : kPrimaryColor)
                                                    : kSecondaryColor),
                                            textAlign: TextAlign.start,
                                          ),
                                          IconButton(
                                              icon: Icon(
                                                Icons.info_outline,
                                                color: account.balanceOverdue !=
                                                        null
                                                    ? (account.balanceOverdue >
                                                            0
                                                        ? Colors.red
                                                        : kPrimaryColor)
                                                    : kSecondaryColor,
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TransactionsScreen(
                                                                account)));
                                              }),
                                        ],
                                      ),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                  Divider(
                                    color: Colors.black54,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      AutoSizeText(
                                        'Balance',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black45),
                                        textAlign: TextAlign.start,
                                      ),
                                      Row(
                                        children: [
                                          AutoSizeText(
                                            '${accProvider.formatCurrency(account?.balance)}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black),
                                            textAlign: TextAlign.start,
                                          ),
                                          IconButton(
                                              icon: Icon(null),
                                              onPressed: () {}),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  account.balance <= 0
                                      ? Container()
                                      : Container(
                                          alignment: Alignment.centerLeft,
                                          child: InkWell(
                                            onTap: () {
                                              _showMakePaymentDialog();
                                            },
                                            child: Row(
                                              children: [
                                                AutoSizeText(
                                                    'How to make a payment? ',
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            kSecondaryColor)),
                                                // InkWell(
                                                // onTap: (){
                                                //   Navigator.push(
                                                //       context,
                                                //       MaterialPageRoute(
                                                //           builder: (context) =>
                                                //               TransactionsScreen(
                                                //                   account)));
                                                // },
                                                // child:
                                                Icon(
                                                  Icons.info_outlined,
                                                  color: kSecondaryColor,
                                                ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  account.balance <= 0
                                      ? Container()
                                      : FlatButton(
                                          color: kPrimaryColor,
                                          onPressed: () {
                                            payURL(account);
                                          },
                                          child: AutoSizeText(
                                            'Make Additional Payment'
                                            /*+
                                              '${accProvider.formatCurrency(account?.balance)}'*/
                                            ,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                        ),
                                ],
                              )
                            ],
                          ),
                        )
                      : Row(
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AutoSizeText(
                                              'Overdue',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black87,
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            AutoSizeText(
                                              '${accProvider.formatCurrency(account.balanceOverdue ??= 0.00)}',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w600,
                                                  color: kSecondaryColor),
                                              textAlign: TextAlign.start,
                                            ),
                                            IconButton(
                                                icon: Icon(Icons.info_outline,
                                                    color: account
                                                                .balanceOverdue !=
                                                            null
                                                        ? (account.balanceOverdue >
                                                                0
                                                            ? Colors.red
                                                            : kPrimaryColor)
                                                        : kSecondaryColor,
                                                    size: 30),
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TransactionsScreen(
                                                                  account)));
                                                }),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.grey[400],
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            AutoSizeText(
                                              'Balance',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black87,
                                                fontFamily: 'Montserrat',
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            AutoSizeText(
                                              '${accProvider.formatCurrency(account?.balance)}',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black),
                                              textAlign: TextAlign.start,
                                            ),
                                            IconButton(
                                                icon: Icon(null, size: 30),
                                                onPressed: () {}),
                                          ],
                                        )
                                      ],
                                    ),

                                    Divider(
                                      color: Colors.grey[400],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    account.balance <= 0
                                        ? Container()
                                        : Container(
                                            alignment: Alignment.centerLeft,
                                            child: InkWell(
                                              onTap: () {
                                                _showMakePaymentDialog();
                                              },
                                              child: Row(
                                                children: [
                                                  AutoSizeText(
                                                      'How to make a payment? ',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily:
                                                              'Montserrat',
                                                          color:
                                                              kSecondaryColor)),
                                                  Icon(
                                                    Icons.info_outlined,
                                                    size: _isLarge ? 30 : 16,
                                                    color: kSecondaryColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                    SizedBox(
                                      height: 20,
                                    ),

                                    // FlatButton(
                                    //   onPressed: () {},
                                    //   color: kSecondaryColor,
                                    //   child: Padding(
                                    //     padding: EdgeInsets.all(8.0),
                                    //     child: AutoSizeText('How to make a payment?',
                                    //         style: TextStyle(
                                    //             fontSize: _isLarge ? 25 : 20,
                                    //             fontWeight: FontWeight.w600,
                                    //             color: Colors.white)),
                                    //   ),
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    account.balance <= 0
                                        ? Container()
                                        : FlatButton(
                                            color: kPrimaryColor,
                                            onPressed: () {
                                              payURL(account);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.all(15),
                                              child: AutoSizeText(
                                                'Make Additional Payment'
                                                /* +
                                                  '${accProvider.formatCurrency(account.balance)}'*/
                                                ,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 20,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                            ),
                                          ),
                                  ],
                                ))
                          ],
                        )
                ]),
              ),
            ),
          ),
/*
              Container(
                padding: EdgeInsets.all(10),
                child: Card(
                  color: kWhiteColor,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AutoSizeText(
                              'Next Repayment',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink),
                              textAlign: TextAlign.start,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.0),
                              child: AutoSizeText(
                                '\$300.00',
                                style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            AutoSizeText(
                              'By Direct Debit, July 14, 2020',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontFamily: 'OpenSans'),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        Container(
                          child: Column(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                size: 40,
                                color: kSecondaryColor,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              AutoSizeText(
                                'Remind Me',
                                style: TextStyle(
                                    color: kSecondaryColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
*/
          SizedBox(
            width: 10,
          ),
          //Expansion Tiles
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isLarge ? 15.0 : 20,
                    ),
                    child: Theme(
                      data: ThemeData(
                          dividerColor: Colors.transparent,
                          accentColor: Colors.black),
                      child: _isLarge
                          ? ExpansionTile(
                              leading: ImageIcon(AssetImage('images/loan.png'),
                                  size: _isLarge ? 30 : 24,
                                  color: kSecondaryColor),
                              initiallyExpanded: true,
                              title: Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: AutoSizeText(
                                  'Loan Details',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Montserrat',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(_isLarge ? 20 : 10.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                buildLoanDetail('Account ID',
                                                    account.accountId),
                                                SizedBox(
                                                    height: _isLarge ? 30 : 15),
                                                buildLoanDetail(
                                                    'Maturity Date',
                                                    DateFormat('dd-MM-yy')
                                                        .format(DateTime.parse(
                                                            account
                                                                .dateMaturity))),
                                              ],
                                            ),
                                            Column(
                                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                buildLoanDetail(
                                                    'Open Date',
                                                    DateFormat('dd-MM-yy')
                                                        .format(DateTime.parse(
                                                            account
                                                                .dateOpened))),
                                                SizedBox(
                                                    height: _isLarge ? 30 : 15),
                                                buildLoanDetail(
                                                    'Loan Amount',
                                                    accProvider.formatCurrency(
                                                        account
                                                            ?.balanceOpening))
                                                //SizedBox(height: _isLarge ? 30 : 15),
                                                // buildLoanDetail('Payments Remaining', '20'),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          : ExpansionTile(
                              leading: ImageIcon(AssetImage('images/loan.png'),
                                  size: _isLarge ? 30 : 24,
                                  color: kSecondaryColor),
                              initiallyExpanded: true,
                              title: AutoSizeText(
                                'Loan Details'
                                '',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Montserrat',
                                  fontSize: 20,
                                  color: Colors.black,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          buildLoanDetail(
                                              'Account ID', account.accountId),
                                          SizedBox(height: _isLarge ? 30 : 15),
                                          buildLoanDetail(
                                              'Maturity Date',
                                              DateFormat('dd-MM-yy').format(
                                                  DateTime.parse(
                                                      account.dateMaturity))),
                                        ],
                                      ),
                                      Column(
                                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          buildLoanDetail(
                                              'Open Date',
                                              DateFormat('dd-MM-yy').format(
                                                  DateTime.parse(
                                                      account.dateOpened))),
                                          SizedBox(height: _isLarge ? 30 : 15),
                                          buildLoanDetail(
                                              'Loan Amount',
                                              accProvider.formatCurrency(
                                                  account?.balanceOpening))
                                          //SizedBox(height: _isLarge ? 30 : 15),
                                          // buildLoanDetail('Payments Remaining', '20'),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                    ),
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isLarge ? 15.0 : 20,
                      vertical: 5,
                    ),
                    child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      LoanDocuments(account)));
                        },
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                          size: _isLarge ? 32 : 24,
                        ),
                        leading: ImageIcon(AssetImage('images/documents.png'),
                            size: _isLarge ? 30 : 24, color: kSecondaryColor),
                        title: AutoSizeText('Loan Documents',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontFamily: 'Montserrat',
                            ))),
                  ),
                ),
              ),
              Divider(
                color: Colors.grey,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isLarge ? 15.0 : 20,
                      vertical: 5,
                    ),
                    child: ListTile(
                      onTap: () async {
                        // print(account.balance.toString());
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    TransactionsScreen(account)));
                      },
                      leading: ImageIcon(
                        AssetImage('images/transaction.png'),
                        size: _isLarge ? 30 : 24,
                        color: kSecondaryColor,
                      ),
                      title: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: AutoSizeText('Transactions',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            )),
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_right,
                        size: _isLarge ? 32 : 24,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column buildLoanDetail(String title, String data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          data,
          style: TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
              color: Colors.black54),
          textAlign: TextAlign.start,
        ),
        AutoSizeText(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
              color: kSecondaryColor),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
