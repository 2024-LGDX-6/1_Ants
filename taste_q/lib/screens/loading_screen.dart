import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taste_q/screens/final_ready_screen.dart';
import 'package:taste_q/views/front_appbar.dart';

class LoadingScreen extends StatefulWidget {
  final String recipeImageUrl;
  final String recipeName;
  final int recipeId;
  final List<String> seasoningName;
  final List<double> amounts;
  final String recipeLink;

  const LoadingScreen({
    super.key,
    required this.recipeImageUrl,
    required this.recipeName,
    required this.recipeId,
    required this.seasoningName,
    required this.amounts,
    required this.recipeLink,
  });

  @override
  State<LoadingScreen> createState() => _LoadingScreenState(

  );
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Alignment>> _animations;
  int _stage = 0;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
    });

    // 각 이미지의 목적지 위치 지정 - Y축 범위를 더 넓게 분배하여 균형 있게 조정
    final List<Alignment> endAlignments = [
      Alignment(-0.85, -0.9), // tasteQ: 상단
      Alignment(-0.85, 0.0),  // elec_range: 중앙
      Alignment(-0.85, 0.9),  // fridge: 하단
    ];

    _animations = List.generate(3, (i) {
      return AlignmentTween(
        begin: Alignment.center,
        end: endAlignments[i],
      ).animate(CurvedAnimation(
          parent: _controllers[i], curve: Curves.easeInOut)
      );
    });

    _runSequence();
  }

  Future<void> _runSequence() async {
    for (int i = 0; i < 3; i++) {
      setState(() {
        _stage = i;
      });
      await Future.delayed(const Duration(seconds: 2)); // 유지 시간 증가
      _controllers[i].forward();
      await Future.delayed(const Duration(milliseconds: 800)); // 애니메이션 시간 그대로 유지
    }
    await Future.delayed(const Duration(milliseconds: 500)); // 마지막 애니메이션 여유 시간
    setState(() {
      _stage = 3; // 종료 상태
    });
    await Future.delayed(const Duration(milliseconds: 1500)); // 1.5초 대기 후 화면 전환
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => FinalReadyScreen(
            recipeId: widget.recipeId,
            recipeImageUrl: widget.recipeImageUrl,
            recipeName: widget.recipeName,
            seasoningName: widget.seasoningName,
            amounts: widget.amounts,
            recipeLink: widget.recipeLink,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FrontAppBar(),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 36),
            _stage < 3
                ? Expanded(child: _buildStageAnimation())
                : _buildFinalState(),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildStageAnimation() {
    final messages = ["조미료 분사중", "상태 확인중", "재고 갱신중"];
    final images = [
      "images/tasteQ.png",
      "images/elec_range.png",
      "images/fridge.png"
    ];

    // 3개 모두를 쌓아놓고, 현재 단계에만 중앙 노출, 이전 단계는 이동
    return Stack(
      children: List.generate(3, (i) {
        bool show = (_stage == i) || (_stage > i);
        return Visibility(
          visible: show,
          child: AnimatedBuilder(
            animation: _animations[i],
            builder: (context, child) {
              return AnimatedAlign(
                alignment: _animations[i].value,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                child: i == _stage
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(images[i], width: 130.w, height: 130.h),
                          SizedBox(height: 20.h),
                          Text(
                            messages[i],
                            style: TextStyle(
                                fontSize: 24.sp, fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Image.asset(images[i], width: 130.w, height: 130.h),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildFinalState() {
    final images = [
      "images/tasteQ.png",
      "images/elec_range.png",
      "images/fridge.png"
    ];
    final alignments = [
      Alignment(-0.85, -0.9), // tasteQ: 상단
      Alignment(-0.85, 0.0),  // elec_range: 중앙
      Alignment(-0.85, 0.9),  // fridge: 하단
    ];
    return Expanded(
      child: Stack(
        children: List.generate(3, (i) {
          return Align(
            alignment: alignments[i],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  images[i],
                  width: 130,
                  height: 130,
                ),
                SizedBox(width: 16.w),
                Text(
                  "완료",
                  style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 12.w),
                Icon(Icons.check, color: Colors.green, size: 36.h),
              ],
            ),
          );
        }),
      ),
    );
  }

  // _buildDeviceRow는 더 이상 사용하지 않으므로 삭제하거나 남겨둡니다.
}
