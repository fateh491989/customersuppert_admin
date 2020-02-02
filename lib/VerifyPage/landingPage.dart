import 'package:customersuppert_admin/AllUsers/allUsers.dart';
import 'package:customersuppert_admin/Chat/chat.dart';
import 'package:customersuppert_admin/Config/config.dart';
import 'package:customersuppert_admin/VerifyPage/landingPageUI.dart';
import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}
class _LandingPageState extends State<LandingPage> {

  @override
  void initState() {
    super.initState();
    readLocal();
  }
  readLocal() async {
    if(await ChatApp.auth.currentUser()!= null){
      Route route = MaterialPageRoute(
          builder: (builder) => AllUsers());
      Navigator.push(context, route);
    }
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: PhoneAuthScreen(),
      ),
    );
  }
}

