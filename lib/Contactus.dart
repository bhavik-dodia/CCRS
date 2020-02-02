import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ignore: camel_case_types
class contactus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Image(
            image: AssetImage("assets/bg.jpg"),
            width: size.width,
            height: size.height,
            fit: BoxFit.fill,
            color: Colors.black54, //lightens the image
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 53),),
              Text("About Us",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,),
              Padding(padding: EdgeInsets.only(top: 175),),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  """\nTeam Enigma\n\nPhone Number:\nAbhishek Doshi: +91 7818044311\nBhavik Dodia: +91 9913971152\nRonak Joshi: +91 9033365867""",
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                  softWrap: true,
                  textAlign: TextAlign.justify,),
              ),
            ],
          ),
        ],
      ),
    );
  }
}