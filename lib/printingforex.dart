import 'dart:async';

import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/shared_data.dart';

class PrinterProvider with ChangeNotifier {
  void _printEscPos(List<int> bytes, Generator generator) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceName = prefs.getString('deviceName');
    final productId = prefs.getString('productId');
    final vendorId = prefs.getString('vendorId');

    bytes += generator.feed(2);
    bytes += generator.cut();
    bytes += generator.drawer();

    //   await printerManager.connect(
    //       type: PrinterType.usb,
    //       model: UsbPrinterInput(
    //           name: deviceName, productId: productId, vendorId: vendorId));
    //   printerManager.send(type: PrinterType.usb, bytes: bytes);
    // }

    Future printReceipt(
        dynamic cartData,
        dynamic total,
        dynamic paid,
        dynamic balance,
        dynamic custName,
        dynamic docNum,
        String date,
        dynamic payments,
        dynamic changeDue,
        dynamic soldBy,
        dynamic companyDetails) async {
      List<int> bytes = [];
      final formatter = NumberFormat('#,###');
      final totalsformatter = NumberFormat('#,##0.00');

      // Xprinter XP-N160I
      final profile = await CapabilityProfile.load(name: 'XP-N160I');
      // PaperSize.mm80 or PaperSize.mm58
      final generator = Generator(PaperSize.mm80, profile);
      bytes += generator.setGlobalCodeTable('CP1252');

      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd kk:mm:ss').format(now);

      // if (custName != null) {
      //   bytes += generator.text(custName,
      //       styles: const PosStyles(bold: true, align: PosAlign.center),
      //       linesAfter: 1);
      // }

      // bytes += generator.text(formattedDate,
      //     styles: const PosStyles(bold: true, align: PosAlign.center),
      //     linesAfter: 1);

      final prefsData = await sharedData();
      var storeName = prefsData['storeName'];

      bytes += generator.text('SEVEN STAR ACCRA',
          styles: const PosStyles(
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
              align: PosAlign.center));

      bytes += generator.text('ACCRA TRADE CENTRE G5 ACCRA RD',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('TEL: 0797-951437 , 0723-802591',
          styles: const PosStyles(align: PosAlign.center));

      bytes += generator.text('NAIROBI',
          styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

      bytes += generator.row([
        PosColumn(
          text: 'Customer Name : $custName',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        )
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Date: $date',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        )
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Sale No: $docNum',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        )
      ]);

      bytes += generator.hr();
      bytes += generator.row([
        PosColumn(
          text: 'Description',
          width: 7,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Qty',
          width: 1,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: '@',
          width: 1,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        )
      ]);
      bytes += generator.hr();

      var productsList = cartData;

      for (var cartItem in productsList) {
        // bytes += generator.row([
        //   PosColumn(
        //     text: '  ${cartItem['name']}',
        //     width: 12,
        //     styles: const PosStyles(align: PosAlign.left),
        //   )
        // ]);

        // qty row
        bytes += generator.row([
          PosColumn(
            text: '(${cartItem['name'].toString()})',
            width: 7,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: cartItem['Quantity'].toString(),
            width: 1,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: formatter.format(double.parse(cartItem['Price'].toString())),
            width: 1,
            styles: const PosStyles(align: PosAlign.right),
          ),
          PosColumn(
            text: totalsformatter
                .format(double.parse(cartItem['LineTotal'].toString())),
            width: 3,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ]);
        bytes += generator.hr();
      }

      bytes += generator.row([
        PosColumn(
          text: 'Total Amount:',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: totalsformatter.format(total),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        )
      ]);

      bytes += generator.row([
        PosColumn(
          text: 'Amount Paid :',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: totalsformatter.format(paid),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        )
      ]);

      if (balance <= 0) {
        bytes += generator.row([
          PosColumn(
            text: 'Change :',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: totalsformatter.format(changeDue),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          )
        ]);
      }

      if (changeDue <= 0) {
        bytes += generator.row([
          PosColumn(
            text: 'Balance :',
            width: 6,
            styles: const PosStyles(align: PosAlign.left),
          ),
          PosColumn(
            text: totalsformatter.format(balance),
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          )
        ]);
      }

      bytes += generator.text('',
          styles: const PosStyles(bold: true, align: PosAlign.center),
          linesAfter: 1);

      bytes += generator.hr();

      bytes += generator.row([
        PosColumn(
          text: 'Payment Method (S)',
          width: 12,
          styles: const PosStyles(align: PosAlign.left),
        )
      ]);

      for (var payment in payments) {
        var amountPaid = payment.amount;
        if (amountPaid != '') {
          bytes += generator.row([
            PosColumn(
              text: '${payment.name.toString()} :',
              width: 6,
              styles: const PosStyles(align: PosAlign.left),
            ),
            PosColumn(
              text: totalsformatter.format(double.parse(payment.amount)),
              width: 6,
              styles: const PosStyles(align: PosAlign.right),
            )
          ]);
        }
      }

      bytes += generator.hr();

      bytes += generator.text('Paybill: 222111',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Account: 729491',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('You were served By: $soldBy',
          styles: const PosStyles(align: PosAlign.center));

      bytes += generator.hr();

      bytes += generator.text('Thanks you for shopping with us!',
          styles: const PosStyles(align: PosAlign.center));

      // bytes += generator.feed(2);
      // bytes += generator.cut();

      _printEscPos(bytes, generator);
    }

    Future orderPrintReciept(dynamic cartData) async {
      List<int> bytes = [];
      // Xprinter XP-N160I
      final profile = await CapabilityProfile.load(name: 'XP-N160I');
      // PaperSize.mm80 or PaperSize.mm58
      final generator = Generator(PaperSize.mm80, profile);
      generator.setStyles(PosStyles(align: PosAlign.left));

      bytes += generator.setGlobalCodeTable('CP1252');

      bytes += generator.text('MORIASI 3D ',
          styles: const PosStyles(
              bold: true,
              align: PosAlign.left,
              height: PosTextSize.size4,
              width: PosTextSize.size4),
          linesAfter: 2);

      bytes += generator.text('Project: BATU BATU                          ',
          styles: const PosStyles(
              bold: true,
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text('DANCUN MUNGABI                           ',
          styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size2),
          linesAfter: 4);
      bytes += generator.text(
        'SN MORIASI -STORE                                      ',
        styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2),
      );
      bytes += generator.text(
        'OrderNo: SO0002489                                      ',
        styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size2),
      );

      bytes += generator.text(
          '${DateTime.now()}                                   ',
          styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size2),
          linesAfter: 3);

      bytes += generator.text(
          '1. SAND PAPER ROUGH-P80 PER ROLL          3.3333',
          styles: const PosStyles(
              align: PosAlign.left,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size1),
          linesAfter: 2);

      bytes += generator.text(
        'Total :                                   3.3333',
        styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size2),
        linesAfter: 2,
      );

      bytes += generator.text('Order Request Received',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text('Issued By : .....',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text('Received By : .....',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text('Utilised: Yes ..../NO ....',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text(
        'Returns: .....',
        styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size1,
            width: PosTextSize.size2),
        linesAfter: 2,
      );
      bytes += generator.text('You are good to go!',
          styles: const PosStyles(align: PosAlign.center));

      _printEscPos(bytes, generator);
    }

    Future moriasiPrintReciept(
        dynamic cartData, totalbill, currentProjects, currentProjectID) async {
      print(cartData);
      print(currentProjectID.runtimeType);

      var selectedProject = currentProjects.firstWhere(
          (project) => project['id'] == int.parse(currentProjectID),
          orElse: () => null);
      print(
          '$selectedProject--------------------------------------------------------------------');
      List<int> bytes = [];

      final profile = await CapabilityProfile.load(name: 'XP-N160I');
      // PaperSize.mm80 or PaperSize.mm58
      final generator = Generator(PaperSize.mm80, profile);
      generator.setStyles(PosStyles(align: PosAlign.left));

      bytes += generator.setGlobalCodeTable('CP1252');

      bytes += generator.text('MORIASI 3D ',
          styles: const PosStyles(
              bold: true,
              align: PosAlign.left,
              height: PosTextSize.size3,
              width: PosTextSize.size3),
          linesAfter: 2);

      bytes += generator.text(
          'Project: ${selectedProject['name']}                          ',
          styles: const PosStyles(
              bold: true,
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size1),
          linesAfter: 2);

      bytes += generator.text('DANCUN MUNGABI                           ',
          styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size1),
          linesAfter: 4);
      bytes += generator.text(
        'SN MORIASI -STORE                                      ',
        styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1),
      );
      bytes += generator.text(
        'OrderNo: SO0002489                                      ',
        styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size2,
            width: PosTextSize.size1),
      );

      bytes += generator.text(
          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}                                   ',
          styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size2,
              width: PosTextSize.size1),
          linesAfter: 3);
      for (var item in cartData) {
        bytes += generator.text(
            '${item['name']}        ${item['Quantity']}  ${item['uomName']}',
            styles: const PosStyles(
                align: PosAlign.left,
                bold: true,
                height: PosTextSize.size1,
                width: PosTextSize.size1),
            linesAfter: 2);
      }

      // bytes += generator.text(
      //   'Total :                                   3.3333',
      //   styles: const PosStyles(
      //       align: PosAlign.left,
      //       height: PosTextSize.size1,
      //       width: PosTextSize.size2),
      //   linesAfter: 2,
      // );

      bytes += generator.text('Order Request Received',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text('Issued By : ..........',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text('Received By : ........',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text('Utilised:Yes .../NO ...',
          styles: const PosStyles(
              align: PosAlign.center,
              bold: true,
              height: PosTextSize.size1,
              width: PosTextSize.size2),
          linesAfter: 2);

      bytes += generator.text(
        'Returns: ...........',
        styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size1,
            width: PosTextSize.size2),
        linesAfter: 2,
      );
      bytes += generator.text('You are good to go!',
          styles: const PosStyles(align: PosAlign.center));

      _printEscPos(bytes, generator);
    }
  }
}
