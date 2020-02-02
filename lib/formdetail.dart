import 'package:ccs/admin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:mailer2/mailer.dart';
import 'package:toast/toast.dart';

// ignore: must_be_immutable
class FormDetail extends StatelessWidget {
  FormDetail(
      {@required this.doc,
      this.description,
      this.category,
      this.subject,
      this.down,
      this.uemail});

  final doc;
  final description;
  final category;
  final subject;
  final down;
  final uemail;
  final db = Firestore.instance;

void sendMail() {
  
    GmailSmtpOptions options = new GmailSmtpOptions()
      ..username = 'teamenigma96@gmail.com'
      ..password = 'opagpdcvbjrvkdzw';
    SmtpTransport emailTransport = new SmtpTransport(options);
    Envelope envelope = new Envelope()
      ..from = 'teamenigma96@gmail.com'
      ..recipients.add(uemail)
      ..subject = 'Grievance Solved!!!'
      //..attachments.add(new Attachment(file: new File(fileName)))
      ..html =
          "<html><body><p><font size=3>Thanks for contacting us!<br>Your grievance for Form ID: <b>$doc</b> has been resolved and closed successfully!!</font></p></body></html>";
      emailTransport
        .send(envelope)
        .then((envelope) => print('Email sent!'))
        .catchError((e) => print('Error occurred: $e'));
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Image(
            image: AssetImage("assets/bg.jpg"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            color: Colors.black54,
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 53),
              ),
              Text(
                doc,
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(padding: const EdgeInsets.only(top: 20)),
                              Text("Category: " + category,
                                  softWrap: true, textAlign: TextAlign.justify),
                              Padding(padding: const EdgeInsets.only(top: 20)),
                              Text("Subject: " + subject,
                                  softWrap: true, textAlign: TextAlign.justify),
                              Padding(padding: const EdgeInsets.only(top: 20)),
                              Text("Description: " + description,
                                  softWrap: true, textAlign: TextAlign.justify),
                              Padding(padding: const EdgeInsets.only(top: 20)),
                              down != null
                                  ? Image.network(down,height: 400,)
                                  : new Container(),
                              Padding(padding: const EdgeInsets.only(top: 20)),
                              Container(
                                padding: const EdgeInsets.only(
                                    top: 20, left: 90, right: 90),
                                child: MaterialButton(
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  color: Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  child: Text('Mark Close',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  splashColor: Colors.lightBlueAccent,
                                  onPressed: () {
                                    sendMail();
                                    db.collection('Forms')
                                        .document(doc)
                                        .updateData({'09 Status': 'Close'}); 
                                    Toast.show(
                                        "Form " + doc + " closed successfully",
                                        context,
                                        duration: Toast.LENGTH_LONG,
                                        gravity: Toast.BOTTOM);
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushReplacementNamed('/admin');
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
            ],
          ),
        ],
      ),
    );
  }
}
