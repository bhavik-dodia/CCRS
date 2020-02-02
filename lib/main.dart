import 'dart:async';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:ccs/cnfusr.dart';
import 'package:ccs/forget.dart';
import 'package:ccs/navigation.dart';
import 'package:ccs/register.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'delayed_animation.dart';
import 'package:toast/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin.dart';

final db = Firestore.instance;
bool ot, ot1;
String s = "",name="",dept="";

void main() {
  //SystemChrome.setEnabledSystemUIOverlays([]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
      routes: <String, WidgetBuilder>{
        '/homepage': (BuildContext context) => NavigationHomeScreen(),
        '/loginpage': (BuildContext context) => MyApp(),
        '/admin': (BuildContext context) => Admindisplay(),
        '/forget': (BuildContext context) => forget(),
      },
      theme: ThemeData(
          primarySwatch: Colors.lightBlue, accentColor: Colors.lightBlueAccent),
    );
  }
}

class Login extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<Login> with SingleTickerProviderStateMixin {
  final int delayedAmount = 500;
  double _scale;

  AnimationController _controller;
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String type;
  String phoneNo;
  String smsOTP;
  String verificationId;
  String errorMessage = '';
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhone() async {
    Toast.show(
        "OTP has been sent to your registered number. Please Wait...\n\nIf you don't receive otp, you have been blocked by our server for multiple logins in a day. Please try again after 24 hours",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.TOP);
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
          codeSent:
              smsOTPSent, // WHEN CODE SENT THEN WE OPEN DIALOG TO ENTER OTP.
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text('Enter OTP', style: TextStyle(color: Colors.blue)),
            content: Container(
              padding: const EdgeInsets.only(left: 15.0, right: 15),
              height: 85,
              child: Column(children: [
                TextField(
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  onChanged: (value) {
                    this.smsOTP = value;
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                ),
                (errorMessage != ''
                    ? Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      )
                    : Container())
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
                      if (type == "Admin")
                        Navigator.of(context).pushReplacementNamed('/admin');
                      else
                        Navigator.of(context).pushReplacementNamed('/homepage');
                      Toast.show("You have successfully signed in", context,
                          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pop();
      if (type == "Admin")
        Navigator.of(context).pushReplacementNamed('/admin');
      else
        Navigator.of(context).pushReplacementNamed('/homepage');
      Toast.show("You have successfully signed in", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
          errorMessage =
              'You have been blocked by our server for multiple logins in a day. Please try again after 24 hours';
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

  void change() async {
    String pass;
    s = _email.text;
    if (_formKey.currentState.validate()) {
      DocumentReference documentReference = db.collection("Users").document(s);
      documentReference.get().then((datasnapshot) {
        if (datasnapshot.exists) {
          pass = datasnapshot.data['Password'].toString();
          if (_password.text == pass) {
            phoneNo = datasnapshot.data['Phone Number'].toString();
            name = datasnapshot.data['Name'].toString();
            type = datasnapshot.data['Account Type'].toString();
            if(type == 'Admin')
              dept = datasnapshot.data['Department'].toString();
            verifyPhone();
          } else
            Toast.show("Invalid Password!!!", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        } else
          Toast.show("User not registered!!!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      });
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    ot = true;
    ot1 = true;
    _email.text = null;
    _password.text = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Colors.white;
    _scale = 1 - _controller.value;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        resizeToAvoidBottomInset: false,
        body: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image(
              image: AssetImage("assets/bg.jpg"),
              fit: BoxFit.cover,
              color: Colors.black54,
              colorBlendMode: BlendMode.darken,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: _formKey,
                child: Theme(
                  data: ThemeData(
                    brightness: Brightness.dark,
                    accentColor: Colors.lightBlue,
                    primaryColor: Colors.blueAccent,
                    inputDecorationTheme: InputDecorationTheme(
                      labelStyle: TextStyle(color: color, fontSize: 20.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      AvatarGlow(
                        endRadius: 90,
                        duration: Duration(seconds: 2),
                        glowColor: color,
                        repeat: true,
                        repeatPauseDuration: Duration(seconds: 2),
                        startDelay: Duration(seconds: 1),
                        child: Container(
                            height: 105,
                            width: 105,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: AppTheme.grey.withOpacity(0.6),
                                    offset: const Offset(2.0, 4.0),
                                    blurRadius: 8),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(60.0)),
                              child: Image.asset('assets/complaint.png',color: Colors.blueGrey, colorBlendMode: BlendMode.hue,),
                            ),
                          ),
                      ),
                      DelayedAimation(
                        child: Text(
                          "Welcome",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 35.0,
                              color: color),
                        ),
                        delay: delayedAmount + 500,
                      ),
                      SizedBox(height: 30.0),
                      DelayedAimation(
                        child: TextFormField(
                          autofocus: false,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email),
                            hintText: 'Email Id',
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                          ),
                          validator: (value) {
                            if (value.isEmpty)
                              return 'Please enter Email Address';
                            return null;
                          },
                          controller: _email,
                        ),
                        delay: delayedAmount + 1000,
                      ),
                      SizedBox(height: 15.0),
                      DelayedAimation(
                        child: TextFormField(
                          autofocus: false,
                          obscureText: ot,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: 'Password',
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32.0)),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  ot = !ot;
                                });
                              },
                              child: Icon(
                                ot ? Icons.visibility : Icons.visibility_off,
                                semanticLabel:
                                    ot ? 'show password' : 'hide password',
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) return 'Please enter Password';
                            return null;
                          },
                          controller: _password,
                        ),
                        delay: delayedAmount + 1500,
                      ),
                      SizedBox(height: 50.0),
                      DelayedAimation(
                        child: GestureDetector(
                          onTapDown: _onTapDown,
                          onTapUp: _onTapUp,
                          child: Transform.scale(
                            scale: _scale,
                            child: _animatedButtonUI,
                          ),
                        ),
                        delay: delayedAmount + 2000,
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          DelayedAimation(
                            child: FlatButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NavigationHomeScreen()));
                              },
                              child: Text('Forgot Password',
                                  style: TextStyle(color: Colors.white70)),
                            ),
                            delay: delayedAmount + 2500,
                          ),
                          DelayedAimation(
                            child: Text("|"),
                            delay: delayedAmount + 2500,
                          ),
                          DelayedAimation(
                            child: FlatButton(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onPressed: () async {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => register()));
                              },
                              child: Text('Register Now',
                                  style: TextStyle(color: Colors.white70)),
                            ),
                            delay: delayedAmount + 2500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _animatedButtonUI => Container(
        height: 60,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          /*gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blueAccent,
          Colors.pinkAccent,
        ],
      )*/
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            'Log In',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ),
      );

  void _onTapDown(TapDownDetails details) async {
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      change();
    });
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }
}
