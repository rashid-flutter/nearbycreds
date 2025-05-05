import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color color;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    this.onPressed,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen size
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * 0.8, // Button takes 80% of the screen width
      height: 50, // Fixed height, can also be dynamic based on screen height if desired
      child: ElevatedButton.icon(
        icon: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(icon ?? Icons.check, color: Colors.white,),
        label: Text(
          isLoading ? 'Please wait...' : label,
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        onPressed: isLoading ? null : onPressed,
      ),
    );
  }
}
