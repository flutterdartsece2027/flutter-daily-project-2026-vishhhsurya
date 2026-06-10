import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;

  void initialize(Function(PaymentSuccessResponse) onSuccess, 
                  Function(PaymentFailureResponse) onFailure, 
                  Function(ExternalWalletResponse) onExternalWallet) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onFailure);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  void openCheckout(double amount, String contact, String email) {
    var options = {
      'key': 'rzp_test_SzoZgorxg14tvd',
      'amount': (amount * 100).toInt(), // amount in the smallest currency unit
      'name': 'Smart Taxi',
      'description': 'Ride Payment',
      'prefill': {'contact': contact, 'email': email},
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
