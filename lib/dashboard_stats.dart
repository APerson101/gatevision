import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gatevision/models/attendance.dart';
import 'package:gatevision/models/staffmodel.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';

import 'new_staff_form.dart';

class DashboardStats extends ConsumerWidget {
  const DashboardStats({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [_ButtonsView(), _LatestAttendance()],
      ),
    );
  }
}

class _ButtonsView extends ConsumerWidget {
  const _ButtonsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // activate listeners
    Widget staffCount = ref.watch(staffCountStreamProvider).when(
        data: (data) {
          return Text(
            ref.watch(numberOfStaff).toString(),
            style: const TextStyle(
                fontSize: 17, color: Colors.white, fontWeight: FontWeight.bold),
          );
        },
        error: (er, sr) => const Text("error"),
        loading: () => const CircularProgressIndicator.adaptive());
    Widget attendanceCount = ref.watch(visitorsCountStreamProvider).when(
        data: (data) {
          return Text(
            ref.watch(numberOfVisitors).toString(),
            style: const TextStyle(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
          );
        },
        error: (er, sr) => const Text("error"),
        loading: () =>
            const Expanded(child: CircularProgressIndicator.adaptive()));
    return DecoratedBox(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.deepPurple.shade300),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Card(
              elevation: 2,
              shadowColor: Colors.grey,
              color: Colors.deepPurple.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: SizedBox(
                height: 60,
                width: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Total Staff',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    staffCount
                  ],
                ),
              ),
            ),
            Card(
              elevation: 2,
              shadowColor: Colors.grey,
              color: Colors.deepPurple.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: SizedBox(
                height: 60,
                width: 90,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const Text(
                      'Attendance Today',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    attendanceCount
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return NewStaffFormView();
                }));
              },
              child: Card(
                elevation: 2,
                shadowColor: Colors.grey,
                color: Colors.green.shade900,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: const SizedBox(
                  height: 60,
                  width: 90,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Add new staff',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}

class _LatestAttendance extends HookConsumerWidget {
  const _LatestAttendance();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var visitor = ref.watch(_lastVisitor);
    return visitor.when(
        data: (lastvisitor) {
          switch (lastvisitor.runtimeType) {
            case Null:
              return ListTile(
                tileColor: Colors.deepPurple[300],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                trailing: const Align(
                  heightFactor: 1,
                  widthFactor: 1,
                  child: FaIcon(
                    FontAwesomeIcons.faceSadCry,
                    color: Colors.white,
                  ),
                ),
                title: const Center(
                  child: Text(
                    "No visitors today yet",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              );

            case Attendance:
              return ListTile(
                tileColor: Colors.red[400],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                trailing: const Align(
                    heightFactor: 1,
                    widthFactor: 1,
                    child: Text(
                      'Visitor',
                    )),
                subtitle: Text(
                    'License number: ${(lastvisitor as Attendance).licenseNumber!}'),
                title: Text(
                  'Entrance: ${DateFormat.yMEd().add_jms().format(lastvisitor.entrance!)},\nExit: ${lastvisitor.exit != null ? DateFormat.yMEd().add_jms().format(lastvisitor.exit!) : '-'}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );

            case _LastStaffAttendance:
              return ListTile(
                tileColor: Colors.red[400],
                textColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                leading:
                    (lastvisitor as _LastStaffAttendance).staff.image != null
                        ? Align(
                            heightFactor: 1,
                            widthFactor: 1,
                            child: CircleAvatar(
                              backgroundImage: Image.memory(Uint8List.fromList(
                                      (lastvisitor).staff.image!))
                                  .image,
                            ))
                        : null,
                trailing: const Align(
                    heightFactor: 1,
                    widthFactor: 1,
                    child: Text(
                      'Staff',
                    )),
                subtitle: Text(
                    '${(lastvisitor).staff.firstname!} ${(lastvisitor).staff.lastname!}'),
                title: Text(
                  'Entrance: ${DateFormat.yMEd().add_jms().format(lastvisitor.attendance.entrance!)},\nExit: ${lastvisitor.attendance.exit != null ? DateFormat.yMEd().add_jms().format(lastvisitor.attendance.exit!) : '-'}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );

            default:
              return Container();
          }
        },
        error: (Object error, StackTrace stackTrace) {
          return const Text("ERROR");
        },
        loading: () => const CircularProgressIndicator.adaptive());
  }
}

final staffCountStreamProvider = StreamProvider<int>((ref) async* {
  var db = GetIt.I<DatabaseHandler>();
  var isar = db.getIsar();
  var total = db.staffs != null ? await db.staffs!.count() : 0;
  Stream<void> change = isar.staffModels.watchLazy(fireImmediately: true);
  change.listen((event) async {
    debugPrint("New staff added");
    total = db.staffs != null ? await db.staffs!.count() : 0;
    debugPrint("New total is: $total");
    ref.watch(numberOfStaff.notifier).state = total;
  });
  ref.watch(numberOfStaff.notifier).state = total;
  yield total;
});

final visitorsCountStreamProvider = StreamProvider<int>((ref) async* {
  var db = GetIt.I<DatabaseHandler>();
  var isar = db.getIsar();

  var get = GetIt.instance;
  var attendance = get<DatabaseHandler>().attendance;
  var amount = attendance != null
      ? await attendance
          .filter()
          .entranceGreaterThan(DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day))
          .findAll()
      : [];
  ref.watch(numberOfVisitors.notifier).state = amount.length;
  Stream<void> change = isar.attendances.watchLazy(fireImmediately: true);
  change.listen((event) async {
    debugPrint("New Attendance added");
    var amount = attendance != null
        ? await attendance
            .filter()
            .entranceGreaterThan(DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day))
            .findAll()
        : [];
    ref.watch(numberOfVisitors.notifier).state = amount.length;
  });
  yield amount.length;
});

final numberOfStaff = StateProvider((ref) => 0);
final numberOfVisitors = StateProvider((ref) => 0);

final _lastVisitor = StreamProvider((ref) async* {
  var db = GetIt.I<DatabaseHandler>();
  var isar = db.getIsar();
  var visitorsLength = ref.watch(numberOfVisitors);
  // ignore: prefer_typing_uninitialized_variables
  var latest;

  if (visitorsLength > 0) {
    var allAttendanceToday = db.attendance != null
        ? await db.attendance!
            .filter()
            .entranceGreaterThan(DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day))
            .findAll()
        : [];

    var lastAttendance = allAttendanceToday[allAttendanceToday.length - 1];
    if (lastAttendance!.type == 1) {
      // is a visitor
      latest = lastAttendance;
      yield latest;
    } else {
      var staff = await db.staffs!
          .filter()
          .licenseNumberStartsWith(lastAttendance.licenseNumber!)
          .findFirst();
      latest = _LastStaffAttendance(attendance: lastAttendance, staff: staff!);
    }
  }

  Stream<void> change = isar.attendances.watchLazy(fireImmediately: true);
  change.listen((event) async {
    debugPrint("New Attendance added, updating latest visitor");
    var allAttendanceToday = db.attendance != null
        ? await db.attendance!
            .filter()
            .entranceGreaterThan(DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day))
            .findAll()
        : [];

    var lastAttendance = allAttendanceToday[allAttendanceToday.length - 1];
    if (lastAttendance!.type == 1) {
      // is a visitor
      latest = lastAttendance;
    } else {
      var staff = await db.staffs!
          .filter()
          .licenseNumberStartsWith(lastAttendance.licenseNumber!)
          .findFirst();
      latest = _LastStaffAttendance(attendance: lastAttendance, staff: staff!);
    }
  });
  yield latest;
});

class _LastStaffAttendance {
  Attendance attendance;
  StaffModel staff;
  _LastStaffAttendance({
    required this.attendance,
    required this.staff,
  });
}
