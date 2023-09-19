# api_app
riverpod_generatorを使用してAPI通信をおこなうサンプルを作成しました。

https://pub.dev/packages/riverpod_generator

ドキュメントだと分かりずらい部分があったので、自分で動くサンプルを作ってみました。

モデルクラスは、Freezedを使用しています。これを使うと何がうれしいかというと、モデルクラスを作成するときに、json_serializableを使って、fromJsonとtoJsonを自動生成してくれるので、モデルクラスを作成するときに、楽になります。

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'todo.freezed.dart';
part 'todo.g.dart';


// 自動生成するコマンド
// flutter pub run build_runner watch --delete-conflicting-outputs

// このURLのAPIにデータの型を合わせて、変数を定義する
// https://jsonplaceholder.typicode.com/todos

@freezed
class Todo with _$Todo {
  const factory Todo({
    @Default(0) int userId,
    @Default(0) int id,
    @Default('') String title,
    @Default(false) bool completed,
  }) = _Todo;

  factory Todo.fromJson(Map<String, Object?> json)
      => _$TodoFromJson(json);
}
```

API通信には、Dioを使用しています。

https://pub.dev/packages/dio

これが通常の書き方。
```dart
// generaterを使わない場合の書き方
final todosProvider = FutureProvider<List<Todo>>((ref) async {
  final _dio = Dio();
  final response = await _dio.get('https://jsonplaceholder.typicode.com/todos/');
  return (response.data as List).map((e) => Todo.fromJson(e)).toList();
});
```

これがgeneraterを使った場合の書き方。
```dart
// generaterを使う場合の書き方
@riverpod
Future<List<Todo>> todos(TodosRef ref) async {
  final _dio = Dio();
  final response = await _dio.get('https://jsonplaceholder.typicode.com/todos/');
  return (response.data as List).map((e) => Todo.fromJson(e)).toList();
}
```

コマンドを実行するファイルが自動生成される。ここでプロバイダーが作成されているので、ref.watchで呼び出すことができる。
```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'future.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todosHash() => r'18eec8411dba24b53b1567de5285f8bd71e0afc3';

/// See also [todos].
@ProviderFor(todos)
final todosProvider = AutoDisposeFutureProvider<List<Todo>>.internal(
  todos,
  name: r'todosProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$todosHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TodosRef = AutoDisposeFutureProviderRef<List<Todo>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
```

FutureProvierを使用して、API通信をからデータを取得するときは、このように書く。
```dart
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
```