import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;

  bool _connected = false;
  BluetoothDevice? _device;
  String tips = 'no device connect';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initBluetooth() async {
    bluetoothPrint.startScan(timeout: Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

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

    if (isConnected) {
      setState(() {
        _connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BluetoothPrint example app'),
        ),
        body: RefreshIndicator(
          onRefresh: () =>
              bluetoothPrint.startScan(timeout: Duration(seconds: 4)),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text(tips),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder<List<BluetoothDevice>>(
                  stream: bluetoothPrint.scanResults,
                  initialData: [],
                  builder: (c, snapshot) => Column(
                    children: snapshot.data!
                        .map((d) => ListTile(
                              title: Text(d.name ?? ''),
                              subtitle: Text(d.address ?? ''),
                              onTap: () async {
                                setState(() {
                                  _device = d;
                                });
                              },
                              trailing: _device != null &&
                                      _device!.address == d.address
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                            ))
                        .toList(),
                  ),
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          OutlinedButton(
                            child: Text('connect'),
                            onPressed: _connected
                                ? null
                                : () async {
                                    if (_device != null &&
                                        _device!.address != null) {
                                      setState(() {
                                        tips = 'connecting...';
                                      });
                                      await bluetoothPrint.connect(_device!);
                                    } else {
                                      setState(() {
                                        tips = 'please select device';
                                      });
                                      print('please select device');
                                    }
                                  },
                          ),
                          SizedBox(width: 10.0),
                          OutlinedButton(
                            child: Text('disconnect'),
                            onPressed: _connected
                                ? () async {
                                    setState(() {
                                      tips = 'disconnecting...';
                                    });
                                    await bluetoothPrint.disconnect();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      Divider(),
                      OutlinedButton(
                        child: Text('print receipt(esc)'),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = Map();

                                List<LineText> list = [];

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '         ---------------     ',
                                    weight: 2,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        'REGIONAL FOREX BUREAU LIMITED (KIMATHI)',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    fontZoom: 1,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Kimathi House, Kimathi Street',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    fontZoom: 2,
                                    linefeed: 1));

                                list.add(LineText(linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   P.O BOX 634 ---00100',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '      Nairobi ---  Kenya',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: "  Tel . TEL:313279\\90",
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Cell:',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: 'Email:regionalfx@gmail.com',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: ' ---------------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '  Receipt No  : F2962',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: ' ---------------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Date: 07---May---2024',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '    Time: 12:48:36',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: ' ---------------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Served By: TELLER 1',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: ' ---------------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   CASH PURCHASE',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: ' ---------------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: ' Curr   Amount  Rate  KES     Eq',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        ' USD  8,000  128   1,024,000.00    ',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content:
                                        ' TOTAL KES          1,024,000.00        ',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: ' ---------------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Source of Funds',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   4. Service Receipts',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Business',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Customer ID:  20332467',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Name: David Maina',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Address: 2547025904906',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Sign ----------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '   Aproved -------------------',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    content: '      Best Rates, Best Service ',
                                    weight: 1,
                                    align: LineText.ALIGN_CENTER,
                                    linefeed: 1));
                                list.add(LineText(linefeed: 1));

                                // ByteData data = await rootBundle
                                //     .load("assets/images/bluetooth_print.png");
                                // List<int> imageBytes = data.buffer.asUint8List(
                                //     data.offsetInBytes, data.lengthInBytes);
                                // String base64Image = base64Encode(imageBytes);
                                // // list.add(LineText(type: LineText.TYPE_IMAGE, content: base64Image, align: LineText.ALIGN_CENTER, linefeed: 1));

                                await bluetoothPrint.printReceipt(config, list);
                              }
                            : null,
                      ),
                      OutlinedButton(
                        child: Text('print label(tsc)'),
                        onPressed: _connected
                            ? () async {
                                Map<String, dynamic> config = Map();
                                config['width'] = 40; // 标签宽度，单位mm
                                config['height'] = 70; // 标签高度，单位mm
                                config['gap'] = 2; // 标签间隔，单位mm

                                // x、y坐标位置，单位dpi，1mm=8dpi
                                List<LineText> list = [];
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 10,
                                    content: 'A Title'));
                                list.add(LineText(
                                    type: LineText.TYPE_TEXT,
                                    x: 10,
                                    y: 40,
                                    content: 'this is content'));
                                list.add(LineText(
                                    type: LineText.TYPE_QRCODE,
                                    x: 10,
                                    y: 70,
                                    content: 'qrcode i\n'));
                                list.add(LineText(
                                    type: LineText.TYPE_BARCODE,
                                    x: 10,
                                    y: 190,
                                    content: 'qrcode i\n'));

                                List<LineText> list1 = [];
                                ByteData data = await rootBundle
                                    .load("assets/images/guide3.png");
                                List<int> imageBytes = data.buffer.asUint8List(
                                    data.offsetInBytes, data.lengthInBytes);
                                String base64Image = base64Encode(imageBytes);
                                list1.add(LineText(
                                  type: LineText.TYPE_IMAGE,
                                  x: 10,
                                  y: 10,
                                  content: base64Image,
                                ));

                                await bluetoothPrint.printLabel(config, list);
                                await bluetoothPrint.printLabel(config, list1);
                              }
                            : null,
                      ),
                      OutlinedButton(
                        child: Text('print selftest'),
                        onPressed: _connected
                            ? () async {
                                await bluetoothPrint.printTest();
                              }
                            : null,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        floatingActionButton: StreamBuilder<bool>(
          stream: bluetoothPrint.isScanning,
          initialData: false,
          builder: (c, snapshot) {
            if (snapshot.data == true) {
              return FloatingActionButton(
                child: Icon(Icons.stop),
                onPressed: () => bluetoothPrint.stopScan(),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                  child: Icon(Icons.search),
                  onPressed: () =>
                      bluetoothPrint.startScan(timeout: Duration(seconds: 4)));
            }
          },
        ),
      ),
    );
  }
}
