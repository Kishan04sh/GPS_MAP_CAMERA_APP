
import 'package:flutter/material.dart';

// ================= Modern Permission Tile =================
class PermissionTile extends StatelessWidget {
  final String title;
  final bool granted;
  final VoidCallback onTap;

  const PermissionTile({
    super.key,
    required this.title,
    required this.granted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: granted ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: granted ? Colors.green : Colors.red,
          child: Icon(
            granted ? Icons.check : Icons.close,
            size: 20,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          granted ? 'Granted' : 'Not granted',
          style: TextStyle(
            color: granted ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        trailing: Switch(
          value: granted,
          onChanged: (_) {
            if (!granted) onTap();
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.redAccent,
        ),
      ),
    );
  }
}


/// *************************************************************************
