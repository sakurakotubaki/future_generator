import 'package:api_app/domain/entity/todo.dart';
import 'package:api_app/provider/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'todo_dto.g.dart';

@Riverpod(keepAlive: true)
TodoDto todoDto(TodoDtoRef ref) {
  return TodoDto(ref);
}

// APIとやりとりをするDTOクラス
class TodoDto {
  TodoDto(this.ref);
  Ref ref;

  Future<List<Todo>> fetchTodo() async {
    final response = await ref.read(dioProvider).get('https://jsonplaceholder.typicode.com/todos/');
    return (response.data as List).map((e) => Todo.fromJson(e)).toList();
  }
}
