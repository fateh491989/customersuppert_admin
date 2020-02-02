import 'package:customersuppert_admin/Chat/chatScreen.dart';
import 'package:flutter/material.dart';

Color bg = Colors.black;

// TODO Change bg color
class Chat extends StatelessWidget {
  final String peerId, userID, peerName;

  Chat({
    Key key,
    @required this.peerId,
    @required this.userID,
    @required this.peerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: new Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(peerName),
        ),
        body: ChatScreen(
          userID: userID,
          adminId: peerId,
          peerName: peerName,
        ),
      ),
    );
  }
}
