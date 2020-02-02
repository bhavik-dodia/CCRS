import 'package:ccs/main.dart';
import 'package:ccs/cnfusr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toast/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
// ignore: camel_case_types
class forget extends StatefulWidget {
  forget({Key key, this.title}) : super(key: key);

  final String title;


  @override
  _forgetstate createState() => new _forgetstate();
}

// ignore: camel_case_types
class _forgetstate extends State<forget> {
  final db=Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser user;


  TextEditingController _conpassword = new TextEditingController();
  TextEditingController _password = new TextEditingController();

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  initState() {
    super.initState();
    auth.onAuthStateChanged.listen((u) {
      setState(() => user = u);
    });
  }


  void submit()  async{
    if(_formKey.currentState.validate()) {
      _formKey.currentState.save();
      Map<String,String> data = <String,String>{
        "Password": _password.text,
      };
      await db.collection("Users").document(s1).updateData(data).whenComplete(() {
        print("Password Updated");
      }).catchError((e) => print(e));
      Toast.show("Password Updated Successfully", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      appBar: new AppBar(
        title: new Text("Change Password", style: TextStyle(color: Colors.white)),
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
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: new MaterialButton(
                        height: 60,
                        minWidth: 200,
                        color: Colors.white,
                        textColor: Colors.blueAccent,
                        child: Text('Change Password', style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
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