import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/models/attendance.dart';
import 'package:gatevision/models/staffmodel.dart';
import 'package:gatevision/repo/db.dart';
import 'package:gatevision/show_staff_info.dart';
import 'package:gatevision/visitorview.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

class LicenseView extends ConsumerWidget {
  LicenseView({Key? key, required this.extractedText}) : super(key: key);
  final String extractedText;
  final GetIt get = GetIt.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (extractedText == "") {
      return Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
            ),
          ),
          body: const Center(child: Text('unable to find license number')));
    }
    return ref.watch(stafflicenseNumberChecker(extractedText)).when(
        data: (staff) {
          if (staff.licenseNumber == '-1') {
            return VisitorView(
              cleanexText: extractedText,
            );
          } else {
            return ShowStaffInfo(staff: staff);
          }
        },
        error: (er, st) {
          return const Scaffold(body: Center(child: Text('eror')));
        },
        loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive())));
  }
}

final stafflicenseNumberChecker =
    FutureProvider.family<StaffModel, String>((ref, extractedText) async {
  var staff = GetIt.instance<DatabaseHandler>().staffs;
  List<StaffModel> allStaff = await staff!.where().findAll();
  // List<StaffModel> allStaff = List<StaffModel>.generate(
  //     30,
  //     (index) => StaffModel()
  //       ..firstname = 'test'
  //       ..lastname = 'last'
  //       ..licenseNumber = 'STAFF'
  //       ..staffID = '4421'
  //       ..id = index);
  var matchingStaff = allStaff.firstWhere(
      (element) => extractedText.contains(element.licenseNumber!), orElse: () {
    return StaffModel()..licenseNumber = '-1';
  });
  return matchingStaff;
});

final addNewVisitor = FutureProvider.family<bool, String>((ref, license) async {
  try {
    var db = GetIt.instance<DatabaseHandler>();

    await db.addUpdateNewRecord(Attendance()
      ..entrance = DateTime.now()
      ..licenseNumber = license
      ..type = 1);
    return true;
  } catch (e) {
    return false;
  }
});

final states = [
  "Abia",
  "Adamawa",
  "Akwa Ibom",
  "Anambra",
  "Bauchi",
  "Bayelsa",
  "Benue",
  "Borno",
  "Cross River",
  "Delta",
  "Ebonyi",
  "Edo",
  "Ekiti",
  "Enugu",
  "Gombe",
  "Imo",
  "Jigawa",
  "Kaduna",
  "Kano",
  "Katsina",
  "Kebbi",
  "Kogi",
  "Kwara",
  "Lagos",
  "Nasarawa",
  "Niger",
  "Ogun",
  "Ondo",
  "Osun",
  "Oyo",
  "Plateau",
  "Rivers",
  "Sokoto",
  "Taraba",
  "Yobe",
  "Zamfara ",
  "Abuja"
];

final slogans = [
  "God’s Own State",
  "Land of Beauty, Sunshine and Hospitality",
  "Land of Promise",
  "Light of the Nation",
  "Pearl of Tourism",
  "Glory of all Lands",
  "Food Basket of the Nation",
  "Home of Peace",
  "The People's Paradise",
  "The Finger of God",
  "State of the Living Spring",
  "Centre of Unity",
  "Heartbeat of the Nation",
  "Centre of Commerce",
  "Home of Peace and Tourism",
  "Land of Equity",
  "Gateway State",
  "Centre of Excellence",
  "Land of Hospitality",
  "Sunshine State",
  "Home of Solid Minerals",
  "Centre of Learning",
  "Nigeria’s Home of Solid Minerals",
  "Seat of the Caliphate",
  "Home of Peaceful People",
  "Centre of Islamic Learning",
  "The Big Heart",
  "The Promise Land",
  "The Nation’s Pride",
  "Power State",
  "The Confluence State",
  "Centre of Excellence in Education",
  "The Food Basket of the Nation",
  "The Home of Heroes",
  "The Treasure Base of the Nation",
  "Salt of the Nation",
];
