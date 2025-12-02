import 'package:path/path.dart';
import '../model/musteatplace.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHandler {
  // DatabaseHandler 클래스의 내용
  //Database와 Table만들기
  Future<Database> initializeDB() async { 
    //DB생성 및 Table생성
    String path = await getDatabasesPath(); // DB가 저장될 위치 얻기
    print("Database Path : $path"); // DB경로 출력
    return openDatabase(
      join(path, 'musteatplace.db'),
      onCreate: (db, version) async {
        await db.execute(
          """
          CREATE TABLE musteatplace(id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT, 
          phone TEXT,
          address TEXT,
          lat REAL,
          lng REAL,
          image BLOB,
          estimate TEXT,
          initdate TEXT,
          starlevel INTEGER
          );
          """
        );
        await db.execute(
          """
          CREATE TABLE deleted_musteatplace(id INTEGER PRIMARY KEY AUTOINCREMENT, 
          name TEXT, 
          phone TEXT,
          address TEXT,
          lat REAL,
          lng REAL,
          image BLOB,
          estimate TEXT,
          initdate TEXT,
          starlevel INTEGER
          );
          """
        );
        //imge BLOB : 이미지 데이터를 바이트 형태로 저장
      },
      version: 1,
    );  
  }

  // musteatplace table 검색 
  Future<List<Musteatplace>> queryData() async {
    final Database db = await initializeDB(); // DB열기
    final List<Map<String, Object?>> queryResult = await db.rawQuery( // Object는 sqlite에서 지원하는 모든 타입
      'SELECT * FROM musteatplace' //전체 검색
    ); 
    return queryResult.map((e) => Musteatplace.fromMap(e)).toList(); //List<Musteatplace>로 변환 후 반환
  }
  // deleted_musteatplace table 검색
  Future<List<Musteatplace>> queryDeletedData() async {
    final Database db = await initializeDB(); // DB열기
    final List<Map<String, Object?>> queryResult = await db.rawQuery( // Object는 sqlite에서 지원하는 모든 타입
      'SELECT * FROM deleted_musteatplace' //전체 검색
    ); 
    return queryResult.map((e) => Musteatplace.fromMap(e)).toList(); //List<Musteatplace>로 변환 후 반환
  }

  //입력
  Future<int> insertData(Musteatplace musteatplace) async {
    int result = 0; // 반환 값 0이면 실패, 1 이상 이면 성공
    final Database db = await initializeDB();
    result = await db.rawInsert( 
      // id 는 Auto Increment이므로 입력하지 않음
      '''
      INSERT INTO musteatplace (name, phone, address, lat, lng, image, estimate, initdate, starlevel) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [musteatplace.name, musteatplace.phone, musteatplace.address, musteatplace.lat, musteatplace.lng, musteatplace.image, musteatplace.estimate, musteatplace.initdate, musteatplace.starlevel]
    );
    print("Insert return value : $result");

    return result;
    
  }

  //수정
  Future<int> updateData(Musteatplace musteatplace) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      '''
      UPDATE musteatplace 
      SET name = ?, phone = ?, address = ?, estimate = ?, starlevel = ?
      WHERE id = ?
      ''',
      [musteatplace.name, musteatplace.phone, musteatplace.address, musteatplace.estimate, musteatplace.starlevel, musteatplace.id]
    );
    return result;
  }

  Future<int> updateDataAll(Musteatplace musteatplace) async {
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawUpdate(
      '''
      UPDATE musteatplace 
      SET name = ?, phone = ?, address = ?, estimate = ?, starlevel = ?, image = ?
      WHERE id = ?
      ''',
      [musteatplace.name, musteatplace.phone, musteatplace.address, musteatplace.estimate, musteatplace.starlevel, musteatplace.image, musteatplace.id]
    );
    return result;
  }
 

  //임시 삭제  
  Future<void> delectData(Musteatplace musteatplace) async {
    print("Deleting musteatplace id: ${musteatplace.id}");
    final Database db = await initializeDB(); // DB열기
    int result = await db.rawInsert( //삭제 전에 deleted_address 테이블에 데이터 이동
      '''
      INSERT INTO deleted_musteatplace (name, phone, address, lat, lng, image, estimate, initdate, starlevel) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [musteatplace.name, musteatplace.phone, musteatplace.address, musteatplace.lat, musteatplace.lng, musteatplace.image, musteatplace.estimate, musteatplace.initdate, musteatplace.starlevel]
    );
    print("Moved to deleted_musteatplace, Insert return value : $result");
    if(result == 0) { //이동 실패 시 삭제 취소
      print("Error moving address to deleted_musteatplace table.");
      return;
    }else
    {
      await db.rawDelete( //이동 성공 시 musteatplace 테이블에서 삭제
        'DELETE FROM musteatplace WHERE id = ?',
        [musteatplace.id]
      );
    }
  }

  //복원  
  Future<void> restoreData(Musteatplace musteatplace) async {
    print("Restoring musteatplace id: ${musteatplace.id}");
    final Database db = await initializeDB(); // DB열기
    int result = await db.rawInsert( //삭제 전에 deleted_address 테이블에 데이터 이동
      '''
      INSERT INTO musteatplace (name, phone, address, lat, lng, image, estimate, initdate, starlevel) 
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [musteatplace.name, musteatplace.phone, musteatplace.address, musteatplace.lat, musteatplace.lng, musteatplace.image, musteatplace.estimate, musteatplace.initdate, musteatplace.starlevel]
    );
    print("Moved to musteatplace, Insert return value : $result");
    if(result == 0) { //이동 실패 시 삭제 취소
      print("Error moving address to musteatplace table.");
      return;
    }else
    {
      await db.rawDelete( //이동 성공 시 deleted_musteatplace 테이블에서 삭제
        'DELETE FROM deleted_musteatplace WHERE id = ?',
        [musteatplace.id]
      );
    }
  }
  //완전 삭제
  Future<void> realDeleteData(Musteatplace musteatplace) async {
    print("Deleting musteatplace id: ${musteatplace.id}");
    final Database db = await initializeDB(); // DB열기

    await db.rawDelete( //deleted_musteatplace 테이블에서 삭제
      'DELETE FROM deleted_musteatplace WHERE id = ?',
      [musteatplace.id]
    );
    
  }



}