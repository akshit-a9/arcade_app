import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'coins.dart';  // Ensure coins.dart is imported to use CoinManager

class ShopCoins extends StatefulWidget {
  @override
  _ShopCoinsState createState() => _ShopCoinsState();
}

class _ShopCoinsState extends State<ShopCoins> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final String _productID = 'buy_1000_coins'; // Define your product ID here

  @override
  void initState() {
    super.initState();
    final purchaseUpdates = _inAppPurchase.purchaseStream;
    purchaseUpdates.listen((purchases) {
      _handlePurchaseUpdates(purchases);
    });
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyPurchase(purchase);
      }
    }
  }

  void _verifyPurchase(PurchaseDetails purchase) async {
    // Here, you'd typically verify the purchase with your server and grant the coins.
    if (purchase.productID == _productID) {
      CoinManager.convertPointsToCoins(1000, 30).then((success) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('1000 coins purchased for ₹ 30.00!'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to process purchase.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      });
    }
  }

  Future<void> _buyCoins() async {
    final productDetails = await _inAppPurchase.queryProductDetails({_productID});
    if (productDetails.notFoundIDs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product not found!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final ProductDetails product = productDetails.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Ensures back button is present
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 169, 169, 169)), // Greyish white color
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Color.fromARGB(252, 0, 0, 0),
      ),
      body: Container(
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/BM.jpg"),
            fit: BoxFit.cover,
          ),
          border: Border.all(
            color: Color.fromARGB(252, 0, 0, 0),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Buy Coins Here!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 171, 84, 248),
                ),
              ),
              SizedBox(height: 20),
              // In-App Purchase Button at the top
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Card(
                  color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/Rupee.png',
                              width: 30,  // Set the size of the image to be small
                              height: 30,
                            ),
                            Text(
                              ' 1000 Coins ',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 171, 84, 248),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5), // Space between lines
                        Text(
                          'In-App Purchase',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: _buyCoins,
                      child: Text('₹ 30.00'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 171, 84, 248),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    CoinPurchaseItem(coinAmount: 100, points: 1000),
                    CoinPurchaseItem(coinAmount: 200, points: 1800),
                    CoinPurchaseItem(coinAmount: 500, points: 4000),
                    CoinPurchaseItem(coinAmount: 800, points: 6000),
                    CoinPurchaseItem(coinAmount: 1000, points: 7000),
                    CoinPurchaseItem(coinAmount: 2000, points: 13000),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class CoinPurchaseItem extends StatelessWidget {
  final int coinAmount;
  final int points;

  CoinPurchaseItem({required this.coinAmount, required this.points});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Card(
        color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: ListTile(
          title: Row(
            children: [
              Image.asset(
                'assets/images/Rupee.png',
                width: 30,  // Set the size of the image to be very small
                height: 30,
              ),
              Text(
                ' $coinAmount ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 171, 84, 248),
                ),
              ),
            ],
          ),
          subtitle: Text(
            '$points Points',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          trailing: ElevatedButton(
            onPressed: () => buyCoins(context, coinAmount, points),
            child: Text('Buy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 171, 84, 248),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void buyCoins(BuildContext context, int coinAmount, int pointsToDeduct) {
    CoinManager.convertPointsToCoins(pointsToDeduct, coinAmount).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$coinAmount coins added to your balance!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Not enough points to buy $coinAmount coins.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add coins: $error'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
