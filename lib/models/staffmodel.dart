import 'package:isar/isar.dart';

part 'staffmodel.g.dart';

@collection
class StaffModel {
  Id id = Isar.autoIncrement;
  String? firstname;
  String? lastname;
  String? licenseNumber;
  String? staffID;
  List<int>? image;
}
