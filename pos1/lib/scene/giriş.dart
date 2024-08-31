import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'navigator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Giris extends StatefulWidget {
  @override
  _GirisState createState() => _GirisState();
}

class _GirisState extends State<Giris> {
  @override
  void initState() {
    super.initState();
    wifi();
    kontrol();
  }

  void wifi() async {
    var result = await Connectivity().checkConnectivity();
    switch (result) {
      case ConnectivityResult.wifi:
        break;
      case ConnectivityResult.mobile:
        break;
      case ConnectivityResult.none:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(AppLocalizations.of(context)!.baglanti),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        break;
    }
  }

  Future<void> kontrol() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    GoogleSignInAccount? googleSignInAccount = googleSignIn.currentUser;
    if (googleSignInAccount == null) {
      googleSignInAccount = await googleSignIn.signInSilently();
    }

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await firebaseAuth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null && !user.isAnonymous && await user.getIdToken() != null) {
        await checkSubscriptionStatus(user);
      } else {
        // Handle error
      }
    } else {
      // Handle error
    }
  }

  Future<void> giris() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    GoogleSignInAccount? googleSignInAccount = googleSignIn.currentUser;
    if (googleSignInAccount == null) {
      googleSignInAccount = await googleSignIn.signInSilently();
    }
    if (googleSignInAccount == null) {
      googleSignInAccount = await googleSignIn.signIn();
    }

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await firebaseAuth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null && !user.isAnonymous && await user.getIdToken() != null) {
        await checkSubscriptionStatus(user);
      } else {
        wifi();
      }
    } else {
      wifi();
    }
  }

  Future<void> checkSubscriptionStatus(User user) async {
    final DocumentSnapshot subscriptionSnapshot =
    await FirebaseFirestore.instance.collection('subscriptions').doc('${user.email.toString()}Bilgiler').get();

    if (subscriptionSnapshot.exists && subscriptionSnapshot['isActive']) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage()));
    } else {
      showSubscriptionDialog();
    }
  }

  void showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Abonelik'),
          content: Text(
            '30 Günlük deneme sürenizi şimdi başlatın. '
                'Deneme süreniz bittiyse aylık 59.99 TL ile uygulamanın bütün özelliklerinden yararlanmaya devam edin.',
          ),
          actions: [
            TextButton(
              child: Text('Vazgeç'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Devam Et'),
              onPressed: () async {
                Navigator.of(context).pop();
                await startSubscription();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> startSubscription() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (!available) {
      showErrorDialog('Satın alma işlemi şu anda kullanılamıyor.');
      return;
    }

    const Set<String> _kIds = <String>{'monthly_subscription'};
    final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.notFoundIDs.isNotEmpty) {
      showErrorDialog('Ürün bulunamadı.');
      return;
    }

    final ProductDetails productDetails = response.productDetails[0];
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
    InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);

    InAppPurchase.instance.purchaseStream.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Bekleyen satın alma işlemi
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        showErrorDialog('Satın alma işlemi sırasında hata oluştu.');
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        await FirebaseFirestore.instance
            .collection('subscriptions')
            .doc('${FirebaseAuth.instance.currentUser!.email.toString()}Bilgiler')
            .set({
          'isActive': true,
          'startDate': DateTime.now(),
          'endDate': DateTime.now().add(Duration(days: 30)),
        });
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage()));
      }

      if (purchaseDetails.pendingCompletePurchase) {
        InAppPurchase.instance.completePurchase(purchaseDetails);
      }
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hata'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.blueAccent,
            expandedHeight: 90.0,
            floating: false,
            pinned: true,
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              expandedTitleScale: 1.8,
              titlePadding: EdgeInsets.symmetric(vertical: 17),
              centerTitle: true,
              title: Text(
                AppLocalizations.of(context)!.giris,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                SizedBox(height: 90),
                CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: AssetImage("images/barkodKasamLogo.png"),
                ),
                SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.magazamcepte,
                  style: TextStyle(fontSize: 30),
                ),
                SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.magazanizicincozum,
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 90),
                ElevatedButton(
                  onPressed: () {
                    giris();
                  },
                  child: Text(
                    AppLocalizations.of(context)!.googlegiris,
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
