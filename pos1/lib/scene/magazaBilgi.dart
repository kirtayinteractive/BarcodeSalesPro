import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
class MagazaPage extends StatefulWidget {
  @override
  _MagazaPageState createState() => _MagazaPageState();
}

class _MagazaPageState extends State<MagazaPage> {
  TextEditingController magazaAd= TextEditingController();
  TextEditingController magazaAdres= TextEditingController();
  TextEditingController vkn= TextEditingController();
  TextEditingController paraBirim= TextEditingController();
  void urunsorgu() async{
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot documentSnapshot = await firestore.collection('${user!.email.toString()}magazaBilgiler').doc("magazaBilgiler").get();
    if(documentSnapshot.exists){
      setState((){
        magazaAd.text=documentSnapshot["magazaAd"].toString();
        magazaAdres.text=documentSnapshot["magazaAdres"].toString();
        vkn.text=documentSnapshot["vkn"].toString();
        paraBirim.text=documentSnapshot["paraBirim"].toString();
      });
    }
  }
  void urunEkle()async{
    if (magazaAd.text.isNotEmpty&&magazaAdres.text.isNotEmpty&&vkn.text.isNotEmpty&&paraBirim.text.isNotEmpty) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('${user.email.toString()}magazaBilgiler').doc("magazaBilgiler").set(
            {
              'magazaAd': magazaAd.text,
              'magazaAdres': magazaAdres.text,
              'vkn': vkn.text,
              'paraBirim': paraBirim.text,
              'date':DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
              'belge':0,
            });
      }
      return showDialog(context: context, builder: (context)=>AlertDialog(
        content: Text(AppLocalizations.of(context)!.kaydedildi),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text("OK"))
        ],

      ));
    }else {
      return showDialog(context: context, builder: (context)=>AlertDialog(
        title: Text(AppLocalizations.of(context)!.kaydedilemedi),
        content: Text(AppLocalizations.of(context)!.kaydedilemediText),
        actions: [
          TextButton(onPressed: (){
            Navigator.of(context).pop();
          }, child: Text("OK"))
        ],
      ));
    }

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    urunsorgu();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.blueAccent, // AppBar'ın rengini lightGreen yaptık
            expandedHeight: 80.0,
            floating: false,
            pinned: true,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLocalizations.of(context)!.magazabilgiler,style: TextStyle(color: Colors.white)),
              titlePadding: EdgeInsets.symmetric(vertical: 15),
              centerTitle: true,

            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.magazaadi,style: TextStyle(fontSize: 20),)),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: magazaAd,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.magazaadresi,style: TextStyle(fontSize: 20),)),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: magazaAdres,
                          expands: false,
                          maxLines: 4,
                          decoration: InputDecoration(
                            label: Text(AppLocalizations.of(context)!.adresbilgiler,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.vkno,style: TextStyle(fontSize: 20),)),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: vkn,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(flex: 1, child: Text(AppLocalizations.of(context)!.parabirimi,style: TextStyle(fontSize: 20),)),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: paraBirim,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                    child:Column(children: [
                      ElevatedButton(
                        onPressed: () {
                          urunEkle();
                        },
                        child:
                        Text(AppLocalizations.of(context)!.kaydetguncelle),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20), // rounded button
                          ),
                        ),
                      ),
                    ],)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
