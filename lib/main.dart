import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey='pk_test_51KZYqYLQcMqN2tVhE38pSQsFa5d2jX9OOfoyB0EhgInQLGyWO02m8j3Xe43SjJQZe8Pk1BHtLXzbQYYidLacjHbi00EI9EZBZo';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Stripe test',

      home: HomeScreen(),
    );
  }
}

