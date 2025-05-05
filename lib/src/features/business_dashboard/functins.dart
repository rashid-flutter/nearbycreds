import 'package:intl/intl.dart';

String formatDateWithRelative(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  String relative;
  if (difference.inDays >= 2) {
    relative = '${difference.inDays} days ago';
  } else if (difference.inDays == 1) {
    relative = '1 day ago';
  } else if (difference.inHours >= 1) {
    relative = '${difference.inHours} hours ago';
  } else if (difference.inMinutes >= 1) {
    relative = '${difference.inMinutes} minutes ago';
  } else {
    relative = 'Just now';
  }

  final formattedDate = DateFormat('dd-MM-yyyy').format(date);
  return '$formattedDate • $relative';
}
