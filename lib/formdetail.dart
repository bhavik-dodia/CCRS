import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:toast/toast.dart';


// ignore: must_be_immutable
class FormDetail extends StatelessWidget {
  FormDetail({@required this.doc, this.description, this.category, this.subject, this.down});

  final doc;
  final description;
  final category;
  final subject;
  final down;
  final db=Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final HttpsCallable callable = CloudFunctions.instance.getHttpsCallable(functionName: 'genericEmail');
  String emailAddress='dodiabhavik.db@gmail.com';
  String pass='Bhavik@123';
  String username = 'dodiabhavik.db@gmail.com';
  String pass1 = '(Dodia_Bhavik@2000)';

  /*@override
  initState() {
    super.initState();
    auth.onAuthStateChanged.listen((u) {
      setState(() => user = u);
    });
  }*/

  /*sendEmail() {
      return callable.call({
        'user': '$s',
        'text': 'Sending email with Flutter and SendGrid is fun!',
      }).then((res) => print(res.data));
  }*/
  /*sendMail() async{
    final smtpServer = gmail(username, pass1);
    final message = Message()
      ..from = Address(username, 'Your name')
      ..recipients.add('manm13034@gmail.com')
    //..ccRecipients.addAll(['destCc1@example.com', 'destCc2@example.com'])
    //..bccRecipients.add(Address('bccAddress@example.com'))
      ..subject = 'Test Dart Mailer library :: 😀 :: ${DateTime.now()}'
      ..text = 'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
    var connection = PersistentConnection(smtpServer);
    await connection.send(message);
    await connection.close();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(doc, style: TextStyle(color: Colors.white)),
          iconTheme: new IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Center(
            child: Column(
              children: <Widget>[
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(padding: const EdgeInsets.only(top: 20)),
                        Text("Category: "+category,softWrap: true,textAlign: TextAlign.justify),
                        Padding(padding: const EdgeInsets.only(top: 20)),
                        Text("Subject: "+subject,softWrap: true,textAlign: TextAlign.justify),
                        Padding(padding: const EdgeInsets.only(top: 20)),
                        Text("Description: "+description,softWrap: true,textAlign: TextAlign.justify),
                        Padding(padding: const EdgeInsets.only(top: 20)),
                        down!=null?Image.network(down): new Container(),
                        Padding(padding: const EdgeInsets.only(top: 20)),
                        Container(
                          padding: const EdgeInsets.only(top: 20, left: 90, right: 90),
                          child: MaterialButton(
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            color: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            child: Text('Mark Close', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            splashColor: Colors.lightBlueAccent,
                            onPressed: () {
                              db.collection('Forms').document(doc).updateData({'08 Status': 'Close'});
                              /*db.collection("Forms").document(doc).get().then((datasnapshot) {
                                if(datasnapshot.exists) {
                                  s=datasnapshot.data["02 Enrollment No"];
                                }
                              }).catchError((e) => print(e));
                              db.collection("Users").document("$s").get().then((datasnapshot) {
                                if(datasnapshot.exists) {
                                  username = datasnapshot.data["Email Id"];
                                  pass1 = datasnapshot.data["Password"];
                                }
                              }).catchError((e1) => print(e1));
                              print(username);
                              print(pass1);
                              auth.createUserWithEmailAndPassword(email: emailAddress, password: pass);
                              sendEmail();
                              sendMail();*/
                              Toast.show("Form "+doc+" closed successfully", context, duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                              Navigator.of(context).pop();
                              //auth.signOut();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}