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
