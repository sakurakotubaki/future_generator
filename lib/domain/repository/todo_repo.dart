import 'package:api_app/domain/dto/todo_dto.dart';
import 'package:api_app/domain/entity/todo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_repo.g.dart';

@riverpod
Future<List<Todo>> todoRepository(TodoRepositoryRef ref) async {
  return await ref.read(todoDtoProvider).fetchTodo();
}
