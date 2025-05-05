/*
* Project      : autoconnectpro
* File         : ble_service.dart
* Description  :
* Author       : SrihariharanT
* Date         : 2025-05-05
* Version      : 1.0
* Ticket       :
*/

import 'dart:typed_data';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
class BluetoothServices {
  BluetoothConnection? _connection;
  BluetoothDevice? _connectedDevice;

  Future<bool> checkPermissions() async {
    final bluetooth = await Permission.bluetooth.request();
    final location = await Permission.locationWhenInUse.request();
    return bluetooth.isGranted && location.isGranted;
  }

  Future<void> startScan({Duration timeout = const Duration(seconds: 4)}) async {
    if (!await checkPermissions()) {
      print("Bluetooth or Location permissions not granted");
      return;
    }

    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      print("Found ${result.device.name} - ${result.device.address}");
    });

    await Future.delayed(timeout);
    FlutterBluetoothSerial.instance.cancelDiscovery();
  }


  Future<bool> connectToDevice(BluetoothDevice device) async {
    try {
      print("Connecting to ${device.name}...");
      _connection = await BluetoothConnection.toAddress(device.address);
      _connectedDevice = device;
      print("Connected to ${device.name}");

      await sendDataToDevice("Hello, Device!");
      return true;
    } catch (e) {
      print("Connection failed: $e");
      return false;
    }
  }


  Future<void> sendDataToDevice(String data) async {
    if (_connection?.isConnected ?? false) {
      _connection!.output.add(Uint8List.fromList(data.codeUnits));
      await _connection!.output.allSent;
      print("Sent data: $data");
    } else {
      print("No connected device to send data.");
    }
  }

  Future<void> disconnect() async {
    if (_connection != null) {
      await _connection!.close();
      _connectedDevice = null;
      print("Disconnected from device.");
    }
  }
}



