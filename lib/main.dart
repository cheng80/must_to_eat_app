//main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:must_to_eat_app/view/insert_page.dart';
import 'view/deleted_page.dart';
import 'view/home.dart';
import 'view/map_page.dart';
import 'view/update_page.dart';


//import 'package:프로젝트명/home.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Main',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      debugShowCheckedModeBanner: false, // 우측 상단 디버그 배너 제거
      
      // 다국어 지원
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // 영어
        const Locale('ko', 'KR'), // 한국어
        const Locale('ja', 'JP'), // 일본어
      ],
      
      initialRoute: '/', // 처음 화면 지정
      routes: {
        '/': (context) => const Home(),
        '/insert_page': (context) => const InsertPage(),
        '/update_page': (context) => const UpdatePage(),
        '/deleted_page': (context) => const DeletedPage(),
        '/map_page': (context) => const MapPage(),

        
      },
    );
  }
}
