import 'custom_text.dart';
import 'custom_common_util.dart';
import 'package:flutter/material.dart';

/// Drawer 메뉴 항목 정보 클래스
class DrawerItem {
  /// 메뉴 항목의 텍스트 또는 위젯
  /// String인 경우 CustomText로 자동 변환, Widget인 경우 그대로 사용
  final dynamic label;

  /// 메뉴 항목의 아이콘 (선택사항)
  final IconData? icon;

  /// 메뉴 항목의 텍스트 색상 (선택사항, 기본값: Colors.black)
  final Color? textColor;

  /// 메뉴 항목 클릭 시 실행될 콜백
  final VoidCallback? onTap;

  /// 이 항목이 선택된 상태인지 여부
  final bool selected;

  /// 선택된 상태의 배경색
  final Color? selectedColor;

  /// 선택된 상태의 텍스트 색상
  final Color? selectedTextColor;

  DrawerItem({
    required this.label,
    this.icon,
    this.textColor,
    this.onTap,
    this.selected = false,
    this.selectedColor,
    this.selectedTextColor,
  }) : assert(
         CustomCommonUtil.isString(label) || CustomCommonUtil.isWidget(label),
         'label은 String 또는 Widget이어야 합니다.',
       );
}

/// 사이드 드로어 메뉴 위젯
///
/// 사용 예시:
/// ```dart
/// CustomDrawer(
///   header: DrawerHeader(...),
///   middleChildren: [
///     Divider(),
///     Padding(...), // 헤더와 items 사이에 일반 위젯 추가 가능
///   ],
///   items: [DrawerItem(label: "홈", icon: Icons.home, onTap: () {})],
///   bottomChildren: [
///     Divider(),
///     Padding(...), // items 아래 footer 위에 일반 위젯 추가 가능
///   ],
///   footer: Container(...),
/// )
/// ```
class CustomDrawer extends StatelessWidget {
  /// Drawer 상단에 표시할 헤더 위젯 (선택사항)
  final Widget? header;

  /// 헤더와 메뉴 항목 사이에 표시할 일반 위젯들 (선택사항)
  /// 헤더 아래, items 위에 표시됩니다.
  final List<Widget>? middleChildren;

  /// Drawer 메뉴 항목 리스트 (필수)
  final List<DrawerItem> items;

  /// 메뉴 항목과 푸터 사이에 표시할 일반 위젯들 (선택사항)
  /// items 아래, footer 위에 표시됩니다.
  final List<Widget>? bottomChildren;

  /// Drawer 배경색
  final Color? backgroundColor;

  /// Drawer 너비
  final double? width;

  /// Drawer 하단에 표시할 위젯 (선택사항)
  final Widget? footer;

  const CustomDrawer({
    super.key,
    this.header,
    this.middleChildren,
    required this.items,
    this.bottomChildren,
    this.backgroundColor,
    this.width,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: backgroundColor ?? Colors.white,
      width: width,
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            if (header != null)
              SizedBox(
                height: header is DrawerHeader ? null : 160,
                child: header!,
              ),

            // 헤더와 items 사이의 일반 위젯들
            if (middleChildren != null && middleChildren!.isNotEmpty) ...middleChildren!,

            // 메뉴 항목들 (items가 있으면 ListView, 없으면 빈 공간 확보용 Expanded)
            Expanded(
              child: items.isNotEmpty
                  ? ListView(
                      padding: EdgeInsets.zero,
                      children: items.map((item) {
                        // label이 String인지 Widget인지 확인하고 처리
                        Widget labelWidget;
                        if (CustomCommonUtil.isString(item.label)) {
                          // String인 경우 CustomText로 변환
                          labelWidget = CustomText(
                            item.label as String,
                            fontSize: 16,
                            fontWeight: item.selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: item.selected
                                ? (item.selectedTextColor ?? Colors.blue)
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
                                  color: item.selected
                                      ? (item.selectedTextColor ?? Colors.blue)
                                      : (item.textColor ?? Colors.black),
                                )
                              : null,
                          title: labelWidget,
                          selected: item.selected,
                          selectedTileColor: item.selectedColor ?? Colors.blue.shade50,
                          onTap: () {
                            Navigator.pop(context);
                            item.onTap?.call();
                          },
                        );
                      }).toList(),
                    )
                  : const SizedBox.shrink(),
            ),

            // items와 footer 사이의 일반 위젯들
            if (bottomChildren != null && bottomChildren!.isNotEmpty) ...bottomChildren!,

            // 푸터
            if (footer != null) footer!,
          ],
        ),
      ),
    );
  }
}

