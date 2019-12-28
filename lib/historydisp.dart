import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:toast/toast.dart';


class historydisplay extends StatelessWidget {
  historydisplay({@required this.doc, this.description, this.category, this.subject, this.status, this.down});

  final doc;
  final description;
  final category;
  final subject;
  final status;
  final down;
  final db=Firestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc, style: TextStyle(color: Colors.white)),
        iconTheme: new IconThemeData(color: Colors.white)
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
                      Text("Status: "+status,softWrap: true,textAlign: TextAlign.justify,),
                      Padding(padding: const EdgeInsets.only(top: 20)),
                      down!=null?Image.network(down): new Container(),
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