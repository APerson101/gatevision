import 'package:isar/isar.dart';

part 'attendance.g.dart';

@collection
class Attendance {
  Id id = Isar.autoIncrement;
  String? licenseNumber;
  int? type;
  DateTime? entrance;
  DateTime? exit;
}
