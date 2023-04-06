import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/models/attendance.dart';
import 'package:gatevision/repo/db.dart';
import 'package:gatevision/status%20pages/status_page.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';

import 'status pages/exit_visitor_status.dart';

class VisitorView extends ConsumerWidget {
  VisitorView({super.key, required this.cleanexText});
  final GetIt get = GetIt.instance;
  final String cleanexText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // return as visitor
    return ref.watch(visitorlicenseNumberChecker(cleanexText)).when(
        data: (visitor) {
      debugPrint('the visitor is ${visitor.licenseNumber}');
      if (visitor.licenseNumber == '-1') {
        // new visitor
        return Scaffold(
          appBar: AppBar(title: const Text("New visitor")),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('Extracted License Number: '),
                Text(
                  cleanexText,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 22),
                ),
                ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              StatusPage(cleantext: cleanexText)));
                    },
                    child: const Text("Approve Visitor"))
              ],
            ),
          ),
        );
      } else {
        // exiting visitor
        return Scaffold(
          appBar: AppBar(
            title: Text(visitor.licenseNumber!),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Entry Time: ${visitor.entrance.toString()}'),
                ElevatedButton(
                    onPressed: () async {
                      visitor.exit = DateTime.now();
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              ExitStatusPage(visitor: visitor)));
                    },
                    child: const Text('Approve Exit'))
              ],
            ),
          ),
        );
      }
    }, error: (Object error, StackTrace stackTrace) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Failed to load visitor")),
      );
    }, loading: () {
      debugPrint("Loading visitors");
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text("Loading visitor.....")),
      );
    });
  }
}

final visitorlicenseNumberChecker = FutureProvider.autoDispose
    .family<Attendance, String>((ref, extractedText) async {
  var allVisitors = GetIt.instance<DatabaseHandler>().attendance!;
  List<Attendance> visits = await allVisitors.where().findAll();
  // find visitor with this license who has entered but hasn't left yet
  debugPrint('checking for visitor with license number: $extractedText');
  // var visits = List<Attendance>.generate(
  //     20,
  //     (index) => Attendance()
  //       ..entrance = DateTime.now()
  //       ..exit = index == 19 ? null : DateTime.now()
  //       ..licenseNumber = 'ABC123EG'
  //       ..type = 0
  //       ..id = index);
  var visitor = visits.firstWhere(
      (element) =>
          extractedText.contains(element.licenseNumber!) &&
          element.exit == null, orElse: () {
    return Attendance()..licenseNumber = '-1';
  });
  return visitor;
});
