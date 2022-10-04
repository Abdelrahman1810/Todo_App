import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo/shared/cubit/states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialState());

  int selectIndex = 0;
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];

  void changeSelectIndex(int index) {
    selectIndex = index;
    emit(ChangeSelectIndex());
  }

  bool isBottomSheetOpen = false;
  IconData fabIcon = Icons.edit;

  void changeBottomSheetUi(IconData icon, bool isOpen) {
    isBottomSheetOpen = isOpen;
    fabIcon = icon;
    emit(AppChangeBottomSheetUi());
  }

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  late Database database;

  void createDatabase() {
    openDatabase('Todo.db',
        version: 1,
        onCreate: (database, version) {
          database
              .execute(
                  'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, description TEXT, date TEXT, time TEXT, status TEXT)')
              .then((value) {});
        },
        onOpen: (database) => getDataFromDatabase(database)).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertToDatabase({
    required String title,
    required String date,
    required String time,
    required String description,
  }) async {
    await database.transaction((txn) {
      txn
          .rawInsert(
        'INSERT INTO tasks(title, description, date, time, status) VALUES("$title", "$description", "$date", "$time", "new")',
      )
          .then((value) {
        emit(AppInsertDatabaseState());

        getDataFromDatabase(database);
      });
      return asd();
    });
  }

  void getDataFromDatabase(database) {
    newTasks.clear();
    doneTasks.clear();
    archivedTasks.clear();
    emit(AppGetDatabaseLoadingState());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new') {
          newTasks.add(element);
        } else if (element['status'] == 'done') {
          doneTasks.add(element);
        } else if (element['status'] == 'archived') {
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  Future asd() async {}

  void updateData({
    required String status,
    required int id,
  }) async {
    await database.rawUpdate('UPDATE tasks SET status = ? WHERE id = ?', [status, id]).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData(int id) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]);
    getDataFromDatabase(database);
    emit(AppDeleteDatabaseState());
  }

  static AppCubit get(context) => BlocProvider.of(context);
}
