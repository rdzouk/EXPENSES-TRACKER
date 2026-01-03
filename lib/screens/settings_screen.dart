// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class SettingsScreen extends StatelessWidget {
  final VoidCallback onRefresh;

  const SettingsScreen({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Info Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo[700]!, Colors.indigo[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Project Expense Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track your project finances with ease',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Application Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Currency Setting
          _buildSettingCard(
            icon: Icons.attach_money,
            title: 'Currency',
            subtitle: 'FCFA (Central African Franc)',
            color: Colors.green,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Currency: FCFA (Fixed)')),
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // About Setting
          _buildSettingCard(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Version 1.0.0',
            color: Colors.blue,
            onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('About'),
              content: const Text(
                'Project Expense Tracker v1.0.0\n\n'
                'An offline expense tracking app designed for project managers.\n\n'
                'Built with Flutter & Dart',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
      
      const SizedBox(height: 32),
      
      const Text(
        'Data Management',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      
      const SizedBox(height: 12),
      
      // Reset Data Button
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_forever, color: Colors.red),
          ),
          title: const Text(
            'Reset All Data',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          subtitle: const Text('Delete all transactions permanently'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
          onTap: () => _showResetConfirmation(context),
        ),
      ),
      
      const SizedBox(height: 32),
      
      // Warning message
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          border: Border.all(color: Colors.amber[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.amber[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Resetting data cannot be undone. Please backup important information.',
                style: TextStyle(
                  color: Colors.amber[900],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
);}
Widget _buildSettingCard({
required IconData icon,
required String title,
required String subtitle,
required Color color,
required VoidCallback onTap,
}) {
return Container(
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.05),
blurRadius: 10,
offset: const Offset(0, 2),
),
],
),
child: ListTile(
leading: Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: color.withOpacity(0.1),
borderRadius: BorderRadius.circular(8),
),
child: Icon(icon, color: color),
),
title: Text(
title,
style: const TextStyle(fontWeight: FontWeight.bold),
),
subtitle: Text(subtitle),
trailing: const Icon(Icons.arrow_forward_ios, size: 16),
onTap: onTap,
),
);
}
void _showResetConfirmation(BuildContext context) {
showDialog(
context: context,
builder: (context) => AlertDialog(
title: const Row(
children: [
Icon(Icons.warning, color: Colors.red),
SizedBox(width: 8),
Text('Reset All Data?'),
],
),
content: const Text(
'This will permanently delete all your transactions. This action cannot be undone.\n\nAre you sure you want to continue?',
),
actions: [
TextButton(
onPressed: () => Navigator.pop(context),
child: const Text('Cancel'),
),
ElevatedButton(
onPressed: () async {
await DatabaseHelper.instance.clearAllData();
onRefresh();
if (context.mounted) {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('All data has been reset'),
backgroundColor: Colors.red,
),
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.red,
foregroundColor: Colors.white,
),
child: const Text('Reset'),
),
],
),
);
}
}