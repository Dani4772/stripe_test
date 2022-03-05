import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _paymentIntentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Stripe Payment',
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await makePayment();
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: const BoxDecoration(color: Colors.green),
                child: const Center(
                  child: Text(
                    'Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      _paymentIntentData = await createPaymentIntent('20', 'USD');
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: _paymentIntentData!['client_secret'],
          applePay: true,
          googlePay: true,
          style: ThemeMode.dark,
          merchantCountryCode: 'US',
          merchantDisplayName: 'Spark Solutions',
        ),
      );
      await displayPaymentSheet();
    } catch (e) {
      debugPrint('makePayment -> Exception Occurred -> ${e.toString()}');
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet(
        parameters: PresentPaymentSheetParameters(
          clientSecret: _paymentIntentData!['client_secret'],
          confirmPayment: true,
        ),
      );
      setState(() {
        _paymentIntentData = null;
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paid Successfully'),
        ),
      );
    } on StripeException catch (e) {
      debugPrint('Stripe Exception Occurred -> ${e.toString()}');
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          content: Text('Payment Cancelled'),
        ),
      );
    } catch (e) {
      debugPrint('displayPaymentSheet -> Exception Occurred -> ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card',
      };

      //

      var response = await http.post(
        Uri.parse(
          'https://api.stripe.com/v1/payment_intents',
        ),
        body: body,
        headers: {
          'Authorization':
          'Bearer sk_test_51KZYqYLQcMqN2tVh1VBtEP60VCEfYuZ5jKUaAEhu3YdE2FqP6fO0DylDuqvFLinHNBFuqP2Sk8zvss6qigiFZwxn00nFcppcOn',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      return json.decode(response.body.toString());
    } catch (e) {
      debugPrint('createPaymentIntent -> Exception Occurred -> ${e.toString()}');
    }
  }

  String calculateAmount(String amount) =>
      (int.parse(amount) * 176.36).toInt().toString();
}