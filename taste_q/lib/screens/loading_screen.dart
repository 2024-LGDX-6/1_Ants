import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/screens/final_ready_screen.dart';
import 'package:taste_q/views/front_appbar.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:taste_q/providers/ble_provider.dart';

class LoadingScreen extends StatefulWidget {
  final String recipeImageUrl;
  final String recipeName;
  final int recipeId;
  final List<String> seasoningName;
  final List<double> amounts;
  final String recipeLink;
  final int recipeType;
  final int servings;
  final int cookingMode;
  final String startTime;
  final BluetoothDevice? connectedDevice;
  final BluetoothCharacteristic? txCharacteristic;

  const LoadingScreen({
    super.key,
    required this.recipeImageUrl,
    required this.recipeName,
    required this.recipeId,
    required this.seasoningName,
    required this.amounts,
    required this.recipeLink,
    required this.recipeType,
    required this.servings,
    required this.cookingMode,
    required this.startTime,
    this.connectedDevice,
    this.txCharacteristic,
  });


  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  int _stage = 0; // 0~5: 단계, 6: 마지막
  List<bool> _showText = [false, false, false];
  List<bool> _showCheck = [false, false, false];
  List<String> _images = [
    "images/tasteQ.png",
    "images/elec_range.png",
    "images/fridge.png"
  ];
  List<String> _messages = [
    "조미료 분사 준비중",
    "상태 확인중",
    "재고 확인중"
  ];

  @override
  void initState() {
    super.initState();
    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1단계: tasteQ, 텍스트 보이기
    setState(() {
      _stage = 0;
      _showText[0] = true;
    });
    await Future.delayed(const Duration(milliseconds: 1800));
    // 1단계 완료: 텍스트 숨기고 체크 표시 (체크가 더 천천히 보이도록)
    setState(() {
      _showText[0] = false;
      _showCheck[0] = true;
      _stage = 1;
    });
    await Future.delayed(const Duration(milliseconds: 1200)); // 체크 더 오래 보여줌
    // 2단계: elec_range, 텍스트 보이기
    setState(() {
      _showText[1] = true;
      _stage = 2;
    });
    await Future.delayed(const Duration(milliseconds: 1800));
    // 2단계 완료: 텍스트 숨기고 체크 표시 (체크가 더 천천히 보이도록)
    setState(() {
      _showText[1] = false;
      _showCheck[1] = true;
      _stage = 3;
    });
    await Future.delayed(const Duration(milliseconds: 1200)); // 체크 더 오래 보여줌
    // 3단계: fridge, 텍스트 보이기
    setState(() {
      _showText[2] = true;
      _stage = 4;
    });
    await Future.delayed(const Duration(milliseconds: 1800));
    // 3단계 완료: 텍스트 숨기고 체크 표시 (체크가 더 천천히 보이도록)
    setState(() {
      _showText[2] = false;
      _showCheck[2] = true;
      _stage = 5;
    });
    await Future.delayed(const Duration(milliseconds: 1200)); // 체크 더 오래 보여줌
    // 마지막: 세 이미지 수직 정렬, 체크 모두 표시
    setState(() {
      _stage = 6;
    });
    // BLE 명령 전송 (소금이 있을 때만)
    final ble = Provider.of<BleProvider>(context, listen: false);
    try {
      if (ble.txCharacteristic != null) {
        debugPrint("TX characteristic UUID: ${ble.txCharacteristic?.uuid}");
        List<String> seasoningNames = widget.seasoningName;
        List<double> amounts = widget.amounts;
        int saltIndex = seasoningNames.indexOf('소금');
        if (saltIndex != -1) {
          double amount = amounts[saltIndex];
          String command = "M_ON_${amount.toStringAsFixed(1)}";
          await ble.txCharacteristic!.write(utf8.encode(command), withoutResponse: false);
          debugPrint("아두이노에 전송됨: $command");
        } else {
          debugPrint("소금 없음. 전송하지 않음.");
        }
      } else {
        debugPrint("BLE 명령어 전송 생략됨 (txCharacteristic이 null)");
      }
    } catch (e) {
      debugPrint("전송 중 오류: $e");
    }
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => FinalReadyScreen(
            recipeId: widget.recipeId,
            recipeImageUrl: widget.recipeImageUrl,
            recipeName: widget.recipeName,
            seasoningName: widget.seasoningName,
            amounts: widget.amounts,
            recipeType: widget.recipeType,
            servings: widget.servings,
            cookingMode: widget.cookingMode,
            startTime: widget.startTime,
            recipeLink: widget.recipeLink,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FrontAppBar(appBarName: "디바이스 확인",),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Stack(
          children: [
            // 흐림 효과만 (어두운 overlay 제거)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            // 애니메이션 단계별
            if (_stage < 6)
              Center(child: _buildStageStep()),
            if (_stage == 6)
              _buildFinalScreen(),
          ],
        ),
      ),
    );
  }

  Widget _buildStageStep() {
    // 0: tasteQ 준비중, 1: tasteQ 체크, 2: elec_range 준비중, 3: elec_range 체크, 4: fridge 준비중, 5: fridge 체크
    int idx = (_stage ~/ 2).clamp(0, 2);
    String image = _images[idx];
    String? text = _showText[idx] ? _messages[idx] : null;
    bool showCheck = _showCheck[idx];
    // 이미지 크기: 높이 60~70% (가로세로 비율 맞춤)
    double imgHeight = (MediaQuery.of(context).size.height * 0.65).clamp(250.0, 550.0);
    double imgWidth = imgHeight;
    double iconSize = imgHeight * 0.17;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: imgHeight,
          child: Stack(
            children: [
              Center(
                child: Image.asset(
                  image,
                  height: imgHeight,
                  width: imgWidth,
                  fit: BoxFit.contain,
                ),
              ),
              // 체크 아이콘 (중앙 하단)
              Positioned(
                left: (imgWidth - iconSize) / 2,
                bottom: imgHeight * 0.05,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: showCheck
                      ? Icon(Icons.check_circle, color: Colors.green, size: iconSize, key: ValueKey('check$idx'))
                      : SizedBox(width: iconSize, height: iconSize),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 텍스트
        SizedBox(
          height: 40.h, // Fixed height to prevent layout shift
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: text != null
                ? Text(
              text,
              key: ValueKey('text$idx'),
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(2, 2),
                    ),
                  ]),
            )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildFinalScreen() {
    // 세 이미지 수직 정렬, 오른쪽에 체크, "준비 완료" 텍스트도 함께 표시
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double imgSize = (screenWidth * 0.23).clamp(90.0, 180.0);
    double iconSize = imgSize * 0.65;
    double fontSize = (screenWidth * 0.055).clamp(22.0, 36.0);
    double rowSpacing = (screenHeight * 0.06).clamp(24.0, 56.0);
    double sideSpacing = (screenWidth * 0.05).clamp(16.0, 36.0);
    List<String> readyTexts = ["조미료 분사 준비", "상태 확인", "재고 확인"];

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(3, (i) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: rowSpacing / 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                          _images[i],
                          width: imgSize,
                          height: imgSize,
                          fit: BoxFit.contain
                      ),
                      const SizedBox(height: 8),
                      Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: iconSize
                      ),
                    ],
                  ),
                  SizedBox(width: sideSpacing),
                  Text(
                    readyTexts[i],
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Text(
            "준비 완료",
            style: TextStyle(
              color: Colors.black,
              fontSize: fontSize * 1.05,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

// _buildDeviceRow는 더 이상 사용하지 않으므로 삭제하거나 남겨둡니다.
}
