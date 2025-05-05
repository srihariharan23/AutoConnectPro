/*
* Project      : autoconnectpro
* File         : home_screen.dart
* Description  : BLE scanning UI with runtime permission handling
* Author       : SrihariharanT
* Date         : 2025-05-05
* Version      : 1.1
* Ticket       : BLE-Scan-UI
*/

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../shared/widgets/vehicle_tile.dart';
import '../ble/ble_service.dart';
import 'package:device_info_plus/device_info_plus.dart';



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isScanning = false;
  final Set<String> _deviceAddresses = {};
  final List<BluetoothDiscoveryResult> devices = [];
  final BluetoothServices _bluetoothService = BluetoothServices();

  Future<bool> _checkPermissions() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (Platform.isAndroid) {
      final androidVersion = int.parse(androidInfo.version.sdkInt.toString());

      if (androidVersion >= 31) {
        // Android 12+ needs BLUETOOTH_SCAN and BLUETOOTH_CONNECT
        final bluetoothScan = await Permission.bluetoothScan.request();
        final bluetoothConnect = await Permission.bluetoothConnect.request();
        final location = await Permission.locationWhenInUse.request();

        return bluetoothScan.isGranted && bluetoothConnect.isGranted && location.isGranted;
      } else {
        // For older versions
        final bluetooth = await Permission.bluetooth.request();
        final location = await Permission.locationWhenInUse.request();

        return bluetooth.isGranted && location.isGranted;
      }
    }

    return true; // iOS or others
  }


  void _startScan() async {
    final granted = await _checkPermissions();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bluetooth/Location permission denied")),
      );
      return;
    }

    setState(() {
      isScanning = true;
      devices.clear();
      _deviceAddresses.clear();
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      if (_deviceAddresses.contains(result.device.address)) return;

      setState(() {
        devices.add(result);
        _deviceAddresses.add(result.device.address);
      });
    });

    await Future.delayed(const Duration(seconds: 5));
    FlutterBluetoothSerial.instance.cancelDiscovery();

    setState(() => isScanning = false);
  }

  void _connectToDevice(BluetoothDevice device) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Connecting to ${device.name ?? "Device"}...")),
    );

    final success = await _bluetoothService.connectToDevice(device);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? "Connected to ${device.name ?? "Device"}"
              : "Failed to connect to ${device.name ?? "Device"}",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AutoConnect Pro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: isScanning ? null : _startScan,
              icon: const Icon(Icons.bluetooth_searching),
              label:
              Text(isScanning ? "Scanning..." : "Scan for Vehicle (Bluetooth)"),
            ),
            const SizedBox(height: 20),
            const Text("Vehicle Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const VehicleTile(title: "Battery Level", value: "89%"),
            const VehicleTile(title: "Fuel", value: "65%"),
            const VehicleTile(title: "Engine Temp", value: "78°C"),
            const VehicleTile(title: "Tire Pressure", value: "34 PSI"),
            const SizedBox(height: 20),
            const Divider(),
            const Text("Discovered Devices", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].device;
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.name ?? "Unnamed Device"),
                    subtitle: Text(device.address),
                    onTap: () => _connectToDevice(device),
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




