import 'package:ccs/Contactus.dart';
import 'package:ccs/Grievance.dart';
import 'package:ccs/history.dart';
import 'package:ccs/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_theme.dart';
import 'drawer_user_controller.dart';
import 'home_drawer.dart';
import 'home.dart';
import 'package:flutter/material.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
  AnimationController sliderAnimationController;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = const MyHomePage();
    super.initState();
  }
  
  Future<bool> _requestPop() {
    FirebaseAuth.instance.signOut();
    print("Sign Out");
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
          child: Container(
        color: AppTheme.nearlyWhite,
        child: SafeArea(
          top: false,
          bottom: false,
          child: Scaffold(
            backgroundColor: AppTheme.nearlyWhite,
            body: DrawerUserController(
              screenIndex: drawerIndex,
              drawerWidth: MediaQuery.of(context).size.width * 0.75,
              animationController: (AnimationController animationController) {
                sliderAnimationController = animationController;
              },
              onDrawerCall: (DrawerIndex drawerIndexdata) {
                changeIndex(drawerIndexdata);
              },
              screenView: screenView,
            ),
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.HOME) {
        setState(() {
          screenView = const MyHomePage();
        });
      } else if (drawerIndex == DrawerIndex.Grievances) {
        setState(() {
          screenView = grievance();
        });
      } else if (drawerIndex == DrawerIndex.History) {
        setState(() {
          screenView = display();
        });
      } else if (drawerIndex == DrawerIndex.About) {
        setState(() {
          screenView = contactus();
        });
      } else {
        //do in your way......
      }
    }
  }
}