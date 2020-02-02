import 'historydisp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'package:toast/toast.dart';
import 'dart:async';

class CustomCard extends StatefulWidget {
  CustomCard(
      {@required this.doc,
      this.description,
      this.category,
      this.department,
      this.subject,
      this.status,
      this.down});

  final doc;
  final description;
  final category;
  final department;
  final subject;
  final status;
  final down;

  @override
  _CustomCardState createState() => _CustomCardState();
}

class _CustomCardState extends State<CustomCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.status=="Open"?Colors.redAccent:Colors.greenAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: <Widget>[
            Text("Form ID: " + widget.doc),
            FlatButton(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                child: Text("See More"),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => historydisplay(
                              doc: widget.doc,
                              description: widget.description,
                              category: widget.category,
                              department: widget.department,
                              subject: widget.subject,
                              status: widget.status,
                              down: widget.down)));
                  Toast.show(
                      "Please wait...Image will be loaded soon.", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                }),
          ],
        ),
      ),
    );
  }
}



 

// Future<bool> _requestPop() {
//   goto();
//   return Future.value(true);
// }

// ignore: camel_case_types
class display extends StatefulWidget {
  @override
  _displayState createState() => _displayState();
}

class _displayState extends State<display> {
  Stream babyStream;
  @override
  void initState() {
  super.initState();
  babyStream = Firestore.instance
                              .collection('Forms')
                              .where("03 Email Id", isEqualTo: 'fa')
                              .snapshots();

}
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
        body: Stack(
    fit: StackFit.expand,
    children: <Widget>[
      Image(
        image: AssetImage("assets/bg.jpg"),
        fit: BoxFit.cover,
        color: Colors.black54,
        colorBlendMode: BlendMode.darken,
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: 53),
          ),
          Text(
            "History",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SingleChildScrollView(
                      child: Container(height: MediaQuery.of(context).size.height-90,
                        padding: const EdgeInsets.all(10.0),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: babyStream,
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            snapshot.data.documents.sort((b,a){
                              return a['01 Submitted On'].compareTo(b['01 Submitted On']);
                            });
                            if (snapshot.hasError)
                              return new Text('Error: ${snapshot.error}');
                            if (!snapshot.hasData)
                              return new Text(
                                  'No forms are available now!!!\n\nPlease try again later.',
                                  style: TextStyle(fontSize: 15));
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Text(
                                  'Retrieving Forms...',
                                  style: TextStyle(fontSize: 20),
                                );
                              default:
                                return new ListView(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                  children: snapshot.data.documents
                                      .map((DocumentSnapshot document) {
                                    return CustomCard(
                                      doc: document.documentID,
                                      category: document['04 Category'],
                                      department: document['05 Department'],
                                      subject: document['06 Subject'],
                                      description: document['07 Description'],
                                      status: document['09 Status'],
                                      down: document['08 ImageURL'],
                                    );
                                  }).toList(),
                                );
                            }
                          },
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
