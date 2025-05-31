import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/providers/ble_provider.dart';

class BleScanPage extends StatefulWidget {
  const BleScanPage({super.key});

  @override
  State<BleScanPage> createState() => _BleScanPageState();
}

class _BleScanPageState extends State<BleScanPage> {
  List<BluetoothDevice> connectedDevices = [];
  List<ScanResult> scanResults = [];
  bool isScanning = false;
  StreamSubscription<List<ScanResult>>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    // 권한 요청
    final scanStatus = await Permission.bluetoothScan.request();
    final connectStatus = await Permission.bluetoothConnect.request();
    final locationStatus = await Permission.locationWhenInUse.request();

    if (!scanStatus.isGranted || !connectStatus.isGranted || !locationStatus.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("블루투스 권한이 필요합니다.")),
        );
      }
      return;
    }

    setState(() {
      isScanning = true;
      scanResults.clear();
    });

    // 스캔 시작
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

    // 스캔 결과 구독 (한 번만 등록)
    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      setState(() {
        scanResults = results;
      });
    });

    // 10초 후 자동 종료
    await Future.delayed(const Duration(seconds: 10));
    await FlutterBluePlus.stopScan();

    setState(() {
      isScanning = false;
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 10));
      if (mounted) {
        // 연결된 기기 및 characteristic 저장
        final bleProvider = Provider.of<BleProvider>(context, listen: false);
        bleProvider.setDevice(device);

        List<BluetoothService> services = await device.discoverServices();
        for (BluetoothService service in services) {
          for (BluetoothCharacteristic c in service.characteristics) {
            if (c.properties.write) {
              bleProvider.setTxCharacteristic(c);
              break;
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${device.localName}에 연결되었습니다")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("연결 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '장치 연결',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            if (isScanning)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else
              ElevatedButton(
                onPressed: _startScan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                child: const Text("다시 검색"),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: scanResults.length,
                itemBuilder: (context, index) {
                  final result = scanResults[index];
                  final device = result.device;
                  return ListTile(
                    title: Text(device.localName.isNotEmpty
                        ? device.localName
                        : '(이름 없음)'),
                    subtitle: Text(device.id.toString()),
                    trailing: ElevatedButton(
                      onPressed: () => _connectToDevice(device),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text("연결"),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}