import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos1/scene/printPage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
class SatinAlim extends StatefulWidget {
  @override
  _SatinAlimState createState() => _SatinAlimState();
}

class _SatinAlimState extends State<SatinAlim> {

  List<Map<String, dynamic>> products = [];
  double toplam=0;
  String qr="";
  double fiyat=10;
  String ad="";
  int adet=1;
  int stok=1;
  String parabirim="";
  String magazaad="";
  String magazaadres="";
  String vkno="VKN/Mersis No";
  int kdv=1;
  String vergi="1";
  double vergitoplam=0;
  double vergiDdegil=0;
  var belgeno=0;
  var tarih;

  Future<void> printPdf() async {
    if(tarih.toString()!=DateFormat('yyyy-MM-dd').format(DateTime.now()).toString()){
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = FirebaseAuth.instance.currentUser;
      belgeno=0;
      await firestore.collection('${user!.email.toString()}magazaBilgiler').doc("magazaBilgiler").update(
          {
        'belge':0,
        'date':DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
      }
      );

      print(belgeno.toString());
    }
    Navigator.push(context, MaterialPageRoute(builder: (_)=>PrintPage(products,vergitoplam,toplam,magazaad,magazaadres,vkno,belgeno)));
  }
  void fisCikart(){
    showDialog(context: context, builder: (context)=>AlertDialog(
      content: Text(AppLocalizations.of(context)!.fiscikartilsin),
      actions: [
        TextButton(onPressed: () async {
          Navigator.of(context).pop();
          await dateSorgu();
          printPdf();
        }, child: Text(AppLocalizations.of(context)!.evet)),
        TextButton(onPressed: (){
          Navigator.of(context).pop();
        }, child: Text(AppLocalizations.of(context)!.iptal)),
      ],

    ));
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
    setState((){
      super.initState();
      if(barcode!="-1"&&barcode.isNotEmpty){
          qr=barcode;
          urunsorgu(qr);
      }else {
        qr = "";
      }

    });


  }
  void urunsorgu(String _qr) async{
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot documentSnapshot2 = await firestore.collection('${user!.email.toString()}magazaBilgiler').doc("magazaBilgiler").get();
    if(documentSnapshot2.exists){
      setState((){
        parabirim= documentSnapshot2["paraBirim"].toString();
        magazaad= documentSnapshot2["magazaAd"].toString();
        magazaadres= documentSnapshot2["magazaAdres"].toString();
        vkno= documentSnapshot2["vkn"].toString();

      });
    }else{
      parabirim=" ";
    }
    DocumentSnapshot documentSnapshot = await firestore.collection(user!.email.toString()).doc(_qr.toString()).get();
    if(documentSnapshot.exists){
      setState((){
        ad=documentSnapshot["urunAdi"].toString();
        fiyat=double.parse(documentSnapshot["vergidahil"].toString()) ;
        stok= int.parse(documentSnapshot["urunStok"].toString());
        vergiDdegil=double.parse(documentSnapshot["vergidahildeil"].toString());
        kdv=int.parse(documentSnapshot["urunVergi"].toString()) ;
        vergi=(fiyat-vergiDdegil).toStringAsFixed(2);
        print(fiyat);
        print(vergiDdegil);
        print(vergi);
        bool mevcut=false;
        for(int i=0;i<products.length;i++){
          if(products[i]['qr']==_qr){
            mevcut=true;
            incrementQuantity(i);
            i=products.length;
          }else{
            mevcut=false;
          }
        }
        if(mevcut){
        }else {
          addProduct();
        }
      });
    }


  }
  void addProduct() {
    setState(() {
      products.add({
        'qr':qr.toString(),
        'name': '$ad',
        'price': '${(adet * fiyat).toStringAsFixed(2)}',
        'birim': parabirim==null?" ":parabirim,
        'quantity': adet,
        //'stok':stok-adet,
        'stok':stok,
        'kdv':kdv,
        'vergi':'${(double.parse(vergi)*adet).toStringAsFixed(2)}',
      });
      vergitoplam+=double.parse(vergi)*adet;
      print(vergitoplam.toStringAsFixed(2));
      toplam+=fiyat*adet;
    });
  }
  void incrementQuantity(int index) {
    if(int.parse(products[index]['stok'].toString())>0){
    setState(() {
      //products[index]['stok']=(int.parse( products[index]['stok'].toString())-1).toString();
      products[index]['price']=((double.parse(products[index]['price'])/int.parse(products[index]['quantity'].toString()))*(int.parse(products[index]['quantity'].toString()) + 1)).toStringAsFixed(2);
      products[index]['vergi']=((double.parse(products[index]['vergi'])/int.parse(products[index]['quantity'].toString()))*(int.parse(products[index]['quantity'].toString()) + 1)).toStringAsFixed(2);
      products[index]['quantity'] = (int.parse(products[index]['quantity'].toString()) + 1).toString();
      toplam+=double.parse(products[index]['price'])/int.parse(products[index]['quantity']);
      vergitoplam+=double.parse(products[index]['vergi'].toString())/int.parse(products[index]['quantity']);
      print(vergitoplam.toStringAsFixed(2));
      print(products[index]['stok'].toString());
      print(index.toString());
    });
  }}

