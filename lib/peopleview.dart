import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gatevision/models/staffmodel.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';
import 'package:isar/isar.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class PeopleView extends ConsumerWidget {
  PeopleView({super.key});
  final GetIt get = GetIt.instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(staffStream).when(data: (_) {
      var data = ref.watch(getStaff);
      return data == null || data.isEmpty
          ? SafeArea(
              child: Scaffold(
                  appBar: AppBar(),
                  body: const Center(child: Text("No staff Added yet"))))
          : Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  leading: Container(),
                  title: const Text("All Staff")),
              body: Stack(
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
                      source: StaffDataSource(
                          staff: data,
                          buttonCallBack: (id) {
                            debugPrint("deleting staff with id $id");
                            ref.watch(deleteStaffController(id)).whenData(
                                (value) => ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        content: ListTile(
                                            title: Text("Done deleting...")))));
                          }),
                      columns: [
                        GridColumn(
                            columnName: 'S/N',
                            label: const SizedBox(
                              height: 50,
                              width: 70,
                              child: Center(
                                child: Text(
                                  'S/N',
                                ),
                              ),
                            )),
                        GridColumn(
                            columnName: 'License Number',
                            label: const Center(
                                child: Text(
                              'License Number',
                            ))),
                        GridColumn(
                            columnName: 'First Name',
                            label: const Center(
                              child: Text(
                                'First Name',
                                overflow: TextOverflow.ellipsis,
                              ),
                            )),
                        GridColumn(
                            columnName: 'Last Name',
                            label: const Center(
                                child: Text(
                              'Last Name',
                              overflow: TextOverflow.ellipsis,
                            ))),
                        GridColumn(
                            columnName: 'Staff ID',
                            label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Staff ID',
                                ))),
                        GridColumn(
                            columnName: 'Action',
                            label: Container(
                                padding: const EdgeInsets.all(16.0),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Action',
                                ))),
                      ]),
                ],
              ));
    }, error: (er, st) {
      return const Scaffold(
        body: Center(child: Text("Failed to load")),
      );
    }, loading: () {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Text("Loading staff data..."),
            CircularProgressIndicator.adaptive()
          ],
        )),
      );
    });
  }
}

final staffStream = StreamProvider((ref) async* {
  var db = GetIt.I<DatabaseHandler>();
  var isar = db.getIsar();
  var allStaff = await db.staffs?.where().findAll();
  Stream<void> change = isar.staffModels.watchLazy(fireImmediately: true);
  change.listen((event) async {
    debugPrint("New staff action");
    allStaff = await db.staffs?.where().findAll();
    ref.watch(getStaff.notifier).state = allStaff;
  });
  ref.watch(getStaff.notifier).state = allStaff;
  yield allStaff;
});

final getStaff = StateProvider<List<StaffModel>?>((ref) {
  return null;
});

class StaffDataSource extends DataGridSource {
  StaffDataSource({required this.staff, required this.buttonCallBack}) {
    _source = staff
        .map((e) => DataGridRow(cells: [
              DataGridCell(columnName: 'S/N', value: e.id),
              DataGridCell(
                  columnName: 'License Number', value: e.licenseNumber),
              DataGridCell(columnName: 'First Name', value: e.firstname),
              DataGridCell(columnName: 'Last Name', value: e.lastname),
              DataGridCell(columnName: 'Staff ID', value: e.staffID),
              DataGridCell(columnName: 'Action', value: e.id),
            ]))
        .toList();
  }
  List<StaffModel> staff;
  List<DataGridRow> _source = [];
  Function(int) buttonCallBack;
  @override
  List<DataGridRow> get rows => _source;
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row
            .getCells()
            .map((e) => Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(16.0),
                  child: e.columnName == 'Action'
                      ? ElevatedButton(
                          onPressed: () => buttonCallBack(e.value),
                          child: const Text("Delete Staff"))
                      : Text(e.value.toString()),
                ))
            .toList());
  }
}

final deleteStaffController =
    FutureProvider.family.autoDispose<void, int>((ref, staffID) async {
  await GetIt.I<DatabaseHandler>().deleteStaff(staffID);
});
