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
      // appBar: AppBar(
      //   title: Text("Contact Us", style: TextStyle(color: Colors.white)),
      // ),
      body: Stack(
        children: <Widget>[
          Image(
            image: AssetImage("assets/abstract_bg.jpg"),
            width: size.width,
            height: size.height,
            fit: BoxFit.fill,
            color: Colors.black54, //lightens the image
            colorBlendMode: BlendMode.darken,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[          
              Padding(padding: EdgeInsets.only(top: 50),),
              Text("Contact Us",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),textAlign: TextAlign.center,),
              Padding(padding: EdgeInsets.only(top: 175),),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                  """\nTeam Enigma\n\nVadodara-Mumbai NH#8, Varnama, Vadodara-391240 Gujarat, India.\n\nPhone Number:\n+91 7818044311\n+91 9913971152\n""",
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