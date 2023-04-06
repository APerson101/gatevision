import 'package:edit_distance/edit_distance.dart';
import 'package:flutter/material.dart';
import 'package:gatevision/licenseviewer.dart';
import 'package:gatevision/models/attendance.dart';
import 'package:gatevision/models/staffmodel.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:isar/isar.dart';

import '../models/usermodel.dart';

class DatabaseHandler {
  Isar isar;
  IsarCollection<StaffModel>? staffs;
  IsarCollection<Attendance>? attendance;
  IsarCollection<UserModel>? users;
  UserModel? activeUser;
  TextRecognizer textRecognizer;
  DatabaseHandler({required this.isar, required this.textRecognizer}) {
    staffs = isar.staffModels;
    attendance = isar.attendances;
    users = isar.userModels;
  }
  IsarCollection<StaffModel>? getAllStaff() => staffs;
  getAllAttendance() => attendance;

  addUpdateNewStaff(StaffModel newStaff) async {
    await isar.writeTxn(() async {
      await isar.staffModels.put(newStaff);
    });
  }

  addUpdateNewRecord(Attendance attendance) async {
    await isar.writeTxn(() async {
      await isar.attendances.put(attendance);
    });
  }

  deleteStaff(int id) async {
    await isar.writeTxn(() async {
      await isar.staffModels.delete(id);
    });
  }

  deleteUser(int id) async {
    await isar.writeTxn(() async {
      await isar.userModels.delete(id);
    });
  }

  deleteRecord(int attendanceID) async {
    await isar.writeTxn(() async {
      await isar.attendances.delete(attendanceID);
    });
  }

  Future<List<UserModel>?>? getAllUsers() async {
    return await users?.where().findAll();
  }

  setActiveUser(UserModel user) async {
    activeUser = user;
  }

  Future<UserModel?>? getspecificUser(String email, String password) async {
    return await users
        ?.filter()
        .emailEqualTo(email)
        .passwordEqualTo(password)
        .findFirst();
  }

  addUpdateNewUser(UserModel user) async {
    await isar.writeTxn(() async {
      await isar.userModels.put(user);
    });
  }

  Isar getIsar() => isar;

  runOCR(String filePath) async {
    final inputImage = InputImage.fromFilePath(filePath);
    final RecognizedText text = await textRecognizer.processImage(inputImage);
    var reg = text.text;
    textRecognizer.close();
    var replaced = reg.trim().toLowerCase().replaceAll(RegExp(r'\n'), ' ');
    Levenshtein l = Levenshtein();
    var words = replaced.split(' ');
    var copied = words;
    if (words.isEmpty) return '';
    for (var word in words) {
      for (var state in states) {
        if (l.distance(word.toLowerCase(), state.toLowerCase()) == 1) {
          copied.remove(word);
        }
      }
    }
    for (var word in words) {
      for (var slogan in slogans) {
        if (l.distance(word.toLowerCase(), slogan.toLowerCase()) == 1) {
          copied.remove(word);
        }
      }
    }
    var finalSentence = '';
    for (var word in copied) {
      finalSentence += '$word ';
    }
    debugPrint("FINAL SENTENCE IS: $finalSentence");
    return finalSentence;
  }
}
