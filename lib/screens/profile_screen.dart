import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 15),
          CircleAvatar(
            radius: 48,
            backgroundColor: Color(0xFFE2F2ED),
            child: Icon(Icons.person, size: 55, color: AppColors.primary),
          ),
          SizedBox(height: 14),
          Text(
            'Safvan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Expense Manager User',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey),
          ),
          SizedBox(height: 30),
          _ProfileTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
            onTap: () => _showMessage(context),
          ),
          _ProfileTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => _showMessage(context),
          ),
          _ProfileTile(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            onTap: () => _showMessage(context),
          ),
          _ProfileTile(
            icon: Icons.info_outline,
            title: 'About App',
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Expenzia',
                applicationVersion: '1.0.0',
                applicationLegalese: 'Expense Management Application',
              );
            },
          ),
        ],
      ),
    );
  }

  static void _showMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('This feature is not implemented yet.')),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
        trailing: Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
