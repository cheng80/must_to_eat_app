import 'package:flutter/material.dart';

/// Checkbox 위젯
///
/// 사용 예시:
/// ```dart
/// CustomCheckbox(value: _isChecked, onChanged: (value) {})
/// CustomCheckbox(value: _isChecked, label: "이용약관 동의", onChanged: (value) {})
/// ```
class CustomCheckbox extends StatelessWidget {
  /// Checkbox의 현재 값 (필수)
  final bool? value;

  /// Checkbox 값 변경 시 호출되는 콜백 함수 (필수)
  final ValueChanged<bool?>? onChanged;

  /// Checkbox 활성화 상태의 색상 (기본값: Colors.blue)
  final Color? activeColor;

  /// Checkbox 비활성화 상태의 색상
  final Color? inactiveColor;

  /// Checkbox 체크 마크 색상
  final Color? checkColor;

  /// Checkbox 옆에 표시할 레이블 텍스트
  final String? label;

  /// 레이블 텍스트 스타일
  final TextStyle? labelStyle;

  /// Checkbox와 레이블 사이의 간격 (기본값: 8)
  final double? spacing;

  /// Checkbox 크기 조절 (기본값: null, Material 3 기본 크기 사용)
  final MaterialTapTargetSize? materialTapTargetSize;

  /// Checkbox의 시각적 밀도
  final VisualDensity? visualDensity;

  /// 커스텀 CheckboxThemeData (다른 스타일 속성들을 직접 지정하고 싶을 때 사용)
  final CheckboxThemeData? checkboxTheme;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.checkColor,
    this.label,
    this.labelStyle,
    this.spacing,
    this.materialTapTargetSize,
    this.visualDensity,
    this.checkboxTheme,
  });

  @override
  Widget build(BuildContext context) {
    final checkboxWidget = CheckboxTheme(
      data: checkboxTheme ??
          CheckboxThemeData(
            fillColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.disabled)) {
                  return inactiveColor;
                }
                if (states.contains(WidgetState.selected)) {
                  return activeColor ?? Colors.blue;
                }
                return inactiveColor;
              },
            ),
            checkColor: WidgetStateProperty.all(
              checkColor ?? Colors.white,
            ),
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return activeColor?.withValues(alpha: 0.12) ?? Colors.blue.withValues(alpha: 0.12);
                }
                return null;
              },
            ),
          ),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
        checkColor: checkColor,
        materialTapTargetSize: materialTapTargetSize,
        visualDensity: visualDensity,
      ),
    );

    // 레이블이 있는 경우 Row로 감싸서 반환
    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          checkboxWidget,
          SizedBox(width: spacing ?? 8),
          Text(
            label!,
            style: labelStyle ??
                TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
          ),
        ],
      );
    }

    return checkboxWidget;
  }
}

