import 'package:flutter/material.dart';

/// 태그, 필터, 선택 표시용 Chip 위젯
///
/// 사용 예시:
/// ```dart
/// CustomChip(label: "태그", onDeleted: () {})
/// CustomChip(label: "필터", selectable: true, selected: true, onSelected: (selected) {})
/// ```
class CustomChip extends StatelessWidget {
  /// Chip에 표시할 라벨 (필수)
  /// String인 경우 Text로 자동 변환, Widget인 경우 그대로 사용
  final dynamic label;

  /// 삭제 버튼 클릭 시 콜백
  final VoidCallback? onDeleted;

  /// 선택 가능한 Chip인지 여부
  final bool selectable;

  /// 선택된 상태 (selectable이 true일 때만 유효)
  final bool selected;

  /// 선택 상태 변경 시 콜백 (selectable이 true일 때만 유효)
  final ValueChanged<bool>? onSelected;

  /// 왼쪽에 표시할 아바타
  final Widget? avatar;

  /// 배경색
  final Color? backgroundColor;

  /// 선택된 상태의 배경색
  final Color? selectedColor;

  /// 삭제 아이콘 색상
  final Color? deleteIconColor;

  /// 라벨 색상
  final Color? labelColor;

  /// 선택된 상태의 라벨 색상
  final Color? selectedLabelColor;

  /// 패딩
  final EdgeInsetsGeometry? padding;

  /// 모서리 둥글기
  final double? borderRadius;

  /// 아이콘 크기
  final double? iconSize;

  /// 삭제 아이콘
  final IconData? deleteIcon;

  /// 툴팁 메시지
  final String? tooltip;

  const CustomChip({
    super.key,
    required this.label,
    this.onDeleted,
    this.selectable = false,
    this.selected = false,
    this.onSelected,
    this.avatar,
    this.backgroundColor,
    this.selectedColor,
    this.deleteIconColor,
    this.labelColor,
    this.selectedLabelColor,
    this.padding,
    this.borderRadius,
    this.iconSize,
    this.deleteIcon,
    this.tooltip,
  }) : assert(
          !selectable || onSelected != null || !selected,
          'selectable이 true일 때 onSelected가 제공되어야 합니다.',
        );

  @override
  Widget build(BuildContext context) {
    // label이 String인지 Widget인지 확인
    Widget labelWidget;
    if (label is String) {
      labelWidget = Text(
        label as String,
        style: TextStyle(
          color: selectable && selected
              ? (selectedLabelColor ?? Colors.white)
              : (labelColor ?? Colors.black),
        ),
      );
    } else {
      labelWidget = label as Widget;
    }

    // 선택 가능한 Chip
    if (selectable) {
      return ChoiceChip(
        label: labelWidget,
        selected: selected,
        onSelected: onSelected,
        avatar: avatar,
        backgroundColor: backgroundColor,
        selectedColor: selectedColor ?? Colors.blue,
        labelStyle: TextStyle(
          color: selected
              ? (selectedLabelColor ?? Colors.white)
              : (labelColor ?? Colors.black),
        ),
        padding: padding,
        shape: borderRadius != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius!),
              )
            : null,
      );
    }

    // 삭제 가능한 Chip
    if (onDeleted != null) {
      return Chip(
        label: labelWidget,
        onDeleted: onDeleted,
        avatar: avatar,
        backgroundColor: backgroundColor,
        deleteIconColor: deleteIconColor,
        labelStyle: TextStyle(color: labelColor ?? Colors.black),
        padding: padding,
        shape: borderRadius != null
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius!),
              )
            : null,
        deleteIcon: deleteIcon != null
            ? Icon(deleteIcon, size: iconSize ?? 18)
            : null,
      );
    }

    // 기본 Chip
    Widget chip = Chip(
      label: labelWidget,
      avatar: avatar,
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(color: labelColor ?? Colors.black),
      padding: padding,
      shape: borderRadius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius!),
            )
          : null,
    );

    // tooltip이 있는 경우 Tooltip으로 감싸기
    if (tooltip != null) {
      chip = Tooltip(message: tooltip, child: chip);
    }

    return chip;
  }
}

