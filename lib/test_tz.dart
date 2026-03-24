import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tz.initializeTimeZones();
  try {
    final loc = tz.getLocation('Asia/Calcutta');
    print('Found: ${loc.name}');
  } catch (e) {
    print('Error: $e');
  }
}
