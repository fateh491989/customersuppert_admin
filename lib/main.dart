import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customersuppert_admin/AllUsers/allUsers.dart';
import 'package:customersuppert_admin/Config/config.dart';
import 'package:customersuppert_admin/VerifyPage/landingPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   ChatApp.sharedPreferences = await SharedPreferences.getInstance();
   ChatApp.auth = FirebaseAuth.instance;
   ChatApp.firestore = Firestore.instance;
   runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        textTheme: TextTheme(
          title: TextStyle(
            color: Colors.red,
            fontSize: 20
          )
        )
      ),
      home:
      //MyHomePage()
      LandingPage()
      //AllUsers()
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carousel in vertical scrollable'),
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        itemBuilder: (BuildContext context, int index) {
          if(index % 2 == 0) {
            return _buildCarousel(context, index ~/ 2);
          }
          else {
            return Divider();
          }
        },
      ),
    );
  }

  Widget _buildCarousel(BuildContext context, int carouselIndex) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Carousel $carouselIndex'),
        SizedBox(
          // you may want to use an aspect ratio here for tablet support
          height: 200.0,
          child: PageView.builder(
            // store this controller in a State to save the carousel scroll position
            controller: PageController(viewportFraction: 0.8),
            itemBuilder: (BuildContext context, int itemIndex) {
              return _buildCarouselItem(context, carouselIndex, itemIndex);
            },
          ),
        )
      ],
    );
  }

  Widget _buildCarouselItem(BuildContext context, int carouselIndex, int itemIndex) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
      ),
    );
  }
}


class FirestoreSlideshow extends StatefulWidget {
  createState() => FirestoreSlideshowState();
}

class FirestoreSlideshowState extends State<FirestoreSlideshow> {

  final PageController ctrl = PageController(viewportFraction: 0.8);

  final Firestore db = Firestore.instance;
  Stream slides;


  String activeTag = 'favorites';

  // Keep track of current page to avoid unnecessary renders
  int currentPage = 0;


  @override
  void initState() {
    _queryDb();

    // Set state when page changes
    ctrl.addListener(() {
      int next = ctrl.page.round();

      if(currentPage != next) {
        setState(() {
          currentPage = next;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: slides,
        initialData: [],
        builder: (context, AsyncSnapshot snap) {

          List slideList = snap.data.toList();

          return PageView.builder(

              controller: ctrl,
              itemCount: slideList.length + 1,
              itemBuilder: (context, int currentIdx) {


                if (currentIdx == 0) {
                  return _buildTagPage();
                } else if (slideList.length >= currentIdx) {
                  // Active page
                  bool active = currentIdx == currentPage;
                  return _buildStoryPage(slideList[currentIdx - 1], active);
                }
              }
          );
        }
    );
  }

  Stream _queryDb({ String tag ='favorites' }) {

    // Make a Query
    Query query = db.collection('stories').where('tags', arrayContains: tag);

    // Map the documents to the data payload
    slides = query.snapshots().map((list) => list.documents.map((doc) => doc.data));

    // Update the active tag
    setState(() {
      activeTag = tag;
    });

  }


  // Builder Functions

  _buildStoryPage(Map data, bool active) {
    // Animated Properties
    final double blur = active ? 30 : 0;
    final double offset = active ? 20 : 0;
    final double top = active ? 100 : 200;


    return AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOutQuint,
        margin: EdgeInsets.only(top: top, bottom: 50, right: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),

            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(data['img']),
            ),

            boxShadow: [BoxShadow(color: Colors.black87, blurRadius: blur, offset: Offset(offset, offset))]
        ),
        child: Center(
            child: Text(data['title'], style: TextStyle(fontSize: 40, color: Colors.white))
        )
    );
  }


  _buildTagPage() {
    return Container(child:
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Text('Your Stories', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
        Text('FILTER', style: TextStyle( color: Colors.black26 )),
        _buildButton('favorites'),
        _buildButton('happy'),
        _buildButton('sad')
      ],
    )
    );
  }

  _buildButton(tag) {
    Color color = tag == activeTag ? Colors.purple : Colors.white;
    return FlatButton(color: color, child: Text('#$tag'), onPressed: () => _queryDb(tag: tag));
  }

}