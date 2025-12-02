import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../model/musteatplace.dart';
import '../vm/database_handler.dart';
import '../custom/custom.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class InsertPage extends StatefulWidget {
  const InsertPage({super.key});

  @override
  State<InsertPage> createState() => _InsertPageState();
}

class _InsertPageState extends State<InsertPage> {
  //Property
  XFile? imageFile; // 선택된 이미지 파일 저장 (확장자 유의)
  

  //late 는 초기화를 나중으로 미룸
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _addressController;
  late TextEditingController _estimateController;
  late DatabaseHandler _handler;
  late ImagePicker picker;  
  late List<TextEditingController> _textControllers = [];
  late double _rating;

  late bool _isLoading;
  late String _result;

  late Position currentPosition; //현재 위치 정보 변수
  late double latData; //위도
  late double lngData; //경도
  late bool canRun;  //위치 정보 가져오기 가능 여부

  late String currentAddress;



  @override
  void initState() { //페이지가 새로 생성 될때 무조건 1번 사용 됨
    super.initState();
      _nameController = TextEditingController();
      _phoneController = TextEditingController();
      _latController = TextEditingController();
      _lngController = TextEditingController();
      _addressController = TextEditingController();
      _estimateController = TextEditingController();
     _handler = DatabaseHandler();
      picker = ImagePicker();
      _textControllers = [
        _nameController,
        _phoneController,
        _latController,
        _lngController,
        _estimateController,
      ];
      _isLoading = false;
      _result = '';
      latData = 0;
      lngData = 0;
      canRun = false;
      currentAddress = '';
      _rating = 5.0;
      _checkLocationPermission();


  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _addressController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: CustomText( "맛집 추가", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,),),
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

                  CustomCard(
                    color: Colors.white,
                    elevation: 4,
                    borderRadius: 16,
                    padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      child: imageFile != null
                          ? CustomImage.file(File(imageFile!.path), height: 150, fit: BoxFit.contain,)                       
                          : Center(child: CustomText("이미지를 선택 하세요.")),
                   ),
                
                  _getLatLngRow(_latController, _lngController),

                  SizedBox(height: 10),
                  CustomTextField(
                    controller: _addressController,
                    labelText: "주소",
                    hintText: "위치 정보 가져오기를 통해 설정 됩니다.",
                    keyboardType: TextInputType.text,
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  CustomTextField(
                    maxLength: 30,
                    controller: _nameController,
                    labelText: "상호를 입력 하세요",
                    keyboardType: TextInputType.text,
                  ),
                  CustomTextField(
                    maxLength: 14,
                    controller: _phoneController,
                    labelText: "매장번호를 입력 하세요",
                    keyboardType: TextInputType.text,
                  ),
                  CustomTextField(
                    maxLength: 50,
                    maxLines: 3,
                    controller: _estimateController,
                    labelText: "평가를 입력 하세요",
                    keyboardType: TextInputType.text,
                  ),

                  CustomPadding.horizontal(
                    20,
                    child: CustomRow(
                      
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _getRatingColumn(),
                                    
                        CustomButton(
                          btnText: "입력",
                          onCallBack: (){
                            //저장 기능 구현
                            _insertAction();
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
    } else {
      // 사용자가 이미지를 선택하지 않은 경우 처리할 코드 작성
      imageFile = null;
      print('No image selected.');
    }
    setState(() {}); //화면 갱신
  }

  void _reloadData() { //데이터 새로고침
    _handler.queryData();
    setState(() {});
  }

  bool _dateCheck() { //입력 데이터 체크
    for (TextEditingController element in _textControllers) { //텍스트 필드 체크
      if (!CustomTextField.textCheck(context, element)) {
        return false;
      }
    }
    if(imageFile == null) { //이미지 선택 여부 체크
      return false;
    }
    return true;
  }


  Future<void> _insertAction() async {
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
    File imageFileData = File(imageFile!.path);
    Uint8List getImageBytes = await imageFileData.readAsBytes();

    Musteatplace musteatplace = Musteatplace(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: currentAddress,
      lat: latData,
      lng: lngData,
      estimate: _estimateController.text.trim(),
      initdate: DateTime.now().toString(),
      starlevel: _rating.toInt(),
      image: getImageBytes,
    );

    int result = await _handler.insertData(musteatplace);
    _reloadData();
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
      message: "저장이 완료 되었습니다.",
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


  _checkLocationPermission() async //위치 권한 체크
  {
    LocationPermission permission = await Geolocator.checkPermission(); //현재 위치 권한 상태 확인

    if(permission == LocationPermission.denied){ //거부 됨
      permission = await Geolocator.requestPermission(); //다시 한번 권한 요청
    }

    if(permission == LocationPermission.deniedForever){ 
      //영구적으로 거부 됨
      _getSimpleAddressFromCoordinates(); //위치 정보 가져오기 시도
      return;
    } 
    
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always){
      //앱 사용 중에 허용 , 항상 허용

      _getCurrentLocation(); //현재 위치 정보 가져오기
    } else {
      //거부 됨
      return;
    }
  }

  _getCurrentLocation() async { //현재 위치 정보 가져오기
    // Position position = await Geolocator.getCurrentPosition(locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
    Position position = await Geolocator.getCurrentPosition(); //기본값이 high

    currentPosition = position;
    canRun = false;
    latData = currentPosition.latitude;
    lngData = currentPosition.longitude;
    _getSimpleAddressFromCoordinates();
    

    setState(() {});

  }

  /// 간단한 주소 가져오기
  Future<void> _getSimpleAddressFromCoordinates() async {
    setState(() {
      _isLoading = true;
      _result = '간단한 주소를 가져오는 중...\n';
    });

    try {
      final address = await CustomAddressUtil.getSimpleAddressFromCoordinates(
        latData,
        lngData,
      );

      setState(() {
        _isLoading = false;
        _result = '=== 간단한 주소 가져오기 (국가 제외) ===\n\n';
        _result += '위도: $latData\n';
        _result += '경도: $lngData\n\n';
        _result += '주소: $address\n';
        print(_result);
        currentAddress = address!;
        _addressController.text = currentAddress;
        _latController.text = _formatNumber(latData, 5);
        _lngController.text = _formatNumber(lngData, 6);
        canRun = true;
      });
    } on AddressException catch (e) {
      setState(() {
        _isLoading = false;
        _result = '❌ 오류 발생\n\n';
        _result += '메시지: ${e.message}\n';
        _result += '코드: ${e.code}\n';
        latData = 0;
        lngData = 0;
        currentAddress = "알수 없는 주소";
        _addressController.text = currentAddress;
        _latController.text = _formatNumber(latData);
        _lngController.text = _formatNumber(lngData);
        canRun = true;
        print(_result);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _result = '❌ 알 수 없는 오류: $e';
        latData = 0;
        lngData = 0;
        currentAddress = "알수 없는 주소";
        _addressController.text = currentAddress;
        _latController.text = _formatNumber(latData);
        _lngController.text = _formatNumber(lngData);
        canRun = true;
        print(_result);
      });
    }
  }

  String _formatNumber(double n , [int fractionDigits = 6]) { 

    return n % 1 == 0
      ? n.toInt().toString()  // 정수로 변환
      : n.toStringAsFixed(fractionDigits)                    // 소수점 첫째자리까지 반올림
        .replaceAll(RegExp(r'0+$'), '')       // 끝의 0 제거
        .replaceAll(RegExp(r'\.$'), '');      // 마지막이 .이면 제거
  }
  //------------------------------

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
}