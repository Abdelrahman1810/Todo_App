import 'package:flutter/material.dart';
import 'package:todo/modules/archived_tasks/archived_screen.dart';
import 'package:todo/modules/done_tasks/done_screen.dart';
import 'package:todo/modules/new_tasks/new_screen.dart';

List<Widget> screens = [
  const NewTasks(),
  const DoneTasks(),
  const ArchivedTasks(),
];

List<Widget> itemsNavigationBar = const [
  Icon(Icons.add_task),
  Icon(Icons.task_alt),
  Icon(Icons.archive_outlined),
];

dynamic defaultColor = const Color.fromRGBO(153, 51, 255, 1);
