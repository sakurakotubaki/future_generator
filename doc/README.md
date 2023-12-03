# 他の言語のMVVMぽくするとどうなるのか?
これが正解かわからないですが、AndroidのMVVMチックなアーキテクチャで設計をしてみました。最近自己学習しているJetpack Composeにインスパイアされました(ひらめきを得たって意味)💡

## 📦こちらが完成品です
[Githubのソースコード](https://github.com/sakurakotubaki/future_generator/tree/feat-dto)

![](https://storage.googleapis.com/zenn-user-upload/3bd6d2d75452-20231203.png)


## 📁ディレクトリ構成
```dart
lib
├── domain
│   ├── dto
│   │   ├── todo_dto.dart
│   │   └── todo_dto.g.dart
│   ├── entity
│   │   ├── todo.dart
│   │   ├── todo.freezed.dart
│   │   └── todo.g.dart
│   └── repository
│       ├── todo_repo.dart
│       └── todo_repo.g.dart
├── main.dart
└── provider
    ├── dio_provider.dart
    └── dio_provider.g.dart
```

## 🖼️図も作ってみました!
これで設計が合っているのか疑問ですが...

![](https://storage.googleapis.com/zenn-user-upload/918e52256be6-20231203.png)

今回は、API通信には、dioを使うので、プロバイダーで使えるようにインスタンス化しておく。

```dart
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'dio_provider.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return Dio();
}
```

## Entityとは?
エンティティ（entity）には、次のような意味があります。﻿
実体、存在、実在（物）、本質、本体
存在物、統一体
組織や団体など物質的な実体に限らず実存する概念
明瞭に区別される物
データモデル内で個別に識別可能な要素やオブジェクト

>IT分野では、標識や識別名、所在情報によって指し示される、独立した一意の対象物をエンティティといいます。また、プログラミングでは、データモデル内で個別に識別可能な要素やオブジェクトを表す概念です。

Flutterだと、モデルクラスのことですね。名前が難しくなってわかりにくい😕
ただの入れ物と表現する人もいますね。

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

## DTOとは?
DTO（Data Transfer Object）は、関連するデータをまとめて、データの格納・読み出しのためのメソッドを定義したオブジェクトです。
DTOは、オブジェクト指向プログラミングで用いられるデザインパターンの1つで、異なるプログラム間やコンピュータ間でひとまとまりのデータを受け渡す際に使用されます。

AndroidでDTOを使った時は、SQLを操作する関数を書いていましたね。参考までに載せておきます。

```kt
package com.example.libraryapp.room

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.Query
import androidx.room.Update
import kotlinx.coroutines.flow.Flow

@Dao
interface BookDAO {

    @Insert
    suspend fun addBook(bookEntity: BookEntity)

    @Query("SELECT * FROM BookEntity")
    fun getAllBooks(): Flow<List<BookEntity>>

    @Delete
    suspend fun deleteBook(bookEntity: BookEntity)

    @Update
    suspend fun updateBook(bookEntity: BookEntity)

}
```

### こっちがFlutterのコード
APIにHTTPリクエストを送り、GETメソッドでAPIのデータを取得します。

```dart
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
```

## Repositoryとは?
リポジトリ（repository）は英語で「貯蔵庫」、「倉庫」などを意味する言葉です。一般用語としては、さまざまなデータ、情報、知識や成果物を蓄積するデータベースやアーカイブを指します。

リポジトリには、次のような意味があります。
システム開発分野においては、「開発の仕様やシステム資源に関する情報を一元管理できる場所」という意味で使われます。
バージョン管理システムではソースコード等の管理対象を溜めておく場所をリポジトリと呼びます。
大学や研究機関が主体となり、研究者が作成した研究や教育成果物などの電子データを体系立てて保管する「機関リポジトリ」があります。

抽象クラスのコードで書いてる人いたから、Dartだとそんな感じなのかと思ったが、Kotlinは違ったので、僕の解釈が間違ってるかも💦

FutureProviderを使って、riverpodを使用してView側にAPIから取得したデータを非同期に表示できるようにしてます。

```dart
import 'package:api_app/domain/dto/todo_dto.dart';
import 'package:api_app/domain/entity/todo.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'todo_repo.g.dart';

@riverpod
Future<List<Todo>> todoRepository(TodoRepositoryRef ref) async {
  return await ref.read(todoDtoProvider).fetchTodo();
}
```

## 画面に表示するView
こちらは、FlutterのWidgetで作成したUIですね。Viewっても呼びますか。`AsyncValue`というデータ型でAPIのデータは渡されてきます。ここは、StreamProviderを使っていても同じデータ型が渡されてきます。

```
AsyncValue<List<Todo>> todo
Type: AsyncValue<List<Todo>>
```

APIのデータを表示するときは最近は、whenメソッドではなくて、Dart3のswitchでRiverpodを使うらしいです?

https://riverpod.dev/ja/docs/providers/future_provider

```dart

Widget build(BuildContext context, WidgetRef ref) {
  final config = ref.watch(fetchConfigurationProvider);

  return switch (config) {
    AsyncError(:final error) => Text('Error: $error'),
    AsyncData(:final value) => Text(value.host),
    _ => const CircularProgressIndicator(),
  };
}
```

:::details View側のコード
```dart
import 'package:api_app/domain/repository/todo_repo.dart';
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
      debugShowCheckedModeBanner: false,
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
    final todo = ref.watch(todoRepositoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('DTO MVVM'),
      ),
      // [todo]の状態によって、表示するWidgetを変更する
      body: switch (todo) {
        AsyncData(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(value[index].title),
                subtitle: Text(value[index].id.toString()),
              );
            },
          ),
        AsyncError(:final error) => Text('Error: $error'),
        _ => const CircularProgressIndicator(),
      },
    );
  }
}
```


## 最後に
今回は、Androidの設計パターンを取り入れてRiverpodを使ってみました。他の言語じゃないと設計のパターンってないので、どれがFlutterと相性がいいのかわからないですね?
