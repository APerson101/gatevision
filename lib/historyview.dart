import 'package:flutter/material.dart';
import 'package:gatevision/models/attendance.dart';
import 'package:gatevision/repo/db.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HistoryView extends StatelessWidget {
  HistoryView({Key? key}) : super(key: key);
  final GetIt geter = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Container(),
        title: const Text("Attendance History"),
      ),
      body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator.adaptive());
            } else if (snapshot.hasData) {
              if (snapshot.data != null) {
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("No attendance Yet"));
                } else {
                  return Stack(
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
                          source:
                              AttendanceDataSource(attendance: snapshot.data!),
                          columns: [
                            GridColumn(
                                columnName: 'S/N',
                                label: Container(
                                    height: 50,
                                    width: 70,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'S/N',
                                    ))),
                            GridColumn(
                                columnName: 'Type',
                                label: Container(
                                    height: 50,
                                    width: 70,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Type',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'License Number',
                                label: Container(
                                    height: 50,
                                    width: 70,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'License Number',
                                    ))),
                            GridColumn(
                                columnName: 'Entry Time',
                                label: Container(
                                    height: 50,
                                    width: 70,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Entry Time',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Exit Time',
                                label: Container(
                                    height: 50,
                                    width: 70,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Exit Time',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                          ]),
                    ],
                  );
                }
              }
            }
            return Container();
          },
          future: getAttendances()),
    );
  }

  Future<List<Attendance>?>? getAttendances() async {
    return await geter.get<DatabaseHandler>().attendance?.where().findAll();
  }
}

class AttendanceDataSource extends DataGridSource {
  AttendanceDataSource({required this.attendance}) {
    _source = attendance
        .map((e) => DataGridRow(cells: [
              DataGridCell(columnName: 'S/N', value: e.id),
              DataGridCell(
                  columnName: 'Type',
                  value: e.type == 0 ? 'Employee' : 'Visitor'),
              DataGridCell(
                  columnName: 'License Number', value: e.licenseNumber),
              DataGridCell(
                  columnName: 'Entry Time',
                  value: e.entrance != null
                      ? DateFormat.yMEd().add_jms().format(e.entrance!)
                      : '-'),
              DataGridCell(
                  columnName: 'Exit Time',
                  value: e.exit != null
                      ? DateFormat.yMEd().add_jms().format(e.exit!)
                      : '-'),
            ]))
        .toList();
  }
  List<Attendance> attendance;
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
                  padding: const EdgeInsets.all(16.0),
                  child: Text(e.value.toString()),
                ))
            .toList());
  }
}
