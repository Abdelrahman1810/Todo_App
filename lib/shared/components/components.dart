import 'package:flutter/material.dart';
import 'package:todo/shared/constant/constants.dart';
import 'package:todo/shared/cubit/cubit.dart';

Widget defaultTextField({
  required controller,
  required String labelText,
  prefixIcon,
  keyboardType,
  onTap,
  validate,
}) =>
    SizedBox(
      width: double.infinity,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validate,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(width: 3, color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(color: Colors.red),
          ),
          errorStyle: const TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        textInputAction: TextInputAction.done,
      ),
    );

Widget tasksBuilder({
  required List<Map> tasks,
  required text,
  required IconData icon,
  required bool done,
  required bool archive,
}) {
  return tasks.isNotEmpty
      ? ListView.separated(
          itemBuilder: (context, index) => buildListItems(
            model: tasks[index],
            context: context,
            done: done,
            archive: archive,
          ),
          separatorBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              width: double.infinity,
              height: 1,
              color: Colors.grey[300],
            ),
          ),
          itemCount: tasks.length,
        )
      : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 100,
                color: Colors.grey,
              ),
              Opacity(
                opacity: .5,
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
}

Widget buildListItems({
  required Map model,
  required context,
  bool done = false,
  bool archive = false,
}) =>
    Dismissible(
      key: Key(model['id'].toString()),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              '${model['title']}',
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: defaultColor,
                  child: Text(
                    '${model['time']}',
                    style: const TextStyle(
                      fontSize: 17.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '${model['description']}',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '${model['date']}',
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            archive
                ? IconButton(
                    onPressed: () {
                      AppCubit.get(context).deleteData(model['id']);
                    },
                    icon: const Icon(Icons.delete),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (done) {
                            AppCubit.get(context).deleteData(model['id']);
                          } else {
                            AppCubit.get(context).updateData(
                              id: model['id'],
                              status: 'done',
                            );
                          }
                        },
                        icon: done ? const Icon(Icons.delete) : const Icon(Icons.task_alt),
                      ),
                      const SizedBox(width: 20.0),
                      IconButton(
                        onPressed: () {
                          AppCubit.get(context).updateData(
                            id: model['id'],
                            status: 'archived',
                          );
                        },
                        icon: const Icon(Icons.archive_outlined),
                      ),
                    ],
                  ),
          ],
        ),
      ),
      onDismissed: (direc) {
        AppCubit.get(context).deleteData(model['id']);
      },
    );
