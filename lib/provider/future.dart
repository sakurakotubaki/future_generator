import 'package:api_app/model/todo.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'future.g.dart';

// generaterを使わない場合の書き方
// final todosProvider = FutureProvider<List<Todo>>((ref) async {
//   final _dio = Dio();
//   final response = await _dio.get('https://jsonplaceholder.typicode.com/todos/');
//   return (response.data as List).map((e) => Todo.fromJson(e)).toList();
// });

// generaterを使う場合の書き方
@riverpod
Future<List<Todo>> todos(TodosRef ref) async {
  final _dio = Dio();
  final response = await _dio.get('https://jsonplaceholder.typicode.com/todos/');
  return (response.data as List).map((e) => Todo.fromJson(e)).toList();
}