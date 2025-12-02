import 'custom_text.dart';
import 'custom_common_util.dart';
import 'package:flutter/material.dart';

/// 액션시트 아이템 클래스
/// 각 액션 항목의 정보를 담는 클래스입니다.
class ActionSheetItem {
  /// 액션 항목의 텍스트 또는 위젯
  /// String인 경우 CustomText로 자동 변환, Widget인 경우 그대로 사용
  final dynamic label;

  /// 액션 항목의 아이콘 (선택사항)
  final IconData? icon;

  /// 액션 항목의 텍스트 색상 (선택사항, 기본값: Colors.black)
  final Color? textColor;

  /// 액션 항목 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  /// 이 항목이 위험한 작업인지 여부 (true일 경우 빨간색으로 표시)
  final bool isDestructive;

  ActionSheetItem({
    required this.label,
    this.icon,
    this.textColor,
    this.onTap,
    this.isDestructive = false,
  }) : assert(
         CustomCommonUtil.isString(label) || CustomCommonUtil.isWidget(label),
         'label은 String 또는 Widget이어야 합니다.',
       );
}

/// ActionSheet 헬퍼 클래스
///
/// 사용 예시:
/// ```dart
/// CustomActionSheet.show(
///   context,
///   title: "선택하세요",
///   items: [ActionSheetItem(label: "옵션1", onTap: () {})],
/// )
/// ```
class CustomActionSheet {
  /// ActionSheet를 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    String? title,
    String? message,
    required List<ActionSheetItem> items,
    bool showCancel = true,
    String cancelText = "취소",
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor ?? Colors.white,
      shape: borderRadius != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(borderRadius),
              ),
            )
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목과 메시지
              if (title != null || message != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        CustomText(
                          title,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      if (message != null) ...[
                        if (title != null) const SizedBox(height: 4),
                        CustomText(
                          message,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ],
                  ),
                ),

              // 구분선
              if (title != null || message != null) const Divider(height: 20),

              // 액션 항목들
              ...items.map((item) {
                // label이 String인지 Widget인지 확인하고 처리
                Widget labelWidget;
                if (CustomCommonUtil.isString(item.label)) {
                  // String인 경우 CustomText로 변환
                  labelWidget = CustomText(
                    item.label as String,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: item.isDestructive
                        ? Colors.red
                        : (item.textColor ?? Colors.black),
                  );
                } else {
                  // Widget인 경우 그대로 사용
                  labelWidget = item.label as Widget;
                }

                return ListTile(
                  leading: item.icon != null
                      ? Icon(
                          item.icon,
                          color: item.isDestructive
                              ? Colors.red
                              : (item.textColor ?? Colors.black),
                        )
                      : null,
                  title: labelWidget,
                  onTap: () {
                    Navigator.pop(ctx);
                    item.onTap?.call();
                  },
                );
              }),

              // 취소 버튼
              if (showCancel) ...[
                const Divider(height: 8),
                ListTile(
                  title: CustomText(
                    cancelText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 간단한 액션시트를 표시하는 메서드 (라벨만 있는 경우)
  static Future<void> showSimple(
    BuildContext context, {
    required List<String> labels,
    required List<VoidCallback> callbacks,
    String? title,
    bool showCancel = true,
    String cancelText = "취소",
  }) {
    if (labels.length != callbacks.length) {
      throw ArgumentError("labels와 callbacks의 길이가 일치해야 합니다.");
    }

    final items = List.generate(
      labels.length,
      (index) => ActionSheetItem(label: labels[index], onTap: callbacks[index]),
    );

    return show(
      context,
      title: title,
      items: items,
      showCancel: showCancel,
      cancelText: cancelText,
    );
  }
}
