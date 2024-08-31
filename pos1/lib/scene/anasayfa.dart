import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../custom/customUrun.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {

  final TextEditingController _qr=TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  String? scanResult;

  Future<void> scanBarcode()async{
    String barcode;

    try{
      barcode=await FlutterBarcodeScanner.scanBarcode(
          '#ff6666',
          'Cancel',
          true,
          ScanMode.BARCODE
      );
    } on PlatformException{
      barcode='Failed';
    }
    if(!mounted) return;
    setState(() {
      super.initState();

      _qr.text=barcode;
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.blueAccent,
            expandedHeight: 75.0,
            floating: false,
            pinned: true,
            automaticallyImplyLeading: false,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(AppLocalizations.of(context)!.anasayfa,style: TextStyle(color: Colors.white)),
              titlePadding: EdgeInsets.symmetric(vertical: 15),
              centerTitle: true,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _qr,
                      onChanged: (val){
                        setState(() {
                          _qr.text=val;
                        });

                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10), // rounded TextField
                        ),
                        labelText: AppLocalizations.of(context)!.ara,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: () {
                      scanBarcode();

                    },
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(user!.email!).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Text(AppLocalizations.of(context)!.bulunamadi));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(child: Text(AppLocalizations.of(context)!.yukleniyor));
              }

              bool urunBulundu = snapshot.data!.docs.any((doc) {
                Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                return data['urunAdi'].toString().toLowerCase().startsWith(_qr.text.toString().toLowerCase()) || data['barkod'].toString().startsWith(_qr.text.toString());
              });

              if (!urunBulundu) {
                return SliverToBoxAdapter(
                  child: Center(child: Text(AppLocalizations.of(context)!.bulunamadi)),
                );
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      Map<String, dynamic> data = snapshot.data!.docs[index].data()! as Map<String, dynamic>;
                      if(data['urunAdi'].toString().toLowerCase().startsWith(_qr.text.toString().toLowerCase()) || data['barkod'].toString().startsWith(_qr.text.toString())){
                        return CustomUrun(
                          urunAdi: data['urunAdi'],
                          urunFiyati: data['urunFiyat'],
                          urunId: data['barkod'],
                          urunStok: data['urunStok'],
                        );
                      } else {
                        return Container();
                      }
                    },
                    childCount: snapshot.data!.docs.length,
                  ),
                );
              }


            },
          ),
        ],
      ),
    );
  }
}
