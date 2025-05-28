import 'package:flutter/material.dart';
import 'package:taste_q/views/front_appbar.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FrontAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            Expanded(child: _buildDeviceRow("images/tasteQ.png")),
            const SizedBox(height: 24),
            Expanded(child: _buildDeviceRow("images/elec_range.png")),
            const SizedBox(height: 24),
            Expanded(child: _buildDeviceRow("images/fridge.png")),
            const SizedBox(height: 36),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildDeviceRow(String imagePath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: 130,
          height: 130,
        ),
        Row(
          children: const [
            Text(
              "완료",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 12),
            Icon(Icons.check, color: Colors.green, size: 36),
          ],
        ),
      ],
    );
  }
}
