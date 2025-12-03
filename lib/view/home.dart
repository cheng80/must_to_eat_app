import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:must_to_eat_app/model/musteatplace.dart';
import '../custom/custom.dart';
import '../vm/database_handler.dart';

enum FunctionType { update, delete }


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Property
  //late 는 초기화를 나중으로 미룸
  late DatabaseHandler _handler; 
 
  @override
  void initState() { //페이지가 새로 생성 될때 무조건 1번 사용 됨
    super.initState();
    _handler = DatabaseHandler();
  }
  
  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // FAB는 body 밖에서 자동으로 고정됨
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Get.toNamed('/insert_page')?.then((value) {
            _reloadData();
          });
        },
        icon: Icons.add,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // 위치 지정
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        
        title: CustomText( "내가 경험한 맛집 리스트", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,),
        drawerIcon: Icons.menu, // Drawer 아이콘 커스텀 (기본값: Icons.menu)
        drawerIconColor: Colors.white.withAlpha(0),
        leading: Builder(
          builder: (context) {
            return GestureDetector(
              onLongPress: () {
                Scaffold.of(context).openDrawer();
              },
              child: Icon(Icons.menu, color: Colors.white.withAlpha(0),),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white,),
            onPressed: (){
              Get.toNamed('/insert_page')?.then((value) {
                _reloadData();
              });
            },
          ),
          CustomIconButton(
            icon: Icons.delete, 
            iconColor: Colors.white,
            onPressed: () {
              Get.toNamed('/deleted_page')?.then((value) {
                _reloadData();
              });
            }
          ),
        ],
      ),
      drawerEnableOpenDragGesture: false, // 스와이프 비활성화
      drawer: CustomDrawer(
        header: DrawerHeader(
          
          decoration: BoxDecoration(color: Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: CustomColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              
              CustomText(
                "맛집 더미 데이터 삽입",
                color: Colors.white70,
              ),

              CustomButton(
                btnText: "더미 데이터 삽입",
                onCallBack: () async {
                  int result = await _handler.insertDummyData();
                  _reloadData();
                  if (result > 0) {
                    CustomSnackBar.show(context, message: "더미 데이터가 삽입되었습니다.");
                    //drawer 닫기
                    Navigator.of(context).pop();
                  } else {
                    CustomSnackBar.show(context, message: "더미 데이터 삽입에 실패했습니다.");
                  }
                },
              ),
              //-----------
              
            ],
          ),
        ),
        items: [
          
        ],
        middleChildren: [
          Container(
            padding: const EdgeInsets.all(16),
            child: CustomColumn(
              children: [
                CustomText(
                  "맛집 데이터 일괄 삭제",
                  color: Colors.white70,
                ),

                CustomButton(
                  btnText: "데이터 일괄 삭제",
                  onCallBack: () async {
                    await _handler.allClearData();
                    _reloadData();
                    CustomSnackBar.show(context, message: "모든 맛집 데이터가 삭제되었습니다.");
                    //drawer 닫기
                    Navigator.of(context).pop();
                  },
                ),
                
              ],
            ),
          ),
        ],
        footer: Container(
          height: MediaQuery.of(context).size.height * 0.1,
          padding: const EdgeInsets.all(16),
          child: CustomColumn(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomText("맛집 앱 v1.0.0", color: Colors.grey,),
            ],
          ),
        ),
        
      ),
      body: CustomPadding.all(
        16,
        child: FutureBuilder( // 비동기 처리 위젯
          future: _handler.queryData(),  // 미래에 실행 될 작업
          builder: (context, snapshot) { // 작업이 끝난 후 실행 될 빌더
            print(snapshot.hasData && snapshot.data!.isNotEmpty? "Data length: ${snapshot.data!.length}" : "No data");
            return snapshot.hasData && snapshot.data!.isNotEmpty
            ? CustomListView(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                return Slidable(
                  startActionPane: _getActionPlane(Colors.green, Icons.edit, '수정', (context) async {
                    await _dataChangeFn(FunctionType.update, snapshot, index);
                  }),
                  endActionPane:_getActionPlane(Colors.red, Icons.delete, '삭제', (context) async {
                    await _dataChangeFn(FunctionType.delete, snapshot, index);
                  }),
                  child: GestureDetector(
                    onTap: (){
                      // _updateFn(snapshot, index);
                      _gotoMap( snapshot, index );
                    },
                    child: _buildCustomCard(snapshot, index),
                  ),
                );
              }): Center(
                child: CustomText("데이터가 없습니다."),
              );
          }, // Builder 끝
        ),
      )
    );
  }


  //--------Functions ------------
  void _reloadData() {
    _handler.queryData();
    setState(() {});
  }

  Future<void> _dataChangeFn(FunctionType type, AsyncSnapshot<List<Musteatplace>> snapshot, int index) async  // 수정 페이지로 이동
  { 
    Musteatplace musteatplace = Musteatplace(
      id: snapshot.data![index].id,
      name: snapshot.data![index].name,
      phone: snapshot.data![index].phone,
      address: snapshot.data![index].address,
      lat: snapshot.data![index].lat,
      lng: snapshot.data![index].lng,
      image: snapshot.data![index].image,
      estimate: snapshot.data![index].estimate,
      initdate: snapshot.data![index].initdate,
      starlevel: snapshot.data![index].starlevel,
    );

    print("Selected musteatplace id: ${musteatplace.id}");
    if (type == FunctionType.update) {
      await Get.toNamed('/update_page', arguments: musteatplace);
      _reloadData();
    }else if (type == FunctionType.delete) {
      await _handler.delectData(musteatplace);
      _reloadData();
    } 
  }


  _gotoMap(AsyncSnapshot<List<Musteatplace>> snapshot, int index) {
    Musteatplace musteatplace = Musteatplace(
      id: snapshot.data![index].id,
      name: snapshot.data![index].name,
      phone: snapshot.data![index].phone,
      address: snapshot.data![index].address,
      lat: snapshot.data![index].lat,
      lng: snapshot.data![index].lng,
      image: snapshot.data![index].image,
      estimate: snapshot.data![index].estimate,
      initdate: snapshot.data![index].initdate,
      starlevel: snapshot.data![index].starlevel,
    );
    print(  "Navigating to Map Page for musteatplace id: ${musteatplace.id}");
    print(  "Address: ${musteatplace.address}, Lat: ${musteatplace.lat}, Lng: ${musteatplace.lng}"  );
    Get.toNamed('/map_page', arguments: musteatplace)?.then((value) {
      _reloadData();
    });
  }

  ActionPane _getActionPlane(Color bgColor, IconData icon, String label, Function(BuildContext)? onPressed ) {
    return ActionPane(
      motion: BehindMotion(),
      children: [
        SlidableAction(
          onPressed: onPressed,
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          icon: icon,
          label: label,
        ),
      ],
    );
  }

  CustomCard _buildCustomCard(AsyncSnapshot<List<Musteatplace>> snapshot, int index) {
    return CustomCard(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(16),
      elevation: 4,
      borderRadius: 16,
      child: CustomRow(
        spacing: 10,
        children: [
          CustomImage.memory(snapshot.data![index].image, height: 60, fit: BoxFit.contain,),
          Expanded(
            child: CustomColumn(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  "상호 : ${snapshot.data![index].name}",
                  fontSize: 16, 
                  maxLines: 1, // 필요에 따라 조절
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  "매장번호 : ${snapshot.data![index].phone}",
                  fontSize: 16, 
                  maxLines: 1, // 필요에 따라 조절
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),  
    );
  }
  //------------------------------
}