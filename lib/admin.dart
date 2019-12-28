import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'formdetail.dart';
import 'package:toast/toast.dart';

class CustomCard extends StatelessWidget {
  CustomCard({@required this.doc, this.description, this.category, this.subject, this.down});

  final doc;
  final description;
  final category;
  final subject;
  final down;

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              children: <Widget>[
                Text("Form ID: "+doc),
                FlatButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Text("See More"),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => FormDetail(doc: doc, description: description, category: category, subject: subject, down: down)));
                      Toast.show("Please wait...Image will be loaded soon.", context, duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                    }),
              ],
            )
        )
    );
  }
}

class Admindisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Grievances Forms'),
        ),
        body: Center(
          child: Container(
              padding: const EdgeInsets.all(10.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('Forms').where("08 Status",isEqualTo: "Open").orderBy("01 Submitted On",descending: true).snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  if (!snapshot.hasData) return new Text('No open forms are available now!!!\n\nPlease try again later.',style: TextStyle(fontSize: 15));
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Text('Retrieving Forms...',style: TextStyle(fontSize: 20),);
                    default:
                      return new ListView(
                        children: snapshot.data.documents.map((DocumentSnapshot document) {
                          return new CustomCard(
                            doc: document.documentID,
                            category: document['04 Category'],
                            subject: document['05 Subject'],
                            description: document['06 Description'],
                            down: document['07 ImageURL'],
                          );
                        }).toList(),
                      );
                  }
                },
              ),
          ),
        ),
      ),
    );
  }
}