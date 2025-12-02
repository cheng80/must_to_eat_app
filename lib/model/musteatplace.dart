import 'dart:typed_data';

class Musteatplace {
  int? id; //Auto Increment ID
  String name;
  String phone;
  String address;
  double lat ;
  double lng ;
  Uint8List image;
  String estimate;
  String initdate;
  int starlevel;

  Musteatplace(
    {
      this.id,
      required this.name,
      required this.phone,
      required this.address,
      required this.lat,
      required this.lng,
      required this.image,
      required this.estimate,
      required this.initdate,
      required this.starlevel,
    }
  );

  Musteatplace.fromMap(Map<String, dynamic> res) //테이블의 컬럼 이름과 동일하게 작성
      : id = res['id'],
        name = res['name']??'',
        phone = res['phone']??'',
        address = res['address']??'',
        lat = res['lat']??0.0,
        lng = res['lng']??0.0,
        image = res['image']??Uint8List(0),
        estimate = res['estimate']??'',
        initdate = res['initdate']??'',
        starlevel = res['starlevel']??5;
}