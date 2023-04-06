import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../licenseviewer.dart';

class StatusPage extends ConsumerWidget {
  StatusPage({super.key, required this.cleantext});
  final String cleantext;
  final GetIt get = GetIt.I;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(addNewVisitor(cleantext)).when(
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
                children: const [Icon(Icons.check), Text("Successfully added")],
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
