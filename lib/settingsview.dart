import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/main.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var activeUser = GetIt.I<DatabaseHandler>().activeUser;
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text("Name: ${activeUser?.firstname} ${activeUser?.lastname}"),
          Text("ID: ${activeUser?.userID} "),
          Text("Email: ${activeUser?.email} "),
          ElevatedButton(
              onPressed: () {
                ref.watch(_signOut);
              },
              child: const Text("Logout")),
        ],
      )),
    );
  }
}

final _signOut = FutureProvider.autoDispose((ref) async {
  await GetIt.I<SharedPreferences>().setString('signedin', 'none');
  GetIt.I<SharedPreferences>().setString('activeuser', 'none');
  GetIt.I<DatabaseHandler>().activeUser = null;
  ref.watch(authenticationStatus.notifier).state = 'none';
});
