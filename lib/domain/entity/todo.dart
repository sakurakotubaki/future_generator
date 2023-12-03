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