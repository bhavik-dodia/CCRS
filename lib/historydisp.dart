import 'package:flutter/material.dart';

// ignore: camel_case_types
class historydisplay extends StatelessWidget {
  historydisplay(
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
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: false,
      body: Stack(
        children: <Widget>[
          Image(
            image: AssetImage("assets/bg.jpg"),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
            color: Colors.grey.shade800,
            colorBlendMode: BlendMode.darken,
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 50),
                  ),
                  Text(
                    doc,
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5),
                  ),
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
                              softWrap: true, textAlign: TextAlign.justify, style: TextStyle(fontFamily: 'Google-Sans')),
                          Padding(padding: const EdgeInsets.only(top: 20)),
                          Text("Department: " + department,
                              softWrap: true, textAlign: TextAlign.justify, style: TextStyle(fontFamily: 'Google-Sans')),
                          Padding(padding: const EdgeInsets.only(top: 20)),
                          Text("Subject: " + subject,
                              softWrap: true, textAlign: TextAlign.justify, style: TextStyle(fontFamily: 'Google-Sans')),
                          Padding(padding: const EdgeInsets.only(top: 20)),
                          Text("Description: " + description,
                              softWrap: true, textAlign: TextAlign.justify, style: TextStyle(fontFamily: 'Google-Sans')),
                          Padding(padding: const EdgeInsets.only(top: 20)),
                          Text("Status: " + status, softWrap: true, textAlign: TextAlign.justify, style: TextStyle(fontFamily: 'Google-Sans')),
                          Padding(padding: const EdgeInsets.only(top: 20)),
                          down != null
                              ? Image.network(
                                  down,
                                )
                              : new Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
