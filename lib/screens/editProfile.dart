import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:g2g/components/navigationDrawer.dart';
import 'package:g2g/components/progressDialog.dart';
import 'package:g2g/constants.dart';
import 'package:g2g/controllers/clientController.dart';
import 'package:g2g/models/clientBasicModel.dart';
import 'package:g2g/responsive_ui.dart';
import 'package:g2g/screens/loginScreen.dart';
import 'package:g2g/utility/custom_formbuilder_validators.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:g2g/utility/input_decoration.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class EditProfile extends StatefulWidget {
  ClientBasicModel data;
  EditProfile(this.data);
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _editProfileKey = GlobalKey<ScaffoldState>();

  double _height;
  double _width;
  double _pixelRatio;
  bool _isLarge;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch

    // if failed,use refreshFailed()
    if (mounted) setState(() {});

    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await ClientController().getClientBasic();
    print('check');
    if (mounted) setState(() {});

    _refreshController.loadComplete();
  }

  // @override
  // void initState(){
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((_){
  //     Provider.of<ClientController>(context,listen: false).getClientBasic().then((value) {
  //       data = value;
  //     } );
  //
  //   });
  // }
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _width = MediaQuery.of(context).size.width;
    _isLarge = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    /*final firstNameNode = FocusNode();
    final lastNameNode = FocusNode();
    final emailNode = FocusNode();
    final mobileNoNode = FocusNode();
    final homePhoneNoNode = FocusNode();
    final workPhoneNoNode = FocusNode();
    final streetAddressNode = FocusNode();
    final suburbNode = FocusNode();
    final postCodeNode = FocusNode();*/

    final focusNode = FocusNode();
    print("Name::: ${widget.data?.name} ");
    return Scaffold(
      key: _editProfileKey,
      drawer: NavigationDrawer(),
      // appBar: AppBar(
      //   actions: [
      //     InkWell(
      //         onTap: () {
      //           launch("tel://1300197727");
      //         },
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //           child: Icon(
      //             Icons.call,
      //             size: _isLarge ? 35 : 30,
      //           ),
      //         )),
      //     InkWell(
      //         onTap: () {
      //           Alert(
      //               context: context,
      //               title: 'Are you sure you want to Logout?',
      //               style: AlertStyle(isCloseButton: false,titleStyle: TextStyle(
      //                   color: Colors.black,
      //                   fontWeight: FontWeight.bold,
      //                   fontSize: _isLarge ? 26 : 20)),
      //               buttons: [
      //                 DialogButton(
      //
      //                   child: AutoSizeText(
      //                     "Close",
      //                     style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: _isLarge ? 24 : 18),
      //                   ),
      //                   onPressed: () => Navigator.pop(context),
      //                   color: kSecondaryColor,
      //                   radius: BorderRadius.circular(10.0),
      //                 ),
      //                 DialogButton(
      //                   radius:BorderRadius.circular(10),
      //                   child: AutoSizeText(
      //                     "Logout",
      //                     style: TextStyle(
      //                         color: Colors.white,
      //                         fontSize: _isLarge ? 24 : 18),
      //                   ),
      //                   onPressed: (){
      //                     SharedPreferences.getInstance().then((prefs) {
      //                       prefs.remove('isLoggedIn');
      //                       Navigator.of(context).pushAndRemoveUntil(
      //                           new MaterialPageRoute(
      //                               builder: (BuildContext context) => LoginScreen()),
      //                               (r) => false);
      //                     });
      //                   },
      //                   color: Colors.grey[600],
      //                 ),
      //               ]).show();
      //         },
      //         child: Padding(
      //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //           child: Icon(
      //             Icons.exit_to_app,
      //             size: _isLarge ? 35 : 30,
      //           ),
      //         )),
      //   ],
      //   backgroundColor: Colors.white,
      //   iconTheme: IconThemeData(color: kSecondaryColor, size: 30),
      //   title: AutoSizeText('Edit Profile',
      //       style: TextStyle(
      //           fontSize: _isLarge?28:22,
      //           fontWeight: FontWeight.bold,
      //           color: kSecondaryColor)),
      //   leading: IconButton(
      //     icon: Icon(Icons.menu, color: kSecondaryColor, size: 30),
      //     onPressed: () {
      //       _editProfileKey.currentState.openDrawer();
      //     },
      //   ),
      // ),
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
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              new Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: const AssetImage('images/bg.jpg'),
                        fit: BoxFit.cover)),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: AppBar(
                  centerTitle: true,
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xffccebf2),
                    child: IconButton(
                      onPressed: () {
                        print('abc');
                        _editProfileKey.currentState.openDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: kSecondaryColor,
                        size: _isLarge ? 35 : 30,
                      ),
                    ),
                  ),
                  title: AutoSizeText(
                    'Edit Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: _isLarge ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
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
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.15,
                left: 0.0,
                bottom: 0.0,
                right: 0.0,
                child: SingleChildScrollView(
                  child: Container(
                    padding: _isLarge ? EdgeInsets.all(20) : EdgeInsets.all(10),
                    color: Colors.white,
                    // height: _isLarge ? _height * 0.65 : _height * 1,
                    margin: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4)),
                          elevation: 0,
                          shadowColor: kPrimaryColor,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onPanDown: (_) {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                              },
                              child: FormBuilder(
                                  key: _fbKey,
                                  initialValue: {
                                    'first_name':
                                        splitName(widget.data?.name, '2'),
                                    'last_name':
                                        splitName(widget.data?.name, '1'),
                                    'email': widget.data?.contactMethodEmail,
                                    'mobile_no':
                                        widget.data?.contactMethodMobile,
                                    'home_phone_no':
                                        widget.data?.contactMethodPhoneHome,
                                    'work_phone_no':
                                        widget.data?.contactMethodPhoneWork,
                                    'street_address': widget.data
                                        ?.addressPhysical?.streetAddressFull,
                                    'suburb':
                                        widget.data?.addressPhysical?.suburb,
                                    'post_code':
                                        widget.data?.addressPhysical?.postcode,
                                  },
                                  //enabled: false,
                                  //readOnly: false,
                                  child: Column(
                                    children: [
                                      /*!_isLarge
                                          ? Column(
                                        children: [
                                          SizedBox(
                                            height: 0,
                                          ),
                                          FormBuilderTextField(
                                           // focusNode: firstNameNode,
                                            autofocus: true,
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "first_name",
                                            decoration: buildInputDecoration(
                                                context,
                                                "First Name",
                                                "Enter First Name"),
                                            onFieldSubmitted: (value) {
                                             // lastNameNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            textInputAction:
                                            TextInputAction.next,
                                            keyboardType: TextInputType.text,
                                            validators: [
                                              FormBuilderValidators.min(3),
                                              CustomFormBuilderValidators
                                                  .charOnly(),
                                              FormBuilderValidators.maxLength(
                                                  20),
                                              FormBuilderValidators.required(),
                                              FormBuilderValidators.minLength(
                                                  3),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                           // focusNode: lastNameNode,
                                            onFieldSubmitted: (value) {
                                            //  emailNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            autofocus: true,
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "last_name",
                                            textInputAction:
                                            TextInputAction.next,
                                            decoration: buildInputDecoration(
                                                context,
                                                "Last Name",
                                                "Enter Last Name"),
                                            keyboardType: TextInputType.text,
                                            validators: [
                                              CustomFormBuilderValidators
                                                  .charOnly(),
                                              FormBuilderValidators.minLength(
                                                  3),
                                              FormBuilderValidators.maxLength(
                                                  20),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                            textInputAction:
                                            TextInputAction.next,
                                            //focusNode: emailNode,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                             // mobileNoNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "email",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Email Address",
                                                "Enter Email Address"),
                                            keyboardType:
                                            TextInputType.emailAddress,
                                            validators: [
                                              FormBuilderValidators.email(),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          FormBuilderTextField(
                                           // focusNode: mobileNoNode,
                                            textInputAction:
                                            TextInputAction.next,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                              //homePhoneNoNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "mobile_no",
                                            //  maxLength: 11,
                                            inputFormatters: [
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: buildInputDecoration(
                                                context,
                                                "Mobile Number",
                                                "Enter Mobile Number"),
                                            keyboardType: TextInputType.number,
                                            validators: [
                                              //   FormBuilderValidators.numeric(),
                                              //FormBuilderValidators.minLength(10),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                          //  focusNode: homePhoneNoNode,
                                            textInputAction:
                                            TextInputAction.next,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                             // workPhoneNoNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "home_phone_no",
                                            // maxLength: 15,
                                            decoration: buildInputDecoration(
                                                context,
                                                "Ph Home",
                                                "Phone Number(Home)"),
                                            keyboardType: TextInputType.number,
                                            validators: [
                                              // FormBuilderValidators.minLength(10),
                                              //  FormBuilderValidators.numeric(),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                           // focusNode: workPhoneNoNode,
                                            textInputAction:
                                            TextInputAction.next,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                             // streetAddressNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "work_phone_no",
                                            //  maxLength: 10,
                                            inputFormatters: [
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: buildInputDecoration(
                                                context,
                                                "Ph Work",
                                                "Phone Number(Work)"),
                                            keyboardType: TextInputType.number,
                                            validators: [
                                              // FormBuilderValidators.numeric(),
                                              // FormBuilderValidators.minLength(10),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                            textInputAction:
                                            TextInputAction.next,
                                           // focusNode: streetAddressNode,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                              //suburbNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "street_address",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Address",
                                                "Enter Street Address"),
                                            keyboardType: TextInputType.text,
                                            validators: [
                                              FormBuilderValidators.maxLength(
                                                  50),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          FormBuilderTextField(
                                            textInputAction:
                                            TextInputAction.next,
                                            //focusNode: suburbNode,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                             // postCodeNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "suburb",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Suburb",
                                                "Enter Suburb"),
                                            keyboardType: TextInputType.text,
                                            validators: [
                                              FormBuilderValidators.maxLength(
                                                  50),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                          FormBuilderTextField(
                                            textInputAction:
                                            TextInputAction.done,
                                            //focusNode: postCodeNode,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                               return focusNode.unfocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "post_code",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Postcode",
                                                "Enter PostCode"),
                                            keyboardType: TextInputType.text,
                                            validators: [
                                              FormBuilderValidators.maxLength(
                                                  50),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      )
                                          : Column(
                                        children: [
                                          SizedBox(
                                            height: 0,
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: FormBuilderTextField(
                                                     // focusNode: firstNameNode,
                                                      style: TextStyle(
                                                        color: Color(0xff222222),
                                                        fontFamily: "Montserrat",
                                                      ),
                                                      attribute: "first_name",
                                                      decoration:
                                                      buildInputDecoration(
                                                          context,
                                                          "First Name",
                                                          "Enter First Name"),
                                                      autofocus: true,
                                                      onFieldSubmitted: (value) {
                                                       // lastNameNode.requestFocus();
                                                        return focusNode.nextFocus();
                                                      },
                                                      textInputAction:
                                                      TextInputAction.next,
                                                      keyboardType:
                                                      TextInputType.text,
                                                      validators: [
                                                        FormBuilderValidators.min(3),
                                                        CustomFormBuilderValidators
                                                            .charOnly(),
                                                        FormBuilderValidators
                                                            .maxLength(20),
                                                        FormBuilderValidators
                                                            .required(),
                                                        FormBuilderValidators
                                                            .minLength(3),
                                                      ],
                                                    )),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                    child: FormBuilderTextField(
                                                     // focusNode: lastNameNode,
                                                      autofocus: true,
                                                      onFieldSubmitted: (value) {
                                                       // emailNode.requestFocus();
                                                        return focusNode.nextFocus();
                                                      },
                                                      style: TextStyle(
                                                        color: Color(0xff222222),
                                                        fontFamily: "Montserrat",
                                                      ),
                                                      attribute: "last_name",
                                                      textInputAction:
                                                      TextInputAction.next,
                                                      decoration:
                                                      buildInputDecoration(
                                                          context,
                                                          "Last Name",
                                                          "Enter Last Name"),
                                                      keyboardType:
                                                      TextInputType.text,
                                                      validators: [
                                                        CustomFormBuilderValidators
                                                            .charOnly(),
                                                        FormBuilderValidators
                                                            .minLength(3),
                                                        FormBuilderValidators
                                                            .maxLength(20),
                                                        FormBuilderValidators
                                                            .required()
                                                      ],
                                                    )),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: FormBuilderTextField(
                                                    textInputAction:
                                                    TextInputAction.next,
                                                    //focusNode: emailNode,
                                                    autofocus: true,
                                                    onFieldSubmitted: (value) {
                                                      //mobileNoNode.requestFocus();
                                                      return focusNode.nextFocus();
                                                    },
                                                    style: TextStyle(
                                                      color: Color(0xff222222),
                                                      fontFamily: "Montserrat",
                                                    ),
                                                    attribute: "email",
                                                    decoration:
                                                    buildInputDecoration(
                                                        context,
                                                        "Email Address",
                                                        "Enter Email Address"),
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    validators: [
                                                      FormBuilderValidators
                                                          .email(),
                                                      FormBuilderValidators
                                                          .required()
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: FormBuilderTextField(
                                                    //focusNode: mobileNoNode,
                                                    textInputAction:
                                                    TextInputAction.next,
                                                    autofocus: true,
                                                    onFieldSubmitted: (value) {
                                                    //  homePhoneNoNode.requestFocus();
                                                      return focusNode.nextFocus();
                                                    },
                                                    style: TextStyle(
                                                      color: Color(0xff222222),
                                                      fontFamily: "Montserrat",
                                                    ),
                                                    attribute: "mobile_no",
                                                    maxLength: 11,
                                                    decoration:
                                                    buildInputDecoration(
                                                        context,
                                                        "Mobile Number",
                                                        "Enter Mobile Number"),
                                                    keyboardType:
                                                    TextInputType.number,
                                                    validators: [
                                                      FormBuilderValidators
                                                          .minLength(10),
                                                      FormBuilderValidators
                                                          .required()
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 30),

                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: FormBuilderTextField(
                                                   // focusNode: homePhoneNoNode,
                                                    textInputAction:
                                                    TextInputAction.next,
                                                    autofocus: true,
                                                    onFieldSubmitted: (value) {
                                                     // workPhoneNoNode.requestFocus();
                                                      return focusNode.nextFocus();
                                                    },
                                                    style: TextStyle(
                                                      color: Color(0xff222222),
                                                      fontFamily: "Montserrat",
                                                    ),
                                                    attribute: "home_phone_no",
                                                    maxLength: 15,
                                                    inputFormatters: [
                                                      WhitelistingTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    decoration:
                                                    buildInputDecoration(
                                                        context,
                                                        "Ph Home",
                                                        "Phone Number(Home)"),
                                                    keyboardType:
                                                    TextInputType.number,
                                                    validators: [
                                                      FormBuilderValidators
                                                          .numeric(),
                                                      FormBuilderValidators
                                                          .minLength(10),
                                                      FormBuilderValidators
                                                          .required()
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: FormBuilderTextField(
                                                   // focusNode: workPhoneNoNode,
                                                    textInputAction:
                                                    TextInputAction.next,
                                                    autofocus: true,
                                                    onFieldSubmitted: (value) {
                                                    //  streetAddressNode.requestFocus();
                                                      return focusNode.nextFocus();
                                                    },
                                                    style: TextStyle(
                                                      color: Color(0xff222222),
                                                      fontFamily: "Montserrat",
                                                    ),
                                                    attribute: "work_phone_no",
                                                    maxLength: 10,
                                                    inputFormatters: [
                                                      WhitelistingTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    decoration:
                                                    buildInputDecoration(
                                                        context,
                                                        "Ph Work",
                                                        "Phone Number(Work)"),
                                                    keyboardType:
                                                    TextInputType.number,
                                                    validators: [
                                                      FormBuilderValidators
                                                          .numeric(),
                                                      FormBuilderValidators
                                                          .minLength(10),
                                                      FormBuilderValidators
                                                          .required()
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 30),
                                          FormBuilderTextField(
                                            textInputAction:
                                            TextInputAction.next,
                                            //focusNode: streetAddressNode,
                                            autofocus: true,
                                            onFieldSubmitted: (value) {
                                             // suburbNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            attribute: "street_address",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Address",
                                                "Enter Street Address"),
                                            keyboardType: TextInputType.text,
                                            validators: [
                                              FormBuilderValidators.maxLength(
                                                  50),
                                              FormBuilderValidators.required()
                                            ],
                                          ),
                                          SizedBox(height: 30),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                FormBuilderTextField(
                                                  textInputAction:
                                                  TextInputAction.next,
                                                  //focusNode: suburbNode,
                                                  autofocus: true,
                                                  onFieldSubmitted: (value) {
                                                  //  postCodeNode.requestFocus();
                                                    return focusNode.nextFocus();
                                                  },
                                                  style: TextStyle(
                                                    color: Color(0xff222222),
                                                    fontFamily: "Montserrat",
                                                  ),
                                                  attribute: "suburb",
                                                  decoration:
                                                  buildInputDecoration(
                                                      context,
                                                      "Suburb",
                                                      "Enter Suburb"),
                                                  keyboardType:
                                                  TextInputType.text,
                                                  validators: [
                                                    FormBuilderValidators
                                                        .maxLength(50),
                                                    FormBuilderValidators
                                                        .required()
                                                  ],
                                                ),
                                                FormBuilderTextField(
                                                  textInputAction:
                                                  TextInputAction.done,
                                                 // focusNode: postCodeNode,
                                                  autofocus: true,
                                                  onFieldSubmitted: (value) {
                                                    return focusNode.unfocus();
                                                  },
                                                  style: TextStyle(
                                                    color: Color(0xff222222),
                                                    fontFamily: "Montserrat",
                                                  ),
                                                  attribute: "post_code",
                                                  decoration:
                                                  buildInputDecoration(
                                                      context,
                                                      "Postcode",
                                                      "Enter PostCode"),
                                                  keyboardType:
                                                  TextInputType.text,
                                                  validators: [
                                                    FormBuilderValidators
                                                        .maxLength(50),
                                                    FormBuilderValidators
                                                        .required()
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),*/
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: 0,
                                          ),
                                          FormBuilderTextField(
                                            // focusNode: firstNameNode,
                                            autofocus: true,
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "first_name",
                                            decoration: buildInputDecoration(
                                                context,
                                                "First Name",
                                                "Enter First Name"),
                                            onSubmitted: (value) {
                                              // lastNameNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            textInputAction:
                                                TextInputAction.next,
                                            keyboardType: TextInputType.text,

                                            // validator:
                                            //     FormBuilderValidators.compose([
                                            //   FormBuilderValidators.min(
                                            //       context, 3),
                                            //   CustomFormBuilderValidators
                                            //       .charOnly(),
                                            //   FormBuilderValidators.maxLength(
                                            //       context, 20),
                                            //   FormBuilderValidators.required(
                                            //       context),
                                            //   FormBuilderValidators.minLength(
                                            //       context, 3),
                                            // ]),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                            // focusNode: lastNameNode,
                                            onSubmitted: (value) {
                                              //  emailNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            autofocus: true,
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "last_name",
                                            textInputAction:
                                                TextInputAction.next,
                                            decoration: buildInputDecoration(
                                                context,
                                                "Last Name",
                                                "Enter Last Name"),
                                            keyboardType: TextInputType.text,
                                            validator:
                                                FormBuilderValidators.compose([
                                              CustomFormBuilderValidators
                                                  .charOnly(),
                                              FormBuilderValidators.minLength(
                                                  context, 3),
                                              FormBuilderValidators.maxLength(
                                                  context, 20),
                                              FormBuilderValidators.required(
                                                  context)
                                            ]),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                            textInputAction:
                                                TextInputAction.next,
                                            //focusNode: emailNode,
                                            autofocus: true,
                                            onSubmitted: (value) {
                                              // mobileNoNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "email",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Email Address",
                                                "Enter Email Address"),
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            validator:
                                                FormBuilderValidators.compose([
                                              FormBuilderValidators.email(
                                                  context),
                                              FormBuilderValidators.required(
                                                  context),
                                            ]),

                                            // FormBuilderValidators.required()
                                          ),
                                          SizedBox(height: 20),
                                          FormBuilderTextField(
                                            // focusNode: mobileNoNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofocus: true,
                                            onSubmitted: (value) {
                                              //homePhoneNoNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "mobile_no",
                                            //  maxLength: 11,
                                            inputFormatters: [
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: buildInputDecoration(
                                                context,
                                                "Mobile Number",
                                                "Enter Mobile Number"),
                                            keyboardType: TextInputType.number,
                                            validator:
                                                //   FormBuilderValidators.numeric(),
                                                //FormBuilderValidators.minLength(10),
                                                FormBuilderValidators.required(
                                                    context),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                            //  focusNode: homePhoneNoNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofocus: true,
                                            onSubmitted: (value) {
                                              // workPhoneNoNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "home_phone_no",
                                            // maxLength: 15,
                                            decoration: buildInputDecoration(
                                                context,
                                                "Phone Number(Home)",
                                                "Phone Number(Home)"),
                                            keyboardType: TextInputType.number,
                                            //validators: [
                                            // FormBuilderValidators.minLength(10),
                                            //  FormBuilderValidators.numeric(),
                                            //FormBuilderValidators.required()
                                            //],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                            // focusNode: workPhoneNoNode,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofocus: true,
                                            onSubmitted: (value) {
                                              // streetAddressNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "work_phone_no",
                                            //  maxLength: 10,
                                            inputFormatters: [
                                              WhitelistingTextInputFormatter
                                                  .digitsOnly
                                            ],
                                            decoration: buildInputDecoration(
                                                context,
                                                "Phone Number(Work)",
                                                "Phone Number(Work)"),
                                            keyboardType: TextInputType.number,
                                            //validator: [
                                            // FormBuilderValidators.numeric(),
                                            // FormBuilderValidators.minLength(10),
                                            // FormBuilderValidators.required()
                                            //],
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          FormBuilderTextField(
                                            textInputAction:
                                                TextInputAction.next,
                                            // focusNode: streetAddressNode,
                                            autofocus: true,
                                            onSubmitted: (value) {
                                              //suburbNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "street_address",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Address",
                                                "Enter Street Address"),
                                            keyboardType: TextInputType.text,
                                            validator:
                                                FormBuilderValidators.maxLength(
                                                    context, 50),
                                            // FormBuilderValidators.required()
                                          ),
                                          SizedBox(height: 20),
                                          FormBuilderTextField(
                                            textInputAction:
                                                TextInputAction.next,
                                            //focusNode: suburbNode,
                                            autofocus: true,
                                            onSubmitted: (value) {
                                              // postCodeNode.requestFocus();
                                              return focusNode.nextFocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "suburb",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Suburb",
                                                "Enter Suburb"),
                                            keyboardType: TextInputType.text,
                                            validator:
                                                FormBuilderValidators.maxLength(
                                                    context, 50),
                                            //  FormBuilderValidators.required()
                                          ),
                                          SizedBox(height: 20),
                                          FormBuilderTextField(
                                            textInputAction:
                                                TextInputAction.done,
                                            //focusNode: postCodeNode,
                                            autofocus: true,
                                            onSubmitted: (value) {
                                              return focusNode.unfocus();
                                            },
                                            style: TextStyle(
                                              color: Color(0xff222222),
                                              fontFamily: "Montserrat",
                                            ),
                                            name: "post_code",
                                            decoration: buildInputDecoration(
                                                context,
                                                "Postcode",
                                                "Enter PostCode"),
                                            keyboardType: TextInputType.text,
                                            validator:
                                                FormBuilderValidators.maxLength(
                                                    context, 50),
                                            // FormBuilderValidators.required()
                                          ),
                                          SizedBox(height: 20),
                                        ],
                                      ),
                                      _isLarge
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: FlatButton(
                                                      color: Colors.grey,
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12.0),
                                                        child: AutoSizeText(
                                                            'Back'
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Montserrat',
                                                                fontSize:
                                                                    _isLarge
                                                                        ? 18
                                                                        : 16,
                                                                // fontWeight:
                                                                // FontWeight.bold,
                                                                color: Colors
                                                                    .white)),
                                                      )),
                                                ),
                                                SizedBox(width: 5),
                                                Expanded(
                                                  child: FlatButton(
                                                      color: kSecondaryColor,
                                                      onPressed: () {
                                                        updateProfile();
                                                      },
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            12.0),
                                                        child: AutoSizeText(
                                                            'Update My Profile'
                                                                .toUpperCase(),
                                                            style: TextStyle(
                                                                fontSize:
                                                                    _isLarge
                                                                        ? 18
                                                                        : 16,
                                                                fontFamily:
                                                                    'Montserrat',

                                                                // fontWeight:
                                                                // FontWeight.bold,
                                                                color: Colors
                                                                    .white)),
                                                      )),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                FlatButton(
                                                    color: Colors.grey,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              12.0),
                                                      child: AutoSizeText(
                                                          'Back'.toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: _isLarge
                                                                  ? 18
                                                                  : 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Montserrat',
                                                              color: Colors
                                                                  .black)),
                                                    )),
                                                SizedBox(width: 5),
                                                FlatButton(
                                                    color: kSecondaryColor,
                                                    onPressed: () {
                                                      if (_fbKey.currentState
                                                          .validate()) {
                                                        updateProfile();
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(12.0),
                                                      child: AutoSizeText(
                                                          'Update My Profile'
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontSize: _isLarge
                                                                  ? 18
                                                                  : 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontFamily:
                                                                  'Montserrat',
                                                              color: Colors
                                                                  .white)),
                                                    )),
                                              ],
                                            ),
                                    ],
                                  )),
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
        ),
      ),
    );
  }

  String splitName(String name, flag) {
    List<String> listName = name?.split(', ');
    //print("Listname :${listName[0]}");
    //print("Listname :${listName[1]}");
    //print("Listname :${listName}");
    List<String> list1Name = listName[1]?.split(' ');
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

  removeFocus() {}

  Future<bool> showAlert(List error, var message) {
    Alert(
        context: context,
        title: '',
        content: Container(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  child: Image.asset(error.isEmpty
                      ? 'images/success.png'
                      : 'images/alert_icon.png'),
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
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
              style:
                  TextStyle(color: Colors.white, fontSize: _isLarge ? 24 : 18),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            color: kPrimaryColor,
            radius: BorderRadius.circular(0.0),
          ),
        ],
        style: AlertStyle(
          animationType: AnimationType.fromTop,
          isCloseButton: false,
          isOverlayTapDismiss: false,
          titleStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: _isLarge ? 24 : 18),
        )).show();
  }

  void updateProfile() {
    var pr = ProgressDialog(context);
    if (_fbKey.currentState.saveAndValidate()) {
      print(_fbKey.currentState.value);

      pr.show();
      Provider.of<ClientController>(context, listen: false)
          .postClientBasic(widget.data, _fbKey.currentState.value)
          .then((value) {
        pr.hide();

        /* _editProfileKey.currentState
            .showSnackBar(SnackBar(
          content: AutoSizeText(
              value['message']),
        ));*/
        List error = value['error'];
        showAlert(error, value['message']);
      });
    } else {
      print(_fbKey.currentState.value);
      print('validation failed');
      pr.hide();
    }
  }
}
