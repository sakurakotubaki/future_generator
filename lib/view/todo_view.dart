import 'package:api_app/view/todo_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [APIのデータを表示する画面]
class TodoVIew extends ConsumerWidget {
  const TodoVIew({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// [dataProvider]を監視して、データを取得する
    final todo = ref.watch(todoViewModelProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Model Sample'),
      ),
      // [todo]の状態によって、表示するWidgetを変更する
      body: switch (todo) {
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(value[index].title),
                subtitle: Text(value[index].id.toString()),
              );
            },
          ),
        AsyncError(:final error) => Text('Error: $error'),
        _ => const CircularProgressIndicator(),
      },
    );
  }
}
