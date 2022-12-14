import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:todo/shared/components/components.dart';
import 'package:todo/shared/constant/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo/shared/cubit/cubit.dart';
import 'package:todo/shared/cubit/states.dart';

// ignore: must_be_immutable
class Home extends StatelessWidget {
  Home({super.key});

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var taskTitle = TextEditingController();
  var taskTime = TextEditingController();
  var taskDate = TextEditingController();
  var taskDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {},
        builder: (context, state) {
          AppCubit cubit = AppCubit.get(context);

          return Scaffold(
            extendBody: true,
            key: scaffoldKey,
            body: NestedScrollView(
              floatHeaderSlivers: true,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  floating: true,
                  title: Text(cubit.titles[cubit.selectIndex]),
                  backgroundColor: defaultColor,
                  actions: [
                    IconButton(
                      onPressed: () {
                        if (cubit.newTasks.isEmpty && cubit.archivedTasks.isEmpty && cubit.doneTasks.isEmpty) {
                          showDialog(
                              context: context,
                              builder: (builder) => SimpleDialog(
                                    children: [
                                      Column(
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Already Clear',
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 70.0,
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            child: TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ));
                        } else {
                          showSimpleDialog(
                              context, cubit.newTasks.length, cubit.doneTasks.length, cubit.archivedTasks.length);
                        }
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ],
              body: screens[cubit.selectIndex],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: defaultColor,
              onPressed: () {
                if (cubit.isBottomSheetOpen) {
                  Navigator.pop(context);
                  cubit.changeBottomSheetUi(Icons.edit, false);
                } else {
                  cubit.changeBottomSheetUi(Icons.arrow_downward, true);
                  scaffoldKey.currentState!.showBottomSheet(
                    (context) => SingleChildScrollView(
                      child: Container(
                        color: commonColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultTextField(
                                  controller: taskTitle,
                                  labelText: 'Task Title',
                                  keyboardType: TextInputType.text,
                                  prefixIcon: const Icon(Icons.title),
                                  validate: (value) {
                                    if (value.isEmpty) {
                                      return 'Can\'t be Empty';
                                    }
                                  },
                                ),
                                const SizedBox(height: 15.0),
                                defaultTextField(
                                  maxLength: 150,
                                  isCounterTextShown: true,
                                  controller: taskDescription,
                                  labelText: 'Task Description',
                                  keyboardType: TextInputType.text,
                                ),
                                const SizedBox(height: 15.0),
                                defaultTextField(
                                  controller: taskTime,
                                  labelText: 'Task Time',
                                  keyboardType: TextInputType.none,
                                  prefixIcon: const Icon(Icons.watch_later_outlined),
                                  onTap: () {
                                    showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    ).then(
                                      (value) => taskTime.text = value!.format(context).toString(),
                                    );
                                  },
                                  validate: (value) {
                                    if (value.isEmpty) {
                                      return 'Can\'t be Empty';
                                    }
                                  },
                                ),
                                const SizedBox(height: 15.0),
                                defaultTextField(
                                  controller: taskDate,
                                  labelText: 'Task Date',
                                  keyboardType: TextInputType.none,
                                  prefixIcon: const Icon(Icons.calendar_month),
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(DateTime.now().year + 2),
                                    ).then((value) => taskDate.text = DateFormat.yMMMd().format(value!));
                                  },
                                  validate: (value) {
                                    if (value.isEmpty) {
                                      return 'Can\'t be Empty';
                                    }
                                  },
                                ),
                                const SizedBox(height: 15.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    FloatingActionButton(
                                        backgroundColor: defaultColor,
                                        onPressed: () {
                                          if (formKey.currentState!.validate()) {
                                            cubit.insertToDatabase(
                                              title: taskTitle.text,
                                              time: taskTime.text,
                                              date: taskDate.text,
                                              description: taskDescription.text,
                                            );
                                            Navigator.pop(context);
                                            cubit.changeBottomSheetUi(Icons.edit, false);
                                            clearController();
                                          }
                                        },
                                        child: const Icon(Icons.add)),
                                    FloatingActionButton(
                                      backgroundColor: defaultColor,
                                      onPressed: () => clearController(),
                                      child: const Icon(Icons.delete),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              child: CurvedNavigationBar(
                height: 60,
                color: defaultColor,
                backgroundColor: cubit.isBottomSheetOpen ? commonColor : Colors.transparent,
                animationDuration: const Duration(milliseconds: 600),
                index: cubit.selectIndex,
                onTap: (index) => cubit.changeSelectIndex(index),
                items: itemsNavigationBar,
              ),
            ),
          );
        },
      ),
    );
  }

  void clearController() {
    taskTitle.clear();
    taskTime.clear();
    taskDate.clear();
    taskDescription.clear();
  }

  void showSimpleDialog(BuildContext context, int newTask, int doneTask, int archivedTask) => showDialog(
        context: context,
        builder: (builder) => SimpleDialog(
          title: const Text('Hint!'),
          children: <Widget>[
            SimpleDialogOption(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Text(
                    'If you press Delete you will lose the saved data',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  newTask > 0
                      ? Text(
                          '$newTask New task',
                          style: const TextStyle(fontSize: 16.0),
                        )
                      : Container(height: 0),
                  doneTask > 0
                      ? Text(
                          '$doneTask done task',
                          style: const TextStyle(fontSize: 16.0),
                        )
                      : Container(height: 0),
                  archivedTask > 0
                      ? Text(
                          '$archivedTask archived task',
                          style: const TextStyle(fontSize: 16.0),
                        )
                      : Container(height: 0),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      AppCubit.get(context).clearData();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
