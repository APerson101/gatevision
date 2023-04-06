import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/repo/db.dart';
import 'package:gatevision/status%20pages/add_entrance_staff.dart';
import 'package:gatevision/status%20pages/add_exit_staff.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

import 'models/attendance.dart';
import 'models/staffmodel.dart';

class ShowStaffInfo extends ConsumerWidget {
  const ShowStaffInfo({super.key, required this.staff});
  final StaffModel staff;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isExiting = false;
    return ref.watch(getStaffType(staff)).when(data: (staffType) {
      //if staffType.licenseNumber!= -1, then staff is exiting
      if (staffType != null && staffType.licenseNumber != '-1') {
        isExiting = true;
      } else {
        isExiting = false;
      }
      return StaffContext(
        isExiting: isExiting,
        staff: staff,
        attendance: staffType?.licenseNumber == '-1' ? null : staffType,
      );
    }, error: (Object error, StackTrace stackTrace) {
      return const Scaffold(
          body: Center(
        child: Text("Failed"),
      ));
    }, loading: () {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()));
    });
  }
}

final getStaffType = FutureProvider.autoDispose
    .family<Attendance?, StaffModel>((ref, staff) async {
  var db = GetIt.instance<DatabaseHandler>();
  // get current attendance and check for entry without exit
  var allAttendance = await db.attendance?.where().findAll();
  for (var element in allAttendance!) {
    debugPrint('${element.licenseNumber}, ${element.exit.toString()}');
  }
  return allAttendance.firstWhere(
      (element) =>
          element.exit == null && element.licenseNumber == staff.licenseNumber,
      orElse: () {
    return Attendance()..licenseNumber = '-1';
  });
});

class StaffContext extends ConsumerWidget {
  StaffContext(
      {super.key,
      required this.isExiting,
      required this.staff,
      this.attendance});
  final bool isExiting;
  final StaffModel staff;
  final GetIt get = GetIt.instance;
  final Attendance? attendance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('${staff.firstname} ${staff.lastname}'),
            staff.image != null
                ? Image.memory(Uint8List.fromList(staff.image!))
                : Container(),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: () async {
                      Attendance newAt = Attendance();
                      isExiting
                          ? {
                              attendance!.exit = DateTime.now(),
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ExitStaffPage(attendance: attendance!)))
                            }
                          : {
                              newAt.entrance = DateTime.now(),
                              newAt.exit = null,
                              newAt.licenseNumber = staff.licenseNumber,
                              newAt.type = 0,
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      EntranceStaffPage(visitor: newAt)))
                            };
                    },
                    child:
                        Text(isExiting ? "Approve Exit" : "Approve Entrance")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
