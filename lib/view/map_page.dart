import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../custom/custom.dart';
import '../model/musteatplace.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //Property

  Musteatplace? args = Get.arguments as Musteatplace;
  //late 는 초기화를 나중으로 미룸
  late MapController mapController;  //지도 컨트롤러
  late bool canRun;  //위치 정보 가져오기 가능 여부
  late List<String> _locationName; //위치 정보 리스트
  late latlng.LatLng _initLocation; //초기 위치 정보
  late TextEditingController _addressController;

  @override
  void initState() { //페이지가 새로 생성 될때 무조건 1번 사용 됨
    super.initState();
    mapController = MapController();
    _initLocation = latlng.LatLng(37.5665, 126.9780); //서울 시청 좌표
    _addressController = TextEditingController();
    _addressController.text = args!.address;
  }
  
  @override
  void dispose() {
    mapController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: CustomText( "위치 보기", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,),),
      body: Center(
        child: _flutterMap(),
      ),
    );
  }


  //--------Functions ------------
  _flutterMap()
  {
    return CustomColumn(
      spacing: 8,
      children: [
        SizedBox(height: 5,),
        CustomPadding.horizontal(
          16,
          child: CustomTextField(
            readOnly: true,
            controller: _addressController,
            labelText: '주소',
            labelStyle: TextStyle(fontSize: 16, color: Colors.grey[700]),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.2),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
        ),
        CustomRow(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 20,
          children: [
            CustomText(
              "별점: ${args!.starlevel.toString()}",
              fontSize: 20,
              color: Colors.amber,
            ),
            CustomRating(
              rating: args!.starlevel.toDouble(),
              readOnly: true,
              starSize: 32.0,
            ),
          ],
        ),

        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.7,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: latlng.LatLng(args!.lat, args!.lng),
              initialZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tj.app',
              ),
              
              MarkerLayer(
                  markers: [
                  Marker(
                    width: 220,
                    height: 110,
                    point: latlng.LatLng(args!.lat, args!.lng),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          margin: const EdgeInsets.only(bottom: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ],
                          ),
                          child: Text(
                            args!.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.pin_drop,
                          size: 40,
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
              )
              
            ],
            
          ),
        ),
      ],
    );
  }
  
  //------------------------------
}