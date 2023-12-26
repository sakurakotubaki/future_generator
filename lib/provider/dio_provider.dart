import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'dio_provider.g.dart';
// Dioをインスタンス化するプロバイダーを定義
@riverpod
Dio dio(DioRef ref) {
  return Dio();
}
