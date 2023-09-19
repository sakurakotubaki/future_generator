import 'package:api_app/provider/future.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

/// [APIのデータを表示する画面]
class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// [todosProvider]を監視して、データを取得する
    /// generatorを使わない場合は、普通のFutureProviderを使う
    final todo = ref.watch(todosProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
      ),
      // [todo]の状態によって、表示するWidgetを変更する
      body: todo.when(
        data: (todos) {
          return ListView.builder(
            itemCount: todos.length,// [todos]の長さ分、Widgetを作成する
            itemBuilder: (context, index) {
              final todo = todos[index];// [todos]のindex番目のデータを取得する
              return ListTile(
                title: Text(todo.title),
                subtitle: Text(todo.id.toString()),
              );
            },
          );
        },
        error: (_, __) => const Center(// [todo]の状態がエラーの場合の処理
          child: Text('Error'),
        ),
        loading: () => const Center(// [todo]の状態がロード中の場合の処理
          child: CircularProgressIndicator(),
        ),
        ),
    );
  }
}