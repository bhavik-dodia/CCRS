import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'formdetail.dart';
import 'package:toast/toast.dart';
import 'main.dart';

class CustomCard extends StatefulWidget {
  CustomCard(
      {@required this.doc,
      this.description,
      this.category,
      this.subject,
      this.down,
      this.status,
      this.uemail});

  final doc;
  final description;
  final category;
  final subject;
  final down;
  final status;
  final uemail;

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
                      builder: (context) => FormDetail(
                          doc: widget.doc,
                          description: widget.description,
                          category: widget.category,
                          subject: widget.subject,
                          down: widget.down,
                          uemail: widget.uemail),
                    ),
                  );
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

class Admindisplay extends StatefulWidget {
  @override
  _AdmindisplayState createState() => _AdmindisplayState();
}

class _AdmindisplayState extends State<Admindisplay> {
  Stream babyStream;
  

  @override
  void initState() {
  super.initState();
  babyStream = Firestore.instance
                          .collection("Forms")
                          .where("05 Department", isEqualTo: dept)
                          .orderBy("01 Submitted On", descending: true)
                          .snapshots();
}
  Widget build(BuildContext context) {
    return MaterialApp(
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
                  dept+" Department",
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height-90,
                    padding: const EdgeInsets.all(10.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: babyStream,
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError)
                          return new Text('Error: ${snapshot.error}');
                        if (!snapshot.hasData)
                          return new Text(
                              'No open forms are available now!!!\n\nPlease try again later.',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white));
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return new Text(
                              'Retrieving Forms...',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.white),
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
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
