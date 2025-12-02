//-- Insert Address Page -
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/musteatplace.dart';
import '../vm/database_handler.dart';
import '../custom/custom.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  //Property
  //late 는 초기화를 나중으로 미룸
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _estimateController;
  late double _rating;
  

  late DatabaseHandler _handler;
  late ImagePicker picker;  
   XFile? imageFile; // 선택된 이미지 파일 저장 (확장자 유의)
   late List<TextEditingController> _textControllers = [];

   Musteatplace? args = Get.arguments as Musteatplace;
   late int firstDisp;


  @override
  void initState() { //페이지가 새로 생성 될때 무조건 1번 사용 됨
    super.initState();
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
      _latController = TextEditingController();
      _lngController = TextEditingController();
      _estimateController = TextEditingController();
    
      _handler = DatabaseHandler();
      picker = ImagePicker();
      
      _textControllers = [
        _nameController,
        _phoneController,
        _addressController,
        _latController,
        _lngController,
        _estimateController,
      ];
      if(args != null) {
        //수정 모드
        _nameController.text = args!.name;
        _phoneController.text = args!.phone;
        _addressController.text = args!.address;
        _latController.text = args!.lat.toString();
        _lngController.text = args!.lng.toString();
        _estimateController.text = args!.estimate;
        _rating = args!.starlevel.toDouble();
      }else {
        _rating = 5.0;
      }

      firstDisp = 0; //이미지 선택 여부

      print("args image length : ${args!.image.length}");
      print("args Rating : ${args!.starlevel} , _rating : $_rating");
        
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: CustomText( "맛집 수정", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,),),
      body: SingleChildScrollView(
        child: CustomPadding.all(
          16,
          child: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus(); //빈 공간 터치시 키보드 숨기기
            },

            child: Center(
              child: CustomColumn(
                spacing: 6,
                children:[

                  _getCameraAndGallyButtonRow(),

                  firstDisp == 0 ?
                  CustomCard(
                    color: Colors.white,
                    elevation: 4,
                    borderRadius: 16,
                    padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      child: CustomImage.memory(args!.image, height: 150, fit: BoxFit.contain,)
                   )
                  : CustomCard(
                    color: Colors.white,
                    elevation: 4,
                    borderRadius: 16,
                    padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      child: imageFile != null
                          ? CustomImage.file(File(imageFile!.path), height: 150, fit: BoxFit.contain,)
                          : Center(child: Text("Image is not selected")),
                   ),
                
                  _getLatLngRow(_latController, _lngController),

                  SizedBox(height: 10),
                  CustomTextField(
                    controller: _addressController,
                    labelText: "주소",
                    keyboardType: TextInputType.text,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    maxLength: 30,
                    controller: _nameController,
                    labelText: "상호를 수정 하세요",
                    keyboardType: TextInputType.text,
                  ),
                  CustomTextField(
                    maxLength: 14,
                    controller: _phoneController,
                    labelText: "매장번호를 수정 하세요",
                    keyboardType: TextInputType.text,
                  ),
                  CustomTextField(
                    maxLength: 50,
                    maxLines: 3,
                    controller: _estimateController,
                    labelText: "평가를 수정 하세요",
                    keyboardType: TextInputType.text,
                  ),

                
                  CustomPadding.horizontal(
                    20,
                    child: CustomRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _getRatingColumn(),
                                    
                        CustomButton(
                          btnText: "수정",
                          onCallBack: (){
                            //저장 기능 구현
                            if(firstDisp == 0){
                              print("이미지 변경 없음");
                              _updateActionCheck();
                            } else {
                              print("이미지 변경 있음");
                              _updateActionCheck(imageFile);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
            
                ]
              ),
            ),
          
          ),
        ),
      ),
    );
  }


  //--------Functions ------------
  //이미지 선택 함수
  Future<void> _getImageFromDevice(ImageSource source) async {
    final XFile? pickedFile = await picker.pickImage(source: source); //이미지 선택 다이얼로그 오픈
    if (pickedFile != null) { 
      // 이미지가 선택된 경우 처리할 코드 작성
      print('Selected image path: ${pickedFile.path}');
      imageFile = XFile(  pickedFile.path );
      firstDisp = 1;
    } else {
      // 사용자가 이미지를 선택하지 않은 경우 처리할 코드 작성
      imageFile = null;
      print('No image selected.');
    }
    setState(() {}); //화면 갱신
  }

  void reloadData() { //데이터 새로고침
    _handler.queryData();
    setState(() {});
  }

  bool _dateCheck() { //입력 데이터 체크
    for (TextEditingController element in _textControllers) { //텍스트 필드 체크
      if (!CustomTextField.textCheck(context, element)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _updateActionCheck( [XFile? imageFile] ) async {
    print("Insert Button Clicked");
    if(_dateCheck() == false) { //입력 데이터 체크
      CustomSnackBar.show( 
        context,
        message: "입력 필드가 비었거나 \n이미지가 선택되지 않았습니다.",
        textColor: Colors.white,
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // 공중에 떠있는 형태
      );
      return;
    }
    
    //FileType를 Byte Type으로 변환하기 
    File? imageFileData;
    Uint8List? getImageBytes;

    if(imageFile != null) {
      imageFileData = File(imageFile.path);
      getImageBytes = await imageFileData.readAsBytes();
    }


    Musteatplace musteatplace = Musteatplace(
      id: args!.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      lat: double.parse(_latController.text.trim()),
      lng: double.parse(_lngController.text.trim()),
      estimate: _estimateController.text.trim(),
      initdate: args!.initdate,
      starlevel: _rating.toInt(),
      image: imageFile != null ? getImageBytes! : args!.image,
    );

    int result = await _handler.updateDataAll(musteatplace);
    reloadData();
    if(result == 0) {
      //입력 실패
      _errorSnackBar();
    } else {
      //입력 성공
      _showDialog();
    }  
  }

  _showDialog() {
    CustomDialog.show(
      context,
      title: "알림",
      message: "수정이 완료 되었습니다.",
      type: DialogType.single,
      confirmText: "확인",
      onConfirm: () {
        Navigator.of(context).pop(); //다이얼로그 닫기
      },
    );
  }

  _errorSnackBar() {
    CustomSnackBar.show( 
      context,
      message: "입력 중 문제가 발생 하였습니다.",
      textColor: Colors.white,
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating, // 공중에 떠있는 형태
    );
  }

  CustomRow _getLatLngRow(TextEditingController latController, TextEditingController lngController) {
    return CustomRow(
      spacing: 16,
      width: MediaQuery.of(context).size.width,
      children: [
        Expanded(
          child: CustomTextField(
            readOnly: true,
            controller: latController,
            labelText: '위도',
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
        Expanded(
          child: CustomTextField(
            readOnly: true,
            controller: lngController,
            labelText: '경도',
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
      ],
    );
  }

  CustomRow _getCameraAndGallyButtonRow(){
    return CustomRow(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20,
      children: [
        CustomButton(
          minimumSize: Size(100, 50),
          btnText: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.photo_camera_back,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              CustomText(
                "Photo",
                fontSize: 16,
                color: Colors.white,
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          onCallBack: (){
            _getImageFromDevice(ImageSource.camera);
          },
        ),
        
        CustomButton(
          minimumSize: Size(100, 50),
          btnText: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.camera_roll,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              CustomText(
                "Gallery",
                fontSize: 16,
                color: Colors.white,
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          onCallBack: (){
            _getImageFromDevice(ImageSource.gallery);
          },
        ),
      ],
    );
  }

  CustomColumn _getRatingColumn() {
    return CustomColumn(
      children: [
        CustomText(
          "별점을 선택해주세요",
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
        CustomRating(
          rating: _rating,
          onRatingChanged: (rating) {
            setState(() {
              _rating = rating;
            });
          },
          starSize: 32.0,
        ),
      ],
    );
  }
  //------------------------------
}