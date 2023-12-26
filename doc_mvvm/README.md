# MVVM + Reositoryバターン
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

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'dio_provider.g.dart';
// Dioをインスタンス化するプロバイダーを定義
@riverpod
Dio dio(DioRef ref) {
  return Dio();
}
```

API通信は、Repository層でおこないます。`abstract class`を上書きして、ロジックを実装する。

```dart
import 'package:api_app/domain/entity/todo.dart';
import 'package:api_app/provider/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'todo_repository.g.dart';

// MVVMだと現場では、こんな感じのコードを書くことが多い
@Riverpod(keepAlive: true)
TodoRepositoryImpl todoRepositoryImpl(TodoRepositoryImplRef ref) {
  return TodoRepositoryImpl(ref);
}

// abstract class を定義する
abstract class TodoRepository {
  Future<List<Todo>> fetchTodo();
}

// abstract class をoverrideして機能を実装する
class TodoRepositoryImpl implements TodoRepository {
  TodoRepositoryImpl(this.ref);
  final Ref ref;// refメソッドを使うために必要
  // API通信するロジックを実装する
  @override
  Future<List<Todo>> fetchTodo() async {
    final response = await ref.read(dioProvider).get('https://jsonplaceholder.typicode.com/todos/');
    return (response.data as List).map((e) => Todo.fromJson(e)).toList();
  }
}
```

View側とロジックを分けたり状態の管理をするときには、riverpodではプロバイダーを使います。`FutureProvider`をAPI通信では使うことが多いのですが、riverpod2.0では、AsyncNotifierでおこなうと扱いやすいみたいです。同じ`AsyncValue`でデータが返ってくるからこっちの方がいいのかな。

ViewModelのファイルですけど、どこに配置するかというと、view_modelってフォルダは作らなくて、viewとかpageっていうUIのファイルを配置してるところに置くのが一般的なようです。

```dart
import 'package:api_app/domain/entity/todo.dart';
import 'package:api_app/domain/repository/todo_repository.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'todo_view_model.g.dart';

/* FutureProviderではなく最近は、AsyncNotifierを使うのが流行りみたい?
StateNotifierのAsyncValueと同じようなものです。どちらもAsyncValueでデータが返ってきて、
data, error, loadingの3つの状態を持つことができます。
*/
@riverpod
class TodoViewModel extends _$TodoViewModel {
  // FutureOrのデータ型は、ソッドに合わせる
  @override
  FutureOr<List<Todo>> build() {
    return fetchTodo();
  }
  // voidではないので、returnを書く必要がある
  Future<List<Todo>> fetchTodo() async {
    try {
      state = const AsyncLoading();
      final response = await ref.read(todoRepositoryImplProvider).fetchTodo();
      state = AsyncData(response);
      return response;
    } on Exception catch (e) {
      throw Exception('エラーが発生しました: $e');
    } finally {
      debugPrint('🛜API通信を実行');
    }
  }
}
```
