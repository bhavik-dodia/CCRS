
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: camel_case_types
String s1;
// ignore: camel_case_types
class cnfusr extends StatefulWidget {
  cnfusr({Key key, this.title}) : super(key: key);

  final String title;


  @override
  _cnfusrstate createState() => new _cnfusrstate();
}

// ignore: camel_case_types
class _cnfusrstate extends State<cnfusr> {
  final db=Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;


  TextEditingController _email = new TextEditingController();

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
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/forget');
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
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/forget');
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


  void submit()  async{
    s1 = _email.text;
    if (_formKey.currentState.validate()) {
      DocumentReference documentReference = db.collection("Users").document(s1);
      documentReference.get().then((datasnapshot) {
        if (datasnapshot.exists) {
            phoneNo = datasnapshot.data['Phone Number'].toString();
            verifyPhone();
        }
        else
          Toast.show("Invalid Email!!!", context, duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: new AppBar(
        title: new Text("Forgot Password", style: TextStyle(color: Colors.white)),
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
          Padding(padding:EdgeInsets.all(10),
            child: Form(key: _formKey,
              child: Theme(
                data: ThemeData(
                  brightness: Brightness.dark,
                  accentColor: Colors.lightBlue,
                  primaryColor: Colors.blueAccent,
                  inputDecorationTheme: InputDecorationTheme(
                    labelStyle: TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 50),
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
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: new MaterialButton(
                        height: 60,
                        minWidth: 200,
                        color: Colors.white,
                        textColor: Colors.blueAccent,
                        child: Text('Verify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        splashColor: Colors.white12,
                        onPressed: submit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}