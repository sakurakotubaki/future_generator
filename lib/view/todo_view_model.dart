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
