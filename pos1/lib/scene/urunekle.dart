import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class UrunEkle extends StatefulWidget {
  @override
  _UrunEkleState createState() => _UrunEkleState();
}
class _UrunEkleState extends State<UrunEkle> {
   final TextEditingController _qr=TextEditingController();
   TextEditingController urunAd=TextEditingController();
   final TextEditingController urunFiyat=TextEditingController();
   final TextEditingController urunVergi=TextEditingController();
   final TextEditingController urunStok=TextEditingController();
   String vergidahil="";
    String vergidahildeil="";
   void urunEkle()async{
     FirebaseFirestore firestore = FirebaseFirestore.instance;
     final User? user = FirebaseAuth.instance.currentUser;
     DocumentSnapshot documentSnapshot2 = await firestore.collection('${user!.email.toString()}magazaBilgiler').doc("magazaBilgiler").get();
     if(documentSnapshot2.exists){
       if (_qr.text.isNotEmpty&&urunFiyat.text.isNotEmpty&&urunAd.text.isNotEmpty&&urunVergi.text.isNotEmpty&&urunStok.text.isNotEmpty&&dropdown!="") {
         final User? user = FirebaseAuth.instance.currentUser;
         if (user != null) {
           await FirebaseFirestore.instance.collection(user.email.toString()).doc(_qr.text.toString()).set(
               {
                 'urunAdi': urunAd.text,
                 'urunVergi': urunVergi.text,
                 'urunFiyat': urunFiyat.text,
                 'urunStok': urunStok.text,
                 'email': user.email,
                 'barkod':_qr.text,
                 'vergidahil': vergidahil,
                 'vergidahildeil': vergidahildeil,
                 'dropdown':dropdown
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
     }else{
       return showDialog(context: context, builder: (context)=>AlertDialog(
         title: Text(AppLocalizations.of(context)!.kaydedilemedi),
         content: Text(AppLocalizations.of(context)!.magazabilgilerinigir),
         actions: [
           TextButton(onPressed: (){
             Navigator.of(context).pop();
           }, child: Text("OK"))
         ],
       ));
     }


   }
   void vergihesap(){
     double a= double.parse(urunFiyat.text);
     double b= double.parse(urunVergi.text);
     if(urunFiyat.text.isEmpty){a=0;}
     if(urunVergi.text.isEmpty){b=0;}
     double dahilsonuc=0;
     double dDegilsonuc=0;
     if(dropdown==AppLocalizations.of(context)!.vergidahil){
       dahilsonuc=a;
       dDegilsonuc=a/(1+(b/100));
     }else if(dropdown==AppLocalizations.of(context)!.vergiDdegil){
     dahilsonuc=a+(b/100)*a;
     dDegilsonuc=a;
     }else{
       vergidahil="Error";
       vergidahildeil="Error";
     }
     setState(() {
       vergidahil=dahilsonuc.toStringAsFixed(2);
       vergidahildeil=dDegilsonuc.toStringAsFixed(2);
     });


   }
  String? scanResult;
   void urunsorgu() async{
       FirebaseFirestore firestore = FirebaseFirestore.instance;
       final User? user = FirebaseAuth.instance.currentUser;

       DocumentSnapshot documentSnapshot = await firestore.collection(user!.email.toString()).doc(_qr.text.toString()).get();
       if(documentSnapshot.exists){
         setState((){
         urunAd.text=documentSnapshot["urunAdi"].toString();
         urunFiyat.text=documentSnapshot["urunFiyat"].toString();
         urunStok.text=documentSnapshot["urunStok"].toString();
         urunVergi.text=documentSnapshot["urunVergi"].toString();
         vergidahil=documentSnapshot["vergidahil"].toString();
         vergidahildeil=documentSnapshot["vergidahildeil"].toString();
         dropdown=documentSnapshot["dropdown"].toString();
       });
     }
   }
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
      setState(() async {
        super.initState();
        _qr.text=barcode;
        urunsorgu();
      });


  }
   String dropdown="";
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.blueAccent,
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
              title: Text(AppLocalizations.of(context)!.ekleguncelle,style: TextStyle(color: Colors.white)),
              titlePadding: EdgeInsets.symmetric(vertical: 15),
              centerTitle: true,

            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text("${AppLocalizations.of(context)!.urunId}:", style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 80,
                          child: TextField(
                            controller: _qr,
                            onChanged: (text) {
                              urunsorgu();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              label: Text(AppLocalizations.of(context)!.barkodokut),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          icon: Icon(Icons.qr_code_scanner),
                          onPressed: () {
                            scanBarcode();
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text('${AppLocalizations.of(context)!.urunad}:', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 80,
                          child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection(FirebaseAuth.instance.currentUser!.email!)
                                .snapshots(),
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return CircularProgressIndicator();
                              }
                              return Autocomplete<String>(
                                optionsBuilder: (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == "") {
                                    return const Iterable<String>.empty();
                                  }
                                  return snapshot.data!.docs
                                      .where((DocumentSnapshot document) =>
                                      document['urunAdi'].toString().toLowerCase().startsWith(textEditingValue.text.toLowerCase()))
                                      .map((DocumentSnapshot document) => document['urunAdi'].toString());
                                },
                                fieldViewBuilder: (context, controller, focusNode, onEditingComplete,) {
                                 urunAd=controller;
                                  return TextField(
                                    controller: urunAd,
                                    focusNode: focusNode,
                                    onEditingComplete: onEditingComplete,
                                    onChanged: (text){
                                      },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      labelText: AppLocalizations.of(context)!.urunad,
                                    ),
                                  );
                                },
                                onSelected: (String selection) {
                                  final selectedDoc = snapshot.data!.docs.firstWhere(
                                        (DocumentSnapshot document) => document['urunAdi'] == selection,
                                    orElse: () => throw FlutterError('No matching document found for the selected product.'),
                                  );
                                  _qr.text = selectedDoc.id;
                                  urunsorgu();
                                  urunAd.text = selection;
                                },
                              );
                            },
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
                      Expanded(
                        flex: 1,
                        child: Text('${AppLocalizations.of(context)!.stok}:', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 80,
                          child: TextField(
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                            ],
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            controller: urunStok,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              label: Text(AppLocalizations.of(context)!.stok),
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
                      Expanded(
                        flex: 1,
                        child: Text('${AppLocalizations.of(context)!.urunFiyat}:', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 80,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: TextField(
                                  controller: urunFiyat,
                                  onChanged: (text) {
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*$')),
                                  ],
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    labelText: '${AppLocalizations.of(context)!.orn}:100.00/100',
                                  ),
                                ),
                              ),
                              DropdownButton(
                                value: dropdown,
                                items:[
                                  DropdownMenuItem<String>(
                                    value: "", child: Text(""),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: AppLocalizations.of(context)!.vergidahil, child: Text(AppLocalizations.of(context)!.vergidahil),
                                  ),
                                  DropdownMenuItem<String>(
                                    value: AppLocalizations.of(context)!.vergiDdegil, child: Text(AppLocalizations.of(context)!.vergiDdegil),
                                  ),
                                ],
                                onChanged: (String? newValue){
                                  setState(() {
                                    dropdown = newValue!;
                                    if(urunFiyat.text.isNotEmpty&&urunVergi.text.isNotEmpty) vergihesap();
                                  });
                                },
                              )
                            ],
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
                      Expanded(
                        flex: 1,
                        child: Text('${AppLocalizations.of(context)!.vergi}:', style: TextStyle(fontSize: 20)),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          height: 80,
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            controller: urunVergi,
                            onChanged: (text) {
                              vergihesap();
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              label: Text(AppLocalizations.of(context)!.vergi),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Text('${AppLocalizations.of(context)!.vergidahil}:', style: TextStyle(fontSize: 20)),
                  // u artırdık
                  title: Container(
                    height: 40,
                    child: Text(vergidahil)
                  ),
                ),
                ListTile(
                  leading: Text('${AppLocalizations.of(context)!.vergiDdegil}:', style: TextStyle(fontSize: 20)),
                  // u artırdık
                  title: Container(
                    height: 40,
                    child: Text(vergidahildeil),
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
                          borderRadius: BorderRadius.circular(20),
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
