import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class CustomUrun extends StatefulWidget {
  final String urunAdi;
  final String urunFiyati;
  final String urunId;
  final String urunStok;

  CustomUrun({required this.urunAdi, required this.urunFiyati, required this.urunId, required this.urunStok});

  @override
  _CustomUrunState createState() => _CustomUrunState();
}

class _CustomUrunState extends State<CustomUrun> {
   String birim=" ";
  Future<void> parabirim() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot documentSnapshot = await firestore.collection('${user!.email.toString()}magazaBilgiler').doc("magazaBilgiler").get();
    if(documentSnapshot.exists){
      setState((){
        birim=documentSnapshot["paraBirim"].toString();
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parabirim();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 13),
      child: Column(
        children: [
          SizedBox(height: 15),
          ListTile(
            title: Text("${AppLocalizations.of(context)!.urunad}: ${widget.urunAdi}", style: TextStyle(fontSize: 26)),
            subtitle: Text(
              "${AppLocalizations.of(context)!.urunFiyat}: ${widget.urunFiyati} ${birim.toString()}\n${AppLocalizations.of(context)!.stok}: ${widget.urunStok}",
              style: TextStyle(fontSize: 22),
            ),
            isThreeLine: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(strokeAlign: 3, color: Colors.blueAccent, width: 2),
            ),
          ),
        ],
      ),
    );
  }
}
