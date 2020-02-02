import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Grievance.dart';

// ignore: camel_case_types
class MyHomePage extends StatefulWidget
{
  const MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      resizeToAvoidBottomInset: false,
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
              Text("Home Page",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white,),),
              Padding(padding: EdgeInsets.only(top: 150),),
              Padding(
                padding: EdgeInsets.all(15.0),
                child: Text("""\n\nThe Citizen Complaint Redressal System helps the citizen to file complaints which they face in daily life.\n\nThese complaints will be viewed by the highest authority and will be solved as soon as possible. Once solved, the respective citizen will be notified for the same.""",
                    style: TextStyle(fontSize: 20,color: Colors.white),softWrap: true,textAlign: TextAlign.justify),
              ),
              Padding(padding: EdgeInsets.only(top: 50),),
              MaterialButton(
                minWidth: 200,
                height: 60,
                color: Colors.white,
                textColor: Colors.lightBlue,
                child: Text("Grievance Form",style: TextStyle(fontSize: 20),),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                splashColor: Colors.white24,
                onPressed: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => grievance()
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
