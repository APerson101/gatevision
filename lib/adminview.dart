import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/models/usermodel.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'adduserview.dart';
import 'main.dart';

class AdminView extends ConsumerWidget {
  const AdminView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("All Users"),
        actions: [
          TextButton(
              onPressed: () async {
                ref.watch(_signout);
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white, fontSize: 16),
              )),
          TextButton(
              onPressed: () async {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => AddNewUser()));
              },
              child: const Text(
                "Add new user",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ))
        ],
      ),
      body: ref.watch(usersStream).when(
          data: (_) {
            var users = ref.watch(getUser);
            return users == null || users.isEmpty
                ? const Center(child: Text("No Users added yet"))
                : Stack(
                    children: [
                      Positioned(
                          left: 10,
                          right: 10,
                          top: 10,
                          bottom: 10,
                          child: Opacity(
                            opacity: .1,
                            child: Image.asset(
                              'images/binghamlogo.png',
                              fit: BoxFit.contain,
                            ),
                          )),
                      SfDataGrid(
                          source: UsersDataSource(
                              users: users,
                              buttonCallBack: (id) {
                                debugPrint("Deleting user with id: $id");
                                ref.watch(deleteUserController(id)).whenData(
                                    (value) => ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                            backgroundColor: Colors.green,
                                            content:
                                                Text("Done deleting..."))));
                              }),
                          columns: [
                            GridColumn(
                                columnName: 'S/N', label: const Text('S/N')),
                            GridColumn(
                                columnName: 'First Name',
                                label: const Text('First Name')),
                            GridColumn(
                                columnName: 'Last Name',
                                label: const Text('Last Name')),
                            GridColumn(
                                columnName: 'ID', label: const Text('ID')),
                            GridColumn(
                                columnName: 'Action',
                                label: const Text('Action')),
                          ])
                    ],
                  );
          },
          error: (er, st) => const Center(child: Text("Failed to Load")),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive())),
    );
  }
}

final _signout = FutureProvider.autoDispose((ref) async {
  await GetIt.I<SharedPreferences>().setString('signedin', 'none');
  ref.watch(authenticationStatus.notifier).state = 'none';
});

final usersStream = StreamProvider((ref) async* {
  var db = GetIt.I<DatabaseHandler>();
  var isar = db.getIsar();
  var allUsers = await db.users?.where().findAll();
  Stream<void> change = isar.userModels.watchLazy(fireImmediately: true);
  change.listen((event) async {
    debugPrint("New User action");
    allUsers = await db.users?.where().findAll();
    ref.watch(getUser.notifier).state = allUsers;
  });
  ref.watch(getUser.notifier).state = allUsers;
  yield allUsers;
});

final getUser = StateProvider<List<UserModel>?>((ref) {
  return null;
});

final deleteUserController =
    FutureProvider.family.autoDispose<void, int>((ref, staffID) async {
  await GetIt.I<DatabaseHandler>().deleteUser(staffID);
});

class UsersDataSource extends DataGridSource {
  UsersDataSource({required this.users, required this.buttonCallBack}) {
    _source = users
        .map((e) => DataGridRow(cells: [
              DataGridCell(columnName: 'S/N', value: e.id),
              DataGridCell(columnName: 'First Name', value: e.firstname),
              DataGridCell(columnName: 'Last Name', value: e.lastname),
              DataGridCell(columnName: 'ID', value: e.userID),
              DataGridCell(columnName: 'Action', value: e.id),
            ]))
        .toList();
  }

  List<UserModel> users;
  Function(int) buttonCallBack;
  List<DataGridRow> _source = [];
  @override
  List<DataGridRow> get rows => _source;
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row
            .getCells()
            .map((e) => Container(
                  alignment: Alignment.center,
                  child: e.columnName == 'Action'
                      ? ElevatedButton(
                          onPressed: () => buttonCallBack(e.value),
                          child: const Text(
                            "Del",
                            style: TextStyle(color: Colors.black),
                          ))
                      : Text(e.value.toString()),
                ))
            .toList());
  }
}
