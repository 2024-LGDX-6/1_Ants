import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';

class BleProvider with ChangeNotifier {
  BluetoothDevice? _device;
  BluetoothCharacteristic? _txCharacteristic;

  BluetoothDevice? get device => _device;
  BluetoothCharacteristic? get txCharacteristic => _txCharacteristic;

  void setDevice(BluetoothDevice device) {
    _device = device;
    notifyListeners();
  }

  void setTxCharacteristic(BluetoothCharacteristic characteristic) {
    _txCharacteristic = characteristic;
    notifyListeners();
  }

  void clear() {
    _device = null;
    _txCharacteristic = null;
    notifyListeners();
  }
}