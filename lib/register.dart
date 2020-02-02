import 'package:ccs/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: camel_case_types
class register extends StatefulWidget {
  register({Key key, this.title}) : super(key: key);

  final String title;


  @override
  _registerstate createState() => new _registerstate();
}

// ignore: camel_case_types
class _registerstate extends State<register> {
  final db=Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;
  TextEditingController _name = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _password = new TextEditingController();
  TextEditingController _conpassword = new TextEditingController();
  TextEditingController _phone = new TextEditingController();
  TextEditingController _addl1 = new TextEditingController();
  TextEditingController _addl2 = new TextEditingController();
  TextEditingController _city = new TextEditingController();
  TextEditingController _state = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhone() async {
    Toast.show("OTP has been sent to your registered number. Please Wait...\n\nIf you don't receive otp, you have been blocked by our server for multiple logins in a day. Please try again after 24 hours", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      smsOTPDialog(context).then((value) {
        print('sign in');
      });
    };
    try {
      await _auth.verifyPhoneNumber(
          phoneNumber: this.phoneNo, // PHONE NUMBER TO SEND OTP
          codeAutoRetrievalTimeout: (String verId) {
            //Starts the phone number verification process for the given phone number.
            //Either sends an SMS with a 6 digit code to the phone number specified, or sign's the user in and [verificationCompleted] is called.
            this.verificationId = verId;
          },
          codeSent: smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
          timeout: const Duration(seconds: 20),
          verificationCompleted: (AuthCredential phoneAuthCredential) {
            print(phoneAuthCredential);
          },
          verificationFailed: (AuthException exceptio) {
            print('${exceptio.message}');
          });
    } catch (e) {
      handleError(e);
    }
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(15)),
            title: Text('Enter OTP',style: TextStyle(color: Colors.blue)),
            content: Container(
              padding: const EdgeInsets.only(left:15.0,right: 15),
              height: 85,
              child: Column(children: [
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 10),),
                (errorMessage != '' ? Text(errorMessage, style: TextStyle(color: Colors.red),) : Container())
              ]),
            ),
            contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                child: Text('Done'),
                onPressed: () {
                  _auth.currentUser().then((user) async {
                    if (user != null) {
                      Map<String,dynamic> data = <String,dynamic>{
                        "Account Type": 'User',
                        "Name": _name.text,
                        "Email Id": _email.text,
                        "Password": _password.text,
                        "Phone Number": _phone.text,
                        "Registered On": Timestamp.now(),
                      };
                      await db.collection("Users").document(_email.text).setData(data).whenComplete(() {
                        print("Form Added");
                      }).catchError((e) => print(e));
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/loginpage');
                      Toast.show("You have successfully signed in", context, duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                      FirebaseAuth.instance.signOut();
                    } else {
                      signIn();
                    }
                  });
                },
              )
            ],
          );
        });
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verificationId,
        smsCode: smsOTP,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      Map<String,dynamic> data = <String,dynamic>{
        "Name": _name.text,
        "Email Id": _email.text,
        "Password": _password.text,
        "Phone Number": _phone.text,
        "Address": _addl1.text +" "+ _addl2.text,
        "City": _city.text,
        "State": _state.text,
        "Registered On": Timestamp.now(),
      };
      await db.collection("Users").document(_email.text).setData(data).whenComplete(() {
        print("Form Added");
      }).catchError((e) => print(e));
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/loginpage');
      Toast.show("You have successfully registered", context, duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
      FirebaseAuth.instance.signOut();
    } catch (e) {
      handleError(e);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'Invalid OTP';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      case 'We have blocked all requests from this device due to unusual activity. Try again later.':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          errorMessage = 'You have been blocked by our server for multiple logins in a day. Please try again after 24 hours';
        });
        Navigator.of(context).pop();
        smsOTPDialog(context).then((value) {
          print('sign in');
        });
        break;
      default:
        setState(() {
          errorMessage = error.message;
        });
        break;
    }
  }

  @override
  initState() {
    super.initState();
    auth.onAuthStateChanged.listen((u) {
      setState(() => user = u);
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size =MediaQuery.of(context).size;
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: true,
      appBar: new AppBar(
        title: new Text("Registration Form", style: TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: <Widget>[
          Image(
            image: AssetImage("assets/bg.jpg"),
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
          ),
          SingleChildScrollView(
            child: Padding(padding:EdgeInsets.all(10),
              child: Form(key: _formKey,
                child: Theme(
                  data: ThemeData(
                    brightness: Brightness.dark,
                    accentColor: Colors.lightBlue,
                    primaryColor: Colors.blueAccent,
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: Colors.white, fontSize: 18.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 30),
                      ),
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.person),hintText: 'Enter name and surname',
                          labelText: 'Name',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter Name';
                          return null;
                        },
                        controller: _name,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.email),hintText: 'Enter your email id',
                          labelText: 'Email Id',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter Email Address';
                          return null;
                        },
                        controller: _email,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        obscureText: ot,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.lock),hintText: 'Choose strong password',
                          labelText: 'Password',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                          suffixIcon: GestureDetector(
                            onTap: () { setState(() {ot = !ot;}); },
                            child: Icon(ot ? Icons.visibility : Icons.visibility_off,
                              semanticLabel: ot ? 'show password' : 'hide password',
                            ),
                          ),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter Password';
                          return null;
                        },
                        controller: _password,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        obscureText: ot1,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.lock),hintText: 'Same as password',
                          labelText: 'Confirm Password',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                          suffixIcon: GestureDetector(
                            onTap: () { setState(() {ot1 = !ot1;}); },
                            child: Icon(ot1 ? Icons.visibility : Icons.visibility_off,
                              semanticLabel: ot1 ? 'show password' : 'hide password',
                            ),
                          ),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter Password';
                          else if(value != _password.text)
                            return 'Password must be same!!!';
                          return null;
                        },
                        controller: _conpassword,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.phone),hintText: 'Enter phone no as +91xxxxxxxxxx',
                          labelText: 'Phone No',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter Phone no';
                          return null;
                        },
                        controller: _phone,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.home),hintText: 'Enter house no & apartment name',
                          labelText: 'Address Line 1',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter Address';
                          return null;
                        },
                        controller: _addl1,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.home),hintText: 'Enter Street name & area',
                          labelText: 'Address Line 2',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter Area';
                          return null;
                        },
                        controller: _addl2,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.location_city),hintText: 'Enter your city',
                          labelText: 'City',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter City';
                          return null;
                        },
                        controller: _city,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                      ),
                      TextFormField(
                        autofocus: false,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(prefixIcon: Icon(Icons.place),hintText: 'Enter state',
                          labelText: 'State',
                          contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
                        ),
                        validator: (value){
                          if(value.isEmpty)
                            return 'Please enter State';
                          return null;
                        },
                        controller: _state,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      Container(
                        padding: const EdgeInsets.only(top: 20),
                        child: new MaterialButton(
                          height: 60,
                          minWidth: 200,
                          color: Colors.white,
                          textColor: Colors.blueAccent,
                          child: Text('Submit', style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                          splashColor: Colors.white12,
                          onPressed: () async {
                            if(_formKey.currentState.validate()) {
                              _formKey.currentState.save();
                              phoneNo=_phone.text;
                              verifyPhone();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}