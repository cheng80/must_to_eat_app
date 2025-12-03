import 'package:flutter_slidable/flutter_slidable.dart';

import '../model/musteatplace.dart';
import '../vm/database_handler.dart';
import 'package:flutter/material.dart';
import '../custom/custom.dart';
  
enum FunctionType { reardelete, restore }

class DeletedPage extends StatefulWidget {
  const DeletedPage({super.key});

  @override
  State<DeletedPage> createState() => _DeletedPageState();
}

class _DeletedPageState extends State<DeletedPage> {
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
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: CustomText( "삭제한 맛집", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,),),
      body: CustomPadding.all(
        16,
        child: FutureBuilder( // 비동기 처리 위젯
          future: _handler.queryDeletedData(),  // 미래에 실행 될 작업
          builder: (context, snapshot) { // 작업이 끝난 후 실행 될 빌더
            return snapshot.hasData && snapshot.data!.isNotEmpty
            ? CustomListView(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                return Slidable(
                  startActionPane: _getActionPlane(Colors.blue, Icons.restore, '복원', (context) async {
                    await _dataChangeFn(FunctionType.restore, snapshot, index);
                  }),
                  endActionPane: _getActionPlane(Colors.red, Icons.delete, '삭제', (context) async {
                    await _dataChangeFn(FunctionType.reardelete, snapshot, index);
                  }),
                  child: _buildCustomCard(snapshot, index),
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
    _handler.queryDeletedData();
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
    if (type == FunctionType.restore) {
      await _handler.restoreData(musteatplace);
      _reloadData();
    }else if (type == FunctionType.reardelete) {
      await _handler.realDeleteData(musteatplace);
      _reloadData();
    } 
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
          borderRadius: BorderRadius.circular(16),
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
                  "이름 : ${snapshot.data![index].name}",
                  fontSize: 16, 
                  maxLines: 1, // 필요에 따라 조절
                  overflow: TextOverflow.ellipsis,
                ),
                CustomText(
                  "전화번호 : ${snapshot.data![index].phone}",
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