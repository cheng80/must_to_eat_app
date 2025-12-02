import 'package:flutter/material.dart';

/// Switch 위젯
///
/// 사용 예시:
/// ```dart
/// CustomSwitch(value: _isSwitched, onChanged: (value) {})
/// CustomSwitch(value: _isSwitched, label: "알림 받기", onChanged: (value) {})
/// ```
class CustomSwitch extends StatelessWidget {
  /// Switch의 현재 값 (필수)
  final bool value;

  /// Switch 값 변경 시 호출되는 콜백 함수 (필수)
  final ValueChanged<bool> onChanged;

  /// Switch 활성화 상태의 색상 (기본값: Colors.blue)
  final Color? activeColor;

  /// Switch 비활성화 상태의 색상
  final Color? inactiveColor;

  /// Switch 비활성화 상태의 썸(thumb) 색상
  final Color? inactiveThumbColor;

  /// Switch 비활성화 상태의 트랙(track) 색상
  final Color? inactiveTrackColor;

  /// Switch 활성화 상태의 썸(thumb) 색상
  final Color? thumbColor;

  /// Switch 활성화 상태의 트랙(track) 색상
  final Color? trackColor;

  /// Switch 옆에 표시할 레이블 텍스트
  final String? label;

  /// 레이블 텍스트 스타일
  final TextStyle? labelStyle;

  /// Switch와 레이블 사이의 간격 (기본값: 12)
  final double? spacing;

  /// Switch 크기 조절 (기본값: null, Material 3 기본 크기 사용)
  final MaterialTapTargetSize? materialTapTargetSize;

  /// 커스텀 SwitchThemeData (다른 스타일 속성들을 직접 지정하고 싶을 때 사용)
  final SwitchThemeData? switchTheme;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.trackColor,
    this.label,
    this.labelStyle,
    this.spacing,
    this.materialTapTargetSize,
    this.switchTheme,
  });

  @override
  Widget build(BuildContext context) {
    final switchWidget = SwitchTheme(
      data:
          switchTheme ??
          SwitchThemeData(
            thumbColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return inactiveThumbColor;
              }
              if (states.contains(WidgetState.selected)) {
                return thumbColor ?? activeColor ?? Colors.blue;
              }
              return inactiveThumbColor;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.disabled)) {
                return inactiveTrackColor;
              }
              if (states.contains(WidgetState.selected)) {
                return trackColor ??
                    activeColor?.withValues(alpha: 0.5) ??
                    Colors.blue.withValues(alpha: 0.5);
              }
              return inactiveTrackColor;
            }),
            overlayColor: WidgetStateProperty.resolveWith<Color?>((
              Set<WidgetState> states,
            ) {
              if (states.contains(WidgetState.selected)) {
                return activeColor?.withValues(alpha: 0.12) ??
                    Colors.blue.withValues(alpha: 0.12);
              }
              return null;
            }),
          ),
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: activeColor,
        inactiveThumbColor: inactiveThumbColor,
        inactiveTrackColor: inactiveTrackColor,
        thumbColor: thumbColor != null
            ? WidgetStateProperty.all(thumbColor)
            : null,
        trackColor: trackColor != null
            ? WidgetStateProperty.all(trackColor)
            : null,
        materialTapTargetSize: materialTapTargetSize,
      ),
    );

    // 레이블이 있는 경우 Row로 감싸서 반환
    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          switchWidget,
          SizedBox(width: spacing ?? 12),
          Text(
            label!,
            style: labelStyle ?? TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      );
    }

    return switchWidget;
  }
}
