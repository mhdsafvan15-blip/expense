import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CreditScreen extends StatelessWidget {
  const CreditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Credit', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Container(
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(height: 18),
                Text('Total Credit', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                Text(
                  '₹ 0.00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track your credit records',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(height: 25),
          Text(
            'Credit Overview',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFE2F2ED),
                  child: Icon(Icons.info_outline, color: AppColors.primary),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No credit records available yet.',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
