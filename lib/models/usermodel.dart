import 'package:isar/isar.dart';

part 'usermodel.g.dart';

@collection
class UserModel {
  Id id = Isar.autoIncrement;
  String? firstname;
  String? lastname;
  String? userID;
  List<int>? image;
  String? email;
  String? password;
}
