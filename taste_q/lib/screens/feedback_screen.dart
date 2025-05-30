import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taste_q/views/feedback_appbar.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // 피드백 선택지들을 담고 있는 리스트입니다.
  // 사용자가 이 중에서 하나를 선택할 수 있도록 보여줍니다.
  final List<String> _feedbackOptions = [
    '짰어요',
    '달았어요',
    '매웠어요',
    '좋았어요',
    '싱거웠어요',
  ];

  // 사용자가 선택한 피드백을 저장하는 Set입니다.
  // Set을 사용하여 중복 선택을 방지하고, 현재 선택된 항목을 관리합니다.
  final Set<String> _selectedOptions = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 화면 상단에 고정되는 앱바를 설정합니다.
      appBar: const FeedbackAppbar(),
      // 전체 배경색을 흰색으로 지정합니다.
      backgroundColor: Colors.white,
      // 화면 내용 전체에 16픽셀의 패딩을 줍니다.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // 자식 위젯들을 왼쪽 정렬로 배치합니다.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단에 약간의 여백을 줍니다.
            SizedBox(height: 16),
            // 화면에 "이 요리는 어땠나요?"라는 질문 텍스트를 크게 보여줍니다.
            const Text(
              '이 요리는 어땠나요?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // 텍스트 아래에 10픽셀 간격을 둡니다.
            const SizedBox(height: 10),
            // 추가로 40픽셀 높이의 공간을 만들어 텍스트와 체크박스 리스트 사이에 여백을 확보합니다.
            SizedBox(height: 40), // 살짝만 아래로 내려서 여백 확보
            // 피드백 선택지를 체크박스 형태로 나열하는 열(Column) 위젯입니다.
            Column(
              // _feedbackOptions 리스트의 각 항목을 체크박스 리스트 타일로 변환하여 보여줍니다.
              children: _feedbackOptions.map((option) {
                // 현재 옵션이 선택되었는지 여부를 확인합니다.
                final isSelected = _selectedOptions.contains(option);
                return Padding(
                  // 각 체크박스 리스트 타일 위아래에 12픽셀씩 여백을 줍니다.
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: CheckboxListTile(
                    // 체크박스 옆에 표시될 텍스트입니다.
                    title: Text(
                      option,
                      style: TextStyle(fontSize: 20),
                    ),
                    // 체크박스의 현재 선택 상태를 지정합니다.
                    value: isSelected,
                    // 체크박스가 선택되었을 때 표시되는 색상을 오렌지색으로 설정합니다.
                    activeColor: Colors.orange,
                    // 사용자가 체크박스를 클릭했을 때 호출되는 콜백 함수입니다.
                    // 체크박스가 선택되면 _selectedOptions에 해당 옵션만 남기고 모두 지웁니다.
                    // 즉, 한 번에 하나의 피드백만 선택할 수 있도록 합니다.
                    // 체크 해제를 하면 해당 옵션을 선택 목록에서 제거합니다.
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedOptions
                            ..clear()
                            ..add(option);
                        } else {
                          _selectedOptions.remove(option);
                        }
                      });
                    },
                    // 체크박스가 텍스트 왼쪽에 위치하도록 설정합니다.
                    controlAffinity: ListTileControlAffinity.leading,
                    // 체크박스 리스트 타일의 좌우 패딩을 없앱니다.
                    contentPadding: EdgeInsets.zero,
                    // 리스트 타일의 높이를 기본보다 조금 더 콤팩트하게 만듭니다.
                    dense: true,
                  ),
                );
              }).toList(),
            ),
            // 체크박스 리스트 아래에 80픽셀의 여백을 둡니다.
            const SizedBox(height: 80),
            // 제출 버튼을 화면 중앙에 배치합니다.
            Center(
              child: ElevatedButton(
                // 버튼이 눌렸을 때 실행되는 함수입니다.
                // 현재 선택된 피드백을 리스트로 변환하여 스낵바에 표시합니다.
                onPressed: () {
                  final selected = _selectedOptions.toList();

                  showDialog(
                    context: context,
                    barrierDismissible: false, // 다이얼로그 바깥 터치로 닫히지 않게
                    builder: (BuildContext context) {
                      // 1초 후 자동으로 닫히도록 Future.delayed 사용
                      Future.delayed(Duration(seconds: 1), () {
                        Navigator.of(context).pop(); // 첫 번째 뒤로가기
                        Navigator.of(context).pop(); // 두 번째 뒤로가기
                        Navigator.of(context).pop(); // 세 번째 뒤로가기
                      });
                      return AlertDialog(
                        backgroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 0),
                          child: IntrinsicHeight(
                            child: Center(
                              child: Text(
                                "의견 감사합니다!",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                // 버튼의 스타일을 지정합니다.
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.orange,
                ),
                // 버튼에 표시될 텍스트입니다.
                child: const Text(
                  "피드백 제출",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}