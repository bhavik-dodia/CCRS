import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'formdetail.dart';
import 'package:toast/toast.dart';
import 'main.dart';
import 'dart:async';

class CustomCard extends StatelessWidget {
  CustomCard(
      {@required this.doc,
      this.description,
      this.category,
      this.subject,
      this.down,
      this.status,
      this.uemail,
      this.nm,
      this.ph,
      this.add});

  final doc;
  final description;
  final category;
  final subject;
  final down;
  final status;
  final uemail;
  final nm;
  final ph;
  final add;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormDetail(
                doc: doc,
                description: description,
                category: category,
                subject: subject,
                down: down,
                uemail: uemail,
                nm: nm,
                ph: ph,
                add: add),
          ),
        );
        Toast.show("Please wait...Image will be loaded soon.", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      },
      child: Card(
        color: status == "Open" ? Colors.redAccent : Colors.greenAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          height: 65,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Form ID: " + doc,
                style: TextStyle(fontSize: 18,fontFamily: 'Google-Sans'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Admindisplay extends StatefulWidget {
  @override
  _AdmindisplayState createState() => _AdmindisplayState();
}

class _AdmindisplayState extends State<Admindisplay> {
  Future<bool> _requestPop() {
    FirebaseAuth.instance.signOut();
    print("Sign out");
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: MaterialApp(
        routes: <String, WidgetBuilder>{
          '/admin': (BuildContext context) => Admindisplay(),
        },
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
                color: Colors.grey.shade800,
                colorBlendMode: BlendMode.darken,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 53),
                  ),
                  Text(
                    dept + " Department",
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Google-Sans',
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height - 90,
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('Forms')
                          .where("05 Department", isEqualTo: dept)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        snapshot.data.documents.sort((b, a) {
                          return a['01 Submitted On']
                              .compareTo(b['01 Submitted On']);
                        });
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.white));
                        if (!snapshot.hasData)
                          return new Text(
                              'No open forms are available now!!!\n\nPlease try again later.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white, fontFamily: 'Google-Sans'));
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Text(
                              'Retrieving Forms...',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Google-Sans'),
                            );
                          default:
                            return new ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              children: snapshot.data.documents
                                  .map((DocumentSnapshot document) {
                                return new CustomCard(
                                  doc: document.documentID,
                                  uemail: document['03 Email Id'],
                                  nm: document['02 Name'],
                                  ph: document['10 Phone Number'],
                                  add: document['11 Address'],
                                  category: document['04 Category'],
                                  subject: document['06 Subject'],
                                  description: document['07 Description'],
                                  down: document['08 ImageURL'],
                                  status: document['09 Status'],
                                );
                              }).toList(),
                            );
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
