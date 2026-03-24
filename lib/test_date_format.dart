import 'package:intl/intl.dart';

void main() {
  final utcTime = DateTime.utc(2023, 1, 1, 10, 0);
  final localTime = utcTime.toLocal();
  
  print('UTC format: ${DateFormat('h:mm a').format(utcTime)}');
  print('Local format: ${DateFormat('h:mm a').format(localTime)}');
}
