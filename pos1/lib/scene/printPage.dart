import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';

class PrintPage extends StatefulWidget{
  final List<Map<String,dynamic>> data;
  final double vergitoplam;
  final double toplam;
  final String magazaad;
  final String magazaadres;
  final String vkno;
  late final int belgeno;
  PrintPage(this.data,this.vergitoplam,this.toplam,this.magazaad,this.magazaadres,this.vkno,this.belgeno);
  @override
  _PrintPageState createState()=>_PrintPageState();
}

class _PrintPageState  extends State<PrintPage>{
  int belge=0;
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  String tire="-----------------------------";
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';
  int clickSayi=0;
  @override
  void initState() {
    belge=widget.belgeno;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await textduzen();
      initBluetooth();
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {

    bluetoothPrint.startScan(timeout: Duration(seconds: 3));

    bool isConnected=await bluetoothPrint.isConnected??false;

    bluetoothPrint.state.listen((state) {
      print('******************* cur device status: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = 'connect success';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = 'disconnect success';
          });
          break;
        default:
          break;
      }
    });

    if (!mounted) return;

    if(isConnected) {
      setState(() {
        _connected=true;
      });
    }
  }
  late final splittedAD;
  late String magazaAD;
  late String mgzadresAD;
  late String magazaD;
  late String mgzadres;
  String bslk="                 ";
  late List<String> bosluk;
  late List<String> urunad;
  Future<void> textduzen() async {
    /*final User? user = FirebaseAuth.instance.currentUser;
    int s=0;
    do{
      if( int.parse(widget.data[s]['stok'].toString()) <0){
        widget.data[s]['stok']="0";
      }
      await FirebaseFirestore.instance.collection(user!.email.toString()).doc(widget.data[s]['qr'].toString()).update(
          {
            'urunStok':widget.data[s]['stok'].toString()
          });
      s++;
    }while(s<=widget.data.length-1);*/
    setState(() {
      bosluk=List.generate(widget.data.length, (index) => "                        ");
      urunad=List.generate(widget.data.length, (index) => "");
      for(int i=0;i<widget.data.length;i++){
        final splittedurun= widget.data[i]['name'].toString().split(" ");
        String urunadi=splittedurun[0].toString();
        String urna=splittedurun[0].toString();
        for(int f=0;f<splittedurun.length-1;f++){
          int a=f+1;
          if(urna.characters.length+splittedurun[a].characters.length<14){
            urunadi+=" ${splittedurun[a]}";
            urna+=" ${splittedurun[a]}";
          }else{
            urunadi+="\n${splittedurun[a]}";
            urna="\n${splittedurun[a]}";
          }
        }

        int b=urna.characters.length-1+widget.data[i]['quantity'].toString().characters.length;
        bosluk[i]=bslk.replaceRange(0, b, "");
        urunad[i]=urunadi.toString();
      }

      splittedAD= widget.magazaad.split(" ");
      magazaAD=splittedAD[0].toString();
      mgzadresAD=splittedAD[0].toString();
      for(int i=0;i<splittedAD.length-1;i++){
        int a=i+1;
        if(mgzadresAD.characters.length+splittedAD[a].characters.length<20){
          magazaAD+=" ${splittedAD[a]}";
          mgzadresAD+="${splittedAD[a]}";
        }else{
          magazaAD+="\n${splittedAD[a]}";
          mgzadresAD="\n${splittedAD[a]}";
        }

      }

      final splitted= widget.magazaadres.split(" ");
      magazaD=splitted[0].toString();
      mgzadres=splitted[0].toString();
      for(int i=0;i<splitted.length-1;i++){
        int a=i+1;

        if(mgzadres.characters.length+splitted[a].characters.length<24){
          magazaD+=" ${splitted[a]}";
          mgzadres+="${splitted[a]}";
        }else{
          magazaD+="\n${splitted[a]}";
          mgzadres="\n${splitted[a]}";
        }

      }

    });

  }
  String replaceTurkishCharacters(String input) {
    final replacements = {
      'ç': 'c',
      'Ç': 'C',
      'ğ': 'g',
      'Ğ': 'G',
      'ı': 'i',
      'İ': 'I',
      'ö': 'o',
      'Ö': 'O',
      'ş': 's',
      'Ş': 'S',
      'ü': 'u',
      'Ü': 'U',
    };

    replacements.forEach((key, value) {
      input = input.replaceAll(key, value);
    });

    return input;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(AppLocalizations.of(context)!.yazicisec, style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: RefreshIndicator(
          onRefresh: () => bluetoothPrint.startScan(timeout: Duration(seconds: 3)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[],
                ),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!.map((d) => ListTile(
                      leading: Icon(Icons.print),
                      title: Text(d.name ?? ''),
                      subtitle: Text(d.address ?? ''),
                      onTap: () async {
                        setState(() {
                          _device = d;
                        });
                        if (_device != null && _device!.address != null) {
                          await bluetoothPrint.connect(_device!);
                        }
                      },
                      trailing: _device != null && _device!.address == d.address ? Icon(
                        Icons.check,
                        color: Colors.blue,
                      ) : null,
                    )).toList(),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(width: 10.0),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            StreamBuilder<bool>(
              stream: bluetoothPrint.isScanning,
              initialData: false,
              builder: (c, snapshot) {
                if (snapshot.data == true) {
                  return FloatingActionButton(
                    child: Icon(Icons.stop, color: Colors.white),
                    onPressed: () => bluetoothPrint.stopScan(),
                    backgroundColor: Colors.blue,
                  );
                } else {
                  return FloatingActionButton(
                      child: Icon(Icons.search, color: Colors.white),
                      backgroundColor: Colors.blue[400],
                      onPressed: () async {
                        bluetoothPrint.startScan(timeout: Duration(seconds: 4));
                      }
                  );
                }
              },
            ),
            SizedBox(height: 10),
            FloatingActionButton(
                backgroundColor: Colors.blue[400],
                child: Icon(Icons.bluetooth_disabled, color: Colors.red),
                onPressed: _connected ? () async {
                  await bluetoothPrint.disconnect().then((value) => bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
                } : null
            ),
            SizedBox(height: 10),
            FloatingActionButton(
              child: Icon(Icons.print, color: Colors.white),
              onPressed: _connected ? () async {
                await stok();
                Map<String, dynamic> config = {};
                List<LineText> list = [];
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: replaceTurkishCharacters('${magazaAD.toUpperCase()}\n${magazaD.toUpperCase()}'),
                    weight: 0,
                    align: LineText.ALIGN_CENTER,
                    linefeed: 1,
                  ),
                );
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: replaceTurkishCharacters('${AppLocalizations.of(context)!.vkno} ${widget.vkno}\n'),
                    weight: 0,
                    align: LineText.ALIGN_CENTER,
                    linefeed: 1,
                  ),
                );
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: tire,
                    weight: 0,
                    align: LineText.ALIGN_CENTER,
                    linefeed: 1,
                  ),
                );
                for (var i = 0; i <= widget.data.length - 1; i++) {
                  list.add(
                    LineText(
                      type: LineText.TYPE_TEXT,
                      content: replaceTurkishCharacters("${urunad[i].toUpperCase()}*${widget.data[i]['quantity']}${bosluk[i]}%${widget.data[i]['kdv']} ${widget.data[i]['price']}"),
                      weight: 0,
                      align: LineText.ALIGN_LEFT,
                      linefeed: 1,
                    ),
                  );
                }
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: tire,
                    weight: 0,
                    align: LineText.ALIGN_CENTER,
                    linefeed: 1,
                  ),
                );
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: replaceTurkishCharacters("${AppLocalizations.of(context)!.kdv}    ${widget.vergitoplam.toStringAsFixed(2)}\n${AppLocalizations.of(context)!.toplam} ${widget.toplam}\n"),
                    weight: 0,
                    align: LineText.ALIGN_LEFT,
                    linefeed: 1,
                  ),
                );
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: tire,
                    weight: 0,
                    align: LineText.ALIGN_CENTER,
                    linefeed: 1,
                  ),
                );
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: replaceTurkishCharacters("${AppLocalizations.of(context)!.fisno} ${belge.toString()}"),
                    weight: 0,
                    align: LineText.ALIGN_CENTER,
                    linefeed: 1,
                  ),
                );
                list.add(
                  LineText(
                    type: LineText.TYPE_TEXT,
                    content: replaceTurkishCharacters("${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}  ${AppLocalizations.of(context)!.saat} ${DateTime.now().hour}:${DateTime.now().minute}"),
                    weight: 0,
                    align: LineText.ALIGN_CENTER,
                    linefeed: 1,
                  ),
                );

                return await bluetoothPrint.printReceipt(config, list);

                //await bluetoothPrint.disconnect();
              } : null,
              backgroundColor: _connected ? Colors.blue[400] : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  Future<void> stok() async {
    if (clickSayi == 0) {
      clickSayi++;
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final User? user = FirebaseAuth.instance.currentUser;
      int s = 0;

      // Döngü düzeltildi
      while (s < widget.data.length) {
        int currentStok = int.parse(widget.data[s]['stok'].toString());
        int quantity = int.parse(widget.data[s]['quantity'].toString());

        currentStok -= quantity;

        if (currentStok <= 0) {
          currentStok = 0;
        }

        // Stok bilgisini güncelleme
        widget.data[s]['stok'] = currentStok;

        // Firestore güncellemesi
        await firestore.collection(user!.email.toString()).doc(widget.data[s]['qr'].toString()).update({
          'urunStok': currentStok.toString(),
        });

        s++;
      }

      // Belge numarası güncellemesi

      belge++;
      setState(() {});
       await firestore.collection('${user!.email.toString()}magazaBilgiler').doc("magazaBilgiler").update({
        'belge': belge,
      });

    }
  }


}