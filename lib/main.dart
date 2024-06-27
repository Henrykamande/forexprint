import 'package:flutter/material.dart';
import 'package:forex_printing/printingforex.dart';
import 'package:forex_printing/utils/printer_settings.dart';
import 'package:forex_printing/utils/printert_test.dart';

import '../utils/printer_settings.dart';
import 'package:provider/provider.dart';

void main() => runApp(Stalisapp());

class Stalisapp extends StatelessWidget {
  const Stalisapp({Key? key}) : super(key: key);
  static const String title = "Stalis Pos";
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (cxt) => PrinterProvider(),
          // ),
          // ChangeNotifierProvider(
          //   create: (cxt) => GetProducts(),
          // ),
          // ChangeNotifierProvider(
          //   create: (cxt) => UserLogin(),
          // ),
          // ChangeNotifierProvider(
          //   create: (cxt) => DefaultPrinter(),
          // ),
          // ChangeNotifierProvider(
          //   create: (cxt) => PrinterService(),
        ),
        // ChangeNotifierProvider(
        //   create: (cxt) => DatabaseHelper(),
        // )
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/generalsettings': (context) => MyApp(),
          },
          title: title,
          home: Scaffold(
              appBar: AppBar(
                title: Text(title),
              ),
              body: MyApp() //LoginPage()
              )),
    );
  }
}
