import 'dart:convert';
import 'dart:io';

import 'package:customersuppert_admin/Chat/chat.dart';
import 'package:customersuppert_admin/Config/config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersuppert_admin/main.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {


  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    readLocal();
    // TODO: define these methods in your homepage
    registerNotification();
    configLocalNotification();

  }
  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();
    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      showNotification(message['notification']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      ChatApp.firestore
          .collection(ChatApp.collectionAdmin)
          .document(ChatApp.sharedPreferences.getString(ChatApp.userUID))
          .updateData({ChatApp.userToken: token});
    }).catchError((err) {
      Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      // TODO: Change package name
      Platform.isAndroid
          ? 'com.example.customersuppert_admin'
          : 'com.duytq.flutterchatdemo',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));
  }

  readLocal() {}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text('All Users'),
            //leading: Container(),
          ),
          body: _buildBody(context),
    ));
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection(ChatApp.collectionUser)
          .orderBy(ChatApp.userLastSeen, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    //TODO delete self
    //snapshot.data.data['count'].toString()
    String groupChatId;
    if (ChatApp.sharedPreferences.getString(ChatApp.userUID).hashCode <=
        data[ChatApp.userUID].toString().hashCode) {
      groupChatId =
          '${ChatApp.sharedPreferences.getString(ChatApp.userUID)}-${data[ChatApp.userUID].toString()}';
    } else {
      groupChatId =
          '${data[ChatApp.userUID].toString()}-${ChatApp.sharedPreferences.getString(ChatApp.userUID)}';
    }
    return InkWell(
      onTap: (){
        Firestore.instance
            .collection(ChatApp.collectionMessage)
            .document(groupChatId)
            .collection(ChatApp.sharedPreferences.getString(ChatApp.userUID))
            .document(ChatApp.sharedPreferences.getString(ChatApp.userUID))
            .setData({UserMessage.count: 0}).catchError((error) {
          print('Hello');
          print(error);
        });
        Route route = MaterialPageRoute(
            builder: (builder) => Chat(
              peerId: data[ChatApp.userUID],
              userID: ChatApp.sharedPreferences.getString(ChatApp.userUID),
              peerName: data[ChatApp.userName],
            ));
        Navigator.push(context, route);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
        child: InkWell(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 0.0, top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        //child: Image.network(data[ChatApp.userPhotoUrl]),
                        backgroundImage: NetworkImage(data[ChatApp.userPhotoUrl]),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0, top: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(data[ChatApp.userName].toUpperCase(),
                          style: Theme.of(context).textTheme.title),
                      Text(data[ChatApp.userPhoneNumber],
                          style: Theme.of(context).textTheme.title.copyWith(
                            fontSize: 15,
                            color: Colors.grey
                          )),
                    ],
                  ),
                ),
                Flexible(child: Container()),
                StreamBuilder<DocumentSnapshot>(
                  stream: ChatApp.firestore
                      .collection(ChatApp.collectionMessage)
                      .document(groupChatId)
                      .collection(ChatApp.sharedPreferences.getString(ChatApp.userUID))
                      .document(ChatApp.sharedPreferences.getString(ChatApp.userUID))
                      .snapshots(),
                  builder: (context, snapshot) {
                    print(groupChatId);
                    if (snapshot.hasData) {
                      return snapshot.data.exists?
                       snapshot.data.data['count']==0? Container():CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 15,
                        child: Text(snapshot.data.data['count'].toString(),style: TextStyle(
                          fontSize: 15
                        ),),
                      ):Container();
                    }
                    else if(snapshot.hasError){
                      return Text('0');
                    }
                    else {
                      return Text('');
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