  void decrementQuantity(int index) {

      int currentQuantity = int.parse(products[index]['quantity'].toString());

        if (currentQuantity > 1) {
          setState(() {
        //products[index]['stok']=(int.parse( products[index]['stok'].toString())+1).toString();
        products[index]['price']=((double.parse(products[index]['price'])/int.parse(products[index]['quantity']))*(int.parse(products[index]['quantity']) - 1)).toStringAsFixed(2);
        products[index]['vergi']=((double.parse(products[index]['vergi'])/int.parse(products[index]['quantity']))*(int.parse(products[index]['quantity']) - 1)).toStringAsFixed(2);
        products[index]['quantity'] = (currentQuantity - 1).toString();
        toplam-=double.parse(products[index]['price'])/int.parse(products[index]['quantity']);
        vergitoplam-=double.parse(products[index]['vergi'].toString())/int.parse(products[index]['quantity']);
        print(vergitoplam.toStringAsFixed(2));
        print(products[index]['stok'].toString());
      });
    }
  }
  sil(int index) {
    setState(() {
      toplam-=double.parse(products[index]['price'].toString());
      vergitoplam-=double.parse(products[index]['vergi'].toString());
      products.removeAt(index);
    });

  }
  Future<void> dateSorgu() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot documentSnapshot2 = await firestore.collection('${user!.email.toString()}magazaBilgiler').doc("magazaBilgiler").get();
    if(documentSnapshot2.exists){
      setState((){
        tarih=documentSnapshot2["date"].toString();
        belgeno=documentSnapshot2["belge"];
      });
  }
  print(tarih.toString());
    print(belgeno.toString());
  }
  TextEditingController urunAd= TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    dateSorgu();

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
              title: Text(AppLocalizations.of(context)!.kasa,style: TextStyle(color: Colors.white)),
              titlePadding: EdgeInsets.symmetric(vertical: 15),
              centerTitle: true,

            ),
          ),
          SliverPadding(padding: const EdgeInsets.all(8.0),sliver: SliverToBoxAdapter(
            child:Container(
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
                          labelText: AppLocalizations.of(context)!.aramaileEkle,
                        ),
                      );
                    },
                    onSelected: (String selection) {
                      final selectedDoc = snapshot.data!.docs.firstWhere(
                            (DocumentSnapshot document) => document['urunAdi'] == selection,
                        orElse: () => throw FlutterError('No matching document found for the selected product.'),
                      );
                      qr = selectedDoc.id;
                      urunsorgu(qr);
                      urunAd.text = selection;
                    },
                  );
                },
              ),
            ),
          ),),
          SliverPadding(
            padding: const EdgeInsets.all(8.0),
            sliver: SliverToBoxAdapter(
            child: Text("${AppLocalizations.of(context)!.toplamFiyat}:${toplam.toStringAsFixed(2)}$parabirim"),
          ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return ListTile(
                  title: Text(products[index]['name']),
                  subtitle: Text('${products[index]['price']}${products[index]['birim']}    ${products[index]['quantity']} ${AppLocalizations.of(context)!.adet}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () => decrementQuantity(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => incrementQuantity(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          sil(index);
                        },
                      ),
                    ],
                  ),
                );
              },
              childCount: products.length,

            ),
          ),
        ],
      ),
      floatingActionButton:Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: fisCikart,
            tooltip: 'Fiş Al',
            child: Icon(Icons.print),
          ),
        SizedBox(height: 20,),
        FloatingActionButton(
          onPressed: (){
            scanBarcode();
          },
          tooltip: 'Ürün Ekle',
          child: Icon(Icons.add),
        ),
      ],)
    );
  }
}

