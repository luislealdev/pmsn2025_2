import 'package:flutter/material.dart';

class FirebaseErrorBanner extends StatelessWidget {
  final bool showError;
  final VoidCallback? onDismiss;
  
  const FirebaseErrorBanner({
    super.key,
    required this.showError,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!showError) return SizedBox.shrink();
    
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[600],
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Problema con Firebase',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[800],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Se cambió automáticamente al almacenamiento local. Tus datos están seguros.',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onDismiss != null) ...[
            SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: Colors.orange[600],
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }
}