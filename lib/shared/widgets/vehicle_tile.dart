/*
* Project      : autoconnectpro
* File         : vehicle_tile.dart
* Description  : 
* Author       : SrihariharanT
* Date         : 2025-05-05
* Version      : 1.0
* Ticket       : 
*/

import 'package:flutter/material.dart';

class VehicleTile extends StatelessWidget {
  final String title;
  final String value;

  const VehicleTile({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
