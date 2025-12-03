
import 'package:get/get.dart';
import 'package:path/path.dart';
import '../model/musteatplace.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';


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

  //DB 내용 일괄 삭제  
  Future<void> allClearData() async {
    
    final Database db = await initializeDB(); // DB열기
    await db.rawDelete( //mustateplace 테이블 내용 전체 삭제
      'DELETE FROM musteatplace'
    );
  }
  //더미 데이터 삽입
  Future<int> insertDummyData() async {
  final Database db = await initializeDB();

  // 1. id=1 레코드의 image 값 존재 여부 확인
  final List<Map<String, Object?>> rows = await db.rawQuery(
    '''
    SELECT image FROM musteatplace
    WHERE id = 1
    LIMIT 1;
    '''
  );

  if (rows.isEmpty) {
    Get.snackbar( 
      "Error", 
      "데이터가 존재하지 않습니다. 더미 데이터를 추가하려면 \n먼저 1개 이상의 데이터를 삽입해야 합니다.", 
      colorText: Colors.white, 
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
      snackPosition: SnackPosition.TOP
    );
    return 0;
  }

  final imageData = rows.first['image'];

  if (imageData == null) {
    Get.snackbar("Error", "데이터에 이미지가 존재해야 더미 데이터를 추가할 수 있습니다.",
      colorText: Colors.white, 
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 2),
      snackPosition: SnackPosition.TOP
    );
    return 0;
  }

  // 2. 더미 데이터 삽입
  int lastInsertedId = await db.rawInsert(
    '''
    INSERT INTO musteatplace
    (name, phone, address, lat, lng, image, estimate, initdate, starlevel)
    VALUES
    ('대박식당 강남역점', '02-555-1111', '서울특별시 강남구 테헤란로 151', 37.498095, 127.027610, NULL, '강남역 직장인 점심 맛집.', '2025-01-01', 5),
    ('한강국밥 잠실점', '02-423-2222', '서울특별시 송파구 올림픽로 240', 37.515316, 127.099031, NULL, '진한 국물과 양 많은 국밥.', '2025-01-02', 4),
    ('을지로 곰탕집', '02-2271-3333', '서울특별시 중구 을지로 12', 37.566216, 126.988677, NULL, '서울 로컬 감성의 곰탕집.', '2025-01-03', 5),
    ('광안리 해물파전', '051-752-4444', '부산광역시 수영구 광안해변로 219', 35.153204, 129.118321, NULL, '바다 보면서 해물파전과 막걸리.', '2025-01-04', 4),
    ('해운대 회센타', '051-747-5555', '부산광역시 해운대구 해운대해변로 264', 35.158698, 129.160384, NULL, '신선한 회와 초밥 세트가 인기.', '2025-01-05', 5),
    ('대구 막창골목 1호점', '053-422-6666', '대구광역시 중구 동성로2길 80', 35.868504, 128.596651, NULL, '막창이 쫄깃하고 냄새가 적다.', '2025-01-06', 5),
    ('전주비빔밥 중앙점', '063-284-7777', '전라북도 전주시 완산구 풍남문2길 12', 35.814987, 127.148126, NULL, '고명이 풍성한 전주비빔밥 전문점.', '2025-01-07', 4),
    ('광주 떡갈비촌', '062-227-8888', '광주광역시 동구 충장로4가 32', 35.146118, 126.918801, NULL, '수제 떡갈비와 한정식 세트.', '2025-01-08', 4),
    ('제주 흑돼지 거리', '064-733-9999', '제주특별자치도 서귀포시 중문관광로 72', 33.247200, 126.408150, NULL, '흑돼지 삼겹살과 모듬구이.', '2025-01-09', 5),
    ('인천 차이나타운 짜장', '032-777-0000', '인천광역시 중구 차이나타운로 41', 37.474501, 126.616981, NULL, '짜장과 짬뽕 둘 다 인기.', '2025-01-10', 3),
    ('수원 통닭거리 본점', '031-245-1111', '경기도 수원시 팔달구 팔달로 1가 15', 37.280030, 127.013900, NULL, '바삭한 옛날 통닭 전문.', '2025-01-11', 5),
    ('분당 국수나무', '031-711-2222', '경기도 성남시 분당구 황새울로 200', 37.378600, 127.112100, NULL, '잔치국수와 비빔국수가 맛있는 집.', '2025-01-12', 4),
    ('일산 호수뷰 카페', '031-901-3333', '경기도 고양시 일산동구 호수로 595', 37.658400, 126.770200, NULL, '호수공원 뷰가 좋은 디저트 카페.', '2025-01-13', 4),
    ('의정부 부대찌개 골목', '031-844-4444', '경기도 의정부시 호국로 1358', 37.738100, 127.045800, NULL, '진한 육수의 부대찌개.', '2025-01-14', 4),
    ('안양 평촌 순대타운', '031-389-5555', '경기도 안양시 동안구 시민대로 180', 37.392500, 126.953700, NULL, '순대국밥과 모듬순대 세트.', '2025-01-15', 3),
    ('천안 불당동 고기집', '041-555-6666', '충청남도 천안시 서북구 불당25로 134', 36.815100, 127.113900, NULL, '숙성 삼겹살과 목살 세트.', '2025-01-16', 5),
    ('아산 온양 설렁탕', '041-532-7777', '충청남도 아산시 온천대로 1451', 36.781000, 127.002600, NULL, '24시간 설렁탕 전문점.', '2025-01-17', 4),
    ('청주 성안길 분식', '043-255-8888', '충청북도 청주시 상당구 성안로 23', 36.635700, 127.488900, NULL, '떡볶이와 튀김, 순대 세트.', '2025-01-18', 4),
    ('세종 정부청사 곰국', '044-865-9999', '세종특별자치시 도움3로 20', 36.504000, 127.265300, NULL, '점심시간 직장인 줄 서는 집.', '2025-01-19', 4),
    ('대전 빵집옆 분식', '042-222-0000', '대전광역시 중구 대흥로 170', 36.327400, 127.427500, NULL, '빵 사러 왔다가 함께 들르는 분식집.', '2025-01-20', 3),
    ('포항 물회 골목', '054-246-1111', '경상북도 포항시 북구 해안로 195', 36.032000, 129.365000, NULL, '시원한 물회와 회덮밥.', '2025-01-21', 5),
    ('울산 삼산동 숯불갈비', '052-258-2222', '울산광역시 남구 삼산로 277', 35.538400, 129.338000, NULL, '가성비 좋은 숯불갈비.', '2025-01-22', 4),
    ('창원 상남동 떡볶이', '055-262-3333', '경상남도 창원시 성산구 상남로 113', 35.223400, 128.681200, NULL, '매콤한 국물떡볶이 전문.', '2025-01-23', 3),
    ('마산 어시장 회집', '055-241-4444', '경상남도 창원시 마산합포구 어시장10길 34', 35.193000, 128.572000, NULL, '현지인들이 찾는 회 전문점.', '2025-01-24', 4),
    ('진주 냉면 골목', '055-744-5555', '경상남도 진주시 동성로 120', 35.180200, 128.108000, NULL, '비빔냉면과 물냉면이 유명.', '2025-01-25', 4),
    ('통영 중앙시장 충무김밥', '055-644-6666', '경상남도 통영시 중앙시장4길 6', 34.855700, 128.434700, NULL, '충무김밥과 오징어무침 세트.', '2025-01-26', 4),
    ('순천 야시장 꼬치구이', '061-742-7777', '전라남도 순천시 장선배기길 24', 34.950600, 127.487200, NULL, '야시장 분위기의 꼬치구이.', '2025-01-27', 3),
    ('여수 밤바다 포차', '061-662-8888', '전라남도 여수시 종화동 600', 34.743000, 127.736700, NULL, '야경 보면서 해산물 안주.', '2025-01-28', 5),
    ('목포 항구 갈치조림', '061-242-9999', '전라남도 목포시 해안로 52', 34.789000, 126.386200, NULL, '갈치조림과 생선구이.', '2025-01-29', 4),
    ('강릉 안목 커피거리', '033-652-1111', '강원특별자치도 강릉시 창해로 14', 37.772100, 128.951500, NULL, '바다 보며 마시는 핸드드립.', '2025-01-30', 5),
    ('속초 중앙시장 회센타', '033-633-2222', '강원특별자치도 속초시 중앙로 147', 38.207300, 128.591200, NULL, '시장 안 회와 튀김 세트.', '2025-01-31', 4),
    ('춘천 닭갈비 골목', '033-252-3333', '강원특별자치도 춘천시 명동길 24', 37.881300, 127.729000, NULL, '숯불 닭갈비와 막국수.', '2025-02-01', 5),
    ('원주 단구동 곱창', '033-744-4444', '강원특별자치도 원주시 단구로 123', 37.332600, 127.919800, NULL, '곱이 꽉 찬 소곱창 구이.', '2025-02-02', 4),
    ('평창 한우마을 식당', '033-332-5555', '강원특별자치도 평창군 평창읍 백오로 45', 37.370500, 128.390000, NULL, '한우 구이와 곰탕 세트.', '2025-02-03', 5),
    ('제천 청풍호 매운탕', '043-647-6666', '충청북도 제천시 청풍면 청풍호로 180', 37.017900, 128.205500, NULL, '민물매운탕과 매운탕칼국수.', '2025-02-04', 4),
    ('단양 마늘떡갈비', '043-423-7777', '충청북도 단양군 단양읍 도전천길 15', 36.984200, 128.365900, NULL, '마늘 향이 진한 떡갈비.', '2025-02-05', 4),
    ('김포 공항 근처 국밥', '02-2660-8888', '서울특별시 강서구 하늘길 77', 37.562200, 126.801800, NULL, '새벽 비행 전 후 먹기 좋은 국밥.', '2025-02-06', 3),
    ('구리 한강 뷰 카페', '031-555-9999', '경기도 구리시 체육관로 40', 37.593600, 127.147600, NULL, '루프탑에서 보는 한강 뷰.', '2025-02-07', 4),
    ('남양주 다산동 브런치', '031-566-0000', '경기도 남양주시 다산순환로 50', 37.630600, 127.158200, NULL, '브런치와 파스타 전문 카페.', '2025-02-08', 4),
    ('파주 프로방스 파스타', '031-941-1111', '경기도 파주시 탄현면 성동로 40', 37.800400, 126.708300, NULL, '이탈리안 파스타와 피자.', '2025-02-09', 3),
    ('양평 두물머리 카페', '031-772-2222', '경기도 양평군 양서면 두물머리길 125', 37.553300, 127.320200, NULL, '강가 뷰와 핸드드립 커피.', '2025-02-10', 5),
    ('가평 쁘띠프랑스 레스토랑', '031-581-3333', '경기도 가평군 청평면 호반로 763', 37.815200, 127.512300, NULL, '프렌치 스타일 스테이크.', '2025-02-11', 4),
    ('홍천 강변 막국수', '033-433-4444', '강원특별자치도 홍천군 홍천읍 연봉로 20', 37.691000, 127.888700, NULL, '시원한 메밀 막국수.', '2025-02-12', 4),
    ('포천 이동 갈비촌', '031-532-5555', '경기도 포천시 이동면 화동로 1134', 37.943000, 127.295800, NULL, '숯불 양념갈비 전문.', '2025-02-13', 5),
    ('안동 찜닭 골목', '054-853-6666', '경상북도 안동시 문화광장길 45', 36.566300, 128.729400, NULL, '간장 베이스 안동찜닭.', '2025-02-14', 5),
    ('경주 황리단길 카페', '054-748-7777', '경상북도 경주시 포석로 1070', 35.842800, 129.211600, NULL, '디저트와 커피가 예쁜 카페.', '2025-02-15', 4),
    ('군산 칼국수 골목', '063-445-8888', '전라북도 군산시 은파순환길 42', 35.986400, 126.707400, NULL, '바지락 칼국수와 수제 만두.', '2025-02-16', 4),
    ('익산 왕궁 비빔밥', '063-852-9999', '전라북도 익산시 왕궁면 호반로 12', 35.960300, 127.012700, NULL, '돌솥비빔밥 전문 식당.', '2025-02-17', 3),
    ('김해 장유 숯불갈비', '055-338-0000', '경상남도 김해시 삼문로 20', 35.205700, 128.802200, NULL, '가족단위 숯불갈비 맛집.', '2025-02-18', 4),
    ('양산 물금 돼지국밥', '055-383-1111', '경상남도 양산시 물금읍 야리로 35', 35.323100, 129.008500, NULL, '진한 사골 돼지국밥.', '2025-02-19', 5);
    '''
  );

  print("Dummy insert completed. lastInsertedId: $lastInsertedId");

  // 3. image 복제 (2~50번)
  await db.rawUpdate(
    '''
    UPDATE musteatplace
    SET image = (SELECT image FROM musteatplace WHERE id = 1)
    WHERE id > 1;
    '''
  );

  return lastInsertedId;
}                     



}