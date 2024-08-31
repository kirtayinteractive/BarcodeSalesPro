import 'package:flutter/material.dart';
import 'package:pos1/scene/magazaBilgi.dart';
import 'package:pos1/scene/satinAlim.dart';
import 'anasayfa.dart';
import 'urunekle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    AnaSayfa(),
    UrunEkle(),
    SatinAlim(),
    MagazaPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home,size: 30,),
            label:  '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add,size: 30,),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.money,size: 30,),
            label:  '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business,size: 30,),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    ), onWillPop: ()async{
      return false;
    }) ;
  }
}
