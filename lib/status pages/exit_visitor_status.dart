import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/models/attendance.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';

class ExitStatusPage extends ConsumerWidget {
  const ExitStatusPage({super.key, required this.visitor});
  final Attendance visitor;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(updateVisitor(visitor)).when(
        data: (data) {
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
            body: DecoratedBox(
              decoration: const BoxDecoration(color: Colors.lightGreen),
              child: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  Icon(Icons.check),
                  Text("Successfully Updated")
                ],
              )),
            ),
          );
        },
        error: (er, st) => Scaffold(
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () {
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                ),
              ),
              body: DecoratedBox(
                decoration: const BoxDecoration(color: Colors.redAccent),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [Icon(Icons.cancel), Text("Failed to  add")],
                )),
              ),
            ),
        loading: () => Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: () {
                  Navigator.of(context)
                    ..pop()
                    ..pop();
                },
              ),
            ),
            body: const DecoratedBox(
              decoration: BoxDecoration(color: Colors.lightGreen),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )));
  }
}

final updateVisitor =
    FutureProvider.family<void, Attendance>((ref, visitor) async {
  await GetIt.instance<DatabaseHandler>().addUpdateNewRecord(visitor);
});
